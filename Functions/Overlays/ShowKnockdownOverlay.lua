-- ShowKnockdownOverlay.lua
-- White "flash-bang" on knockdown that fades out over ~4 second.
-- Mirrors the structure of your breath overlay functions.
-- Can be tested with /run if UltraHardcore and UltraHardcore.TriggerFlashBang then UltraHardcore.TriggerFlashBang(4, 1) end

-- ⚙️ Debuffs that should trigger a flash (add/remove as you like)
UltraHardcore = UltraHardcore or {}
UltraHardcore.KnockdownDebuffs = UltraHardcore.KnockdownDebuffs or {
  ["Knockdown"]      = true,
  ["Knockdown Stun"] = true,
  ["Charge Stun"]  = true,
}

-- Internal state
local FLASH_DURATION   = 4.0   -- seconds to fade out
local FLASH_MAX_ALPHA  = 1  -- how bright the white flash gets
local flashElapsed     = 0
local flashActive      = false

-- 🟢 Create overlay frame (same strata logic used by your breath overlay)
local function EnsureFlashFrame()
  if UltraHardcore.knockdownFlashFrame then return end

  local f = CreateFrame('Frame', nil, UIParent)
  f:SetAllPoints(UIParent)

  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.tunnelVisionMaxStrata then
    f:SetFrameStrata('FULLSCREEN_DIALOG')
    f:SetFrameLevel(1000)
  else
    f:SetFrameStrata(ChatFrame1:GetFrameStrata())
    f:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
  end

  f.texture = f:CreateTexture(nil, 'BACKGROUND')
  f.texture:SetAllPoints()
  f.texture:SetColorTexture(1, 1, 1, 0) -- white, invisible by default
  f:Hide()

  UltraHardcore.knockdownFlashFrame = f
end

-- 🟢 Start a flash: quick pop to white, then fade out via OnUpdate
local function StartKnockdownFlash(duration, maxAlpha)
  EnsureFlashFrame()

  duration  = duration or FLASH_DURATION
  maxAlpha  = maxAlpha or FLASH_MAX_ALPHA
  flashElapsed = 0
  flashActive  = true

  local f = UltraHardcore.knockdownFlashFrame
  f.texture:SetColorTexture(1, 1, 1, maxAlpha)
  f:Show()

  f:SetScript("OnUpdate", function(self, elapsed)
    if not flashActive then
      self.texture:SetAlpha(0)
      self:Hide()
      self:SetScript("OnUpdate", nil)
      return
    end

    flashElapsed = flashElapsed + elapsed
    local t = math.min(flashElapsed / duration, 1)
    -- Linear fade from maxAlpha -> 0 over [0,1]
    local alpha = (1 - t) * maxAlpha
    self.texture:SetAlpha(alpha)

    if t >= 1 then
      flashActive = false
      self.texture:SetAlpha(0)
      self:Hide()
      self:SetScript("OnUpdate", nil)
    end
  end)
end

-- 🟢 Public helper (so you can macro it or call from other files)
function UltraHardcore.TriggerKnockdownFlash(duration, maxAlpha)
  StartKnockdownFlash(duration, maxAlpha)
end

-- 🟢 Auto-trigger on knockdown-like debuffs using UNIT_AURA
local auraWatcher = CreateFrame("Frame")
auraWatcher:RegisterEvent("UNIT_AURA")
auraWatcher:SetScript("OnEvent", function(_, _, unit)
  if unit ~= "player" or not UltraHardcore.KnockdownDebuffs then return end

  local i = 1
  while true do
    local name = UnitDebuff("player", i)
    if not name then break end
    if UltraHardcore.KnockdownDebuffs[name] then
      StartKnockdownFlash(FLASH_DURATION, FLASH_MAX_ALPHA)
      break
    end
    i = i + 1
  end
end)

-- 🟢 Optional: simple stop in case you ever need to cancel mid-fade
function UltraHardcore.StopKnockdownFlash()
  flashActive = false
  if UltraHardcore.knockdownFlashFrame then
    UltraHardcore.knockdownFlashFrame.texture:SetAlpha(0)
    UltraHardcore.knockdownFlashFrame:Hide()
    UltraHardcore.knockdownFlashFrame:SetScript("OnUpdate", nil)
  end
end
