# Ignis - 在浏览器中运行 Obsidian

Ignis 是一个兼容层，为 Obsidian 使用的 Electron API 提供浏览器兼容实现，让 Obsidian 在标准浏览器中运行，同时将你的笔记库保留在服务器上。Obsidian 不包含在镜像中，容器首次启动时会从官方源下载 Obsidian。

## 使用方式

1. 安装后访问 `http://<你的IP>:8080`，首次启动需等待 1-2 分钟下载 Obsidian。
2. 默认 `PUID/PGID` 为 1000，请按宿主机实际用户调整（运行 `id` 查看）。
3. 首次打开会进入笔记库管理器，创建你的第一个笔记库即可开始使用。

> [!IMPORTANT]
> 暴露到公网或局域网前，请在前面加上鉴权并通过 HTTPS 访问。Ignis 自身没有内置鉴权，任何能访问到实例的人都可读写整个笔记库；且在非安全上下文（非 HTTPS 或非 localhost）下浏览器会禁用部分必需功能。

## 主要特性

- 核心 Obsidian 功能：编辑器、画布、Bases、命令面板、主题与 CSS 片段。
- 大部分基于 Obsidian 插件 API 的社区插件（需 Node 原生模块或 `child_process` 的插件除外）。
- 文件上传与下载，多笔记库支持（创建、打开、切换、重命名、删除）。
- 浏览器标签页间通过 WebSocket 实时同步，编辑在秒级内传播。
- 支持 Obsidian Sync 与无标签页的服务端 Headless Sync。

## 文档

- 官网：<https://ignis.thiefling.com/>
- 部署指南：<https://ignis.thiefling.com/docs/server/deploy/>
- GitHub：<https://github.com/Nystik-gh/ignis>
