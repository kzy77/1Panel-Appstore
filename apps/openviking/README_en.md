# OpenViking

OpenViking is an open-source, self-evolving **context database for AI agents** from Volcengine. It unifies agent memory, knowledge RAG (resources) and skills in one `viking://` virtual filesystem, so agents can `ls`, `tree`, `read`, `write`, `grep` and `find` everything they know. Every directory carries generated summaries (L0/L1) so agents can judge relevance before reading full content (L2).

This app packages the official image `ghcr.io/volcengine/openviking` and includes:

- **OpenViking HTTP service** (default port `1933`)
- **Web Studio console** (`http://<IP>:1933/studio`)
- **VikingBot** (disabled by default; see below)

## Versions and Deployment

- Pinned version: `0.5.2.1`, using `ghcr.io/volcengine/openviking:v0.5.2.1`; the existing `0.5.2` package is retained.
- Rolling version: `latest`, using the official `:latest` tag. Back up before upgrading.
- The official `v0.5.2.1` image manifest has been verified for `linux/amd64` and `linux/arm64`.
- Uses embedded local filesystem and vector storage; no separate Redis, vector database or Caddy is required. Use 1Panel for HTTPS reverse proxying.
- The logo is from the upstream repository's `docs/images/ov-logo-square.png`.

## Features

- One filesystem for knowledge, memory and skills, each with a `viking://` URI.
- Directory-scoped semantic search, instead of scanning a flat vector pool.
- Three context layers: L0 abstract, L1 overview, L2 full content.
- Sessions become readable Markdown with extracted memories.
- Accounts and user isolation, opt-in resource ACLs, API-key authentication.
- Python / Go / TypeScript SDKs and a full HTTP API.

## Usage

1. Prepare working model APIs and enter their settings during installation. Then open `http://<your-ip>:<configured-http-port>/studio` (default port: `1933`).
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
- **Ollama / other OpenAI-compatible gateways**: provider `openai` or `ollama`, base pointing at your `/v1` endpoint. Versions `0.5.2.1` and `latest` include a Linux host mapping for `http://host.docker.internal:11434/v1`. Ollama must listen on a container-reachable address and allow the Docker subnet; do not expose it publicly. If no key is required, enter `ollama` in the required key field. Choose appropriate embedding and vision-language models.

The form initially shares the provider, endpoint and key between Embedding and VLM. To use different services, edit `embedding.dense` and `vlm` separately in `ov.conf` after initialization. Third-party model APIs may incur charges.

> Note: changing the embedding model or dimension makes existing vector collections incompatible and requires reindexing.

## Data Directory

- `./data` is mounted at `/app/.openviking` inside the container:
  - `ov.conf` — server configuration
  - `ovcli.conf` — CLI configuration
  - `data/` — workspace (accounts, resources, vector data, ...)

Stop the app and back up the entire `./data` directory before upgrading, not just `ov.conf`. Multiple instances must not share a workspace with the local vector backend.

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
- **Public access / HTTPS**: proxy to the configured HTTP port using 1Panel and set `server.public_base_url` in `ov.conf` to the external HTTPS URL. Restrict direct port access, protect root and user keys, and narrow `server.cors_origins` from `*` to your actual origins where appropriate.
- **Health checks**: `/health` only checks process liveness, not model credentials. Use `/ready` and `openviking-server doctor` to check readiness and model access.

## Port

- `1933` — HTTP service and Web Studio (configurable during installation).

## Links

- Website: <https://openviking.ai/>
- Docs: <https://docs.openviking.ai/>
- GitHub: <https://github.com/volcengine/OpenViking>
- Deployment guide: <https://docs.openviking.ai/en/guides/03-deployment>
- Configuration guide: <https://docs.openviking.ai/en/guides/01-configuration>
