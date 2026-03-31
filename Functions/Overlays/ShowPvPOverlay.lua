-- PvP Active Warning Overlay
-- Shows a warning banner when the player has PvP flag active

local pvpOverlayFrame = nil
local pvpOverlayTimer = nil

function ShowPvPOverlay()
  if not pvpOverlayFrame then
    local success, err = pcall(function()
      pvpOverlayFrame = CreateFrame('Frame', 'PvPOverlay', UIParent, 'BackdropTemplate')
      if not pvpOverlayFrame then return end

      pvpOverlayFrame:SetFrameStrata('DIALOG')
      pvpOverlayFrame:SetSize(400, 60)
      pvpOverlayFrame:SetPoint('TOP', UIParent, 'TOP', 0, -80)

      -- Semi-transparent red background
      pvpOverlayFrame.bg = pvpOverlayFrame:CreateTexture(nil, 'BACKGROUND')
      pvpOverlayFrame.bg:SetAllPoints()
      pvpOverlayFrame.bg:SetColorTexture(0.6, 0.1, 0.1, 0.85)

      -- Border
      pvpOverlayFrame:SetBackdrop({
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        edgeSize = 12,
        insets = {
          left = 4,
          right = 4,
          top = 4,
          bottom = 4,
        },
      })
      pvpOverlayFrame:SetBackdropBorderColor(1, 0.3, 0.3, 1)

      -- Warning text
      pvpOverlayFrame.text = pvpOverlayFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      pvpOverlayFrame.text:SetPoint('CENTER', pvpOverlayFrame, 'CENTER', 0, 0)
      pvpOverlayFrame.text:SetText('PvP ACTIVE')
      pvpOverlayFrame.text:SetTextColor(1, 1, 1, 1)
      pvpOverlayFrame.text:SetShadowOffset(1, -1)
      pvpOverlayFrame.text:SetShadowColor(0, 0, 0, 1)
    end)

    if not success then
      print('UltraHardcore: Error creating PvP overlay frame:', err)
      return
    end
  end

  if not pvpOverlayFrame then return end

  pvpOverlayFrame:Show()
end

function HidePvPOverlay()
  if pvpOverlayFrame and pvpOverlayFrame:IsVisible() then
    pvpOverlayFrame:Hide()
  end
end

-- Update overlay visibility based on current PvP state and setting
function UltraHardcore_UpdatePvPOverlay()
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showPvPOverlayWhenActive then
    if HidePvPOverlay then
      HidePvPOverlay()
    end
    return
  end
  if not ShowPvPOverlay or not HidePvPOverlay then return end

  if UnitIsPVP('player') then
    ShowPvPOverlay()
  else
    HidePvPOverlay()
  end
end

-- Start periodic check for PvP state (catches manual /pvp toggles in Classic)
function UltraHardcore_StartPvPOverlayTimer()
  if pvpOverlayTimer then return end

  pvpOverlayTimer = C_Timer.NewTicker(2, function()
    if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showPvPOverlayWhenActive then
      if pvpOverlayTimer then
        pvpOverlayTimer:Cancel()
        pvpOverlayTimer = nil
      end
      return
    end
    UltraHardcore_UpdatePvPOverlay()
  end)
end
