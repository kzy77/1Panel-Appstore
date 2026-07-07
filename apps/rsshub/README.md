## 产品介绍

RSSHub 是一款开源、可自行部署的通用 RSS 内容聚合器。它将“万物皆可 RSS”的理念变为现实，能够从各类网站、社交媒体、新闻平台等数千种数据源中抓取内容并生成标准 RSS 输出。

本应用使用 RSSHub 官方 `chromium-bundled` 镜像，内置浏览器运行环境；同时在编排中内置 Redis 服务用于缓存，无需在 1Panel 中单独安装 Redis。

## 主要功能

- 万物皆可 RSS：支持从大量网站和平台生成 RSS 订阅源
- 开箱即用的路由库：覆盖新闻、博客、社交媒体、论坛、视频平台等场景
- 自托管部署：通过 Docker 快速运行，数据和缓存由本地实例掌控
- 内置 Redis 缓存：提升请求性能并减少对源站的重复访问
- Chromium bundled：适合需要浏览器环境的路由，无需额外 Browserless 服务
- 配套生态：可搭配 RSSHub Radar、Folo 等工具使用

## 使用说明

1. 安装后访问 `http://服务器IP:端口`。
2. RSSHub 路由和参数请参考官方文档：<https://docs.rsshub.app/guide/>。
3. Redis 已作为应用内部服务随 RSSHub 一起启动，缓存数据保存在应用目录的 `data/redis` 下。
4. 如需调整高级配置，可在安装后按 RSSHub 官方环境变量说明扩展 compose 配置。
