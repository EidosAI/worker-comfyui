# Change Log (EidosAI)

## 2026-02-23

### Docker build strategy

- `Dockerfile` 改為基於官方 base image，而非自行重建完整 ComfyUI runtime。
- 改動前：本地多階段 build（從 CUDA base 開始安裝全部依賴）。
- 改動後：`FROM runpod/worker-comfyui:5.7.1-base`，只額外下載 z-image-turbo 模型資產。

### z-image only

- 目前 image 只包含 z-image-turbo 相關模型：
  - `models/text_encoders/qwen_3_4b.safetensors`
  - `models/diffusion_models/z_image_turbo_bf16.safetensors`
  - `models/vae/ae.safetensors`
  - `models/model_patches/Z-Image-Turbo-Fun-Controlnet-Union.safetensors`

### Docs structure

- 新增 `docs/custom/` 作為集中管理資料夾。
- 後續所有 EidosAI 客製部署紀錄都寫在此資料夾下。

### RunPod serverless test fix

- `.runpod/tests.json` 的 `basic_test` 由 `flux1-dev-fp8` checkpoint 流程改為 z-image-turbo workflow。
- 原因：image 已改為 z-image-only，不再包含 `flux1-dev-fp8.safetensors`，舊測試會在 `CheckpointLoaderSimple` 驗證失敗。
- `.runpod/README.md` 維持 upstream 內容，只加短註記導引到 `docs/custom/`。
- 規則：fork-specific 細節優先寫在 `docs/custom/`，避免重寫 `.runpod/README.md` 全文。
