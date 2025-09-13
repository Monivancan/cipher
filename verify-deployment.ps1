#!/usr/bin/env pwsh
# Cipher Deployment Verification Script
# Run this script after applying environment variables in Coolify

Write-Host "🔍 Cipher Deployment Verification" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://cipher.craftedbymonish.space"
$endpoints = @(
    @{ Name = "Health Check"; Url = "$baseUrl/health" },
    @{ Name = "Root Endpoint"; Url = "$baseUrl" },
    @{ Name = "API Endpoint"; Url = "$baseUrl/api" }
)

$allPassed = $true

foreach ($endpoint in $endpoints) {
    Write-Host "Testing $($endpoint.Name): $($endpoint.Url)" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint.Url -Method GET -TimeoutSec 10 -ErrorAction Stop
        $statusCode = $response.StatusCode
        
        if ($statusCode -eq 200) {
            Write-Host "  ✅ SUCCESS - Status: $statusCode" -ForegroundColor Green
        } elseif ($statusCode -eq 503) {
            Write-Host "  ❌ FAILED - Status: $statusCode (Service Unavailable)" -ForegroundColor Red
            $allPassed = $false
        } else {
            Write-Host "  ⚠️  WARNING - Status: $statusCode" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ❌ ERROR - $($_.Exception.Message)" -ForegroundColor Red
        $allPassed = $false
    }
    
    Write-Host ""
}

# DNS Resolution Check
Write-Host "🌐 DNS Resolution Check" -ForegroundColor Cyan
try {
    $dnsResult = Resolve-DnsName -Name "cipher.craftedbymonish.space" -Type A
    $ipAddress = $dnsResult.IPAddress
    Write-Host "  ✅ DNS Resolution: $ipAddress" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ DNS Resolution Failed: $($_.Exception.Message)" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# Summary
Write-Host "📊 Deployment Status Summary" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "🎉 ALL TESTS PASSED - Deployment is healthy!" -ForegroundColor Green
    Write-Host "✅ Cipher is successfully deployed and accessible" -ForegroundColor Green
} else {
    Write-Host "⚠️  SOME TESTS FAILED - Deployment needs attention" -ForegroundColor Red
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Check Coolify dashboard for container logs" -ForegroundColor White
    Write-Host "   2. Verify all environment variables are set correctly" -ForegroundColor White
    Write-Host "   3. Ensure database connectivity" -ForegroundColor White
    Write-Host "   4. Check application startup logs" -ForegroundColor White
}

Write-Host ""
Write-Host "🔗 Useful Links:" -ForegroundColor Cyan
Write-Host "   Coolify Dashboard: https://coolify.craftedbymonish.space" -ForegroundColor Blue
Write-Host "   Cipher Application: https://cipher.craftedbymonish.space" -ForegroundColor Blue
Write-Host "   Health Check: https://cipher.craftedbymonish.space/health" -ForegroundColor Blue

Write-Host ""
Write-Host "Verification completed at: $(Get-Date)" -ForegroundColor Gray