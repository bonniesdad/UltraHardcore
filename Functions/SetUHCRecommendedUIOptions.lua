function SetUHCRecommendedUIOptions(enableDefaultOptions)
    if not enableDefaultOptions then return end
    
    -- Disable incoming combat text
    SetCVar("floatingCombatTextCombatDamage", "0")
    SetCVar("floatingCombatTextCombatHealing", "0")
    
    -- Disable outgoing combat text
    SetCVar("floatingCombatTextCombatDamageDirectionalScale", "0")
    SetCVar("floatingCombatTextCombatHealingDirectionalScale", "0")
    
    -- Disable combat text scrolling
    SetCVar("floatingCombatTextCombatDamageDirectionalOffset", "0")
    SetCVar("floatingCombatTextCombatHealingDirectionalOffset", "0")
end 