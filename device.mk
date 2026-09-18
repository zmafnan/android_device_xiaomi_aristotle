#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/xiaomi/aristotle

# ---------------------------------------------------------------------------
# Apply device-tree source patches to upstream repos (idempotent).
# Patches live in $(LOCAL_PATH)/patches/ and are named after the repo they
# target (e.g. packages_modules_Connectivity.patch → packages/modules/Connectivity/).
# The script uses `git apply --check` to skip already-applied patches, so
# re-running on subsequent builds is safe and fast.
# infinity/ source trees are never modified directly; all customisations for
# this device stay inside HOS2_Source_Aristotle/device/xiaomi/aristotle/.
# ---------------------------------------------------------------------------
$(shell bash device/xiaomi/aristotle/patches/apply-patches.sh 2>&1 | \
    sed 's/^/[aristotle-patch] /' >&2)

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Enable project quotas and casefolding for emulated storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Dalvik VM configuration
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

PRODUCT_SHIPPING_API_LEVEL := 33
PRODUCT_ENFORCE_VINTF_MANIFEST := true
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := false

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/mediatek \
    hardware/xiaomi \
    vendor/xiaomi/aristotle

PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE := erofs

# Recovery & OTA
PRODUCT_PACKAGES += \
    checkpoint_gc \
    create_pl_dev \
    create_pl_dev.recovery \
    fastbootd \
    android.hardware.fastboot@1.1-impl.custom \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# BootControl AIDL
PRODUCT_PACKAGES += \
    com.android.hardware.boot \
    android.hardware.boot-service.default_recovery

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.mediatek \
    android.hardware.health-service.mediatek-recovery \
    vendor.lineage.health-service.default

$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/power_supply/battery/input_suspend)
$(call soong_config_set,lineage_health,charging_control_charging_enabled,0)
$(call soong_config_set,lineage_health,charging_control_charging_disabled,1)
$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr \
    vendor.mediatek.hardware.mtkpower@1.2-service.stub \
    vendor.mediatek.hardware.mtkpower@1.0.vendor \
    vendor.mediatek.hardware.mtkpower@1.1.vendor \
    vendor.mediatek.hardware.mtkpower@1.2.vendor

# Graphics composer service for the stock HIDL HWC implementation & Gralloc dependencies
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.3-service \
    android.hardware.graphics.allocator@4.0.vendor \
    android.hardware.graphics.common@1.0.vendor \
    android.hardware.graphics.common@1.1.vendor \
    android.hardware.graphics.common@1.2.vendor \
    android.hardware.graphics.mapper@2.0.vendor \
    android.hardware.graphics.mapper@2.1.vendor \
    android.hardware.graphics.mapper@3.0.vendor \
    android.hardware.graphics.mapper@4.0.vendor \
    libgralloctypes.vendor \
    libdmabufheap.vendor \
    libdrm.vendor \
    libion.vendor \
    libbase_shim \
    libaudioclient_shim

# Stock HOS2 KeyMint ABI required by the Android 31 MiTEE service
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-v31 \
    android.hardware.keymaster@4.0-v31 \
    android.hardware.security.keymint-V1-ndk_platform-v31 \
    android.hardware.security.secureclock-V1-ndk_platform-v31 \
    android.hardware.security.sharedsecret-V1-ndk_platform-v31 \
    lib_android_keymaster_keymint_utils-v31 \
    libcppbor_external-v31 \
    libcppcose_rkp-v31 \
    libkeymaster_messages-v31 \
    libkeymaster_portable-v31 \
    libkeymint-v31 \
    libpuresoftkeymasterdevice-v31 \
    libsoft_attestation_cert-v31

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# Audio
$(call soong_config_set_bool,android_hardware_audio,skip_speaker_layout_channel_mask_field,true)

