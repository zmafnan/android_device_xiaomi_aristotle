#!/usr/bin/env -S PYTHONPATH=../../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

"""Extract Xiaomi 13T (aristotle) HyperOS 2 baseline proprietary files."""

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    "device/xiaomi/aristotle",
    "hardware/mediatek",
    "hardware/xiaomi",
    "vendor/xiaomi/aristotle",
]


def lib_fixup_xiaomi_suffix(lib: str, partition: str, *args, **kwargs):
    """Disambiguate Xiaomi C++ blob from unrelated AOSP Rust crate."""
    return f"{lib}-xiaomi" if partition == "system_ext" else None


def lib_fixup_mtk_prebuilt_interface(lib: str, partition: str, *args, **kwargs):
    """Use existing HOS2 module names without selecting duplicate source HALs."""
    return lib.replace("@", "_") if partition == "vendor" else None


def lib_fixup_isp_interface(lib: str, partition: str, *args, **kwargs):
    if partition == "system_ext":
        return f"{lib}-systemext"
    return lib.replace("@", "_") if partition == "vendor" else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        "vendor.mediatek.hardware.camera.isphal@1.0",
        "vendor.mediatek.hardware.camera.isphal-V1-ndk",
    ): lib_fixup_isp_interface,
    ("libsink",): lib_fixup_xiaomi_suffix,
    tuple(f"vendor.mediatek.hardware.pq@2.{minor}" for minor in range(16))
    + (
        "vendor.mediatek.hardware.audio@8.1",
        "vendor.mediatek.hardware.bluetooth.audio@2.1",
        "vendor.mediatek.hardware.bluetooth.audio@2.2",
        "vendor.mediatek.hardware.mmagent@1.0",
    ): lib_fixup_mtk_prebuilt_interface,
}


