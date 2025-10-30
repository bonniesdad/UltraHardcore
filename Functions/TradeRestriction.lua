-- Helper: normalize name to character name without realm and lowercase
function NormalizeName(name)
  if not name then
    return nil
  end
  local short = name
  local dashPos = string.find(short, '-')
  if dashPos then
    short = string.sub(short, 1, dashPos - 1)
  end
  return string.lower(short)
end

-- Helper: check if a name is allowed by the saved group list
function IsAllowedByGroupList(name)
  local normalized = NormalizeName(name)
  if not normalized then
    return false
  end
  local list = (GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupFoundNames) or {}
  for _, allowed in ipairs(list) do
    if NormalizeName(allowed) == normalized then
      return true
    end
  end
  return false
end

function IsAllowedByGuildList(name)
  local numGuildMembers = GetNumGuildMembers()
  for j = 1, numGuildMembers do
    local name = GetGuildRosterInfo(j)
    if name and string.find(name, targetName) then
      allowed = true
      break
    end
  end

  return false
end

local frame = CreateFrame('Frame')

frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')
frame:RegisterEvent('MAIL_INBOX_UPDATE')

frame:SetScript('OnEvent', function(self, event, ...)
  local inGuildFound = GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound
  local inGroupFound = GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound

  if not (inGuildFound or inGroupFound) then return end

  if event == 'MAIL_INBOX_UPDATE' then
    for i = GetInboxNumItems(), 1, -1 do
      local packageIcon,
        stationeryIcon,
        sender,
        subject,
        money,
        CODAmount,
        daysLeft,
        hasItem,
        wasRead,
        wasReturned,
        textCreated,
        canReply,
        isGM
      = GetInboxHeaderInfo(i)

      if sender and not isGM then
        local allowed = false
        if inGuildFound then
          allowed = IsAllowedByGuildList(sender)
        elseif inGroupFound then
          allowed = IsAllowedByGroupList(sender)
        end

        if not allowed then
          local reason = inGuildFound and 'not in my guild' or 'not on my Group Found list'
          print(
            '|cffff0000[ULTRA]|r|cffffff00 Mail from ' .. sender .. ' blocked - ' .. reason .. '.|r'
          )
          ReturnInboxItem(i)
        end
      end
    end
  elseif event == 'TRADE_SHOW' then
    -- Get the trade target name using the correct Classic WoW API
    local targetName = GetUnitName('npc', true)
    if not targetName then
      return -- No trade target, allow
    end

    local allowed = false
    if inGuildFound then
      local numGuildMembers = GetNumGuildMembers()
      for j = 1, numGuildMembers do
        local name = GetGuildRosterInfo(j)
        if name and string.find(name, targetName) then
          allowed = true
          break
        end
      end
    elseif inGroupFound then
      allowed = IsAllowedByGroupList(targetName)
    end

    if not allowed then
      local reason = inGuildFound and 'not in my guild' or 'not on my Group Found list'
      print(
        '|cffff0000[ULTRA]|r|cffffff00 Trade with ' .. targetName .. ' cancelled - ' .. reason .. '.|r'
      )
      CancelTrade()
    end
  elseif event == 'AUCTION_HOUSE_SHOW' then
    local modeLabel = inGuildFound and 'Guild Found' or 'Group Found'
    print(
      '|cffff0000[ULTRA]|r|cffffff00 Auction House blocked - ' .. modeLabel .. ' mode enabled.|r'
    )
    C_Timer.After(0.1, function()
      if CloseAuctionHouse then
        CloseAuctionHouse()
      end
    end)
  end
end)
