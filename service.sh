#!/system/bin/sh
#Bootloop saver by HuskyDG

MODULEDIR=${0%/*}
. "$MODULEDIR/utils.sh"

rm -rf /data/adb/rm_saver
cat <<EOF >/data/adb/rm_saver
#!/system/bin/sh
. /data/adb/magisk/util_functions.sh
. /data/adb/modules/${MODULEDIR##*/}/uninstall.sh
touch /data/adb/modules/${MODULEDIR##*/}/remove
reboot
EOF
chmod 777 /data/adb/rm_saver

post_fs_dir

mkdir -p "$MAGISKTMP/.magisk/${MODULEDIR##*/}"
cp "$MODULEDIR/module.prop" "$MAGISKTMP/.magisk/${MODULEDIR##*/}/module.prop"
mount --bind "$MAGISKTMP/.magisk/${MODULEDIR##*/}" "$MAGISKTMP/.magisk/modules/${MODULEDIR##*/}"

[ -f "$POSTFSDIR/note.txt" ] && MESSAGE="$(cat "$POSTFSDIR/note.txt" | head -c100)"

if [ -f "$MAGISKTMP/bootloopsaver/module.prop" ]; then
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ 😊 Script is installed in boot image. $MESSAGE ] /g" "$MAGISKTMP/.magisk/${MODULEDIR##*/}/module.prop"
else
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ 😵 Script is not installed in boot image. Please reinstall this module. $MESSAGE ] /g" "$MAGISKTMP/.magisk/${MODULEDIR##*/}/module.prop"
fi


rm -rf "$POSTFSDIR/bootloop_saver.log.bak"
mv -f "$POSTFSDIR/bootloop_saver.log" "$POSTFSDIR/bootloop_saver.log.bak" 2>/dev/null
write_log "bootloop saver started"
MAIN_ZYGOTE_NICENAME=zygote
CPU_ABI=$(getprop ro.product.cpu.api)
[ "$CPU_ABI" = "arm64-v8a" -o "$CPU_ABI" = "x86_64" ] && MAIN_ZYGOTE_NICENAME=zygote64

check(){
TEXT1="$1"
TEXT2="$2"
result=false
for i in $TEXT1; do
    for j in $TEXT2; do
        [ "$i" == "$j" ] && result=true
    done
done
$result
}


# Wait for zygote starts
sleep 5

ZYGOTE_PID1=$(pidof "$MAIN_ZYGOTE_NICENAME")
write_log "pid of zygote stage 1: $ZYGOTE_PID1"
sleep 15
ZYGOTE_PID2=$(pidof "$MAIN_ZYGOTE_NICENAME")
write_log "pid of zygote stage 2: $ZYGOTE_PID2"
sleep 15
ZYGOTE_PID3=$(pidof "$MAIN_ZYGOTE_NICENAME")
write_log "pid of zygote stage 3: $ZYGOTE_PID3"


if check "$ZYGOTE_PID1" "$ZYGOTE_PID2" && check "$ZYGOTE_PID2" "$ZYGOTE_PID3"; then
    if [ -z "$ZYGOTE_PID1" ]; then
        write_log "maybe zygote not start :("
        write_log "zygote meets the trouble, disable all modules and restart"

        disable_modules
    else
        exit_log "pid of 3 stage zygote is the same"
    fi
else
    write_log "pid of 3 stage zygote is different, continue check to make sure... "
fi




sleep 15
ZYGOTE_PID4=$(pidof "$MAIN_ZYGOTE_NICENAME")
write_log "pid of zygote stage 4: $ZYGOTE_PID4"
check "$ZYGOTE_PID3" "$ZYGOTE_PID4" && exit_log "pid of zygote stage 3 and 4 is the same."

write_log "zygote meets the trouble, disable all modules and restart"

disable_modules

