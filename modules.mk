#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# HyperOS 2 (OS2.0.214.0.VMFMIXM) stock kernel 5.10.236 modules

ARISTOTLE_MODULES_PATH := device/xiaomi/aristotle/prebuilt/modules

# Complete bit-exact platform module set extracted from the Aristotle HOS2
# vendor_boot ramdisk. Keep this separate from vendor_dlkm: these modules are
# needed before vendor_dlkm is mounted and by recovery.
ARISTOTLE_VENDOR_RAMDISK_MODULES_PATH := $(ARISTOTLE_MODULES_PATH)/vendor_ramdisk

BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    $(wildcard $(ARISTOTLE_VENDOR_RAMDISK_MODULES_PATH)/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(ARISTOTLE_VENDOR_RAMDISK_MODULES_PATH)/modules.load 2>/dev/null))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(ARISTOTLE_VENDOR_RAMDISK_MODULES_PATH)/modules.load.recovery 2>/dev/null))
BOARD_DO_NOT_STRIP_VENDOR_RAMDISK_MODULES := true

BOARD_VENDOR_KERNEL_MODULES := \
    $(wildcard $(ARISTOTLE_MODULES_PATH)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := \
    $(strip $(shell cat $(ARISTOTLE_MODULES_PATH)/vendor_dlkm/modules.load 2>/dev/null))
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true

BOARD_SYSTEM_KERNEL_MODULES :=
BOARD_SYSTEM_KERNEL_MODULES_LOAD :=
BOARD_DO_NOT_STRIP_SYSTEM_MODULES := true

BOARD_ODM_KERNEL_MODULES :=
