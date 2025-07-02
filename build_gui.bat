@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                          GitGuard Sync 自動建置工具                          ║
echo ║                     Git 倉庫安全同步守護者 - v3.0.0                         ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

:: 設定變數
set "APP_NAME=GitGuard-Sync"
set "SCRIPT_NAME=gitguard_sync.py"
set "VERSION=3.0.0"
set "DIST_DIR=release"
set "BUILD_DIR=build"

:: 檢查 Python 環境
echo [1/6] 檢查 Python 環境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: 找不到 Python，請先安裝 Python 3.7 或更高版本
    pause
    exit /b 1
)

python -c "import sys; exit(0 if sys.version_info >= (3,7) else 1)" >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: Python 版本過低，需要 3.7 或更高版本
    pause
    exit /b 1
)

echo ✅ Python 環境檢查通過

:: 檢查必要檔案
echo.
echo [2/6] 檢查專案檔案...
if not exist "%SCRIPT_NAME%" (
    echo ❌ 錯誤: 找不到主程式檔案 %SCRIPT_NAME%
    pause
    exit /b 1
)

echo ✅ 專案檔案檢查通過

:: 安裝依賴套件
echo.
echo [3/6] 安裝建置依賴...
pip install --upgrade pyinstaller >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: 安裝 PyInstaller 失敗
    pause
    exit /b 1
)

pip install --upgrade gitpython requests >nul 2>&1
if errorlevel 1 (
    echo ❌ 錯誤: 安裝專案依賴失敗
    pause
    exit /b 1
)

echo ✅ 依賴套件安裝完成

:: 清理舊檔案
echo.
echo [4/6] 清理舊建置檔案...
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%" >nul 2>&1
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%" >nul 2>&1
if exist "*.spec" del /q "*.spec" >nul 2>&1

echo ✅ 舊檔案清理完成

:: 建立圖示檔案（如果不存在）
if not exist "icon.ico" (
    echo 🎨 未找到圖示檔案，將不使用自訂圖示
    set "ICON_PARAM="
) else (
    echo 🎨 找到圖示檔案，將使用自訂圖示
    set "ICON_PARAM=--icon=icon.ico"
)

:: 執行打包
echo.
echo [5/6] 開始建置執行檔...
echo 📦 建置模式: 單一執行檔
echo 🎯 目標平台: Windows
echo 📂 輸出目錄: %DIST_DIR%
echo.

pyinstaller ^
    --onefile ^
    --windowed ^
    --name "%APP_NAME%" ^
    --distpath "%DIST_DIR%" ^
    --workpath "%BUILD_DIR%" ^
    --clean ^
    --noconfirm ^
    %ICON_PARAM% ^
    --add-data "README.md;." ^
    --hidden-import tkinter ^
    --hidden-import tkinter.ttk ^
    --hidden-import tkinter.font ^
    --hidden-import tkinter.filedialog ^
    --hidden-import tkinter.messagebox ^
    --hidden-import tkinter.scrolledtext ^
    --hidden-import git ^
    --hidden-import git.repo ^
    --hidden-import git.remote ^
    --hidden-import requests ^
    --hidden-import threading ^
    --hidden-import subprocess ^
    --hidden-import pathlib ^
    --hidden-import json ^
    --hidden-import re ^
    --hidden-import webbrowser ^
    "%SCRIPT_NAME%"

if errorlevel 1 (
    echo.
    echo ❌ 建置失敗！請檢查上方錯誤訊息
    pause
    exit /b 1
)

:: 檢查建置結果
echo.
echo [6/6] 驗證建置結果...
if exist "%DIST_DIR%\%APP_NAME%.exe" (
    echo ✅ 建置成功！
    echo.
    echo 📊 建置資訊:
    dir "%DIST_DIR%\%APP_NAME%.exe" | find "%APP_NAME%.exe"
    echo.
    echo 📁 檔案位置: %cd%\%DIST_DIR%\%APP_NAME%.exe
    echo.
    
    :: 詢問是否測試執行檔
    choice /C YN /M "是否要測試執行檔案 (Y/N)"
    if !errorlevel! == 1 (
        echo.
        echo 🚀 啟動測試...
        start "" "%DIST_DIR%\%APP_NAME%.exe"
    )
    
    :: 詢問是否開啟輸出目錄
    choice /C YN /M "是否要開啟輸出目錄 (Y/N)"
    if !errorlevel! == 1 (
        explorer "%DIST_DIR%"
    )
    
) else (
    echo ❌ 建置失敗: 找不到輸出檔案
    pause
    exit /b 1
)

:: 清理建置快取（可選）
echo.
choice /C YN /M "是否要清理建置快取以節省空間 (Y/N)"
if !errorlevel! == 1 (
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%" >nul 2>&1
    if exist "*.spec" del /q "*.spec" >nul 2>&1
    echo ✅ 建置快取已清理
)

echo.
echo 🎉 GitGuard Sync v%VERSION% 建置完成！
echo 📦 執行檔位置: %DIST_DIR%\%APP_NAME%.exe
echo 💡 提示: 您可以將此執行檔複製到任何 Windows 電腦上使用
echo.
pause