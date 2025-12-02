-- Global mask and event frame
local targetFrameMask = {}
local targetFrameEventFrame = nil

-- Buff Limits
local maxBuffs = BUFF_MAX_DISPLAY or 32
local maxDebuffs = DEBUFF_MAX_DISPLAY or 16

-- Top-level frames that can be hidden
local HIDEABLE_SUBFRAMES = {
  "HealthBar",
  "ManaBar",
  "Name",
  "NameBackground",
  "HealthBarText",
  "ManaBarText",
  "Background"
}

-- Hide all texture regions inside frame except portrait, raid icon
local function HideTextureRegions(frame)
  if not frame then return end
  if targetFrameMask.all then
    -- Don't hide if we are trying to show all frames, like when in lite mode
    return
  end

  for i = 1, select("#", frame:GetRegions()) do
    local region = select(i, frame:GetRegions())
    if region and not region:IsProtected() then
      region:SetAlpha(0)
    end
  end
end

-- Apply alpha to hide subframes
local function HideSubFrames(frame)
  if targetFrameMask.all then
    -- don't hide anything if we are trying to show all
    return
  end

  for _, name in ipairs(HIDEABLE_SUBFRAMES) do
    local f = _G[frame..name]
    if f then
      f:SetAlpha(0)
    end
  end
end

-- Show/hide portrait
local function ApplyPortrait()
  if TargetFramePortrait then
    TargetFramePortrait:SetAlpha(targetFrameMask.portrait and 1 or 0)
  end
end

-- Show/hide buffs/debuffs
local function ApplyAuras()
  for i = 1, maxBuffs do
    local buff = _G["TargetFrameBuff"..i]
    if buff then
      buff:SetAlpha(targetFrameMask.buffs and 1 or 0)
    end
  end

  for i = 1, maxDebuffs do
    local debuff = _G["TargetFrameDebuff"..i]
    if debuff then
      debuff:SetAlpha(targetFrameMask.debuffs and 1 or 0)
    end
  end
end

-- Position buffs and debuffs
local function PositionAuras()
  local spacing = 5 -- spacing between icons
  local size = 16   -- icon size
  local maxPerRow = 10 -- how many buffs/debuffs before we start a new row - TODO:  make this configurable

  -- Buffs
  local buffRowsUsed = 0

  if targetFrameMask.buffs then
    local shownIndex = 0

    for i = 1, maxBuffs do
      local buff = _G["TargetFrameBuff"..i]
      if buff and buff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        buff:ClearAllPoints()
        buff:SetPoint(
          "LEFT",
          TargetFramePortrait,
          "RIGHT",
          spacing + col * (size + spacing),
          15 - row * (size + spacing)
        )

        buffRowsUsed = row + 1
      end
    end
  end

  -- Debuffs
  if targetFrameMask.debuffs then
    local shownIndex = 0

    -- debuffs start below the last buff row
    local baseYOffset = 5 - buffRowsUsed * (size + spacing) - spacing

    for i = 1, maxDebuffs do
      local debuff = _G["TargetFrameDebuff"..i]
      if debuff and debuff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        debuff:ClearAllPoints()
        debuff:SetPoint(
          "LEFT",
          TargetFramePortrait,
          "RIGHT",
          spacing + col * (size + spacing),
          baseYOffset - row * (size + spacing)
        )
      end
    end
  end
end

-- Show/hide raid icon
local function ApplyRaidIcon()
  if TargetFrameTextureFrameRaidTargetIcon then
    TargetFrameTextureFrameRaidTargetIcon:SetAlpha(targetFrameMask.raidIcon and 1 or 0)
  end
end

-- Showing Buffs/Debuffs on ToT can be a bit too much
local function HideToTAuras()
  for i = 1, maxBuffs do
    local buff = _G["TargetFrameToTBuff"..i]
    if buff then buff:SetAlpha(0) end
  end
  for i = 1, maxDebuffs do
    local debuff = _G["TargetFrameToTDebuff"..i]
    if debuff then debuff:SetAlpha(0) end
  end
end

-- Show Target of Target if the user has turned it on in the blizzard options
-- We will strip it down to just the portrait
local function ShowToT()
  if not TargetFrameToT then return end
    -- allow Blizzard to show ToT normally
  if not InCombatLockdown() then
    TargetFrameToT:SetAlpha(1)
    if TargetFrameToTTextureFrame then
      TargetFrameToTTextureFrame:SetAlpha(1)
    end
  end
end

-- Apply the full mask (combat-safe with alpha instead of Show/Hide)
local function ApplyMask()
  if TargetFrame then TargetFrame:SetAlpha(1) end
  if TargetFrameTextureFrame then TargetFrameTextureFrame:SetAlpha(1) end

  -- If mask is set to show all, do nothing (show Blizzard default frames)
  if targetFrameMask.all then
    -- still must update ToT visibility
    ShowToT()
    return
  end

  if not UnitExists("target") then
    if TargetFrame then TargetFrame:SetAlpha(0) end
    if TargetFrameTextureFrame then TargetFrameTextureFrame:SetAlpha(0) end
    return
  end

  HideSubFrames("TargetFrame")
  HideTextureRegions(TargetFrameTextureFrame)
  ApplyPortrait()
  ApplyRaidIcon()
  ApplyAuras()
  PositionAuras()
end

-- Hook Blizzard update functions
hooksecurefunc("TargetFrame_Update", ApplyMask)
hooksecurefunc("TargetFrame_UpdateAuras", ApplyMask)
  -- Target of Target hook (NO existence checks, NO visibility logic)
hooksecurefunc("TargetofTarget_Update", function()
  -- Always allow default alpha/visibility
  TargetFrameToT:SetAlpha(1)

  -- Strip subframes/texture
  HideSubFrames("TargetFrameToT")
  if TargetFrameToTTextureFrame then
    HideTextureRegions(TargetFrameToTTextureFrame)
  end
  -- Always hide auras (regardless of ToT existence)
  HideToTAuras()
end)


-- Main API
function SetTargetFrameDisplay(mask)
  -- ensure mask is always a table
  if type(mask) ~= "table" then mask = {} end
  targetFrameMask = mask

  if not targetFrameEventFrame then
    targetFrameEventFrame = CreateFrame("Frame")
    targetFrameEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    targetFrameEventFrame:RegisterEvent("UNIT_AURA")
    targetFrameEventFrame:RegisterEvent("RAID_TARGET_UPDATE")
    targetFrameEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    targetFrameEventFrame:SetScript("OnEvent", function(_, event, unit)
      if event == "PLAYER_TARGET_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
        ApplyMask()
      end
    end)
  end
end
