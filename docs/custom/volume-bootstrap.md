# Network Volume 初始化（繁中）

目標：不經過本機下載，直接在 RunPod Pod 內把模型拉到同一顆 Network Volume。

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

## 預設行為（非全下載）

不帶參數時，預設會下載 `flux2-klein-9b-distilled` + `z-image-core`：

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

## 可選參數

列出所有可用 target：

```bash
./scripts/volume/sync-models.sh --list
```

只下載特定 target：

```bash
./scripts/volume/sync-models.sh --target flux2-klein-9b-distilled
./scripts/volume/sync-models.sh --target z-image-nvfp4
./scripts/volume/sync-models.sh --target z-image-core --target z-image-qwen-fp8
```

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
- 若是私有模型，可設定 `HF_TOKEN` 或 `HUGGINGFACE_ACCESS_TOKEN`。
