# FLUX 2 Klein 研究筆記

## 官方資料
- https://docs.comfy.org/tutorials/flux/flux-2-klein
  - 類型：Comfy 官方教學
  - 重點：節點與模型需求以官方文件為基準。

## 目前策略
- 先固定單一路線（9B distilled）確保可跑。
- 前端只暴露必要參數做快速測試，避免一次引入過多變體。

## 後續方向
- 若要加變體，採增量策略：每次只加一個可驗證變數（模型或步數或 scheduler）。
