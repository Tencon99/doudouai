#!/usr/bin/env pwsh
# PowerShell Script for Version Release
# Encoding: UTF-8 with BOM

<#
.SYNOPSIS
    自动版本升级和发布脚本

.DESCRIPTION
    该脚本会自动递增版本号，更新pubspec.yaml，提交更改，创建tag并推送到GitHub

.PARAMETER Description
    版本发布描述信息

.PARAMETER VersionType
    版本类型：patch (默认), minor, major

.EXAMPLE
    .\scripts\release.ps1 "修复了一些bug"
    .\scripts\release.ps1 "添加新功能" minor
    .\scripts\release.ps1 "重大更新" major

.NOTES
    需要确保已经配置了git和GitHub访问权限
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("patch", "minor", "major")]
    [string]$VersionType = "patch"
)

# 设置控制台编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 设置错误停止
$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success($Message) {
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Info($Message) {
    Write-ColorOutput "ℹ️  $Message" "Cyan"
}

function Write-Warning($Message) {
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Error($Message) {
    Write-ColorOutput "❌ $Message" "Red"
}

# 检查是否在项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "未找到 pubspec.yaml 文件，请在项目根目录运行此脚本"
    exit 1
}

Write-Info "🚀 开始版本发布流程..."

# 检查工作区是否干净
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Warning "工作区不干净，存在未提交的更改："
    git status --short
    $continue = Read-Host "是否继续？(y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Info "已取消发布"
        exit 0
    }
}

# 读取当前版本
Write-Info "📖 读取当前版本..."
$pubspecContent = Get-Content "pubspec.yaml" -Raw -Encoding UTF8
$versionMatch = [regex]::Match($pubspecContent, "version:\s+(\d+)\.(\d+)\.(\d+)")

if (-not $versionMatch.Success) {
    Write-Error "无法解析 pubspec.yaml 中的版本号"
    exit 1
}

$currentMajor = [int]$versionMatch.Groups[1].Value
$currentMinor = [int]$versionMatch.Groups[2].Value
$currentPatch = [int]$versionMatch.Groups[3].Value
$currentVersion = "$currentMajor.$currentMinor.$currentPatch"

Write-Info "当前版本: v$currentVersion"

# 计算新版本
switch ($VersionType) {
    "major" {
        $newMajor = $currentMajor + 1
        $newMinor = 0
        $newPatch = 0
    }
    "minor" {
        $newMajor = $currentMajor
        $newMinor = $currentMinor + 1
        $newPatch = 0
    }
    "patch" {
        $newMajor = $currentMajor
        $newMinor = $currentMinor
        $newPatch = $currentPatch + 1
    }
}

$newVersion = "$newMajor.$newMinor.$newPatch"
$newTag = "v$newVersion"

Write-Info "新版本: $newTag ($VersionType 升级)"

# 确认发布
$confirm = Read-Host "确认发布版本 $newTag 吗？(y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Info "已取消发布"
    exit 0
}

try {
    # 更新 pubspec.yaml
    Write-Info "📝 更新 pubspec.yaml..."
    $newPubspecContent = $pubspecContent -replace "version:\s+\d+\.\d+\.\d+", "version: $newVersion"
    Set-Content "pubspec.yaml" $newPubspecContent -Encoding UTF8 -NoNewline
    Write-Success "已更新版本号到 $newVersion"

    # 添加更改到 git
    Write-Info "📦 添加更改到 Git..."
    git add pubspec.yaml
    
    # 提交更改
    $commitMessage = "🔖 Release $newTag - $Description"
    Write-Info "💾 提交更改: $commitMessage"
    git commit -m $commitMessage

    # 创建标签
    Write-Info "🏷️  创建标签 $newTag..."
    $tagMessage = "Release $newTag`n`n$Description"
    git tag -a $newTag -m $tagMessage

    # 推送到远程仓库
    Write-Info "🚀 推送到 GitHub..."
    git push origin master
    
    Write-Info "🏷️  推送标签..."
    git push origin $newTag

    Write-Success "🎉 版本 $newTag 发布成功！"
    Write-Info ""
    Write-Info "📋 发布信息："
    Write-Info "   版本: $newTag"
    Write-Info "   类型: $VersionType 升级"
    Write-Info "   描述: $Description"
    Write-Info ""
    Write-Info "🔗 查看发布状态："
    Write-Info "   GitHub Actions: https://github.com/Tencon99/doudouai/actions"
    Write-Info "   Releases: https://github.com/Tencon99/doudouai/releases"
    Write-Info ""
    Write-Success "GitHub Actions 将自动构建各平台的安装包！"

} catch {
    Write-Error "发布过程中出现错误: $($_.Exception.Message)"
    Write-Warning "正在回滚更改..."
    
    # 回滚 pubspec.yaml
    $originalPubspecContent = $pubspecContent
    Set-Content "pubspec.yaml" $originalPubspecContent -Encoding UTF8 -NoNewline
    
    # 删除可能创建的标签
    try {
        git tag -d $newTag 2>$null
    } catch {
        # 忽略删除标签的错误
    }
    
    Write-Info "已回滚更改"
    exit 1
} 