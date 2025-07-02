# 🚀 版本发布脚本使用指南

本目录包含自动化版本发布脚本，支持版本自增、自动提交、创建标签并推送到GitHub。

## 📁 脚本文件

- `release.cmd` - Windows 批处理脚本 (推荐，支持中文)
- `release.ps1` - Windows PowerShell 脚本 (可能有中文编码问题)
- `release.sh` - Linux/macOS Bash 脚本

## 🔧 功能特性

- ✅ 自动递增版本号（patch、minor、major）
- ✅ 更新 `pubspec.yaml` 文件中的版本
- ✅ 创建Git提交和标签
- ✅ 自动推送到GitHub
- ✅ 触发GitHub Actions构建
- ✅ 错误回滚机制
- ✅ 彩色输出和进度提示

## 📋 使用方法

### Windows (批处理脚本 - 推荐)

```cmd
# Patch版本升级 (0.0.1 -> 0.0.2)
scripts\release.cmd "修复了一些重要bug"

# Minor版本升级 (0.0.1 -> 0.1.0)
scripts\release.cmd "添加了新功能" minor

# Major版本升级 (0.0.1 -> 1.0.0)
scripts\release.cmd "重大更新，不兼容旧版本" major
```

### Windows (PowerShell - 可能有编码问题)

```powershell
# Patch版本升级 (0.0.1 -> 0.0.2)
./scripts/release.ps1 "修复了一些重要bug"

# Minor版本升级 (0.0.1 -> 0.1.0)
./scripts/release.ps1 "添加了新功能" minor

# Major版本升级 (0.0.1 -> 1.0.0)
./scripts/release.ps1 "重大更新，不兼容旧版本" major
```

### Linux/macOS (Bash)

```bash
# 设置执行权限（首次使用）
chmod +x scripts/release.sh

# Patch版本升级 (0.0.1 -> 0.0.2)
./scripts/release.sh "修复了一些重要bug"

# Minor版本升级 (0.0.1 -> 0.1.0)
./scripts/release.sh "添加了新功能" minor

# Major版本升级 (0.0.1 -> 1.0.0)
./scripts/release.sh "重大更新，不兼容旧版本" major
```

## 📝 参数说明

### 必需参数

- **描述信息**: 版本发布的描述，会作为标签消息和提交信息的一部分

### 可选参数

- **版本类型**: `patch`(默认) | `minor` | `major`
  - `patch`: 修复bug，递增第三位数字 (1.0.0 -> 1.0.1)
  - `minor`: 新功能，递增第二位数字 (1.0.0 -> 1.1.0)
  - `major`: 重大更新，递增第一位数字 (1.0.0 -> 2.0.0)

## 🔄 工作流程

1. **前置检查**
   - 检查是否在项目根目录
   - 检查工作区是否干净
   - 解析当前版本号

2. **版本计算**
   - 根据版本类型计算新版本号
   - 用户确认发布

3. **文件更新**
   - 更新 `pubspec.yaml` 中的版本号
   - 添加到Git暂存区

4. **Git操作**
   - 创建提交：`🔖 Release v0.0.3 - 修复了一些重要bug`
   - 创建标签：`v0.0.3`
   - 推送代码和标签到GitHub

5. **完成发布**
   - 显示发布信息
   - 提供相关链接

## ⚠️ 注意事项

### 前置要求

- 确保Git已正确配置
- 确保有GitHub推送权限
- 确保在项目根目录运行脚本

### 安全检查

- 脚本会检查工作区状态，如有未提交更改会提示
- 支持错误回滚，出错时自动恢复原始版本号
- 需要用户确认才会执行发布操作

### Windows 中文编码问题解决方案

**推荐使用批处理脚本** (`release.cmd`)，它已经解决了中文编码问题。

如果必须使用PowerShell脚本，可能会遇到中文显示乱码的问题。这是由于PowerShell的编码设置导致的。

### PowerShell执行策略

如果在Windows上使用PowerShell脚本遇到执行策略问题，请运行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🎯 示例输出

### Windows 批处理脚本输出：
```
🚀 开始版本发布流程...
📖 读取当前版本...
当前版本: v0.0.3
新版本: v0.0.4 (patch 升级)
确认发布版本 v0.0.4 吗？(y/N): y
📝 更新 pubspec.yaml...
✅ 已更新版本号到 0.0.4
📦 添加更改到 Git...
💾 提交更改: 🔖 Release v0.0.4 - 修复了一些重要bug
🏷️  创建标签 v0.0.4...
🚀 推送到 GitHub...
🏷️  推送标签...

✅ 🎉 版本 v0.0.4 发布成功！

📋 发布信息:
   版本: v0.0.4
   类型: patch 升级
   描述: 修复了一些重要bug

🔗 查看发布状态:
   GitHub Actions: https://github.com/Tencon99/doudouai/actions
   Releases: https://github.com/Tencon99/doudouai/releases

✅ GitHub Actions 将自动构建各平台的安装包！
```

## 🔗 相关链接

- [GitHub Actions 状态](https://github.com/Tencon99/doudouai/actions)
- [Releases 页面](https://github.com/Tencon99/doudouai/releases)
- [项目主页](https://github.com/Tencon99/doudouai) 