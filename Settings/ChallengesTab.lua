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
  -- Use your existing tab content frame (update index if needed)
  if not _G.tabContents or not _G.tabContents[6] then return end
  local content = _G.tabContents[6]

  -- If already built, just refresh and show the current subtab
  if content._uhc_chal_initialized then
    if widgets._refreshAll then widgets._refreshAll() end
    if widgets._showSub then widgets._showSub(widgets.subIndex or 1) end
    return
  end
  content._uhc_chal_initialized = true

  widgets.root = content

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

  ------------------------------------------------------------
  -- Presets panel = your CURRENT UI (moved here)
  ------------------------------------------------------------
  local function buildPresetsUI(parent)
    if built[1] then return end
    built[1] = true

    -- Title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    title:SetText("Presets")

    -- Lock status
    if not widgets.lockStatus then
      widgets.lockStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      widgets.lockStatus:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
      widgets.lockStatus:SetText("")
    else
      widgets.lockStatus:SetParent(parent)
      widgets.lockStatus:ClearAllPoints()
      widgets.lockStatus:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
      widgets.lockStatus:Show()
    end

    -- Lock button
    if not widgets.lockButton then
      widgets.lockButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
      widgets.lockButton:SetSize(160, 22)
      widgets.lockButton:SetPoint("LEFT", widgets.lockStatus, "RIGHT", 8, 0)
      widgets.lockButton:SetText("Lock selection now")
      widgets.lockButton:SetScript("OnClick", function()
        if Challenges.LockSelection then
          Challenges.LockSelection("User confirmed")
        end
        if widgets._refreshAll then widgets._refreshAll() end
      end)
    else
      widgets.lockButton:SetParent(parent)
      widgets.lockButton:ClearAllPoints()
      widgets.lockButton:SetPoint("LEFT", widgets.lockStatus, "RIGHT", 8, 0)
      widgets.lockButton:Show()
    end

    -- Divider
    local yAnchor = widgets.lockStatus
    if CreateDivider then
      local div = CreateDivider(parent)
      div:SetPoint("TOPLEFT", widgets.lockStatus, "BOTTOMLEFT", 0, -8)
      yAnchor = div
    end

    -- "Available Challenges" header
    local listHdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listHdr:SetPoint("TOPLEFT", yAnchor, "BOTTOMLEFT", 0, -10)
    listHdr:SetText("Available Challenges")

    -- Rows container
    if not widgets.rowsContainer then
      widgets.rowsContainer = CreateFrame("Frame", nil, parent)
    end
    widgets.rowsContainer:SetParent(parent)
    widgets.rowsContainer:ClearAllPoints()
    widgets.rowsContainer:SetPoint("TOPLEFT",  listHdr, "BOTTOMLEFT", 0, -6)
    widgets.rowsContainer:SetPoint("RIGHT",    parent, "RIGHT", -8, 0)
    widgets.rowsContainer:SetHeight(200)
    widgets.rowsContainer:Show()

    -- Populate using your existing function
    if PopulateRows then
      PopulateRows(widgets.rowsContainer)
    end
  end

  -- Populate rows using the same Presets UI, but with a filter
local function PopulateRowsFiltered(container, fn)
  ClearRows()
  local defs = {}
  for _, def in pairs(Challenges.GetAll()) do
    if fn(def) then
      table.insert(defs, def)
    end
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

  ------------------------------------------------------------
  -- Class panel (class-specific challenge buttons)
  ------------------------------------------------------------
  -- Preset-style row factory
local function CreatePresetStyleRow(parent, i)
  local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  row:SetSize(540, 44)
  row:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
  row:SetBackdropColor(0, 0, 0, (i % 2 == 0) and 0.06 or 0.03)

  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(28, 28)
  row.icon:SetPoint("LEFT", row, "LEFT", 6, 0)

  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.title:SetPoint("TOPLEFT", row.icon, "RIGHT", 8, -2)

  row.desc = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  row.desc:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)
  row.desc:SetWidth(360)
  row.desc:SetJustifyH("LEFT")

  row.select = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
  row.select:SetSize(100, 22)
  row.select:SetPoint("RIGHT", row, "RIGHT", -8, 0)
  row.select:SetText("Select")

  return row
end

