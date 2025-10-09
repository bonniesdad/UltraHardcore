-- ShowKnockdownOverlay.lua
-- White "flash-bang" on knockdown that fades out over ~4 second.
-- Can be tested with /run if UltraHardcore and UltraHardcore.TriggerKnockdownFlash then UltraHardcore.TriggerKnockdownFlash(4, 1) end

-- Debuffs that should trigger a flash
UltraHardcore = UltraHardcore or {}
UltraHardcore.KnockdownDebuffs = UltraHardcore.KnockdownDebuffs or {
  { 13360, 15753, 5951 },  -- Knockdown
  7922,                    -- Stun (charge)
  7139,                    -- Fel Stomp
}

local FLASH_DURATION   = 4.0   -- seconds to fade out
local FLASH_MAX_ALPHA  = 1  -- how bright the white flash gets
local flashElapsed     = 0
local flashActive      = false

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

local function IsKnockdownSpell(spellId)
  if not spellId then return false end
  for _, v in ipairs(UltraHardcore.KnockdownDebuffs) do
    if type(v) == "table" then
      for _, id in ipairs(v) do
        if id == spellId then
          return true
        end
      end
    elseif v == spellId then
      return true
    end
  end
  return false
end

-- Helper (so you can macro it or call from other files)
function UltraHardcore.TriggerKnockdownFlash(duration, maxAlpha)
  StartKnockdownFlash(duration, maxAlpha)
end

local auraWatcher = CreateFrame("Frame")
auraWatcher:RegisterEvent("UNIT_AURA")
auraWatcher:SetScript("OnEvent", function(_, _, unit)
  if unit ~= "player" then return end

  for i = 1, 40 do
    local _, _, _, _, _, _, _, _, _, spellId = UnitDebuff("player", i)
    if not spellId then break end
    if IsKnockdownSpell(spellId) then
      StartKnockdownFlash(FLASH_DURATION, FLASH_MAX_ALPHA)
      break
    end
  end
end)


