#!/bin/bash
# GitGuard Sync 快速開始腳本 (修復版 v3.0.1)
# 解決所有已知的兼容性問題

set -e # 遇到錯誤時停止執行

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 顯示 ASCII 標題 - 修復版，完美置中
show_banner() {
    echo -e "${CYAN}"
    cat <<'EOF'
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
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}🔐 Git 倉庫安全同步守護者 - 快速開始腳本 v3.0.1 (修復版)${NC}"
    echo -e "${BLUE}作者:  | 修復所有已知問題${NC}"
    echo ""
}

# 檢測作業系統
detect_os() {
    echo -e "${BLUE}🔍 檢測作業系統環境...${NC}"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        OS="Windows (Cygwin)"
    elif [[ "$OSTYPE" == "msys" ]]; then
        OS="Windows (MSYS2/Git Bash)"
    elif [[ "$OSTYPE" == "win32" ]]; then
        OS="Windows"
    else
        OS="Unknown"
    fi

    echo -e "${GREEN}✅ 作業系統: $OS${NC}"
}

# 智能 Python 檢查 (強化版)
check_python_smart() {
    echo -e "${BLUE}🔍 檢查 Python 環境 (智能檢測)...${NC}"

    # 嘗試各種 Python 命令
    local python_commands=("python3" "python" "py" "python3.11" "python3.10" "python3.9" "python3.8" "python3.7")
    local pip_commands=("pip3" "pip" "pip3.11" "pip3.10" "pip3.9" "pip3.8" "pip3.7")

    PYTHON_CMD=""
    PIP_CMD=""

    # 找到可用的 Python
    for cmd in "${python_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            # 檢查版本是否符合要求
            if $cmd -c "import sys; exit(0 if sys.version_info >= (3, 7) else 1)" 2>/dev/null; then
                PYTHON_CMD="$cmd"
                PYTHON_VERSION=$($cmd --version 2>&1 | cut -d' ' -f2)
                echo -e "${GREEN}✅ 找到合適的 Python: $cmd ($PYTHON_VERSION)${NC}"
                break
            fi
        fi
    done

    if [ -z "$PYTHON_CMD" ]; then
        echo -e "${RED}❌ 找不到 Python 3.7+，請先安裝 Python${NC}"
        echo -e "${YELLOW}💡 建議安裝方式:${NC}"
        case "$OS" in
        "Linux")
            echo "   sudo apt update && sudo apt install python3 python3-pip"
            ;;
        "macOS")
            echo "   brew install python3"
            ;;
        "Windows"*)
            echo "   從 https://python.org 下載安裝"
            ;;
        esac
        return 1
    fi

    # 找到對應的 pip
    for cmd in "${pip_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            PIP_CMD="$cmd"
            echo -e "${GREEN}✅ 找到套件管理工具: $cmd${NC}"
            break
        fi
    done

    if [ -z "$PIP_CMD" ]; then
        echo -e "${YELLOW}⚠️  找不到 pip，嘗試使用 python -m pip${NC}"
        PIP_CMD="$PYTHON_CMD -m pip"
    fi

    return 0
}

# 檢查必要檔案
check_files() {
    echo -e "${BLUE}📁 檢查專案檔案...${NC}"

    local required_files=("gitguard_sync.py")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}❌ 找不到必要檔案:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${RED}   - $file${NC}"
        done
        echo -e "${YELLOW}💡 請確認您在正確的專案目錄中${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ 專案檔案檢查通過${NC}"
    return 0
}

