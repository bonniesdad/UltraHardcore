# Installation

>Ultra Hardcore supports multiple installation methods to accommodate different user preferences and technical comfort levels. The addon is designed to work seamlessly with World of Warcraft Classic Era (Interface version 11507) and requires no external dependencies.

## Method 1: Install via Curseforge (Recommended)

1. **Download the Latest Release**
   ```bash
   # Navigate to your WoW Classic AddOns directory
   cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"
   
   # Download and extract the latest release
   # Visit: https://github.com/bonniesdad/UltraHardcore/releases
   ```

2. **Extract to AddOns Directory**
   - Extract the downloaded ZIP file directly into your `Interface\AddOns` folder
   - Ensure the folder structure is: `Interface\AddOns\UltraHardcore\`
   - The main addon file should be located at: `Interface\AddOns\UltraHardcore\UltraHardcore.lua`

3. **Enable in Game**
   - Launch World of Warcraft Classic Era
   - At the character selection screen, click "AddOns"
   - Locate "Ultra Hardcore" in the addon list
   - Check the box to enable the addon
   - Click "Okay" and enter the game
   
## Method 2: Direct Download

1. **Download the Latest Release**
   ```bash
   # Navigate to your WoW Classic AddOns directory
   cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"
   
   # Download and extract the latest release
   # Visit: https://github.com/bonniesdad/UltraHardcore/releases
   ```

2. **Extract to AddOns Directory**
   - Extract the downloaded ZIP file directly into your `Interface\AddOns` folder
   - Ensure the folder structure is: `Interface\AddOns\UltraHardcore\`
   - The main addon file should be located at: `Interface\AddOns\UltraHardcore\UltraHardcore.lua`

3. **Enable in Game**
   - Launch World of Warcraft Classic Era
   - At the character selection screen, click "AddOns"
   - Locate "Ultra Hardcore" in the addon list
   - Check the box to enable the addon
   - Click "Okay" and enter the game

## Method 3: Git Clone (For Developers)

```bash
# Navigate to your AddOns directory
cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"

# Clone the repository
git clone https://github.com/bonniesdad/UltraHardcore.git

