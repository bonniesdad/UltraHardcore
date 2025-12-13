
local ReloadReminder = {
    ReminderInterval = 3600,
    DefaultMinutes = 60,
    MinMinutes = 15,
    MaxMinutes = 180,
    RemindersClosed = 0,
}

--- Updates the reminder interval to the specified number of minutes.
-- Clamped between MinMinutes and MaxMinutes.
function ReloadReminder:UpdateInterval(minutes)
    -- Clamp between min and max
    minutes = math.max(self.MinMinutes, math.min(self.MaxMinutes, minutes))
    self.ReminderInterval = minutes * 60
end

--- Returns the time remaining until the next reminder should be shown.
-- @return The time in seconds until the next reminder.
function ReloadReminder:TimeUntilReminder()
    local elapsedTime = self:TimeSinceSave()
    local closedTime = self:TimeSinceClose()

    if closedTime < elapsedTime then
        elapsedTime = closedTime
    end
    local timeLeft = self.ReminderInterval - elapsedTime
    if timeLeft < 0 then timeLeft = 0 end
    return timeLeft
end

--- Loads the reminder interval from global settings.
function ReloadReminder:LoadInterval()
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.reminderIntervalMinutes then
        self.ReminderInterval = GLOBAL_SETTINGS.reminderIntervalMinutes * 60
    else
        self.ReminderInterval = 3600 -- 60 minutes default
    end
end

--- Prints information about the time since last save and reminders closed.
function ReloadReminder:IntervalInformation()
    local elapsedTime = self:TimeSinceSave()
    local closedTime = self:TimeSinceClose()
    local timeInPlainText = SecondsToTime(elapsedTime)

    if self.RemindersClosed > 0 then
        Printing:P(Colours:ByName("Silver", "Addon data not saved for ")
                    .. Colours:ByName("OrangeRed", tostring(timeInPlainText)) .. ". "
                    .. Colours:ByName("Silver", "Reminder closed ")
                    .. Colours:ByName("Orange", SecondsToTime(closedTime)) .. " ago. "
                    .. Colours:ByName("Silver", self.RemindersClosed .. " reminder(s) closed.")
                    .. Colours:ByName("Silver", " Reload when safe to save your stats."))
    else
        Printing:P(Colours:ByName("Silver", "Addon data not saved for ")
                    .. Colours:ByName("OrangeRed", tostring(timeInPlainText)) .. ". "
                    .. Colours:ByName("Silver", "Reload when safe to save your stats."))
    end
end

--- Prints the reload reminder message and shows the reload button.
function ReloadReminder:PrintReminder()
    self:IntervalInformation()
    -- show an actionable button so the user can reload the UI immediately
    self:ShowReminderButton()

    -- If we haven't reloaded, keep halfing the time until the next reminder
    -- until 15 minutes, then remind every 5
    if self.ReminderInterval > 900 then 
        self.ReminderInterval = self.ReminderInterval / 2
    elseif self.ReminderInterval > 300 then 
        self.ReminderInterval = self.ReminderInterval - 300
    end
end

--- Shows the reload reminder button on screen.
function ReloadReminder:ShowReminderButton()
    if self.reloadButtonFrame and self.reloadButtonFrame:IsShown() then return end

    if not self.reloadButtonFrame then
        local frame = CreateFrame("Frame", "UHC_ReloadFrame", UIParent)
        frame:SetSize(160, 40)
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 20, 20)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            if ReloadReminder and ReloadReminder.SaveReminderButtonPosition then
                ReloadReminder:SaveReminderButtonPosition()
            end
        end)

        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints(true)
        frame.bg:SetColorTexture(0, 0, 0, 0.5)

        local btn = CreateFrame("Button", "UHC_ReloadUIButton", frame, "UIPanelButtonTemplate")
        btn:SetSize(140, 22)
        btn:SetPoint("CENTER", frame, "CENTER", 0, 0)
        btn:SetText(" [ULTRA] Reload ")
        btn:SetScript("OnClick", function()
            ReloadReminder:DoReload()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Reload the UI and save addon data", 1, 0.75, 0)
            GameTooltip:AddLine("Minimizes loss of tracked stats due to disconnect or crash", 1, 1, 1)
            GameTooltip:AddLine("Click and drag the gray border to move", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Create a close button 
        local closeBtn = CreateFrame("Button", "UHC_ReloadCloseButton", frame, "UIPanelButtonTemplate")
        closeBtn:SetSize(20, 20)
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 8, 8)
        
        local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        closeBtnText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
        closeBtnText:SetText("X")
        closeBtnText:SetTextColor(1, 1, 1, 0.8)
        
        closeBtn:SetScript("OnClick", function()
            ReloadReminder:HideReminderButton()
        end)
        closeBtn:SetScript("OnEnter", function(self)
            closeBtnText:SetTextColor(1, 0.3, 0.3, 1)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Close", 1, 1, 1)
            GameTooltip:Show()
        end)
        closeBtn:SetScript("OnLeave", function()
            closeBtnText:SetTextColor(1, 1, 1, 0.8)
            GameTooltip:Hide()
        end)

        frame.closeBtn = closeBtn
        frame.button = btn
        self.reloadButtonFrame = frame
        -- provide save/load helpers
        function self:SaveReminderButtonPosition()
            if not UltraHardcoreDB then UltraHardcoreDB = {} end
            local point, _, relPoint, x, y = self.reloadButtonFrame:GetPoint()
            UltraHardcoreDB.reloadButtonPosition = { point = point, relPoint = relPoint, x = x, y = y }
            if SaveDBData then SaveDBData('reloadButtonPosition', UltraHardcoreDB.reloadButtonPosition) end
        end

        function self:LoadReminderButtonPosition()
            if not UltraHardcoreDB then UltraHardcoreDB = {} end
            local pos = UltraHardcoreDB.reloadButtonPosition
            self.reloadButtonFrame:ClearAllPoints()
            if pos then
                self.reloadButtonFrame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
            else
                self.reloadButtonFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 20, 20)
            end
        end

        -- expose a reset helper
        _G.ResetReloadButtonPosition = function()
            if UltraHardcoreDB then UltraHardcoreDB.reloadButtonPosition = nil end
            if SaveDBData then SaveDBData('reloadButtonPosition', nil) end
            if ReloadReminder and ReloadReminder.reloadButtonFrame then
                ReloadReminder.reloadButtonFrame:ClearAllPoints()
                ReloadReminder.reloadButtonFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 20, 20)
            end
        end
    end

    -- load saved position if present
    if self.LoadReminderButtonPosition then
        self:LoadReminderButtonPosition()
    end

    self.reloadButtonFrame:Show()
