# Change Log (EidosAI)

## 2026-02-25

### Fill-Nodes install hardening (FL_RIFE missing fix)

- `Dockerfile` 增加 `libopengl0`，避免 `ComfyUI_Fill-Nodes` 的 OpenGL 相關依賴在 runtime 缺少系統庫。
- `Dockerfile` 在 `comfy-node-install` 之後新增 `ComfyUI_Fill-Nodes` fallback：
  - 若 `/comfyui/custom_nodes/ComfyUI_Fill-Nodes` 不存在，改用 `git clone --depth 1` 直接安裝。
  - 若存在 `requirements.txt`，強制執行 `uv pip install -r ...`。
- 目的：避免 registry 安裝偶發失敗導致 `FL_RIFE`/`FL_IntToFloat` 等 `FL_*` 節點不存在，造成 LTX workflow 在 serverless 上報 `missing_node_type`。

### LTX2 Phr00t v5 workflow integration

- 新增 workflow 來源追蹤檔：
  - `docs/custom/workflows/ltx2/source.md`
  - 記錄上游來源、UI/API 檔案 SHA256、與 ULO 對應路徑。
- 保留 workflow 原始檔（UI + API）：
  - `docs/custom/workflows/ltx2/LTXV-DoAlmostEverything-v3.json`
  - `docs/custom/workflows/ltx2/LTXV-DoAlmostEverything-v3-api.json`
- `scripts/volume/targets/manifest.json` 新增 target：`ltx2-phr00t-sfw-v5-i2v`，包含：
  - `ltx2-phr00tmerge-sfw-v5.safetensors`
  - `gemma_3_12B_it_fp8_scaled.safetensors`
  - `ltx-2-19b-embeddings_connector_distill_bf16.safetensors`
  - `LTX2_audio_vae_bf16.safetensors`
  - `LTX2_video_vae_bf16.safetensors`
- `docs/custom/volume-bootstrap.md` 補上 `ltx2-phr00t-sfw-v5-i2v` 指令與檔案清單。
- `docs/custom/research/ltx-2.md` 補上「本專案已落地的 Phr00t v5 基線」段落與對應路徑。
- `Dockerfile` 補上 LTX2 workflow 需要的節點安裝：
  - `ComfyUI-LTXVideo`
  - `ComfyUI_Fill-Nodes`
- `handler.py` 擴充輸出處理：
  - 除 `images` 外，新增處理 `gifs` / `videos` 輸出鍵。
  - 輸出結果新增 `media` 陣列（含 `media_kind` / `mime_type`），並保留 `images`（僅 image 子集）相容舊邏輯。
  - 無輸出狀態改為 `success_no_media`（原本 `success_no_images`）。
- 新增最小單元測試：
  - `tests/test_handler_media.py`
  - 驗證 `infer_mime_type`、`infer_media_kind`、`to_output_entry` 在 base64 與 S3 模式的輸出格式。

## 2026-02-24

### Research docs split

- 研究筆記由單一檔案拆分為主題化文件，避免資訊混在一起：
  - `docs/custom/research/README.md`
  - `docs/custom/research/wan-2.2-i2v.md`
  - `docs/custom/research/z-image.md`
  - `docs/custom/research/flux2-klein.md`
  - `docs/custom/research/comfy-core.md`
- `docs/custom/model-research-notes.md` 改為入口頁，只保留導引連結。
- `docs/custom/README.md` 增加 `research/README.md` 索引項目。
- 新增 WAN2.2 workflow 來源追蹤與原始檔保存：
  - `docs/custom/workflows/wan22/source.md`
  - `docs/custom/workflows/wan22/source-ui-wan22-lx2v-gguf.json`（上游 UI workflow）
  - `docs/custom/workflows/wan22/source-api-wan22-lx2v-gguf.json`（API 匯出版）
  - 內含來源連結與 SHA256，供後續更新/回溯。
- `docs/custom/research/wan-2.2-i2v.md` 新增「極速目標參考（待驗證）」：
  - 記錄 https://zhuanlan.zhihu.com/p/1981363125866481093
  - 作為後續 1:1 即時生成方向的研究入口。
  - 補上圖表的完整數據與解讀（H100/5090/4090 在 cfg、no cfg、fp8、4-step 各階段秒數），並新增可執行 A/B 實驗清單。
- `scripts/volume/targets/manifest.json` 新增 target：`wan2.2-i2v-a14b-fp8-lightx2v-4step`：
  - 下載 Wan2.2 I2V high/low noise `fp8_scaled` 本體
  - 搭配 `umt5_xxl_fp8_e4m3fn_scaled.safetensors`、`wan_2.1_vae.safetensors`
  - 搭配 `lightx2v/Wan2.2-Distill-Loras` high/low 4-step LoRA
- `docs/custom/volume-bootstrap.md` 補上上述新 target 的使用指令與檔案清單。
- 新增 `docs/custom/research/ltx-2.md`：
  - 彙整 LTX-2 官方模型卡、官方 GitHub README、官方 collection。
  - 整理可選版本（dev/dev-fp8/dev-fp4/distilled/distilled-lora/upscalers）。
  - 補上「速度優先但盡量不犧牲太多品質」的嘗試順序與 A/B 實驗矩陣。
