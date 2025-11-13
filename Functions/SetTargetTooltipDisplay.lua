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
      local levelLineFound = false
      for i = 2, self:NumLines() do
        if levelLineFound then break end
        
        local line = _G['GameTooltipTextLeft' .. i]
        if line then
           -- Cache the original font size
          if not line._defaultFontHeight then
            line._defaultFontHeight = math.ceil(select(2, line:GetFont()))
          end

          local text = line:GetText()
          if text then
            if text:match(LEVEL) and not UnitIsPlayer(unit) then
              -- Cache original height if not already cached
              if not line._defaultHeight then
                line._defaultHeight = line:GetHeight()
              end
              -- Collapse the line frame immediately to eliminate gap
              line:SetHeight(0)
              line:SetAlpha(0)
              levelLineFound = true
              C_Timer.After(0, function()
                line:SetText(nil)
                -- Restore height after text is removed (tooltip will recalculate)
                if line._defaultHeight then
                  line:SetHeight(line._defaultHeight)
                end
              end)
            else -- ensure we reset it for the subsequent lines
              if line._defaultFontHeight then
                line:SetTextHeight(line._defaultFontHeight)
              end
              if line._defaultHeight then
                line:SetHeight(line._defaultHeight)
              end
              line:SetAlpha(1)
            end
          end
        end
      end
      -- Refresh tooltip to remove empty line
      self:Show()
    end)
  end
end
