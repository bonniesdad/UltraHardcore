function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
    tooltip:SetOwner(parent, 'ANCHOR_NONE')
    tooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 200)
  end)

  if not GameTooltip._MyAddon_UnitHooked then
    GameTooltip._MyAddon_UnitHooked = true

    local frame = GameTooltip
    frame:HookScript('OnTooltipSetUnit', function(self)
      local _, unit = self:GetUnit()
      if not unit then return end

      -- Hide health bar
      GameTooltipStatusBar:Hide()

      for i = 2, self:NumLines() do
        local line = _G['GameTooltipTextLeft' .. i]
        if line then
           -- Cache the original font size
          if not line._defaultFontHeight then
            line._defaultFontHeight = math.ceil(select(2, line:GetFont()))
          end

          local text = line:GetText()
          if text then
            -- Optional approaches to pattern match specifically lines that say "Level ..." or "Level ??"
            --local levelPatternNumber = string.format("^%s %%d+.*$", LEVEL) -- General mobs that show level
            --local levelPatternQuestionMark = string.format("^%s %%%%?%%%%?.*$", LEVEL) -- Mobs that show ??
            --if text:match(levelPatternNumber) or text:match(levelPatternQuestionMark) and not UnitIsPlayer(unit) then
            if text:match(LEVEL) and not UnitIsPlayer(unit) then
              line:SetTextHeight(1)
              line:SetAlpha(0)
            else -- ensure we reset it for the subsequent lines
              line:SetTextHeight(line._defaultFontHeight)
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
