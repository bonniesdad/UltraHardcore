local minimapHideTimer = nil
local minimapCleanupTicker = nil

-- Track temporary reveal state so we can restore cleanly on any event
local minimapRevealState = {
  active = false,
  originalParent = nil,
  originalPoint = nil,
  originalRelPoint = nil,
  originalX = nil,
  originalY = nil,
  originalScale = nil,
  originalAlpha = nil,
  initialZoom = nil,
  originalRotateMinimap = nil,
  toggledFrames = nil,
  toggledRegions = nil,
}

local function ResetMinimapRevealState()
  if minimapHideTimer then
    minimapHideTimer:Cancel()
    minimapHideTimer = nil
  end
  if minimapCleanupTicker then
    minimapCleanupTicker:Cancel()
    minimapCleanupTicker = nil
  end
  if not minimapRevealState.active then return end

  -- Restore hidden UI frames
  if minimapRevealState.toggledFrames then
    for _, entry in ipairs(minimapRevealState.toggledFrames) do
      if entry.wasShown and entry.frame and entry.frame.Show then
        entry.frame:Show()
      end
    end
  end

  -- Restore hidden texture regions
  if minimapRevealState.toggledRegions then
    for _, entry in ipairs(minimapRevealState.toggledRegions) do
      if entry.wasShown and entry.region and entry.region.Show then
        entry.region:Show()
      end
    end
  end

  -- Restore minimap state
  Minimap:EnableMouse(true)
  if minimapRevealState.originalAlpha ~= nil then
    Minimap:SetAlpha(minimapRevealState.originalAlpha)
  end
  if minimapRevealState.initialZoom ~= nil then
    Minimap:SetZoom(minimapRevealState.initialZoom)
  end
  -- Only restore RotateMinimap if we explicitly overrode it for a temporary reveal
  if minimapRevealState.originalRotateMinimap ~= nil then
    SetCVar('RotateMinimap', minimapRevealState.originalRotateMinimap)
  end

  Minimap:ClearAllPoints()
  if minimapRevealState.originalParent then
    Minimap:SetParent(minimapRevealState.originalParent)
  end
  if minimapRevealState.originalPoint then
    Minimap:SetPoint(
      minimapRevealState.originalPoint,
      minimapRevealState.originalParent or UIParent,
      minimapRevealState.originalRelPoint,
      minimapRevealState.originalX,
      minimapRevealState.originalY
    )
  end
  if minimapRevealState.originalScale then
    Minimap:SetScale(minimapRevealState.originalScale)
  end

  -- Clear state
  minimapRevealState = {
    active = false,
    originalParent = nil,
    originalPoint = nil,
    originalRelPoint = nil,
    originalX = nil,
    originalY = nil,
    originalScale = nil,
    originalAlpha = nil,
    initialZoom = nil,
    toggledFrames = nil,
    toggledRegions = nil,
  }
end

function SetMinimapDisplay(hideMinimap)
  -- Always reset any temporary reveal state first
  ResetMinimapRevealState()
  if hideMinimap then
    -- With Hide Minimap enabled, keep it hidden in all cases (including taxi/dead)
    HideMinimap()
  else
    ShowMinimap()
  end
end

local function LoadClockPosition()
  if not TimeManagerClockButton then return end

  TimeManagerClockButton:SetParent(UIParent)
  TimeManagerClockButton:ClearAllPoints()

  local pos = UltraHardcoreDB.minimapClockPosition
  if pos then
    TimeManagerClockButton:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    -- Scale-adjusted default position: maintains visual position relative to mail/tracking icons
    -- when clock scale changes. Uses divisor pattern to calculate offset.
    -- Calibrated values: 100% scale = -60, 150% scale = -30, 200% scale = -15
    local scale = GLOBAL_SETTINGS.minimapClockScale or 1.0
    local divisor
    if scale <= 1.0 then
      divisor = 1.0 -- 100% scale: offset = -60 / 1.0 = -60
    elseif scale <= 1.5 then
      divisor = 1.0 + (scale - 1.0) * 2.0 -- Linear interpolation: 1.0 to 2.0 (100% to 150%)
    else
      divisor = 2.0 + (scale - 1.5) * 4.0 -- Linear interpolation: 2.0 to 4.0 (150% to 200%)
    end
    TimeManagerClockButton:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -60 / divisor, 0)
  end

  TimeManagerClockButton:SetFrameStrata('HIGH')
  TimeManagerClockButton:SetScale(GLOBAL_SETTINGS.minimapClockScale or 1.0)
