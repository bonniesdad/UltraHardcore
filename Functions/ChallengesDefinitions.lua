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
  icon = "Interface\\Icons\\ability_warrior_challange",
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

-- =========================
-- Class-Specific Challenges
-- =========================

local C = _G.Challenges
if not C then return end

local PLAYER_CLASS = select(2, UnitClass("player"))

-- Helpers for weapon checks
local function GetItemClassSubClass(link)
  if GetItemInfoInstant then
    local classID, subClassID = select(10, GetItemInfoInstant(link or ""))
    return classID, subClassID
  end
  -- Fallback: less strict
  local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link or "")
  return nil, nil, equipLoc
end

local function equipLoc(link)
  return select(9, GetItemInfo(link or ""))
end

local function invLink(slot) return GetInventoryItemLink("player", slot) end
local function isWand(link)
  local classID, subClassID = GetItemClassSubClass(link)
  return (classID == LE_ITEM_CLASS_WEAPON and subClassID == LE_ITEM_WEAPON_WAND)
end
local function isDagger(link)
  local classID, subClassID = GetItemClassSubClass(link)
  return (classID == LE_ITEM_CLASS_WEAPON and subClassID == LE_ITEM_WEAPON_DAGGER)
end

-- -------------------------
-- WARRIOR: Two-Handed Only
-- -------------------------
if PLAYER_CLASS == "WARRIOR" then
  local function classSub(link)
    if not link then return nil, nil end
    local classID, subClassID = select(10, GetItemInfoInstant(link))
    return classID, subClassID
  end
  local function equipLoc(link)
    return select(9, GetItemInfo(link or "")) -- "INVTYPE_2HWEAPON", etc.
  end
  local function isSword(link)
    if not link then return false end
    local classID, subClassID = classSub(link)
    return classID == LE_ITEM_CLASS_WEAPON and (subClassID == LE_ITEM_WEAPON_SWORD1H or subClassID == LE_ITEM_WEAPON_SWORD2H)
  end
  local function isStaff(link)
    if not link then return false end
    local classID, subClassID = classSub(link)
    return classID == LE_ITEM_CLASS_WEAPON and subClassID == LE_ITEM_WEAPON_STAFF
  end
  local function isCloth(link)
    if not link then return false end
    local classID, subClassID = classSub(link)
    return classID == LE_ITEM_CLASS_ARMOR and subClassID == LE_ITEM_ARMOR_CLOTH
  end

  -- 2H Only
  C.Register({
    id = "class_warrior_2h_only",
    name = "Two-Handed Only",
    description = "Must equip a two-handed weapon; no offhand or shield.",
    icon = "Interface\\Icons\\inv_axe_04",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED" },
    onEvent = function(self)
      local mh = invLink(16)
      local oh = invLink(17)
      if oh then return C.Fail(self.id, "Offhand/shield equipped") end
      if not mh then return C.Fail(self.id, "No main-hand weapon") end
      if equipLoc(mh) ~= "INVTYPE_2HWEAPON" then
        return C.Fail(self.id, "Main hand is not two-handed")
      end
    end,
    validate = function(self)
      local mh, oh = invLink(16), invLink(17)
      if oh then return false, "Offhand/shield equipped" end
      if not mh then return false, "No main-hand weapon" end
      if equipLoc(mh) ~= "INVTYPE_2HWEAPON" then return false, "Main hand is not two-handed" end
      return true
    end,
  })
  C.RegisterPreset("Class: Warrior (2H Only)", { "class_warrior_2h_only" })
  Challenges.RegisterClassRule("class_warrior_2h_only", {
    name = "Two-Handed Only",
    desc = "Must equip a two-handed weapon; no offhand/shield.",
    icon = "Interface\\Icons\\inv_axe_04",
  })

  -- Swordmaster
  C.Register({
    id = "class_warrior_swordmaster",
    name = "Swordmaster",
    description = "May equip only swords (1H or 2H). Shields and non-sword weapons are forbidden.",
    icon = "Interface\\Icons\\inv_sword_27",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED" },
    onEvent = function(self)
      local mh, oh = invLink(16), invLink(17)
      if mh and not isSword(mh) then
        return C.Fail(self.id, "Main hand is not a sword")
      end
      if oh and not isSword(oh) then
        return C.Fail(self.id, "Offhand is not a sword")
      end
    end,
    validate = function(self)
      local mh, oh = invLink(16), invLink(17)
      if mh and not isSword(mh) then return false, "Main hand is not a sword" end
      if oh and not isSword(oh) then return false, "Offhand is not a sword" end
      return true
    end,
  })
  C.RegisterPreset("Class: Warrior (Swordmaster)", { "class_warrior_swordmaster" })
  Challenges.RegisterClassRule("class_warrior_swordmaster", {
    name = "Swordmaster",
    desc = "Only swords (1H/2H). No shields or other weapons.",
    icon = "Interface\\Icons\\inv_sword_27",
  })

  -- Monk
  C.Register({
    id = "class_warrior_monk",
    name = "Monk",
    description = "May only wear cloth armor and may only use a staff (2H). Offhand must be empty.",
    icon = "Interface\\Icons\\inv_staff_08",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED" },
    onEvent = function(self)
      local armorSlots = {1,3,5,6,7,8,9,10,15}
      for _, slot in ipairs(armorSlots) do
        local link = invLink(slot)
        if link and not isCloth(link) then
          return C.Fail(self.id, "Non-cloth armor equipped")
        end
      end
      local mh, oh = invLink(16), invLink(17)
      if not mh or not isStaff(mh) then
        return C.Fail(self.id, "Main hand is not a staff")
      end
      if equipLoc(mh) ~= "INVTYPE_2HWEAPON" then
        return C.Fail(self.id, "Staff must be two-handed")
      end
      if oh then
        return C.Fail(self.id, "Offhand must be empty")
      end
    end,
    validate = function(self)
      local armorSlots = {1,3,5,6,7,8,9,10,15}
      for _, slot in ipairs(armorSlots) do
        local link = invLink(slot)
        if link and not isCloth(link) then return false, "Non-cloth armor equipped" end
      end
      local mh, oh = invLink(16), invLink(17)
      if not mh or not isStaff(mh) then return false, "Main hand is not a staff" end
      if equipLoc(mh) ~= "INVTYPE_2HWEAPON" then return false, "Staff must be two-handed" end
      if oh then return false, "Offhand must be empty" end
      return true
    end,
  })
  C.RegisterPreset("Class: Warrior (Monk)", { "class_warrior_monk" })
  Challenges.RegisterClassRule("class_warrior_monk", {
    name = "Monk",
    desc = "Cloth armor only. Two-handed staff only. Offhand empty.",
    icon = "Interface\\Icons\\inv_staff_08",
  })

  -- Barbarian
  C.Register({
    id = "class_warrior_barbarian",
    name = "Barbarian",
    description = "May not equip a chest piece and may only use swords.",
    icon = "Interface\\Icons\\ability_warrior_battleshout",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED" },
    onEvent = function(self)
      if invLink(5) then
        return C.Fail(self.id, "Chest piece equipped")
      end
      local mh, oh = invLink(16), invLink(17)
      if mh and not isSword(mh) then
        return C.Fail(self.id, "Main hand is not a sword")
      end
      if oh and not isSword(oh) then
        return C.Fail(self.id, "Offhand is not a sword")
      end
    end,
    validate = function(self)
      if invLink(5) then return false, "Chest piece equipped" end
      local mh, oh = invLink(16), invLink(17)
      if mh and not isSword(mh) then return false, "Main hand is not a sword" end
      if oh and not isSword(oh) then return false, "Offhand is not a sword" end
      return true
    end,
  })
  C.RegisterPreset("Class: Warrior (Barbarian)", { "class_warrior_barbarian" })
  Challenges.RegisterClassRule("class_warrior_barbarian", {
    name = "Barbarian",
    desc = "No chest piece. Only swords (1H/2H).",
    icon = "Interface\\Icons\\ability_warrior_battleshout",
  })
