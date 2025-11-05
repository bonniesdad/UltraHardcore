-- ChallengesTab.lua
-- UI for the Challenges tab

local ADDON_NAME, ns = ...
local Challenges = ns.Challenges

local widgets = {}

local function setEnabled(frame, enabled)
  if not frame then return end
  if enabled then
    frame:Enable()
    frame:SetAlpha(1)
  else
    frame:Disable()
    frame:SetAlpha(0.5)
  end
end

local function refreshUI()
  local db = Challenges.GetState()
  if not widgets.container then return end

  -- Preset dropdown text
  local presetText = widgets.presetText
  if presetText then
    local preset = db.preset or "NONE"
    local name = Challenges.GetPresets()[preset] and Challenges.GetPresets()[preset].name or "None"
    presetText:SetText("Preset: "..name)
  end

  -- Checkboxes
  if widgets.chkNoGrouping then widgets.chkNoGrouping:SetChecked(db.rules.noGrouping) end
  if widgets.chkNoEconomy then widgets.chkNoEconomy:SetChecked(db.rules.noExternalEconomy) end
  if widgets.chkDeathFails then widgets.chkDeathFails:SetChecked(db.rules.deathFails) end

  -- Lock state & level 1 restriction
  local canEdit = (not db.locked) and (UnitLevel("player") <= 1)
  setEnabled(widgets.btnPresetNone,   canEdit)
  setEnabled(widgets.btnPresetSSF,    canEdit)
  setEnabled(widgets.btnPresetIron,   canEdit)
  setEnabled(widgets.chkNoGrouping,   canEdit)
  setEnabled(widgets.chkNoEconomy,    canEdit)
  setEnabled(widgets.chkDeathFails,   canEdit)
  setEnabled(widgets.btnLock,         (not db.locked) and (UnitLevel("player") <= 1))

  widgets.statusText:SetText(Challenges.GetSummaryText())
end

local function makeButton(parent, label, width, height, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width, height)
  b:SetText(label)
  b:SetScript("OnClick", onClick)
  return b
end

local function makeCheckbox(parent, label, onClick)
  local c = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  c.Text:SetText(label)
  c:SetScript("OnClick", onClick)
  return c
end

function InitializeChallengesTab()
  local content = TabManager.getTabContent(6)
  if widgets.container then
    refreshUI()
    content:Show()
    return
  end

  local container = CreateFrame("Frame", nil, content)
  container:SetSize(500, 520)
  container:SetPoint("TOP", content, "TOP", 0, -10)
  widgets.container = container

  -- Title
  local title = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -10)
  title:SetText("Challenges")
  
  -- Status / summary
  local statusText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  statusText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
  widgets.statusText = statusText

  -- Preset row
  local presetLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  presetLabel:SetPoint("TOPLEFT", statusText, "BOTTOMLEFT", 0, -14)
  presetLabel:SetText("Presets:")

  local btnNone = makeButton(container, "None", 80, 22, function()
    Challenges.SetPreset("NONE"); refreshUI()
  end)
  btnNone:SetPoint("LEFT", presetLabel, "RIGHT", 10, 0)
  widgets.btnPresetNone = btnNone

  local btnSSF = makeButton(container, "Solo Self-Found", 140, 22, function()
    Challenges.SetPreset("SOLO_SELF_FOUND"); refreshUI()
  end)
  btnSSF:SetPoint("LEFT", btnNone, "RIGHT", 8, 0)
  widgets.btnPresetSSF = btnSSF

  local btnIron = makeButton(container, "Ironman (Lite)", 140, 22, function()
    Challenges.SetPreset("IRON_LITE"); refreshUI()
  end)
  btnIron:SetPoint("LEFT", btnSSF, "RIGHT", 8, 0)
  widgets.btnPresetIron = btnIron

  local presetText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  presetText:SetPoint("LEFT", btnIron, "RIGHT", 10, 0)
  widgets.presetText = presetText

  -- Custom rules header
  local customHdr = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  customHdr:SetPoint("TOPLEFT", presetLabel, "BOTTOMLEFT", 0, -18)
  customHdr:SetText("Custom Rules (optional):")

  -- Checkboxes
  local chkNoGrouping = makeCheckbox(container, "No Grouping (party/raid)", function(self)
    Challenges.SetRule("noGrouping", self:GetChecked()); refreshUI()
  end)
  chkNoGrouping:SetPoint("TOPLEFT", customHdr, "BOTTOMLEFT", 6, -8)
  widgets.chkNoGrouping = chkNoGrouping

  local chkNoEconomy = makeCheckbox(container, "Self-Found: No Trade/Mail/AH/Bank", function(self)
    Challenges.SetRule("noExternalEconomy", self:GetChecked()); refreshUI()
  end)
  chkNoEconomy:SetPoint("TOPLEFT", chkNoGrouping, "BOTTOMLEFT", 0, -6)
  widgets.chkNoEconomy = chkNoEconomy

  local chkDeathFails = makeCheckbox(container, "Death fails the challenge", function(self)
    Challenges.SetRule("deathFails", self:GetChecked()); refreshUI()
  end)
  chkDeathFails:SetPoint("TOPLEFT", chkNoEconomy, "BOTTOMLEFT", 0, -6)
  widgets.chkDeathFails = chkDeathFails

  -- Lock button / hint
  local btnLock = makeButton(container, "Lock Now (Level 1 Only)", 220, 24, function()
    Challenges.LockChallenges(); refreshUI()
  end)
  btnLock:SetPoint("TOPLEFT", chkDeathFails, "BOTTOMLEFT", -6, -16)
  widgets.btnLock = btnLock

  local hint = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("TOPLEFT", btnLock, "BOTTOMLEFT", 0, -6)
  hint:SetText("You can choose presets or custom rules at level 1.\nThey will lock permanently at level 2 (or when you press Lock).")

  refreshUI()
  content:Show()
end
