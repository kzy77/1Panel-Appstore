# Hermes WebUI

Hermes WebUI is a third-party web interface for [Hermes Agent](https://hermes-agent.nousresearch.com/), letting you use Hermes Agent from the browser or your phone. It is a single-container deployment that runs the agent and the web UI in-process.

## Usage

- After installation, open `http://server-address:web-port`. The default port is `8787`.
- **Prerequisite**: Hermes Agent must already be installed on the host, with a Hermes home directory (`~/.hermes`) and a workspace directory. Fill in the host absolute paths during installation:
  - `Hermes home directory`: where Hermes Agent config, sessions and state live. Default `/root/.hermes`, mounted to `/home/hermeswebui/.hermes` in the container.
  - `Workspace directory`: the code/project directory shown in the file browser. Default `/root/workspace`, mounted to `/workspace`.
- `UID`/`GID`: the container runs as this UID/GID. Match it to the owner of the `.hermes` directory (check with `id -u` / `id -g`), otherwise the WebUI may fail to read config or write sessions due to permissions.
- **Password auth**: if the port is exposed publicly, you MUST set the `WebUI Password` (without one, anyone who can reach the port can run commands as the agent).
- Sessions, workspaces and state live in the mounted Hermes home and survive container recreation.
- Health check: `curl http://127.0.0.1:8787/health`

## Notes

- The image is published to GHCR by the project author (`ghcr.io/nesquena/hermes-webui`), amd64 + arm64.
- This package is a different app from the existing `hermes-web-ui` in this store (community fork, two containers, port 6060). Do not confuse them.

## Resources

- Repository: https://github.com/nesquena/hermes-webui
- Image: https://ghcr.io/nesquena/hermes-webui
