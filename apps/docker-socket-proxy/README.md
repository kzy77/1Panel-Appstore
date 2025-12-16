# Docker-Socket-Proxy

Socket Proxy是一个安全增强型代理，允许您对Docker socket应用访问规则，从而限制需要使用它的容器的攻击面，如watchtower或Traefik等容器。

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)

## 应用设置

此容器在概念上基于[https://github.com/Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)，因此不遵循我们通常的容器约定。它不支持mods或自定义脚本/服务，也不能以非root用户（或rootless环境中的docker用户）身份运行。它旨在作为Tecnativa容器的直接替代品运行。

容器应在与服务使用它的同一docker网络上运行。通常会连接到挂载的docker.sock的大多数容器如果不提供配置选项，可以使用`DOCKER_HOST`环境变量覆盖其端点；通常应指向`tcp://socket-proxy:2375`。

* 永远不要将此容器的端口暴露给公共网络。它应该被视为与docker socket或TCP端点相同的方式处理。
* 撤销对您认为服务不需要的任何API部分的访问。
* 要查看Docker守护进程和客户端支持的API版本，请使用`docker version`并检查`API version`。
* [阅读文档](https://docs.docker.com/engine/api/)以了解您正在使用的API版本的可用端点说明。

## 只读操作

此镜像可以与只读容器文件系统一起运行。详细信息请[阅读文档](https://docs.linuxserver.io/misc/read-only/)。

## 参数

容器使用运行时传递的参数进行配置（如上所述）。这些参数用冒号分隔，分别表示`<外部>:<内部>`。例如，`-p 8080:80`将暴露容器内部的端口`80`，使其可从容器外部主机的IP上的端口`8080`访问。

| 参数 | 功能 |
| :----: | --- |
| `-e ALLOW_START=0` | `/containers/{id}/start` - **即使`POST=0`此选项也将生效** |
| `-e ALLOW_STOP=0` | `/containers/{id}/stop` - **即使`POST=0`此选项也将生效** |
| `-e ALLOW_RESTARTS=0` | `/containers/{id}/stop`、`/containers/{id}/restart`和`/containers/{id}/kill` - **即使`POST=0`此选项也将生效** |
| `-e AUTH=0` | `/auth` |
| `-e BUILD=0` | `/build` |
| `-e COMMIT=0` | `/commit` |
| `-e CONFIGS=0` | `/configs` |
| `-e CONTAINERS=0` | `/containers` |
| `-e DISTRIBUTION=0` | `/distribution` |
| `-e DISABLE_IPV6=0` | 设置为`1`以防止绑定到IPv6接口，适用于无法支持IPv6的旧系统。 |
| `-e EVENTS=1` | `/events` |
| `-e EXEC=0` | `/exec`和`/containers/{id}/exec` |
| `-e IMAGES=0` | `/images` |
| `-e INFO=0` | `/info` |
| `-e LOG_LEVEL=info` | 可能的值：debug、info、notice、warning、err、crit、alert和emerg。默认为info。 |
| `-e NETWORKS=0` | `/networks` |
| `-e NODES=0` | `/nodes` |
| `-e PING=1` | `/_ping` |
| `-e PLUGINS=0` | `/plugins` |
| `-e POST=0` | 设置为`0`时，仅允许`GET`和`HEAD`操作，使API访问变为只读。 |
| `-e SECRETS=0` | `/secrets` |
| `-e SERVICES=0` | `/services` |
| `-e SESSION=0` | `/session` |
| `-e SWARM=0` | `/swarm` |
| `-e SYSTEM=0` | `/system` |
| `-e TASKS=0` | `/tasks` |
| `-e TZ=Etc/UTC` | `设置容器时区` |
| `-e VERSION=1` | `/version` |
| `-e VOLUMES=0` | `/volumes` |
| `-v /var/run/docker.sock:ro` | 将主机docker socket挂载到容器中。 |
| `--read-only` | 使容器文件系统为只读。 |
| `--tmpfs /run` | 将/run挂载到tmpfs（RAM）中以使其可写。 |

### 参数建议

如果需要将docker socket代理作为服务运行，建议配置以下参数以获得完整功能：

- `CONTAINERS=1` - 允许容器操作
- `NETWORKS=1` - 允许网络操作  
- `EVENTS=1` - 启用事件监控
- `PING=1` - 允许ping操作
- `POST=1` - 允许写操作（创建、修改、删除）

这些参数组合提供了完整的Docker API访问能力，适用于大多数容器管理场景。