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

  -- TODO: Not ready... Keys get stuck!
  -- UpdateKeyBindings()

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

  -- Detect Immunity
  if subEvent == 'SPELL_CAST_FAILED' and destGUID == UnitGUID('target') then
    if string.match(spellName, 'Immune') then
      ShowImmunityIcon()
    end
  end
end
