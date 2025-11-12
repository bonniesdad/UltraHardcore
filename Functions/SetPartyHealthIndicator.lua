-- Party Health Indicator System
-- Shows health indicator icons next to party member frames and target glow

-- Use the same health indicator steps as nameplates
PARTY_HEALTH_INDICATOR_STEPS = {
  {health = 0, alpha = 1.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-black.png'},
  {health = 0.2, alpha = 1.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.3, alpha = 0.8, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.4, alpha = 0.6, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.6, alpha = 0.4, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.8, alpha = 0.2, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
  {health = 1, alpha = 0.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
}

-- Cache of all party health indicators
PARTY_HEALTH_INDICATOR_FRAMES = {}

-- Cache of all party target highlight frames
PARTY_TARGET_HIGHLIGHT_FRAMES = {}

-- Cache of all pet health indicators (player pet + party pets)
PET_HEALTH_INDICATOR_FRAMES = {}

-- Cache of all pet target highlight frames
PET_TARGET_HIGHLIGHT_FRAMES = {}

-- Cache of all raid health indicators
RAID_HEALTH_INDICATOR_FRAMES = {}

-- Helper to get a CompactRaidFrame's unit, being tolerant of different fields
local function GetRaidFrameUnit(frame, fallbackIndex)
  if not frame then return fallbackIndex and ('raid' .. fallbackIndex) or nil end
  if frame.displayedUnit and type(frame.displayedUnit) == 'string' then
    return frame.displayedUnit
  end
  if frame.unit and type(frame.unit) == 'string' then
    return frame.unit
  end
  if fallbackIndex then
    return 'raid' .. fallbackIndex
  end
  return nil
end

-- Create or update an indicator for a specific CompactRaidFrame index
function SetRaidHealthIndicator(enabled, raidIndex)
  local raidFrame = _G['CompactRaidFrame' .. raidIndex]
  local nameFrame = _G['CompactRaidFrame' .. raidIndex .. 'Name']
  if not raidFrame or not nameFrame then
    return
  end

  if not enabled then
    local indicator = RAID_HEALTH_INDICATOR_FRAMES[raidIndex]
    if indicator then
      indicator:Hide()
      RAID_HEALTH_INDICATOR_FRAMES[raidIndex] = nil
    end
    return
  end

  local indicator = RAID_HEALTH_INDICATOR_FRAMES[raidIndex]
  if not indicator then
    indicator = raidFrame:CreateTexture(nil, 'OVERLAY')
    indicator:SetSize(30, 30)
    if raidFrame.uhcCircle then
      indicator:SetPoint('CENTER', raidFrame.uhcCircle, 'CENTER', 0, 0)
    else
      indicator:SetPoint('CENTER', raidFrame, 'TOP', 0, -20)
    end
    if indicator.SetDrawLayer then
      indicator:SetDrawLayer('ARTWORK')
    end
    indicator:SetAlpha(0.0)
    indicator:Hide()
    RAID_HEALTH_INDICATOR_FRAMES[raidIndex] = indicator
  end

  UpdateRaidHealthIndicator(raidIndex)
end

function UpdateRaidHealthIndicator(raidIndex)
  local indicator = RAID_HEALTH_INDICATOR_FRAMES[raidIndex]
  if not indicator then return end

  local raidFrame = _G['CompactRaidFrame' .. raidIndex]
  if not raidFrame then
    indicator:Hide()
    return
  end

  local unit = GetRaidFrameUnit(raidFrame, raidIndex)
  if not unit or not UnitExists(unit) then
    indicator:Hide()
    return
  end

  local health = UnitHealth(unit)
  local maxHealth = UnitHealthMax(unit)
  if not health or not maxHealth or maxHealth == 0 then
    indicator:Hide()
    return
  end

  local healthRatio = health / maxHealth
  if health == 0 or UnitIsDead(unit) then
    healthRatio = 0
  end

  local alpha = 0.0
  local texture = nil
  for _, step in pairs(PARTY_HEALTH_INDICATOR_STEPS) do
    if healthRatio <= step.health then
      alpha = step.alpha
      texture = step.texture
      break
    end
  end

  if alpha > 0 then
    indicator:SetTexture(texture)
    indicator:SetAlpha(alpha)
    indicator:Show()
  else
    indicator:Hide()
  end
end

function UpdateRaidHealthIndicatorForUnit(unit)
  -- Find all compact raid frames that correspond to this unit and update
  for i = 1, 40 do
    local raidFrame = _G['CompactRaidFrame' .. i]
    if raidFrame then
      local frameUnit = GetRaidFrameUnit(raidFrame, nil)
      if frameUnit == unit then
        UpdateRaidHealthIndicator(i)
      end
    end
  end
end

function SetAllRaidHealthIndicators(enabled)
  if not enabled then
    for i = 1, 40 do
      local indicator = RAID_HEALTH_INDICATOR_FRAMES[i]
      if indicator then
        indicator:Hide()
        RAID_HEALTH_INDICATOR_FRAMES[i] = nil
      end
    end
    return
  end

  for i = 1, 40 do
    local raidFrame = _G['CompactRaidFrame' .. i]
    local nameFrame = _G['CompactRaidFrame' .. i .. 'Name']
    if raidFrame and nameFrame then
      local indicator = RAID_HEALTH_INDICATOR_FRAMES[i]
      if not indicator then
        indicator = raidFrame:CreateTexture(nil, 'OVERLAY')
        indicator:SetSize(30, 30)
        if raidFrame.uhcCircle then
          indicator:SetPoint('CENTER', raidFrame.uhcCircle, 'CENTER', 0, 0)
        else
          indicator:SetPoint('CENTER', raidFrame, 'TOP', 0, -20)
        end
        if indicator.SetDrawLayer then
          indicator:SetDrawLayer('ARTWORK')
        end
        indicator:SetAlpha(0.0)
        indicator:Hide()
        RAID_HEALTH_INDICATOR_FRAMES[i] = indicator
      end
      UpdateRaidHealthIndicator(i)
    end
  end

  -- Try again shortly in case frames are created asynchronously
  C_Timer.After(0.5, function()
    for i = 1, 40 do
      UpdateRaidHealthIndicator(i)
    end
  end)
end

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
  
  -- Handle dead party members (0 health)
  if health == 0 or UnitIsDead(unit) then
    healthRatio = 0
  end
  
  -- Find the appropriate health step
  local alpha = 0.0
  local texture = nil
  
  for _, step in pairs(PARTY_HEALTH_INDICATOR_STEPS) do
    if healthRatio <= step.health then
      alpha = step.alpha
      texture = step.texture
      break
    end
  end

  -- Only show if we have a valid alpha > 0
  if alpha > 0 then
    healthIndicator:SetTexture(texture)
    healthIndicator:SetAlpha(alpha)
    healthIndicator:Show()
  else
    -- Ensure it's hidden when alpha is 0
    healthIndicator:Hide()
  end
end

function UpdateAllPartyHealthIndicators()
  for i = 1, 4 do -- Party members 1-4
    UpdatePartyHealthIndicator(i)
  end
end

-- Pet Health Indicator Functions
function SetPetHealthIndicator(enabled, petType, petIndex)
  local petFrame = nil
  local petUnit = nil
  
  if petType == "player" then
    petFrame = PetFrame
    petUnit = "pet"
  elseif petType == "party" then
    petFrame = _G['PartyMemberFrame' .. petIndex .. 'PetFrame']
    petUnit = "partypet" .. petIndex
  end
  
  if not petFrame then
    return
  end

  -- If health indicator is disabled, hide existing indicators
  if not enabled then
    local healthIndicator = PET_HEALTH_INDICATOR_FRAMES[petType .. petIndex]
    if healthIndicator then
      healthIndicator:Hide()
      PET_HEALTH_INDICATOR_FRAMES[petType .. petIndex] = nil
    end
    return
  end

  -- Create or get existing health indicator
  local healthIndicator = PET_HEALTH_INDICATOR_FRAMES[petType .. petIndex]
  if not healthIndicator then
    healthIndicator = petFrame:CreateTexture(nil, 'OVERLAY')
    healthIndicator:SetSize(24, 24) -- Smaller than party indicators
    healthIndicator:SetPoint('LEFT', petFrame, 'RIGHT', -80, 0)
    healthIndicator:SetAlpha(0.0)
    
    -- Cache for updates
    PET_HEALTH_INDICATOR_FRAMES[petType .. petIndex] = healthIndicator
  end

  -- Update the health indicator immediately
  UpdatePetHealthIndicator(petType, petIndex)
end

function UpdatePetHealthIndicator(petType, petIndex)
  local healthIndicator = PET_HEALTH_INDICATOR_FRAMES[petType .. petIndex]
  if not healthIndicator then return end

  local petUnit = nil
  if petType == "player" then
    petUnit = "pet"
  elseif petType == "party" then
    petUnit = "partypet" .. petIndex
  end
  
  -- Always hide first - only show if we have reliable data AND health is low
  healthIndicator:Hide()
  
  if not UnitExists(petUnit) then
    return
  end

  local health = UnitHealth(petUnit)
  local maxHealth = UnitHealthMax(petUnit)
  if not health or not maxHealth or maxHealth == 0 then
    return
  end

  local healthRatio = health / maxHealth
  
  -- Handle dead pets (0 health)
  if health == 0 or UnitIsDead(petUnit) then
    healthRatio = 0
  end
  
  -- Find the appropriate health step
  local alpha = 0.0
  local texture = nil
  
  for _, step in pairs(PARTY_HEALTH_INDICATOR_STEPS) do
    if healthRatio <= step.health then
      alpha = step.alpha
      texture = step.texture
      break
    end
  end

  -- Only show if we have a valid alpha > 0
  if alpha > 0 then
    healthIndicator:SetTexture(texture)
    healthIndicator:SetAlpha(alpha)
    healthIndicator:Show()
  else
    -- Ensure it's hidden when alpha is 0
    healthIndicator:Hide()
  end
end

function UpdateAllPetHealthIndicators()
  -- Update player pet
  UpdatePetHealthIndicator("player", "")
  
  -- Update party pets
  for i = 1, 4 do
    UpdatePetHealthIndicator("party", i)
  end
end

function SetAllPetHealthIndicators(enabled)
  if not enabled then
    -- Hide all pet health indicators
    for key, healthIndicator in pairs(PET_HEALTH_INDICATOR_FRAMES) do
      if healthIndicator then
        healthIndicator:Hide()
      end
    end
    return
  end

  -- Create health indicators for player pet
  local playerPetFrame = PetFrame
  if playerPetFrame then
    local healthIndicator = PET_HEALTH_INDICATOR_FRAMES["player"]
    if not healthIndicator then
      healthIndicator = playerPetFrame:CreateTexture(nil, 'OVERLAY')
      healthIndicator:SetSize(24, 24)
      healthIndicator:SetPoint('LEFT', playerPetFrame, 'RIGHT', -80, 0)
      healthIndicator:SetAlpha(0.0)
      healthIndicator:Hide()
      
      PET_HEALTH_INDICATOR_FRAMES["player"] = healthIndicator
    end
    
    UpdatePetHealthIndicator("player", "")
  end

  -- Create health indicators for party pets
  for i = 1, 4 do
    local partyPetFrame = _G['PartyMemberFrame' .. i .. 'PetFrame']
    if partyPetFrame then
      local healthIndicator = PET_HEALTH_INDICATOR_FRAMES["party" .. i]
      if not healthIndicator then
        healthIndicator = partyPetFrame:CreateTexture(nil, 'OVERLAY')
        healthIndicator:SetSize(24, 24)
        healthIndicator:SetPoint('LEFT', partyPetFrame, 'RIGHT', -90, 0)
        healthIndicator:SetAlpha(0.0)
        healthIndicator:Hide()
        
        PET_HEALTH_INDICATOR_FRAMES["party" .. i] = healthIndicator
      end
      
      UpdatePetHealthIndicator("party", i)
    end
  end
  
  -- Also try with a delay in case pet frames aren't ready yet
  C_Timer.After(0.5, function()
    -- Update player pet
    UpdatePetHealthIndicator("player", "")
    
    -- Update party pets
    for i = 1, 4 do
      UpdatePetHealthIndicator("party", i)
    end
  end)
end

function SetAllPartyHealthIndicators(enabled)
  if not enabled then
    -- Hide all health indicators
    for i = 1, 4 do
      local healthIndicator = PARTY_HEALTH_INDICATOR_FRAMES[i]
      if healthIndicator then
        healthIndicator:Hide()
      end
    end
    return
  end

  -- Create health indicators for all party members and update them based on actual health
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
        healthIndicator:SetSize(32, 32)
        healthIndicator:SetPoint('RIGHT', partyFrame, 'LEFT', -5, 0)
        healthIndicator:SetAlpha(0.0)
        healthIndicator:Hide()
        
        -- Cache for updates
        PARTY_HEALTH_INDICATOR_FRAMES[i] = healthIndicator
      end
      
      -- Update the indicator based on actual health
      UpdatePartyHealthIndicator(i)
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
          healthIndicator:SetSize(32, 32)
          healthIndicator:SetPoint('RIGHT', partyFrame, 'LEFT', -5, 0)
          healthIndicator:SetAlpha(0.0)
          healthIndicator:Hide()
          
          -- Cache for updates
          PARTY_HEALTH_INDICATOR_FRAMES[i] = healthIndicator
        end
        
        -- Update the indicator based on actual health
        UpdatePartyHealthIndicator(i)
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

-- Function to create target highlight for a pet
function CreatePetTargetHighlight(petType)
  local petFrame = nil
  
  if petType == "player" then
    petFrame = PetFrame
  elseif petType:match("^party%d+$") then
    local petIndex = petType:match("party(%d+)")
    petFrame = _G['PartyMemberFrame' .. petIndex .. 'PetFrame']
  end
  
  if not petFrame then
    return nil
  end

  local highlight = PET_TARGET_HIGHLIGHT_FRAMES[petType]
  if not highlight then
    -- Create a glow effect around the pet frame
    highlight = petFrame:CreateTexture(nil, 'OVERLAY')
    highlight:SetSize(80, 80) -- Smaller than party frame for pet frames
    
    -- Position differently for player pet vs party pets
    if petType == "player" then
      highlight:SetPoint('CENTER', petFrame, 'CENTER', -40, 0)
    else
      -- Party pets get positioned 30 pixels to the right
      highlight:SetPoint('CENTER', petFrame, 'CENTER', 30, 0)
    end
    
    -- Use holy damage texture for a golden glow effect
    highlight:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\holy-damage.png')
    highlight:SetVertexColor(1, 0.84, 0, 0.7) -- Gold color with transparency
    highlight:SetAlpha(0.8)
    highlight:SetBlendMode('ADD') -- Additive blending for glow effect
    highlight:Hide()
    
    PET_TARGET_HIGHLIGHT_FRAMES[petType] = highlight
  else
    -- Ensure existing highlight is properly positioned
    if petType == "player" then
      highlight:SetPoint('CENTER', petFrame, 'CENTER', -40, 0)
    else
      -- Party pets get positioned 30 pixels to the right
      highlight:SetPoint('CENTER', petFrame, 'CENTER', -20, 0)
    end
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
    -- Also hide pet highlights
    UpdatePetTargetHighlights()
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
  
  -- Also check for pet targets
  UpdatePetTargetHighlights()
end

-- Function to update pet target highlights
function UpdatePetTargetHighlights()
  local targetUnit = "target"
  if not UnitExists(targetUnit) then
    -- Hide all pet highlights if no target
    -- Hide player pet highlight
    local playerPetHighlight = PET_TARGET_HIGHLIGHT_FRAMES["player"]
    if playerPetHighlight then
      playerPetHighlight:Hide()
    end
    
    -- Hide party pet highlights
    for i = 1, 4 do
      local partyPetHighlight = PET_TARGET_HIGHLIGHT_FRAMES["party" .. i]
      if partyPetHighlight then
        partyPetHighlight:Hide()
      end
    end
    return
  end

  -- Check if target is player pet
  if UnitIsUnit(targetUnit, "pet") then
    local highlight = PET_TARGET_HIGHLIGHT_FRAMES["player"]
    if not highlight then
      highlight = CreatePetTargetHighlight("player")
    end
    if highlight then
      highlight:Show()
    end
  else
    -- Hide player pet highlight if not targeting it
    local playerPetHighlight = PET_TARGET_HIGHLIGHT_FRAMES["player"]
    if playerPetHighlight then
      playerPetHighlight:Hide()
    end
  end

  -- Check if target is a party pet
  for i = 1, 4 do
    local partyPetUnit = "partypet" .. i
    local highlight = PET_TARGET_HIGHLIGHT_FRAMES["party" .. i]
    
    if UnitIsUnit(targetUnit, partyPetUnit) then
      -- Target is this party pet - show highlight
      if not highlight then
        highlight = CreatePetTargetHighlight("party" .. i)
      end
      if highlight then
        highlight:Show()
      end
    else
      -- Target is not this party pet - hide highlight
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
    -- Also hide pet highlights
    SetAllPetTargetHighlights(false)
    return
  end

  -- Create highlights for all party members
  for i = 1, 4 do
    CreatePartyTargetHighlight(i)
  end
  
  -- Also create pet highlights
  SetAllPetTargetHighlights(true)
  
  -- Update highlights based on current target
  UpdatePartyTargetHighlights()
end

-- Function to set up all pet target highlights
function SetAllPetTargetHighlights(enabled)
  if not enabled then
    -- Hide all pet highlights
    for key, highlight in pairs(PET_TARGET_HIGHLIGHT_FRAMES) do
      if highlight then
        highlight:Hide()
      end
    end
    return
  end

  -- Create highlight for player pet
  CreatePetTargetHighlight("player")
  
  -- Create highlights for party pets
  for i = 1, 4 do
    CreatePetTargetHighlight("party" .. i)
  end
  
  -- Update pet highlights based on current target
  UpdatePetTargetHighlights()
end

-- Convenience helper to apply all group-related indicators together
function SetAllGroupIndicators()
  SetAllPartyHealthIndicators(true)
  SetAllPetHealthIndicators(true)
  SetAllPartyTargetHighlights(true)
  SetAllPetTargetHighlights(true)
  -- Only enable raid health indicators when group health is hidden
  if GLOBAL_SETTINGS and (GLOBAL_SETTINGS.hideGroupHealth or false) then
    SetAllRaidHealthIndicators(true)
  else
    SetAllRaidHealthIndicators(false)
  end
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
partyHealthFrame:RegisterEvent('GROUP_JOINED')
partyHealthFrame:RegisterEvent('PARTY_MEMBER_ENABLE')
partyHealthFrame:RegisterEvent('PARTY_MEMBER_DISABLE')
partyHealthFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
partyHealthFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
partyHealthFrame:RegisterEvent('ADDON_LOADED')

partyHealthFrame:SetScript('OnEvent', function(self, event, unit)
  if event == 'UNIT_HEALTH_FREQUENT' or event == 'UNIT_HEALTH' then
    -- Raid member health updates
    local raidFrameInParty = GetCVar('useCompactPartyFrames')
    if unit and (unit:match('^raid%d+$') or raidFrameInParty) then
      if GLOBAL_SETTINGS and (GLOBAL_SETTINGS.hideGroupHealth or false) then
        UpdateRaidHealthIndicatorForUnit(unit)
      end
    end
    -- Check if this is a party member
    if unit and unit:match('^party%d+$') then
      local partyIndex = tonumber(unit:match('party(%d+)'))
      if partyIndex and partyIndex >= 1 and partyIndex <= 4 then
        UpdatePartyHealthIndicator(partyIndex)
      end
    -- Check if this is a pet
    elseif unit == 'pet' then
      UpdatePetHealthIndicator("player", "")
    elseif unit and unit:match('^partypet%d+$') then
      local petIndex = tonumber(unit:match('partypet(%d+)'))
      if petIndex and petIndex >= 1 and petIndex <= 4 then
        UpdatePetHealthIndicator("party", petIndex)
      end
    end
  elseif event == 'GROUP_ROSTER_UPDATE' or event == 'GROUP_JOINED' or event == 'PARTY_MEMBER_ENABLE' or event == 'PARTY_MEMBER_DISABLE' then
    -- Update all party indicators when party composition changes
    -- Add a small delay to ensure health data is loaded
    C_Timer.After(0.1, function()
      UpdateAllPartyHealthIndicators()
      UpdateAllPetHealthIndicators()
      UpdatePartyTargetHighlights()
      if GLOBAL_SETTINGS and (GLOBAL_SETTINGS.hideGroupHealth or false) then
        SetAllRaidHealthIndicators(true)
      end
    end)
  elseif event == 'PLAYER_TARGET_CHANGED' then
    -- Update target highlights when target changes
    UpdatePartyTargetHighlights()
  elseif event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    -- Update all party indicators on login/reload with delay
    C_Timer.After(1.0, function()
      UpdateAllPartyHealthIndicators()
      UpdateAllPetHealthIndicators()
      if GLOBAL_SETTINGS and (GLOBAL_SETTINGS.hideGroupHealth or false) then
        SetAllRaidHealthIndicators(true)
      end
    end)
  end
end)