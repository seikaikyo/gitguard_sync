#!/usr/bin/env python3
"""
GitGuard Sync 跨平台自動打包腳本
支援 Windows、macOS、Linux 三大平台
"""

import os
import sys
import shutil
import subprocess
import platform
from pathlib import Path

class GitGuardSyncBuilder:
    """GitGuard Sync 建置工具"""
    
    def __init__(self):
        self.app_name = "GitGuard-Sync"
        self.script_name = "gitguard_sync.py"
        self.version = "3.0.0"
        self.dist_dir = "release"
        self.build_dir = "build"
        self.platform = platform.system().lower()
        
        # 平台特定設定
        self.platform_config = {
            'windows': {
                'executable_suffix': '.exe',
                'separator': ';',
                'icon_param': '--icon=icon.ico' if Path('icon.ico').exists() else ''
            },
            'darwin': {  # macOS
                'executable_suffix': '',
                'separator': ':',
                'icon_param': '--icon=icon.icns' if Path('icon.icns').exists() else ''
            },
            'linux': {
                'executable_suffix': '',
                'separator': ':',
                'icon_param': ''
            }
        }
    
    def print_banner(self):
        """顯示標題橫幅"""
        banner = """
╔══════════════════════════════════════════════════════════════════════════════╗
║                          GitGuard Sync 自動建置工具                          ║
║                     Git 倉庫安全同步守護者 - v3.0.0                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
        """
        print(banner)
        print(f"🖥️  目標平台: {platform.system()} {platform.machine()}")
        print(f"🐍 Python 版本: {sys.version.split()[0]}")
        print()
    
    def check_environment(self):
        """檢查建置環境"""
        print("[1/7] 檢查建置環境...")
        
        # 檢查 Python 版本
        if sys.version_info < (3, 7):
            print("❌ 錯誤: Python 版本過低，需要 3.7 或更高版本")
            return False
        
        # 檢查主程式檔案
        if not Path(self.script_name).exists():
            print(f"❌ 錯誤: 找不到主程式檔案 {self.script_name}")
            return False
        
        print("✅ 環境檢查通過")
        return True
    
    def install_dependencies(self):
        """安裝建置依賴"""
        print("\n[2/7] 安裝建置依賴...")
        
        try:
            # 升級 pip
            subprocess.run([sys.executable, '-m', 'pip', 'install', '--upgrade', 'pip'], 
                         check=True, capture_output=True)
            
            # 安裝 PyInstaller
            subprocess.run([sys.executable, '-m', 'pip', 'install', '--upgrade', 'pyinstaller'], 
                         check=True, capture_output=True)
            
            # 安裝專案依賴
            dependencies = ['gitpython', 'requests']
            subprocess.run([sys.executable, '-m', 'pip', 'install', '--upgrade'] + dependencies, 
                         check=True, capture_output=True)
            
            print("✅ 依賴套件安裝完成")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 安裝依賴失敗: {e}")
            return False
    
    def clean_old_builds(self):
        """清理舊建置檔案"""
        print("\n[3/7] 清理舊建置檔案...")
        
        try:
            # 移除舊目錄
            for directory in [self.dist_dir, self.build_dir]:
                if Path(directory).exists():
                    shutil.rmtree(directory)
            
            # 移除 spec 檔案
            for spec_file in Path('.').glob('*.spec'):
                spec_file.unlink()
            
            print("✅ 舊檔案清理完成")
            return True
            
        except Exception as e:
            print(f"❌ 清理失敗: {e}")
            return False
    
    def create_version_file(self):
        """創建版本資訊檔案（Windows 專用）"""
        if self.platform != 'windows':
            return True
        
        print("\n[4/7] 創建版本資訊檔案...")
        
        version_info = f"""# UTF-8
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=({self.version.replace('.', ',')},0),
    prodvers=({self.version.replace('.', ',')},0),
    mask=0x3f,
    flags=0x0,
    OS=0x40004,
    fileType=0x1,
    subtype=0x0,
    date=(0, 0)
  ),
  kids=[
    StringFileInfo(
      [
      StringTable(
        u'040904B0',
        [StringStruct(u'CompanyName', u''),
        StringStruct(u'FileDescription', u'GitGuard Sync - Git 倉庫安全同步守護者'),
        StringStruct(u'FileVersion', u'{self.version}'),
        StringStruct(u'InternalName', u'{self.app_name}'),
        StringStruct(u'LegalCopyright', u'MIT License'),
        StringStruct(u'OriginalFilename', u'{self.app_name}.exe'),
        StringStruct(u'ProductName', u'GitGuard Sync'),
        StringStruct(u'ProductVersion', u'{self.version}')])
      ]), 
    VarFileInfo([VarStruct(u'Translation', [1033, 1200])])
  ]
)
"""
        
        try:
            with open('version_info.py', 'w', encoding='utf-8') as f:
                f.write(version_info)
            print("✅ 版本資訊檔案創建完成")
            return True
        except Exception as e:
            print(f"❌ 創建版本資訊檔案失敗: {e}")
            return False
    
    def build_executable(self):
        """建置執行檔"""
        print("\n[5/7] 開始建置執行檔...")
        
        config = self.platform_config.get(self.platform, self.platform_config['linux'])
        
        # 基本參數
        cmd = [
            'pyinstaller',
            '--onefile',
            '--name', self.app_name,
            '--distpath', self.dist_dir,
            '--workpath', self.build_dir,
            '--clean',
            '--noconfirm'
        ]
        
        # 平台特定參數
        if self.platform == 'windows':
            cmd.append('--windowed')  # Windows 隱藏控制台
            if config['icon_param']:
                cmd.extend(['--icon', 'icon.ico'])
            if Path('version_info.py').exists():
                cmd.extend(['--version-file', 'version_info.py'])
        elif self.platform == 'darwin':  # macOS
            if config['icon_param']:
                cmd.extend(['--icon', 'icon.icns'])
            cmd.append('--windowed')
        
        # 隱藏匯入模組
        hidden_imports = [
            'tkinter', 'tkinter.ttk', 'tkinter.font',
            'tkinter.filedialog', 'tkinter.messagebox', 'tkinter.scrolledtext',
            'git', 'git.repo', 'git.remote',
            'requests', 'threading', 'subprocess',
            'pathlib', 'json', 're', 'webbrowser',
            'datetime', 'dataclasses', 'typing'
        ]
        
        for module in hidden_imports:
            cmd.extend(['--hidden-import', module])
        
        # 排除不需要的大型模組
        exclude_modules = ['matplotlib', 'numpy', 'pandas', 'scipy']
        for module in exclude_modules:
            cmd.extend(['--exclude-module', module])
        
        # 主程式檔案
        cmd.append(self.script_name)
        
        print(f"📦 建置命令: {' '.join(cmd)}")
        print("🔧 正在建置，請稍候...")
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print("✅ 建置完成")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 建置失敗: {e}")
            if e.stdout:
                print(f"標準輸出: {e.stdout}")
            if e.stderr:
                print(f"錯誤輸出: {e.stderr}")
            return False
    
    def verify_build(self):
        """驗證建置結果"""
        print("\n[6/7] 驗證建置結果...")
        
        config = self.platform_config.get(self.platform, self.platform_config['linux'])
        executable_name = f"{self.app_name}{config['executable_suffix']}"
        executable_path = Path(self.dist_dir) / executable_name
        
        if executable_path.exists():
            # 獲取檔案大小
            file_size = executable_path.stat().st_size
            size_mb = file_size / (1024 * 1024)
            
            print("✅ 建置驗證成功")
            print(f"📊 執行檔資訊:")
            print(f"   📁 檔案路徑: {executable_path}")
            print(f"   📏 檔案大小: {size_mb:.1f} MB")
            print(f"   🏗️  建置平台: {platform.system()} {platform.machine()}")
            
            return True
        else:
            print(f"❌ 建置驗證失敗: 找不到執行檔 {executable_path}")
            return False
    
    def cleanup_and_finalize(self):
        """清理和最終處理"""
        print("\n[7/7] 最終處理...")
        
        try:
            # 詢問是否保留建置快取
            keep_cache = input("是否保留建置快取？(y/N): ").lower().startswith('y')
            
            if not keep_cache:
                # 清理建置快取
                if Path(self.build_dir).exists():
                    shutil.rmtree(self.build_dir)
                
                # 清理 spec 檔案
                for spec_file in Path('.').glob('*.spec'):
                    spec_file.unlink()
                
                # 清理版本資訊檔案
                if Path('version_info.py').exists():
                    Path('version_info.py').unlink()
                
                print("🗑️  建置快取已清理")
            
            # 創建使用說明
            self.create_usage_instructions()
            
            print("✅ 最終處理完成")
            return True
            
        except Exception as e:
            print(f"❌ 最終處理失敗: {e}")
            return False
    
    def create_usage_instructions(self):
        """創建使用說明檔案"""
        config = self.platform_config.get(self.platform, self.platform_config['linux'])
        executable_name = f"{self.app_name}{config['executable_suffix']}"
        
        instructions = f"""GitGuard Sync v{self.version} 使用說明
{'=' * 50}

📦 建置資訊:
- 建置平台: {platform.system()} {platform.machine()}
- 建置時間: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- Python 版本: {sys.version.split()[0]}

🚀 執行方式:
"""
        
        if self.platform == 'windows':
            instructions += f"""
1. 雙擊執行 {executable_name}
2. 或在命令提示字元中執行:
   {executable_name}
"""
        else:
            instructions += f"""
1. 在終端機中執行:
   ./{executable_name}
   
2. 如果遇到權限問題，請先執行:
   chmod +x {executable_name}
"""
        
        instructions += f"""
📋 系統需求:
- 作業系統: {platform.system()} 
- 記憶體: 至少 100MB 可用
- 硬碟空間: 50MB

🔧 功能特色:
- Git 倉庫安全掃描
- 雙平台同步 (GitHub + GitLab)
- GitGuardian API 整合
- 現代化 GUI 介面

📞 技術支援:
- 作者: 
- 專案網頁: https://github.com/seikaikyo/gitguard-sync

⚠️  注意事項:
- 首次執行可能需要較長時間載入
- 防毒軟體可能會誤報，請加入白名單
- 使用 GitGuardian 功能需要 API 金鑰

🎉 感謝使用 GitGuard Sync！
"""
        
        try:
            readme_path = Path(self.dist_dir) / 'README.txt'
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(instructions)
            print(f"📝 使用說明已創建: {readme_path}")
        except Exception as e:
            print(f"⚠️  創建使用說明失敗: {e}")
    
    def run(self):
        """執行完整建置流程"""
        self.print_banner()
        
        steps = [
            self.check_environment,
            self.install_dependencies,
            self.clean_old_builds,
            self.create_version_file,
            self.build_executable,
            self.verify_build,
            self.cleanup_and_finalize
        ]
        
        for step in steps:
            if not step():
                print(f"\n❌ 建置過程失敗，請檢查上方錯誤訊息")
                return False
        
        print(f"\n🎉 GitGuard Sync v{self.version} 建置完成！")
        print(f"📦 執行檔位置: {Path(self.dist_dir).absolute()}")
        
        # 詢問是否開啟輸出目錄
        if input("\n是否要開啟輸出目錄？(Y/n): ").lower() != 'n':
            try:
                if self.platform == 'windows':
                    os.startfile(self.dist_dir)
                elif self.platform == 'darwin':
                    subprocess.run(['open', self.dist_dir])
                else:  # linux
                    subprocess.run(['xdg-open', self.dist_dir])
            except Exception as e:
                print(f"⚠️  無法開啟目錄: {e}")
        
        return True

def main():
    """主函式"""
    builder = GitGuardSyncBuilder()
    success = builder.run()
    
    if not success:
        input("\n按 Enter 鍵離開...")
        sys.exit(1)

if __name__ == "__main__":
    main()