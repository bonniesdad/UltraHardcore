-- Shared guild leaderboard data and sorting (settings tab + on-screen panel).

GUILD_LEADERBOARD_TAB_INDEX = 2

function UHC_GetGuildLeaderboardRowTint()
  return { r = 0.13, g = 0.19, b = 0.40, a = 0.30 }
end

local ULTRA_TEX_VALID = 'Interface\\AddOns\\UltraHardcore\\Textures\\valid.png'
local ULTRA_TEX_FAILED = 'Interface\\AddOns\\UltraHardcore\\Textures\\failed.png'
local ULTRA_TEX_UNSURE = 'Interface\\AddOns\\UltraHardcore\\Textures\\unsure.png'

--- @return 'valid'|'failed'|'unsure'
function UHC_NormalizeGuildLeaderboardUltraStatus(code)
  local c = type(code) == 'string' and string.upper(code) or ''
  if c == 'V' or c == 'VALID' then
    return 'valid'
  end
  if c == 'F' or c == 'FAILED' then
    return 'failed'
  end
  return 'unsure'
end

--- Single-letter code for guild addon messages (v4 payload).
function UHC_GetGuildLeaderboardUltraBroadcastCode()
  if not UHC_XPVerification or not UHC_XPVerification.GetVerificationVerdictAndSettingLabel then
    return 'U'
  end
  local verdict = UHC_XPVerification.GetVerificationVerdictAndSettingLabel()
  if verdict == 'Verified' then
    return 'V'
  end
  if verdict == 'Failed' or verdict == 'Sceptical' then
    return 'F'
  end
  return 'U'
end

function UHC_GetLocalGuildLeaderboardUltraStatus()
  return UHC_NormalizeGuildLeaderboardUltraStatus(UHC_GetGuildLeaderboardUltraBroadcastCode())
end

function UHC_GetGuildLeaderboardUltraStatusForRow(row)
  if not row then
    return 'unsure'
  end
  if UHC_IsLocalGuildLeaderboardRow and UHC_IsLocalGuildLeaderboardRow(row) then
    return UHC_GetLocalGuildLeaderboardUltraStatus()
  end
  if row.ultraVerificationStatus then
    return UHC_NormalizeGuildLeaderboardUltraStatus(row.ultraVerificationStatus)
  end
  return 'unsure'
end

function UHC_GetGuildLeaderboardUltraTexture(status)
  status = UHC_NormalizeGuildLeaderboardUltraStatus(status)
  if status == 'valid' then
    return ULTRA_TEX_VALID
  end
  if status == 'failed' then
    return ULTRA_TEX_FAILED
  end
  return ULTRA_TEX_UNSURE
end

function UHC_GetGuildLeaderboardPlayerAchievementPoints()
  if type(UHC_GetGuildLeaderboardAchievementPoints) == 'function' then
    return UHC_GetGuildLeaderboardAchievementPoints()
  end
  return 0
end

function UHC_GetGuildLeaderboardPlayerRow()
  local name = UnitName and UnitName('player')
  local level = UnitLevel and UnitLevel('player')
  if not level or level < 1 then
    level = 1
  end
  local guid = UnitGUID and UnitGUID('player')
  return {
    name = name,
    playerId = guid,
    level = level,
    achievementPoints = UHC_GetGuildLeaderboardPlayerAchievementPoints(),
    enemiesSlain = (UHC_GetGuildLeaderboardEnemiesSlain and UHC_GetGuildLeaderboardEnemiesSlain()) or 0,
    dungeonsCompleted = (UHC_GetGuildLeaderboardDungeonCompletions and UHC_GetGuildLeaderboardDungeonCompletions()) or 0,
    playerJumps = (UHC_GetGuildLeaderboardJumpCount and UHC_GetGuildLeaderboardJumpCount()) or 0,
    ultraVerificationStatus = UHC_GetLocalGuildLeaderboardUltraStatus(),
  }
end

function UHC_GuildLeaderboardDisplayName(name)
  if name == nil or name == '' then
    return name
  end
  local s = tostring(name)
  local dash = string.find(s, '-', 1, true)
  if not dash or dash <= 1 then
    return s
  end
  return string.sub(s, 1, dash - 1)
end

local function leaderboardCompare(a, b)
  local la, lb = a.level or 0, b.level or 0
  if la ~= lb then
    return la > lb
  end
  local apA = a.achievementPoints or 0
  local apB = b.achievementPoints or 0
  if apA ~= apB then
    return apA > apB
  end
  local na, nb = tostring(a.name or ''), tostring(b.name or '')
  return na < nb
end

function UHC_CopyGuildLeaderboardEntries(source)
  local r = {}
  local t = source
  if not t then
    t = UHC_GetSortedGuildLeaderboardCopy()
  end
  for i = 1, #t do
    r[i] = t[i]
  end
  return r
end

function UHC_SortGuildLeaderboardInPlace(rows)
  table.sort(rows, leaderboardCompare)
