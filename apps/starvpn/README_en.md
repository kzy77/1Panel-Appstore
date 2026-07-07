# StarVPN

The StarVPN Docker client is intended for cloud servers, lightweight Linux hosts, and NAS container environments. After the container starts, it prints the console URL in the container logs. Open that URL in a browser and sign in with a StarVPN member account to bind the Docker host to your network.

## Deployment Notes

This app follows the official Docker documentation:

- Image: `registry.cn-beijing.aliyuncs.com/ld_beijing/stars.client`
- Network mode: `host`
- Privileged mode: enabled
- Restart policy: `always`

Official example command:

```bash
docker run -d --privileged --net=host --name stars.client --restart=always registry.cn-beijing.aliyuncs.com/ld_beijing/stars.client:latest
```

## First Use

1. Install and start the app in 1Panel.
2. Check the container logs and copy the console URL:

   ```bash
   docker logs <container-name>
   ```

3. Open the console URL in a browser and sign in with a StarVPN member account.
4. After the device is online, note its private-network IP. You can then access the host and its services through that IP with the original service ports.

## Notes

- The official Docker deployment uses the host network stack, so this app does not expose configurable port mappings.
- Member credentials are entered in the web console after startup; they are not preconfigured with environment variables.
- To remove the client, uninstall the app in 1Panel or remove the container.

## Official Resources

- Website: [https://starvpn.cn/](https://starvpn.cn/)
- Docker documentation: [https://doc.starvpn.cn/#/docker](https://doc.starvpn.cn/#/docker)
