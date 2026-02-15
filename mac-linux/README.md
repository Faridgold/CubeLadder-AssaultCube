# CubeLadder for Mac & Linux

**Real-time ladder viewer for AssaultCube with automatic refresh**

Displays the top 100 players from [cubeladder.ovh](https://cubeladder.ovh) directly in your game with a beautiful in-game menu.

## ✨ Features

- 🏆 **Live Top 100 Ladder** - Direct from cubeladder.ovh API
- 🔄 **Auto-refresh** - Updates every 30 seconds while playing
- 🎨 **Color-coded ranks** - Gold (top 3), silver (4-10), red (your rank)
- 🌍 **Country flags** - Color-coded flag display
- 👤 **Personal highlight** - Your name stands out if you're ranked
- 🎮 **One-key access** - Press **L** anytime to view
- 🧹 **Clean shutdown** - Auto-stops when you exit the game
- 💻 **Cross-platform** - Works on both macOS and Linux

## 📋 Requirements

### macOS
- macOS 10.12 or later
- AssaultCube 1.3.0.2
- Python 3 (pre-installed on macOS 10.15+)
- curl (pre-installed)
- Internet connection

### Linux
- Any recent distribution
- AssaultCube 1.3.0.2
- Python 3
- curl
- Internet connection

## 🚀 Installation

### Step 1: Download Files

Download these files:
- `install_cubeladder.sh`
- `uninstall_cubeladder.sh`
- `update_config_path.sh` (optional - for fixing config issues)

### Step 2: Locate Your Game Folder

**macOS:**
```
Right-click AssaultCube.app → Show Package Contents → Contents → gamedata
```

Common locations:
- `/Applications/AssaultCube.app/Contents/gamedata/`
- Desktop or external drive if copied

**Linux:**
```
~/assaultcube/
```
or wherever you installed AssaultCube

### Step 3: Copy Files

Place the downloaded scripts in your AssaultCube `gamedata` folder.

### Step 4: Run Installer

Open Terminal and navigate to the gamedata folder:

**macOS:**
```bash
cd /Applications/AssaultCube.app/Contents/gamedata
# Or if on Desktop:
cd ~/Desktop/AssaultCube.app/Contents/gamedata
```

**Linux:**
```bash
cd ~/assaultcube
```

Then run the installer:
```bash
chmod +x install_cubeladder.sh
./install_cubeladder.sh
```

**macOS Note:** If you get "Killed: 9", run:
```bash
xattr -c install_cubeladder.sh
./install_cubeladder.sh
```

Wait for:
```
========================================
 Installation Complete!
========================================
```

## 🎮 How to Use

### Starting the Game

**Method 1: Command Line**
```bash
cd /path/to/gamedata
./cubeladder_launcher.sh
```

**Method 2: Desktop Shortcut (Recommended)**

**macOS:**
1. Open **Automator**
2. Create new **Application**
3. Add **Run Shell Script** action
4. Paste:
   ```bash
   cd "/path/to/your/gamedata" && ./cubeladder_launcher.sh
   ```
5. Save as `AssaultCubeLadder` on Desktop

**Linux:**
Desktop shortcut is created automatically at:
`~/Desktop/AssaultCubeLadder.desktop`

### In-Game

1. Start the game using the launcher
2. Press **L** to open the ladder menu
3. Auto-refreshes every 30 seconds
4. Press **L** again to manually refresh
5. Close the game normally - services stop automatically

## 🛠 Troubleshooting

### Permission Denied
```bash
chmod +x *.sh
```

### Python 3 Not Found

**macOS:**
```bash
# Install Homebrew first if needed:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install Python:
brew install python3
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3
```

**Linux (Fedora):**
```bash
sudo dnf install python3
```

### Killed: 9 (macOS)
```bash
xattr -c install_cubeladder.sh
./install_cubeladder.sh
```

### Player Name Not Updating (macOS)

If your name doesn't appear highlighted in the ladder:

```bash
cd /path/to/gamedata
chmod +x update_config_path.sh
xattr -c update_config_path.sh
./update_config_path.sh
```

This fixes the config file detection path.

### Services Still Running After Game Closes
```bash
./stop_cubeladder.sh
```

Or manually:
```bash
pkill -f cubeladder
```

### Connection Error

- Check your internet connection
- Verify cubeladder.ovh is accessible:
  ```bash
  curl -s https://cubeladder.ovh/api/top100 | head
  ```

### Game Not Starting

**macOS:**
- Ensure you're in the correct `gamedata` folder
- Check that `AssaultCube.app/Contents/MacOS/assaultcube` exists

**Linux:**
- Verify `assaultcube.sh` or `assaultcube` is executable:
  ```bash
  chmod +x assaultcube.sh
  ```

## 🗑 Uninstallation

1. Close AssaultCube completely
2. Navigate to gamedata folder
3. Run:
   ```bash
   chmod +x uninstall_cubeladder.sh
   ./uninstall_cubeladder.sh
   ```

This removes:
- All CubeLadder scripts
- Menu modifications
- Config file changes
- Desktop shortcuts (Linux)
- All background processes

Your game will be restored to its original state.

## 📁 File Structure

After installation:
```
gamedata/
├── config/
│   ├── fetch_ladder.sh         # API fetcher
│   ├── auto_refresh.sh         # Background refresh service
│   ├── game_watcher.sh         # Process monitor
│   ├── ladder_data.cfg         # Generated menu (auto-updated)
│   ├── menus.cfg              # Modified - menu entry added
│   └── autoexec.cfg           # Modified - L key bound
├── cubeladder_launcher.sh      # Main launcher
├── stop_cubeladder.sh          # Emergency stop
├── install_cubeladder.sh       # Installer
├── uninstall_cubeladder.sh     # Uninstaller
└── update_config_path.sh       # Config path fixer
```

## 🔧 Platform-Specific Notes

### macOS

**Config Locations (checked in order):**
1. `gamedata/profile/config/saved.cfg` (local - preferred)
2. `~/Library/Application Support/assaultcube/v1.3/config/saved.cfg`
3. `~/Library/Application Support/assaultcube_v1.3/config/saved.cfg`

**Security:**
- May need to allow scripts in System Preferences → Security & Privacy
- Use `xattr -c` command to remove quarantine flags

**Process Name:** `assaultcube`

### Linux

**Config Location:**
- `~/.assaultcube_v1.3/config/saved.cfg`

**Desktop File:**
- Standard XDG desktop entry
- Created at `~/Desktop/AssaultCubeLadder.desktop`

**Process Name:** `assaultcube`

## ⚙️ Technical Details

### How It Works

1. **Fetcher** (`fetch_ladder.sh`):
   - Reads your player name from `saved.cfg`
   - Fetches top 100 from cubeladder.ovh API
   - Parses JSON with Python
   - Generates color-coded menu
   - Creates `ladder_data.cfg`

2. **Auto-Refresh** (`auto_refresh.sh`):
   - Runs in background
   - Executes fetcher every 30 seconds
   - Monitors game process
   - Auto-stops when game closes

3. **Game Watcher** (`game_watcher.sh`):
   - Monitors AssaultCube process
   - Kills refresh service on game exit
   - Ensures clean shutdown

4. **Launcher** (`cubeladder_launcher.sh`):
   - Initial fetch
   - Starts background services
   - Launches game
   - Platform-aware

### Configuration Priority

The installer automatically detects your OS and uses the correct config paths. On macOS, it prioritizes local profile configs to ensure your player name is detected correctly.

## 🔒 Privacy & Security

- **Read-only access** - Only reads ladder data and your player name
- **No modifications** to game scores or server data
- **Local processing** - All parsing happens on your machine
- **No telemetry** - No data sent anywhere except cubeladder.ovh API fetch
- **Minimal changes** - Only modifies config files (easily reversible)

## 🆘 Getting Help

### Common Issues

**Q: Ladder shows "None" instead of my name**
A: Run `update_config_path.sh` to fix config detection

**Q: Menu doesn't appear when I press L**
A: Check that `config/autoexec.cfg` exists and contains the bind

**Q: Auto-refresh not working**
A: Verify Python 3 is installed: `python3 --version`

**Q: Services don't stop after closing game**
A: Run `./stop_cubeladder.sh` manually

### Debug Mode

To see what's happening:
```bash
# Run fetcher manually
bash config/fetch_ladder.sh

# Check generated menu
cat config/ladder_data.cfg

# Test API connection
curl -s https://cubeladder.ovh/api/top100 | python3 -m json.tool
```

## 🔗 Links

- **Ladder API:** https://cubeladder.ovh
- **AssaultCube:** https://assault.cubers.net
- **Windows Version:** https://github.com/Faridgold/CubeLadder-AssaultCube
- **Report Issues:** GitHub Issues

## 📜 Version History

**v2.5 (Current)**
- Fixed macOS config path detection
- Added local profile support
- Improved error handling
- Better cross-platform compatibility

**v2.0**
- Initial Mac/Linux port
- Auto-refresh support
- Desktop launcher support

## 💡 Tips

- Keep the terminal window open to see refresh logs
- Use desktop shortcut for easiest access
- Check cubeladder.ovh occasionally to verify API is working
- Auto-refresh only works while game is running

## 🎯 Credits

- **Ladder API:** cubeladder.ovh
- **Original AssaultCube:** assault.cubers.net team
- **Windows Version:** Original CubeLadder project
- **Mac/Linux Port:** Community contribution

---

**Enjoy the ladder and good luck ranking up!** 🔥

*Press L and frag responsibly!*
