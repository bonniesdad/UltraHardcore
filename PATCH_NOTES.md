# Patch Notes

## Version 3.0.1 - 2026-04-01

### New Features

- SoD - Rune Broker dialog banned.
- Death = invalidated character.
- Anti cheat protection for death.
- Save settings profile.

### UI Improvements

- Frame Ring Overlay.
- Remove invisible player frame clickable area.

## Version 3.0.0 - 2026-03-31

### New Features

- Verification tab added to settings menu.

### Code Improvements

- Remove duplicated function names with sister addons.

## Version 2.4.0 - 2026-03-17

### New Features

- Sister addon compatability

## Version 2.4.0 - 2026-03-17 (TBC)

### New Features

- Sister addon compatability

## Version 2.3.0 - 2026-03-01

### New Features

- PvP Active Warning Overlay

## Version 2.3.0 - 2026-03-01 (TBC)

### New Features

- PvP Active Warning Overlay

## Version 2.2.0 - 2026-02-26

### UI Improvements

- Statistic moved to it's own addon.
- Compatability with Utra Found and Ultra Statistics addons.

## Version 2.2.0 - 2026-02-26 (TBC)

### UI Improvements

- Statistic moved to it's own addon.
- Compatability with Utra Found and Ultra Statistics addons.

## Version 2.1.3 - 2026-01-16 (TBC)

### UI Improvements

- Better intro panel for first time characters.

## Version 2.1.3 - 2026-01-16

### UI Improvements

- Better intro panel for first time characters.

## Version 2.1.2 - 2026-01-16

### UI Improvements

- Intro panel for first time characters.

## Version 2.1.2 - 2026-01-16 (TBC)

### UI Improvements

- Intro panel for first time characters.

## Version 2.1.1 - 2026-01-14 (TBC)

### Bug Fixes

- Fix: Party health on party, raid and compact variants.

## Version 2.1.0 - 2026-01-14 (TBC)

### Bug Fixes

- Fix: Party health visible on raid style frames.
- Fix: Set Focus frame showing health etc.
- Fix: With hide action bars, rested zone repositions bars.
- Fix: When HideActionBars enabled, blizzard artwork always reappears when resting.
- Fix: Vitals overlay hidden behind TBC dropdown.

### Other

- Added /ultra commant to open settings menu.

## Version 2.0.0 - 2026-01-13 (TBC)

- TBC Initial Release
- Initial release of the addon for TBC.
- All of the features from the Classic version are now available in TBC.

## Version 2.0.0 - 2026-01-13

### New Features

- TBC Compatible version.

### UI Improvements

- Intro dialog for new users.
- Gold gained icons for each type of coin.
- Update content of "Need Help?" tab.

## Version 1.4.0 - 2026-01-05

### New Features

- Statistics notifications
  - This can be turned off in the settings menu!
  - Minimal display version (icon only)
  - Turn off individual stats by clicking the tier button in Statistics tab
- Statistics tier rewards.
  - Statistics now have a tier system.
- Session lowest health does not reset as often.
  - Check if logged out for more than 30 minutes before resetting session lowest health.
- PvP Flag icon on target frame
- Supress UHC channel join/leave notices
- Disable Guild Found on non-Hardcore servers
- Disable "Save and Reload" button when in combat

### UI Improvements

- Improved menu display for first time users.
- Remove unused tabs in settings menu.
- Fixed checkboxes borders in statistics tab not showing correctly.

### Dev Improvements

- Reverse dependancies for options menu.

## Version 1.3.0 - 2025-12-05

### UI Improvements

- New improved UI for Stats and Options tabs

### New Features

- Permanent resource tracking minimap
- Vitals Overlay
  - Displays your max health in character screen.
- Target of Target
- Target Buffs
- Target Debuffs
- Target Raid Icon
- Class colour on raid frames

### Bug Fixes

- Fix: Raid frames showing on nameplates when enabled.
- Fix: Shaman UI image missing from settings menu.

### Other

- Remove Custom Breath Indicator
- Rebrand to ULTRA from UltraHardcore
- Preview for Lives feature

## Version 1.2.10 - 2025-11-20

### Bug Fixes

- Fix: Route planner blocking map in combat even when disabled.

## Version 1.2.9 - 2025-11-19

### New Features

- Guild Found beta test
  - Guild Found is being BETA tested on the EU server Soulseeker
- UHC Raid Frames
  - Raid frames are now displayed when the player is in a raid.
  - Party can be converted to raid frames and dragged around the screen.
  - Early development stage, expect minor bugs.

### New Statistics

- Map key presses while map blocked
  - Tracks the number of times the map key has been pressed whilst blocked by the Route Planner Extreme option.

### UI Improvements

- UI Overhaul
  - Big improvements to the UHC settings menu.
- Added a new setting to show the druid mana bar when shapeshifted as a druid
- Added a new setting to anchor the druid mana bar to the resource bar when shapeshifted as a druid
  - This setting is in the Misc section of the settings menu.
  - This setting is disabled by default.
  - This setting is only available for druids.
- Reset on screen statistics command: "/uhcrs" or "/uhcstatsreset"
- Added an option to play a subtle audio cue upon reaching full health
- Added one time Resource Tracking Explainer
  - The addon will show a message on the screen explaining how to use the resource tracking feature when the minimap is hidden.
