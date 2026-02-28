@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ═══════════════════════════════════════════════════════════════════════════════
echo                    GitGuard Sync 簡化建置腳本 (修復版)
echo                         快速測試版 - v3.0.1 (修復版)
echo ═══════════════════════════════════════════════════════════════════════════════
echo.

:: 設定變數
set "APP_NAME=GitGuard-Sync"
set "SCRIPT_NAME=gitguard_sync.py"
set "VERSION=3.0.1"
set "DIST_DIR=release"

:: 顯示系統資訊
echo 🖥️  系統資訊:
echo    作業系統: %OS%
echo    處理器: %PROCESSOR_ARCHITECTURE%
echo    使用者: %USERNAME%
echo.

:: 檢查 Python 環境
echo [1/6] 檢查 Python 環境...
set "PYTHON_CMD="

:: 嘗試各種 Python 命令
for %%p in (python3 python py python3.11 python3.10 python3.9 python3.8 python3.7) do (
    where %%p >nul 2>&1
    if !errorlevel! == 0 (
        %%p --version >nul 2>&1
        if !errorlevel! == 0 (
            set "PYTHON_CMD=%%p"
            goto :python_found
        )
    )
)

echo ❌ 找不到 Python，請先安裝 Python 3.7+
echo 💡 下載地址: https://python.org
pause
exit /b 1

:python_found
echo ✅ 找到 Python: %PYTHON_CMD%
%PYTHON_CMD% --version

:: 檢查檔案
echo.
echo [2/6] 檢查必要檔案...
if not exist "%SCRIPT_NAME%" (
    echo ❌ 找不到主程式檔案: %SCRIPT_NAME%
    echo 💡 請確認您在正確的目錄中執行此腳本
    pause
    exit /b 1
)
echo ✅ 檔案檢查通過

:: 安裝依賴
echo.
echo [3/6] 安裝建置依賴...
echo 📦 升級 pip...
%PYTHON_CMD% -m pip install --upgrade pip >nul 2>&1
if errorlevel 1 (
    echo ⚠️  pip 升級失敗，但繼續進行
)

echo 📦 安裝 PyInstaller...
%PYTHON_CMD% -m pip install --upgrade pyinstaller >nul 2>&1
if errorlevel 1 (
    echo ❌ PyInstaller 安裝失敗
    echo 💡 請檢查網路連線或手動安裝: pip install pyinstaller
    pause
    exit /b 1
)

echo 📦 安裝專案依賴...
%PYTHON_CMD% -m pip install --upgrade gitpython requests >nul 2>&1
if errorlevel 1 (
    echo ⚠️  專案依賴安裝可能有問題，但繼續建置
)
echo ✅ 依賴安裝完成

:: 清理舊檔案
echo.
echo [4/6] 清理舊建置檔案...
if exist "%DIST_DIR%" (
    echo 🗑️  移除舊的 %DIST_DIR% 目錄...
    rmdir /s /q "%DIST_DIR%" >nul 2>&1
)
if exist "build" (
    echo 🗑️  移除舊的 build 目錄...
    rmdir /s /q "build" >nul 2>&1
)
for %%f in (*.spec) do (
    if exist "%%f" (
        echo 🗑️  移除舊的 spec 檔案: %%f
        del /q "%%f" >nul 2>&1
    )
)
echo ✅ 清理完成

:: 執行建置
echo.
echo [5/6] 開始建置執行檔...
echo 📦 正在建置，請稍候...
echo.

:: 建置命令 (修復版，包含所有必要參數)
%PYTHON_CMD% -m PyInstaller ^
    --onefile ^
    --windowed ^
    --name "%APP_NAME%" ^
    --distpath "%DIST_DIR%" ^
    --clean ^
    --noconfirm ^
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
    --hidden-import datetime ^
    --hidden-import dataclasses ^
    --hidden-import typing ^
    --hidden-import os ^
    --hidden-import sys ^
    --collect-all git ^
    --collect-all requests ^
    --exclude-module matplotlib ^
    --exclude-module numpy ^
    --exclude-module pandas ^
    --exclude-module scipy ^
    --exclude-module PIL ^
    --exclude-module pygame ^
    "%SCRIPT_NAME%"

if errorlevel 1 (
    echo.
    echo ❌ 建置失敗
    echo 💡 常見解決方法:
    echo    1. 確認 Python 版本 3.7+
    echo    2. 重新安裝 PyInstaller: pip uninstall pyinstaller ^&^& pip install pyinstaller
    echo    3. 檢查防毒軟體是否阻擋
    echo    4. 以管理員權限執行
    pause
    exit /b 1
)

