@echo off
chcp 65001 >nul
title GitGuard Sync - 快速修復工具

echo.
echo ████████████████████████████████████████████████████████████████████
echo █                                                                  █
echo █              GitGuard Sync 快速修復工具 v3.0.1                  █
echo █                                                                  █
echo █              解決所有 Windows 相關問題                          █
echo █                                                                  █
echo ████████████████████████████████████████████████████████████████████
echo.

echo 🛠️  正在診斷並修復問題...
echo.

:: 步驟 1: 檢查 Python
echo [檢查 1/5] Python 環境檢測...
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Python 可用: 
    python --version
    set PYTHON_CMD=python
    goto :check_files
)

python3 --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Python3 可用:
    python3 --version
    set PYTHON_CMD=python3
    goto :check_files
)

py --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ py 命令可用:
    py --version
    set PYTHON_CMD=py
    goto :check_files
)

echo ❌ 未找到 Python！
echo.
echo 🔧 請先安裝 Python：
echo    1. 前往 https://python.org/downloads/
echo    2. 下載 Python 3.7+ 版本
echo    3. 安裝時勾選 "Add Python to PATH"
echo    4. 重新啟動電腦後再執行此腳本
echo.
pause
exit /b 1

:check_files
:: 步驟 2: 檢查檔案
echo.
echo [檢查 2/5] 專案檔案檢測...
if exist "gitguard_sync.py" (
    echo ✅ 主程式檔案存在
) else (
    echo ❌ 找不到 gitguard_sync.py
    echo.
    echo 🔧 請確認：
    echo    1. 您在正確的資料夾中
    echo    2. gitguard_sync.py 檔案存在
    echo    3. 重新下載完整的專案檔案
    echo.
    pause
    exit /b 1
)

:: 步驟 3: 安裝依賴
echo.
echo [檢查 3/5] 安裝必要套件...
echo 📦 正在安裝 gitpython 和 requests...
%PYTHON_CMD% -m pip install gitpython requests --quiet --disable-pip-version-check
if %errorlevel% == 0 (
    echo ✅ 套件安裝成功
) else (
    echo ⚠️  套件安裝可能有問題，但繼續嘗試
)

:: 步驟 4: 測試程式
echo.
echo [檢查 4/5] 測試程式功能...
%PYTHON_CMD% -c "import sys; import tkinter; import git; import requests; print('✅ 所有模組正常載入')" 2>nul
if %errorlevel% == 0 (
    echo ✅ 程式功能測試通過
) else (
    echo ⚠️  某些模組可能有問題，但仍可啟動
)

:: 步驟 5: 創建啟動檔案
echo.
echo [檢查 5/5] 創建啟動檔案...

:: 創建最簡單的啟動腳本
echo @echo off > 啟動程式.bat
echo title GitGuard Sync >> 啟動程式.bat
echo echo 🚀 啟動 GitGuard Sync... >> 啟動程式.bat
echo %PYTHON_CMD% gitguard_sync.py >> 啟動程式.bat
echo pause >> 啟動程式.bat

echo ✅ 啟動腳本已創建: 啟動程式.bat

:: 創建建置腳本
echo @echo off > 建置程式.bat
echo title 建置 GitGuard Sync >> 建置程式.bat
echo echo 🔨 安裝 PyInstaller... >> 建置程式.bat
echo %PYTHON_CMD% -m pip install pyinstaller --quiet >> 建置程式.bat
echo echo 🔨 開始建置... >> 建置程式.bat
echo %PYTHON_CMD% -m PyInstaller --onefile --windowed gitguard_sync.py >> 建置程式.bat
echo echo ✅ 建置完成！ >> 建置程式.bat
echo explorer dist >> 建置程式.bat
echo pause >> 建置程式.bat

echo ✅ 建置腳本已創建: 建置程式.bat

echo.
echo 🎉 修復完成！現在您可以：
echo.
echo    方法 1: 雙擊 "啟動程式.bat"
echo    方法 2: 雙擊 "建置程式.bat" (建置獨立執行檔)
echo    方法 3: 在命令提示字元輸入: %PYTHON_CMD% gitguard_sync.py
echo.

choice /C 123 /M "請選擇：1-立即啟動程式 2-建置執行檔 3-退出"

if errorlevel 3 goto :end
if errorlevel 2 goto :build
if errorlevel 1 goto :launch

:launch
echo.
echo 🚀 正在啟動程式...
start "" "%PYTHON_CMD%" "gitguard_sync.py"
echo ✅ 啟動命令已執行
goto :end

:build
echo.
echo 🔨 正在建置執行檔...
start "" "建置程式.bat"
echo ✅ 建置腳本已執行
goto :end

:end
echo.
echo 🙏 感謝使用 GitGuard Sync！
echo 💡 如有問題請聯絡: noreply@example.com
echo.
pause