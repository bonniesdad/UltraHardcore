--[[
  Removes health information (and power) from the party frames.
  Compact party frames are not supported yet.
]]

PARTY_MEMBER_SUBFRAMES_TO_HIDE = {
  'HealthBar',
  'ManaBar',
  'Texture',
  'Background',
}

function SetPartyFramesInfo(hideGroupHealth)
  ForcePartyFrames()

  if hideGroupHealth then
    for n = 1, 5 do
      SetPartyFrameInfo(n)
    end
  end
end

function SetPartyFrameInfo(n)
  for _, subFrame in ipairs(PARTY_MEMBER_SUBFRAMES_TO_HIDE) do
    HidePartySubFrame(n, subFrame)

    -- Move Name subframe down a few pixels to be centered with the portrait
    local nameFrame = _G['PartyMemberFrame' .. n .. "Name"]
    
    if nameFrame then
      nameFrame:SetPoint("BOTTOMLEFT", 55, 25)
    end
  end
  
  -- Move the entire party frame to the right by 100px and stack vertically
  local partyFrame = _G['PartyMemberFrame' .. n]
  if partyFrame then
    -- Position each party frame vertically below the previous one
    local verticalOffset = -120 - ((n - 1) * 60) -- 60px spacing between frames
    partyFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 80, verticalOffset)
    
    -- Set party frame to highest tooltip level (above 1000)
    partyFrame:SetFrameLevel(1500)
  end
  
  -- Reposition target highlights to match the moved party frame
  if RepositionAllPartyTargetHighlights then
    RepositionAllPartyTargetHighlights()
  end
  
  -- TODO move buffs/debuffs up
end

function HidePartySubFrame(n, subFrame)
  local frame = _G['PartyMemberFrame' .. n .. subFrame]
  if frame then
    ForceHideFrame(frame)
  end
end

function ForcePartyFrames()
  SetCVar('useCompactPartyFrames', 0)
end

-- Ensure that party frames are always configured
local frame = CreateFrame('Frame')
frame:RegisterEvent('CVAR_UPDATE')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_LOGIN')

frame:SetScript('OnEvent', function(self, event, cvar)
  if GLOBAL_SETTINGS.hideGroupHealth then
    ForcePartyFrames()
    -- Apply styling to all party frames
    for n = 1, 5 do
      SetPartyFrameInfo(n)
    end
  end
end)
