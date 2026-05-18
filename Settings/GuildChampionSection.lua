-- Guild Champion summary above the settings leaderboard table.
-- Two bordered sub-panels (~60% / ~40%) with separate background tints.

local MID_GAP = 6
local CHAMPION_WIDTH_FRAC = 0.60
local OUTER_PAD_Y = 4

local SECTION_H = 58
local STATS_ROW_H = 46
local STATS_ROW_GAP = 6
local INNER_PAD = 8
local ICON_CHAMPION = 34
local ICON_PAD = 2

local LABEL_GOLD = { 1, 0.92, 0.62 }
local NAME_COLOR = { 0.95, 0.93, 0.88 }
local MUTED = { 0.62, 0.6, 0.55 }

-- Champion panel: warm brown-gold tint
local CHAMPION_BG = {
  r = 0.16,
  g = 0.12,
  b = 0.08,
  a = 0.94,
}
local CHAMPION_BORDER = {
  r = 0.58,
  g = 0.5,
  b = 0.32,
  a = 0.92,
}

-- AP panel: cooler slate tint
local AP_BG = {
  r = 0.08,
  g = 0.1,
  b = 0.14,
  a = 0.94,
}
local AP_BORDER = {
  r = 0.38,
  g = 0.45,
  b = 0.52,
  a = 0.88,
}

local CHAMPION_ICON_TEX = 'Interface\\Icons\\spell_holy_surgeoflight'

local PANEL_BACKDROP = {
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = false,
  edgeSize = 10,
  insets = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
}

local AP_PANEL_BACKDROP = {
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = false,
  edgeSize = 8,
  insets = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
}

local function makeIconFrame(parent, size, texturePath, edgeSize)
  edgeSize = edgeSize or 8
  local f = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  f:SetSize(size + ICON_PAD * 2, size + ICON_PAD * 2)
  f:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8x8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = false,
    edgeSize = edgeSize,
    insets = {
      left = 2,
      right = 2,
      top = 2,
      bottom = 2,
    },
  })
  f:SetBackdropColor(0.04, 0.04, 0.05, 1)
  f:SetBackdropBorderColor(0.48, 0.44, 0.36, 0.88)
  local t = f:CreateTexture(nil, 'ARTWORK')
  t:SetPoint('TOPLEFT', f, 'TOPLEFT', ICON_PAD, -ICON_PAD)
  t:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -ICON_PAD, ICON_PAD)
  t:SetTexture(texturePath)
  t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  return f
end

