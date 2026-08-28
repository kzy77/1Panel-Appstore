# Nitter 介绍

## 产品介绍

Nitter 是一款免费开源、注重隐私的 Twitter/X 替代前端。它不依赖 JavaScript、无广告、无追踪、无付费墙，无需登录即可浏览推文、时间线和搜索内容，适合自建部署后匿名使用 Twitter/X。

本应用同时内置 Redis 服务用于缓存，安装后开箱即用，无需在 1Panel 中单独安装 Redis。

## ⚠️ 重要：需要配置 Twitter 会话

当前版本的 Nitter **必须** 提供 Twitter 账号会话文件 `sessions.jsonl` 才能启动并访问 Twitter API，已无匿名/游客模式。该文件需要你使用真实的 Twitter 账号生成一次：

```bash
# 克隆 Nitter 仓库并安装依赖
git clone https://github.com/zedeus/nitter && cd nitter
pip install -r tools/requirements.txt

# 创建账号文件 accounts.json（可填写一个或多个账号）
cat > accounts.json <<EOF
[{"username": "你的推特用户名", "password": "你的推特密码", "totp": "TOTP密钥(如开启两步验证)"}]
EOF

# 生成会话并追加到 sessions.jsonl
python3 tools/create_sessions_browser.py accounts.json --append sessions.jsonl
```

将生成的 `sessions.jsonl` 内容放置到应用目录的 `data/sessions.jsonl`（替换安装时生成的空文件），然后重启应用。会话过期失效后需重新生成并替换。

> 说明：本应用安装时会生成一个空的 `sessions.jsonl` 占位文件，仅用于保证容器能正常启动；未放入真实会话前，页面能打开但无法加载推文数据。

## 主要功能

- **隐私友好**：无需登录、无追踪、无广告、无 JavaScript
- **简洁快速**：页面轻量，浏览推文和媒体更省流量
- **RSS 支持**：内置 RSS 订阅，可订阅用户、列表和搜索关键词
- **多主题**：支持多套界面主题，可自定义替换链接与偏好设置
- **内置 Redis 缓存**：提升访问性能，减少对 Twitter/X 的重复请求
- **多架构支持**：镜像同时支持 amd64 与 arm64

## 使用说明

1. 安装后访问 `http://服务器IP:端口`。
2. 主要配置均保存在 `nitter.conf` 文件中，位于应用安装目录的 `data/` 文件夹下：
   - 修改 `[Server]` 中的 `hostname` 为你的域名或 IP，用于生成正确链接。
   - 修改 `[Config]` 中的 `hmacKey` 为随机值（可用 `openssl rand -hex 32` 生成），用于签名媒体链接。
   - 如需 HTTPS 访问，建议通过反向代理（如 1Panel 网站）配置，并将 `https` 保持为 `false`。
3. 修改配置或更换 `sessions.jsonl` 后需重启应用生效。
4. Redis 数据保存在 `data/redis` 目录下，缓存可安全清理，不影响使用。

## 注意事项

- `nitter.conf` 与 `sessions.jsonl` 必须存在，请勿删除或将其改名为目录。
- `sessions.jsonl` 为空时应用能启动，但无法加载推文，必须放入真实会话。

## 相关链接

- [Nitter 官方仓库](https://github.com/zedeus/nitter)
- [Nitter 官方文档](https://github.com/zedeus/nitter/blob/master/README.md)
- [会话生成工具](https://github.com/zedeus/nitter/tree/master/tools)
