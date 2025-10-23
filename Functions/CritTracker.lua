-- Critical Hit Tracker
-- Handles critical hit tracking, effects, and statistics

-- Initialize global table
CritTracker = {}

-- Function to play random crit sound
local function PlayRandomCritSound()
  local critSoundNumber = math.random(1, 4)
  local soundFile =
    'Interface\\AddOns\\UltraHardcore\\Sounds\\xar-crit' .. critSoundNumber .. '.mp3'
  PlaySoundFile(soundFile, 'Master')
end

-- Handle critical hit effects and tracking
function CritTracker.HandleCriticalHit(subEvent, sourceGUID, destGUID, amount)
  if not GLOBAL_SETTINGS.showCritScreenMoveEffect then return end

  if subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE' then
    if destGUID == UnitGUID('player') then
      local critical = select(18, CombatLogGetCurrentEventInfo())
      if critical then
        RotateScreenEffect()
      end
    end
  end
end

-- Track critical hit statistics
function CritTracker.TrackCriticalHit(subEvent, sourceGUID, amount)
  if subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' then
    local critical

    if subEvent == 'SWING_DAMAGE' then
      -- For swing damage, critical is at position 18
      critical = select(18, CombatLogGetCurrentEventInfo())
    elseif subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' then
      -- For spell damage and ranged damage, critical is at position 21
      critical = select(21, CombatLogGetCurrentEventInfo())
    end

    if critical then
      -- Only trigger crit effects when PLAYER crits an enemy
      if sourceGUID == UnitGUID('player') then
        local currentHighestCrit = CharacterStats:GetStat('highestCritValue') or 0
        if amount > currentHighestCrit then
          print('|cFFFF0000[UHC]|r Highest crit value updated to: ' .. amount .. '|r')
          CharacterStats:UpdateStat('highestCritValue', amount)
          if GLOBAL_SETTINGS.newHighCritAppreciationSoundbite then
            PlayRandomCritSound()
          end
        end
      end
    end
  end
end
