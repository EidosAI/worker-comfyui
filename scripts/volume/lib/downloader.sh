#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=scripts/volume/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

download_file() {
  local url="$1"
  local output="$2"

  if [[ "${MOCK_DOWNLOAD:-false}" == "true" ]]; then
    printf 'mock:%s\n' "$url" >"$output"
    return 0
  fi

  local auth_header=()
  local hf_token="${HF_TOKEN:-${HUGGINGFACE_ACCESS_TOKEN:-}}"
  if [[ -n "${hf_token}" ]]; then
    auth_header=("Authorization: Bearer ${hf_token}")
  fi

  if have_cmd aria2c; then
    if [[ ${#auth_header[@]} -gt 0 ]]; then
      aria2c --console-log-level=warn --summary-interval=0 --allow-overwrite=true \
        --header "${auth_header[0]}" -o "$(basename "$output")" -d "$(dirname "$output")" "$url"
    else
      aria2c --console-log-level=warn --summary-interval=0 --allow-overwrite=true \
        -o "$(basename "$output")" -d "$(dirname "$output")" "$url"
    fi
    return 0
  fi

  if have_cmd wget; then
    if [[ ${#auth_header[@]} -gt 0 ]]; then
      wget -q --show-progress --progress=bar:force:noscroll \
        --header "${auth_header[0]}" -O "$output" "$url"
    else
      wget -q --show-progress --progress=bar:force:noscroll -O "$output" "$url"
    fi
    return 0
  fi

  if have_cmd curl; then
    if [[ ${#auth_header[@]} -gt 0 ]]; then
      curl -L --fail --progress-bar -H "${auth_header[0]}" -o "$output" "$url"
    else
      curl -L --fail --progress-bar -o "$output" "$url"
    fi
    return 0
  fi

  err "No downloader found. Install one of: aria2c, wget, curl"
  return 1
}
