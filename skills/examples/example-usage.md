# 使用示例

## 示例 1：从 GitHub 项目生成

```bash
# 输入
./scripts/generate-app.sh https://github.com/alist-org/alist

# 输出
./apps/alist/v3.45.0/
├── data.yml
├── docker-compose.yml
├── logo.png
├── README.md
└── README_en.md
```

### 生成的 data.yml

```yaml
name: AList
tags:
    - 实用工具
    - 云存储
title: AList - 文件列表程序
description: 支持多存储的文件列表程序和私人网盘
additionalProperties:
    key: alist
    name: AList
    tags:
        - Storage
        - Tool
    shortDescZh: 支持多存储的文件列表程序和私人网盘
    shortDescEn: Supporting multi-storage file listing program
    website: https://alist.nn.ci/
    github: https://github.com/alist-org/alist
```

### 生成的 docker-compose.yml

```yaml
services:
  alist:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "${PANEL_APP_PORT_HTTP}:5244"
    volumes:
      - ./data/data:/opt/alist/data
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    image: xhofe/alist:v3.45.0
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
```

---

## 示例 2：从 docker run 命令生成

```bash
# 输入
./scripts/generate-app.sh "docker run -d --name=nginx -p 80:80 nginx:latest"

# 输出
./apps/nginx/latest/
├── data.yml
├── docker-compose.yml
├── logo.png
├── README.md
└── README_en.md
```

### 生成的 docker-compose.yml

```yaml
services:
  nginx:
    container_name: ${CONTAINER_NAME}
    restart: always
    networks:
      - 1panel-network
    ports:
      - "${PANEL_APP_PORT_HTTP}:80"
    volumes:
      - ./data/data:/app/data
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    image: nginx:latest
    labels:
      createdBy: "Apps"
networks:
  1panel-network:
    external: true
```

---

## 示例 3：从 docker-compose 文件链接生成

```bash
# 输入
./scripts/generate-app.sh https://raw.githubusercontent.com/portainer/portainer/develop/docker-compose.yml

# 输出
./apps/portainer/latest/
├── data.yml
├── docker-compose.yml
├── logo.png
├── README.md
└── README_en.md
```

---

## 示例 4：从本地文件生成

```bash
# 创建测试文件
cat > /tmp/test-compose.yml << 'EOF'
version: '3'
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  redis-data:
EOF

# 运行脚本
./scripts/generate-app.sh /tmp/test-compose.yml ./my-apps

# 输出
./my-apps/redis/7-alpine/
├── data.yml
├── docker-compose.yml
├── logo.png
├── README.md
└── README_en.md
```

---

## 示例 5：单独下载图标

```bash
# 下载 Redis 图标
./scripts/download-icon.sh redis ./redis-logo.png 200

# 输出
✓ 从 Simple Icons 下载成功
✓ 图标下载完成: ./redis-logo.png
```

---

## 示例 6：自定义输出目录

```bash
# 输出到指定目录
./scripts/generate-app.sh https://github.com/portainer/portainer ~/my-1panel-apps

# 输出
/Users/username/my-1panel-apps/portainer/latest/
├── data.yml
├── docker-compose.yml
├── logo.png
├── README.md
└── README_en.md
```

---

## 完整工作流程示例

```bash
# 1. 生成应用配置
./scripts/generate-app.sh https://github.com/alist-org/alist

# 2. 查看生成的文件
cd ./apps/alist/v3.45.0
cat data.yml
cat docker-compose.yml

# 3. 手动优化配置
# - 补充应用描述
# - 添加合适的标签
# - 替换 logo.png

# 4. 测试 docker-compose
docker-compose up -d

# 5. 确认无误后，提交到应用商店
git add .
git commit -m "feat: add alist app"
git push
```

---

## 故障排除

### 问题：图标下载失败

```bash
# 手动下载图标
# 访问：https://dashboardicons.com/icons?q=alist
# 下载后保存为 logo.png
```

### 问题：端口冲突

```bash
# 修改 docker-compose.yml 中的端口映射
ports:
  - "${PANEL_APP_PORT_HTTP}:5244"  # 修改此处
```

### 问题：镜像版本不对

```bash
# 手动编辑 docker-compose.yml
image: xhofe/alist:v3.45.0  # 修改版本号
```
