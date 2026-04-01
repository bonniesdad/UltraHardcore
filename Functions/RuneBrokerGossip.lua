local RUNE_BROKER_NAMES = { ['Rune Broker'] = true }

local frame = CreateFrame('Frame')
frame:RegisterEvent('GOSSIP_SHOW')
frame:SetScript('OnEvent', function()
  local name = UnitName('npc')
  if name and RUNE_BROKER_NAMES[name] then
    HideUIPanel(GossipFrame)
    DEFAULT_CHAT_FRAME:AddMessage(
      '|cFFFF0000[ULTRA]|r You cannot purchase runes from the Rune Broker.',
      1,
      0,
      0
    )
  end
end)
