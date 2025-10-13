local resourceBar = CreateFrame('StatusBar', nil, UIParent)
if not resourceBar then
    print("UltraHardcore: Failed to create resource bar")
    return
end

resourceBar:SetSize(225, PlayerFrameManaBar:GetHeight())
resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
resourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

-- Cache power type colors and max values
local POWER_COLORS = {
    ENERGY = {1, 1, 0},
    RAGE = {1, 0, 0},
    MANA = {0, 0, 1}
}

-- Position persistence functions
local function LoadResourceBarPosition()
    if not UltraHardcoreDB then
        UltraHardcoreDB = {}
    end
    
    local pos = UltraHardcoreDB.resourceBarPosition
    -- Clear existing points first to avoid anchor conflicts
    resourceBar:ClearAllPoints()
    -- Always anchor to UIParent to avoid frame reference issues
    resourceBar:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
end

local function SaveResourceBarPosition()
    if not UltraHardcoreDB then
        UltraHardcoreDB = {}
    end
    
    local point, relativeTo, relativePoint, xOfs, yOfs = resourceBar:GetPoint()
    -- Always save UIParent as the relativeTo frame to avoid reference issues
    UltraHardcoreDB.resourceBarPosition = {
        point = point,
        relativeTo = "UIParent",
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
    
    SaveDBData('resourceBarPosition', UltraHardcoreDB.resourceBarPosition)
end

-- Make the resource bar draggable with position saving
resourceBar:SetMovable(true)
resourceBar:EnableMouse(true)
resourceBar:RegisterForDrag('LeftButton')
resourceBar:SetScript('OnDragStart', function(self)
    self:StartMoving()
end)
resourceBar:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    SaveResourceBarPosition()
end)

-- Create a frame for the combo points
local comboFrame = CreateFrame('Frame', nil, UIParent)
if not comboFrame then
    print("UltraHardcore: Failed to create combo frame")
    return
end

comboFrame:SetSize(200, 32)
comboFrame:SetPoint('BOTTOM', resourceBar, 'TOP', 0, 10)

-- Create combo point outlines and fill layers
local resourceOrbs = {}
local COMBO_TEXTURE = 'Interface\\AddOns\\UltraHardcore\\textures\\combopoint'
local COMBO_SHADOW_TEXTURE = COMBO_TEXTURE .. '_outline.blp'

for i = 1, 5 do
    local orb = CreateComboPointOrb(comboFrame, i, 5, COMBO_TEXTURE .. '.blp', COMBO_SHADOW_TEXTURE)
    if not orb then
        print("UltraHardcore: Failed to create combo point orb " .. i)
        return
    end
    resourceOrbs[i] = orb
end

-- Function to update combo points
local function UpdateComboPoints()
    if not UnitExists('target') then
        for _, orb in ipairs(resourceOrbs) do
            orb.fill:Hide()
            orb.isFilled = false
        end
        return
    end

    local points = GetComboPoints('player', 'target')
    if not points then
        print("UltraHardcore: Failed to get combo points")
        return
    end

    for i = 1, 5 do
        local orb = resourceOrbs[i]
        if not orb then
            print("UltraHardcore: Missing combo point orb " .. i)
            return
        end

        if i <= points then
            if not orb.isFilled then
                SmoothTextureFadeIn(orb.fill)
                orb.fill:Show()
            end
        else
            orb.fill:Hide()
            orb.isFilled = false
        end
    end
end

-- Add a border around the resource bar
local border = resourceBar:CreateTexture(nil, 'OVERLAY')
if not border then
    print("UltraHardcore: Failed to create resource bar border")
    return
end

border:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border')
border:SetPoint('CENTER', resourceBar, 'CENTER', 0, 0)
border:SetSize(300, 64)

-- Unified function to update resource points
local function UpdateResourcePoints()
    local powerType = GetCurrentResourceType()
    local value = UnitPower('player', Enum.PowerType[powerType])
    local maxValue = UnitPowerMax('player', Enum.PowerType[powerType])
    
    resourceBar:SetMinMaxValues(0, maxValue)
    resourceBar:SetValue(value)
    resourceBar:SetStatusBarColor(unpack(POWER_COLORS[powerType]))
end

-- Function to hide combo points for non-users
local function HideComboPointsForNonUsers()
    comboFrame:SetShown(CanGainComboPoints())
end

-- Event Handling
resourceBar:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceBar:RegisterEvent('UNIT_POWER_FREQUENT')
resourceBar:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
comboFrame:RegisterEvent('PLAYER_TARGET_CHANGED')

resourceBar:SetScript('OnEvent', function(self, event, unit)
    if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.hidePlayerFrame then
        resourceBar:Hide()
        comboFrame:Hide()
        return
    end

    if unit == 'player' or event == 'PLAYER_TARGET_CHANGED' then
        UpdateComboPoints()
    end

    if event == 'PLAYER_ENTERING_WORLD' then
        HideComboPointsForNonUsers()
        UpdateResourcePoints()
        -- Load saved position after database is available
        C_Timer.After(0.1, function()
            LoadResourceBarPosition()
        end)
    elseif event == 'UNIT_POWER_FREQUENT' and unit == 'player' then
        UpdateResourcePoints()
    elseif event == 'UPDATE_SHAPESHIFT_FORM' then
        -- Update resource bar and combo points when shapeshifting
        UpdateResourcePoints()
        HideComboPointsForNonUsers()
        UpdateComboPoints()
    end
end)

-- Hide the default combo points (Blizzard UI)
if ComboFrame then
    ComboFrame:Hide()
    ComboFrame:UnregisterAllEvents()
    ComboFrame:SetScript('OnUpdate', nil)
end
