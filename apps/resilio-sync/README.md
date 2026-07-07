# Resilio-sync

Resilio-sync（原名 BitTorrent Sync）使用 BitTorrent 协议在您的所有设备之间同步文件和文件夹。有免费版和付费版，并且支持这两种版本。官方已放弃V3版本的Docker镜像支持，本版本基于最新发布的v3 Linux版本构建，镜像来自[https://www.linuxserver.io/](https://www.linuxserver.io/)

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/ResilioSync.png)

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)

当前版本支持用户映射，简化文件映射和卷的权限管理

### 端口（-p）

| 端口        | 功能      |
| ----------- | --------- |
| 8888:8888   | WebUI端口 |
| 55555:55555 | 同步端口  |

### 环境变量（-e）

| 环境             | 功能             |
| ---------------- | ---------------- |
| PUID=1000        | UserID           |
| PGID=1000        | GroupID          |
| TZ=Asia/Shanghai | 指定要使用的时区 |

### 文件映射( -v)

| 文件目录               | 介绍                      |
| ---------------------- | ------------------------- |
| ./data/config:/config    | resilio-sync 配置文件位置 |
| ./data/downloads:/downloads | 下载/缓存文件夹           |
| ./data/sync:/sync       | 同步文件夹根目录          |