end

-- ---------------
-- HUNTER: No Pet
-- ---------------
if PLAYER_CLASS == "HUNTER" then
  C.Register({
    id = "class_hunter_no_pet",
    name = "No Pet",
    description = "May not have a pet active.",
    icon = "Interface\\Icons\\ability_hunter_beastcall",
    events = { "PLAYER_LOGIN", "UNIT_PET" },
    onEvent = function(self, event, unit)
      if UnitExists("pet") then
        return C.Fail(self.id, "Pet is active")
      end
    end,
    validate = function(self)
      if UnitExists("pet") then
        return false, "Pet is active"
      end
      return true
    end,
  })
  C.RegisterPreset("Class: Hunter (No Pet)", { "class_hunter_no_pet" })
  Challenges.RegisterClassRule("class_hunter_no_pet", {
    name = "No Pet",
    desc = "May not have a pet active.",
    icon = "Interface\\Icons\\ability_hunter_beastcall",
  })
end

-- --------------------------
-- ROGUE: Daggers Only (MH/OH)
-- --------------------------
if PLAYER_CLASS == "ROGUE" then
  C.Register({
    id = "class_rogue_daggers_only",
    name = "Daggers Only",
    description = "May only equip daggers in weapon slots.",
    icon = "Interface\\Icons\\inv_weapon_shortblade_04",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED" },
    onEvent = function(self)
      local mh = invLink(16)
      local oh = invLink(17)
      if mh and not isDagger(mh) then return C.Fail(self.id, "Main hand is not a dagger") end
      if oh and not isDagger(oh) then return C.Fail(self.id, "Offhand is not a dagger") end
    end,
      validate = function(self)
        local mh, oh = invLink(16), invLink(17)
        if mh and not isDagger(mh) then return false, "Main hand is not a dagger" end
        if oh and not isDagger(oh) then return false, "Offhand is not a dagger" end
        return true
    end,
  })
  C.RegisterPreset("Class: Rogue (Daggers)", { "class_rogue_daggers_only" })
  Challenges.RegisterClassRule("class_rogue_daggers_only", {
    name = "Daggers Only",
    desc = "May only equip daggers in weapon slots.",
    icon = "Interface\\Icons\\inv_weapon_shortblade_04",
  })
