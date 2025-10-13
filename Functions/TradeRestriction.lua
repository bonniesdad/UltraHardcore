local frame = CreateFrame('Frame')

frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')
frame:RegisterEvent('MAIL_INBOX_UPDATE')

frame:SetScript('OnEvent', function(self, event)
  if GLOBAL_SETTINGS.guildSelfFound then
    if event == 'MAIL_INBOX_UPDATE' then
      for i = GetInboxNumItems(), 1, -1 do
        local packageIcon,
          stationeryIcon,
          sender,
          subject,
          money,
          CODAmount,
          daysLeft,
          hasItem,
          wasRead,
          wasReturned,
          textCreated,
          canReply,
          isGM
        = GetInboxHeaderInfo(i)

        if sender and not isGM then
          local isGuildMember = false

          for j = 1, GetNumGuildMembers() do
            local guildName = GetGuildRosterInfo(j)

            if guildName and guildName == sender then
              isGuildMember = true
              break
            end
          end

          if not isGuildMember then
            ReturnInboxItem(i) -- Deletes mail from non-guild members
            SendChatMessage('[UHC] —  Mail from non-guild members is blocked.', 'EMOTE')
          end
        end
      end
    end
    if event == 'TRADE_SHOW' then
      local targetName = UnitName('NPC') -- Gets the trade target
      if targetName and not IsInGuild() then
        SendChatMessage('[UHC] — Trade cancelled: You are not in my guild.', 'EMOTE')
        CancelTrade()
        return
      end

      local numGuildMembers = GetNumGuildMembers()
      for i = 1, numGuildMembers do
        local name = GetGuildRosterInfo(i)
        if name and name == targetName then
          return -- Allow trade
        end
      end

      SendChatMessage('[UHC] — Trade cancelled: You are not in my guild.', 'EMOTE')
      CancelTrade()
    elseif event == 'AUCTION_HOUSE_SHOW' then
      SendChatMessage('[UHC] — I cannot use the Auction House.', 'EMOTE')
      CloseAuctionHouse()
    end
  end
end)
