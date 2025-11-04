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

  -- If placeholder is enabled, show a simple message and skip building pages
    if not XFoundModeManager.parentFrame then
      XFoundModeManager.parentFrame = tabContents[4]
    end

    if not XFoundModeManager.placeholder then
      local placeholder = CreateFrame('Frame', nil, XFoundModeManager.parentFrame)
      placeholder:SetAllPoints(XFoundModeManager.parentFrame)
      placeholder:Hide()

      local message = placeholder:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
      message:SetPoint('CENTER', placeholder, 'CENTER', 0, 10)
      message:SetText('Coming In Phase 2!')

      local subText = placeholder:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      subText:SetPoint('TOP', message, 'BOTTOM', 0, -16)
      subText:SetWidth(460)
      subText:SetJustifyH('CENTER')
      subText:SetNonSpaceWrap(true)
      subText:SetText("Guild and Group found are nearly done.\nWe're working on the anti cheat system before releasing it to the public.")

      local subText2 = placeholder:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      subText2:SetPoint('TOP', subText, 'BOTTOM', 0, -8)
      subText2:SetWidth(460)
      subText2:SetJustifyH('CENTER')
      subText2:SetNonSpaceWrap(true)
      subText2:SetText("Seriously, why y'all cheating? It gives me a whole lot more work to do!")

      XFoundModeManager.placeholder = placeholder
    end

    XFoundModeManager:HideAllPages()
    XFoundModeManager.placeholder:Show()
    XFoundModeManager.currentPage = 'placeholder'
end

  -- Initialize the manager if not already done
--[[
  if not XFoundModeManager.parentFrame then
    XFoundModeManager.parentFrame = tabContents[4]

    -- Create all pages only once
    if XFoundModePages then
      XFoundModeManager.pages.intro = XFoundModePages.CreateIntroPage(tabContents[4])
      XFoundModeManager.pages.status = XFoundModePages.CreateStatusPage(tabContents[4])
      XFoundModeManager.pages.guildConfirm = XFoundModePages.CreateGuildConfirmPage(tabContents[4])
      XFoundModeManager.pages.groupConfirm = XFoundModePages.CreateGroupConfirmPage(tabContents[4])
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
]]

--[[
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
]]

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
