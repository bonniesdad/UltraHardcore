-- ChallengesTab.lua

local Challenges = _G.Challenges
if not Challenges then
  return
end

-- Colors
local COLOR_LOCKED   = {1.00, 0.82, 0.00}   -- gold
local COLOR_FAILED   = {1.00, 0.25, 0.25}   -- red
local COLOR_COMPLETE = {0.20, 0.80, 0.20}   -- green

local widgets = {
  rows = {},
}

-- ----- Subtabs config -----
local CHAL_SUBTABS = { "Presets", "Class", "Custom" }

local function rgb(t) return t[1], t[2], t[3] end

local function sortDefsByName(a, b)
  local an = (a.name or a.id or ""):lower()
  local bn = (b.name or b.id or ""):lower()
  return an < bn
end

local function CreateDivider(parent)
  local d = parent:CreateTexture(nil, "ARTWORK")
  d:SetColorTexture(1, 1, 1, 0.08)
  d:SetHeight(1)
  d:SetPoint("LEFT",  parent, "LEFT",  0, 0)
  d:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
  return d
end

-- Build one challenge row (icon, name, desc, checkbox, status)
local function CreateChallengeRow(parent, def, index)
  local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  row:SetHeight(52)
  row:SetPoint("LEFT",  parent, "LEFT",  0, 0)
  row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
  if index == 1 then
    row:SetPoint("TOP", parent, "TOP", 0, 0)
  else
    row:SetPoint("TOP", widgets.rows[index-1], "BOTTOM", 0, -6)
  end

  -- Icon
  local icon = row:CreateTexture(nil, "ARTWORK")
  icon:SetSize(28, 28)
  icon:SetPoint("LEFT", row, "LEFT", 6, 0)
  icon:SetTexture(def.icon or "Interface\\Icons\\inv_misc_questionmark")

  -- Name
  local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  name:SetPoint("LEFT", icon, "RIGHT", 8, 10)
  name:SetJustifyH("LEFT")
  name:SetText(def.name or def.id or "Challenge")

  -- Description
  local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  desc:SetPoint("LEFT", icon, "RIGHT", 8, -10)
  desc:SetPoint("RIGHT", row, "RIGHT", -120, 0)
  desc:SetJustifyH("LEFT")
  desc:SetJustifyV("TOP")
  desc:SetText(def.description or "")

  -- Status tag (Failed/Complete)
  local status = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  status:SetPoint("RIGHT", row, "RIGHT", -52, 0)
  status:SetJustifyH("RIGHT")
  status:SetText("")

  -- Checkbox
  local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  cb:SetPoint("RIGHT", row, "RIGHT", -10, 0)
  cb:SetSize(24, 24)

  cb:SetScript("OnClick", function(self)
    local was = Challenges.IsEnabled(def.id)
    Challenges.Toggle(def.id)
    local now = Challenges.IsEnabled(def.id)
    self:SetChecked(now)
    if was == now and not Challenges.CanModifySelection() then
      if UIErrorsFrame then
        UIErrorsFrame:AddMessage("Challenge selection is locked at level 2.", 1, 0.2, 0)
      end
    end
    if widgets.refresh then widgets.refresh() end
  end)

  row.icon   = icon
  row.name   = name
  row.desc   = desc
  row.check  = cb
  row.status = status
  row.def    = def

  return row
end

local function ClearRows()
  for _, r in ipairs(widgets.rows) do r:Hide() end
  wipe(widgets.rows)
end

local function PopulateRows(container)
  ClearRows()
  local defs = {}
  for _, def in pairs(Challenges.GetAll()) do
    table.insert(defs, def)
  end
  table.sort(defs, sortDefsByName)

  for i, def in ipairs(defs) do
    local row = CreateChallengeRow(container, def, i)
    table.insert(widgets.rows, row)
  end

  local total = 0
  for _, r in ipairs(widgets.rows) do total = total + r:GetHeight() + 6 end
  container:SetHeight(math.max(160, total))
end

local function RefreshState()
  if not widgets.root then return end
  local canEdit  = Challenges.CanModifySelection()
  local isLocked = Challenges.IsSelectionLocked()

  -- Lock status text
  if isLocked then
    widgets.lockStatus:SetText("|cffffd100Selection locked|r (level 2 reached or confirmed)")
    widgets.lockStatus:SetTextColor(rgb(COLOR_LOCKED))
  else
    widgets.lockStatus:SetText("|cff20c020You can change challenges until level 2.|r")
    widgets.lockStatus:SetTextColor(0.8, 0.8, 0.8)
  end

  -- Lock button availability
  widgets.lockButton:SetEnabled(canEdit)
  widgets.lockButton:SetAlpha(canEdit and 1 or 0.5)

  -- Rows
  for _, r in ipairs(widgets.rows) do
    local st = Challenges.GetState(r.def.id)
    r.check:SetChecked(st.enabled)
    r.check:SetEnabled(canEdit)
    r.check:SetAlpha(canEdit and 1 or 0.5)

    if st.failed then
      r.status:SetText("|cffff4040Failed|r")
      r.status:SetTextColor(rgb(COLOR_FAILED))
    elseif st.complete then
      r.status:SetText("|cff33cc33Complete|r")
      r.status:SetTextColor(rgb(COLOR_COMPLETE))
    else
      r.status:SetText("")
      r.status:SetTextColor(1, 1, 1)
    end

    local alpha = (isLocked and not st.enabled) and 0.6 or 1
    r.icon:SetAlpha(alpha)
    r.name:SetAlpha(alpha)
    r.desc:SetAlpha(alpha)
  end
