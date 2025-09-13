# Cipher Deployment Health Check Script
# This script helps diagnose deployment issues on Coolify

Write-Host "=== Cipher Deployment Health Check ===" -ForegroundColor Cyan
Write-Host "Checking deployment status..." -ForegroundColor Yellow

# Function to test endpoint with detailed output
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description
    )
    
    Write-Host "\nTesting $Description..." -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10
        Write-Host "✅ SUCCESS: HTTP $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response Length: $($response.Content.Length) bytes" -ForegroundColor Gray
        return $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode) {
            Write-Host "❌ FAILED: HTTP $statusCode" -ForegroundColor Red
        } else {
            Write-Host "❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
        return $false
    }
}

# Function to check DNS resolution
function Test-DNS {
    param([string]$Domain)
    
    Write-Host "\nChecking DNS resolution for $Domain..." -ForegroundColor Yellow
    try {
        $dnsResult = Resolve-DnsName -Name $Domain -ErrorAction Stop
        Write-Host "✅ DNS Resolution: $($dnsResult[0].IPAddress)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ DNS Resolution Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main health checks
$domain = "cipher.craftedbymonish.space"
$baseUrl = "https://$domain"

# Check DNS first
$dnsOk = Test-DNS -Domain $domain

# Check various endpoints
$endpoints = @(
    @{ Url = "$baseUrl/health"; Description = "Health Check Endpoint" },
    @{ Url = "$baseUrl"; Description = "Root Endpoint" },
    @{ Url = "$baseUrl/api"; Description = "API Endpoint" }
)

$results = @()
foreach ($endpoint in $endpoints) {
    $result = Test-Endpoint -Url $endpoint.Url -Description $endpoint.Description
    $results += @{ Endpoint = $endpoint.Description; Success = $result }
}

# Summary
Write-Host "\n=== HEALTH CHECK SUMMARY ===" -ForegroundColor Cyan
Write-Host "DNS Resolution: $(if($dnsOk) {'✅ OK'} else {'❌ FAILED'})" -ForegroundColor $(if($dnsOk) {'Green'} else {'Red'})

foreach ($result in $results) {
    $status = if($result.Success) {'✅ OK'} else {'❌ FAILED'}
    $color = if($result.Success) {'Green'} else {'Red'}
    Write-Host "$($result.Endpoint): $status" -ForegroundColor $color
}

# Diagnosis and recommendations
Write-Host "\n=== DIAGNOSIS & RECOMMENDATIONS ===" -ForegroundColor Cyan

if (-not $dnsOk) {
    Write-Host "🔍 DNS Issues Detected:" -ForegroundColor Yellow
    Write-Host "  - Check domain configuration in Coolify" -ForegroundColor White
    Write-Host "  - Verify DNS records are properly set" -ForegroundColor White
    Write-Host "  - Wait for DNS propagation (up to 24 hours)" -ForegroundColor White
}

$failedEndpoints = $results | Where-Object { -not $_.Success }
if ($failedEndpoints.Count -gt 0) {
    Write-Host "\n🔍 Application Issues Detected:" -ForegroundColor Yellow
    Write-Host "  - Application may not be starting properly" -ForegroundColor White
    Write-Host "  - Check Coolify deployment logs" -ForegroundColor White
    Write-Host "  - Verify environment variables are set" -ForegroundColor White
    Write-Host "  - Check Docker container health" -ForegroundColor White
}

# Next steps
Write-Host "\n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Check Coolify Dashboard:" -ForegroundColor Yellow
Write-Host "   - Go to https://coolify.craftedbymonish.space" -ForegroundColor White
Write-Host "   - Navigate to Cipher application" -ForegroundColor White
Write-Host "   - Check 'Deployments' and 'Logs' tabs" -ForegroundColor White

Write-Host "\n2. Verify Environment Variables:" -ForegroundColor Yellow
Write-Host "   - GEMINI_API_KEY (required)" -ForegroundColor White
Write-Host "   - SUPABASE_URL (required)" -ForegroundColor White
Write-Host "   - SUPABASE_ANON_KEY (required)" -ForegroundColor White
Write-Host "   - NODE_ENV=production" -ForegroundColor White

Write-Host "\n3. Check Configuration:" -ForegroundColor Yellow
Write-Host "   - Verify CONFIG_FILE=/app/memAgent/cipher.yml" -ForegroundColor White
Write-Host "   - Ensure port 3000 is exposed" -ForegroundColor White
Write-Host "   - Check health check configuration" -ForegroundColor White

Write-Host "\n4. Manual Debugging:" -ForegroundColor Yellow
Write-Host "   - SSH into Coolify server if possible" -ForegroundColor White
Write-Host "   - Run: docker logs <container-name>" -ForegroundColor White
Write-Host "   - Run: docker exec -it <container-name> /bin/sh" -ForegroundColor White

Write-Host "\n5. Emergency Actions:" -ForegroundColor Yellow
Write-Host "   - Restart deployment in Coolify" -ForegroundColor White
Write-Host "   - Rebuild from scratch" -ForegroundColor White
Write-Host "   - Rollback to previous working version" -ForegroundColor White

# Configuration check
Write-Host "\n=== CONFIGURATION VERIFICATION ===" -ForegroundColor Cyan
Write-Host "Checking local configuration files..." -ForegroundColor Yellow

$configFiles = @(
    "memAgent/cipher.yml",
    ".env.production",
    "docker-compose.production.yml",
    "Dockerfile"
)

foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Check for common issues in cipher.yml
if (Test-Path "memAgent/cipher.yml") {
    $cipherConfig = Get-Content "memAgent/cipher.yml" -Raw
    if ($cipherConfig -match "provider:\s*gemini") {
        Write-Host "✅ Gemini provider configured" -ForegroundColor Green
    } else {
        Write-Host "❌ No LLM provider configured" -ForegroundColor Red
    }
    
    if ($cipherConfig -match "\$GEMINI_API_KEY") {
        Write-Host "✅ Gemini API key placeholder found" -ForegroundColor Green
    } else {
        Write-Host "❌ Gemini API key not configured" -ForegroundColor Red
    }
}

Write-Host "\n=== END OF HEALTH CHECK ===" -ForegroundColor Cyan
Write-Host "For detailed troubleshooting, see: DEPLOYMENT-TROUBLESHOOTING.md" -ForegroundColor Gray