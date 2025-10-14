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
            -- Check if this line contains level information by looking for level patterns
            -- This works for all languages: "Level 60", "Stufe 60", "Niveau 60", etc.
            if text:match('^%w+%s+%d+') or text:match('^%d+%s+%w+') then
              -- Additional check: if it's a level line, it usually contains a number followed by text
              -- or starts with a word followed by a number
              local level = UnitLevel(unit)
              if level and level > 0 and (text:match(tostring(level)) or text:match('^%w+%s+' .. level)) then
                line:SetText('') -- Remove level display for NPCs and enemies
              end
            end
          end
        end
      end
    end)
  end)
end
