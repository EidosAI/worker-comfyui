# WAN 2.2 I2V 研究筆記

## 官方/基礎資料
- https://docs.comfy.org/built-in-nodes/conditioning/video-models/wan-vace-to-video
  - 類型：Comfy 官方節點/模型說明（Wan VACE）
  - 重點：用來理解 Wan 生態內不同路線（一般 I2V vs VACE）。

## 社群可跑基準（GGUF + Lightx2v）
- https://github.com/pwillia7/Basic_ComfyUI_Workflows?tab=readme-ov-file#video
  - 類型：社群 workflow 集合
  - 重點：可作為「先求可跑」的基準拓撲。
- https://www.reddit.com/r/StableDiffusion/comments/1mf28sp/wan22_gguf_lightx2v_workflows_more/
  - 類型：社群實測討論
  - 重點：對照參數對穩定性與首幀連續性的影響。

本專案已保存可追蹤來源檔（可直接匯入 + API 匯出版）：
- `docs/custom/workflows/wan22/source.md`
- `docs/custom/workflows/wan22/source-ui-wan22-lx2v-gguf.json`
- `docs/custom/workflows/wan22/source-api-wan22-lx2v-gguf.json`

## Distill / Lightx2v 路線
- https://huggingface.co/lightx2v/Wan2.2-Distill-Models
  - 類型：Distill 模型路線
  - 重點：蒸餾後通常可用更少步數換取速度。
- https://huggingface.co/jayn7/WAN2.2-I2V_A14B-DISTILL-LIGHTX2V-4STEP-GGUF
  - 類型：Distill + GGUF
  - 重點：作為「不掛 LoRA」的候選 A/B 方案。
- https://www.reddit.com/r/StableDiffusion/comments/1objw27/wan22i2v_a14bdistilllightx2v4stepgguf/
  - 類型：社群分享
  - 重點：觀察部署與速度/品質回饋。

## 其他候選加速路線
- https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne
- https://huggingface.co/Zuntan/Wan22-I2V_A14B-Lightning-GGUF
- https://civitai.com/models/1838587/wan2214baio-gguf-t2v-i2v-flf-video-extend-prompt-progression-6-steps-full-steps
- https://civitai.com/models/1855105/rapid-wan-22-i2v-gguf
- https://www.reddit.com/r/StableDiffusion/comments/1mf47ud/wan_22_vs_wan_22_allinone_rapid_vs_wan_21/
  - 類型：社群方案/比較
  - 重點：偏向速度與低步數方案的集合，待 A/B 驗證。

## 進階加速（Diffusers 生態）
- https://zhuanlan.zhihu.com/p/1943976514321380955
- https://github.com/vipshop/cache-dit/tree/main
  - 類型：推理加速工具
  - 重點：偏 Python/diffusers 路線，不是 Comfy 工作流直套。

## 極速目標參考（待驗證）
- https://zhuanlan.zhihu.com/p/1981363125866481093
  - 類型：LightX2V 端到端延遲與技術棧說明
  - 重點：目標是接近 1:1 即時生成（影片時長接近生成耗時）。
  - 對我們的意義：可作為「極速路線」研究起點，後續要拆解可在 Comfy/RunPod 落地的子技術（4-step、CFG 策略、量化、快取/並行）。

### 文章圖表重點（必看）

圖表標題：`LightX2V E2E Latency for Wan2.1-I2V-14B-480p on 8 GPUs`

- 測試模型/條件（依圖）：
  - Wan2.1-I2V-14B
  - 解析度 480p
  - 比較端到端耗時（E2E latency）
  - 圖上註記是 8 GPUs 條件

- 四種設定（由慢到快）：
  - `cfg`
  - `no cfg`
  - `no cfg + fp8`
  - `no cfg + fp8 + 4 step`

- 圖上數據（秒）：
  - H100：`30.0 -> 15.6 -> 14.0 -> 1.4`
  - RTX 5090：`80.4 -> 46.8 -> 38.8 -> 3.9`
  - RTX 4090：`190.0 -> 125.2 -> 94.0 -> 9.4`

- 可直接讀出的結論：
  - 關閉 CFG（`cfg -> no cfg`）有明顯降時。
  - 只加 FP8（`no cfg -> no cfg+fp8`）有中度降時。
  - 最大降時來自 `4-step`（`no cfg+fp8 -> +4 step`）。
  - 也就是：真正接近「即時」不是單一技巧，而是多個優化疊加。

- 對我們當前路線（Comfy + RunPod + 單/少卡）的啟示：
  - 我們目前已吃到部分能力（4-step 蒸餾路線、低步數 workflow）。
  - 尚未完整覆蓋圖中所有系統優化（例如特定多卡並行策略/完整算子棧），所以不能直接把圖上秒數當成我們可達數字。
  - 這張圖適合作為「優先級排序」依據：先驗證 `4-step + CFG策略 + 量化`，再評估更重的系統級優化。

### 後續可執行實驗（以速度優先）

在同一 prompt、同一首圖、同一長寬、同一幀數下做 A/B：

1. CFG 開關對延遲與首幀穩定性的影響。  
2. GGUF 量化級別（Q4/Q5）對延遲與畫質的影響。  
3. 4-step（Lightx2v/Distill）對比非 4-step 路線。  
4. Distill 模型本體 vs Base+LoRA（同條件）延遲對比。  

輸出固定指標：
- E2E 秒數
- 每秒輸出幀數（等效）
- 首幀一致性（是否明顯跳幀）
- 主觀可用畫質（簡單分級）

## 概念備忘
- GGUF：量化格式，不是訓練方法。
- Distill：蒸餾訓練方法，通常降低步數、提高速度。
- 常見組合：
  - Base GGUF + Distill LoRA
  - Distill 模型本體 + GGUF（通常不再疊同類 distill LoRA）
