# MyIP

MyIP is an open-source IP and network toolbox for checking local IPv4/IPv6 addresses, IP information, WebRTC detection, DNS leak tests, website availability, speed tests, global latency, MTR, Whois, MAC lookup, browser fingerprinting and more.

## Usage

- After installation, open `http://server-address:web-port`. The default port is `18966`.
- For more complete IP geolocation, ASN and organization lookup features, configure MaxMind Account ID and License Key in the install form and enable MaxMind database auto update.
- Other third-party API keys are optional and only enhance the related lookup features.
- MaxMind and CAIDA datasets are persisted under the version `data/` directory to avoid re-downloading after container recreation.
- `Allowed Domains` accepts a comma-separated domain list to restrict backend API access origins. Leave it empty to disable this restriction.
- API rate limiting, slowdown thresholds and log level can be configured as needed. Rate-limit logs are persisted under `data/logs/`.

## Resources

- Demo: https://ipcheck.ing
- Repository: https://github.com/jason5ng32/MyIP
- Docker image: https://hub.docker.com/r/jason5ng32/myip
