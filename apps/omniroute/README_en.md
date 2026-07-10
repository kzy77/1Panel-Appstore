# OmniRoute

OmniRoute is a free, open-source AI gateway that connects Claude Code, Codex, Cursor, Cline, Copilot and more to 237 AI providers (90+ with free tiers). It provides auto-fallback, 17 routing strategies, RTK + Caveman compression (15-95% token savings), OpenAI/Claude/Gemini/Codex compatible APIs, and built-in MCP and A2A services.

## Usage

- After installation, open the dashboard at `http://<server-ip>:<dashboard-port>`, default port `20128`.
- The API endpoint is `http://<server-ip>:<api-port>/v1`, default port `20129`.
- On first install, make sure to set `Initial Admin Password`; if left empty it defaults to `CHANGEME` — change it in "Settings → Security" after login.
- `JWT Secret` and `API Key Secret` are auto-generated on first start and persisted to the `data/` directory when left empty, so manual input is optional; fill them in if you want fixed keys.
- Data (SQLite database, config, backups) is persisted to the version directory's `data/` folder and survives container rebuilds.
- Uses the built-in in-memory rate limiter by default; configure Redis inside the app for higher concurrency (advanced, not bundled here).

## Configuration

| Parameter | Default | Description |
| --- | --- | --- |
| `PANEL_APP_PORT_HTTP` | `20128` | Dashboard port |
| `PANEL_APP_PORT_API` | `20129` | API port |
| `INITIAL_PASSWORD` | - | Initial admin login password |
| `JWT_SECRET` | auto-generated | JWT signing key for dashboard sessions |
| `API_KEY_SECRET` | auto-generated | Encryption key for stored API keys |
| `REQUIRE_API_KEY` | `false` | Require API key for all requests |

## Official Resources

- Website: https://omniroute.online
- Repository: https://github.com/diegosouzapw/OmniRoute
- Docker image: https://hub.docker.com/r/diegosouzapw/omniroute
