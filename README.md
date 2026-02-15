CubeLadder – AssaultCube Ladder Viewer with Auto-Refresh

**CubeLadder** is a lightweight tool that brings the current **Top 100 ladder** from [cubeladder.ovh](https://cubeladder.ovh) directly into **AssaultCube 1.3.0.2** (and compatible versions).

Just press **L** in-game to open a beautiful, color-coded ladder menu that:
- Shows rank, score, country flag and player name
- Highlights **your own name** if you're in the top 100
- Automatically refreshes every ~30 seconds (background service)
- Closes all services cleanly when you exit the game

Latest version: **2.5** (improved auto-update stability + desktop shortcut with icon)

Features

- Real-time ladder from https://cubeladder.ovh/api/top100
- Nice in-game menu with your personal rank/status
- Colored rank highlighting (gold for top 3, silver for 4–10, your name in red if ranked)
- Country flags using AssaultCube color codes
- Auto-refresh runs only while the game is open
- One-click desktop shortcut (`AssaultCubeLadder`)
- Full cleanup with the included uninstaller
- Safe patching of `menus.cfg` and `autoexec.cfg`

Requirements

- AssaultCube **1.3.0.2** (or compatible version)
- Windows operating system
- Internet connection
- PowerShell (comes with Windows 7+)
  ## Platform Support

### Windows
This is the original Windows version with PowerShell scripts.

### Mac & Linux
**NEW!** Mac and Linux versions are now available in the [`mac-linux/`](mac-linux/) folder.

- Full bash script support
- Automatic config detection
- Desktop launcher support
- See [`mac-linux/README.md`](mac-linux/README.md) for installation

Quick start for Mac/Linux:
```bash
cd /path/to/assaultcube/gamedata
chmod +x install_cubeladder.sh
xattr -c install_cubeladder.sh  # macOS only
./install_cubeladder.sh
```

Installation (very quick)

1. Extract / copy all files into your **AssaultCube game folder**  
   (the folder containing `assaultcube.bat` or C:\Program Files (x86)\AssaultCube 1.3.0.2 or whereever your Assaultcube is installed)

   Files you should have:
   - `Install_CubeLadder.bat`
   - `UNinstall_CubeLadder.bat`
   - `COMPLETED_INSTALLER.ps1` (called automatically)

2. **Double-click** `Install_CubeLadder.bat`

3. Wait until you see:

========================================
CubeLadder V2.5 Installation Finished
========================================


4. A shortcut named **AssaultCubeLadder** should appear on your Desktop

## How to Play

**Method 1 – Recommended**  
Double-click **AssaultCubeLadder** on your Desktop

**Method 2**  
Double-click `CubeLadder.bat` inside the game folder

In-game:
- Press **L** anytime → opens / refreshes the ladder menu
- The background service refreshes data every ~30 seconds
- Everything stops automatically when you close AssaultCube

## Uninstall / Revert Changes

1. Close AssaultCube completely
2. Double-click **`UNinstall_CubeLadder.bat`**
3. Wait for the message:
------------------------------------------
Cleanup finished.
Game should now be back to original state.
------------------------------------------

This removes:
- All CubeLadder files in `config\`
- Menu item from `menus.cfg`
- Bind + echo lines from `autoexec.cfg`
- Desktop shortcut
- Stops/kills any remaining background processes

You can then safely delete the uninstaller and this readme file.

Troubleshooting

| Issue                                      | Possible Solution / Explanation                                 |
|:-------------------------------------------|:----------------------------------------------------------------|
| "Connection error - check internet"        | No internet or site is down → try again later                   |
| Ladder menu doesn't appear                 | Make sure you pressed **L** after game fully loaded             |
| Auto-refresh not working                   | Antivirus may block PowerShell → add exception if needed        |
| Shortcut has default icon (no AC logo)     | Normal if `ac_client.exe` wasn't found in standard locations    |
| Installer says PowerShell execution error  | Run `Install_CubeLadder.bat` as Administrator once              |
| Menu item missing after install            | Check if `config\menus.cfg` exists and is not read-only         |
| Services keep running after game closes    | Run `UNinstall_CubeLadder.bat` or manually kill via Task Manager|

Important Notes

- This tool only **reads** the ladder — it does **not** modify scores or interact with the server in any other way.
- All changes to config files are minimal and easily reversible.
- Tested mostly on Windows 10 / 11 — should work on Windows 7+ with PowerShell 5.1+.

Credits & Links

- Ladder API: https://cubeladder.ovh
- Original AssaultCube: https://assault.cubers.net
- Community ladder project inspiration: various AC ladder sites & scripts

Enjoy the ladder — and good luck ranking up!  
Press **L** and frag responsibly! 🔥

---
Last updated: February 2026
