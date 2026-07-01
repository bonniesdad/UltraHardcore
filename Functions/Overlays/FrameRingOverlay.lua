-- Custom portrait ring aligned with the default PlayerFrameTexture / TargetFrameTexture frame art.

local FRAME_RING_TEXTURE = 'Interface\\AddOns\\UltraHardcore\\Textures\\frame-ring.png'

-- Portrait is 64x64 in Blizzard XML; the decorative ring extends slightly beyond it.
local PORTRAIT_RING_PADDING = 4
local RING_SIZE_SCALE = 1.2
local RING_POSITION_OFFSET_X = 20
local RING_POSITION_OFFSET_Y = 20

-- Portrait ring center offsets from the unit-frame texture center (see PlayerFrame.xml / TargetFrame.xml).
local PLAYER_RING_CENTER_OFFSET_X = -63
local PLAYER_RING_CENTER_OFFSET_Y = -16
local TARGET_RING_CENTER_OFFSET_X = 23
local TARGET_RING_CENTER_OFFSET_Y = -16

local playerRing, targetRing, targetToTRing, focusRing, focusToTRing
local initialized = false

local function IsTBCClient()
  return type(IsTBC) == 'function' and IsTBC()
end

local function GetPortraitRingSize(portrait)
  local portraitSize = portrait and portrait:GetWidth() or 0
  if portraitSize <= 0 then
    portraitSize = 64
  end
  return (portraitSize + (PORTRAIT_RING_PADDING * 2)) * RING_SIZE_SCALE
end

local function CreateRing(parent)
  local ring = parent:CreateTexture(nil, 'OVERLAY', nil, 7)
  ring:SetTexture(FRAME_RING_TEXTURE)
  return ring
end

local function PositionRingOnPortrait(ring, portrait, offsetX, offsetY)
  if not ring or not portrait then return end

  local ringSize = GetPortraitRingSize(portrait)
  ring:ClearAllPoints()
  ring:SetSize(ringSize, ringSize)
  ring:SetPoint('CENTER', portrait, 'CENTER', offsetX or 0, offsetY or 0)
end

local function PositionRing(ring, frameTexture, portrait, centerOffsetX, centerOffsetY)
  if not ring or not frameTexture or not portrait then return end

  local ringSize = GetPortraitRingSize(portrait)
  ring:ClearAllPoints()
  ring:SetSize(ringSize, ringSize)
  ring:SetPoint(
    'CENTER',
    frameTexture,
    'CENTER',
    centerOffsetX + RING_POSITION_OFFSET_X,
    centerOffsetY + RING_POSITION_OFFSET_Y
  )
end

local function ShouldShowPlayerRing()
  if not GLOBAL_SETTINGS or GLOBAL_SETTINGS.completelyRemovePlayerFrame then
    return false
  end
  return GLOBAL_SETTINGS.hidePlayerFrame
end

local function ShouldShowTargetRing()
  if not GLOBAL_SETTINGS or GLOBAL_SETTINGS.completelyRemoveTargetFrame then
    return false
  end
  if not GLOBAL_SETTINGS.hideTargetFrame then
    return false
  end
  return UnitExists('target')
end

local function ShouldShowTargetToTRing()
  if not ShouldShowTargetRing() then
    return false
  end
  return UnitExists('targettarget')
end

local function ShouldShowFocusRing()
  if not IsTBCClient() then
    return false
  end
  if not GLOBAL_SETTINGS or GLOBAL_SETTINGS.completelyRemoveTargetFrame then
    return false
  end
  if not GLOBAL_SETTINGS.hideTargetFrame then
    return false
  end
  return UnitExists('focus')
end

local function ShouldShowFocusToTRing()
  if not ShouldShowFocusRing() then
    return false
  end
  return UnitExists('focustarget')
end

local function GetFocusPortrait()
  return _G.FocusFramePortrait or _G.FocusFrameTextureFramePortrait or _G.FocusFramePortraitFramePortrait
end

function UpdateFrameRingOverlay()
  if PlayerFrame and PlayerFrameTexture and PlayerPortrait then
    if not playerRing then
      playerRing = CreateRing(PlayerFrame)
    end
    PositionRing(
      playerRing,
      PlayerFrameTexture,
      PlayerPortrait,
      PLAYER_RING_CENTER_OFFSET_X,
      PLAYER_RING_CENTER_OFFSET_Y
    )
    playerRing:SetAlpha(ShouldShowPlayerRing() and 1 or 0)
  end

  if TargetFrame and TargetFramePortrait then
    local targetTexture = _G.TargetFrameTextureFrameTexture
    if targetTexture then
      if not targetRing then
        targetRing = CreateRing(TargetFrame)
      end
      PositionRing(
        targetRing,
        targetTexture,
        TargetFramePortrait,
        TARGET_RING_CENTER_OFFSET_X,
        TARGET_RING_CENTER_OFFSET_Y
      )
      targetRing:SetAlpha(ShouldShowTargetRing() and 1 or 0)
    end
  end

  if TargetFrameToT and TargetFrameToTPortrait then
    if not targetToTRing then
      targetToTRing = CreateRing(TargetFrameToT)
    end
    PositionRingOnPortrait(targetToTRing, TargetFrameToTPortrait)
    targetToTRing:SetAlpha(ShouldShowTargetToTRing() and 1 or 0)
  end

  if IsTBCClient() and FocusFrame then
    local focusPortrait = GetFocusPortrait()
    local focusTexture = _G.FocusFrameTextureFrameTexture
    if focusPortrait and focusTexture then
      if not focusRing then
        focusRing = CreateRing(FocusFrame)
      end
      PositionRing(
        focusRing,
        focusTexture,
        focusPortrait,
        TARGET_RING_CENTER_OFFSET_X,
        TARGET_RING_CENTER_OFFSET_Y
      )
      focusRing:SetAlpha(ShouldShowFocusRing() and 1 or 0)
    end
  end

  if IsTBCClient() and FocusFrameToT then
    local focusToTPortrait = _G.FocusFrameToTPortrait or _G.FocusFrameToTTextureFramePortrait
    if focusToTPortrait then
      if not focusToTRing then
        focusToTRing = CreateRing(FocusFrameToT)
      end
      PositionRingOnPortrait(focusToTRing, focusToTPortrait)
      focusToTRing:SetAlpha(ShouldShowFocusToTRing() and 1 or 0)
    end
  end
end

local function InitializeFrameRingOverlay()
  if initialized then
    UpdateFrameRingOverlay()
    return
  end
  initialized = true

  if type(hooksecurefunc) == 'function' then
    hooksecurefunc('PlayerFrame_Update', UpdateFrameRingOverlay)
  end

  UpdateFrameRingOverlay()
end

local initFrame = CreateFrame('Frame')
initFrame:RegisterEvent('PLAYER_LOGIN')
initFrame:SetScript('OnEvent', function()
  InitializeFrameRingOverlay()
end)
