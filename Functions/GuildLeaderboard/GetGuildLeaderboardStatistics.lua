local function getUltraStatsRow()
  if not IsAddOnLoaded('UltraStatistics') then
    return nil
  end
  local db = _G.UltraStatisticsDB
  if type(db) ~= 'table' or type(db.characterStats) ~= 'table' then
    return nil
  end
  local guid = UnitGUID('player')
  if not guid then
    return nil
  end
  local row = db.characterStats[guid]
  if type(row) ~= 'table' then
    return nil
  end
  return row
end

function UHC_GetGuildLeaderboardDungeonCompletions()
  local row = getUltraStatsRow()
  if not row then
    return 0
  end
  local n = tonumber(row.dungeonsCompleted) or 0
  if n < 0 then
    n = 0
  end
  return n
end

function UHC_GetGuildLeaderboardJumpCount()
  local row = getUltraStatsRow()
  if not row then
    return 0
  end
  local n = tonumber(row.playerJumps) or 0
  if n < 0 then
    n = 0
  end
  return n
end

function UHC_GetGuildLeaderboardEnemiesSlain()
  local row = getUltraStatsRow()
  if not row then
    return 0
  end
  local n = tonumber(row.enemiesSlain) or 0
  if n < 0 then
    n = 0
  end
  return n
end
