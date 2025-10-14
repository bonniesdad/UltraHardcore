-- Create a frame for event handling and cache management
local frame = CreateFrame("Frame", nil, UIParent)

-- Enemy cache to store GUIDs and their classifications
local enemyCache = {}
local CACHE_TIMEOUT = 60 -- Remove enemies from cache after 60 seconds
local MAX_CACHE_SIZE = 50 -- Maximum number of entries in the cache

-- Function to update the enemy cache
local function UpdateEnemyCache(unit)
    if not unit or not UnitExists(unit) or not UnitIsEnemy("player", unit) then return end
    if UnitIsTapDenied(unit) then return end -- Only cache if tapped by player or group
    local guid = UnitGUID(unit)
    if not guid then return end

    local classification = UnitClassification(unit)
    enemyCache[guid] = {
        classification = classification,
        timestamp = GetTime()
    }

    -- Enforce max cache size by removing oldest entry if needed
    local cacheSize = 0
    for _ in pairs(enemyCache) do cacheSize = cacheSize + 1 end
    if cacheSize > MAX_CACHE_SIZE then
        local oldestGUID, oldestTime = nil, math.huge
        for guid, data in pairs(enemyCache) do
            if data.timestamp < oldestTime then
                oldestGUID, oldestTime = guid, data.timestamp
            end
        end
        if oldestGUID then
            enemyCache[oldestGUID] = nil
        end
    end
end

-- Scan enemies based on player and group targets
local function ScanGroupEnemies()
    -- Check player's target
    if UnitExists("target") and UnitIsEnemy("player", "target") then
        UpdateEnemyCache("target")
    end

    -- Check party/raid member targets
    if IsInGroup() then
        local unitPrefix = IsInRaid() and "raid" or "party"
        local maxMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
        for i = 1, maxMembers do
            local unit = unitPrefix .. i .. "target"
            if UnitExists(unit) and UnitIsEnemy("player", unit) then
                UpdateEnemyCache(unit)
            end
        end
    end
end

-- Scan enemies based on threat (for player and group)
local function ScanThreatEnemies()
    if UnitExists("target") and UnitIsEnemy("player", "target") then
        if UnitThreatSituation("player", "target") then
            UpdateEnemyCache("target")
        end
    end

    if IsInGroup() then
        local unitPrefix = IsInRaid() and "raid" or "party"
        local maxMembers = IsInRaid() and GetNumGroupMembers() or GetNumSubgroupMembers()
        for i = 1, maxMembers do
            local unit = unitPrefix .. i
            local target = unit .. "target"
            if UnitExists(target) and UnitIsEnemy("player", target) and UnitThreatSituation(unit, target) then
                UpdateEnemyCache(target)
            end
        end
    end
end

-- Clean up old cache entries
local function CleanEnemyCache()
    local currentTime = GetTime()
    for guid, data in pairs(enemyCache) do
        if currentTime - data.timestamp > CACHE_TIMEOUT then
            enemyCache[guid] = nil
        end
    end
end

-- Periodic cache cleanup and scanning
local cacheCleanupTimer = 0
local scanTimer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    cacheCleanupTimer = cacheCleanupTimer + elapsed
    scanTimer = scanTimer + elapsed

    if cacheCleanupTimer >= 10 then -- Clean cache every 10 seconds
        CleanEnemyCache()
        cacheCleanupTimer = 0
    end

    if scanTimer >= 1 then -- Scan enemies every 1 second
        ScanGroupEnemies()
        ScanThreatEnemies()
        scanTimer = 0
    end
end)

-- Register events
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")

-- Event handler
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_THREAT_LIST_UPDATE" or event == "UPDATE_MOUSEOVER_UNIT" or event == "GROUP_ROSTER_UPDATE" then
        ScanGroupEnemies()
        ScanThreatEnemies()
    end
end)

-- Main function to check if an enemy is elite and tagged
function IsEnemyElite(unitGUID)
    if enemyCache[unitGUID] then
        if enemyCache[unitGUID].classification == "elite" or
           enemyCache[unitGUID].classification == "rareelite" or
           enemyCache[unitGUID].classification == "worldboss" then
            return true
        end
    end
    return false
end
