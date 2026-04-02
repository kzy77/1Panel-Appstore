---
name: 1panel-app-builder
description: >
  Build 1Panel local app store configurations from Docker deployments. Use when:
  - User provides a GitHub project link and wants to add it to 1Panel app store
  - User has a docker-compose.yml or docker run command and needs 1Panel app format
  - User wants to create a local app for 1Panel panel
  - User mentions "1Panel app", "1Panel 应用商店", "本地应用", "app store", or similar
  
  Supports: GitHub repos, Docker Hub images, docker-compose files, docker run commands.
  Output: Complete app folder with data.yml, docker-compose.yml, logo.png, README.md
  
  Always use this skill for 1Panel app packaging - it knows the exact directory structure,
  variable naming conventions (PANEL_APP_PORT_HTTP, CONTAINER_NAME), and 1panel-network
  requirements that are easy to get wrong without guidance.
---

# 1Panel App Store Builder

Transform Docker deployments into 1Panel-compatible local app store packages.

## Understanding 1Panel App Structure

A valid 1Panel app follows this directory structure:

```
app-key/                          # App identifier (lowercase, hyphenated)
├── logo.png                      # App icon (64x64 or 128x128 recommended)
├── data.yml                      # App metadata (top-level)
├── README.md                     # Chinese documentation
├── README_en.md                  # English documentation (optional)
└── 1.0.0/                        # Version directory (semver or "latest")
    ├── data.yml                  # Parameter definitions (form fields)
    ├── docker-compose.yml        # Compose file with variable substitution
    ├── data/                     # Persistent data directory
    └── scripts/                  # Optional scripts
        └── upgrade.sh            # Upgrade script
```

## Step-by-Step Workflow

### Step 1: Gather Source Information

Based on user input type, extract Docker deployment details:

**From GitHub Link:**
1. Fetch the GitHub repository README.md
2. Look for Docker installation instructions (docker run, docker-compose)
3. Extract: image name, ports, volumes, environment variables
4. Note: project name, description, official website, supported architectures

**From docker-compose.yml:**
1. Parse all services defined
2. Extract: image versions, port mappings, volume mounts, environment variables
3. Identify the main service (typically the one with web UI)

**From docker run command:**
1. Parse flags: `-p` (ports), `-v` (volumes), `-e` (env vars), `--name`
2. Extract the image name and tag
3. Identify exposed ports and data directories

### Step 2: Resolve Latest Version (Create Version + latest)

Always create **two** version directories when possible:

- `latest/` uses image tag `latest`
- `<version>/` uses the **latest concrete tag** from the registry

**How to resolve the latest concrete tag:**

1. If the image is on **GitHub Container Registry** (`ghcr.io`), query tags from GitHub Packages (GHCR).
2. Otherwise, query **Docker Hub** tags.
3. Prefer the newest semver-like tag (e.g., `v1.2.3` or `1.2.3`). If none exist, pick the most recently updated non-`latest` tag.
4. If you cannot resolve a concrete tag, fall back to the image tag from input and warn the user.

**Rule:** The `latest/` directory must **always** use `image: ...:latest`. The `<version>/` directory must **always** use `image: ...:<version>`.

### Step 3: Generate App Key and Metadata

**App Key Rules:**
- Lowercase only
- Use hyphens for multi-word names
- Keep it short but descriptive
- Examples: `alist`, `it-tools`, `n8n-zh`, `lobe-chat-data`

**Required Metadata (top-level data.yml):**
```yaml
name: AppName                    # Display name (can have capitals)
tags:                            # Chinese tags for categorization
    - 开发工具
    - 实用工具
title: Brief Chinese description
description: Same as title
additionalProperties:
  key: app-key                   # Must match directory name
  name: AppName                  # Same as name above
  tags:                          # English tags
    - DevTool
    - Utility
  shortDescZh: Chinese description
  shortDescEn: English description
  description:
    en: Full English description
    zh: Full Chinese description
    # Add more languages if available: ja, ko, ru, pt-br, ms, zh-Hant
  type: website                  # or "runtime" for databases, "tool" for CLI tools
  crossVersionUpdate: true       # Usually true
  limit: 0                       # 0 = unlimited instances
  recommend: 0                   # 0-100, higher = more recommended
  website: https://example.com   # Official website
  github: https://github.com/org/repo
  document: https://docs.example.com
  architectures:                 # Supported CPU architectures
    - amd64
    - arm64
    # Add: arm/v7, arm/v6, s390x if supported
```

