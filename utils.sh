FILE="$0"; NAME="$1"; VALUE="$2"; MODID="/data/adb/modules/huskydg_bootloopsaver"; VX="$@"

MODULEDIR=${0%/*}
MAGISKTMP="$(magisk --path)"
abort(){ echo "$1"; exit 1; }

post_fs_dir(){
  unset POSTFSDIR
  if [ -d /data/unencrypted ] && ! grep ' /data ' /proc/mounts | grep -qE 'dm-|f2fs'; then
    POSTFSDIR="/data/unencrypted/${MODULEDIR##*/}"
  elif grep ' /cache ' /proc/mounts | grep -q 'ext4' ; then
    POSTFSDIR="/cache/${MODULEDIR##*/}"
  elif grep ' /metadata ' /proc/mounts | grep -q 'ext4' ; then
    POSTFSDIR="/metadata/${MODULEDIR##*/}"
  elif grep ' /persist ' /proc/mounts | grep -q 'ext4' ; then
    POSTFSDIR="/persist/${MODULEDIR##*/}"
  elif grep ' /mnt/vendor/persist ' /proc/mounts | grep -q 'ext4' ; then
    POSTFSDIR="/mnt/vendor/persist/${MODULEDIR##*/}"
  elif [ ! -z "$MAGISKTMP" ]; then
    POSTFSDIR="$MAGISKTMP/.magisk/${MODULEDIR##*/}"
  else
    POSTFSDIR="/dev/${MODULEDIR##*/}"
  fi
  [ ! -z "$POSTFSDIR" ] && mkdir -p "$POSTFSDIR"
}
 post_fs_dir


write_log(){ 
TEXT=$@; echo "[`date +%d%m%y` `date +%T`]: $TEXT" >>"$POSTFSDIR/bootloop_saver.log"
}

exit_log(){
write_log "$@"; exit 0;
}

grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1
}


disable_modules(){
COUNT=0
list="$(find /data/adb/modules/* -prune -type d)"
IFS=$"
"
for module in $list; do
COUNT="$(($COUNT+1))"
echo -n >> $module/disable
done

## Disable all modules except itself

rm -rf "$MODULEDIR/disable"
COUNT="$(($COUNT-1))"
echo "I disabled $COUNT modules at `date +%d.%m.%y` `date +%T`" >"$POSTFSDIR/note.txt"
    rm -rf /cache/.system_booting /data/unencrypted/.system_booting /metadata/.system_booting /persist/.system_booting /mnt/vendor/persist/.system_booting
reboot
exit
}


