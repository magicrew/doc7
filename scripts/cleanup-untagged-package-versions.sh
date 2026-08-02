#!/usr/bin/env bash

set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"

owner="${PACKAGE_OWNER:-magicrew}"
package_name="${PACKAGE_NAME:-doc7}"
package_type="${PACKAGE_TYPE:-container}"

command -v gh >/dev/null 2>&1 || {
  printf 'gh is required\n' >&2
  exit 1
}
command -v jq >/dev/null 2>&1 || {
  printf 'jq is required\n' >&2
  exit 1
}

gh api --paginate \
  "/orgs/${owner}/packages/${package_type}/${package_name}/versions?per_page=100" \
  --jq '.[] | select((.metadata.container.tags // []) | length == 0) | .id' |
while IFS= read -r version_id; do
  [[ -n "${version_id}" ]] || continue
  gh api --method DELETE \
    "/orgs/${owner}/packages/${package_type}/${package_name}/versions/${version_id}"
done