### Step 4: Define Parameters (version/data.yml)

Parameters become UI form fields in 1Panel. Define user-configurable values:

```yaml
additionalProperties:
  formFields:
    # Port parameter example
    - default: 8080
      edit: true
      envKey: PANEL_APP_PORT_HTTP     # Variable name used in docker-compose
      labelEn: Web Port
      labelZh: Web端口
      required: true
      rule: paramPort                 # Validation rule
      type: number                    # Field type
      label:                          # Multi-language labels
        en: Web Port
        zh: Web端口
        ja: Webポート
        ko: Web 포트
    
    # Text parameter example (for API keys, passwords, etc.)
    - default: ""
      edit: true
      envKey: API_KEY
      labelEn: API Key
      labelZh: API密钥
      required: false
      rule: paramCommon
      type: text
    
    # Password parameter example
    - default: "changeme"
      edit: true
      envKey: ADMIN_PASSWORD
      labelEn: Admin Password
      labelZh: 管理员密码
      required: true
      rule: paramCommon
      type: password
    
    # Select parameter example
    - default: "sqlite"
      edit: true
      envKey: DATABASE_TYPE
      labelEn: Database Type
      labelZh: 数据库类型
      required: true
      type: select
      values:
        - label: SQLite
          value: sqlite
        - label: PostgreSQL
          value: postgres
```

**Parameter Types:**
- `number`: For ports, counts
- `text`: For API keys, URLs, names
- `password`: For secrets (masked input)
- `select`: For dropdown choices
- `boolean`: For toggle switches

**Validation Rules:**
- `paramPort`: Valid port number (1-65535)
- `paramCommon`: Non-empty string
- `paramExtUrl`: Valid URL format
- Empty string: No validation

### Port envKey Naming (Use 1Panel Standard Names)

Prefer these **standard** `envKey` names (observed across apps in `apps/`):

- `PANEL_APP_PORT_HTTP` (primary Web/UI port)
- `PANEL_APP_PORT_HTTPS`
- `PANEL_APP_PORT_API`
- `PANEL_APP_PORT_ADMIN`
- `PANEL_APP_PORT_PROXY`
- `PANEL_APP_PORT_PROXY_HTTP`
- `PANEL_APP_PORT_PROXY_HTTPS`
- `PANEL_APP_PORT_DB`
- `PANEL_APP_PORT_SSH`
- `PANEL_APP_PORT_S3`
- `PANEL_APP_PORT_SYNC`

**Guideline:** Use the most semantically correct name first; only invent new suffixes if none of the standard names fit.

### Step 5: Create docker-compose.yml

Convert the original Docker deployment to use variable substitution:

```yaml
services:
  app-name:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "${PANEL_APP_PORT_HTTP}:8080"
    volumes:
      - ./data:/app/data
    environment:
      - TZ=Asia/Shanghai
    image: org/image:tag
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
```

**Critical Rules:**
1. Always use `${CONTAINER_NAME}` for container_name
2. Always use `restart: always`
3. Always connect to `1panel-network` (external network)
4. Port mapping uses `PANEL_APP_PORT_*` variables from version/data.yml
5. Volume paths use relative `./data/` for persistence
6. Add `labels: createdBy: "Apps"`
7. Keep original environment variables but use defaults

**Port Mapping Format (Important):**

Use quoted mappings like:
```
- "${PANEL_APP_PORT_HTTP}:8080"
```
and ensure the same `envKey` exists in `version/data.yml`.

### Step 6: Create README Files

**README.md (Chinese):**
```markdown
# AppName

简短描述应用的功能和特点。

## 功能特点

- 特点1
- 特点2
- 特点3

## 使用说明

### 默认端口

- Web界面: 8080

### 默认账号密码

- 用户名: admin
- 密码: changeme (请在部署后立即修改)

### 数据目录

应用数据存储在 `./data` 目录。

## 相关链接

- 官方网站: https://example.com
- GitHub: https://github.com/org/repo
- 文档: https://docs.example.com
```