- `docs/custom/research/ltx-2.md` 補充 Comfy 官方教程資訊：
  - 納入官方能力清單（T2V/I2V/V2V、控制、keyframe、upscaler）
  - 納入官方模板 workflow 下載連結（t2v/i2v/distilled/canny/depth/pose）
  - 納入官方 prompt 建議（時間順序描述、200 詞內）
- `docs/custom/research/ltx-2.md` 補充中文社群實戰來源：
  - 新增 Bilibili 影片（BV1PfkGBSEso）連結與定位。
  - 新增影片推薦節點清單與用途註記：`KJ Nodes`、`Mie Nodes`、`Impact Pack`、`RES4LYF`、`ComfyUI-LTXVideo`。
- `docs/custom/research/ltx-2.md` 補充兩個社群模型來源：
  - `MachineDelusions/LTX-2_Image2Video_Adapter_LoRa`（I2V adapter LoRA）
  - `Phr00t/LTX2-Rapid-Merges`（快速導向 merges + workflow）
  - 並新增「可用價值 vs 風險」註記，供後續導入決策。
- `docs/custom/research/ltx-2.md` 補上 Phr00t v5 的直接落地方式：
  - 指定模型 `sfw/ltx2-phr00tmerge-sfw-v5.safetensors`
  - 記錄作者提供的 workflow `LTXV-DoAlmostEverything-v3.json`（raw 連結）
  - 記錄作者 README 的配套依賴（Kijai 模型包、Comfy-Org text encoder）與必備節點清單（KJNodes/LTXVideo/VHS/Fill-Nodes）
  - 記錄 `VideoCombine.save_output=false` 等 workflow 注意事項
- `docs/custom/research/README.md` 新增 LTX-2 索引項目。

## 2026-02-23

### Docker build strategy

- `Dockerfile` 改為基於官方 base image，而非自行重建完整 ComfyUI runtime。
- 改動前：本地多階段 build（從 CUDA base 開始安裝全部依賴）。
- 改動後：`FROM runpod/worker-comfyui:5.7.1-base`，採 pure volume-first，不在 image 內下載任何模型。
- 修正：新增 `COPY src/extra_model_paths.yaml /comfyui/extra_model_paths.yaml`。
  - 原因：若只 `FROM ...-base` 但未覆蓋 `extra_model_paths.yaml`，ComfyUI 可能不會掃描 `/runpod-volume/models/...`，導致 `CLIPLoader`/`UNETLoader` 出現 `not in []`。
- 調整：`Dockerfile` 改為貼齊 upstream 原文結構（`runpod-workers/worker-comfyui` `main`），僅移除不需要的 `downloader/final` model-download stages，維持 pure volume-first。
  - `COMFYUI_VERSION` 預設改為 `latest`，可透過 build-arg 覆蓋。
  - 保留 `MODEL_TYPE` / `HUGGINGFACE_ACCESS_TOKEN` build args 以相容現有 bake target 參數，但不再用於 image 內建模型下載。

### z-image only

- 目前 z-image 模型改由 Network Volume 管理（非 image 內建）：
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
- `basic_test` 進一步降載：`512x512`、`steps=4`，並將 timeout 從 `300000` 提高到 `900000`，降低 cold start + polling 導致的逾時誤判。
- `basic_test` 改為不依賴模型/volume 的 smoke test（`LoadImage -> SaveImage`），避免 build/test 階段因未掛載 volume 而失敗。
- `basic_test` timeout 調整為 `180000`，測試應更快完成與回報。
- 目前採 UI 直接 deploy 驗證流程，暫時停用 RunPod 自動測試觸發：`tests.json` 重新命名為 `.runpod/tests.disabled.json`（不被平台當成測試設定讀取）。

### Network Volume bootstrap script

- 新增 `scripts/volume/sync-models.sh`，可在 RunPod Pod 內直接下載模型到掛載的 Network Volume。
- 預設只下載 `z-image-core`，不做全下載。
- 可用 `--target` 精選下載、`--all` 全下載、`--force` 強制重抓、`--volume-root` 指定 volume 路徑。
- 已存在檔案會自動跳過，適合重複執行與增量更新。
- 新增文件 `docs/custom/volume-bootstrap.md` 說明操作流程。
- 更新 `src/extra_model_paths.yaml`，加入 `diffusion_models`、`text_encoders`、`model_patches` 映射，確保 z-image 模型可從 volume 被 ComfyUI 掃描。
- 腳本移入專用目錄 `scripts/volume/`，避免與其他 scripts 混在同一層。
- `scripts/volume/` 進一步重構：入口、函式庫（`lib/`）、目標資料（`targets/`）分離。
- target 定義改為 `scripts/volume/targets/manifest.json`（JSON + `jq` 解析），不再使用多個 `.list/.tsv`。
- `manifest.json` 每個模型檔新增 `size_bytes`，可追蹤容量。
- `sync-models.sh` 新增 `--estimate` 模式，輸出每檔與總容量（不實際下載）。
- 在 `docs/custom/volume-bootstrap.md` 補上 `jq` 安裝前置條件與指令，避免在 Pod 執行時缺依賴。
- 新增 `scripts/volume/check.sh`（語法/lint/格式/smoke 一鍵檢查）與 `scripts/volume/test-smoke.sh`。
- 後續每次修改 volume 相關 shell，固定執行 `./scripts/volume/check.sh`。
- 修正為 bash 3 相容寫法（移除 `declare -n`/新式陣列依賴），可在 macOS 預設 bash 下執行。
- 新增 target：`flux2-klein-9b-distilled`，包含：
  - `models/diffusion_models/flux-2-klein-9b-fp8.safetensors`
  - `models/text_encoders/qwen_3_8b_fp8mixed.safetensors`
  - `models/vae/flux2-vae.safetensors`
