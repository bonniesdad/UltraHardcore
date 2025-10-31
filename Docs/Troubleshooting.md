# Troubleshooting

>Ultra Hardcore is designed to be robust and reliable, but the complex nature of World of Warcraft addon interactions can occasionally lead to issues. This comprehensive troubleshooting guide addresses common problems and provides systematic solutions for resolving conflicts and performance issues.

## Common Installation Issues

**Addon Not Loading**
If Ultra Hardcore doesn't appear in your addon list or fails to load, follow these diagnostic steps:

1. **Verify File Structure**: Ensure the addon folder is named exactly "UltraHardcore" and contains the `UltraHardcore.toc` file. The complete path should be `Interface\AddOns\UltraHardcore\UltraHardcore.toc`.

2. **Check Interface Version**: While Ultra Hardcore is designed to be forward-compatible, significant game updates may require interface version updates. The addon will still function with "out of date" warnings.

3. **Validate File Integrity**: Re-download the addon if files appear corrupted. Incomplete downloads or extraction errors can prevent proper loading.

4. **Clear WoW Cache**: Delete the `Cache` folder in your World of Warcraft directory to force the client to rebuild addon information.

**Features Not Working**
When specific Ultra Hardcore features fail to activate:

1. **Confirm Addon Enabled**: Verify the addon is checked in the character selection addon list and shows as loaded in-game.

2. **Check for Error Messages**: Enable Lua error display (`/console scriptErrors 1`) to identify specific error messages that might indicate the problem.

3. **Test Core Commands**: Use `/bonnie` to verify basic addon functionality. If this command doesn't work, the addon isn't properly loaded.

4. **Review Saved Variables**: Corrupted saved variables can prevent proper initialization. Delete `UltraHardcoreDB.lua` from your SavedVariables folder to reset to defaults.

## Performance and Compatibility Issues

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

## Visual Effect Problems

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

## Configuration and Settings Issues

**Settings Not Saving**
Configuration changes that don't persist between sessions:

1. **File Permissions**: Ensure World of Warcraft has write permissions to the SavedVariables directory
2. **Disk Space**: Insufficient disk space can prevent saved variable updates
3. **File Corruption**: Delete and recreate the UltraHardcoreDB.lua file to resolve corruption issues
4. **Multiple WoW Installations**: Verify you're modifying settings in the correct WoW installation directory

**Command Not Recognized**
Slash commands that don't respond properly:

1. **Verify Syntax**: Ensure commands are typed exactly as documented (case-sensitive)
2. **Check Addon Loading**: Commands won't work if the addon hasn't loaded properly
3. **Clear Chat Cache**: Sometimes chat command registration can be delayed or fail

## Advanced Troubleshooting

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
/run local mem = GetAddOnMemoryUsage("UltraHardcore"); print("UHC Memory: " .. mem .. " KB")
```

**Event Debugging**
Monitor specific events to diagnose event-related issues:

```lua
-- Enable event debugging for specific events
/run UltraHardcore:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
/run UltraHardcore.debugEvents = true
```

## Getting Help

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