-- Global mask and event frame
local targetFrameMask = {}
local targetFrameEventFrame = nil

-- Buff Limits
local maxBuffs = BUFF_MAX_DISPLAY or 32
local maxDebuffs = DEBUFF_MAX_DISPLAY or 16

-- Top-level frames that can be hidden
local HIDEABLE_SUBFRAMES =
  { 'HealthBar', 'ManaBar', 'Name', 'NameBackground', 'HealthBarText', 'ManaBarText', 'Background' }

-- Cache commonly accessed frames
local TargetFrame, TargetFrameTextureFrame, TargetFramePortrait
local TargetFrameToT, TargetFrameToTTextureFrame, TargetFrameToTPortrait
local TargetFrameTextureFrameRaidTargetIcon

-- Update cached frame references
local function UpdateCachedFrames()
  TargetFrame = _G.TargetFrame
  TargetFrameTextureFrame = _G.TargetFrameTextureFrame
  TargetFramePortrait = _G.TargetFramePortrait
  TargetFrameToT = _G.TargetFrameToT
  TargetFrameToTTextureFrame = _G.TargetFrameToTTextureFrame
  TargetFrameToTPortrait = _G.TargetFrameToTPortrait
  TargetFrameTextureFrameRaidTargetIcon = _G.TargetFrameTextureFrameRaidTargetIcon
end

-- Hide all texture regions inside frame except portrait, raid icon
local function HideTextureRegions(frame)
  if not frame or targetFrameMask.all then return end

  local regions = { frame:GetRegions() }
  for i = 1, #regions do
    local region = regions[i]
    if region and not region:IsProtected() then
      region:SetAlpha(0)
    end
  end
end

-- Apply alpha to hide subframes
local function HideSubFrames(framePrefix)
  if targetFrameMask.all then return end

  for i = 1, #HIDEABLE_SUBFRAMES do
    local f = _G[framePrefix .. HIDEABLE_SUBFRAMES[i]]
    if f and not f:IsProtected() then
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
  local showBuffs = targetFrameMask.buffs
  local showDebuffs = targetFrameMask.debuffs

  for i = 1, maxBuffs do
    local buff = _G['TargetFrameBuff' .. i]
    if buff then
      buff:SetAlpha(showBuffs and 1 or 0)
    end
  end

  for i = 1, maxDebuffs do
    local debuff = _G['TargetFrameDebuff' .. i]
    if debuff then
      debuff:SetAlpha(showDebuffs and 1 or 0)
    end
  end
end

