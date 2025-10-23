local addonName = 'UHC'
local panel
local slots = {}
local slotSpellData = {}

local MAX_SLOTS = 8
local SLOT_SIZE = 38
local PADDING = 3
local GAP = 3
local EMPTY_TEXTURE = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"

-- Configuration options
local PROFESSION_PANEL_CONFIG = {
  enabled = true,
  slotsPerRow = 4,
  maxSlots = MAX_SLOTS,
  showPanel = true
}

-- Apprentice, Journeyman, Expert, Artisan
local allowedSpells = {
  { 8690, 556 },                 -- Hearthstone, Astral Recall
  { 3273, 3274, 7924, 10846 },   -- First Aid
  { 7620, 7731, 7732, 18248 },   -- Fishing
  { 2550, 3102, 3413, 18260 },   -- Cooking
  818,                           -- Campfire
  { 2259, 3101, 3464, 11611 },   -- Alchemy
  2366,                          -- Herb Gathering
  2580,                          -- Find Minerals
  { 4036, 4037, 4038, 12656 },   -- Engineering
  { 2018, 3100, 3538, 9785 },    -- Blacksmithing
  2656,                          -- Smelting
  { 2108, 3104, 3811, 10662 },   -- Leatherworking
  8613,                          -- Skinning
  { 7411, 7412, 7413, 13920 },   -- Enchanting
  13262,                         -- Disenchanting
  { 3908, 3909, 3910, 12180 },   -- Tailoring
  { 6991, 883, 982 },            -- Hunter Spells? Feed, Call, Revive?
  { 19902, 19029, 13335, 19872, 21176, 2411, 13086, 19030, 2414,
    5655, 5656, 8632, 20221, 18242, 8631, 18778, 8629, 18766, 18902,
    18246, 18777, 18247, 18241, 18776, 13331, 13325, 18767, 18245,
    21321, 12353, 13332, 5665, 5668, 8591, 18791, 8588, 21218, 18798,
    18244, 23720, 1132, 13333, 18248, 8592, 12303, 18790, 14062, 13317,
    5864, 12302, 8627, 18797, 8630, 15290, 5872, 13334, 21736, 18768,
    8595, 12354, 16344, 13322, 15277, 18788, 18796, 2413, 2415, 5873,
    18785, 21324, 13328, 18789, 13324, 18786, 18787, 23193, 13326,
    8563, 15292, 18243, 8583, 13329, 18795, 8590, 13327, 18772, 18793,
    18794, 12325, 12351, 16339, 901, 8586, 12327, 5874, 5875, 18773,
    18774, 21323, 13321, 15293, 16343, 12326, 12330, 8589, 16338,
    5663, 1134, 1133, 1041, 8633, 875, 8628, 13323 }, -- Mounts
}

local function IsAllowedSpell(spellId)
  for _, entry in ipairs(allowedSpells) do
    if type(entry) == "table" then
      for _, id in ipairs(entry) do
        if id == spellId then
          return true
        end
      end
    elseif entry == spellId then
      return true
    end
  end
  return false
end

local function IsTracked(i)
  local slot = slots[i]
  return slot and slot.spellId ~= nil
end

local function TrackedCount()
  local n = 0
  for i = 1, MAX_SLOTS do
    if IsTracked(i) then n = n + 1 end
  end
  return n
end

local function FirstEmptyIndex()
  for i = 1, MAX_SLOTS do
    if not IsTracked(i) then return i end
  end
end

local function LoadConfig()
  if not UltraHardcoreDB then UltraHardcoreDB = {} end
  local guid = UnitGUID("player") or "unknown"
  if not UltraHardcoreDB[guid] then UltraHardcoreDB[guid] = {} end
  if not UltraHardcoreDB[guid].ProfessionPanel then UltraHardcoreDB[guid].ProfessionPanel = {} end
  local db = UltraHardcoreDB[guid].ProfessionPanel
  
  -- Load configuration with defaults
  PROFESSION_PANEL_CONFIG.enabled = db.enabled ~= nil and db.enabled or true
  PROFESSION_PANEL_CONFIG.slotsPerRow = db.slotsPerRow or 4
  PROFESSION_PANEL_CONFIG.maxSlots = db.maxSlots or MAX_SLOTS
  PROFESSION_PANEL_CONFIG.showPanel = db.showPanel ~= nil and db.showPanel or true
