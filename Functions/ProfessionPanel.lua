local addonName = 'UHC'
local panel
local slots = {}
local slotSpellData = {}

local MAX_SLOTS = 8
local SLOT_SIZE = 38
local PADDING = 3
local GAP = 3
local EMPTY_TEXTURE = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"

-- Apprentice, Journeyman, Expert, Artisan
local ALLOWED_SPELLS = {
  -- First Aid
  [3273] = true, [3274] = true, [7924] = true, [10846] = true,
  -- Fishing
  [7620] = true, [7731] = true, [7732] = true, [18248] = true,
  -- Cooking
  [2550] = true, [3102] = true, [3413] = true, [18260] = true,
  -- Campfire
  [818]  = true,
  -- Alchemy
  [2259] = true, [3101] = true, [3464] = true, [11611] = true,
  -- Herb Gathering
  [2366] = true,
  -- Find Minerals
  [2580] = true,
  -- Engineering
  [4036] = true, [4037] = true, [4038] = true, [12656] = true,
  -- Blacksmithing
  [2018] = true, [3100] = true, [3538] = true, [9785]  = true,
  -- Smelting
  [2656] = true,
  -- Leatherworking
  [2108] = true, [3104] = true, [3811] = true, [10662] = true,
  -- Skinning
  [8613] = true,
  -- Enchanting
  [7411] = true, [7412] = true, [7413] = true, [13920] = true,
  -- Disenchanting
  [13262] = true,
  -- Tailoring
  [3908] = true, [3909] = true, [3910] = true, [12180] = true,
}

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
end

local function ClearSlot(i)
  local slot = slots[i]
  if not slot then return end
  slot.spellId = nil
  slot.spellName = nil
  slot:SetNormalTexture(EMPTY_TEXTURE)
  slot:SetPushedTexture(EMPTY_TEXTURE)
  slot:RegisterForDrag("LeftButton")
  slot:SetScript("OnEnter", function(self) GameTooltip:Hide() end)
end

local function UpdateSlot(i, spellId, spellName, spellIcon)
  local slot = slots[i]
  if not slot then return end

  slot.spellId = spellId
  slot.spellName = spellName

  local tex = spellIcon or EMPTY_TEXTURE
  slot:SetNormalTexture(tex)
  slot:SetPushedTexture(tex)
  slot:RegisterForDrag("LeftButton")

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
  if desired > MAX_SLOTS then desired = MAX_SLOTS end
  return desired
end

local function Relayout()
  if not panel then return end

  local visible = VisibleSlotsDesired()

  local x = PADDING
  for i = 1, MAX_SLOTS do
    local slot = slots[i]
    if i <= visible then
      slot:ClearAllPoints()
      slot:SetPoint("LEFT", panel, "LEFT", x, 0)
      slot:Show()
      x = x + SLOT_SIZE + GAP
    else
      slot:Hide()
    end
  end

  local innerWidth = (visible * SLOT_SIZE) + ((visible - 1) * GAP)
  panel:SetWidth(PADDING * 2 + innerWidth)
  panel:SetHeight(SLOT_SIZE + PADDING * 2)
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
      if data and data.spellId and ALLOWED_SPELLS[data.spellId] then
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
  local infoType, spellBookId, _, spellId = GetCursorInfo()
  if infoType ~= "spell" or not spellId then return end

  if not ALLOWED_SPELLS[spellId] then
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
  if IsMouseButtonDown("LeftButton") and self.spellId then
    PickupSpell(self.spellId)
    ClearSlot(self:GetID())
    slotSpellData[self:GetID()] = nil
    RefreshLayout(false)
    SaveData()
  end
end

local function OnSlotMouseDown(self, button)
  if button == "LeftButton" then
    if not self.spellId then
      local parent = self:GetParent()
      if parent and parent.StartMoving then
        parent:StartMoving()
      end
    end
  elseif button == "RightButton" then
    local i = self:GetID()
    ClearSlot(i)
    slotSpellData[i] = nil
    GameTooltip:Hide()
    RefreshLayout(false)
    SaveData()
  end
end

local function OnSlotMouseUp(self, button)
  if button == "LeftButton" then
    if not self.spellId then
      local parent = self:GetParent()
      StopDraggingFrame(parent)
    end
  end
end

local function OnSlotReceiveDrag(self)
  if not self:IsShown() then return end
  TrackSpell(self:GetID())
end

local function OnSlotClick(self, button)
  if button == "LeftButton" then
    if not self:IsShown() then return end
    if self.spellId and slotSpellData[self:GetID()] then
      CastSpellByName(slotSpellData[self:GetID()].spellName)
    else
      TrackSpell(self:GetID())
    end
  end
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
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  panel:SetFrameStrata("MEDIUM")
  panel:Show()

  for i = 1, MAX_SLOTS do
    local slot = CreateFrame("Button", addonName .. "_Slot" .. i, panel)
    slots[i] = slot
    slot:SetID(i)
    slot:SetSize(SLOT_SIZE, SLOT_SIZE)
    slot:SetNormalTexture(EMPTY_TEXTURE)
    slot:SetPushedTexture(EMPTY_TEXTURE)
    slot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    slot:SetFrameStrata("MEDIUM")

    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:RegisterForDrag("LeftButton")
    slot:SetScript("OnMouseDown", OnSlotMouseDown)
    slot:SetScript("OnMouseUp", OnSlotMouseUp)
    slot:SetScript("OnReceiveDrag", OnSlotReceiveDrag)
    slot:SetScript("OnClick", OnSlotClick)
    slot:SetScript("OnDragStart", StartDraggingSpell)
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end

  LoadData()
end

-- Event registration
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    if not panel then
      CreateProfessionPanel()
    else
      LoadData()
    end
  end
end)