end

-- -----------------------------------------------
-- MAGE/PRIEST/WARLOCK: No Wands (and no Shoot cast)
-- -----------------------------------------------
local function registerNoWandFor(classToken, prettyName, icon)
  if PLAYER_CLASS ~= classToken then return end

  C.Register({
    id = "class_"..string.lower(classToken).."_no_wand",
    name = "No Wands",
    description = "Cannot equip wands or use Shoot (wand).",
    icon = icon or "Interface\\Icons\\inv_wand_02",
    events = { "PLAYER_LOGIN", "PLAYER_EQUIPMENT_CHANGED", "COMBAT_LOG_EVENT_UNFILTERED" },
    onEvent = function(self, event)
      if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, _, _, _, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
        if subEvent == "SPELL_CAST_SUCCESS" and (spellID == 5019 or spellName == "Shoot") then
          return C.Fail(self.id, "Used Shoot (wand)")
        end
      else
        local r = GetInventoryItemLink("player", 18)
        if r then
          local classID, subClassID = select(10, GetItemInfoInstant(r))
          if classID == LE_ITEM_CLASS_WEAPON and subClassID == LE_ITEM_WEAPON_WAND then
            return C.Fail(self.id, "Wand equipped")
          end
        end
      end
    end,
    validate = function(self)
      local r = GetInventoryItemLink("player", 18)
      if r then
        local classID, subClassID = select(10, GetItemInfoInstant(r))
        if classID == LE_ITEM_CLASS_WEAPON and subClassID == LE_ITEM_WEAPON_WAND then
          return false, "Wand equipped"
        end
      end
      return true
    end,
  })

  C.RegisterPreset("Class: "..prettyName.." (No Wands)", { "class_"..string.lower(classToken).."_no_wand" })

  Challenges.RegisterClassRule("class_"..string.lower(classToken).."_no_wand", {
    name = "No Wands",
    desc = "Cannot equip wands or use Shoot.",
    icon = icon or "Interface\\Icons\\inv_wand_02",
  })
end

registerNoWandFor("MAGE",   "Mage",   "Interface\\Icons\\inv_wand_07")
registerNoWandFor("PRIEST", "Priest", "Interface\\Icons\\inv_wand_01")
registerNoWandFor("WARLOCK","Warlock","Interface\\Icons\\inv_wand_04")