end

local function SaveConfig()
  if not UltraHardcoreDB then UltraHardcoreDB = {} end
  local guid = UnitGUID("player") or "unknown"
  if not UltraHardcoreDB[guid] then UltraHardcoreDB[guid] = {} end
  if not UltraHardcoreDB[guid].ProfessionPanel then UltraHardcoreDB[guid].ProfessionPanel = {} end
  local db = UltraHardcoreDB[guid].ProfessionPanel
  
  db.enabled = PROFESSION_PANEL_CONFIG.enabled
  db.slotsPerRow = PROFESSION_PANEL_CONFIG.slotsPerRow
  db.maxSlots = PROFESSION_PANEL_CONFIG.maxSlots
  db.showPanel = PROFESSION_PANEL_CONFIG.showPanel
end

local function SaveData()
  if not UltraHardcoreDB then UltraHardcoreDB = {} end
  local guid = UnitGUID("player") or "unknown"
  if not UltraHardcoreDB[guid] then UltraHardcoreDB[guid] = {} end
  if not UltraHardcoreDB[guid].ProfessionPanel then UltraHardcoreDB[guid].ProfessionPanel = {} end
  local db = UltraHardcoreDB[guid].ProfessionPanel

  if panel then
    local point, _, _, x, y = panel:GetPoint()
    db.position = { point = point, x = x, y = y }
  end

  db.slots = {}
  for i = 1, MAX_SLOTS do
    local s = slotSpellData[i]
    if s and s.spellId then
      db.slots[i] = { spellId = s.spellId, spellName = s.spellName }
    end
  end
  
  SaveConfig()
end

local function ClearSlot(i)
  local slot = slots[i]
  if not slot then return end
  
  if not InCombatLockdown() then
    slot:SetAttribute("type", nil)
    slot:SetAttribute("spell", nil)
  end

  slot.spellId = nil
  slot.spellName = nil
  slot:SetNormalTexture(EMPTY_TEXTURE)
  slot:SetPushedTexture(EMPTY_TEXTURE)
end

local function UpdateSlot(i, spellId, spellName, spellIcon)
  local slot = slots[i]
  if not slot then return end

  slot.spellId = spellId
  slot.spellName = spellName

  -- Icon
  local tex = spellIcon or EMPTY_TEXTURE
  slot:SetNormalTexture(tex)
  slot:SetPushedTexture(tex)

  if not InCombatLockdown() then
    if spellId and spellName then
      slot:SetAttribute("type", "spell")
      slot:SetAttribute("spell", spellName)
    else
      slot:SetAttribute("type", nil)
      slot:SetAttribute("spell", nil)
    end
  end

  -- Tooltip
  slot:SetScript("OnEnter", function(self)
    if self.spellId then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetSpellByID(self.spellId)
      GameTooltip:Show()
    else
      GameTooltip:Hide()
    end
  end)
end

local function VisibleSlotsDesired()
  local desired = TrackedCount() + 1
  if desired < 1 then desired = 1 end
  if desired > PROFESSION_PANEL_CONFIG.maxSlots then desired = PROFESSION_PANEL_CONFIG.maxSlots end
  return desired
end

