#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_FILES=(
	"${ROOT_DIR}/sync-models.sh"
	"${ROOT_DIR}/check.sh"
	"${ROOT_DIR}/test-smoke.sh"
	"${ROOT_DIR}/lib/common.sh"
	"${ROOT_DIR}/lib/downloader.sh"
	"${ROOT_DIR}/lib/targets.sh"
)

echo "[1/5] bash -n"
for f in "${SHELL_FILES[@]}"; do
	bash -n "$f"
done

echo "[2/5] jq"
if command -v jq >/dev/null 2>&1; then
	jq -e . "${ROOT_DIR}/targets/manifest.json" >/dev/null
else
	echo "jq not found. Install jq to parse target manifest." >&2
fi

echo "[3/5] shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
	shellcheck "${SHELL_FILES[@]}"
else
	echo "shellcheck not found. Install shellcheck to enable lint checks." >&2
fi

echo "[4/5] shfmt -d"
if command -v shfmt >/dev/null 2>&1; then
	shfmt -d "${SHELL_FILES[@]}"
else
	echo "shfmt not found. Install shfmt to enable formatting checks." >&2
fi

echo "[5/5] smoke tests"
"${ROOT_DIR}/test-smoke.sh"

echo "All checks completed."