# 智能依賴安裝 (強化版)
install_dependencies_smart() {
    echo -e "${BLUE}📦 檢查和安裝依賴套件...${NC}"

    # 檢查現有安裝
    local missing_deps=()

    if ! $PYTHON_CMD -c "import git" >/dev/null 2>&1; then
        missing_deps+=("gitpython")
    fi

    if ! $PYTHON_CMD -c "import requests" >/dev/null 2>&1; then
        missing_deps+=("requests")
    fi

    if ! $PYTHON_CMD -c "import tkinter" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  tkinter 不可用，可能需要安裝 python3-tk${NC}"
        case "$OS" in
        "Linux")
            echo -e "${BLUE}🔧 嘗試安裝 tkinter...${NC}"
            if command -v apt >/dev/null 2>&1; then
                sudo apt update && sudo apt install python3-tk -y || true
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install tkinter -y || true
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S tk -y || true
            fi
            ;;
        esac
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ 所有依賴套件已安裝${NC}"
        return 0
    fi

    echo -e "${BLUE}📥 安裝缺少的套件: ${missing_deps[*]}${NC}"

    # 嘗試升級 pip
    echo -e "${BLUE}🔧 升級 pip...${NC}"
    $PIP_CMD install --upgrade pip >/dev/null 2>&1 || true

    # 安裝依賴
    for dep in "${missing_deps[@]}"; do
        echo -e "${BLUE}📦 安裝 $dep...${NC}"
        if $PIP_CMD install "$dep" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $dep 安裝成功${NC}"
        else
            echo -e "${YELLOW}⚠️  $dep 安裝可能有問題，但繼續嘗試${NC}"
        fi
    done

    return 0
}

# 全面模組測試
test_modules_comprehensive() {
    echo -e "${BLUE}🧪 全面測試核心模組...${NC}"

    local test_script="
import sys
print('Python 版本:', sys.version)

modules_status = {}

# 測試 tkinter
try:
    import tkinter as tk
    import tkinter.ttk as ttk
    import tkinter.messagebox as messagebox
    root = tk.Tk()
    root.withdraw()  # 隱藏視窗
    root.destroy()
    modules_status['tkinter'] = '✅ 正常'
except Exception as e:
    modules_status['tkinter'] = f'❌ 錯誤: {e}'

# 測試 git
try:
    import git
    modules_status['gitpython'] = '✅ 正常'
except Exception as e:
    modules_status['gitpython'] = f'❌ 錯誤: {e}'

# 測試 requests
try:
    import requests
    modules_status['requests'] = '✅ 正常'
except Exception as e:
    modules_status['requests'] = f'❌ 錯誤: {e}'

# 測試其他必要模組
essential_modules = ['threading', 'subprocess', 'pathlib', 'json', 're', 'webbrowser', 'datetime', 'dataclasses', 'typing']
for module in essential_modules:
    try:
        __import__(module)
        modules_status[module] = '✅ 正常'
    except Exception as e:
        modules_status[module] = f'❌ 錯誤: {e}'

# 輸出結果
print('\\n模組測試結果:')
print('=' * 40)
for module, status in modules_status.items():
    print(f'{module:15} : {status}')

# 檢查是否有關鍵錯誤
critical_modules = ['tkinter', 'gitpython', 'requests']
errors = [m for m in critical_modules if '❌' in modules_status.get(m, '')]
if errors:
    print(f'\\n⚠️  關鍵模組有問題: {errors}')
    sys.exit(1)
else:
    print('\\n✅ 所有關鍵模組正常')
"

    if $PYTHON_CMD -c "$test_script"; then
        echo -e "${GREEN}✅ 模組測試全部通過${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  部分模組測試未通過，但可嘗試啟動程式${NC}"
        return 0
    fi
}

