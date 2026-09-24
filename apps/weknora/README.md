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
| neo4j | 知识图谱存储（默认启用） | Browser 7474 / Bolt 7687 |

启动后请访问 **Web 界面端口** 完成初始化。

### 重要：首次使用需配置大模型

WeKnora 不内置任何大模型。部署完成后，需要在界面中配置至少一个可用的对话模型与嵌入模型（远程 API 或本地 Ollama）才能进行文档问答。若使用本地 Ollama，默认地址为 `http://host.docker.internal:11434`，可在安装时修改。

### 对象存储

默认使用内置 MinIO 作为文件存储，存储桶会在首次初始化时自动创建。请务必修改默认的访问密钥与私钥。

### SearXNG（联网检索）

内置 SearXNG 不会自动启用。需要在「设置 → Web 搜索」中新增 SearXNG Provider，实例地址填写 `http://searxng:8080`。

WeKnora 同样支持连接**外部 SearXNG 实例**：在 Provider 中填写外部实例地址即可。外部实例需开启 JSON 输出（`search.formats: [json]`）；若为内网地址，还需将主机加入 `SSRF_WHITELIST_EXTRA` 环境变量（见下方「常见问题」）。

### 知识图谱（Neo4j）

默认已启用（`NEO4J_ENABLE=true`），随包内置 Neo4j 2025.10.1。构建图谱时会调用大模型抽取实体与关系，耗时较长，建议按需为知识库开启。

- **Neo4j Browser**：`http://<服务器IP>:<Neo4j Browser 端口>`（安装时配置，默认 7474），账号 `neo4j`，密码为安装时设置的 **Neo4j 密码**。
- **Bolt**：默认端口 7687，供外部图数据库工具连接。
- 如不需要知识图谱，可在应用参数中把 `NEO4J_ENABLE` 关闭；关闭后仍会运行 neo4j 容器，可按需停止。

### 配置修改

应用包已将 WeKnora 的 `config/` 目录挂载到容器内 `/app/config`，可直接编辑安装目录下的 `config/` 文件，保存后重启应用生效：

- `config.yaml`：主配置（对话轮数、分块参数、抽取、租户策略等）
- `builtin_agents.yaml`、`agent_type_presets.yaml`：内置智能体与类型预设
- `prompt_templates/*`：提示词模板

> 注意：挂载的是随包发布的配置副本。升级应用版本时请同步更新 `config/` 目录（用新版本目录下的同名文件覆盖），否则可能缺少新版本引入的配置项。

### MCP Server（可选，需独立部署）

WeKnora 官方**未提供 MCP 镜像**，MCP Server 需单独部署。可使用上游 `mcp-server/` 源码构建，或使用 PyPI 上的 `tencent-weknora-mcp` 包。运行时需设置：

- `WEKNORA_BASE_URL`：后端 API 地址，容器内可用 `http://app:8080/api/v1`
- `WEKNORA_API_KEY`：在前端「设置 → API Keys」生成
- `MCP_SERVER_AUTH_TOKEN`：HTTP/SSE 传输必填，否则拒绝启动

HTTP 传输默认监听 8000 端口。

### 系统管理员（首个）

WeKnora 没有默认管理员账号，首个系统管理员通过「引导」产生：

1. 先用 Web 界面注册一个账号（**记住注册时用的邮箱**）；
2. 在安装参数 **引导系统管理员邮箱** 中填入**该账号的邮箱**（可选字段，可随时修改/清空）；
3. 保存并重启 app 服务。启动时会把该邮箱对应的已存在账号提升为系统管理员。

> ⚠️ **安装/启动时传入的邮箱必须与已注册账号的邮箱完全一致**，否则不生效（日志会记录告警，不会阻断启动）。
> 引导只提升**已存在**的账号，不会创建账号；且仅在部署尚无系统管理员时授予权限，之后该字段不再生效，因此留着不会把你后来撤销的管理员又加回来。
> 系统管理员可在「设置」侧栏看到**系统设置 / 任务队列 / 平台 API Key / 系统审计日志**四个分区，并可重置用户密码、创建用户、提升或撤销其他管理员（不能撤销自己或最后一位）。

### 密钥安全

- `SYSTEM_AES_KEY`：用于加密数据库中的 API Key 等敏感字段，**必须为 32 个字符且妥善保管**，丢失后已加密数据不可恢复。
- `JWT_SECRET`：安装时会自动生成，建议替换为强随机值。
- 请在安装时修改数据库、Redis、MinIO 的默认密码、Neo4j 密码以及 SearXNG 密钥。

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
- 启用知识图谱（Neo4j）后建议额外预留 1 GB 以上内存。
- docreader 镜像体积较大（约 1.5 GB），首次拉取与启动需要一定时间。

## 官方资源

- 官网：[https://weknora.weixin.qq.com](https://weknora.weixin.qq.com)
- GitHub：[https://github.com/Tencent/WeKnora](https://github.com/Tencent/WeKnora)
- 文档：[https://github.com/Tencent/WeKnora](https://github.com/Tencent/WeKnora)
