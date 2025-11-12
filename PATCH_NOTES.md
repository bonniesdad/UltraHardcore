# Patch Notes

## Version 1.2.9 - 2025-11-14

### New Features

- UHC Raid Frames
- Added a new command for verification of party members

### New Statistics

- Map attempts blocked
  - A statistic for the amount of times the player attempts to open the map and routep lanner blocks it

### UI Improvements

- Reset on screen statistics command: "/uhcrs" or "/uhcstatsreset"
- Added one time Resource Tracking Explainer
  - The addon will show a message on the screen explaining how to use the resource tracking feature when the minimap is hidden.
  - Added the "/uhcverify" command to verify party members
  
### Bug Fixes

- Route planner added to xp gained tracker

### Other

- Don't send the join party message on non-Hardcore servers  

## Version 1.2.8 - 2025-11-04

### New Features


### New Statistics


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

- **Tunnel Vision Covers Everything**
  - Moved to ULTRA preset settings from Recommended
- **Super Spooky Tunnel Vision**
  - When enabled, the tunnel vision will be displayed in a spooky Halloween theme.
- **Terrifying Pumpkin Themed Settings Presets**
  - New pumpkin themed ultra preset icons, a big thanks to the talented Vivi!
- **Highest Crit Appreciation Soundbite**
  - Play a soundbite when you achieve a new highest crit score
- **Party Death Soundbite**
  - Play a soundbite when a party member dies
- **Player Death Soundbite**
  - Play a soundbite when you die
- **Completely Remove Target Frame** - Added to EXPERIMENTAL settings
  - When enabled, the target frame will be completely removed from the screen.
- **Completely Remove Player Frame** - Added to EXPERIMENTAL settings
  - When enabled, the player frame will be completely removed from the screen.
- **Tooltips to Statistics labels**
  - When you hover over a statistic label, a tooltip will be displayed with the statistic description.

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

### Bug Fixes

- Auto run save resource bar position if the value is not set.

## Version 1.2.4 - 2025-10-21

### New Features

- **Added Slash command to reset resource bar position**
  - /resetresourcebar or /rrb

## Version 1.2.3 - 2025-10-20

### New Features

- **Patch notes and version update dialog**
  - Each time you update the addon, you will see this dialog with the patch notes.
- **On screen statistics are toggleable in settings menu**
  - Each player can decide which statistics they want to see on screen.
- **Pet resource bar attached to custom resource bar**

### Settings Menu Updates

- **Ultra options in settings menu**
  - Pets die permanently when killed.
  - Hide Actions bars when not resting or under Cozy Fire.
  - These settings have been moved from the Experimental section.
- **Misc options in settings menu**
  - Several options in the addon have been moved to the misc section.
  - These settings do not belong in any 'difficult' section.
- **Misc options do not show in XP Gained tracking**
  - These settings have nothing to do with the 'difficulty' of the addon, and so are not tracked for XP gained without them.

### New Options

- **Announce ULTRA player info on join party (misc option)**
  - Dungeons completed.
  - Party member deaths.
  - Both, either or non of these options can be enabled.
- **Buffs & Debuffs on resource bar (misc option)**
  - When enabled, buffs and debuffs will be displayed above and below the custom resource bar.

### Bug Fixes

- **Fixed player name right click issues**
  - Whisper tab would not update after leaving the tab.
  - Report player would not work properly.
  - Copy player name would not copy to clipboard.
- **Fixed LFG search error**

### New Statistics

- Close Escapes statistic
- Highest Crit statistic
- Dungeon Bosses Killed statistic
- Dungeons Completed statistic
- Rare Elites Slain statistic
- World Bosses Slain statistic
- Party Deaths Witnessed statistic
