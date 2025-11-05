-- Challenges.lua
-- Core logic and state machine for Challenges

local ADDON_NAME, ns = ...
local M = {}
ns.Challenges = M

-- -------------------------
-- SavedVariables structure
-- -------------------------
-- UHC_ChallengeState = {
--   locked = false,
--   startedAtLevel = 1,
--   preset = "NONE" | "SOLO_SELF_FOUND" | "IRON_LITE" | "CUSTOM",
--   rules = {
--     noGrouping = false,
--     noExternalEconomy = false, -- trade/mail/ah/bank/guildbank
--     deathFails = true,         -- default true
--   },
--   status = "INACTIVE" | "ACTIVE" | "FAILED" | "COMPLETE",
--   failReason = nil,
--   lockTime = 0,
--   completeTime = 0,
-- }

-- -------------- Utilities --------------
local function d(...) if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff88ccff[UHC]|r "..table.concat({...}," ")) end end
local function now() return time() end

local function getPlayerLevel()
  return UnitLevel and UnitLevel("player") or 1
end

local function getMaxLevel()
  -- Try multiple APIs for cross-version compatibility
  if GetMaxLevelForPlayerExpansion then
    return GetMaxLevelForPlayerExpansion()
  end
  if MAX_PLAYER_LEVEL then
    return MAX_PLAYER_LEVEL
  end
  -- Fallbacks (classic/era commonly 60; seasonal/retail varies)
  return 60
end

local function ensureDB()
  UHC_ChallengeState = UHC_ChallengeState or {}
  local db = UHC_ChallengeState
  db.rules = db.rules or {}
  if db.status == nil then db.status = "INACTIVE" end
  if db.rules.deathFails == nil then db.rules.deathFails = true end
  if db.preset == nil then db.preset = "NONE" end
  return db
end

-- -------------- Presets --------------
local PRESETS = {
  NONE = { name = "None", apply = function(r) end },
  SOLO_SELF_FOUND = {
    name = "Solo Self-Found",
    apply = function(r)
      r.noGrouping = true
      r.noExternalEconomy = true
      r.deathFails = true
    end
  },
  IRON_LITE = {
    name = "Ironman (Lite)",
    apply = function(r)
      r.noGrouping = true
      r.deathFails = true
      -- leave economy allowed in “Lite”
      r.noExternalEconomy = false
    end
  },
}

function M.GetPresets() return PRESETS end

local function applyPreset(db, key)
  db.preset = key
  db.rules = db.rules or {}
  -- reset to defaults, then apply
  db.rules.noGrouping = false
  db.rules.noExternalEconomy = false
  db.rules.deathFails = true
  if PRESETS[key] and PRESETS[key].apply then
    PRESETS[key].apply(db.rules)
  end
end

-- -------------- State Machine --------------
function M.LockChallenges()
  local db = ensureDB()
  if db.locked then return end
  if getPlayerLevel() > 1 then
    -- Past the allowed point: lock as-is (or inactive if nothing chosen)
    db.locked = true
    db.status = (db.preset ~= "NONE" or db.rules.noGrouping or db.rules.noExternalEconomy) and "ACTIVE" or "INACTIVE"
    db.lockTime = now()
    d("Challenges auto-locked at level "..getPlayerLevel()..".")
    return
  end
  db.locked = true
  db.status = (db.preset ~= "NONE" or db.rules.noGrouping or db.rules.noExternalEconomy) and "ACTIVE" or "INACTIVE"
  db.startedAtLevel = getPlayerLevel()
  db.lockTime = now()
  d("Challenges locked.")
end

local function failChallenge(reason)
  local db = ensureDB()
  if db.status ~= "ACTIVE" then return end
  db.status = "FAILED"
  db.failReason = reason
  d("Challenge failed: "..reason)
end

local function maybeComplete()
  local db = ensureDB()
  if db.status ~= "ACTIVE" then return end
  if getPlayerLevel() >= getMaxLevel() then
    db.status = "COMPLETE"
    db.completeTime = now()
    d("Challenge complete! Reached max level.")
  end
end

-- -------------- Rule Checks --------------
local function onGroupChanged()
  local db = ensureDB()
  if not (db.locked and db.status == "ACTIVE") then return end
  if db.rules.noGrouping then
    -- Any party/raid membership fails the rule
    if IsInGroup() or IsInRaid() then
      failChallenge("Joined a group/raid")
    end
  end
end

local function onProhibitedEconomy()
  local db = ensureDB()
  if not (db.locked and db.status == "ACTIVE") then return end
  if db.rules.noExternalEconomy then
    failChallenge("Interacted with trade/mail/auction/bank")
  end
end

local function onDeath()
  local db = ensureDB()
  if not (db.locked and db.status == "ACTIVE") then return end
  if db.rules.deathFails then
    failChallenge("Died")
  end
end

-- -------------- Events --------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_DEAD")
-- Economy interactions:
f:RegisterEvent("TRADE_SHOW")
f:RegisterEvent("AUCTION_HOUSE_SHOW")           -- Retail
f:RegisterEvent("AUCTION_HOUSE_SHOW_HACK")      -- Just in case (older builds)
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("GUILDBANKFRAME_OPENED")
f:RegisterEvent("MAIL_SHOW")

f:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then
    local db = ensureDB()
    -- Auto-lock if they log in past level 1
    if not db.locked and getPlayerLevel() > 1 then
      M.LockChallenges()
    end
    -- If locked and active, enforce immediate group/economy checks
    if db.locked and db.status == "ACTIVE" then
      onGroupChanged()
      maybeComplete()
    end

  elseif event == "PLAYER_LEVEL_UP" then
    local level = ...
    -- If they dinged past 1 and not locked, auto-lock
    local db = ensureDB()
    if level >= 2 and not db.locked then
      M.LockChallenges()
    end
    maybeComplete()

  elseif event == "GROUP_ROSTER_UPDATE" then
    onGroupChanged()

  elseif event == "PLAYER_DEAD" then
    onDeath()

  elseif event == "TRADE_SHOW" or event == "AUCTION_HOUSE_SHOW" or event == "BANKFRAME_OPENED"
      or event == "GUILDBANKFRAME_OPENED" or event == "MAIL_SHOW" or event == "AUCTION_HOUSE_SHOW_HACK" then
    onProhibitedEconomy()
  end
end)

-- -------------- Public API --------------
function M.GetState()
  return ensureDB()
end

function M.SetPreset(key)
  local db = ensureDB()
  if db.locked then return false, "Challenges are locked." end
  applyPreset(db, key)
  if getPlayerLevel() > 1 then
    -- Safety: if they managed to open UI after level 1 before auto-lock triggers
    M.LockChallenges()
  end
  return true
end

function M.SetRule(key, value)
  local db = ensureDB()
  if db.locked then return false, "Challenges are locked." end
  db.rules[key] = not not value
  if getPlayerLevel() > 1 then
    M.LockChallenges()
  end
  return true
end

function M.GetSummaryText()
  local db = ensureDB()
  local parts = {}
  if db.rules.noGrouping then table.insert(parts, "No Grouping") end
  if db.rules.noExternalEconomy then table.insert(parts, "Self-Found (no trade/mail/AH/bank)") end
  if db.rules.deathFails then table.insert(parts, "Death = Fail") end
  local rules = (#parts > 0) and table.concat(parts, ", ") or "No active rules"
  return string.format("Status: %s  |  Rules: %s", db.status, rules)
end
