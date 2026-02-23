# Decisions

## 2026-02-23: 基於 `worker-comfyui:*-base`

決策：

- 使用 `runpod/worker-comfyui:5.7.1-base` 作為 Docker 基底。

原因：

- 可跳過前段 runtime 建置，縮短 RunPod GitHub Integration 的 build 時間。
- 對齊官方 runtime，降低自行維護 Python/CUDA/ComfyUI 安裝流程的成本。

## 2026-02-23: 模型策略先鎖定 z-image-turbo

決策：

- 目前只使用 z-image-turbo 所需模型，不打包其他模型。
- 採用 pure volume-first：模型不放 image，統一放 Network Volume。

原因：

- 現階段目標單純，先確認端到端部署穩定。
- 降低 image 體積與 build 時間。
- 模型可獨立更新，不需重建 image。

## 2026-02-23: 先用 RunPod UI，暫緩 Pulumi

決策：

- 先透過 RunPod 網站 UI 建立 endpoint 驗證可運作，再導入 `ulo/infra/runpod-comfy`。

原因：

- 先驗證 workflow 與 runtime 正常，再做 IaC 抽象可降低排錯成本。
