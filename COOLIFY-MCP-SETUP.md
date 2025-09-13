# Cipher MCP Configuration for Coolify Deployment

This guide shows how to configure Cipher as an MCP server for Trae IDE and other MCP clients when deployed on Coolify using Google Gemini APIs.

## Prerequisites

- Cipher deployed on Coolify (follow `COOLIFY-DEPLOYMENT-GUIDE.md`)
- Google Gemini API key configured
- Trae IDE or other MCP-compatible client

## MCP Configuration Options

### Option 1: STDIO Transport (Recommended)

Use this configuration in your MCP client (e.g., Trae IDE settings):

```json
{
  "mcpServers": {
    "cipher": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "cipher-mcp-client",
        "--server-url",
        "https://your-cipher-deployment.coolify.app"
      ],
      "env": {
        "MCP_SERVER_MODE": "aggregator",
        "GEMINI_API_KEY": "AIzaSyAs2M1ImrO-LPpuJguiuAKfSYIW_mRphOo",
        "CIPHER_SERVER_URL": "https://your-cipher-deployment.coolify.app",
        "NODE_ENV": "production",
        "CIPHER_LOG_LEVEL": "info"
      }
    }
  }
}
```

### Option 2: HTTP Transport

For direct HTTP connections:

```json
{
  "mcpServers": {
    "cipher-http": {
      "type": "http",
      "url": "https://your-cipher-deployment.coolify.app/mcp",
      "headers": {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      "env": {
        "GEMINI_API_KEY": "AIzaSyAs2M1ImrO-LPpuJguiuAKfSYIW_mRphOo",
        "NODE_ENV": "production"
      }
    }
  }
}
```

### Option 3: Server-Sent Events (SSE)

For real-time streaming connections:

```json
{
  "mcpServers": {
    "cipher-sse": {
      "type": "sse",
      "url": "https://your-cipher-deployment.coolify.app/mcp/sse",
      "headers": {
        "Accept": "text/event-stream"
      },
      "env": {
        "GEMINI_API_KEY": "AIzaSyAs2M1ImrO-LPpuJguiuAKfSYIW_mRphOo",
        "NODE_ENV": "production"
      }
    }
  }
}
```

## Setup Instructions

### Step 1: Deploy Cipher on Coolify

1. Follow the complete deployment guide in `COOLIFY-DEPLOYMENT-GUIDE.md`
2. Ensure your deployment is accessible at your Coolify domain
3. Verify the health endpoint: `https://your-domain.coolify.app/health`

### Step 2: Configure Environment Variables in Coolify

In your Coolify application settings, ensure these environment variables are set:

```bash
# Required for Google LLM
GEMINI_API_KEY=AIzaSyAs2M1ImrO-LPpuJguiuAKfSYIW_mRphOo

# MCP Server Configuration
MCP_SERVER_MODE=default
MCP_TRANSPORT_TYPE=sse

# Application Settings
NODE_ENV=production
CIPHER_LOG_LEVEL=info
REDACT_SECRETS=true

# Database Configuration (from .env.production)
CIPHER_PG_URL=postgresql://postgres:wLuCT7fiklmGswfe@db.yfaudsacrjdftfywutvu.supabase.co:5432/postgres
VECTOR_STORE_URL=postgresql://postgres:wLuCT7fiklmGswfe@db.yfaudsacrjdftfywutvu.supabase.co:5432/postgres
```

### Step 3: Configure Port Exposure

Ensure these ports are exposed in Coolify:

- **Port 3000**: Main API server
- **Port 3001**: MCP server (if using separate MCP port)

### Step 4: Configure Your MCP Client

#### For Trae IDE:
1. Open Trae IDE settings
2. Navigate to MCP Servers configuration
3. Add the configuration from Option 1 above
4. Replace `your-cipher-deployment.coolify.app` with your actual domain

#### For Claude Desktop:
1. Edit `~/.config/claude-desktop/config.json` (Linux/Mac) or `%APPDATA%\Claude\config.json` (Windows)
2. Add the MCP server configuration
3. Restart Claude Desktop

#### For Other MCP Clients:
Use the appropriate configuration format for your client, following the same pattern.