local function buildClassUI(parent)
  if built[2] then return end
  built[2] = true

  local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  hdr:SetText("Class Challenges")

  -- Container under the header — no backdrop so it matches Presets
  local list = CreateFrame("Frame", nil, parent)
  list:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -8)
  list:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
  list:SetHeight(220)

  -- Build defs from the class rule registry
  local defs = {}
  if Challenges.GetAvailableClassRules then
    for key, data in pairs(Challenges.GetAvailableClassRules()) do
      defs[#defs+1] = {
        id = key,
        name = (data and data.name) or key,
        description = (data and data.desc) or "",
        icon = (data and data.icon) or "Interface\\Icons\\inv_misc_questionmark",
      }
    end
    table.sort(defs, function(a,b)
      local an = (a.name or a.id or ""):lower()
      local bn = (b.name or b.id or ""):lower()
      return an < bn
    end)
  end

  -- Empty-state message
  if #defs == 0 then
    local msg = parent:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    msg:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 4)
    msg:SetText("No class-specific challenges available for this class.")
    return
  end

  -- Build rows using the SAME row factory as Presets
  widgets.classRows = widgets.classRows or {}

  -- We temporarily reuse CreateChallengeRow’s layout logic, which anchors
  -- to the previous element in widgets.rows; to avoid mixing arrays,
  -- we proxy widgets.rows while building then restore it.
  local old = widgets.rows
  widgets.rows = widgets.classRows

  for i, def in ipairs(defs) do
    local row = CreateChallengeRow(list, def, i)

    -- Override the default checkbox behavior: class rules are single-select
    row.check:SetScript("OnClick", function(self)
      if not Challenges.CanModifySelection() then
        self:SetChecked((Challenges.GetState().rules or {}).classRule == def.id)
        if UIErrorsFrame then
          UIErrorsFrame:AddMessage("Challenge selection is locked at level 2.", 1, 0.2, 0)
        end
        return
      end
      if self:GetChecked() then
        Challenges.SetClassRule(def.id)
      else
        Challenges.SetClassRule("NONE")
      end
      if widgets._refreshAll then widgets._refreshAll() end
    end)

    -- We don’t show status for class rules; make sure it’s blank
    if row.status then row.status:SetText("") end

    -- Ensure the icon uses the provided path/fileID
    row.icon:SetTexture(def.icon)

    widgets.classRows[i] = row
  end

  -- Restore the original preset rows table
  widgets.rows = old

  -- Compute list height like PopulateRows does
  local total = 0
  for _, r in ipairs(widgets.classRows) do total = total + r:GetHeight() + 6 end
  list:SetHeight(math.max(160, total))
end

  ------------------------------------------------------------
  -- Custom panel (DIY/created challenges) – placeholder
  ------------------------------------------------------------
  local function buildCustomUI(parent)
    if built[3] then return end
    built[3] = true

    local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    hdr:SetText("Create Your Challenge")

    local sub = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -6)
    sub:SetText("(Coming soon) Define your own rules here.")
  end

  ------------------------------------------------------------
  -- Sub-tab switching + refresh glue
  ------------------------------------------------------------
  local function highlight(which)
    for i, b in ipairs(widgets.subButtons) do
      if i == which then b:LockHighlight() else b:UnlockHighlight() end
    end
  end

  widgets._showSub = function(i)
    for idx, p in ipairs(widgets.panels) do
      if idx == i then p:Show() else p:Hide() end
    end
    highlight(i)
    if i == 1 then buildPresetsUI(widgets.panels[1])
    elseif i == 2 then buildClassUI(widgets.panels[2])
    else buildCustomUI(widgets.panels[3]) end
    if widgets._refreshAll then widgets._refreshAll() end
    widgets.subIndex = i
  end

  widgets._refreshAll = function()
    -- Update class selection label
if widgets.classSel and Challenges.GetClassRuleSelection then
  local sel = Challenges.GetClassRuleSelection()
  local name = "None"
  if Challenges.GetAvailableClassRules and sel ~= "NONE" then
    local rules = Challenges.GetAvailableClassRules()
    if rules[sel] and rules[sel].name then name = rules[sel].name end
  end
  widgets.classSel:SetText("Selected: " .. name)
end


    -- Refresh your existing Presets UI
    if RefreshState then RefreshState() end
  end

  -- show default sub-tab on first open
  widgets._showSub(widgets.subIndex or 1)
  RefreshClassState()
end
