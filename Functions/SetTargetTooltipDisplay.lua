function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
    tooltip:SetOwner(parent, 'ANCHOR_NONE') -- Remove default behavior
    tooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 200) -- Move up 50px
    tooltip:SetScript('OnTooltipSetUnit', function(self)
      local unit = select(2, self:GetUnit())
      if not unit then return end

      -- Hide health bar graphic under tooltip
      GameTooltipStatusBar:Hide()

      -- Modify tooltip lines
      for i = 2, self:NumLines() do
        local line = _G['GameTooltipTextLeft' .. i]
        if line then
          local text = line:GetText()
          if text and not UnitIsPlayer(unit) then
            if text:match(LEVEL) then
              line:SetText('') -- Hide line containing '??'
            end
          end
        end
      end
    end)
  end)
end
