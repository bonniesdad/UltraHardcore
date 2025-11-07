-- ChallengeDefinitions.lua

local C = _G.Challenges
if not C then return end

-- Helpers
local function playerIs(unit) return unit == "player" end

local function usingPotionByName(spellID)
  if not spellID then return false end
  local name = GetSpellInfo(spellID)
  if not name then return false end
  return name:find("Potion") ~= nil  -- refine with a spellID list
end

local function isInDungeonInstance()
  local inInst, instType = IsInInstance()
  return inInst and (instType == "party")
end

local function isAnyWeaponEquipped()
  local function slotHasWeapon(slot)
    local itemID = GetInventoryItemID("player", slot)
    if not itemID then return false end
    local _, _, _, _, _, itemType = GetItemInfo(itemID)
    if _G.LE_ITEM_CLASS_WEAPON and _G.GetItemClassInfo then
      local weaponTypeName = GetItemClassInfo(LE_ITEM_CLASS_WEAPON)
      return itemType == weaponTypeName
    end
    return itemType == "Weapon"
  end
  return slotHasWeapon(16) or slotHasWeapon(17) or slotHasWeapon(18)
end

-- no_potions
C.Register({
  id = "no_potions",
  name = "No Potions",
  description = "You may not use any healing or mana potions.",
  icon = "Interface\\Icons\\inv_potion_52",
  events = { "UNIT_SPELLCAST_SUCCEEDED" },
  onEvent = function(self, event, unit, _, spellID)
    if playerIs(unit) and usingPotionByName(spellID) then
      C.Fail(self.id, "Used a potion")
    end
  end,
})

-- solo_only
C.Register({
  id = "solo_only",
  name = "Solo Only",
  description = "You may not join a party or raid.",
  icon = "Interface\\Icons\\spell_holy_symbolofhope",
  events = { "GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD" },
  onEvent = function(self)
    if IsInGroup() or IsInRaid() then
      C.Fail(self.id, "Formed a group")
    end
  end,
})

-- no_ah
C.Register({
  id = "no_ah",
  name = "No Auction House",
  description = "You may not use the Auction House.",
  icon = "Interface\\Icons\\inv_misc_coin_01",
  events = { "AUCTION_HOUSE_SHOW" },
  onEvent = function(self)
    C.Fail(self.id, "Opened the Auction House")
  end,
})

-- ironman (no groups, no dungeons, no potions)
C.Register({
  id = "ironman",
  name = "Ironman",
  description = "No grouping, no dungeons, and no potions. Reach 60 without breaking the rules.",
  icon = "Interface\\Icons\\inv_misc_trophy_01",
  events = {
    "GROUP_ROSTER_UPDATE",
    "PLAYER_ENTERING_WORLD",
    "UNIT_SPELLCAST_SUCCEEDED",
  },
  onEvent = function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
      if IsInGroup() or IsInRaid() then
        return C.Fail(self.id, "Formed a group")
      end
    elseif event == "PLAYER_ENTERING_WORLD" then
      if isInDungeonInstance() then
        return C.Fail(self.id, "Entered a dungeon")
      end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
      local unit, _, spellID = ...
      if playerIs(unit) and usingPotionByName(spellID) then
        return C.Fail(self.id, "Used a potion")
      end
    end
  end,
})

-- barehanded
C.Register({
  id = "barehanded",
  name = "Barehanded",
  description = "You may not equip any weapons.",
  icon = "Interface\\Icons\\inv_gauntlets_27",
  events = { "PLAYER_EQUIPMENT_CHANGED", "PLAYER_ENTERING_WORLD" },
  onEvent = function(self)
    if isAnyWeaponEquipped() then
      C.Fail(self.id, "Equipped a weapon")
    end
  end,
})

-- Optional presets (apply at level 1)
C.RegisterPreset("Classic Hardcore", { "no_deaths" })
C.RegisterPreset("No Market",        { "no_deaths", "no_ah" })
C.RegisterPreset("Iron Discipline",  { "ironman" })
C.RegisterPreset("Pure Solo",        { "no_deaths", "solo_only" })
C.RegisterPreset("Fists Only",       { "no_deaths", "barehanded" })
