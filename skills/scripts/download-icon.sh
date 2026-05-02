#!/usr/bin/env bash

# =============================================================================
# Icon Downloader - 从多个图标源下载应用图标
# 支持的源：dashboardicons、simpleicons、selfh.st
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 图标源配置
DASHBOARD_ICONS="https://dashboardicons.com/icons"
SIMPLE_ICONS="https://cdn.simpleicons.org"
SELFHST_ICONS="https://selfh.st/icons"

# 默认输出尺寸
DEFAULT_SIZE=200

# 打印帮助
print_help() {
  cat << EOF
${BLUE}Icon Downloader${NC} - 从多个图标源下载应用图标

${YELLOW}用法:${NC}
  $0 <应用名称> [输出文件] [尺寸]

${YELLOW}参数:${NC}
  应用名称   - 应用的名称（如 alist, nginx, redis）
  输出文件   - 图标保存路径（默认: ./logo.png）
  尺寸       - 图标尺寸（默认: 200x200）

${YELLOW}图标源优先级:${NC}
  1. Dashboard Icons (dashboardicons.com)
  2. Simple Icons (simpleicons.org)
  3. selfh.st Icons (selfh.st)

${YELLOW}示例:${NC}
  $0 alist ./logo.png 200
  $0 nginx /tmp/nginx-icon.png
  $0 redis
EOF
}

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 下载并调整图标尺寸
download_and_resize() {
  local url="$1"
  local output="$2"
  local size="$3"

  if curl -sSL -o "$output" "$url" 2>/dev/null && [[ -s "$output" ]]; then
    # 检查是否安装了 ImageMagick 或 sips (macOS)
    if command -v convert &>/dev/null; then
      convert "$output" -resize "${size}x${size}" "$output" 2>/dev/null || true
    elif command -v sips &>/dev/null; then
      sips -z "$size" "$size" "$output" &>/dev/null || true
    fi
    return 0
  fi
  return 1
}

# 尝试从各图标源下载
try_download_icon() {
  local app_name="$1"
  local output="$2"
  local size="$3"

  local name_lower
  name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

  log_info "尝试下载图标: $app_name"

  # 1. Dashboard Icons
  log_info "尝试 Dashboard Icons..."
  local dashboard_url="${DASHBOARD_ICONS}/${name_lower}.png"
  if download_and_resize "$dashboard_url" "$output" "$size"; then
    log_info "✓ 从 Dashboard Icons 下载成功"
    return 0
  fi

  # 尝试带 -dark 后缀
  if download_and_resize "${DASHBOARD_ICONS}/${name_lower}-dark.png" "$output" "$size"; then
    log_info "✓ 从 Dashboard Icons (dark) 下载成功"
    return 0
  fi

  # 2. Simple Icons
  log_info "尝试 Simple Icons..."
  local simple_url="${SIMPLE_ICONS}/${name_lower}"
  if download_and_resize "$simple_url" "$output" "$size"; then
    log_info "✓ 从 Simple Icons 下载成功"
    return 0
  fi

  # Simple Icons 也支持 SVG
  if curl -sSL -o "${output%.png}.svg" "${SIMPLE_ICONS}/${name_lower}" 2>/dev/null && [[ -s "${output%.png}.svg" ]]; then
    log_info "✓ 从 Simple Icons 下载 SVG 成功"
    # 如果有 SVG，尝试转换
    if command -v convert &>/dev/null; then
      convert "${output%.png}.svg" -resize "${size}x${size}" "$output" 2>/dev/null || true
      if [[ -s "$output" ]]; then
        rm -f "${output%.png}.svg"
        return 0
      fi
    fi
  fi

  # 3. selfh.st Icons
  log_info "尝试 selfh.st Icons..."
  local selfhst_url="${SELFHST_ICONS}/${name_lower}.png"
  if download_and_resize "$selfhst_url" "$output" "$size"; then
    log_info "✓ 从 selfh.st Icons 下载成功"
    return 0
  fi

  return 1
}

# 创建占位图标
create_placeholder() {
  local output="$1"
  local size="$2"

  log_warn "创建占位图标"

  # 使用 ImageMagick 创建简单的占位图标
  if command -v convert &>/dev/null; then
    convert -size "${size}x${size}" xc:'#4A90E2' \
      -gravity center \
      -pointsize 48 \
      -fill white \
      -annotate 0 "?" \
      "$output" 2>/dev/null
    return $?
  fi

  # macOS sips 方式
  if command -v sips &>/dev/null; then
    # 创建一个简单的 1x1 像素 PNG 然后放大
    local temp_file="/tmp/placeholder_${RANDOM}.png"
    echo -n "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > "$temp_file"
    sips -z "$size" "$size" "$temp_file" --out "$output" &>/dev/null
    rm -f "$temp_file"
    return $?
  fi

  # 最简单的占位符
  echo -n "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > "$output"
}

# 主函数
main() {
  local app_name="${1:-}"
  local output="${2:-./logo.png}"
  local size="${3:-$DEFAULT_SIZE}"

  # 参数检查
  if [[ -z "$app_name" ]] || [[ "$app_name" == "-h" ]] || [[ "$app_name" == "--help" ]]; then
    print_help
    exit 0
  fi

  # 确保输出目录存在
  local output_dir
  output_dir=$(dirname "$output")
  mkdir -p "$output_dir"

  # 尝试下载
  if try_download_icon "$app_name" "$output" "$size"; then
    log_info "${GREEN}✓ 图标下载完成: $output${NC}"
    exit 0
  fi

  # 下载失败，创建占位符
  create_placeholder "$output" "$size"
  log_warn "未找到图标，已创建占位符: $output"
  log_info "请手动从以下网站下载合适的图标:"
  echo "  - https://dashboardicons.com/icons?q=${app_name}"
  echo "  - https://simpleicons.org/?q=${app_name}"
  echo "  - https://selfh.st/icons/"
}

# 执行主函数
main "$@"
