local minimapHideTimer = nil
local initialRotateMinimap = GetCVar("RotateMinimap") or false

function SetMinimapDisplay(hideMinimap, showClockEvenWhenMapHidden)
  if hideMinimap then
    HideMinimap(showClockEvenWhenMapHidden)
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
    TimeManagerClockButton:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -50)
  end

  TimeManagerClockButton:SetFrameStrata("HIGH")
  TimeManagerClockButton:SetScale(GLOBAL_SETTINGS.minimapClockScale or 1.0)
end

function HideMinimap(showClockEvenWhenMapHidden)
  -- Use custom blip texture to hide party members and objective arrows
  Minimap:SetBlipTexture("Interface\\AddOns\\UltraHardcore\\Textures\\ObjectIconsAtlasRestricted.png")
  -- Hide the player arrow
  Minimap:SetPlayerTexture("")
    
  -- Make the minimap invisible
  Minimap:SetAlpha(0)

  -- Hide it completely by default
  Minimap:Hide()
  MinimapCluster:Hide()

  if(showClockEvenWhenMapHidden) then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()

      -- Safety check in case TimeManager didn't load
      if not TimeManagerClockButton then
        print("TimeManagerClockButton not found!")
        return
      end
      -- Load the saved position for the clock
      LoadClockPosition()
      TimeManagerClockButton:Show()

      --Make the clock movable and save the position
      TimeManagerClockButton:SetMovable(true)
      TimeManagerClockButton:EnableMouse(true)
      TimeManagerClockButton:RegisterForDrag("LeftButton")
      TimeManagerClockButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
      end)
      TimeManagerClockButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        UltraHardcoreDB.minimapClockPosition = { point = point, relPoint = relPoint, x = x, y = y }
        SaveDBData('minimapClockPosition', UltraHardcoreDB.minimapClockPosition)
      end)
    end)
  end

  -- Show it for 5 seconds after casting particular spells
  Minimap:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
  Minimap:SetScript("OnEvent", function(self, event, ...)
    local unit, _, spellId = ...
    local initialZoom = Minimap:GetZoom()
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

    if unit == 'player' and trackingSpellIDs[spellId] then
      -- Temporarily make the minimap rotate with the user
      SetCVar("RotateMinimap", true)
      -- Allow clicks through minimap while this is up
      Minimap:EnableMouse(false)

      Minimap:ClearAllPoints()
      Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, -24)
      Minimap:SetScale(8.0)

      -- Show the relevant minimap elements
      Minimap:Show()
      MinimapCluster:Show()
      Minimap:SetZoom(0)

      -- Cancel any existing 'hide' timer
      if minimapHideTimer then
        minimapHideTimer:Cancel()
      end
      
      -- After a few seconds, hide the minimap again
      minimapHideTimer = C_Timer.NewTimer(5, function() 
        Minimap:Hide() 
        
        MinimapCluster:Hide()
        
        Minimap:EnableMouse(true)
        
        -- Reset the user's initial minimap options
        SetCVar("RotateMinimap", initialRotateMinimap)
        Minimap:SetZoom(initialZoom)

        -- Reset the position
        Minimap:ClearAllPoints()
      end)
    end
  end)

end

function ShowMinimap()
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
  Minimap:SetBlipTexture("Interface\\Minimap\\ObjectIconsAtlas.blp")
  Minimap:SetPlayerTexture("Interface\\Minimap\\MinimapArrow")
end

-- Reset clock position function
local function ResetClockPosition()
  -- Safety check in case TimeManager didn't load
  if not TimeManagerClockButton then
    print("TimeManagerClockButton not found!")
    return
  end

  -- Clear existing points first
  TimeManagerClockButton:ClearAllPoints()
  -- Reset to default position (top right)
  TimeManagerClockButton:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -50, -50)

  -- Save the reset position
  local point, _, relPoint, x, y = TimeManagerClockButton:GetPoint()
  UltraHardcoreDB.minimapClockPosition = { point = point, relPoint = relPoint, x = x, y = y }
  SaveDBData('minimapClockPosition', UltraHardcoreDB.minimapClockPosition)
  print('UltraHardcore: clock position reset to default')
end

-- Slash command to reset clock position
SLASH_RESETCLOCKPOSITION1 = '/resetclockposition'
SLASH_RESETCLOCKPOSITION2 = '/rcp'
SlashCmdList['RESETCLOCKPOSITION'] = ResetClockPosition