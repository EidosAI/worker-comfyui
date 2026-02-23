# Custom Docs

這個資料夾專門記錄 EidosAI 在 `worker-comfyui` fork 上的部署與客製決策，避免資訊散落在單一文件。

## 文件索引

- `changes.md`: 變更紀錄（每次調整都要補）
- `decisions.md`: 技術決策與理由
- `deploy-runpod-ui.md`: 使用 RunPod 網站 UI 的部署步驟（繁中）
- `volume-bootstrap.md`: 用 Pod 直接把模型下載到 Network Volume（繁中）

## 維護規則

每次修改下列任一項目時，都要同步更新 `changes.md` 與必要的部署文件：

- `Dockerfile`
- RunPod 部署方式（Branch / Dockerfile Path / Build Context）
- 模型下載內容（例如 z-image-turbo）
- Endpoint 建議參數
