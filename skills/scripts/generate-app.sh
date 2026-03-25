#!/usr/bin/env bash

# =============================================================================
# 1Panel App Builder - 主生成脚本
# 功能：从 GitHub 项目、docker-compose、docker run 命令生成 1Panel APP 配置
# 用法：./generate-app.sh <输入源> [输出目录]
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../templates"
OUTPUT_BASE="${2:-./apps}"
ICON_SOURCES=(
  "https://dashboardicons.com/icons"
  "https://simpleicons.org/icons"
  "https://selfh.st/icons"
)

# 打印帮助
print_help() {
  cat << EOF
${BLUE}1Panel App Builder${NC} - 快速生成 1Panel 应用配置

${YELLOW}用法:${NC}
  $0 <输入源> [输出目录]

${YELLOW}输入源支持:${NC}
  1. GitHub 项目链接
     例如: https://github.com/alist-org/alist

  2. docker-compose.yml 文件链接
     例如: https://raw.githubusercontent.com/alist-org/alist/master/docker-compose.yml

  3. docker run 命令
     例如: "docker run -d --name=alist -p 5244:5244 xhofe/alist:v3.45.0"

  4. 本地文件路径
     例如: ./myapp/docker-compose.yml

${YELLOW}输出:${NC}
  在指定目录（默认 ./apps）下生成:
  <app-name>/<version>/
  ├── data.yml          # 应用元数据
  ├── docker-compose.yml # 编排文件
  ├── logo.png          # 应用图标
  ├── README.md         # 中文简介
  └── README_en.md      # 英文简介

${YELLOW}示例:${NC}
  $0 https://github.com/alist-org/alist
  $0 ./my-docker-compose.yml ./my-apps
  $0 "docker run -d --name nginx -p 80:80 nginx:latest"
EOF
}

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测输入类型
detect_input_type() {
  local input="$1"

  # GitHub 项目链接
  if [[ "$input" =~ ^https?://github\.com/[^/]+/[^/]+ ]]; then
    echo "github"
    return 0
  fi

  # docker-compose 文件链接
  if [[ "$input" =~ ^https?://.*\.ya?ml$ ]] || [[ "$input" =~ docker-compose ]]; then
    echo "compose_url"
    return 0
  fi

  # docker run 命令
  if [[ "$input" =~ ^docker\ run ]] || [[ "$input" =~ ^docker\ run$ ]]; then
    echo "docker_run"
    return 0
  fi

  # 本地文件
  if [[ -f "$input" ]]; then
    if [[ "$input" =~ \.ya?ml$ ]]; then
      echo "compose_file"
      return 0
    fi
  fi

  echo "unknown"
}

# 从 GitHub 项目提取信息
extract_from_github() {
  local github_url="$1"
  local api_url temp_dir

  log_info "正在从 GitHub 项目提取信息: $github_url"

  # 转换为 API URL
  # https://github.com/owner/repo -> https://api.github.com/repos/owner/repo
  api_url="${github_url/github\.com/api.github.com\/repos}"

  # 获取项目信息
  local repo_info
  repo_info=$(curl -s "$api_url" 2>/dev/null || echo "{}")

  # 提取字段
  APP_NAME=$(echo "$repo_info" | jq -r '.name // empty')
  APP_KEY=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
  DESCRIPTION=$(echo "$repo_info" | jq -r '.description // empty')
  GITHUB="$github_url"
  WEBSITE=$(echo "$repo_info" | jq -r '.homepage // empty')
  if [[ -z "$WEBSITE" ]]; then
    WEBSITE="$github_url"
  fi

  # 尝试查找 docker-compose.yml
  local owner_repo
  owner_repo=$(echo "$github_url" | sed -E 's|https?://github.com/||')
  COMPOSE_URL="https://raw.githubusercontent.com/${owner_repo}/main/docker-compose.yml"

  log_info "应用名称: $APP_NAME"
  log_info "描述: $DESCRIPTION"
}

# 从 docker-compose 提取信息
extract_from_compose() {
  local compose_content="$1"

  log_info "正在解析 docker-compose 内容"

  # 提取服务名
  SERVICE_NAME=$(echo "$compose_content" | yq '.services | keys | .[0]' 2>/dev/null || echo "")

  # 提取镜像
  local image
  image=$(echo "$compose_content" | yq ".services.${SERVICE_NAME}.image" 2>/dev/null || echo "")

  # 解析镜像名和标签
  if [[ "$image" =~ ^([^:]+):(.+)$ ]]; then
    IMAGE="${BASH_REMATCH[1]}"
    TAG="${BASH_REMATCH[2]}"
  else
    IMAGE="$image"
    TAG="latest"
  fi

  # 提取端口
  PORT=$(echo "$compose_content" | yq ".services.${SERVICE_NAME}.ports[0]" 2>/dev/null | grep -oE '[0-9]+$' || echo "8080")

  log_info "服务名: $SERVICE_NAME"
  log_info "镜像: $IMAGE:$TAG"
  log_info "端口: $PORT"
}

# 从 docker run 命令提取信息
extract_from_docker_run() {
  local cmd="$1"

  log_info "正在解析 docker run 命令"

  # 提取镜像
  IMAGE=$(echo "$cmd" | grep -oE '[^ ]+:[^ ]+$' | cut -d':' -f1 || echo "")
  TAG=$(echo "$cmd" | grep -oE '[^ ]+:[^ ]+$' | cut -d':' -f2 || echo "latest")

  # 提取容器名
  SERVICE_NAME=$(echo "$cmd" | grep -oE '\-\-name[= ]+[^ ]+' | awk '{print $NF}' || echo "app")

  # 提取端口
  PORT=$(echo "$cmd" | grep -oE '\-p[= ]+[0-9]+:[0-9]+' | grep -oE '[0-9]+$' || echo "8080")

  APP_NAME="$SERVICE_NAME"
  APP_KEY=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')

  log_info "应用名称: $APP_NAME"
  log_info "镜像: $IMAGE:$TAG"
  log_info "端口: $PORT"
}

# 生成 data.yml
generate_data_yml() {
  local output_file="$1"

  log_info "生成 data.yml: $output_file"

  cat > "$output_file" << EOF
name: ${APP_NAME:-MyApp}
tags:
    - 实用工具
    - 容器
title: ${APP_NAME:-MyApp} - 容器应用
description: ${DESCRIPTION:-自动生成的应用配置}
additionalProperties:
    key: ${APP_KEY:-myapp}
    name: ${APP_NAME:-MyApp}
    tags:
        - Tool
        - Container
    shortDescZh: ${DESCRIPTION:-自动生成的应用配置}
    shortDescEn: ${DESCRIPTION:-Auto-generated application configuration}
    description:
        en: ${DESCRIPTION:-Auto-generated application configuration}
        ja: ${DESCRIPTION:-Auto-generated application configuration}
        ms: ${DESCRIPTION:-Auto-generated application configuration}
        pt-br: ${DESCRIPTION:-Auto-generated application configuration}
        ru: ${DESCRIPTION:-Auto-generated application configuration}
        ko: ${DESCRIPTION:-Auto-generated application configuration}
        zh-Hant: ${DESCRIPTION:-Auto-generated application configuration}
        zh: ${DESCRIPTION:-自动生成的应用配置}
    type: website
    crossVersionUpdate: true
    limit: 0
    recommend: 50
    website: ${WEBSITE:-https://example.com}
    github: ${GITHUB:-https://github.com}
    document: ${GITHUB:-https://github.com}
    architectures:
      - amd64
      - arm64
EOF
}

# 生成 docker-compose.yml
generate_docker_compose() {
  local output_file="$1"

  log_info "生成 docker-compose.yml: $output_file"

  cat > "$output_file" << EOF
services:
  ${SERVICE_NAME:-app}:
    container_name: \${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "\${PANEL_APP_PORT_HTTP}:${PORT:-8080}"
    volumes:
      - ./data/data:/app/data
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    image: ${IMAGE:-app}:${TAG:-latest}
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
EOF
}

# 生成 README
generate_readme() {
  local output_dir="$1"

  log_info "生成 README 文件"

  cat > "${output_dir}/README.md" << EOF
# ${APP_NAME:-MyApp}

## 简介

${DESCRIPTION:-这是一个自动生成的应用配置。}

## 使用说明

1. 在 1Panel 应用商店中安装此应用
2. 配置相关参数
3. 启动应用

## 更多信息

- 官网: ${WEBSITE:-https://example.com}
- GitHub: ${GITHUB:-https://github.com}
- 文档: ${GITHUB:-https://github.com}
EOF

  cat > "${output_dir}/README_en.md" << EOF
# ${APP_NAME:-MyApp}

## Introduction

${DESCRIPTION:-This is an auto-generated application configuration.}

## Usage

1. Install this app from 1Panel App Store
2. Configure parameters
3. Start the application

## More Information

- Website: ${WEBSITE:-https://example.com}
- GitHub: ${GITHUB:-https://github.com}
- Documentation: ${GITHUB:-https://github.com}
EOF
}

# 下载图标
download_icon() {
  local app_name="$1"
  local output_file="$2"
  local icon_name

  icon_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

  log_info "尝试下载图标: $app_name"

  # 尝试各个图标源
  for source in "${ICON_SOURCES[@]}"; do
    local icon_url="${source}/${icon_name}.png"
    if curl -sSL -o "$output_file" "$icon_url" 2>/dev/null && [[ -s "$output_file" ]]; then
      log_info "图标下载成功: $icon_url"
      return 0
    fi
  done

  log_warn "未找到图标，使用占位符"
  # 创建简单的占位图标（1x1 像素 PNG）
  echo -n "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > "$output_file"
}

# 主函数
main() {
  local input="$1"
  local input_type

  # 参数检查
  if [[ -z "$input" ]] || [[ "$input" == "-h" ]] || [[ "$input" == "--help" ]]; then
    print_help
    exit 0
  fi

  log_info "开始处理: $input"

  # 检测输入类型
  input_type=$(detect_input_type "$input")
  log_info "检测到输入类型: $input_type"

  # 根据类型提取信息
  case "$input_type" in
    github)
      extract_from_github "$input"
      COMPOSE_CONTENT=$(curl -s "$COMPOSE_URL" 2>/dev/null || echo "")
      if [[ -n "$COMPOSE_CONTENT" ]]; then
        extract_from_compose "$COMPOSE_CONTENT"
      fi
      ;;
    compose_url)
      COMPOSE_CONTENT=$(curl -s "$input" 2>/dev/null)
      extract_from_compose "$COMPOSE_CONTENT"
      APP_NAME="$SERVICE_NAME"
      APP_KEY=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')
      ;;
    compose_file)
      COMPOSE_CONTENT=$(cat "$input")
      extract_from_compose "$COMPOSE_CONTENT"
      APP_NAME="$SERVICE_NAME"
      APP_KEY=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')
      ;;
    docker_run)
      extract_from_docker_run "$input"
      ;;
    *)
      log_error "无法识别的输入类型: $input"
      exit 1
      ;;
  esac

  # 创建输出目录
  local output_dir="${OUTPUT_BASE}/${APP_KEY}/${TAG:-latest}"
  mkdir -p "$output_dir"

  log_info "输出目录: $output_dir"

  # 生成文件
  generate_data_yml "${output_dir}/data.yml"
  generate_docker_compose "${output_dir}/docker-compose.yml"
  generate_readme "$output_dir"
  download_icon "$APP_NAME" "${output_dir}/logo.png"

  # 生成上级目录的 data.yml
  generate_data_yml "${OUTPUT_BASE}/${APP_KEY}/data.yml"
  cp "${output_dir}/logo.png" "${OUTPUT_BASE}/${APP_KEY}/logo.png" 2>/dev/null || true
  cp "${output_dir}/README.md" "${OUTPUT_BASE}/${APP_KEY}/README.md" 2>/dev/null || true
  cp "${output_dir}/README_en.md" "${OUTPUT_BASE}/${APP_KEY}/README_en.md" 2>/dev/null || true

  # 输出结果
  echo ""
  log_info "${GREEN}✓ 生成完成！${NC}"
  echo ""
  echo "目录结构:"
  tree "${OUTPUT_BASE}/${APP_KEY}" 2>/dev/null || find "${OUTPUT_BASE}/${APP_KEY}" -type f
  echo ""
  log_info "下一步："
  echo "  1. 检查生成的配置文件"
  echo "  2. 补充完善应用描述和标签"
  echo "  3. 替换 logo.png 为合适的应用图标"
  echo "  4. 测试 docker-compose.yml"
  echo "  5. 提交到应用商店仓库"
}

# 执行主函数
main "$@"