PRODUCT_PACKAGES += \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.soundtrigger@2.3-impl \
    android.hardware.audio.service \
    android.hardware.audio@7.1.vendor \
    android.hardware.audio@7.0.vendor \
    android.hardware.audio.common@7.0.vendor \
    android.hardware.audio.common@7.0-util.vendor \
    android.hardware.audio.common@7.1-util.vendor \
    android.hardware.audio.common-util.vendor \
    android.hardware.audio.common@5.0.vendor \
    android.hardware.audio.effect@7.0.vendor \
    android.hardware.audio.effect@7.0-util.vendor \
    android.hardware.soundtrigger@2.3.vendor \
    android.hardware.bluetooth.audio@2.1.vendor \
    android.hidl.safe_union@1.0.vendor \
    audio.primary.default \
    audio.bluetooth.default \
    audio.r_submix.default \
    libaudiofoundation.vendor \
    libmediautils_vendor.vendor \
    libnbaio_mono \
    libtinycompress \
    libalsautils-v31 \
    libstagefright_foundation-v33.vendor \
    libjsoncpp.vendor \
    audio.usb.default \
    android.hardware.bluetooth.audio-impl \
    MtkInCallService \
    android.hardware.gnss-V1-ndk \
    android.hardware.gnss-V1-ndk.vendor

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/audio/,$(TARGET_COPY_OUT_VENDOR)/etc) \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_in_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_in_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml

# MediaTek C2 Stagefright Foundation stock library for MTK vdec ABI compatibility
PRODUCT_COPY_FILES += \
    vendor/xiaomi/aristotle/proprietary/vendor/lib64/libstagefright_foundation.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libstagefright_foundation_stock.so \
    vendor/xiaomi/aristotle/proprietary/vendor/lib/libstagefright_foundation.so:$(TARGET_COPY_OUT_VENDOR)/lib/libstagefright_foundation_stock.so

# Camera
PRODUCT_PACKAGES += AristotleMiuiCamera

# Frozen system-side interfaces needed by the Leica ISP JNI client.
PRODUCT_PACKAGES += \
    libcamera_ispinterface_shim \
    android.hardware.common-V2-ndk \
    android.hardware.graphics.common-V7-ndk \
    android.hardware.graphics.common@1.0 \
    android.hardware.graphics.common@1.1

PRODUCT_PACKAGES += \
    android.hardware.common-V2-ndk.vendor \
    android.hardware.common.fmq-V1-ndk.vendor \
    android.hardware.graphics.common-V2-ndk.vendor \
    android.hardware.camera.provider@2.4.vendor \
    android.hardware.camera.provider@2.5.vendor \
    android.hardware.camera.provider@2.6.vendor \
    android.hardware.camera.common@1.0.vendor \
    android.hardware.camera.device@1.0.vendor \
    android.hardware.camera.device@3.2.vendor \
    android.hardware.camera.device@3.3.vendor \
    android.hardware.camera.device@3.4.vendor \
    android.hardware.camera.device@3.5.vendor \
    android.hardware.camera.device@3.6.vendor \
    android.hardware.camera.device@3.7.vendor \
    android.hardware.graphics.common@1.1.vendor \
    android.hardware.graphics.allocator@4.0.vendor \
    android.hardware.graphics.mapper@4.0.vendor \
    android.frameworks.displayservice@1.0.vendor \
    android.frameworks.sensorservice@1.0.vendor \
    libsensorndkbridge \
    libcamera_metadata.vendor

# HOS2 sensor conversion and legacy Thread/String16 consumers
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-convert-shared.vendor \
    libutils-v32 \
    libprocessgroup_shim

# Wi-Fi
$(call soong_config_set_bool,mediatek_wifi_hal,use_pre_u_qpr2_struct,true)

PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libwifi-hal-wrapper \
    wpa_supplicant \
    libnl.vendor

PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/configs/wifi/,$(TARGET_COPY_OUT_VENDOR)/etc/wifi)

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth-service.mediatek \
    android.hardware.bluetooth.audio@2.0.vendor \
    android.hardware.bluetooth.audio@2.1.vendor \
    android.hardware.bluetooth.audio@2.2.vendor \
    libbt-vendor

# Network & Radio
PRODUCT_PACKAGES += \
    com.android.hardware.net.nlinterceptor \
    android.hardware.radio@1.0.vendor \
    android.hardware.radio@1.1.vendor \
    android.hardware.radio@1.2.vendor \
    android.hardware.radio@1.3.vendor \
    android.hardware.radio@1.4.vendor \
    android.hardware.radio@1.5.vendor \
    android.hardware.radio@1.6.vendor \
    android.hardware.radio.config@1.0.vendor \
    android.hardware.radio.config@1.1.vendor \
    android.hardware.radio.config@1.2.vendor \
    android.hardware.radio.config@1.3.vendor \
    XiaomiEuicc \
    Photos


