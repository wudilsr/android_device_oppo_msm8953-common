#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Include GSI keys
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@5.0-impl \
    android.hardware.audio.effect@5.0-impl \
    android.hardware.audio.service \
    android.hardware.bluetooth.audio@2.0-impl \
    android.hardware.soundtrigger@2.1-impl

PRODUCT_PACKAGES += \
    audio.a2dp.default \
    audio.bluetooth.default \
    audio.primary.msm8937 \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_PACKAGES += \
    liba2dpoffload \
    libaudioroute \
    libaacwrapper \
    libaudio-resampler \
    libaudiopreprocessing \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libqcompostprocbundle \
    libtinycompress \
    libvolumelistener \
    tinymix

# Bluetooth
PRODUCT_PACKAGES += \
    vendor.qti.hardware.bluetooth_audio@2.0.vendor \
    vendor.qti.hardware.btconfigstore@1.0.vendor

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/oppo/msm8937-common/msm8937-common-vendor.mk)
