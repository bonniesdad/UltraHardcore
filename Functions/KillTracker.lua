-- Kill Tracker
-- Handles tracking of various types of kills (elites, bosses, enemies, etc.)

-- Initialize global table
KillTracker = {}

-- Handle party kill events and update statistics
function KillTracker.HandlePartyKill(destGUID)
  if not destGUID then return end
  -- Track elite kills
  if IsEnemyElite(destGUID) then
    if PlayerIsSolo() then
      -- Track as solo elite kill
      local soloElites = CharacterStats:GetStat("soloElitesSlain") or 0
      CharacterStats:UpdateStat("soloElitesSlain", soloElites + 1)
    else
      -- Track as regular elite kill
      local currentElites = CharacterStats:GetStat("elitesSlain") or 0
      CharacterStats:UpdateStat("elitesSlain", currentElites + 1)
    end
  end

  -- Track rare elite kills
  if IsEnemyRareElite(destGUID) then
    if PlayerIsSolo() then
      local soloElites = CharacterStats:GetStat("soloElitesSlain") or 0
      CharacterStats:UpdateStat("soloElitesSlain", soloElites + 1)
    end
    local currentRareElites = CharacterStats:GetStat('rareElitesSlain') or 0
    CharacterStats:UpdateStat('rareElitesSlain', currentRareElites + 1)
  end

  -- Track world boss kills
  if IsEnemyWorldBoss(destGUID) then
    local currentWorldBosses = CharacterStats:GetStat('worldBossesSlain') or 0
    CharacterStats:UpdateStat('worldBossesSlain', currentWorldBosses + 1)
  end

  -- Check if this was a dungeon boss kill
  local isDungeonBoss, isRaidBoss = IsDungeonBoss(destGUID)
  if isDungeonBoss then
    local currentDungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
    CharacterStats:UpdateStat('dungeonBossesKilled', currentDungeonBosses + 1)
  end

  -- Check if this was a dungeon completion (final boss kill)
  local isDungeonFinalBoss, isRaidFinalBoss = IsDungeonFinalBoss(destGUID)
  if isDungeonFinalBoss then
    local currentDungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
    CharacterStats:UpdateStat('dungeonsCompleted', currentDungeonsCompleted + 1)
  end

  -- Track general enemy kills
  local currentEnemies = CharacterStats:GetStat('enemiesSlain') or 0
  CharacterStats:UpdateStat('enemiesSlain', currentEnemies + 1)
end
