-- Duel Tracker
-- Handles tracking of Duels won and lost 

-- Get localized duel strings
local GLOBAL_DUEL_WINNER_KNOCKOUT = getglobal("DUEL_WINNER_KNOCKOUT")
local GLOBAL_DUEL_WINNER_RETREAT = getglobal("DUEL_WINNER_RETREAT")

-- Build pattern matching regex for the localized string
-- I've only tested this with the english client
local DUEL_WIN_PATTERN = GLOBAL_DUEL_WINNER_KNOCKOUT:gsub("%%1%$s", "(.+)"):gsub("%%2%$s", "(.+)")
-- pattern after sub = (.+) has defeated (.+) in a duel for the english client
local DUEL_WIN_RETREAT_PATTERN = GLOBAL_DUEL_WINNER_RETREAT:gsub("%%1%$s", "(.+)"):gsub("%%2%$s", "(.+)")
-- pattern after sub = (.+) has fled from (.+) in a duel for the english client

-- Parse duel message and update stats accordingly
function DuelTracker(msg)

  local myName = UnitName("player")

  -- regex parse out the winner and loser of a standard duel
  local winner, loser = msg:match(DUEL_WIN_PATTERN)
  -- regex parse out the winner and loser if one of the players ran away
  local retreatLoser, retreatWinner = msg:match(DUEL_WIN_RETREAT_PATTERN)

  local duelsWon = CharacterStats:GetStat('duelsWon') or 0
  local duelsLost = CharacterStats:GetStat('duelsLost') or 0
  local ourDuelSeen = false

  if winner and loser then
    if winner == myName then
      ourDuelSeen = true
      duelsWon = duelsWon + 1
      CharacterStats:UpdateStat('duelsWon', duelsWon)
    elseif loser == myName then
      ourDuelSeen = true
      duelsLost = duelsLost + 1
      CharacterStats:UpdateStat('duelsLost', duelsLost)
    end
  elseif retreatLoser and retreatWinner then
    if retreatLoser == myName then
      ourDuelSeen = true
      duelsLost = duelsLost + 1
      CharacterStats:UpdateStat('duelsLost', duelsLost)
    elseif retreatWinner == myName then
      ourDuelSeen = true
      duelsWon = duelsWon + 1
      CharacterStats:UpdateStat('duelsWon', duelsWon)
    end
  end

  -- only update if the message matches a duel where we participated
  if ourDuelSeen then
    if (duelsWon + duelsLost > 0) then
      local duelsWinPercent = (duelsWon/(duelsWon + duelsLost)) * 100
      CharacterStats:UpdateStat('duelsWinPercent', duelsWinPercent)
      CharacterStats:UpdateStat('duelsTotal', (duelsWon + duelsLost))
    end
  end
end
