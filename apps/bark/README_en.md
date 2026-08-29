# Bark

Bark is a privacy-focused, free and open-source iOS push notification service. After installing the Bark app and registering a device, you can send custom notifications to your iPhone via simple HTTP endpoints.

## Usage

- After installation, open the Web console at `http://server-address:web-port`. The default port is `8080`.
- On first use, install the Bark app on your iPhone, change the push server address to `http://server-address:web-port`, and register your device to get its dedicated device key.
- Push URL format is `/:key/:title/:body`, for example:

  ```sh
  curl "http://server-address:8080/your_key/Title/Message?group=group&copy=copy"
  ```

- POST JSON requests are also supported (`body`, `title`, `badge`, `sound`, `group`, `url`, `icon`, etc.). See the official docs for details.
- Optional configuration:
  - `Database URL`: a MySQL DSN (`user:pass@tcp(host:port)/dbname`) to store push history in an external database; leave empty to use the built-in default storage.
  - `Basic Auth User`/`Password`: when enabled, requests must carry a `Basic` auth header (`Basic base64(username:password)`).
- Push history and other data are persisted under the version `data/` directory and survive container recreation.

## Resources

- Documentation: https://bark.day.app/
- Repository: https://github.com/Finb/bark-server
- Docker image: https://hub.docker.com/r/finab/bark-server