local function Relayout()
  if not panel then return end

  local visible = VisibleSlotsDesired()
  local slotsPerRow = PROFESSION_PANEL_CONFIG.slotsPerRow
  local rows = math.ceil(visible / slotsPerRow)
  
  local x = PADDING
  local y = -PADDING
  
  for i = 1, MAX_SLOTS do
    local slot = slots[i]
    if i <= visible and i <= PROFESSION_PANEL_CONFIG.maxSlots then
      slot:ClearAllPoints()
      
      local row = math.ceil(i / slotsPerRow) - 1
      local col = ((i - 1) % slotsPerRow)
      
      local slotX = PADDING + (col * (SLOT_SIZE + GAP))
      local slotY = -PADDING - (row * (SLOT_SIZE + GAP))
      
      slot:SetPoint("TOPLEFT", panel, "TOPLEFT", slotX, slotY)
      slot:Show()
    else
      slot:Hide()
    end
  end

  local innerWidth = (math.min(visible, slotsPerRow) * SLOT_SIZE) + ((math.min(visible, slotsPerRow) - 1) * GAP)
  local innerHeight = (rows * SLOT_SIZE) + ((rows - 1) * GAP)
  
  panel:SetWidth(PADDING * 2 + innerWidth)
  panel:SetHeight(PADDING * 2 + innerHeight)
  panel:Show()
end

local function RefreshLayout(isInitialLoad)
  if not panel then return end

  if not isInitialLoad then
    local write = 1
    for read = 1, MAX_SLOTS do
      if slotSpellData[read] and slotSpellData[read].spellId then
        if write ~= read then
          local sSrc = slots[read]
          local texObj = sSrc and sSrc:GetNormalTexture()
          local tex = texObj and texObj:GetTexture() or EMPTY_TEXTURE
          UpdateSlot(write, slotSpellData[read].spellId, slotSpellData[read].spellName, tex)
          slotSpellData[write] = slotSpellData[read]
          ClearSlot(read)
          slotSpellData[read] = nil
        end
        write = write + 1
        if write > PROFESSION_PANEL_CONFIG.maxSlots then break end
      end
    end
    for i = write, MAX_SLOTS do
      ClearSlot(i)
      slotSpellData[i] = nil
    end
    SaveData()
  end

  Relayout()
end

local function LoadData()
  LoadConfig()
  
  if not UltraHardcoreDB then UltraHardcoreDB = {} end
  local guid = UnitGUID("player") or "unknown"
  local db = UltraHardcoreDB[guid] and UltraHardcoreDB[guid].ProfessionPanel

  if panel and db and db.position then
    local pos = db.position
    panel:ClearAllPoints()
    panel:SetPoint(pos.point or "CENTER", UIParent, pos.point or "CENTER", pos.x or 0, pos.y or 0)
  end

  for i = 1, MAX_SLOTS do
    ClearSlot(i)
    slotSpellData[i] = nil
  end

  if db and db.slots then
    local j = 1
    for i = 1, MAX_SLOTS do
      local data = db.slots[i]
      if data and IsAllowedSpell(data.spellId) then
        local spellName, _, spellIcon = GetSpellInfo(data.spellId)
        spellName = spellName or data.spellName
        if spellName then
          UpdateSlot(j, data.spellId, spellName, spellIcon)
          slotSpellData[j] = { spellId = data.spellId, spellName = spellName }
          j = j + 1
          if j > MAX_SLOTS then break end
        end
      end
    end
  end

  RefreshLayout(true)
  SaveData()
end


local function TrackSpell(slotIndex)
  if InCombatLockdown() then
    print(addonName .. ": Can't change bar in combat.")
    ClearCursor()
    return
  end
  local infoType, spellBookId, _, spellId = GetCursorInfo()
  if infoType ~= "spell" or not spellId then return end

  if not IsAllowedSpell(spellId) then
    print(addonName .. ": Only profession spells are allowed (e.g., Smelting, Alchemy).")
    return
  end

  ClearCursor()
  local spellName, _, spellIcon = GetSpellInfo(spellId)
  if not spellName then return end

  local target = IsTracked(slotIndex) and slotIndex or FirstEmptyIndex() or slotIndex
  UpdateSlot(target, spellId, spellName, spellIcon)
  slotSpellData[target] = { spellId = spellId, spellName = spellName }

  RefreshLayout(false)
  SaveData()
end

local function StartDraggingFrame(self)
  if IsMouseButtonDown("LeftButton") then
    self:StartMoving()
  end
end

local function StopDraggingFrame(self)
  if self and self.StopMovingOrSizing then
    self:StopMovingOrSizing()
    SaveData()
  end
end

