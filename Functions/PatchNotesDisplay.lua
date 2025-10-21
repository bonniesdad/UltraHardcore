-- Reusable Patch Notes Display Component
-- This component can be used in multiple places (version dialog, settings info tab, etc.)

function CreatePatchNotesDisplay(parent, width, height, xOffset, yOffset)
  -- Create scrollable frame for patch notes
  local patchNotesScrollFrame = CreateFrame('ScrollFrame', nil, parent, 'UIPanelScrollFrameTemplate')
  patchNotesScrollFrame:SetSize(width, height)
  patchNotesScrollFrame:SetPoint('TOPLEFT', parent, 'TOPLEFT', xOffset, yOffset)
  
  -- Create scroll child frame
  local patchNotesScrollChild = CreateFrame('Frame', nil, patchNotesScrollFrame)
  patchNotesScrollChild:SetSize(width, height)
  patchNotesScrollFrame:SetScrollChild(patchNotesScrollChild)

  -- Helper function to create properly formatted bullet point text
  local function createBulletText(parent, text, yOffset, fontSize, textColor)
    -- Simple approach: detect indentation and apply consistent formatting
    local indentLevel = 0
    local cleanText = text
    
    -- Count leading spaces
    local spaces = string.match(text, "^%s*")
    if spaces then
      indentLevel = math.floor(#spaces / 2) -- Every 2 spaces = 1 level
    end
    
    -- Determine formatting based on indentation
    local indent, bulletStyle
    if indentLevel == 0 then
      indent = 10
      bulletStyle = "•"
    elseif indentLevel == 1 then
      indent = 30
      bulletStyle = "-"
    else
      indent = 50
      bulletStyle = "▪"
    end
    
    -- Simple approach: remove leading spaces and bullets manually
    -- cleanText = text
    -- Remove leading spaces
    -- cleanText = string.gsub(cleanText, "^%s+", "")
    -- Remove any bullet character at the start
    -- cleanText = string.gsub(cleanText, "^[•◦▪-*+]%s*", "")
    -- Add our consistent bullet
    -- cleanText = bulletStyle .. " " .. cleanText
    cleanText = text
    
    -- Calculate text width based on indentation
    local textWidth = width - indent
    
    local textFrame = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    textFrame:SetPoint('TOPLEFT', parent, 'TOPLEFT', indent, yOffset)
    textFrame:SetWidth(textWidth)
    textFrame:SetJustifyH('LEFT')
    local font, _, flags = textFrame:GetFont()
    textFrame:SetFont(font, fontSize, flags)
    textFrame:SetTextColor(textColor[1], textColor[2], textColor[3])
    textFrame:SetText(cleanText)
    return textFrame
  end

  -- Generate patch notes content
  local function generatePatchNotes()
    local yOffset = 0
    
    for i, patch in ipairs(PATCH_NOTES) do
      -- Version header
      local versionHeader = patchNotesScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      versionHeader:SetPoint('TOPLEFT', patchNotesScrollChild, 'TOPLEFT', 0, yOffset)
      versionHeader:SetWidth(width)
      versionHeader:SetJustifyH('LEFT')
      local font, _, flags = versionHeader:GetFont()
      versionHeader:SetFont(font, 14, flags)
      versionHeader:SetTextColor(1, 1, 0)
      versionHeader:SetText('Version ' .. patch.version .. ' (' .. patch.date .. ')')
      
      -- Calculate actual height of version header
      local headerHeight = versionHeader:GetStringHeight()
      yOffset = yOffset - headerHeight - 12
      
      -- Patch notes with improved bullet formatting
      for j, note in ipairs(patch.notes) do
        -- Add extra gap before main bullet points (level 0)
        local spaces = string.match(note, "^%s*")
        local indentLevel = spaces and math.floor(#spaces / 2) or 0
        if indentLevel == 0 and j > 1 then
          yOffset = yOffset - 8 -- Extra gap before main bullet points
        end
        
        local noteText = createBulletText(patchNotesScrollChild, note, yOffset, 13, {0.9, 0.9, 0.9})
        
        -- Calculate actual height of note text (handles wrapping)
        local noteHeight = noteText:GetStringHeight()
        yOffset = yOffset - noteHeight - 3
      end
      
      -- Add spacing between versions
      yOffset = yOffset - 12
    end
    
    -- Update scroll child height based on content
    patchNotesScrollChild:SetHeight(math.max(height, math.abs(yOffset) + 20))
  end
  
  generatePatchNotes()
  
  return patchNotesScrollFrame
end
