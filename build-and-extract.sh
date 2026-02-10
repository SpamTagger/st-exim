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
  -v "${EXPORT_DIR}:/out:Z" \
  "localhost/${IMAGE}"

if [[ -f "${EXPORT_DIR}/st-exim.deb" ]]; then
  echo "✔ Successfully built package"
else
  echo "✘ Failed to build package"
  exit 1
fi

mv ${EXPORT_DIR}/st-exim.deb ${EXPORT_DIR}/${FINAL_DEB}
echo "Package available at ${EXPORT_DIR}/${FINAL_DEB}"
