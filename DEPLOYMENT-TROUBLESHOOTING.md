# Cipher Deployment Troubleshooting Guide

## Current Issue: 503 Server Unavailable

The Cipher application is returning a 503 error, indicating the service is not responding properly. This guide provides systematic troubleshooting steps.

## Quick Diagnosis Steps

### 1. Check Application Health
```bash
# Test the health endpoint
curl -I https://cipher.craftedbymonish.space/health

# Expected: HTTP 200 OK
# Current: HTTP 503 Server Unavailable
```

### 2. Common Causes and Solutions

#### A. Configuration File Mismatch ✅ FIXED
**Problem**: Docker-compose was using wrong config file path
- Docker-compose: `/app/config/production-config.yml`
- Dockerfile expects: `/app/memAgent/cipher.yml`

**Solution**: Updated docker-compose.production.yml to use correct path
```yaml
environment:
  - CONFIG_FILE=/app/memAgent/cipher.yml
```

#### B. Missing Environment Variables
**Check these critical variables in Coolify:**
```bash
# Required for LLM functionality
GEMINI_API_KEY=your_gemini_api_key

# Database configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Optional but recommended
TRAE_API_KEY=your_trae_api_key
```

#### C. Port Configuration Issues
**Verify port settings:**
- Application runs on port 3000 (internal)
- Coolify should expose this port
- Health check uses localhost:3000

#### D. Database Connection Problems
**Common database issues:**
1. Supabase URL not accessible from container
2. Invalid database credentials
3. Network connectivity issues
4. pgvector extension not enabled

#### E. Memory/Resource Constraints
**Check resource limits:**
```yaml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
```

## Coolify-Specific Troubleshooting

### 1. Check Deployment Logs
In Coolify dashboard:
1. Go to your Cipher application
2. Click on "Deployments" tab
3. View the latest deployment logs
4. Look for error messages during build/startup

### 2. Check Application Logs
In Coolify dashboard:
1. Go to "Logs" tab
2. Check real-time application logs
3. Look for startup errors or crashes

### 3. Verify Environment Variables
In Coolify dashboard:
1. Go to "Environment Variables" section
2. Ensure all required variables are set
3. Check for typos in variable names

### 4. Check Build Process
Common build issues:
- Node.js version compatibility
- Missing dependencies
- Build timeout
- Insufficient memory during build

## Step-by-Step Recovery Process

### Step 1: Verify Configuration
```bash
# Check if config file exists in container
docker exec -it cipher-app ls -la /app/memAgent/cipher.yml

# Check environment variables
docker exec -it cipher-app env | grep -E "GEMINI|SUPABASE|NODE_ENV"
```

### Step 2: Test Database Connection
```bash
# Test Supabase connection
curl -H "apikey: YOUR_ANON_KEY" \
     -H "Authorization: Bearer YOUR_ANON_KEY" \
     "YOUR_SUPABASE_URL/rest/v1/"
```

### Step 3: Check Application Startup
```bash
# View application logs
docker logs cipher-app --tail 50

# Check if process is running
docker exec -it cipher-app ps aux
```

### Step 4: Manual Health Check
```bash
# Test internal health endpoint
docker exec -it cipher-app curl http://localhost:3000/health

# Test from host
curl http://localhost:3000/health
```

## Common Error Messages and Solutions

### "Cannot find module" Errors
**Cause**: Missing dependencies or incorrect build
**Solution**: 
1. Check package.json dependencies
2. Rebuild Docker image
3. Clear Docker build cache

### "ECONNREFUSED" Database Errors
**Cause**: Database connection issues
**Solution**:
1. Verify Supabase URL and credentials
2. Check network connectivity
3. Ensure database is accessible from container

### "Port already in use" Errors
**Cause**: Port conflicts
**Solution**:
1. Check if another service uses port 3000
2. Update port configuration
3. Restart Docker containers

### "Out of memory" Errors
**Cause**: Insufficient memory allocation
**Solution**:
1. Increase memory limits in docker-compose
2. Optimize application memory usage
3. Check for memory leaks

## Monitoring and Maintenance

### Health Check Configuration
The application includes built-in health checks:
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const req = http.request({host:'localhost',port:process.env.PORT||3000,path:'/health'}, (res) => process.exit(res.statusCode === 200 ? 0 : 1)); req.on('error', () => process.exit(1)); req.end();"
```

### Logging Configuration
Logs are configured with rotation:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Performance Monitoring
Monitor these metrics:
- Memory usage
- CPU utilization
- Response times
- Error rates
- Database connection pool

## Next Steps After Fix

1. **Wait for Deployment**: Allow 2-3 minutes for Coolify to rebuild and deploy
2. **Test Health Endpoint**: Verify `https://cipher.craftedbymonish.space/health` returns 200
3. **Test MCP Functionality**: Use the MCP configuration files to connect from Trae IDE
4. **Monitor Logs**: Watch for any runtime errors or warnings
5. **Performance Testing**: Ensure the application performs well under load

## Emergency Rollback

If issues persist:
```bash
# Rollback to previous commit
git revert HEAD
git push origin main

# Or rollback to specific working commit
git reset --hard <previous-working-commit>
git push --force origin main
```

## Support Resources

- **Coolify Documentation**: https://coolify.io/docs
- **Docker Troubleshooting**: https://docs.docker.com/config/containers/logging/
- **Supabase Connection Issues**: https://supabase.com/docs/guides/database/connecting-to-postgres
- **Node.js Production Best Practices**: https://nodejs.org/en/docs/guides/nodejs-docker-webapp/

---

**Last Updated**: After fixing config file path mismatch
**Status**: Waiting for Coolify redeployment to complete