@echo off
setlocal EnableDelayedExpansion

title CubeLadder Uninstaller - Safe Cleanup
echo.
echo ===============================================
echo   CubeLadder Uninstaller - Safe Cleanup Tool
echo ===============================================
echo.
echo This will:
echo  - Stop and kill any running CubeLadder services
echo  - Delete CubeLadder-related files in config\
echo  - Remove CubeLadder menu item from menus.cfg (if present)
echo  - Remove CubeLadder bind and echo lines from autoexec.cfg (if present)
echo  - Delete CubeLadder.bat and StopAutoRefresh.bat (if exist)
echo  - Delete AssaultCubeLadder.lnk shortcut from Desktop (if exist)
echo.
echo Press any key to CONTINUE or close this window to CANCEL...
pause >nul

echo.
echo [1/5] Stopping running services...
taskkill /FI "WindowTitle eq CubeLadder Auto-Refresh*" /F >nul 2>&1
taskkill /IM powershell.exe /FI "WindowTitle eq *game_watcher*" /F >nul 2>&1
timeout /t 1 >nul

echo [2/5] Deleting CubeLadder files...
del /F /Q "CubeLadder.bat" >nul 2>&1
del /F /Q "StopAutoRefresh.bat" >nul 2>&1
del /F /Q "config\fetch_ladder.ps1" >nul 2>&1
del /F /Q "config\auto_refresh.ps1" >nul 2>&1
del /F /Q "config\start_auto_refresh.bat" >nul 2>&1
del /F /Q "config\game_watcher.ps1" >nul 2>&1
del /F /Q "config\start_game_watcher.bat" >nul 2>&1
del /F /Q "config\ladder_data.cfg" >nul 2>&1

echo [3/5] Removing CubeLadder shortcut from Desktop (if exists)...
set "Desktop=%USERPROFILE%\Desktop"
if exist "%Desktop%\AssaultCubeLadder.lnk" (
    del /F /Q "%Desktop%\AssaultCubeLadder.lnk" >nul 2>&1
    echo    Shortcut deleted from Desktop
) else (
    echo    No CubeLadder shortcut found on Desktop - skipped
)

echo [4/5] Cleaning menus.cfg - removing CubeLadder menu item...
if exist "config\menus.cfg" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$content = Get-Content 'config\menus.cfg' -Encoding ascii -ErrorAction SilentlyContinue;" ^
        "$filtered = $content | Where-Object { $_ -notmatch 'CUBELADDER \(L\)' };" ^
        "if ($filtered.Count -lt $content.Count) { $filtered | Set-Content 'config\menus.cfg' -Encoding ascii -Force; Write-Output 'Menu item removed' } else { Write-Output 'No matching line found' }"
    echo    Done (CubeLadder menu item removed if it existed)
) else (
    echo    menus.cfg not found - skipped
)

echo [5/5] Cleaning autoexec.cfg - removing CubeLadder bind and echo...
if exist "config\autoexec.cfg" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$lines = Get-Content 'config\autoexec.cfg' -Encoding ascii -ErrorAction SilentlyContinue;" ^
        "$result = @();" ^
        "$inBlock = $false;" ^
        "foreach ($line in $lines) {" ^
        "    if ($line -match 'bind\s+\"L\"' -or $line -match 'CubeLadder LOADED') {" ^
        "        $inBlock = $true;" ^
        "        continue;" ^
        "    }" ^
        "    if ($inBlock -and $line -match '^\s*$') {" ^
        "        $inBlock = $false;" ^
        "        continue;" ^
        "    }" ^
        "    if (-not $inBlock) {" ^
        "        $result += $line;" ^
        "    }" ^
        "}" ^
        "if ($result.Count -lt $lines.Count) {" ^
        "    $result | Set-Content 'config\autoexec.cfg' -Encoding ascii -Force;" ^
        "    Write-Output 'Bind and echo removed';" ^
        "} else {" ^
        "    Write-Output 'No matching lines found';" ^
        "}"
    echo    Done (CubeLadder bind and echo removed if they existed)
) else (
    echo    autoexec.cfg not found - skipped
)

echo.
echo ===============================================
echo Cleanup finished.
echo Game should now be back to original state.
echo.
echo You can delete this uninstaller file if you want.
pause >nul