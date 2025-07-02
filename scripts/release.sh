#!/bin/bash

# 自动版本升级和发布脚本
# 用法: ./scripts/release.sh "版本描述" [patch|minor|major]
# 示例: 
#   ./scripts/release.sh "修复了一些bug"
#   ./scripts/release.sh "添加新功能" minor
#   ./scripts/release.sh "重大更新" major

set -e  # 出错时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 输出函数
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 参数检查
if [ $# -lt 1 ]; then
    print_error "使用方法: $0 \"版本描述\" [patch|minor|major]"
    print_info "示例:"
    print_info "  $0 \"修复了一些bug\""
    print_info "  $0 \"添加新功能\" minor"
    print_info "  $0 \"重大更新\" major"
    exit 1
fi

DESCRIPTION="$1"
VERSION_TYPE="${2:-patch}"

# 验证版本类型
if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    print_error "版本类型必须是: patch, minor, 或 major"
    exit 1
fi

# 检查是否在项目根目录
if [ ! -f "pubspec.yaml" ]; then
    print_error "未找到 pubspec.yaml 文件，请在项目根目录运行此脚本"
    exit 1
fi

print_info "🚀 开始版本发布流程..."

# 检查工作区是否干净
if ! git diff-index --quiet HEAD --; then
    print_warning "工作区不干净，存在未提交的更改："
    git status --short
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "已取消发布"
        exit 0
    fi
fi

# 读取当前版本
print_info "📖 读取当前版本..."
if ! current_version=$(grep -E "^version:\s+" pubspec.yaml | sed -E 's/version:\s+([0-9]+\.[0-9]+\.[0-9]+).*/\1/'); then
    print_error "无法解析 pubspec.yaml 中的版本号"
    exit 1
fi

print_info "当前版本: v$current_version"

# 解析版本号
IFS='.' read -r current_major current_minor current_patch <<< "$current_version"

# 计算新版本
case "$VERSION_TYPE" in
    "major")
        new_major=$((current_major + 1))
        new_minor=0
        new_patch=0
        ;;
    "minor")
        new_major=$current_major
        new_minor=$((current_minor + 1))
        new_patch=0
        ;;
    "patch")
        new_major=$current_major
        new_minor=$current_minor
        new_patch=$((current_patch + 1))
        ;;
esac

new_version="$new_major.$new_minor.$new_patch"
new_tag="v$new_version"

print_info "新版本: $new_tag ($VERSION_TYPE 升级)"

# 确认发布
read -p "确认发布版本 $new_tag 吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "已取消发布"
    exit 0
fi

# 备份原始文件
cp pubspec.yaml pubspec.yaml.backup

# 错误处理函数
cleanup() {
    if [ -f "pubspec.yaml.backup" ]; then
        print_warning "正在回滚更改..."
        mv pubspec.yaml.backup pubspec.yaml
        # 删除可能创建的标签
        git tag -d "$new_tag" 2>/dev/null || true
        print_info "已回滚更改"
    fi
}

# 设置错误处理
trap cleanup ERR

# 更新 pubspec.yaml
print_info "📝 更新 pubspec.yaml..."
sed -i.bak "s/version: $current_version/version: $new_version/" pubspec.yaml
rm pubspec.yaml.bak 2>/dev/null || true
print_success "已更新版本号到 $new_version"

# 添加更改到 git
print_info "📦 添加更改到 Git..."
git add pubspec.yaml

# 提交更改
commit_message="🔖 Release $new_tag - $DESCRIPTION"
print_info "💾 提交更改: $commit_message"
git commit -m "$commit_message"

# 创建标签
print_info "🏷️  创建标签 $new_tag..."
tag_message="Release $new_tag

$DESCRIPTION"
git tag -a "$new_tag" -m "$tag_message"

# 推送到远程仓库
print_info "🚀 推送到 GitHub..."
git push origin master

print_info "🏷️  推送标签..."
git push origin "$new_tag"

# 清理备份文件
rm -f pubspec.yaml.backup

print_success "🎉 版本 $new_tag 发布成功！"
echo
print_info "📋 发布信息："
print_info "   版本: $new_tag"
print_info "   类型: $VERSION_TYPE 升级"
print_info "   描述: $DESCRIPTION"
echo
print_info "🔗 查看发布状态："
print_info "   GitHub Actions: https://github.com/Tencon99/doudouai/actions"
print_info "   Releases: https://github.com/Tencon99/doudouai/releases"
echo
print_success "GitHub Actions 将自动构建各平台的安装包！" 