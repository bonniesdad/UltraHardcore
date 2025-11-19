-- Challenges.lua

local addonName = ...
local Challenges = {}
_G.Challenges = Challenges

-- Aura visible to others
local ADDON_PREFIX = "UHC_AURA"
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)

-- Persistence (per character)
local function ensureStorage()
  GLOBAL_SETTINGS = GLOBAL_SETTINGS or {}
  GLOBAL_SETTINGS.challenges = GLOBAL_SETTINGS.challenges or {
    enabled         = {},
    failed          = {},
    complete        = {},
    lastFail        = {},

    -- selection & locking
    selected        = {},
    selectionLocked = false,
    lockedAtLevel   = nil,
    lockedReason    = nil,
    activePreset    = nil,

    -- aura
    aura            = {
      points    = 0,
      rank      = 0,
      lastLevel = UnitLevel and UnitLevel("player") or 1,
    },
  }

  local s = GLOBAL_SETTINGS.challenges
  -- ensure aura exists even if table was created before we added it
  s.aura = s.aura or {
    points    = 0,
    rank      = 0,
    lastLevel = UnitLevel and UnitLevel("player") or 1,
    posX      = 260,
    posY      = -180,
  }
  s.aura.points    = s.aura.points    or 0
  s.aura.rank      = s.aura.rank      or 0
  s.aura.lastLevel = s.aura.lastLevel or (UnitLevel and UnitLevel("player") or 1)
  s.aura.posX      = s.aura.posX      or 260
  s.aura.posY      = s.aura.posY      or -180

  return s
end

-- Simple callback bus for the UI (must exist before any _emit calls)
local CALLBACKS = {}

-- ===== Class rules micro-registry (UI helpers) =====
local _UHC_CLASS_RULES = _UHC_CLASS_RULES or {}  -- key -> { name, desc, icon }

function Challenges.RegisterClassRule(key, data)
  -- data = { name=..., desc=..., icon=... }
  _UHC_CLASS_RULES[key] = {
    name = (data and data.name) or key,
    desc = (data and data.desc) or "",
    icon = data and data.icon or nil,
  }
end

function Challenges.GetAvailableClassRules()
  return _UHC_CLASS_RULES  -- { key -> {name, desc, icon} }
end

function Challenges.GetClassRuleSelection()
  local s = (type(ensureStorage) == "function") and ensureStorage() or nil
  return (s and s.rules and s.rules.classRule) or "NONE"
end

function Challenges.SetClassRule(key)
  local db = Challenges.GetState and Challenges.GetState() or nil
  if not db then return false, "DB not ready." end
  if db.locked then return false, "Challenges are locked." end
  db.rules = db.rules or {}
  db.rules.classRule = key or "NONE"
  return true
end

-- ===== Aura state =====
local function _auraAddPoints(amount)
  local s = ensureStorage()
  s.aura = s.aura or { points = 0, rank = 0, lastLevel = UnitLevel("player") or 1 }
  s.aura.points = (s.aura.points or 0) + (amount or 0)
end

function Challenges.GetAuraState()
  local s = ensureStorage()
  s.aura = s.aura or {
    points    = 0,
    rank      = 0,
    lastLevel = UnitLevel and UnitLevel("player") or 1,
    posX      = 260,
    posY      = -180,
  }

  -- make sure fields exist even on old saves
  s.aura.points    = s.aura.points    or 0
  s.aura.rank      = s.aura.rank      or 0
  s.aura.lastLevel = s.aura.lastLevel or (UnitLevel and UnitLevel("player") or 1)
  s.aura.posX      = s.aura.posX      or 260
  s.aura.posY      = s.aura.posY      or -180

  local names = {}

  -- REGISTRY might not be global at this point; be defensive
  local registry = rawget(_G, "REGISTRY")
  if not registry and Challenges._registry then
    registry = Challenges._registry
  end

  for id, enabled in pairs(s.enabled) do
    if enabled then
      local name = id
      if registry and registry[id] and registry[id].name then
        name = registry[id].name
      end
      table.insert(names, name)
    end
  end

  return {
    points     = s.aura.points or 0,
    rank       = s.aura.rank or 0,
    locked     = s.selectionLocked and true or false,
    challenges = names,
  }
