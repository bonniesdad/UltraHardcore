-- Resource Tab Content
-- This file contains the UI elements and functionality for the Resource tab

local deathCounterValue
local resourceCounterValue
local deathHistoryContent
local deathHistoryPlaceholder
local deathHistoryRows = {}
local DEATH_HISTORY_ROW_HEIGHT = 26
local DEATH_HISTORY_COLUMNS = {
  level = { width = 50, maxChars = 4, header = 'Level' },
  location = { width = 190, maxChars = 28, header = 'Location' },
  killer = { width = 140, maxChars = 20, header = 'Killer' },
  health = { width = 110, maxChars = 18, header = 'Health' },
}
local HARD_CODED_RESOURCE_COUNT = 5

local function truncateText(text, maxChars)
  if type(text) ~= 'string' then
    text = tostring(text or '')
  end
  if maxChars and maxChars > 3 and string.len(text) > maxChars then
    return string.sub(text, 1, maxChars - 3) .. '...'
  end
  return text
end

local function normalizeDeathEntry(entry)
  if type(entry) ~= 'table' then
    return {
      killer = 'Unknown',
      location = tostring(entry or 'Unknown'),
      healthText = '',
      level = nil,
      timestamp = nil,
    }
  end

  entry.killer = entry.killer or 'Unknown'
  entry.location = entry.location or 'Unknown'
  entry.healthText = entry.healthText or entry.message or ''
  entry.level = entry.level
  entry.timestamp = entry.timestamp
  return entry
end

local function getOrCreateHistoryRow(index)
  if not deathHistoryContent then return nil end
  if not deathHistoryRows[index] then
    local row = CreateFrame('Frame', nil, deathHistoryContent)
    row:SetSize(520, DEATH_HISTORY_ROW_HEIGHT)

    row.level = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.level:SetPoint('LEFT', row, 'LEFT', 0, 0)
    row.level:SetWidth(DEATH_HISTORY_COLUMNS.level.width)
    row.level:SetJustifyH('LEFT')
    row.level:SetWordWrap(false)

    row.location = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.location:SetPoint('LEFT', row.level, 'RIGHT', 10, 0)
    row.location:SetWidth(DEATH_HISTORY_COLUMNS.location.width)
    row.location:SetJustifyH('LEFT')
    row.location:SetWordWrap(false)

    row.killer = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.killer:SetPoint('LEFT', row.location, 'RIGHT', 10, 0)
    row.killer:SetWidth(DEATH_HISTORY_COLUMNS.killer.width)
    row.killer:SetJustifyH('LEFT')
    row.killer:SetWordWrap(false)

    row.health = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.health:SetPoint('LEFT', row.killer, 'RIGHT', 10, 0)
    row.health:SetWidth(DEATH_HISTORY_COLUMNS.health.width)
    row.health:SetJustifyH('LEFT')
    row.health:SetWordWrap(false)

    deathHistoryRows[index] = row
  end
  return deathHistoryRows[index]
end