end

local function achievementPointsLeaderboardCompare(a, b)
  local apA = a.achievementPoints or 0
  local apB = b.achievementPoints or 0
  if apA ~= apB then
    return apA > apB
  end
  local la, lb = a.level or 0, b.level or 0
  if la ~= lb then
    return la > lb
  end
  return tostring(a.name or '') < tostring(b.name or '')
end

function UHC_GetTopAchievementPointsGuildLeaderboardRowFromRows(rows)
  if not rows or #rows == 0 then
    return nil
  end
  local copy = UHC_CopyGuildLeaderboardEntries(rows)
  table.sort(copy, achievementPointsLeaderboardCompare)
  return copy[1]
end

function UHC_GetSortedGuildLeaderboardCopy()
  local byPlayerId = {}
  local peers = UltraHardcoreDB and UltraHardcoreDB.guildPeers
  if type(peers) == 'table' then
    for _, e in pairs(peers) do
      if type(e) == 'table' and e.name and e.playerId then
        local pid = e.playerId
        local ts = type(e.lastSeen) == 'number' and e.lastSeen or 0
        local prev = byPlayerId[pid]
        if not prev or ts >= (prev._ts or 0) then
          byPlayerId[pid] = {
            name = e.name,
            playerId = pid,
            achievementPoints = e.achievementPoints or 0,
            enemiesSlain = e.enemiesSlain or 0,
            dungeonsCompleted = e.dungeonsCompleted or 0,
            playerJumps = e.playerJumps or 0,
            level = e.level or 1,
            ultraVerificationStatus = e.ultraVerificationStatus,
            _ts = ts,
          }
        end
      end
    end
  end

  local rows = {}
  for _, row in pairs(byPlayerId) do
    row._ts = nil
    rows[#rows + 1] = row
  end

  local player = UHC_GetGuildLeaderboardPlayerRow()
  local myGuid = player.playerId
  local found = false
  if myGuid then
    for i = 1, #rows do
      if rows[i].playerId == myGuid then
        rows[i].name = player.name
        rows[i].achievementPoints = player.achievementPoints
        rows[i].enemiesSlain = player.enemiesSlain
        rows[i].dungeonsCompleted = player.dungeonsCompleted
        rows[i].playerJumps = player.playerJumps
        rows[i].level = player.level
        rows[i].ultraVerificationStatus = player.ultraVerificationStatus
        found = true
        break
      end
    end
  end
  if not found then
    rows[#rows + 1] = player
  end

  UHC_SortGuildLeaderboardInPlace(rows)
  return rows
end

function UHC_IsLocalGuildLeaderboardName(name)
  local nm = string.lower(tostring(name or ''))
  if nm == '' then
    return false
  end
  local un = UnitName and UnitName('player')
  if un and string.lower(un) == nm then
    return true
  end
  return false
end

function UHC_IsLocalGuildLeaderboardRow(row)
  if not row then
    return false
  end
  local myGuid = UnitGUID and UnitGUID('player')
  if myGuid and row.playerId and row.playerId == myGuid then
    return true
  end
  return UHC_IsLocalGuildLeaderboardName(row.name)
end

function UHC_GetMainScreenGuildLeaderboardWindow(maxRows)
  maxRows = maxRows or 7
  local sorted = UHC_GetSortedGuildLeaderboardCopy()
  local n = #sorted
  if n == 0 then
    return {}, 1
  end

  local midSlot = math.floor(maxRows / 2) + 1
  local playerIdx
  for i = 1, n do
    if UHC_IsLocalGuildLeaderboardRow(sorted[i]) then
      playerIdx = i
      break
    end
  end
  if not playerIdx then
    playerIdx = math.min(midSlot, n)
  end

  local start = playerIdx - (midSlot - 1)
  if start < 1 then
    start = 1
  end
  if start + maxRows - 1 > n then
    start = math.max(1, n - maxRows + 1)
  end

  local window = {}
  for i = 1, maxRows do
    window[i] = sorted[start + i - 1]
  end
  return window, start
end

function UHC_NotifyMainScreenGuildLeaderboardDataChanged()
  if UHC_RefreshMainScreenGuildLeaderboard then
    UHC_RefreshMainScreenGuildLeaderboard()
  end
end

function UHC_NotifyGuildLeaderboardDataChanged()
  UHC_NotifyMainScreenGuildLeaderboardDataChanged()
  if RefreshGuildLeaderboardTabUI then
    RefreshGuildLeaderboardTabUI()
  end
end

function UHC_EnsureGuildLeaderboardDBDefaults()
  if not UltraHardcoreDB then
    return
  end
  UltraHardcoreDB.guildPeers = UltraHardcoreDB.guildPeers or {}
  if UltraHardcoreDB.showOnScreenGuildLeaderboard == nil then
    UltraHardcoreDB.showOnScreenGuildLeaderboard = true
  end
end
