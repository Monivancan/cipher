# Coolify Environment Variables Configuration Guide

## Overview
This guide provides step-by-step instructions to configure environment variables in Coolify to resolve the 503 Server Unavailable errors for the Cipher deployment.

## Current Status
- ✅ Container deployed and running
- ✅ DNS resolution working
- ❌ Application returning 503 errors (likely due to missing environment variables)
- ✅ Environment variables provided by user

## Step-by-Step Configuration

### 1. Access Coolify Dashboard
1. Navigate to: `https://coolify.craftedbymonish.space`
2. Log in with your credentials
3. Select the **Cipher** application

### 2. Configure Environment Variables
1. Go to **Configuration** → **Environment Variables**
2. Add the following environment variables one by one:

```bash
# Service Configuration
SERVICE_FQDN_CIPHER=cipher.craftedbymonish.space
SERVICE_URL_CIPHER=https://cipher.craftedbymonish.space

# API Keys
GEMINI_API_KEY=AIzaSyAs2M1ImrO-LPpuJguiuAKfSYIW_mRphOo

# Application Settings
NODE_ENV=development
CIPHER_LOG_LEVEL=info
REDACT_SECRETS=true

# Database Configuration
CIPHER_PG_URL=postgresql://postgres:wLuCT7fiklmGswfe@db.yfaudsacrjdftfywutvu.supabase.co:5432/postgres

# Vector Store Configuration
VECTOR_STORE_TYPE=pgvector
VECTOR_STORE_URL=postgresql://postgres:wLuCT7fiklmGswfe@db.yfaudsacrjdftfywutvu.supabase.co:5432/postgres
VECTOR_STORE_COLLECTION=knowledge_memory
VECTOR_STORE_DIMENSION=768
VECTOR_STORE_DISTANCE=Cosine
REFLECTION_VECTOR_STORE_COLLECTION=reflection_memory
DISABLE_REFLECTION_MEMORY=false
SEARCH_MEMORY_TYPE=both

# Web Search Configuration
WEB_SEARCH_ENABLE=true
WEB_SEARCH_ENGINE=duckduckgo
WEB_SEARCH_SAFETY_MODE=strict
WEB_SEARCH_MAX_RESULTS=2
WEB_SEARCH_RATE_LIMIT=10

# AI/ML Configuration
EMBEDDING_MODEL=gemini-embedding-001
MCP_GLOBAL_TIMEOUT=30000
ENABLE_QUERY_REFINEMENT=true
```

### 3. Save and Redeploy
1. Click **Save** after adding all environment variables
2. Go to **Deployments** tab
3. Click **Redeploy** to restart the container with new environment variables
4. Wait for deployment to complete (usually 2-3 minutes)

### 4. Verify Deployment
After redeployment, test the following endpoints:

```bash
# Health check
curl https://cipher.craftedbymonish.space/health

# Root endpoint
curl https://cipher.craftedbymonish.space

# API endpoint
curl https://cipher.craftedbymonish.space/api
```

## Expected Results
After applying environment variables:
- ✅ Health endpoint should return 200 OK
- ✅ Root endpoint should serve the application
- ✅ API endpoints should be accessible

## Troubleshooting

### If 503 Errors Persist:
1. **Check Container Logs:**
   - Go to **Logs** tab in Coolify
   - Look for startup errors or missing dependencies

2. **Verify Database Connection:**
   - Ensure Supabase database is accessible
   - Check if pgvector extension is enabled

3. **Port Configuration:**
   - Verify application is listening on port 3000
   - Check if Coolify proxy is configured correctly

### Common Issues:
1. **Database Connection Timeout:**
   - Verify Supabase credentials
   - Check network connectivity

2. **Missing Dependencies:**
   - Ensure all npm packages are installed
   - Check for missing system dependencies

3. **Configuration Errors:**
   - Validate environment variable syntax
   - Check for typos in variable names

## Next Steps
1. Apply environment variables in Coolify
2. Redeploy the application
3. Test all endpoints
4. Monitor application logs
5. Set up monitoring and alerts

## Support
If issues persist after following this guide:
1. Check Coolify deployment logs
2. Review application startup logs
3. Verify database connectivity
4. Contact support with specific error messages