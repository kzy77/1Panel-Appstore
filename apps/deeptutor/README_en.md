# DeepTutor

DeepTutor is an open-source lifelong personalized AI tutoring platform integrating RAG knowledge bases, multi-model support, agents, quizzes, and long-term memory. Build personalized learning paths from your own materials, run Q&A, generate quizzes, and manage knowledge bases for a continuous tutoring experience.

## Usage

- After installation, open the DeepTutor console at `http://<server-ip>:<frontend-port>`, default port `3782`.
- The backend API is available at `http://<server-ip>:<backend-port>`, default port `8001`.
- On first start the app auto-initializes its config and persists it to the `data/` directory — no extra setup required.
- For local models (LM Studio / Ollama / vLLM), use `host.docker.internal` instead of `localhost` when configuring provider endpoints.
- When deployed on a remote server, set the backend API URL (`next_public_api_base_external`) to the server's public IP or hostname in "Settings", otherwise the browser cannot reach the API.
- Data (user config, knowledge bases, memory) is persisted to the version directory's `data/` folder and survives container rebuilds.

## Configuration

| Parameter | Default | Description |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `3782` | Frontend console port |
| `PANEL_APP_PORT_API` | `8001` | Backend API port |

## Official Resources

- Website: https://deeptutor.info
- Repository: https://github.com/HKUDS/DeepTutor
- Docker image: https://github.com/HKUDS/DeepTutor/pkgs/container/deeptutor
