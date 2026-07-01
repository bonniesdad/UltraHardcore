-- Player frame

-- Mask that lets us know what parts to show
local playerMask = {}

-- Subframes / elements we want to control
local PLAYER_HIDEABLE =
  {
    'PlayerFrameHealthBar',
    'PlayerFrameHealthBarText',
    'PlayerFrameHealthBarTextLeft',
    'PlayerFrameHealthBarTextRight',
    'PlayerFrameManaBar',
    'PlayerFrameManaBarText',
    'PlayerFrameManaBarTextLeft',
    'PlayerFrameManaBarTextRight',
    'PlayerName',
    'PlayerFrameTexture',
    'PlayerStatusTexture',
    'PlayerFrameBackground',
    'PlayerLevelText',
  }

local savedPlayerFrameTextureLayout = nil

local function SnapshotPlayerFrameTextureLayout()
  local texture = PlayerFrameTexture
  if not texture or savedPlayerFrameTextureLayout then return end

  local points = {}
  local numPoints = texture:GetNumPoints() or 0
  for i = 1, numPoints do
    points[i] = { texture:GetPoint(i) }
  end

  savedPlayerFrameTextureLayout = {
    width = texture:GetWidth(),
    height = texture:GetHeight(),
    points = points,
  }
end

local function RestorePlayerFrameTextureLayout()
  local texture = PlayerFrameTexture
  local saved = savedPlayerFrameTextureLayout
  if not texture or not saved then return end

  texture:SetSize(saved.width, saved.height)
  texture:ClearAllPoints()
  for i = 1, #saved.points do
    local point = saved.points[i]
    texture:SetPoint(point[1], point[2], point[3], point[4], point[5])
  end
end

local function SetHitRectToPortrait(frame, portrait)
  if not frame or not portrait or type(frame.SetHitRectInsets) ~= 'function' then return end

  local frameLeft, frameBottom, frameWidth, frameHeight = frame:GetRect()
  local portraitLeft, portraitBottom, portraitWidth, portraitHeight = portrait:GetRect()
  if not frameLeft or not portraitLeft then return end

  local left = portraitLeft - frameLeft
  local right = (frameLeft + frameWidth) - (portraitLeft + portraitWidth)
  local bottom = portraitBottom - frameBottom
  local top = (frameBottom + frameHeight) - (portraitBottom + portraitHeight)

  frame:SetHitRectInsets(left, right, top, bottom)
end

local function RestorePlayerFrameInteraction()
  if PlayerFrame and type(PlayerFrame.SetHitRectInsets) == 'function' then
    PlayerFrame:SetHitRectInsets(0, 0, 0, 0)
  end
  RestorePlayerFrameTextureLayout()
end

local function ShrinkPlayerFrameToPortrait()
  if not PlayerFrame or not PlayerPortrait or not PlayerFrameTexture then return end

  SnapshotPlayerFrameTextureLayout()

  local portraitWidth = PlayerPortrait:GetWidth()
  local portraitHeight = PlayerPortrait:GetHeight()
  if portraitWidth <= 0 then portraitWidth = 56 end
  if portraitHeight <= 0 then portraitHeight = 56 end

  PlayerFrameTexture:ClearAllPoints()
  PlayerFrameTexture:SetSize(portraitWidth, portraitHeight)
  PlayerFrameTexture:SetPoint('CENTER', PlayerPortrait, 'CENTER')

  SetHitRectToPortrait(PlayerFrame, PlayerPortrait)
end

-- Apply mask to PlayerFrame
local function ApplyPlayerMask()
  -- Show everything (default blizzard frames)
  if playerMask.all then
    RestorePlayerFrameInteraction()
    return
  end

  -- Hide/alpha all standard hideable elements
  for _, name in ipairs(PLAYER_HIDEABLE) do
    local f = _G[name]
    if f then
      if name == 'PlayerStatusTexture' then
        -- This will hide the name glow in rested areas
        PlayerStatusTexture:SetTexture(nil)
      end
      f:SetAlpha(0)
    end
  end

  if playerMask.portrait then
    ShrinkPlayerFrameToPortrait()
  end
end

-- Hook into Blizzard updates
hooksecurefunc('PlayerFrame_Update', ApplyPlayerMask)

function SetPlayerFrameDisplay()
  -- Setup Player frame options
  if GLOBAL_SETTINGS.hidePlayerFrame then
    -- Only show the portrait
    playerMask.portrait = true
    playerMask.all = nil
  else
    -- Show all (default player frame)
    playerMask.all = true
    playerMask.portrait = nil
  end
  if GLOBAL_SETTINGS.completelyRemovePlayerFrame then
    -- Completely hide the Player Frame
    ForceHideFrame(PlayerFrame)
    if UpdateFrameRingOverlay then
      UpdateFrameRingOverlay()
    end
    return
  end
  ApplyPlayerMask()
  if UpdateFrameRingOverlay then
    UpdateFrameRingOverlay()
  end
end
