#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="${ROOT_DIR}/sync-models.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

assert_contains() {
	local content="$1"
	local needle="$2"
	if ! grep -Fq "$needle" <<<"$content"; then
		echo "assert_contains failed: expected '${needle}'" >&2
		exit 1
	fi
}

echo "smoke: --list"
list_output="$("${SYNC_SCRIPT}" --list)"
assert_contains "${list_output}" "z-image-core"

echo "smoke: default target download (mock)"
MOCK_DOWNLOAD=true "${SYNC_SCRIPT}" --volume-root "${TMP_DIR}" >/dev/null
test -s "${TMP_DIR}/models/text_encoders/qwen_3_4b.safetensors"
test -s "${TMP_DIR}/models/diffusion_models/z_image_turbo_bf16.safetensors"

echo "smoke: estimate mode"
estimate_output="$("${SYNC_SCRIPT}" --target z-image-core --estimate)"
assert_contains "${estimate_output}" "Estimate only mode"
assert_contains "${estimate_output}" "Known size total"

echo "smoke: unknown target should fail"
set +e
unknown_output="$("${SYNC_SCRIPT}" --target not-a-target 2>&1)"
unknown_status=$?
set -e
if [[ ${unknown_status} -eq 0 ]]; then
	echo "expected non-zero for unknown target" >&2
	exit 1
fi
assert_contains "${unknown_output}" "Unknown target"

echo "smoke tests passed."