end

local function LoadMailPosition()
  if not MiniMapMailFrame then return end

  MiniMapMailFrame:SetParent(UIParent)
  MiniMapMailFrame:ClearAllPoints()

  local pos = UltraHardcoreDB.minimapMailPosition
  if pos then
    MiniMapMailFrame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    -- Scale-adjusted default position: maintains visual position relative to clock/tracking icons
    -- when mail scale changes. Uses linear interpolation between calibrated breakpoints.
    -- Calibrated values: 100% scale = -20, 150% scale = -5, 200% scale = 0
    local scale = GLOBAL_SETTINGS.minimapMailScale or 1.0
    local offsetX
    if scale <= 1.0 then
      offsetX = -20 -- 100% scale: -20
    elseif scale <= 1.5 then
      offsetX = -20 + (scale - 1.0) * 30 -- Linear interpolation: -20 to -5 (100% to 150%)
    else
      offsetX = -5 + (scale - 1.5) * 10 -- Linear interpolation: -5 to 0 (150% to 200%)
    end
    MiniMapMailFrame:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', offsetX, -7)
  end

  MiniMapMailFrame:SetFrameStrata('HIGH')
  MiniMapMailFrame:SetScale(GLOBAL_SETTINGS.minimapMailScale or 1.0)
end

local function LoadTrackingPosition()
  if not MiniMapTracking then return end

  MiniMapTracking:SetParent(UIParent)
  MiniMapTracking:ClearAllPoints()

  local pos = UltraHardcoreDB.MiniMapTrackingPosition
  if pos then
    MiniMapTracking:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    -- Scale-adjusted default position: maintains visual position relative to clock/mail icons
    -- when tracking scale changes. Uses linear interpolation between calibrated breakpoints.
    -- Calibrated values: 90% scale = -145, 150% scale = -85, 200% scale = -65
    -- Note: Default scale is 90% (0.9), not 100%
    local scale = GLOBAL_SETTINGS.minimapTrackingScale or 0.9
    local offsetX
    if scale <= 0.9 then
      offsetX = -145 -- 90% scale (default): -145
    elseif scale <= 1.5 then
      offsetX = -145 + (scale - 0.9) * 100 -- Linear interpolation: -145 to -85 (90% to 150%)
    else
      offsetX = -85 + (scale - 1.5) * 40 -- Linear interpolation: -85 to -65 (150% to 200%)
    end
    MiniMapTracking:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', offsetX, -7)
  end

  MiniMapTracking:SetFrameStrata('HIGH')
  MiniMapTracking:SetScale(GLOBAL_SETTINGS.minimapTrackingScale or 0.9)
end

-- Take the given frame and disable the mouse and hide for all children
local function DisableMouseAndHideChildren(f)
  for _, child in ipairs({ f:GetChildren() }) do
    if child.EnableMouse then
      child:EnableMouse(false)
    end
    if child.EnableMouseWheel then
      child:EnableMouseWheel(false)
    end
    if child and child:IsShown() then
      child:Hide()
    end
  end
end

function ShowTrackingButton()
  if not MiniMapTracking then
    print('MiniMapTracking not found!')
    return
  end
  -- Load the saved position for the tracking
  LoadTrackingPosition()
  MiniMapTracking:Show()

  --Make the tracking movable and save the position
  MiniMapTracking:SetMovable(true)
  MiniMapTracking:EnableMouse(true)
  MiniMapTracking:RegisterForDrag('LeftButton')
  MiniMapTracking:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  MiniMapTracking:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    UltraHardcoreDB.MiniMapTrackingPosition = {
      point = point,
      relPoint = relPoint,
      x = x,
      y = y,
    }
    UHC_SaveDBData('MiniMapTrackingPosition', UltraHardcoreDB.MiniMapTrackingPosition)
  end)
  showTrackingInitialized = true
