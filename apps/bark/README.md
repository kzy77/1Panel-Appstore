# Bark

Bark 是一款注重隐私、免费开源的 iOS 推送通知服务。安装 Bark App 并注册设备后，即可通过简单的 HTTP 接口向自己的 iPhone 推送自定义通知。

## 使用说明

- 安装后通过 `http://服务器地址:Web 端口` 访问 Web 控制台，默认端口为 `8080`。
- 首次使用请在 iPhone 上安装 Bark App，将推送服务器地址改为 `http://服务器地址:Web 端口` 并注册设备，即可获得本机专属的设备 key。
- 推送 URL 格式为 `/:key/:title/:body`，示例：

  ```sh
  curl "http://服务器地址:8080/your_key/标题/推送内容?group=分组&copy=复制"
  ```

- 也支持 POST JSON 请求（`body`、`title`、`badge`、`sound`、`group`、`url`、`icon` 等参数），详见官方文档。
- 可选配置：
  - `数据库链接`：填写 MySQL DSN（格式 `user:pass@tcp(host:port)/dbname`）可使用外部数据库保存推送历史；留空则使用内置默认存储。
  - `用户名`/`密码`（服务基础验证）：启用后请求需携带 `Basic` 认证头（`Basic base64(username:password)`）。
- 推送历史等数据持久化在应用版本目录下的 `data/` 中，容器重建不会丢失。

## 官方资源

- 官方文档：https://bark.day.app/
- 项目仓库：https://github.com/Finb/bark-server
- Docker 镜像：https://hub.docker.com/r/finab/bark-server
