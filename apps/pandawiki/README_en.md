# PandaWiki

PandaWiki is an open-source AI-powered knowledge base system for product documentation, technical docs, FAQ and blogs. It provides AI writing, AI Q&A and AI search capabilities.

## Usage

- After installation, open `https://server-address:admin-https-port`. The default port is `2443`.
- Use the admin password configured in the 1Panel install form for the first login. Keep it safe.
- Internal service passwords should be random strings longer than 8 characters. Alphanumeric strings are recommended.
- The default container subnet prefix is `169.254.15`. Change it before installation if it conflicts with another network on the host.
- After installation, configure an LLM provider and create a knowledge base in the PandaWiki admin console.

## Data directory

Runtime data is persisted under the version `data/` directory, including PostgreSQL, Redis, MinIO, NATS, Qdrant, RagLite, Nginx/Caddy configuration and certificates.

## Documentation

- Installation guide: https://pandawiki.docs.baizhi.cloud/node/01971602-bb4e-7c90-99df-6d3c38cfd6d5
- Repository: https://github.com/chaitin/PandaWiki
