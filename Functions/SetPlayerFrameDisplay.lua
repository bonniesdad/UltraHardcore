-- Player frame

-- Mask that lets us know what parts to show
local playerMask = {}

-- Subframes / elements we want to control
local PLAYER_HIDEABLE = {
  "PlayerFrameHealthBar",
  "PlayerFrameHealthBarText",
  "PlayerFrameHealthBarTextLeft",
  "PlayerFrameHealthBarTextRight",
  "PlayerFrameManaBar",
  "PlayerFrameManaBarText",
  "PlayerFrameManaBarTextLeft",
  "PlayerFrameManaBarTextRight",
  "PlayerName",
  "PlayerFrameTexture",
  "PlayerStatusTexture",
  "PlayerFrameBackground",
}

-- Apply mask to PlayerFrame
local function ApplyPlayerMask()
  -- Show everything (default blizzard frames)
  if playerMask.all then return end

  -- Hide/alpha all standard hideable elements
  for _, name in ipairs(PLAYER_HIDEABLE) do
    local f = _G[name]
    if f then
      if name == "PlayerStatusTexture" then
        -- This will hide the name glow in rested areas
        PlayerStatusTexture:SetTexture(nil)
      end
      f:SetAlpha(0)
    end
  end
end


-- Hook into Blizzard updates
hooksecurefunc("PlayerFrame_Update", ApplyPlayerMask)

function SetPlayerFrameDisplay()
  -- Setup Player frame options
  if GLOBAL_SETTINGS.hidePlayerFrame then
    -- Only show the portrait
    playerMask.portrait = true
  else
    -- Show all (default player frame)
    playerMask.all = true
  end
  if GLOBAL_SETTINGS.completelyRemovePlayerFrame then
    -- Completely hide the Player Frame 
    ForceHideFrame(PlayerFrame)
    return
  end
  ApplyPlayerMask()
end
