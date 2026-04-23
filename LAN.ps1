Clear-Host
$ErrorActionPreference = "SilentlyContinue"

function Get-NetworkRange {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object {$_.IPAddress -like "192.168.*"} |
           Select-Object -First 1).IPAddress
    
    if (!$ip) {
        Write-Host "Could not detect network range." -ForegroundColor Red
        exit
    }

    $base = $ip.Substring(0, $ip.LastIndexOf('.') + 1)
    return $base
}

function Scan-Network {
    param ($base)

    Write-Host "Scanning network..." -ForegroundColor Cyan

    1..254 | ForEach-Object -Parallel {
        $ip = "$using:base$_"
        Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1 | Out-Null
    }

    Start-Sleep -Seconds 1
}

function Get-Devices {
    arp -a | Select-String "192\.168\." | ForEach-Object {
        $parts = ($_ -split "\s+") | Where-Object {$_ -ne ""}
        [PSCustomObject]@{
            IP  = $parts[1]
            MAC = $parts[2]
        }
    }
}

function Monitor-Latency {
    param ($devices)

    foreach ($device in $devices) {
        $ping = Test-Connection -ComputerName $device.IP -Count 1 -ErrorAction SilentlyContinue
        
        if ($ping) {
            $time = $ping.ResponseTime
            if ($time -lt 50) {
                $color = "Green"
            } elseif ($time -lt 100) {
                $color = "Yellow"
            } else {
                $color = "Red"
            }

            Write-Host "$($device.IP) [$($device.MAC)] - $time ms" -ForegroundColor $color
        } else {
            Write-Host "$($device.IP) [$($device.MAC)] - Offline" -ForegroundColor DarkGray
        }
    }
}

# ===== MAIN LOOP =====

$base = Get-NetworkRange

while ($true) {
    Clear-Host
    Write-Host "==============================="
    Write-Host " NETWORK DEVICE MONITOR"
    Write-Host "==============================="

    Scan-Network $base
    $devices = Get-Devices

    Write-Host ""
    Write-Host "Devices Found: $($devices.Count)"
    Write-Host "-------------------------------"

    Monitor-Latency $devices

    Write-Host ""
    Write-Host "Refreshing in 5 seconds..." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
}
