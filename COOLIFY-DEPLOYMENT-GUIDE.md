# Cipher Coolify Deployment Guide

Complete step-by-step guide for deploying Cipher to Coolify with Trae IDE integration.

## Prerequisites

- Coolify instance running
- GitHub/GitLab repository access
- PostgreSQL database (Supabase recommended)
- API keys for your chosen LLM provider
- Trae IDE API key (if using Trae MCP integration)

## Phase 1: Repository Preparation

### 1.1 Fork and Clone Repository

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/cipher.git
cd cipher

# Add upstream remote for updates
git remote add upstream https://github.com/byterover/cipher.git
```

### 1.2 Environment Configuration

The project is already configured with production-ready files:

- ✅ `.env.production` - Production environment variables
- ✅ `config/production-config.yml` - Agent configuration
- ✅ `docker-compose.production.yml` - Coolify deployment config
- ✅ `memAgent/cipher.yml` - Updated with Gemini LLM

### 1.3 Update Environment Variables

Edit `.env.production` and replace placeholder values:

```bash
# Required: LLM API Keys (choose one or more)
GEMINI_API_KEY=your-actual-gemini-api-key
OPENAI_API_KEY=your-actual-openai-api-key
ANTHROPIC_API_KEY=your-actual-anthropic-api-key

# Required: Database Configuration
CIPHER_PG_URL=postgresql://postgres:your-db-password@your-db-host:5432/cipher
VECTOR_STORE_URL=postgresql://postgres:your-db-password@your-db-host:5432/cipher

# Optional: Trae IDE Integration
TRAE_API_KEY=your-trae-api-key

# Optional: Additional providers
OPENROUTER_API_KEY=your-openrouter-api-key
DEEPSEEK_API_KEY=your-deepseek-api-key
VOYAGE_API_KEY=your-voyage-api-key
```

### 1.4 Database Setup (Supabase Recommended)

#### Option A: Supabase (Recommended)

1. Create a new Supabase project
2. Go to Settings → Database
3. Copy the connection string
4. Enable pgvector extension:

```sql
-- Run in Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS vector;
```

#### Option B: Self-hosted PostgreSQL

```sql
-- Create database and user
CREATE DATABASE cipher;
CREATE USER cipher_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE cipher TO cipher_user;

-- Enable pgvector extension
\c cipher
CREATE EXTENSION IF NOT EXISTS vector;
```

### 1.5 Commit and Push Changes

```bash
# Add all configuration files
git add .
git commit -m "Configure Cipher for production deployment with Trae IDE integration"
git push origin main
```

## Phase 2: Coolify Deployment

### 2.1 Create New Application in Coolify

1. **Login to Coolify Dashboard**
2. **Create New Resource** → **Application**
3. **Choose Source**: GitHub/GitLab
4. **Select Repository**: Your forked cipher repository
5. **Branch**: `main`
6. **Build Pack**: Docker Compose

### 2.2 Configure Build Settings

**Build Configuration:**
- **Docker Compose File**: `docker-compose.production.yml`
- **Build Command**: `docker-compose -f docker-compose.production.yml build`
- **Start Command**: `docker-compose -f docker-compose.production.yml up -d`

### 2.3 Environment Variables Setup

In Coolify, go to **Environment Variables** and add:

#### Required Variables
```bash
# LLM Configuration
GEMINI_API_KEY=your-actual-gemini-api-key

# Database Configuration
CIPHER_PG_URL=postgresql://postgres:password@db-host:5432/cipher
VECTOR_STORE_URL=postgresql://postgres:password@db-host:5432/cipher

# Application Settings
NODE_ENV=production
CIPHER_LOG_LEVEL=info
REDACT_SECRETS=true
```

#### Optional Variables (Trae IDE Integration)
```bash
# Trae IDE MCP Integration
TRAE_API_KEY=your-trae-api-key

# Additional LLM Providers
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
OPENROUTER_API_KEY=your-openrouter-api-key
```

#### Advanced Configuration
```bash
# MCP Server Configuration
MCP_SERVER_MODE=default
MCP_TRANSPORT_TYPE=sse

# Performance Settings
CIPHER_WAL_FLUSH_INTERVAL=5000
CIPHER_MULTI_BACKEND=1

# Vector Store Settings
VECTOR_STORE_TYPE=pgvector
VECTOR_STORE_COLLECTION=knowledge_memory
VECTOR_STORE_DIMENSION=768
VECTOR_STORE_DISTANCE=Cosine

# Memory Configuration
SEARCH_MEMORY_TYPE=both
REFLECTION_VECTOR_STORE_COLLECTION=reflection_memory
DISABLE_REFLECTION_MEMORY=false

