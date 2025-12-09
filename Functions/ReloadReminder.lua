local ReloadReminder = {
    ReminderInterval = 3600,
}

function ReloadReminder:PrintReminder()
    local elapsedTime = self:TimeSinceSave()
    local timeInPlainText = SecondsToTime(elapsedTime)
    Printing:P(Colours:ByName("Silver", "Addon data not saved for ")
                .. Colours:ByName("Cyan", tostring(timeInPlainText))
                .. Colours:ByName("Silver", ".  Reload when safe to save your stats."))

    -- If we haven't reloaded, keep halfing the time until the next reminder
    -- until 15 minutes, then remind every 5
    if self.ReminderInterval > 900 then 
        self.ReminderInterval = self.ReminderInterval / 2
    elseif self.ReminderInterval > 300 then 
        self.ReminderInterval = self.ReminderInterval - 300
    end
end

function ReloadReminder:ShowReminderButton()

end

function ReloadReminder:HideReminderButton()

end

function ReloadReminder:Touch() 
    local stats = CharacterStats:GetCurrentCharacterStats()
    stats["LastReloadedAt"] = GetServerTime()
end

function ReloadReminder:DoReload()
    self:Touch()
    self.ReminderInterval = 3600
    self:HideReminderButton()
end

function ReloadReminder:TimeSinceSave()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]
    local serverTime = GetServerTime()
    return (serverTime - lastReload)
end

function ReloadReminder:CheckLastReloadTime()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]

    if lastReload == nil then
        stats["LastReloadedAt"] = GetServerTime()
    else
        local diff = self:TimeSinceSave()
        Printing:Debug("Last reloaded " .. SecondsToTime(diff) .. " ago")

        if diff > self.ReminderInterval then 
            self:PrintReminder()
        end
    end
end


local reloadReminderFrame = CreateFrame("Frame")

reloadReminderFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

reloadReminderFrame:SetScript('OnEvent', function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        ReloadReminder:CheckLastReloadTime()
    end
end)

_G.ReloadReminder = ReloadReminder