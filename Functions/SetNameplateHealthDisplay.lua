-- Nameplate Health Hiding System
-- When enabled, hides nameplate health bars and level information
-- Health bars are stuck at 100% and levels are hidden for both allies and enemies

local GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit

-- Cache of nameplates we've modified
local modifiedNameplates = {}

function SetNameplateHealthDisplay(disabled)
    if not disabled then
        -- If disabled is false, restore all nameplates to normal
        for nameplate, _ in pairs(modifiedNameplates) do
            RestoreNameplate(nameplate)
        end
        modifiedNameplates = {}
        return
    end

    -- Only process nameplates if disabled is true
    -- Process all existing nameplates
    for i = 1, 40 do -- Maximum number of nameplates
        local nameplate = _G["NamePlate" .. i]
        if nameplate and nameplate:IsVisible() then
            ProcessNameplate(nameplate)
        end
    end
end

function ProcessNameplate(nameplate)
    if not nameplate or not nameplate.UnitFrame then
        return
    end

    local unitFrame = nameplate.UnitFrame
    local unit = nameplate.namePlateUnitToken
    
    if not unit or not UnitExists(unit) then
        return
    end

    -- Process both enemy and allied units
    -- Check if this nameplate is already processed
    if modifiedNameplates[nameplate] then
        return
    end

    -- Store original states
    modifiedNameplates[nameplate] = {
        healthBar = unitFrame.healthBar,
        levelFrame = unitFrame.LevelFrame,
        originalHealthBarShow = unitFrame.healthBar.Show,
        originalLevelFrameShow = unitFrame.LevelFrame.Show,
        originalHealthBarSetValue = unitFrame.healthBar.SetValue,
        originalHealthBarSetMinMaxValues = unitFrame.healthBar.SetMinMaxValues
    }

    -- Hide level frame completely
    unitFrame.LevelFrame:Hide()
    unitFrame.LevelFrame.Show = function() end
    
    -- Store original functions for restoration
    local originalSetValue = unitFrame.healthBar.SetValue
    local originalSetMinMaxValues = unitFrame.healthBar.SetMinMaxValues
    
    -- Override health bar functions to keep it at 100%
    unitFrame.healthBar.SetValue = function(self, value)
        -- Always set to 100% (1.0)
        originalSetValue(self, 1.0)
    end
    
    unitFrame.healthBar.SetMinMaxValues = function(self, min, max)
        -- Always set to 0-1 range (100%)
        originalSetMinMaxValues(self, 0, 1)
    end
    
    -- Force health bar to show at 100%
    unitFrame.healthBar:SetMinMaxValues(0, 1)
    unitFrame.healthBar:SetValue(1.0)
end

function RestoreNameplate(nameplate)
    if not modifiedNameplates[nameplate] then
        return
    end

    local data = modifiedNameplates[nameplate]
    
    -- Restore original functions
    data.healthBar.SetValue = data.originalHealthBarSetValue
    data.healthBar.SetMinMaxValues = data.originalHealthBarSetMinMaxValues
    data.levelFrame.Show = data.originalLevelFrameShow
    
    -- Show the level frame
    data.levelFrame:Show()
    
    -- Remove from cache
    modifiedNameplates[nameplate] = nil
end

-- Event handler for nameplate updates
local nameplateFrame = CreateFrame('Frame')
nameplateFrame:RegisterEvent('NAME_PLATE_UNIT_ADDED')
nameplateFrame:RegisterEvent('NAME_PLATE_UNIT_REMOVED')

nameplateFrame:SetScript('OnEvent', function(self, event, unit)
    -- Only process events if the setting is enabled
    if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.disableNameplateHealth then
        return
    end
    
    if event == 'NAME_PLATE_UNIT_ADDED' then
        local nameplate = GetNamePlateForUnit(unit)
        if nameplate then
            ProcessNameplate(nameplate)
        end
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        local nameplate = GetNamePlateForUnit(unit)
        if nameplate and modifiedNameplates[nameplate] then
            RestoreNameplate(nameplate)
        end
    end
end)
