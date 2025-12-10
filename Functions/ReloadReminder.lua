local ReloadReminder = {
    ReminderInterval = 3600,
}

function ReloadReminder:PrintReminder()
    local elapsedTime = self:TimeSinceSave()
    local timeInPlainText = SecondsToTime(elapsedTime)
    Printing:P(Colours:ByName("Silver", "Addon data not saved for ")
                .. Colours:ByName("Cyan", tostring(timeInPlainText))
                .. Colours:ByName("Silver", ".  Reload when safe to save your stats."))

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

function ReloadReminder:HideReminderButton()
    if self.reloadButtonFrame then
        self.reloadButtonFrame:Hide()
    end
end

function ReloadReminder:Touch() 
    local stats = CharacterStats:GetCurrentCharacterStats()
    stats["LastReloadedAt"] = GetServerTime()
end

function ReloadReminder:DoReload()
    self:Touch()
    self.ReminderInterval = 3600
    self:HideReminderButton()
    ReloadUI()
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