end

-- Refresh only the Class rows (checkbox state + enable rules)
local function RefreshClassState()
  if not widgets.classRows then return end
  local canEdit  = Challenges.CanModifySelection()
  local isLocked = Challenges.IsSelectionLocked()
  local db = Challenges.GetState and Challenges.GetState() or nil
  local sel = (db and db.rules and db.rules.classRule) or "NONE"

  for _, r in ipairs(widgets.classRows) do
    local isSelected = (r.def and r.def.id == sel)
    r.check:SetChecked(isSelected)
    r.check:SetEnabled(canEdit)
    r.check:SetAlpha(canEdit and 1 or 0.5)

    -- Class rows don’t show status text; ensure it’s hidden/blank
    if r.status then r.status:SetText("") end

    -- Match Presets dimming rules for unselected items when locked
    local alpha = (isLocked and not isSelected) and 0.6 or 1
    r.icon:SetAlpha(alpha)
    r.name:SetAlpha(alpha)
    r.desc:SetAlpha(alpha)
  end
end

function InitializeChallengesTab()
  if not _G.tabContents or not _G.tabContents[6] then return end
  local content = _G.tabContents[6]

  if content._uhc_chal_initialized then
    if widgets._refreshAll then widgets._refreshAll() end
    if widgets._showSub then widgets._showSub(widgets.subIndex or 1) end
    return
  end
  content._uhc_chal_initialized = true

  widgets.root = content

