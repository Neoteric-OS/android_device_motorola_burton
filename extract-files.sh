#!/bin/bash
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=burton
VENDOR=motorola

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/etc/permissions/moto-telephony.xml)
            sed -i 's|/system/framework/|/system_ext/framework/|g' "${2}"
            ;;
        vendor/bin/STFlashTool | vendor/lib64/sensors.moto.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/bin/rmt_storage | vendor/bin/thermal-engine | vendor/lib64/libril-qc-hal-qmi.so)
            sed -i 's/ro.mot.build.customerid/vendor.build.customerid/g' "${2}"
            ;;
        vendor/lib64/libdpps.so)
            "${PATCHELF}" --replace-needed "libtinyxml2.so" "libtinyxml2-v34.so" "${2}"
            ;;
        vendor/lib64/libmot_chi_desktop_helper.so)
            "${PATCHELF}" --add-needed "libgui_buffer_shim_vendor.so" "${2}"
            ;;
        vendor/lib64/libvidhance.so)
            "${PATCHELF}" --add-needed "libcomparetf2_shim.so" "${2}"
            ;;
        vendor/lib64/libwvhidl.so)
            "${PATCHELF}" --add-needed "libcrypto_shim.so" "${2}"
            ;;
        vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so)
            "${SIGSCAN}" -p "E4 0A 00 94" -P "1F 20 03 D5" -f "${2}"
            ;;
    esac
}

setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
