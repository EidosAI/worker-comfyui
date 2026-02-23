#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=scripts/volume/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

TARGETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../targets" && pwd)"
MANIFEST_FILE="${TARGETS_DIR}/manifest.json"

require_jq() {
	if ! have_cmd jq; then
		err "jq is required to read ${MANIFEST_FILE}."
		err "Install jq and retry."
		exit 1
	fi
}

list_targets() {
	require_jq
	jq -r '.targets | to_entries[] | .key' "${MANIFEST_FILE}"
}

render_target_help() {
	require_jq
	jq -r '.targets | to_entries[] | "\(.key)\t\(.value.description)"' "${MANIFEST_FILE}" |
		while IFS=$'\t' read -r key desc; do
			printf '  %-24s %s\n' "${key}" "${desc}"
		done
}

target_exists() {
	local target="$1"
	require_jq
	jq -e --arg t "${target}" '.targets[$t] != null' "${MANIFEST_FILE}" >/dev/null
}

print_target_items() {
	local target="$1"
	require_jq
	if ! target_exists "${target}"; then
		err "Unknown target: ${target}"
		err "Run 'sync-models.sh --list' to see available targets."
		exit 1
	fi

	jq -r --arg t "${target}" '.targets[$t].files[] | "\(.path)|\(.url)|\(.size_bytes // 0)"' "${MANIFEST_FILE}"
}
