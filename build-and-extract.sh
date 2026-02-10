#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :
set -euo pipefail

EXIM_VERSION="${1:-4.99}"
DISTRO="${2:-trixie}"
ARCH="${3:-amd64}"
EXPORT_DIR="${4:-$(pwd)/dist}"
FINAL_DEB="st-exim_${EXIM_VERSION}+${DISTRO}_${ARCH}.deb"
IMAGE="st-exim:${EXIM_VERSION}-${DISTRO}-${ARCH}"
CPUS="$(nproc)"
SELINUX=""
if [[ -e /sys/fs/selinux ]]; then
  SELINUX=":z"
fi

echo "Building Exim $EXIM_VERSION for ${DISTRO}/${ARCH}"
mkdir -p "${EXPORT_DIR}"

podman build \
  --build-arg EXIM_VERSION=$EXIM_VERSION \
  --build-arg DISTRO=$DISTRO \
  --build-arg ARCH=$ARCH \
  --build-arg CPUS=$CPUS \
  -t "$IMAGE" .

podman run --rm \
  --arch "${ARCH}" \
  -v "${EXPORT_DIR}:/out${SELINUX}" \
  "localhost/${IMAGE}"

if [[ -f "${EXPORT_DIR}/st-exim.deb" ]]; then
  echo "✔ Successfully built package"
else
  echo "✘ Failed to build package"
  exit 1
fi

mv ${EXPORT_DIR}/st-exim.deb ${EXPORT_DIR}/${FINAL_DEB}
pushd "${EXPORT_DIR}" >/dev/null
sha256sum "${FINAL_DEB}" > "${FINAL_DEB}.sha256"
echo "SHA256 checksum written to ${EXPORT_DIR}/${FINAL_DEB}.sha256"
popd >/dev/null

echo "Package available at ${EXPORT_DIR}/${FINAL_DEB}"
