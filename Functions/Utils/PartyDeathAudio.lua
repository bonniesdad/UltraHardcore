local currentSoundHandle = nil

SLASH_STOPSOUND1 = '/stopsound'
SlashCmdList.STOPSOUND = function()
  if currentSoundHandle then
    StopSound(currentSoundHandle)
    currentSoundHandle = nil
  end
end

SLASH_TESTPARTYDEATHAUDIO1 = '/testpartydeathaudio'
SlashCmdList.TESTPARTYDEATHAUDIO = function()
  local randomNumber = random(1,4)
  local willPlay = nil
  local soundHandle = nil
  if currentSoundHandle == nil then
    -- Play sound file on party death
    willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\UltraHardcore\\Sounds\\PartyDeath" .. randomNumber .. ".ogg", "SFX")
    if willPlay then
        currentSoundHandle = soundHandle
    end
  end
end