--[[
  Preset Sections Configuration
  Defines the preset categories and their associated settings for the UltraHardcore addon
  Used across Settings UI, Statistics display, and XP tracking
]]

-- Base preset sections configuration
-- Each section contains a title and array of setting names
local PRESET_SECTIONS = { {
  title = 'Lite:',
  settings = { 'hidePlayerFrame', 'showTunnelVision' },
}, {
  title = 'Recommended:',
  settings = {
    'hideTargetFrame',
    'hideTargetTooltip',
    'disableNameplateHealth',
    'showDazedEffect',
    'hideGroupHealth',
    'hideMinimap',
  },
}, {
  title = 'Extreme:',
  settings = {
    'petsDiePermanently',
    'hideActionBars',
    'tunnelVisionMaxStrata',
    'routePlanner',
  },
}, {
  title = 'Experimental:',
  settings = {
    'hideBreathIndicator',
    'hidePlayerCastBar',
    'showCritScreenMoveEffect',
    'showFullHealthIndicator',
    'showFullHealthIndicatorAudioCue',
    'hideCustomResourceBar',
    'showIncomingDamageEffect',
    'showHealingIndicator',
    'setFirstPersonCamera',
    'completelyRemovePlayerFrame',
    'completelyRemoveTargetFrame',
    'routePlannerCompass',
    'showTargetDebuffs',
  },
},  {
  title = 'Misc:',
  settings = {
    'showOnScreenStatistics',
    'announceLevelUpToGuild',
    'hideUIErrors',
    'showClockEvenWhenMapHidden',
    'announcePartyDeathsOnGroupJoin',
    'announceDungeonsCompletedOnGroupJoin',
    'buffBarOnResourceBar',
    'hideBuffsCompletely',
    'hideDebuffs',
    'newHighCritAppreciationSoundbite',
    'playPartyDeathSoundbite',
    'playPlayerDeathSoundbite',
    'spookyTunnelVision',
    'roachHearthstoneInPartyCombat',
  },
}, {
  title = 'XP Bar:',
  settings = {
    'showExpBar',
    'showXpBarToolTip',
    'hideDefaultExpBar',
    'xpBarHeight',
  },
}, }

-- Function to get preset sections with custom title formatting
-- @param titleFormat: "simple" for "Lite:", "extended" for "Lite Preset Settings:", or custom function
-- @param includeMisc: boolean to include/exclude the Misc section
local function GetPresetSections(titleFormat, includeMisc)
  local sections = {}

  for i, section in ipairs(PRESET_SECTIONS) do
    -- Skip Misc section if not requested
    if section.title == 'Misc:' and not includeMisc then
      -- Skip this iteration
    else
      local formattedTitle = section.title

      if titleFormat == 'extended' then
        -- Convert "Lite:" to "Lite Preset Settings:"
        formattedTitle = section.title:gsub(':', ' Preset Settings:')
      elseif type(titleFormat) == 'function' then
        formattedTitle = titleFormat(section.title)
      end

      table.insert(sections, {
        title = formattedTitle,
        settings = section.settings,
      })
    end
  end

  return sections
end

-- Export the functions globally
_G.GetPresetSections = GetPresetSections
_G.PRESET_SECTIONS = PRESET_SECTIONS
