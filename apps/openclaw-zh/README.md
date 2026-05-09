# OpenClaw Chinese

OpenClaw Chinese 是 OpenClaw 的汉化发行版。OpenClaw 是开源、自托管的个人 AI 助理，提供本地运行的 Web Dashboard 和 Gateway。

## 使用说明

安装后访问 `http://服务器 IP:端口` 打开 Dashboard。默认端口为 `18789`。

建议在安装参数中设置 `OPENCLAW_GATEWAY_TOKEN`，用于 Dashboard 访问认证。浏览器打开页面后，可以在 URL 后追加 `?token=你的令牌` 进行访问。

## 数据目录

应用数据会持久化到安装目录下的 `data/conf`，对应容器内 `/root/.openclaw`。

## 参考

- 项目仓库：https://github.com/1186258278/OpenClawChineseTranslation
- Docker 说明：https://github.com/1186258278/OpenClawChineseTranslation/blob/main/DOCKER_README.md
- OpenClaw 官网：https://openclaw.ai/
