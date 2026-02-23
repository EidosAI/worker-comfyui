#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/volume/lib/common.sh
source "${ROOT_DIR}/lib/common.sh"
# shellcheck source=scripts/volume/lib/downloader.sh
source "${ROOT_DIR}/lib/downloader.sh"
# shellcheck source=scripts/volume/lib/targets.sh
source "${ROOT_DIR}/lib/targets.sh"

SCRIPT_NAME="$(basename "$0")"
VOLUME_ROOT="/workspace"
FORCE=false
LIST_ONLY=false
DOWNLOAD_ALL=false
declare -a SELECTED_TARGETS=()
declare -a QUEUE=()

usage() {
  cat <<EOF
Usage:
  ${SCRIPT_NAME} [options]

Description:
  Download selected models directly into a RunPod Network Volume mount.
  Default behavior downloads only the z-image core set (not all optional files).

Options:
  --volume-root <path>    Network volume root path. Default: /workspace
  --target <name>         Add a target group. Repeatable.
  --all                   Download every target group.
  --force                 Re-download even if file already exists.
  --list                  Print available targets and exit.
  -h, --help              Show this help.

Targets:
$(render_target_help)

Examples:
  # Default (z-image core only)
  ${SCRIPT_NAME}

  # Download only NVFP4 variant
  ${SCRIPT_NAME} --target z-image-nvfp4

  # Download core + fp8 text encoder
  ${SCRIPT_NAME} --target z-image-core --target z-image-qwen-fp8

  # Download every target group
  ${SCRIPT_NAME} --all

Notes:
  - Files are written under: <volume-root>/models/...
  - Set HF_TOKEN or HUGGINGFACE_ACCESS_TOKEN if private downloads are needed.
  - Set MOCK_DOWNLOAD=true to skip real downloads (for smoke tests).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume-root)
      VOLUME_ROOT="${2:-}"
      shift 2
      ;;
    --target)
      SELECTED_TARGETS+=("${2:-}")
      shift 2
      ;;
    --all)
      DOWNLOAD_ALL=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "$LIST_ONLY" == "true" ]]; then
  list_targets
  exit 0
fi

if [[ "$DOWNLOAD_ALL" == "true" ]]; then
  SELECTED_TARGETS=()
  while IFS= read -r target; do
    [[ -n "${target}" ]] && SELECTED_TARGETS+=("${target}")
  done < <(list_targets)
fi

if [[ ${#SELECTED_TARGETS[@]} -eq 0 ]]; then
  SELECTED_TARGETS=("z-image-core")
fi

log "Volume root: ${VOLUME_ROOT}"
log "Targets: ${SELECTED_TARGETS[*]}"
echo

queue_contains() {
  local needle="$1"
  local item
  if [[ ${#QUEUE[@]} -eq 0 ]]; then
    return 1
  fi
  for item in "${QUEUE[@]}"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

for target in "${SELECTED_TARGETS[@]}"; do
  if ! target_exists "${target}"; then
    err "Unknown target: ${target}"
    err "Run '${SCRIPT_NAME} --list' to see available targets."
    exit 1
  fi
  while IFS= read -r item; do
    [[ -z "${item}" ]] && continue
    if ! queue_contains "${item}"; then
      QUEUE+=("${item}")
    fi
  done < <(print_target_items "${target}")
done

success=0
skipped=0
failed=0

if [[ ${#QUEUE[@]} -eq 0 ]]; then
  log "No files queued. Nothing to do."
else
  for item in "${QUEUE[@]}"; do
    relative_path="${item%%|*}"
    url="${item#*|}"
    out_path="${VOLUME_ROOT}/${relative_path}"

    mkdir -p "$(dirname "$out_path")"

    if [[ -s "$out_path" && "$FORCE" != "true" ]]; then
      log "[skip] ${relative_path} (already exists)"
      skipped=$((skipped + 1))
      continue
    fi

    log "[dl]   ${relative_path}"
    if download_file "$url" "$out_path"; then
      success=$((success + 1))
    else
      err "[fail] ${relative_path}"
      failed=$((failed + 1))
    fi
  done
fi

echo
log "Done. success=${success} skipped=${skipped} failed=${failed}"

if [[ $failed -gt 0 ]]; then
  exit 1
fi
