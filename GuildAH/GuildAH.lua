local ADDON_NAME, ns = ...
ns.GAH = ns.GAH or {}
local M = ns.GAH

-- ---------- Context ----------
local function now() return time() end
local function playerGUID() return UnitGUID("player") end
local function playerName() return UnitName("player") end
local function realmName() return GetRealmName() end
local function guildName() local g = GetGuildInfo("player"); return g end

-- ---------- DB ----------
local function ensureDB()
  UHC_GuildAHDB = UHC_GuildAHDB or {}
  local r = realmName() or "?"
  UHC_GuildAHDB[r] = UHC_GuildAHDB[r] or {}
  local g = guildName()
  if not g then return nil end
  UHC_GuildAHDB[r][g] = UHC_GuildAHDB[r][g] or { listings = {} }
  return UHC_GuildAHDB[r][g]
end
M.EnsureDB = ensureDB

-- ---------- Helpers ----------
local function parseItemString(link)
  if not link then return nil end
  return link:match("item:[%-?%d:]+") or link
end

local function newId() return (playerGUID() or "noguid") .. ":" .. tostring(now()) end

-- ---------- API ----------
function M.NewListing(itemLink, count, priceCopper, durationHours)
  local db = ensureDB(); if not db then return false, "Not in a guild." end
  if not itemLink or itemLink == "" then return false, "No item." end
  local id = newId()
  local l = {
    id = id,
    itemLink = itemLink,
    itemString = parseItemString(itemLink),
    count = tonumber(count) or 1,
    price = tonumber(priceCopper) or 0,
    sellerGUID = playerGUID(),
    sellerName = playerName(),
    created = now(),
    expires = now() + (tonumber(durationHours) or 48) * 3600,
    state = "ACTIVE", -- ACTIVE | RESERVED | SOLD | CANCELLED | EXPIRED
    reservedByGUID = nil,
    reservedByName = nil,
  }
  db.listings[id] = l
  if ns.GAHComms then ns.GAHComms.BroadcastNew(l) end
  return true, id
end

function M.GetAllListings()
  local db = ensureDB(); return (db and db.listings) or {}
end

function M.Find(id)
  local db = ensureDB(); return (db and db.listings[id]) or nil
end

function M.Reserve(id, buyerGUID, buyerName)
  local L = M.Find(id); if not L or L.state ~= "ACTIVE" then return false, "Not active." end
  L.state = "RESERVED"; L.reservedByGUID = buyerGUID; L.reservedByName = buyerName
  if ns.GAHComms then ns.GAHComms.BroadcastReserve(L) end
  return true
end

function M.AcceptReserve(id)
  local L = M.Find(id); if not L or L.state ~= "RESERVED" then return false end
  if ns.GAHComms then ns.GAHComms.BroadcastReserveAccept(L) end
  return true
end

function M.DeclineReserve(id, reason)
  local L = M.Find(id); if not L or L.state ~= "RESERVED" then return false end
  L.state = "ACTIVE"; L.reservedByGUID = nil; L.reservedByName = nil
  if ns.GAHComms then ns.GAHComms.BroadcastReserveDecline(L, reason or "") end
  return true
end

function M.Complete(id)
  local L = M.Find(id); if not L then return false end
  L.state = "SOLD"
  if ns.GAHComms then ns.GAHComms.BroadcastComplete(L) end
  return true
end

function M.Cancel(id)
  local L = M.Find(id); if not L then return false end
  L.state = "CANCELLED"
  if ns.GAHComms then ns.GAHComms.BroadcastCancel(L) end
  return true
end

local function expireSweep()
  local db = ensureDB(); if not db then return end
  for _, L in pairs(db.listings) do
    if L.state == "ACTIVE" and L.expires <= now() then
      L.state = "EXPIRED"
      if ns.GAHComms then ns.GAHComms.BroadcastExpire(L) end
    end
  end
end
M.ExpireSweep = expireSweep

-- ---------- Events ----------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(_, ev)
  if ev == "PLAYER_LOGIN" then
    expireSweep()
    if IsInGuild() and ns.GAHComms then ns.GAHComms.Init() end
  end
end)
