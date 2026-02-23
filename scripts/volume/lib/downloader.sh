#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=scripts/volume/lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

download_file() {
	local url="$1"
	local output="$2"
	local tmp_output="${output}.part.$$"

	if [[ "${MOCK_DOWNLOAD:-false}" == "true" ]]; then
		printf 'mock:%s\n' "$url" >"$output"
		return 0
	fi

	local auth_header=()
	local hf_token="${HUGGINGFACE_ACCESS_TOKEN:-}"
	if [[ -n "${hf_token}" ]]; then
		auth_header=("Authorization: Bearer ${hf_token}")
	fi

	rm -f "$tmp_output"

	if have_cmd aria2c; then
		if [[ ${#auth_header[@]} -gt 0 ]]; then
			aria2c --console-log-level=warn --summary-interval=0 --allow-overwrite=true \
				--header "${auth_header[0]}" -o "$(basename "$tmp_output")" -d "$(dirname "$tmp_output")" "$url"
		else
			aria2c --console-log-level=warn --summary-interval=0 --allow-overwrite=true \
				-o "$(basename "$tmp_output")" -d "$(dirname "$tmp_output")" "$url"
		fi
	elif have_cmd wget; then
		if [[ ${#auth_header[@]} -gt 0 ]]; then
			wget --show-progress --progress=bar:force:noscroll \
				--header "${auth_header[0]}" -O "$tmp_output" "$url"
		else
			wget --show-progress --progress=bar:force:noscroll -O "$tmp_output" "$url"
		fi
	elif have_cmd curl; then
		if [[ ${#auth_header[@]} -gt 0 ]]; then
			curl -L --fail --show-error --progress-bar -H "${auth_header[0]}" -o "$tmp_output" "$url"
		else
			curl -L --fail --show-error --progress-bar -o "$tmp_output" "$url"
		fi
	else
		err "No downloader found. Install one of: aria2c, wget, curl"
		return 1
	fi

	if [[ ! -s "$tmp_output" ]]; then
		err "Download produced empty file: $url"
		err "Hint: for gated HF models, set HUGGINGFACE_ACCESS_TOKEN."
		rm -f "$tmp_output"
		return 1
	fi

	mv -f "$tmp_output" "$output"
	return 0
}
