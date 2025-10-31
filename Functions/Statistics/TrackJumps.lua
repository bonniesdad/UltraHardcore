
local jumpTrackingFrame = CreateFrame("Frame")
jumpTrackingFrame:RegisterEvent("ADDON_LOADED")

jumpTrackingFrame:SetScript("OnEvent", function(self, event, ...)
  -- Table to store jump count and timestamps
  local JumpCounter = {}
  JumpCounter.count = 0
  JumpCounter.lastJump = 0
  JumpCounter.debounce = 0.75  -- seconds between counted jumps
  -- Get saved jump count if we have one
  JumpCounter.count = CharacterStats:GetStat('playerJumps') or 0

  -- Function to call when a jump is detected
  function JumpCounter:OnJump()
    self.count = self.count + 1
    self.lastJump = GetTime()
    CharacterStats:UpdateStat('playerJumps', JumpCounter.count)
    UpdateStatistics()
  end

  -- Hook AscendStop to detect player jumps
  hooksecurefunc("AscendStop", function()
    if not IsFalling() then
      return  -- ignore if the player is on the ground
    end

    local now = GetTime()
    if not JumpCounter.lastJump or (now - JumpCounter.lastJump > JumpCounter.debounce) then
      JumpCounter:OnJump()
    end
  end)
end)