end

-- ===== Aura widget (small UI button) =====
local auraFrame

local function _CreateAuraFrame()
  if auraFrame then return end

  local s  = ensureStorage()
  local ax = s.aura.posX or 260
  local ay = s.aura.posY or -180

  auraFrame = CreateFrame("Button", "UHC_ChallengeAura", UIParent, "BackdropTemplate")
  auraFrame:SetSize(32, 32)
  auraFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ax, ay)

  auraFrame:SetBackdrop({
    bgFile   = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Buttons/WHITE8x8",
    edgeSize = 1,
  })
  auraFrame:SetBackdropColor(0,0,0,0.4)
  auraFrame:SetBackdropBorderColor(0,0,0,0.8)

  auraFrame.icon = auraFrame:CreateTexture(nil, "ARTWORK")
  auraFrame.icon:SetAllPoints(auraFrame)
  auraFrame.icon:SetTexture("Interface\\Icons\\spell_holy_auraoflight")

  auraFrame.count = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  auraFrame.count:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", -2, 2)
  auraFrame.count:SetText("0")

  -- make it movable
  auraFrame:SetMovable(true)
  auraFrame:EnableMouse(true)
  auraFrame:RegisterForDrag("LeftButton")
  auraFrame:SetClampedToScreen(true)

  auraFrame:SetScript("OnDragStart", function(self)
    -- require Shift to be held to drag; remove this check if you want free drag
    if IsShiftKeyDown() then
      self:StartMoving()
    end
  end)

  auraFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local _, _, _, x, y = self:GetPoint()
    local s = ensureStorage()
    s.aura.posX = x
    s.aura.posY = y
  end)

  auraFrame:SetScript("OnEnter", function(self)
    local info = Challenges.GetAuraState()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Ultra Hardcore Challenges", 1, 0.82, 0)

    if #info.challenges > 0 then
      GameTooltip:AddLine("Active Challenges:", 0.8, 0.9, 1)
      for _, n in ipairs(info.challenges) do
        GameTooltip:AddLine(" - "..n, 0.9, 0.9, 0.9)
      end
    else
      GameTooltip:AddLine("No active challenges.", 0.8, 0.8, 0.8)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(("Aura Points: |cff00ff00%d|r"):format(info.points or 0))
    GameTooltip:Show()
  end)

  auraFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

function Challenges._UpdateAuraFrame()
  _CreateAuraFrame()
  local info = Challenges.GetAuraState()
  local s = ensureStorage()

  -- choose icon: first enabled challenge with an icon
  local iconTex = "Interface\\Icons\\spell_holy_auraoflight"
  for id, enabled in pairs(s.enabled) do
    if enabled and REGISTRY[id] and REGISTRY[id].icon then
      iconTex = REGISTRY[id].icon
      break
    end
  end

  auraFrame.icon:SetTexture(iconTex)
  auraFrame.count:SetText(tostring(info.points or 0))
  auraFrame:Show()
end

local function _SendAuraUpdate()
  local s = ensureStorage()
  local info = Challenges.GetAuraState()

  local challengeIds = {}
  for id, enabled in pairs(s.enabled) do
    if enabled then table.insert(challengeIds, id) end
  end

  local payload = table.concat({
    tostring(info.points or 0),
    table.concat(challengeIds, ","),
  }, ";")

  -- Broadcast to others running the addon
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, payload, "PARTY")
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, payload, "RAID")
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, payload, "GUILD")
end

Challenges._SendAuraUpdate = _SendAuraUpdate