--- @param parent Frame
--- @param sortedRows table[]|nil same sort as leaderboard (#1 = top rank)
--- @param rightInset number align with leaderboard panel (e.g. PANEL_RIGHT_INSET)
--- @return Frame root container
--- @return number total height including internal padding
function UHC_CreateGuildChampionSection(parent, sortedRows, rightInset)
  rightInset = rightInset or 0

  local function topByStat(fieldName)
    if type(sortedRows) ~= 'table' then
      return nil
    end
    local top
    for i = 1, #sortedRows do
      local row = sortedRows[i]
      if type(row) == 'table' then
        local val = tonumber(row[fieldName]) or 0
        if val >= 0 then
          if not top then
            top = row
          else
            local topVal = tonumber(top[fieldName]) or 0
            if val > topVal then
              top = row
            elseif val == topVal then
              local lvl = tonumber(row.level) or 0
              local topLvl = tonumber(top.level) or 0
              if lvl > topLvl then
                top = row
              elseif lvl == topLvl and tostring(row.name or '') < tostring(top.name or '') then
                top = row
              end
            end
          end
        end
      end
    end
    return top
  end

  local topRank = sortedRows and sortedRows[1] or nil
  local topAp = nil
  if UHC_GetTopAchievementPointsGuildLeaderboardRowFromRows then
    topAp = UHC_GetTopAchievementPointsGuildLeaderboardRowFromRows(sortedRows)
  end
  local topEnemies = topByStat('enemiesSlain')
  local topDungeons = topByStat('dungeonsCompleted')
  local topJumps = topByStat('playerJumps')

  local innerH = SECTION_H
  local totalH = OUTER_PAD_Y * 2 + innerH + STATS_ROW_GAP + STATS_ROW_H
  local root = CreateFrame('Frame', nil, parent)
  root:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
  root:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -rightInset, 0)
  root:SetHeight(totalH)

  local championPane = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  championPane:SetBackdrop(PANEL_BACKDROP)
  championPane:SetBackdropColor(CHAMPION_BG.r, CHAMPION_BG.g, CHAMPION_BG.b, CHAMPION_BG.a)
  championPane:SetBackdropBorderColor(
    CHAMPION_BORDER.r,
    CHAMPION_BORDER.g,
    CHAMPION_BORDER.b,
    CHAMPION_BORDER.a
  )
  championPane:SetHeight(innerH)
  championPane:SetPoint('TOPLEFT', root, 'TOPLEFT', 0, -OUTER_PAD_Y)

  local apPane = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  apPane:SetBackdrop(AP_PANEL_BACKDROP)
  apPane:SetBackdropColor(AP_BG.r, AP_BG.g, AP_BG.b, AP_BG.a)
  apPane:SetBackdropBorderColor(AP_BORDER.r, AP_BORDER.g, AP_BORDER.b, AP_BORDER.a)
  apPane:SetHeight(innerH)

  local killerPane = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  killerPane:SetBackdrop(AP_PANEL_BACKDROP)
  killerPane:SetBackdropColor(AP_BG.r, AP_BG.g, AP_BG.b, AP_BG.a)
  killerPane:SetBackdropBorderColor(AP_BORDER.r, AP_BORDER.g, AP_BORDER.b, AP_BORDER.a)
  killerPane:SetHeight(STATS_ROW_H)
  local delverPane = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  delverPane:SetBackdrop(AP_PANEL_BACKDROP)
  delverPane:SetBackdropColor(AP_BG.r, AP_BG.g, AP_BG.b, AP_BG.a)
  delverPane:SetBackdropBorderColor(AP_BORDER.r, AP_BORDER.g, AP_BORDER.b, AP_BORDER.a)
  delverPane:SetHeight(STATS_ROW_H)
  local hopperPane = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  hopperPane:SetBackdrop(AP_PANEL_BACKDROP)
  hopperPane:SetBackdropColor(AP_BG.r, AP_BG.g, AP_BG.b, AP_BG.a)
  hopperPane:SetBackdropBorderColor(AP_BORDER.r, AP_BORDER.g, AP_BORDER.b, AP_BORDER.a)
  hopperPane:SetHeight(STATS_ROW_H)

  local iconChamp = makeIconFrame(championPane, ICON_CHAMPION, CHAMPION_ICON_TEX)

  local championTextHost = CreateFrame('Frame', nil, championPane)
  championTextHost:SetHeight(40)

  local labelChampion = championTextHost:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  labelChampion:SetJustifyH('LEFT')
  labelChampion:SetText('Guild Champion')
  labelChampion:SetTextColor(LABEL_GOLD[1], LABEL_GOLD[2], LABEL_GOLD[3])

  local nameChampion = championTextHost:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  nameChampion:SetJustifyH('LEFT')
  -- Stack straddles host vertical center so the block reads centered in the panel.
  labelChampion:SetPoint('LEFT', championTextHost, 'LEFT', 0, 0)
  labelChampion:SetPoint('RIGHT', championTextHost, 'RIGHT', 0, 0)
  labelChampion:SetPoint('BOTTOM', championTextHost, 'CENTER', 0, 2)
  nameChampion:SetPoint('LEFT', championTextHost, 'LEFT', 0, 0)
  nameChampion:SetPoint('RIGHT', championTextHost, 'RIGHT', 0, 0)
  nameChampion:SetPoint('TOP', championTextHost, 'CENTER', 0, -5)
  if topRank and topRank.name and topRank.name ~= '' then
    local dn =
      UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(
        topRank.name
      ) or topRank.name
    nameChampion:SetText(tostring(dn))
    nameChampion:SetTextColor(NAME_COLOR[1], NAME_COLOR[2], NAME_COLOR[3])
  else
    nameChampion:SetText('—')
    nameChampion:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  end

  local labelAp = apPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  labelAp:SetJustifyH('CENTER')
  labelAp:SetText('Over Achiever')
  labelAp:SetTextColor(LABEL_GOLD[1] * 0.9, LABEL_GOLD[2] * 0.9, LABEL_GOLD[3] * 0.9)

  local detailAp = apPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  detailAp:SetJustifyH('CENTER')
  detailAp:SetWordWrap(true)
  if topAp and topAp.name and topAp.name ~= '' then
    local dn =
      UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(topAp.name) or topAp.name
    detailAp:SetText(
      string.format('%s  ·  %s', tostring(dn), tostring(topAp.achievementPoints or 0))
    )
    detailAp:SetTextColor(0.82, 0.8, 0.74)
  else
    detailAp:SetText('—')
    detailAp:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  end

  local labelKiller = killerPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  labelKiller:SetJustifyH('CENTER')
  labelKiller:SetText('Bloodthirsty')
  labelKiller:SetTextColor(LABEL_GOLD[1] * 0.9, LABEL_GOLD[2] * 0.9, LABEL_GOLD[3] * 0.9)
  local detailKiller = killerPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  detailKiller:SetJustifyH('CENTER')
  detailKiller:SetWordWrap(true)
  if topEnemies and topEnemies.name and topEnemies.name ~= '' then
    local dn =
      UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(
        topEnemies.name
      ) or topEnemies.name
    detailKiller:SetText(
      string.format('%s  ·  %s', tostring(dn), tostring(topEnemies.enemiesSlain or 0))
    )
    detailKiller:SetTextColor(0.82, 0.8, 0.74)
  else
    detailKiller:SetText('—')
    detailKiller:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  end

  local labelDelver = delverPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  labelDelver:SetJustifyH('CENTER')
  labelDelver:SetText('Dungeon Delver')
  labelDelver:SetTextColor(LABEL_GOLD[1] * 0.9, LABEL_GOLD[2] * 0.9, LABEL_GOLD[3] * 0.9)
  local detailDelver = delverPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  detailDelver:SetJustifyH('CENTER')
  detailDelver:SetWordWrap(true)
  if topDungeons and topDungeons.name and topDungeons.name ~= '' then
    local dn =
      UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(
        topDungeons.name
      ) or topDungeons.name
    detailDelver:SetText(
      string.format('%s  ·  %s', tostring(dn), tostring(topDungeons.dungeonsCompleted or 0))
    )
    detailDelver:SetTextColor(0.82, 0.8, 0.74)
  else
    detailDelver:SetText('—')
    detailDelver:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  end

  local labelHopper = hopperPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  labelHopper:SetJustifyH('CENTER')
  labelHopper:SetText('Hopper')
  labelHopper:SetTextColor(LABEL_GOLD[1] * 0.9, LABEL_GOLD[2] * 0.9, LABEL_GOLD[3] * 0.9)
  local detailHopper = hopperPane:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  detailHopper:SetJustifyH('CENTER')
  detailHopper:SetWordWrap(true)
  if topJumps and topJumps.name and topJumps.name ~= '' then
    local dn =
      UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(
        topJumps.name
      ) or topJumps.name
    detailHopper:SetText(
      string.format('%s  ·  %s', tostring(dn), tostring(topJumps.playerJumps or 0))
    )
    detailHopper:SetTextColor(0.82, 0.8, 0.74)
  else
    detailHopper:SetText('—')
    detailHopper:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  end

  local function layoutColumns()
    local rw = root:GetWidth()
    if (not rw or rw < 2) and parent and parent.GetWidth then
      rw = math.max(0, parent:GetWidth() - rightInset)
    end
    local w = rw - MID_GAP
    if w < 50 then
      w = 280
    end
    local cw = math.floor(w * CHAMPION_WIDTH_FRAC + 0.5)
    local aw = w - cw
    championPane:SetWidth(cw)
    apPane:SetWidth(aw)
    apPane:ClearAllPoints()
    apPane:SetPoint('TOPLEFT', championPane, 'TOPRIGHT', MID_GAP, 0)
    apPane:SetHeight(innerH)

    killerPane:ClearAllPoints()
    killerPane:SetPoint('TOPLEFT', championPane, 'BOTTOMLEFT', 0, -STATS_ROW_GAP)
    killerPane:SetHeight(STATS_ROW_H)

    local rowW = rw - (MID_GAP * 2)
    if rowW < 90 then
      rowW = 270
    end
    local eachW = math.floor(rowW / 3)
    local rem = rowW - (eachW * 3)
    local w1 = eachW
    local w2 = eachW
    local w3 = eachW + rem
    killerPane:SetWidth(w1)
    delverPane:ClearAllPoints()
    delverPane:SetPoint('TOPLEFT', killerPane, 'TOPRIGHT', MID_GAP, 0)
    delverPane:SetWidth(w2)
    delverPane:SetHeight(STATS_ROW_H)
    hopperPane:ClearAllPoints()
    hopperPane:SetPoint('TOPLEFT', delverPane, 'TOPRIGHT', MID_GAP, 0)
    hopperPane:SetWidth(w3)
    hopperPane:SetHeight(STATS_ROW_H)

    local W = championPane:GetWidth()
    local iw = iconChamp:GetWidth()
    if W and W > 20 and iw and iw > 0 then
      local gapTextIcon = 8
      local dxIcon = W * 0.5 - INNER_PAD - iw * 0.5
      iconChamp:ClearAllPoints()
      iconChamp:SetPoint('CENTER', championPane, 'CENTER', dxIcon, 0)

      local textW = math.max(40, W - INNER_PAD * 2 - gapTextIcon - iw)
      championTextHost:SetWidth(textW)
      local offText = INNER_PAD + textW * 0.5 - W * 0.5
      championTextHost:ClearAllPoints()
      championTextHost:SetPoint('CENTER', championPane, 'CENTER', offText, 0)
    end

    labelAp:ClearAllPoints()
    detailAp:ClearAllPoints()
    labelAp:SetPoint('LEFT', apPane, 'LEFT', INNER_PAD, 0)
    labelAp:SetPoint('RIGHT', apPane, 'RIGHT', -INNER_PAD, 0)
    labelAp:SetPoint('BOTTOM', apPane, 'CENTER', 0, 5)
    detailAp:SetPoint('LEFT', apPane, 'LEFT', INNER_PAD, 0)
    detailAp:SetPoint('RIGHT', apPane, 'RIGHT', -INNER_PAD, 0)
    detailAp:SetPoint('TOP', apPane, 'CENTER', 0, -5)

    local function layoutStatPane(labelFs, detailFs, pane)
      labelFs:ClearAllPoints()
      detailFs:ClearAllPoints()
      labelFs:SetPoint('LEFT', pane, 'LEFT', INNER_PAD, 0)
      labelFs:SetPoint('RIGHT', pane, 'RIGHT', -INNER_PAD, 0)
      labelFs:SetPoint('BOTTOM', pane, 'CENTER', 0, 4)
      detailFs:SetPoint('LEFT', pane, 'LEFT', INNER_PAD, 0)
      detailFs:SetPoint('RIGHT', pane, 'RIGHT', -INNER_PAD, 0)
      detailFs:SetPoint('TOP', pane, 'CENTER', 0, -4)
    end
    layoutStatPane(labelKiller, detailKiller, killerPane)
    layoutStatPane(labelDelver, detailDelver, delverPane)
    layoutStatPane(labelHopper, detailHopper, hopperPane)
  end

  root:SetScript('OnSizeChanged', layoutColumns)
  root:SetScript('OnShow', layoutColumns)
  layoutColumns()

  return root, totalH
end
