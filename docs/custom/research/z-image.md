# Z-Image 研究筆記

## 目前基線
- 本專案以 `z-image-turbo` 的最小必需模型組為主。
- 目的：先確保 RunPod Serverless 可穩定部署與可重現。

## 參考來源
- 專案 Dockerfile 中 `MODEL_TYPE=z-image-turbo` 的下載段（本 repo 內部來源）
  - 重點：
    - `qwen_3_4b.safetensors`
    - `z_image_turbo_bf16.safetensors`
    - `ae.safetensors`
    - `Z-Image-Turbo-Fun-Controlnet-Union.safetensors`

## 實務備忘
- 若採 volume-first，重點是路徑與檔名需與 workflow node 一致。
- 若未來加變體，原本可跑基線要保留，不覆蓋。
