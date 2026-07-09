# PandaWiki

PandaWiki 是一款 AI 大模型驱动的开源知识库搭建系统，可用于构建产品文档、技术文档、FAQ、博客系统，并提供 AI 创作、AI 问答、AI 搜索等能力。

## 使用说明

- 安装后通过 `https://服务器地址:管理后台 HTTPS 端口` 访问管理后台，默认端口为 `2443`。
- 首次登录使用安装表单中填写的“管理后台密码”。请妥善保存该密码。
- 内部服务密码请使用长度大于 8 位的随机字符串，建议仅包含数字和字母。
- `容器子网前缀` 默认使用 `169.254.15`，如与宿主机或其他容器网络冲突，可在安装前调整。
- 安装完成后需要在 PandaWiki 管理后台配置大模型服务并创建知识库。

## 数据目录

应用数据保存在版本目录下的 `data/` 中，包括 PostgreSQL、Redis、MinIO、NATS、Qdrant、RagLite、Nginx/Caddy 配置与证书等运行数据。

## 官方文档

- 安装文档：https://pandawiki.docs.baizhi.cloud/node/01971602-bb4e-7c90-99df-6d3c38cfd6d5
- 项目仓库：https://github.com/chaitin/PandaWiki