# Web Search (Optional)
WEB_SEARCH_ENABLE=true
WEB_SEARCH_ENGINE=duckduckgo
WEB_SEARCH_SAFETY_MODE=strict
WEB_SEARCH_MAX_RESULTS=2
WEB_SEARCH_RATE_LIMIT=10
```

### 2.4 Port Configuration

**Exposed Ports:**
- **3000**: Main API server (HTTP)
- **3001**: MCP server (HTTP/SSE)

**Port Mapping in Coolify:**
- Map port `3000` to your desired public port
- Optionally map port `3001` for direct MCP access

### 2.5 Health Check Configuration

Coolify will automatically use the health check defined in `docker-compose.production.yml`:

```yaml
healthcheck:
  test: ["CMD", "sh", "-c", "wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 2.6 Deploy Application

1. **Review Configuration**
2. **Click Deploy**
3. **Monitor Build Logs**
4. **Wait for Health Check to Pass**

## Phase 3: Trae IDE Integration

### 3.1 Configure Trae IDE MCP Connection

In Trae IDE, add Cipher as an MCP server:

```json
{
  "mcpServers": {
    "cipher": {
      "command": "curl",
      "args": [
        "-X", "GET",
        "https://your-cipher-domain.com/mcp/sse"
      ],
      "transport": "sse"
    }
  }
}
```

### 3.2 Alternative: Direct HTTP Integration

```bash
# Test MCP connection
curl -X POST https://your-cipher-domain.com/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "trae-ide", "version": "1.0.0"}}}'
```

## Phase 4: Verification and Testing

### 4.1 Health Check Verification

```bash
# Check application health
curl https://your-cipher-domain.com/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 3600,
  "version": "1.0.0",
  "websocket": {
    "enabled": true,
    "active": true
  }
}
```

### 4.2 API Endpoints Testing

```bash
# Test chat endpoint
curl -X POST https://your-cipher-domain.com/api/message \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, Cipher!", "sessionId": "test-session"}'

# Test MCP endpoint
curl https://your-cipher-domain.com/mcp/sse

# Test WebSocket stats
curl https://your-cipher-domain.com/ws/stats
```

### 4.3 Database Connection Verification

```bash
# Check logs for database connection
# In Coolify, go to Logs tab and look for:
# "[Database] Connected to PostgreSQL successfully"
# "[Vector Store] pgvector initialized successfully"
```

## Phase 5: Trae IDE Usage

### 5.1 Basic Chat Interface

Access the web UI at: `https://your-cipher-domain.com`

### 5.2 API Integration

```javascript
// Example: Integrate with Trae IDE
const cipherClient = {
  baseUrl: 'https://your-cipher-domain.com',
  
  async sendMessage(message, sessionId) {
    const response = await fetch(`${this.baseUrl}/api/message`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, sessionId })
    });
    return response.json();
  },
  
  async getHealth() {
    const response = await fetch(`${this.baseUrl}/health`);
    return response.json();
  }
};
```

### 5.3 MCP Tools Usage

Once connected to Trae IDE, Cipher provides:

- **Memory Management**: Store and retrieve coding context
- **Code Analysis**: Understand project structure
- **Documentation**: Generate and maintain docs
- **Workflow Automation**: Automate repetitive tasks

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed
```bash
# Check environment variables
echo $CIPHER_PG_URL

# Test database connection
psql $CIPHER_PG_URL -c "SELECT version();"
```

#### 2. Health Check Failing
```bash
# Check if application is running
curl -I https://your-cipher-domain.com/health

# Check Coolify logs for errors
# Look for port binding issues or startup errors
```

#### 3. MCP Connection Issues
```bash
# Test MCP endpoint directly
curl -v https://your-cipher-domain.com/mcp/sse

# Check CORS settings in production config
```

#### 4. Memory/Performance Issues
```bash
# Monitor resource usage in Coolify
# Adjust memory limits in docker-compose.production.yml
# Check vector store performance
```

### Log Analysis

**Key log patterns to monitor:**
```bash
# Successful startup
"API Server started on 0.0.0.0:3000"
"MCP SSE endpoints available"
"Database connected successfully"

# Error patterns
"Failed to connect to database"
"MCP server initialization failed"
"Health check timeout"
```

## Maintenance

### Regular Updates

```bash
# Update from upstream
git fetch upstream
git merge upstream/main
git push origin main

# Coolify will auto-deploy if configured
```

### Backup Strategy

1. **Database Backups**: Configure automatic Supabase backups
2. **Configuration Backups**: Keep `.env.production` and configs in secure storage
3. **Memory Data**: Vector store data is automatically persisted in PostgreSQL

### Monitoring

- **Health Endpoint**: Monitor `/health` for uptime
- **Database Performance**: Monitor PostgreSQL query performance
- **Memory Usage**: Track vector store size and performance
- **API Usage**: Monitor request rates and response times

## Security Considerations

1. **API Keys**: Store securely in Coolify environment variables
2. **Database**: Use strong passwords and SSL connections
3. **CORS**: Configure appropriate origins in production config
4. **Rate Limiting**: Enabled by default (1000 requests per 15 minutes)
5. **Secrets**: All sensitive data is automatically redacted in logs

## Support

- **Documentation**: [Cipher GitHub Repository](https://github.com/byterover/cipher)
- **Issues**: Report bugs on GitHub Issues
- **Community**: Join discussions in GitHub Discussions
- **Trae IDE**: [Trae IDE Documentation](https://trae.ai/docs)

---

**Deployment Complete!** 🚀

Your Cipher agent is now running on Coolify with full Trae IDE integration, persistent memory, and production-grade configuration.