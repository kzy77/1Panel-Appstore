# OpenViking

OpenViking 是火山引擎（Volcengine）开源的**面向 AI Agent 的自进化上下文数据库**。它把智能体的记忆（Memory）、知识 RAG（Resources）与技能（Skills）统一到一个 `viking://` 虚拟文件系统中，Agent 可以像读写文件一样 `ls`、`tree`、`read`、`write`、`grep`、`find` 上下文；每个目录都带有自动生成的摘要（L0/L1），便于先判断相关性再读取全文。

本应用封装官方镜像 `ghcr.io/volcengine/openviking`，包含：

- **OpenViking HTTP 服务**（默认端口 `1933`）
- **Web Studio 控制台**（`http://<IP>:1933/studio`）
- **VikingBot**（默认关闭，见下文）

## 版本与部署方式

- 固定版本：`0.5.2.1`，使用官方镜像 `ghcr.io/volcengine/openviking:v0.5.2.1`；保留原有 `0.5.2` 供已有安装使用。
- 滚动版本：`latest`，使用官方 `:latest` 标签，升级前请先备份。
- 官方 `v0.5.2.1` 镜像已核实支持 `linux/amd64` 和 `linux/arm64`。
- 使用内嵌本地文件与向量存储，不需要额外部署 Redis、外部向量数据库或 Caddy。HTTPS 可由 1Panel 反向代理提供。
- 图标来自官方仓库 `docs/images/ov-logo-square.png`。

## 主要特性

- 一个文件系统承载知识、记忆与技能，均可通过 `viking://` URI 浏览和检索。
- 目录级语义检索 `/find`，可按项目或记忆子树限定范围，而不是扫描整个向量库。
- L0 摘要 / L1 概览 / L2 全文三级上下文加载。
- 会话可归档为可读的 Markdown，并抽取记忆。
- 多账号与用户隔离，可选资源 ACL，支持 API Key 认证。
- 提供 Python / Go / TypeScript SDK 与 HTTP API。

## 使用说明

1. 准备可用的模型 API，安装时填写模型配置；完成后访问 `http://<你的IP>:<安装时设置的HTTP端口>/studio` 打开 Web Studio（默认端口 `1933`）。
2. 在 Studio 设置页填入安装时生成的 **根 API 密钥（Root API Key）**。
3. 在 **Users** 页面创建账号与用户，创建后会显示该用户的 **User API Key**。日常数据访问请使用 User/Admin Key，根密钥仅用于管理。
4. 也可以使用 CLI、SDK 或 `curl` 连接：

   ```bash
   curl http://<你的IP>:1933/health
   curl "http://<你的IP>:1933/api/v1/fs/ls?uri=viking://" -H "X-API-Key: <User API Key>"
   ```

## 模型配置（重要）

OpenViking 需要一个**向量嵌入模型（Embedding）**和**视觉语言模型（VLM）**来处理与检索内容。官方 Docker 镜像**不包含**本地嵌入模型依赖，因此必须使用 API 方式提供模型。

安装表单中的参数会在**首次启动时**写入 `ov.conf`：

| 参数 | 说明 | 默认值 |
| --- | --- | --- |
| 模型提供商 | `openai`（兼容 OpenAI 的接口）/ `volcengine` / `ollama` | `openai` |
| 模型 API 地址 | 模型服务地址 | `https://api.openai.com/v1` |
| 模型 API 密钥 | 模型服务密钥 | 空（必填） |
| 向量嵌入模型 | Embedding 模型名 | `text-embedding-3-small` |
| 向量维度 | 必须与嵌入模型输出一致 | `1536` |
| 嵌入输入类型 | `text` 或 `multimodal` | `text` |
| VLM 模型 | 用于摘要、记忆抽取的模型 | `gpt-5.4` |

不同提供商的参考配置：

- **OpenAI**：提供商 `openai`，地址 `https://api.openai.com/v1`，嵌入 `text-embedding-3-small`（维度 1536），VLM 如 `gpt-5.4`。
- **火山方舟（豆包）**：提供商 `volcengine`，地址 `https://ark.cn-beijing.volces.com/api/v3`，嵌入 `doubao-embedding-vision-251215`（维度 1024，输入类型 `multimodal`），VLM 如 `doubao-seed-2-0-lite-260428`。
- **Ollama / 其他 OpenAI 兼容网关**：提供商 `openai` 或 `ollama`，地址填写你的 `/v1` 地址。`0.5.2.1` 与 `latest` 已添加 Linux 宿主机映射，可用 `http://host.docker.internal:11434/v1`；Ollama 需监听容器可达的地址并允许 Docker 网段访问，不要直接暴露到公网。Ollama 不要求密钥时，可在必填密钥框填 `ollama`。嵌入模型和 VLM 必须分别具备所需能力。

表单默认让 Embedding 与 VLM 共用提供商、地址和密钥；如需使用不同服务，请在首次启动后分别修改 `ov.conf` 的 `embedding.dense` 和 `vlm`。使用第三方模型 API 可能产生费用。

> 提示：切换嵌入模型或维度会导致已有向量集合不兼容，需要重建索引。

## 数据目录

- 持久化目录：`./data` 挂载到容器内的 `/app/.openviking`
  - `ov.conf`：服务配置
  - `ovcli.conf`：CLI 配置
  - `data/`：工作区（账号、资源、向量数据等）

升级前停止应用并备份整个 `./data`，不要只备份 `ov.conf`。本地向量后端不支持多个实例同时共享工作区。

## 修改配置

`ov.conf` 只在首次启动（文件不存在）时由安装参数生成并持久化在 `./data/ov.conf`。**安装后修改表单参数不会重新生成配置**，请直接编辑该文件后重启容器：

```bash
docker exec -it <容器名> openviking-server doctor   # 校验配置
docker restart <容器名>
```

也可以进入容器重新运行配置向导：

```bash
docker exec -it <容器名> openviking-server init
```

## 常用设置

- **启用 VikingBot**：默认关闭。API Key 模式下 Bot 需要一个 User/Admin 密钥（不能使用根密钥）。在 `./data/ov.conf` 中配置 `bot.ov_server.api_key` 后，将 compose 中的 `OPENVIKING_WITH_BOT` 改为 `1` 并重启。
- **中国大陆镜像加速**：若 `ghcr.io` 访问缓慢，可在 `docker-compose.yml` 中改用注释里的火山引擎镜像 `openviking-cn-beijing.cr.volces.com/volcengine/openviking`。
- **公网访问 / HTTPS**：建议由 1Panel 反向代理到安装时设置的 HTTP 端口，并在 `ov.conf` 的 `server.public_base_url` 中填写外部 HTTPS 地址。限制直连端口的访问范围，妥善保管根密钥和用户密钥；按需将 `server.cors_origins` 从 `*` 收紧到实际站点。
- **健康检查**：`/health` 只表示进程存活，不验证模型凭据；使用 `/ready` 和 `openviking-server doctor` 检查就绪状态与模型访问。

## 端口

- `1933`：HTTP 服务与 Web Studio（安装时可修改映射端口）。

## 相关链接

- 官网：<https://openviking.ai/>
- 文档：<https://docs.openviking.ai/>
- GitHub：<https://github.com/volcengine/OpenViking>
- 部署指南：<https://docs.openviking.ai/en/guides/03-deployment>
- 配置指南：<https://docs.openviking.ai/en/guides/01-configuration>
