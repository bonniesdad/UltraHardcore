-- Global UI Reset Utility
-- Handles resetting all draggable UI elements to their default positions

-- Combined reset function for all draggable UI elements
local function ResetUI()
  -- Reset minimap elements (these are local functions, so we call via slash commands)
  if SlashCmdList['RESETCLOCKPOSITION'] then
    SlashCmdList['RESETCLOCKPOSITION']()
  end
  if SlashCmdList['RESETMAILPOSITION'] then
    SlashCmdList['RESETMAILPOSITION']()
  end
  if SlashCmdList['RESETTRACKINGPOSITION'] then
    SlashCmdList['RESETTRACKINGPOSITION']()
  end

  -- Reset resource bar
  if _G.ResetResourceBarPosition then
    _G.ResetResourceBarPosition()
  elseif SlashCmdList['RESETRESOURCEBAR'] then
    SlashCmdList['RESETRESOURCEBAR']()
  end

  -- Reset resource indicator
  if _G.ResetResourceIndicatorPosition then
    _G.ResetResourceIndicatorPosition()
  end

  -- Reset soulshard indicator
  if _G.ResetSoulshardPosition then
    _G.ResetSoulshardPosition()
  end

  -- Reset statistics panel
  if _G.ResetStatsFramePosition then
    _G.ResetStatsFramePosition()
  end

  -- Reset ULTRA Menu frame
  if _G.ResetULTRAMenuFramesPosition then
    _G.ResetULTRAMenuFramesPosition()
  end

  print('|cfff44336[ULTRA]|r All UI element positions reset to default.')
end

-- Slash command to reset UI elements
SLASH_RESETUI1 = '/resetui'
SLASH_RESETUI2 = '/rui'
SlashCmdList['RESETUI'] = ResetUI

-- Make ResetUI globally accessible
_G.ResetUI = ResetUI