- `sync-models.sh` 預設 target 改為同時下載 `flux2-klein-9b-distilled` + `z-image-core`。
- 注意：`flux-2-klein-9b-fp8.safetensors` 來自 gated repo（BFL），需先在 Hugging Face 接受授權。
- `scripts/volume/lib/downloader.sh` 調整：
  - 統一只讀取 `HUGGINGFACE_ACCESS_TOKEN`（不再支援 `HF_TOKEN`/`HUGGINGFACE_TOKEN`）。
  - 下載改為先寫暫存檔再原子覆蓋，避免失敗留下 0-byte 正式檔。
  - 若下載結果為空檔，視為失敗並提示檢查 HF token / 權限。
- `scripts/volume/sync-models.sh` 調整：
  - 遇到單檔下載失敗立即退出（fail-fast），不再默默繼續。
  - 若偵測到既有 0-byte 檔案，先刪除再重抓，避免把壞檔當既存成果。
- `scripts/volume/targets/manifest.json` 新增 target：`wan2.2-i2v-a14b-lightx2v-4step`，內容包含：
  - Wan2.2 I2V A14B `high_noise/low_noise`（fp16）
  - `umt5_xxl_fp16.safetensors`
  - `wan2.2_vae.safetensors`
  - Lightx2v 4-step `high_noise/low_noise` LoRA
- `Dockerfile` 新增最小 custom nodes 安裝（僅保留 I2V + GGUF 需要）：
  - `ComfyUI-WanVideoWrapper`
  - `ComfyUI-GGUF`
  - `comfyui-videohelpersuite`
- `scripts/volume/targets/manifest.json` 新增 target：`wan2.2-i2v-a14b-lightning-gguf-q4km`，內容包含：
  - `Wan22-I2V_A14B-Lightning-H-Q4_K_M.gguf`
  - `Wan22-I2V_A14B-Lightning-L-Q4_K_M.gguf`
  - `umt5_xxl_fp16.safetensors`
  - `wan2.2_vae.safetensors`
- `docs/custom/volume-bootstrap.md` 補上 WAN2.2 + Lightx2v 的 target 指令與檔案清單。
- `Dockerfile` custom nodes 擴充為：
  - `ComfyUI-WanVideoWrapper`
  - `ComfyUI-GGUF`
  - `comfyui-videohelpersuite`
  - `comfyui-kjnodes`
  - `comfyui_essentials`
  - `comfyui-custom-scripts`
  - `comfyui-impact-pack`
  - `rgthree-comfy`
  - `comfyui-easy-use`
- `scripts/volume/sync-models.sh` 預設 target 更新為 4 組（不帶參數時）：
  - `flux2-klein-9b-distilled`
  - `z-image-core`
  - `wan2.2-i2v-a14b-lightx2v-4step`
  - `wan2.2-i2v-a14b-lightning-gguf-q4km`
- 新增 target：`wan2.2-i2v-lightx2v-4step-lora-only`（只下載 Lightx2v high/low LoRA）。
- `scripts/volume/sync-models.sh` 預設 target 再調整：
  - 預設改為 `GGUF + Lightx2v LoRA`（不含原版 Wan2.2 fp16 base）
  - 若要原版 Wan2.2 fp16，需手動指定 `--target wan2.2-i2v-a14b-lightx2v-4step`
- `wan2.2-i2v-a14b-lightning-gguf-q4km` 下載來源改為 `bullerwins/Wan2.2-I2V-A14B-GGUF`，並使用其原始檔名：
  - `wan2.2_i2v_high_noise_14B_Q4_K_M.gguf`
  - `wan2.2_i2v_low_noise_14B_Q4_K_M.gguf`
- `wan2.2-i2v-a14b-lightning-gguf-q4km` 補上 I2V workflow 常用依賴：
  - `models/clip_vision/clip_vision_h.safetensors`
- `wan2.2-i2v-a14b-lightning-gguf-q4km` 的文字編碼器與 VAE 改為官方 I2V 常用組合：
  - `models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors`
  - `models/vae/wan_2.1_vae.safetensors`
