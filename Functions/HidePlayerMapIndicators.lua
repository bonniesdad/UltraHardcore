function HidePlayerMapIndicators()
  if not GLOBAL_SETTINGS.routePlanner then return end

  local HIDE_ALL = true -- set to false to hide only the player
  -- Minimap: hide player arrow
  if Minimap and Minimap.SetPlayerTexture then
    Minimap:SetPlayerTexture('')
  end

  -- World Map: kill the yellow ping + hide group/player pins
  for pin in WorldMapFrame:EnumeratePinsByTemplate('GroupMembersPinTemplate') do
    hooksecurefunc(pin, 'StartPlayerPing', function(self)
      self:StopPlayerPing()
    end)
    if HIDE_ALL then
      pin:Hide()
      pin.Show = function() end
    else
      pin:SetPinTexture('player', '')
      break
    end
  end
end
