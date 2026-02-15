#!/bin/bash

echo ""
echo "========================================"
echo " CubeLadder Uninstaller"
echo "========================================"
echo ""
echo "This will remove:"
echo "  - All CubeLadder files"
echo "  - Menu modifications"
echo "  - Config changes"
echo "  - Desktop shortcuts"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "[1/5] Stopping services..."
pkill -f "auto_refresh.sh" 2>/dev/null
pkill -f "game_watcher.sh" 2>/dev/null
sleep 1

echo "[2/5] Removing files..."
rm -f "cubeladder_launcher.sh" 2>/dev/null
rm -f "stop_cubeladder.sh" 2>/dev/null
rm -f "config/fetch_ladder.sh" 2>/dev/null
rm -f "config/auto_refresh.sh" 2>/dev/null
rm -f "config/game_watcher.sh" 2>/dev/null
rm -f "config/ladder_data.cfg" 2>/dev/null

echo "[3/5] Removing shortcuts..."
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)
        if [ -f "$HOME/Desktop/AssaultCubeLadder.desktop" ]; then
            rm -f "$HOME/Desktop/AssaultCubeLadder.desktop"
            echo "   Desktop shortcut removed"
        else
            echo "   No shortcut found"
        fi
        ;;
    Darwin*)
        echo "   macOS: Remove Automator app manually if created"
        ;;
esac

echo "[4/5] Cleaning menus.cfg..."
if [ -f "config/menus.cfg" ]; then
    if grep -q 'CUBELADDER (L)' "config/menus.cfg"; then
        grep -v 'CUBELADDER (L)' "config/menus.cfg" > "config/menus.cfg.tmp"
        mv "config/menus.cfg.tmp" "config/menus.cfg"
        echo "   Menu cleaned"
    else
        echo "   Nothing to clean"
    fi
else
    echo "   menus.cfg not found"
fi

echo "[5/5] Cleaning autoexec.cfg..."
if [ -f "config/autoexec.cfg" ]; then
    awk '
        BEGIN { in_block = 0 }
        /bind "L"/ { in_block = 1; next }
        /CubeLadder LOADED/ { next }
        in_block && /^]/ { in_block = 0; next }
        in_block { next }
        { print }
    ' "config/autoexec.cfg" > "config/autoexec.cfg.tmp"
    
    if ! diff -q "config/autoexec.cfg" "config/autoexec.cfg.tmp" > /dev/null 2>&1; then
        mv "config/autoexec.cfg.tmp" "config/autoexec.cfg"
        echo "   Config cleaned"
    else
        rm "config/autoexec.cfg.tmp"
        echo "   Nothing to clean"
    fi
else
    echo "   autoexec.cfg not found"
fi

echo ""
echo "========================================"
echo " Uninstall Complete"
echo "========================================"
echo ""
echo "Game restored to original state"
echo "You can delete this uninstaller now"
echo ""
read -p "Press Enter to exit..."