local function StartDraggingSpell(self)
  if InCombatLockdown() then return end
  if not self.spellId then return end
  if IsMouseButtonDown("LeftButton") and self.spellId then
    PickupSpell(self.spellId)
    ClearSlot(self:GetID())
    slotSpellData[self:GetID()] = nil
    RefreshLayout(false)
    SaveData()
  end
end

local function OnSlotMouseDown(self, button)
  if button == "LeftButton" and not self.spellId then
    local parent = self:GetParent()
    if parent and parent.StartMoving then
      parent:StartMoving()
    end
  end
end

local function OnSlotMouseUp(self, button)
  if button == "LeftButton" and not self.spellId then
    local parent = self:GetParent()
    StopDraggingFrame(parent)
    TrackSpell(self:GetID())
  end
end

local function OnSlotReceiveDrag(self)
  if not self:IsShown() then return end
  TrackSpell(self:GetID())
end

local function CreateProfessionPanel()
  panel = CreateFrame("Frame", addonName .. "_Panel", UIParent, "BackdropTemplate")
  panel:SetSize(180, 48)
  panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  panel:SetMovable(true)
  panel:EnableMouse(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", function(self)
    local mouseX, mouseY = GetCursorPosition()
    local scale = self:GetEffectiveScale()
    mouseX, mouseY = mouseX / scale, mouseY / scale
    local isOverSlot = false
    for i = 1, MAX_SLOTS do
      local slot = slots[i]
      if slot:IsShown() and slot.spellId then
        local left, bottom, width, height = slot:GetRect()
        if mouseX >= left and mouseX <= left + width and mouseY >= bottom and mouseY <= bottom + height then
          isOverSlot = true
          break
        end
      end
    end
    if not isOverSlot then
      StartDraggingFrame(self)
    end
  end)
  panel:SetScript("OnDragStop", StopDraggingFrame)
  panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  panel:SetFrameStrata("MEDIUM")
  panel:Show()

  for i = 1, MAX_SLOTS do
    local slot = CreateFrame("Button", addonName .. "_Slot" .. i, panel, "SecureActionButtonTemplate")
    slots[i] = slot
    slot:SetID(i)
    slot:SetSize(SLOT_SIZE, SLOT_SIZE)
    slot:SetNormalTexture(EMPTY_TEXTURE)
    slot:SetPushedTexture(EMPTY_TEXTURE)
    slot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    slot:SetFrameStrata("MEDIUM")

    slot:RegisterForClicks("AnyUp")
    slot:RegisterForDrag("LeftButton")

    slot:SetScript("OnMouseDown", OnSlotMouseDown)
    slot:SetScript("OnMouseUp", OnSlotMouseUp)
    slot:SetScript("OnReceiveDrag", OnSlotReceiveDrag)
    slot:SetScript("OnDragStart", StartDraggingSpell)
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end

  LoadData()
end

local function UpdatePanelVisibility()
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.hideActionBars and PROFESSION_PANEL_CONFIG.enabled and PROFESSION_PANEL_CONFIG.showPanel then
    if not panel then
      CreateProfessionPanel()
    else
      panel:Show()
    end
  else
    if panel then
      panel:Hide()
    end
  end
end

-- Global function to update panel visibility (called from main addon)
function UpdateProfessionPanelVisibility()
  UpdatePanelVisibility()
end

-- Function to reset panel position to center
local function ResetPanelPosition()
  if panel then
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    SaveData()
  end
end

-- Configuration dialog
local configFrame = nil

