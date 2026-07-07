# Resilio Sync

Resilio Sync (formerly BitTorrent Sync) synchronizes files and folders across devices using the BitTorrent protocol. This package uses the LinuxServer.io container image.

![](https://cdn.jsdelivr.net/gh/xiaoY233/PicList@main/public/assets/ResilioSync.png)

![](https://img.shields.io/badge/Copyright-arch3rPro-ff9800?style=flat&logo=github&logoColor=white)

The pinned version supports user and group mapping to simplify volume permissions.

### Ports (`-p`)

| Port | Description |
| ---- | ----------- |
| 8888:8888 | Web UI port |
| 55555:55555 | Sync port |

### Environment variables (`-e`)

| Variable | Description |
| -------- | ----------- |
| PUID=1000 | User ID |
| PGID=1000 | Group ID |
| TZ=Asia/Shanghai | Time zone |

### Volumes (`-v`)

| Path | Description |
| ---- | ----------- |
| ./data/config:/config | Resilio Sync configuration |
| ./data/downloads:/downloads | Downloads/cache directory |
| ./data/sync:/sync | Root sync directory |
