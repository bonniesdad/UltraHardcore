function SetTargetTooltipDisplay(hideTargetTooltip)
  if not hideTargetTooltip then return end

  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
  end)

  -- Forcefully suppress the default status bar even if other addons or the default UI
  -- try to show it again later.
  if GameTooltipStatusBar and not GameTooltipStatusBar._UHC_HideHooked then
    GameTooltipStatusBar._UHC_HideHooked = true
    GameTooltipStatusBar:HookScript('OnShow', function(bar)
      bar:Hide()
    end)
    -- Also hide once now in case it's already visible
    GameTooltipStatusBar:Hide()
  end

  if not GameTooltip._MyAddon_UnitHooked then
    GameTooltip._MyAddon_UnitHooked = true

    local frame = GameTooltip
    frame:HookScript('OnTooltipSetUnit', function(self)
      local _, unit = self:GetUnit()
      if not unit or not UnitExists(unit) or UnitIsPlayer(unit) then return end

      -- Always hide health bar
      GameTooltipStatusBar:Hide()

      -- Immediately hide any NPC level line to avoid a one-frame flicker
      for i = 2, self:NumLines() do
        local lineFS = _G['GameTooltipTextLeft' .. i]
        if lineFS then
          local text = lineFS:GetText()
          if text and text:match(LEVEL) and not UnitIsPlayer(unit) then
            lineFS:SetText(nil)
            lineFS:SetAlpha(0)
            lineFS:SetHeight(0)
            break
          end
        end
      end

      -- Delay our full rewrite to the next frame so all other addons (including Questie)
      -- have finished writing their lines into the tooltip.
      local tooltip = self
      C_Timer.After(0, function()
        local _, delayedUnit = tooltip:GetUnit()
        if not delayedUnit or not UnitExists(delayedUnit) or UnitIsPlayer(delayedUnit) then
          return
        end

        -- Capture all current lines (including Questie), then rewrite without the level line
        local numLines = tooltip:NumLines()
        if numLines == 0 then return end

        local lines = {}
        for i = 1, numLines do
          local leftFS = _G['GameTooltipTextLeft' .. i]
          local rightFS = _G['GameTooltipTextRight' .. i]

          local leftText, rightText = nil, nil
          local lr, lg, lb = 1, 1, 1
          local rr, rg, rb = 1, 1, 1

          if leftFS then
            leftText = leftFS:GetText()
          end
          if rightFS then
            rightText = rightFS:GetText()
          end

          if leftText and leftText ~= "" then
            -- Skip the NPC level line(s), keep everything else (including Questie)
            if not (leftText:match(LEVEL) and not UnitIsPlayer(delayedUnit)) then
              lr, lg, lb = leftFS:GetTextColor()
              if rightText and rightText ~= "" then
                rr, rg, rb = rightFS:GetTextColor()
              else
                rightText, rr, rg, rb = nil, nil, nil, nil
              end
              table.insert(lines, {
                leftText = leftText, lr = lr, lg = lg, lb = lb,
                rightText = rightText, rr = rr, rg = rg, rb = rb,
              })
            end
          end
        end

        if #lines == 0 then return end

        tooltip:ClearLines()

        for idx, line in ipairs(lines) do
          if line.rightText then
            tooltip:AddDoubleLine(line.leftText, line.rightText, line.lr, line.lg, line.lb, line.rr, line.rg, line.rb)
          else
            if idx == 1 then
              tooltip:AddLine(line.leftText, line.lr, line.lg, line.lb)
            else
              tooltip:AddLine(line.leftText, line.lr, line.lg, line.lb, true)
            end
          end
        end

        -- Check if unit is tapped by another player, gray out the name line
        if UnitIsTapDenied(delayedUnit) then
          local nameLine = _G['GameTooltipTextLeft1']
          if nameLine then
            nameLine:SetTextColor(0.5, 0.5, 0.5)
          end
        end

        tooltip:Show()
      end)
    end)
  end
end
