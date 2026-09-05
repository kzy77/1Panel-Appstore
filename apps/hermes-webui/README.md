# Hermes WebUI

Hermes WebUI 是 [Hermes Agent](https://hermes-agent.nousresearch.com/) 的 Web 界面（第三方项目），通过浏览器或手机即可使用 Hermes Agent。单容器部署，容器内同时运行 Agent 与 Web 界面。

## 使用说明

- 安装后通过 `http://服务器地址:Web 端口` 访问，默认端口为 `8787`。
- **前置要求**：宿主机上需已安装 Hermes Agent，并存在 Hermes 数据目录（`~/.hermes`）与工作区目录。安装时填写对应的宿主机绝对路径：
  - `Hermes 数据目录`：Hermes Agent 配置、会话与状态所在目录，默认 `/root/.hermes`，将挂载到容器内 `/home/hermeswebui/.hermes`。
  - `工作区目录`：文件浏览器展示的代码/项目目录，默认 `/root/workspace`，将挂载到容器内 `/workspace`。
- `UID`/`GID`：容器会以该 UID/GID 运行，请与 `.hermes` 目录的属主一致（用 `id -u` / `id -g` 查看），否则可能因权限问题无法读取配置或写入会话。
- **密码认证**：如果端口暴露在公网，务必设置 `WebUI 密码`（未设置密码时任何能访问该端口的人都可以以 Agent 身份执行命令）。
- 会话、工作区与状态存储于挂载的 Hermes 数据目录中，容器重建不会丢失。
- 健康检查：`curl http://127.0.0.1:8787/health`

## 注意事项

- 镜像由项目作者发布到 GHCR（`ghcr.io/nesquena/hermes-webui`），amd64 + arm64。
- 本包与仓库中已有的 `hermes-web-ui`（社区 fork 版，双容器、端口 6060）是两个不同的应用，请勿混淆。

## 项目资源

- 项目仓库：https://github.com/nesquena/hermes-webui
- 镜像：https://ghcr.io/nesquena/hermes-webui
