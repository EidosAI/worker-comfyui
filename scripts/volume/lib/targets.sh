#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=scripts/volume/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

TARGETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../targets" && pwd)"
TARGET_HELP_FILE="${TARGETS_DIR}/help.tsv"

list_targets() {
  awk -F '\t' 'NF >= 2 {print $1}' "${TARGET_HELP_FILE}"
}

render_target_help() {
  awk -F '\t' 'NF >= 2 {printf "  %-24s %s\n", $1, $2}' "${TARGET_HELP_FILE}"
}

target_list_file() {
  local target="$1"
  printf '%s/%s.list\n' "${TARGETS_DIR}" "${target}"
}

target_exists() {
  local target="$1"
  local file

  file="$(target_list_file "$target")"
  [[ -f "${file}" ]]
}

print_target_items() {
  local target="$1"
  local file

  file="$(target_list_file "$target")"
  if [[ ! -f "${file}" ]]; then
    err "Unknown target: ${target}"
    err "Run 'sync-models.sh --list' to see available targets."
    exit 1
  fi

  while IFS='|' read -r relative_path url; do
    [[ -z "${relative_path}" ]] && continue
    case "${relative_path}" in
      \#*) continue ;;
    esac
    printf '%s|%s\n' "${relative_path}" "${url}"
  done <"${file}"
}
