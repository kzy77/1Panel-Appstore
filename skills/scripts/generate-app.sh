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

# 解析镜像引用（支持 registry/namespace/repo:tag）
parse_image_ref() {
  local image_ref="$1"
  local image_no_tag tag

  # 去掉 digest
  image_ref="${image_ref%%@*}"

  if [[ "$image_ref" =~ ^(.+):([^/:]+)$ ]]; then
    image_no_tag="${BASH_REMATCH[1]}"
    tag="${BASH_REMATCH[2]}"
  else
    image_no_tag="$image_ref"
    tag="latest"
  fi

  local first_segment="${image_no_tag%%/*}"
  if [[ "$image_no_tag" == */* ]] && ([[ "$first_segment" == *.* ]] || [[ "$first_segment" == *:* ]] || [[ "$first_segment" == "localhost" ]]); then
    REGISTRY="$first_segment"
    IMAGE_PATH="${image_no_tag#*/}"
  else
    REGISTRY="docker.io"
    IMAGE_PATH="$image_no_tag"
  fi

  if [[ "$IMAGE_PATH" == */* ]]; then
    NAMESPACE="${IMAGE_PATH%%/*}"
    REPO_PATH="${IMAGE_PATH#*/}"
  else
    NAMESPACE="library"
    REPO_PATH="$IMAGE_PATH"
  fi

  IMAGE_BASE="$image_no_tag"
  TAG="$tag"
}

# 获取 Docker Hub 最新版本号
get_latest_tag_docker_hub() {
  local namespace="$1"
  local repo_path="$2"
  local url="https://hub.docker.com/v2/repositories/${namespace}/${repo_path}/tags?page_size=100&ordering=last_updated"
  local tags
  tags=$(curl -s "$url" | jq -r '.results[].name' 2>/dev/null || true)

  local semver
  semver=$(echo "$tags" | grep -E '^[vV]?[0-9]+\\.[0-9]+(\\.[0-9]+)?$' | head -n1 || true)
  if [[ -n "$semver" ]]; then
    echo "$semver"
    return 0
  fi

  local nonlatest
  nonlatest=$(echo "$tags" | grep -v '^latest$' | head -n1 || true)
  echo "${nonlatest:-latest}"
}

# 获取 GHCR 最新版本号
get_latest_tag_ghcr() {
  local namespace="$1"
  local repo_path="$2"
  local token tags

  token=$(curl -s "https://ghcr.io/token?service=ghcr.io&scope=repository:${namespace}/${repo_path}:pull" | jq -r '.token' 2>/dev/null || true)
  if [[ -z "$token" || "$token" == "null" ]]; then
    echo "latest"
    return 0
  fi

  tags=$(curl -s -H "Authorization: Bearer ${token}" "https://ghcr.io/v2/${namespace}/${repo_path}/tags/list" | jq -r '.tags[]' 2>/dev/null || true)

  local semver
  semver=$(echo "$tags" | grep -E '^[vV]?[0-9]+\\.[0-9]+(\\.[0-9]+)?$' | sort -V | tail -n1 || true)
  if [[ -n "$semver" ]]; then
    echo "$semver"
    return 0
  fi

  local nonlatest
  nonlatest=$(echo "$tags" | grep -v '^latest$' | sort -V | tail -n1 || true)
  echo "${nonlatest:-latest}"
}

# 统一获取最新版本号
get_latest_tag() {
  if [[ "$REGISTRY" == "ghcr.io" ]]; then
    get_latest_tag_ghcr "$NAMESPACE" "$REPO_PATH"
    return 0
  fi

  # 默认走 Docker Hub
  get_latest_tag_docker_hub "$NAMESPACE" "$REPO_PATH"
}

# 解析端口映射条目为 host:container
parse_port_entry() {
  local entry="$1"
  entry="${entry%\"}"
  entry="${entry#\"}"
  if [[ "$entry" == */* ]]; then
    entry="${entry%/*}"
  fi
  IFS=':' read -r -a parts <<< "$entry"
  local host_port container_port
  if [[ ${#parts[@]} -eq 1 ]]; then
    host_port="${parts[0]}"
    container_port="${parts[0]}"
  elif [[ ${#parts[@]} -eq 2 ]]; then
    host_port="${parts[0]}"
    container_port="${parts[1]}"
  else
    host_port="${parts[-2]}"
    container_port="${parts[-1]}"
  fi
  echo "${host_port}:${container_port}"
}

# 根据端口号选择 1Panel 常用 envKey
map_port_envkey() {
  local port="$1"
  local index="$2"
  case "$port" in
    80|8080|3000|5173|8000|5000)
      echo "PANEL_APP_PORT_HTTP"
      ;;
    443|8443)
      echo "PANEL_APP_PORT_HTTPS"
      ;;
    22)
      echo "PANEL_APP_PORT_SSH"
      ;;
    3306|5432|27017|6379)
      echo "PANEL_APP_PORT_DB"
      ;;
    9000|9001|8081|7001)
      echo "PANEL_APP_PORT_API"
      ;;
    *)
      if [[ "$index" -eq 0 ]]; then
        echo "PANEL_APP_PORT_HTTP"
      else
        echo "PANEL_APP_PORT_API"
      fi
      ;;
  esac
}

# envKey 对应标签
labels_for_envkey() {
  local envkey="$1"
  case "$envkey" in
    PANEL_APP_PORT_HTTP) echo "Web Port|Web端口" ;;
    PANEL_APP_PORT_HTTPS) echo "HTTPS Port|HTTPS端口" ;;
    PANEL_APP_PORT_API) echo "API Port|API端口" ;;
    PANEL_APP_PORT_ADMIN) echo "Admin Port|管理端口" ;;
    PANEL_APP_PORT_PROXY) echo "Proxy Port|代理端口" ;;
    PANEL_APP_PORT_DB) echo "DB Port|数据库端口" ;;
    PANEL_APP_PORT_SSH) echo "SSH Port|SSH端口" ;;
    PANEL_APP_PORT_S3) echo "S3 Port|S3端口" ;;
    PANEL_APP_PORT_PROXY_HTTP) echo "Proxy HTTP Port|代理HTTP端口" ;;
    PANEL_APP_PORT_PROXY_HTTPS) echo "Proxy HTTPS Port|代理HTTPS端口" ;;
    PANEL_APP_PORT_SYNC) echo "Sync Port|同步端口" ;;
    *) echo "Port|端口" ;;
  esac
}
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
  parse_image_ref "$image"

  # 提取端口
  PORT_ENTRIES=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "null" ]] && continue
    PORT_ENTRIES+=("$line")
  done < <(echo "$compose_content" | yq ".services.${SERVICE_NAME}.ports[]" 2>/dev/null || true)

  if [[ ${#PORT_ENTRIES[@]} -eq 0 ]]; then
    PORT_ENTRIES=("8080")
  fi

  log_info "服务名: $SERVICE_NAME"
  log_info "镜像: $IMAGE_BASE:$TAG"
  log_info "端口数量: ${#PORT_ENTRIES[@]}"
}

# 从 docker run 命令提取信息
extract_from_docker_run() {
  local cmd="$1"

  log_info "正在解析 docker run 命令"

  # 提取镜像
  local image_ref
  image_ref=$(echo "$cmd" | awk '{print $NF}')
  parse_image_ref "$image_ref"

  # 提取容器名
  SERVICE_NAME=$(echo "$cmd" | grep -oE '\-\-name[= ]+[^ ]+' | awk '{print $NF}' || echo "app")

  # 提取端口
  PORT_ENTRIES=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    PORT_ENTRIES+=("$line")
  done < <(echo "$cmd" | grep -oE '\-p[= ]+[^ ]+' | awk '{print $NF}' || true)

  if [[ ${#PORT_ENTRIES[@]} -eq 0 ]]; then
    PORT_ENTRIES=("8080")
  fi

  APP_NAME="$SERVICE_NAME"
  APP_KEY=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')

  log_info "应用名称: $APP_NAME"
  log_info "镜像: $IMAGE_BASE:$TAG"
  log_info "端口数量: ${#PORT_ENTRIES[@]}"
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

# 生成 version/data.yml（参数定义）
generate_version_data_yml() {
  local output_file="$1"

  log_info "生成版本 data.yml: $output_file"

  cat > "$output_file" << EOF
additionalProperties:
  formFields:
EOF

  local i
  for ((i=0; i<${#CONTAINER_PORTS[@]}; i++)); do
    local envkey="${PORT_ENV_KEYS[$i]}"
    local default_port="${HOST_PORTS[$i]}"
    local labels
    labels=$(labels_for_envkey "$envkey")
    local label_en="${labels%%|*}"
    local label_zh="${labels##*|}"
    cat >> "$output_file" << EOF
    - default: ${default_port}
      edit: true
      envKey: ${envkey}
      labelEn: ${label_en}
      labelZh: ${label_zh}
      required: true
      rule: paramPort
      type: number
      label:
        en: ${label_en}
        zh: ${label_zh}
EOF
  done
}

# 生成 docker-compose.yml
generate_docker_compose() {
  local output_file="$1"
  local image_tag="$2"

  log_info "生成 docker-compose.yml: $output_file"

  cat > "$output_file" << EOF
services:
  ${SERVICE_NAME:-app}:
    container_name: \${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
EOF

  local i
  for ((i=0; i<${#CONTAINER_PORTS[@]}; i++)); do
    cat >> "$output_file" << EOF
      - "\${${PORT_ENV_KEYS[$i]}}:${CONTAINER_PORTS[$i]}"
EOF
  done

  cat >> "$output_file" << EOF
    volumes:
      - ./data/data:/app/data
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    image: ${IMAGE_BASE:-app}:${image_tag}
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
  local github_url="${3:-}"
  local icon_name

  icon_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

  log_info "尝试获取图标: $app_name"

  # 优先从 GitHub 仓库内查找常见图标文件
  if [[ -n "$github_url" ]]; then
    local owner_repo repo_api candidate_paths
    owner_repo=$(echo "$github_url" | sed -E 's|https?://github.com/||')
    repo_api="https://api.github.com/repos/${owner_repo}"
    candidate_paths=(
      "logo.png"
      "icon.png"
      "logo.svg"
      "icon.svg"
      "assets/logo.png"
      "assets/icon.png"
      ".github/logo.png"
      ".github/icon.png"
    )

    for path in "${candidate_paths[@]}"; do
      local file_api="${repo_api}/contents/${path}"
      local download_url
      download_url=$(curl -s "$file_api" | jq -r '.download_url // empty' 2>/dev/null || true)
      if [[ -n "$download_url" ]]; then
        if curl -sSL -o "$output_file" "$download_url" 2>/dev/null && [[ -s "$output_file" ]]; then
          log_info "图标来自仓库: ${path}"
          return 0
        fi
      fi
    done
  fi

  # 尝试各个图标源
  for source in "${ICON_SOURCES[@]}"; do
    local icon_url="${source}/${icon_name}.png"
    if curl -sSL -o "$output_file" "$icon_url" 2>/dev/null && [[ -s "$output_file" ]]; then
      log_info "图标下载成功: $icon_url"
      return 0
    fi
  done

  log_warn "未找到图标，请手动补充 logo.png"
  return 1
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

  # 生成端口映射数组
  HOST_PORTS=()
  CONTAINER_PORTS=()
  PORT_ENV_KEYS=()
  PORT_ENV_KEYS_USED=()
  local i
  for ((i=0; i<${#PORT_ENTRIES[@]}; i++)); do
    local mapping
    mapping=$(parse_port_entry "${PORT_ENTRIES[$i]}")
    local host_port="${mapping%%:*}"
    local container_port="${mapping##*:}"
    HOST_PORTS+=("$host_port")
    CONTAINER_PORTS+=("$container_port")
    local envkey
    envkey=$(map_port_envkey "$container_port" "$i")
    # 保证 envKey 唯一
    if [[ " ${PORT_ENV_KEYS_USED[*]} " == *" ${envkey} "* ]]; then
      envkey="${envkey}_${i}"
    fi
    PORT_ENV_KEYS+=("$envkey")
    PORT_ENV_KEYS_USED+=("$envkey")
  done

  # 获取最新版本号
  VERSION_TAG=$(get_latest_tag)
  if [[ -z "$VERSION_TAG" ]]; then
    VERSION_TAG="$TAG"
  fi
  if [[ -z "$VERSION_TAG" ]]; then
    VERSION_TAG="latest"
  fi

  # 创建输出目录（latest + 具体版本）
  local output_dir_latest="${OUTPUT_BASE}/${APP_KEY}/latest"
  mkdir -p "$output_dir_latest"

  local output_dir_version=""
  if [[ "$VERSION_TAG" != "latest" ]]; then
    output_dir_version="${OUTPUT_BASE}/${APP_KEY}/${VERSION_TAG}"
    mkdir -p "$output_dir_version"
  else
    log_warn "未能获取具体版本号，version 目录将使用 latest（请手动修正）"
  fi

  log_info "输出目录: $output_dir_latest"
  if [[ -n "$output_dir_version" ]]; then
    log_info "输出目录: $output_dir_version"
  fi

  # 生成 latest 版本文件
  generate_version_data_yml "${output_dir_latest}/data.yml"
  generate_docker_compose "${output_dir_latest}/docker-compose.yml" "latest"

  # 生成具体版本文件
  if [[ -n "$output_dir_version" ]]; then
    generate_version_data_yml "${output_dir_version}/data.yml"
    generate_docker_compose "${output_dir_version}/docker-compose.yml" "$VERSION_TAG"
  fi

  generate_readme "${OUTPUT_BASE}/${APP_KEY}"
  download_icon "$APP_NAME" "${OUTPUT_BASE}/${APP_KEY}/logo.png" "${GITHUB:-}"

  # 生成上级目录的 data.yml
  generate_data_yml "${OUTPUT_BASE}/${APP_KEY}/data.yml"
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
