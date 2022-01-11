#!/bin/sh
# This file is available at the option of the licensee under:
# Public domain
# or licensed under X/MIT (LICENSE.TXT) Copyright 2019 Even Rouault <even.rouault@spatialys.com>

set -eu

SCRIPT_DIR=$(dirname "$0")
case $SCRIPT_DIR in
    "/"*)
        ;;
    ".")
        SCRIPT_DIR=$(pwd)
        ;;
    *)
        SCRIPT_DIR=$(pwd)/$(dirname "$0")
        ;;
esac

export SCRIPT_DIR
TAG_NAME=$(basename "${SCRIPT_DIR}")
export TARGET_IMAGE=${TARGET_IMAGE:-ghcr.io/dbca-wa/gdal:${TAG_NAME}}

HAS_PLATFORM=0
if echo "$*" | grep "\-\-platform" > /dev/null; then
  HAS_PLATFORM=1
fi

HAS_RELEASE=0
if echo "$*" | grep "\-\-release" > /dev/null; then
  HAS_RELEASE=1
fi

HAS_PUSH=0
if echo "$*" | grep "\-\-push" > /dev/null; then
  HAS_PUSH=1
fi

"${SCRIPT_DIR}/../util_dbca.sh" "$@" --test-python

if test "${HAS_PLATFORM}" = "0" -a "${HAS_RELEASE}" = "0" -a "x${TARGET_IMAGE}" = "xghcr.io/dbca-wa/gdal:ubuntu-small"; then
 "${SCRIPT_DIR}/../util_dbca.sh" --platform linux/arm64 "$@" --test-python
 ./push_image.sh ${IMAGE_NAME}

fi