# The addon will be automatically available in-game
```

## Method 4: Manual File Copy

1. Download the repository as a ZIP file from GitHub
2. Extract all files to a new folder named `UltraHardcore`
3. Copy this folder to your `Interface\AddOns` directory
4. Restart World of Warcraft if it's currently running


## Verification Steps

After installation, verify the addon is working correctly:

1. **Check Addon Loading**: Look for "Ultra Hardcore loaded successfully" message in your chat window upon login
2. **Verify UI Changes**: Your health bar, character avatar and minimap should be hidden immediately upon entering the world
3. **Test Core Features**: Target an enemy to confirm nameplate information is hidden
4. **Access Settings**: Use the `/bonnie` command to toggle the resource indicator

## Common Installation Issues

**Addon Not Appearing in List**: Ensure the folder name exactly matches "UltraHardcore" and contains the `.toc` file. The folder structure should be `Interface\AddOns\UltraHardcore\UltraHardcore.toc`.

**Interface Version Mismatch**: If you receive out-of-date warnings, the addon will still function correctly. Ultra Hardcore is designed to be forward-compatible with minor interface updates.

**Conflicting AddOns**: Some UI modification addons may conflict with Ultra Hardcore's interface changes. Disable other UI addons temporarily to isolate any conflicts.

**Permission Issues**: On some systems, you may need administrator privileges to write to the World of Warcraft directory. Run your file manager as administrator if you encounter access denied errors.

## System Requirements

- **World of Warcraft**: Classic Era (Vanilla) client
- **Interface Version**: 11507 or compatible
- **Operating System**: Windows, macOS, or Linux (any system supporting WoW Classic)
- **Disk Space**: Approximately 2.75 KB for core files plus additional space for saved variables
- **Memory**: Minimal impact on game performance (< 1MB RAM usage)

## Post-Installation Configuration

Upon first launch, Ultra Hardcore initializes with default settings optimized for maximum difficulty. However, you may want to customize certain aspects:

1. **Saved Variables**: Your preferences are automatically saved to `WTF\Account\[AccountName]\SavedVariables\UltraHardcoreDB.lua`
2. **Character-Specific Settings**: Some preferences are saved per-character for maximum flexibility

The addon requires no additional configuration to function at its core difficulty level, but advanced users can modify settings through the in-game interface or by editing the saved variables file directly.

## Core Framework Design

The addon utilizes an event-driven architecture centered around a main frame object that registers for specific World of Warcraft events. This design pattern ensures efficient resource usage and responsive behavior while maintaining compatibility with the game's security model.

```lua
-- Core frame initialization
UltraHardcore = CreateFrame('Frame')
UltraHardcore:RegisterEvent('ADDON_LOADED')
UltraHardcore:RegisterEvent('PLAYER_ENTERING_WORLD')
UltraHardcore:RegisterEvent('UNIT_HEALTH_FREQUENT')
```

The main event handler implements a dispatch system that routes events to appropriate handler functions based on event type and current game state. This approach allows for clean code organization and efficient event processing.

## File Structure and Organization

The addon follows a hierarchical file organization that promotes maintainability and code reuse:

**Core Files**:
- `UltraHardcore.lua`: Main entry point and event dispatcher
- `UltraHardcore.toc`: Addon metadata and file loading order

**Modular Components**:
- `Functions/`: Core functionality modules
- `Settings/`: Configuration management
- `Constants/`: Game data and configuration constants
- `Sounds/`: Audio assets and sound management
- `Textures/`: Visual assets and overlay systems

## Event System Architecture

Ultra Hardcore implements an event handling system that responds to different World of Warcraft events:

**Player State Events**:
- `PLAYER_ENTERING_WORLD`: Initializes addon state and applies UI modifications
- `PLAYER_UPDATE_RESTING`: Manages action bar visibility in rested areas
- `PLAYER_LEVEL_UP`: Triggers level-up specific functionality

**Combat Events**:
- `COMBAT_LOG_EVENT_UNFILTERED`: Processes combat actions for critical hit detection
- `UNIT_HEALTH_FREQUENT`: Monitors health changes for death indicator system

**UI Events**:
- `UNIT_AURA`: Manages buff/debuff related visual effects
- `GROUP_ROSTER_UPDATE`: Handles party composition changes
- `NAME_PLATE_UNIT_ADDED`: Controls enemy nameplate visibility

## Database Management System

The addon implements a saved variables system that persists user preferences and character statistics across game sessions. The database architecture supports both account-wide and character-specific data storage.

```lua
-- Database structure
UltraHardcoreDB = {
    global = {
        settings = { ... },
        statistics = { ... }
    },
    characters = {
        [characterKey] = {
            preferences = { ... },
            achievements = { ... }
        }
    }
}
```

**Data Persistence Features**:
- Automatic saving on significant events
- Character-specific preference tracking
- Cross-character statistics aggregation
- Backup and recovery mechanisms

## UI Modification Framework

Ultra Hardcore employs a UI manipulation system that modifies World of Warcraft's interface without causing taint or security violations. The framework uses secure hooking mechanisms and frame manipulation techniques.

**Frame Management**:
- Secure frame hiding using `ForceHideFrame()` utility
- Dynamic overlay creation for visual effects
- Event-driven UI state management
- Compatibility with other UI addons

**Visual Effects System**:
- Progressive screen darkening for death indicator
- Blur effects for dazed status
- Screen rotation for critical hit feedback
- Color-coded health indicators for party members

## Security and Compatibility

Ultra Hardcore adheres to Blizzard's addon security policies and maintains compatibility with the game's protected functions:

**Security Compliance**:
- No protected function hooking
- Secure frame manipulation techniques
- Taint-free operation with default UI

**Addon Compatibility**:
- Non-intrusive global namespace usage
- Defensive programming against addon conflicts
- Graceful degradation when conflicts occur