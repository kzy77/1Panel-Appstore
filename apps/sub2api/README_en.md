# Sub2API

AI API Gateway Platform for subscription quota distribution.

## Features

- Multi-Account Management - Support multiple upstream account types (OAuth, API Key)
- API Key Distribution - Generate and manage API Keys for users
- Precise Billing - Token-level usage tracking and cost calculation
- Smart Scheduling - Intelligent account selection with sticky sessions
- Concurrency Control - Per-user and per-account concurrency limits
- Rate Limiting - Configurable request and token rate limits
- Admin Dashboard - Web interface for monitoring and management
- External System Integration - Embed external systems via iframe

## Quick Start

### Default Port

- Web UI: 8080

### Initial Setup

After deployment, access `http://YOUR_SERVER_IP:8080` to run the setup wizard.

**Database Connection Settings:**
- PostgreSQL Host: `postgres` (use service name in Docker network, NOT localhost)
- Redis Host: `redis` (use service name in Docker network, NOT localhost)
- PostgreSQL Password: Please use a strong password

**JWT Secret Requirements:**
- Length must be at least 32 characters
- Use a randomly generated strong password for production

### Data Directory

Application data is stored in Docker named volumes:
- `postgres_data` - PostgreSQL database data
- `redis_data` - Redis cache data
- `./data` - Application configuration and data

## Links

- Website: https://sub2api.org
- GitHub: https://github.com/Wei-Shaw/sub2api
- Demo: https://demo.sub2api.org/

## Important Notes

1. **Database Connection**: In Docker deployment, PostgreSQL and Redis use service names (`postgres`, `redis`) for connection. Do NOT use `localhost`

2. **JWT Secret**: Must be at least 32 characters, use a random string recommended

3. **First Deployment**: If you encounter database connection errors, ensure:
   - PostgreSQL container has fully started (wait about 10-30 seconds)
   - Old corrupted data volumes are cleared (use `docker compose down -v`)

4. **Disclaimer**:
   - This project is for personal learning purposes only
   - Users must comply with the Terms of Service of Anthropic, OpenAI, etc.
   - Do not use for illegal purposes