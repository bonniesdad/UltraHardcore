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

local function updateRadioButtons()
  for settingName, radio in pairs(radioButtons) do
    if radio then
      local isChecked = tempSettings[settingName] or false
      radio:SetChecked(isChecked)
      GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
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
