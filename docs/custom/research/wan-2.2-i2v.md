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

## 概念備忘
- GGUF：量化格式，不是訓練方法。
- Distill：蒸餾訓練方法，通常降低步數、提高速度。
- 常見組合：
  - Base GGUF + Distill LoRA
  - Distill 模型本體 + GGUF（通常不再疊同類 distill LoRA）
