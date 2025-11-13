-- Track lowest health percentage
local pvpPauseLowestHealth = false
local pvpPauseLowestHealthThisLevel = false
local pvpPauseLowestHealthThisSession = false
local pvpPauseLowestHealthCloseEscape = false

-- A health drop below this percentage is considered a close escape
closeEscapeHealthPercent = 15

GLOBAL_SETTINGS.isDueling = false

local combatLowest = nil

local function IsFeigningDeath()
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitBuff('player', i)
    if not name then
      break
    end
    if spellId == 5384 or name == 'Feign Death' then
      return true
    end
  end
  return false
end

local function leftCombat()
  if combatLowest == nil then return end

  local currentLowestHealth = CharacterStats:GetStat('lowestHealth')
  local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel')
  local currentLowestHealthThisSession = CharacterStats:GetStat('lowestHealthThisSession')
  local currentCloseEscapes = CharacterStats:GetStat('closeEscapes')

  -- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of combat
  -- Check if lowestHealth tracking is not paused
  if not pvpPauseLowestHealth and combatLowest < currentLowestHealth then
    CharacterStats:UpdateStat('lowestHealth', combatLowest)
  end

  -- Track This Level lowest health (same conditions as total)
  -- Check if lowestHealthThisLevel tracking is not paused
  if not pvpPauseLowestHealthThisLevel and combatLowest < currentLowestHealthThisLevel then
    CharacterStats:UpdateStat('lowestHealthThisLevel', combatLowest)
  end

  -- Track This Session lowest health (same conditions as total)
  -- Check if lowestHealthThisSession tracking is not paused
  if not pvpPauseLowestHealthThisSession and combatLowest < currentLowestHealthThisSession then
    CharacterStats:UpdateStat('lowestHealthThisSession', combatLowest)
  end

  -- Track Close Escapes lowest health
  -- Check if lowestHealthCloseEscapes tracking is not paused
  if not pvpPauseLowestHealthCloseEscape and combatLowest < closeEscapeHealthPercent then
    if not UnitIsDeadOrGhost('player') then
      -- only increment if we didn't die and health was below closeEscapeHe
      CharacterStats:UpdateStat('closeEscapes', (currentCloseEscapes + 1))
    end
  end

  combatLowest = nil
end

local function TrackLowestHealth(event)
  local health = UnitHealth('player')
  local maxHealth = UnitHealthMax('player')

  local inCombat = UnitAffectingCombat('player')

  local healthPercent = (health / maxHealth) * 100
  local currentLowestHealth = CharacterStats:GetStat('lowestHealth')
  local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel')
  local currentLowestHealthThisSession = CharacterStats:GetStat('lowestHealthThisSession')
  local currentCloseEscapes = CharacterStats:GetStat('closeEscapes')

  -- Return early if any stats are nil (not initialized yet)
  if not currentLowestHealth or not currentLowestHealthThisLevel or not currentLowestHealthThisSession or not currentCloseEscapes then return end

  -- Handle pause resumption for lowestHealth
  if pvpPauseLowestHealth then
    -- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or you somehow died
    if not GLOBAL_SETTINGS.isDueling and (healthPercent >= currentLowestHealth or health == 0) then
      pvpPauseLowestHealth = false
      print(
        '|cfff44336[UHC]|r |cfff0f000Health has returned above your previous lowest health stat. Lowest Health tracking has resumed!|r'
      )
    else
    -- Skip lowestHealth tracking while paused
    end
  end

  -- Handle pause resumption for lowestHealthThisLevel
  if pvpPauseLowestHealthThisLevel then
    -- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or you somehow died
    if not GLOBAL_SETTINGS.isDueling and (healthPercent >= currentLowestHealthThisLevel or health == 0) then
      pvpPauseLowestHealthThisLevel = false
      print(
        '|cfff44336[UHC]|r |cfff0f000Health has returned above your previous lowest health this level stat. This Level Health tracking has resumed!|r'
      )
    else
    -- Skip lowestHealthThisLevel tracking while paused
    end
  end

  -- Handle pause resumption for lowestHealthThisSession (special logic)
  if pvpPauseLowestHealthThisSession then
    -- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or you somehow died
    if not GLOBAL_SETTINGS.isDueling and (healthPercent >= currentLowestHealthThisSession or health == 0) then
      pvpPauseLowestHealthThisSession = false
      print(
        '|cfff44336[UHC]|r |cfff0f000Health has returned above your previous lowest health this session stat. This Session Health tracking has resumed!|r'
      )
    else
    -- Skip lowestHealthThisSession tracking while paused
    end
  end

  -- Handle pause resumption for close escape (special logic)
  if pvpPauseLowestHealthCloseEscape then
    -- End pause after 1) not dueling, 2) HP% is above close escape percentage
    if not GLOBAL_SETTINGS.isDueling and (healthPercent > closeEscapeHealthPercent or health == 0) then
      pvpPauseLowestHealthCloseEscape = false
      --print(
      --  '|cfff44336[UHC]|r |cfff0f000Health has returned above the close escape threshold.  This session close escape tracking has resumed!|r'
      --)
    else
    -- Skip closeEscape tracking while paused
    end
  end

  -- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of combat
  if inCombat then
    combatLowest = math.min(healthPercent, combatLowest or 100)
    return
  end

  -- Track lowestHealth (only if not paused)
  if event == 'UNIT_HEALTH' and not inCombat and not pvpPauseLowestHealth and healthPercent < currentLowestHealth then
    CharacterStats:UpdateStat('lowestHealth', healthPercent)
  end

  -- Track This Level lowest health (only if not paused)
  if event == 'UNIT_HEALTH' and not inCombat and not pvpPauseLowestHealthThisLevel and healthPercent < currentLowestHealthThisLevel then
    CharacterStats:UpdateStat('lowestHealthThisLevel', healthPercent)
  end

  -- Track This Session lowest health (only if not paused)
  if event == 'UNIT_HEALTH' and not inCombat and not pvpPauseLowestHealthThisSession and healthPercent < currentLowestHealthThisSession then
    CharacterStats:UpdateStat('lowestHealthThisSession', healthPercent)
  end

  -- Track Close Escapes
  if event == 'UNIT_HEALTH' and not inCombat and not pvpPauseLowestHealthCloseEscape and healthPercent < closeEscapeHealthPercent then
    -- lets pause until we get above the thrshold again
    pvpPauseLowestHealthCloseEscape = true
  end

