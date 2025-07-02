@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 自动版本升级和发布脚本
:: 用法: release.cmd "版本描述" [patch|minor|major]

if "%~1"=="" (
    echo 错误: 缺少版本描述参数
    echo 用法: %~nx0 "版本描述" [patch^|minor^|major]
    echo 示例:
    echo   %~nx0 "修复了一些bug"
    echo   %~nx0 "添加新功能" minor
    echo   %~nx0 "重大更新" major
    exit /b 1
)

set "DESCRIPTION=%~1"
set "VERSION_TYPE=%~2"
if "%VERSION_TYPE%"=="" set "VERSION_TYPE=patch"

:: 验证版本类型
if not "%VERSION_TYPE%"=="patch" if not "%VERSION_TYPE%"=="minor" if not "%VERSION_TYPE%"=="major" (
    echo 错误: 版本类型必须是 patch, minor, 或 major
    exit /b 1
)

:: 检查是否在项目根目录
if not exist "pubspec.yaml" (
    echo 错误: 未找到 pubspec.yaml 文件，请在项目根目录运行此脚本
    exit /b 1
)

echo 🚀 开始版本发布流程...

:: 检查工作区是否干净
git status --porcelain > nul 2>&1
if errorlevel 1 (
    echo 错误: Git 命令失败
    exit /b 1
)

for /f %%i in ('git status --porcelain') do (
    echo ⚠️  工作区不干净，存在未提交的更改:
    git status --short
    set /p "continue=是否继续？(y/N): "
    if /i not "!continue!"=="y" (
        echo 已取消发布
        exit /b 0
    )
    goto :continue_process
)

:continue_process
echo 📖 读取当前版本...

:: 读取当前版本
for /f "tokens=2" %%i in ('findstr "version:" pubspec.yaml') do set "CURRENT_VERSION=%%i"
if "%CURRENT_VERSION%"=="" (
    echo 错误: 无法解析 pubspec.yaml 中的版本号
    exit /b 1
)

echo 当前版本: v%CURRENT_VERSION%

:: 解析版本号
for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
    set /a "CURRENT_MAJOR=%%a"
    set /a "CURRENT_MINOR=%%b"
    set /a "CURRENT_PATCH=%%c"
)

:: 计算新版本
if "%VERSION_TYPE%"=="major" (
    set /a "NEW_MAJOR=%CURRENT_MAJOR%+1"
    set "NEW_MINOR=0"
    set "NEW_PATCH=0"
) else if "%VERSION_TYPE%"=="minor" (
    set "NEW_MAJOR=%CURRENT_MAJOR%"
    set /a "NEW_MINOR=%CURRENT_MINOR%+1"
    set "NEW_PATCH=0"
) else (
    set "NEW_MAJOR=%CURRENT_MAJOR%"
    set "NEW_MINOR=%CURRENT_MINOR%"
    set /a "NEW_PATCH=%CURRENT_PATCH%+1"
)

set "NEW_VERSION=%NEW_MAJOR%.%NEW_MINOR%.%NEW_PATCH%"
set "NEW_TAG=v%NEW_VERSION%"

echo 新版本: %NEW_TAG% (%VERSION_TYPE% 升级)

:: 确认发布
set /p "confirm=确认发布版本 %NEW_TAG% 吗？(y/N): "
if /i not "%confirm%"=="y" (
    echo 已取消发布
    exit /b 0
)

:: 备份原始文件
copy pubspec.yaml pubspec.yaml.backup >nul

:: 更新 pubspec.yaml
echo 📝 更新 pubspec.yaml...
powershell -Command "(Get-Content 'pubspec.yaml') -replace 'version: %CURRENT_VERSION%', 'version: %NEW_VERSION%' | Set-Content 'pubspec.yaml' -Encoding UTF8"
echo ✅ 已更新版本号到 %NEW_VERSION%

:: Git 操作
echo 📦 添加更改到 Git...
git add pubspec.yaml

set "COMMIT_MESSAGE=🔖 Release %NEW_TAG% - %DESCRIPTION%"
echo 💾 提交更改: %COMMIT_MESSAGE%
git commit -m "%COMMIT_MESSAGE%"

echo 🏷️  创建标签 %NEW_TAG%...
set "TAG_MESSAGE=Release %NEW_TAG%

%DESCRIPTION%"
git tag -a %NEW_TAG% -m "%TAG_MESSAGE%"

echo 🚀 推送到 GitHub...
git push origin master

echo 🏷️  推送标签...
git push origin %NEW_TAG%

:: 清理备份文件
del pubspec.yaml.backup >nul 2>&1

echo.
echo ✅ 🎉 版本 %NEW_TAG% 发布成功！
echo.
echo 📋 发布信息:
echo    版本: %NEW_TAG%
echo    类型: %VERSION_TYPE% 升级
echo    描述: %DESCRIPTION%
echo.
echo 🔗 查看发布状态:
echo    GitHub Actions: https://github.com/Tencon99/doudouai/actions
echo    Releases: https://github.com/Tencon99/doudouai/releases
echo.
echo ✅ GitHub Actions 将自动构建各平台的安装包！

goto :eof

:error
echo 错误: 发布过程中出现错误
echo 正在回滚更改...
if exist pubspec.yaml.backup (
    move pubspec.yaml.backup pubspec.yaml >nul
    echo 已回滚更改
)
exit /b 1 