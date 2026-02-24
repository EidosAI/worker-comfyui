# Comfy Core 與相容性筆記

## 目標
記錄會影響 workflow 可用性的 Comfy 核心版本、節點可用欄位、以及常見不相容訊號。

## 已觀察重點
- 同一份 workflow 在不同 Comfy 版本上，節點輸入欄位可能不同。
- 匯出 API workflow 時，若節點缺失或 custom node 不存在，會出現 `UNKNOWN` 或驗證失敗。
- 常見錯誤包含：
  - `required_input_missing`
  - `value_not_in_list`
  - channels 維度不匹配

## 建議流程
1. 先確認 Comfy 版本與節點清單（object_info）。
2. 再檢查模型檔名是否與節點下拉列表一致。
3. 最後才調參數，避免把相容性問題誤判為調參問題。

## RunPod / 部署相關參考
- https://docs.runpod.io/api-reference/endpoints/POST/endpoints
- https://docs.runpod.io/storage/s3-api
