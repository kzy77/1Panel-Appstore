# OpenClaw Chinese

OpenClaw Chinese is a localized Chinese distribution of OpenClaw. OpenClaw is an open-source, self-hosted personal AI assistant with a local Web Dashboard and Gateway.

## Usage

After installation, open `http://server-ip:port` in your browser. The default port is `18789`.

It is recommended to set `OPENCLAW_GATEWAY_TOKEN` during installation for Dashboard authentication. You can append `?token=your-token` to the URL when opening the Dashboard.

## Data Directory

Application data is persisted in `data/conf` under the installation directory, mapped to `/root/.openclaw` inside the container.

## References

- Repository: https://github.com/1186258278/OpenClawChineseTranslation
- Docker guide: https://github.com/1186258278/OpenClawChineseTranslation/blob/main/DOCKER_README.md
- OpenClaw website: https://openclaw.ai/