- Stop the preselected difficulties from overriding the misc settings
- Added setting tab to show all the available commands to the user

### Bug Fixes

- Fix: Route planner added to xp gained tracker

### Other

- Don't send the join party message on non-Hardcore servers

## Version 1.2.8 - 2025-11-04

### UI Improvements

- Add fstack name to route planner compass

### Bug Fixes

- Fix action bar visibility after taxi
- Fix tracking map overlay showing party members etc

### Other

- Remove Trade Restrictions
- Remove Cancel Buffs

## Version 1.2.7 - 2025-11-03

### New Features

- Reject buffs from others (experimental option)
  - When enabled, the addon will reject buffs from other players.
- Route planner now hides player position markers on the map.
- Added buttons for invite to party and leave group
  - These buttons will be displayed in the bottom right corner of the screen.
  - Only show when the "Completely Remove Player Frame" and "Completely Remove Target Frame" are enabled.
- Minimap Clock
  - Added a clock to the top right corner of the screen.
  - Added a scaling slider to update the size of the clock.
- Added resource bar colour picker.
  - Allows you to change the colour of the resource and pet resource bars.
- Added statistics background opacity slider.
  - Allows you to change the opacity of the on screen statistics background.

### New Statistics

- Mana potions used.
- Max heal crit value.
- Duels total.
- Duels won.
- Duels lost.
- Duels win percentage.
- Player jumps.

### UI Improvements

- Revamp the settings menu UI.
- Add collapseable sections to the settings menu.
- Show selection count on each option section header.
- Escape key now closes the settings menu.
- Tooltips show grey if you will receive no xp for killing the unit.
- Buffs on resource bar positioning improved for combo point characters.

### Bug Fixes

- Fix: Tunnel vision fails when reapplied within 0.6s.
- Fix: Moonkin and dire bear form resource bar default colours.

### Other

- Removed halloween holiday updates from default settings

## Version 1.2.6 - 2025-10-22

### New Features

- Added Tunnel Vision Covers Everything to ULTRA preset settings
- Added Super Spooky Tunnel Vision
  - When enabled, the tunnel vision will be displayed in a spooky Halloween theme.
- Added Terrifying Pumpkin Themed Settings Presets
- Added Highest Crit Appreciation Soundbite
  - Play a soundbite when you achieve a new highest crit value
- Added Party Death Soundbite
  - Play a soundbite when a party member dies
- Added Player Death Soundbite
  - Play a soundbite when you die
- Added "Completely Remove Target Frame" to EXPERIMENTAL settings
  - When enabled, the target frame will be completely removed from the screen.
- Added "Completely Remove Player Frame" to EXPERIMENTAL settings
  - When enabled, the player frame will be completely removed from the screen.
- Added Tooltips to Statistics labels
  - When you hover over a statistic label, a tooltip will be displayed with the statistic description.
- Added Slash command to set lowest health
  - /setlowesthealth <value> (e.g. /setlowesthealth 20)
  - <value> is a number between 0 and 100
  - This command will only set the value if it is higher than the current lowest health.

### Bug Fixes

- Fix bug where buffs are uncancellable in combat.
- Fix: Allow Hidden Action Bars to show Action Bars when on a taxi.
- Fix nameplates issue causing guild promo break. (wtf?)
- Fix Dueling lowest health level & session tracking issue.
- Fix: Missing Sound files from zip upload.
- Fix: Missing Libs from zip upload.

### Technical Improvements

- Massive codebase cleanup.

## Version 1.2.5 - 2025-10-21

- Auto run save resource bar position if the value is not set.

## Version 1.2.4 - 2025-10-21

- Added Slash command to reset resource bar position
  - /resetresourcebar or /rrb

## Version 1.2.3 - 2025-10-20

- Added Patch notes and version update dialog
  - Each time you update the addon, you will see this dialog with the patch notes.
- On screen statistics are toggleable in settings menu.
  - Each player can decide which statistics they want to see on screen.
- Pet resource bar attached to custom resource bar.
- Ultra options in settings menu
  - Pets die permanently when killed.
  - Hide Actions bars when not resting or under Cozy Fire.
  - These settings have been moved from the Experimental section.
- Misc options in settings menu
  - Several options in the addon have been moved to the misc section.
  - These settings do not belong in any 'difficult' section.
- Misc options do not show in XP Gained tracking
  - These settings have nothing to do with the 'difficulty' of the addon, and so are not tracked for XP gained without them.
- Announce ULTRA player info on join party (misc option)
  - Dungeons completed.
  - Party member deaths.
  - Both, either or non of these options can be enabled.
- Buffs & Debuffs on resource bar (misc option)
  - When enabled, buffs and debuffs will be displayed above and below the custom resource bar.
- Fixed player name right click issues.
  - Whisper tab would not update after leaving the tab.
  - Report player would not work properly.
  - Copy player name would not copy to clipboard.
- Added New Statistics:
  - Close Escapes statistic
  - Highest Crit statistic
  - Dungeon Bosses Killed statistic
  - Dungeons Completed statistic
  - Rare Elites Slain statistic
  - World Bosses Slain statistic
  - Party Deaths Witnessed statistic
- Fixed LFG search error.
