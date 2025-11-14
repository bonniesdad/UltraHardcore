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

      local originalAlpha = self:GetAlpha()
      self:SetAlpha(0)

      -- Delay the level line removal to ensure tooltip is fully built (this makes it so it runs last and retains information each time you hover)
      C_Timer.After(0.0, function()
        if not self:IsShown() then
          self:SetAlpha(originalAlpha or 1)
          return
        end

        local removedLine = false

        if not UnitIsPlayer(unit) then
          for i = 2, self:NumLines() do
            local line = _G['GameTooltipTextLeft' .. i]
            if line then
              local text = line:GetText()
              if text and text:match(LEVEL) then
                line:SetText(nil)
                removedLine = true
                break -- Stop after removing the level line
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

        if removedLine then
          -- Refresh tooltip to remove empty line
          self:Show()
        end

        self:SetAlpha(originalAlpha or 1)
      end)
    end)
  end
end
