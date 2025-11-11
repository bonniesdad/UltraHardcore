-- Addon communication prefix for UHC verification
local ADDON_PREFIX = 'UHC_VERIFY'

local partyVerificationData = {}
local verificationRequestTime = 0
local isWaitingForResponses = false
local lastPartyMembers = {}
local lastAutoVerifyTime = 0
local AUTO_VERIFY_THROTTLE = 5 -- Minimum seconds between automatic verifications

-- Function to get current party member names
local function GetCurrentPartyMembers()
  local members = {}
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local name = GetRaidRosterInfo(i)
      if name then
        table.insert(members, name)
      end
    end
  elseif IsInGroup() then
    for i = 1, GetNumGroupMembers() do
      local name = UnitName('party' .. i)
      if name then
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

-- This sends a verification request to party members
local function SendVerificationRequest()
  local channel = IsInRaid() and 'RAID' or 'PARTY'
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX, 'REQUEST', channel)
  end
end

local function SendVerificationResponse()
  local channel = IsInRaid() and 'RAID' or 'PARTY'

  local presetLevel = DeterminePresetLevel(GLOBAL_SETTINGS)
  local isLegit, presetName = GetPlayerLegitimacyStatus(presetLevel)
  
  -- Build response message: "PRESET:LEGIT" (e.g., "Extreme:1" or "Lite:0" or "None:0")
  local presetStr = presetName or 'None'
  local legitStr = isLegit and '1' or '0'
  local message = presetStr .. ':' .. legitStr
  
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, channel)
  end
end

local function DisplayVerificationResults()
  local playerName = UnitName('player')
  
  print('|cffffd000[UHC]|r Party Member Verification Results:')
  print('|cffffd000[UHC]|r ' .. string.rep('-', 50))
  
  local hasResponses = false
  for name, data in pairs(partyVerificationData) do
    hasResponses = true
    local preset = data.preset or 'None'
    local isLegit = data.legit == true
    
    if isLegit then
      print('|cffffd000[UHC]|r |cff33F24C[OK]|r ' .. name .. ' - Certified ' .. preset .. ' Ultra')
    elseif preset ~= 'None' then
      print('|cffffd000[UHC]|r |cffFF4444[X]|r ' .. name .. ' - ' .. preset .. ' settings but not legitimate')
    else
      print('|cffffd000[UHC]|r |cffFF4444[X]|r ' .. name .. ' - Not using UHC addon or not using a preset')
    end
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
    print('|cffffd000[UHC]|r')
    print('|cffffd000[UHC]|r |cffFFAA00[!]|r No response from: ' .. table.concat(nonResponders, ', '))
    print('|cffffd000[UHC]|r These members may not have the UHC addon installed.')
  end
  
  if not hasResponses and #nonResponders == 0 then
    print('|cffffd000[UHC]|r')
    print('|cffffd000[UHC]|r Note: No other party members detected or responded.')
  end
end

-- Function to display verification result for a specific player
local function DisplaySinglePlayerVerification(targetName)
  local data = partyVerificationData[targetName]
  
  if data then
    local preset = data.preset or 'None'
    local isLegit = data.legit == true
    
    print('|cffffd000[UHC]|r Verification Result for ' .. targetName .. ':')
    print('|cffffd000[UHC]|r ' .. string.rep('-', 50))
    
    if isLegit then
      print('|cffffd000[UHC]|r |cff33F24C[OK]|r ' .. targetName .. ' - Certified ' .. preset .. ' Ultra')
    elseif preset ~= 'None' then
      print('|cffffd000[UHC]|r |cffFF4444[X]|r ' .. targetName .. ' - ' .. preset .. ' settings but not legitimate')
    else
      print('|cffffd000[UHC]|r |cffFF4444[X]|r ' .. targetName .. ' - Not using UHC addon or not using a preset')
    end
  else
    print('|cffffd000[UHC]|r |cffFFAA00[!]|r No response from ' .. targetName)
    print('|cffffd000[UHC]|r They may not have the UHC addon installed or are not in your group.')
  end
end

-- Function to verify a specific player by name
local function VerifySpecificPlayer(playerName)
  if not IsInGroup() then
    print('|cffffd000[UHC]|r You are not in a party or raid.')
    return
  end

  local normalizedTarget = NormalizeName(playerName)
  if not normalizedTarget then
    print('|cffffd000[UHC]|r Invalid player name.')
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
    print('|cffffd000[UHC]|r ' .. normalizedTarget .. ' is not in your party or raid.')
    return
  end

  -- Reset verification data for this specific player
  partyVerificationData[normalizedTarget] = nil
  verificationRequestTime = GetTime()
  isWaitingForResponses = true
  
  SendVerificationRequest()
  
  print('|cffffd000[UHC]|r Requesting verification from ' .. normalizedTarget .. '...')
  
  C_Timer.After(2, function()
    isWaitingForResponses = false
    DisplaySinglePlayerVerification(normalizedTarget)
  end)
end

-- Main function to verify UHC party members
function VerifyUhcPartyMembers(args)
  if args and args ~= '' then
    VerifySpecificPlayer(args)
    return
  end

  -- Check if player is in a group
  if not IsInGroup() then
    print('|cffffd000[UHC]|r You are not in a party or raid.')
    return
  end

  -- Reset verification data
  partyVerificationData = {}
  verificationRequestTime = GetTime()
  isWaitingForResponses = true
  
  SendVerificationRequest()
  
  print('|cffffd000[UHC]|r Requesting verification from party members...')
  
  C_Timer.After(2, function()
    isWaitingForResponses = false
    DisplayVerificationResults()
  end)
end

-- Function to detect new party members and auto-verify
local function CheckForNewPartyMembers()
  if not IsInGroup() then
    lastPartyMembers = {}
    return
  end

  local currentMembers = GetCurrentPartyMembers()
  local currentMemberSet = {}
  
  for _, name in ipairs(currentMembers) do
    local normalized = NormalizeName(name)
    if normalized then
      currentMemberSet[normalized] = true
    end
  end
 
  local newMembers = {}
  for memberName, _ in pairs(currentMemberSet) do
    if not lastPartyMembers[memberName] then
      table.insert(newMembers, memberName)
    end
  end
  
  lastPartyMembers = currentMemberSet

  if #newMembers > 0 then
    local currentTime = GetTime()
    if currentTime - lastAutoVerifyTime >= AUTO_VERIFY_THROTTLE then
      lastAutoVerifyTime = currentTime
      
      -- Display notification about new members
      if #newMembers == 1 then
        print('|cffffd000[UHC]|r ' .. newMembers[1] .. ' joined the party. Verifying...')
      else
        print('|cffffd000[UHC]|r ' .. #newMembers .. ' new members joined the party. Verifying...')
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

local verifyFrame = CreateFrame('Frame')
verifyFrame:RegisterEvent('CHAT_MSG_ADDON')
verifyFrame:RegisterEvent('GROUP_ROSTER_UPDATE')

verifyFrame:SetScript('OnEvent', function(self, event, prefix, message, channel, sender)
  if event == 'GROUP_ROSTER_UPDATE' then
    -- Check for new party members when roster changes
    CheckForNewPartyMembers()
    return
  end
  
  if event == 'CHAT_MSG_ADDON' and prefix == ADDON_PREFIX then
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
