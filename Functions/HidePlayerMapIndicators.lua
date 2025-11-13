-- State flags for reversible hooks/overrides
ULTRA_HC_STOP_PLAYER_PING = ULTRA_HC_STOP_PLAYER_PING or false

function HidePlayerMapIndicators()
  if not GLOBAL_SETTINGS.routePlanner then return end

  local HIDE_ALL = true -- set to false to hide only the player
  -- Enable ping-blocking while this feature is active
  ULTRA_HC_STOP_PLAYER_PING = true
  -- Minimap: hide player arrow
  if Minimap and Minimap.SetPlayerTexture then
    Minimap:SetPlayerTexture('')
  end

  -- World Map: kill the yellow ping + hide group/player pins
  for pin in WorldMapFrame:EnumeratePinsByTemplate('GroupMembersPinTemplate') do
    if not pin.ultraHC_Hooked then
      hooksecurefunc(pin, 'StartPlayerPing', function(self)
        if ULTRA_HC_STOP_PLAYER_PING then
          self:StopPlayerPing()
        end
      end)
      pin.ultraHC_Hooked = true
    end
    if HIDE_ALL then
      -- Hide without permanently breaking Show(); keep a reversible handle
      if not pin.ultraHC_OriginalShow then
        pin.ultraHC_OriginalShow = pin.Show
      end
      pin:Hide()
      pin.Show = function() end
    else
      pin:SetPinTexture('player', '')
      break
    end
  end
end

function RestorePlayerMapIndicators()
  -- Disable ping-blocking so future pings work
  ULTRA_HC_STOP_PLAYER_PING = false

  -- Minimap: restore default player arrow texture
  if Minimap and Minimap.SetPlayerTexture then
    Minimap:SetPlayerTexture('Interface\\Minimap\\MinimapArrow')
  end

  -- World Map: restore group/player pins behavior
  for pin in WorldMapFrame:EnumeratePinsByTemplate('GroupMembersPinTemplate') do
    if pin.Show then
      -- Restore original Show method if we replaced it, otherwise let it fall back to default
      if pin.ultraHC_OriginalShow then
        pin.Show = pin.ultraHC_OriginalShow
        pin.ultraHC_OriginalShow = nil
      else
        pin.Show = nil
      end
      if pin:IsShown() == false then
        pin:Show()
      end
    end
    -- If we blanked textures in the non-HIDE_ALL path, try to restore
    if pin.SetPinTexture then
      -- Best-effort: rely on the pin to re-derive textures on Show/Refresh
      if pin.Refresh then
        pin:Refresh()
      end
    end
  end
end
