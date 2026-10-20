# OpenViking

OpenViking is an open-source, self-evolving **context database for AI agents** from Volcengine. It unifies agent memory, knowledge RAG (resources) and skills in one `viking://` virtual filesystem, so agents can `ls`, `tree`, `read`, `write`, `grep` and `find` everything they know. Every directory carries generated summaries (L0/L1) so agents can judge relevance before reading full content (L2).

This app packages the official image `ghcr.io/volcengine/openviking` and includes:

- **OpenViking HTTP service** (default port `1933`)
- **Web Studio console** (`http://<IP>:1933/studio`)
- **VikingBot** (disabled by default; see below)

## Features

- One filesystem for knowledge, memory and skills, each with a `viking://` URI.
- Directory-scoped semantic search, instead of scanning a flat vector pool.
- Three context layers: L0 abstract, L1 overview, L2 full content.
- Sessions become readable Markdown with extracted memories.
- Accounts and user isolation, opt-in resource ACLs, API-key authentication.
- Python / Go / TypeScript SDKs and a full HTTP API.

## Usage

1. After installation, open `http://<your-ip>:1933/studio`.
2. In Web Studio settings, enter the **Root API Key** generated during installation.
3. Create an account and a user on the **Users** page. The user's **User API Key** is shown immediately. Use User/Admin keys for data access; the root key is for administration only.
4. You can also connect with the CLI, SDKs or `curl`:

   ```bash
   curl http://<your-ip>:1933/health
   curl "http://<your-ip>:1933/api/v1/fs/ls?uri=viking://" -H "X-API-Key: <User API Key>"
   ```

## Model Configuration (important)

OpenViking requires an **embedding model** and a **VLM (vision-language model)**. The official Docker image does **not** bundle local embedding dependencies, so models must be provided over an API.

The install form values are written to `ov.conf` on **first start**:

| Field | Description | Default |
| --- | --- | --- |
| Model Provider | `openai` (OpenAI-compatible) / `volcengine` / `ollama` | `openai` |
| Model API Base URL | Model endpoint | `https://api.openai.com/v1` |
| Model API Key | Provider API key | empty (required) |
| Embedding Model | Embedding model name | `text-embedding-3-small` |
| Embedding Dimension | Must match the model output | `1536` |
| Embedding Input Type | `text` or `multimodal` | `text` |
| VLM Model | Model used for summaries and memory extraction | `gpt-5.4` |

Reference setups:

- **OpenAI**: provider `openai`, base `https://api.openai.com/v1`, embedding `text-embedding-3-small` (dim 1536), VLM e.g. `gpt-5.4`.
- **Volcengine Ark (Doubao)**: provider `volcengine`, base `https://ark.cn-beijing.volces.com/api/v3`, embedding `doubao-embedding-vision-251215` (dim 1024, input `multimodal`), VLM e.g. `doubao-seed-2-0-lite-260428`.
- **Ollama / other OpenAI-compatible gateways**: provider `openai` or `ollama`, base pointing at your `/v1` endpoint (from inside the container use e.g. `http://host.docker.internal:11434/v1`).

> Note: changing the embedding model or dimension makes existing vector collections incompatible and requires reindexing.

## Data Directory

- `./data` is mounted at `/app/.openviking` inside the container:
  - `ov.conf` — server configuration
  - `ovcli.conf` — CLI configuration
  - `data/` — workspace (accounts, resources, vector data, ...)

## Changing Configuration

`ov.conf` is generated from the install form only on first start (when it does not exist) and is persisted at `./data/ov.conf`. **Changing the form later does not regenerate it**; edit the file directly and restart:

```bash
docker exec -it <container-name> openviking-server doctor   # validate config
docker restart <container-name>
```

Or re-run the setup wizard inside the container:

```bash
docker exec -it <container-name> openviking-server init
```

## Notes

- **Enabling VikingBot**: disabled by default. In API-key mode the Bot needs a User/Admin key (a root key cannot be used). Configure `bot.ov_server.api_key` in `./data/ov.conf`, set `OPENVIKING_WITH_BOT` to `1` in the compose file, then restart.
- **Mainland China mirror**: if `ghcr.io` is slow, switch to the commented Volcengine image `openviking-cn-beijing.cr.volces.com/volcengine/openviking`.
- **Public access / HTTPS**: put 1Panel's reverse proxy in front of port `1933` and set `server.public_base_url` in `ov.conf`.

## Port

- `1933` — HTTP service and Web Studio (configurable during installation).

## Links

- Website: <https://openviking.ai/>
- Docs: <https://docs.openviking.ai/>
- GitHub: <https://github.com/volcengine/OpenViking>
- Deployment guide: <https://docs.openviking.ai/en/guides/03-deployment>
- Configuration guide: <https://docs.openviking.ai/en/guides/01-configuration>
