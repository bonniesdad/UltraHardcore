local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('CVAR_UPDATE')

frame:SetScript('OnEvent', function(self, event, cvar)
  if GLOBAL_SETTINGS.hideEnemyNameplates then
    if event == 'PLAYER_ENTERING_WORLD' or (event == 'CVAR_UPDATE' and cvar == 'nameplateShowEnemies') then
      SetCVar('nameplateShowEnemies', 0)
    end
  end
end)
