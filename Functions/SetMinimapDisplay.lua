local minimapHideTimer = nil
local initialRotateMinimap = GetCVar("RotateMinimap") or false

function SetMinimapDisplay(hideMinimap, showClockEvenWhenMapHidden)
  if hideMinimap then
    HideMinimap(showClockEvenWhenMapHidden)
  else
    ShowMinimap()
  end
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
      Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, -6)
      Minimap:SetScale(2.0)

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
        
        if not showClockEvenWhenMapHidden then
          MinimapCluster:Hide()
        end
        
        Minimap:EnableMouse(true)
        
        -- Reset the user's initial minimap options
        SetCVar("RotateMinimap", initialRotateMinimap)
        Minimap:SetZoom(initialZoom)

        -- Reset the position
        Minimap:ClearAllPoints()
      end)
    end
  end)

  -- Hide the zone text
  MinimapZoneText:Hide()
  -- Hide the background bar behind the zone text
  MinimapZoneTextButton:Hide()
  -- Hide the close/minimap tracking button (the button that shows tracking options)
  MiniMapTracking:Hide()

  MinimapBorderTop:Hide()
  MinimapToggleButton:Hide()
  
  -- Hide the day/night indicator (moon/sun icon)
  -- Hide the minimap cluster (including the "Toggle minimap" button)
  if not showClockEvenWhenMapHidden then
    MinimapCluster:Hide()
    GameTimeFrame:Hide()
  end
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