end

function ShowClock()
  if not TimeManagerClockButton then
    print('TimeManagerClockButton not found!')
    return
  end
  -- Load the saved position for the clock
  LoadClockPosition()
  TimeManagerClockButton:Show()

  --Make the clock movable and save the position
  TimeManagerClockButton:SetMovable(true)
  TimeManagerClockButton:EnableMouse(true)
  TimeManagerClockButton:RegisterForDrag('LeftButton')
  TimeManagerClockButton:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  TimeManagerClockButton:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    UltraHardcoreDB.minimapClockPosition = {
      point = point,
      relPoint = relPoint,
      x = x,
      y = y,
    }
    UHC_SaveDBData('minimapClockPosition', UltraHardcoreDB.minimapClockPosition)
  end)
  showClockInitialized = true
end

function ShowMail()
  if not MiniMapMailFrame then
    print('MiniMapMailFrame not found!')
    return
  end

  MiniMapMailFrame:SetParent(UIParent)
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint('TOPRIGHT', Minimap, 'TOPRIGHT', -20, -20)
  -- Load the saved position for the MiniMapMailFrame
  LoadMailPosition()
  MiniMapMailFrame:Show()

  --Make the clock movable and save the position
  MiniMapMailFrame:SetMovable(true)
  MiniMapMailFrame:EnableMouse(true)
  MiniMapMailFrame:RegisterForDrag('LeftButton')
  MiniMapMailFrame:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  MiniMapMailFrame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    UltraHardcoreDB.minimapMailPosition = {
      point = point,
      relPoint = relPoint,
      x = x,
      y = y,
    }
    UHC_SaveDBData('minimapMailPosition', UltraHardcoreDB.minimapMailPosition)
  end)
  showMailInitialized = true
end

function HideMinimap()
  -- Ensure no temporary reveal leftovers are active
  ResetMinimapRevealState()

  -- Make the minimap invisible by default
  Minimap:SetAlpha(0)
  Minimap:Hide()
  MinimapCluster:Hide()

  -- Just check settings for specific toggles once
  local isAlwaysOn = GLOBAL_SETTINGS and GLOBAL_SETTINGS.alwaysShowResourceMap
  local showPlayerArrow = GLOBAL_SETTINGS and GLOBAL_SETTINGS.showPlayerArrowOnResourceMap

  -- Set blip texture based on Always On mode
  if isAlwaysOn then
    Minimap:SetBlipTexture(
      'Interface\\AddOns\\UltraHardcore\\Textures\\ObjectIconsAtlasRestricted-AlwaysOn.png'
    )
    -- Show player arrow if setting is enabled
    if showPlayerArrow then
      Minimap:SetPlayerTexture('Interface\\Minimap\\MinimapArrow')
    else
      Minimap:SetPlayerTexture('')
    end

    RevealMinimapForTracking(isAlwaysOn)
  else
    -- Standard hide mode
    Minimap:SetBlipTexture(
      'Interface\\AddOns\\UltraHardcore\\Textures\\ObjectIconsAtlasRestricted.png'
    )
    Minimap:SetPlayerTexture('')

    -- Register spell event handler
    Minimap:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    Minimap:SetScript('OnEvent', function(self, event, ...)
      local unit, _, spellId = ...
      local initialZoom = Minimap:GetZoom()

      -- Tracking spells that should trigger the resource map reveal
      local trackingSpellIDs = {
        [2580] = true, -- Find Minerals
        [2383] = true, -- Find Herbs
        [2481] = true, -- Find Treasure
        [1494] = true, -- Track Beasts
        [19880] = true, -- Track Elementals
        [19882] = true, -- Track Giants
        [19883] = true, -- Track Humanoids (Hunter)
        [5225] = true, -- Track Humanoids (Druid)
        [19884] = true, -- Track Undead
        [19878] = true, -- Track Demons
        [19879] = true, -- Track Dragonkin
        [19885] = true, -- Track Hidden
        [5502] = true, -- Sense Undead
        [5500] = true, -- Sense Demons
        [10242] = true, -- Elemental Tracking
        [5124] = true, -- Elemental Tracker
      }

      if (unit == 'player' and trackingSpellIDs[spellId]) then
        RevealMinimapForTracking(isAlwaysOn)
      end
    end)
  end
