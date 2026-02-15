#!/bin/bash

# CubeLadder V2.5 - Mac/Linux Installer (FINAL)
# Fixed config path detection for macOS local profile support

echo -e "\033[0;36m========================================\033[0m"
echo -e "\033[0;36m CubeLadder V2.5 Installer (Mac/Linux)\033[0m"
echo -e "\033[0;36m========================================\033[0m"
echo ""

CONFIG_DIR="config"
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
fi

# 1. fetch_ladder.sh
echo -e "\033[0;33m[1/8] Creating fetch_ladder.sh ...\033[0m"
cat > "$CONFIG_DIR/fetch_ladder.sh" << 'FETCH_EOF'
#!/bin/bash

# Determine saved.cfg location based on OS
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Darwin*)
        # Check local config first (inside game folder), then system config
        GAME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        if [ -f "$GAME_DIR/profile/config/saved.cfg" ]; then
            SAVED_CFG="$GAME_DIR/profile/config/saved.cfg"
        elif [ -f "$HOME/Library/Application Support/assaultcube/v1.3/config/saved.cfg" ]; then
            SAVED_CFG="$HOME/Library/Application Support/assaultcube/v1.3/config/saved.cfg"
        else
            SAVED_CFG="$HOME/Library/Application Support/assaultcube_v1.3/config/saved.cfg"
        fi
        ;;
    Linux*)
        SAVED_CFG="$HOME/.assaultcube_v1.3/config/saved.cfg"
        ;;
    *)
        SAVED_CFG="$HOME/.assaultcube_v1.3/config/saved.cfg"
        ;;
esac

MY_IN_GAME_NAME="None"
MY_RANK=0

# Extract player name from saved.cfg
if [ -f "$SAVED_CFG" ]; then
    while IFS= read -r line; do
        if [[ "$line" =~ name[[:space:]]+\"?([^\"[:space:]]+)\"? ]]; then
            MY_IN_GAME_NAME="${BASH_REMATCH[1]}"
            MY_IN_GAME_NAME="${MY_IN_GAME_NAME//\"/}"
            break
        fi
    done < "$SAVED_CFG"
fi

# Fetch ladder data
if ! LADDER_JSON=$(curl -s -f "https://cubeladder.ovh/api/top100" 2>/dev/null); then
    echo 'newmenu "ladder"' > config/ladder_data.cfg
    echo 'menuitem "\f3Connection error - check internet" -1' >> config/ladder_data.cfg
    exit 1
fi

# Country flag color mapping function
get_flag() {
    local country="$1"
    case "$country" in
        IR) echo "\f0I\f5R\f3N" ;; TR) echo "\f3T\f5R\f3K" ;; FR) echo "\f1F\f5R\f3A" ;;
        DE) echo "\f4G\f3E\f2R" ;; IN) echo "\f9I\f5N\f0D" ;; NO) echo "\f3N\f5O\f1R" ;;
        TH) echo "\f3T\f5H\f1A" ;; LK) echo "\f9L\f5K\f0A" ;; CO) echo "\f2C\f1O\f3L" ;;
        BR) echo "\f0B\f2R\f0A" ;; NZ) echo "\f1N\f3Z\f1L" ;; UY) echo "\f5U\f2R\f1Y" ;;
        BA) echo "\f1B\f2I\f1H" ;; UA) echo "\f1U\f5K\f2R" ;; VE) echo "\f2V\f1E\f3N" ;;
        CA) echo "\f3C\f5A\f3N" ;; RS) echo "\f3R\f1S\f5B" ;; US) echo "\f1U\f5S\f3A" ;;
        GB) echo "\f1G\f3B\f1R" ;; IT) echo "\f0I\f5T\f3A" ;; HR) echo "\f3C\f5R\f1O" ;;
        BY) echo "\f3B\f0L\f5R" ;; AT) echo "\f3A\f5U\f3T" ;; DZ) echo "\f0D\f5Z\f3A" ;;
        MX) echo "\f0M\f5X\f3C" ;; PT) echo "\f0P\f3R\f3T" ;; PL) echo "\f5P\f5O\f3L" ;;
        SK) echo "\f5S\f1V\f3K" ;; TT) echo "\f3T\f4T\f3O" ;; ES) echo "\f3E\f2S\f3P" ;;
        AU) echo "\f3A\f3U\f1S" ;; ZA) echo "\f2Z\f0A\f1F" ;; AR) echo "\f1A\f5R\f1G" ;;
        PH) echo "\f1P\f3H\f5L" ;; BG) echo "\f3B\f5U\f3L" ;; CL) echo "\f1C\f5H\f3L" ;;
        EC) echo "\f2E\f1C\f3U" ;; GT) echo "\f1G\f5T\f1M" ;; ID) echo "\f3I\f5D\f3N" ;;
        TW) echo "\f1T\f3W\f5N" ;; HK) echo "\f1H\f3K\f5G" ;; CN) echo "\f3C\f5H\f4N" ;;
        JP) echo "\f5J\f3P\f5N" ;; KR) echo "\f1K\f3O\f5R" ;;
        *)
            if [ -z "$country" ]; then
                echo "\f4???"
            else
                local first_char="${country:0:1}"
                local code3=$(printf "%-3s" "$country" | tr '[:lower:]' '[:upper:]')
                case "$first_char" in
                    [ABab]) echo "\f0$code3" ;; [CDcd]) echo "\f1$code3" ;;
                    [EFef]) echo "\f2$code3" ;; [GHgh]) echo "\f3$code3" ;;
                    [IJij]) echo "\f4$code3" ;; [KLkl]) echo "\f5$code3" ;;
                    [MNmn]) echo "\f9$code3" ;; *) echo "\f7$code3" ;;
                esac
            fi
            ;;
    esac
}

