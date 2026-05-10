# Hermes Web UI

A full-featured web dashboard for Hermes Agent. Manage AI chat sessions, monitor usage & costs, configure platform channels, schedule cron jobs, browse skills — all from a clean, responsive web interface.

## Deployment

This is a standalone Web UI app that does **not include** the Hermes Agent service. Install the official [Hermes Agent](https://github.com/1Panel-dev/appstore/tree/dev/apps/hermes-agent) from 1Panel app store first, then install this app to connect to your existing Agent.

### Setup Steps

1. Install **Hermes Agent** from 1Panel app store (official app)
2. Install **Hermes Web UI** (this app)
3. Configure the "Hermes Agent Gateway" URL during installation (default: `http://hermes-agent:8642`)
4. If you changed the Agent container name, adjust the hostname in the gateway URL accordingly

### Networking

Both apps use the `1panel-network` and communicate via Docker internal networking — no additional ports need to be exposed.

## Features

- **AI Chat** — Real-time streaming via SSE, multi-session management, Markdown rendering with syntax highlighting
- **Platform Channels** — Unified configuration for 8 platforms (Telegram, Discord, Slack, WhatsApp, Matrix, Feishu, WeChat, WeCom)
- **Usage Analytics** — Token usage breakdown, cost tracking, model distribution charts
- **Scheduled Jobs** — Create, edit, pause, resume, delete cron jobs
- **Model Management** — Auto-discover providers, add custom OpenAI-compatible endpoints
- **Multi-Profile** — Create, clone, import/export Hermes profiles
- **File Browser** — Browse, upload, download files on remote backends
- **Group Chat** — Multi-agent chat rooms with @mention support and context compression
- **Skills & Memory** — Browse installed skills, user notes management
- **Log Viewer** — Filter and view agent/gateway/error logs
- **Authentication** — Token-based auth (auto-generated on first run)
- **Web Terminal** — Integrated terminal with multi-session support

## Usage

### Default Port

- Web UI: `6060` (configurable during installation)

### Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Web UI Port | `6060` | Web dashboard access port |
| Agent Gateway | `http://hermes-agent:8642` | Hermes Agent gateway URL |

### Default Credentials

- Auth Token is auto-generated on first run. View it via container logs:
  ```bash
  docker logs <container-name> | grep token
  ```
- You can also set a custom token via `AUTH_TOKEN` environment variable

### Data Directories

- `./webui-data` — Web UI data (auth token, etc.)

### Model Configuration

Make sure to configure your AI model API keys via the Hermes Agent web interface or this app's Model Management page before use.

## Links

- Hermes Web UI: https://github.com/EKKOLearnAI/hermes-web-ui
- Hermes Agent: https://github.com/NousResearch/hermes-agent
- Official 1Panel Hermes Agent: https://github.com/1Panel-dev/appstore/tree/dev/apps/hermes-agent