# 創建多平台啟動腳本
create_launchers() {
    echo -e "${BLUE}🚀 建立啟動腳本...${NC}"

    # 創建 Unix Shell 腳本
    cat >GitGuard-Sync.sh <<'EOF'
#!/bin/bash
# GitGuard Sync 啟動腳本

# 取得腳本所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 啟動 GitGuard Sync..."
echo "📁 工作目錄: $SCRIPT_DIR"

# 嘗試不同的 Python 命令
python_commands=("python3" "python" "py")
launched=false

for cmd in "${python_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "🐍 使用 Python: $cmd"
        "$cmd" gitguard_sync.py
        launched=true
        break
    fi
done

if [ "$launched" = false ]; then
    echo "❌ 找不到 Python，請確認已安裝 Python 3.7+"
    read -p "按 Enter 鍵繼續..."
fi
EOF

    chmod +x GitGuard-Sync.sh 2>/dev/null || true
    echo -e "${GREEN}✅ 已建立 GitGuard-Sync.sh${NC}"

    # Windows 批次檔
    cat >GitGuard-Sync.bat <<'EOF'
@echo off
chcp 65001 >nul
title GitGuard Sync

echo.
echo 🚀 啟動 GitGuard Sync...
echo 📁 工作目錄: %cd%

REM 嘗試不同的 Python 命令
set launched=false

where python3 >nul 2>&1
if %errorlevel% == 0 (
    echo 🐍 使用 Python: python3
    python3 gitguard_sync.py
    set launched=true
    goto end
)

where python >nul 2>&1
if %errorlevel% == 0 (
    echo 🐍 使用 Python: python
    python gitguard_sync.py
    set launched=true
    goto end
)

where py >nul 2>&1
if %errorlevel% == 0 (
    echo 🐍 使用 Python: py
    py gitguard_sync.py
    set launched=true
    goto end
)

:end
if "%launched%" == "false" (
    echo ❌ 找不到 Python，請確認已安裝 Python 3.7+
    pause
)
EOF

    echo -e "${GREEN}✅ 已建立 GitGuard-Sync.bat${NC}"

    # Python 啟動器 (跨平台)
    cat >launcher.py <<'EOF'
#!/usr/bin/env python3
"""
GitGuard Sync 跨平台啟動器
自動檢測環境並啟動主程式
"""

import os
import sys
import subprocess
from pathlib import Path

def main():
    print("🚀 GitGuard Sync 跨平台啟動器")
    print("=" * 40)
    
    # 確定主程式路徑
    script_dir = Path(__file__).parent
    main_script = script_dir / "gitguard_sync.py"
    
    if not main_script.exists():
        print(f"❌ 找不到主程式: {main_script}")
        input("按 Enter 鍵退出...")
        return 1
    
    print(f"📁 工作目錄: {script_dir}")
    print(f"🐍 Python 版本: {sys.version.split()[0]}")
    print(f"🎯 啟動程式: {main_script}")
    print()
    
    try:
        # 切換到腳本目錄
        os.chdir(script_dir)
        
        # 啟動主程式
        subprocess.run([sys.executable, str(main_script)], check=True)
        
    except KeyboardInterrupt:
        print("\n⚠️  程式被使用者中斷")
    except subprocess.CalledProcessError as e:
        print(f"❌ 程式執行失敗: {e}")
        input("按 Enter 鍵退出...")
        return 1
    except Exception as e:
        print(f"❌ 啟動器錯誤: {e}")
        input("按 Enter 鍵退出...")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOF

    echo -e "${GREEN}✅ 已建立 launcher.py (跨平台啟動器)${NC}"
}

# 顯示詳細使用說明
show_usage_detailed() {
    echo -e "${BLUE}📚 詳細使用說明${NC}"
    echo "=================================="
    echo ""
    echo -e "${GREEN}🚀 啟動 GitGuard Sync 的多種方法:${NC}"
    echo ""
    echo -e "${CYAN}方法 1: 直接執行 Python 腳本${NC}"
    echo "   $PYTHON_CMD gitguard_sync.py"
    echo ""
    echo -e "${CYAN}方法 2: 使用啟動腳本${NC}"
    case "$OS" in
    "Windows"*)
        echo "   - 雙擊 GitGuard-Sync.bat"
        echo "   - 或在命令提示字元執行: GitGuard-Sync.bat"
        ;;
    *)
        echo "   - ./GitGuard-Sync.sh"
        echo "   - 或 bash GitGuard-Sync.sh"
        ;;
    esac
    echo ""
    echo -e "${CYAN}方法 3: 使用跨平台啟動器${NC}"
    echo "   $PYTHON_CMD launcher.py"
    echo ""
    echo -e "${GREEN}🔒 GitGuardian API 設定 (可選):${NC}"
    echo "   1. 註冊 GitGuardian 帳號: https://www.gitguardian.com/"
    echo "   2. 取得 API 金鑰"
    echo "   3. 在程式中設定 API 金鑰以啟用專業掃描"
    echo ""
    echo -e "${GREEN}🛠️ 常見問題解決:${NC}"
    echo "   - 無法啟動: 檢查 Python 版本是否 3.7+"
    echo "   - 模組錯誤: 重新執行此腳本安裝依賴"
    echo "   - GUI 問題: 確認已安裝 tkinter (Linux 需額外安裝)"
    echo ""
    echo -e "${GREEN}📞 技術支援:${NC}"
    echo "   - GitHub: https://github.com/seikaikyo/gitguard-sync"
    echo "   - 作者: "
    echo ""
    echo -e "${PURPLE}🎉 修復內容 (v3.0.1):${NC}"
    echo "   ✅ 修復程式無法正常關閉問題"
    echo "   ✅ 修復 ASCII 藝術標題置中顯示"
    echo "   ✅ 改進跨平台兼容性"
    echo "   ✅ 優化錯誤處理和用戶體驗"
    echo ""
}

