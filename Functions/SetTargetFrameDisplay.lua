function SetTargetFrameDisplay(hide)
  if not hide then return end

  -- Function to forcibly hide both Target Frame and Target of Target Frame
  local function HideTargetFrames()
    -- Only try to hide frames if not in combat to avoid protected function errors
    if not UnitAffectingCombat("player") then
      TargetFrame:Hide()
      TargetFrameToT:Hide()
    end
  end

  -- Completely block Blizzard's attempts to show the frame
  TargetFrame:UnregisterAllEvents()
  TargetFrameToT:UnregisterAllEvents()

  -- Override Show() function so the frames can never appear
  TargetFrame:SetScript('OnShow', function(self)
    if not UnitAffectingCombat("player") then
      self:Hide()
    end
  end)
  TargetFrameToT:SetScript('OnShow', function(self)
    if not UnitAffectingCombat("player") then
      self:Hide()
    end
  end)

  -- Hook into Blizzard's force-show logic
  hooksecurefunc(TargetFrame, 'Show', function(self)
    if not UnitAffectingCombat("player") then
      self:Hide()
    end
  end)
  hooksecurefunc(TargetFrameToT, 'Show', function(self)
    if not UnitAffectingCombat("player") then
      self:Hide()
    end
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

  -- Initial hide when not in combat - defer until safe
  local function SafeInitialHide()
    if not UnitAffectingCombat("player") then
      HideTargetFrames()
    end
  end
  
  -- Try to hide immediately, but if in combat, defer until combat ends
  if UnitAffectingCombat("player") then
    -- Will be handled by PLAYER_REGEN_ENABLED event that's already registered
  else
    SafeInitialHide()
  end
end
