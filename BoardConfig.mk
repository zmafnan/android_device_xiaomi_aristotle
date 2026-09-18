#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/aristotle

# Architecture & CPU
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a76
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Board Platform
TARGET_BOARD_PLATFORM := mt6895
TARGET_BOOTLOADER_BOARD_NAME := aristotle
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 480

# APEX
OVERRIDE_TARGET_FLATTEN_APEX := true

# Build Broken Rules
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Partitions & Storage
BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 33554432
BOARD_USES_METADATA_PARTITION := true

# A/B OTA partitions
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Dynamic Partitions (Super: 9.6 GB)
BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_SIZE := 9653190656
BOARD_MAIN_PARTITION_LIST := \
    system \
    system_ext \
    product \
    vendor \
    odm \
    vendor_dlkm \
    odm_dlkm \
    system_dlkm

# Filesystem Types
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

TARGET_USERIMAGES_USE_EXT4 := false
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# Kernel & Bootloader (Stock HyperOS 2 Linux 5.10.236)
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_KERNEL_TAGS_OFFSET := 0x07c88000
BOARD_DTB_OFFSET := 0x07c88000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 bootconfig
BOARD_RAMDISK_USE_LZ4 := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz
TARGET_PREBUILT_KERNEL_HEADERS := $(DEVICE_PATH)/prebuilt/kernel-uapi-headers.tar.gz
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_KERNEL_SOURCE :=
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_MKBOOTIMG_ARGS := --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

# Verified Boot (AVB)
BOARD_AVB_ENABLE := true
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_ALGORITHM := SHA256_RSA2048

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_SYSTEM := system system_dlkm system_ext
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR := vendor odm product vendor_dlkm odm_dlkm
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 4

# Recovery & Vendor Boot Packaging
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/fstab.mt6895
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USES_RECOVERY_AS_BOOT := false
TARGET_RECOVERY_DENSITY := xxhdpi
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true

# SELinux policy
include device/mediatek/sepolicy_vndr/SEPolicy.mk
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_ODM_PROP += $(DEVICE_PATH)/odm.prop

# Wi-Fi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_FW_PATH_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_STATE_ON := "1"
WIFI_DRIVER_STATE_OFF := "0"
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 2}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{AP_BRIDGED}, 1},}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{AP}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{P2P}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{NAN}, 1}}
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WIFI_FEATURE_HOSTAPD_11AX := true
WIFI_FEATURE_SUPPLICANT_11AX := true

# VINTF Manifests
DEVICE_MANIFEST_FILE += \
    $(DEVICE_PATH)/vintf/vendor/manifest.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/manifest_hwcomposer.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/gnss@2.1-service.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/android.hardware.security.keymint-service.mitee.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/android.hardware.security.secureclock-service.mitee.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/android.hardware.security.sharedsecret-service.mitee.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/vendor.xiaomi.hardware.vibratorfeature.service.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/android.hardware.neuralnetworks-shim-service-mtk.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/fod.xml \
    $(DEVICE_PATH)/vintf/odm/manifest_dsds.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/manifest_cameraprovider.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/manifest_android.hardware.drm@1.4-service.clearkey.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/manifest_android.hardware.drm@1.4-service.widevine.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/manifest_media_c2_V1_1_default.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/vendor.xiaomi.hardware.bgservice@1.0-service.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/vendor.dolby_3_8_5.hardware.dms.xml \
    $(DEVICE_PATH)/vintf/vendor/manifest/vendor.dolby_3_8_5.media.c2@1.0-service.xml

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/framework_compatibility_matrix.xml \
    hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml \
    hardware/xiaomi/vintf/xiaomi_framework_compatibility_matrix.xml


# Kernel Modules
include $(DEVICE_PATH)/modules.mk


# Inherit Vendor BoardConfig
-include vendor/xiaomi/aristotle/BoardConfigVendor.mk
-include vendor/lunaris/dolby/BoardConfigDolby.mk