# 詢問啟動程式
ask_launch() {
    echo -e "${YELLOW}🤔 是否立即啟動 GitGuard Sync? (Y/n)${NC}"
    read -r response

    case "$response" in
    [Nn] | [Nn][Oo])
        echo -e "${BLUE}👋 程式已準備就緒，稍後可手動啟動${NC}"
        echo -e "${CYAN}💡 啟動命令: $PYTHON_CMD gitguard_sync.py${NC}"
        ;;
    *)
        echo -e "${GREEN}🚀 啟動 GitGuard Sync...${NC}"
        echo -e "${CYAN}使用 Python: $PYTHON_CMD${NC}"
        echo ""

        # 切換到腳本目錄
        cd "$(dirname "$0")" 2>/dev/null || true

        # 啟動程式
        $PYTHON_CMD gitguard_sync.py
        ;;
    esac
}

# 主程式流程 (全面修復版)
main() {
    # 清除螢幕 (兼容多平台)
    if command -v clear >/dev/null 2>&1; then
        clear
    elif command -v cls >/dev/null 2>&1; then
        cls
    fi

    # 顯示標題
    show_banner

    echo -e "${PURPLE}🔧 開始全面檢查和設定 (修復版)...${NC}"
    echo ""

    # 執行檢查步驟
    detect_os

    if ! check_python_smart; then
        echo -e "${RED}❌ Python 環境檢查失敗${NC}"
        echo -e "${YELLOW}💡 請安裝 Python 3.7+ 後重新執行此腳本${NC}"
        read -p "按 Enter 鍵退出..."
        exit 1
    fi

    if ! check_files; then
        echo -e "${RED}❌ 檔案檢查失敗${NC}"
        read -p "按 Enter 鍵退出..."
        exit 1
    fi

    install_dependencies_smart
    test_modules_comprehensive
    create_launchers

    echo ""
    echo -e "${GREEN}🎉 GitGuard Sync 設定完成！${NC}"
    echo -e "${CYAN}✨ 所有修復和改進已套用${NC}"
    echo ""

    show_usage_detailed
    ask_launch
}

# 錯誤處理 (改進版)
handle_error() {
    echo ""
    echo -e "${RED}❌ 腳本執行過程中遇到問題${NC}"
    echo -e "${YELLOW}💡 可嘗試的解決方法:${NC}"
    echo "   1. 確認網路連線正常"
    echo "   2. 以管理員權限執行腳本"
    echo "   3. 手動安裝 Python 依賴: pip install gitpython requests"
    echo ""
    echo -e "${CYAN}🚀 即使有警告，您仍可嘗試手動啟動:${NC}"
    if [ -n "$PYTHON_CMD" ]; then
        echo "   $PYTHON_CMD gitguard_sync.py"
    else
        echo "   python3 gitguard_sync.py"
    fi
    echo ""
    read -p "按 Enter 鍵退出..."
    exit 1
}

# 設定錯誤陷阱
trap 'handle_error' ERR

# 執行主程式
main "$@"
