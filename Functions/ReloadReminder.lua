local reloadReminder = {
    RemindInterval = 3600,
}

local function PrintReminder()
    local elapsedTime = self:TimeSinceSave()
    Printing:P("Addon data not saved for " .. Colours.ByName("Cyan", SecondsToTime(elapsedTime)) .. ".  Reloading is recommended.")

    -- If we haven't reloaded, keep halfing the time until the next reminder
    -- until 15 minutes, then remind every 5
    if self.ReminderInterval > 900 then 
        self.RemindInterval = self.ReminderInterval / 2
    elseif self.ReminderInterval > 300 then 
        self.ReminderInterval = self.ReminderInterval - 300
    end
end

local function ShowReminderButton()

end

local function HideReminderButton()

end

function Touch() 
    local stats = CharacterStats:GetCurrentCharacterStats()
    stats["LastReloadedAt"] = GetServerTime()
end

function DoReload()
    self:Touch()
    self.ReminderInterval = 3600
    self:HideReminderButton()
end

local function TimeSinceSave()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]
    local serverTime = GetServerTime()
    return (serverTime - lastReload)
end

local function CheckLastReloadTime()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]

    if lastReload == nil then
        stats["LastReloadedAt"] = GetServerTime()
    else
        local diff = self:TimeSinceSave()

        if diff > self.RemindInterval then 
            self:PrintReminder()
        end
    end
end


local reloadReminderFrame = CreateFrame("Frame")

reloadReminderFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

reloadReminderFrame:SetScript('OnEvent', function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        CheckLastReloadTime()
    end
end)