# Vendor HALs & Libraries
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0.vendor \
    android.hardware.usb@1.1.vendor \
    android.hardware.usb@1.2.vendor \
    android.hardware.usb@1.3.vendor \
    android.hardware.usb.gadget@1.0.vendor \
    android.hardware.usb.gadget@1.1.vendor \
    android.hardware.usb.gadget@1.2.vendor \
    android.hardware.gnss@1.0.vendor \
    android.hardware.gnss@1.1.vendor \
    android.hardware.gnss@2.0.vendor \
    android.hardware.gnss@2.1.vendor \
    android.hardware.drm@1.0.vendor \
    android.hardware.drm@1.1.vendor \
    android.hardware.drm@1.2.vendor \
    android.hardware.drm@1.3.vendor \
    android.hardware.drm@1.4.vendor \
    android.hardware.secure_element@1.0.vendor \
    android.hardware.secure_element@1.1.vendor \
    android.hardware.secure_element@1.2.vendor \
    android.hardware.power@1.0.vendor \
    android.hardware.power@1.1.vendor \
    android.hardware.power@1.2.vendor \
    android.hardware.power-V2-ndk \
    android.hardware.power-V2-ndk.vendor \
    android.hardware.media.c2@1.0.vendor \
    android.hardware.media.c2@1.1.vendor \
    android.hardware.media.c2@1.2.vendor \
    vndservicemanager \
    vendor.xiaomi.hardware.displayfeature@1.0 \
    vendor.xiaomi.hardware.displayfeature@1.0.vendor \
    libprotobuf-cpp-lite-3.9.1-vendorcompat \
    libcodec2_hidl@1.0.vendor \
    libcodec2_hidl@1.1.vendor \
    libcodec2_hidl@1.2.vendor \
    libcodec2_vndk.vendor \
    libcodec2_soft_common.vendor \
    libsfplugin_ccodec_utils.vendor \
    libcodec2_hal_common.vendor \
    libavservices_minijail_vendor \
    libexpat.vendor \
    libcurl.vendor \
    libssl.vendor \
    libpcap.vendor \
    libnetutils.vendor

# Fingerprint / UDFPS
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi \
    libudfpshandler \
    vendor.xiaomi.hardware.fx.tunnel@1.0.vendor \
    libhidltransport \
    libhidltransport.vendor \
    libhwbinder \
    libhwbinder.vendor \
    libion.vendor

# Permissions & Feature XMLs
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.calling.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.calling.xml \
    frameworks/native/data/etc/android.hardware.telephony.data.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.data.xml \
    frameworks/native/data/etc/android.hardware.telephony.euicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.euicc.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.telephony.messaging.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.messaging.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_3.xml \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml \
    $(LOCAL_PATH)/configs/adb_keys:root/adb_keys \
    $(LOCAL_PATH)/configs/adb_keys:$(TARGET_COPY_OUT_PRODUCT)/etc/security/adb_keys \
    $(LOCAL_PATH)/configs/adb_keys:$(TARGET_COPY_OUT_SYSTEM)/etc/security/adb_keys

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-service.lineage

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras \
    Tag

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.0-subhal-impl-1.0 \
    android.hardware.sensors-service.xiaomi-multihal \
    sensors.xiaomi.aristotle \
    sensors.dynamic_sensor_hal

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Codec2 & Health
PRODUCT_PACKAGES += \
    libcodec2.vendor \
    android.hardware.health@1.0.vendor

# Vibrator, IFAA & Power
PRODUCT_PACKAGES += \
    IFAAService \
    PowerOffAlarm \
    vibratorfeature-wrapper

# ConsumerIr
PRODUCT_PACKAGES += \
    android.hardware.ir-service.example \
    android.hardware.consumerir.prebuilt.xml

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.consumerir=common \
    ro.vendor.sensors.xiaomi.double_tap=true \
    ro.vendor.sensors.xiaomi.udfps=true

# Overlays
PRODUCT_PACKAGES += \
    CarrierConfigOverlayMT6895 \
    FrameworksResOverlayMT6895 \
    LineageApertureOverlayMT6895 \
    LineageDialerMT6895 \
    LineageSDKOverlayMT6895 \
    LineageSettingsOverlayMT6895 \
    LineageSystemUIOverlayMT6895 \
    PowerOffAlarmOverlayMT6895 \
    SettingsOverlayMT6895 \
    SystemUIOverlayMT6895 \
    TetheringResOverlayMT6895 \
    WifiResOverlayMT6895

