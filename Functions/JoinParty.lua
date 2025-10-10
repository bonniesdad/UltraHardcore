local frame = CreateFrame('Frame')

frame:RegisterEvent('GROUP_JOINED')

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'GROUP_JOINED' then
    StaticPopupDialogs['ULTRA_HARDCORE_WARNING'] = {
      text = 'You should only do dungeons and raids with other players who are using the Ultra Hardcore addon. To join a group on non ultimates is putting them in increased danger and can be seen as griefing. Would you like to disable the addon?',
      button1 = 'Disable Addon',
      button2 = 'No, Keep Addon On',
      OnAccept = function()
        local chatType = IsInRaid() and 'RAID' or 'PARTY'
        SendChatMessage(
          '!! INFO !! I have disabled the Ultra Hardcore addon for this group.',
          chatType
        )
        SaveDBData('GLOBAL_SETTINGS', {
          hidePlayerFrame = false,
          hideMinimap = false,
          hideBuffFrame = false,
          hideTargetFrame = false,
          hideTargetTooltip = false,
          hideQuestFrame = false,
          showTunnelVision = false,
          showDazedEffect = false,
          showCritScreenMoveEffect = false,
          showIncomingDamageEffect = false,
          petsDiePermanently = false,
          hideGroupHealth = false,
          hideActionBars = false,
        })
        ReloadUI()
      end,
      OnCancel = function()
        local chatType = IsInRaid() and 'RAID' or 'PARTY'
        local characterName = UnitName("player")

        if(characterName == "Ultrapikaboo") then
          -- I tested this with my name to make sure it works :D
          SendChatMessage(
            '!! BEWARE !! I am using the Ultra Hardcore addon. If you do not give me loot priority, minute thirty ad!',
            chatType
          )
        else
          SendChatMessage(
            '!! BEWARE !! I am using the Ultra Hardcore addon. The chances of my demise are much higher. You have been warned.',
            chatType
          )
        end
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
    }
    StaticPopup_Show('ULTRA_HARDCORE_WARNING')
  end
end)
