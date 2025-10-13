-- Function to announce level ups to guild chat every 10th level
local function AnnounceLevelUpToGuild(announceLevelUpToGuild)
    -- Check if the setting is enabled
    if not announceLevelUpToGuild then
        return
    end
    
    -- Get current player level
    local currentLevel = UnitLevel("player") + 1
    
    -- Check if this is a 10th level (10, 20, 30, 40, 50, 60)
    if currentLevel % 10 == 0 and currentLevel > 0 then
        -- Send message to guild chat
        local message = "[ULTRA] I just dinged to level " .. currentLevel .. " whilst using Ultra!"
        SendChatMessage(message, "GUILD")
    end
end

-- Export the function
_G.AnnounceLevelUpToGuild = AnnounceLevelUpToGuild
