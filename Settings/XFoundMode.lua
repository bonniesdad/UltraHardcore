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

  -- Initialize the manager if not already done
  if not XFoundModeManager.parentFrame then
    XFoundModeManager.parentFrame = tabContents[4]

    -- Create all pages only once
    if XFoundModePages then
      -- Create pages with error checking
      if XFoundModePages.CreateIntroPage then
        XFoundModeManager.pages.intro = XFoundModePages.CreateIntroPage(tabContents[4])
      end
      if XFoundModePages.CreateStatusPage then
        XFoundModeManager.pages.status = XFoundModePages.CreateStatusPage(tabContents[4])
      end
      if XFoundModePages.CreateGuildConfirmPage then
        XFoundModeManager.pages.guildConfirm = XFoundModePages.CreateGuildConfirmPage(tabContents[4])
      end
      if XFoundModePages.CreateDuoConfirmPage then
        XFoundModeManager.pages.duoConfirm = XFoundModePages.CreateDuoConfirmPage(tabContents[4])
      end
      if XFoundModePages.CreateGroupConfirmPage then
        XFoundModeManager.pages.groupConfirm = XFoundModePages.CreateGroupConfirmPage(tabContents[4])
      end
    else
      print("UltraHardcore: XFoundModePages not available yet, retrying...")
    end
  end

  -- Always hide all pages first to prevent stacking
  XFoundModeManager:HideAllPages()

  -- Show appropriate page based on player level and mode selection status
  local playerLevel = UnitLevel('player')
  local hasSelectedMode = false
  
  -- Check if any X Found mode has been selected
  if GLOBAL_SETTINGS then
    hasSelectedMode = GLOBAL_SETTINGS.guildSelfFound or GLOBAL_SETTINGS.groupSelfFound or GLOBAL_SETTINGS.duoSelfFound
  end

  if playerLevel == 1 and not hasSelectedMode then
    -- Level 1 and no mode selected - show intro page
    XFoundModeManager:ShowIntroPage()
  elseif hasSelectedMode then
    -- Mode already selected - show status page
    XFoundModeManager:ShowStatusPage()
  else
    -- Default case - show intro page for mode selection
    XFoundModeManager:ShowIntroPage()
  end
end

-- Show Intro Page (for level 1 players)
function XFoundModeManager:ShowIntroPage()
  self:HideAllPages()
  if self.pages.intro then
    self.pages.intro:Show()
    self.currentPage = 'intro'
  else
    -- Fallback: Create intro page if it doesn't exist
    if XFoundModePages and XFoundModePages.CreateIntroPage and self.parentFrame then
      self.pages.intro = XFoundModePages.CreateIntroPage(self.parentFrame)
      if self.pages.intro then
        self.pages.intro:Show()
        self.currentPage = 'intro'
      end
    end
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

-- Show Duo Confirmation Page
function XFoundModeManager:ShowDuoConfirmPage()
  self:HideAllPages()
  if self.pages.duoConfirm then
    self.pages.duoConfirm:Show()
    self.currentPage = 'duoConfirm'
  else
    -- Fallback: Create duo confirm page if it doesn't exist
    if XFoundModePages and XFoundModePages.CreateDuoConfirmPage and self.parentFrame then
      self.pages.duoConfirm = XFoundModePages.CreateDuoConfirmPage(self.parentFrame)
      if self.pages.duoConfirm then
        self.pages.duoConfirm:Show()
        self.currentPage = 'duoConfirm'
      end
    end
  end
end

-- Show Group Confirmation Page
function XFoundModeManager:ShowGroupConfirmPage()
  self:HideAllPages()
  if self.pages.groupConfirm then
    self.pages.groupConfirm:Show()
    self.currentPage = 'groupConfirm'
  else
    -- Fallback: Create group confirm page if it doesn't exist
    if XFoundModePages and XFoundModePages.CreateGroupConfirmPage and self.parentFrame then
      self.pages.groupConfirm = XFoundModePages.CreateGroupConfirmPage(self.parentFrame)
      if self.pages.groupConfirm then
        self.pages.groupConfirm:Show()
        self.currentPage = 'groupConfirm'
      end
    end
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