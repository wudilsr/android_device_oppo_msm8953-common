# Copyright (C) 2021 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This Makefile appends the public key extracted from stock ROM,
# which is required to boot custom images on this device, since
# OPPO accidentally shipped an engineering bootloader that allowed
# for custom images on an earlier version.
#

LOCAL_PATH := $(call my-dir)

BOOT_PATCH := $(COMMON_PATH)/boot

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty, "Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) cat $(BOOT_PATCH)/boot.patch >> $@
	$(hide) $(call assert-max-image-size, $@, $(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo "Made boot image: $@"

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) cat $(BOOT_PATCH)/recovery.patch >> $@
	$(hide) $(call assert-max-image-size, $@, $(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo "Made recovery image: $@"
