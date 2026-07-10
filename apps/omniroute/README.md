# OmniRoute

OmniRoute 是一个免费、开源的 AI 网关，将 Claude Code、Codex、Cursor、Cline、Copilot 等工具接入 237 个 AI 提供商（其中 90+ 提供免费层级）。支持自动故障转移、17 种路由策略、RTK + Caveman 压缩（可节省 15-95% token），兼容 OpenAI、Claude、Gemini、Codex API，并内置 MCP 与 A2A 服务。

## 使用说明

- 安装后通过 `http://服务器地址:仪表盘端口` 访问控制面板，默认端口为 `20128`。
- API 地址为 `http://服务器地址:API 端口/v1`，默认端口为 `20129`。
- 首次安装请务必在表单中设置 `初始管理员密码`；未设置时默认为 `CHANGEME`，登录后请在「设置 → 安全」中修改。
- `JWT 密钥` 与 `API Key 加密密钥` 留空时，应用会在首次启动时自动生成并持久化到 `data/` 目录，无需手动填写；如需固定密钥可自行填入。
- 数据（SQLite 数据库、配置、备份）持久化到应用版本目录下的 `data/` 中，容器重建后不会丢失。
- 默认使用内置内存限流器；如需更高并发，可在应用内配置 Redis（高级用法，本应用包未包含）。

## 配置参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `20128` | 仪表盘端口 |
| `PANEL_APP_PORT_API` | `20129` | API 端口 |
| `INITIAL_PASSWORD` | - | 初始管理员登录密码 |
| `JWT_SECRET` | 自动生成 | 仪表盘会话 JWT 签名密钥 |
| `API_KEY_SECRET` | 自动生成 | API Key 数据库加密密钥 |
| `REQUIRE_API_KEY` | `false` | 是否对所有请求强制校验 API Key |

## 官方资源

- 官网：https://omniroute.online
- 项目仓库：https://github.com/diegosouzapw/OmniRoute
- Docker 镜像：https://hub.docker.com/r/diegosouzapw/omniroute
