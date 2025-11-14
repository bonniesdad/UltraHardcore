-- Challenges.lua

local addonName = ...
local Challenges = {}
_G.Challenges = Challenges

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
  }
  return GLOBAL_SETTINGS.challenges
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

function Challenges.LockSelection(reason)
  local s = ensureStorage()
  if s.selectionLocked then return end
  s.selectionLocked = true
  s.lockedAtLevel   = UnitLevel and UnitLevel("player") or nil
  s.lockedReason    = reason or "Confirmed"
  persist()
  Challenges._emit("CHALLENGES_LOCKED")
end

function Challenges._autoLockOnLevel2(level)
  local s = ensureStorage()
  if not s.selectionLocked and level and level >= 2 then
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
end

function Challenges.MarkComplete(id)
  local s = ensureStorage()
  if not REGISTRY[id] then return end
  if s.failed[id] or s.complete[id] then return end
  s.complete[id] = true
  persist()
  Challenges._emit("CHALLENGE_COMPLETED", id)
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
  for _, ev in ipairs(BASE_EVENTS) do evtFrame:RegisterEvent(ev) end

  local s = ensureStorage()
  local needed = {}
  for id, def in pairs(REGISTRY) do
    if s.enabled[id] and def.events then
      for _, ev in ipairs(def.events) do needed[ev] = true end
    end
  end
  for ev in pairs(needed) do evtFrame:RegisterEvent(ev) end
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
    Challenges._autoLockOnLevel2(level)
    if level and level >= 60 then
      for id, def in pairs(REGISTRY) do
        if s.enabled[id] and not s.failed[id] and not s.complete[id] then
          local ok = true
          if def.isComplete then
            local okCall, res = pcall(def.isComplete, def)
            ok = okCall and (res ~= false)
          end
          if ok then Challenges.MarkComplete(id) end
        end
      end
    end
  end

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

ensureStorage()
local lvl = UnitLevel and UnitLevel("player") or 1
if lvl >= 2 then Challenges._autoLockOnLevel2(lvl) end
