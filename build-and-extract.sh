#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :
set -euo pipefail

EXIM_VERSION="${1:-4.99}"
DISTRO="${2:-trixie}"
ARCH="${3:-amd64}"
BUILD_DIR="${4:-$(pwd)/build}"
EXPORT_DIR="${4:-$(pwd)/dist}"
FINAL_DEB="st-exim_${EXIM_VERSION}+${DISTRO}_${ARCH}.deb"
IMAGE="st-exim:${EXIM_VERSION}-${DISTRO}-${ARCH}"
CPUS="$(nproc)"
SELINUX=""
if [[ -e /sys/fs/selinux ]]; then
  SELINUX=":z"
fi

echo "Building Exim $EXIM_VERSION for ${DISTRO}/${ARCH}"
mkdir -p "${BUILD_DIR}"

if [[ ! -d "${EXPORT_DIR}" ]]; then
  mkdir -p "${EXPORT_DIR}"
fi

podman build \
  --arch "${ARCH}" \
  --build-arg EXIM_VERSION=$EXIM_VERSION \
  --build-arg DISTRO=$DISTRO \
  --build-arg ARCH=$ARCH \
  --build-arg CPUS=$CPUS \
  --output type=local,dest="${BUILD_DIR}" \
  -t "$IMAGE" .

echo Contents of export dir:
ls "${BUILD_DIR}/tmp"

if [[ -f "${BUILD_DIR}/tmp/st-exim.deb" ]]; then
  echo "✔ Successfully built package"
else
  echo "✘ Failed to build package"
  exit 1
fi

mv ${BUILD_DIR}/tmp/st-exim.deb ${EXPORT_DIR}/${FINAL_DEB}
rm -rf ${BUILD_DIR}

pushd "${EXPORT_DIR}" >/dev/null
sha256sum "${FINAL_DEB}" > "${FINAL_DEB}.sha256"
echo "SHA256 checksum written to ${EXPORT_DIR}/${FINAL_DEB}.sha256"
popd >/dev/null

echo "Package available at ${EXPORT_DIR}/${FINAL_DEB}"