:: 檢查建置結果
echo.
echo [6/6] 驗證建置結果...
set "EXE_PATH=%DIST_DIR%\%APP_NAME%.exe"

if exist "%EXE_PATH%" (
    echo ✅ 建置成功！
    echo.
    echo 📊 建置資訊:
    echo    📁 執行檔位置: %EXE_PATH%
    echo    🏗️  建置時間: %date% %time%
    echo    🐍 Python 版本: 
    %PYTHON_CMD% --version
    
    :: 顯示檔案大小
    for %%f in ("%EXE_PATH%") do (
        set /a "size_mb=%%~zf / 1024 / 1024"
        echo    📏 檔案大小: !size_mb! MB
    )
    
    :: 創建使用說明
    echo.
    echo 📝 創建使用說明...
    (
        echo GitGuard Sync v%VERSION% 使用說明 (修復版^)
        echo ================================================
        echo.
        echo 🚀 執行方式:
        echo    1. 雙擊執行 %APP_NAME%.exe
        echo    2. 或在命令提示字元中執行: %APP_NAME%.exe
        echo.
        echo 📦 建置資訊:
        echo    - 建置時間: %date% %time%
        echo    - 建置平台: Windows %PROCESSOR_ARCHITECTURE%
        echo    - 程式版本: %VERSION% (修復版^)
        echo.
        echo 🔧 修復內容:
        echo    ✅ 修復程式無法正常關閉問題
        echo    ✅ 修復 ASCII 藝術標題置中顯示
        echo    ✅ 改進建置腳本穩定性
        echo    ✅ 優化錯誤處理機制
        echo.
        echo 📋 系統需求:
        echo    - 作業系統: Windows 7/8/10/11
        echo    - 記憶體: 至少 100MB 可用
        echo    - 硬碟空間: 50MB
        echo.
        echo 🔧 功能特色:
        echo    - Git 倉庫安全掃描
        echo    - 雙平台同步 (GitHub + GitLab^)
        echo    - GitGuardian API 整合
        echo    - 現代化 GUI 介面
        echo.
        echo 📞 技術支援:
        echo    - GitHub: https://github.com/seikaikyo/gitguard-sync
        echo.
        echo ⚠️  注意事項:
        echo    - 首次執行可能需要較長時間載入
        echo    - 防毒軟體可能會誤報，請加入白名單
        echo    - 使用 GitGuardian 功能需要 API 金鑰
        echo.
        echo 🎉 感謝使用 GitGuard Sync！
    ) > "%DIST_DIR%\README.txt"
    
    echo ✅ 使用說明已創建: %DIST_DIR%\README.txt
    echo.
    
    :: 詢問是否測試執行檔
    choice /C YN /M "是否要測試執行檔 (Y/N)"
    if !errorlevel! == 1 (
        echo.
        echo 🚀 啟動測試...
        echo ⚠️  注意：這將啟動完整的 GUI 程式
        timeout /t 3 /nobreak >nul
        start "" "%EXE_PATH%"
    )
    
    :: 詢問是否開啟資料夾
    choice /C YN /M "是否要開啟輸出資料夾 (Y/N)"
    if !errorlevel! == 1 (
        explorer "%DIST_DIR%"
    )
    
    :: 清理建置快取
    choice /C YN /M "是否要清理建置快取以節省空間 (Y/N)"
    if !errorlevel! == 1 (
        echo 🗑️  清理建置快取...
        if exist "build" rmdir /s /q "build" >nul 2>&1
        for %%f in (*.spec) do if exist "%%f" del /q "%%f" >nul 2>&1
        echo ✅ 快取清理完成
    )
    
) else (
    echo ❌ 建置失敗: 找不到執行檔
    echo.
    echo 🔍 偵錯資訊:
    if exist "%DIST_DIR%" (
        echo    📁 %DIST_DIR% 目錄內容:
        dir /b "%DIST_DIR%"
    ) else (
        echo    📁 %DIST_DIR% 目錄不存在
    )
    
    echo.
    echo 💡 可能的解決方法:
    echo    1. 檢查防毒軟體是否阻擋
    echo    2. 確認有足夠的磁碟空間
    echo    3. 以管理員權限重新執行
    echo    4. 手動檢查 PyInstaller 輸出訊息
    pause
    exit /b 1
)

echo.
echo 🎉 GitGuard Sync v%VERSION% 建置完成！
echo 💡 執行檔位置: %cd%\%DIST_DIR%\%APP_NAME%.exe
echo 📖 使用說明: %cd%\%DIST_DIR%\README.txt
echo.
echo 🔗 相關連結:
echo    - 專案網頁: https://github.com/seikaikyo/gitguard-sync
echo    - 技術支援: https://github.com/seikaikyo/gitguard-sync
echo.
pause