-- Position buffs and debuffs
local function PositionAuras()
  local spacing = 5 -- spacing between icons
  local size = 16 -- icon size
  local maxPerRow = 10 -- how many buffs/debuffs before we start a new row - TODO:  make this configurable
  -- Buffs
  local buffRowsUsed = 0

  if targetFrameMask.buffs then
    local shownIndex = 0

    for i = 1, maxBuffs do
      local buff = _G['TargetFrameBuff' .. i]
      if buff and buff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        buff:ClearAllPoints()
        buff:SetPoint(
          'LEFT',
          TargetFramePortrait,
          'RIGHT',
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
      local debuff = _G['TargetFrameDebuff' .. i]
      if debuff and debuff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        debuff:ClearAllPoints()
        debuff:SetPoint(
          'LEFT',
          TargetFramePortrait,
          'RIGHT',
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

-- Hide all target of target frames (but keep portrait like target frame)
local function HideTargetOfTargetFrames()
  if targetFrameMask.all then return end

  -- Keep the main TargetFrameToT frame visible (same as target frame)
  if TargetFrameToT then
    TargetFrameToT:SetAlpha(1)
  end

  -- Hide all TargetFrameToT subframes
  HideSubFrames('TargetFrameToT')

  -- Explicitly hide TargetFrameToTBackground
  local totBackground = _G.TargetFrameToTBackground
  if totBackground and not totBackground:IsProtected() then
    totBackground:SetAlpha(0)
  end

  -- Hide health and mana bar backgrounds (semi-transparent black backgrounds)
  local totHealthBar = _G.TargetFrameToTHealthBar
  if totHealthBar then
    HideTextureRegions(totHealthBar)
    local healthBarBg = _G.TargetFrameToTHealthBarBackground
    if healthBarBg and not healthBarBg:IsProtected() then
      healthBarBg:SetAlpha(0)
    end
  end

  local totManaBar = _G.TargetFrameToTManaBar
  if totManaBar then
    HideTextureRegions(totManaBar)
    local manaBarBg = _G.TargetFrameToTManaBarBackground
    if manaBarBg and not manaBarBg:IsProtected() then
      manaBarBg:SetAlpha(0)
    end
  end

  -- Hide texture regions but preserve portrait (same as target frame)
  if TargetFrameToTTextureFrame then
    HideTextureRegions(TargetFrameToTTextureFrame)
    local totTexture = _G.TargetFrameToTTextureFrameTexture
    if totTexture and not totTexture:IsProtected() then
      totTexture:SetAlpha(0)
    end
  end

  -- Show/hide portrait based on mask (same as target frame)
  if TargetFrameToTPortrait then
    TargetFrameToTPortrait:SetAlpha(targetFrameMask.portrait and 1 or 0)
  end
end

-- Apply the full mask (combat-safe with alpha instead of Show/Hide)
local function ApplyMask()
  -- Update cached frames in case they changed
  UpdateCachedFrames()

  if TargetFrame then
    TargetFrame:SetAlpha(1)
  end
  if TargetFrameTextureFrame then
    TargetFrameTextureFrame:SetAlpha(1)
  end

  -- If mask is set to show all, do nothing (show Blizzard default frames)
  if targetFrameMask.all then
    if TargetFrameToT then
      TargetFrameToT:SetAlpha(1)
    end
    return
  end

  if not UnitExists('target') then
    if TargetFrame then
      TargetFrame:SetAlpha(0)
    end
    if TargetFrameTextureFrame then
      TargetFrameTextureFrame:SetAlpha(0)
    end
    if TargetFrameToT then
      TargetFrameToT:SetAlpha(0)
    end
    return
  end

  HideSubFrames('TargetFrame')
  HideTextureRegions(TargetFrameTextureFrame)
  ApplyPortrait()
  ApplyRaidIcon()
  ApplyAuras()
  PositionAuras()
  HideTargetOfTargetFrames()
end

hooksecurefunc('TargetFrame_Update', ApplyMask)
hooksecurefunc('TargetFrame_UpdateAuras', ApplyMask)

-- Hook TargetFrameToT_Update if it exists
if _G.TargetFrameToT_Update then
  hooksecurefunc('TargetFrameToT_Update', ApplyMask)
end

-- Main API
function SetTargetFrameDisplay(mask)
  -- ensure mask is always a table
  if type(mask) ~= 'table' then
    mask = {}
  end
  targetFrameMask = mask

  if not targetFrameEventFrame then
    targetFrameEventFrame = CreateFrame('Frame')
    targetFrameEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    targetFrameEventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
    targetFrameEventFrame:RegisterEvent('PLAYER_REGEN_DISABLED') -- entering combat
    targetFrameEventFrame:SetScript('OnEvent', function(_, event)
      if event == 'PLAYER_TARGET_CHANGED' or event == 'GROUP_ROSTER_UPDATE' then
        ApplyMask()
      elseif event == 'PLAYER_REGEN_DISABLED' then
        -- Reapply mask immediately when entering combat
        ApplyMask()
        -- Also reapply after a small delay to catch any UI updates
        C_Timer.After(0.1, ApplyMask)
      end
    end)
  end

  -- Update cached frames and apply mask immediately
  UpdateCachedFrames()
  ApplyMask()
end
