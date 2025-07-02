# GitGuard Sync 🔐

[![Version](https://img.shields.io/badge/version-3.0.1-blue.svg)](https://github.com/seikaikyo/gitguard-sync)
[![Python](https://img.shields.io/badge/python-3.7%2B-green.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/seikaikyo/gitguard-sync)

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  ██████╗ ██╗████████╗ ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗              ║
║ ██╔════╝ ██║╚══██╔══╝██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗             ║
║ ██║  ███╗██║   ██║   ██║  ███╗██║   ██║███████║██████╔╝██║  ██║             ║
║ ██║   ██║██║   ██║   ██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║             ║
║ ╚██████╔╝██║   ██║   ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝             ║
║  ╚═════╝ ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝              ║
║                                                                              ║
║  ███████╗██╗   ██╗███╗   ██╗ ██████╗    ██╗   ██╗██████╗ ██╗██████╗         ║
║  ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝    ██║   ██║╚════██╗██║██╔══██╗        ║
║  ███████╗ ╚████╔╝ ██╔██╗ ██║██║         ██║   ██║ █████╔╝██║██████╔╝        ║
║  ╚════██║  ╚██╔╝  ██║╚██╗██║██║         ╚██╗ ██╔╝ ╚═══██╗██║██╔══██╗        ║
║  ███████║   ██║   ██║ ╚████║╚██████╗     ╚████╔╝ ██████╔╝██║██████╔╝        ║
║  ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝      ╚═══╝  ╚═════╝ ╚═╝╚═════╝         ║
║                                                                              ║
║                        🔐 Git 倉庫安全同步守護者 🔐                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> **專業級 Git 倉庫安全同步工具** - 支援雙平台同步、GitGuardian 整合、現代化 GUI 介面

## 📋 目錄

- [特色功能](#-特色功能)
- [系統需求](#-系統需求)
- [快速開始](#-快速開始)
- [安裝指南](#-安裝指南)
- [使用說明](#-使用說明)
- [建置執行檔](#-建置執行檔)
- [功能詳解](#-功能詳解)
- [修改歷程](#-修改歷程)
- [常見問題](#-常見問題)
- [技術支援](#-技術支援)
- [授權條款](#-授權條款)

## 🌟 特色功能

### 🔒 專業安全掃描

- **本地安全掃描** - 內建多種安全模式檢測
- **GitGuardian API 整合** - 專業級機敏資料檢測
- **智慧檔案過濾** - 自動識別需要掃描的檔案類型
- **詳細報告產出** - JSON/TXT 格式匯出掃描結果

### 🌐 雙平台同步支援

- **GitHub 整合** - 完整支援 GitHub 倉庫操作
- **GitLab 整合** - 無縫連接 GitLab 私有/公有倉庫
- **智慧推送** - 自動檢測並推送到多個遠端倉庫
- **連線測試** - 即時驗證遠端倉庫連線狀態

### 🖥️ 現代化 GUI 介面

- **直觀操作** - 友好的圖形化使用介面
- **即時日誌** - 詳細的操作過程記錄
- **進度顯示** - 清晰的任務執行進度
- **多國語言** - 支援繁體中文操作介面

### 🛠️ 強大的輔助工具

- **倉庫狀態檢視** - 完整的 Git 倉庫資訊顯示
- **自動 .gitignore** - 智慧產生安全檔案忽略規則
- **環境變數範本** - 自動建立 .env.example 檔案
- **跨平台支援** - Windows、macOS、Linux 全平台支援

## 💻 系統需求

### 基本需求

- **Python**: 3.7 或更高版本
- **作業系統**: Windows 7+、macOS 10.12+、Linux (任何現代發行版)
- **記憶體**: 至少 100MB 可用記憶體
- **硬碟空間**: 50MB 可用空間

### Python 依賴套件

```bash
gitpython>=3.1.0    # Git 操作核心庫
requests>=2.25.0    # HTTP 請求處理
tkinter             # GUI 框架 (通常內建)
```

### 選用需求

- **GitGuardian API 金鑰** - 啟用專業安全掃描功能
- **Git 客戶端** - 建議安裝最新版本的 Git

## 🚀 快速開始

### 方法一：一鍵啟動 (推薦)

**Linux/macOS:**

```bash
chmod +x quick_start.sh
./quick_start.sh
```

**Windows:**

```cmd
quick_start.bat
```

### 方法二：直接執行

```bash
# 安裝依賴
pip install gitpython requests

# 執行程式
python3 gitguard_sync.py
```

### 方法三：使用跨平台啟動器

```bash
python3 launcher.py
```

## 📦 安裝指南

### 1. 克隆倉庫

```bash
git clone https://github.com/seikaikyo/gitguard-sync.git
cd gitguard-sync
```

### 2. 安裝依賴

```bash
# 使用 pip 安裝
pip install -r requirements.txt

# 或手動安裝核心依賴
pip install gitpython requests
```

### 3. 驗證安裝

```bash
python3 gitguard_sync.py --version
```

### 4. 可選：設定 GitGuardian API

```bash
# 設定環境變數
export GITGUARDIAN_API_KEY="your_api_key_here"

# 或在程式中設定
```

## 📖 使用說明

### 基本操作流程

1. **選擇工作目錄**

   - 點擊「📂 瀏覽目錄」選擇 Git 倉庫
   - 或直接在目前目錄下執行程式

2. **配置遠端倉庫**

   - 點擊「⚙️ 配置遠端」新增 GitHub/GitLab 倉庫
   - 使用「🔍 測試連線」驗證設定

3. **執行安全掃描**

   - **本地掃描**: 使用內建規則檢測潛在安全問題
   - **GitGuardian 掃描**: 使用專業 API 進行深度檢測

4. **處理掃描結果**

   - 檢視詳細的安全問題報告
   - 自動產生 .gitignore 和環境變數範本
   - 匯出詳細報告

5. **同步推送**
   - 提交變更到本地倉庫
   - 同步推送到所有配置的遠端倉庫

### GitGuardian API 設定

1. 註冊 [GitGuardian](https://www.gitguardian.com/) 帳號
2. 取得 API 金鑰
3. 在程式中設定 API 金鑰
4. 享受專業級安全掃描功能

## 🔨 建置執行檔

### 跨平台建置 (推薦)

```bash
python3 build_script.py
```

### Windows 快速建置

```cmd
simple_build.bat
```

### 手動建置

```bash
# 安裝 PyInstaller
pip install pyinstaller

# 建置執行檔
pyinstaller --onefile --windowed --name GitGuard-Sync gitguard_sync.py
```

建置完成後，執行檔將位於 `release/` 或 `dist/` 目錄中。

## 🔧 功能詳解

### 安全掃描功能

#### 本地掃描模式

- **AWS 訪問金鑰檢測** - 識別 AWS 相關憑證
- **GitHub Token 檢測** - 偵測 GitHub 個人訪問令牌
- **JWT Token 分析** - 檢查 JSON Web Token
- **API 金鑰掃描** - 通用 API 金鑰模式匹配
- **資料庫連線字串** - 檢測資料庫 URL 洩漏
- **SSH 私鑰檢測** - 識別 SSH 私鑰檔案
- **Email 地址提取** - 掃描程式碼中的郵件地址

#### GitGuardian 專業掃描

- **200+ 機敏資料類型** - 涵蓋主流服務的 API 金鑰
- **上下文分析** - 智慧判斷誤報情況
- **嚴重程度評估** - 高/中/低風險分級
- **修復建議** - 提供具體的安全修復指導

### 倉庫同步功能

#### 支援的 Git 平台

- **GitHub** - 公有和私有倉庫
- **GitLab** - GitLab.com 和私有實例
- **其他 Git 服務** - 任何標準 Git 協議的服務

#### 同步功能

- **多遠端推送** - 同時推送到多個遠端倉庫
- **智慧衝突處理** - 自動檢測並提示衝突情況
- **分支管理** - 支援多分支操作
- **標籤同步** - 同步 Git 標籤到所有遠端

## 📝 修改歷程

### v3.0.1 (2024-01-XX) - 修復版 🔧

#### 🐛 錯誤修復

- **[Critical]** 修復程式無法正常關閉的問題

  - 添加正確的線程控制初始化 (`self.stop_threads = threading.Event()`)
  - 改進視窗關閉處理機制，增加異常捕獲
  - 解決 `AttributeError: 'GitGuardSyncGUI' object has no attribute 'stop_threads'` 錯誤

- **[UI]** 修復 ASCII 藝術標題置中顯示問題
  - 使用 `tag_config` 實現文字完美置中
  - 調整副標題布局，確保品牌一致性
  - 優化視覺呈現效果

#### 🚀 功能改進

- **[Build]** 大幅改進建置腳本穩定性

  - 增強 Python 環境檢測機制
  - 添加完整的隱藏匯入模組列表
  - 改進錯誤處理和用戶提示信息
  - 添加建置後自動驗證功能

- **[Setup]** 優化快速啟動腳本
  - 實現智能作業系統檢測
  - 支援多種 Python 命令自動嘗試
  - 增加全面的模組測試功能
  - 生成多平台啟動腳本

#### 🛠️ 技術改進

- **線程管理**: 正確初始化和清理線程控制物件
- **UI 布局**: 使用標準 tkinter 置中方法
- **建置流程**: 完整的依賴管理和錯誤處理
- **跨平台**: 智能環境檢測和適配機制

### v3.0.0 (2024-01-XX) - 初始發布 🎉

#### ✨ 核心功能

- **安全掃描引擎** - 本地 + GitGuardian API 雙重掃描
- **雙平台同步** - GitHub + GitLab 完整支援
- **現代化 GUI** - 基於 tkinter 的直觀介面
- **即時進度顯示** - 清晰的任務執行狀態
- **詳細操作日誌** - 完整的操作過程記錄

#### 🔧 技術特色

- **跨平台支援** - Windows、macOS、Linux 三大平台
- **模組化設計** - 清晰的程式架構和代碼組織
- **異常處理** - 完善的錯誤處理和恢復機制
- **用戶體驗** - 友好的操作提示和幫助信息

#### 📦 工具鏈

- **建置腳本** - 自動化的執行檔打包工具
- **快速啟動** - 一鍵式環境設定和程式啟動
- **依賴管理** - 智能的套件安裝和檢查機制

### 開發里程碑 🏆

- **2024-01** - 項目啟動，核心功能開發
- **2024-01** - GUI 介面設計和實現
- **2024-01** - GitGuardian API 整合完成
- **2024-01** - 跨平台建置工具完成
- **2024-01** - v3.0.0 初始版本發布
- **2024-01** - v3.0.1 修復版本發布

## ❓ 常見問題

### Q: 程式無法啟動，提示找不到模組？

**A:** 請確認已安裝所需依賴：

```bash
pip install gitpython requests
```

### Q: GitGuardian 掃描功能無法使用？

**A:** 請檢查：

1. 是否已設定有效的 API 金鑰
2. 網路連線是否正常
3. API 金鑰是否有足夠權限

### Q: 建置執行檔失敗？

**A:** 常見解決方法：

```bash
# 升級 PyInstaller
pip install --upgrade pyinstaller

# 清除快取重新建置
rm -rf build dist *.spec
python3 build_script.py
```

### Q: Linux 下 tkinter 不可用？

**A:** 安裝 tkinter 依賴：

```bash
# Ubuntu/Debian
sudo apt-get install python3-tk

# CentOS/RHEL
sudo yum install tkinter

# Arch Linux
sudo pacman -S tk
```

### Q: Windows 防毒軟體誤報？

**A:** 建議將程式執行檔加入防毒軟體的白名單，這是 PyInstaller 打包程式的常見問題。

### Q: 如何更新到最新版本？

**A:** 從 GitHub 下載最新版本：

```bash
git pull origin main
# 或重新下載整個倉庫
```

## 📞 技術支援

### 聯絡方式

- **作者**: 
- **GitHub**: [https://github.com/seikaikyo/gitguard-sync](https://github.com/seikaikyo/gitguard-sync)

### 問題回報

如果您遇到任何問題，請通過以下方式回報：

1. **GitHub Issues** (推薦)

   - 前往 [Issues 頁面](https://github.com/seikaikyo/gitguard-sync/issues)
   - 創建新 Issue 並詳細描述問題

2. **問題聯絡**
   - 請附上錯誤日誌和系統資訊

### 貢獻指南

歡迎為項目做出貢獻！請遵循以下步驟：

1. Fork 本倉庫
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 創建 Pull Request

## 📄 授權條款

本項目採用 MIT 授權條款。詳細內容請參閱 [LICENSE](LICENSE) 檔案。

```
MIT License

Copyright (c) 2024 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🌟 支持項目

如果這個項目對您有幫助，請考慮：

- ⭐ 給項目點個星星
- 🐛 回報遇到的問題
- 💡 提出新功能建議
- 🔀 提交 Pull Request
- 📢 向朋友推薦這個工具

---

<div align="center">

**感謝使用 GitGuard Sync！** 🎉

_讓 Git 倉庫管理更安全、更簡單_

</div>
