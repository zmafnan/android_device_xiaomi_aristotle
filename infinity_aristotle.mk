#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Disable deprecated HIDL CAS HAL before base_vendor.mk is inherited
TARGET_REQUIRES_HIDL_CAS_HAL := false

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Enable insecure ADB during bringup
WITH_ADB_INSECURE := true

$(call inherit-product, device/xiaomi/aristotle/device.mk)
$(call inherit-product, vendor/infinity/config/common_full_phone.mk)

# Maintainer Name
INFINITY_MAINTAINER := Zikri Afnan

# Whether the device supports Fingerprint On Display
TARGET_HAS_UDFPS := true

# Whether Including Google Apps
WITH_GAPPS := true

# Comms Suite (Google Dialer & Messages)
PRODUCT_PACKAGES += \
    GoogleDialer \
    Messages

# Android System Intelligence (ASI)
$(call inherit-product-if-exists, device/xiaomi/aristotle/asi/asi.mk)

PRODUCT_NAME := infinity_aristotle
PRODUCT_DEVICE := aristotle
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := 2306EPN60G

PRODUCT_SYSTEM_NAME := aristotle_global
PRODUCT_SYSTEM_DEVICE := aristotle

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="aristotle_global-user 15 AP3A.240905.015.A2 OS2.0.214.0.VMFMIXM release-keys" \
    BuildFingerprint=Xiaomi/aristotle_global/aristotle:15/AP3A.240905.015.A2/OS2.0.214.0.VMFMIXM:user/release-keys \
    DeviceName=aristotle \
    DeviceProduct=aristotle_global \
    SystemDevice=aristotle \
    SystemName=aristotle_global
