# Sub2API

AI API 网关平台，用于分发和管理 AI 产品订阅的 API 配额。

## 功能特点

- 多账号管理 - 支持多种上游账号类型（OAuth、API Key）
- API Key 分发 - 为用户生成和管理 API Key
- 精确计费 - Token 级别使用追踪和费用计算
- 智能调度 - 智能账号选择，支持粘性会话
- 并发控制 - 支持用户级和账号级并发限制
- 限流 - 可配置的请求和 Token 限流
- 管理后台 - Web 界面用于监控和管理
- 外部系统集成 - 支持通过 iframe 嵌入外部系统

## 快速开始

### 默认端口

- Web 界面: 8080

### 初始化配置

部署完成后，访问 `http://YOUR_SERVER_IP:8080` 进入设置向导。

**数据库连接设置：**
- PostgreSQL 主机: `postgres`（Docker 网络内使用服务名，不是 localhost）
- Redis 主机: `redis`（Docker 网络内使用服务名，不是 localhost）
- PostgreSQL 密码: 请使用强密码

**JWT 密钥要求：**
- 长度必须至少 32 字符
- 生产环境请使用随机生成的强密码

### 数据目录

应用数据存储在 Docker 命名卷中：
- `postgres_data` - PostgreSQL 数据库数据
- `redis_data` - Redis 缓存数据
- `./data` - 应用配置和数据

## 相关链接

- 官方网站: https://sub2api.org
- GitHub: https://github.com/Wei-Shaw/sub2api
- 在线演示: https://demo.sub2api.org/

## 注意事项

1. **数据库连接**：在 Docker 部署中，PostgreSQL 和 Redis 使用服务名（`postgres`、`redis`）进行连接，请勿使用 `localhost`

2. **JWT 密钥**：必须至少 32 字符，建议使用随机字符串

3. **首次部署**：如果遇到数据库连接错误，请确保：
   - PostgreSQL 容器已完全启动（等待约 10-30 秒）
   - 旧的损坏数据卷已清除（使用 `docker compose down -v`）

4. **安全提醒**：
   - 本项目仅供个人学习使用
   - 使用者必须在遵循 Anthropic、OpenAI 等服务条款的情况下使用
   - 请勿用于非法用途