## Testing Your Configuration

### Test 1: Health Check
```bash
curl https://your-cipher-deployment.coolify.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 3600,
  "version": "1.0.0"
}
```

### Test 2: MCP Endpoint
```bash
curl -X POST https://your-cipher-deployment.coolify.app/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version": "1.0.0"}}}'
```

### Test 3: SSE Endpoint
```bash
curl -N -H "Accept: text/event-stream" https://your-cipher-deployment.coolify.app/mcp/sse
```

## Troubleshooting

### Common Issues

#### 1. Connection Refused
- **Cause**: Cipher not properly deployed or ports not exposed
- **Solution**: Check Coolify deployment logs and port configuration

#### 2. Authentication Errors
- **Cause**: Missing or invalid GEMINI_API_KEY
- **Solution**: Verify API key in Coolify environment variables

#### 3. MCP Client Can't Connect
- **Cause**: Incorrect URL or transport type
- **Solution**: Verify your domain and try different transport options

#### 4. Database Connection Issues
- **Cause**: Invalid database URL or network issues
- **Solution**: Test database connection from Coolify logs

### Debug Commands

```bash
# Check deployment status
curl -I https://your-cipher-deployment.coolify.app

# Test MCP tools endpoint
curl https://your-cipher-deployment.coolify.app/mcp/tools

# Check WebSocket stats
curl https://your-cipher-deployment.coolify.app/ws/stats

# Test memory functionality
curl -X POST https://your-cipher-deployment.coolify.app/api/memory/test
```

### Log Analysis

In Coolify, monitor these log patterns:

**Successful startup:**
```
[INFO] API Server started on 0.0.0.0:3000
[INFO] MCP SSE endpoints available
[INFO] Database connected successfully
[INFO] Vector store initialized
```

**Error patterns:**
```
[ERROR] Failed to connect to database
[ERROR] MCP server initialization failed
[ERROR] Invalid API key for Gemini
```

## Security Considerations

1. **API Key Security**: Never expose your Gemini API key in client-side code
2. **HTTPS Only**: Always use HTTPS for production deployments
3. **Environment Variables**: Store sensitive data in Coolify's environment variables
4. **Rate Limiting**: Monitor API usage to avoid quota exceeded errors
5. **Access Control**: Consider implementing authentication for production use

## Advanced Configuration

### Custom MCP Server Settings

For advanced use cases, you can customize the MCP server behavior:

```json
{
  "mcpServers": {
    "cipher-advanced": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "cipher-mcp-client", "--server-url", "https://your-domain.coolify.app"],
      "env": {
        "GEMINI_API_KEY": "your-api-key",
        "MCP_SERVER_MODE": "aggregator",
        "MCP_TIMEOUT": "30000",
        "MCP_MAX_RETRIES": "3",
        "CIPHER_LOG_LEVEL": "debug"
      },
      "timeout": 30000,
      "retries": 3
    }
  }
}
```

### Multiple Environment Support

You can configure different environments:

```json
{
  "mcpServers": {
    "cipher-production": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "cipher-mcp-client", "--server-url", "https://cipher-prod.coolify.app"],
      "env": {
        "GEMINI_API_KEY": "prod-api-key",
        "NODE_ENV": "production"
      }
    },
    "cipher-staging": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "cipher-mcp-client", "--server-url", "https://cipher-staging.coolify.app"],
      "env": {
        "GEMINI_API_KEY": "staging-api-key",
        "NODE_ENV": "staging"
      }
    }
  }
}
```

## Next Steps

1. **Test Integration**: Verify MCP connection works with your IDE
2. **Monitor Performance**: Check API usage and response times
3. **Backup Strategy**: Set up regular backups of your memory data
4. **Team Setup**: Share configuration with team members
5. **Documentation**: Document any custom configurations for your team

---

**Your Cipher MCP server is now ready for use with Trae IDE and other MCP clients!** 🚀

For additional support, refer to:
- [Cipher Documentation](https://github.com/byterover/cipher)
- [Trae IDE MCP Guide](https://trae.ai/docs/mcp)
- [Coolify Documentation](https://coolify.io/docs)