local usingExperimentalTooltip = true

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

      if not usingExperimentalTooltip then

        -- Modify tooltip lines
        for i = 2, self:NumLines() do
          local line = _G['GameTooltipTextLeft' .. i]
          if line then
            local text = line:GetText()
            if text and text:match('^Level') and not UnitIsPlayer(unit) then
              line:SetText('') -- Remove level display for NPCs and enemies
            end
          end
        end

      else -- usingExperimentalTooltip

        -- Leave friendly NPC unit info alone.
        if UnitIsFriend(unit, "player") and not UnitIsPlayer(unit) then
          return
        end

        -- Append the guild name for players.
        if UnitIsPlayer(unit) then
          local guildName = GetGuildInfo(unit)
          if guildName then
            local line1 = _G['GameTooltipTextLeft1']
            line1:SetText(line1:GetText() .. ' <' .. guildName .. '>')
          end
          return
        end

        -- If we get here, we know the unit is an enemy NPC.

        -- Modify tooltip lines.
        for i = 2, self:NumLines() do
          local line = _G['GameTooltipTextLeft' .. i]
          if line then

            local text = line:GetText()
            local pattern = "^Level%s+%d+%s*"
            if text and text:match(pattern) then

              -- Go back to line 1 and color the mob's name according to its difficulty.
              local color = GetQuestDifficultyColor(UnitLevel(unit))
              local hex6 = string.format("%02x%02x%02x", 255*color.r, 255*color.g, 255*color.b)
              local line1 = _G['GameTooltipTextLeft1']
              line1:SetText("|cFF" .. hex6 .. line1:GetText() .. "|r")

              -- Remove "Level N" from the current line.
              line:SetText(text:gsub(pattern, ""))

            elseif text and text:match("^Level%s+%?%?%s*") then

              -- Go back to line 1 and color the mob's name red.
              local hex6 = "ff0000"
              local line1 = _G['GameTooltipTextLeft1']
              line1:SetText("|cFF" .. hex6 .. line1:GetText() .. "|r")

            end
          end
        end

      end -- usingExperimentalTooltip

    end)
  end)

end
