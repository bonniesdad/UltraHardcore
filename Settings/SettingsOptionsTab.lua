local settingsCheckboxOptions = { {
  -- Lite Preset Settings
  name = 'UHC Player Frame',
  dbSettingsValueName = 'hidePlayerFrame',
  tooltip = 'Minimalistic player frame to hide own health',
}, {
  name = 'Tunnel Vision',
  dbSettingsValueName = 'showTunnelVision',
  tooltip = 'The screen gets darker as you get closer to death',
}, {
  -- Recommended Preset Settings
  name = 'Hide Target Frame',
  dbSettingsValueName = 'hideTargetFrame',
  tooltip = "Target frame is not visible, so you can't see the target's health or level",
}, {
  name = 'Hide Target Tooltips',
  dbSettingsValueName = 'hideTargetTooltip',
  tooltip = "Target tooltips are not visible, so you can't see the target's health or level",
}, {
  name = 'Disable Nameplates',
  dbSettingsValueName = 'disableNameplateHealth',
  tooltip = 'Turns off nameplates, hiding healthbars above units',
}, {
  name = 'Show Dazed effect',
  dbSettingsValueName = 'showDazedEffect',
  tooltip = 'A blue blur effect appears around your character when dazed',
}, {
  name = 'UHC Party Frames',
  dbSettingsValueName = 'hideGroupHealth',
  tooltip = 'Party healthbars are hidden and replaced with a custom health indicator',
}, {
  name = 'Hide Minimap',
  dbSettingsValueName = 'hideMinimap',
  tooltip = 'Makes gathering resources a lot more challenging by hiding the minimap',
},  {
  -- Extreme Preset Settings {
  name = 'Pets Die Permanently',
  dbSettingsValueName = 'petsDiePermanently',
  tooltip = "Pets can't be resurrected when they are killed",
}, {
  name = 'Hide Action Bars when not resting',
  dbSettingsValueName = 'hideActionBars',
  tooltip = 'Hide action bars when not resting or near a campfire',
}, {
  name = 'Tunnel Vision Covers Everything',
  dbSettingsValueName = 'tunnelVisionMaxStrata',
  tooltip = 'Tunnel Vision covers all UI elements',
},  {
  name = 'Route Planner',
  dbSettingsValueName = 'routePlanner',
  tooltip = 'The map is only usable near campfire or when resting. Your location marker on the map is also hidden.',
}, { -- Experimental Preset Settings
  name = 'UHC Breath Indicator',
  dbSettingsValueName = 'hideBreathIndicator',
  tooltip = 'Replace the breath bar with a increasingly red screen overlay when underwater',
}, {
  name = 'UHC Incoming Crit Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
  tooltip = 'A red screen rotation effect appears when you take a critical hit',
}, {
  name = 'Hide Custom Resource Bar',
  dbSettingsValueName = 'hideCustomResourceBar',
  tooltip = 'Hide the custom resource bar',
}, {
  name = 'UHC Full Health Indicator (Screen Glow)',
  dbSettingsValueName = 'showFullHealthIndicator',
  tooltip = 'The edges of the screen glow when you are at full health',
}, {
  name = 'UHC Full Health Indicator (Audio Cue)',
  dbSettingsValueName = 'showFullHealthIndicatorAudioCue',
  tooltip = 'An audio cue plays when you are at full health',
}, {
  name = 'UHC Incoming Damage Effect',
  dbSettingsValueName = 'showIncomingDamageEffect',
  tooltip = 'Various screen effects on incoming damage',
}, {
  name = 'UHC Incoming Healing Effect',
  dbSettingsValueName = 'showHealingIndicator',
  tooltip = 'Gold glow on the edges of the screen when you are healed',
}, {
  name = 'Hide Player Cast Bar',
  dbSettingsValueName = 'hidePlayerCastBar',
  tooltip = 'Hide the player casting bar to remove spell casting information',
}, {
  name = 'First Person Camera',
  dbSettingsValueName = 'setFirstPersonCamera',
  tooltip = 'Play in first person mode, allows to look around for briew records of time',
}, {
  name = 'Completely Remove Player Frame',
  dbSettingsValueName = 'completelyRemovePlayerFrame',
  tooltip = 'Completely remove the player frame',
}, {
  name = 'Completely Remove Target Frame',
  dbSettingsValueName = 'completelyRemoveTargetFrame',
  tooltip = 'Completely remove the target frame',
}, {
  -- Misc Settings (no preset button)
  name = 'On Screen Statistics',
  dbSettingsValueName = 'showOnScreenStatistics',
  tooltip = 'Show important UHC statistics on the screen at all times',
}, {
  name = 'Announce Level Up to Guild',
  dbSettingsValueName = 'announceLevelUpToGuild',
  tooltip = 'Announces level ups to guild chat every 10th level',
}, {
  name = 'Hide UI Error Messages',
  dbSettingsValueName = 'hideUIErrors',
  tooltip = 'Hide error messages that appear on screen (like "Target is too far away")',
}, {
  name = 'Show Clock Even When Map is Hidden',
  dbSettingsValueName = 'showClockEvenWhenMapHidden',
  tooltip = 'If Hide Minimap is enabled, keep the clock on display instead of hiding it',
}, {
  name = 'Announce Party Deaths on Group Join',
  dbSettingsValueName = 'announcePartyDeathsOnGroupJoin',
  tooltip = 'Automatically announce party death statistics when joining a group',
}, {
  name = 'Announce Dungeons Completed on Group Join',
  dbSettingsValueName = 'announceDungeonsCompletedOnGroupJoin',
  tooltip = 'Automatically announce dungeons completed statistics when joining a group',
}, {
  name = 'Buff Bar on Resource Bar',
  dbSettingsValueName = 'buffBarOnResourceBar',
  tooltip = 'Position player buff bar on top of the custom resource bar',
}, {
  name = 'Hide Buffs & Debuffs',
  dbSettingsValueName = 'hideBuffsCompletely',
  tooltip = 'Hides buffs and debuffs completely',
}, {
  name = 'Hide Debuffs',
  dbSettingsValueName = 'hideDebuffs',
  tooltip = 'Hides debuff icons only',
}, {
  name = 'Highest Crit Appreciation Soundbite',
  dbSettingsValueName = 'newHighCritAppreciationSoundbite',
  tooltip = 'Play a soundbite when you achieve a new highest crit value',
}, {
  name = 'Party Death Soundbite',
  dbSettingsValueName = 'playPartyDeathSoundbite',
  tooltip = 'Play a soundbite when a party member dies',
}, {
  name = 'Player Death Soundbite',
  dbSettingsValueName = 'playPlayerDeathSoundbite',
  tooltip = 'Play a soundbite when you die',
}, {
  name = 'Spooky Tunnel Vision',
  dbSettingsValueName = 'spookyTunnelVision',
  tooltip = 'Use Halloween-themed tunnel vision overlay for ultra spooky experience',
}, {
  name = 'Roach Hearthstone In Party Combat',
  dbSettingsValueName = 'roachHearthstoneInPartyCombat',
  tooltip = 'Show a roach overlay on screen when using hearthstone whilst a party member is in combat',
}, {
  name = 'Show XP Bar',
  dbSettingsValueName = 'showExpBar',
  tooltip = 'Shows experience percentage and current XP/max XP in a bar at the top of the screen',
}, {
  name = 'Show XP Bar Tooltip',
  dbSettingsValueName = 'showXpBarToolTip',
  tooltip = 'Shows detailed XP information when hovering over the XP bar (percentage and exact numbers)',
}, {
  name = 'Hide Default WoW XP Bar',
  dbSettingsValueName = 'hideDefaultExpBar',
  tooltip = 'Hide the original World of Warcraft experience bar',
}, {
  name = 'Route Planner - Compass',
  dbSettingsValueName = 'routePlannerCompass',
  tooltip = 'Get a compass to aid you in your journey',
} }

-- XP Bar Settings
local settingsSliderOptions = { {
  name = 'XP Bar Height',
  dbSettingsValueName = 'xpBarHeight',
  tooltip = 'Adjust the height of the XP bar at the top of the screen (1-10 pixels)',
  minValue = MINIMUM_XP_BAR_HEIGHT,
  maxValue = MAXIMUM_XP_BAR_HEIGHT,
  defaultValue = 3,
} }

local presets = { {
  -- Preset 1: Lite
  -- Lite Preset Settings
  hidePlayerFrame = true,
  showTunnelVision = true,
  -- Recommended Preset Settings
  hideMinimap = false,
  hideTargetFrame = false,
  hideTargetTooltip = false,
  disableNameplateHealth = false,
  showDazedEffect = false,
  hideGroupHealth = false,
  -- Extreme Preset Settings
  petsDiePermanently = false,
  hideActionBars = false,
  tunnelVisionMaxStrata = false,
  -- Experimental Preset Settings
  hideBreathIndicator = false,
  hidePlayerCastBar = false,
  showCritScreenMoveEffect = false,
  showFullHealthIndicator = false,
  hideCustomResourceBar = false,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  setFirstPersonCamera = false,
  routePlanner = false,
  routePlannerCompass = false,
  -- Misc Settings
  showOnScreenStatistics = true,
  announceLevelUpToGuild = true,
  hideUIErrors = false,
  showClockEvenWhenMapHidden = false,
  announcePartyDeathsOnGroupJoin = false,
  announceDungeonsCompletedOnGroupJoin = false,
  newHighCritAppreciationSoundbite = false,
  buffBarOnResourceBar = false,
  hideBuffsCompletely = false,
  hideDebuffs = false,
  playPartyDeathSoundbite = false,
  playPlayerDeathSoundbite = false,
  spookyTunnelVision = false,
  roachHearthstoneInPartyCombat = false,
}, {
  -- Preset 2: Recommended
  -- Lite Preset Settings
  hidePlayerFrame = true,
  showTunnelVision = true,
  -- Recommended Preset Settings
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  disableNameplateHealth = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  -- Extreme Preset Settings
  petsDiePermanently = false,
  hideActionBars = false,
  tunnelVisionMaxStrata = false,
  routePlanner = false,
  -- Experimental Preset Settings
  hideBreathIndicator = false,
  hidePlayerCastBar = false,
  showCritScreenMoveEffect = false,
  showFullHealthIndicator = false,
  hideCustomResourceBar = false,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  setFirstPersonCamera = false,
  routePlannerCompass = false,
  -- Misc Settings
  showOnScreenStatistics = true,
  announceLevelUpToGuild = true,
  hideUIErrors = false,
  showClockEvenWhenMapHidden = false,
  announcePartyDeathsOnGroupJoin = false,
  announceDungeonsCompletedOnGroupJoin = false,
  newHighCritAppreciationSoundbite = false,
  buffBarOnResourceBar = false,
  hideBuffsCompletely = false,
  hideDebuffs = false,
  playPartyDeathSoundbite = false,
  playPlayerDeathSoundbite = false,
  spookyTunnelVision = false,
  roachHearthstoneInPartyCombat = false,
}, {
  -- Preset 3: Extreme
  -- Lite Preset Settings
  hidePlayerFrame = true,
  showTunnelVision = true,
  -- Recommended Preset Settings
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  disableNameplateHealth = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  -- Extreme Preset Settings
  petsDiePermanently = true,
  hideActionBars = true,
  tunnelVisionMaxStrata = true,
  routePlanner = true,
  -- Experimental Preset Settings
  hideBreathIndicator = false,
  hidePlayerCastBar = false,
  showCritScreenMoveEffect = false,
  showFullHealthIndicator = false,
  hideCustomResourceBar = false,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  setFirstPersonCamera = false,
  routePlannerCompass = false,
  -- Misc Settings
  showOnScreenStatistics = true,
  announceLevelUpToGuild = true,
  hideUIErrors = false,
  showClockEvenWhenMapHidden = false,
  announcePartyDeathsOnGroupJoin = false,
  announceDungeonsCompletedOnGroupJoin = false,
  newHighCritAppreciationSoundbite = false,
  buffBarOnResourceBar = false,
  hideBuffsCompletely = false,
  hideDebuffs = false,
  playPartyDeathSoundbite = false,
  playPlayerDeathSoundbite = false,
  spookyTunnelVision = false,
  roachHearthstoneInPartyCombat = false,
} }

-- Global function to update radio buttons (needed by Statistics tab)
function updateRadioButtons()
  for settingName, radio in pairs(radioButtons) do
    if radio then
      local isChecked = tempSettings[settingName] or false
      radio:SetChecked(isChecked)
      GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
    end
  end
end

-- Initialize Settings Options Tab when called
function InitializeSettingsOptionsTab()
  -- Check if tabContents[2] exists
  if not tabContents or not tabContents[2] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[2].initialized then return end

  -- Mark as initialized
  tabContents[2].initialized = true

  -- Ensure collapsed state storage exists
  if not GLOBAL_SETTINGS.collapsedSettingsSections then
    GLOBAL_SETTINGS.collapsedSettingsSections = {}
  end
  if GLOBAL_SETTINGS.collapsedSettingsSections.presetSection == nil then
    GLOBAL_SETTINGS.collapsedSettingsSections.presetSection = {}
  end

  local presetButtonsFrame = CreateFrame('Frame', nil, tabContents[2])
  presetButtonsFrame:SetSize(420, 150)
  presetButtonsFrame:SetPoint('TOP', tabContents[2], 'TOP', 0, -10)

  local checkboxes = {}
  local sliders = {}
  local presetButtons = {}
  local selectedPreset = nil

  local function updateCheckboxes()
    for _, checkboxItem in ipairs(settingsCheckboxOptions) do
      local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
      if checkbox then
        -- Provide proper defaults for checkboxes if they're nil
        local isChecked = tempSettings[checkboxItem.dbSettingsValueName]
        if isChecked == nil then
          -- Default showExpBar to false (user must explicitly enable it)
          isChecked = false
        end
        checkbox:SetChecked(isChecked)
      end
    end
    if _G.updateSectionCounts then
      _G.updateSectionCounts()
    end
  end

  local function updateSliders()
    for _, sliderItem in ipairs(settingsSliderOptions) do
      local slider = sliders[sliderItem.dbSettingsValueName]
      if slider then
        local value = tempSettings[sliderItem.dbSettingsValueName]
        if value == nil then
          value = sliderItem.defaultValue
        end
        slider:SetValue(value)
      end
    end
  end

  local function applyPreset(presetIndex)
    if not presets[presetIndex] then return end

    for key, value in pairs(presets[presetIndex]) do
      tempSettings[key] = value
    end

    -- Save selected difficulty
    local difficultyNames = { "lite", "recommended", "extreme" }
    tempSettings.selectedDifficulty = difficultyNames[presetIndex]
    GLOBAL_SETTINGS.selectedDifficulty = difficultyNames[presetIndex]

    if tempSettings.hidePlayerFrame then
      SetCVar('statusText', '0')
    end

    -- Apply the new completely remove settings immediately when presets are applied
    SetPlayerFrameDisplay(
      tempSettings.hidePlayerFrame or false,
      tempSettings.completelyRemovePlayerFrame or false
    )
    SetTargetFrameDisplay(
      tempSettings.hideTargetFrame or false,
      tempSettings.completelyRemoveTargetFrame or false
    )

    updateCheckboxes()
    updateSliders()
    updateRadioButtons()

    if selectedPreset then
      selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end
    selectedPreset = presetButtons[presetIndex]
    selectedPreset:SetBackdropBorderColor(1, 1, 0)
  end

  local presetIcons =
    {
      'Interface\\AddOns\\UltraHardcore\\textures\\' .. (UltraHardcoreDB.resourceIndicatorShown and '01_bonnie_light.png' or 'skull1_100.png'),
      'Interface\\AddOns\\UltraHardcore\\textures\\' .. (UltraHardcoreDB.resourceIndicatorShown and '02_bonnie_recommended.png' or 'skull2_100.png'),
      'Interface\\AddOns\\UltraHardcore\\textures\\' .. (UltraHardcoreDB.resourceIndicatorShown and '03_bonnie_extreme.png' or 'skull3_100.png'),
    }

  local buttonSize = 100
  local spacing = 10
  local textYOffset = -5

  for i = 1, 3 do
    local button = CreateFrame('Button', nil, presetButtonsFrame, 'BackdropTemplate')
    button:SetSize(buttonSize, buttonSize)

    if i == 1 then
      button:SetPoint('LEFT', presetButtonsFrame, 'LEFT', spacing, -20)
    elseif i == 2 then
      button:SetPoint('CENTER', presetButtonsFrame, 'CENTER', 0, -20)
    elseif i == 3 then
      button:SetPoint('RIGHT', presetButtonsFrame, 'RIGHT', -spacing, -20)
    end

    button:SetBackdrop({
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      edgeSize = 10,
    })
    button:SetBackdropBorderColor(0.5, 0.5, 0.5)

    local icon = button:CreateTexture(nil, 'ARTWORK')
    icon:SetAllPoints()
    icon:SetTexture(presetIcons[i])

    local presetText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    presetText:SetPoint('TOP', button, 'BOTTOM', 0, textYOffset)
    if i == 1 then
      presetText:SetText('Lite')
    elseif i == 2 then
      presetText:SetText('Recommended')
    elseif i == 3 then
      presetText:SetText('Extreme')
    end

    button:SetScript('OnClick', function()
      applyPreset(i)
    end)

    presetButtons[i] = button
  end

  -- Initialize preset selection display based on current selectedDifficulty
  local function updatePresetSelectionDisplay()
    local currentDifficulty = GLOBAL_SETTINGS.selectedDifficulty
    
    -- Reset all buttons to default appearance
    for i = 1, 3 do
      presetButtons[i]:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end
    
    -- Highlight the currently selected preset
    if currentDifficulty then
      local presetIndex = nil
      if currentDifficulty == 'lite' then
        presetIndex = 1
      elseif currentDifficulty == 'recommended' then
        presetIndex = 2
      elseif currentDifficulty == 'extreme' then
        presetIndex = 3
      end
      
      if presetIndex and presetButtons[presetIndex] then
        presetButtons[presetIndex]:SetBackdropBorderColor(1, 1, 0) -- Yellow border
        selectedPreset = presetButtons[presetIndex]
      end
    end
  end

  -- Call the function to initialize display
  updatePresetSelectionDisplay()

  -- Search bar (filters options below)
  local searchBox = CreateFrame('EditBox', nil, tabContents[2], 'InputBoxTemplate')
  searchBox:SetSize(405, 24)
  searchBox:SetAutoFocus(false)
  searchBox:SetPoint('TOPLEFT', tabContents[2], 'TOPLEFT', 25, -180)

  local searchPlaceholder = searchBox:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  searchPlaceholder:SetPoint('LEFT', searchBox, 'LEFT', 6, 0)
  searchPlaceholder:SetText('Search options...')

  local clearSearchButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
  clearSearchButton:SetSize(56, 22)
  clearSearchButton:SetPoint('LEFT', searchBox, 'RIGHT', 6, 0)
  clearSearchButton:SetText('Clear')

  -- Global filter function (uses globals set after checkbox creation)
  _G.UHC_ApplySettingsSearchFilter = function(query)
    local q = (query or '')
    _G.__UHC_CurrentSearchQuery = q
    local ql = string.lower(q)

    local childrenBySection = _G.__UHC_SectionChildren
    local framesBySection = _G.__UHC_SectionFrames
    local collapsedBySection = _G.__UHC_SectionCollapsed
    local HEADER_HEIGHT = _G.__UHC_SECTION_HEADER_HEIGHT or 22
    local ROW_HEIGHT = _G.__UHC_ROW_HEIGHT or 30
    local HEADER_CONTENT_GAP = _G.__UHC_HEADER_CONTENT_GAP or 10

    if not childrenBySection or not framesBySection or not collapsedBySection then return end

    for idx, children in ipairs(childrenBySection) do
      local sf = framesBySection[idx]
      local isCollapsed = collapsedBySection[idx]
      local visibleCount = 0

      for _, cb in ipairs(children) do
        local searchBlob = cb._uhcSearch or ''
        local isMatch = (ql == '' or string.find(searchBlob, ql, 1, true) ~= nil)
        if not isCollapsed and isMatch then
          cb:Show()
          cb:ClearAllPoints()
          cb:SetPoint('TOPLEFT', sf, 'TOPLEFT', 10, -(HEADER_HEIGHT + HEADER_CONTENT_GAP + (visibleCount * ROW_HEIGHT)))
          visibleCount = visibleCount + 1
        else
          cb:Hide()
        end
      end

      local expandedHeight = HEADER_HEIGHT
      if visibleCount > 0 then
        expandedHeight = HEADER_HEIGHT + HEADER_CONTENT_GAP + (visibleCount * ROW_HEIGHT) + 5
      end
      local collapsedHeight = HEADER_HEIGHT
      sf:SetHeight(isCollapsed and collapsedHeight or expandedHeight)
    end

    if _G.__UHC_RecalcContentHeight then _G.__UHC_RecalcContentHeight() end
  end

  searchBox:SetScript('OnTextChanged', function(self)
    local txt = self:GetText() or ''
    if txt == '' then searchPlaceholder:Show() else searchPlaceholder:Hide() end
    if _G.UHC_ApplySettingsSearchFilter then _G.UHC_ApplySettingsSearchFilter(txt) end
  end)
  searchBox:SetScript('OnEditFocusGained', function()
    if (searchBox:GetText() or '') == '' then searchPlaceholder:Hide() end
  end)
  searchBox:SetScript('OnEditFocusLost', function()
    if (searchBox:GetText() or '') == '' then searchPlaceholder:Show() end
  end)
  searchBox:SetScript('OnEscapePressed', function(self)
    self:SetText('')
    self:ClearFocus()
    if _G.UHC_ApplySettingsSearchFilter then _G.UHC_ApplySettingsSearchFilter('') end
  end)

  clearSearchButton:SetScript('OnClick', function()
    searchBox:SetText('')
    if _G.UHC_ApplySettingsSearchFilter then _G.UHC_ApplySettingsSearchFilter('') end
  end)

  local scrollFrame = CreateFrame('ScrollFrame', nil, tabContents[2], 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', searchBox, 'BOTTOMLEFT', -15, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', tabContents[2], 'BOTTOMRIGHT', -30, 10)

  local scrollChild = CreateFrame('Frame')
  scrollFrame:SetScrollChild(scrollChild)
  -- Initial size; will be recalculated dynamically as sections expand/collapse
  scrollChild:SetHeight(100)
  local function updateScrollChildWidth()
    local gutter = 1
    local w = scrollFrame:GetWidth() - gutter
    if w and w > 0 then
      scrollChild:SetWidth(w)
    end
  end
  scrollFrame:SetScript('OnSizeChanged', function()
    updateScrollChildWidth()
  end)
  updateScrollChildWidth()

  -- Keep a handle to the last section frame so we can anchor subsequent sections beneath it
  local lastSectionFrame = nil
  -- Track all preset section frames and a dynamic height recalculator
  local sectionFrames = {}
  local recalcContentHeight = nil

  function createCheckboxes()
    -- Initialize slider defaults for settings that don't exist
    for _, sliderItem in ipairs(settingsSliderOptions) do
      if tempSettings[sliderItem.dbSettingsValueName] == nil then
        tempSettings[sliderItem.dbSettingsValueName] = sliderItem.defaultValue
      end
    end

    local HEADER_HEIGHT = 22
    local ROW_HEIGHT = 30
    local SECTION_GAP = 10
    local HEADER_CONTENT_GAP = 10
    local prevSectionFrame = nil

    local sectionChildren = {}
    local sectionCollapsed = {}
    local sectionChildSettingNames = {}
    local sectionCountTexts = {}

    -- Expose layout numbers and section arrays for the search filter
    _G.__UHC_SECTION_HEADER_HEIGHT = HEADER_HEIGHT
    _G.__UHC_ROW_HEIGHT = ROW_HEIGHT
    _G.__UHC_HEADER_CONTENT_GAP = HEADER_CONTENT_GAP

    local function updateSectionCount(idx)
      if not sectionCountTexts[idx] or not sectionChildSettingNames[idx] then return end
      local total = #sectionChildSettingNames[idx]
      local selected = 0
      for _, settingName in ipairs(sectionChildSettingNames[idx]) do
        local value = tempSettings[settingName]
        -- For sliders (numeric values), count as selected if value exists and > 0
        -- For checkboxes (boolean values), count as selected if true
        local isSlider = false
        for _, sliderItem in ipairs(settingsSliderOptions) do
          if sliderItem.dbSettingsValueName == settingName then
            isSlider = true
            break
          end
        end

        if isSlider then
          if value and value > 0 then selected = selected + 1 end
        else
          if value then selected = selected + 1 end
        end
      end
      sectionCountTexts[idx]:SetText(selected .. "/" .. total)
    end

    local presetSections = GetPresetSections('simple', true) -- Include Misc section
    for sectionIndex, section in ipairs(presetSections) do
      -- Container for the whole section so collapsing reflows subsequent sections
      local sectionFrame = CreateFrame('Frame', nil, scrollChild)
      sectionFrame:SetWidth(420)
      if prevSectionFrame then
        sectionFrame:SetPoint('TOPLEFT', prevSectionFrame, 'BOTTOMLEFT', 0, -SECTION_GAP)
        sectionFrame:SetPoint('TOPRIGHT', prevSectionFrame, 'BOTTOMRIGHT', 0, -SECTION_GAP)
      else
        sectionFrame:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 10, -10)
        sectionFrame:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -10)
      end

      -- Clickable header inside the section container
      local sectionHeaderButton = CreateFrame('Button', nil, sectionFrame, 'BackdropTemplate')
      sectionHeaderButton:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 0, 0)
      sectionHeaderButton:SetPoint('TOPRIGHT', sectionFrame, 'TOPRIGHT', 0, 0)
      sectionHeaderButton:SetHeight(HEADER_HEIGHT)
      sectionHeaderButton:SetBackdrop({
        bgFile = 'Interface\\Buttons\\WHITE8X8',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
      })
      sectionHeaderButton:SetBackdropColor(0, 0, 0, 0.35)
      sectionHeaderButton:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
      sectionHeaderButton:SetScript('OnEnter', function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
      end)
      sectionHeaderButton:SetScript('OnLeave', function(self)
        self:SetBackdropColor(0, 0, 0, 0.35)
      end)

      local sectionHeader = sectionHeaderButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      sectionHeader:SetPoint('LEFT', sectionHeaderButton, 'LEFT', 4, 0)
      sectionHeader:SetText(section.title)
      sectionHeader:SetTextColor(1, 1, 0.5)

      local headerIcon = sectionHeaderButton:CreateTexture(nil, 'ARTWORK')
      local headerCountText = sectionHeaderButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
      headerIcon:SetPoint('RIGHT', sectionHeaderButton, 'RIGHT', -6, 0)
      headerCountText:SetPoint('RIGHT', headerIcon, 'LEFT', -6, 0)
      headerIcon:SetSize(16, 16)
      headerIcon:SetTexture('Interface\\Buttons\\UI-MinusButton-Up')
      -- Hide count for sections below the Optional features note (sections after Extreme)
      if sectionIndex > 3 then
        headerCountText:Hide()
      end

      sectionChildren[sectionIndex] = {}
      sectionChildSettingNames[sectionIndex] = {}

      local numRows = 0
      for _, settingName in ipairs(section.settings) do
        local checkboxItem = nil
        local sliderItem = nil

        -- Check if this setting is a checkbox
        for _, item in ipairs(settingsCheckboxOptions) do
          if item.dbSettingsValueName == settingName then
            checkboxItem = item
            break
          end
        end

        -- Check if this setting is a slider
        if not checkboxItem then
          for _, item in ipairs(settingsSliderOptions) do
            if item.dbSettingsValueName == settingName then
              sliderItem = item
              break
            end
          end
        end

        if checkboxItem then
          numRows = numRows + 1
          local checkbox = CreateFrame('CheckButton', nil, sectionFrame, 'ChatConfigCheckButtonTemplate')
          checkbox:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 10, -(HEADER_HEIGHT + HEADER_CONTENT_GAP + ((numRows - 1) * ROW_HEIGHT)))
          checkbox.Text:SetText(checkboxItem.name)
          checkbox.Text:SetPoint('LEFT', checkbox, 'RIGHT', 5, 0)
          checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])

          -- Precompute search blob for fast filtering
          local n = checkboxItem.name or ''
          local t = checkboxItem.tooltip or ''
          local k = checkboxItem.dbSettingsValueName or ''
          checkbox._uhcSearch = string.lower(n .. ' ' .. t .. ' ' .. k)

          checkboxes[checkboxItem.dbSettingsValueName] = checkbox
          table.insert(sectionChildren[sectionIndex], checkbox)
          table.insert(sectionChildSettingNames[sectionIndex], checkboxItem.dbSettingsValueName)

          checkbox:SetScript('OnClick', function(self)
            tempSettings[checkboxItem.dbSettingsValueName] = self:GetChecked()

            if checkboxItem.dbSettingsValueName == 'hidePlayerFrame' and self:GetChecked() then
              SetCVar('statusText', '0')
            end

            if checkboxItem.dbSettingsValueName == 'buffBarOnResourceBar' or checkboxItem.dbSettingsValueName == 'hidePlayerFrame' then
              if _G.UltraHardcoreHandleBuffBarSettingChange then
                _G.UltraHardcoreHandleBuffBarSettingChange()
              end
            end

            updateSectionCount(sectionIndex)
          end)

          checkbox:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText(checkboxItem.tooltip)
            GameTooltip:Show()
          end)

          checkbox:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
          end)
        elseif sliderItem then
          numRows = numRows + 1

          -- Create slider frame
          local sliderFrame = CreateFrame('Frame', nil, sectionFrame)
          sliderFrame:SetSize(400, ROW_HEIGHT)
          sliderFrame:SetPoint('TOPLEFT', sectionFrame, 'TOPLEFT', 10, -(HEADER_HEIGHT + HEADER_CONTENT_GAP + ((numRows - 1) * ROW_HEIGHT)))

          -- Create slider label
          local sliderLabel = sliderFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
          sliderLabel:SetPoint('LEFT', sliderFrame, 'LEFT', 0, 0)
          sliderLabel:SetText(sliderItem.name)

          -- Create the slider
          local slider = CreateFrame('Slider', nil, sliderFrame, 'OptionsSliderTemplate')
          slider:SetSize(150, 15)
          slider:SetPoint('RIGHT', sliderFrame, 'RIGHT', -50, 0)
          slider:SetMinMaxValues(sliderItem.minValue, sliderItem.maxValue)
          slider:SetValue(tempSettings[sliderItem.dbSettingsValueName] or sliderItem.defaultValue)
          slider:SetValueStep(1)
          slider:SetObeyStepOnDrag(true)

          -- Create value label
          local valueLabel = sliderFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          valueLabel:SetPoint('RIGHT', sliderFrame, 'RIGHT', -10, 0)
          valueLabel:SetText(tostring(math.floor(slider:GetValue())))

          -- Precompute search blob for fast filtering
          local n = sliderItem.name or ''
          local t = sliderItem.tooltip or ''
          local k = sliderItem.dbSettingsValueName or ''
          sliderFrame._uhcSearch = string.lower(n .. ' ' .. t .. ' ' .. k)

          sliders[sliderItem.dbSettingsValueName] = slider
          table.insert(sectionChildren[sectionIndex], sliderFrame)
          table.insert(sectionChildSettingNames[sectionIndex], sliderItem.dbSettingsValueName)

          -- Handle slider value changes
          slider:SetScript('OnValueChanged', function(self, value)
            local newValue = math.floor(value)
            tempSettings[sliderItem.dbSettingsValueName] = newValue
            valueLabel:SetText(tostring(newValue))

            -- Handle XP Bar height changes
            if sliderItem.dbSettingsValueName == 'xpBarHeight' and _G.UpdateExpBarHeight then
              UpdateExpBarHeight()
            end
          end)

          -- Add tooltip functionality
          sliderFrame:EnableMouse(true)
          sliderFrame:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText(sliderItem.tooltip)
            GameTooltip:Show()
          end)

          sliderFrame:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
          end)
        end
      end

      local expandedHeight = HEADER_HEIGHT + HEADER_CONTENT_GAP + (numRows * ROW_HEIGHT) + 5
      local collapsedHeight = HEADER_HEIGHT

      -- Determine initial collapsed state (persisted or default collapsed for sections after Ultra)
      local presetStates = GLOBAL_SETTINGS.collapsedSettingsSections.presetSection
      local initialCollapsed = presetStates[section.title]
      if initialCollapsed == nil then
        initialCollapsed = sectionIndex > 3 -- collapse Experimental and below by default
      end
      sectionCollapsed[sectionIndex] = initialCollapsed
      headerIcon:SetTexture(initialCollapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up')
      for _, child in ipairs(sectionChildren[sectionIndex]) do
        child:SetShown(not initialCollapsed)
      end
      sectionFrame:SetHeight(initialCollapsed and collapsedHeight or expandedHeight)

      -- Initialize and display count text for this section
      sectionCountTexts[sectionIndex] = headerCountText
      updateSectionCount(sectionIndex)

      -- Toggle all child checkboxes and resize the section so the layout reflows
      sectionHeaderButton:SetScript('OnClick', function()
        local collapsed = not sectionCollapsed[sectionIndex]
        sectionCollapsed[sectionIndex] = collapsed
        headerIcon:SetTexture(collapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up')
        for _, child in ipairs(sectionChildren[sectionIndex]) do
          child:SetShown(not collapsed)
        end
        sectionFrame:SetHeight(collapsed and collapsedHeight or expandedHeight)
        -- Persist state
        GLOBAL_SETTINGS.collapsedSettingsSections.presetSection[section.title] = collapsed
        if SaveCharacterSettings then
          SaveCharacterSettings(GLOBAL_SETTINGS)
        end
        if recalcContentHeight then recalcContentHeight() end
        -- Reapply current filter to fix heights and visibility after toggle
        if _G.UHC_ApplySettingsSearchFilter then _G.UHC_ApplySettingsSearchFilter(_G.__UHC_CurrentSearchQuery or '') end
      end)

      prevSectionFrame = sectionFrame
      lastSectionFrame = sectionFrame
      table.insert(sectionFrames, sectionFrame)
      -- Insert an informational note after the Extreme section
      if sectionIndex == 3 then
        local infoFrame = CreateFrame('Frame', nil, scrollChild)
        infoFrame:SetWidth(420)
        infoFrame:SetPoint('TOPLEFT', sectionFrame, 'BOTTOMLEFT', 0, -SECTION_GAP)
        infoFrame:SetPoint('TOPRIGHT', sectionFrame, 'BOTTOMRIGHT', 0, -SECTION_GAP)
        infoFrame:SetHeight(64)

        -- Divider line above the note
        local divider = infoFrame:CreateTexture(nil, 'ARTWORK')
        divider:SetTexture('Interface\\Buttons\\WHITE8X8')
        divider:SetVertexColor(0.6, 0.6, 0.6, 0.6)
        divider:SetPoint('TOPLEFT', infoFrame, 'TOPLEFT', 0, -2)
        divider:SetPoint('TOPRIGHT', infoFrame, 'TOPRIGHT', 0, -2)
        divider:SetHeight(1)

        -- Small title
        local titleText = infoFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
        titleText:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 10, -12)
        titleText:SetText('Optional features')

        -- Body text under the title
        local bodyText = infoFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        bodyText:SetPoint('TOPLEFT', titleText, 'BOTTOMLEFT', 0, -2)
        bodyText:SetPoint('RIGHT', infoFrame, 'RIGHT', -10, 0)
        bodyText:SetJustifyH('LEFT')
        bodyText:SetJustifyV('TOP')
        bodyText:SetText('Everything below is optional and not part of the core Ultra experience. Use these tweaks if they suit your playstyle.')

        -- Ensure subsequent sections anchor below this note
        prevSectionFrame = infoFrame
        lastSectionFrame = infoFrame
      end
    end

    -- Expose a global to refresh all section counts after bulk changes
    _G.updateSectionCounts = function()
      for idx, _ in ipairs(sectionCountTexts) do
        updateSectionCount(idx)
      end
    end

    -- Expose built arrays for search filter usage
    _G.__UHC_SectionChildren = sectionChildren
    _G.__UHC_SectionFrames = sectionFrames
    _G.__UHC_SectionCollapsed = sectionCollapsed
  end

  local saveButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
  saveButton:SetSize(120, 30)
  saveButton:SetPoint('BOTTOM', tabContents[2], 'BOTTOM', 0, -40)
  saveButton:SetText('Save and Reload')
  saveButton:SetScript('OnClick', function()
    for key, value in pairs(tempSettings) do
      GLOBAL_SETTINGS[key] = value
    end

    if GLOBAL_SETTINGS.hidePlayerFrame then
      SetCVar('statusText', '0')
    end

    -- Apply the new completely remove settings immediately
    SetPlayerFrameDisplay(
      GLOBAL_SETTINGS.hidePlayerFrame or false,
      GLOBAL_SETTINGS.completelyRemovePlayerFrame or false
    )
    SetTargetFrameDisplay(
      GLOBAL_SETTINGS.hideTargetFrame or false,
      GLOBAL_SETTINGS.completelyRemoveTargetFrame or false
    )

    -- Handle XP Bar settings
    if GLOBAL_SETTINGS.showExpBar then
      InitializeExpBar()
    else
      HideExpBar()
    end

    if GLOBAL_SETTINGS.hideDefaultExpBar then
      HideDefaultExpBar()
    else
      ShowDefaultExpBar()
    end

    -- Update XP bar color and height if it exists
    if _G.UpdateExpBarColor then
      UpdateExpBarColor()
    end
    if _G.UpdateExpBarHeight then
      UpdateExpBarHeight()
    end

    SaveCharacterSettings(GLOBAL_SETTINGS)
    ReloadUI()
  end)

  _G.updateCheckboxes = updateCheckboxes
  _G.updateSliders = updateSliders
  _G.updateRadioButtons = updateRadioButtons
  _G.updatePresetSelectionDisplay = updatePresetSelectionDisplay
  _G.applyPreset = applyPreset
  _G.createCheckboxes = createCheckboxes
  _G.checkboxes = checkboxes
  _G.sliders = sliders
  _G.presetButtons = presetButtons
  _G.selectedPreset = selectedPreset

  createCheckboxes()

  -- Collapsible: Resource Bar Colors
  local HEADER_HEIGHT = 22
  local ROW_HEIGHT = 28
  local HEADER_CONTENT_GAP = 10
  local SUBHEADER_TO_ROWS_GAP = 10

  local colorSectionFrame = CreateFrame('Frame', nil, scrollChild)
  colorSectionFrame:SetWidth(420)
  if lastSectionFrame then
    colorSectionFrame:SetPoint('TOPLEFT', lastSectionFrame, 'BOTTOMLEFT', 0, -10)
    colorSectionFrame:SetPoint('TOPRIGHT', lastSectionFrame, 'BOTTOMRIGHT', 0, -10)
  else
    colorSectionFrame:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 10, -10)
    colorSectionFrame:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -10)
  end

  local colorHeaderButton = CreateFrame('Button', nil, colorSectionFrame, 'BackdropTemplate')
  colorHeaderButton:SetPoint('TOPLEFT', colorSectionFrame, 'TOPLEFT', 0, 0)
  colorHeaderButton:SetPoint('TOPRIGHT', colorSectionFrame, 'TOPRIGHT', 0, 0)
  colorHeaderButton:SetHeight(HEADER_HEIGHT)
  colorHeaderButton:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  colorHeaderButton:SetBackdropColor(0, 0, 0, 0.35)
  colorHeaderButton:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
  colorHeaderButton:SetScript('OnEnter', function(self)
    self:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
  end)
  colorHeaderButton:SetScript('OnLeave', function(self)
    self:SetBackdropColor(0, 0, 0, 0.35)
  end)
  local colorHeaderText = colorHeaderButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  colorHeaderText:SetPoint('LEFT', colorHeaderButton, 'LEFT', 4, 0)
  colorHeaderText:SetText('Ultra UI Settings')
  colorHeaderText:SetTextColor(1, 1, 0.5)
  local colorHeaderIcon = colorHeaderButton:CreateTexture(nil, 'ARTWORK')
  colorHeaderIcon:SetPoint('RIGHT', colorHeaderButton, 'RIGHT', -6, 0)
  colorHeaderIcon:SetSize(16, 16)
  colorHeaderIcon:SetTexture('Interface\\Buttons\\UI-MinusButton-Up')

  tempSettings.resourceBarColors = tempSettings.resourceBarColors or {}
  local colorRows = {}

  -- Subheader: Resource Bar Colours
  local resourceSubHeader = colorSectionFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  resourceSubHeader:SetPoint('TOPLEFT', colorSectionFrame, 'TOPLEFT', 6, -(HEADER_HEIGHT + HEADER_CONTENT_GAP))
  resourceSubHeader:SetText('Resource Bar Colours')
  resourceSubHeader:SetTextColor(1, 0.85, 0.4)

  local COLOR_ROWS_TOP_OFFSET = HEADER_HEIGHT + HEADER_CONTENT_GAP + 18 + SUBHEADER_TO_ROWS_GAP

  local function createColorRowInSection(labelText, powerKey, rowIndex, fallbackColor)
    local row = CreateFrame('Frame', nil, colorSectionFrame)
    row:SetSize(380, 24)
    row:SetPoint('TOPLEFT', colorSectionFrame, 'TOPLEFT', 20, -(COLOR_ROWS_TOP_OFFSET + ((rowIndex - 1) * ROW_HEIGHT)))

    local LABEL_WIDTH = 140
    local SWATCH_WIDTH = 54
    local GAP = 12

    local label = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    label:SetPoint('LEFT', row, 'LEFT', 0, 0)
    label:SetWidth(LABEL_WIDTH)
    label:SetJustifyH('LEFT')
    label:SetText(labelText)

    local swatch = CreateFrame('Frame', nil, row, 'BackdropTemplate')
    swatch:SetSize(SWATCH_WIDTH, 16)
    swatch:SetPoint('LEFT', row, 'LEFT', LABEL_WIDTH + GAP, 0)
    swatch:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      edgeSize = 8,
      insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })

    local function getDefaultColor()
      if POWER_COLORS and POWER_COLORS[powerKey] then
        return POWER_COLORS[powerKey][1], POWER_COLORS[powerKey][2], POWER_COLORS[powerKey][3]
      end
      if fallbackColor then
        return fallbackColor[1], fallbackColor[2], fallbackColor[3]
      end
      return 1, 1, 1
    end

    local function getCurrentColor()
      local c = nil
      if tempSettings.resourceBarColors[powerKey] then
        c = tempSettings.resourceBarColors[powerKey]
      elseif POWER_COLORS and POWER_COLORS[powerKey] then
        c = POWER_COLORS[powerKey]
      else
        c = fallbackColor
      end
      return c[1], c[2], c[3]
    end

    local function setSwatchColor(r, g, b)
      swatch:SetBackdropColor(r, g, b, 1)
      swatch:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    end

    setSwatchColor(getCurrentColor())

    local pickButton = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
    pickButton:SetSize(70, 20)
    pickButton:SetPoint('LEFT', row, 'LEFT', LABEL_WIDTH + GAP + SWATCH_WIDTH + GAP, 0)
    pickButton:SetText('Pick')

    local resetButton = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
    resetButton:SetSize(56, 20)
    resetButton:SetPoint('LEFT', pickButton, 'RIGHT', 6, 0)
    resetButton:SetText('Reset')

    local classButton = CreateFrame('Button', nil, row, 'UIPanelButtonTemplate')
    classButton:SetSize(96, 20)
    classButton:SetPoint('LEFT', resetButton, 'RIGHT', 6, 0)
    classButton:SetText('Class Colour')
    classButton:SetScript('OnClick', function()
      local _, englishClass = UnitClass('player')
      local classColor = RAID_CLASS_COLORS[englishClass]
      if classColor then
        tempSettings.resourceBarColors[powerKey] = { classColor.r, classColor.g, classColor.b }
        setSwatchColor(classColor.r, classColor.g, classColor.b)
      end
    end)

    pickButton:SetScript('OnClick', function()
      local r, g, b = getCurrentColor()
      local function onColorPicked()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        tempSettings.resourceBarColors[powerKey] = { nr, ng, nb }
        setSwatchColor(nr, ng, nb)
      end
      local function onCancel(prev)
        local pr, pg, pb = r, g, b
        if prev and prev.r and prev.g and prev.b then
          pr, pg, pb = prev.r, prev.g, prev.b
        end
        tempSettings.resourceBarColors[powerKey] = { pr, pg, pb }
        setSwatchColor(pr, pg, pb)
      end
      if ColorPickerFrame then
        ColorPickerFrame:Hide()
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.opacityFunc = nil
        ColorPickerFrame.func = onColorPicked
        ColorPickerFrame.swatchFunc = onColorPicked

        -- Only create inputs once per ColorPickerFrame
        if not ColorPickerFrame.__UHC_InputsCreated then
          local inputs = CreateFrame('Frame', nil, ColorPickerFrame)
          inputs:SetSize(240, 44)
          -- Slightly increase frame height to make room
          local fh = (ColorPickerFrame.GetHeight and ColorPickerFrame:GetHeight()) or 0
          if fh and fh > 0 then
            ColorPickerFrame:SetHeight(fh + 40)
          end
          -- Position inputs above the standard OK/Cancel buttons (closer to bottom)
          inputs:SetPoint('BOTTOM', ColorPickerFrame, 'BOTTOM', 0, 20)

          -- RGB inputs
          inputs.rgb = {}
          local labels = {'R: ', 'G: ', 'B: '}
          for i = 1, 3 do
            local lbl = inputs:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            lbl:SetPoint('TOPLEFT', inputs, 'TOPLEFT', -15 + ((i-1) * 55), -4)
            lbl:SetText(labels[i])

            local box = CreateFrame('EditBox', nil, inputs, 'InputBoxTemplate')
            box:SetSize(30, 20)
            box:SetPoint('TOPLEFT', lbl, 'TOPRIGHT', 4, 4)
            box:SetAutoFocus(false)
            box:SetMaxLetters(3)
            box:SetNumeric(true)

            local function updateColorFromRGB()
              local r = tonumber(inputs.rgb[1]:GetText() or '') or 0
              local g = tonumber(inputs.rgb[2]:GetText() or '') or 0
              local b = tonumber(inputs.rgb[3]:GetText() or '') or 0
              r = math.max(0, math.min(255, r)) / 255
              g = math.max(0, math.min(255, g)) / 255
              b = math.max(0, math.min(255, b)) / 255
              ColorPickerFrame:SetColorRGB(r, g, b)
            end
            box:SetScript('OnTextChanged', function(self, user)
              if user then updateColorFromRGB() end
            end)
            box:SetScript('OnEnterPressed', function(self)
              self:ClearFocus()
            end)

            inputs.rgb[i] = box
          end

          -- Hex input
          local hexLbl = inputs:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
          hexLbl:SetPoint('TOPLEFT', inputs, 'TOPLEFT', 160, -4)
          hexLbl:SetText('Hex: ')

          local hexBox = CreateFrame('EditBox', nil, inputs, 'InputBoxTemplate')
          hexBox:SetSize(56, 20)
          hexBox:SetPoint('LEFT', hexLbl, 'RIGHT', 4, 0)
          hexBox:SetAutoFocus(false)
          hexBox:SetMaxLetters(6)

          local function updateColorFromHex()
            local hex = (hexBox:GetText() or ''):gsub('#', ''):upper()
            if hex:match('^%x%x%x%x%x%x$') then
              local rr = (tonumber(hex:sub(1,2), 16) or 0) / 255
              local gg = (tonumber(hex:sub(3,4), 16) or 0) / 255
              local bb = (tonumber(hex:sub(5,6), 16) or 0) / 255
              rr = rr or 0; gg = gg or 0; bb = bb or 0
              ColorPickerFrame:SetColorRGB(rr, gg, bb)
            end
          end
          hexBox:SetScript('OnTextChanged', function(self, user)
            if not user then return end
            local hex = (self:GetText() or ''):gsub('#', ''):upper()
            if #hex == 6 and hex:match('^%x%x%x%x%x%x$') then
              updateColorFromHex()
            end
          end)
          hexBox:SetScript('OnEnterPressed', function(self)
            self:ClearFocus()
          end)

          inputs.hex = hexBox

          -- Attempt to find the default top-right preview texture and replace it
          local preview
          for _, region in pairs({ColorPickerFrame:GetRegions()}) do
            if region and region:IsObjectType('Texture') then
              local w = (region.GetWidth and region.GetWidth(region)) or 0
              local h = (region.GetHeight and region.GetHeight(region)) or 0
              if w >= 18 and w <= 48 and math.abs(w - h) <= 6 then
                -- hide original preview region and reparent preview to same anchor
                local p, rel, rp, ox, oy = region:GetPoint()
                region:Hide()
                preview = ColorPickerFrame:CreateTexture(nil, 'ARTWORK')
                preview:SetSize(w, h)
                if p then
                  preview:ClearAllPoints()
                  preview:SetPoint(p, rel or ColorPickerFrame, rp or p, ox or 0, oy or 0)
                else
                  preview:SetPoint('RIGHT', inputs, 'RIGHT', -8, 0)
                end
                break
              end
            end
          end
          if not preview then
            preview = inputs:CreateTexture(nil, 'ARTWORK')
            preview:SetSize(28, 28)
            preview:SetPoint('RIGHT', inputs, 'RIGHT', -8, 0)
          end
          if preview.SetColorTexture then
            preview:SetColorTexture(1, 1, 1, 1)
          else
            preview:SetTexture('Interface\\Buttons\\WHITE8X8')
            preview:SetVertexColor(1, 1, 1, 1)
          end
          inputs.preview = preview

          ColorPickerFrame.__UHC_Inputs = inputs
          ColorPickerFrame.__UHC_InputsCreated = true
          -- try repositioning the default OK/Cancel buttons to sit below our inputs
          -- find likely OK/Cancel buttons among children
          local okBtn, cancelBtn
          for _, child in pairs({ColorPickerFrame:GetChildren()}) do
            if child and child:IsObjectType('Button') and child.GetText then
              local t = child:GetText() or ''
              if t == 'Okay' or t == 'OK' then okBtn = child end
              if t == 'Cancel' then cancelBtn = child end
            end
          end
          if okBtn and cancelBtn then
            okBtn:ClearAllPoints()
            cancelBtn:ClearAllPoints()
            okBtn:SetPoint('TOP', inputs, 'BOTTOM', -70, 12)
            cancelBtn:SetPoint('TOP', inputs, 'BOTTOM', 70, 12)
          end
        end

        -- update function to sync picker -> inputs/preview
        local function updateInputs()
          local rr, gg, bb = ColorPickerFrame:GetColorRGB()
          rr = rr or 0; gg = gg or 0; bb = bb or 0
          local inputs = ColorPickerFrame.__UHC_Inputs
          if inputs and inputs.rgb then
            for i, box in ipairs(inputs.rgb) do
              local val = math.floor((i == 1 and rr or i == 2 and gg or bb) * 255 + 0.5)
              box:SetText(tostring(val))
            end
            inputs.hex:SetText(string.format('%02X%02X%02X', math.floor(rr * 255 + 0.5), math.floor(gg * 255 + 0.5), math.floor(bb * 255 + 0.5)))
            local pv = inputs.preview
            if pv then
              if pv.SetColorTexture then
                pv:SetColorTexture(rr, gg, bb, 1)
              else
                pv:SetVertexColor(rr, gg, bb, 1)
              end
            end
          end
        end

        -- chain existing OnColorSelect
        local oldOnColorSelect = ColorPickerFrame:GetScript('OnColorSelect')
        ColorPickerFrame:SetScript('OnColorSelect', function(self)
          if oldOnColorSelect then pcall(oldOnColorSelect, self) end
          pcall(updateInputs)
        end)

        -- assign picker callbacks to keep original behavior and sync inputs
        ColorPickerFrame.func = function()
          onColorPicked()
          pcall(updateInputs)
        end
        ColorPickerFrame.swatchFunc = function()
          pcall(onColorPicked)
          pcall(updateInputs)
        end
        ColorPickerFrame.cancelFunc = onCancel
        ColorPickerFrame.previousValues = { r = r, g = g, b = b }

        r = r or 0; g = g or 0; b = b or 0
        ColorPickerFrame:SetColorRGB(r, g, b)
        pcall(updateInputs)
        ColorPickerFrame:Show()
      end
    end)

    resetButton:SetScript('OnClick', function()
      tempSettings.resourceBarColors[powerKey] = nil
      local dr, dg, db = getDefaultColor()
      setSwatchColor(dr, dg, db)
    end)

    table.insert(colorRows, row)
  end

  createColorRowInSection('Energy', 'ENERGY', 1)
  createColorRowInSection('Rage', 'RAGE', 2)
  createColorRowInSection('Mana', 'MANA', 3)
  createColorRowInSection('Pet', 'PET', 4, { 0.5, 0, 1 })
  createColorRowInSection('XP Bar', 'EXPBAR', 5, { 0.0, 0.4, 1.0 })

  -- Subheaders and additional fields consolidated under this single collapsible section
  local SUBHEADER_GAP = 12
  local SUBHEADER_FONT = 'GameFontNormal'

  -- Statistics Background subheader
  local statsSubHeader = colorSectionFrame:CreateFontString(nil, 'OVERLAY', SUBHEADER_FONT)
  statsSubHeader:SetPoint('TOPLEFT', colorSectionFrame, 'TOPLEFT', 6, -(COLOR_ROWS_TOP_OFFSET + (#colorRows * ROW_HEIGHT) + SUBHEADER_GAP))
  statsSubHeader:SetText('Statistics Background')
  statsSubHeader:SetTextColor(1, 0.85, 0.4)

  local opacityRow = CreateFrame('Frame', nil, colorSectionFrame)
  opacityRow:SetSize(380, 24)
  opacityRow:SetPoint('TOPLEFT', statsSubHeader, 'BOTTOMLEFT', 14, -6)

  local LABEL_WIDTH = 140
  local GAP = 12

  local opacityLabel = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  opacityLabel:SetPoint('LEFT', opacityRow, 'LEFT', 0, 0)
  opacityLabel:SetWidth(LABEL_WIDTH)
  opacityLabel:SetJustifyH('LEFT')
  opacityLabel:SetText('Opacity')

  if tempSettings.statisticsBackgroundOpacity == nil then
    tempSettings.statisticsBackgroundOpacity = GLOBAL_SETTINGS.statisticsBackgroundOpacity or 0.3
  end

  local percentText = opacityRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  percentText:SetPoint('LEFT', opacityRow, 'LEFT', LABEL_WIDTH + GAP, 0)
  percentText:SetWidth(40)
  percentText:SetJustifyH('LEFT')
  percentText:SetText(tostring(math.floor((tempSettings.statisticsBackgroundOpacity or 0.3) * 100)) .. '%')

  local slider = CreateFrame('Slider', nil, opacityRow, 'OptionsSliderTemplate')
  slider:SetPoint('LEFT', percentText, 'RIGHT', 10, 0)
  slider:SetSize(180, 16)
  slider:SetMinMaxValues(0, 100)
  slider:SetValueStep(1)
  slider:SetObeyStepOnDrag(true)
  slider:SetValue((tempSettings.statisticsBackgroundOpacity or 0.3) * 100)
  if slider.Low then slider.Low:SetText('0%') end
  if slider.High then slider.High:SetText('100%') end
  if slider.Text then slider.Text:SetText('') end

  slider:SetScript('OnValueChanged', function(self, val)
    local pct = math.floor(val + 0.5)
    percentText:SetText(pct .. '%')
    tempSettings.statisticsBackgroundOpacity = pct / 100
  end)

  -- Minimap Clock Scale subheader
  local clockSubHeader = colorSectionFrame:CreateFontString(nil, 'OVERLAY', SUBHEADER_FONT)
  clockSubHeader:SetPoint('TOPLEFT', opacityRow, 'BOTTOMLEFT', -14, -12)
  clockSubHeader:SetText('Minimap Clock Scale')
  clockSubHeader:SetTextColor(1, 0.85, 0.4)

  local minimapClockScaleRow = CreateFrame('Frame', nil, colorSectionFrame)
  minimapClockScaleRow:SetSize(380, 24)
  minimapClockScaleRow:SetPoint('TOPLEFT', clockSubHeader, 'BOTTOMLEFT', 14, -6)

  local LABEL_WIDTH2 = 140
  local GAP2 = 12

  local minimapClockScaleLabel = minimapClockScaleRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  minimapClockScaleLabel:SetPoint('LEFT', minimapClockScaleRow, 'LEFT', 0, 0)
  minimapClockScaleLabel:SetWidth(LABEL_WIDTH2)
  minimapClockScaleLabel:SetJustifyH('LEFT')
  minimapClockScaleLabel:SetText('Minimap Clock Scale')

  if tempSettings.minimapClockScale == nil then
    tempSettings.minimapClockScale = GLOBAL_SETTINGS.minimapClockScale or 1.0
  end

  local minimapClockScalePercentText = minimapClockScaleRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  minimapClockScalePercentText:SetPoint('LEFT', minimapClockScaleRow, 'LEFT', LABEL_WIDTH2 + GAP2, 0)
  minimapClockScalePercentText:SetWidth(40)
  minimapClockScalePercentText:SetJustifyH('LEFT')
  minimapClockScalePercentText:SetText(tostring(math.floor((tempSettings.minimapClockScale or 1.0) * 100)) .. '%')

  local minimapClockScaleSlider = CreateFrame('Slider', nil, minimapClockScaleRow, 'OptionsSliderTemplate')
  minimapClockScaleSlider:SetPoint('LEFT', minimapClockScalePercentText, 'RIGHT', 10, 0)
  minimapClockScaleSlider:SetSize(180, 16)
  minimapClockScaleSlider:SetMinMaxValues(10, 20)
  minimapClockScaleSlider:SetValueStep(1)
  minimapClockScaleSlider:SetObeyStepOnDrag(true)
  minimapClockScaleSlider:SetValue(math.floor(((tempSettings.minimapClockScale or 1.0) * 10) + 0.5))
  if minimapClockScaleSlider.Low then minimapClockScaleSlider.Low:SetText('100%') end
  if minimapClockScaleSlider.High then minimapClockScaleSlider.High:SetText('200%') end
  if minimapClockScaleSlider.Text then minimapClockScaleSlider.Text:SetText('') end

  minimapClockScaleSlider:SetScript('OnValueChanged', function(self, val)
    local steps = math.floor(val + 0.5)
    minimapClockScalePercentText:SetText((steps * 10) .. '%')
    tempSettings.minimapClockScale = steps / 10
  end)

  -- Expanded height now includes resource subheader + color rows + other subheaders + two rows
  local colorExpandedHeight = HEADER_HEIGHT + HEADER_CONTENT_GAP + 18 + SUBHEADER_TO_ROWS_GAP + (#colorRows * ROW_HEIGHT) + 12 + 18 + 8 + 24 + 12 + 18 + 8 + 24 + 8
  local colorCollapsedHeight = HEADER_HEIGHT
  -- Initial collapsed state (default collapsed) using unified key
  local colorCollapsed = GLOBAL_SETTINGS.collapsedSettingsSections.uiColour
  if colorCollapsed == nil then
    colorCollapsed = GLOBAL_SETTINGS.collapsedSettingsSections.resourceBarColors
    if colorCollapsed == nil then colorCollapsed = true end
  end
  colorHeaderIcon:SetTexture(colorCollapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up')
  resourceSubHeader:SetShown(not colorCollapsed)
  for _, r in ipairs(colorRows) do r:SetShown(not colorCollapsed) end
  statsSubHeader:SetShown(not colorCollapsed)
  opacityRow:SetShown(not colorCollapsed)
  clockSubHeader:SetShown(not colorCollapsed)
  minimapClockScaleRow:SetShown(not colorCollapsed)
  colorSectionFrame:SetHeight(colorCollapsed and colorCollapsedHeight or colorExpandedHeight)
  colorHeaderButton:SetScript('OnClick', function()
    colorCollapsed = not colorCollapsed
    colorHeaderIcon:SetTexture(colorCollapsed and 'Interface\\Buttons\\UI-PlusButton-Up' or 'Interface\\Buttons\\UI-MinusButton-Up')
    resourceSubHeader:SetShown(not colorCollapsed)
    for _, r in ipairs(colorRows) do r:SetShown(not colorCollapsed) end
    statsSubHeader:SetShown(not colorCollapsed)
    opacityRow:SetShown(not colorCollapsed)
    clockSubHeader:SetShown(not colorCollapsed)
    minimapClockScaleRow:SetShown(not colorCollapsed)
    colorSectionFrame:SetHeight(colorCollapsed and colorCollapsedHeight or colorExpandedHeight)
    GLOBAL_SETTINGS.collapsedSettingsSections.uiColour = colorCollapsed
    if SaveCharacterSettings then SaveCharacterSettings(GLOBAL_SETTINGS) end
    if recalcContentHeight then recalcContentHeight() end
  end)

  -- Recalculate scroll child height so the scrollbar reflects current content
  recalcContentHeight = function()
    local total = 10 -- top padding
    local SECTION_GAP = 10
    for i, sf in ipairs(sectionFrames) do
      if i > 1 then total = total + SECTION_GAP end
      total = total + (sf:GetHeight() or 0)
    end
    -- Gaps between major UI sections
    total = total + SECTION_GAP + (colorSectionFrame:GetHeight() or 0)
    total = total + 20 -- bottom padding
    scrollChild:SetHeight(total)
  end

  -- Make recalc accessible to search filter
  _G.__UHC_RecalcContentHeight = recalcContentHeight

  -- Initial recalculation after building UI
  if recalcContentHeight then recalcContentHeight() end
end

