-- Audio utilities for Ultra Hardcore
-- Shared helpers for soundbite playback configuration

-- Returns the configured soundbite channel or a safe default.
-- Possible return values (Classic-compatible): "Master", "SFX", "Music", "Ambience"
function UHC_GetSoundbiteChannel()
  local channel = (GLOBAL_SETTINGS and GLOBAL_SETTINGS.soundbiteChannel) or 'Master'

  if channel == 'Master' or channel == 'SFX' or channel == 'Music' or channel == 'Ambience' then
    return channel
  end

  return 'Master'
end


