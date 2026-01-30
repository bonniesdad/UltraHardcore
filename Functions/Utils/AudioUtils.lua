function UHC_GetSoundbiteChannel()
  local channel = (GLOBAL_SETTINGS and GLOBAL_SETTINGS.soundbiteChannel) or 'Master'

  if channel == 'Master' or channel == 'Music' or channel == 'SFX' or channel == 'Ambience' or channel == 'Dialog' then
    return channel
  end

  return 'Master'
end
