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
}, {
  name = 'UHC Breath Indicator',
  dbSettingsValueName = 'hideBreathIndicator',
  tooltip = 'Replace the breath bar with a increasingly red screen overlay when underwater',
}, {
  -- Ultra Preset Settings
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
}, {
  -- Experimental Preset Settings
  name = 'UHC Incoming Crit Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
  tooltip = 'A red screen rotation effect appears when you take a critical hit',
}, {
  name = 'UHC Full Health Indicator',
  dbSettingsValueName = 'showFullHealthIndicator',
  tooltip = 'The edges of the screen glow when you are at full health',
}, {
  name = 'UHC Incoming Damage Effect',
  dbSettingsValueName = 'showIncomingDamageEffect',
  tooltip = 'Various screen effects on incoming damage',
}, {
  name = 'UHC Incoming Healing Effect',
  dbSettingsValueName = 'showHealingIndicator',
  tooltip = 'Gold glow on the edges of the screen when you are healed',
}, {
  name = 'First Person Camera',
  dbSettingsValueName = 'setFirstPersonCamera',
  tooltip = 'Play in first person mode, allows to look around for briew records of time',
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
} }

local presets = { {
  -- Preset 1: Lite
  hidePlayerFrame = true,
  hideMinimap = false,
  hideTargetFrame = false,
  hideTargetTooltip = false,
  showTunnelVision = true,
  tunnelVisionMaxStrata = false,
  showDazedEffect = false,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  hideGroupHealth = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = false,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  hideBreathIndicator = false,
  setFirstPersonCamera = false,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = false,
  showDazedEffect = true,
  hideGroupHealth = true,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = true,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  hideBreathIndicator = true,
  setFirstPersonCamera = false,
}, {
  -- Preset 3: Ultra
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  hideBreathIndicator = true,
  petsDiePermanently = true,
  showCritScreenMoveEffect = false,
  hideActionBars = true,
  showFullHealthIndicator = false,
  disableNameplateHealth = true,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  setFirstPersonCamera = false,
  newHighCritAppreciationSoundbite = true,
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

  local presetButtonsFrame = CreateFrame('Frame', nil, tabContents[2])
  presetButtonsFrame:SetSize(420, 150)
  presetButtonsFrame:SetPoint('TOP', tabContents[2], 'TOP', 0, -10)

  local checkboxes = {}
  local presetButtons = {}
  local selectedPreset = nil

  local function updateCheckboxes()
    for _, checkboxItem in ipairs(settingsCheckboxOptions) do
      local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
      if checkbox then
        checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])
      end
    end
  end

  local function applyPreset(presetIndex)
    if not presets[presetIndex] then return end

    for key, value in pairs(presets[presetIndex]) do
      tempSettings[key] = value
    end

    if tempSettings.hidePlayerFrame then
      SetCVar('statusText', '0')
    end

    updateCheckboxes()
    updateRadioButtons()

    if selectedPreset then
      selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5)
    end
    selectedPreset = presetButtons[presetIndex]
    selectedPreset:SetBackdropBorderColor(1, 1, 0)
  end

  local presetIcons =
    {
      'Interface\\AddOns\\UltraHardcore\\textures\\skull1_100_halloween.png',
      'Interface\\AddOns\\UltraHardcore\\textures\\skull2_100_halloween.png',
      'Interface\\AddOns\\UltraHardcore\\textures\\skull3_100_halloween.png',
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
      presetText:SetText('Ultra')
    end

    button:SetScript('OnClick', function()
      applyPreset(i)
    end)

    presetButtons[i] = button
  end

  local scrollFrame = CreateFrame('ScrollFrame', nil, tabContents[2], 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', tabContents[2], 'TOPLEFT', 10, -190)
  scrollFrame:SetPoint('BOTTOMRIGHT', tabContents[2], 'BOTTOMRIGHT', -30, 10)

  local scrollChild = CreateFrame('Frame')
  scrollFrame:SetScrollChild(scrollChild)
  local totalHeight = (5 * 25) + (#settingsCheckboxOptions * 30) + (5 * 10) + 40
  scrollChild:SetSize(420, totalHeight)

  function createCheckboxes()
    local yOffset = -10

    local presetSections = { {
      title = 'Lite:',
      settings = { 'hidePlayerFrame', 'showTunnelVision' },
    }, {
      title = 'Recommended:',
      settings = {
        'hideTargetFrame',
        'hideTargetTooltip',
        'disableNameplateHealth',
        'showDazedEffect',
        'hideGroupHealth',
        'hideMinimap',
        'hideBreathIndicator',
      },
    }, {
      title = 'Ultra:',
      settings = { 'petsDiePermanently', 'hideActionBars', 'tunnelVisionMaxStrata' },
    }, {
      title = 'Experimental:',
      settings = {
        'showCritScreenMoveEffect',
        'showFullHealthIndicator',
        'showIncomingDamageEffect',
        'showHealingIndicator',
        'setFirstPersonCamera',
      },
    }, {
      title = 'Misc:',
      settings = {
        'showOnScreenStatistics',
        'announceLevelUpToGuild',
        'hideUIErrors',
        'showClockEvenWhenMapHidden',
        'announcePartyDeathsOnGroupJoin',
        'announceDungeonsCompletedOnGroupJoin',
        'buffBarOnResourceBar',
        'newHighCritAppreciationSoundbite',
        'playPartyDeathSoundbite',
        'playPlayerDeathSoundbite',
        'spookyTunnelVision',
        'roachHearthstoneInPartyCombat',
      },
    } }

    for sectionIndex, section in ipairs(presetSections) do
      local sectionHeader = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      sectionHeader:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 10, yOffset)
      sectionHeader:SetText(section.title)
      sectionHeader:SetTextColor(1, 1, 0.5)
      yOffset = yOffset - 25

      for _, settingName in ipairs(section.settings) do
        local checkboxItem = nil
        for _, item in ipairs(settingsCheckboxOptions) do
          if item.dbSettingsValueName == settingName then
            checkboxItem = item
            break
          end
        end

        if checkboxItem then
          local checkbox =
            CreateFrame('CheckButton', nil, scrollChild, 'ChatConfigCheckButtonTemplate')
          checkbox:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 20, yOffset)
          checkbox.Text:SetText(checkboxItem.name)
          checkbox.Text:SetPoint('LEFT', checkbox, 'RIGHT', 5, 0)
          checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])

          checkboxes[checkboxItem.dbSettingsValueName] = checkbox

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
          end)

          checkbox:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText(checkboxItem.tooltip)
            GameTooltip:Show()
          end)

          checkbox:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
          end)

          yOffset = yOffset - 30
        end
      end

      yOffset = yOffset - 10
    end
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

    SaveCharacterSettings(GLOBAL_SETTINGS)
    ReloadUI()
  end)

  _G.updateCheckboxes = updateCheckboxes
  _G.updateRadioButtons = updateRadioButtons
  _G.applyPreset = applyPreset
  _G.createCheckboxes = createCheckboxes
  _G.checkboxes = checkboxes
  _G.presetButtons = presetButtons
  _G.selectedPreset = selectedPreset

  createCheckboxes()
end
