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

function InitializeChallengesTab()
  if not _G.tabContents or not _G.tabContents[6] then return end  -- adjust index if needed
  local content = _G.tabContents[6]
  if content.initialized then
    if widgets.refresh then widgets.refresh() end
    return
  end
  content.initialized = true
  widgets.root = content

  -- Title
  local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  local TOP_PAD = 32
  title:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -TOP_PAD)
  title:SetText("Challenges")

  -- Lock status
  local lockStatus = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  lockStatus:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  lockStatus:SetText("")
  widgets.lockStatus = lockStatus

  -- Lock now button
  local lockBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
  lockBtn:SetPoint("LEFT", lockStatus, "RIGHT", 8, 0)
  lockBtn:SetSize(140, 22)
  lockBtn:SetText("Lock selection now")
  lockBtn:SetScript("OnClick", function()
    Challenges.LockSelection("User confirmed")
    if widgets.refresh then widgets.refresh() end
  end)
  widgets.lockButton = lockBtn

  -- Divider under lock section
  local div1 = CreateDivider(content)
  div1:SetPoint("TOPLEFT", lockStatus, "BOTTOMLEFT", 0, -8)

  -- List header (now directly under lock divider)
  local listHdr = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  listHdr:SetPoint("TOPLEFT", div1, "BOTTOMLEFT", 0, -10)
  listHdr:SetText("Available Challenges")

  -- Rows container
  local rows = CreateFrame("Frame", nil, content)
  rows:SetPoint("TOPLEFT",  listHdr, "BOTTOMLEFT", 0, -6)
  rows:SetPoint("RIGHT",    content, "RIGHT", -8, 0)
  rows:SetHeight(160)

  PopulateRows(rows)

  -- Bottom spacer
  local spacer = content:CreateTexture(nil, "ARTWORK")
  spacer:SetColorTexture(0,0,0,0)
  spacer:SetHeight(8)
  spacer:SetPoint("TOPLEFT", rows, "BOTTOMLEFT", 0, 0)
  spacer:SetPoint("RIGHT",   content, "RIGHT", -8, 0)

  -- Refresh hook
  widgets.refresh = function()
    RefreshState()
  end

  widgets.refresh()

  -- Backend events -> refresh UI
  Challenges.On("CHALLENGE_ENABLED",     function() widgets.refresh() end)
  Challenges.On("CHALLENGE_DISABLED",    function() widgets.refresh() end)
  Challenges.On("CHALLENGE_FAILED",      function() widgets.refresh() end)
  Challenges.On("CHALLENGE_COMPLETED",   function() widgets.refresh() end)
  Challenges.On("CHALLENGES_LOCKED",     function() widgets.refresh() end)
end
