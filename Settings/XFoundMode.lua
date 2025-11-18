-- 🟢 X Found Mode Tab Content

-- X Found Mode Manager
XFoundModeManager = {
  currentPage = nil,
  pages = {},
  parentFrame = nil,
}

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
    print('|cff00ff00Guild Found mode activated!|r Trading is now restricted to guild members only.')
  end

  if XFoundModeManager and XFoundModeManager.ShowStatusPage then
    XFoundModeManager:ShowStatusPage()
  end

  if XFoundModeManager
      and XFoundModeManager.pages
      and XFoundModeManager.pages.status
      and XFoundModeManager.pages.status.UpdateStatus then
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

  -- Lazily create pages once
  if XFoundModePages then
    if not XFoundModeManager.pages.intro then
      XFoundModeManager.pages.intro = XFoundModePages.CreateIntroPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.status then
      XFoundModeManager.pages.status = XFoundModePages.CreateStatusPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.guildConfirm then
      XFoundModeManager.pages.guildConfirm = XFoundModePages.CreateGuildConfirmPage(XFoundModeManager.parentFrame)
    end
    if not XFoundModeManager.pages.groupConfirm then
      XFoundModeManager.pages.groupConfirm = XFoundModePages.CreateGroupConfirmPage(XFoundModeManager.parentFrame)
    end
  end

  -- Always hide all pages first to prevent stacking
  XFoundModeManager:HideAllPages()

  -- Show appropriate page based on player level and mode selection status
  local playerLevel = UnitLevel('player')
  local hasSelectedMode =
    (GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound) or (GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound)

  if playerLevel == 1 and not hasSelectedMode then
    -- Level 1 and no mode selected - show intro page
    XFoundModeManager:ShowIntroPage()
  else
    -- Either not level 1 OR level 1 with mode already selected - show status page
    XFoundModeManager:ShowStatusPage()
  end
end

-- Show Intro Page (for level 1 players)
function XFoundModeManager:ShowIntroPage()
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
    print('|cffffd000[ULTRA]|r Type "/guildfound confirm" to permanently lock this character into Guild Found mode.')
    print('|cffffd000[ULTRA]|r This restricts trading and mail to guild members and blocks auction house usage. This cannot be undone.')
    return
  end

  local activated = ActivateGuildFoundMode and ActivateGuildFoundMode()
  if activated and UnitLevel and UnitLevel('player') > 1 then
    print('|cffffd000[ULTRA]|r Guild Found mode enabled after level 1. Restrictions are now active immediately.')
  end
end