end

function RevealMinimapForTracking(isAlwaysOn)
  -- Reset any existing reveal state to ensure we capture the true 'base' state
  ResetMinimapRevealState()

  -- Rotation behaviour:
  --  - If Always On resource map is NOT enabled (spell-based temporary reveal),
  --    we snapshot the current RotateMinimap CVar and force rotation for the
  --    duration of the overlay, then restore the snapshot afterwards.
  --  - If Always On resource map IS enabled, we respect the user's ULTRA
  --    setting (rotateMinimapOnResourceMap) and do NOT snapshot/restore,
  --    so their underlying WoW minimap rotation preference is not overridden
  --    when Always Show Resource Map is disabled.
  if not isAlwaysOn then
    minimapRevealState.originalRotateMinimap = GetCVar('RotateMinimap')
    SetCVar('RotateMinimap', true)
  else
    local rotate
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.rotateMinimapOnResourceMap ~= nil then
      rotate = GLOBAL_SETTINGS.rotateMinimapOnResourceMap
    else
      local cvarValue = GetCVar('RotateMinimap')
      rotate = (cvarValue == '1' or cvarValue == 'true' or cvarValue == true)
    end
    SetCVar('RotateMinimap', rotate)
    minimapRevealState.originalRotateMinimap = nil
  end

  -- Allow clicks through minimap while this is up
  Minimap:EnableMouse(false)
  -- Prevent zooming when showing our tracking
  Minimap:EnableMouseWheel(false)

  -- Capture original state so we can restore it cleanly
  minimapRevealState.active = true
  minimapRevealState.originalParent = Minimap:GetParent()
  local originalPoint, _, originalRelPoint, originalX, originalY = Minimap:GetPoint(1)
  minimapRevealState.originalPoint = originalPoint
  minimapRevealState.originalRelPoint = originalRelPoint
  minimapRevealState.originalX = originalX
  minimapRevealState.originalY = originalY
  minimapRevealState.originalScale = Minimap:GetScale()
  minimapRevealState.originalAlpha = Minimap:GetAlpha()
  minimapRevealState.initialZoom = initialZoom

  -- Detach the minimap from its cluster so we can show ONLY the map
  Minimap:SetParent(UIParent)

  Minimap:ClearAllPoints()

  if isAlwaysOn then
    -- Normal position/scale for Always On mode
    Minimap:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -20, -20)
    Minimap:SetScale(1.0)
  else
    -- Giant/Center for standard reveal
    Minimap:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    Minimap:SetScale(8.0)

    DisableMouseAndHideChildren(Minimap)
  end

  -- Hide extra minimap adornments while revealing
  minimapRevealState.toggledFrames = {}
  minimapRevealState.toggledRegions = {}
  local function hideTemp(frame)
    if frame and frame.Hide then
      table.insert(minimapRevealState.toggledFrames, {
        frame = frame,
        wasShown = frame:IsShown(),
      })
      frame:Hide()
    end
  end

  -- TODO: Delete these, they don't seem to actually do anything
  -- hideTemp(_G.MiniMapTracking)
  hideTemp(_G.GameTimeFrame)
  -- hideTemp(_G.MiniMapMailFrame)
  hideTemp(_G.MinimapBorder)
  hideTemp(_G.MinimapBackdrop)
  hideTemp(_G.MinimapBorderTop)
  hideTemp(_G.MinimapZoomIn)
  hideTemp(_G.MinimapZoomOut)
  hideTemp(_G.MinimapCompassTexture)
  hideTemp(_G.MinimapNorthTag)

  -- Hide terrain/background and border texture regions so only blips remain
  do
    local regions = { Minimap:GetRegions() }
    for _, region in ipairs(regions) do
      if region and region.GetObjectType and region:GetObjectType() == 'Texture' then
        local layer = (region.GetDrawLayer and region:GetDrawLayer()) or nil
        -- Hide all terrain/background/border art so only blips remain
        if layer == 'BACKGROUND' or layer == 'BORDER' or layer == 'ARTWORK' then
          table.insert(minimapRevealState.toggledRegions, {
            region = region,
            wasShown = region:IsShown(),
          })
          region:Hide()
        end
      end
    end
  end

  -- Show only the minimap (keep cluster elements hidden)
  Minimap:Show()
  Minimap:SetZoom(0)

  -- Cancel any existing 'hide' timer
  if minimapHideTimer then
    minimapHideTimer:Cancel()
  end

  -- Only set timer if NOT in Always On mode
  if not isAlwaysOn then
    -- After a few seconds, hide the minimap again
    minimapHideTimer = C_Timer.NewTimer(5, function()
      -- Restore any temporary reveal state
      ResetMinimapRevealState()
      -- Then ensure minimap stays hidden if the setting is enabled
      if GLOBAL_SETTINGS and GLOBAL_SETTINGS.hideMinimap then
        Minimap:Hide()
        MinimapCluster:Hide()
        Minimap:SetAlpha(0)
      end
    end)
  end
