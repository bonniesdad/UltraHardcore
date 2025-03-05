-- Create a frame to display messages
local buffMessagesFrame = CreateFrame('Frame', nil, UIParent)
buffMessagesFrame:SetSize(300, 200) -- Set the size of the frame
buffMessagesFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 10, -10) -- Position the frame at the top-left
buffMessagesFrame:Hide() -- Initially hidden
-- Create a FontString to display the buff messages
local buffMessagesText = buffMessagesFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
buffMessagesText:SetPoint('TOPLEFT', buffMessagesFrame, 'TOPLEFT', 10, -10)

buffMessagesText:SetJustifyH('LEFT') -- Ensure left alignment
-- Function to get buff messages based on stat changes
local function GetBuffMessages()
  local statMessages = {}
  local i = 1
  local message = ''

  -- Iterate through all buffs
  while true do
    local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura('player', i)

    if not name then
      break
    end

    -- Create a temporary GameTooltip to get the description
    GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')

    -- Use SetUnitAura to set the tooltip for the current buff
    GameTooltip:SetUnitAura('player', i)

    -- Show the tooltip
    GameTooltip:Show()

    -- Check the tooltip text for stat increases
    for j = 1, GameTooltip:NumLines() do
      local line = _G['GameTooltipTextLeft' .. j]:GetText()
      if line then
        if string.find(string.lower(line), 'attack power') then
          message = 'I feel more deadly!'
          statMessages['attack power'] = message
        elseif string.find(string.lower(line), 'haste') then
          message = 'I feel faster!'
          statMessages['Haste'] = message
        elseif string.find(string.lower(line), 'armor') then
          message = 'I feel tougher!'
          statMessages['Stamina'] = message
        elseif string.find(string.lower(line), 'stamina') then
          message = 'I feel sturdier!'
          statMessages['Stamina'] = message
        elseif string.find(string.lower(line), 'spirit') then
          message = 'I feel confident!'
          statMessages['Intellect'] = message
        elseif string.find(string.lower(line), 'intellect') then
          message = 'I feel smarter!'
          statMessages['Intellect'] = message
        elseif string.find(string.lower(line), 'strength') then
          message = 'I feel stronger!'
          statMessages['Strength'] = message
        end
      end
    end

    -- Hide the tooltip after processing
    GameTooltip:Hide()

    i = i + 1
  end

  return statMessages
end

-- Function to update the display with the current buff messages
function UpdateBuffMessages()
  local buffStats = GetBuffMessages()
  local messageText = ''

  -- Build the string of all buffs affecting stats
  for stat, message in pairs(buffStats) do
    messageText = messageText .. message .. '\n'
  end

  -- Display the messages in the frame
  if messageText ~= '' then
    buffMessagesText:SetText(messageText)
    buffMessagesText:SetTextColor(1, 1, 0)
    buffMessagesFrame:Show()
  else
    buffMessagesFrame:Hide() -- Hide if no messages
  end
end
