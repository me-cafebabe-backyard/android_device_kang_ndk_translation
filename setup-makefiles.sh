#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=ndk_translation
VENDOR=kang

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

cat << EOF >> $PRODUCTMK
ifneq (\$(filter %x86_64 %x86_64%,\$(TARGET_PRODUCT)),)
EOF

write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers

cat << EOF >> $PRODUCTMK

include frameworks/libs/native_bridge_support/native_bridge_support.mk

PRODUCT_SOONG_NAMESPACES += \\
    frameworks/libs/native_bridge_support/android_api/libc

PRODUCT_PACKAGES += \\
    \$(NATIVE_BRIDGE_PRODUCT_PACKAGES)

PRODUCT_SYSTEM_PROPERTIES += \\
    ro.dalvik.vm.native.bridge=libndk_translation.so \\
    ro.dalvik.vm.isa.arm64=x86_64 \\
    ro.dalvik.vm.isa.arm=x86 \\
    ro.enable.native.bridge.exec=1 \\
    ro.ndk_translation.version=0.2.3 \\
    ro.ndk_translation.flags=accurate-sigsegv
endif
EOF

cat << EOF >> $BOARDMK
ifneq (\$(filter %x86_64 %x86_64%,\$(TARGET_PRODUCT)),)
TARGET_NATIVE_BRIDGE_ARCH := arm64
TARGET_NATIVE_BRIDGE_ARCH_VARIANT := armv8-a
TARGET_NATIVE_BRIDGE_CPU_VARIANT := generic
TARGET_NATIVE_BRIDGE_ABI := arm64-v8a
endif
EOF
