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

  -- Request guild roster information from the server
  GuildRoster()

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
  text:SetText('Validating Guild Found and Status...')
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

local currentTradeValidation = nil

local function PrintRestrictionMessage(message)
  if not message then return end
  print('|cffff0000[ULTRA]|r|cffffff00 ' .. message .. '|r')
end

local function ResetTradeValidation()
  currentTradeValidation = nil
  HideTradeOverlay()
end

local function NormalizeTradeTarget(name)
  return NormalizeName(name or '')
end

local function IsCurrentTradeTarget(name)
  if not currentTradeValidation then return false end
  return NormalizeTradeTarget(name) == currentTradeValidation.target
end

local function BuildOverlayMessage()
  if not currentTradeValidation then return nil end
  local pending = {}
  if not currentTradeValidation.gfVerified then
    table.insert(pending, 'Guild Found handshake')
  end
  if currentTradeValidation.requiresTamper and not currentTradeValidation.tamperVerified then
    table.insert(pending, 'Tamper status')
  end
  if #pending == 0 then
    return nil
  end
  return 'Validating:\n\n' .. table.concat(pending, '\n\n')
end

local function UpdateTradeOverlayStatus()
  local message = BuildOverlayMessage()
  if message then
    ShowTradeOverlay(message)
  else
    HideTradeOverlay()
  end
end

local function EnsureTradeValidationState(targetName, requiresGuildVerification, requiresTamperVerification)
  currentTradeValidation = {
    target = NormalizeTradeTarget(targetName),
    gfVerified = not requiresGuildVerification,
    tamperVerified = not requiresTamperVerification,
    requiresTamper = not not requiresTamperVerification,
    cancelled = false,
  }
  UpdateTradeOverlayStatus()
  return currentTradeValidation
end

local function CompleteTradeValidationIfReady()
  if not currentTradeValidation then
    return
  end

  local tamperSatisfied = currentTradeValidation.requiresTamper
      and currentTradeValidation.tamperVerified
    or not currentTradeValidation.requiresTamper

  if currentTradeValidation.gfVerified and tamperSatisfied then
    currentTradeValidation.ready = true
    HideTradeOverlay()
  end
end

local function CancelTradeForReason(message)
  if currentTradeValidation and currentTradeValidation.cancelled then
    return
  end
  if message then
    PrintRestrictionMessage(message)
  end
  CancelTrade()
  if currentTradeValidation then
    currentTradeValidation.cancelled = true
  end
  ResetTradeValidation()
end

local function MarkGuildVerificationComplete(name)
  if not IsCurrentTradeTarget(name) or not currentTradeValidation then
    return
  end
  currentTradeValidation.gfVerified = true
  UpdateTradeOverlayStatus()
  CompleteTradeValidationIfReady()
end

local function StartTamperVerification(targetName)
  if not currentTradeValidation or not currentTradeValidation.requiresTamper then
    return
  end

  if not PlayerComm or not PlayerComm.RequestTamperStatus then
    CancelTradeForReason(
      'Trade with ' .. targetName .. ' cancelled - tamper verification unavailable.'
    )
    return
  end

  local requestAccepted = PlayerComm:RequestTamperStatus(targetName, function(isTampered, playerName, success)
    if not IsCurrentTradeTarget(playerName) or not currentTradeValidation then
      return
    end

    if not success then
      CancelTradeForReason(
        'Trade with ' .. targetName .. ' cancelled - tamper status verification timed out.'
      )
      return
    end

    if isTampered then
      CancelTradeForReason(
        'Trade with ' .. targetName .. ' cancelled - player failed tamper verification.'
      )
      return
    end

    currentTradeValidation.tamperVerified = true
    UpdateTradeOverlayStatus()
    CompleteTradeValidationIfReady()
  end)

  if not requestAccepted then
    CancelTradeForReason(
      'Trade with ' .. targetName .. ' cancelled - unable to request tamper verification.'
    )
    return
  end

  UpdateTradeOverlayStatus()
end

local function SendGuildFoundPing(targetName)
  if not targetName then return false end
  if PlayerComm and PlayerComm.SendGuildFoundHandshake then
    return PlayerComm:SendGuildFoundHandshake('PING', targetName)
  end
  return false
end

local frame = CreateFrame('Frame')

frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('TRADE_CLOSED')
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
    ResetTradeValidation()

    -- Get the trade target name using the correct Classic WoW API
    local targetName = GetUnitName('npc', true)
    if not targetName then
      return -- No trade target, allow
    end

    if inGuildFound then
      PrintRestrictionMessage('Trade with ' .. targetName .. ' in Guild Found mode.')
      if not IsAllowedByGuildList(targetName) then
        CancelTradeForReason('Trade with ' .. targetName .. ' cancelled - not in my guild.')
        return
      end
    elseif inGroupFound then
      local allowed = IsAllowedByGroupList(targetName)
      if not allowed then
        CancelTradeForReason(
          'Trade with ' .. targetName .. ' cancelled - not on my Group Found list.'
        )
        return
      end
    end

    EnsureTradeValidationState(targetName, inGuildFound, inGuildFound or inGroupFound)
    StartTamperVerification(targetName)

    if inGuildFound then
      if IsPartnerVerifiedGF(targetName) then
        MarkGuildVerificationComplete(targetName)
      else
        UpdateTradeOverlayStatus()
        local pingSent = SendGuildFoundPing(targetName)
        if not pingSent then
          CancelTradeForReason(
            'Trade with ' .. targetName .. ' cancelled - unable to initiate Guild Found verification.'
          )
          return
        end
        local normalizedName = NormalizeTradeTarget(targetName)
        C_Timer.After(1, function()
          if
            currentTradeValidation
            and currentTradeValidation.target == normalizedName
            and not currentTradeValidation.gfVerified
          then
            CancelTradeForReason(
              'Trade with ' .. targetName .. ' cancelled - other player not using Guild Found.'
            )
          end
        end)
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
  elseif event == 'TRADE_CLOSED' then
    -- Ensure buttons are restored if trade ends while blocked
    ResetTradeValidation()
  end
end)

local function HandleGuildFoundHandshake(payload)
  if not payload or not payload.action or not payload.sender then
    return
  end

  local sender = payload.sender
  local action = payload.action
  local inGuildFound = GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound

  if action == 'PING' then
    if inGuildFound and PlayerComm and PlayerComm.SendGuildFoundHandshake then
      PlayerComm:SendGuildFoundHandshake('ACK', sender)
      MarkPartnerVerifiedGF(sender)
      MarkGuildVerificationComplete(sender)
    end
  elseif action == 'ACK' then
    MarkPartnerVerifiedGF(sender)
    MarkGuildVerificationComplete(sender)
  end
end

local function RegisterGuildFoundHandlerWithRetry(attempt)
  if PlayerComm and PlayerComm.RegisterGuildFoundHandler then
    PlayerComm:RegisterGuildFoundHandler(HandleGuildFoundHandshake)
    return
  end

  local nextAttempt = (attempt or 0) + 1
  if nextAttempt <= 5 then
    C_Timer.After(1, function()
      RegisterGuildFoundHandlerWithRetry(nextAttempt)
    end)
  end
end

RegisterGuildFoundHandlerWithRetry(0)
