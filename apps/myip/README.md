# MyIP

MyIP 是一个开源 IP 与网络检测工具箱，可用于查看本机 IPv4/IPv6、查询 IP 信息，并提供 WebRTC 检测、DNS 泄露检测、网站可用性检测、网络测速、全球延迟测试、MTR、Whois、MAC 查询、浏览器指纹等工具。

## 使用说明

- 安装后通过 `http://服务器地址:Web 端口` 访问，默认端口为 `18966`。
- 如需更完整的 IP 地理位置、ASN 与组织归属查询能力，建议在安装表单中填写 MaxMind Account ID 与 License Key，并开启 MaxMind 数据库自动更新。
- 其他第三方 API Key 均为可选项，仅用于增强对应查询能力。
- MaxMind 与 CAIDA 数据集会持久化到应用版本目录下的 `data/` 中，避免容器重建后重复下载。
- `允许访问的域名` 可填写英文逗号分隔的域名列表，用于限制后端 API 访问来源；留空表示不限制。
- 可按需配置 API 速率限制、延迟阈值与日志级别；限流日志会持久化到 `data/logs/`。

## 官方资源

- 在线演示：https://ipcheck.ing
- 项目仓库：https://github.com/jason5ng32/MyIP
- Docker 镜像：https://hub.docker.com/r/jason5ng32/myip
