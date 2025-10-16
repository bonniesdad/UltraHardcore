function SetMinimapDisplay(hideMinimap, showClockEvenWhenMapHidden)
  if hideMinimap then
    HideMinimap(showClockEvenWhenMapHidden)
  else
    ShowMinimap()
  end
end

function HideMinimap(showClockEvenWhenMapHidden)

  Minimap:Hide()
  -- Hide the zone text
  MinimapZoneText:Hide()
  -- Hide the background bar behind the zone text
  MinimapZoneTextButton:Hide()
  -- Hide the close/minimap tracking button (the button that shows tracking options)
  MiniMapTracking:Hide()
  -- Hide the day/night indicator (moon/sun icon)
  -- Hide the minimap cluster (including the "Toggle minimap" button)
  if showClockEvenWhenMapHidden then
    MinimapBorderTop:Hide()
    MinimapToggleButton:Hide()
  else
    MinimapCluster:Hide()
  end
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
