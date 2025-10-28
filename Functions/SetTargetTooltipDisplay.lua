function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip)
    tooltip:SetScript('OnTooltipSetUnit', function(self)
      local unit = select(2, self:GetUnit())
      if not unit then return end

      -- Hide health bar graphic under tooltip
      GameTooltipStatusBar:Hide()

      -- Check if unit is tapped by another player and in combat, modify first line (name) color
      if UnitIsTapDenied(unit) then
        local nameLine = _G['GameTooltipTextLeft1']
        if nameLine then
          nameLine:SetTextColor(0.5, 0.5, 0.5) -- Gray color
        end
      end

      -- Modify tooltip lines
      for i = 2, self:NumLines() do
        local line = _G['GameTooltipTextLeft' .. i]
        if line then
          local text = line:GetText()
          if text and not UnitIsPlayer(unit) then
            if text:match(LEVEL) then
              line:SetText('')
            end
          end
        end
      end
    end)
  end)
end
