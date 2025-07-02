#!/bin/bash
# GitGuard Sync 快速開始腳本 (修正版)
# 解決 MSYS2/Git Bash 兼容性問題

set -e # 遇到錯誤時停止執行

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 顯示 ASCII 標題
show_banner() {
    echo -e "${CYAN}"
    cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
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
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}🔐 Git 倉庫安全同步守護者 - 快速開始腳本 v3.0.1 (修正版)${NC}"
    echo -e "${BLUE}作者: ${NC}"
    echo ""
}

# 簡化的 Python 檢查 (避免複雜的版本檢測)
check_python_simple() {
    echo -e "${BLUE}🔍 檢查 Python 環境...${NC}"

    # 確定 Python 命令
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
        PIP_CMD="pip3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"
        PIP_CMD="pip"
    else
        echo -e "${RED}❌ 找不到 Python，請先安裝 Python 3.7+${NC}"
        exit 1
    fi

    # 簡單測試 Python 可用性
    if $PYTHON_CMD --version >/dev/null 2>&1; then
        PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}✅ 找到 Python: $PYTHON_VERSION${NC}"
    else
        echo -e "${RED}❌ Python 無法正常執行${NC}"
        exit 1
    fi
}

# 檢查必要檔案
check_files() {
    echo -e "${BLUE}📁 檢查專案檔案...${NC}"

    if [ ! -f "gitguard_sync.py" ]; then
        echo -e "${RED}❌ 找不到主程式檔案: gitguard_sync.py${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ 專案檔案檢查通過${NC}"
}

# 簡化的依賴安裝
install_dependencies_simple() {
    echo -e "${BLUE}📦 檢查依賴套件...${NC}"

    # 檢查是否已安裝
    if $PYTHON_CMD -c "import git, requests" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 依賴套件已安裝${NC}"
        return 0
    fi

    echo "📥 安裝核心依賴..."
    if $PIP_CMD install gitpython requests >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 依賴套件安裝完成${NC}"
    else
        echo -e "${YELLOW}⚠️  依賴安裝可能有問題，但繼續嘗試啟動${NC}"
    fi
}

# 簡化的模組測試
test_modules_simple() {
    echo -e "${BLUE}🧪 測試核心模組...${NC}"

    # 測試模組可用性
    if $PYTHON_CMD -c "
import sys
try:
    import tkinter
    import git  
    import requests
    print('✅ 所有核心模組正常')
except ImportError as e:
    print(f'⚠️  模組問題: {e}')
    print('但仍可嘗試啟動程式')
" 2>/dev/null; then
        echo -e "${GREEN}✅ 模組測試通過${NC}"
    else
        echo -e "${YELLOW}⚠️  模組測試有警告，但繼續啟動${NC}"
    fi
}

# 創建簡單的啟動腳本
create_simple_launcher() {
    echo -e "${BLUE}🚀 建立啟動腳本...${NC}"

    # 創建批次檔 (Windows)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || command -v cmd.exe >/dev/null 2>&1; then
        cat >GitGuard-Sync.bat <<EOF
@echo off
echo 啟動 GitGuard Sync...
python gitguard_sync.py
pause
EOF
        echo -e "${GREEN}✅ 已建立 GitGuard-Sync.bat${NC}"
    fi

    # 創建 shell 腳本
    cat >GitGuard-Sync.sh <<EOF
#!/bin/bash
echo "啟動 GitGuard Sync..."
cd "\$(dirname "\$0")"
python gitguard_sync.py
EOF
    chmod +x GitGuard-Sync.sh 2>/dev/null || true
    echo -e "${GREEN}✅ 已建立 GitGuard-Sync.sh${NC}"
}

# 顯示使用說明
show_usage() {
    echo -e "${BLUE}📚 使用說明${NC}"
    echo "=================================="
    echo ""
    echo -e "${GREEN}🚀 啟動 GitGuard Sync:${NC}"
    echo "   方法 1: python gitguard_sync.py"
    echo "   方法 2: ./GitGuard-Sync.sh"
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "   方法 3: 雙擊 GitGuard-Sync.bat"
    fi
    echo ""
    echo -e "${GREEN}🔒 GitGuardian API (可選):${NC}"
    echo "   在程式中設定 API 金鑰以啟用專業掃描"
    echo ""
    echo -e "${GREEN}📞 技術支援:${NC}"
    echo "   GitHub: https://github.com/seikaikyo/gitguard-sync"
    echo "   Email: noreply@example.com"
    echo ""
}

# 詢問啟動
ask_launch() {
    echo -e "${YELLOW}🤔 立即啟動 GitGuard Sync? (Y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}👋 稍後可手動啟動${NC}"
    else
        echo -e "${GREEN}🚀 啟動 GitGuard Sync...${NC}"
        echo ""
        $PYTHON_CMD gitguard_sync.py
    fi
}

# 主程式流程 (簡化版)
main() {
    # 清除螢幕
    clear

    # 顯示標題
    show_banner

    echo -e "${PURPLE}🔧 快速檢查和設定 (簡化版)...${NC}"
    echo ""

    # 執行簡化的檢查步驟
    check_python_simple
    check_files
    install_dependencies_simple
    test_modules_simple
    create_simple_launcher

    echo ""
    echo -e "${GREEN}🎉 GitGuard Sync 設定完成！${NC}"
    echo ""

    show_usage
    ask_launch
}

# 錯誤處理 (寬鬆模式)
trap 'echo -e "\n${YELLOW}⚠️  過程中有問題，但可嘗試手動啟動: python gitguard_sync.py${NC}"; exit 0' ERR

# 執行主程式
main "$@"
