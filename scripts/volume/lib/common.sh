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
