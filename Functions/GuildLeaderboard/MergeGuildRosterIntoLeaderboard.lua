-- Apply cached guild roster rows to the guild leaderboard.

function UHC_MergeGuildRosterIntoLeaderboard(pruneMissing)
  if not IsInGuild() or type(UHC_ApplyGuildRosterRowToLeaderboard) ~= 'function' then
    return false
  end
  local total = select(1, GetNumGuildMembers(true))
  if not total or total < 1 then
    total = select(1, GetNumGuildMembers())
  end
  total = tonumber(total) or 0
  if total < 1 then
    return false
  end

  local changed = false
  local seenPlayerIds = {}
  for i = 1, total do
    local name, _, _, level, _, _, _, _, _, _, _, achievementPoints, _, _, _, _, guid = GetGuildRosterInfo(i)
    if guid and guid ~= '' and name and name ~= '' then
      seenPlayerIds[guid] = true
      local rowChanged = UHC_ApplyGuildRosterRowToLeaderboard({
        name = name,
        playerId = guid,
        level = level,
        achievementPoints = achievementPoints,
      })
      changed = changed or rowChanged
    end
  end

  if pruneMissing and UltraHardcoreDB then
    UltraHardcoreDB.guildPeers = UltraHardcoreDB.guildPeers or {}
    for playerId in pairs(UltraHardcoreDB.guildPeers) do
      if not seenPlayerIds[playerId] then
        UltraHardcoreDB.guildPeers[playerId] = nil
        changed = true
      end
    end
  end

  return changed
end
