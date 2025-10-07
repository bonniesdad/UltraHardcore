-- Function to abandon pet when it dies
function CheckAndAbandonPet()
    -- Check if the player is a hunter
    local _, playerClass = UnitClass("player")
    if playerClass ~= "HUNTER" then
        return
    end
    
    -- Check if player has a pet
    if not UnitExists("pet") then
        return
    end
    
    -- Check if pet is dead
    local isDead = UnitIsDead("pet")
    if not isDead then
        return
    end

    -- Pet is dead, abandon it immediately
    PetAbandon()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[UHC]|r Your pet has died and been abandoned.", 1, 0, 0)
end