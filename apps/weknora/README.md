WeKnora 是腾讯开源的 LLM 知识平台，围绕三大核心能力构建：**RAG 快速问答**、可自主编排检索与工具的 **ReAct 智能体**，以及把原始文档沉淀为可维护 Markdown 知识库的 **Wiki 模式**。

## 核心特性

- **文档理解**：支持 PDF、Word、Excel、图片、XMind 等 10+ 格式，内置 docreader 解析服务（含 OCR / 版面分析）。
- **RAG 问答**：文档切分、向量化、混合检索、重排，提供带引用的问答。
- **智能体**：ReAct Agent 可编排检索、MCP 工具、沙箱与网络搜索，处理多步复杂任务。
- **Wiki 与知识图谱**：自动生成互相链接的 Wiki 页面，支持版本历史与回滚。
- **多数据源**：飞书、Notion、语雀、GitLab、RSS 等自动同步。
- **模型与可观测**：20+ 大模型供应商（OpenAI 兼容 / DeepSeek / Qwen / 智谱 / Ollama 等），可选 Langfuse 追踪。
- **私有化与协作**：多空间 RBAC、审计日志，数据完全本地化。

## 部署说明

本应用包使用 Docker Compose 部署，包含以下服务：

| 服务 | 说明 | 默认端口 |
| --- | --- | --- |
| frontend | Web 界面（Nginx，含 API 反代） | 安装时配置（默认 80） |
| app | 后端 API / 智能体 | 安装时配置（默认 8080） |
| docreader | 文档解析 gRPC 服务（仅内部） | 不对外暴露 |
| postgres | ParadeDB（PostgreSQL + 全文/向量检索） | 不对外暴露 |
| redis | 任务队列与流 | 不对外暴露 |
| minio | 对象存储，**默认存储后端** | S3 9000 / 控制台 9001 |
| searxng | 内置元搜索，用于联网检索 | 安装时配置（默认 8888） |

启动后请访问 **Web 界面端口** 完成初始化。

### 重要：首次使用需配置大模型

WeKnora 不内置任何大模型。部署完成后，需要在界面中配置至少一个可用的对话模型与嵌入模型（远程 API 或本地 Ollama）才能进行文档问答。若使用本地 Ollama，默认地址为 `http://host.docker.internal:11434`，可在安装时修改。

### 对象存储

默认使用内置 MinIO 作为文件存储，存储桶会在首次初始化时自动创建。请务必修改默认的访问密钥与私钥。

### SearXNG（联网检索）

内置 SearXNG 不会自动启用。需要在「设置 → Web 搜索」中新增 SearXNG Provider，实例地址填写 `http://searxng:8080`。

WeKnora 同样支持连接**外部 SearXNG 实例**：在 Provider 中填写外部实例地址即可。外部实例需开启 JSON 输出（`search.formats: [json]`）；若为内网地址，还需将主机加入 `SSRF_WHITELIST_EXTRA` 环境变量（见下方「常见问题」）。

### 密钥安全

- `SYSTEM_AES_KEY`：用于加密数据库中的 API Key 等敏感字段，**必须为 32 个字符且妥善保管**，丢失后已加密数据不可恢复。
- `JWT_SECRET`：安装时会自动生成，建议替换为强随机值。
- 请在安装时修改数据库、Redis、MinIO 的默认密码以及 SearXNG 密钥。

## 常见问题

### 配置本地大模型时提示「Base URL 未通过安全校验：SSRF validation failed」

WeKnora 出于 SSRF 防护，**默认拒绝直接使用 IP 地址**（包括内网 IP）作为模型/服务的访问地址。若你的本地大模型网关（One-API / New-API / Ollama / vLLM 等）使用 `http://192.168.123.216:3000/v1` 这类地址，需要把该主机或网段加入 `SSRF_WHITELIST_EXTRA`：

1. 打开 1Panel →「应用商店」→「已安装」→ WeKnora →「参数」。
2. 在 **SSRF 白名单（额外主机/域名/CIDR，逗号分隔）** 中追加你的地址，例如：

   ```
   searxng,qdrant,milvus,weaviate,doris-fe,doris-be,minio,192.168.123.216
   ```

   支持精确域名（如 `llm.lan`）、通配域名（`*.example.com`）、单个 IP、CIDR 网段（如 `192.168.123.0/24`、`10.0.0.0/8`）。
3. 保存并重建应用容器后即可使用。

> 说明：`SSRF_WHITELIST_EXTRA` 是**追加**列表，修改时请保留原有的 `searxng,...,minio` 默认项，否则内置 SearXNG / MinIO 可能无法访问。
> 改用域名同样会被拦截，因为该域名会解析到内网 IP，因此仍然必须加入白名单。
> 若模型服务在宿主机本机，也可填 `http://host.docker.internal:3000/v1`，并将 `host.docker.internal` 加入白名单。

## 系统要求

- 建议至少 4 核 CPU、8 GB 内存、20 GB 可用磁盘。
- docreader 镜像体积较大（约 1.5 GB），首次拉取与启动需要一定时间。

## 官方资源

- 官网：[https://weknora.weixin.qq.com](https://weknora.weixin.qq.com)
- GitHub：[https://github.com/Tencent/WeKnora](https://github.com/Tencent/WeKnora)
- 文档：[https://github.com/Tencent/WeKnora](https://github.com/Tencent/WeKnora)
