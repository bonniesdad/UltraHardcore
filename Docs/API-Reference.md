# API Reference

>Ultra Hardcore exposes an API that allows other addons to integrate with its hardcore mechanics and provides advanced users with programmatic control over the addon's behavior. The API is designed with security and performance in mind while maintaining the integrity of the hardcore experience.

## Core API Functions

**UltraHardcore.GetSettings()**
Returns the current global settings configuration object.

```lua
-- Usage example
local settings = UltraHardcore.GetSettings()
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

**UltraHardcore.UpdateSetting(key, value)**
Safely updates a specific setting with validation and error handling.

```lua
-- Parameters:
-- key (string): Setting name to modify
-- value (any): New value for the setting

-- Usage examples
UltraHardcore.UpdateSetting("hidePlayerFrame", false)
UltraHardcore.UpdateSetting("deathIndicatorSensitivity", 0.8)

-- Return values:
-- true: Setting updated successfully
-- false: Invalid setting name or value
-- nil: Setting update failed due to restrictions
```

**UltraHardcore.GetPlayerStatus()**
Retrieves comprehensive information about the player's current hardcore status.

```lua
-- Usage example
local status = UltraHardcore.GetPlayerStatus()
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

## Event System API

**UltraHardcore.RegisterCallback(event, callback)**
Registers a callback function to be executed when specific Ultra Hardcore events occur.

```lua
-- Available events:
-- "DEATH_INDICATOR_CHANGED" - Death overlay intensity changed
-- "CRITICAL_HIT_RECEIVED" - Player received critical hit
-- "SETTINGS_UPDATED" - Configuration changed
-- "HARDCORE_MODE_TOGGLED" - Addon enabled/disabled

-- Usage example
UltraHardcore.RegisterCallback("CRITICAL_HIT_RECEIVED", function(damage, source)
    print(string.format("Critical hit for %d damage from %s", damage, source))
end)

-- Callback function signatures:
-- DEATH_INDICATOR_CHANGED: function(intensity, healthPercent)
-- CRITICAL_HIT_RECEIVED: function(damage, sourceUnit, spellId)
-- SETTINGS_UPDATED: function(settingName, oldValue, newValue)
-- HARDCORE_MODE_TOGGLED: function(enabled, reason)
```

**UltraHardcore.UnregisterCallback(event, callback)**
Removes a previously registered callback function.

```lua
-- Usage example
local myCallback = function(intensity, healthPercent)
    -- Handle death indicator changes
end

UltraHardcore.RegisterCallback("DEATH_INDICATOR_CHANGED", myCallback)
-- Later...
UltraHardcore.UnregisterCallback("DEATH_INDICATOR_CHANGED", myCallback)
```

## Visual Effects API

**UltraHardcore.ApplyCustomOverlay(overlayConfig)**
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

UltraHardcore.ApplyCustomOverlay(customOverlay)

-- Configuration options:
-- name (string): Unique identifier for the overlay
-- texture (string): Texture path or color specification
-- alpha (number): Opacity level (0.0 - 1.0)
-- duration (number): Display duration in seconds (0 = permanent)
-- fadeIn (number): Fade-in animation duration
-- fadeOut (number): Fade-out animation duration
-- blendMode (string): Texture blending mode
```

**UltraHardcore.RemoveCustomOverlay(name)**
Removes a custom overlay by name.

```lua
-- Usage example
UltraHardcore.RemoveCustomOverlay("MyCustomEffect")

-- Return values:
-- true: Overlay removed successfully
-- false: Overlay not found
```

**UltraHardcore.GetActiveOverlays()**
Returns information about all currently active overlays.

```lua
-- Usage example
local overlays = UltraHardcore.GetActiveOverlays()
for name, config in pairs(overlays) do
    print(string.format("Active overlay: %s (alpha: %.2f)", name, config.alpha))
end
```

## Statistics and Tracking API

**UltraHardcore.GetStatistics(scope)**
Retrieves statistical data about hardcore gameplay.

```lua
-- Parameters:
-- scope (string): "session", "character", or "account"

-- Usage examples
local sessionStats = UltraHardcore.GetStatistics("session")
local characterStats = UltraHardcore.GetStatistics("character")
local accountStats = UltraHardcore.GetStatistics("account")

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

**UltraHardcore.RecordCustomEvent(eventName, eventData)**
Records custom events for statistical tracking.

```lua
-- Parameters:
-- eventName (string): Unique event identifier
-- eventData (table): Event-specific data

-- Usage example
UltraHardcore.RecordCustomEvent("BOSS_ENCOUNTER", {
    bossName = "Ragnaros",
    duration = 180,
    outcome = "victory",
    healthRemaining = 0.15
})
```

## Integration API

**UltraHardcore.IsCompatibleAddon(addonName)**
Checks if a specific addon is compatible with Ultra Hardcore.

```lua
-- Usage example
if UltraHardcore.IsCompatibleAddon("Details") then
    print("Details addon is compatible")
else
    print("Details addon may conflict with Ultra Hardcore")
end

-- Return values:
-- true: Addon is known to be compatible
-- false: Addon may cause conflicts
-- nil: Compatibility unknown
```

**UltraHardcore.RequestFeatureDisable(featureName, reason)**
Allows other addons to request temporary disabling of specific Ultra Hardcore features.

```lua
-- Parameters:
-- featureName (string): Feature to disable
-- reason (string): Reason for the request

-- Usage example
UltraHardcore.RequestFeatureDisable("hidePlayerFrame", "Raid healing interface needed")

-- Available features:
-- "hidePlayerFrame", "hideMinimap", "hideTargetFrame"
-- "showTunnelVision", "critScreenEffect", "hideActionBars"

-- Return values:
-- true: Request approved and feature disabled
-- false: Request denied (feature is core to hardcore experience)
```

**UltraHardcore.RestoreFeature(featureName)**
Restores a previously disabled feature.

```lua
-- Usage example
UltraHardcore.RestoreFeature("hidePlayerFrame")
```

## Advanced Configuration API

**UltraHardcore.CreateCustomChallenge(challengeConfig)**
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

UltraHardcore.CreateCustomChallenge(customChallenge)
```

**UltraHardcore.GetChallengeProgress(challengeName)**
Retrieves progress information for a specific challenge.

```lua
-- Usage example
local progress = UltraHardcore.GetChallengeProgress("No Healing Challenge")
print(string.format("Progress: %d/%d conditions met", progress.completed, progress.total))
```

## Error Handling and Debugging API

**UltraHardcore.EnableDebugMode(level)**
Enables debug logging with specified verbosity level.

```lua
-- Parameters:
-- level (number): Debug level (1-5, higher = more verbose)

-- Usage example
UltraHardcore.EnableDebugMode(3)

-- Debug levels:
-- 1: Errors only
-- 2: Warnings and errors
-- 3: Info, warnings, and errors
-- 4: Debug info and above
-- 5: All messages including trace
```

**UltraHardcore.GetLastError()**
Retrieves information about the most recent error.

```lua
-- Usage example
local error = UltraHardcore.GetLastError()
if error then
    print(string.format("Last error: %s at %s", error.message, error.timestamp))
end
```

This API provides the foundation for extending Ultra Hardcore's functionality while maintaining the integrity and security of the hardcore gaming experience.