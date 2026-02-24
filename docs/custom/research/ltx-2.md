# LTX-2 研究筆記

## 官方來源

- 模型卡（主入口）：https://huggingface.co/Lightricks/LTX-2
- 官方程式碼與推理說明：https://github.com/Lightricks/LTX-2
- 官方模型/LoRA 集合：https://huggingface.co/collections/Lightricks/ltx-2
- Comfy 官方教學頁：https://docs.comfy.org/tutorials/video/ltx/ltx-2

## LTX-2 是什麼

- LTX-2 是 Lightricks 的 19B 音視訊（audio+video）基礎模型。
- 官方模型卡列出的主線 checkpoint 與 upscaler 都在同一個 Hugging Face repo。

## 可選版本（先看主模型）

以下名稱來自官方模型卡 `Model Checkpoints`：

1. `ltx-2-19b-dev`
- 說明：完整可訓練 bf16 版本。
- 典型用途：品質/可調整性優先。

2. `ltx-2-19b-dev-fp8`
- 說明：完整模型的 fp8 量化版本。
- 典型用途：在盡量保留完整模型能力下，降低顯存與延遲。

3. `ltx-2-19b-dev-fp4`
- 說明：完整模型的 nvfp4 量化版本。
- 典型用途：更省資源、速度更高，但畫質/穩定性風險通常比 fp8 高。

4. `ltx-2-19b-distilled`
- 說明：蒸餾版本，官方註記 8 steps、CFG=1。
- 典型用途：速度優先，快速出片。

5. `ltx-2-19b-distilled-lora-384`
- 說明：可套在 full model 的 distilled LoRA。
- 典型用途：沿用 full model 路線時，導入蒸餾行為。

6. `ltx-2-spatial-upscaler-x2-1.0`
- 說明：空間 x2 latent upscaler（多階段高解析流程用）。

7. `ltx-2-temporal-upscaler-x2-1.0`
- 說明：時間 x2 latent upscaler（多階段高 FPS 流程用）。

補充：官方 GitHub README 也列出 `ltx-2-19b-distilled-fp8.safetensors` 作為可下載主 checkpoint 選項（同屬速度優先路線）。

## Comfy 官方教學補充（重點）

Comfy 官方頁把 LTX-2 定位為：
- 19B DiT 音視訊模型
- 單次流程可同時生成同步的 video + audio

官方頁列出的核心能力：
1. 同步音視訊生成（motion / dialogue / SFX / music）
2. 多種模式：T2V / I2V / V2V
3. 控制路線：Canny / Depth / Pose（IC-LoRAs）
4. Keyframe interpolation
5. 原生空間/時間 upscaling（x2）
6. Prompt enhancement 支援

## Comfy 官方模板工作流（可直接追蹤）

### Text-to-Video
- Base:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_t2v.json
- Distilled:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_t2v_distilled.json

### Image-to-Video
- Base:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_i2v.json
- Distilled:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_i2v_distilled.json

### Control-to-Video
- Depth:
  - https://github.com/Comfy-Org/workflow_templates/raw/refs/heads/main/templates/video_ltx2_depth_to_video.json
- Canny:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_canny_to_video.json
- Pose:
  - https://raw.githubusercontent.com/Comfy-Org/workflow_templates/refs/heads/main/templates/video_ltx2_pose_to_video.json

## Prompt 規範（Comfy 官方頁重點）

官方頁建議：
1. 用時間順序描述動作與場景（單段、連續敘述）。  
2. 描述要包含：動作細節、主體外觀、背景環境、鏡頭運動、光影顏色、事件變化。  
3. 建議 prompt 長度控制在 200 詞內。  

這對我們的意義：
- 若要做速度 A/B 測試，prompt 必須固定且具體，不然結果抖動太大。  
- 先做短且具體 prompt，再擴展到長 prompt，比較容易得到可重現基線。  

## 速度優先且盡量不掉太多品質：推薦嘗試順序

### A. 首選（速度/品質折衷）
- `ltx-2-19b-distilled-fp8` + `DistilledPipeline`
- 理由：
  - Distilled 走少步數（官方說明 DistilledPipeline 為最快）
  - FP8 降低資源壓力
  - 通常比 fp4 更穩定

### B. 次選（品質再高一點，速度稍慢）
- `ltx-2-19b-dev-fp8`
- 理由：保留 full model 特性，速度仍優於 bf16/full。

### C. 極限省資源/極速測試
- `ltx-2-19b-dev-fp4`
- 理由：資源最省、可能最快；但畫質與穩定性通常最需要實測驗證。

### D. 品質與可訓練性優先
- `ltx-2-19b-dev`（bf16）
- 理由：完整能力，但成本最高。

## 官方明確的加速建議（GitHub README）

官方 README 的 Optimization Tips 重點：

1. 用 `DistilledPipeline`（官方標示最快，預設 sigmas；stage1 8 steps + stage2 4 steps）。
2. 啟用 FP8 transformer（`--enable-fp8` / `fp8transformer=True`）。
3. 安裝 attention 優化（xFormers 或 Flash Attention 3）。
4. 在可接受畫質前提下，利用梯度估計減步數（如從 40 減到 20-30）。
5. VRAM 足夠時，減少階段間 memory cleanup 開銷。
6. 若可接受品質，改用 one-stage pipeline 追求速度。

## 你要追蹤的「版本群」

除了主模型外，官方 collection 還有：
- Camera-control LoRAs（Dolly/Jib/Static）
- IC-LoRAs（Canny/Depth/Pose/Detailer/Union）

這些是功能型增強，不是主模型替代。選型時應先定主模型，再決定是否掛 LoRA。

## 我們建議的實驗矩陣（之後可直接照跑）

固定同條件（同 prompt、同種子、同解析度、同幀數）做 A/B：

1. `distilled-fp8` vs `dev-fp8`
2. `dev-fp8` vs `dev-fp4`
3. `distilled-fp8 + one-stage` vs `distilled-fp8 + two-stage`
4. 是否掛 camera/IC LoRA 對延遲與畫質影響

輸出固定指標：
- E2E 時間
- 每秒輸出幀數（等效）
- 顯存峰值
- 主觀畫質等級（可用/可發/高品質）

## 來源註記

- 本頁內容優先依據官方來源（Hugging Face 模型卡、Lightricks GitHub README、官方 HF collection）。
- 若未來官方更新 checkpoint 名稱或 pipeline 建議，需優先同步本檔。
