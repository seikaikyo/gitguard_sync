#!/usr/bin/env python3
"""
GitGuard Sync - Git 倉庫安全同步守護者
功能強大的 Git 倉庫同步工具，具備現代化的 GUI 介面
支援 GitLab 和 GitHub 雙平台同步，並整合 GitGuardian 專業機敏資料掃描

作者: 
版本: 3.0.1 (修復版)
"""

import os
import sys
import json
import subprocess
import threading
import webbrowser
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime
import re

# GUI 相關
import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
from tkinter.font import Font

# 第三方庫
try:
    import requests
    import git
except ImportError as e:
    print(f"缺少必要套件: {e}")
    print("請執行: pip install gitpython requests")
    sys.exit(1)


@dataclass
class ScanResult:
    """掃描結果資料結構"""
    file_path: str
    line_number: int
    secret_type: str
    content: str
    severity: str


@dataclass
class RemoteConfig:
    """遠端倉庫配置"""
    name: str
    url: str
    type: str  # 'github' or 'gitlab'
    status: str  # 'connected', 'error', 'not_configured'


class GitGuardSyncGUI:
    """GitGuard Sync GUI 主應用程式"""

    def __init__(self):
        # 先初始化基本屬性
        self.current_path = Path.cwd()
        self.repo = None
        self.gitguardian_api_key = os.getenv('GITGUARDIAN_API_KEY', '')
        self.security_patterns = self._init_security_patterns()

        # 初始化線程控制
        self.stop_threads = threading.Event()

        # 再設定 GUI
        self.root = tk.Tk()
        self.setup_window()
        self.setup_fonts()
        self.setup_colors()
        self.setup_variables()
        self.setup_ui()
        self.center_window()

    def setup_window(self):
        """設定主視窗"""
        self.root.title("GitGuard Sync v3.0.1 - Git 倉庫安全同步守護者")
        self.root.geometry("900x700")
        self.root.minsize(800, 600)

        # 設定圖示（如果有的話）
        try:
            if hasattr(sys, '_MEIPASS'):
                icon_path = os.path.join(sys._MEIPASS, 'icon.ico')
            else:
                icon_path = 'icon.ico'
            if os.path.exists(icon_path):
                self.root.iconbitmap(icon_path)
        except:
            pass

    def setup_fonts(self):
        """設定字型"""
        self.font_title = Font(family="Consolas", size=12, weight="bold")
        self.font_ascii = Font(family="Courier New", size=8)
        self.font_button = Font(family="微軟正黑體", size=10)
        self.font_text = Font(family="微軟正黑體", size=9)

    def setup_colors(self):
        """設定色彩主題"""
        self.colors = {
            'bg_primary': '#2c3e50',  # 深藍灰
            'bg_secondary': '#34495e',  # 次要背景
            'bg_card': '#ecf0f1',  # 卡片背景
            'text_primary': '#2c3e50',  # 主要文字
            'text_secondary': '#7f8c8d',  # 次要文字
            'accent_blue': '#3498db',  # 藍色強調
            'accent_green': '#2ecc71',  # 綠色強調
            'accent_red': '#e74c3c',  # 紅色強調
            'accent_orange': '#f39c12',  # 橙色強調
            'button_hover': '#bdc3c7'  # 按鈕懸停
        }

        # 設定主視窗背景
        self.root.configure(bg=self.colors['bg_card'])

    def setup_variables(self):
        """設定變數"""
        self.current_dir_var = tk.StringVar(value=str(self.current_path))
        self.api_key_var = tk.StringVar(value=self.gitguardian_api_key)
        self.scan_progress_var = tk.DoubleVar()
        self.scan_status_var = tk.StringVar(value="就緒")

    def setup_ui(self):
        """設定使用者介面"""
        # 主容器
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # ASCII 標題
        self.create_title_section(main_frame)

        # 主要功能區域
        content_frame = ttk.Frame(main_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, pady=(10, 0))

        # 左側功能面板
        left_frame = ttk.LabelFrame(content_frame, text="🎛️ 控制面板", padding=10)
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 5))

        # 右側日誌面板
        right_frame = ttk.LabelFrame(content_frame, text="📋 操作日誌", padding=10)
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True, padx=(5, 0))

        self.create_control_panel(left_frame)
        self.create_log_panel(right_frame)

        # 底部狀態列
        self.create_status_bar(main_frame)

    def create_title_section(self, parent):
        """創建標題區域"""
        title_frame = ttk.Frame(parent)
        title_frame.pack(fill=tk.X, pady=(0, 10))

        # ASCII 藝術標題 - 中文版，置中顯示
        ascii_title = """
╔══════════════════════════════════════════════════════════════════════════════╗
║   ██████╗ ██╗████████╗  ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗            ║
║  ██╔════╝ ██║╚══██╔══╝ ██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗           ║
║  ██║  ███╗██║   ██║    ██║  ███╗██║   ██║███████║██████╔╝██║  ██║           ║
║  ██║   ██║██║   ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║           ║
║  ╚██████╔╝██║   ██║    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝           ║
║   ╚═════╝ ╚═╝   ╚═╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝            ║
║                                                                              ║
║     ███████╗██╗   ██╗███╗   ██╗ ██████╗    ██╗   ██╗██████╗ ██╗██████╗      ║
║     ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝    ██║   ██║╚════██╗██║██╔══██╗     ║
║     ███████╗ ╚████╔╝ ██╔██╗ ██║██║         ██║   ██║ █████╔╝██║██████╔╝     ║
║     ╚════██║  ╚██╔╝  ██║╚██╗██║██║         ╚██╗ ██╔╝ ╚═══██╗██║██╔══██╗     ║
║     ███████║   ██║   ██║ ╚████║╚██████╗     ╚████╔╝ ██████╔╝██║██████╔╝     ║
║     ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝      ╚═══╝  ╚═════╝ ╚═╝╚═════╝      ║
║                                                                              ║
║                         🔐 Git 倉庫安全同步守護者 🔐                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
        """

        title_text = tk.Text(title_frame,
                             height=16,
                             wrap=tk.NONE,
                             font=self.font_ascii,
                             bg=self.colors['bg_primary'],
                             fg='white',
                             relief=tk.FLAT,
                             state=tk.DISABLED)
        title_text.pack(fill=tk.X)

        title_text.config(state=tk.NORMAL)
        title_text.insert(tk.END, ascii_title)

        # 將文字置中
        title_text.tag_add("center", "1.0", "end")
        title_text.tag_config("center", justify='center')

        title_text.config(state=tk.DISABLED)

        # 副標題 - 置中
        subtitle_frame = ttk.Frame(title_frame)
        subtitle_frame.pack(fill=tk.X, pady=(5, 0))

        subtitle = ttk.Label(
            subtitle_frame,
            text="🔐 Git 倉庫安全同步守護者 | 支援雙平台同步 + GitGuardian 安全掃描 🔐",
            font=self.font_title,
            foreground=self.colors['text_secondary'],
            anchor="center")
        subtitle.pack(expand=True)

    def create_control_panel(self, parent):
        """創建控制面板"""
        # 目錄選擇區域
        dir_frame = ttk.LabelFrame(parent, text="📁 工作目錄", padding=5)
        dir_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Entry(dir_frame,
                  textvariable=self.current_dir_var,
                  font=self.font_text,
                  state="readonly").pack(fill=tk.X, pady=(0, 5))

        dir_buttons_frame = ttk.Frame(dir_frame)
        dir_buttons_frame.pack(fill=tk.X)

        ttk.Button(dir_buttons_frame,
                   text="📂 瀏覽目錄",
                   command=self.select_directory).pack(side=tk.LEFT,
                                                       padx=(0, 5))
        ttk.Button(dir_buttons_frame, text="🔄 重新載入",
                   command=self.refresh_repo).pack(side=tk.LEFT)

        # 遠端倉庫管理
        remote_frame = ttk.LabelFrame(parent, text="🌐 遠端倉庫", padding=5)
        remote_frame.pack(fill=tk.X, pady=(0, 10))

        remote_buttons_frame = ttk.Frame(remote_frame)
        remote_buttons_frame.pack(fill=tk.X)

        ttk.Button(remote_buttons_frame,
                   text="⚙️ 配置遠端",
                   command=self.configure_remotes).pack(side=tk.LEFT,
                                                        padx=(0, 5))
        ttk.Button(remote_buttons_frame,
                   text="🔍 測試連線",
                   command=self.test_remotes).pack(side=tk.LEFT)

        # 安全掃描區域
        scan_frame = ttk.LabelFrame(parent, text="🔒 安全掃描", padding=5)
        scan_frame.pack(fill=tk.X, pady=(0, 10))

        # GitGuardian API 設定
        api_frame = ttk.Frame(scan_frame)
        api_frame.pack(fill=tk.X, pady=(0, 5))

        ttk.Label(api_frame, text="API 金鑰:").pack(anchor=tk.W)
        api_entry_frame = ttk.Frame(api_frame)
        api_entry_frame.pack(fill=tk.X)

        self.api_entry = ttk.Entry(api_entry_frame,
                                   textvariable=self.api_key_var,
                                   show="*",
                                   font=self.font_text)
        self.api_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)

        ttk.Button(api_entry_frame,
                   text="💾",
                   command=self.save_api_key,
                   width=3).pack(side=tk.RIGHT, padx=(5, 0))

        # 掃描按鈕
        scan_buttons_frame = ttk.Frame(scan_frame)
        scan_buttons_frame.pack(fill=tk.X, pady=(5, 0))

        ttk.Button(scan_buttons_frame,
                   text="🔍 本地掃描",
                   command=lambda: self.start_scan("local")).pack(side=tk.LEFT,
                                                                  padx=(0, 5))
        ttk.Button(
            scan_buttons_frame,
            text="🛡️ GitGuardian",
            command=lambda: self.start_scan("gitguardian")).pack(side=tk.LEFT)

        # 進度條
        progress_frame = ttk.Frame(scan_frame)
        progress_frame.pack(fill=tk.X, pady=(5, 0))

        self.progress_bar = ttk.Progressbar(progress_frame,
                                            variable=self.scan_progress_var,
                                            maximum=100)
        self.progress_bar.pack(fill=tk.X)

        # 同步推送區域
        sync_frame = ttk.LabelFrame(parent, text="🚀 同步推送", padding=5)
        sync_frame.pack(fill=tk.X, pady=(0, 10))

        sync_buttons_frame = ttk.Frame(sync_frame)
        sync_buttons_frame.pack(fill=tk.X)

        ttk.Button(sync_buttons_frame,
                   text="📤 提交變更",
                   command=self.commit_changes).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(sync_buttons_frame,
                   text="🌐 推送同步",
                   command=self.sync_repositories).pack(side=tk.LEFT)

        # 工具區域
        tools_frame = ttk.LabelFrame(parent, text="🛠️ 工具", padding=5)
        tools_frame.pack(fill=tk.X)

        tools_buttons_frame = ttk.Frame(tools_frame)
        tools_buttons_frame.pack(fill=tk.X)

        ttk.Button(tools_buttons_frame,
                   text="📊 倉庫狀態",
                   command=self.show_repo_status).pack(side=tk.LEFT,
                                                       padx=(0, 5))
        ttk.Button(tools_buttons_frame, text="ℹ️ 關於",
                   command=self.show_about).pack(side=tk.LEFT)

    def create_log_panel(self, parent):
        """創建日誌面板"""
        # 日誌文字區域
        self.log_text = scrolledtext.ScrolledText(parent,
                                                  wrap=tk.WORD,
                                                  font=self.font_text,
                                                  height=20)
        self.log_text.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        # 日誌控制按鈕
        log_buttons_frame = ttk.Frame(parent)
        log_buttons_frame.pack(fill=tk.X)

        ttk.Button(log_buttons_frame, text="🗑️ 清除日誌",
                   command=self.clear_log).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(log_buttons_frame, text="💾 儲存日誌",
                   command=self.save_log).pack(side=tk.LEFT)

        # 初始化日誌
        self.log("GitGuard Sync v3.0.1 啟動成功")
        self.log("=" * 50)

    def create_status_bar(self, parent):
        """創建狀態列"""
        status_frame = ttk.Frame(parent)
        status_frame.pack(fill=tk.X, pady=(10, 0))

        # 狀態標籤
        ttk.Label(status_frame,
                  textvariable=self.scan_status_var,
                  relief=tk.SUNKEN,
                  padding=5).pack(side=tk.LEFT)

        # Git 狀態指示器
        self.git_status_label = ttk.Label(status_frame,
                                          text="❌ 非 Git 倉庫",
                                          relief=tk.SUNKEN,
                                          padding=5)
        self.git_status_label.pack(side=tk.RIGHT)

        # 更新初始狀態
        self.update_git_status()

    def center_window(self):
        """視窗置中"""
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() - self.root.winfo_width()) // 2
        y = (self.root.winfo_screenheight() - self.root.winfo_height()) // 2
        self.root.geometry(f"+{x}+{y}")

    def _init_security_patterns(self) -> Dict[str, str]:
        """初始化安全檢查模式"""
        return {
            'aws_access_key': r'AKIA[0-9A-Z]{16}',
            'github_token': r'gh[pousr]_[A-Za-z0-9]{36}',
            'jwt_token':
            r'eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*',
            'api_key': r'api[_-]?key["\']?\s*[:=]\s*["\']?[A-Za-z0-9]{20,}',
            'password': r'password["\']?\s*[:=]\s*["\'][^"\']{8,}["\']',
            'secret_key':
            r'secret[_-]?key["\']?\s*[:=]\s*["\']?[A-Za-z0-9]{20,}',
            'database_url': r'(mysql|postgresql|mongodb)://[^\s]+',
            'email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            'ssh_private_key': r'-----BEGIN [A-Z ]*PRIVATE KEY-----',
            'slack_token': r'xox[baprs]-[A-Za-z0-9-]{10,48}',
        }

    def log(self, message: str, level: str = "INFO"):
        """記錄日誌"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_message = f"[{timestamp}] {level}: {message}\n"

        self.log_text.insert(tk.END, log_message)
        self.log_text.see(tk.END)

        # 根據等級設定顏色
        if level == "ERROR":
            # 可以添加顏色標記
            pass

    def clear_log(self):
        """清除日誌"""
        self.log_text.delete(1.0, tk.END)
        self.log("日誌已清除")

    def save_log(self):
        """儲存日誌"""
        try:
            filename = filedialog.asksaveasfilename(defaultextension=".txt",
                                                    filetypes=[
                                                        ("文字檔案", "*.txt"),
                                                        ("所有檔案", "*.*")
                                                    ],
                                                    title="儲存日誌檔案")

            if filename:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(self.log_text.get(1.0, tk.END))
                self.log(f"日誌已儲存至: {filename}")

        except Exception as e:
            self.log(f"儲存日誌失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"儲存日誌失敗: {e}")

    def select_directory(self):
        """選擇工作目錄"""
        directory = filedialog.askdirectory(title="選擇 Git 倉庫目錄",
                                            initialdir=str(self.current_path))

        if directory:
            self.current_path = Path(directory)
            self.current_dir_var.set(str(self.current_path))
            self.log(f"已切換到目錄: {self.current_path}")
            self.refresh_repo()

    def refresh_repo(self):
        """重新載入倉庫"""
        try:
            if self._is_git_repo():
                self.repo = git.Repo(self.current_path)
                self.log("Git 倉庫載入成功")
            else:
                self.repo = None
                self.log("當前目錄不是 Git 倉庫", "WARNING")

            self.update_git_status()

        except Exception as e:
            self.log(f"載入倉庫失敗: {e}", "ERROR")
            self.repo = None
            self.update_git_status()

    def _is_git_repo(self, path: Optional[Path] = None) -> bool:
        """檢查是否為 Git 倉庫"""
        check_path = path or self.current_path
        return (check_path / '.git').exists()

    def update_git_status(self):
        """更新 Git 狀態顯示"""
        if self._is_git_repo():
            try:
                if self.repo:
                    branch = self.repo.active_branch.name
                    self.git_status_label.config(text=f"✅ Git 倉庫 ({branch})")
                else:
                    self.git_status_label.config(text="✅ Git 倉庫")
            except:
                self.git_status_label.config(text="✅ Git 倉庫")
        else:
            self.git_status_label.config(text="❌ 非 Git 倉庫")

    def save_api_key(self):
        """儲存 API 金鑰"""
        api_key = self.api_key_var.get().strip()
        if api_key:
            os.environ['GITGUARDIAN_API_KEY'] = api_key
            self.gitguardian_api_key = api_key
            self.log("GitGuardian API 金鑰已設定")
            messagebox.showinfo("成功", "API 金鑰已儲存")
        else:
            self.log("API 金鑰為空", "WARNING")

    def configure_remotes(self):
        """配置遠端倉庫"""
        if not self._is_git_repo():
            messagebox.showerror("錯誤", "當前目錄不是 Git 倉庫")
            return

        RemoteConfigDialog(self.root, self)

    def test_remotes(self):
        """測試遠端連線"""
        if not self.repo:
            messagebox.showerror("錯誤", "請先載入 Git 倉庫")
            return

        self.log("開始測試遠端連線...")

        def test_worker():
            try:
                remotes = list(self.repo.remotes)
                if not remotes:
                    self.log("沒有配置遠端倉庫", "WARNING")
                    return

                for remote in remotes:
                    try:
                        result = subprocess.run(
                            ["git", "ls-remote", "--heads", remote.name],
                            cwd=self.current_path,
                            capture_output=True,
                            timeout=10,
                            encoding='utf-8')

                        if result.returncode == 0:
                            self.log(f"✅ {remote.name}: 連線正常")
                        else:
                            self.log(f"❌ {remote.name}: 連線失敗", "ERROR")

                    except subprocess.TimeoutExpired:
                        self.log(f"⏰ {remote.name}: 連線逾時", "WARNING")
                    except Exception as e:
                        self.log(f"❌ {remote.name}: {e}", "ERROR")

                self.log("遠端連線測試完成")

            except Exception as e:
                self.log(f"測試遠端連線失敗: {e}", "ERROR")

        thread = threading.Thread(target=test_worker, daemon=True)
        thread.start()

    def start_scan(self, scan_type: str):
        """開始安全掃描"""
        if not self._is_git_repo():
            messagebox.showerror("錯誤", "請先選擇 Git 倉庫目錄")
            return

        self.scan_progress_var.set(0)
        self.scan_status_var.set("掃描中...")
        self.log(f"開始 {scan_type} 安全掃描...")

        def scan_worker():
            try:
                results = []

                if scan_type == "local":
                    results = self._local_security_scan()
                elif scan_type == "gitguardian":
                    if not self.gitguardian_api_key:
                        self.log("請先設定 GitGuardian API 金鑰", "ERROR")
                        self.scan_status_var.set("就緒")
                        return
                    results = self._gitguardian_scan()

                self.scan_progress_var.set(100)
                self._display_scan_results(results)
                self.scan_status_var.set("掃描完成")

            except Exception as e:
                self.log(f"掃描失敗: {e}", "ERROR")
                self.scan_status_var.set("掃描失敗")

        thread = threading.Thread(target=scan_worker, daemon=True)
        thread.start()

    def _local_security_scan(self) -> List[ScanResult]:
        """本地安全掃描"""
        results = []
        file_count = 0
        processed = 0

        # 計算總檔案數
        for file_path in self.current_path.rglob("*"):
            if self._should_scan_file(file_path):
                file_count += 1

        self.log(f"準備掃描 {file_count} 個檔案...")

        for file_path in self.current_path.rglob("*"):
            if self._should_scan_file(file_path):
                try:
                    content = file_path.read_text(encoding='utf-8',
                                                  errors='ignore')
                    file_results = self._scan_file_content(
                        str(file_path), content)
                    results.extend(file_results)

                    processed += 1
                    progress = (processed / file_count) * 100
                    self.scan_progress_var.set(progress)

                    if file_results:
                        self.log(
                            f"發現 {len(file_results)} 個問題: {file_path.name}")

                except Exception as e:
                    self.log(f"掃描檔案失敗 {file_path}: {e}", "WARNING")
                    continue

        return results

    def _should_scan_file(self, file_path: Path) -> bool:
        """判斷是否應該掃描檔案"""
        if not file_path.is_file():
            return False

        # 排除隱藏目錄和檔案
        if any(part.startswith('.') for part in file_path.parts):
            return False

        # 只掃描特定副檔名
        scan_extensions = {
            '.py', '.js', '.json', '.yaml', '.yml', '.env', '.sh', '.md',
            '.txt', '.conf', '.cfg'
        }
        return file_path.suffix.lower() in scan_extensions

    def _scan_file_content(self, file_path: str,
                           content: str) -> List[ScanResult]:
        """掃描檔案內容"""
        results = []
        lines = content.split('\n')

        for line_num, line in enumerate(lines, 1):
            for pattern_name, pattern in self.security_patterns.items():
                matches = re.finditer(pattern, line, re.IGNORECASE)
                for match in matches:
                    results.append(
                        ScanResult(file_path=file_path,
                                   line_number=line_num,
                                   secret_type=pattern_name,
                                   content=match.group(),
                                   severity="high" if pattern_name in [
                                       'aws_access_key', 'github_token'
                                   ] else "medium"))

        return results

    def _gitguardian_scan(self) -> List[ScanResult]:
        """GitGuardian API 掃描"""
        results = []
        headers = {
            'Authorization': f'Token {self.gitguardian_api_key}',
            'Content-Type': 'application/json'
        }

        file_count = 0
        processed = 0

        # 計算檔案數
        for file_path in self.current_path.rglob("*"):
            if self._should_scan_file(file_path):
                file_count += 1

        self.log(f"使用 GitGuardian API 掃描 {file_count} 個檔案...")

        for file_path in self.current_path.rglob("*"):
            if self._should_scan_file(file_path):
                try:
                    content = file_path.read_text(encoding='utf-8',
                                                  errors='ignore')

                    # 呼叫 GitGuardian API
                    response = requests.post(
                        'https://api.gitguardian.com/v1/scan',
                        headers=headers,
                        json={
                            'document': content,
                            'filename': file_path.name
                        },
                        timeout=30)

                    if response.status_code == 200:
                        scan_data = response.json()
                        if scan_data.get('policy_breaks'):
                            for break_info in scan_data['policy_breaks']:
                                matches = break_info.get('matches', [{}])
                                if matches:
                                    match = matches[0]
                                    results.append(
                                        ScanResult(file_path=str(file_path),
                                                   line_number=match.get(
                                                       'line_start', 0),
                                                   secret_type=break_info.get(
                                                       'break_type',
                                                       'unknown'),
                                                   content=match.get(
                                                       'match', ''),
                                                   severity=break_info.get(
                                                       'severity', 'medium')))

                            self.log(
                                f"GitGuardian 發現 {len(scan_data['policy_breaks'])} 個問題: {file_path.name}"
                            )

                    elif response.status_code == 401:
                        self.log("GitGuardian API 金鑰無效", "ERROR")
                        break

                    processed += 1
                    progress = (processed / file_count) * 100
                    self.scan_progress_var.set(progress)

                except requests.RequestException as e:
                    self.log(f"GitGuardian API 請求失敗: {e}", "ERROR")
                    continue
                except Exception as e:
                    self.log(f"掃描檔案失敗 {file_path}: {e}", "WARNING")
                    continue

        return results

    def _display_scan_results(self, results: List[ScanResult]):
        """顯示掃描結果"""
        if not results:
            self.log("✅ 未發現安全問題")
            messagebox.showinfo("掃描完成", "未發現安全問題")
            return

        # 按嚴重程度分組
        high_severity = [r for r in results if r.severity == "high"]
        medium_severity = [r for r in results if r.severity == "medium"]

        self.log(f"🔍 掃描完成，發現 {len(results)} 個潛在安全問題")

        if high_severity:
            self.log(f"🚨 高風險問題: {len(high_severity)} 個", "ERROR")

        if medium_severity:
            self.log(f"⚠️ 中風險問題: {len(medium_severity)} 個", "WARNING")

        # 顯示詳細結果視窗
        ScanResultDialog(self.root, results, self)

    def commit_changes(self):
        """提交變更"""
        if not self.repo:
            messagebox.showerror("錯誤", "請先載入 Git 倉庫")
            return

        try:
            # 檢查是否有變更
            if not self.repo.is_dirty():
                self.log("沒有需要提交的變更")
                messagebox.showinfo("資訊", "沒有需要提交的變更")
                return

            # 顯示提交對話框
            CommitDialog(self.root, self)

        except Exception as e:
            self.log(f"檢查變更失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"檢查變更失敗: {e}")

    def sync_repositories(self):
        """同步推送到所有遠端倉庫"""
        if not self.repo:
            messagebox.showerror("錯誤", "請先載入 Git 倉庫")
            return

        try:
            remotes = list(self.repo.remotes)
            if not remotes:
                messagebox.showerror("錯誤", "沒有配置遠端倉庫")
                return

            # 顯示推送對話框
            SyncDialog(self.root, self, remotes)

        except Exception as e:
            self.log(f"準備同步失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"準備同步失敗: {e}")

    def show_repo_status(self):
        """顯示倉庫狀態"""
        if not self.repo:
            messagebox.showerror("錯誤", "請先載入 Git 倉庫")
            return

        RepoStatusDialog(self.root, self)

    def show_about(self):
        """顯示關於對話框"""
        AboutDialog(self.root)

    def run(self):
        """執行主程式"""
        try:
            # 設置窗口關閉處理
            self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
            self.refresh_repo()
            self.root.mainloop()
        except KeyboardInterrupt:
            self.log("程式被使用者中斷")
        except Exception as e:
            self.log(f"程式執行錯誤: {e}", "ERROR")
            messagebox.showerror("錯誤", f"程式執行錯誤: {e}")
        finally:
            # 確保線程安全結束
            if hasattr(self, 'stop_threads'):
                self.stop_threads.set()

    def on_closing(self):
        """窗口關閉時的處理"""
        try:
            self.log("程式正在關閉...")
            # 設置停止標誌
            self.stop_threads.set()
            # 銷毀視窗
            self.root.destroy()
        except Exception as e:
            print(f"關閉程式時發生錯誤: {e}")


# 對話框類別


class RemoteConfigDialog:
    """遠端倉庫配置對話框"""

    def __init__(self, parent, main_app):
        self.main_app = main_app
        self.dialog = tk.Toplevel(parent)
        self.dialog.title("遠端倉庫配置")
        self.dialog.geometry("500x400")
        self.dialog.resizable(False, False)
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()
        self.load_remotes()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 遠端列表
        list_frame = ttk.LabelFrame(main_frame, text="現有遠端倉庫", padding=5)
        list_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        # 創建 Treeview
        self.tree = ttk.Treeview(list_frame,
                                 columns=("url", "type"),
                                 show="tree headings",
                                 height=8)
        self.tree.heading("#0", text="名稱")
        self.tree.heading("url", text="URL")
        self.tree.heading("type", text="類型")

        self.tree.column("#0", width=100)
        self.tree.column("url", width=250)
        self.tree.column("type", width=80)

        scrollbar = ttk.Scrollbar(list_frame,
                                  orient=tk.VERTICAL,
                                  command=self.tree.yview)
        self.tree.configure(yscrollcommand=scrollbar.set)

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # 新增遠端區域
        add_frame = ttk.LabelFrame(main_frame, text="新增遠端倉庫", padding=5)
        add_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(add_frame, text="名稱:").grid(row=0,
                                              column=0,
                                              sticky=tk.W,
                                              pady=2)
        self.name_var = tk.StringVar()
        ttk.Entry(add_frame, textvariable=self.name_var,
                  width=50).grid(row=0, column=1, sticky=tk.EW, pady=2)

        ttk.Label(add_frame, text="URL:").grid(row=1,
                                               column=0,
                                               sticky=tk.W,
                                               pady=2)
        self.url_var = tk.StringVar()
        ttk.Entry(add_frame, textvariable=self.url_var,
                  width=50).grid(row=1, column=1, sticky=tk.EW, pady=2)

        add_frame.columnconfigure(1, weight=1)

        # 按鈕區域
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)

        ttk.Button(button_frame, text="新增",
                   command=self.add_remote).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(button_frame, text="移除",
                   command=self.remove_remote).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(button_frame, text="關閉",
                   command=self.dialog.destroy).pack(side=tk.RIGHT)

    def load_remotes(self):
        """載入遠端倉庫列表"""
        # 清除現有項目
        for item in self.tree.get_children():
            self.tree.delete(item)

        if not self.main_app.repo:
            return

        for remote in self.main_app.repo.remotes:
            remote_type = "GitHub" if "github.com" in remote.url else "GitLab"
            self.tree.insert("",
                             tk.END,
                             text=remote.name,
                             values=(remote.url, remote_type))

    def add_remote(self):
        """新增遠端倉庫"""
        name = self.name_var.get().strip()
        url = self.url_var.get().strip()

        if not name or not url:
            messagebox.showerror("錯誤", "請填寫完整的名稱和 URL")
            return

        try:
            self.main_app.repo.create_remote(name, url)
            self.main_app.log(f"已新增遠端倉庫: {name}")
            self.load_remotes()

            # 清除輸入框
            self.name_var.set("")
            self.url_var.set("")

            messagebox.showinfo("成功", f"已新增遠端倉庫: {name}")

        except Exception as e:
            self.main_app.log(f"新增遠端倉庫失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"新增失敗: {e}")

    def remove_remote(self):
        """移除遠端倉庫"""
        selection = self.tree.selection()
        if not selection:
            messagebox.showwarning("警告", "請選擇要移除的遠端倉庫")
            return

        item = selection[0]
        name = self.tree.item(item, "text")

        if messagebox.askyesno("確認", f"確定要移除遠端倉庫 '{name}' 嗎？"):
            try:
                self.main_app.repo.delete_remote(name)
                self.main_app.log(f"已移除遠端倉庫: {name}")
                self.load_remotes()
                messagebox.showinfo("成功", f"已移除遠端倉庫: {name}")

            except Exception as e:
                self.main_app.log(f"移除遠端倉庫失敗: {e}", "ERROR")
                messagebox.showerror("錯誤", f"移除失敗: {e}")


class ScanResultDialog:
    """掃描結果對話框"""

    def __init__(self, parent, results: List[ScanResult], main_app):
        self.results = results
        self.main_app = main_app

        self.dialog = tk.Toplevel(parent)
        self.dialog.title("安全掃描結果")
        self.dialog.geometry("800x600")
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()
        self.load_results()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 標題
        title_label = ttk.Label(main_frame,
                                text=f"發現 {len(self.results)} 個潛在安全問題",
                                font=("微軟正黑體", 12, "bold"))
        title_label.pack(pady=(0, 10))

        # 結果列表
        list_frame = ttk.Frame(main_frame)
        list_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.tree = ttk.Treeview(list_frame,
                                 columns=("file", "line", "type", "severity"),
                                 show="headings",
                                 height=15)

        self.tree.heading("file", text="檔案")
        self.tree.heading("line", text="行號")
        self.tree.heading("type", text="類型")
        self.tree.heading("severity", text="嚴重程度")

        self.tree.column("file", width=200)
        self.tree.column("line", width=60)
        self.tree.column("type", width=150)
        self.tree.column("severity", width=100)

        scrollbar_v = ttk.Scrollbar(list_frame,
                                    orient=tk.VERTICAL,
                                    command=self.tree.yview)
        scrollbar_h = ttk.Scrollbar(list_frame,
                                    orient=tk.HORIZONTAL,
                                    command=self.tree.xview)
        self.tree.configure(yscrollcommand=scrollbar_v.set,
                            xscrollcommand=scrollbar_h.set)

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar_v.pack(side=tk.RIGHT, fill=tk.Y)
        scrollbar_h.pack(side=tk.BOTTOM, fill=tk.X)

        # 詳細內容
        detail_frame = ttk.LabelFrame(main_frame, text="詳細內容", padding=5)
        detail_frame.pack(fill=tk.X, pady=(0, 10))

        self.detail_text = tk.Text(detail_frame, height=4, wrap=tk.WORD)
        self.detail_text.pack(fill=tk.X)

        # 處理按鈕
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)

        ttk.Button(button_frame,
                   text="加入 .gitignore",
                   command=self.add_to_gitignore).pack(side=tk.LEFT,
                                                       padx=(0, 5))
        ttk.Button(button_frame,
                   text="建立環境變數範本",
                   command=self.create_env_template).pack(side=tk.LEFT,
                                                          padx=(0, 5))
        ttk.Button(button_frame, text="匯出報告",
                   command=self.export_report).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(button_frame, text="關閉",
                   command=self.dialog.destroy).pack(side=tk.RIGHT)

        # 綁定選擇事件
        self.tree.bind("<<TreeviewSelect>>", self.on_select)

    def load_results(self):
        """載入掃描結果"""
        for result in self.results:
            file_name = Path(result.file_path).name
            severity_text = "🚨 高" if result.severity == "high" else "⚠️ 中"

            self.tree.insert("",
                             tk.END,
                             values=(file_name, result.line_number,
                                     result.secret_type, severity_text),
                             tags=(result.severity, ))

        # 設定標籤顏色
        self.tree.tag_configure("high", foreground="red")
        self.tree.tag_configure("medium", foreground="orange")

    def on_select(self, event):
        """選擇項目時顯示詳細內容"""
        selection = self.tree.selection()
        if not selection:
            return

        item = selection[0]
        index = self.tree.index(item)
        if index < len(self.results):
            result = self.results[index]

            self.detail_text.delete(1.0, tk.END)
            detail = f"檔案: {result.file_path}\n"
            detail += f"行號: {result.line_number}\n"
            detail += f"類型: {result.secret_type}\n"
            detail += f"內容: {result.content}\n"
            detail += f"嚴重程度: {result.severity}"

            self.detail_text.insert(1.0, detail)

    def add_to_gitignore(self):
        """將問題檔案加入 .gitignore"""
        try:
            gitignore_path = self.main_app.current_path / '.gitignore'

            files_to_ignore = set()
            for result in self.results:
                file_path = Path(result.file_path)
                if file_path.suffix == '.env':
                    files_to_ignore.add('.env*')
                else:
                    files_to_ignore.add(file_path.name)

            existing_content = ""
            if gitignore_path.exists():
                existing_content = gitignore_path.read_text(encoding='utf-8')

            new_entries = []
            for entry in files_to_ignore:
                if entry not in existing_content:
                    new_entries.append(entry)

            if new_entries:
                with gitignore_path.open('a', encoding='utf-8') as f:
                    f.write('\n# 安全掃描自動新增\n')
                    for entry in new_entries:
                        f.write(f'{entry}\n')

                self.main_app.log(f"已將 {len(new_entries)} 個項目加入 .gitignore")
                messagebox.showinfo("成功",
                                    f"已將 {len(new_entries)} 個項目加入 .gitignore")
            else:
                messagebox.showinfo("資訊", "所有項目都已在 .gitignore 中")

        except Exception as e:
            self.main_app.log(f"更新 .gitignore 失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"更新 .gitignore 失敗: {e}")

    def create_env_template(self):
        """建立環境變數範本"""
        try:
            env_example_path = self.main_app.current_path / '.env.example'

            env_vars = set()
            for result in self.results:
                if 'key' in result.secret_type.lower(
                ) or 'token' in result.secret_type.lower():
                    var_name = result.secret_type.upper().replace('_', '_')
                    env_vars.add(f"{var_name}=your_{result.secret_type}_here")

            with env_example_path.open('w', encoding='utf-8') as f:
                f.write("# 環境變數範本檔案\n")
                f.write("# 請複製為 .env 並填入實際值\n\n")
                for var in sorted(env_vars):
                    f.write(f"{var}\n")

            self.main_app.log(f"已建立環境變數範本: {env_example_path}")
            messagebox.showinfo("成功", f"已建立環境變數範本: {env_example_path.name}")

        except Exception as e:
            self.main_app.log(f"建立環境變數範本失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"建立環境變數範本失敗: {e}")

    def export_report(self):
        """匯出掃描報告"""
        try:
            filename = filedialog.asksaveasfilename(defaultextension=".txt",
                                                    filetypes=[
                                                        ("文字檔案", "*.txt"),
                                                        ("JSON 檔案", "*.json"),
                                                        ("所有檔案", "*.*")
                                                    ],
                                                    title="儲存掃描報告")

            if filename:
                if filename.endswith('.json'):
                    # JSON 格式
                    data = []
                    for result in self.results:
                        data.append({
                            'file_path': result.file_path,
                            'line_number': result.line_number,
                            'secret_type': result.secret_type,
                            'content': result.content,
                            'severity': result.severity
                        })

                    with open(filename, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                else:
                    # 文字格式
                    with open(filename, 'w', encoding='utf-8') as f:
                        f.write("GitGuard Sync 安全掃描報告\n")
                        f.write("=" * 50 + "\n")
                        f.write(
                            f"掃描時間: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
                        )
                        f.write(f"發現問題: {len(self.results)} 個\n\n")

                        for i, result in enumerate(self.results, 1):
                            f.write(f"{i}. 檔案: {result.file_path}\n")
                            f.write(f"   行號: {result.line_number}\n")
                            f.write(f"   類型: {result.secret_type}\n")
                            f.write(f"   嚴重程度: {result.severity}\n")
                            f.write(f"   內容: {result.content}\n")
                            f.write("-" * 30 + "\n")

                self.main_app.log(f"掃描報告已儲存至: {filename}")
                messagebox.showinfo("成功", "掃描報告已儲存")

        except Exception as e:
            self.main_app.log(f"匯出報告失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"匯出報告失敗: {e}")


class CommitDialog:
    """提交對話框"""

    def __init__(self, parent, main_app):
        self.main_app = main_app

        self.dialog = tk.Toplevel(parent)
        self.dialog.title("提交變更")
        self.dialog.geometry("600x400")
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()
        self.load_changes()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 變更列表
        changes_frame = ttk.LabelFrame(main_frame, text="變更檔案", padding=5)
        changes_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.changes_text = scrolledtext.ScrolledText(changes_frame,
                                                      height=10,
                                                      wrap=tk.WORD)
        self.changes_text.pack(fill=tk.BOTH, expand=True)

        # 提交訊息
        message_frame = ttk.LabelFrame(main_frame, text="提交訊息", padding=5)
        message_frame.pack(fill=tk.X, pady=(0, 10))

        self.message_var = tk.StringVar(value="更新檔案")
        ttk.Entry(message_frame,
                  textvariable=self.message_var,
                  font=("微軟正黑體", 10)).pack(fill=tk.X)

        # 按鈕
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)

        ttk.Button(button_frame, text="提交",
                   command=self.commit).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(button_frame, text="取消",
                   command=self.dialog.destroy).pack(side=tk.RIGHT)

    def load_changes(self):
        """載入變更列表"""
        try:
            # 獲取變更狀態
            status = self.main_app.repo.git.status("--porcelain")

            if status:
                self.changes_text.insert(tk.END, "變更檔案:\n")
                self.changes_text.insert(tk.END, "=" * 30 + "\n")

                for line in status.split('\n'):
                    if line.strip():
                        self.changes_text.insert(tk.END, f"{line}\n")
            else:
                self.changes_text.insert(tk.END, "沒有變更檔案")

        except Exception as e:
            self.changes_text.insert(tk.END, f"獲取變更狀態失敗: {e}")

    def commit(self):
        """執行提交"""
        message = self.message_var.get().strip()
        if not message:
            messagebox.showerror("錯誤", "請輸入提交訊息")
            return

        try:
            # 添加所有變更
            self.main_app.repo.git.add(".")

            # 提交
            self.main_app.repo.index.commit(message)

            self.main_app.log(f"變更已提交: {message}")
            messagebox.showinfo("成功", "變更已提交")
            self.dialog.destroy()

        except Exception as e:
            self.main_app.log(f"提交失敗: {e}", "ERROR")
            messagebox.showerror("錯誤", f"提交失敗: {e}")


class SyncDialog:
    """同步對話框"""

    def __init__(self, parent, main_app, remotes):
        self.main_app = main_app
        self.remotes = remotes

        self.dialog = tk.Toplevel(parent)
        self.dialog.title("同步推送")
        self.dialog.geometry("500x300")
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 選擇遠端
        remote_frame = ttk.LabelFrame(main_frame, text="選擇推送目標", padding=5)
        remote_frame.pack(fill=tk.X, pady=(0, 10))

        self.selected_remotes = {}

        # 全選選項
        self.all_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(remote_frame,
                        text="全部推送",
                        variable=self.all_var,
                        command=self.toggle_all).pack(anchor=tk.W)

        ttk.Separator(remote_frame, orient=tk.HORIZONTAL).pack(fill=tk.X,
                                                               pady=5)

        # 個別遠端選項
        for remote in self.remotes:
            var = tk.BooleanVar(value=True)
            self.selected_remotes[remote.name] = var

            remote_type = "GitHub" if "github.com" in remote.url else "GitLab"
            text = f"{remote.name} ({remote_type})"

            ttk.Checkbutton(remote_frame, text=text,
                            variable=var).pack(anchor=tk.W)

        # 進度顯示
        progress_frame = ttk.LabelFrame(main_frame, text="推送進度", padding=5)
        progress_frame.pack(fill=tk.X, pady=(0, 10))

        self.progress_var = tk.DoubleVar()
        self.progress_bar = ttk.Progressbar(progress_frame,
                                            variable=self.progress_var,
                                            maximum=100)
        self.progress_bar.pack(fill=tk.X, pady=(0, 5))

        self.status_var = tk.StringVar(value="就緒")
        ttk.Label(progress_frame, textvariable=self.status_var).pack()

        # 按鈕
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)

        self.sync_button = ttk.Button(button_frame,
                                      text="開始推送",
                                      command=self.start_sync)
        self.sync_button.pack(side=tk.LEFT, padx=(0, 5))

        ttk.Button(button_frame, text="取消",
                   command=self.dialog.destroy).pack(side=tk.RIGHT)

    def toggle_all(self):
        """切換全選狀態"""
        value = self.all_var.get()
        for var in self.selected_remotes.values():
            var.set(value)

    def start_sync(self):
        """開始同步推送"""
        selected = [
            name for name, var in self.selected_remotes.items() if var.get()
        ]

        if not selected:
            messagebox.showerror("錯誤", "請至少選擇一個遠端倉庫")
            return

        self.sync_button.config(state="disabled")
        self.status_var.set("推送中...")

        def sync_worker():
            try:
                total = len(selected)

                for i, remote_name in enumerate(selected):
                    self.status_var.set(f"推送到 {remote_name}...")

                    try:
                        remote = self.main_app.repo.remote(remote_name)
                        remote.push()

                        self.main_app.log(f"✅ 成功推送到 {remote_name}")

                    except Exception as e:
                        self.main_app.log(f"❌ 推送到 {remote_name} 失敗: {e}",
                                          "ERROR")

                    progress = ((i + 1) / total) * 100
                    self.progress_var.set(progress)

                self.status_var.set("推送完成")
                self.main_app.log("同步推送完成")

                messagebox.showinfo("完成", "同步推送完成")
                self.dialog.destroy()

            except Exception as e:
                self.main_app.log(f"同步推送失敗: {e}", "ERROR")
                self.status_var.set("推送失敗")
                messagebox.showerror("錯誤", f"同步推送失敗: {e}")

            finally:
                self.sync_button.config(state="normal")

        thread = threading.Thread(target=sync_worker, daemon=True)
        thread.start()


class RepoStatusDialog:
    """倉庫狀態對話框"""

    def __init__(self, parent, main_app):
        self.main_app = main_app

        self.dialog = tk.Toplevel(parent)
        self.dialog.title("倉庫狀態")
        self.dialog.geometry("600x500")
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()
        self.load_status()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # 基本資訊
        info_frame = ttk.LabelFrame(main_frame, text="基本資訊", padding=5)
        info_frame.pack(fill=tk.X, pady=(0, 10))

        self.info_text = tk.Text(info_frame, height=8, wrap=tk.WORD)
        self.info_text.pack(fill=tk.X)

        # 遠端倉庫
        remote_frame = ttk.LabelFrame(main_frame, text="遠端倉庫", padding=5)
        remote_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))

        self.remote_tree = ttk.Treeview(remote_frame,
                                        columns=("url", "type", "status"),
                                        show="tree headings",
                                        height=6)

        self.remote_tree.heading("#0", text="名稱")
        self.remote_tree.heading("url", text="URL")
        self.remote_tree.heading("type", text="類型")
        self.remote_tree.heading("status", text="狀態")

        self.remote_tree.column("#0", width=100)
        self.remote_tree.column("url", width=200)
        self.remote_tree.column("type", width=80)
        self.remote_tree.column("status", width=80)

        self.remote_tree.pack(fill=tk.BOTH, expand=True)

        # 按鈕
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)

        ttk.Button(button_frame, text="重新整理",
                   command=self.load_status).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(button_frame, text="關閉",
                   command=self.dialog.destroy).pack(side=tk.RIGHT)

    def load_status(self):
        """載入倉庫狀態"""
        try:
            # 清除現有內容
            self.info_text.delete(1.0, tk.END)
            for item in self.remote_tree.get_children():
                self.remote_tree.delete(item)

            # 基本資訊
            info = []
            info.append(f"倉庫路徑: {self.main_app.current_path}")

            if self.main_app.repo:
                try:
                    current_branch = self.main_app.repo.active_branch.name
                    info.append(f"當前分支: {current_branch}")
                except:
                    info.append("當前分支: (無法取得)")

                try:
                    total_commits = len(list(
                        self.main_app.repo.iter_commits()))
                    info.append(f"總提交數: {total_commits}")
                except:
                    info.append("總提交數: (無法取得)")

                dirty_status = "有未提交變更" if self.main_app.repo.is_dirty(
                ) else "乾淨"
                info.append(f"工作區狀態: {dirty_status}")

                # 最後提交資訊
                try:
                    last_commit = self.main_app.repo.head.commit
                    info.append(f"最後提交: {last_commit.hexsha[:8]}")
                    info.append(
                        f"提交時間: {datetime.fromtimestamp(last_commit.committed_date).strftime('%Y-%m-%d %H:%M:%S')}"
                    )
                    info.append(f"提交者: {last_commit.author.name}")
                    info.append(f"提交訊息: {last_commit.message.strip()}")
                except:
                    info.append("最後提交: (無法取得)")

            self.info_text.insert(tk.END, '\n'.join(info))

            # 遠端倉庫資訊
            if self.main_app.repo:
                for remote in self.main_app.repo.remotes:
                    remote_type = "GitHub" if "github.com" in remote.url else "GitLab"

                    # 測試連線狀態
                    try:
                        result = subprocess.run(
                            ["git", "ls-remote", "--heads", remote.name],
                            cwd=self.main_app.current_path,
                            capture_output=True,
                            timeout=5,
                            encoding='utf-8')
                        status = "✅ 正常" if result.returncode == 0 else "❌ 錯誤"
                    except:
                        status = "⏰ 逾時"

                    self.remote_tree.insert("",
                                            tk.END,
                                            text=remote.name,
                                            values=(remote.url, remote_type,
                                                    status))

        except Exception as e:
            self.info_text.insert(tk.END, f"載入狀態失敗: {e}")


class AboutDialog:
    """關於對話框"""

    def __init__(self, parent):
        self.dialog = tk.Toplevel(parent)
        self.dialog.title("關於 GitGuard Sync")
        self.dialog.geometry("500x400")
        self.dialog.resizable(False, False)
        self.dialog.transient(parent)
        self.dialog.grab_set()

        self.setup_ui()

        # 置中顯示
        self.dialog.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() -
                                self.dialog.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() -
                                self.dialog.winfo_height()) // 2
        self.dialog.geometry(f"+{x}+{y}")

    def setup_ui(self):
        """設定界面"""
        main_frame = ttk.Frame(self.dialog)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # 標題
        title_label = ttk.Label(main_frame,
                                text="GitGuard Sync",
                                font=("微軟正黑體", 16, "bold"))
        title_label.pack(pady=(0, 10))

        subtitle_label = ttk.Label(main_frame,
                                   text="Git 倉庫安全同步守護者",
                                   font=("微軟正黑體", 12))
        subtitle_label.pack(pady=(0, 20))

        # 版本資訊
        info_text = """版本: 3.0.1 (修復版)
        