# Copy Files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/fstab.mt6895:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.mt6895 \
    $(LOCAL_PATH)/rootdir/fstab.mt6895:$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/fstab.mt6895 \
    $(LOCAL_PATH)/rootdir/fstab.mt6895:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6895 \
    $(LOCAL_PATH)/rootdir/init.mt6895.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6895.rc \
    $(LOCAL_PATH)/rootdir/init.mtkgki.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mtkgki.rc \
    $(LOCAL_PATH)/rootdir/init.batterysecret.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.batterysecret.rc \
    $(LOCAL_PATH)/rootdir/init.cgroup.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.cgroup.rc \
    $(LOCAL_PATH)/rootdir/init.connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.connectivity.rc \
    $(LOCAL_PATH)/rootdir/init.connectivity.common.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.connectivity.common.rc \
    $(LOCAL_PATH)/rootdir/init_conninfra.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init_conninfra.rc \
    $(LOCAL_PATH)/rootdir/init.mi_thermald.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mi_thermald.rc \
    $(LOCAL_PATH)/rootdir/init.sensor_2_0.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.sensor_2_0.rc \
    $(LOCAL_PATH)/rootdir/init.project.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.project.rc \
    $(LOCAL_PATH)/rootdir/init.mt6895.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6895.usb.rc \
    $(LOCAL_PATH)/rootdir/init.fingerprint.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.fingerprint.rc \
    $(LOCAL_PATH)/rootdir/ueventd.mt6895.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \
    $(LOCAL_PATH)/rootdir/init.mt6895.power.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6895.power.rc \
    vendor/xiaomi/aristotle/proprietary/vendor/libnfc-nxp_RF.conf:$(TARGET_COPY_OUT_VENDOR)/libnfc-nxp_RF.conf \
    $(LOCAL_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json \
    $(LOCAL_PATH)/configs/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/configs/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_dolby_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_dolby_audio.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_mediatek_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_audio.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_system_default.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_system_default.xml \
    $(LOCAL_PATH)/configs/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/configs/media/mtk_platform_codecs_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mtk_platform_codecs_config.xml \
    $(LOCAL_PATH)/configs/seccomp/android.hardware.media.c2@1.2-extended-seccomp-policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/android.hardware.media.c2@1.2-extended-seccomp-policy \
    $(LOCAL_PATH)/configs/seccomp/android.hardware.media.c2@1.2-mediatek-seccomp-policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/android.hardware.media.c2@1.2-mediatek-seccomp-policy \
    $(LOCAL_PATH)/configs/seccomp/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy \
    $(LOCAL_PATH)/configs/seccomp/mediaextractor.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaextractor.policy \
    $(LOCAL_PATH)/configs/seccomp/mediaswcodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediaswcodec.policy

$(call inherit-product, vendor/mediatek/ims/ims.mk)
$(call inherit-product-if-exists, vendor/xiaomi/aristotle/aristotle-vendor.mk)

# USB
$(call soong_config_set_bool,android_hardware_mediatek_usb,audio_accessory_supported,true)

PRODUCT_PACKAGES += \
    android.hardware.usb-service.mediatek \
    android.hardware.usb.gadget-service.mediatek

# Filter out deprecated/broken vendor lights & USB HALs inherited from aristotle-vendor.mk
PRODUCT_PACKAGES := $(filter-out android.hardware.lights-service.mediatek android.hardware.usb_1.2-service-mediatekv2,$(PRODUCT_PACKAGES))
PRODUCT_COPY_FILES := $(filter-out %/lights-mtk-default.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/lights-mtk-default.rc %/android.hardware.usb@1.2-service-mediatekv2.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.usb@1.2-service-mediatekv2.rc,$(PRODUCT_COPY_FILES))

# Stock clients required by Leica PerfLock and FPSGO/GBE dlopen callers.
PRODUCT_PACKAGES += \
    libmtkperf_client_vendor-stock \
    libperfctl_vendor-stock

# Tethering offload
PRODUCT_PACKAGES += android.hardware.tetheroffload-V1-ndk

# Fallback for CLOSE_RANGE_CLOEXEC on the stock kernel.
PRODUCT_PACKAGES += libnetd_close_range_compat

# Suppress noisy MTK vendor logs
include $(LOCAL_PATH)/vendor_logtag.mk

# Dolby Atmos (Lunaris AOSP)
$(call inherit-product-if-exists, vendor/lunaris/dolby/dolby.mk)
