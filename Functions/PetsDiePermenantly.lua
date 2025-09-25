-- Function to prevent hunters from reviving their pets
local function PreventPetRevival()
    -- Hook into the revive pet spell
    hooksecurefunc("CastSpellByName", function(spellName)
        if spellName == "Revive Pet" then
            -- Check if the player is a hunter
            local _, playerClass = UnitClass("player")
            if playerClass == "HUNTER" then
                -- Cancel the spell cast
                SpellStopCasting()
                -- Notify the player
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[UltraHardcore]|r Your pet has died permanently and cannot be revived.", 1, 0, 0)
            end
        end
    end)
end

-- Register the function to run when the addon loads
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if (event == "PLAYER_ENTERING_WORLD" or (event == "ADDON_LOADED" and addonName == "UltraHardcore")) then
        if GLOBAL_SETTINGS.petsDiePermanently then
            PreventPetRevival()
        end
    end
end)
