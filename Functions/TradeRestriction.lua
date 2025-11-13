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
  local normalizedTarget = NormalizeName(name)
  if not normalizedTarget then
    return false
  end
  
  -- Prefer cached roster if available
  if _G.UHC_GuildRoster and _G.UHC_GuildRoster.isReady and _G.UHC_GuildRoster.namesSet then
    return _G.UHC_GuildRoster.namesSet[normalizedTarget] == true
  end

  -- Kick off a roster request in case cache isn't ready yet
  if _G.UHC_RequestGuildRoster then _G.UHC_RequestGuildRoster() end

  local numGuildMembers = GetNumGuildMembers and GetNumGuildMembers() or 0
  for j = 1, numGuildMembers do
    local guildName = GetGuildRosterInfo(j)
    local normalizedGuildName = NormalizeName(guildName)
    if normalizedGuildName and normalizedGuildName == normalizedTarget then
      return true
    end
  end
  return false
end

-- Guild Found handshake (silent addon messages during trade)
local ADDON_PREFIX_GF = 'UHC_GF'
local verifiedPartners = {}

local function MarkPartnerVerifiedGF(name)
  local normalized = NormalizeName(name)
  if not normalized then return end
  verifiedPartners[normalized] = { gf = true, ts = GetTime() }
end

local function IsPartnerVerifiedGF(name)
  local normalized = NormalizeName(name)
  if not normalized then return false end
  local entry = verifiedPartners[normalized]
  if not entry then return false end
  -- consider verification fresh for 60 seconds
  return entry.gf and (GetTime() - (entry.ts or 0) < 60)
end

-- Trade overlay to block interaction while GF checks run
local tradeOverlay = nil

local function EnsureTradeOverlay()
  if tradeOverlay and tradeOverlay:GetParent() == TradeFrame then return tradeOverlay end
  if not TradeFrame then return nil end
  tradeOverlay = CreateFrame('Frame', 'UHCTradeOverlay', TradeFrame)
  tradeOverlay:SetAllPoints(TradeFrame)
  tradeOverlay:SetFrameStrata(TradeFrame:GetFrameStrata())
  tradeOverlay:SetFrameLevel(TradeFrame:GetFrameLevel() + 100)
  tradeOverlay:EnableMouse(true) -- capture clicks
  tradeOverlay:EnableMouseWheel(true)
  tradeOverlay:Hide()

  -- dim background
  local bg = tradeOverlay:CreateTexture(nil, 'ARTWORK')
  bg:SetAllPoints(tradeOverlay)
  bg:SetColorTexture(0, 0, 0, 0.4)
  tradeOverlay.bg = bg

  -- status text
  local text = tradeOverlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
  text:SetPoint('CENTER')
  text:SetText('Validating Guild Found...')
  tradeOverlay.text = text

  return tradeOverlay
end

local function ShowTradeOverlay(message)
  local overlay = EnsureTradeOverlay()
  if not overlay then return end
  if message then overlay.text:SetText(message) end
  overlay:Show()
end

local function HideTradeOverlay()
  if tradeOverlay then
    tradeOverlay:Hide()
  end
end

local function SendGuildFoundPing(targetName)
  if not targetName then return end
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX_GF, 'PING', 'WHISPER', targetName)
  end
end

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
  C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX_GF)
end

local frame = CreateFrame('Frame')

frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('TRADE_CLOSED')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')
frame:RegisterEvent('MAIL_INBOX_UPDATE')
frame:RegisterEvent('CHAT_MSG_ADDON')

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

    if inGuildFound then
      print('|cffff0000[ULTRA]|r|cffffff00 Trade with ' .. targetName .. ' in Guild Found mode.|r')
      -- First, enforce guild membership
      if not IsAllowedByGuildList(targetName) then
        print(
          '|cffff0000[ULTRA]|r|cffffff00 Trade with ' .. targetName .. ' cancelled - not in my guild.|r'
        )
        CancelTrade()
        return
      end

      -- If already verified via addon handshake, allow
      if IsPartnerVerifiedGF(targetName) then
        HideTradeOverlay()
        return
      end

      -- Temporarily overlay to block interaction while we verify (up to 1s)
      ShowTradeOverlay('Validating Guild Found...')

      -- Start handshake and cancel if no ACK within timeout
      SendGuildFoundPing(targetName)
      local nameForTimer = targetName
      C_Timer.After(1, function()
        if not IsPartnerVerifiedGF(nameForTimer) then
          print(
            '|cffff0000[ULTRA]|r|cffffff00 Trade with ' .. nameForTimer .. ' cancelled - other player not using Guild Found.|r'
          )
          CancelTrade()
        end
      end)
      return
    elseif inGroupFound then
      local allowed = IsAllowedByGroupList(targetName)
      if not allowed then
        print(
          '|cffff0000[ULTRA]|r|cffffff00 Trade with ' .. targetName .. ' cancelled - not on my Group Found list.|r'
        )
        CancelTrade()
      end
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
  elseif event == 'CHAT_MSG_ADDON' then
    local prefix, msg, channel, sender = ...
    if prefix ~= ADDON_PREFIX_GF then return end
    if not sender or sender == '' then return end

    -- Only care about Guild Found mode handshakes
    if msg == 'PING' then
      -- Respond only if we are in Guild Found mode
      if inGuildFound and C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(ADDON_PREFIX_GF, 'ACK', 'WHISPER', sender)
        -- Their PING implies they are in GF; mark them as verified
        MarkPartnerVerifiedGF(sender)
        HideTradeOverlay()
      end
    elseif msg == 'ACK' then
      -- They acknowledged our ping; mark verified
      MarkPartnerVerifiedGF(sender)
      HideTradeOverlay()
    end
  elseif event == 'TRADE_CLOSED' then
    -- Ensure buttons are restored if trade ends while blocked
    HideTradeOverlay()
  end
end)