# Start building menu
{
    echo 'newmenu "ladder"'
    
    if [ "$MY_RANK" -gt 0 ]; then
        echo "menuitem \"\f8Status: \f2You are ranked #$MY_RANK in Top 100\" -1"
    else
        echo "menuitem \"\f3Status: \f3$MY_IN_GAME_NAME not in Top 100\" -1"
    fi
    
    LAST_UPDATE=$(date +"%Y-%m-%d %H:%M:%S")
    echo "menuitem \"\f5Last Update: \f2$LAST_UPDATE\" -1"
    echo "menuitem \"\f0Auto-refresh: \f2Active! Press L to see updates\" -1"
    echo "menuitem \"\f4 ------------------------------------------\" -1"
    echo "menuitem \"\f5 Rank Score Flag Player\" -1"
    echo "menuitem \"\f4 ------------------------------------------\" -1"
    
    # Parse JSON and build ladder rows
    echo "$LADDER_JSON" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    my_name = '$MY_IN_GAME_NAME'.lower()
    my_rank = 0
    
    sorted_items = sorted(data.items(), key=lambda x: int(x[1]['rank']))
    
    for key, player in sorted_items:
        rank = int(player['rank'])
        if rank > 100:
            break
            
        name = player['name']
        score = player['total_score']
        country = player.get('country', '')
        
        if my_name != 'none' and name.lower().replace('\\\f', '').replace('\\\\\\\f[0-9]', '') == my_name:
            row_color = '\\\f8'
            display_name = f'>> {name} <<'
            my_rank = rank
            star = '\\\f2*'
        elif rank <= 3:
            row_color = '\\\f2'
            display_name = name
            star = ' '
        elif rank <= 10:
            row_color = '\\\f9'
            display_name = name
            star = ' '
        else:
            row_color = '\\\f5'
            display_name = name
            star = ' '
        
        if len(display_name) > 20:
            display_name = display_name[:17] + '..'
        
        rank_str = f'{rank:<3}'
        score_str = f'{score:<8}'
        
        print(f'menuitem \"{row_color}{star}{rank_str} {score_str} \\\f4[COUNTRY_PLACEHOLDER_{country}] {row_color}{display_name}\" -1')
    
    if my_rank > 0:
        print(f'# MY_RANK={my_rank}', file=sys.stderr)
        
except Exception as e:
    print(f'menuitem \\\"\\\f3Parse error: {str(e)}\\\" -1')
" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ COUNTRY_PLACEHOLDER_([A-Z]*) ]]; then
            country="${BASH_REMATCH[1]}"
            flag=$(get_flag "$country")
            echo "${line//COUNTRY_PLACEHOLDER_$country/$flag}"
        elif [[ "$line" =~ MY_RANK=([0-9]+) ]]; then
            MY_RANK="${BASH_REMATCH[1]}"
        else
            echo "$line"
        fi
    done
    
} > config/ladder_data.cfg

FETCH_EOF

chmod +x "$CONFIG_DIR/fetch_ladder.sh"

