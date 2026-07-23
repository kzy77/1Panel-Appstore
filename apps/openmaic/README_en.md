# OpenMAIC

OpenMAIC is an open-source multi-agent learning platform. Powered by multi-agent orchestration, it generates a full lesson in minutes from a topic or your own materials, including slides, quizzes, interactive HTML simulations, and project-based learning (PBL) activities. AI teachers and AI classmates can speak, draw on a whiteboard, and engage in real-time discussions with you. Export editable `.pptx` slides or interactive `.html` pages.

## Usage

- After installation, open OpenMAIC at `http://<server-ip>:<access-port>`, default port `3000`.
- Before first launch, configure at least one LLM provider key in `data/.env.local` under the app version directory (e.g. `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`). Classroom generation will not work without it.
- `.env.local` follows the upstream `.env.example` and supports OpenAI, Azure OpenAI, Anthropic, Google Gemini, DeepSeek, Qwen, Kimi, MiniMax, Grok, OpenRouter, Doubao, Tencent Hunyuan, Xiaomi MiMo, GLM (Zhipu), Ollama (local), and any OpenAI-compatible API.
- The container runs the Next.js standalone build; no separate Node build step is needed at runtime — the image is built from source on first start.
- Optionally set `ACCESS_CODE` to protect the deployment with a site-level password.
- User data is persisted to the version directory's `data/` folder and survives container rebuilds.

## Build Notes

OpenMAIC does not publish a prebuilt Docker image. This app builds the image from source via a Docker git build context:

- The `0.3.0` version is pinned to the `v0.3.0` tag.
- The `latest` version tracks the `main` branch.

The first startup takes longer (dependency install + `next build`); ensure the server has enough memory (4GB+ recommended) and disk space.

## Configuration

| Parameter | Default | Description |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3000` | Web access port |

## Official Resources

- Live demo: https://open.maic.chat
- Repository: https://github.com/THU-MAIC/OpenMAIC
- Environment variable example: https://github.com/THU-MAIC/OpenMAIC/blob/main/.env.example