end

function ShowMinimap()
  -- Clean up any temporary handlers/timers and restore reveal state
  ResetMinimapRevealState()
  Minimap:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
  Minimap:SetScript('OnEvent', nil)

  Minimap:Show()
  Minimap:SetAlpha(1)
  -- Hide the zone text
  MinimapZoneText:Show()
  -- Hide the background bar behind the zone text
  MinimapZoneTextButton:Show()
  -- Hide the close/minimap tracking button (the button that shows tracking options)
  MiniMapTracking:Show()
  -- Hide the day/night indicator (moon/sun icon)
  GameTimeFrame:Show()
  -- Hide the minimap cluster (including the "Toggle minimap" button)
  MinimapCluster:Show()
  -- Reset minimap textures
  Minimap:SetBlipTexture('Interface\\Minimap\\ObjectIconsAtlas.blp')
  Minimap:SetPlayerTexture('Interface\\Minimap\\MinimapArrow')
end

-- Self-contained event registration to mirror action bar taxi handling
local minimapEventsFrame = CreateFrame('Frame')
minimapEventsFrame:RegisterEvent('PLAYER_REGEN_DISABLED') -- entering combat
minimapEventsFrame:RegisterEvent('PLAYER_REGEN_ENABLED') -- leaving combat
minimapEventsFrame:RegisterEvent('PLAYER_CONTROL_LOST') -- starting taxi/control loss
minimapEventsFrame:RegisterEvent('PLAYER_CONTROL_GAINED') -- ending taxi/control gain
minimapEventsFrame:SetScript('OnEvent', function()
  if GLOBAL_SETTINGS then
    SetMinimapDisplay(GLOBAL_SETTINGS.hideMinimap or false)
  end
end)

-- Reset clock position function
local function ResetClockPosition()
  -- Safety check in case TimeManager didn't load
  if not TimeManagerClockButton then
    print('TimeManagerClockButton not found!')
    return
  end

  -- Clear existing points first
  TimeManagerClockButton:ClearAllPoints()
  -- Reset to scale-adjusted default position (maintains visual position when scale changes)
  -- See LoadClockPosition() for detailed comments on the scaling logic
  local scale = GLOBAL_SETTINGS.minimapClockScale or 1.0
  local divisor
  if scale <= 1.0 then
    divisor = 1.0 -- 100% scale: offset = -60 / 1.0 = -60
  elseif scale <= 1.5 then
    divisor = 1.0 + (scale - 1.0) * 2.0 -- Linear interpolation: 1.0 to 2.0 (100% to 150%)
  else
    divisor = 2.0 + (scale - 1.5) * 4.0 -- Linear interpolation: 2.0 to 4.0 (150% to 200%)
  end
  TimeManagerClockButton:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -60 / divisor, 0)

  -- Save the reset position
  local point, _, relPoint, x, y = TimeManagerClockButton:GetPoint()
  UltraHardcoreDB.minimapClockPosition = {
    point = point,
    relPoint = relPoint,
    x = x,
    y = y,
  }
  UHC_SaveDBData('minimapClockPosition', UltraHardcoreDB.minimapClockPosition)
  print('|cfff44336[ULTRA]|r Clock position reset to default.')
