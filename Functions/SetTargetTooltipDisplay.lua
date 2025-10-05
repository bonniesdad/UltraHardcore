function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
    tooltip:SetOwner(parent, 'ANCHOR_NONE')
    tooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 200)
  end)

  -- Only hook once
  if not GameTooltip._MyAddon_UnitHooked then
    GameTooltip._MyAddon_UnitHooked = true

    GameTooltip:HookScript('OnTooltipSetUnit', function(self)
      local _, unit = self:GetUnit()
      if not unit then return end

      -- Hide health bar graphic under tooltip
      GameTooltipStatusBar:Hide()

      -- Remove level line but leave Questie / other addon lines intact
      for i = 2, self:NumLines() do
        local line = _G['GameTooltipTextLeft' .. i]
        if line then
          local text = line:GetText()
          if text and text:match('^Level') and not UnitIsPlayer(unit) then
            line:SetText('') -- Remove level display for NPCs and enemies
          end
        end
      end
    end)
  end
end
