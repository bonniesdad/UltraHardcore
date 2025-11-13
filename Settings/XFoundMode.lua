-- 🟢 X Found Mode Tab Content

-- X Found Mode Manager
XFoundModeManager = {
  currentPage = nil,
  pages = {},
  parentFrame = nil,
}


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
