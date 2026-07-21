# DeepTutor

DeepTutor 是一个开源的终身个性化 AI 辅导平台，集成 RAG 知识库、多模型支持、智能体、测验与长期记忆系统。用户可基于私有资料构建个性化学习路径，进行问答、生成测验、管理知识库，打造可持续的个性化辅导体验。

## 使用说明

- 安装后通过 `http://服务器地址:前端端口` 访问 DeepTutor 控制台，默认端口为 `3782`。
- 后端 API 地址为 `http://服务器地址:后端端口`，默认端口为 `8001`。
- 首次启动时应用会自动初始化配置并持久化到 `data/` 目录，无需额外配置。
- 本地模型（LM Studio / Ollama / vLLM）请使用 `host.docker.internal` 替代 `localhost` 配置模型提供商地址。
- 若部署在远程服务器，请在应用「设置」中将后端 API 地址（`next_public_api_base_external`）改为服务器公网 IP 或域名，否则浏览器将无法访问 API。
- 数据（用户配置、知识库、记忆）持久化到应用版本目录下的 `data/` 中，容器重建后不会丢失。

## 配置参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3782` | 前端控制台端口 |
| `PANEL_APP_PORT_API` | `8001` | 后端 API 端口 |

## 官方资源

- 官网：https://deeptutor.info
- 项目仓库：https://github.com/HKUDS/DeepTutor
- Docker 镜像：https://github.com/HKUDS/DeepTutor/pkgs/container/deeptutor
