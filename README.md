# Ultra Hardcore

> A World of Warcraft Classic addon that enhances the solo player experience by adding extreme difficulty modifiers and immersive hardcore mechanics.

[![WoW Classic Era](https://img.shields.io/badge/WoW-Classic%20Era-orange)](https://worldofwarcraft.com/en-us/wowclassic)
[![Interface](https://img.shields.io/badge/Interface-11507-blue)](https://github.com/bonniesdad/Ultra)
[![Version](https://img.shields.io/badge/Version-1.2.0-green)](https://github.com/bonniesdad/Ultra/releases)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

Ultra Hardcore is a comprehensive World of Warcraft Classic addon designed to push the boundaries of the already challenging hardcore mode. By systematically removing critical UI elements and introducing punishing visual effects, this addon creates an authentic old-school gaming experience where every decision matters and death lurks around every corner.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Development](#development)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)
- [License](#license)

## Features

Ultra Hardcore transforms your World of Warcraft experience through a carefully designed system of UI modifications and gameplay enhancements that recreate the tension and uncertainty of classic gaming.



### Core Difficulty Modifiers

**No Health Bar Visibility**: The addon completely removes your character's health bar display, forcing you to rely on visual and audio cues to gauge your survival status. This fundamental change eliminates the safety net of precise health monitoring that modern players have come to depend on, recreating the uncertainty that defined early gaming experiences.

**Progressive Death Indicator**: As your health decreases, the visible area of your screen progressively shrinks through a sophisticated overlay system. This creates an increasingly claustrophobic experience as you approach death, with the screen literally closing in around you. The effect serves both as a warning system and an immersive representation of your character's deteriorating condition.

**Enemy Information Blackout**: All enemy nameplates, level indicators, and health information are systematically hidden. You'll face every encounter without knowing whether you're fighting a level 1 rabbit or a level 60 elite dragon. This uncertainty transforms every combat situation into a calculated risk, forcing you to rely on visual cues, mob behavior, and environmental context to assess threats. When the "Disable Nameplate Health" setting is enabled, nameplates display normally but health bars are stuck at 100% and level information is completely hidden for both allies and enemies. When disabled, nameplates function normally with full health and level information.

**Combat Feedback Elimination**: Damage numbers, healing amounts, and combat text are completely removed from your interface. Success and failure in combat must be judged through character animations, sound effects, and the visual state of your targets. This creates a more immersive combat experience where you must pay attention to the actual fight rather than scrolling numbers.

**Navigation Challenges**: The minimap is hidden by default, forcing you to navigate using landmarks, road signs, and environmental cues. This recreates the exploration experience of early MMORPGs where getting lost was a real possibility and geographical knowledge was a valuable skill.

### Immersive Punishment Systems

**Critical Hit Screen Disruption**: When you receive a critical hit, your camera view spins in a random direction, simulating the disorienting effect of a devastating blow. This mechanic adds a layer of chaos to combat encounters and can potentially lead to dangerous situations if you lose track of your surroundings or additional enemies.

**Dazed Visual Effects**: Being dazed triggers a blur overlay effect that obscures your vision, making it difficult to assess your surroundings or react to new threats. This visual impairment adds consequence to poor positioning and movement decisions.

**Restricted Action Bar Access**: Your action bars are only visible when you're in a rested area (inn or major city). Outside of these safe zones, you must rely on memorized keybindings and muscle memory to execute abilities. This forces careful preparation and planning before venturing into dangerous areas.

### Social and Group Dynamics

**Ally Health Indicators**: While your own health remains hidden, you can gauge your party members' condition through a color-coded healing icon system that appears above their heads. The icon gradually shifts from green to red as their health decreases, allowing for strategic healing decisions without precise health values.

**Enhanced Party Information**: The addon provides improved party management tools while maintaining the hardcore aesthetic, including streamlined party formation and communication features designed for high-stakes group content.

**Guild Integration**: Built-in guild channel functionality helps connect hardcore players and facilitates the formation of like-minded groups who appreciate the additional challenge layers.

### Advanced Challenge Systems

**Dynamic Keybinding Disruption**: When critically hit, your keybindings temporarily scramble for several seconds, forcing you to adapt quickly or risk using the wrong abilities at crucial moments. This feature is currently in development and represents the cutting edge of hardcore difficulty modification.

**Resource Management Audio Cues**: A heartbeat sound system provides audio feedback for resource regeneration during combat, replacing visual indicators with immersive audio cues that require active listening and interpretation.

**Challenge Tracking System**: An integrated logbook tracks your completion of unique hardcore challenges, providing long-term goals and achievement recognition within the hardcore community. This system is actively being expanded with new challenge types and difficulty tiers.


## Installation

Ultra Hardcore supports multiple installation methods to accommodate different user preferences and technical comfort levels. The addon is designed to work seamlessly with World of Warcraft Classic Era (Interface version 11507) and requires no external dependencies.

### Method 1: Install via Curseforge (Recommended)

1. **Download the Latest Release**
   ```bash
   # Navigate to your WoW Classic AddOns directory
   cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"
   
   # Download and extract the latest release
   # Visit: https://github.com/bonniesdad/Ultra/releases
   ```

2. **Extract to AddOns Directory**
   - Extract the downloaded ZIP file directly into your `Interface\AddOns` folder
   - Ensure the folder structure is: `Interface\AddOns\Ultra\`
   - The main addon file should be located at: `Interface\AddOns\Ultra\Ultra.lua`

3. **Enable in Game**
   - Launch World of Warcraft Classic Era
   - At the character selection screen, click "AddOns"
   - Locate "Ultra Hardcore" in the addon list
   - Check the box to enable the addon
   - Click "Okay" and enter the game
   
### Method 2: Direct Download

1. **Download the Latest Release**
   ```bash
   # Navigate to your WoW Classic AddOns directory
   cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"
   
   # Download and extract the latest release
   # Visit: https://github.com/bonniesdad/Ultra/releases
   ```

2. **Extract to AddOns Directory**
   - Extract the downloaded ZIP file directly into your `Interface\AddOns` folder
   - Ensure the folder structure is: `Interface\AddOns\Ultra\`
   - The main addon file should be located at: `Interface\AddOns\Ultra\Ultra.lua`

3. **Enable in Game**
   - Launch World of Warcraft Classic Era
   - At the character selection screen, click "AddOns"
   - Locate "Ultra Hardcore" in the addon list
   - Check the box to enable the addon
   - Click "Okay" and enter the game

### Method 3: Git Clone (For Developers)

```bash
# Navigate to your AddOns directory
cd "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns"

# Clone the repository
git clone https://github.com/bonniesdad/Ultra.git

# The addon will be automatically available in-game
```

### Method 4: Manual File Copy

1. Download the repository as a ZIP file from GitHub
2. Extract all files to a new folder named `Ultra`
3. Copy this folder to your `Interface\AddOns` directory
4. Restart World of Warcraft if it's currently running

### Verification Steps

After installation, verify the addon is working correctly:

1. **Check Addon Loading**: Look for "Ultra Hardcore loaded successfully" message in your chat window upon login
2. **Verify UI Changes**: Your health bar, character avatar and minimap should be hidden immediately upon entering the world
3. **Test Core Features**: Target an enemy to confirm nameplate information is hidden
4. **Access Settings**: Use the `/bonnie` command to toggle the resource indicator

### Common Installation Issues

**Addon Not Appearing in List**: Ensure the folder name exactly matches "Ultra" and contains the `.toc` file. The folder structure should be `Interface\AddOns\Ultra\Ultra.toc`.

**Interface Version Mismatch**: If you receive out-of-date warnings, the addon will still function correctly. Ultra Hardcore is designed to be forward-compatible with minor interface updates.

**Conflicting AddOns**: Some UI modification addons may conflict with Ultra Hardcore's interface changes. Disable other UI addons temporarily to isolate any conflicts.

**Permission Issues**: On some systems, you may need administrator privileges to write to the World of Warcraft directory. Run your file manager as administrator if you encounter access denied errors.

### System Requirements

- **World of Warcraft**: Classic Era (Vanilla) client
- **Interface Version**: 11507 or compatible
- **Operating System**: Windows, macOS, or Linux (any system supporting WoW Classic)
- **Disk Space**: Approximately 2.75 KB for core files plus additional space for saved variables
- **Memory**: Minimal impact on game performance (< 1MB RAM usage)

### Post-Installation Configuration

Upon first launch, Ultra Hardcore initializes with default settings optimized for maximum difficulty. However, you may want to customize certain aspects:

1. **Saved Variables**: Your preferences are automatically saved to `WTF\Account\[AccountName]\SavedVariables\UltraDB.lua`
2. **Character-Specific Settings**: Some preferences are saved per-character for maximum flexibility

The addon requires no additional configuration to function at its core difficulty level, but advanced users can modify settings through the in-game interface or by editing the saved variables file directly.

### Core Framework Design

The addon utilizes an event-driven architecture centered around a main frame object that registers for specific World of Warcraft events. This design pattern ensures efficient resource usage and responsive behavior while maintaining compatibility with the game's security model.

```lua
-- Core frame initialization
Ultra = CreateFrame('Frame')
Ultra:RegisterEvent('ADDON_LOADED')
Ultra:RegisterEvent('PLAYER_ENTERING_WORLD')
Ultra:RegisterEvent('UNIT_HEALTH_FREQUENT')
```

The main event handler implements a dispatch system that routes events to appropriate handler functions based on event type and current game state. This approach allows for clean code organization and efficient event processing.

### File Structure and Organization

The addon follows a hierarchical file organization that promotes maintainability and code reuse:

**Core Files**:
- `Ultra.lua`: Main entry point and event dispatcher
- `Ultra.toc`: Addon metadata and file loading order

**Modular Components**:
- `Functions/`: Core functionality modules
- `Settings/`: Configuration management
- `Constants/`: Game data and configuration constants
- `Sounds/`: Audio assets and sound management
- `Textures/`: Visual assets and overlay systems

### Event System Architecture

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

### Database Management System

The addon implements a saved variables system that persists user preferences and character statistics across game sessions. The database architecture supports both account-wide and character-specific data storage.

```lua
-- Database structure
UltraDB = {
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

### UI Modification Framework

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

### Security and Compatibility

Ultra Hardcore adheres to Blizzard's addon security policies and maintains compatibility with the game's protected functions:

**Security Compliance**:
- No protected function hooking
- Secure frame manipulation techniques
- Taint-free operation with default UI

**Addon Compatibility**:
- Non-intrusive global namespace usage
- Defensive programming against addon conflicts
- Graceful degradation when conflicts occur

## Configuration

Ultra Hardcore provides configuration options that allow players to customize their hardcore experience while maintaining the core challenge philosophy. The configuration system is designed to be both powerful for advanced users and accessible for those who prefer simple setup.

### Global Settings Overview

The addon's behavior is controlled through a comprehensive global settings object that manages all aspects of the hardcore experience:

```lua
GLOBAL_SETTINGS = {
    hidePlayerFrame = true,        -- Remove health bar visibility
    hideMinimap = true,           -- Hide minimap for navigation challenge
    hideTargetFrame = true,       -- Hide target information
    hideTargetTooltip = true,     -- Remove target tooltips
    showTunnelVision = true,      -- Enable death indicator screen effect
    showDazedEffect = true,       -- Enable dazed blur overlay
    showCritScreenMoveEffect = true, -- Enable critical hit screen rotation
    hideActionBars = false,       -- Control action bar visibility (rested areas only)
    hideGroupHealth = true,       -- Hide party member health bars
    hideUIErrors = true          -- Remove UI error messages
}
```

### Runtime Configuration Commands

Ultra Hardcore supports several slash commands for real-time configuration adjustment:

**Primary Commands**:
- `/bonnie`: Toggles the Bonnie resource indicator visibility
- `/uhc help`: Displays available commands and current settings
- `/uhc reset`: Restores all settings to default hardcore values
- `/uhc status`: Shows current configuration state and active features

### Advanced Configuration Options

**Death Indicator Sensitivity**: The progressive screen darkening effect can be fine-tuned through health percentage thresholds:

```lua
-- Death indicator activation points
if healthPercent <= 20 then
    ApplyDeathIndicatorChange(10)  -- Maximum darkness
elseif healthPercent <= 40 then
    ApplyDeathIndicatorChange(14)  -- Heavy darkening
elseif healthPercent <= 60 then
    ApplyDeathIndicatorChange(9)   -- Moderate darkening
elseif healthPercent <= 80 then
    ApplyDeathIndicatorChange(4)   -- Light darkening
end
```

**Critical Hit Screen Effects**: The screen rotation intensity and duration can be customized:

```lua
-- Screen rotation parameters
local rotationIntensity = 45      -- Degrees of rotation
local rotationDuration = 2.5      -- Seconds of effect
local recoverySpeed = 1.2         -- Return to normal speed
```

**Action Bar Visibility Rules**: The rested area detection system supports custom location definitions:

```lua
-- Rested area detection
local restedZones = {
    "Stormwind City",
    "Ironforge", 
    "Darnassus",
    "Orgrimmar",
    "Thunder Bluff",
    "Undercity"
}
```

### Saved Variables Configuration

Ultra Hardcore automatically persists configuration changes through World of Warcraft's saved variables system. The configuration file is located at:

```
WTF\Account\[AccountName]\SavedVariables\UltraDB.lua
```

**Configuration File Structure**:
```lua
UltraDB = {
    ["global"] = {
        ["settings"] = {
            ["difficultyLevel"] = 3,
            ["enableExperimentalFeatures"] = false,
            ["audioFeedbackEnabled"] = true,
            ["visualEffectsIntensity"] = 1.0
        },
        ["statistics"] = {
            ["totalDeaths"] = 0,
            ["criticalHitsReceived"] = 0,
            ["timePlayedHardcore"] = 0
        }
    },
    ["characters"] = {
        ["RealmName-CharacterName"] = {
            ["preferences"] = {
                ["resourceIndicatorVisible"] = false,
                ["customKeybindings"] = { ... }
            }
        }
    }
}
```

### Character-Specific Customization

While Ultra Hardcore maintains consistent hardcore principles across all characters, certain preferences can be customized per character:

**Individual Character Settings**:
- Resource indicator visibility preferences
- Custom keybinding configurations for scramble effects
- Achievement tracking and challenge completion status
- Personal statistics and performance metrics

**Cross-Character Features**:
- Global difficulty settings that apply to all characters
- Shared addon preferences for consistent experience
- Account-wide achievement recognition
- Unified statistics tracking

### Experimental Features Configuration

Ultra Hardcore includes several experimental features that can be enabled for testing and feedback:

**Keybinding Scramble System**:
```lua
-- Enable experimental keybinding disruption
GLOBAL_SETTINGS.enableKeybindingScramble = true
GLOBAL_SETTINGS.scrambleDuration = 3.0
GLOBAL_SETTINGS.scrambleIntensity = 0.7
```

**Enhanced Audio Feedback**:
```lua
-- Heartbeat audio system configuration
GLOBAL_SETTINGS.heartbeatEnabled = true
GLOBAL_SETTINGS.heartbeatVolume = 0.5
GLOBAL_SETTINGS.heartbeatFrequency = 1.2
```

**Advanced Challenge Tracking**:
```lua
-- Challenge system parameters
GLOBAL_SETTINGS.challengeTrackingEnabled = true
GLOBAL_SETTINGS.challengeDifficulty = "extreme"
GLOBAL_SETTINGS.shareAchievements = false
```

### Configuration Validation and Error Handling

The addon implements validation to ensure configuration changes don't compromise game stability:

**Setting Validation**:
- Type checking for all configuration values
- Range validation for numeric parameters
- Dependency checking for related settings
- Automatic fallback to safe defaults on invalid input

**Error Recovery**:
- Graceful handling of corrupted saved variables
- Automatic backup creation before major changes
- Recovery mechanisms for failed configuration updates
- User notification of configuration issues

### Performance Impact Configuration

Advanced users can fine-tune the addon's performance characteristics:

**Update Frequency Control**:
```lua
-- Visual effect update rates
GLOBAL_SETTINGS.deathIndicatorUpdateRate = 0.1    -- 10 FPS
GLOBAL_SETTINGS.healthCheckFrequency = 0.05       -- 20 FPS
GLOBAL_SETTINGS.effectProcessingRate = 0.033      -- 30 FPS
```

**Memory Usage Optimization**:
```lua
-- Memory management settings
GLOBAL_SETTINGS.enableGarbageCollection = true
GLOBAL_SETTINGS.statisticsRetentionDays = 30
GLOBAL_SETTINGS.maxCachedEvents = 1000
```

This configuration system provides the flexibility to customize the hardcore experience while maintaining the core challenge that defines Ultra Hardcore's unique approach to World of Warcraft gameplay.


## Development

Ultra Hardcore welcomes contributions from developers who share the vision of creating the ultimate hardcore World of Warcraft experience. The project maintains high standards for code quality, performance, and user experience while fostering an inclusive development environment.

### Development Environment Setup

Setting up a development environment for Ultra Hardcore requires familiarity with World of Warcraft addon development and Lua programming. The project uses modern development practices adapted for the WoW addon ecosystem.

**Prerequisites**:
- World of Warcraft Classic Era client
- Text editor with Lua syntax highlighting (VS Code, Sublime Text, or Vim)
- Git for version control
- Basic understanding of WoW addon architecture
- Familiarity with Lua programming language

**Development Setup Process**:

1. **Fork and Clone the Repository**
   ```bash
   # Fork the repository on GitHub first
   git clone https://github.com/yourusername/Ultra.git
   cd Ultra
   
   # Set up upstream remote
   git remote add upstream https://github.com/bonniesdad/Ultra.git
   ```

2. **Create Development Symlink**
   ```bash
   # Create symlink in WoW AddOns directory (Windows)
   mklink /D "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\Ultra" "C:\path\to\your\Ultra"
   
   # Create symlink on macOS/Linux
   ln -s /path/to/your/Ultra "/Applications/World of Warcraft/_classic_era_/Interface/AddOns/Ultra"
   ```

3. **Install Development Tools**
   ```bash
   # Install Node.js dependencies for linting and formatting
   npm install
   
   # Set up pre-commit hooks
   npm run setup-hooks
   ```

### Code Organization and Standards

Ultra Hardcore follows a strict code organization philosophy that emphasizes modularity, readability, and maintainability. Understanding this structure is essential for effective contribution.

**File Naming Conventions**:
- Core functionality: `PascalCase.lua` (e.g., `DeathIndicator.lua`)
- Utility functions: `Utils/PascalCase.lua` (e.g., `Utils/RotateScreenEffect.lua`)
- Database operations: `DB/PascalCase.lua` (e.g., `DB/LoadDBData.lua`)
- Settings management: `Settings/PascalCase.lua` (e.g., `Settings/Settings.lua`)

**Code Style Guidelines**:

```lua
-- Function naming: PascalCase for public functions, camelCase for private
function DeathIndicator(self, event, unit, showTunnelVision)
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100
    
    if showTunnelVision then
        if healthPercent <= 20 then
            ApplyDeathIndicatorChange(10)
        elseif healthPercent <= 40 then
            ApplyDeathIndicatorChange(14)
        end
    else
        RemoveDeathIndicator()
    end
end

-- Local variables for performance optimization
local function updateHealthIndicator(unit, healthPercent)
    -- Implementation details
end
```

**Documentation Standards**:
- All public functions must include comprehensive comments
- Complex algorithms require step-by-step explanation
- Event handlers must document their trigger conditions
- Configuration options need usage examples

### Testing and Quality Assurance

Ultra Hardcore maintains rigorous testing standards to ensure stability and performance across different game scenarios and hardware configurations.

**Testing Framework**:
The addon includes a custom testing framework designed specifically for World of Warcraft addon validation:

```lua
-- Test framework example
UHCTestSuite = {
    testDeathIndicator = function()
        -- Simulate health loss
        local mockHealth = 0.3
        DeathIndicator(nil, "UNIT_HEALTH_FREQUENT", "player", true)
        
        -- Verify overlay application
        assert(deathOverlayActive == true, "Death overlay should be active at 30% health")
    end,
    
    testCriticalHitEffect = function()
        -- Simulate critical hit event
        OnCombatLogEvent(nil, "SPELL_DAMAGE", nil, nil, nil, nil, nil, nil, true)
        
        -- Verify screen rotation
        assert(screenRotationActive == true, "Screen rotation should activate on critical hit")
    end
}
```

**Manual Testing Procedures**:
1. **Core Functionality Testing**: Verify all primary features work correctly
2. **Edge Case Testing**: Test extreme scenarios (very low health, multiple critical hits)
3. **Performance Testing**: Monitor frame rate impact during intensive scenarios
4. **Compatibility Testing**: Ensure compatibility with popular addons
5. **User Experience Testing**: Validate that the hardcore experience remains challenging but fair

**Automated Testing**:
```bash
# Run automated test suite
npm run test

# Run performance benchmarks
npm run benchmark

# Validate code style
npm run lint
```

### Contributing Guidelines

Ultra Hardcore follows a structured contribution process that ensures code quality while welcoming developers of all skill levels.

**Contribution Workflow**:

1. **Issue Discussion**: Before implementing features, discuss your ideas in GitHub issues
2. **Feature Branch**: Create a descriptive branch name (e.g., `feature/enhanced-death-indicator`)
3. **Implementation**: Follow coding standards and include comprehensive tests
4. **Documentation**: Update relevant documentation and code comments
5. **Pull Request**: Submit a detailed pull request with clear description and testing notes

**Pull Request Requirements**:
- Clear description of changes and motivation
- Comprehensive testing of new functionality
- Documentation updates for user-facing changes
- Performance impact assessment
- Compatibility verification with existing features

**Code Review Process**:
All contributions undergo thorough code review focusing on:
- Code quality and adherence to project standards
- Performance implications and optimization opportunities
- User experience impact and hardcore philosophy alignment
- Security considerations and addon safety
- Documentation completeness and accuracy

### Development Tools and Utilities

Ultra Hardcore provides several development tools to streamline the contribution process:

**Debugging Utilities**:
```lua
-- Debug logging system
UHCDebug = {
    log = function(message, level)
        if GLOBAL_SETTINGS.debugMode then
            print(string.format("[UHC-%s] %s", level or "INFO", message))
        end
    end,
    
    dumpSettings = function()
        -- Output current settings for debugging
        for key, value in pairs(GLOBAL_SETTINGS) do
            UHCDebug.log(string.format("%s: %s", key, tostring(value)))
        end
    end
}
```

**Performance Profiling**:
```lua
-- Performance monitoring
UHCProfiler = {
    startTimer = function(name)
        UHCProfiler.timers[name] = GetTime()
    end,
    
    endTimer = function(name)
        local elapsed = GetTime() - (UHCProfiler.timers[name] or 0)
        UHCDebug.log(string.format("Timer %s: %.3fms", name, elapsed * 1000))
    end
}
```

**Development Configuration**:
```lua
-- Development-specific settings
if GLOBAL_SETTINGS.developmentMode then
    GLOBAL_SETTINGS.debugMode = true
    GLOBAL_SETTINGS.enableProfiling = true
    GLOBAL_SETTINGS.skipIntroAnimations = true
    GLOBAL_SETTINGS.fastTestMode = true
end
```

## API Reference

Ultra Hardcore exposes an API that allows other addons to integrate with its hardcore mechanics and provides advanced users with programmatic control over the addon's behavior. The API is designed with security and performance in mind while maintaining the integrity of the hardcore experience.

### Core API Functions

**Ultra.GetSettings()**
Returns the current global settings configuration object.

```lua
-- Usage example
local settings = Ultra.GetSettings()
if settings.hidePlayerFrame then
    print("Health bar is currently hidden")
end

-- Return value structure
{
    hidePlayerFrame = boolean,
    hideMinimap = boolean,
    showTunnelVision = boolean,
    -- ... additional settings
}
```

**Ultra.UpdateSetting(key, value)**
Safely updates a specific setting with validation and error handling.

```lua
-- Parameters:
-- key (string): Setting name to modify
-- value (any): New value for the setting

-- Usage examples
Ultra.UpdateSetting("hidePlayerFrame", false)
Ultra.UpdateSetting("deathIndicatorSensitivity", 0.8)

-- Return values:
-- true: Setting updated successfully
-- false: Invalid setting name or value
-- nil: Setting update failed due to restrictions
```

**Ultra.GetPlayerStatus()**
Retrieves comprehensive information about the player's current hardcore status.

```lua
-- Usage example
local status = Ultra.GetPlayerStatus()
print(string.format("Health: %d%%, Deaths: %d", status.healthPercent, status.deathCount))

-- Return value structure
{
    healthPercent = number,        -- Current health percentage (0-100)
    isInCombat = boolean,         -- Combat state
    deathIndicatorActive = boolean, -- Death overlay status
    criticalHitCount = number,    -- Session critical hits received
    timeInHardcoreMode = number,  -- Total time played with addon
    currentZone = string,         -- Current zone name
    isInRestedArea = boolean      -- Rested area status
}
```

### Event System API

**Ultra.RegisterCallback(event, callback)**
Registers a callback function to be executed when specific Ultra Hardcore events occur.

```lua
-- Available events:
-- "DEATH_INDICATOR_CHANGED" - Death overlay intensity changed
-- "CRITICAL_HIT_RECEIVED" - Player received critical hit
-- "SETTINGS_UPDATED" - Configuration changed
-- "HARDCORE_MODE_TOGGLED" - Addon enabled/disabled

-- Usage example
Ultra.RegisterCallback("CRITICAL_HIT_RECEIVED", function(damage, source)
    print(string.format("Critical hit for %d damage from %s", damage, source))
end)

-- Callback function signatures:
-- DEATH_INDICATOR_CHANGED: function(intensity, healthPercent)
-- CRITICAL_HIT_RECEIVED: function(damage, sourceUnit, spellId)
-- SETTINGS_UPDATED: function(settingName, oldValue, newValue)
-- HARDCORE_MODE_TOGGLED: function(enabled, reason)
```

**Ultra.UnregisterCallback(event, callback)**
Removes a previously registered callback function.

```lua
-- Usage example
local myCallback = function(intensity, healthPercent)
    -- Handle death indicator changes
end

Ultra.RegisterCallback("DEATH_INDICATOR_CHANGED", myCallback)
-- Later...
Ultra.UnregisterCallback("DEATH_INDICATOR_CHANGED", myCallback)
```

### Visual Effects API

**Ultra.ApplyCustomOverlay(overlayConfig)**
Creates custom visual overlays using the Ultra Hardcore overlay system.

```lua
-- Parameters:
-- overlayConfig (table): Overlay configuration object

-- Usage example
local customOverlay = {
    name = "MyCustomEffect",
    texture = "Interface\\FullScreenTextures\\LowHealth",
    alpha = 0.5,
    duration = 3.0,
    fadeIn = 0.5,
    fadeOut = 1.0,
    blendMode = "BLEND"
}

Ultra.ApplyCustomOverlay(customOverlay)

-- Configuration options:
-- name (string): Unique identifier for the overlay
-- texture (string): Texture path or color specification
-- alpha (number): Opacity level (0.0 - 1.0)
-- duration (number): Display duration in seconds (0 = permanent)
-- fadeIn (number): Fade-in animation duration
-- fadeOut (number): Fade-out animation duration
-- blendMode (string): Texture blending mode
```

**Ultra.RemoveCustomOverlay(name)**
Removes a custom overlay by name.

```lua
-- Usage example
Ultra.RemoveCustomOverlay("MyCustomEffect")

-- Return values:
-- true: Overlay removed successfully
-- false: Overlay not found
```

**Ultra.GetActiveOverlays()**
Returns information about all currently active overlays.

```lua
-- Usage example
local overlays = Ultra.GetActiveOverlays()
for name, config in pairs(overlays) do
    print(string.format("Active overlay: %s (alpha: %.2f)", name, config.alpha))
end
```

### Statistics and Tracking API

**Ultra.GetStatistics(scope)**
Retrieves statistical data about hardcore gameplay.

```lua
-- Parameters:
-- scope (string): "session", "character", or "account"

-- Usage examples
local sessionStats = Ultra.GetStatistics("session")
local characterStats = Ultra.GetStatistics("character")
local accountStats = Ultra.GetStatistics("account")

-- Return value structure
{
    timePlayed = number,          -- Total time in seconds
    deathCount = number,          -- Number of deaths
    criticalHitsReceived = number, -- Critical hits taken
    nearDeathExperiences = number, -- Times below 10% health
    zonesExplored = table,        -- List of zones visited
    achievementsUnlocked = table, -- Hardcore achievements
    averageHealthPercent = number, -- Session average health
    combatTime = number,          -- Time spent in combat
    restedTime = number          -- Time spent in rested areas
}
```

**Ultra.RecordCustomEvent(eventName, eventData)**
Records custom events for statistical tracking.

```lua
-- Parameters:
-- eventName (string): Unique event identifier
-- eventData (table): Event-specific data

-- Usage example
Ultra.RecordCustomEvent("BOSS_ENCOUNTER", {
    bossName = "Ragnaros",
    duration = 180,
    outcome = "victory",
    healthRemaining = 0.15
})
```

### Integration API

**Ultra.IsCompatibleAddon(addonName)**
Checks if a specific addon is compatible with Ultra Hardcore.

```lua
-- Usage example
if Ultra.IsCompatibleAddon("Details") then
    print("Details addon is compatible")
else
    print("Details addon may conflict with Ultra Hardcore")
end

-- Return values:
-- true: Addon is known to be compatible
-- false: Addon may cause conflicts
-- nil: Compatibility unknown
```

**Ultra.RequestFeatureDisable(featureName, reason)**
Allows other addons to request temporary disabling of specific Ultra Hardcore features.

```lua
-- Parameters:
-- featureName (string): Feature to disable
-- reason (string): Reason for the request

-- Usage example
Ultra.RequestFeatureDisable("hidePlayerFrame", "Raid healing interface needed")

-- Available features:
-- "hidePlayerFrame", "hideMinimap", "hideTargetFrame"
-- "showTunnelVision", "critScreenEffect", "hideActionBars"

-- Return values:
-- true: Request approved and feature disabled
-- false: Request denied (feature is core to hardcore experience)
```

**Ultra.RestoreFeature(featureName)**
Restores a previously disabled feature.

```lua
-- Usage example
Ultra.RestoreFeature("hidePlayerFrame")
```

### Advanced Configuration API

**Ultra.CreateCustomChallenge(challengeConfig)**
Creates custom hardcore challenges with tracking and achievement integration.

```lua
-- Parameters:
-- challengeConfig (table): Challenge configuration object

-- Usage example
local customChallenge = {
    name = "No Healing Challenge",
    description = "Complete a dungeon without using healing spells",
    category = "Combat",
    difficulty = "Extreme",
    conditions = {
        {
            type = "SPELL_CAST_SUCCESS",
            spellCategories = {"Healing"},
            maxCount = 0
        },
        {
            type = "ZONE_COMPLETION",
            zoneType = "Dungeon",
            minCount = 1
        }
    },
    rewards = {
        title = "The Unhealed",
        achievement = "NO_HEALING_MASTER"
    }
}

Ultra.CreateCustomChallenge(customChallenge)
```

**Ultra.GetChallengeProgress(challengeName)**
Retrieves progress information for a specific challenge.

```lua
-- Usage example
local progress = Ultra.GetChallengeProgress("No Healing Challenge")
print(string.format("Progress: %d/%d conditions met", progress.completed, progress.total))
```

### Error Handling and Debugging API

**Ultra.EnableDebugMode(level)**
Enables debug logging with specified verbosity level.

```lua
-- Parameters:
-- level (number): Debug level (1-5, higher = more verbose)

-- Usage example
Ultra.EnableDebugMode(3)

-- Debug levels:
-- 1: Errors only
-- 2: Warnings and errors
-- 3: Info, warnings, and errors
-- 4: Debug info and above
-- 5: All messages including trace
```

**Ultra.GetLastError()**
Retrieves information about the most recent error.

```lua
-- Usage example
local error = Ultra.GetLastError()
if error then
    print(string.format("Last error: %s at %s", error.message, error.timestamp))
end
```

This API provides the foundation for extending Ultra Hardcore's functionality while maintaining the integrity and security of the hardcore gaming experience.


## Contributing

Ultra Hardcore thrives on community contributions from developers, testers, and hardcore gaming enthusiasts who share our vision of creating the ultimate challenging World of Warcraft experience. We welcome contributions of all types, from code improvements to documentation enhancements to gameplay suggestions.

### Ways to Contribute

**Code Contributions**: Help improve the addon's functionality, performance, and compatibility. Whether you're fixing bugs, implementing new features, or optimizing existing code, your programming skills can make Ultra Hardcore even better.

**Testing and Quality Assurance**: Test the addon across different scenarios, character classes, and game situations. Report bugs, edge cases, and compatibility issues to help maintain the addon's stability and reliability.

**Documentation**: Improve user guides, API documentation, code comments, and help resources. Clear documentation is essential for helping new users understand and adopt the hardcore gaming philosophy.

**Feature Design**: Propose new hardcore mechanics, visual effects, and challenge systems that align with the addon's philosophy of creating authentic difficulty without compromising game integrity.

**Community Support**: Help other users in discussions, provide troubleshooting assistance, and share your hardcore gaming experiences to build a stronger community around challenging gameplay.

### Getting Started with Contributions

**Join the Community**: Connect with other contributors through our Discord server where we discuss development priorities, share ideas, and coordinate efforts. The community provides valuable feedback and helps maintain the addon's direction.

**Understand the Philosophy**: Ultra Hardcore is built around the principle of creating authentic difficulty through information limitation and consequence amplification, not through artificial stat modifications or game-breaking changes. All contributions should align with this core philosophy.

**Review Existing Issues**: Check the GitHub issues page for bug reports, feature requests, and ongoing discussions. Many contributions start by addressing existing problems or implementing requested features.

**Start Small**: New contributors are encouraged to begin with smaller tasks like documentation improvements, minor bug fixes, or code cleanup before tackling major features.

### Contribution Process

**1. Discussion and Planning**
Before implementing significant changes, open an issue to discuss your ideas with the community and maintainers. This ensures your contribution aligns with project goals and prevents duplicate work.

**2. Development Setup**
Follow the development environment setup instructions in the Development section. Ensure you can build, test, and run the addon locally before making changes.

**3. Implementation**
Write clean, well-documented code that follows the project's coding standards. Include comprehensive comments explaining complex logic and ensure your changes don't break existing functionality.

**4. Testing**
Thoroughly test your changes across different scenarios. Include both automated tests where applicable and manual testing in various game situations.

**5. Documentation**
Update relevant documentation, including code comments, user guides, and API documentation. Ensure other developers and users can understand and use your contributions.

**6. Pull Request Submission**
Submit a detailed pull request with a clear description of your changes, the problem they solve, and how they've been tested. Include screenshots or videos for visual changes.

### Code Contribution Guidelines

**Coding Standards**: Follow the established Lua coding conventions used throughout the project. Use consistent indentation, meaningful variable names, and appropriate commenting.

**Performance Considerations**: World of Warcraft addons must be highly optimized to avoid impacting game performance. Consider memory usage, CPU efficiency, and frame rate impact when implementing features.

**Security and Compatibility**: Ensure your code doesn't introduce security vulnerabilities or compatibility issues with other addons. Follow Blizzard's addon development guidelines and avoid protected function modifications.

**Error Handling**: Implement robust error handling that gracefully manages unexpected situations without crashing the addon or affecting the game client.

### Testing Guidelines

**Functional Testing**: Verify that new features work correctly across different character classes, levels, and game scenarios. Test edge cases and unusual situations that might not be immediately obvious.

**Performance Testing**: Monitor the addon's impact on game performance, especially during intensive scenarios like raids or large-scale PvP battles.

**Compatibility Testing**: Ensure your changes don't conflict with popular addons that users commonly run alongside Ultra Hardcore.

**Regression Testing**: Verify that your changes don't break existing functionality or introduce new bugs in previously working features.

### Documentation Standards

**Code Documentation**: Include comprehensive comments explaining the purpose, parameters, and return values of functions. Document complex algorithms and non-obvious implementation decisions.

**User Documentation**: Write clear, step-by-step instructions for new features. Include examples and screenshots where helpful.

**API Documentation**: Maintain accurate and complete API documentation for functions that other developers might use.

**Changelog Maintenance**: Document all changes in the project changelog, including bug fixes, new features, and breaking changes.

### Community Guidelines

**Respectful Communication**: Maintain a welcoming and inclusive environment for all contributors regardless of experience level or background.

**Constructive Feedback**: Provide helpful, specific feedback on contributions. Focus on the code and ideas rather than personal criticism.

**Collaborative Problem Solving**: Work together to find the best solutions to challenges. Different perspectives and approaches often lead to better outcomes.

**Knowledge Sharing**: Share your expertise and learn from others. The hardcore gaming community benefits when knowledge and techniques are shared openly.

### Recognition and Attribution

**Contributor Recognition**: All contributors are acknowledged in the project's credits and changelog. Significant contributions may be highlighted in release notes and community announcements.

**Authorship**: Code contributions are attributed to their authors through Git commit history and contributor lists.

**Community Appreciation**: The Ultra Hardcore community regularly celebrates and thanks contributors for their efforts in making the addon better.

Contributing to Ultra Hardcore is more than just writing code—it's about joining a community dedicated to preserving and enhancing the challenging, immersive gaming experiences that made classic MMORPGs special. Every contribution, no matter how small, helps maintain and improve this unique approach to World of Warcraft gameplay.


## Troubleshooting

Ultra Hardcore is designed to be robust and reliable, but the complex nature of World of Warcraft addon interactions can occasionally lead to issues. This comprehensive troubleshooting guide addresses common problems and provides systematic solutions for resolving conflicts and performance issues.

### Common Installation Issues

**Addon Not Loading**
If Ultra Hardcore doesn't appear in your addon list or fails to load, follow these diagnostic steps:

1. **Verify File Structure**: Ensure the addon folder is named exactly "Ultra" and contains the `Ultra.toc` file. The complete path should be `Interface\AddOns\Ultra\Ultra.toc`.

2. **Check Interface Version**: While Ultra Hardcore is designed to be forward-compatible, significant game updates may require interface version updates. The addon will still function with "out of date" warnings.

3. **Validate File Integrity**: Re-download the addon if files appear corrupted. Incomplete downloads or extraction errors can prevent proper loading.

4. **Clear WoW Cache**: Delete the `Cache` folder in your World of Warcraft directory to force the client to rebuild addon information.

**Features Not Working**
When specific Ultra Hardcore features fail to activate:

1. **Confirm Addon Enabled**: Verify the addon is checked in the character selection addon list and shows as loaded in-game.

2. **Check for Error Messages**: Enable Lua error display (`/console scriptErrors 1`) to identify specific error messages that might indicate the problem.

3. **Test Core Commands**: Use `/bonnie` to verify basic addon functionality. If this command doesn't work, the addon isn't properly loaded.

4. **Review Saved Variables**: Corrupted saved variables can prevent proper initialization. Delete `UltraDB.lua` from your SavedVariables folder to reset to defaults.

### Performance and Compatibility Issues

**Frame Rate Drops**
Ultra Hardcore is optimized for minimal performance impact, but certain configurations or conflicts can cause frame rate issues:

1. **Monitor Resource Usage**: Use `/frameratemonitor` or similar tools to identify when frame rate drops occur in relation to Ultra Hardcore features.

2. **Adjust Visual Effects**: Reduce the frequency of death indicator updates or disable experimental features that may be causing performance issues.

3. **Check for Conflicts**: Disable other UI addons temporarily to isolate whether conflicts are causing performance problems.

4. **Update Graphics Drivers**: Ensure your graphics drivers are current, as some visual effects may interact poorly with outdated drivers.

**Addon Conflicts**
Ultra Hardcore is designed to coexist with most addons, but conflicts can occur:

**Common Conflict Sources**:
- **UI Replacement Addons**: ElvUI, Bartender, and similar comprehensive UI replacements may conflict with Ultra Hardcore's interface modifications
- **Combat Addons**: Damage meters and combat analysis tools may interfere with the hidden damage text feature
- **Nameplate Addons**: Custom nameplate addons may conflict with Ultra Hardcore's nameplate hiding functionality

**Conflict Resolution Process**:
1. **Identify Conflicting Addon**: Disable addons one by one to isolate which addon is causing conflicts
2. **Check Load Order**: Ensure Ultra Hardcore loads after conflicting addons by modifying the TOC file if necessary
3. **Configure Compatibility**: Many conflicts can be resolved by configuring the conflicting addon to avoid overlapping functionality
4. **Report Compatibility Issues**: Submit detailed conflict reports to help improve future compatibility

### Visual Effect Problems

**Death Indicator Not Appearing**
The progressive screen darkening effect is a core Ultra Hardcore feature that should activate automatically:

1. **Verify Health Detection**: Ensure the addon can properly detect your health status by checking that other health-related features work
2. **Check Graphics Settings**: Some graphics configurations may interfere with overlay rendering
3. **Test in Different Zones**: Certain zones or situations may affect overlay functionality
4. **Reset Visual Settings**: Use `/uhc reset` to restore default visual effect settings

**Screen Rotation Issues**
Critical hit screen rotation effects may malfunction under certain conditions:

1. **Camera Settings**: Ensure your camera settings allow for programmatic rotation
2. **Input Conflicts**: Some input modification addons may interfere with camera control
3. **Hardware Acceleration**: Graphics hardware acceleration issues can affect smooth rotation effects

**Overlay Persistence**
Visual overlays that don't clear properly can obstruct gameplay:

1. **Manual Overlay Clearing**: Use `/uhc clearoverlays` to manually remove stuck overlays
2. **Restart UI**: `/reload` will reset all visual effects and clear persistent overlays
3. **Check for Memory Leaks**: Persistent overlays may indicate memory management issues that require addon restart

### Configuration and Settings Issues

**Settings Not Saving**
Configuration changes that don't persist between sessions:

1. **File Permissions**: Ensure World of Warcraft has write permissions to the SavedVariables directory
2. **Disk Space**: Insufficient disk space can prevent saved variable updates
3. **File Corruption**: Delete and recreate the UltraDB.lua file to resolve corruption issues
4. **Multiple WoW Installations**: Verify you're modifying settings in the correct WoW installation directory

**Command Not Recognized**
Slash commands that don't respond properly:

1. **Verify Syntax**: Ensure commands are typed exactly as documented (case-sensitive)
2. **Check Addon Loading**: Commands won't work if the addon hasn't loaded properly
3. **Clear Chat Cache**: Sometimes chat command registration can be delayed or fail

### Advanced Troubleshooting

**Debug Mode Activation**
For complex issues, enable debug mode to gather detailed diagnostic information:

```lua
-- Enable comprehensive debugging
/run GLOBAL_SETTINGS.debugMode = true
/run GLOBAL_SETTINGS.verboseLogging = true
/reload
```

**Log File Analysis**
Ultra Hardcore generates detailed logs when debug mode is enabled:

1. **Locate Log Files**: Debug logs are written to the SavedVariables directory
2. **Analyze Error Patterns**: Look for recurring errors or warnings that might indicate the root cause
3. **Timestamp Correlation**: Match error timestamps with when problems occur in-game

**Memory Usage Monitoring**
Monitor addon memory usage to identify potential memory leaks:

```lua
-- Check addon memory usage
/run local mem = GetAddOnMemoryUsage("Ultra"); print("UHC Memory: " .. mem .. " KB")
```

**Event Debugging**
Monitor specific events to diagnose event-related issues:

```lua
-- Enable event debugging for specific events
/run Ultra:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
/run Ultra.debugEvents = true
```

### Getting Help

**Community Support**
The Ultra Hardcore community provides support through the community discord channel:
- https://discord.com/invite/zuSPDNhYEN

**Bug Reporting**
When reporting bugs, include the following information:
- Exact steps to reproduce the issue
- Your character class, level, and current zone
- List of other installed addons
- Any error messages or unusual behavior
- Screenshots or videos of the problem

**Feature Requests**
Suggest new features or improvements through GitHub issues with:
- Clear description of the desired functionality
- Explanation of how it fits the hardcore philosophy
- Examples of similar features in other contexts
- Consideration of implementation complexity

**Emergency Fixes**
For critical issues that prevent gameplay:

1. **Disable Ultra Hardcore**: Temporarily disable the addon to continue playing
2. **Safe Mode**: Use `/uhc safemode` to disable all visual effects while keeping core functionality
3. **Factory Reset**: Use `/uhc factoryreset` to restore all settings to default values
4. **Complete Removal**: Delete the addon folder and saved variables for complete removal

This troubleshooting guide covers the most common issues encountered by Ultra Hardcore users. For problems not addressed here, the community is always ready to provide assistance and work toward solutions that maintain the addon's hardcore gaming philosophy.


## Credits

Ultra Hardcore represents the collaborative effort of dedicated developers, testers, and community members who share a passion for challenging, authentic gaming experiences. This project builds upon the rich tradition of World of Warcraft addon development while pushing the boundaries of what's possible within the game's framework.

### Core Development Team

**Bonnie's Dad** - *Project Creator and Lead Developer*
The visionary behind Ultra Hardcore, Bonnie's Dad conceived and implemented the core philosophy of creating authentic difficulty through information limitation rather than artificial stat modifications. Their deep understanding of World of Warcraft's mechanics and commitment to preserving the essence of hardcore gaming drives the project's direction and maintains its focus on meaningful challenge.

### Technical Acknowledgments

**World of Warcraft Addon Framework**: Ultra Hardcore is built upon Blizzard Entertainment's robust addon framework, which provides the foundation for all World of Warcraft modifications. The framework's event system, UI manipulation capabilities, and security model enable the sophisticated functionality that defines Ultra Hardcore.

**Lua Programming Language**: The project leverages the power and flexibility of Lua, a lightweight scripting language that provides the perfect balance of performance and expressiveness for World of Warcraft addon development.

**Open Source Community**: Ultra Hardcore benefits from the broader open source community's tools, practices, and knowledge sharing. The project follows established open source development practices and contributes back to the community through its own open source release.

### Future Contributors

Ultra Hardcore continues to evolve through community contributions, and we acknowledge in advance the future contributors who will help shape the project's continued development. Whether through code contributions, testing, documentation, or community support, every contribution helps maintain and improve the authentic hardcore gaming experience that defines Ultra Hardcore.

### License and Legal

Ultra Hardcore is released under an open source license that encourages community contribution while protecting the project's integrity and ensuring its continued availability to the hardcore gaming community. The project respects Blizzard Entertainment's intellectual property and operates within the guidelines established for World of Warcraft addon development.

### Contact and Recognition

Contributors who wish to be recognized for their efforts or who have questions about attribution should reach out through the project's official channels. The development team is committed to properly acknowledging all contributions and maintaining accurate records of community involvement.

## License

Ultra Hardcore is released under the MIT License, which provides maximum freedom for community use, modification, and distribution while maintaining appropriate attribution requirements. This license choice reflects the project's commitment to open source development and community collaboration.

## Links and Resources

- **GitHub Repository**: [https://github.com/bonniesdad/Ultra](https://github.com/bonniesdad/Ultra)
- **Discord Community**: Join our Discord server for real-time support and community discussion
- **Development YouTube Series**: [https://www.youtube.com/@Bonnies-Dad](https://www.youtube.com/@Bonnies-Dad)
- **Issue Tracker**: [https://github.com/bonniesdad/Ultra/issues](https://github.com/bonniesdad/Ultra/issues)
- **CurseForge Page**: [https://www.curseforge.com/wow/addons/ultra-hardcore](https://www.curseforge.com/wow/addons/ultra-hardcore)
- **World of Warcraft Classic**: [https://worldofwarcraft.com/en-us/wowclassic](https://worldofwarcraft.com/en-us/wowclassic)
