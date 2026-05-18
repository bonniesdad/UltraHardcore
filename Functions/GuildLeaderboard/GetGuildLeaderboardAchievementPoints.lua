function UHC_GetGuildLeaderboardAchievementPoints()
  if not IsAddOnLoaded('HardcoreAchievements') then
    return 0
  end

  local db = _G.HardcoreAchievementsDB
  if type(db) ~= 'table' or type(db.chars) ~= 'table' then
    return 0
  end

  local guid = UnitGUID('player')
  if not guid then
    return 0
  end

  local cdb = db.chars[guid]
  if type(cdb) ~= 'table' or type(cdb.achievements) ~= 'table' then
    return 0
  end

  local total = 0
  for _, rec in pairs(cdb.achievements) do
    if type(rec) == 'table' and rec.completed then
      total = total + (tonumber(rec.points) or 0)
    end
  end
  return total
end
