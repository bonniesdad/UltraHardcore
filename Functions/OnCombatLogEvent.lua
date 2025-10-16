local frame = CreateFrame('Frame', nil, UIParent)
frame:SetSize(300, 100) -- Set the size of the frame
frame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 150)
frame:Hide() -- Initially hidden
--
local messageText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
messageText:SetPoint('CENTER', frame, 'CENTER')
messageText:SetFont('Fonts\\FRIZQT__.TTF', 18, 'OUTLINE')
messageText:SetTextColor(1, 1, 1, 1) -- White text
messageText:SetJustifyH('CENTER') -- Center the text
--
local incomingSpellTimer
--
function OnCombatLogEvent(self, event)
  local _, subEvent, _, sourceGUID, _, _, _, destGUID, enemyName, _, _, spellID, a, b, c, d, e, f =
    CombatLogGetCurrentEventInfo()

  amount, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())

  -- Incoming spell damage
  if GLOBAL_SETTINGS.showIncomingDamageEffect then
    if subEvent == 'SWING_DAMAGE' then
      if destGUID == UnitGUID('player') then
        ShowPhysicalDamageOverlay()
      end
    end
    if subEvent == 'SPELL_DAMAGE' or subEvent == 'SPELL_PERIODIC_DAMAGE' then
      if destGUID == UnitGUID('player') then
        local school = select(15, CombatLogGetCurrentEventInfo())
        local schoolNames = {
          [2] = "Fire",
          [3] = "Fire",
          [4] = "Fire",
          [5] = "Shadow",
          [8] = "Nature",
          [11] = "Physical",
          [12] = "Physical",
          [16] = "Frost",
          [32] = "Shadow",
          [64] = "Arcane"
        }
        local schoolName = schoolNames[school] or "Unknown"
        
        -- Use OverTime variant for periodic damage
        if subEvent == 'SPELL_PERIODIC_DAMAGE' then
          if schoolName == "Physical" then
            ShowPhysicalDamageOverTimeOverlay()
          elseif schoolName == "Shadow" then
            ShowShadowDamageOverTimeOverlay()
          elseif schoolName == "Holy" then
            ShowHolyDamageOverTimeOverlay()
          elseif schoolName == "Arcane" then
            ShowArcaneDamageOverTimeOverlay()
          elseif schoolName == "Nature" then
            ShowNatureDamageOverTimeOverlay()
          elseif schoolName == "Fire" then
            ShowFireDamageOverTimeOverlay()
          end
        else
          if schoolName == "Shadow" then
            ShowShadowDamageOverlay()
          elseif schoolName == "Holy" then
            ShowHolyDamageOverlay()
          elseif schoolName == "Arcane" then
            ShowArcaneDamageOverlay()
          elseif schoolName == "Nature" then
            ShowNatureDamageOverlay()
          elseif schoolName == "Fire" then
            ShowFireDamageOverlay()
          end
        end
      end
    end
  end

  -- Critical hit!
  if GLOBAL_SETTINGS.showCritScreenMoveEffect then
    if subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE' then
      if destGUID == UnitGUID('player') and critical then
        RotateScreenEffect()
      end
    end
  end

  -- Party kill
  if subEvent == 'PARTY_KILL' then
    if IsEnemyElite(destGUID) then
      local currentElites = CharacterStats:GetStat('elitesSlain') or 0
      CharacterStats:UpdateStat('elitesSlain', currentElites + 1)
    end

    -- Check if this was a dungeon boss kill
    local isDungeonBoss, isRaidBoss = IsDungeonBoss(destGUID)
    if isDungeonBoss then
      local currentDungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
      CharacterStats:UpdateStat('dungeonBossesKilled', currentDungeonBosses + 1)
    end

    -- Check if this was a dungeon completion (final boss kill)
    local isDungeonFinalBoss, isRaidFinalBoss = IsDungeonFinalBoss(destGUID)
    if isDungeonFinalBoss then
      local currentDungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
      CharacterStats:UpdateStat('dungeonsCompleted', currentDungeonsCompleted + 1)
    end

    local currentEnemies = CharacterStats:GetStat('enemiesSlain') or 0
    CharacterStats:UpdateStat('enemiesSlain', currentEnemies + 1)
  end

  -- Dazed!
  if GLOBAL_SETTINGS.showDazedEffect then
    if subEvent == 'SPELL_AURA_APPLIED' and destGUID == UnitGUID('player') and spellID == 1604 then
      ShowDazedOverlay(true) -- Dazed, enable blur
    elseif subEvent == 'SPELL_AURA_REMOVED' and destGUID == UnitGUID(
      'player'
    ) and spellID == 1604 then
      ShowDazedOverlay(false) -- Daze ended, disable blur
    end
  end

  -- Bandage tracking using "Recently Bandaged" debuff
  if subEvent == 'SPELL_AURA_APPLIED' and destGUID == UnitGUID('player') and spellID == 11196 then
    local currentBandages = CharacterStats:GetStat('bandagesUsed') or 0
    CharacterStats:UpdateStat('bandagesUsed', currentBandages + 1)
  end

  -- Health potion tracking
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    -- Common healing potion spell IDs in WoW Classic (these are the spell effects triggered by potion items)
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
      [22729] = true -- Rejuvenation Potion 
    }
    
    if healingPotionSpellIDs[spellID] then
      local currentHealthPotions = CharacterStats:GetStat('healthPotionsUsed') or 0
      local newCount = currentHealthPotions + 1
      CharacterStats:UpdateStat('healthPotionsUsed', newCount)
    end
  end

  -- Target dummy tracking
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
    -- Target dummy spell IDs in WoW Classic
    local targetDummySpellIDs = {
      [4071] = true, -- Target Dummy
      [4072] = true, -- Advanced Target Dummy
      [19805] = true -- Masterwork Target Dummy
    }
    
    if targetDummySpellIDs[spellID] then
      local currentTargetDummies = CharacterStats:GetStat('targetDummiesUsed') or 0
      local newCount = currentTargetDummies + 1
      CharacterStats:UpdateStat('targetDummiesUsed', newCount)
    end
  end

  -- Grenade tracking
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') then
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
      [12562] = true -- The Big One
    }
    
    if grenadeSpellIDs[spellID] then
      local currentGrenades = CharacterStats:GetStat('grenadesUsed') or 0
      local newCount = currentGrenades + 1
      CharacterStats:UpdateStat('grenadesUsed', newCount)
    end
  end

  -- Party member death tracking
  if subEvent == 'UNIT_DIED' then
    -- Check if the dead unit is a party member (not the player)
    local playerGUID = UnitGUID('player')
    if destGUID ~= playerGUID and IsInGroup() then
      -- Check if the dead unit is a party member
      local isPartyMember = false
      local deadPlayerName = nil
      
      if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
          local name, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
          if guid == destGUID then
            isPartyMember = true
            deadPlayerName = name
            break
          end
        end
      else
        -- Regular party (not raid)
        for i = 1, GetNumGroupMembers() do
          local unitID = 'party' .. i
          if UnitGUID(unitID) == destGUID then
            isPartyMember = true
            deadPlayerName = UnitName(unitID)
            break
          end
        end
      end
      
      -- If it's a party member, increment the death count
      if isPartyMember and deadPlayerName then
        local currentPartyDeaths = CharacterStats:GetStat('partyMemberDeaths') or 0
        local newCount = currentPartyDeaths + 1
        CharacterStats:UpdateStat('partyMemberDeaths', newCount)
        
        -- Optional: Print a message to chat
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[UHC]|r Party member " .. deadPlayerName .. " has died. Total party deaths: " .. newCount, 1, 0, 0)
      end
    elseif destGUID == playerGUID then
      -- Player death sound
      PlaySoundFile("Interface\\AddOns\\UltraHardcore\\Sounds\\PlayerDeath.ogg", "SFX")
    end
  end
end
