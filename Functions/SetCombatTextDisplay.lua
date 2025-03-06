local frame = CreateFrame('Frame')

-- Store original CVar values
local originalCombatTextCombatDamage = GetCVar('floatingCombatTextCombatDamage')
local originalCombatTextCombatHealing = GetCVar('floatingCombatTextCombatHealing')

local function HideCombatText()
  if GLOBAL_SETTINGS.hideCombatText then
    -- Block all combat text updates
    CombatText_AddMessage = function() end
    -- Set CVar values to hide combat text
    SetCVar('floatingCombatTextCombatDamage', '0')
    SetCVar('floatingCombatTextCombatHealing', '0')
  end
end

-- Save the original CombatText_AddMessage function so we can restore it
if not CombatText_AddMessage_original then
  CombatText_AddMessage_original = CombatText_AddMessage
end

frame:RegisterEvent('CVAR_UPDATE')
frame:RegisterEvent('ADDON_LOADED') -- Apply on login
local function OnEvent(self, event, arg1)
  HideCombatText()
  if event == 'ADDON_LOADED' and arg1 == 'UltraHardcore' then
    if GLOBAL_SETTINGS.hideCombatText then
      -- Disable combat text settings
      SetCVar('floatingCombatTextCombatDamage', '0')
      SetCVar('floatingCombatTextCombatHealing', '0')
    end
  elseif event == 'CVAR_UPDATE' then
    -- Handle CVar updates here if needed
    if GLOBAL_SETTINGS.hideCombatText then
      SetCVar('floatingCombatTextCombatDamage', '0')
      SetCVar('floatingCombatTextCombatHealing', '0')
    end
  end
end

frame:SetScript('OnEvent', OnEvent)