功能特色:
• 🔐 專業安全掃描 (本地 + GitGuardian API)
• 🌐 雙平台同步 (GitHub + GitLab)
• 🖥️ 現代化 GUI 介面
• 📊 即時進度顯示
• 📋 詳細操作日誌
• 🛠️ 智慧檔案處理

技術支援:
• Python 3.7+
• tkinter GUI 框架
• GitPython 庫
• GitGuardian API

作者: 
許可證: MIT License"""

        info_label = ttk.Label(main_frame, text=info_text, justify=tk.LEFT)
        info_label.pack(pady=(0, 20))

        # 連結按鈕
        link_frame = ttk.Frame(main_frame)
        link_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Button(link_frame,
                   text="🌐 專案網頁",
                   command=lambda: webbrowser.open(
                       "https://github.com/seikaikyo/gitguard-sync")).pack(
                           side=tk.LEFT, padx=(0, 10))

        # 關閉按鈕
        ttk.Button(main_frame, text="關閉",
                   command=self.dialog.destroy).pack(pady=(20, 0))


def main():
    """主函式"""
    try:
        app = GitGuardSyncGUI()
        app.run()
    except Exception as e:
        messagebox.showerror("啟動錯誤", f"程式啟動失敗: {e}")


if __name__ == "__main__":
    main()