local function RefreshDeathHistoryList()
  if not deathHistoryContent then return end

  local history = {}
  if CharacterStats and CharacterStats.GetDeathHistory then
    history = CharacterStats:GetDeathHistory() or {}
  end
  if type(history) ~= 'table' then
    history = {}
  end

  if #history == 0 then
    if deathHistoryPlaceholder then deathHistoryPlaceholder:Show() end
    for _, row in ipairs(deathHistoryRows) do
      if row then row:Hide() end
    end
    deathHistoryContent:SetHeight(40)
    return
  end

  if deathHistoryPlaceholder then deathHistoryPlaceholder:Hide() end

  local rowIndex = 0
  local currentOffset = 0
  for idx = #history, 1, -1 do
    local entry = normalizeDeathEntry(history[idx])
    rowIndex = rowIndex + 1
    local row = getOrCreateHistoryRow(rowIndex)
    if row then
      row:Show()
      row:ClearAllPoints()
      row:SetPoint('TOPLEFT', deathHistoryContent, 'TOPLEFT', 0, -currentOffset)
      row:SetPoint('TOPRIGHT', deathHistoryContent, 'TOPRIGHT', 0, -currentOffset)

      row.level:SetText(
        truncateText(entry.level and tostring(entry.level) or '--', DEATH_HISTORY_COLUMNS.level.maxChars)
      )
      row.location:SetText(truncateText(entry.location == 'Unknown' and 'N/A' or entry.location, DEATH_HISTORY_COLUMNS.location.maxChars))
      row.killer:SetText(truncateText(entry.killer == 'Unknown' and 'N/A' or entry.killer, DEATH_HISTORY_COLUMNS.killer.maxChars))
      row.health:SetText(truncateText(entry.healthText == 'Unknown' and 'N/A' or entry.healthText, DEATH_HISTORY_COLUMNS.health.maxChars))

      currentOffset = currentOffset + DEATH_HISTORY_ROW_HEIGHT
    end
  end

  for i = rowIndex + 1, #deathHistoryRows do
    if deathHistoryRows[i] then
      deathHistoryRows[i]:Hide()
    end
  end

  deathHistoryContent:SetHeight(math.max(currentOffset, 40))
end

local function UpdateResourceTabDeathCounter()
  if not deathCounterValue then return end

  local deaths = 0
  if CharacterStats and CharacterStats.GetStat then
    deaths = CharacterStats:GetStat('playerDeaths') or 0
  end

  if formatNumberWithCommas then
    deathCounterValue:SetText(formatNumberWithCommas(deaths))
  else
    deathCounterValue:SetText(tostring(deaths))
  end
  if resourceCounterValue then
    resourceCounterValue:SetText(tostring(HARD_CODED_RESOURCE_COUNT))
  end
  RefreshDeathHistoryList()
end

_G.UpdateResourceTabDeathCounter = UpdateResourceTabDeathCounter

