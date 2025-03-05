function SetTargetFrameDisplay(hide)
  if not hide then return end

  -- Function to forcibly hide both Target Frame and Target of Target Frame
  local function HideTargetFrames()
    TargetFrame:Hide()
    TargetFrameToT:Hide()
  end

  -- Completely block Blizzard's attempts to show the frame
  TargetFrame:UnregisterAllEvents()
  TargetFrameToT:UnregisterAllEvents()

  -- Override Show() function so the frames can never appear
  TargetFrame:SetScript('OnShow', function(self)
    self:Hide()
  end)
  TargetFrameToT:SetScript('OnShow', function(self)
    self:Hide()
  end)

  -- Hook into Blizzard's force-show logic
  hooksecurefunc(TargetFrame, 'Show', function(self)
    self:Hide()
  end)
  hooksecurefunc(TargetFrameToT, 'Show', function(self)
    self:Hide()
  end)

  -- Create an event listener to actively hide frames when certain conditions occur
  local frameHider = CreateFrame('Frame')
  frameHider:RegisterEvent('PLAYER_TARGET_CHANGED') -- When your target changes
  frameHider:RegisterEvent('UNIT_TARGET') -- When any unit's target changes
  frameHider:RegisterEvent('PLAYER_REGEN_DISABLED') -- When entering combat
  frameHider:RegisterEvent('PLAYER_REGEN_ENABLED') -- When leaving combat
  frameHider:RegisterEvent('UNIT_THREAT_LIST_UPDATE') -- When something aggros you
  frameHider:RegisterEvent('UNIT_COMBAT') -- Any combat-related action
  frameHider:SetScript('OnEvent', HideTargetFrames)

  -- Hard override: Force-hide every frame
  frameHider:SetScript('OnUpdate', HideTargetFrames)
end
