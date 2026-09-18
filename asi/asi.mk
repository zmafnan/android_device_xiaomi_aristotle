#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Android System Intelligence (ASI)
PRODUCT_PACKAGES += \
    AndroidSystemIntelligence

PRODUCT_COPY_FILES += \
    device/xiaomi/aristotle/asi/privapp-permissions-asi.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-asi.xml