# 2. auto_refresh.sh
echo -e "\033[0;33m[2/8] Creating auto_refresh.sh ...\033[0m"
cat > "$CONFIG_DIR/auto_refresh.sh" << 'AUTO_EOF'
#!/bin/bash

echo -e "\033[0;36m================================\033[0m"
echo -e "\033[0;36m CubeLadder Auto-Refresh\033[0m"
echo -e "\033[0;36m================================\033[0m"
echo -e "\033[0;32mStatus: Running\033[0m"
echo -e "\033[0;33mInterval: 30 seconds\033[0m"
echo ""

REFRESH_INTERVAL=30
RUN_COUNT=0
GAME_STARTED=false

OS_TYPE="$(uname -s)"
GAME_PROCESS="assaultcube"

echo -e "\033[0;33mWaiting for game...\033[0m"
WAIT_COUNT=0
while [ $WAIT_COUNT -lt 60 ]; do
    if pgrep -x "$GAME_PROCESS" > /dev/null 2>&1; then
        GAME_STARTED=true
        echo -e "\033[0;32mGame detected!\033[0m"
        break
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ "$GAME_STARTED" = false ]; then
    echo -e "\033[0;33mWill work anyway!\033[0m"
fi

echo ""

while true; do
    if [ "$GAME_STARTED" = true ]; then
        if ! pgrep -x "$GAME_PROCESS" > /dev/null 2>&1; then
            echo ""
            echo -e "\033[0;33mGame closed. Shutting down...\033[0m"
            sleep 1
            exit 0
        fi
    fi
    
    RUN_COUNT=$((RUN_COUNT + 1))
    TIMESTAMP=$(date +"%H:%M:%S")
    echo -e "\033[0;36m[$TIMESTAMP] Refresh #$RUN_COUNT...\033[0m"
    
    if bash "config/fetch_ladder.sh"; then
        echo -e "\033[0;32m[$TIMESTAMP] Success!\033[0m"
    else
        echo -e "\033[0;31m[$TIMESTAMP] Error\033[0m"
    fi
    
    sleep $REFRESH_INTERVAL
done

AUTO_EOF

chmod +x "$CONFIG_DIR/auto_refresh.sh"

# 3. game_watcher.sh
echo -e "\033[0;33m[3/8] Creating game_watcher.sh ...\033[0m"
cat > "$CONFIG_DIR/game_watcher.sh" << 'WATCH_EOF'
#!/bin/bash

GAME_PROCESS="assaultcube"
WAIT_COUNT=0
GAME_STARTED=false

while [ $WAIT_COUNT -lt 60 ]; do
    if pgrep -x "$GAME_PROCESS" > /dev/null 2>&1; then
        GAME_STARTED=true
        break
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

if [ "$GAME_STARTED" = false ]; then
    exit 0
fi

while true; do
    if ! pgrep -x "$GAME_PROCESS" > /dev/null 2>&1; then
        pkill -f "auto_refresh.sh" 2>/dev/null
        sleep 1
        exit 0
    fi
    sleep 2
done

WATCH_EOF

chmod +x "$CONFIG_DIR/game_watcher.sh"

# 4. Patch menus.cfg
echo -e "\033[0;33m[4/8] Patching menus.cfg ...\033[0m"
MENU_FILE="config/menus.cfg"
MENU_ITEM='menuitem "\f2CUBELADDER (L)" [delmenu "ladder"; exec "config/ladder_data.cfg"; showmenu "ladder"]'

if [ -f "$MENU_FILE" ]; then
    grep -v 'CUBELADDER (L)' "$MENU_FILE" > "$MENU_FILE.tmp"
    
    if grep -q -i 'menuitem.*Singleplayer.*showmenu.*singleplayer' "$MENU_FILE.tmp"; then
        awk -v item="$MENU_ITEM" '
            /menuitem.*Singleplayer.*showmenu.*singleplayer/ {
                print
                print item
                next
            }
            {print}
        ' "$MENU_FILE.tmp" > "$MENU_FILE"
    else
        cat "$MENU_FILE.tmp" > "$MENU_FILE"
        echo "" >> "$MENU_FILE"
        echo "$MENU_ITEM" >> "$MENU_FILE"
    fi
    
    rm "$MENU_FILE.tmp"
    echo -e "\033[0;32m[OK] Menu patched\033[0m"
