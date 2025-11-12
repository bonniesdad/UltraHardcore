-- Addon communication prefix for UHC verification
local ADDON_PREFIX = 'UHC_VERIFY'

local partyVerificationData = {}
local verificationRequestTime = 0
local isWaitingForResponses = false
local lastPartyMembers = {}
local lastAutoVerifyTime = 0
local AUTO_VERIFY_THROTTLE = 5
local wasInGroup = false

local yellowTextColour = '|cffffd000'
local greenTextColour = '|cff33F24C'
local redTextColour = '|cffFF4444'

-- Helper to convert member list to normalized set
local function BuildMemberSet(members)
  local memberSet = {}
  for _, name in ipairs(members) do
    local normalized = NormalizeName(name)
    if normalized then
      memberSet[normalized] = true
    end
  end
  return memberSet
end

-- Function to get current party member names (only online members)
local function GetCurrentPartyMembers()
  local members = {}
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
      if name and online then
        table.insert(members, name)
      end
    end
  elseif IsInGroup() then
    --[[ Because GetNumGroupMembers() includes the player as well, party units are party1-party4 (not including yourself) ]]--
    local numMembers = GetNumGroupMembers()
    for i = 1, numMembers - 1 do  -- -1 because the count includes yourself but units don't
      local unit = 'party' .. i
      local name = UnitName(unit)
      local isOnline = UnitIsConnected(unit)
      if name and isOnline then
        table.insert(members, name)
      end
    end
  end
  return members
end

local function DeterminePresetLevel(settings)
  if not settings then
    return nil
  end

  local sections = GetPresetSections and GetPresetSections('simple', false) or {}
  
  local function allTrueForSettings(settingsList)
    for _, settingName in ipairs(settingsList or {}) do
      if not settings[settingName] then
        return false
      end
    end
    return true
  end
  
  local lite = sections[1] and sections[1].settings or {}
  local recommended = sections[2] and sections[2].settings or {}
  local extreme = sections[3] and sections[3].settings or {}

  local liteOk = allTrueForSettings(lite)
  local recOk = liteOk and allTrueForSettings(recommended)
  local extOk = recOk and allTrueForSettings(extreme)

  if extOk then
    return 'Extreme'
  elseif recOk then
    return 'Recommended'
  elseif liteOk then
    return 'Lite'
  else
    return nil
  end
end

-- Function to get the legitimacy status based on preset level and XP for the current player
local function GetPlayerLegitimacyStatus(presetLevel)
  local xpWithoutAddon = 1
  if CharacterStats and CharacterStats.ReportXPWithoutAddon then
    local reported = CharacterStats:ReportXPWithoutAddon()
    if type(reported) == 'number' then
      xpWithoutAddon = reported
    end
  end

  -- Get total XP gained with addon
  local xpWithAddon = 0
  if CharacterStats and CharacterStats.GetStat then
    xpWithAddon = CharacterStats:GetStat('xpGainedWithAddon') or 0
  end

  -- Check if character has any UHC settings enabled
  local hasUHCSettings = false
  local sections = GetPresetSections and GetPresetSections('simple', false) or {}
  for _, section in ipairs(sections) do
    for _, settingName in ipairs(section.settings or {}) do
      if GLOBAL_SETTINGS and GLOBAL_SETTINGS[settingName] then
        hasUHCSettings = true
        break
      end
    end
    if hasUHCSettings then break end
  end

  -- Level 1 character with no XP gained at all should be considered verified only if they have UHC settings enabled
  local playerLevel = UnitLevel('player') or 1
  local isLevelOneWithNoXP = (playerLevel == 1 and xpWithAddon == 0 and xpWithoutAddon == 0 and hasUHCSettings)

  if presetLevel and (xpWithoutAddon == 0 or isLevelOneWithNoXP) then
    return true, presetLevel
  else
    return false, presetLevel
  end
end

-- Helper to get the appropriate chat channel
local function GetGroupChannel()
  return IsInRaid() and 'RAID' or 'PARTY'
end

-- This sends a verification request to party members
local function SendVerificationRequest()
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX, 'REQUEST', GetGroupChannel())
  end
end

local function SendVerificationResponse()
  local presetLevel = DeterminePresetLevel(GLOBAL_SETTINGS)
  local isLegit, presetName = GetPlayerLegitimacyStatus(presetLevel)
  
  -- Build response message: "PRESET:LEGIT" (e.g., "Extreme:1" or "Lite:0" or "None:0")
  local presetStr = presetName or 'None'
  local legitStr = isLegit and '1' or '0'
  local message = presetStr .. ':' .. legitStr
  
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, GetGroupChannel())
  end
