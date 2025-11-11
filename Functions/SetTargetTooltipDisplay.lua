function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
  end)

  if not GameTooltip._MyAddon_UnitHooked then
    GameTooltip._MyAddon_UnitHooked = true

    local frame = GameTooltip
    frame:HookScript('OnTooltipSetUnit', function(self)
      local _, unit = self:GetUnit()
      if not unit then return end

      -- Hide health bar
      GameTooltipStatusBar:Hide()

      -- Delay the level line removal to ensure tooltip is fully built (this makes it so it runs last and retains information each time you hover)
      C_Timer.After(0.0, function()
        for i = 2, self:NumLines() do
          local line = _G['GameTooltipTextLeft' .. i]
          if line then
            local text = line:GetText()
            if text then
              if text:match(LEVEL) and not UnitIsPlayer(unit) then
                line:SetText(nil)
                break -- Stop after removing the level line
              end
            end
          end
        end
        -- Refresh tooltip to remove empty line
        self:Show()
      end)
    end)
  end
end
