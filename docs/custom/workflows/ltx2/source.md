# LTX2 Phr00t workflow 來源追蹤

## 目的

保留可重現的上游 workflow（UI + API），避免後續「自己重編節點」造成行為偏差。

## 上游來源

- 模型與 workflow 來源頁：
  - https://huggingface.co/Phr00t/LTX2-Rapid-Merges
- workflow 原始檔（UI）：
  - `LTXV-DoAlmostEverything-v3.json`
  - https://huggingface.co/Phr00t/LTX2-Rapid-Merges/raw/main/LTXV-DoAlmostEverything-v3.json

## 本地保存檔案

1. `LTXV-DoAlmostEverything-v3.json`
- 說明：可直接匯入 ComfyUI 的 UI workflow。
- SHA256: `fb00f23b1ace7a25edf4bc58a109e275e29624c183ba1fd3399882822ec99ba8`

2. `LTXV-DoAlmostEverything-v3-api.json`
- 說明：由上面 UI workflow 匯出的 API workflow（可直接送 `/prompt` 類接口）。
- SHA256: `22fd77b344163e90b2bdad26f23192beade24966c43d94780b6cdd7952960f95`

## ULO 對應

- ULO 目前使用這份 API workflow 作為模板，僅替換必要輸入：
  - prompt / seed / width / height / numFrames / input image / output prefix
- 對應檔案：
  - `/Users/one/repos/ffo/eidosai/ulo/packages/runpod/src/workflows/ltx2-phr00t-sfw-v5.ts`

## 依賴節點（依 workflow 實際 class_type）

- `ComfyUI-LTXVideo`
- `comfyui-videohelpersuite`
- `comfyui-kjnodes`
- `ComfyUI_Fill-Nodes`

## 更新規則

- 上游 workflow 只要改版，就要同步更新本目錄檔案與 SHA256。
- ULO 若改 workflow 行為，必須在 commit / docs 標註「基於哪個來源檔與版本」。
