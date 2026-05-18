-- Apply one guild roster row into UltraHardcoreDB.guildPeers.

local function normalizeRosterLevel(level)
  local n = tonumber(level) or 1
  if n < 1 then
    n = 1
  end
  return n
end

local function normalizeRosterAchievementPoints(ap)
  local n = tonumber(ap) or 0
  if n < 0 then
    n = 0
  end
  return n
end

function UHC_ApplyGuildRosterRowToLeaderboard(row)
  if type(row) ~= 'table' or not row.playerId or row.playerId == '' then
    return false
  end

  if not UltraHardcoreDB then
    return false
  end
  UltraHardcoreDB.guildPeers = UltraHardcoreDB.guildPeers or {}

  local existing = UltraHardcoreDB.guildPeers[row.playerId]
  local level = normalizeRosterLevel(row.level)

  if existing then
    if tonumber(existing.level) ~= level then
      existing.level = level
      return true
    end
    return false
  end

  UltraHardcoreDB.guildPeers[row.playerId] = {
    name = row.name,
    playerId = row.playerId,
    level = level,
    achievementPoints = normalizeRosterAchievementPoints(row.achievementPoints),
    enemiesSlain = tonumber(row.enemiesSlain) or 0,
    dungeonsCompleted = tonumber(row.dungeonsCompleted) or 0,
    playerJumps = tonumber(row.playerJumps) or 0,
    lastSeen = time and time() or 0,
  }
  return true
end
