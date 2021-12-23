#
# This Makefile appends the public key extracted from stock ROM
# which is required to boot custom images on this device, since
# OPPO accidentally shipped an engineering bootloader on an earlier
# version.
#

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) cat $(COMMON_PATH)/boot/boot.patch >> $@
	$(hide) $(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_BOOTIMAGE_PARTITION_SIZE)))

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	$(call pretty,"Target recovery image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) cat $(COMMON_PATH)/boot/recovery.patch >> $@
	$(hide) $(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))

