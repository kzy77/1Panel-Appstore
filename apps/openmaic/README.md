# OpenMAIC

OpenMAIC 是一个开源的多智能体学习平台。由多智能体编排驱动，它能在数分钟内根据主题或你的私有资料生成完整课堂，包含课件、测验、交互式 HTML 模拟与项目式学习（PBL）活动。AI 老师与 AI 同学可开口讲解、在白板书写公式并实时与你讨论，支持导出可编辑的 `.pptx` 课件或交互式 `.html` 页面。

## 使用说明

- 安装后通过 `http://服务器地址:访问端口` 访问 OpenMAIC，默认端口为 `3000`。
- 首次部署前，请在应用版本目录下的 `data/.env.local` 中至少配置一个 LLM 提供商密钥（如 `OPENAI_API_KEY`、`ANTHROPIC_API_KEY`、`GOOGLE_API_KEY` 等），否则课堂生成功能无法使用。
- `.env.local` 可参考上游 `.env.example`，支持 OpenAI、Azure OpenAI、Anthropic、Google Gemini、DeepSeek、通义千问、Kimi、MiniMax、Grok、OpenRouter、豆包、腾讯混元、小米 MiMo、智谱 GLM、Ollama（本地）及任意 OpenAI 兼容 API。
- 容器内通过 Next.js standalone 模式运行，生产环境无需额外 Node 构建步骤；镜像会在首次启动时从源码构建。
- 可选设置 `ACCESS_CODE` 为部署加一层站点级访问密码。
- 用户数据持久化到应用版本目录下的 `data/` 中，容器重建后不会丢失。

## 构建说明

OpenMAIC 官方未发布预构建 Docker 镜像，本应用通过 Docker 的 git 构建上下文从源码构建镜像：

- `0.3.0` 版本固定从 `v0.3.0` tag 构建。
- `latest` 版本从 `main` 分支构建。

首次拉起时构建时间较长（需安装依赖并执行 `next build`），请确保服务器有足够的内存（建议 4GB 以上）与磁盘空间。

## 配置参数

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3000` | Web 访问端口 |

## 官方资源

- 在线演示：https://open.maic.chat
- 项目仓库：https://github.com/THU-MAIC/OpenMAIC
- 环境变量示例：https://github.com/THU-MAIC/OpenMAIC/blob/main/.env.example
