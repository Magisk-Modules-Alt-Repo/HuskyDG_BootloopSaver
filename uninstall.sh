MAGISKTMP="$(magisk --path)"
. /data/adb/magisk/util_functions.sh
get_flags
find_boot_image
( if [ ! -z "$BOOTIMAGE" ]; then
    ui_print "- Target boot image: $BOOTIMAGE"
    rm -rf "$TMPDIR/boot"
    mkdir -p "$TMPDIR/boot"
    dd if=$BOOTIMAGE of="$TMPDIR/boot/boot.img" || abort "! Unable to dump boot image"
    cd "$TMPDIR/boot" || exit 1
    ui_print "- Revert patch from boot image"
    /data/adb/magisk/magiskboot unpack boot.img
     /data/adb/magisk/magiskboot cpio ramdisk.cpio \
"rm overlay.d/safemode.rc" \
"rm -r overlay.d/sbin/bootloopsaver" \
"rm overlay.d/sbin/safemode.sh"
     /data/adb/magisk/magiskboot repack boot.img || abort "! Unable to repack boot image"
    ui_print "- Flashing new boot image"
     flash_image "$TMPDIR/boot/new-boot.img" "$BOOTIMAGE"
     case $? in
        1)
          abort "! Insufficient partition size"
          ;;
        2)
          abort "! $BOOTIMAGE is read only"
          ;;
     esac
    ui_print "- Done!"
fi )
