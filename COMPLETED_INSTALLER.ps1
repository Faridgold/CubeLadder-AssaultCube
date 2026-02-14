# --- Installing CubeLadder - V2.5 (Fixed Auto-Update + Desktop Shortcut) ---
Write-Host "--- Installing CubeLadder - V2.5 (Fixed Auto-Update + Desktop Shortcut) ---" -ForegroundColor Cyan

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$configDir = "config"
if (!(Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
}

# 1. fetch_ladder.ps1
Write-Host "[1/8] Writing fetch_ladder.ps1 ..." -ForegroundColor Yellow
$fetchContent = @'
try {
    $documentsPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "My Games\AssaultCube\v1.3\config\saved.cfg")
    $myInGameName = "None"; $myRank = 0
   
    if (Test-Path $documentsPath) {
        $content = Get-Content $documentsPath -Encoding UTF8 -ErrorAction SilentlyContinue
        foreach ($line in $content) {
            if ($line -match 'name\s+"?([^"\s]+)"?') {
                $myInGameName = $matches[1].Replace('"','').Trim(); break
            }
        }
    }
   
    $data = Invoke-RestMethod -Uri "https://cubeladder.ovh/api/top100" -Method Get -ErrorAction Stop
   
    $menu = @(); $tempRows = @()
   
    $menu += "newmenu `"ladder`""
   
    $keys = $data.psobject.Properties.Name | Sort-Object { [int]$_ }
   
    foreach ($key in $keys) {
        $p = $data.$key; $rank = $p.rank; $name = $p.name; $score = $p.total_score
        $country = if ($p.country) { $p.country } else { "" }
       
        $f = switch ($country) {
            "IR" { "\f0I\f5R\f3N" }; "TR" { "\f3T\f5R\f3K" }; "FR" { "\f1F\f5R\f3A" }; "DE" { "\f4G\f3E\f2R" }
            "IN" { "\f9I\f5N\f0D" }; "NO" { "\f3N\f5O\f1R" }; "TH" { "\f3T\f5H\f1A" }; "LK" { "\f9L\f5K\f0A" }
            "CO" { "\f2C\f1O\f3L" }; "BR" { "\f0B\f2R\f0A" }; "NZ" { "\f1N\f3Z\f1L" }; "UY" { "\f5U\f2R\f1Y" }
            "BA" { "\f1B\f2I\f1H" }; "UA" { "\f1U\f5K\f2R" }; "VE" { "\f2V\f1E\f3N" }; "CA" { "\f3C\f5A\f3N" }
            "RS" { "\f3R\f1S\f5B" }; "US" { "\f1U\f5S\f3A" }; "GB" { "\f1G\f3B\f1R" }; "IT" { "\f0I\f5T\f3A" }
            "HR" { "\f3C\f5R\f1O" }; "BY" { "\f3B\f0L\f5R" }; "AT" { "\f3A\f5U\f3T" }; "DZ" { "\f0D\f5Z\f3A" }
            "MX" { "\f0M\f5X\f3C" }; "PT" { "\f0P\f3R\f3T" }; "PL" { "\f5P\f5O\f3L" }; "SK" { "\f5S\f1V\f3K" }
            "TT" { "\f3T\f4T\f3O" }; "ES" { "\f3E\f2S\f3P" }; "AU" { "\f3A\f3U\f1S" }; "ZA" { "\f2Z\f0A\f1F" }
            "AR" { "\f1A\f5R\f1G" }; "PH" { "\f1P\f3H\f5L" }; "BG" { "\f3B\f5U\f3L" }; "CL" { "\f1C\f5H\f3L" }
            "EC" { "\f2E\f1C\f3U" }; "GT" { "\f1G\f5T\f1M" }; "ID" { "\f3I\f5D\f3N" }; "TW" { "\f1T\f3W\f5N" }
            "HK" { "\f1H\f3K\f5G" }; "CN" { "\f3C\f5H\f4N" }; "JP" { "\f5J\f3P\f5N" }; "KR" { "\f1K\f3O\f5R" }
            default {
                if ([string]::IsNullOrWhiteSpace($country)) { "\f4???" }
                else {
                    $first = $country.Substring(0,1).ToUpper(); $code3 = $country.PadRight(3).Substring(0,3).ToUpper()
                    switch ($first) {
                        {$_ -in "A","B"} { "\f0$code3" }; {$_ -in "C","D"} { "\f1$code3" }; {$_ -in "E","F"} { "\f2$code3" }
                        {$_ -in "G","H"} { "\f3$code3" }; {$_ -in "I","J"} { "\f4$code3" }; {$_ -in "K","L"} { "\f5$code3" }
                        {$_ -in "M","N"} { "\f9$code3" }; default { "\f7$code3" }
                    }
                }
            }
        }
       
        $rowColor = "\f5"; $displayName = $name; $cleanName = $name -replace '\\f\d', ''; $star = " "
       
        if ($myInGameName -ne "None" -and $cleanName -ieq $myInGameName) {
            $rowColor = "\f8"; $displayName = ">> $name <<"; $myRank = $rank; $star = "\f2*"
        }
        elseif ([int]$rank -le 3) { $rowColor = "\f2" }
        elseif ([int]$rank -le 10) { $rowColor = "\f9" }
       
        $rStr = $rank.ToString().PadRight(3); $sStr = $score.ToString().PadRight(8)
        if ($displayName.Length -gt 20) { $displayName = $displayName.Substring(0,17) + ".." }
       
        $tempRows += "menuitem `"$rowColor$star$rStr $sStr \f4[$f\f4] $rowColor$displayName`" -1"
       
        if ([int]$rank -ge 100) { break }
    }
   
    if ($myRank -gt 0) {
        $menu += "menuitem `"\f8Status: \f2You are ranked #$myRank in Top 100`" -1"
    } else {
        $menu += "menuitem `"\f3Status: \f3$myInGameName not in Top 100`" -1"
    }
   
    $lastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $menu += "menuitem `"\f5Last Update: \f2$lastUpdate`" -1"
    $menu += "menuitem `"\f0Auto-refresh: \f2Active! Just press L again to see updates`" -1"
    $menu += "menuitem `"\f4 ------------------------------------------`" -1"
    $menu += "menuitem `"\f5 Rank Score Flag Player`" -1"
    $menu += "menuitem `"\f4 ------------------------------------------`" -1"
   
    $menu += $tempRows
   
    $menu | Out-File -FilePath "config\ladder_data.cfg" -Encoding ascii -Force
   
} catch {
    "newmenu `"ladder`"`nmenuitem `"\f3Connection error - check internet`" -1" | Out-File -FilePath "config\ladder_data.cfg" -Encoding ascii -Force
}
'@
$fetchContent | Out-File -FilePath "config\fetch_ladder.ps1" -Encoding utf8 -Force

