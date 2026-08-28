# Nitter Introduction

## Overview

Nitter is a free and open-source, privacy-focused alternative Twitter/X front-end. It does not rely on JavaScript, shows no ads, performs no tracking, and has no paywalls. You can browse tweets, timelines and search results without logging in, making it ideal for anonymous self-hosted access to Twitter/X.

This app also bundles a Redis service for caching, so it works out of the box without installing Redis separately in 1Panel.

## ⚠️ Important: Twitter sessions required

The current Nitter **requires** a Twitter account session file `sessions.jsonl` to start and to access the Twitter API — there is no anonymous/guest mode anymore. You need to generate it once with a real Twitter account:

```bash
# Clone the Nitter repo and install dependencies
git clone https://github.com/zedeus/nitter && cd nitter
pip install -r tools/requirements.txt

# Create an accounts file accounts.json (one or more accounts)
cat > accounts.json <<EOF
[{"username": "your_twitter_username", "password": "your_twitter_password", "totp": "TOTP_secret_if_2FA"}]
EOF

# Generate sessions and append to sessions.jsonl
python3 tools/create_sessions_browser.py accounts.json --append sessions.jsonl
```

Put the generated `sessions.jsonl` content into `data/sessions.jsonl` under the app directory (replacing the empty file created at install), then restart the app. When sessions expire, regenerate and replace the file.

> Note: Installation ships an empty `sessions.jsonl` placeholder so the container can start cleanly. Until real sessions are added, the page opens but cannot load tweet data.

## Key Features

- **Privacy-friendly**: No login, no tracking, no ads, no JavaScript
- **Lightweight & fast**: Minimal pages, less bandwidth when browsing tweets and media
- **RSS support**: Built-in RSS feeds for users, lists and search keywords
- **Multiple themes**: Several interface themes, customizable link replacement and preferences
- **Bundled Redis cache**: Better performance, fewer repeated requests to Twitter/X
- **Multi-architecture**: Image supports both amd64 and arm64

## Usage

1. After installation, visit `http://server-ip:port`.
2. Most configuration lives in `nitter.conf`, under the `data/` folder of the app directory:
   - Set `hostname` under `[Server]` to your domain or IP so links are generated correctly.
   - Set `hmacKey` under `[Config]` to a random value (e.g. `openssl rand -hex 32`) to sign media URLs.
   - For HTTPS, use a reverse proxy (e.g. a 1Panel website) and keep `https` set to `false`.
3. Restart the app after changing the configuration or replacing `sessions.jsonl`.
4. Redis data is stored in `data/redis`; the cache can be safely cleared without affecting usage.

## Notes

- `nitter.conf` and `sessions.jsonl` must exist; do not delete them or turn them into directories.
- With an empty `sessions.jsonl` the app starts but cannot load tweets; real sessions are required.

## Links

- [Nitter repository](https://github.com/zedeus/nitter)
- [Nitter documentation](https://github.com/zedeus/nitter/blob/master/README.md)
- [Session generation tools](https://github.com/zedeus/nitter/tree/master/tools)
