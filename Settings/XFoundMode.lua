-- 🟢 X Found Mode Tab Content

-- X Found Mode Manager
XFoundModeManager = {
  currentPage = nil,
  pages = {},
  parentFrame = nil,
}

-- Feature flag helper: when false, Guild Found UI is hidden behind "Coming in phase 2"
local function IsGuildFoundUIEnabled()
  return _G.UHC_ENABLE_GUILD_FOUND_UI == true or IsUltraGuildMember()
end

-- Simple placeholder page used when a section is hidden for phase 2
local function CreatePhase2PlaceholderPage(parentFrame)
  local page = CreateFrame('Frame', nil, parentFrame)
  page:SetAllPoints(parentFrame)
  page:Hide()
  local text = page:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  text:SetPoint('CENTER')
  text:SetText('Coming soon')
  text:SetTextColor(1, 0.95, 0.5)
  return page
end

-- Determine if the player should be treated as level 1 for X Found interactions
function XFoundMode_ShouldTreatPlayerAsLevelOne()
  local playerLevel = UnitLevel('player') or 1
  if playerLevel == 1 then
    return true
  end

  if HasSelfFoundBuff and HasSelfFoundBuff() then
    return true
  end

  return false
end

-- Shared helper to activate Guild Found mode from UI or slash commands
function ActivateGuildFoundMode(options)
  if not GLOBAL_SETTINGS then
    if not (options and options.silent) then
      print('|cffffd000[ULTRA]|r Settings not loaded. Try again in a moment.')
    end
    return false
  end

  if GLOBAL_SETTINGS.guildSelfFound then
    if not (options and options.silent) then
      print('|cffffd000[ULTRA]|r Guild Found mode is already active on this character.')
    end
    return false
  end

  GLOBAL_SETTINGS.guildSelfFound = true
  GLOBAL_SETTINGS.groupSelfFound = false

  if SaveCharacterSettings then
    SaveCharacterSettings(GLOBAL_SETTINGS)
  end

  if not (options and options.silent) then
    print(
      '|cff00ff00Guild Found mode activated!|r Trading is now restricted to guild members only.'
    )
  end

  if XFoundModeManager and XFoundModeManager.ShowStatusPage then
    XFoundModeManager:ShowStatusPage()
  end

  if XFoundModeManager and XFoundModeManager.pages and XFoundModeManager.pages.status and XFoundModeManager.pages.status.UpdateStatus then
    XFoundModeManager.pages.status:UpdateStatus()
  end

  return true
end

-- Shared helper to leave any active X Found mode (only while eligible)
function LeaveXFoundModes(options)
  if not GLOBAL_SETTINGS then
    if not (options and options.silent) then
      print('|cffffd000[ULTRA]|r Settings not loaded. Try again in a moment.')
    end
    return false
  end

  local treatAsLevelOne = false
  if XFoundMode_ShouldTreatPlayerAsLevelOne then
    treatAsLevelOne = XFoundMode_ShouldTreatPlayerAsLevelOne()
  end

  if not treatAsLevelOne then
    if not (options and options.silent) then
      print(
        '|cffffd000[ULTRA]|r You can only leave Guild/Group Found while level 1 or under the Self Found buff.'
      )
    end
    return false
  end

  local hadActiveMode =
    (GLOBAL_SETTINGS.guildSelfFound or GLOBAL_SETTINGS.groupSelfFound) and true or false
  if not hadActiveMode then
    if not (options and options.silent) then
      print('|cffffd000[ULTRA]|r No X Found mode is currently active on this character.')
    end
    return false
  end

  GLOBAL_SETTINGS.guildSelfFound = false
  GLOBAL_SETTINGS.groupSelfFound = false

  if SaveCharacterSettings then
    SaveCharacterSettings(GLOBAL_SETTINGS)
  end

  if not (options and options.silent) then
    print(
      '|cff00ff00X Found restrictions cleared.|r You may choose a new mode while you remain eligible.'
    )
  end

  if XFoundModeManager and XFoundModeManager.ShowStatusPage then
    XFoundModeManager:ShowStatusPage()
  end

  if XFoundModeManager and XFoundModeManager.pages and XFoundModeManager.pages.status and XFoundModeManager.pages.status.UpdateStatus then
    XFoundModeManager.pages.status:UpdateStatus()
  end

  return true
end

