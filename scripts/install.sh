#!/usr/bin/env bash

set -euo pipefail

fail() {
  printf 'doc7 installer: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

resolve_latest_version() {
  local latest_url

  latest_url="$(curl --fail --silent --show-error --location \
    --output /dev/null --write-out '%{url_effective}' \
    "https://github.com/${REPOSITORY}/releases/latest")"

  case "${latest_url}" in
    */releases/tag/*)
      printf '%s\n' "${latest_url##*/}"
      ;;
    *)
      fail "could not resolve the latest GitHub release"
      ;;
  esac
}

detect_platform() {
  case "$(uname -s)" in
    Darwin) OS=darwin ;;
    Linux) OS=linux ;;
    *) fail "supported systems are macOS and Linux" ;;
  esac

  case "$(uname -m)" in
    x86_64 | amd64) ARCH=amd64 ;;
    arm64 | aarch64) ARCH=arm64 ;;
    *) fail "supported architectures are x86_64 and arm64" ;;
  esac
}

verify_checksum() {
  local expected actual

  expected="$(awk -v target="${ASSET_NAME}" '
    {
      file = $2
      sub(/^\*/, "", file)
      sub(/^\.\//, "", file)
      if (file == target) {
        print $1
        exit
      }
    }
  ' "${CHECKSUMS_PATH}")"

  [[ "${expected}" =~ ^[0-9A-Fa-f]{64}$ ]] || \
    fail "release checksums do not contain ${ASSET_NAME}"

  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "${ARCHIVE_PATH}" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "${ARCHIVE_PATH}" | awk '{print $1}')"
  else
    fail "sha256sum or shasum is required to verify the release"
  fi

  expected="$(printf '%s' "${expected}" | tr '[:upper:]' '[:lower:]')"
  actual="$(printf '%s' "${actual}" | tr '[:upper:]' '[:lower:]')"
  [[ "${actual}" == "${expected}" ]] || fail "checksum verification failed"
}

clear_macos_quarantine() {
  [[ "${OS}" == "darwin" ]] || return 0
  command -v xattr >/dev/null 2>&1 || return 0
  xattr -dr com.apple.quarantine "${TEMP_DIR}" 2>/dev/null || true
}

require_command curl
require_command tar
require_command awk
require_command install

REPOSITORY="${DOC7_REPOSITORY:-magicrew/doc7}"
VERSION="${DOC7_VERSION:-}"
INSTALL_DIR="${DOC7_INSTALL_DIR:-${HOME}/.local/bin}"
SHARE_DIR="${DOC7_SHARE_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/doc/doc7}"

[[ "${REPOSITORY}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || \
  fail "invalid GitHub repository: ${REPOSITORY}"

detect_platform

if [[ -z "${VERSION}" ]]; then
  VERSION="$(resolve_latest_version)"
fi

case "${VERSION}" in
  *[!A-Za-z0-9._-]*) fail "invalid release version: ${VERSION}" ;;
esac

PACKAGE_NAME="doc7_${VERSION}_${OS}_${ARCH}"
ASSET_NAME="${PACKAGE_NAME}.tar.gz"
RELEASE_URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/doc7-install.XXXXXXXX")"
ARCHIVE_PATH="${TEMP_DIR}/${ASSET_NAME}"
CHECKSUMS_PATH="${TEMP_DIR}/checksums.txt"

cleanup() {
  rm -rf -- "${TEMP_DIR}"
}
trap cleanup EXIT

printf 'Downloading doc7 %s for %s/%s...\n' "${VERSION}" "${OS}" "${ARCH}"
curl --fail --silent --show-error --location \
  --output "${ARCHIVE_PATH}" "${RELEASE_URL}/${ASSET_NAME}"
curl --fail --silent --show-error --location \
  --output "${CHECKSUMS_PATH}" "${RELEASE_URL}/checksums.txt"

verify_checksum
tar -xzf "${ARCHIVE_PATH}" -C "${TEMP_DIR}"
clear_macos_quarantine

BINARY_PATH="${TEMP_DIR}/${PACKAGE_NAME}/doc7"
LICENSE_PATH="${TEMP_DIR}/${PACKAGE_NAME}/LICENSE"
[[ -f "${BINARY_PATH}" ]] || fail "release archive does not contain doc7"
[[ -f "${LICENSE_PATH}" ]] || fail "release archive does not contain LICENSE"

mkdir -p "${INSTALL_DIR}" "${SHARE_DIR}"
install -m 0755 "${BINARY_PATH}" "${INSTALL_DIR}/doc7"
install -m 0644 "${LICENSE_PATH}" "${SHARE_DIR}/LICENSE"

README_PATH="${TEMP_DIR}/${PACKAGE_NAME}/README.txt"
if [[ -f "${README_PATH}" ]]; then
  install -m 0644 "${README_PATH}" "${SHARE_DIR}/README.txt"
fi

"${INSTALL_DIR}/doc7" version
printf 'Installed executable: %s\n' "${INSTALL_DIR}/doc7"

case ":${PATH}:" in
  *":${INSTALL_DIR}:"*) ;;
  *)
    printf 'Add this directory to PATH before opening a new shell:\n'
    printf '  export PATH="%s:$PATH"\n' "${INSTALL_DIR}"
    ;;
esac

printf 'Next: doc7 setup\n'
printf 'Then: doc7 <file>\n'
