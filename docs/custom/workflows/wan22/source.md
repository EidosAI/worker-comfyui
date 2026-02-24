# WAN2.2 GGUF + Lightx2v 來源追蹤

## 目的

這個資料夾保留「可直接匯入 ComfyUI 的原始 workflow」與「API 匯出版」，作為我們客製化修改的基準來源。

## 上游來源

- Repository: https://github.com/pwillia7/Basic_ComfyUI_Workflows
- Section: https://github.com/pwillia7/Basic_ComfyUI_Workflows?tab=readme-ov-file#video
- 上游檔案（UI workflow）:
  - `Video/WorkflowJSONs/wan22_lx2v_gguf.json`

## 本地保存檔案

1. `source-ui-wan22-lx2v-gguf.json`
- 說明：從上游 repo 複製的 UI workflow（可直接在 ComfyUI 匯入）。
- SHA256: `16d429b230167e0f362edd66cb95f6fa3838a1d82dfecf01365b9b5abb0f8810`

2. `source-api-wan22-lx2v-gguf.json`
- 說明：由 UI workflow 匯出/提供的 API workflow（可直接送 `/prompt` 類介面）。
- 來源：本地檔 `/Users/one/Downloads/wan22_lx2v_gguf.json`。
- SHA256: `7e0304f6653ffa8f9dadaa1c121040d2b5e5f34727d533daca8c03c51c6192dc`

## 與 ULO 的對應

ULO 使用這份來源作為基準，並只做必要替換（輸入/輸出/模型名對應）：
- `/Users/one/repos/ffo/eidosai/ulo/packages/runpod/src/workflows/wan22-i2v-gguf-lightx2v.ts`

## 更新規則

- 若上游更新，請重新複製 UI workflow，並更新 SHA256 與變更說明。
- 若 API 匯出版本更新，也要保存新檔並更新 SHA256。
- ULO 內的 workflow 若有調整，需在 commit / docs 註記「基於哪個來源檔與版本」。