end

--- Hides the reload reminder button.
function ReloadReminder:HideReminderButton()
    self:LogClose()
    if self.reloadButtonFrame then
        self.reloadButtonFrame:Hide()
    end
end

--- Updates the last reloaded and last closed timestamps to the current server time.
function ReloadReminder:Touch() 
    local stats = CharacterStats:GetCurrentCharacterStats()
    stats["LastReloadedAt"] = GetServerTime()
    stats["LastReminderClosedAt"] = stats["LastReloadedAt"]
    self.RemindersClosed = 0

end

--- Logs that the reminder was closed by updating the last closed timestamp.
function ReloadReminder:LogClose() 
    local stats = CharacterStats:GetCurrentCharacterStats()
    stats["LastReminderClosedAt"] = GetServerTime()
    self.RemindersClosed = self.RemindersClosed + 1
end

--- Performed the UI reload and updates timestamps.
function ReloadReminder:DoReload()
    self:Touch()
    self:LoadInterval() -- Reload interval from settings
    self:HideReminderButton()
    ReloadUI()
end

--- Returns the time since the last reload in seconds.
function ReloadReminder:TimeSinceSave()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]
    local serverTime = GetServerTime()
    return (serverTime - lastReload)
end

--- Returns the time since the last reminder was closed in seconds.
function ReloadReminder:TimeSinceClose()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastClosed = stats["LastReminderClosedAt"]
    local serverTime = GetServerTime()
    return (serverTime - lastClosed)
end

--- Checks the time since the last reload and shows a reminder if the interval has passed.
function ReloadReminder:CheckLastReloadTime()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local lastReload = stats["LastReloadedAt"]
    local lastClosed = stats["LastReminderClosedAt"]

    if lastClosed == nil then
        stats["LastReminderClosedAt"] = GetServerTime()
    end

    if lastReload == nil then
        stats["LastReloadedAt"] = GetServerTime()
    else
        local diff = self:TimeSinceSave()
        local closedDiff = self:TimeSinceClose()
        Printing:Debug("Last reloaded " .. SecondsToTime(diff) .. " ago")
        Printing:Debug("Last closed " .. SecondsToTime(closedDiff) .. " ago")

        if closedDiff < diff then
            diff = closedDiff
        end

        if diff > self.ReminderInterval then 
            self:PrintReminder()
        end
    end
end


-- Slash command to reset reload button position
SLASH_UHCRELOADBUTTONRESET1 = "/uhcreloadbuttonreset"
SlashCmdList.UHCRELOADBUTTONRESET = function()
    if ResetReloadButtonPosition then
        ResetReloadButtonPosition()
    end
end

local reloadReminderFrame = CreateFrame("Frame")

reloadReminderFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
reloadReminderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

reloadReminderFrame:SetScript('OnEvent', function(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        ReloadReminder:CheckLastReloadTime()
    elseif event == "PLAYER_ENTERING_WORLD" then
        --Printing:EnableDebug()
        -- Load reminder interval from settings on login
        ReloadReminder:LoadInterval()
        -- Ensure the reload button restores position/visibility after login/reload
        if ReloadReminder and ReloadReminder.reloadButtonFrame then
            -- If frame already created, try to load its position
            if ReloadReminder.LoadReminderButtonPosition then
                ReloadReminder:LoadReminderButtonPosition()
            end
        end
    end
end)

_G.ReloadReminder = ReloadReminder