# ====================================================================================
# SCRIPT NAME: AutoNetworkOutage-V1.ps1
# DESCRIPTION: Monitors primary internet connection and automatically fails over to a
#              secondary connection (e.g., mobile hotspot) in case of an outage.
#              Automatically fails back when the primary connection is restored.
# VERSION:     1.0
# ====================================================================================

# --- CONFIGURATION ---
# IMPORTANT: Edit these settings to match your specific setup.

# Network Adapter Names (Get these from ncpa.cpl)
$mainAdapter = "YOUR_MAIN_ETHERNET_ADAPTER_NAME" 
$backupAdapter = "YOUR_PHONE_ADAPTER_NAME"

# Test Targets (Using multiple ensures a more reliable test)
$pingTargets = @("8.8.8.8", "1.1.1.1", "google.com")

# Thresholds to trigger action
$failoverThreshold = 3  # Number of consecutive failures to switch to backup
$failbackThreshold = 5  # Number of consecutive successes to switch back to main
$latencyThreshold = 500 # Max acceptable latency in milliseconds (optional)

# Script Behavior
$checkInterval = 5      # Time between checks in seconds
$logFile = "C:\Users\$env:USERNAME\Desktop\NetworkFailover.log"

# ====================================================================================
# --- FUNCTIONS ---
# ====================================================================================

function Test-InternetConnection {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Targets
    )
    
    $pingResult = $false
    $averageLatency = 0
    $successfulPings = 0

    foreach ($target in $Targets) {
        $test = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
        if ($test) {
            $successfulPings++
            $averageLatency += $test.ResponseTime
        }
    }

    if ($successfulPings -gt 0) {
        $averageLatency = [Math]::Round($averageLatency / $successfulPings, 2)
        Write-Host "Pings successful to $successfulPings/$($Targets.Count) targets. Avg Latency: $($averageLatency)ms" -ForegroundColor Green
        
        if ($averageLatency -le $latencyThreshold) {
            $pingResult = $true
        } else {
            Write-Host "WARNING: Latency ($($averageLatency)ms) is above threshold." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Failed to connect to any ping targets." -ForegroundColor Red
    }
    
    return $pingResult
}

function Switch-Adapter {
    param (
        [Parameter(Mandatory=$true)]
        [string]$EnableAdapter,
        [Parameter(Mandatory=$true)]
        [string]$DisableAdapter
    )
    
    Write-Host "Switching adapter from '$DisableAdapter' to '$EnableAdapter'..." -ForegroundColor Cyan
    Add-Content -Path $logFile -Value "$(Get-Date) - ACTION: Switching to '$EnableAdapter'"
    
    try {
        netsh interface set interface $EnableAdapter admin=enable
        netsh interface set interface $DisableAdapter admin=disable
        Add-Content -Path $logFile -Value "$(Get-Date) - SUCCESS: Switch completed."
        return $true
    } catch {
        Add-Content -Path $logFile -Value "$(Get-Date) - ERROR: Failed to switch adapters."
        Write-Host "ERROR: Failed to switch adapters. Check script permissions." -ForegroundColor Red
        return $false
    }
}

# ====================================================================================
# --- MAIN SCRIPT EXECUTION ---
# ====================================================================================

Write-Host "Starting network failover monitoring..." -ForegroundColor Yellow
Write-Host "To exit, press Ctrl+C." -ForegroundColor Gray
Add-Content -Path $logFile -Value "`n$(Get-Date) - SCRIPT START"

$currentActiveAdapter = $mainAdapter
$failedChecks = 0
$successfulChecks = 0

while ($true) {
    # Test primary connection's health
    $isMainConnectionHealthy = Test-InternetConnection -Targets $pingTargets
    
    # --- FAILOVER LOGIC ---
    if (-not $isMainConnectionHealthy) {
        $failedChecks++
        Write-Host "Main adapter is unhealthy. Consecutive failures: $failedChecks" -ForegroundColor Red

        if ($failedChecks -ge $failoverThreshold) {
            if ($currentActiveAdapter -eq $mainAdapter) {
                if (Switch-Adapter -EnableAdapter $backupAdapter -DisableAdapter $mainAdapter) {
                    $currentActiveAdapter = $backupAdapter
                }
            }
        }
        $successfulChecks = 0
    }
    
    # --- FAILBACK LOGIC ---
    else {
        $successfulChecks++
        Write-Host "Main adapter is healthy. Consecutive successes: $successfulChecks" -ForegroundColor Green

        if ($currentActiveAdapter -ne $mainAdapter -and $successfulChecks -ge $failbackThreshold) {
            if (Switch-Adapter -EnableAdapter $mainAdapter -DisableAdapter $backupAdapter) {
                $currentActiveAdapter = $mainAdapter
            }
        }
        $failedChecks = 0
    }
    
    # Pause before the next check
    Start-Sleep -Seconds $checkInterval
}
