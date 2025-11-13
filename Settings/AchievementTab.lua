-- Achievement Tab Content
-- This file contains the UI elements and functionality for the Achievement tab

-- Initialize Achievement Tab
function InitializeAchievementTab()
  -- Check if tabContents[3] exists
  if not tabContents or not tabContents[3] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[3].initialized then return end

  -- Mark as initialized
  tabContents[3].initialized = true

  -- Achievements Tab Content (empty for now)
  local achievementsTitle = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  achievementsTitle:SetPoint('CENTER', tabContents[3], 'CENTER', 0, 10)
  achievementsTitle:SetText('Coming In Phase 3!')
  achievementsTitle:SetFontObject('GameFontNormalHuge')

  -- Description line under the title (same as X Found placeholder)
  local achievementsDesc = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  achievementsDesc:SetPoint('TOP', achievementsTitle, 'BOTTOM', 0, -16)
  achievementsDesc:SetWidth(460)
  achievementsDesc:SetJustifyH('CENTER')
  achievementsDesc:SetNonSpaceWrap(true)
  achievementsDesc:SetText("Achievements are currently under development.")
  -- 

  local achievementsDesc2 = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  achievementsDesc2:SetPoint('TOP', achievementsDesc, 'BOTTOM', 0, -8)
  achievementsDesc2:SetWidth(460)
  achievementsDesc2:SetJustifyH('CENTER')
  achievementsDesc2:SetNonSpaceWrap(true)
  achievementsDesc2:SetText("You can try out the BETA version by downloading the addon called\n'Hardcore Achievements By Chills'\nfrom CurseForge.")
end
