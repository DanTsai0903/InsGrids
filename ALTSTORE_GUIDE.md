# 如何使用 AltStore 安裝 InsGrids (免年費、無線續期)

這份指南將教您如何使用 [AltStore](https://altstore.io/) 將 InsGrids 安裝到您的 iPhone 上。這是目前最穩定且免費的安裝方式。

## 第一階段：電腦端準備

### 1. 安裝 AltServer
1. 前往 [altstore.io](https://altstore.io/) 下載 **AltServer (macOS)**。
2. 解壓縮並將 `AltServer.app` 拖入「應用程式」資料夾。
3. 開啟 AltServer（它會出現在頂部選單列）。

### 2. 安裝 Mail Plug-in (必要)
1. 點擊選單列的 AltServer 圖示 > **Install Mail Plug-in**。
2. 開啟 Mac 的「郵件」(Mail) App。
3. 郵件 > 設定 > 一般 > 管理外掛模組... (Manage Plug-ins...)。
4. 勾選 **AltPlugin.mailbundle** 並點擊「允許存取」。
5. 重啟郵件 App。

### 3.生成 App 檔案
我們為您準備了一個自動打包腳本，只需在終端機執行：

```bash
./generate_ipa.sh
```

執行後，資料夾內會出現一個 `InsGrids.ipa` 檔案。這就是我們要安裝的安裝包。

## 第二階段：手機端安裝

### 1. 安裝 AltStore 到手機
1. 用傳輸線將 iPhone 連接至 Mac。
2. 點擊選單列的 AltServer 圖示 > **Install AltStore** > 選擇您的 iPhone。
3. 輸入您的 Apple ID 和密碼（這僅用於向 Apple 申請免費憑證，很安全）。
4. 幾秒後，AltStore App 就會出現在您的 iPhone 上。

### 2. 信任開發者
1. 在 iPhone 上，前往 **設定 > 一般 > VPN 與裝置管理**。
2. 點擊您的 Apple ID。
3. 點擊「信任...」。

## 第三階段：安裝 InsGrids

1. **傳送檔案**：將剛剛電腦生成的 `InsGrids.ipa` 透過 AirDrop 傳送到 iPhone。
2. **安裝**：
   - 在 iPhone 上打開 AltStore。
   - 點擊下方的 **My Apps**。
   - 點擊左上角的 **+** 號。
   - 選擇剛剛傳送的 `InsGrids.ipa`。
   - 如果是第一次使用，需要再次輸入 Apple ID。
3. **完成！** InsGrids 現在已經安裝在您的手機上，並且可以正常使用了。

## 如何保持 App 不過期？

免費帳號的 App 只有 7 天有效期。但 AltStore 會自動幫您續命：
1. 確保電腦上的 **AltServer** 是開啟的。
2. 確保 iPhone 和電腦連在 **同一個 Wi-Fi**。
3. AltStore 會在背景自動更新簽名（您可以隨時打開 AltStore 查看剩餘天數）。

只要每 7 天內有一次機會讓手機和電腦在同一個 Wi-Fi 下相遇，您的 App 就可以永久使用！

## 如何更新 App？

當 InsGrids 有新功能發佈或修復 Bug 時，更新步驟非常簡單：

1. **重新生成檔案**：
   - 在電腦上重新執行打包腳本：
     ```bash
     ./generate_ipa.sh
     ```
   - 這會產生最新的 `InsGrids.ipa`。

2. **覆蓋安裝**：
   - 將新的 IPA 傳送到手機。
   - 用 AltStore 再次開啟它。
   - AltStore 會自動覆蓋舊版本，您的設定和資料通常會保留。

**注意**：不需要刪除舊版 App，直接安裝新版即可覆蓋。
