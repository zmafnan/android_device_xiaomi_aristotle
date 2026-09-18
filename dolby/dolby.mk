#
# Copyright (C) 2023-2026 The LineageOS Project
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

DOLBY_PATH := device/xiaomi/aristotle/dolby

# Codec support
AUDIO_FEATURE_ENABLED_DS2_DOLBY_DAP := true

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DOLBY_PATH)/sepolicy/vendor

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += $(DOLBY_PATH)/dolby_framework_matrix.xml
DEVICE_MANIFEST_FILE += $(DOLBY_PATH)/vendor.dolby.hardware.dms@2.0-service.xml

# MotoDolbyDax3, daxService, and vendor dependencies
PRODUCT_PACKAGES += \
    MotoDolbyDax3 \
    daxService \
    libsqlite.vendor

# Proprietary blobs
PRODUCT_COPY_FILES += \
    $(DOLBY_PATH)/proprietary/system_ext/etc/default-permissions/default-com.dolby.daxservice.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/default-permissions/default-com.dolby.daxservice.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/default-permissions/default-com.motorola.dolby.dolbyui.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/default-permissions/default-com.motorola.dolby.dolbyui.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/sysconfig/config-com.motorola.dolby.dolbyui.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/config-com.motorola.dolby.dolbyui.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/sysconfig/config-com.dolby.daxservice.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/config-com.dolby.daxservice.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/permissions/com.motorola.software.dolbyui.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/com.motorola.software.dolbyui.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/permissions/privapp-com.dolby.daxservice.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-com.dolby.daxservice.xml \
    $(DOLBY_PATH)/proprietary/system_ext/etc/permissions/privapp-com.motorola.dolby.dolbyui.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-com.motorola.dolby.dolbyui.xml \
    $(DOLBY_PATH)/proprietary/vendor/bin/hw/vendor.dolby.hardware.dms@2.0-service:$(TARGET_COPY_OUT_VENDOR)/bin/hw/vendor.dolby.hardware.dms@2.0-service \
    $(DOLBY_PATH)/proprietary/vendor/etc/init/vendor.dolby.hardware.dms@2.0-service.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/vendor.dolby.hardware.dms@2.0-service.rc \
    $(DOLBY_PATH)/proprietary/vendor/lib/libdapparamstorage.so:$(TARGET_COPY_OUT_VENDOR)/lib/libdapparamstorage.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/libdeccfg.so:$(TARGET_COPY_OUT_VENDOR)/lib/libdeccfg.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/libstagefright_soft_ac4dec.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstagefright_soft_ac4dec.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/libstagefright_soft_ddpdec.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstagefright_soft_ddpdec.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/libstagefrightdolby.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstagefrightdolby.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/soundfx/libswgamedap.so:$(TARGET_COPY_OUT_VENDOR)/lib/soundfx/libswgamedap.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/soundfx/libswdap.so:$(TARGET_COPY_OUT_VENDOR)/lib/soundfx/libswdap.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/soundfx/libswvqe.so:$(TARGET_COPY_OUT_VENDOR)/lib/soundfx/libswvqe.so \
    $(DOLBY_PATH)/proprietary/vendor/lib/vendor.dolby.hardware.dms@2.0.so:$(TARGET_COPY_OUT_VENDOR)/lib/vendor.dolby.hardware.dms@2.0.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libdapparamstorage.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libdapparamstorage.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libdeccfg.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libdeccfg.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libdlbdsservice.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libdlbdsservice.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libstagefright_soft_ac4dec.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libstagefright_soft_ac4dec.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libstagefright_soft_ddpdec.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libstagefright_soft_ddpdec.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/libstagefrightdolby.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libstagefrightdolby.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/soundfx/libswgamedap.so:$(TARGET_COPY_OUT_VENDOR)/lib64/soundfx/libswgamedap.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/soundfx/libswdap.so:$(TARGET_COPY_OUT_VENDOR)/lib64/soundfx/libswdap.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/soundfx/libswvqe.so:$(TARGET_COPY_OUT_VENDOR)/lib64/soundfx/libswvqe.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/vendor.dolby.hardware.dms@2.0-impl.so:$(TARGET_COPY_OUT_VENDOR)/lib64/vendor.dolby.hardware.dms@2.0-impl.so \
    $(DOLBY_PATH)/proprietary/vendor/lib64/vendor.dolby.hardware.dms@2.0.so:$(TARGET_COPY_OUT_VENDOR)/lib64/vendor.dolby.hardware.dms@2.0.so
