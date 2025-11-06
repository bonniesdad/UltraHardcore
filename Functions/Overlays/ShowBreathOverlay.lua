-- 🟢 Function to show greyscale overlay based on breath percentage
function ShowBreathOverlay(breathPercent)
  -- Initialize breath overlay frame if it doesn't exist
  if not UltraHardcore.breathOverlayFrame then
    local breathOverlayFrame = CreateFrame('Frame', nil, UIParent)
    breathOverlayFrame:SetAllPoints(UIParent)
    
    -- Set frame strata and level based on tunnelVisionMaxStrata setting
    if GLOBAL_SETTINGS.tunnelVisionMaxStrata then
      breathOverlayFrame:SetFrameStrata('FULLSCREEN_DIALOG')
      breathOverlayFrame:SetFrameLevel(1000)
    else
      breathOverlayFrame:SetFrameStrata(ChatFrame1:GetFrameStrata())
      breathOverlayFrame:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
    end
    
    breathOverlayFrame.texture = breathOverlayFrame:CreateTexture(nil, 'BACKGROUND')
    breathOverlayFrame.texture:SetAllPoints()
    breathOverlayFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.breathOverlayFrame = breathOverlayFrame
  end
  
  -- Calculate greyscale intensity based on breath percentage
  -- Only start showing effect when breath is below 80%
  -- Use a very gradual curve for subtle start
  local alpha = 0
  if breathPercent < 80 then
    -- Start effect only when breath drops below 80%
    local breathRatio = (80 - breathPercent) / 80 -- Scale from 0-1 as breath goes from 80% to 0%
    alpha = math.max(0, math.pow(breathRatio, 3.5) * 0.8) -- Even more gradual curve
  end
  
  if alpha > 0 then
    -- Show red-tinted overlay (more dramatic and urgent)
    UltraHardcore.breathOverlayFrame.texture:SetColorTexture(0.8, 0.2, 0.2, alpha)
    UltraHardcore.breathOverlayFrame:Show()
  else
    -- Hide overlay when breath is full
    UltraHardcore.breathOverlayFrame:Hide()
  end
end

-- 🟢 Function to remove breath overlay
function RemoveBreathOverlay()
  if UltraHardcore.breathOverlayFrame then
    UltraHardcore.breathOverlayFrame:Hide()
  end
end

-- Throttle updates to reduce frequency
local updateThrottle = 0
local UPDATE_INTERVAL = 0.1 -- Update every 100ms (10 times per second instead of 60+)

-- 🟢 Function to handle breath timer updates
function OnBreathUpdate(self, elapsed)
  updateThrottle = updateThrottle + elapsed
  
  -- Only update every UPDATE_INTERVAL seconds
  if updateThrottle >= UPDATE_INTERVAL then
    updateThrottle = 0
    
    -- Get breath data using GetMirrorTimerProgress (this works!)
    local progress = GetMirrorTimerProgress("BREATH")
    if progress and progress > 0 then
      -- Progress appears to be time remaining in milliseconds
      -- Let's estimate total breath duration and calculate percentage
      local estimatedTotalDuration = 90000 -- 90 seconds in milliseconds (typical max breath)
      local breathPercent = (progress / estimatedTotalDuration) * 100
      
      -- Clamp the percentage to 0-100
      breathPercent = math.max(0, math.min(100, breathPercent))
      
      -- Show red-tinted overlay (higher breath = less red, lower breath = more red)
      ShowBreathOverlay(breathPercent)
    else
      -- If we're still in water but out of breath, keep the overlay at max intensity
      if IsSwimming and IsSwimming() then
        ShowBreathOverlay(0)
      else
        -- Not in water, hide overlay
        RemoveBreathOverlay()
      end
    end
  end
end

-- 🟢 Function to start breath monitoring
function OnBreathStart()
  -- Initialize the overlay frame first
  ShowBreathOverlay(100) -- Start with full breath
  
  if UltraHardcore.breathOverlayFrame then
    UltraHardcore.breathOverlayFrame:SetScript("OnUpdate", OnBreathUpdate)
    UltraHardcore.breathOverlayFrame:Show() -- Make sure frame is visible
  end

  -- Hide only the BREATH mirror timer (once) without affecting fatigue (EXHAUSTION)
  -- Do not use ForceHideFrame here to avoid suppressing the frame for other timers
  for i = 1, 3 do
    local frame = _G["MirrorTimer" .. i]
    if frame and frame.timer == "BREATH" then
      frame:Hide()
    end
  end
end

-- 🟢 Function to stop breath monitoring
function OnBreathStop()
  -- If still in water, keep the overlay active until we actually leave the water
  if IsSwimming and IsSwimming() then
    ShowBreathOverlay(0)
    if UltraHardcore.breathOverlayFrame then
      UltraHardcore.breathOverlayFrame:SetScript("OnUpdate", OnBreathUpdate)
      UltraHardcore.breathOverlayFrame:Show()
    end
  else
    RemoveBreathOverlay()
    if UltraHardcore.breathOverlayFrame then
      UltraHardcore.breathOverlayFrame:SetScript("OnUpdate", nil)
    end
  end
end
