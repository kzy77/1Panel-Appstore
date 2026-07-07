## Introduction

RSSHub is an open-source, self-hosted universal RSS content aggregator. It turns “Everything is RSSible” into reality by generating standard RSS feeds from thousands of websites, social platforms, news sources, forums, and more.

This app uses the official RSSHub `chromium-bundled` image and includes an internal Redis service for cache. You do not need to install Redis separately in 1Panel.

## Features

- Everything is RSSible: generate RSS feeds from many websites and platforms
- Rich route ecosystem maintained by the community
- Self-hosted Docker deployment
- Built-in Redis cache for better performance and fewer repeated source requests
- Chromium bundled image for routes that need a browser runtime, without an extra Browserless service
- Works well with RSSHub Radar, Folo, and other RSS tools

## Usage

1. Open `http://SERVER_IP:PORT` after installation.
2. Check the official documentation for routes and parameters: <https://docs.rsshub.app/guide/>.
3. Redis runs as an internal service and stores cache data under `data/redis` in the app directory.
4. For advanced options, extend the compose file according to the official RSSHub environment variable documentation.
