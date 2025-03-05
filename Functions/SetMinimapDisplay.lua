function SetMinimapDisplay(hideMinimap)
  if hideMinimap then
    HideMinimap()
  else
    ShowMinimap()
  end
end

function HideMinimap()
  Minimap:Hide()
  -- Hide the zone text
  MinimapZoneText:Hide()
  -- Hide the background bar behind the zone text
  MinimapZoneTextButton:Hide()
  -- Hide the close/minimap tracking button (the button that shows tracking options)
  MiniMapTracking:Hide()
  -- Hide the day/night indicator (moon/sun icon)
  GameTimeFrame:Hide()
  -- Hide the minimap cluster (including the "Toggle minimap" button)
  MinimapCluster:Hide()
end

function ShowMinimap()
  Minimap:Show()
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
end
