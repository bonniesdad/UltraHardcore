--[[
  Route Planner
  - Shows map/battlefield map only when resting or under Cozy Fire (spell ID 7353)
]]

function SetRoutePlanner(routePlanner)
  if routePlanner then
    -- Allow map while resting, near Cozy Fire, or while on taxi
    if IsResting() or HasCozyFire() or UnitOnTaxi('player') then
      MakeMapUsable()
    else
      MakeMapUnusable()
    end
  else
    -- When disabling Route Planner, restore any map indicator changes
    if MakeMapUsable then
      MakeMapUsable()
    end
    if RestorePlayerMapIndicators then
      RestorePlayerMapIndicators()
    end
  end
end

local toggleWorldMapBackup = ToggleWorldMap
local toggleBattlefieldMapBackup = ToggleBattlefieldMap

function MakeMapUnusable()
    if WorldMapFrame:IsShown() then
        ToggleWorldMap()
    end
    ToggleWorldMap = function()
      if CharacterStats and CharacterStats.GetStat and CharacterStats.UpdateStat then
        local current = CharacterStats:GetStat('mapKeyPressesWhileMapBlocked') or 0
        CharacterStats:UpdateStat('mapKeyPressesWhileMapBlocked', current + 1)
      end
    end

    if BattlefieldMapFrame and BattlefieldMapFrame:IsShown() then
        ToggleBattlefieldMap()
    end
    ToggleBattlefieldMap = function() end
end

function MakeMapUsable()
    ToggleWorldMap = toggleWorldMapBackup
    ToggleBattlefieldMap = toggleBattlefieldMapBackup
end

-- Ensure map usability state stays correct across rest/taxi/focus changes
local routePlannerEventsFrame = CreateFrame('Frame')
routePlannerEventsFrame:RegisterEvent('PLAYER_UPDATE_RESTING')
routePlannerEventsFrame:RegisterEvent('PLAYER_CONTROL_LOST')
routePlannerEventsFrame:RegisterEvent('PLAYER_CONTROL_GAINED')
routePlannerEventsFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
routePlannerEventsFrame:RegisterEvent('UNIT_AURA')
routePlannerEventsFrame:SetScript('OnEvent', function(self, event, unit)
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.routePlanner then
    if event == 'UNIT_AURA' and unit ~= 'player' then return end
    -- Re-evaluate immediately and once more shortly after (to handle lagging API updates)
    SetRoutePlanner(true)
    if C_Timer and C_Timer.After then
      C_Timer.After(0.1, function() SetRoutePlanner(true) end)
    end
  end
end)
