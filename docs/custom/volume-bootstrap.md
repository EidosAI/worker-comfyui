# Network Volume 初始化（繁中）

目標：不經過本機下載，直接在 RunPod Pod 內把模型拉到同一顆 Network Volume。

## 最快流程（一次貼上）

```bash
git clone https://user:token@github.com/EidosAI/worker-comfyui.git
cd worker-comfyui
git checkout develop
export HUGGINGFACE_ACCESS_TOKEN='hf_...'
./scripts/volume/sync-models.sh
```

- 若你的 volume 掛載路徑是 `/runpod-volume`，請改用：

```bash
./scripts/volume/sync-models.sh --volume-root /runpod-volume
```

- 本地檢查 S3（確認模型是否真的上到 RunPod S3）：

```bash
AWS_ACCESS_KEY_ID="xxx" \
AWS_SECRET_ACCESS_KEY="xxx" \
AWS_DEFAULT_REGION="eur-no-1" \
aws s3 ls --recursive \
  --endpoint-url https://s3api-eur-no-1.runpod.io \
  s3://fooo/models/
```

## 為什麼用這種方式

- 大模型不需要先下載到本機再上傳。
- 初始化完成後，serverless endpoint 直接掛同一顆 volume 就能讀到模型。
- 可重複執行，已存在檔案會自動跳過。

## 前置條件

1. 建一台暫時用的 RunPod CPU Pod（GPU 也可）。
2. Pod 掛上你要給 serverless endpoint 使用的同一顆 Network Volume。
3. 進入 Pod shell，確認 volume 路徑（通常是 `/workspace`）。
4. 安裝 `jq`（腳本用它讀取 `manifest.json`）：

```bash
apt-get update && apt-get install -y jq
```

## 腳本位置

- 入口：`scripts/volume/sync-models.sh`
- 檢查：`scripts/volume/check.sh`
- Smoke test：`scripts/volume/test-smoke.sh`
- 函式庫：`scripts/volume/lib/*.sh`
- 模型清單：`scripts/volume/targets/manifest.json`
  - 每個檔案可記錄 `size_bytes`，供預估模式計算總容量

## 每次改 shell 後的檢查流程（固定）

在 repo root 跑：

```bash
./scripts/volume/check.sh
```

這會依序跑：

1. `bash -n` 語法檢查
2. `shellcheck`（若有安裝）
3. `shfmt -d`（若有安裝）
4. `test-smoke.sh`（mock 模式，不做真下載）

## 預設行為（固定核心組合）

不帶參數時，預設會下載以下四組（GGUF + Lightx2v LoRA 為預設）：

```bash
./scripts/volume/sync-models.sh
```

下載目標：

`flux2-klein-9b-distilled`
- `models/diffusion_models/flux-2-klein-9b-fp8.safetensors`
- `models/text_encoders/qwen_3_8b_fp8mixed.safetensors`
- `models/vae/flux2-vae.safetensors`

`z-image-core`
- `models/text_encoders/qwen_3_4b.safetensors`
- `models/diffusion_models/z_image_turbo_bf16.safetensors`
- `models/vae/ae.safetensors`
- `models/model_patches/Z-Image-Turbo-Fun-Controlnet-Union.safetensors`

`wan2.2-i2v-lightx2v-4step-lora-only`
- `models/loras/wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step_1022.safetensors`
- `models/loras/wan2.2_i2v_A14b_low_noise_lora_rank64_lightx2v_4step_1022.safetensors`

`wan2.2-i2v-a14b-lightning-gguf-q4km`
- `models/unet/wan2.2_i2v_high_noise_14B_Q4_K_M.gguf`
- `models/unet/wan2.2_i2v_low_noise_14B_Q4_K_M.gguf`
- `models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors`
- `models/vae/wan_2.1_vae.safetensors`
- `models/clip_vision/clip_vision_h.safetensors`

## 可選參數

列出所有可用 target：

```bash
./scripts/volume/sync-models.sh --list
```

只下載特定 target：

```bash
./scripts/volume/sync-models.sh --target flux2-klein-9b-distilled
./scripts/volume/sync-models.sh --target wan2.2-i2v-lightx2v-4step-lora-only
./scripts/volume/sync-models.sh --target wan2.2-i2v-a14b-lightx2v-4step
./scripts/volume/sync-models.sh --target wan2.2-i2v-a14b-lightning-gguf-q4km
./scripts/volume/sync-models.sh --target z-image-nvfp4
./scripts/volume/sync-models.sh --target z-image-core --target z-image-qwen-fp8
```

`wan2.2-i2v-lightx2v-4step-lora-only` 包含：
- `models/loras/wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step_1022.safetensors`
- `models/loras/wan2.2_i2v_A14b_low_noise_lora_rank64_lightx2v_4step_1022.safetensors`

`wan2.2-i2v-a14b-lightx2v-4step`（原版 fp16，僅手動指定）包含：
- `models/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors`
- `models/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors`
- `models/text_encoders/umt5_xxl_fp16.safetensors`
- `models/vae/wan2.2_vae.safetensors`
- `models/loras/wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step_1022.safetensors`
- `models/loras/wan2.2_i2v_A14b_low_noise_lora_rank64_lightx2v_4step_1022.safetensors`

`wan2.2-i2v-a14b-lightning-gguf-q4km` 包含：
- `models/unet/wan2.2_i2v_high_noise_14B_Q4_K_M.gguf`
- `models/unet/wan2.2_i2v_low_noise_14B_Q4_K_M.gguf`
- `models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors`
- `models/vae/wan_2.1_vae.safetensors`
- `models/clip_vision/clip_vision_h.safetensors`

全下載（只有帶 `--all` 才會做）：

```bash
./scripts/volume/sync-models.sh --all
```

只做容量預估（不下載）：

```bash
./scripts/volume/sync-models.sh --estimate
./scripts/volume/sync-models.sh --all --estimate
```

指定 volume root（若不是 `/workspace`）：

```bash
./scripts/volume/sync-models.sh --volume-root /runpod-volume
```

強制重抓：

```bash
./scripts/volume/sync-models.sh --target flux2-klein-9b-distilled --force
```

## Serverless 端要配合的事

1. 建立/編輯 endpoint 時，必須在 Advanced 選同一顆 Network Volume。
2. 確認模型路徑在 volume 內是 `models/...` 結構。
3. 如需排錯可開：
   - `NETWORK_VOLUME_DEBUG=true`

## 補充

- 腳本會自動選 downloader：`aria2c` > `wget` > `curl`。
- 若是私有/受限模型（例如 gated HF repo），請設定：
  - `HUGGINGFACE_ACCESS_TOKEN`
- 下載失敗時腳本會立即停止（fail-fast），且不會把 0-byte 檔案標記為成功。