-- Rebuild any subtab lists that exist
local function RebuildAllLists()
  -- --- Presets ---
  if widgets.presetInner then
    -- nuke children
    for _, child in ipairs({ widgets.presetInner:GetChildren() }) do
      child:Hide(); child:SetParent(nil)
    end
    -- re-populate with your existing renderer
    if PopulateRows then
      PopulateRows(widgets.presetInner)
    end
    -- height estimate
    local rowCount = widgets.presetInner._rowCount or (widgets.presetInner.rows and #widgets.presetInner.rows) or 12
    widgets.presetInner:SetHeight(math.max(220, rowCount * 36 + 8))
  end

  -- --- Class ---
  if widgets.classInner then
    -- nuke children
    for _, child in ipairs({ widgets.classInner:GetChildren() }) do
      child:Hide(); child:SetParent(nil)
    end

    -- collect class items
    local items, sel = {}, (Challenges.GetClassRuleSelection and Challenges.GetClassRuleSelection()) or "NONE"
    if Challenges.GetAvailableClassRules then
      for key, def in pairs(Challenges.GetAvailableClassRules()) do
        items[#items+1] = {
          id   = key,
          name = def.name or key,
          desc = def.desc or "",
          icon = def.icon or "Interface\\Icons\\inv_misc_questionmark",
          selected = (sel == key),
        }
      end
      table.sort(items, function(a,b) return (a.name or "") < (b.name or "") end)
    end

    -- small row factory that matches your Presets look
    local ROW_H, rows = 36, {}
    local function ensureRow(i)
      local r = rows[i]
      if r then return r end
      r = CreateFrame("Button", nil, widgets.classInner, "BackdropTemplate")
      r:SetSize(1, ROW_H)
      r:SetBackdrop({ bgFile="Interface/Buttons/WHITE8x8" })
      r:SetBackdropColor(0,0,0, (i%2==0) and 0.04 or 0.02)

      r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(24,24); r.icon:SetPoint("LEFT", r, "LEFT", 6, 0)
      r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight");    r.name:SetPoint("LEFT", r.icon, "RIGHT", 8, 6)
      r.desc = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"); r.desc:SetPoint("LEFT", r.icon, "RIGHT", 8, -10); r.desc:SetWidth(360); r.desc:SetJustifyH("LEFT")
      r.pick = CreateFrame("Button", nil, r, "UIPanelButtonTemplate");     r.pick:SetSize(100,22); r.pick:SetPoint("RIGHT", r, "RIGHT", -8, 0)
      rows[i] = r
      return r
    end

    for i, it in ipairs(items) do
      local r = ensureRow(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", widgets.classInner, "TOPLEFT", 4, - (i-1) * ROW_H)

      r.icon:SetTexture(it.icon)
      r.name:SetText(it.name); r.desc:SetText(it.desc or "")

      r.pick:SetText(it.selected and "Selected" or "Select")
      r.pick:SetEnabled(not it.selected)
      r.pick:SetScript("OnClick", function()
        if Challenges.SetClassRule then
          local ok, err = Challenges.SetClassRule(it.id)
          if not ok and err then
            if UIErrorsFrame then UIErrorsFrame:AddMessage(err, 1, .2, 0) else print(err) end
          end
        end
        if widgets._refreshAll then widgets._refreshAll() end
      end)

      r:Show()
    end

    widgets.classInner:SetHeight(math.max(220, #items * ROW_H + 8))
  end
end

  ------------------------------------------------------------
  -- Sub-tab strip (Presets | Class | Custom)
  ------------------------------------------------------------
  local strip = CreateFrame("Frame", nil, content, "BackdropTemplate")
  strip:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
  strip:SetPoint("TOPRIGHT", content, "TOPRIGHT", -8, -8)
  strip:SetHeight(26)
  widgets.subStrip = strip

  widgets.subButtons = {}
  local subNames = { "Presets", "Class", "Custom" }

  local function createSubButton(label, index)
    local b = CreateFrame("Button", nil, strip, "UIPanelButtonTemplate")
    b:SetSize(100, 22)
    if index == 1 then
      b:SetPoint("LEFT", strip, "LEFT", 0, 0)
    else
      b:SetPoint("LEFT", widgets.subButtons[index-1], "RIGHT", 6, 0)
    end
    b.index = index
    b:SetText(label)
    b:SetScript("OnClick", function() widgets._showSub(index) end)
    widgets.subButtons[index] = b
    return b
  end

  for i, name in ipairs(subNames) do
    createSubButton(name, i)
  end

  ------------------------------------------------------------
  -- Panels for each sub-tab
  ------------------------------------------------------------
  widgets.panels = {}

  local function makePanel()
    local p = CreateFrame("Frame", nil, content, "BackdropTemplate")
    p:SetPoint("TOPLEFT",  content, "TOPLEFT",  8, -40)
    p:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -8, 8)
    p:Hide()
    return p
  end

  widgets.panels[1] = makePanel()  -- Presets
  widgets.panels[2] = makePanel()  -- Class
  widgets.panels[3] = makePanel()  -- Custom

  local built = { false, false, false }
  local buildPresetsUI, buildClassUI, buildCustomUI

  ------------------------------------------------------------
  -- Presets panel
  ------------------------------------------------------------
local function _buildPresetsUI(parent)
  if built[1] then return end
  built[1] = true

  -- Title
  local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  title:SetText("Presets")

  -- Lock status
  if not widgets.lockStatus then
    widgets.lockStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  end
  widgets.lockStatus:SetParent(parent)
  widgets.lockStatus:ClearAllPoints()
  widgets.lockStatus:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  widgets.lockStatus:Show()

  -- Lock button
  if not widgets.lockButton then
    widgets.lockButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    widgets.lockButton:SetSize(160, 22)
    widgets.lockButton:SetText("Lock selection now")
    widgets.lockButton:SetScript("OnClick", function()
      if Challenges.TryLock then
        local ok, fails = Challenges.TryLock("User confirmed")
        if not ok then
          -- show a concise toast with first reason, then list all in chat for clarity
          local first = fails and fails[1]
          local msg = first and (first.name..": "..(first.reason or "Not compliant")) or "Selection not compliant."
          if UIErrorsFrame then UIErrorsFrame:AddMessage(msg, 1, .2, 0) else print(msg) end
          print("|cffff5555UHC: Please comply with selected challenges before locking:|r")
          for _, f in ipairs(fails) do
            print(("- %s: %s"):format(f.name or f.id, f.reason or "Not compliant"))
          end
          return
        end
      else
        -- Fallback to old behavior
        if Challenges.LockSelection then Challenges.LockSelection("User confirmed") end
      end
      if widgets._refreshAll then widgets._refreshAll() end
    end)    
  end
  widgets.lockButton:SetParent(parent)
  widgets.lockButton:ClearAllPoints()
  widgets.lockButton:SetPoint("LEFT", widgets.lockStatus, "RIGHT", 8, 0)
  widgets.lockButton:Show()

  -- Divider
  local yAnchor = widgets.lockStatus
  if CreateDivider then
    local div = CreateDivider(parent)
    div:SetPoint("TOPLEFT", widgets.lockStatus, "BOTTOMLEFT", 0, -8)
    yAnchor = div
  end

  -- Header
  local listHdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  listHdr:SetPoint("TOPLEFT", yAnchor, "BOTTOMLEFT", 0, -10)
  listHdr:SetText("Available Challenges")

  -- ===== ScrollFrame =====
  local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT",  listHdr, "BOTTOMLEFT", 0, -6)
  scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 8) -- leave room for scrollbar
  scroll:EnableMouseWheel(true)
  widgets.presetScroll = scroll

  local inner = CreateFrame("Frame", nil, scroll)
  inner:SetPoint("TOPLEFT")
  inner:SetSize(520, 1)
  scroll:SetScrollChild(inner)
  widgets.presetInner = inner

  if PopulateRows then
    PopulateRows(inner)
  end

  -- ---- Auto-size the inner height so the scrollbar knows what to scroll ----
  local function countChildren(f)
    local n = 0
    for _ in pairs({ f:GetChildren() }) do n = n + 1 end
    return n
  end

  local function estimateContentHeight(f)
    local ROW_H = 36
    local n = f._rowCount or (f.rows and #f.rows) or countChildren(f)
    local h = (n > 0) and (n * ROW_H + 8) or 200
    return math.max(200, h)
  end

  inner:SetHeight(estimateContentHeight(inner))

  -- Smooth mouse wheel scroll
  scroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local step = 32
    self:SetVerticalScroll( math.max(0, current - delta * step) )
  end)
end
buildPresetsUI = _buildPresetsUI

--------------------------
----- Class Panel --------
--------------------------
local function _buildClassUI(parent)
  if built[2] then return end
  built[2] = true

  local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  hdr:SetText("Class Challenges")

  -- Collect class rules (name/desc/icon/selected)
  local items = {}
  if Challenges.GetAvailableClassRules then
    for key, def in pairs(Challenges.GetAvailableClassRules()) do
      items[#items+1] = {
        id   = key,
        name = def.name or key,
        desc = def.desc or "",
        icon = def.icon or "Interface\\Icons\\inv_misc_questionmark",
        selected = (Challenges.GetClassRuleSelection and Challenges.GetClassRuleSelection() == key) or false,
      }
    end
    table.sort(items, function(a,b) return a.name < b.name end)
  end

  -- Rows container
  if type(PopulateRows) == "function" then
    if not widgets.classRows then widgets.classRows = CreateFrame("Frame", nil, parent) end
    widgets.classRows:SetParent(parent)
    widgets.classRows:ClearAllPoints()
    widgets.classRows:SetPoint("TOPLEFT",  hdr, "BOTTOMLEFT", 0, -10)
    widgets.classRows:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 8)
    widgets.classRows:Show()
  end

    -- Scroll area
local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT",  hdr, "BOTTOMLEFT", 0, -10)
scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -24, 8)
local inner = CreateFrame("Frame", nil, scroll)
inner:SetSize(520, 1)
scroll:SetScrollChild(inner)
widgets.classScroll = scroll
widgets.classInner  = inner
end
buildClassUI = _buildClassUI

  ------------------------------------------------------------
  -- Custom panel (DIY/created challenges)
  ------------------------------------------------------------
  local function _buildCustomUI(parent)
    if built[3] then return end
    built[3] = true

    local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    hdr:SetText("Create Your Challenge")

    local sub = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -6)
    sub:SetText("(Coming soon) Define your own rules here.")
  end
  buildCustomUI = _buildCustomUI

  ------------------------------------------------------------
  -- Sub-tab switching + refresh glue
  ------------------------------------------------------------
  local function highlight(i)
    for idx, b in ipairs(widgets.subButtons) do
      if idx == i then b:LockHighlight() else b:UnlockHighlight() end
    end
  end

  widgets._showSub = function(i)
    for idx, p in ipairs(widgets.panels) do
      if idx == i then p:Show() else p:Hide() end
    end
  
    if i == 1 then
      buildPresetsUI(widgets.panels[1])
    elseif i == 2 then
      buildClassUI(widgets.panels[2])
    else
      buildCustomUI(widgets.panels[3])
    end
  
    -- one call refreshes whatever panels exist
    RebuildAllLists()
  
    if widgets._refreshAll then widgets._refreshAll() end
    widgets.subIndex = i
  end  

  -- 9) Refresher --------------------------------------------------------------
  widgets._refreshAll = function()
    -- update Class "Selected:" text
    if widgets.classSel and Challenges.GetClassRuleSelection then
      local sel = Challenges.GetClassRuleSelection()
      local name = "None"
      if sel ~= "NONE" and Challenges.GetAvailableClassRules then
        local defs = Challenges.GetAvailableClassRules()
        if defs[sel] and defs[sel].name then name = defs[sel].name end
      end
      widgets.classSel:SetText("Selected: " .. name)
    end
  
    -- repopulate whichever lists exist
    RebuildAllLists()
  
    -- keep your existing Presets state sync
    if RefreshState then RefreshState() end
  end  
end
