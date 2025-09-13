# Complete Cipher Deployment Guide for Coolify

## Phase 1: Fork and Customize the Repository

### Step 1: Fork the Repository
1. Go to https://github.com/campfirein/cipher
2. Click the **Fork** button in the top right
3. Choose your GitHub account as the destination
4. Wait for the fork to complete

### Step 2: Clone Your Fork Locally
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/cipher.git
cd cipher

# Add upstream remote (for future updates)
git remote add upstream https://github.com/campfirein/cipher.git
```

### Step 3: Customize Configuration Files

#### 3.1 Create Production Environment File
```bash
# Copy the example environment file
cp .env.example .env.production
```

#### 3.2 Edit .env.production for Google LLM
```bash
# Open in your preferred editor
nano .env.production
```

Add the following configuration:
```env
# Required Google API Key
GEMINI_API_KEY=your-gemini-api-key-here

# Optional: OpenAI for embeddings fallback (if needed)
OPENAI_API_KEY=your-openai-api-key-here

# Production settings
NODE_ENV=production
CIPHER_LOG_LEVEL=info

# Database (if using external database)
# DATABASE_URL=postgresql://user:password@host:port/database

# Server configuration
PORT=3000
HOST=0.0.0.0
```

#### 3.3 Create Custom Agent Configuration
Create a file `config/production-config.yml`:
```yaml
# LLM Configuration for Google
llm:
  provider: gemini
  model: gemini-1.5-pro
  apiKey: $GEMINI_API_KEY
  temperature: 0.1
  maxTokens: 4096

# Embedding Configuration
embedding:
  provider: gemini  # or openai as fallback
  model: text-embedding-004
  apiKey: $GEMINI_API_KEY

# Memory Configuration
memory:
  type: in-memory  # or neo4j for production
  persistentPath: ./data/memory
  maxEntries: 10000

# System Prompt
systemPrompt: |
  You are a helpful AI coding assistant with persistent memory capabilities.
  You can remember previous conversations, code patterns, and project context.
  Always use your memory to provide better, more contextual assistance.

# MCP Server Configuration
mcp:
  enabled: true
  port: 3001
  
# Optional: External MCP Servers
mcpServers:
  filesystem:
    type: stdio
    command: npx
    args: ['-y', '@modelcontextprotocol/server-filesystem', '.']
```

#### 3.4 Customize Docker Configuration
Create/edit `docker-compose.production.yml`:
```yaml
version: '3.8'

services:
  cipher:
    build: .
    ports:
      - "3000:3000"
      - "3001:3001"  # MCP port
    environment:
      - NODE_ENV=production
      - CIPHER_CONFIG_PATH=/app/config/production-config.yml
    env_file:
      - .env.production
    volumes:
      - cipher_data:/app/data
      - ./config:/app/config:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  cipher_data:
    driver: local
```

#### 3.5 Create Dockerfile Optimization (Optional)
If you want to optimize the Dockerfile, create `Dockerfile.production`:
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Install dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy source code
COPY . .

# Build the application
RUN pnpm run build

# Create data directory
RUN mkdir -p /app/data

# Expose ports
EXPOSE 3000 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["pnpm", "start"]
```

### Step 4: Commit and Push Changes
```bash
# Add all files
git add .

# Commit changes
git commit -m "Configure Cipher for production deployment with Google LLM"

# Push to your fork
git push origin main
```

## Phase 2: Deploy on Coolify

### Step 1: Access Coolify Dashboard
1. Log into your Coolify instance
2. Go to your project/server where you want to deploy

### Step 2: Create New Application
1. Click **"New Resource"** or **"Add Application"**
2. Choose **"Docker Compose"** or **"Git Repository"**
3. Select **"Public Repository"** and enter your fork URL: `https://github.com/YOUR_USERNAME/cipher`

### Step 3: Configure Deployment Settings

#### 3.1 Basic Settings
- **Application Name**: `cipher-memory-server`
- **Branch**: `main`
- **Build Pack**: `Docker`
- **Docker Compose File**: `docker-compose.production.yml` (if you created one)

#### 3.2 Environment Variables
Add these in Coolify's Environment Variables section:
```
GEMINI_API_KEY=your-actual-gemini-api-key
OPENAI_API_KEY=your-openai-api-key (if needed)
NODE_ENV=production
CIPHER_LOG_LEVEL=info
PORT=3000
HOST=0.0.0.0
```

#### 3.3 Port Configuration
- **Application Port**: `3000`
- **Additional Ports**: `3001` (for MCP if needed)

#### 3.4 Domain Configuration
- Set up a custom domain or use Coolify's generated URL
- Enable HTTPS/SSL certificate

### Step 4: Deploy
1. Click **"Deploy"** or **"Save & Deploy"**
2. Monitor the build logs
3. Wait for deployment to complete

### Step 5: Verify Deployment
1. Check the application logs for any errors
2. Test the health endpoint: `https://your-domain.com/health`
3. Test basic functionality:
```bash
curl https://your-domain.com/health
```

## Phase 3: Configure IDE Integration

### Step 1: Get Your Deployment URL
Note your Coolify deployment URL, e.g., `https://cipher-memory.your-domain.com`

### Step 2: Configure Claude Desktop
Edit your Claude Desktop MCP configuration:
```json
{
  "mcpServers": {
    "cipher-remote": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "cipher-mcp-client",
        "--server-url",
        "https://your-cipher-deployment.com"
      ],
      "env": {
        "CIPHER_SERVER_URL": "https://your-cipher-deployment.com"
      }
    }
  }
}
```

### Step 3: Configure Other IDEs
For Cursor, Windsurf, VS Code, etc., add similar MCP configuration pointing to your deployed instance.

## Phase 4: Test and Validate

### Step 1: Test Basic Functionality
```bash
# Test API endpoint
curl -X POST https://your-domain.com/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, can you remember this conversation?"}'

# Test MCP endpoint (if exposed)
curl https://your-domain.com/mcp/health
```

### Step 2: Test IDE Integration
1. Open your IDE with Cipher MCP configured
2. Try asking the AI to remember something
3. In a new session, ask it to recall what you told it

### Step 3: Monitor Performance
- Check Coolify logs for any errors
- Monitor memory usage and performance
- Test from different computers to ensure accessibility

## Phase 5: Maintenance and Updates

### Step 1: Keep Fork Updated
```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git merge upstream/main

# Push updates
git push origin main
```

### Step 2: Coolify Auto-Deploy
- Enable auto-deployment in Coolify for automatic updates when you push to your fork
- Set up monitoring and alerts

### Step 3: Backup Configuration
- Export your environment variables
- Backup your custom configuration files
- Document any customizations for team members

## Troubleshooting

### Common Issues:
1. **API Key Issues**: Verify Gemini API key is correct and has quota
2. **Memory Persistence**: Ensure volumes are properly mounted
3. **Network Access**: Check firewall and port configurations
4. **IDE Connection**: Verify MCP configuration syntax

### Debug Commands:
```bash
# Check application logs
docker logs cipher_cipher_1

# Test memory functionality
curl -X POST https://your-domain.com/api/memory/test

# Check MCP server status
curl https://your-domain.com/mcp/tools
```

## Security Notes
- Never commit API keys to your repository
- Use Coolify's environment variable management
- Enable HTTPS for all connections
- Regularly update dependencies
- Monitor API usage and costs

This setup gives you a production-ready Cipher deployment that you can access from any computer and integrate with multiple IDEs!