end

-- Function to print verification status for a single player's data
local function PrintVerificationStatus(name, data)
  local preset = data.preset or 'None'
  local isLegit = data.legit == true
  local isOk = '|TInterface\\AddOns\\UltraHardcore\\Textures\\01_bonnie_light.png:0|t'
  local isTainted = '|TInterface\\AddOns\\UltraHardcore\\Textures\\02_bonnie_recommended.png:0|t'
  local isFailed = '|TInterface\\AddOns\\UltraHardcore\\Textures\\03_bonnie_extreme.png:0|t'
  
  if isLegit then
    print(yellowTextColour .. '[UHC]|r ' .. greenTextColour .. '[' .. isOk .. ' - OK]|r ' .. name .. greenTextColour .. ' - Certified ' .. preset .. ' Ultra|r')
  elseif preset ~= 'None' then
    print(yellowTextColour .. '[UHC]|r ' .. redTextColour .. '[' .. isTainted .. ' - Tainted]|r ' .. name .. yellowTextColour .. ' - ' .. preset .. ' settings but not legitimate|r')
  else
    print(yellowTextColour .. '[UHC]|r ' .. redTextColour .. '[' .. isFailed .. ' - Failed]|r ' .. name .. redTextColour .. ' - Not using UHC addon or not using a preset|r')
  end
end

local function DisplayVerificationResults()
  local playerName = UnitName('player')
  
  print(yellowTextColour .. '[UHC]|r Party Member Verification Results:')
  print(yellowTextColour .. '[UHC]|r ' .. string.rep('-', 50))
  
  local hasResponses = false
  for name, data in pairs(partyVerificationData) do
    hasResponses = true
    PrintVerificationStatus(name, data)
  end

  -- Check for members who didn't respond
  local allMembers = GetCurrentPartyMembers()
  local nonResponders = {}
  
  for _, name in ipairs(allMembers) do
    local normalizedName = NormalizeName(name)
    if normalizedName and normalizedName ~= playerName and not partyVerificationData[normalizedName] then
      table.insert(nonResponders, normalizedName)
    end
  end
  
  if #nonResponders > 0 then
    print(yellowTextColour .. '[UHC]|r')
    print(yellowTextColour .. '[UHC]|r |cffFFAA00[!]|r No response from: ' .. table.concat(nonResponders, ', '))
    print(yellowTextColour .. '[UHC]|r These members may not have the UHC addon installed.')
  end
  
  if not hasResponses and #nonResponders == 0 then
    print(yellowTextColour .. '[UHC]|r')
    print(yellowTextColour .. '[UHC]|r Note: No other party members detected or responded.')
  end
end

-- Function to display verification result for a specific player
local function DisplaySinglePlayerVerification(targetName)
  local data = partyVerificationData[targetName]
  
  if data then
    print(yellowTextColour .. '[UHC]|r Verification Result for ' .. targetName .. ':')
    print(yellowTextColour .. '[UHC]|r ' .. string.rep('-', 50))
    PrintVerificationStatus(targetName, data)
  else
    print(yellowTextColour .. '[UHC]|r' .. redTextColour .. '[!]|r No response from ' .. targetName .. '|r')
    print(yellowTextColour .. '[UHC]|r They may not have the UHC addon installed or are not in your group.')
  end
end

-- Helper to start verification process
local function StartVerification(targetPlayer)
  verificationRequestTime = GetTime()
  isWaitingForResponses = true
  SendVerificationRequest()
  
  if targetPlayer then
    print(yellowTextColour .. '[UHC]|r Requesting verification from ' .. targetPlayer .. '...')
    C_Timer.After(2, function()
      isWaitingForResponses = false
      DisplaySinglePlayerVerification(targetPlayer)
    end)
  else
    print(yellowTextColour .. '[UHC]|r Requesting verification from party members...')
    C_Timer.After(2, function()
      isWaitingForResponses = false
      DisplayVerificationResults()
    end)
  end
end

