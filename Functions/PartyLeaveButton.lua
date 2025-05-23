-- Create the party leave button
local leaveButton = CreateFrame('Button', nil, UIParent, 'UIPanelButtonTemplate')
leaveButton:SetSize(100, 30)
leaveButton:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 20, 20)
leaveButton:SetText('Leave Party')
leaveButton:Hide()

-- Create the confirmation dialog
StaticPopupDialogs['ULTRA_HARDCORE_LEAVE_PARTY'] = {
    text = "Are you sure you want to leave the party?",
    button1 = "Yes, Leave Party",
    button2 = "No, Stay",
    OnAccept = function()
        LeaveParty()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Handle button click
leaveButton:SetScript('OnClick', function()
    StaticPopup_Show('ULTRA_HARDCORE_LEAVE_PARTY')
end)

-- Show/hide button based on party status
local frame = CreateFrame('Frame')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')
frame:RegisterEvent('RAID_ROSTER_UPDATE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')

frame:SetScript('OnEvent', function(self, event)
    if IsInGroup() then
        leaveButton:Show()
    else
        leaveButton:Hide()
    end
end) 