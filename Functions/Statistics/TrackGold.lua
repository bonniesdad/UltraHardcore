-- Tracks money gained/spent via PLAYER_MONEY (stored as COPPER).

local frame = CreateFrame('Frame')

local lastMoney = nil -- copper

local function InitBaseline()
  if GetMoney then
    lastMoney = GetMoney() or 0
  else
    lastMoney = 0
  end
end

local function AddCopperStat(statKey, amount)
  if not CharacterStats or not CharacterStats.GetStat or not CharacterStats.UpdateStat then return end
  local current = CharacterStats:GetStat(statKey) or 0
  CharacterStats:UpdateStat(statKey, current + (amount or 0))
end

local function OnMoneyChanged()
  if not GetMoney then return end

  local current = GetMoney() or 0
  if lastMoney == nil then
    lastMoney = current
    return
  end

  local delta = current - lastMoney
  if delta == 0 then return end

  if delta > 0 then
    AddCopperStat('goldGained', delta)
  else
    local spent = -delta
    AddCopperStat('goldSpent', spent)
  end

  lastMoney = current

  if _G.UpdateStatistics then
    _G.UpdateStatistics()
  end
end

frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_MONEY')
frame:RegisterEvent('ADDON_LOADED')

frame:SetScript('OnEvent', function(_, event, arg1)
  if event == 'PLAYER_LOGIN' then
    InitBaseline()
    return
  end

  if event == 'ADDON_LOADED' and arg1 == 'UltraHardcore' then
    if C_Timer and C_Timer.After then
      C_Timer.After(1.0, InitBaseline) -- helps after /reload
    else
      InitBaseline()
    end
    return
  end

  if event == 'PLAYER_MONEY' then
    OnMoneyChanged()
  end
end)


