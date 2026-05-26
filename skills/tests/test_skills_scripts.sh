#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_not_file() {
  [[ ! -f "$1" ]] || fail "expected missing file: $1"
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -qE -- "$pattern" "$file" || fail "expected pattern '$pattern' in $file"
}

run_test() {
  local name="$1"
  shift
  echo "== $name =="
  "$@"
}

test_download_icon_skip_mode_does_not_create_logo() {
  local out="$TMP_DIR/skip/logo.png"

  bash "$ROOT_DIR/skills/scripts/download-icon.sh" --mode skip demo-app "$out" >/tmp/download_icon_skip.out

  assert_not_file "$out"
  assert_contains /tmp/download_icon_skip.out "跳过图标下载"
}

test_download_icon_cache_only_uses_cached_logo() {
  local cache_dir="$TMP_DIR/icon-cache"
  local out="$TMP_DIR/cache/logo.png"
  mkdir -p "$cache_dir"
  printf 'cached-logo' > "$cache_dir/demo-app.png"

  bash "$ROOT_DIR/skills/scripts/download-icon.sh" --mode cache-only --cache-dir "$cache_dir" demo-app "$out" >/tmp/download_icon_cache.out

  assert_file "$out"
  cmp "$cache_dir/demo-app.png" "$out" || fail "cached logo was not copied"
}

test_generate_app_accepts_explicit_options_and_skips_icon() {
  local compose="$TMP_DIR/compose.yml"
  local output="$TMP_DIR/generated"
  cat > "$compose" <<'YAML'
services:
  demo:
    image: nginx:1.25.3
    ports:
      - "18080:80"
YAML

  bash "$ROOT_DIR/skills/scripts/generate-app.sh" \
    --app-key demo-app \
    --name DemoApp \
    --version 1.25.3 \
    --output "$output" \
    --icon-mode skip \
    "$compose" >/tmp/generate_app_options.out

  assert_file "$output/demo-app/latest/docker-compose.yml"
  assert_file "$output/demo-app/1.25.3/docker-compose.yml"
  assert_contains "$output/demo-app/data.yml" "^name: DemoApp$"
  assert_contains "$output/demo-app/latest/docker-compose.yml" "image: nginx:latest"
  assert_contains "$output/demo-app/1.25.3/docker-compose.yml" "image: nginx:1.25.3"
  assert_not_file "$output/demo-app/logo.png"
}

test_generate_app_preserves_compose_environment_and_volumes() {
  local compose="$TMP_DIR/compose-preserve.yml"
  local output="$TMP_DIR/generated-preserve"
  cat > "$compose" <<'YAML'
services:
  demo:
    image: nginx:1.25.3
    ports:
      - "18080:80"
    volumes:
      - ./data/nginx:/etc/nginx/conf.d
    environment:
      - TZ=Asia/Shanghai
      - DEMO_FLAG=true
YAML

  bash "$ROOT_DIR/skills/scripts/generate-app.sh" \
    --app-key demo-preserve \
    --name DemoPreserve \
    --version 1.25.3 \
    --output "$output" \
    --icon-mode skip \
    "$compose" >/tmp/generate_app_preserve.out

  assert_contains "$output/demo-preserve/1.25.3/docker-compose.yml" "./data/nginx:/etc/nginx/conf.d"
  assert_contains "$output/demo-preserve/1.25.3/docker-compose.yml" "TZ=Asia/Shanghai"
  assert_contains "$output/demo-preserve/1.25.3/docker-compose.yml" "DEMO_FLAG=true"
}

test_validate_app_rejects_undefined_port_variable() {
  local app="$TMP_DIR/bad-port/apps/demo-app"
  mkdir -p "$app/1.0.0"
  printf 'png' > "$app/logo.png"
  cat > "$app/data.yml" <<'YAML'
name: DemoApp
tags:
    - 实用工具
title: Demo
description: Demo
additionalProperties:
    key: demo-app
    name: DemoApp
    architectures:
      - amd64
YAML
  cat > "$app/1.0.0/data.yml" <<'YAML'
additionalProperties:
  formFields:
    - default: 8080
      edit: true
      envKey: PANEL_APP_PORT_HTTP
      labelEn: Web Port
      labelZh: Web端口
      required: true
      rule: paramPort
      type: number
YAML
  cat > "$app/1.0.0/docker-compose.yml" <<'YAML'
services:
  demo:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "${PANEL_APP_PORT_ADMIN}:80"
    image: nginx:1.0.0
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
YAML

  if bash "$ROOT_DIR/skills/scripts/validate-app.sh" "$app" >/tmp/validate_bad_port.out 2>&1; then
    fail "validator should reject undefined port variable"
  fi
  assert_contains /tmp/validate_bad_port.out "未在版本 data.yml 中定义"
}

test_validate_app_rejects_latest_wrong_tag() {
  local app="$TMP_DIR/bad-latest/apps/demo-app"
  mkdir -p "$app/latest"
  printf 'png' > "$app/logo.png"
  cat > "$app/data.yml" <<'YAML'
name: DemoApp
tags:
    - 实用工具
title: Demo
description: Demo
additionalProperties:
    key: demo-app
    name: DemoApp
    architectures:
      - amd64
YAML
  cat > "$app/latest/data.yml" <<'YAML'
additionalProperties:
  formFields: []
YAML
  cat > "$app/latest/docker-compose.yml" <<'YAML'
services:
  demo:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    image: nginx:1.25.3
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
YAML

  if bash "$ROOT_DIR/skills/scripts/validate-app.sh" "$app" >/tmp/validate_bad_latest.out 2>&1; then
    fail "validator should reject latest directory with concrete tag"
  fi
  assert_contains /tmp/validate_bad_latest.out "latest 目录"
}

run_test "download icon skip mode" test_download_icon_skip_mode_does_not_create_logo
run_test "download icon cache-only mode" test_download_icon_cache_only_uses_cached_logo
run_test "generate app explicit options" test_generate_app_accepts_explicit_options_and_skips_icon
run_test "generate app preserves compose fields" test_generate_app_preserves_compose_environment_and_volumes
run_test "validate undefined port variable" test_validate_app_rejects_undefined_port_variable
run_test "validate latest image tag" test_validate_app_rejects_latest_wrong_tag

echo "All skills script tests passed."
