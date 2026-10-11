#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, vendor/neoteric/target/product/neoteric-target.mk)

$(call inherit-product, device/motorola/burton/device.mk)

PRODUCT_DEVICE := burton
PRODUCT_NAME := burton
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola edge plus
PRODUCT_MANUFACTURER := motorola

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="burton_reteu-user 12 S1PB32.41-10-17-3-4 f9362b-54db3 release-keys" \
    BuildFingerprint=motorola/burton_reteu/burton:12/S1PB32.41-10-17-3-4/f9362b-54db3:user/release-keys \
    DeviceName=burton \
    DeviceProduct=burton_reteu \
    SystemDevice=burton \
    SystemName=burton_reteu

PRODUCT_GMS_CLIENTID_BASE := android-motorola
