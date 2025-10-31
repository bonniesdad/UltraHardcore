# Configuration

>Ultra Hardcore provides configuration options that allow players to customize their hardcore experience while maintaining the core challenge philosophy. The configuration system is designed to be both powerful for advanced users and accessible for those who prefer simple setup.

## Global Settings Overview

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

## Runtime Configuration Commands

Ultra Hardcore supports several slash commands for real-time configuration adjustment:

**Primary Commands**:
- `/bonnie`: Toggles the Bonnie resource indicator visibility
- `/uhc help`: Displays available commands and current settings
- `/uhc reset`: Restores all settings to default hardcore values
- `/uhc status`: Shows current configuration state and active features

## Advanced Configuration Options

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

## Saved Variables Configuration

Ultra Hardcore automatically persists configuration changes through World of Warcraft's saved variables system. The configuration file is located at:

```
WTF\Account\[AccountName]\SavedVariables\UltraHardcoreDB.lua
```

**Configuration File Structure**:
```lua
UltraHardcoreDB = {
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

## Character-Specific Customization

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

## Experimental Features Configuration

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

## Configuration Validation and Error Handling

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