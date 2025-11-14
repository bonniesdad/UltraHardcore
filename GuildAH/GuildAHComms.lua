local ADDON_NAME, ns = ...
ns.GAHComms = ns.GAHComms or {}
local C = ns.GAHComms
local M = ns.GAH
local PREFIX = "UHC_GAH1"

local function pack(t) for i=1,#t do t[i] = tostring(t[i] or "") end; return table.concat(t, ";") end
local function send(msg) C_ChatInfo.SendAddonMessage(PREFIX, msg, "GUILD") end

function C.Init()
  C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
end

-- ---------- Broadcasts ----------
function C.BroadcastNew(L)
  send(pack({"NEW", L.id, L.itemString, L.count, L.price, L.created, L.expires, L.sellerGUID, L.sellerName, L.itemLink}))
end
function C.BroadcastReserve(L)       send(pack({"RESERVE",     L.id, L.reservedByGUID or "", L.reservedByName or ""})) end
function C.BroadcastReserveAccept(L) send(pack({"RES_ACCEPT",  L.id})) end
function C.BroadcastReserveDecline(L, reason) send(pack({"RES_DECLINE", L.id, reason or ""})) end
function C.BroadcastComplete(L)      send(pack({"COMPLETE",    L.id})) end
function C.BroadcastCancel(L)        send(pack({"CANCEL",      L.id})) end
function C.BroadcastExpire(L)        send(pack({"EXPIRE",      L.id})) end

-- ---------- Receive ----------
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(_, _, prefix, message, channel)
  if prefix ~= PREFIX or channel ~= "GUILD" then return end
  local op,a,b,c,d,e,f1,g,h,i = strsplit(";", message)

  local listings = M.GetAllListings()

  if op == "NEW" then
    local id = a
    if not listings[id] then
      listings[id] = {
        id = id,
        itemString = b,
        count = tonumber(c) or 1,
        price = tonumber(d) or 0,
        created = tonumber(e) or time(),
        expires = tonumber(f1) or time()+172800,
        sellerGUID = g,
        sellerName = h,
        itemLink = i,
        state = "ACTIVE",
      }
    end

  elseif op == "RESERVE" then
    local id = a; local L = listings[id]; if L and L.state == "ACTIVE" then
      L.state = "RESERVED"; L.reservedByGUID = b; L.reservedByName = c
    end

  elseif op == "RES_ACCEPT" then
    -- informational: seller accepted; UI may highlight

  elseif op == "RES_DECLINE" then
    local id = a; local L = listings[id]; if L then
      L.state = "ACTIVE"; L.reservedByGUID=nil; L.reservedByName=nil
    end

  elseif op == "COMPLETE" then
    local L = listings[a]; if L then L.state = "SOLD" end

  elseif op == "CANCEL" then
    local L = listings[a]; if L then L.state = "CANCELLED" end

  elseif op == "EXPIRE" then
    local L = listings[a]; if L then L.state = "EXPIRED" end
  end

  if ns.GAHTab and ns.GAHTab.Refresh then ns.GAHTab.Refresh() end
end)