**README_en.md (English, optional):**
```markdown
# AppName

Brief description of the application.

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

### Default Port

- Web UI: 8080

### Default Credentials

- Username: admin
- Password: changeme (change after deployment)

## Links

- Website: https://example.com
- GitHub: https://github.com/org/repo
```

### Step 7: Download App Icon

**Priority order:**
1. **Search the GitHub repository** for common icon files (e.g., `logo.png`, `icon.png`, `assets/logo.png`, `.github/icon.png`). Use the repo's raw download URL if found.
2. If not found, search and download the app logo from these sources (in order):

1. **Dashboard Icons**: https://dashboardicons.com/icons?q={app-name}
2. **Simple Icons**: https://simpleicons.org/?q={app-name}
3. **Selfh.st Icons**: https://selfh.st/icons/

**Do not** create a placeholder or incorrect icon. If not found, warn and leave `logo.png` for manual replacement.

### Step 8: Create Data Directory Structure

Create the `data/` directory inside the version folder:
```bash
mkdir -p app-key/version/data
```

This directory will be mounted as a volume for persistent data.

## Quality Checklist

Before delivering the app package, verify:

- [ ] App key is lowercase with hyphens only
- [ ] All required fields in top-level data.yml are present
- [ ] `latest/` and `<version>/` directories both exist (when a concrete tag is resolvable)
- [ ] `latest/` uses image tag `latest`
- [ ] `<version>/` uses the concrete latest tag from registry
- [ ] Version data.yml has proper parameter definitions (formFields)
- [ ] docker-compose.yml uses variable substitution correctly
- [ ] `1panel-network` is defined as external network
- [ ] Volume paths use relative `./data/` format
- [ ] README files are created with proper documentation
- [ ] Logo file exists (logo.png)
- [ ] Version directory follows semver; avoid only `latest`

## Common Patterns

### Database Applications
```yaml
# For apps that need a database (PostgreSQL, MySQL, etc.)
# Include database as a separate service in docker-compose
services:
  app:
    depends_on:
      - db
  db:
    image: postgres:15
    volumes:
      - ./data/db:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=appdb
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=${DB_PASSWORD}
```

### Multi-Service Applications
```yaml
# For apps with multiple services (frontend + backend, etc.)
services:
  frontend:
    image: org/frontend:tag
    ports:
      - "${PANEL_APP_PORT_HTTP}:80"
  backend:
    image: org/backend:tag
    ports:
      - "${PANEL_APP_PORT_API}:8080"
```

### Applications with Reverse Proxy
```yaml
# For apps that don't expose ports directly
services:
  app:
    # No ports section - accessed through 1Panel's reverse proxy
    expose:
      - "8080"
    networks:
      - 1panel-network
```

## Automation Scripts

Use the provided scripts for faster workflow:

### generate-app.sh - 自动生成应用配置

```bash
# GitHub 项目
./scripts/generate-app.sh https://github.com/alist-org/alist

# docker-compose 文件
./scripts/generate-app.sh ./docker-compose.yml

# docker run 命令
./scripts/generate-app.sh "docker run -d --name=nginx -p 80:80 nginx:latest"
```

### download-icon.sh - 下载应用图标

```bash
./scripts/download-icon.sh redis ./logo.png 200
```

### validate-app.sh - 验证配置完整性

```bash
./scripts/validate-app.sh ./apps/myapp
```

## Reference Files

- `references/1panel-examples.md` - 完整的真实应用配置示例（AList、NocoDB等）
- `examples/example-usage.md` - 使用示例和工作流程

## Troubleshooting

**Issue**: App won't start
- Check if ports are already in use
- Verify volume permissions
- Check container logs: `docker logs ${CONTAINER_NAME}`

**Issue**: Data not persisting
- Ensure volumes are correctly mapped to `./data/`
- Check directory permissions

**Issue**: Environment variables not working
- Verify variable names match between data.yml and docker-compose.yml
- Check default values are appropriate

**Issue**: 图标下载失败
- 从以下网站手动下载：
  - https://dashboardicons.com/icons?q={app-name}
  - https://simpleicons.org/?q={app-name}
  - https://selfh.st/icons/
