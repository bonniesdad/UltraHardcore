--[[
  Route Planner
  - Shows map/battlefield map only when resting or under Cozy Fire (spell ID 7353)
]]

function SetRoutePlanner(routePlanner)
  if routePlanner then
    if IsResting() or HasCozyFire() then
      MakeMapUsable()
    else
      MakeMapUnusable()
    end
  end
end

local toggleWorldMapBackup = ToggleWorldMap
local toggleBattlefieldMapBackup = ToggleBattlefieldMap

function MakeMapUnusable()
    if WorldMapFrame:IsShown() then
        ToggleWorldMap()
    end
    ToggleWorldMap = function() end

    if BattlefieldMapFrame and BattlefieldMapFrame:IsShown() then
        ToggleBattlefieldMap()
    end
    ToggleBattlefieldMap = function() end
end

function MakeMapUsable()
    ToggleWorldMap = toggleWorldMapBackup
    ToggleBattlefieldMap = toggleBattlefieldMapBackup
end