else
    echo -e "\033[0;33m[WARN] menus.cfg not found\033[0m"
fi

# 5. autoexec.cfg
echo -e "\033[0;33m[5/8] Creating autoexec.cfg ...\033[0m"
cat > "config/autoexec.cfg" << 'AUTOEXEC_EOF'
bind "L" [
    delmenu "ladder"
    exec "config/ladder_data.cfg"
    showmenu "ladder"
]
echo "CubeLadder LOADED - Press L to view ladder"
AUTOEXEC_EOF

# 6. Launcher
echo -e "\033[0;33m[6/8] Creating launcher ...\033[0m"
cat > "cubeladder_launcher.sh" << 'LAUNCHER_EOF'
#!/bin/bash

echo "========================================"
echo " CubeLadder - Starting"
echo "========================================"
echo ""

echo "[1/3] Fetching ladder..."
bash "config/fetch_ladder.sh"
echo ""

echo "[2/3] Starting auto-refresh..."
bash "config/auto_refresh.sh" &
AUTO_PID=$!
sleep 1

echo "[3/3] Starting watcher..."
bash "config/game_watcher.sh" &
WATCH_PID=$!

echo ""
echo "========================================"
echo " Ready! Press L in-game"
echo "========================================"
echo ""

OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Darwin*)
        if [ -f "AssaultCube.app/Contents/MacOS/assaultcube" ]; then
            ./AssaultCube.app/Contents/MacOS/assaultcube
        elif [ -f "assaultcube.app/Contents/MacOS/assaultcube" ]; then
            ./assaultcube.app/Contents/MacOS/assaultcube
        elif [ -f "assaultcube_unix.sh" ]; then
            ./assaultcube_unix.sh
        else
            echo "Error: Game not found!"
            kill $AUTO_PID $WATCH_PID 2>/dev/null
            exit 1
        fi
        ;;
    Linux*)
        if [ -f "assaultcube.sh" ]; then
            ./assaultcube.sh
        elif [ -f "assaultcube" ]; then
            ./assaultcube
        elif [ -f "./assaultcube_unix" ]; then
            ./assaultcube_unix
        else
            echo "Error: Game not found!"
            kill $AUTO_PID $WATCH_PID 2>/dev/null
            exit 1
        fi
        ;;
esac

LAUNCHER_EOF

chmod +x "cubeladder_launcher.sh"

# 7. Stop script
echo -e "\033[0;33m[7/8] Creating stop script ...\033[0m"
cat > "stop_cubeladder.sh" << 'STOP_EOF'
#!/bin/bash
echo "Stopping CubeLadder..."
pkill -f "auto_refresh.sh" 2>/dev/null
pkill -f "game_watcher.sh" 2>/dev/null
echo "Done."
sleep 1
STOP_EOF

chmod +x "stop_cubeladder.sh"

# 8. Desktop launcher
echo -e "\033[0;33m[8/8] Desktop launcher ...\033[0m"

CURRENT_DIR="$(pwd)"
OS_TYPE="$(uname -s)"

case "$OS_TYPE" in
    Darwin*)
        echo ""
        echo -e "\033[0;36mTo create desktop shortcut on macOS:\033[0m"
        echo "1. Open Automator"
        echo "2. New Application"
        echo "3. Add 'Run Shell Script'"
        echo "4. Paste: cd \"$CURRENT_DIR\" && ./cubeladder_launcher.sh"
        echo "5. Save as 'AssaultCubeLadder' on Desktop"
        ;;
    Linux*)
        DESKTOP="$HOME/Desktop/AssaultCubeLadder.desktop"
        cat > "$DESKTOP" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=AssaultCube Ladder
Comment=AssaultCube with CubeLadder
Exec=$CURRENT_DIR/cubeladder_launcher.sh
Path=$CURRENT_DIR
Icon=applications-games
Terminal=true
Categories=Game;
EOF
        chmod +x "$DESKTOP"
        echo -e "\033[0;32m[OK] Desktop shortcut created\033[0m"
        ;;
esac

echo ""
echo -e "\033[0;32m========================================\033[0m"
echo -e "\033[0;32m Installation Complete!\033[0m"
echo -e "\033[0;32m========================================\033[0m"
echo ""
echo "Run: ./cubeladder_launcher.sh"
echo "Or use desktop shortcut"
echo "Press L in-game to view ladder"
echo ""
read -p "Press Enter to exit..."