-- Function to verify a specific player by name
local function VerifySpecificPlayer(playerName)
  local normalizedTarget = NormalizeName(playerName)
  if not normalizedTarget then
    print(yellowTextColour .. '[UHC]|r' .. redTextColour .. ' Invalid player name.|r')
    return
  end

  local allMembers = GetCurrentPartyMembers()
  local isInParty = false
  for _, name in ipairs(allMembers) do
    local normalizedMember = NormalizeName(name)
    if normalizedMember == normalizedTarget then
      isInParty = true
      break
    end
  end

  if not isInParty then
    print(yellowTextColour .. '[UHC]|r ' .. normalizedTarget .. redTextColour .. ' is not in your party or raid.|r')
    return
  end

  partyVerificationData[normalizedTarget] = nil
  StartVerification(normalizedTarget)
end


function VerifyUhcPartyMembers(args)
  if not IsInGroup() then
    print(yellowTextColour .. '[UHC]|r You are not in a party or raid.')
    return
  end

  if args and args ~= '' then
    VerifySpecificPlayer(args)
    return
  end

  partyVerificationData = {}
  StartVerification()
end

-- Function to detect new party members and auto-verify
local function CheckForNewPartyMembers()
  local currentlyInGroup = IsInGroup()
  
  if not currentlyInGroup then
    lastPartyMembers = {}
    wasInGroup = false
    return
  end

  local currentMembers = GetCurrentPartyMembers()
  local currentMemberSet = BuildMemberSet(currentMembers)
  local justJoinedGroup = not wasInGroup and currentlyInGroup
  
  -- Find members who are in current party but weren't in last party
  local newMembers = {}
  if next(lastPartyMembers) ~= nil then
    for memberName, _ in pairs(currentMemberSet) do
      if not lastPartyMembers[memberName] then
        table.insert(newMembers, memberName)
      end
    end
  end
  
  -- Update state
  lastPartyMembers = currentMemberSet
  wasInGroup = currentlyInGroup

  -- Determine if verification is needed
  local shouldVerify = #newMembers > 0 or (justJoinedGroup and next(currentMemberSet) ~= nil)
  
  if shouldVerify then
    local currentTime = GetTime()
    if currentTime - lastAutoVerifyTime >= AUTO_VERIFY_THROTTLE then
      lastAutoVerifyTime = currentTime
      
      -- Display appropriate notification
      if justJoinedGroup then
        print(yellowTextColour .. '[UHC]|r Joined party.' .. yellowTextColour .. ' Verifying members...|r')
      elseif #newMembers == 1 then
        print(yellowTextColour .. '[UHC]|r ' .. newMembers[1] .. ' joined the party.' .. yellowTextColour .. ' Verifying...|r')
      else
        print(yellowTextColour .. '[UHC]|r ' .. #newMembers .. ' new members joined the party.' .. yellowTextColour .. ' Verifying...|r')
      end

      C_Timer.After(0.5, function()
        VerifyUhcPartyMembers()
      end)
    end
  end
end

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
  C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
end

-- Initialize the party state immediately
local function InitializePartyState()
  wasInGroup = IsInGroup()
  if wasInGroup then
    local members = GetCurrentPartyMembers()
    lastPartyMembers = BuildMemberSet(members)
  end
end

local verifyFrame = CreateFrame('Frame')
verifyFrame:RegisterEvent('CHAT_MSG_ADDON')
verifyFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
verifyFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

verifyFrame:SetScript('OnEvent', function(self, event, prefix, message, channel, sender)
  if event == 'PLAYER_ENTERING_WORLD' then
    InitializePartyState()
    return
  end
  
  if event == 'GROUP_ROSTER_UPDATE' then
    --[[ Check for new party members when roster changes  
         I had to add a small delay, because sometimes unit info isn't populated immediately ]]--
    C_Timer.After(0.5, function()
      CheckForNewPartyMembers()
    end)
    return
  end
  
  if event == 'CHAT_MSG_ADDON' and prefix == ADDON_PREFIX then
    local senderName = NormalizeName(sender)
    if not senderName then
      return
    end
    
    if message == 'REQUEST' then
      -- Someone is requesting verification, send our response
      SendVerificationResponse()
    else
      -- Parse response message: "PRESET:LEGIT" (e.g., "Extreme:1")
      local preset, legitStr = string.match(message, '([^:]+):([01])')
      if preset and legitStr then
        partyVerificationData[senderName] = {
          preset = preset,
          legit = legitStr == '1',
          timestamp = GetTime()
        }
      end
    end
  end
end)

-- Register slash command for party verification
SLASH_UHCVERIFY1 = '/uhcverify'
SlashCmdList['UHCVERIFY'] = VerifyUhcPartyMembers
