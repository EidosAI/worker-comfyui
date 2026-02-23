# RunPod 部署說明（繁中，Z-Image Turbo）

本文件記錄 EidosAI fork (`https://github.com/EidosAI/worker-comfyui`) 目前的部署決策與操作步驟。

## 這次改了什麼

我們已修改 `Dockerfile` 的預設模型類型：

- 檔案：`Dockerfile`
- 變更：`ARG MODEL_TYPE=flux1-dev-fp8` -> `ARG MODEL_TYPE=z-image-turbo`

效果：

- 透過 RunPod GitHub Integration 建置時（未提供 build args 的情況），會預設只下載 `z-image-turbo` 對應模型。
- 不需要額外建立 `Dockerfile.zimage`。

## 為什麼不用 Build Context 來做模型切換

RunPod UI 的 `Build Context` 只決定 Docker build 可見檔案範圍，不能改 `ARG MODEL_TYPE` 值。

- `Build Context`：控制 `COPY/ADD` 可讀到哪些檔案
- `Dockerfile Path`：指定使用哪個 Dockerfile
- `Branch`：指定要建置的 git 分支

因此要固定模型，最直接方式是調整 Dockerfile 預設值（本 repo 已採用）。

## 用 RunPod 網站 UI 部署（GitHub Integration）

前提：

- 已有 RunPod 帳號與可用額度
- RunPod 已授權存取 GitHub repo：`EidosAI/worker-comfyui`

步驟：

1. 進入 RunPod Console -> `Serverless` -> `+ New Endpoint`
2. 選擇 `Start from GitHub Repo`
3. 設定 GitHub 來源：
   - Repository: `EidosAI/worker-comfyui`
   - Branch: 例如 `main`
   - Dockerfile Path: `Dockerfile`
   - Build Context: `/`
4. 設定運算資源：
   - GPU type：依需求選擇
   - Active Workers：可先 `0`
   - Max Workers：先保守設定（例如 `1~3`）
   - GPUs/Worker：通常 `1`
   - Idle Timeout：例如 `5`
   - Flash Boot：建議開啟
5. 環境變數：
   - 目前不設定 S3
6. 按 `Deploy`

## 多個 Endpoint（同一個 GitHub Repo）

目前策略是先在 RunPod UI 手動建立多個 endpoint，全部指向同一個 repo。

可因 endpoint 目的不同，調整：

- Endpoint Name
- GPU / Worker 上限
- Branch（需要隔離變更時）

建議命名範例：

- `comfy-zimage-dev`
- `comfy-zimage-prod`
- `comfy-zimage-batch`

## 驗證清單

部署後請確認：

1. Endpoint 成功啟動且 worker healthy
2. 送出測試任務可產圖
3. 日誌中可看到 z-image-turbo 相關模型載入
4. 沒有 S3 設定時，輸出格式符合目前流程預期

## 後續規劃（暫不實作）

之後若要納入 IaC，再於 `ulo` 建立 `infra/runpod-comfy`，用 Pulumi 管理多 endpoint 設定。
