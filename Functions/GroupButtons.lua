local inviteButton = nil
local leaveButton = nil
local eventFrame = nil

local function areFramesHidden()
  if not GLOBAL_SETTINGS then return false end
  return (GLOBAL_SETTINGS.hidePlayerFrame or false)
    or (GLOBAL_SETTINGS.completelyRemovePlayerFrame or false)
    or (GLOBAL_SETTINGS.hideTargetFrame or false)
    or (GLOBAL_SETTINGS.completelyRemoveTargetFrame or false)
    or (GLOBAL_SETTINGS.hideGroupHealth or false)
end

local function isPlayerInGroup()
  if IsInGroup then
    return IsInGroup()
  end
  local party = GetNumPartyMembers and GetNumPartyMembers() or 0
  local raid = GetNumRaidMembers and GetNumRaidMembers() or 0
  return (party and party > 0) or (raid and raid > 0)
end

local function canInviteTarget()
  if not UnitExists("target") then return false end
  if not UnitIsPlayer("target") then return false end
  if UnitIsUnit("target", "player") then return false end
  if UnitInParty and UnitInParty("target") then return false end
  if UnitInRaid and UnitInRaid("target") then return false end
  return true
end

local function updateInviteButtonVisibility()
  if not inviteButton then return end
  if areFramesHidden() and canInviteTarget() then
    inviteButton:Show()
  else
    inviteButton:Hide()
  end
end

local function updateLeaveButtonVisibility()
  if not leaveButton then return end
  if areFramesHidden() and isPlayerInGroup() then
    leaveButton:Show()
  else
    leaveButton:Hide()
  end
end

local function createButtons()
  if inviteButton and leaveButton then return end

  leaveButton = CreateFrame('Button', 'UltraHardcoreLeaveGroupButton', UIParent, 'UIPanelButtonTemplate')
  leaveButton:SetSize(80, 24)
  leaveButton:SetText('Leave')
  leaveButton:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -16, 16)
  leaveButton:SetFrameStrata('HIGH')
  leaveButton:SetScript('OnClick', function()
    if isPlayerInGroup() then
      if C_PartyInfo and C_PartyInfo.LeaveParty then
        C_PartyInfo.LeaveParty()
      elseif LeaveParty then
        LeaveParty()
      end
    end
  end)
  leaveButton:Hide()

  inviteButton = CreateFrame('Button', 'UltraHardcoreInviteButton', UIParent, 'UIPanelButtonTemplate')
  inviteButton:SetSize(80, 24)
  inviteButton:SetText('Invite')
  inviteButton:SetPoint('RIGHT', leaveButton, 'LEFT', -8, 0)
  inviteButton:SetFrameStrata('HIGH')
  inviteButton:SetScript('OnClick', function()
    if canInviteTarget() then
      local name = UnitName('target')
      if name then
        if C_PartyInfo and C_PartyInfo.InviteUnit then
          C_PartyInfo.InviteUnit(name)
        elseif InviteUnit then
          InviteUnit(name)
        elseif InviteByName then
          InviteByName(name)
        end
      end
    end
  end)
  inviteButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Invite target to group')
    GameTooltip:Show()
  end)
  inviteButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  inviteButton:Hide()
end

local function registerEvents()
  if eventFrame then return end
  eventFrame = CreateFrame('Frame')
  eventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
  eventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
  eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
  eventFrame:SetScript('OnEvent', function(self, event)
    if event == 'PLAYER_TARGET_CHANGED' then
      updateInviteButtonVisibility()
    elseif event == 'GROUP_ROSTER_UPDATE' or event == 'PLAYER_ENTERING_WORLD' then
      updateInviteButtonVisibility()
      updateLeaveButtonVisibility()
    end
  end)
end

function InitializeGroupButtons()
  createButtons()
  registerEvents()
  updateInviteButtonVisibility()
  updateLeaveButtonVisibility()
end


