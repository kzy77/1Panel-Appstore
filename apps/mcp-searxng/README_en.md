# MCP-SearXNG

An [MCP server](https://modelcontextprotocol.io/introduction) that gives AI assistants privacy-respecting web search via [SearXNG](https://docs.searxng.org) — works with Claude, Cursor, Codex and any MCP client. This package deploys it as a long-running service in **HTTP transport mode** (MCP SDK v2 Streamable HTTP); clients connect to the `/mcp` endpoint by URL.

## Usage

1. **Prerequisite: a SearXNG instance.** Use the `searxng` app from this store, your own instance, or a public one. JSON format must be enabled in `settings.yml` (`search.formats: html, json`).
2. During installation, fill in the `SearXNG Instance URL` (required), e.g. `https://searxng.example.com`. A semicolon-separated list of interchangeable replicas enables failover.
3. In your MCP client (Claude Code, Cursor, etc.), add a connection of type streamable-http (or SSE) with the URL:
   `http://server-address:service-port/mcp`
4. Self-check: `curl http://server-address:service-port/health` should succeed.

## Configuration

| Field | Description |
|-------|-------------|
| HTTP Service Port | Host port, default `8080` |
| SearXNG Instance URL | Required; multiple instances separated by semicolons |
| Default Response Format | `text` (formatted, default) or `json` (raw results) |
| Default Language | e.g. `en`, `zh`, `all` |
| Safe-search Level | `0` off / `1` moderate / `2` strict |
| Max Results per Call | 1-20; empty uses the server default |
| HTML Fallback | Parse the HTML results page when an instance rejects JSON (only if JSON cannot be enabled) |

## Security Notes

- This service has **no authentication by default**. Only run it on a trusted network; for public exposure, put it behind a reverse proxy with auth or enable the `MCP_HTTP_HARDEN` hardening mode (see [CONFIGURATION.md](https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md)).
- Advanced features (browser solving for URL reading, caching, proxies, etc.) are documented in the project's [CONFIGURATION.md](https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md).

## Resources

- Repository: https://github.com/ihor-sokoliuk/mcp-searxng
- Docker image: https://hub.docker.com/r/isokoliuk/mcp-searxng
- Configuration docs: https://github.com/ihor-sokoliuk/mcp-searxng/blob/main/CONFIGURATION.md