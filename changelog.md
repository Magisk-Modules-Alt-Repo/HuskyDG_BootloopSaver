### v1.7

Add new way to trigger Safe Mode without using Custom Recovery: If you device does not have Custom Recovery, you can reboot (by holding the power) while in **boot animation** or **bootloop state**, in short **reboot while device is booting but not completed** will trigger Safe Mode in the next boot. 

This feature is not enabled by default, to enable this, create a blank file name "new_safemode" in one or more of these location:
- /cache
- /data/unencrypted
- /persist
- /metadata
- /mnt/vendor/persist