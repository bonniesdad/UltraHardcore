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
local allowedSpells = {
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
  { 0000 },                      -- Mounts?
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