local function CreateConfigDialog()
  if configFrame then
    configFrame:Show()
    return
  end

  configFrame = CreateFrame("Frame", "UHC_ProfessionPanelConfig", UIParent, "BackdropTemplate")
  configFrame:SetSize(400, 300)
  configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  configFrame:SetMovable(true)
  configFrame:EnableMouse(true)
  configFrame:RegisterForDrag("LeftButton")
  configFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  configFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  configFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  configFrame:SetFrameStrata("DIALOG")
  configFrame:SetFrameLevel(20)

  -- Title
  local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", configFrame, "TOP", 0, -15)
  title:SetText("Profession Panel Configuration")

  -- Enable checkbox
  local enableCheckbox = CreateFrame("CheckButton", nil, configFrame, "ChatConfigCheckButtonTemplate")
  enableCheckbox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -50)
  enableCheckbox.Text:SetText("Enable Profession Panel")
  enableCheckbox.Text:SetPoint("LEFT", enableCheckbox, "RIGHT", 5, 0)
  enableCheckbox:SetChecked(PROFESSION_PANEL_CONFIG.enabled)
  enableCheckbox:SetScript("OnClick", function(self)
    PROFESSION_PANEL_CONFIG.enabled = self:GetChecked()
    SaveConfig()
    UpdatePanelVisibility()
  end)

  -- Show panel checkbox
  local showCheckbox = CreateFrame("CheckButton", nil, configFrame, "ChatConfigCheckButtonTemplate")
  showCheckbox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -80)
  showCheckbox.Text:SetText("Show Panel")
  showCheckbox.Text:SetPoint("LEFT", showCheckbox, "RIGHT", 5, 0)
  showCheckbox:SetChecked(PROFESSION_PANEL_CONFIG.showPanel)
  showCheckbox:SetScript("OnClick", function(self)
    PROFESSION_PANEL_CONFIG.showPanel = self:GetChecked()
    SaveConfig()
    UpdatePanelVisibility()
  end)

  -- Layout section
  local layoutLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  layoutLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -120)
  layoutLabel:SetText("Layout Configuration:")

  -- Columns input
  local columnsLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  columnsLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -140)
  columnsLabel:SetText("Columns:")

  local columnsEditBox = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
  columnsEditBox:SetSize(60, 20)
  columnsEditBox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 100, -140)
  columnsEditBox:SetText(tostring(PROFESSION_PANEL_CONFIG.slotsPerRow))
  columnsEditBox:SetAutoFocus(false)
  columnsEditBox:SetScript("OnTextChanged", function(self)
    local value = tonumber(self:GetText())
    if value and value >= 1 and value <= 8 then
      PROFESSION_PANEL_CONFIG.slotsPerRow = value
      SaveConfig()
      if panel then
        Relayout()
      end
    end
  end)

  -- Max slots slider
  local slotsLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  slotsLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -170)
  slotsLabel:SetText("Total Slots:")

  local slotsSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
  slotsSlider:SetSize(200, 20)
  slotsSlider:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -190)
  slotsSlider:SetMinMaxValues(1, MAX_SLOTS)
  slotsSlider:SetValue(PROFESSION_PANEL_CONFIG.maxSlots)
  slotsSlider:SetValueStep(1)
  slotsSlider:SetScript("OnValueChanged", function(self, value)
    PROFESSION_PANEL_CONFIG.maxSlots = math.floor(value)
    self:GetParent().slotsValue:SetText(tostring(PROFESSION_PANEL_CONFIG.maxSlots))
    SaveConfig()
    if panel then
      Relayout()
    end
  end)

  -- Slider value display
  local slotsValue = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  slotsValue:SetPoint("LEFT", slotsSlider, "RIGHT", 10, 0)
  slotsValue:SetText(tostring(PROFESSION_PANEL_CONFIG.maxSlots))
  configFrame.slotsValue = slotsValue

  -- Close button
  local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
  closeButton:SetSize(100, 25)
  closeButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 15)
  closeButton:SetText("Close")
  closeButton:SetScript("OnClick", function()
    configFrame:Hide()
  end)

  -- Reset button
  local resetButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
  resetButton:SetSize(120, 25)
  resetButton:SetPoint("BOTTOM", configFrame, "BOTTOM", -70, 15)
  resetButton:SetText("Reset Position")
  resetButton:SetScript("OnClick", function()
    ResetPanelPosition()
  end)

  configFrame:Show()
end

-- Global function to open config dialog
function OpenProfessionPanelConfig()
  LoadConfig()
  CreateConfigDialog()
end

-- Event registration
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    UpdatePanelVisibility()
  elseif event == "ADDON_LOADED" then
    UpdatePanelVisibility()
  end
end)





