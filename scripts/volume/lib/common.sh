#!/usr/bin/env bash

set -euo pipefail

log() {
	printf '%s\n' "$*"
}

err() {
	printf '%s\n' "$*" >&2
}

have_cmd() {
	command -v "$1" >/dev/null 2>&1
}

format_bytes() {
	local bytes="$1"
	local unit="B"
	local value="$bytes"

	if [[ "$bytes" -ge 1099511627776 ]]; then
		unit="TB"
		value=$(awk -v b="$bytes" 'BEGIN {printf "%.2f", b/1099511627776}')
	elif [[ "$bytes" -ge 1073741824 ]]; then
		unit="GB"
		value=$(awk -v b="$bytes" 'BEGIN {printf "%.2f", b/1073741824}')
	elif [[ "$bytes" -ge 1048576 ]]; then
		unit="MB"
		value=$(awk -v b="$bytes" 'BEGIN {printf "%.2f", b/1048576}')
	elif [[ "$bytes" -ge 1024 ]]; then
		unit="KB"
		value=$(awk -v b="$bytes" 'BEGIN {printf "%.2f", b/1024}')
	fi

	printf '%s %s' "$value" "$unit"
}