end

-- Reset mail position function
local function ResetMailPosition()
  -- Safety check in case TimeManager didn't load
  if not MiniMapMailFrame then
    print('MiniMapMailFrame not found!')
    return
  end

  -- Clear existing points first
  MiniMapMailFrame:ClearAllPoints()
  -- Reset to scale-adjusted default position (maintains visual position when scale changes)
  -- See LoadMailPosition() for detailed comments on the scaling logic
  local scale = GLOBAL_SETTINGS.minimapMailScale or 1.0
  local offsetX
  if scale <= 1.0 then
    offsetX = -20 -- 100% scale: -20
  elseif scale <= 1.5 then
    offsetX = -20 + (scale - 1.0) * 30 -- Linear interpolation: -20 to -5 (100% to 150%)
  else
    offsetX = -5 + (scale - 1.5) * 10 -- Linear interpolation: -5 to 0 (150% to 200%)
  end
  MiniMapMailFrame:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', offsetX, -5)

  -- Save the reset position
  local point, _, relPoint, x, y = MiniMapMailFrame:GetPoint()
  UltraHardcoreDB.minimapMailPosition = {
    point = point,
    relPoint = relPoint,
    x = x,
    y = y,
  }
  UHC_SaveDBData('minimapMailPosition', UltraHardcoreDB.minimapMailPosition)
  print('|cfff44336[ULTRA]|r Mail position reset to default.')
end

-- Reset tracking position function
local function ResetTrackingPosition()
  if not MiniMapTracking then
    print('MiniMapTracking not found!')
    return
  end

  -- Clear existing points first
  MiniMapTracking:ClearAllPoints()
  -- Reset to scale-adjusted default position (maintains visual position when scale changes)
  -- See LoadTrackingPosition() for detailed comments on the scaling logic
  local scale = GLOBAL_SETTINGS.minimapTrackingScale or 0.9
  local offsetX
  if scale <= 0.9 then
    offsetX = -145 -- 90% scale (default): -145
  elseif scale <= 1.5 then
    offsetX = -145 + (scale - 0.9) * 100 -- Linear interpolation: -145 to -85 (90% to 150%)
  else
    offsetX = -85 + (scale - 1.5) * 40 -- Linear interpolation: -85 to -65 (150% to 200%)
  end
  MiniMapTracking:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', offsetX, -5)

  -- Save the reset position
  local point, _, relPoint, x, y = MiniMapTracking:GetPoint()
  UltraHardcoreDB.MiniMapTrackingPosition = {
    point = point,
    relPoint = relPoint,
    x = x,
    y = y,
  }
  UHC_SaveDBData('MiniMapTrackingPosition', UltraHardcoreDB.MiniMapTrackingPosition)
  print('|cfff44336[ULTRA]|r Tracking position reset to default.')
end

-- Slash command to reset clock position
SLASH_RESETCLOCKPOSITION1 = '/resetclockposition'
SLASH_RESETCLOCKPOSITION2 = '/rcp'
SlashCmdList['RESETCLOCKPOSITION'] = ResetClockPosition

-- Slash command to reset mail position
SLASH_RESETMAILPOSITION1 = '/resetmailposition'
SLASH_RESETMAILPOSITION2 = '/rmp'
SlashCmdList['RESETMAILPOSITION'] = ResetMailPosition

-- Slash command to reset tracking position
SLASH_RESETTRACKINGPOSITION1 = '/resettrackingposition'
SLASH_RESETTRACKINGPOSITION2 = '/rtp'
SlashCmdList['RESETTRACKINGPOSITION'] = ResetTrackingPosition
