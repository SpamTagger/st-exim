#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :
set -euo pipefail

EXIM_VERSION="${1:-4.100.1}"
TARGET="${2:-trixie-updates}"
ARCH="${3:-amd64}"
BUILD_DIR="${4:-$(pwd)/build}"
EXPORT_DIR="${4:-$(pwd)/dist}"
UPSTREAM_VERSION=${EXIM_VERSION%-*}
FINAL_DEB="st-exim_${EXIM_VERSION}+${TARGET}_${ARCH}.deb"
IMAGE="st-exim:${EXIM_VERSION}-${TARGET}-${ARCH}"
CPUS="$(nproc)"
SELINUX=""
if [[ -e /sys/fs/selinux ]]; then
  SELINUX=":z"
fi

echo "Building Exim $EXIM_VERSION for ${TARGET}/${ARCH}"
mkdir -p "${BUILD_DIR}"

if [[ ! -d "${EXPORT_DIR}" ]]; then
  mkdir -p "${EXPORT_DIR}"
fi

DISTRO=$TARGET
DISTRO=${DISTRO%-updates}

podman build \
  --arch "${ARCH}" \
  --build-arg EXIM_VERSION=$UPSTREAM_VERSION \
  --build-arg PACKAGE_VERSION=$EXIM_VERSION \
  --build-arg DISTRO=$DISTRO \
  --build-arg TARGET=$TARGET \
  --build-arg ARCH=$ARCH \
  --build-arg CPUS=$CPUS \
  --output type=local,dest="${BUILD_DIR}" \
  -t "$IMAGE" .

if [[ ! -f "${BUILD_DIR}/tmp/st-exim.deb" ]]; then
  echo "✘ Failed to build package"
  exit 1
fi

mv ${BUILD_DIR}/tmp/st-exim.deb ${EXPORT_DIR}/${FINAL_DEB}

cd "${EXPORT_DIR}"
sha256sum "${FINAL_DEB}" > "${FINAL_DEB}.sha256"
echo "Package available at ${EXPORT_DIR}/${FINAL_DEB}"
echo "SHA256 checksum written to ${EXPORT_DIR}/${FINAL_DEB}.sha256"

rm -rf ${BUILD_DIR}
