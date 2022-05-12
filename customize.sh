MAGISKTMP="$(magisk --path)"
get_flags
find_boot_image
( if [ ! -z "$BOOTIMAGE" ]; then
    ui_print "- Target boot image: $BOOTIMAGE"
    # This is how the magisk app detect if boot image contain ramdisk
    ( if [ "$RECOVERYMODE" = "true" ] || 
        ([ ! "$(getprop ro.build.ab_update)" = "true" ] && 
            grep ' / ' /proc/mounts | grep -q '/dev/root' &> /dev/root); then
        ui_print "! Boot image doesn't contain ramdisk"
    else
        mkdir "$TMPDIR/boot"
        dd if=$BOOTIMAGE of="$TMPDIR/boot/boot.img"
        ui_print "- Unpack boot image"
        cd "$TMPDIR/boot" || exit 1
        /data/adb/magisk/magiskboot unpack boot.img
        ui_print "- Add bootloop protector script"
        cat <<EOF > safemode.rc
# safe mode trigger
on post-fs
    exec u:r:magisk:s0 root root -- /system/bin/sh \${MAGISKTMP}/safemode.sh

EOF
        cat <<EOF >safemode.sh
for dir in /cache /data/unencrypted /metadata /persist /mnt/vendor/persist; do
if [ -f "\$dir/disable_magisk" ]; then
    DISABLE=true
    rm -rf "\$dir/disable_magisk"
fi
done

[ "\$DISABLE" == "true" ] && setprop persist.sys.safemode 1
EOF
         /data/adb/magisk/magiskboot cpio ramdisk.cpio \
"mkdir 0750 overlay.d" \
"mkdir 0750 overlay.d/sbin" \
"rm overlay.d/safemode.rc" \
"rm overlay.d/sbin/safemode.sh" \
"add 0750 overlay.d/safemode.rc safemode.rc" \
"add 0750 overlay.d/sbin/safemode.sh safemode.sh"
         ui_print "- Repack boot image"
         /data/adb/magisk/magiskboot repack boot.img
         ui_print "- Flashing new boot image"
         dd of=$BOOTIMAGE if="$TMPDIR/boot/new-boot.img"
    fi )
else
    ui_print "! Cannot detect target boot image"
fi )



ui_print "- Module log is /cache/bootloop_saver.log"
