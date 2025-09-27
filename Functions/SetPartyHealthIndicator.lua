-- Party Health Indicator System
-- Shows health indicator icons next to party member frames and target glow

-- Use the same health indicator steps as nameplates
PARTY_HEALTH_INDICATOR_STEPS = {
  {health = 0.2, alpha = 1.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.4, alpha = 0.8, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.5, alpha = 0.6, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.7, alpha = 0.4, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.9, alpha = 0.2, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
  {health = 1, alpha = 0.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
}

-- Cache of all party health indicators
PARTY_HEALTH_INDICATOR_FRAMES = {}

-- Cache of all party target highlight frames
PARTY_TARGET_HIGHLIGHT_FRAMES = {}

function SetPartyHealthIndicator(enabled, partyIndex)
  local partyFrame = _G['PartyMemberFrame' .. partyIndex]
  if not partyFrame then 
    -- Try alternative party frame names
    partyFrame = _G['PartyMemberFrame' .. partyIndex .. 'Portrait']
    if not partyFrame then
      partyFrame = _G['PartyMemberFrame' .. partyIndex .. 'HealthBar']
    end
    if not partyFrame then
      return 
    end
  end

  -- If health indicator is disabled, hide existing indicators
  if not enabled then
    local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[partyIndex]
    if healthIndicator then
      healthIndicator:Hide()
      PARTY_HEALTH_INDICATOR_FRAMES[partyIndex] = nil
    end
    return
  end

  -- Create or get existing health indicator
  local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[partyIndex]
  if not healthIndicator then
    healthIndicator = partyFrame:CreateTexture(nil, 'OVERLAY')
    healthIndicator:SetSize(32, 32)
    healthIndicator:SetPoint('RIGHT', partyFrame, 'LEFT', -5, 0)
    healthIndicator:SetAlpha(0.0)
    
    -- Cache for updates
    PARTY_HEALTH_INDICATOR_FRAMES[partyIndex] = healthIndicator
  end

  -- Update the health indicator immediately
  UpdatePartyHealthIndicator(partyIndex)
end

function UpdatePartyHealthIndicator(partyIndex)
  local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[partyIndex]
  if not healthIndicator then return end

  local unit = 'party' .. partyIndex
  
  -- Always hide first - only show if we have reliable data AND health is low
  healthIndicator:Hide()
  
  if not UnitExists(unit) then
    return
  end

  local health = UnitHealth(unit)
  local maxHealth = UnitHealthMax(unit)
  if not health or not maxHealth or maxHealth == 0 then
    return
  end

  local healthRatio = health / maxHealth
  
  -- Show indicator for all health levels to see all transitions
  -- Remove the 40% threshold check
  
  local alpha = 0.0
  for _, step in pairs(PARTY_HEALTH_INDICATOR_STEPS) do
    if healthRatio <= step.health then
      alpha = step.alpha
      healthIndicator:SetTexture(step.texture)
      break
    end
  end

  -- Only show if we have a valid alpha
  if alpha > 0 then
    healthIndicator:SetAlpha(alpha)
    healthIndicator:Show()
  end
end

function UpdateAllPartyHealthIndicators()
  for i = 1, 4 do -- Party members 1-4
    UpdatePartyHealthIndicator(i)
  end
end

function SetAllPartyHealthIndicators(enabled)
  -- Force show test indicators for all party members
  for i = 1, 4 do -- Party members 1-4
    local partyFrame = _G['PartyMemberFrame' .. i]
    if not partyFrame then 
      -- Try alternative party frame names
      partyFrame = _G['PartyMemberFrame' .. i .. 'Portrait']
      if not partyFrame then
        partyFrame = _G['PartyMemberFrame' .. i .. 'HealthBar']
      end
    end
    
    if partyFrame then
      -- Create or get existing health indicator
      local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[i]
      if not healthIndicator then
        healthIndicator = partyFrame:CreateTexture(nil, 'OVERLAY')
        healthIndicator:SetSize(32, 32) -- Normal size
        -- Position to the right of the party frame, very close
        healthIndicator:SetPoint('RIGHT', partyFrame, 'LEFT', -5, 0)
        healthIndicator:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png')
        healthIndicator:SetAlpha(1.0) -- Always visible for testing
        healthIndicator:Show()
        
        -- Cache for updates
        PARTY_HEALTH_INDICATOR_FRAMES[i] = healthIndicator
      else
        healthIndicator:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png')
        healthIndicator:SetAlpha(1.0)
        healthIndicator:Show()
      end
    end
  end
  
  -- Also try with a delay in case party frames aren't ready yet
  C_Timer.After(0.5, function()
    for i = 1, 4 do -- Party members 1-4
      local partyFrame = _G['PartyMemberFrame' .. i]
      if not partyFrame then 
        -- Try alternative party frame names
        partyFrame = _G['PartyMemberFrame' .. i .. 'Portrait']
        if not partyFrame then
          partyFrame = _G['PartyMemberFrame' .. i .. 'HealthBar']
        end
      end
      
      if partyFrame then
        -- Create or get existing health indicator
        local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[i]
        if not healthIndicator then
          healthIndicator = partyFrame:CreateTexture(nil, 'OVERLAY')
          healthIndicator:SetSize(32, 32) -- Normal size
          -- Position to the right of the party frame, very close
          healthIndicator:SetPoint('RIGHT', partyFrame, 'LEFT', -5, 0)
          healthIndicator:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png')
          healthIndicator:SetAlpha(1.0) -- Always visible for testing
          healthIndicator:Show()
          
          -- Cache for updates
          PARTY_HEALTH_INDICATOR_FRAMES[i] = healthIndicator
        else
          healthIndicator:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png')
          healthIndicator:SetAlpha(1.0)
          healthIndicator:Show()
        end
      end
    end
  end)
end

-- Function to create target highlight for a party member
function CreatePartyTargetHighlight(partyIndex)
  local partyFrame = _G['PartyMemberFrame' .. partyIndex]
  if not partyFrame then 
    -- Try alternative party frame names
    partyFrame = _G['PartyMemberFrame' .. partyIndex .. 'Portrait']
    if not partyFrame then
      partyFrame = _G['PartyMemberFrame' .. partyIndex .. 'HealthBar']
    end
    if not partyFrame then
      return 
    end
  end

  local highlight = PARTY_TARGET_HIGHLIGHT_FRAMES[partyIndex]
  if not highlight then
    -- Create a glow effect around the party frame
    highlight = partyFrame:CreateTexture(nil, 'OVERLAY')
    highlight:SetSize(100, 100) -- Larger than party frame for glow effect
    highlight:SetPoint('CENTER', partyFrame, 'CENTER', 0, 0)
    
    -- Use holy damage texture for a golden glow effect
    highlight:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\holy-damage.png')
    highlight:SetVertexColor(1, 0.84, 0, 0.7) -- Gold color with transparency
    highlight:SetAlpha(0.8)
    highlight:SetBlendMode('ADD') -- Additive blending for glow effect
    highlight:Hide()
    
    PARTY_TARGET_HIGHLIGHT_FRAMES[partyIndex] = highlight
  else
    -- Ensure existing highlight is properly positioned
    highlight:SetPoint('CENTER', partyFrame, 'CENTER', 0, 0)
  end
  
  return highlight
end

-- Function to update target highlights
function UpdatePartyTargetHighlights()
  local targetUnit = "target"
  if not UnitExists(targetUnit) then
    -- Hide all highlights if no target
    for i = 1, 4 do
      local highlight = PARTY_TARGET_HIGHLIGHT_FRAMES[i]
      if highlight then
        highlight:Hide()
      end
    end
    return
  end

  -- Check if target is a party member
  for i = 1, 4 do
    local partyUnit = "party" .. i
    local highlight = PARTY_TARGET_HIGHLIGHT_FRAMES[i]
    
    if UnitIsUnit(targetUnit, partyUnit) then
      -- Target is this party member - show highlight
      if not highlight then
        highlight = CreatePartyTargetHighlight(i)
      end
      if highlight then
        -- Ensure highlight is properly positioned
        local partyFrame = _G['PartyMemberFrame' .. i]
        if partyFrame then
          highlight:SetPoint('CENTER', partyFrame, 'CENTER', -40, 0)
        end
        highlight:Show()
      end
    else
      -- Target is not this party member - hide highlight
      if highlight then
        highlight:Hide()
      end
    end
  end
end

-- Function to set up all party target highlights
function SetAllPartyTargetHighlights(enabled)
  if not enabled then
    -- Hide all highlights
    for i = 1, 4 do
      local highlight = PARTY_TARGET_HIGHLIGHT_FRAMES[i]
      if highlight then
        highlight:Hide()
      end
    end
    return
  end

  -- Create highlights for all party members
  for i = 1, 4 do
    CreatePartyTargetHighlight(i)
  end
  
  -- Update highlights based on current target
  UpdatePartyTargetHighlights()
end

-- Function to reposition all target highlights when party frames are moved
function RepositionAllPartyTargetHighlights()
  for i = 1, 4 do
    local highlight = PARTY_TARGET_HIGHLIGHT_FRAMES[i]
    if highlight then
      local partyFrame = _G['PartyMemberFrame' .. i]
      if partyFrame then
        highlight:SetPoint('CENTER', partyFrame, 'CENTER', 0, 0)
      end
    end
  end
end

-- Event handler for party health updates
local partyHealthFrame = CreateFrame('Frame')
partyHealthFrame:RegisterEvent('UNIT_HEALTH_FREQUENT')
partyHealthFrame:RegisterEvent('UNIT_HEALTH')
partyHealthFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
partyHealthFrame:RegisterEvent('PARTY_MEMBER_ENABLE')
partyHealthFrame:RegisterEvent('PARTY_MEMBER_DISABLE')
partyHealthFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
partyHealthFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
partyHealthFrame:RegisterEvent('ADDON_LOADED')

partyHealthFrame:SetScript('OnEvent', function(self, event, unit)
  if event == 'UNIT_HEALTH_FREQUENT' or event == 'UNIT_HEALTH' then
    -- Check if this is a party member
    if unit and unit:match('^party%d+$') then
      local partyIndex = tonumber(unit:match('party(%d+)'))
      if partyIndex and partyIndex >= 1 and partyIndex <= 4 then
        UpdatePartyHealthIndicator(partyIndex)
      end
    end
  elseif event == 'GROUP_ROSTER_UPDATE' or event == 'PARTY_MEMBER_ENABLE' or event == 'PARTY_MEMBER_DISABLE' then
    -- Update all party indicators when party composition changes
    -- Add a small delay to ensure health data is loaded
    C_Timer.After(0.1, function()
      UpdateAllPartyHealthIndicators()
    end)
  elseif event == 'PLAYER_TARGET_CHANGED' then
    -- Update target highlights when target changes
    UpdatePartyTargetHighlights()
  elseif event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    -- Update all party indicators on login/reload with delay
    C_Timer.After(1.0, function()
      UpdateAllPartyHealthIndicators()
    end)
  end
end)