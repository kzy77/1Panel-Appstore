# MCP-SearXNG

通过 [SearXNG](https://docs.searxng.org) 为 AI 助手提供隐私友好的网络搜索的 [MCP 服务器](https://modelcontextprotocol.io/introduction)，支持 Claude、Cursor、Codex 等任意 MCP 客户端。本包以 **HTTP 传输模式**（MCP SDK v2 Streamable HTTP）作为常驻服务部署，客户端通过 URL 连接 `/mcp` 端点。

## 使用说明

1. **前置条件：需要一个 SearXNG 实例**。可以是本商店的 `searxng` 应用、自有实例或公共实例。实例需在 `settings.yml` 中启用 JSON 格式（`search.formats: html, json`）。
2. 安装时填写 `SearXNG 实例地址`（必填），例如 `https://searxng.example.com`；支持用分号分隔的多个可互换副本实现故障转移。
3. 在 MCP 客户端（Claude Code、Cursor 等）中新增连接，类型选 streamable-http（或 SSE），地址填：
   `http://服务器地址:服务端口/mcp`
4. 连通性自检：`curl http://服务器地址:服务端口/health` 应返回正常。

## 配置说明

| 参数 | 说明 |
|------|------|
| HTTP 服务端口 | 对外端口，默认 `8080` |
| SearXNG 实例地址 | 必填；多个实例用分号分隔 |
| 搜索响应默认格式 | `text`（格式化文本，默认）或 `json`（原始结果） |
| 默认搜索语言 | 如 `en`、`zh`、`all` |
| 安全搜索等级 | `0` 关闭 / `1` 适中 / `2` 严格 |
| 单次结果上限 | 1-20，留空用服务端默认 |
| HTML 回退 | 实例拒绝 JSON 时自动解析 HTML 结果页（仅当无法启用 JSON 时使用） |

## 安全提醒

- 该服务**默认无认证**。请仅在内网可信环境使用；若需公网暴露，建议通过反代 + 认证，或在 [CONFIGURATION.md](https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md) 中启用 `MCP_HTTP_HARDEN` 加固模式。
- 高级功能（URL 内容读取的浏览器求解、缓存、代理等）见项目 [CONFIGURATION.md](https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md)。

## 官方资源

- 项目仓库：https://github.com/ihor-sokoliuk/mcp-searxng
- Docker 镜像：https://hub.docker.com/r/isokoliuk/mcp-searxng
- 配置文档：https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md