# 1Panel App Builder

快速生成符合 1Panel 本地应用商店规范的 APP 配置文件。

## 功能特性

- ✅ 支持多种输入源（GitHub、docker-compose、docker run、本地文件）
- ✅ 自动抽取应用信息并生成标准化配置
- ✅ 自动下载应用图标（支持多个图标源）
- ✅ 生成中英文 README
- ✅ 符合 1Panel 应用商店规范

## 目录结构

```
1panel-app-builder/
├── SKILL.md              # 技能定义文件
├── README.md             # 使用文档
├── templates/            # 配置模板
│   ├── data.yml.tpl      # 应用元数据模板
│   └── docker-compose.yml.tpl # 编排文件模板
├── scripts/              # 工具脚本
│   ├── generate-app.sh   # 主生成脚本
│   └── download-icon.sh  # 图标下载工具
└── examples/             # 使用示例
    └── example-usage.md
```

## 快速开始

### 1. 基本用法

```bash
# GitHub 项目
./scripts/generate-app.sh https://github.com/alist-org/alist

# docker-compose 文件链接
./scripts/generate-app.sh https://raw.githubusercontent.com/.../docker-compose.yml

# docker run 命令
./scripts/generate-app.sh "docker run -d --name=alist -p 5244:5244 xhofe/alist:v3.45.0"

# 本地文件
./scripts/generate-app.sh ./my-docker-compose.yml
```

### 2. 输出示例

```
./apps/alist/v3.45.0/
├── data.yml          # 应用元数据
├── docker-compose.yml # 编排文件
├── logo.png          # 应用图标
├── README.md         # 中文简介
└── README_en.md      # 英文简介
```

### 3. 生成的配置文件

#### data.yml 示例

```yaml
name: AList
tags:
    - 实用工具
    - 云存储
title: 支持多存储的文件列表程序和私人网盘
description: 支持多存储的文件列表程序和私人网盘
additionalProperties:
    key: alist
    name: AList
    tags:
        - Storage
        - Tool
    shortDescZh: 支持多存储的文件列表程序和私人网盘
    shortDescEn: Supporting multi-storage file listing program
    website: https://alist.nn.ci/
    github: https://github.com/alist-org/alist
    architectures:
      - amd64
      - arm64
```

#### docker-compose.yml 示例

```yaml
services:
  alist:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "${PANEL_APP_PORT_HTTP}:5244"
    volumes:
      - ./data/data:/opt/alist/data
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    image: xhofe/alist:v3.45.0
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
```

## 高级用法

### 指定输出目录

```bash
./scripts/generate-app.sh https://github.com/alist-org/alist ./my-apps
```

### 单独下载图标

```bash
./scripts/download-icon.sh alist ./logo.png 200
```

### 图标源优先级

1. [Dashboard Icons](https://dashboardicons.com/icons)
2. [Simple Icons](https://simpleicons.org/)
3. [selfh.st Icons](https://selfh.st/icons/)

## 依赖工具

必需：
- `bash` - 脚本执行环境
- `curl` - HTTP 请求
- `jq` - JSON 解析
- `yq` - YAML 解析（可选，用于高级解析）

可选：
- `ImageMagick` (convert) - 图标尺寸调整
- `sips` (macOS) - 图标尺寸调整
- `tree` - 目录树显示

## 配置模板说明

### data.yml 模板变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `${APP_NAME}` | 应用名称 | AList |
| `${APP_KEY}` | 应用键名 | alist |
| `${TITLE_ZH}` | 中文标题 | 文件列表程序 |
| `${DESC_ZH}` | 中文描述 | 支持多存储... |
| `${TAG_1}` | 标签1 | 实用工具 |
| `${WEBSITE}` | 官网 | https://alist.nn.ci/ |
| `${GITHUB}` | GitHub | https://github.com/alist-org/alist |

### docker-compose.yml 模板变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `${SERVICE_NAME}` | 服务名 | alist |
| `${IMAGE}` | 镜像名 | xhofe/alist |
| `${TAG}` | 镜像标签 | v3.45.0 |
| `${PORT}` | 端口 | 5244 |

## 下一步操作

生成配置后：

1. ✅ 检查 `data.yml` 中的应用信息是否准确
2. ✅ 补充完善应用描述和标签
3. ✅ 替换 `logo.png` 为合适的应用图标
4. ✅ 测试 `docker-compose.yml` 是否正常工作
5. ✅ 提交到 1Panel 应用商店仓库

## 常见问题

### Q: 图标下载失败怎么办？

A: 手动从以下网站下载图标：
- https://dashboardicons.com/icons?q=<应用名>
- https://simpleicons.org/?q=<应用名>
- https://selfh.st/icons/

### Q: 如何处理多服务应用？

A: 生成后手动编辑 `docker-compose.yml`，添加其他服务。

### Q: 版本号如何确定？

A: 默认从镜像标签提取，也可手动指定。

## 参考资源

- [1Panel 官方文档](https://1panel.cn/docs/)
- [1Panel 应用商店仓库](https://github.com/1Panel-dev/appstore)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 许可证

MIT License