end

local frame = CreateFrame('Frame')
frame:RegisterEvent('UNIT_HEALTH')
frame:RegisterEvent('DUEL_REQUESTED') -- Fired when another player initiates a duel against you. Intentionally ignoring DUEL_TO_THE_DEATH_REQUESTED as that is full combat and should count
frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED') -- SpellID 7266 is Duel. Fired when player initiates the duel
frame:RegisterEvent('DUEL_FINISHED') -- Fired every time a duel is over or cancelled
frame:RegisterEvent('PLAYER_REGEN_DISABLED') -- In combat, if we want it
frame:RegisterEvent('PLAYER_REGEN_ENABLED') -- Out of combat, if we want it
frame:RegisterEvent('PLAYER_LEVEL_UP') -- Reset This Level stats when leveling up
frame:RegisterEvent('PLAYER_LOGIN') -- Reset This Session stats when logging in
frame:SetScript('OnEvent', function(self, event, arg1, arg2, arg3)
  if event == 'UNIT_HEALTH' and arg1 ~= 'player' then return end

  if event == 'DUEL_REQUESTED' or (event == 'UNIT_SPELLCAST_SUCCEEDED' and arg1 == 'player' and arg3 == 7266) then
    pvpPauseLowestHealth = true
    pvpPauseLowestHealthThisLevel = true
    pvpPauseLowestHealthThisSession = true
    pvpPauseLowestHealthCloseEscape = true
    GLOBAL_SETTINGS.isDueling = true
    print(
      '|cfff44336[UHC]|r |cfff0f000A duel has been initiated. All Lowest Health tracking is paused.|r'
    )
  elseif event == 'DUEL_FINISHED' then
    GLOBAL_SETTINGS.isDueling = false
    print(
      '|cfff44336[UHC]|r |cfff0f000Dueling has finished. Each health tracking will resume when your health returns above its respective previous lowest value.|r'
    )
  elseif event == 'PLAYER_LEVEL_UP' then
    -- Reset This Level stats when leveling up
    CharacterStats:ResetLowestHealthThisLevel()
    print('|cfff44336[UHC]|r |cfff0f000Level up! This Level lowest health has been reset.|r')
  elseif event == 'PLAYER_LOGIN' then
    -- Reset This Session stats when logging in
    CharacterStats:ResetLowestHealthThisSession()
    print('|cfff44336[UHC]|r |cfff0f000New session! This Session lowest health has been reset.|r')
  elseif event == 'PLAYER_REGEN_ENABLED' then
    leftCombat()
    return
  end

  local feigning = IsFeigningDeath()

  if feigning then return end

  TrackLowestHealth(event)
end)
