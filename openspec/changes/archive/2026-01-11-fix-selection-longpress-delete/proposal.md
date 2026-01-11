# Fix Selection Border and Long-Press Delete

## Why

1. **選擇框不對齊**：當前的選擇邊框在 overlay 中重複應用了 `position()`, `scaleEffect()`, `rotationEffect()`，導致邊框位置錯誤。
2. **刪除交互不直觀**：點擊選擇 + 工具列刪除的方式不夠直接，用戶希望長按圖片直接顯示刪除選項。

## What Changes

### 1. 修復選擇邊框對齊
- 移除 overlay 內部的 `.position()`, `.scaleEffect()`, `.rotationEffect()` 修飾符
- 讓 overlay 直接繼承父視圖的變換

### 2. 改為長按刪除
- 移除點擊選擇機制（`selectedImageId`, `onSelectImage`, `onDeselect`）
- 添加 `.contextMenu` 或長按手勢顯示刪除選項
- 移除工具列的刪除按鈕

## User Review Required

> [!IMPORTANT]
> 這將完全移除「點擊選擇」的交互模式，改為長按觸發刪除確認。
