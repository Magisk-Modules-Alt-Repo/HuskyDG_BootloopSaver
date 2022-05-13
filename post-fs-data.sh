MODULEDIR=${0%/*}
MAGISKTMP="$(magisk --path)"
. "$MODULEDIR/utils.sh"
DISABLE=false

touch "$MODULEDIR/skip_mount"

for dir in /cache /data/unencrypted /metadata /persist /mnt/vendor/persist; do
if [ -f "$dir/disable_magisk" ]; then
DISABLE=true
rm -rf "$dir/disable_magisk"
fi
done

$DISABLE && disable_modules