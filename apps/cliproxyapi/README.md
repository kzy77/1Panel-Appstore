# CLIProxyAPI

CLIProxyAPI 将 Antigravity、ChatGPT Codex、Claude Code、Grok Build 等 CLI/OAuth 能力封装为兼容 OpenAI、Gemini、Claude 和 Codex 的 API 服务，便于在本地或服务器中统一接入多个 AI 客户端账号。

## 功能特性

- 兼容 OpenAI、Gemini、Claude、Codex 等 API 格式
- 支持 Claude Code、Codex、Gemini、Antigravity 等多种认证来源
- 提供 Web 管理界面和管理 API
- 支持多账号路由、负载均衡、重试和冷却策略
- 支持代理、TLS、日志、用量统计等运行配置

## 默认端口

- **Web/API 端口（8317）**：主服务端口
  - Web 管理界面：`http://localhost:8317/management.html`
  - OpenAI 兼容接口：`http://localhost:8317/v1`
- **代理端口（8085）**：CLI 代理服务端口
- **扩展端口**：1455、54545、51121、11451

## 数据目录

应用数据保存在 `./data` 目录：

- `config.yaml`：主配置文件，包含 API Keys、认证源、路由策略、代理、管理面板等配置
- `auths/`：OAuth/CLI 认证文件目录
- `logs/`：应用日志目录

## 快速配置

1. 编辑 `./data/config.yaml`
2. 在 `api-keys` 中配置访问密钥
3. 如需远程访问管理界面，设置 `remote-management.allow-remote: true` 并配置 `remote-management.secret-key`
4. 按需配置 Claude、Codex、Gemini、OpenAI 兼容等认证来源
5. 重启应用使配置生效

## 关键配置示例

```yaml
# 服务端口
port: 8317

# API Keys
api-keys:
  - 'your-api-key-1'
  - 'your-api-key-2'

# 管理界面设置
remote-management:
  allow-remote: false
  secret-key: ''
  disable-control-panel: false

# 全局代理
proxy-url: ""

# 路由策略
routing:
  strategy: "round-robin"
```

## 版本说明

- **latest**：上游最新镜像
- **v7.2.50**：当前固定版本，对应上游 Docker tag `v7.2.50`

## 相关链接

- GitHub: https://github.com/router-for-me/CLIProxyAPI
- 官方文档: https://github.com/router-for-me/CLIProxyAPI/blob/main/README_CN.md
- 问题反馈: https://github.com/router-for-me/CLIProxyAPI/issues

## 注意事项

1. 首次部署后请及时修改 `api-keys` 和管理密钥
2. 如需远程访问管理界面，请设置强密码并限制访问来源
3. 生产环境建议启用 TLS 或放在可信反向代理后
4. OAuth/CLI 认证文件会写入 `auths/`，请确保目录权限正确
5. 不要公开暴露未配置认证的管理接口
