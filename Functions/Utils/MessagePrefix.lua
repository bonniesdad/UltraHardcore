-- Prefix
local PREFIX = "[UHC] "
--local PREFIX = "{skull} " -- Or use an image

local validChatTypes = {
    ["SAY"] = true,
    ["YELL"] = true,
    ["PARTY"] = true,
    ["RAID"] = true,
    ["GUILD"] = true,
    ["WHISPER"] = true,
}

local originalSendChatMessage = SendChatMessage
SendChatMessage = function(msg, chatType, language, target)
    if validChatTypes[chatType] and msg and msg ~= "" then
        msg = PREFIX .. msg
    end
    return originalSendChatMessage(msg, chatType, language, target)
end