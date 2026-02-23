# RunPod UI 部署指南（繁中）

本指南適用於目前 EidosAI fork：

- Repo: `https://github.com/EidosAI/worker-comfyui`
- Docker 策略：`runpod/worker-comfyui:5.7.1-base` + z-image-turbo 模型
- 不設定 S3

## 前置條件

- RunPod 帳號可建立 Serverless Endpoint
- RunPod 已授權 GitHub repo 存取權限

## 建立 Endpoint（GitHub Integration）

1. 進入 RunPod Console -> `Serverless` -> `+ New Endpoint`
2. 選 `Start from GitHub Repo`
3. 設定 GitHub build：
   - Repository: `EidosAI/worker-comfyui`
   - Branch: `main`（或你要的分支）
   - Dockerfile Path: `Dockerfile`
   - Build Context: `/`
4. 設定運算資源（可先用保守值）：
   - Active Workers: `0`
   - Max Workers: `1~3`
   - GPUs/Worker: `1`
   - Idle Timeout: `5`
   - Flash Boot: 開啟
5. Environment Variables：
   - 目前不設定 S3
6. 按 `Deploy`

## 重要說明

- `Build Context` 只影響可被 `COPY/ADD` 看見的檔案範圍，不能用來切換模型種類。
- 模型種類由 `Dockerfile` 內容決定；目前固定只下載 z-image-turbo 所需模型。

## 驗證

1. Endpoint 啟動成功，worker 狀態 healthy
2. 提交測試任務可正常產圖
3. Logs 可看到 z-image 相關模型被讀取