-- Initialize X Found Mode when the tab is first shown
function InitializeXFoundModeTab()
  -- Check if tabContents[4] exists
  if not tabContents or not tabContents[4] then return end

  -- Ensure parent frame is set
  if not XFoundModeManager.parentFrame then
    XFoundModeManager.parentFrame = tabContents[4]
  end

  -- If the X Found UI is disabled, show only the placeholder and return
  if not IsGuildFoundUIEnabled() then
    if not XFoundModeManager.pages.phase2 then
      XFoundModeManager.pages.phase2 = CreatePhase2PlaceholderPage(XFoundModeManager.parentFrame)
    end
    XFoundModeManager:HideAllPages()
    if XFoundModeManager.pages.phase2 then
      XFoundModeManager.pages.phase2:Show()
      XFoundModeManager.currentPage = 'phase2'
    end
    return
  end

  -- Lazily create pages once
  if XFoundModePages then
    if not XFoundModeManager.pages.intro then
      XFoundModeManager.pages.intro = XFoundModePages.CreateIntroPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.status then
      XFoundModeManager.pages.status =
        XFoundModePages.CreateStatusPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.guildConfirm then
      XFoundModeManager.pages.guildConfirm =
        XFoundModePages.CreateGuildConfirmPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.groupConfirm then
      XFoundModeManager.pages.groupConfirm =
        XFoundModePages.CreateGroupConfirmPage(XFoundModeManager.parentFrame)
    end
  end

  -- Always hide all pages first to prevent stacking
  XFoundModeManager:HideAllPages()

  -- Show appropriate page based on player level and mode selection status
  local treatAsLevelOne =
    XFoundMode_ShouldTreatPlayerAsLevelOne and XFoundMode_ShouldTreatPlayerAsLevelOne()
  local hasSelectedMode =
    (GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound) or (GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound)

  -- Ultra guild members should always see the full Guild Found display
  if IsUltraGuildMember and IsUltraGuildMember() then
    XFoundModeManager:ShowStatusPage()
  elseif treatAsLevelOne and not hasSelectedMode then
    -- Level 1 and no mode selected - show intro page
    XFoundModeManager:ShowIntroPage()
  else
    -- Either not level 1 OR level 1 with mode already selected - show status page
    XFoundModeManager:ShowStatusPage()
  end
end

-- Show Intro Page (for level 1 players)
function XFoundModeManager:ShowIntroPage()
  -- Ultra guild members should always see the status (Guild Found) page
  if IsUltraGuildMember and IsUltraGuildMember() then
    self:ShowStatusPage()
    return
  end
  self:HideAllPages()
  if self.pages.intro then
    self.pages.intro:Show()
    self.currentPage = 'intro'
  end
end

-- Show Status Page (for non-level 1 players)
function XFoundModeManager:ShowStatusPage()
  self:HideAllPages()
  if self.pages.status then
    self.pages.status:Show()
    self.currentPage = 'status'
    -- Update status information
    if self.pages.status.UpdateStatus then
      self.pages.status:UpdateStatus()
    end
  end
end

-- Show Guild Confirmation Page
function XFoundModeManager:ShowGuildConfirmPage()
  self:HideAllPages()
  if not IsGuildFoundUIEnabled() then
    if not self.pages.phase2 then
      self.pages.phase2 = CreatePhase2PlaceholderPage(self.parentFrame)
    end
    if self.pages.phase2 then
      self.pages.phase2:Show()
      self.currentPage = 'phase2'
    end
    return
  end
  if self.pages.guildConfirm then
    self.pages.guildConfirm:Show()
    self.currentPage = 'guildConfirm'
  end
end

-- Show Group Confirmation Page
function XFoundModeManager:ShowGroupConfirmPage()
  self:HideAllPages()
  if self.pages.groupConfirm then
    self.pages.groupConfirm:Show()
    self.currentPage = 'groupConfirm'
  end
end

-- Hide all pages
function XFoundModeManager:HideAllPages()
  for pageName, page in pairs(self.pages) do
    if page then
      page:Hide()
    end
  end
  self.currentPage = nil
end

-- Cleanup function to hide all pages when leaving the tab
function XFoundModeManager:Cleanup()
  self:HideAllPages()
end

-- Slash command to activate Guild Found mode (even post level 1)
SLASH_GUILDFOUNDMODE1 = '/guildfound'
SLASH_GUILDFOUNDMODE2 = '/joinguildfound'

SlashCmdList['GUILDFOUNDMODE'] = function(msg)
  local raw = msg or ''
  raw = string.gsub(raw, '^%s+', '')
  raw = string.gsub(raw, '%s+$', '')
  raw = string.lower(raw)

  if raw ~= 'confirm' then
    print(
      '|cffffd000[ULTRA]|r Type "/guildfound confirm" to permanently lock this character into Guild Found mode.'
    )
    print(
      '|cffffd000[ULTRA]|r This restricts trading and mail to guild members and blocks auction house usage. This cannot be undone.'
    )
    return
  end

  local activated = ActivateGuildFoundMode and ActivateGuildFoundMode()
  if activated and UnitLevel and UnitLevel('player') > 1 then
    print(
      '|cffffd000[ULTRA]|r Guild Found mode enabled after level 1. Restrictions are now active immediately.'
    )
  end
end

-- Slash command to leave any X Found mode (while eligible)
SLASH_LEAVEFOUNDMODE1 = '/leavefound'
SLASH_LEAVEFOUNDMODE2 = '/exitfound'

SlashCmdList['LEAVEFOUNDMODE'] = function()
  if not LeaveXFoundModes or not LeaveXFoundModes() then
    if LeaveXFoundModes == nil then
      print('|cffffd000[ULTRA]|r Leave handler not available right now. Try again in a moment.')
    end
  end
end
