# 星空组网（StarVPN）

星空组网 Docker 客户端适合云服务器、轻量 Linux 主机和 NAS 容器环境部署。容器启动后会在日志中输出控制台访问地址，使用浏览器打开控制台并登录成员账号后，当前 Docker 宿主机会加入组网。

## 部署说明

本应用按官方 Docker 文档配置：

- 镜像：`registry.cn-beijing.aliyuncs.com/ld_beijing/stars.client`
- 网络模式：`host`
- 特权模式：启用
- 重启策略：`always`

官方示例命令：

```bash
docker run -d --privileged --net=host --name stars.client --restart=always registry.cn-beijing.aliyuncs.com/ld_beijing/stars.client:latest
```

## 首次使用

1. 在 1Panel 中安装并启动应用。
2. 查看容器日志，复制日志中输出的控制台访问地址：

   ```bash
   docker logs <容器名>
   ```

3. 在浏览器中打开控制台地址，使用星空组网成员账号登录。
4. 登录后确认设备在线，并记录组网 IP；后续访问宿主机和其上服务时可使用该组网 IP 与原端口。

## 注意事项

- 官方 Docker 部署使用宿主机网络栈，因此本应用不提供端口映射配置。
- 成员账号和密码需要在容器启动后进入控制台登录，不通过环境变量预设。
- 若需要移除客户端，可在 1Panel 中卸载应用或删除对应容器。

## 官方文档与支持

- 官网：[https://starvpn.cn/](https://starvpn.cn/)
- Docker 文档：[https://doc.starvpn.cn/#/docker](https://doc.starvpn.cn/#/docker)
