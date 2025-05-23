-- -- Create the icon for opening the log
-- local logBookIcon = CreateFrame('Button', nil, UIParent)
-- logBookIcon:SetSize(40, 40)
-- logBookIcon:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -10, -10)
-- logBookIcon:SetNormalTexture('Interface\\Icons\\INV_Misc_Book_06') -- Example icon for log book
-- -- Tooltip for the icon
-- logBookIcon:SetScript('OnEnter', function(self)
--   GameTooltip:SetOwner(self, 'ANCHOR_TOP')
--   GameTooltip:SetText('Open Challenge Log')
--   GameTooltip:Show()
-- end)
-- logBookIcon:SetScript('OnLeave', function(self)
--   GameTooltip:Hide()
-- end)
-- -- Create the Log Book Frame (hidden by default)
-- local logBookFrame = CreateFrame('Frame', nil, UIParent)
-- logBookFrame:SetSize(400, 400) -- Size of the log
-- logBookFrame:SetPoint('CENTER', UIParent, 'CENTER')
-- logBookFrame:Hide() -- Initially hidden
-- -- Create the background for the Log Book (similar to the quest log)
-- local logBookBackground = logBookFrame:CreateTexture(nil, 'BACKGROUND')
-- logBookBackground:SetAllPoints()
-- logBookBackground:SetColorTexture(0.1, 0.1, 0.1, 0.9) -- Dark background with transparency
-- -- Title for the Log Book
-- local logBookTitle = logBookFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
-- logBookTitle:SetPoint('TOP', logBookFrame, 'TOP', 0, -10)
-- logBookTitle:SetText('Challenge Log')
-- -- Sample challenges and progress
-- local challenges = { {
--   name = 'Wolves Killed',
--   progress = 0,
--   goal = 1000,
-- }, {
--   name = 'Fully explore a zone',
--   progress = 0,
--   goal = 1,
-- }, {
--   name = 'Slay Elites - Novice',
--   progress = 1,
--   goal = 1,
-- }, {
--   name = 'Slay Elites - Journeyman',
--   progress = 1,
--   goal = 5,
-- }, {
--   name = 'Slay Elites - Veteran',
--   progress = 1,
--   goal = 10,
-- }, {
--   name = 'Reach level 5',
--   progress = 0,
--   goal = 5,
-- }, {
--   name = 'Reach level 10',
--   progress = 0,
--   goal = 10,
-- }, {
--   name = 'Reach level 20',
--   progress = 0,
--   goal = 20,
-- }, {
--   name = 'Reach level 30',
--   progress = 0,
--   goal = 30,
-- }, {
--   name = 'Reach level 40',
--   progress = 0,
--   goal = 40,
-- }, {
--   name = 'Reach level 50',
--   progress = 0,
--   goal = 50,
-- }, {
--   name = 'Reach level 60',
--   progress = 0,
--   goal = 60,
-- } }
-- -- Table to hold challenge text FontStrings
-- local challengeTextFrames = {}
-- local function GetChallengeProgress(challengeName)
--   if challengeName == 'Wolves Killed' then
--     return {
--       unit = vengeanceScore,
--       display = true,
--     }
--   elseif challengeName == 'Fully explore a zone' then
--     return {
--       unit = GetExploredZoneCount(),
--       display = false,
--     }
--   elseif string.find(challengeName, 'Slay Elites') then
--     return {
--       unit = elitesSlain,
--       display = true,
--     }
--   elseif string.find(challengeName, 'Reach level') then
--     return {
--       unit = UnitLevel('player'),
--       display = false,
--     }
--   else
--     return {
--       unit = 0,
--       display = true,
--     }
--   end
-- end
-- -- Function to update the Log Book with current challenge progress
-- local function UpdateChallengeProgress()
--   -- Clear previous challenge text
--   for _, frame in ipairs(challengeTextFrames) do
--     frame:Hide()
--   end
--   -- Add updated text for each challenge
--   local yOffset = -40
--   for _, challenge in ipairs(challenges) do
--     -- Get progress for the challenge
--     local challengeProgress = GetChallengeProgress(challenge.name)
--     -- Create or reuse a FontString for the challenge
--     local challengeText = logBookFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
--     challengeText:SetPoint('TOPLEFT', logBookFrame, 'TOPLEFT', 10, yOffset)
--     challengeText:SetFont('Fonts\\FRIZQT__.TTF', 14, 'OUTLINE')
--     challengeText:SetJustifyH('LEFT') -- Ensure left alignment
--     -- Set the text and color based on progress
--     if challengeProgress.display == true then
--       progressText = challenge.name .. ': ' .. challengeProgress.unit .. ' / ' .. challenge.goal
--     else
--       progressText = challenge.name
--     end
--     challengeText:SetText(progressText)
--     -- Set the color based on whether the challenge is complete
--     if challengeProgress.unit >= challenge.goal then
--       challengeText:SetTextColor(0, 1, 0) -- Green for complete
--     else
--       challengeText:SetTextColor(1, 1, 1) -- White for in-progress
--     end
--     -- Save the reference to the frame for later hiding
--     table.insert(challengeTextFrames, challengeText)
--     -- Update the yOffset to position the next challenge text
--     yOffset = yOffset - 30
--   end
-- end
-- -- Function to toggle the Log Book visibility
-- local function ToggleLogBook()
--   if logBookFrame:IsShown() then
--     logBookFrame:Hide()
--   else
--     UpdateChallengeProgress()
--     logBookFrame:Show()
--   end
-- end
-- -- Set the icon click to toggle the Log Book visibility
-- logBookIcon:SetScript('OnClick', ToggleLogBook)
-- -- Now, you can call UpdateChallengeProgress() from elsewhere in your addon as needed
