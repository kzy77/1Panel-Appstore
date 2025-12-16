# Docker-Socket-Proxy

The Socket Proxy is a security-enhanced proxy which allows you to apply access rules to the Docker socket, limiting the attack surface for containers such as watchtower or Traefik that need to use it.

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)

## Application Setup

This container is conceptually based on [https://github.com/Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) and as such does not follow our usual container conventions. It *does not* support mods or custom scripts/services, or running as a user other than root (or the docker user in a rootless environment). It is designed to act as a drop-in replacement for the Tecnativa container.

The container should be run on the same docker network as the service(s) using it. Most containers that would normally connect to a mounted docker.sock can have their endpoint overridden using the `DOCKER_HOST` environment variable if they do not offer the option in their configuration; it should typically be pointed to `tcp://socket-proxy:2375`.

* Never expose this container's port to a public network. It should be treated the same way you would treat the docker socket or TCP endpoint.
* Revoke access to any API section that you consider your service should not need.
* To see the versions of the API your Docker daemon and client support, use `docker version` and check the `API version`.
* [Read the docs](https://docs.docker.com/engine/api/) for the API version you are using for an explanation of all the available endpoints.

## Read-Only Operation

This image can be run with a read-only container filesystem. For details please [read the docs](https://docs.linuxserver.io/misc/read-only/).

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-e ALLOW_START=0` | `/containers/{id}/start` - **This option will work even if `POST=0`** |
| `-e ALLOW_STOP=0` | `/containers/{id}/stop` - **This option will work even if `POST=0`** |
| `-e ALLOW_RESTARTS=0` | `/containers/{id}/stop`, `/containers/{id}/restart`, and `/containers/{id}/kill` - **This option will work even if `POST=0`** |
| `-e AUTH=0` | `/auth` |
| `-e BUILD=0` | `/build` |
| `-e COMMIT=0` | `/commit` |
| `-e CONFIGS=0` | `/configs` |
| `-e CONTAINERS=0` | `/containers` |
| `-e DISTRIBUTION=0` | `/distribution` |
| `-e DISABLE_IPV6=0` | Set to `1` to prevent binding to the IPv6 interface for legacy systems that cannot support IPv6. |
| `-e EVENTS=1` | `/events` |
| `-e EXEC=0` | `/exec` & `/containers/{id}/exec` |
| `-e IMAGES=0` | `/images` |
| `-e INFO=0` | `/info` |
| `-e LOG_LEVEL=info` | Possible values are: debug, info, notice, warning, err, crit, alert and emerg. Defaults to info. |
| `-e NETWORKS=0` | `/networks` |
| `-e NODES=0` | `/nodes` |
| `-e PING=1` | `/_ping` |
| `-e PLUGINS=0` | `/plugins` |
| `-e POST=0` | When set to `0`, only `GET` and `HEAD` operations are allowed, making API access read-only. |
| `-e SECRETS=0` | `/secrets` |
| `-e SERVICES=0` | `/services` |
| `-e SESSION=0` | `/session` |
| `-e SWARM=0` | `/swarm` |
| `-e SYSTEM=0` | `/system` |
| `-e TASKS=0` | `/tasks` |
| `-e TZ=Etc/UTC` | `Set container timezone` |
| `-e VERSION=1` | `/version` |
| `-e VOLUMES=0` | `/volumes` |
| `-v /var/run/docker.sock:ro` | Mount the host docker socket into the container. |
| `--read-only` | Make the container filesystem read-only. |
| `--tmpfs /run` | Mount /run to tmpfs (RAM) to make it writeable. |

### Parameter Recommendations

If you need to run the docker socket proxy as a service, it's recommended to configure the following parameters for full functionality:

- `CONTAINERS=1` - Allow container operations
- `NETWORKS=1` - Allow network operations  
- `EVENTS=1` - Enable event monitoring
- `PING=1` - Allow ping operations
- `POST=1` - Allow write operations (create, modify, delete)

This parameter combination provides complete Docker API access capabilities, suitable for most container management scenarios.