function Challenges.On(eventName, fn)
  if type(fn) ~= "function" then return end
  CALLBACKS[eventName] = CALLBACKS[eventName] or {}
  table.insert(CALLBACKS[eventName], fn)
end

function Challenges._emit(eventName, ...)
  local list = CALLBACKS[eventName]
  if not list then return end
  for _, fn in ipairs(list) do
    pcall(fn, ...)
  end
end

local function persist()
  if type(SaveCharacterSettings) == "function" and GLOBAL_SETTINGS then
    SaveCharacterSettings(GLOBAL_SETTINGS)
  end
end

local REGISTRY    = {}
local EVENT_INDEX = {}
local PRESETS     = {}

function Challenges.Register(def)
  assert(type(def) == "table" and def.id, "Challenges.Register: def.id required")
  assert(not REGISTRY[def.id], "Challenges.Register: duplicate id '" .. def.id .. "'")

  -- shallow copy + defaults
  local entry = {}
  for k, v in pairs(def) do entry[k] = v end
  entry.name = entry.name or entry.id
  entry.description = entry.description or ""
  entry.isComplete = entry.isComplete or function() return UnitLevel("player") >= 60 end
  REGISTRY[entry.id] = entry

  if entry.events then
    for _, ev in ipairs(entry.events) do
      EVENT_INDEX[ev] = EVENT_INDEX[ev] or {}
      EVENT_INDEX[ev][entry.id] = true
    end
  end

  local s = ensureStorage()
  if s.enabled[entry.id]  == nil then s.enabled[entry.id]  = false end
  if s.failed[entry.id]   == nil then s.failed[entry.id]   = false end
  if s.complete[entry.id] == nil then s.complete[entry.id] = false end

  Challenges._refreshEventSubscriptions()
  return entry.id
end

-- Selection & lock
function Challenges.CanModifySelection()
  local s = ensureStorage()
  if s.selectionLocked then return false end
  local level = (UnitLevel and UnitLevel("player")) or 1
  return level < 2
end

function Challenges.IsSelectionLocked()
  return ensureStorage().selectionLocked == true
end

function Challenges.GetSelected()
  return ensureStorage().selected
end