# 2. auto_refresh.ps1
Write-Host "[2/8] Writing auto_refresh.ps1 ..." -ForegroundColor Yellow
$autoRefreshContent = @'
# CubeLadder Auto-Refresh Background Service
Write-Host "==================================" -ForegroundColor Cyan
Write-Host " CubeLadder Auto-Refresh Service" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Status: Running in background" -ForegroundColor Green
Write-Host "Refresh interval: 30 seconds" -ForegroundColor Yellow
Write-Host "" -ForegroundColor White
$refreshInterval = 30
$runCount = 0
$gameStarted = $false
Write-Host "Waiting for game to start..." -ForegroundColor Yellow
$waitCount = 0
while ($waitCount -lt 60) {
    $gameProcess = Get-Process -Name "ac_client" -ErrorAction SilentlyContinue
    if ($gameProcess) {
        $gameStarted = $true
        Write-Host "Game detected! Starting auto-refresh..." -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 1
    $waitCount++
}
if (-not $gameStarted) {
    Write-Host "Game did not start. Auto-refresh will still work!" -ForegroundColor Yellow
}
Write-Host "" -ForegroundColor White
while ($true) {
    if ($gameStarted) {
        $gameProcess = Get-Process -Name "ac_client" -ErrorAction SilentlyContinue
        if (-not $gameProcess) {
            Write-Host "" -ForegroundColor White
            Write-Host "Game closed. Shutting down auto-refresh service..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            exit
        }
    }
   
    try {
        $runCount++
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Refresh #$runCount - Fetching ladder data..." -ForegroundColor Cyan
       
        & "config\fetch_ladder.ps1"
       
        Write-Host "[$timestamp] Refresh #$runCount - Success! Next refresh in $refreshInterval seconds" -ForegroundColor Green
       
    } catch {
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
   
    Start-Sleep -Seconds $refreshInterval
}
'@
$autoRefreshContent | Out-File -FilePath "config\auto_refresh.ps1" -Encoding utf8 -Force

# 3. start_auto_refresh.bat
Write-Host "[3/8] Writing start_auto_refresh.bat ..." -ForegroundColor Yellow
$startRefreshBat = @'
@echo off
title CubeLadder Auto-Refresh Service
powershell -ExecutionPolicy Bypass -File "config\auto_refresh.ps1"
exit
'@
$startRefreshBat | Out-File -FilePath "config\start_auto_refresh.bat" -Encoding ascii -Force

# 4. game_watcher.ps1
Write-Host "[4/8] Writing game_watcher.ps1 ..." -ForegroundColor Yellow
$watcherContent = @'
Write-Host "Game Watcher: Monitoring AssaultCube..." -ForegroundColor Green
$waitCount = 0
$gameStarted = $false
while ($waitCount -lt 60) {
    $gameProcess = Get-Process -Name "ac_client" -ErrorAction SilentlyContinue
    if ($gameProcess) {
        $gameStarted = $true
        Write-Host "Game detected! Monitoring..." -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 1
    $waitCount++
}
if (-not $gameStarted) {
    Write-Host "Game did not start within 60 seconds. Exiting watcher." -ForegroundColor Yellow
    exit
}
while ($true) {
    $gameProcess = Get-Process -Name "ac_client" -ErrorAction SilentlyContinue
   
    if (-not $gameProcess) {
        Write-Host "Game closed. Cleaning up..." -ForegroundColor Yellow
       
        Get-Process | Where-Object { $_.MainWindowTitle -like "*CubeLadder Auto-Refresh*" } | Stop-Process -Force -ErrorAction SilentlyContinue
       
        $parent = Get-WmiObject Win32_Process -Filter "ProcessId='$PID'" | Select-Object -ExpandProperty ParentProcessId
        if ($parent) {
            Stop-Process -Id $parent -Force -ErrorAction SilentlyContinue
        }
       
        Write-Host "All windows closed. Goodbye!" -ForegroundColor Green
        Start-Sleep -Seconds 1
        exit
    }
   
    Start-Sleep -Seconds 2
}
'@
$watcherContent | Out-File -FilePath "config\game_watcher.ps1" -Encoding utf8 -Force

# 5. start_game_watcher.bat
Write-Host "[5/8] Writing start_game_watcher.bat ..." -ForegroundColor Yellow
$watcherBat = @'
@echo off
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "config\game_watcher.ps1"
'@
$watcherBat | Out-File -FilePath "config\start_game_watcher.bat" -Encoding ascii -Force

# 6. Patching menus.cfg SAFELY
Write-Host "[6/8] Patching menus.cfg SAFELY ..." -ForegroundColor Yellow
$menuFile = "config\menus.cfg"
$safeMenuItem = 'menuitem "\f2CUBELADDER (L)" [delmenu "ladder"; exec "config/ladder_data.cfg"; showmenu "ladder"]'
if (Test-Path $menuFile) {
    $lines = Get-Content $menuFile -Encoding ascii
    $exists = $false
    $newLines = @()
   
    foreach ($line in $lines) {
        if ($line -match 'menuitem "\\f2CUBELADDER \(L\)"') { continue }
        $newLines += $line
       
        if (-not $exists -and $line -match '(?i)menuitem\s+Singleplayer\s+\[.*showmenu\s+singleplayer.*\]') {
            $newLines += $safeMenuItem
            $exists = $true
        }
    }
   
    if (-not $exists) {
        $newLines += ""
        $newLines += $safeMenuItem
    }
   
    $newLines | Out-File -FilePath $menuFile -Encoding ascii -Force
    Write-Host "[OK] CUBELADDER menu item added" -ForegroundColor Green
} else {
    Write-Host "[WARN] menus.cfg not found in config folder" -ForegroundColor Yellow
}

# 7. autoexec.cfg
Write-Host "[7/8] Writing autoexec.cfg ..." -ForegroundColor Yellow
$autoexec = @'
bind "L" [
    delmenu "ladder"
    exec "config/ladder_data.cfg"
    showmenu "ladder"
]
echo "CubeLadder LOADED - Press L to view ladder (auto-updates every 30s)"
'@
$autoexec | Out-File -FilePath "config\autoexec.cfg" -Encoding ascii -Force

# 8. CubeLadder.bat
Write-Host "[8/8] Creating CubeLadder.bat ..." -ForegroundColor Yellow
$bat = @'
@echo off
echo ========================================
echo Starting CubeLadder with Auto-Refresh
echo ========================================
echo.
echo [1/3] Fetching initial ladder data...
powershell -ExecutionPolicy Bypass -File "config\fetch_ladder.ps1"
echo.
echo [2/3] Starting auto-refresh service...
start "CubeLadder Auto-Refresh" /MIN cmd /c "config\start_auto_refresh.bat"
timeout /t 1 /nobreak >nul
echo.
echo [3/3] Starting game watcher...
start "" /B cmd /c "config\start_game_watcher.bat"
echo.
echo ========================================
echo CubeLadder Ready!
echo ========================================
echo - Auto-refresh every 30 seconds
echo - Press L to open ladder
echo - Services close when game exits
echo ========================================
echo.
call assaultcube.bat
'@
$bat | Out-File -FilePath "CubeLadder.bat" -Encoding ascii -Force

# BONUS: StopAutoRefresh.bat
$stopBat = @'
@echo off
echo Stopping CubeLadder services...
taskkill /FI "WindowTitle eq CubeLadder Auto-Refresh*" /F >nul 2>&1
taskkill /IM powershell.exe /FI "WindowTitle eq *game_watcher*" /F >nul 2>&1
echo Done.
timeout /t 2 >nul
'@
$stopBat | Out-File -FilePath "StopAutoRefresh.bat" -Encoding ascii -Force

# BONUS 2: Desktop Shortcut - Fixed Join-Path and icon detection
Write-Host "[Bonus] Creating Desktop Shortcut: AssaultCubeLadder ..." -ForegroundColor Yellow

$DesktopPath = [Environment]::GetFolderPath("Desktop")
if (-not $DesktopPath) { $DesktopPath = "$env:USERPROFILE\Desktop" }

$ShortcutPath = Join-Path $DesktopPath "AssaultCubeLadder.lnk"
$BatPath = Join-Path (Get-Location).Path "CubeLadder.bat"

# پیدا کردن مسیر ac_client.exe
$IconPath = $null

$possiblePaths = @(
    "ac_client.exe",
    "bin_win32\ac_client.exe",
    "bin\ac_client.exe"
)

foreach ($relPath in $possiblePaths) {
    $full = Join-Path (Get-Location).Path $relPath
    if (Test-Path $full -PathType Leaf) {
        $IconPath = $full
        break
    }
}

if (Test-Path $BatPath) {
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        
        $Shortcut.TargetPath       = $BatPath
        $Shortcut.WorkingDirectory = (Get-Location).Path
        $Shortcut.Description      = "AssaultCube + CubeLadder (Auto-refresh ladder)"
        
        if ($IconPath) {
            $Shortcut.IconLocation = "$IconPath,0"
        }
        
        $Shortcut.Save()
        
        Write-Host "[OK] Shortcut created successfully" -ForegroundColor Green
        if ($IconPath) {
            Write-Host "   Icon set from: $IconPath" -ForegroundColor Cyan
        } else {
            Write-Host "   Note: ac_client.exe not found → using default .bat icon" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] Failed to create shortcut: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[ERROR] CubeLadder.bat not found in current folder → shortcut skipped" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  CubeLadder V2.5 Installation Finished" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host " • Double-click AssaultCubeLadder on Desktop" -ForegroundColor White
Write-Host " • Or run CubeLadder.bat directly from game folder" -ForegroundColor White
Write-Host " • In-game press" -NoNewline; Write-Host " L " -ForegroundColor Yellow -NoNewline; Write-Host "to view ladder" -ForegroundColor White

Read-Host "`nPress Enter to exit"