# CLIProxyAPI

CLIProxyAPI wraps Antigravity, ChatGPT Codex, Claude Code, Grok Build, and other CLI/OAuth capabilities as an API service compatible with OpenAI, Gemini, Claude, and Codex clients.

## Features

- OpenAI, Gemini, Claude, and Codex compatible API formats
- Support for Claude Code, Codex, Gemini, Antigravity, and other authentication sources
- Web management interface and management API
- Multi-account routing, load balancing, retry, and cooldown policies
- Proxy, TLS, logging, and usage-statistics configuration

## Default Ports

- **Web/API Port (8317)**: main service port
  - Web Management UI: `http://localhost:8317/management.html`
  - OpenAI-compatible API: `http://localhost:8317/v1`
- **Proxy Port (8085)**: CLI proxy service port
- **Additional Ports**: 1455, 54545, 51121, 11451

## Data Directory

Application data is stored in `./data`:

- `config.yaml` - main configuration file for API keys, auth sources, routing, proxy, and management settings
- `auths/` - OAuth/CLI authentication files
- `logs/` - application logs

## Quick Configuration

1. Edit `./data/config.yaml`
2. Configure access keys in `api-keys`
3. For remote management access, set `remote-management.allow-remote: true` and configure `remote-management.secret-key`
4. Configure Claude, Codex, Gemini, OpenAI-compatible, or other auth sources as needed
5. Restart the application for changes to take effect

## Key Configuration Example

```yaml
# Service port
port: 8317

# API Keys
api-keys:
  - 'your-api-key-1'
  - 'your-api-key-2'

# Management interface settings
remote-management:
  allow-remote: false
  secret-key: ''
  disable-control-panel: false

# Global proxy
proxy-url: ""

# Routing strategy
routing:
  strategy: "round-robin"
```

## Version Information

- **latest**: upstream latest image
- **v7.2.50**: current pinned version, using upstream Docker tag `v7.2.50`

## Links

- GitHub: https://github.com/router-for-me/CLIProxyAPI
- Documentation: https://github.com/router-for-me/CLIProxyAPI/blob/main/README.md
- Issue Tracker: https://github.com/router-for-me/CLIProxyAPI/issues

## Important Notes

1. Change `api-keys` and the management key immediately after first deployment
2. If remote management is enabled, use a strong password and restrict access sources
3. For production, enable TLS or run behind a trusted reverse proxy
4. OAuth/CLI auth files are stored in `auths/`; ensure the directory has correct permissions
5. Do not expose unauthenticated management endpoints publicly
