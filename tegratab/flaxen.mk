# NVIDIA Tegra4 "Tegratab" development system
#
# Copyright (c) 2012-2013, NVIDIA Corporation.  All rights reserved.
# AndroidProducts.mk is included before BoardConfig.mk, variable essential at
# start of build and used in here should always be intialized in this file

# SECURE_OS_BUILD, NV_TN_SKU and NV_TN_PLATFORM can be set from environment
# because of ?= intialization

# SECURE_OS_BUILD - allowed values y,n
# default: y
SECURE_OS_BUILD ?= y

# NV_TN_SKU - allowed values flaxen, blond
# Default: flaxen
NV_TN_SKU ?= flaxen

## REFERENCE_DEVICE
REFERENCE_DEVICE := flaxen

## NV_TN_PLATFORM
NV_TN_PLATFORM := premium

## NV_TN_WITH_GMS - allowed values true, false
NV_TN_WITH_GMS := true

## DEV_TEGRATAB_PATH
DEV_TEGRATAB_PATH := device/nvidia/tegratab

$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)

## Thse are default settings, it gets changed as per sku manifest properties
PRODUCT_NAME := flaxen
PRODUCT_DEVICE := tegratab
PRODUCT_MODEL := TegraNote-Premium
PRODUCT_MANUFACTURER := NVIDIA
PRODUCT_BRAND := nvidia
PRODUCT_LOCALES += en_US


## Property overrides
PRODUCT_PROPERTY_OVERRIDES += ro.com.google.clientidbase=android-nvidia

#Enable TI BT power table
TI_BT_POWER_TABLE := true

#Enable beats audio
BOARD_SUPPORT_BEATS := true

#power table for TI WiFi Wl18xx
WL18XX_POWER_TABLE := true

#Enable power hint for Auido playback with speaker
AUDIO_SPEAKER_POWER_HINT := true

# Configuration files for Beats
ifeq ($(wildcard vendor/nvidia/flaxen/beats),vendor/nvidia/flaxen/beats)
PRODUCT_COPY_FILES += \
    vendor/nvidia/flaxen/beats/BeatsSpeakerProfile.bin:system/etc/BeatsSpeakerProfile.bin \
    vendor/nvidia/flaxen/beats/BeatsHpProfile.bin:system/etc/BeatsHpProfile.bin
endif

# Beats
PRODUCT_PACKAGES += \
    libbeatsaudio.so \
    BeatsSpeakerProfile.bin \
    BeatsHpProfile.bin


# SKU specific packages, variables resides in sku specific device makefile
$(call inherit-product, device/nvidia/tegratab/skus/flaxen/$(NV_TN_SKU).mk)

## Rest of the packages
$(call inherit-product, device/nvidia/tegratab/device.mk)
$(call inherit-product-if-exists, device/nvidia/tegratab/lbh/lbh.mk)

ifeq ($(wildcard device/nvidia/tegratab/lbh),device/nvidia/tegratab/lbh)
PRODUCT_COPY_FILES += \
device/nvidia/tegratab/lbh/1124_nvaudio_conf.xml:system/etc/lbh/1124_nvaudio_conf.xml \
    device/nvidia/tegratab/lbh/1124_nvaudio_tune.xml:system/etc/lbh/1124_nvaudio_tune.xml \
    device/nvidia/tegratab/lbh/1124_audioConfig_qvoice_icera_pc400.xml:system/etc/lbh/1124_audioConfig_qvoice_icera_pc400.xml \
    device/nvidia/tegratab/lbh/1124_nvaudio_fx.xml:system/etc/lbh/1124_nvaudio_fx.xml
endif

$(call inherit-product-if-exists, vendor/nvidia/tegra/secureos/nvsi/nvsi.mk)
$(call inherit-product-if-exists, vendor/nvidia/tegra/tegratab/partition-data/factory-ramdisk/factory.mk)