-- Pre-lock checks for compliance
function Challenges.ValidateSelection()
  local s = ensureStorage()
  local failures = {}

  for id, enabled in pairs(s.enabled) do
    if enabled then
      local def = REGISTRY[id]
      if def and type(def.validate) == "function" then
        local okCall, res, why = pcall(def.validate, def)
        local ok = okCall and (res ~= false)
        if not ok then
          table.insert(failures, {
            id     = id,
            name   = def.name or id,
            reason = why or "Not compliant",
          })
        end
      end
    end
  end

  return (#failures == 0), failures
end

function Challenges.TryLock(reason)
  if not Challenges.CanModifySelection() then
    return false, {
      { id = "lock", name = "Selection", reason = "Selection is locked at level 2." }
    }
  end

  local ok, failures = Challenges.ValidateSelection()
  if not ok then
    return false, failures
  end

  Challenges.LockSelection(reason or "Confirmed")
  return true
end

function Challenges.LockSelection(reason)
  local s = ensureStorage()
  if s.selectionLocked then return end
  s.selectionLocked = true
  s.lockedAtLevel   = UnitLevel and UnitLevel("player") or nil
  s.lockedReason    = reason or "Confirmed"
  persist()
  Challenges._emit("CHALLENGES_LOCKED")
  if Challenges._UpdateAuraFrame then Challenges._UpdateAuraFrame() end
  if Challenges._SendAuraUpdate then Challenges._SendAuraUpdate() end

end

function Challenges._autoLockOnLevel2(level)
  local s = ensureStorage()
  if not s.selectionLocked and level and level >= 2 then
    for id in pairs(s.enabled) do s.enabled[id] = false end
    for id in pairs(s.selected) do s.selected[id] = nil end
    s.activePreset = nil

    s.selectionLocked = true
    s.lockedAtLevel   = level
    s.lockedReason    = "Reached level 2"
    persist()
    Challenges._emit("CHALLENGES_LOCKED")
  end
end

-- Enable/disable/toggle (respect locking)
function Challenges.Enable(id)
  local s = ensureStorage()
  if not REGISTRY[id] then return end
  if not Challenges.CanModifySelection() then return end
  s.enabled[id]  = true
  s.failed[id]   = false
  s.complete[id] = false
  s.selected[id] = true
  persist()
  local def = REGISTRY[id]
  if def and def.onEnable then pcall(def.onEnable, def) end
  Challenges._refreshEventSubscriptions()
  Challenges._emit("CHALLENGE_ENABLED", id)
end

function Challenges.Disable(id)
  local s = ensureStorage()
  if not REGISTRY[id] then return end
  if not Challenges.CanModifySelection() then return end
  s.enabled[id]  = false
  s.selected[id] = nil
  persist()
  local def = REGISTRY[id]
  if def and def.onDisable then pcall(def.onDisable, def) end
  Challenges._refreshEventSubscriptions()
  Challenges._emit("CHALLENGE_DISABLED", id)
end

function Challenges.Toggle(id)
  local s = ensureStorage()
  if s.enabled[id] then Challenges.Disable(id) else Challenges.Enable(id) end
end

function Challenges.IsEnabled(id)   return ensureStorage().enabled[id]  == true end
function Challenges.IsFailed(id)    return ensureStorage().failed[id]   == true end
function Challenges.IsComplete(id)  return ensureStorage().complete[id] == true end
function Challenges.LastFailReason(id) return ensureStorage().lastFail[id] end

-- Terminal states
function Challenges.Fail(id, reason)
  local s = ensureStorage()
  if not REGISTRY[id] then return end
  if s.failed[id] or s.complete[id] then return end
  s.failed[id]   = true
  s.lastFail[id] = reason or "Rule violated"
  persist()
  Challenges._emit("CHALLENGE_FAILED", id, s.lastFail[id])
  if Challenges._UpdateAuraFrame then Challenges._UpdateAuraFrame() end
  if Challenges._SendAuraUpdate then Challenges._SendAuraUpdate() end
end

function Challenges.MarkComplete(id)
  local s = ensureStorage()
  if not REGISTRY[id] then return end
  if s.failed[id] or s.complete[id] then return end
  s.complete[id] = true
  persist()
  Challenges._emit("CHALLENGE_COMPLETED", id)
  if Challenges._UpdateAuraFrame then Challenges._UpdateAuraFrame() end
  if Challenges._SendAuraUpdate then Challenges._SendAuraUpdate() end
end

-- Queries
function Challenges.GetAll() return REGISTRY end
function Challenges.GetState(id)
  local s = ensureStorage()
  return {
    enabled  = s.enabled[id]  == true,
    failed   = s.failed[id]   == true,
    complete = s.complete[id] == true,
    lastFail = s.lastFail[id],
    def      = REGISTRY[id],
  }
end

-- Presets
function Challenges.RegisterPreset(name, ids)
  assert(type(name) == "string" and name ~= "", "Preset name required")
  assert(type(ids) == "table", "Preset ids must be a table")
  PRESETS[name] = ids
end

function Challenges.GetPresets()
  return PRESETS
end

function Challenges.ApplyPreset(name)
  local s = ensureStorage()
  if not Challenges.CanModifySelection() then return end
  local list = PRESETS[name]
  if not list then return end

  for id in pairs(s.enabled)  do s.enabled[id]  = false end
  for id in pairs(s.selected) do s.selected[id] = nil   end

  for _, id in ipairs(list) do
    if REGISTRY[id] then
      s.enabled[id]  = true
      s.selected[id] = true
    end
  end
  s.activePreset = name
  persist()
  Challenges._refreshEventSubscriptions()
  Challenges._emit("CHALLENGES_PRESET_APPLIED", name)
end


local evtFrame = CreateFrame("Frame")
local BASE_EVENTS = {
  "PLAYER_DEAD",
  "PLAYER_LEVEL_UP",
}

function Challenges._refreshEventSubscriptions()
  evtFrame:UnregisterAllEvents()
  for _, ev in ipairs(BASE_EVENTS) do
    evtFrame:RegisterEvent(ev)
  end

  local s = ensureStorage()
  local needed = {}
  for id, def in pairs(REGISTRY) do
    if s.enabled[id] and def.events then
      for _, ev in ipairs(def.events) do
        needed[ev] = true
      end
    end
  end
  for ev in pairs(needed) do
    evtFrame:RegisterEvent(ev)
  end
end

evtFrame:SetScript("OnEvent", function(_, event, ...)
  local s = ensureStorage()

  if event == "PLAYER_DEAD" then
    for id in pairs(s.enabled) do
      if s.enabled[id] and not s.failed[id] and not s.complete[id] then
        Challenges.Fail(id, "Player died")
      end
    end
    return

  elseif event == "PLAYER_LEVEL_UP" then
    local level = ...
    -- existing auto-lock + completion logic
    Challenges._autoLockOnLevel2(level)
    if level and level >= 60 then
      for id, def in pairs(REGISTRY) do
        if s.enabled[id] and not s.failed[id] and not s.complete[id] then
          local ok = true
          if def.isComplete then
            local okCall, res = pcall(def.isComplete, def)
            ok = okCall and (res ~= false)
          end
          if ok then
            Challenges.MarkComplete(id)
          end
        end
      end
    end

    -- aura points: +10 per level while any challenge is active
    local hasActive = false
    for id, enabled in pairs(s.enabled) do
      if enabled and not s.failed[id] and not s.complete[id] then
        hasActive = true
        break
      end
    end
    if hasActive then
      _auraAddPoints(10)
      if Challenges._UpdateAuraFrame then
        Challenges._UpdateAuraFrame()
      end
    end
  end

  -- Dispatch challenge events
  local ids = EVENT_INDEX[event]
  if ids then
    for id in pairs(ids) do
      if s.enabled[id] and not s.failed[id] and not s.complete[id] then
        local def = REGISTRY[id]
        if def and type(def.onEvent) == "function" then
          pcall(def.onEvent, def, event, ...)
        end
      end
    end
  end
end)

-- initialize storage + auto-lock + aura frame
ensureStorage()
local lvl = UnitLevel and UnitLevel("player") or 1
if lvl >= 2 then
  Challenges._autoLockOnLevel2(lvl)
end
if Challenges._UpdateAuraFrame then
  Challenges._UpdateAuraFrame()
end

local auraCache = {}  -- store what we know about others

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
  if prefix ~= ADDON_PREFIX then return end

  -- message format:  points;id1,id2,id3
  local pts, ids = strsplit(";", message)
  pts = tonumber(pts) or 0

  local challengeList = {}
  if ids and #ids > 0 then
    for id in string.gmatch(ids, "[^,]+") do
      table.insert(challengeList, id)
    end
  end

  auraCache[sender] = {
    points = pts,
    challenges = challengeList,
    time = GetTime(),
  }
end)

Challenges._AuraCache = auraCache

GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
  local name, realm = UnitName("mouseover")
  if not name then return end

  local key = name
  if auraCache[key] then
    tooltip:AddLine(" ")
    tooltip:AddLine("|cff00ff00Ultra Hardcore|r")

    tooltip:AddLine("Aura Points: " .. tostring(auraCache[key].points or 0))

    if #auraCache[key].challenges > 0 then
      tooltip:AddLine("Challenges:", 1, 1, 1)
      for _, id in ipairs(auraCache[key].challenges) do
        tooltip:AddLine(" - " .. (REGISTRY[id] and REGISTRY[id].name or id))
      end
    end
  end
end)