-- Initialize Resource Tab
function InitializeResourceTab()
  -- Check if tabContents[3] exists
  if not tabContents or not tabContents[3] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[3].initialized then return end

  -- Mark as initialized
  tabContents[3].initialized = true

  local resourcesTitle = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  resourcesTitle:SetPoint('TOP', tabContents[3], 'TOP', 0, -60)
  resourcesTitle:SetText('Resources & Progress')

  local deathCounterFrame = CreateFrame('Frame', nil, tabContents[3], 'BackdropTemplate')
  deathCounterFrame:SetSize(560, 180)
  deathCounterFrame:SetPoint('TOP', resourcesTitle, 'BOTTOM', 0, -20)
  deathCounterFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  deathCounterFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
  deathCounterFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  local deathCounterTitle = deathCounterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  deathCounterTitle:SetPoint('TOPLEFT', deathCounterFrame, 'TOPLEFT', 16, -16)
  deathCounterTitle:SetText('Death Counter')

  local deathLabel = deathCounterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  deathLabel:SetPoint('TOPLEFT', deathCounterTitle, 'BOTTOMLEFT', 0, -12)
  deathLabel:SetText('Deaths')

  deathCounterValue = deathCounterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  deathCounterValue:SetPoint('TOPLEFT', deathLabel, 'BOTTOMLEFT', 0, -6)
  local valueFont, _, valueFlags = deathCounterValue:GetFont()
  deathCounterValue:SetFont(valueFont, 44, valueFlags)
  deathCounterValue:SetJustifyH('LEFT')
  deathCounterValue:SetTextColor(0.98, 0.25, 0.25)

  local resourceLabel = deathCounterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  resourceLabel:SetPoint('TOPRIGHT', deathCounterTitle, 'BOTTOMRIGHT', 0, -12)
  resourceLabel:SetText('Resources')
  resourceLabel:SetJustifyH('RIGHT')

  resourceCounterValue = deathCounterFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  resourceCounterValue:SetPoint('TOPRIGHT', resourceLabel, 'BOTTOMRIGHT', 0, -6)
  resourceCounterValue:SetFont(valueFont, 36, valueFlags)
  resourceCounterValue:SetJustifyH('RIGHT')
  resourceCounterValue:SetTextColor(0.85, 0.85, 0.85)

  local deathHistoryFrame = CreateFrame('Frame', nil, tabContents[3], 'BackdropTemplate')
  deathHistoryFrame:SetSize(560, 280)
  deathHistoryFrame:SetPoint('TOP', deathCounterFrame, 'BOTTOM', 0, -20)
  deathHistoryFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  deathHistoryFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
  deathHistoryFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  local deathHistoryTitle = deathHistoryFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  deathHistoryTitle:SetPoint('TOPLEFT', deathHistoryFrame, 'TOPLEFT', 16, -16)
  deathHistoryTitle:SetText('Death History')

  local headerFrame = CreateFrame('Frame', nil, deathHistoryFrame)
  headerFrame:SetPoint('TOPLEFT', deathHistoryFrame, 'TOPLEFT', 12, -44)
  headerFrame:SetPoint('TOPRIGHT', deathHistoryFrame, 'TOPRIGHT', -24, -44)
  headerFrame:SetHeight(16)

  local levelHeader = headerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  levelHeader:SetPoint('LEFT', headerFrame, 'LEFT', 0, 0)
  levelHeader:SetWidth(DEATH_HISTORY_COLUMNS.level.width)
  levelHeader:SetJustifyH('LEFT')
  levelHeader:SetText(DEATH_HISTORY_COLUMNS.level.header)

  local locationHeader = headerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  locationHeader:SetPoint('LEFT', levelHeader, 'RIGHT', 10, 0)
  locationHeader:SetWidth(DEATH_HISTORY_COLUMNS.location.width)
  locationHeader:SetJustifyH('LEFT')
  locationHeader:SetText(DEATH_HISTORY_COLUMNS.location.header)

  local killerHeader = headerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  killerHeader:SetPoint('LEFT', locationHeader, 'RIGHT', 10, 0)
  killerHeader:SetWidth(DEATH_HISTORY_COLUMNS.killer.width)
  killerHeader:SetJustifyH('LEFT')
  killerHeader:SetText(DEATH_HISTORY_COLUMNS.killer.header)

  local healthHeader = headerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  healthHeader:SetPoint('LEFT', killerHeader, 'RIGHT', 10, 0)
  healthHeader:SetWidth(DEATH_HISTORY_COLUMNS.health.width)
  healthHeader:SetJustifyH('LEFT')
  healthHeader:SetText(DEATH_HISTORY_COLUMNS.health.header)

  local deathHistoryScrollFrame =
    CreateFrame('ScrollFrame', nil, deathHistoryFrame, 'UIPanelScrollFrameTemplate')
  deathHistoryScrollFrame:SetPoint('TOPLEFT', deathHistoryFrame, 'TOPLEFT', 12, -60)
  deathHistoryScrollFrame:SetPoint('BOTTOMRIGHT', deathHistoryFrame, 'BOTTOMRIGHT', -34, 12)

  deathHistoryContent = CreateFrame('Frame', nil, deathHistoryScrollFrame)
  deathHistoryContent:SetSize(520, 40)
  deathHistoryScrollFrame:SetScrollChild(deathHistoryContent)

  deathHistoryPlaceholder = deathHistoryContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  deathHistoryPlaceholder:SetPoint('TOP', deathHistoryContent, 'TOP', 0, -10)
  deathHistoryPlaceholder:SetWidth(480)
  deathHistoryPlaceholder:SetJustifyH('CENTER')
  deathHistoryPlaceholder:SetText('No deaths recorded yet.')

  tabContents[3]:HookScript('OnShow', UpdateResourceTabDeathCounter)
  UpdateResourceTabDeathCounter()
end
