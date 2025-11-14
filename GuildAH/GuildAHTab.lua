local ADDON_NAME, ns = ...
local GAH = ns.GAH
ns.GAHTab = ns.GAHTab or {}
local T = ns.GAHTab

local widgets = {}

local function moneyToText(c)
  local g = math.floor(c/10000); local s = math.floor((c%10000)/100); local cc = c%100
  return string.format("%dg %ds %dc", g, s, cc)
end
local function parseMoney(g,s,c) g=tonumber(g) or 0; s=tonumber(s) or 0; c=tonumber(c) or 0; return g*10000+s*100+c end

local function makeButton(parent, label, w, h, cb)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w,h); b:SetText(label); b:SetScript("OnClick", cb); return b
end

local function refresh()
  if not widgets.list then return end
  local rows = widgets.rows or {}
  for _,r in ipairs(rows) do r:Hide() end

  local i = 1
  for _, L in pairs(GAH.GetAllListings()) do
    if L.state == "ACTIVE" or L.state == "RESERVED" then
      local row = rows[i]
      if not row then
        row = CreateFrame("Button", nil, widgets.list)
        row:SetSize(560, 18)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
        rows[i] = row
      end
      local tag = (L.state=="RESERVED" and (" [RESERVED by "..(L.reservedByName or "?").."]")) or ""
      row.text:SetText(string.format("%s x%d — %s — Seller: %s%s", L.itemLink or "item", L.count or 1, moneyToText(L.price or 0), L.sellerName or "?", tag))
      row:SetPoint("TOPLEFT", widgets.list, "TOPLEFT", 4, -(i-1)*20)
      row:SetScript("OnClick", function()
        if L.state == "ACTIVE" then
          GAH.Reserve(L.id, UnitGUID("player"), UnitName("player"))
        elseif L.state == "RESERVED" and L.reservedByGUID == UnitGUID("player") then
          ChatFrame_OpenChat("/w "..(L.sellerName or "?").." Hi! Can we trade "..(L.itemLink or "item").." for "..moneyToText(L.price).."?")
        end
      end)
      row:Show()
      i = i + 1
    end
  end
  widgets.rows = rows
end
T.Refresh = refresh

function InitializeGuildAHTab()
  -- set your actual tab index here (e.g., 7)
  local content = TabManager.getTabContent(6)
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
  list:SetSize(580, 200)
  list:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8", edgeFile="Interface/Buttons/WHITE8x8", edgeSize=1 })
  list:SetBackdropColor(0,0,0,0.12); list:SetBackdropBorderColor(0,0,0,0.35)
  widgets.list = list
  widgets.rows = {}

  -- Post section
  local hdr = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  hdr:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -12)
  hdr:SetText("Post an item (Buyout only): Shift-click an item into the box, set price, List.")

  local eb = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
  eb:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -6)
  eb:SetSize(340, 24); eb:SetAutoFocus(false); widgets.postItem = eb

  local gEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); gEB:SetNumeric(true); gEB:SetSize(48,24)
  local sEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); sEB:SetNumeric(true); sEB:SetSize(36,24)
  local cEB = CreateFrame("EditBox", nil, container, "InputBoxTemplate"); cEB:SetNumeric(true); cEB:SetSize(36,24)
  gEB:SetPoint("LEFT", eb, "RIGHT", 8, 0); sEB:SetPoint("LEFT", gEB, "RIGHT", 4, 0); cEB:SetPoint("LEFT", sEB, "RIGHT", 4, 0)

  local priceLbl = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  priceLbl:SetPoint("BOTTOMLEFT", gEB, "TOPLEFT", 0, 2)
  priceLbl:SetText("Price (g s c)")

  local listBtn = makeButton(container, "List", 100, 24, function()
    local link = eb:GetText()
    local price = parseMoney(gEB:GetText(), sEB:GetText(), cEB:GetText())
    if link and link ~= "" then
      local ok, err = GAH.NewListing(link, 1, price, 48)
      if ok then eb:SetText(""); gEB:SetText(""); sEB:SetText(""); cEB:SetText("") end
      InitializeGuildAHTab()
    end
  end)
  listBtn:SetPoint("LEFT", cEB, "RIGHT", 8, 0)

  -- Accept/Decline/Complete buttons for your own reserved listings (simple controls)
  local myHdr = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  myHdr:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", 0, -12)
  myHdr:SetText("My Listings (quick actions for selected row coming later)")

  -- Shift-click item capture
  hooksecurefunc("ChatEdit_InsertLink", function(link)
    if widgets.postItem and widgets.postItem:HasFocus() then widgets.postItem:Insert(link) end
  end)

  refresh()
end
