# Hermes Web UI

Hermes Agent 的全功能 Web 管理面板。管理 AI 聊天会话、监控使用量与成本、配置平台渠道、调度定时任务、浏览技能等，全部通过简洁响应式 Web 界面完成。

## 部署说明

本应用为独立的 Web UI 面板，**不包含** Hermes Agent 服务。使用前请先在 1Panel 中安装官方 [Hermes Agent](https://github.com/1Panel-dev/appstore/tree/dev/apps/hermes-agent) 应用，然后安装本应用连接到已有的 Agent。

### 安装步骤

1. 在 1Panel 应用商店安装 **Hermes Agent**（官方应用）
2. 安装本应用 **Hermes Web UI**
3. 安装时配置「Hermes Agent 网关地址」，默认为 `http://hermes-agent:8642`
4. 如果安装 Agent 时修改了容器名称，请相应调整网关地址中的主机名

### 网络要求

两个应用均使用 `1panel-network` 网络，通过 Docker 内部网络通信，无需暴露额外端口。

## 功能特点

- **AI 聊天** — 实时流式 SSE 传输，多会话管理，Markdown 渲染与代码高亮
- **平台渠道** — 统一配置 8 大平台（Telegram、Discord、Slack、WhatsApp、Matrix、飞书、微信、企业微信）
- **用量分析** — Token 使用量统计、成本追踪、模型分布图表
- **定时任务** — 创建、编辑、暂停、恢复、删除 Cron 任务
- **模型管理** — 自动发现/添加提供商，支持 OpenAI 兼容接口
- **多配置文件** — 创建、克隆、导入/导出 Hermes 配置文件
- **文件浏览器** — 浏览、上传、下载远程后端文件
- **群聊** — 多 Agent 聊天室，支持 @提及和上下文压缩
- **技能与记忆** — 浏览已安装技能，用户笔记管理
- **日志查看** — Agent/网关/错误日志过滤与查看
- **身份认证** — 基于 Token 的认证（首次运行自动生成）
- **Web 终端** — 集成终端，支持多会话

## 使用说明

### 默认端口

- Web 界面: `6060`（可在安装时修改）

### 配置参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| Web UI 端口 | `6060` | Web 管理面板的访问端口 |
| Agent 网关地址 | `http://hermes-agent:8642` | Hermes Agent 的网关地址 |

### 默认认证

- 首次运行时自动生成 Auth Token，可通过容器日志查看：
  ```bash
  docker logs <容器名> | grep token
  ```
- 也可通过环境变量 `AUTH_TOKEN` 设置自定义 Token

### 数据目录

- `./webui-data` — Web UI 数据（Auth Token 等）

### 模型配置

使用前请确保已在 Hermes Agent 的 Web 界面或本应用的模型管理页面配置好 AI 模型的 API 密钥。

## 相关链接

- Hermes Web UI: https://github.com/EKKOLearnAI/hermes-web-ui
- Hermes Agent: https://github.com/NousResearch/hermes-agent
- 1Panel 官方 Hermes Agent: https://github.com/1Panel-dev/appstore/tree/dev/apps/hermes-agent