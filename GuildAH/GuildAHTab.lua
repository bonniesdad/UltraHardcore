local ADDON_NAME, ns = ...
local GAH = ns.GAH
ns.GAHTab = ns.GAHTab or {}
local T = ns.GAHTab

local widgets = {}

-- --- Bag API compatibility ---
local function BagItemCount(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
      local info = C_Container.GetContainerItemInfo(bag, slot)
      return (info and info.stackCount) or 1
    elseif GetContainerItemInfo then
      local _, count = GetContainerItemInfo(bag, slot)
      return count or 1
    end
    return 1
  end
  
local function BagNumSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then
      return C_Container.GetContainerNumSlots(bag)
    elseif GetContainerNumSlots then
      return GetContainerNumSlots(bag)
    end
    return 0
  end
  
  local function BagItemLink(bag, slot)
    if C_Container then
      if C_Container.GetContainerItemLink then
        return C_Container.GetContainerItemLink(bag, slot)
      end
      if C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        return info and (info.hyperlink or info.itemLink)
      end
    elseif GetContainerItemLink then
      return GetContainerItemLink(bag, slot)
    end
    return nil
  end
  
  local function GetButtonBagSlot(btn)
    -- Newer API buttons have :GetBagID(); older ones parent’s :GetID() is the bag
    local bag = (btn.GetBagID and btn:GetBagID()) or (btn:GetParent() and btn:GetParent():GetID())
    local slot = btn:GetID()
    return bag, slot
  end

  -- ---------- Tradable filter helpers ----------
local SCAN_TT = CreateFrame("GameTooltip", "UHC_GAHScanTT", UIParent, "GameTooltipTemplate")
local L_SOULBOUND  = _G.ITEM_SOULBOUND or "Soulbound"
local L_BOP        = _G.ITEM_BIND_ON_PICKUP or "Bind on Pickup"
local L_QUEST      = _G.ITEM_BIND_QUEST or "Quest Item"
local L_CONJURED   = _G.ITEM_CONJURED or "Conjured"
local L_DURATION   = _G.DURABILITY or "Durability"
local L_DURATION_STR = "Duration"

local BLOCKED_ITEMIDS = {
  [6948] = true, -- Hearthstone
}

local BLOCKED_NAME_SUBSTRINGS = {
  "Mining Pick",
  "Blacksmith Hammer",
  "Skinning Knife",
  "Arclight Spanner",
  "Fishing Pole",
}

local function matchBlockedName(name)
  if not name then return false end
  for _, needle in ipairs(BLOCKED_NAME_SUBSTRINGS) do
    if name:find(needle, 1, true) then return true end
  end
  return false
end

local function getItemIDFromLink(link)
  if not link then return nil end
  local id = link:match("item:(%d+)")
  return id and tonumber(id) or nil
end

local function tooltipHas(lineText)
  if not lineText or lineText == "" then return false end
  for i = 2, SCAN_TT:NumLines() do
    local fs = _G["UHC_GAHScanTTTextLeft"..i]
    local txt = fs and fs:GetText()
    if txt and txt:find(lineText, 1, true) then
      return true
    end
  end
  return false
end

local function isTradableBagItem(bag, slot)
  SCAN_TT:SetOwner(UIParent, "ANCHOR_NONE")
  -- GameTooltip supports SetBagItem regardless of C_Container presence
  if SCAN_TT.SetBagItem then
    SCAN_TT:ClearLines()
    SCAN_TT:SetBagItem(bag, slot)
  else
    return false
  end

  local name = _G.UHC_GAHScanTTTextLeft1 and _G.UHC_GAHScanTTTextLeft1:GetText()
  local _, link = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(bag, slot) or nil, nil
  link = link or (C_Container and C_Container.GetContainerItemInfo and (C_Container.GetContainerItemInfo(bag, slot) or {}).hyperlink)
  link = link or (GetContainerItemLink and GetContainerItemLink(bag, slot))

  -- Block by name
  if matchBlockedName(name) then return false end

  -- Block Hearthstone / hard-coded IDs
  local itemID = getItemIDFromLink(link)
  if itemID and BLOCKED_ITEMIDS[itemID] then return false end

  -- Block non-tradable categories by tooltip lines
  if tooltipHas(L_SOULBOUND) then return false end
  if tooltipHas(L_BOP)       then return false end
  if tooltipHas(L_QUEST)     then return false end

  -- exclude conjured/duration-type consumables
  if tooltipHas(L_CONJURED) or tooltipHas(L_DURATION_STR) then
    return false
  end

  return true
end

local function moneyToText(c)
    local g = math.floor(c/10000); local s = math.floor((c%10000)/100); local cc = c%100
    return string.format("%dg %ds %dc", g, s, cc)
  end
  
  -- resolve icon/name from link or itemString (works even if not yet cached)
  local function itemDisplay(linkOrString)
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(linkOrString or "")
    return name, icon
  end
  
  local function ensureRow(i)
    local row = widgets.rows[i]
    if row then return row end
  
    row = CreateFrame("Frame", nil, widgets.list, "BackdropTemplate")
    row:SetSize(560, 36)
    row:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8" })
    row:SetBackdropColor(0,0,0, i % 2 == 0 and 0.06 or 0.03)
  
    -- icon
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(32,32)
    row.icon:SetPoint("LEFT", row, "LEFT", 6, 0)
  
    -- name x qty
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 6)
  
    row.qty  = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.qty:SetPoint("LEFT", row.icon, "RIGHT", 8, -10)
  
    -- price
    row.price = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.price:SetPoint("LEFT", row, "LEFT", 330, 0)
  
    -- reserve button
    row.reserve = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.reserve:SetSize(80, 22)
    row.reserve:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.reserve:SetText("Reserve")
  
    -- overlay for RESERVED
    row.overlay = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.overlay:SetAllPoints(row)
    row.overlay:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8" })
    row.overlay:SetBackdropColor(0,0,0,0.45)
    row.overlay.text = row.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    row.overlay.text:SetPoint("CENTER")
    row.overlay.text:SetText("RESERVED")
    row.overlay:Hide()
  
    -- tooltip on icon
    row:SetScript("OnEnter", function(self)
      if self.link then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
      end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  
    widgets.rows[i] = row
    return row
  end
  
  local function hideExtraRows(startIndex)
    for j = startIndex, #widgets.rows do
      widgets.rows[j]:Hide()
    end
  end
  
  local function canReserve(listing)
    if listing.state ~= "ACTIVE" then return false end
    if listing.sellerGUID == UnitGUID("player") then return false end
    return true
  end
  
  local function reservedByMe(listing)
    return listing.state == "RESERVED" and listing.reservedByGUID == UnitGUID("player")
  end
  
  local function reserveListing(listing)
    GAH.Reserve(listing.id, UnitGUID("player"), UnitName("player"))
  end
  
  local function refresh()
    if not widgets.list then return end
  
    local i = 1
    for _, L in pairs(GAH.GetAllListings()) do
      -- keep ACTIVE and RESERVED visible (SOLD/CANCELLED/EXPIRED are omitted)
      if L.state == "ACTIVE" or L.state == "RESERVED" then
        local row = ensureRow(i)
  
        -- layout
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", widgets.list, "TOPLEFT", 4, - (i-1) * 38)
  
        -- icon/name/qty
        local name, icon = itemDisplay(L.itemLink or L.itemString)
        row.icon:SetTexture(icon or 134400) -- default bag icon fallback
        row.name:SetText(name or (L.itemLink or "Item"))
        row.qty:SetText("x"..(L.count or 1))
        row.link = L.itemLink -- for tooltip
  
        -- price text
        row.price:SetText(moneyToText(L.price or 0))
  
        -- reserve button state & behavior
        row.reserve:SetEnabled(canReserve(L))
        if L.state == "ACTIVE" then
          row.overlay:Hide()
          row.reserve:SetText("Reserve")
        else -- RESERVED
          row.overlay:Show()
          row.overlay.text:SetText("RESERVED")
          row.reserve:SetText(reservedByMe(L) and "Reserved" or "Reserved")
          row.reserve:SetEnabled(false)
        end
  
        row.reserve:SetScript("OnClick", function()
          reserveListing(L)
        end)
  
        row:Show()
        i = i + 1
      end
    end
  
    hideExtraRows(i)
  end
  
  T.Refresh = refresh  

function InitializeGuildAHTab()
  -- set actual tab index here
  local content = TabManager.getTabContent(7)
  if widgets.container then widgets.container:Show(); refresh(); return end

  local container = CreateFrame("Frame", nil, content)
  container:SetAllPoints(content)
  widgets.container = container

  local title = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -10)
  title:SetText("Guild Auction House")

  -- Listings box
  local list = CreateFrame("Frame", nil, container, "BackdropTemplate")
  list:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  list:SetSize(580, 220)
  list:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8", edgeFile="Interface/Buttons/WHITE8x8", edgeSize=1 })
  list:SetBackdropColor(0,0,0,0.12); list:SetBackdropBorderColor(0,0,0,0.35)
  widgets.list = list
  widgets.rows = {}

    -- Post section
    local hdr = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -16)  -- moved down a bit
    hdr:SetText("Post an item (Buyout only)")
  
    -- helper line under the header (clear separation)
    local sub = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -6)
    sub:SetText("Open your bags and SHIFT-CLICK an item, or click 'Pick from Bags' to choose.")
  
    -- item edit box (shift-click target)
    local eb = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -10)    -- pushed further down
    eb:SetSize(360, 24)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(255)
    widgets.postItem = eb
  
    -- Open Bags button (convenience)
    local openBagsBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    openBagsBtn:SetSize(110, 24)
    openBagsBtn:SetPoint("LEFT", eb, "RIGHT", 8, 0)
    openBagsBtn:SetText("Open Bags")
    openBagsBtn:SetScript("OnClick", function()
      ToggleAllBags()              -- open/close all bags
      eb:SetFocus()                -- keep focus so shift-click inserts here
    end)
  
    -- Bag Picker toggle
    local pickBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    pickBtn:SetSize(120, 24)
    pickBtn:SetPoint("LEFT", openBagsBtn, "RIGHT", 6, 0)
    pickBtn:SetText("Pick from Bags")
  
    -- Price label placed lower so it doesn't collide with header
    local priceLbl = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    priceLbl:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 0, -10)
    priceLbl:SetText("Price (g s c)")
  
    -- Price inputs, pushed further down
    local gEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); gEB:SetNumeric(true); gEB:SetSize(48,24)
    local sEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); sEB:SetNumeric(true); sEB:SetSize(36,24)
    local cEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); cEB:SetNumeric(true); cEB:SetSize(36,24)
    gEB:SetPoint("TOPLEFT", priceLbl, "BOTTOMLEFT", 0, -4)
    sEB:SetPoint("LEFT", gEB, "RIGHT", 4, 0)
    cEB:SetPoint("LEFT", sEB, "RIGHT", 4, 0)

    -- Qty label & input (under the price inputs)
    local qtyLbl = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    qtyLbl:SetPoint("TOPLEFT", priceLbl, "BOTTOMLEFT", 0, -36)
    qtyLbl:SetText("Qty")

    local qtyEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    qtyEB:SetNumeric(true); qtyEB:SetSize(48, 24)
    qtyEB:SetPoint("LEFT", qtyLbl, "RIGHT", 6, 0)
    qtyEB:SetAutoFocus(false)
    qtyEB:SetText("1")
    widgets.qtyEB = qtyEB

  
    local listBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    listBtn:SetPoint("LEFT", cEB, "RIGHT", 8, 0)
    listBtn:SetSize(100, 24)
    listBtn:SetText("List")
    listBtn:SetScript("OnClick", function()
        local link = eb:GetText()
        local g = tonumber(gEB:GetText()) or 0
        local s = tonumber(sEB:GetText()) or 0
        local c = tonumber(cEB:GetText()) or 0
        local qty = tonumber(qtyEB:GetText()) or 1
        if qty < 1 then qty = 1 end
      
        local price = g*10000 + s*100 + c
      
        if link and link ~= "" then
          local ok = GAH.NewListing(link, qty, price, 48)
          if ok then
            -- clear everything, including item and qty
            eb:SetText("")
            gEB:SetText("")
            sEB:SetText("")
            cEB:SetText("")
            qtyEB:SetText("1")
            if widgets.picker then widgets.picker:Hide() end
            eb:ClearFocus()
            -- optional: close bags after listing
            -- ToggleAllBags()
          end
          InitializeGuildAHTab()
        end
      end)                  
  
    -- ==== Simple Bag Picker (popup) ====
    local picker = CreateFrame("Frame", "UHC_GAH_BagPicker", container, "BackdropTemplate")
    picker:SetSize(420, 260)
    picker:SetPoint("TOPLEFT", priceLbl, "BOTTOMLEFT", 0, -56) -- below inputs
    picker:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8", edgeFile="Interface/Buttons/WHITE8x8", edgeSize=1 })
    picker:SetBackdropColor(0,0,0,0.15); picker:SetBackdropBorderColor(0,0,0,0.5)
    picker:Hide()
    widgets.picker = picker
  
    local pickTitle = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    pickTitle:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -8)
    pickTitle:SetText("Pick an item from your bags")
  
    local closePick = CreateFrame("Button", nil, picker, "UIPanelButtonTemplate")
    closePick:SetSize(70, 20)
    closePick:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -8, -6)
    closePick:SetText("Close")
    closePick:SetScript("OnClick", function() picker:Hide(); eb:SetFocus() end)
  
    -- scrollable list of bag items
    local scroll = CreateFrame("ScrollFrame", nil, picker, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -28)
    scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -28, 8)
  
    local pickContent = CreateFrame("Frame", nil, scroll)
    pickContent:SetSize(1,1) -- will grow
    scroll:SetScrollChild(pickContent)
    picker.rows = {}
  
    local function rebuildPicker()
      for _, r in ipairs(picker.rows) do r:Hide() end
      local i = 1
      -- Classic Era bag API
      for bag = 0, 4 do
        local slots = BagNumSlots(bag)
        if slots and slots > 0 then
          for slot = 1, slots do
            local link = BagItemLink(bag, slot)
            if link and isTradableBagItem(bag, slot) then
              -- create/show the row exactly as you do now
              local btn = picker.rows[i]
              if not btn then
                btn = CreateFrame("Button", nil, pickContent, "UIPanelButtonTemplate")
                btn:SetSize(370, 20)
                btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                btn.text:SetPoint("LEFT", btn, "LEFT", 6, 0)
                picker.rows[i] = btn
              end
              btn:SetPoint("TOPLEFT", pickContent, "TOPLEFT", 0, -(i-1)*22)
              btn.text:SetText(link)
              btn:SetScript("OnClick", function()
                widgets.postItem:SetText(link)
                picker:Hide()
                widgets.postItem:SetFocus()
              end)
              btn:Show()
              i = i + 1
            end
          end
        end
      end      
      pickContent:SetSize(370, (i-1)*22)
    end
  
    pickBtn:SetScript("OnClick", function()
      ToggleAllBags()     -- show bags if they weren't visible
      eb:SetFocus()
      rebuildPicker()
      picker:Show()
    end)

    -- Shift-click into our edit box when it has focus (chat-style)
hooksecurefunc("ChatEdit_InsertLink", function(link)
    if widgets and widgets.postItem and widgets.postItem:IsVisible() and widgets.postItem:HasFocus() and link then
      widgets.postItem:Insert(link)
    end
  end)
end
  
if type(ContainerFrameItemButton_OnModifiedClick) == "function" then
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button)
      if not (IsModifiedClick("CHATLINK") and widgets and widgets.postItem and widgets.postItem:IsVisible()) then return end
      local bag, slot = GetButtonBagSlot(self)
      if bag == nil or slot == nil then return end
      if not isTradableBagItem(bag, slot) then return end  -- ← filter here
      local link = BagItemLink(bag, slot)
      if link then
        widgets.postItem:SetFocus()
        widgets.postItem:SetText(link)
      end
    end)
  end