blob_fixups: blob_fixups_user_type = {
    # Match the system libgui AIDL version; vendor-side ISP remains unchanged.
    "system_ext/lib64/vendor.mediatek.hardware.camera.isphal-V1-ndk.so": blob_fixup()
    .replace_needed("android.hardware.graphics.common-V5-ndk.so", "android.hardware.graphics.common-V7-ndk.so"),
    "system_ext/lib64/libcamera_ispinterface_jni.xiaomi.so": blob_fixup()
    .add_needed("libcamera_ispinterface_shim.so"),
    "vendor/bin/hw/android.hardware.security.keymint@1.0-service.mitee": blob_fixup()
    .replace_needed("android.hardware.keymaster@4.0.so", "android.hardware.keymaster@4.0-v31.so")
    .replace_needed("lib_android_keymaster_keymint_utils.so", "lib_android_keymaster_keymint_utils-v31.so")
    .replace_needed("libkeymaster_messages.so", "libkeymaster_messages-v31.so")
    .replace_needed("libkeymaster_portable.so", "libkeymaster_portable-v31.so")
    .replace_needed("libkeymint.so", "libkeymint-v31.so")
    .replace_needed("libcppbor_external.so", "libcppbor_external-v31.so")
    .replace_needed("libcppcose_rkp.so", "libcppcose_rkp-v31.so"),
    (
        "vendor/bin/hw/android.hardware.gnss-service.mediatek",
        "vendor/lib64/hw/android.hardware.gnss-impl-mediatek.so",
    ): blob_fixup().replace_needed(
        "android.hardware.gnss-V1-ndk_platform.so", "android.hardware.gnss-V1-ndk.so"
    ),
    (
        "vendor/bin/hw/vendor.mediatek.hardware.mtkpower@1.0-service",
        "vendor/lib64/android.hardware.power-service-mediatek.so",
    ): blob_fixup().replace_needed(
        "android.hardware.power-V2-ndk_platform.so", "android.hardware.power-V2-ndk.so"
    ),
    # Keep the frozen interface versions used by the HOS2 camera device blob.
    "vendor/lib64/android.hardware.camera.device-V1-ndk_platform.so": blob_fixup()
    .replace_needed("android.hardware.common-V2-ndk_platform.so", "android.hardware.common-V2-ndk.so")
    .replace_needed("android.hardware.common.fmq-V1-ndk_platform.so", "android.hardware.common.fmq-V1-ndk.so")
    .replace_needed("android.hardware.graphics.common-V2-ndk_platform.so", "android.hardware.graphics.common-V2-ndk.so"),
    # These consumers create Android Threads before acquiring a strong reference.
    (
        "vendor/bin/hw/camerahalserver",
        "vendor/bin/hw/mt6895/camerahalserver",
        "vendor/bin/hw/vendor.mediatek.hardware.pq@2.2-service",
        "vendor/lib64/libcam.utils.sensorprovider.so",
        "vendor/lib64/libmtkcam_hal_aidl_device.so",
        "vendor/lib64/libmtkcam_hal_android_app_cbadaptor.so",
        "vendor/lib64/libmtkcam_hal_android_device.so",
        "vendor/lib64/libpqpconfig.so",
    ): blob_fixup().replace_needed("libutils.so", "libutils-v32.so"),
    # PQ allocates the HOS2 tinyxml2 XMLDocument (0x308 bytes) on its stack.
    # The Android 16 layout is larger and corrupts saved registers on return.
    "vendor/lib64/hw/vendor.mediatek.hardware.pq@2.15-impl.so": blob_fixup()
    .replace_needed("libutils.so", "libutils-v32.so")
    .replace_needed("libsensorndkbridge.so", "android.hardware.sensors@1.0-convert-shared.so")
    .replace_needed("libtinyxml2.so", "libtinyxml2-vendorcompat.so"),
    "vendor/lib64/libaalservice.so": blob_fixup()
    .replace_needed("libutils.so", "libutils-v32.so")
    .replace_needed("libsensorndkbridge.so", "android.hardware.sensors@1.0-convert-shared.so"),
    "vendor/bin/mnld": blob_fixup().replace_needed(
        "libsensorndkbridge.so", "android.hardware.sensors@1.0-convert-shared.so"
    ),
    # Load compatible String16 symbols before dlopening libmtk-ril/libmtkutils.
    "vendor/bin/hw/mtkfusionrild": blob_fixup().add_needed("libutils-v32.so"),
    (
        "vendor/etc/init/hw/init.batterysecret.rc",
        "vendor/etc/init/hw/init.mi_thermald.rc",
    ): blob_fixup().regex_replace(".*seclabel.*\n", ""),
    (
        "vendor/lib64/libMiPhotoFilter.so",
        "vendor/lib64/mt6895/libneuralnetworks_sl_driver_mtk_prebuilt.so",
    ): blob_fixup()
    .clear_symbol_version("AHardwareBuffer_allocate")
    .clear_symbol_version("AHardwareBuffer_createFromHandle")
    .clear_symbol_version("AHardwareBuffer_describe")
    .clear_symbol_version("AHardwareBuffer_getNativeHandle")
    .clear_symbol_version("AHardwareBuffer_isSupported")
    .clear_symbol_version("AHardwareBuffer_lock")
    .clear_symbol_version("AHardwareBuffer_lockPlanes")
    .clear_symbol_version("AHardwareBuffer_release")
    .clear_symbol_version("AHardwareBuffer_unlock"),
    (
        "vendor/lib/libnvram.so",
        "vendor/lib/libsysenv.so",
        "vendor/lib64/libnvram.so",
        "vendor/lib64/libsysenv.so",
    ): blob_fixup().add_needed("libbase_shim.so"),
    "system_ext/lib64/libsink-mtk.so": blob_fixup().add_needed("libaudioclient_shim.so"),
    "system_ext/lib64/libimsma.so": blob_fixup().replace_needed(
        "libsink.so", "libsink-mtk.so"
    ),
    "vendor/lib/hw/audio.primary.mediatek.so": blob_fixup().replace_needed(
        "libstagefright_foundation.so", "libstagefright_foundation-v33.so"
    ),
    "vendor/lib64/hw/audio.primary.mediatek.so": blob_fixup()
    .add_needed("libstagefright_foundation-v33.so")
    .replace_needed("libalsautils.so", "libalsautils-v31.so"),
    (
        "vendor/lib64/libmtkcam_stdutils.so",
        "vendor/lib64/hw/android.hardware.camera.provider@2.6-impl-mediatek.so",
        "vendor/lib64/hw/mt6895/android.hardware.camera.provider@2.6-impl-mediatek.so",
    ): blob_fixup().replace_needed("libutils.so", "libutils-v32.so"),
    (
        "vendor/lib64/lib3a.flash.so",
        "vendor/lib64/lib3a.sensors.color.so",
        "vendor/lib64/lib3a.sensors.flicker.so",
    ): blob_fixup().add_needed("liblog.so"),
    (
        "vendor/lib64/libcam.hal3a.so",
        "vendor/lib64/libcam.hal3a.ctrl.so",
        "vendor/lib64/libmtkcam_request_requlator.so",
        "vendor/lib64/libmialgoengine.so",
    ): blob_fixup().add_needed("libprocessgroup_shim.so"),
}


module = ExtractUtilsModule(
    "aristotle",
    "xiaomi",
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)


if __name__ == "__main__":
    ExtractUtils.device(module).run()
