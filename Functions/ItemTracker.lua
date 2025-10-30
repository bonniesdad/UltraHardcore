-- Item Usage Tracker
-- Handles tracking of various item usages (potions, bandages, grenades, target dummies)

-- Initialize global table
ItemTracker = {}

-- Healing potion spell IDs in WoW Classic
local healingPotionSpellIDs = {
  [439] = true, -- Minor Healing Potion
  [440] = true, -- Lesser Healing Potion
  [2370] = true, -- Rejuvenation Potion
  [441] = true, -- Healing Potion
  [2024] = true, -- Healing Potion
  [4042] = true, -- Healing Potion
  [11387] = true, -- Wildvine Potion
  [21394] = true, -- Healing Draught
  [17534] = true, -- Healing Potion
  [21393] = true, -- Healing Draught
  [22729] = true, -- Rejuvenation Potion
}

-- Mana potion spell IDs in WoW Classic
local manaPotionSpellIDs = {
  [437] = true, -- Minor Mana Potion
  [438] = true, -- Lesser Mana Potion
  [2023] = true, -- Mana Potion
  [11903] = true, -- Greater Mana Potion
  [17530] = true, -- Superior Mana Potion
  [17531] = true, -- Major Mana Potion
}

-- Target dummy spell IDs in WoW Classic
local targetDummySpellIDs = {
  [4071] = true, -- Target Dummy
  [4072] = true, -- Advanced Target Dummy
  [19805] = true, -- Masterwork Target Dummy
}

-- Grenade spell IDs in WoW Classic
local grenadeSpellIDs = {
  [4064] = true, -- Rough Copper Bomb
  [4065] = true, -- Large Copper Bomb
  [4066] = true, -- Small Bronze Bomb
  [4067] = true, -- Big Bronze Bomb
  [4069] = true, -- Big Iron Bomb
  [12421] = true, -- Mithril Frag Bomb
  [12543] = true, -- Hi-Explosive Bomb
  [19784] = true, -- Dark Iron Bomb
  [4068] = true, -- Iron Grenade
  [19769] = true, -- Thorium Grenade
  [12562] = true, -- The Big One
}

-- Handle bandage tracking using "Recently Bandaged" debuff
function ItemTracker.HandleBandageUsage(subEvent, destGUID, spellID)
  if subEvent == 'SPELL_AURA_APPLIED' and destGUID == UnitGUID('player') and spellID == 11196 then
    local currentBandages = CharacterStats:GetStat('bandagesUsed') or 0
    CharacterStats:UpdateStat('bandagesUsed', currentBandages + 1)
  end
end

-- Handle health potion usage tracking
function ItemTracker.HandleHealthPotionUsage(subEvent, sourceGUID, spellID)
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    if healingPotionSpellIDs[spellID] then
      local currentHealthPotions = CharacterStats:GetStat('healthPotionsUsed') or 0
      local newCount = currentHealthPotions + 1
      CharacterStats:UpdateStat('healthPotionsUsed', newCount)
    end
  end
end

function ItemTracker.HandleManaPotionUsage(subEvent, sourceGUID, spellID)
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    print('Mana potion used: ' .. spellID)
    if manaPotionSpellIDs[spellID] then
      local currentManaPotions = CharacterStats:GetStat('manaPotionsUsed') or 0
      local newCount = currentManaPotions + 1
      CharacterStats:UpdateStat('manaPotionsUsed', newCount)
    end
  end
end

-- Handle target dummy usage tracking
function ItemTracker.HandleTargetDummyUsage(subEvent, sourceGUID, spellID)
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    if targetDummySpellIDs[spellID] then
      local currentTargetDummies = CharacterStats:GetStat('targetDummiesUsed') or 0
      local newCount = currentTargetDummies + 1
      CharacterStats:UpdateStat('targetDummiesUsed', newCount)
    end
  end
end

-- Handle grenade usage tracking
function ItemTracker.HandleGrenadeUsage(subEvent, sourceGUID, spellID)
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    if grenadeSpellIDs[spellID] then
      local currentGrenades = CharacterStats:GetStat('grenadesUsed') or 0
      local newCount = currentGrenades + 1
      CharacterStats:UpdateStat('grenadesUsed', newCount)
    end
  end
end

-- Main function to handle all item usage tracking
function ItemTracker.HandleItemUsage(subEvent, sourceGUID, destGUID, spellID)
  ItemTracker.HandleBandageUsage(subEvent, destGUID, spellID)
  ItemTracker.HandleHealthPotionUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleManaPotionUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleTargetDummyUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleGrenadeUsage(subEvent, sourceGUID, spellID)
end
