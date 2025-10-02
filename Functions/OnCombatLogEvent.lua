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
  if subEvent == "PARTY_KILL" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet")) then
    if IsEnemyElite(destGUID) then
      local solo = true

      if IsInGroup() then
        if IsInRaid() then
          local n = GetNumGroupMembers()
          for i = 1, n do
            local u = "raid"..i
            if not UnitIsUnit(u, "player") and UnitInRange(u) then
              solo = false
              break
            end
          end
        else
          local n = GetNumSubgroupMembers()
          for i = 1, n do
            local u = "party"..i
            if UnitInRange(u) then
              solo = false
              break
            end
          end
        end
      end

      if solo then
        local soloElites = CharacterStats:GetStat("soloElitesSlain") or 0
        CharacterStats:UpdateStat("soloElitesSlain", soloElites + 1)
      end

      local currentElites = CharacterStats:GetStat("elitesSlain") or 0
      CharacterStats:UpdateStat("elitesSlain", currentElites + 1)
    end

    local currentEnemies = CharacterStats:GetStat("enemiesSlain") or 0
    CharacterStats:UpdateStat("enemiesSlain", currentEnemies + 1)
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
end
