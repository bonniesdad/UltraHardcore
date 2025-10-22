-- Global variables for radio button management
local radioButtons = {}

-- Helper function to format numbers with comma separators
local function formatNumberWithCommas(number)
	if type(number) ~= "number" then
		number = tonumber(number) or 0
	end

	-- Handle negative numbers
	local isNegative = number < 0
	if isNegative then
		number = -number
	end

	-- Convert to string and add commas
	local formatted = tostring(math.floor(number))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end

	-- Add back negative sign if needed
	if isNegative then
		formatted = "-" .. formatted
	end

	return formatted
end

-- Layout constants for consistent spacing
local LAYOUT = {
	SECTION_HEADER_HEIGHT = 28,
	ROW_HEIGHT = 25,
	HEADER_TO_CONTENT_GAP = 5,
	SECTION_SPACING = 10,
	CONTENT_INDENT = 20,
	ROW_INDENT = 12,
	CONTENT_PADDING = 8,
}

-- Helper function to calculate consistent positioning
local function calculatePosition(sectionIndex, rowIndex)
	-- Calculate cumulative height of previous sections
	local previousSectionsHeight = 0
	for i = 1, sectionIndex - 1 do
		previousSectionsHeight = previousSectionsHeight + LAYOUT.SECTION_HEADER_HEIGHT + LAYOUT.HEADER_TO_CONTENT_GAP
		if i == 1 then
			previousSectionsHeight = previousSectionsHeight + (5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Lowest Health
		elseif i == 2 then
			previousSectionsHeight = previousSectionsHeight + (4 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Enemies Slain
		elseif i == 3 then
			previousSectionsHeight = previousSectionsHeight + (5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Survival
		end
		previousSectionsHeight = previousSectionsHeight + LAYOUT.SECTION_SPACING
	end

	local headerY = -5 - previousSectionsHeight
	local contentY = headerY - LAYOUT.SECTION_HEADER_HEIGHT - LAYOUT.HEADER_TO_CONTENT_GAP
	local rowY = contentY - LAYOUT.CONTENT_PADDING - (rowIndex - 1) * LAYOUT.ROW_HEIGHT
	return headerY, contentY, rowY
end

-- Helper function to determine if a radio button should be checked
local function shouldRadioBeChecked(settingName, settings)
	if settings[settingName] ~= nil then
		-- Use the actual setting value
		return settings[settingName]
	else
		-- Apply default behavior based on the setting
		-- These default to true (show unless explicitly false)
		if
			settingName == "showMainStatisticsPanelLevel"
			or settingName == "showMainStatisticsPanelLowestHealth"
			or settingName == "showMainStatisticsPanelEnemiesSlain"
			or settingName == "showMainStatisticsPanelDungeonsCompleted"
			or settingName == "showMainStatisticsPanelHighestCritValue"
			or settingName == "showMainStatisticsPanelMaxTunnelVisionOverlayShown"
		then
			return true
		else
			-- These default to false (hide unless explicitly true)
			return false
		end
	end
end

local settingsCheckboxOptions = {
	{
		-- Lite Preset Settings
		name = "UHC Player Frame",
		dbSettingsValueName = "hidePlayerFrame",
		tooltip = "Minimalistic player frame to hide own health",
	},
	{
		name = "Tunnel Vision",
		dbSettingsValueName = "showTunnelVision",
		tooltip = "The screen gets darker as you get closer to death",
	},
	{
		-- Recommended Preset Settings
		name = "Hide Target Frame",
		dbSettingsValueName = "hideTargetFrame",
		tooltip = "Target frame is not visible, so you can't see the target's health or level",
	},
	{
		name = "Hide Target Tooltips",
		dbSettingsValueName = "hideTargetTooltip",
		tooltip = "Target tooltips are not visible, so you can't see the target's health or level",
	},
	{
		name = "Disable Nameplates",
		dbSettingsValueName = "disableNameplateHealth",
		tooltip = "Turns off nameplates, hiding healthbars above units",
	},
	{
		name = "Show Dazed effect",
		dbSettingsValueName = "showDazedEffect",
		tooltip = "A blue blur effect appears around your character when dazed",
	},
	{
		name = "UHC Party Frames",
		dbSettingsValueName = "hideGroupHealth",
		tooltip = "Party healthbars are hidden and replaced with a custom health indicator",
	},
	{
		name = "Hide Minimap",
		dbSettingsValueName = "hideMinimap",
		tooltip = "Makes gathering resources a lot more challenging by hiding the minimap",
	},
	{
		name = "UHC Breath Indicator",
		dbSettingsValueName = "hideBreathIndicator",
		tooltip = "Replace the breath bar with a increasingly red screen overlay when underwater",
	},
	{
		-- Ultra Preset Settings
		name = "Pets Die Permanently",
		dbSettingsValueName = "petsDiePermanently",
		tooltip = "Pets can't be resurrected when they are killed",
	},
	{
		name = "Hide Action Bars when not resting",
		dbSettingsValueName = "hideActionBars",
		tooltip = "Hide action bars when not resting or near a campfire",
	},
	{
		name = "Tunnel Vision Covers Everything",
		dbSettingsValueName = "tunnelVisionMaxStrata",
		tooltip = "Tunnel Vision covers all UI elements",
	},
	{
		-- Experimental Preset Settings
		name = "UHC Incoming Crit Effect",
		dbSettingsValueName = "showCritScreenMoveEffect",
		tooltip = "A red screen rotation effect appears when you take a critical hit",
	},
	{
		name = "UHC Full Health Indicator",
		dbSettingsValueName = "showFullHealthIndicator",
		tooltip = "The edges of the screen glow when you are at full health",
	},
	{
		name = "UHC Incoming Damage Effect",
		dbSettingsValueName = "showIncomingDamageEffect",
		tooltip = "Various screen effects on incoming damage",
	},
	{
		name = "UHC Incoming Healing Effect",
		dbSettingsValueName = "showHealingIndicator",
		tooltip = "Gold glow on the edges of the screen when you are healed",
	},
	{
		name = "First Person Camera",
		dbSettingsValueName = "setFirstPersonCamera",
		tooltip = "Play in first person mode, allows to look around for briew records of time",
	},
	{},
	{
		name = "Show Friendly Health Icons",
		dbSettingsValueName = "showFriendlyNameplateIcons",
		tooltip = "When out in the world, show health indicators over friendly players",
	},
	{
		-- Misc Settings (no preset button)
		name = "On Screen Statistics",
		dbSettingsValueName = "showOnScreenStatistics",
		tooltip = "Show important UHC statistics on the screen at all times",
	},
	{
		name = "Announce Level Up to Guild",
		dbSettingsValueName = "announceLevelUpToGuild",
		tooltip = "Announces level ups to guild chat every 10th level",
	},
	{
		name = "Hide UI Error Messages",
		dbSettingsValueName = "hideUIErrors",
		tooltip = 'Hide error messages that appear on screen (like "Target is too far away")',
	},
	{
		name = "Show Clock Even When Map is Hidden",
		dbSettingsValueName = "showClockEvenWhenMapHidden",
		tooltip = "If Hide Minimap is enabled, keep the clock on display instead of hiding it",
	},
	{
		name = "Announce Party Deaths on Group Join",
		dbSettingsValueName = "announcePartyDeathsOnGroupJoin",
		tooltip = "Automatically announce party death statistics when joining a group",
	},
	{
		name = "Announce Dungeons Completed on Group Join",
		dbSettingsValueName = "announceDungeonsCompletedOnGroupJoin",
		tooltip = "Automatically announce dungeons completed statistics when joining a group",
	},
	{
		name = "Buff Bar on Resource Bar",
		dbSettingsValueName = "buffBarOnResourceBar",
		tooltip = "Position player buff bar on top of the custom resource bar",
	},
	{
		name = "Highest Crit Appreciation Soundbite",
		dbSettingsValueName = "newHighCritAppreciationSoundbite",
		tooltip = "Play a soundbite when you achieve a new highest crit value",
	},
	{
		name = "Party Death Soundbite",
		dbSettingsValueName = "playPartyDeathSoundbite",
		tooltip = "Play a soundbite when a party member dies",
	},
	{
		name = "Player Death Soundbite",
		dbSettingsValueName = "playPlayerDeathSoundbite",
		tooltip = "Play a soundbite when you die",
	},
	{
		name = "Spooky Tunnel Vision",
		dbSettingsValueName = "spookyTunnelVision",
		tooltip = "Use Halloween-themed tunnel vision overlay for ultra spooky experience",
	},
	{
		name = "Roach Hearthstone In Party Combat",
		dbSettingsValueName = "roachHearthstoneInPartyCombat",
		tooltip = "Show a roach overlay on screen when using hearthstone whilst a party member is in combat",
	},
}

local presets = {
	{
		-- Preset 1: Lite
		hidePlayerFrame = true,
		hideMinimap = false,
		hideTargetFrame = false,
		hideTargetTooltip = false,
		showTunnelVision = true,
		tunnelVisionMaxStrata = false,
		showDazedEffect = false,
		showCritScreenMoveEffect = false,
		hideActionBars = false,
		hideGroupHealth = false,
		petsDiePermanently = false,
		showFullHealthIndicator = false,
		disableNameplateHealth = false,
		showIncomingDamageEffect = false,
		showHealingIndicator = false,
		hideBreathIndicator = false,
		setFirstPersonCamera = false,
	},
	{
		-- Preset 2: Recommended
		hidePlayerFrame = true,
		hideMinimap = true,
		hideTargetFrame = true,
		hideTargetTooltip = true,
		showTunnelVision = true,
		tunnelVisionMaxStrata = false,
		showDazedEffect = true,
		hideGroupHealth = true,
		showCritScreenMoveEffect = false,
		hideActionBars = false,
		petsDiePermanently = false,
		showFullHealthIndicator = false,
		disableNameplateHealth = true,
		showIncomingDamageEffect = false,
		showHealingIndicator = false,
		hideBreathIndicator = true,
		setFirstPersonCamera = false,
	},
	{
		-- Preset 3: Ultra
		hidePlayerFrame = true,
		hideMinimap = true,
		hideTargetFrame = true,
		hideTargetTooltip = true,
		showTunnelVision = true,
		tunnelVisionMaxStrata = true,
		showDazedEffect = true,
		hideGroupHealth = true,
		hideBreathIndicator = true,
		petsDiePermanently = true,
		showCritScreenMoveEffect = false,
		hideActionBars = true,
		showFullHealthIndicator = false,
		disableNameplateHealth = true,
		showIncomingDamageEffect = false,
		showHealingIndicator = false,
		setFirstPersonCamera = false,
		newHighCritAppreciationSoundbite = true,
	},
}

-- Temporary settings storage and initialization function
local tempSettings = {}

local function initializeTempSettings()
	-- Copy current GLOBAL_SETTINGS to temporary storage
	for key, value in pairs(GLOBAL_SETTINGS) do
		tempSettings[key] = value
	end

	-- Ensure all radio button settings are initialized with their correct values
	for settingName, _ in pairs(radioButtons) do
		if tempSettings[settingName] == nil then
			tempSettings[settingName] = shouldRadioBeChecked(settingName, GLOBAL_SETTINGS)
		end
	end
end

local settingsFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
settingsFrame:SetSize(560, 640)
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)
settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 30) -- Moved up by 30 pixels from center
settingsFrame:Hide()
settingsFrame:SetFrameStrata("DIALOG") -- Higher layer priority to appear above pet action bar
settingsFrame:SetFrameLevel(15) -- Higher level to ensure it's above pet action bar
settingsFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 64,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

local titleBar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
titleBar:SetSize(560, 50) -- Increased height for header
titleBar:SetPoint("TOP", settingsFrame, "TOP")
titleBar:SetFrameStrata("DIALOG") -- Higher layer priority
titleBar:SetFrameLevel(20) -- Ensure it's above the main frame and tabs
titleBar:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 64,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
titleBar:SetBackdropColor(0, 0, 0, 1) -- Pure black background, fully opaque
titleBar:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create title image instead of text
local settingsTitleImage = titleBar:CreateTexture(nil, "OVERLAY")
settingsTitleImage:SetSize(300, 40) -- Adjust size to fit nicely in title bar
settingsTitleImage:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
settingsTitleImage:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\ultra-hc-title.png")
settingsTitleImage:SetTexCoord(0, 1, 0, 1) -- Use full texture
-- Create proper binder tabs that overlap the main frame
local tabButtons = {}
tabContents = {}
local activeTab = 1

-- Create proper folder tabs with angled edges
local function createTabButton(text, index)
	local button = CreateFrame("Button", nil, settingsFrame, "BackdropTemplate")
	button:SetSize(110, 35)
	button:SetPoint("TOP", settingsFrame, "TOP", (index - 3) * 110, -45) -- Position below title bar
	-- Create the main tab background with proper folder tab shape
	button:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 64,
		edgeSize = 16,
		insets = {
			left = 4,
			right = 4,
			top = 4,
			bottom = 4,
		},
	})

	-- Set the text
	local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	buttonText:SetPoint("CENTER", button, "CENTER", 0, -2)
	buttonText:SetText(text)

	-- Set up click handler
	button:SetScript("OnClick", function()
		-- Hide all tab contents
		for i, content in ipairs(tabContents) do
			content:Hide()
		end

		-- Reset all tab button appearances
		for i, tabButton in ipairs(tabButtons) do
			tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
			tabButton:SetAlpha(0.8)
		end

		-- Show selected tab content and highlight button
		tabContents[index]:Show()
		button:SetBackdropBorderColor(1, 1, 0)
		button:SetAlpha(1.0)
		activeTab = index

		-- Initialize X Found Mode tab if it's being shown
		if index == 4 and InitializeXFoundModeTab then
			InitializeXFoundModeTab()
		end
	end)

	-- Set initial appearance
	button:SetBackdropBorderColor(0.5, 0.5, 0.5)
	button:SetAlpha(0.8)

	return button
end

-- Create tab buttons
tabButtons[1] = createTabButton("Statistics", 1)
tabButtons[2] = createTabButton("Settings", 2)
tabButtons[5] = createTabButton("Achievements", 3)
tabButtons[3] = createTabButton("X Found Mode", 4)
tabButtons[4] = createTabButton("Info", 5)

-- Create tab content frames
local function createTabContent(index)
	local content = CreateFrame("Frame", nil, settingsFrame)
	content:SetSize(520, 540)
	content:SetPoint("TOP", settingsFrame, "TOP", 0, -50) -- Positioned below tabs
	content:Hide()
	return content
end

tabContents[1] = createTabContent(1) -- Statistics tab
tabContents[2] = createTabContent(2) -- Settings tab
tabContents[3] = createTabContent(3) -- Achievements tab
tabContents[4] = createTabContent(4) -- Self Found tab
tabContents[5] = createTabContent(5) -- Info tab
-- Statistics Tab Content - Full size scrollable frame
local statsFrame = CreateFrame("Frame", nil, tabContents[1], "BackdropTemplate")
statsFrame:SetSize(500, 490) -- Back to original height
statsFrame:SetPoint("TOP", tabContents[1], "TOP", 0, -55) -- Moved up 10px
statsFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 64,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

-- Create scroll frame for statistics content
local statsScrollFrame = CreateFrame("ScrollFrame", nil, statsFrame, "UIPanelScrollFrameTemplate")
statsScrollFrame:SetSize(340, 460)
statsScrollFrame:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 10, -10)
statsScrollFrame:SetPoint("BOTTOMRIGHT", statsFrame, "BOTTOMRIGHT", -2, 10)

-- Create scroll child frame
local statsScrollChild = CreateFrame("Frame", nil, statsScrollFrame)
statsScrollChild:SetSize(500, 1100) -- Increased height to accommodate proper bottom spacing for XP section
statsScrollFrame:SetScrollChild(statsScrollChild)

-- Create modern WoW-style lowest health section (no accordion functionality)
local lowestHealthHeader = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
lowestHealthHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
lowestHealthHeader:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", 0, -5)

-- Modern WoW row styling with rounded corners and greyish background
lowestHealthHeader:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
lowestHealthHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
lowestHealthHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create header text
local lowestHealthLabel = lowestHealthHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthLabel:SetPoint("LEFT", lowestHealthHeader, "LEFT", 12, 0)
lowestHealthLabel:SetText("Lowest Health")

-- Create content frame for Lowest Health breakdown
local lowestHealthContent = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
lowestHealthContent:SetSize(450, 5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- 5 rows + padding
lowestHealthContent:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", LAYOUT.CONTENT_INDENT, -38)
lowestHealthContent:Show() -- Show by default
-- Modern content frame styling
lowestHealthContent:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-Listbox-Empty",
	edgeFile = "Interface\\Buttons\\UI-Listbox-Empty",
	tile = true,
	tileSize = 16,
	edgeSize = 8,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

-- Create the level text display
local levelLabel = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
local rowY1 = calculatePosition(1, 1)
levelLabel:SetPoint("TOPLEFT", lowestHealthContent, "TOPLEFT", LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
levelLabel:SetText("Level:")

local levelText = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
levelText:SetPoint("TOPRIGHT", lowestHealthContent, "TOPRIGHT", -LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
levelText:SetText(formatNumberWithCommas(1))

-- Create radio button for showing level in main screen statistics
local showStatsLevelRadio = CreateFrame("CheckButton", nil, lowestHealthContent, "UIRadioButtonTemplate")
showStatsLevelRadio:SetPoint("LEFT", levelLabel, "LEFT", -20, 0)
showStatsLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelLevel = showStatsLevelRadio
showStatsLevelRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelLevel = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelLevel = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the total text display (indented)
local lowestHealthTotalLabel = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthTotalLabel:SetPoint(
	"TOPLEFT",
	lowestHealthContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
)
lowestHealthTotalLabel:SetText("Total:")

lowestHealthText = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthText:SetPoint(
	"TOPRIGHT",
	lowestHealthContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
)
lowestHealthText:SetText(string.format("%.1f", lowestHealthScore or 100) .. "%")

-- Create radio button for showing lowest health in main screen statistics
local showStatsLowestHealthRadio = CreateFrame("CheckButton", nil, lowestHealthContent, "UIRadioButtonTemplate")
showStatsLowestHealthRadio:SetPoint("LEFT", lowestHealthTotalLabel, "LEFT", -20, 0)
showStatsLowestHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelLowestHealth = showStatsLowestHealthRadio
showStatsLowestHealthRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelLowestHealth = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelLowestHealth = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the This Level text display
local lowestHealthThisLevelLabel = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthThisLevelLabel:SetPoint(
	"TOPLEFT",
	lowestHealthContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
)
lowestHealthThisLevelLabel:SetText("This Level (Beta):")

local lowestHealthThisLevelText = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthThisLevelText:SetPoint(
	"TOPRIGHT",
	lowestHealthContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
)
lowestHealthThisLevelText:SetText("100.0%")

-- Create radio button for showing this level health in main screen statistics
local showStatsThisLevelRadio = CreateFrame("CheckButton", nil, lowestHealthContent, "UIRadioButtonTemplate")
showStatsThisLevelRadio:SetPoint("LEFT", lowestHealthThisLevelLabel, "LEFT", -20, 0)
showStatsThisLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelThisLevel = showStatsThisLevelRadio
showStatsThisLevelRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelThisLevel = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelThisLevel = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the This Session text display
local lowestHealthThisSessionLabel = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthThisSessionLabel:SetPoint(
	"TOPLEFT",
	lowestHealthContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
)
lowestHealthThisSessionLabel:SetText("This Session (Beta):")

local lowestHealthThisSessionText = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lowestHealthThisSessionText:SetPoint(
	"TOPRIGHT",
	lowestHealthContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
)
lowestHealthThisSessionText:SetText("100.0%")

-- Create radio button for showing session health in main screen statistics
local showStatsSessionHealthRadio = CreateFrame("CheckButton", nil, lowestHealthContent, "UIRadioButtonTemplate")
showStatsSessionHealthRadio:SetPoint("LEFT", lowestHealthThisSessionLabel, "LEFT", -20, 0)
showStatsSessionHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelSessionHealth = showStatsSessionHealthRadio
showStatsSessionHealthRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelSessionHealth = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelSessionHealth = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Add pet death rows to the same content frame
-- Create the pet deaths text display
local petDeathsLabel = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
petDeathsLabel:SetPoint(
	"TOPLEFT",
	lowestHealthContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
)
petDeathsLabel:SetText("Pet Deaths:")

petDeathsText = lowestHealthContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
petDeathsText:SetPoint(
	"TOPRIGHT",
	lowestHealthContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
)
petDeathsText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing pet deaths in main screen statistics
local showStatsPetDeathsRadio = CreateFrame("CheckButton", nil, lowestHealthContent, "UIRadioButtonTemplate")
showStatsPetDeathsRadio:SetPoint("LEFT", petDeathsLabel, "LEFT", -20, 0)
showStatsPetDeathsRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelPetDeaths = showStatsPetDeathsRadio
showStatsPetDeathsRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelPetDeaths = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelPetDeaths = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create modern WoW-style enemies slain section (no accordion functionality)
local enemiesSlainHeader = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
enemiesSlainHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
enemiesSlainHeader:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", 0, -179)

-- Modern WoW row styling with rounded corners and greyish background
enemiesSlainHeader:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
enemiesSlainHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
enemiesSlainHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create header text
local enemiesSlainLabel = enemiesSlainHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
enemiesSlainLabel:SetPoint("LEFT", enemiesSlainHeader, "LEFT", 12, 0)
enemiesSlainLabel:SetText("Enemies Slain")

-- Create content frame for Enemies Slain breakdown
local enemiesSlainContent = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
enemiesSlainContent:SetSize(450, 7 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- 7 rows + padding (added rare elites and world bosses)
enemiesSlainContent:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", LAYOUT.CONTENT_INDENT, -212)
enemiesSlainContent:Show() -- Show by default
-- Modern content frame styling
enemiesSlainContent:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-Listbox-Empty",
	edgeFile = "Interface\\Buttons\\UI-Listbox-Empty",
	tile = true,
	tileSize = 16,
	edgeSize = 8,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

-- Create the total text display (indented)
local enemiesSlainTotalLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
enemiesSlainTotalLabel:SetPoint("TOPLEFT", enemiesSlainContent, "TOPLEFT", LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
enemiesSlainTotalLabel:SetText("Total:")

local enemiesSlainText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
enemiesSlainText:SetPoint("TOPRIGHT", enemiesSlainContent, "TOPRIGHT", -LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
enemiesSlainText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing enemies slain in main screen statistics
local showStatsEnemiesSlainRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsEnemiesSlainRadio:SetPoint("LEFT", enemiesSlainTotalLabel, "LEFT", -20, 0)
showStatsEnemiesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelEnemiesSlain = showStatsEnemiesSlainRadio
showStatsEnemiesSlainRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the elites slain text display (indented)
local elitesSlainLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
elitesSlainLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
)
elitesSlainLabel:SetText("Elites Slain:")

local elitesSlainText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
elitesSlainText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
)
elitesSlainText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing elites slain in main screen statistics
local showStatsElitesSlainRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsElitesSlainRadio:SetPoint("LEFT", elitesSlainLabel, "LEFT", -20, 0)
showStatsElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelElitesSlain = showStatsElitesSlainRadio
showStatsElitesSlainRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelElitesSlain = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelElitesSlain = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the rare elites slain text display (indented)
local rareElitesSlainLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rareElitesSlainLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
)
rareElitesSlainLabel:SetText("Rare Elites Slain:")

local rareElitesSlainText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rareElitesSlainText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
)
rareElitesSlainText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing rare elites slain in main screen statistics
local showStatsRareElitesSlainRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsRareElitesSlainRadio:SetPoint("LEFT", rareElitesSlainLabel, "LEFT", -20, 0)
showStatsRareElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelRareElitesSlain = showStatsRareElitesSlainRadio
showStatsRareElitesSlainRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the world bosses slain text display (indented)
local worldBossesSlainLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
worldBossesSlainLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
)
worldBossesSlainLabel:SetText("World Bosses Slain:")

local worldBossesSlainText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
worldBossesSlainText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
)
worldBossesSlainText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing world bosses slain in main screen statistics
local showStatsWorldBossesSlainRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsWorldBossesSlainRadio:SetPoint("LEFT", worldBossesSlainLabel, "LEFT", -20, 0)
showStatsWorldBossesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelWorldBossesSlain = showStatsWorldBossesSlainRadio
showStatsWorldBossesSlainRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the dungeon bosses slain text display (indented)
local dungeonBossesLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dungeonBossesLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
)
dungeonBossesLabel:SetText("Dungeon Bosses Slain:")

local dungeonBossesText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dungeonBossesText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
)
dungeonBossesText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing dungeon bosses slain in main screen statistics
local showStatsDungeonBossesRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsDungeonBossesRadio:SetPoint("LEFT", dungeonBossesLabel, "LEFT", -20, 0)
showStatsDungeonBossesRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelDungeonBosses = showStatsDungeonBossesRadio
showStatsDungeonBossesRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelDungeonBosses = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelDungeonBosses = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the dungeons completed text display (indented)
local dungeonsCompletedLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dungeonsCompletedLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 5
)
dungeonsCompletedLabel:SetText("Dungeons Completed:")

local dungeonsCompletedText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dungeonsCompletedText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 5
)
dungeonsCompletedText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing dungeons completed in main screen statistics
local showStatsDungeonsCompletedRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsDungeonsCompletedRadio:SetPoint("LEFT", dungeonsCompletedLabel, "LEFT", -20, 0)
showStatsDungeonsCompletedRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelDungeonsCompleted = showStatsDungeonsCompletedRadio
showStatsDungeonsCompletedRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create the highest crit value text display (indented)
local highestCritLabel = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
highestCritLabel:SetPoint(
	"TOPLEFT",
	enemiesSlainContent,
	"TOPLEFT",
	LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6
)
highestCritLabel:SetText("Highest Crit Value:")

local highestCritText = enemiesSlainContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
highestCritText:SetPoint(
	"TOPRIGHT",
	enemiesSlainContent,
	"TOPRIGHT",
	-LAYOUT.ROW_INDENT,
	-LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6
)
highestCritText:SetText(formatNumberWithCommas(0))

-- Create radio button for showing highest crit value in main screen statistics
local showStatsHighestCritRadio = CreateFrame("CheckButton", nil, enemiesSlainContent, "UIRadioButtonTemplate")
showStatsHighestCritRadio:SetPoint("LEFT", highestCritLabel, "LEFT", -20, 0)
showStatsHighestCritRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
radioButtons.showMainStatisticsPanelHighestCritValue = showStatsHighestCritRadio
showStatsHighestCritRadio:SetScript("OnClick", function(self)
	tempSettings.showMainStatisticsPanelHighestCritValue = self:GetChecked()
	GLOBAL_SETTINGS.showMainStatisticsPanelHighestCritValue = self:GetChecked()
	-- Trigger immediate update of main screen statistics
	if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
		UltraHardcoreStatsFrame.UpdateRowVisibility()
	end
end)

-- Create modern WoW-style Survival section (no accordion functionality)
local survivalHeader = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
survivalHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
survivalHeader:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", 0, -399) -- Moved down by 50px for new rows
-- Modern WoW row styling with rounded corners and greyish background
survivalHeader:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
survivalHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
survivalHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create header text
local survivalLabel = survivalHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
survivalLabel:SetPoint("LEFT", survivalHeader, "LEFT", 12, 0)
survivalLabel:SetText("Survival")

-- Create content frame for Survival breakdown (always visible)
local survivalContent = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
survivalContent:SetSize(450, 5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Height for 5 items
survivalContent:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", LAYOUT.CONTENT_INDENT, -432) -- Moved down by 50px for new rows
survivalContent:Show() -- Always show
-- Modern content frame styling
survivalContent:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-Listbox-Empty",
	edgeFile = "Interface\\Buttons\\UI-Listbox-Empty",
	tile = true,
	tileSize = 16,
	edgeSize = 8,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

-- Create survival statistics display inside the content frame
local survivalLabels = {}
local survivalTexts = {}

-- Create survival statistics entries
local survivalStats = {
	{
		key = "healthPotionsUsed",
		label = "Health Potions Used:",
	},
	{
		key = "bandagesUsed",
		label = "Bandages Applied:",
	},
	{
		key = "targetDummiesUsed",
		label = "Target Dummies Used (Beta):",
	},
	{
		key = "grenadesUsed",
		label = "Grenades Used (Beta):",
	},
	{
		key = "partyMemberDeaths",
		label = "Party Deaths Witnessed:",
	},
	{
		key = "maxTunnelVisionOverlayShown",
		label = "Close Escapes:",
	},
}

local yOffset = -LAYOUT.CONTENT_PADDING
for _, stat in ipairs(survivalStats) do
	local label = survivalContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	label:SetPoint("TOPLEFT", survivalContent, "TOPLEFT", LAYOUT.ROW_INDENT, yOffset)
	label:SetText(stat.label)

	local text = survivalContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetPoint("TOPRIGHT", survivalContent, "TOPRIGHT", -LAYOUT.ROW_INDENT, yOffset)
	text:SetText(formatNumberWithCommas(0))

	-- Create radio button for this survival statistic
	local radio = CreateFrame("CheckButton", nil, survivalContent, "UIRadioButtonTemplate")
	radio:SetPoint("LEFT", label, "LEFT", -20, 0)
	local settingName = "showMainStatisticsPanel" .. string.gsub(stat.key, "^%l", string.upper)
	radio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
	radioButtons[settingName] = radio
	radio:SetScript("OnClick", function(self)
		tempSettings[settingName] = self:GetChecked()
		GLOBAL_SETTINGS[settingName] = self:GetChecked()
		-- Trigger immediate update of main screen statistics
		if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
			UltraHardcoreStatsFrame.UpdateRowVisibility()
		end
	end)

	survivalLabels[stat.key] = label
	survivalTexts[stat.key] = text

	yOffset = yOffset - LAYOUT.ROW_HEIGHT
end

-- Create modern WoW-style XP gained section (no accordion functionality)
local xpGainedHeader = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
xpGainedHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
xpGainedHeader:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", 0, -593) -- Added 20px gap after Close Escapes
-- Modern WoW row styling with rounded corners and greyish background
xpGainedHeader:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
xpGainedHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
xpGainedHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create header text
local xpGainedLabel = xpGainedHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
xpGainedLabel:SetPoint("LEFT", xpGainedHeader, "LEFT", 12, 0)
xpGainedLabel:SetText("XP Gained Without Option Breakdown")

-- Create collapsible content frame for XP breakdown
local xpGainedContent = CreateFrame("Frame", nil, statsScrollChild, "BackdropTemplate")
xpGainedContent:SetSize(450, 20 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2 + 40) -- Added 40px extra gap at bottom
xpGainedContent:SetPoint("TOPLEFT", statsScrollChild, "TOPLEFT", LAYOUT.CONTENT_INDENT, -626) -- Adjusted to maintain proper gap from header
xpGainedContent:Show() -- Show by default
-- Modern content frame styling
xpGainedContent:SetBackdrop({
	bgFile = "Interface\\Buttons\\UI-Listbox-Empty",
	edgeFile = "Interface\\Buttons\\UI-Listbox-Empty",
	tile = true,
	tileSize = 16,
	edgeSize = 8,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})

-- Create XP breakdown display inside the content frame
local xpBreakdownLabels = {}
local xpBreakdownTexts = {}
local xpSectionHeaders = {}

-- Mapping of setting names to display names
local settingDisplayNames = {
	hidePlayerFrame = "Hide Player Frame",
	showOnScreenStatistics = "On Screen Statistics",
	showTunnelVision = "Tunnel Vision",
	announceLevelUpToGuild = "Announce Level Up to Guild",
	tunnelVisionMaxStrata = "Tunnel Vision Covers Everything",
	hideTargetFrame = "Hide Target Frame",
	hideTargetTooltip = "Hide Target Tooltips",
	disableNameplateHealth = "Disable Nameplates",
	showDazedEffect = "Show Dazed Effect",
	hideGroupHealth = "Use UHC Party Frames",
	hideMinimap = "Hide Minimap",
	hideBreathIndicator = "Use UHC Breath Indicator",
	showCritScreenMoveEffect = "Use UHC Incoming Crit Effect",
	hideActionBars = "Hide Action Bars",
	petsDiePermanently = "Pets Die Permanently",
	showFullHealthIndicator = "Use UHC Full Health Indicator",
	showIncomingDamageEffect = "Use UHC Incoming Damage Effect",
	showHealingIndicator = "Use UHC Incoming Healing Effect",
	showClockEvenWhenMapHidden = "Show Clock Even When Map is Hidden",
	announcePartyDeathsOnGroupJoin = "Announce Party Deaths on Group Join",
	announceDungeonsCompletedOnGroupJoin = "Announce Dungeons Completed on Group Join",
	buffBarOnResourceBar = "Buff Bar on Resource Bar",
	newHighCritAppreciationSoundbite = "Highest Crit Appreciation Soundbite (Xaryu)",
	playPartyDeathSoundbite = "Party Death Soundbite",
	playPlayerDeathSoundbite = "Player Death Soundbite",
	showFriendlyNameplateIcons = "Show Friendly Nameplate Health Indicators",
}

-- Define preset sections with their settings
local presetSections = {
	{
		title = "Lite:",
		settings = { "hidePlayerFrame", "showTunnelVision" },
	},
	{
		title = "Recommended:",
		settings = {
			"hideTargetFrame",
			"hideTargetTooltip",
			"disableNameplateHealth",
			"showDazedEffect",
			"hideGroupHealth",
			"hideMinimap",
			"hideBreathIndicator",
		},
	},
	{
		title = "Ultra:",
		settings = { "petsDiePermanently", "hideActionBars", "tunnelVisionMaxStrata" },
	},
	{
		title = "Experimental:",
		settings = {
			"showCritScreenMoveEffect",
			"showFullHealthIndicator",
			"showIncomingDamageEffect",
			"showHealingIndicator",
			"setFirstPersonCamera",
			"showFriendlyNameplateIcons",
		},
	},
}

-- Create XP breakdown entries with section headers
local yOffset = -LAYOUT.CONTENT_PADDING
for sectionIndex, section in ipairs(presetSections) do
	-- Create section header
	local sectionHeader = xpGainedContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sectionHeader:SetPoint("TOPLEFT", xpGainedContent, "TOPLEFT", LAYOUT.ROW_INDENT, yOffset)
	sectionHeader:SetText(section.title)
	sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
	xpSectionHeaders[sectionIndex] = sectionHeader
	yOffset = yOffset - LAYOUT.ROW_HEIGHT

	-- Create settings for this section
	for _, settingName in ipairs(section.settings) do
		local displayName = settingDisplayNames[settingName]
		if displayName then
			local label = xpGainedContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			label:SetPoint("TOPLEFT", xpGainedContent, "TOPLEFT", LAYOUT.ROW_INDENT + 12, yOffset) -- Indented more for settings
			label:SetText(displayName .. ":")

			local text = xpGainedContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			text:SetPoint("TOPRIGHT", xpGainedContent, "TOPRIGHT", -LAYOUT.ROW_INDENT, yOffset)
			text:SetText(formatNumberWithCommas(0))

			xpBreakdownLabels[settingName] = label
			xpBreakdownTexts[settingName] = text

			yOffset = yOffset - LAYOUT.ROW_HEIGHT
		end
	end

	-- Add extra space between sections
	yOffset = yOffset - LAYOUT.SECTION_SPACING
end

-- Set initial positioning after all statistics are created
-- All sections are always visible

local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
closeButton:SetSize(32, 32)
closeButton:SetScript("OnClick", function()
	-- Discard temporary changes by reinitializing temp settings
	initializeTempSettings()
	settingsFrame:Hide()
end)

-- Settings Tab Content
-- Frame for selectable preset buttons
local presetButtonsFrame = CreateFrame("Frame", nil, tabContents[2])
presetButtonsFrame:SetSize(420, 150)
presetButtonsFrame:SetPoint("TOP", tabContents[2], "TOP", 0, -10)

local checkboxes = {}
local presetButtons = {}
local selectedPreset = nil

local function updateCheckboxes()
	for _, checkboxItem in ipairs(settingsCheckboxOptions) do
		local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
		if checkbox then
			checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])
		end
	end
end

local function updateRadioButtons()
	-- Update all radio buttons using the stored references
	for settingName, radio in pairs(radioButtons) do
		if radio then
			local isChecked = tempSettings[settingName] or false
			radio:SetChecked(isChecked)
			-- Also update GLOBAL_SETTINGS for immediate effect
			GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
		end
	end
end

local function applyPreset(presetIndex)
	if not presets[presetIndex] then
		return
	end

	-- Copy preset to temporary settings
	for key, value in pairs(presets[presetIndex]) do
		tempSettings[key] = value
	end

	-- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
	if tempSettings.hidePlayerFrame then
		SetCVar("statusText", "0")
	end

	-- Update checkboxes
	updateCheckboxes()
	updateRadioButtons()

	-- Highlight the selected preset button
	if selectedPreset then
		selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
	end
	selectedPreset = presetButtons[presetIndex]
	selectedPreset:SetBackdropBorderColor(1, 1, 0) -- Highlight new
end

-- Create preset buttons
local presetIcons = {
	"Interface\\AddOns\\UltraHardcore\\textures\\skull1_100_halloween.png",
	"Interface\\AddOns\\UltraHardcore\\textures\\skull2_100_halloween.png",
	"Interface\\AddOns\\UltraHardcore\\textures\\skull3_100_halloween.png",
}

local buttonSize = 100 -- Increased size for better visibility
local spacing = 10 -- Spacing between the buttons
local totalWidth = 360 -- Total width of the frame for preset buttons
local textYOffset = -5 -- Distance between button and text
for i = 1, 3 do
	local button = CreateFrame("Button", nil, presetButtonsFrame, "BackdropTemplate")
	button:SetSize(buttonSize, buttonSize)

	-- Position buttons evenly (left, center, right)
	if i == 1 then
		button:SetPoint("LEFT", presetButtonsFrame, "LEFT", spacing, -20) -- Left
	elseif i == 2 then
		button:SetPoint("CENTER", presetButtonsFrame, "CENTER", 0, -20) -- Centered
	elseif i == 3 then
		button:SetPoint("RIGHT", presetButtonsFrame, "RIGHT", -spacing, -20) -- Right
	end

	button:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
	})
	button:SetBackdropBorderColor(0.5, 0.5, 0.5)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture(presetIcons[i])

	-- Add text below each button
	local presetText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	presetText:SetPoint("TOP", button, "BOTTOM", 0, textYOffset) -- Adjust the distance as needed
	if i == 1 then
		presetText:SetText("Lite")
	elseif i == 2 then
		presetText:SetText("Recommended")
	elseif i == 3 then
		presetText:SetText("Ultra")
	end

	button:SetScript("OnClick", function()
		applyPreset(i)
	end)

	presetButtons[i] = button
end

-- ScrollFrame to enable scrolling for settings tab
local scrollFrame = CreateFrame("ScrollFrame", nil, tabContents[2], "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", tabContents[2], "TOPLEFT", 10, -190)
scrollFrame:SetPoint("BOTTOMRIGHT", tabContents[2], "BOTTOMRIGHT", -30, 10)

-- ScrollChild contains all checkboxes
local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
-- Calculate height: 5 section headers + all checkboxes + spacing
local totalHeight = (5 * 25) + (#settingsCheckboxOptions * 30) + (5 * 10) + 40 -- Headers + checkboxes + section spacing + padding
scrollChild:SetSize(420, totalHeight)

local function createCheckboxes()
	local yOffset = -10

	-- Define preset sections with their settings (same as statistics section)
	local presetSections = {
		{
			title = "Lite:",
			settings = { "hidePlayerFrame", "showTunnelVision" },
		},
		{
			title = "Recommended:",
			settings = {
				"hideTargetFrame",
				"hideTargetTooltip",
				"disableNameplateHealth",
				"showDazedEffect",
				"hideGroupHealth",
				"hideMinimap",
				"hideBreathIndicator",
			},
		},
		{
			title = "Ultra:",
			settings = { "petsDiePermanently", "hideActionBars", "tunnelVisionMaxStrata" },
		},
		{
			title = "Experimental:",
			settings = {
				"showCritScreenMoveEffect",
				"showFullHealthIndicator",
				"showIncomingDamageEffect",
				"showHealingIndicator",
				"setFirstPersonCamera",
				"showFriendlyNameplateIcons",
			},
		},
		{
			title = "Misc:",
			settings = {
				"showOnScreenStatistics",
				"announceLevelUpToGuild",
				"hideUIErrors",
				"showClockEvenWhenMapHidden",
				"announcePartyDeathsOnGroupJoin",
				"announceDungeonsCompletedOnGroupJoin",
				"buffBarOnResourceBar",
				"newHighCritAppreciationSoundbite",
				"playPartyDeathSoundbite",
				"playPlayerDeathSoundbite",
				"spookyTunnelVision",
				"roachHearthstoneInPartyCombat",
			},
		},
	}

	-- Create sections with headers and checkboxes
	for sectionIndex, section in ipairs(presetSections) do
		-- Create section header
		local sectionHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		sectionHeader:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, yOffset)
		sectionHeader:SetText(section.title)
		sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
		yOffset = yOffset - 25

		-- Create checkboxes for this section
		for _, settingName in ipairs(section.settings) do
			-- Find the checkbox item by dbSettingsValueName
			local checkboxItem = nil
			for _, item in ipairs(settingsCheckboxOptions) do
				if item.dbSettingsValueName == settingName then
					checkboxItem = item
					break
				end
			end

			if checkboxItem then
				local checkbox = CreateFrame("CheckButton", nil, scrollChild, "ChatConfigCheckButtonTemplate")
				checkbox:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 20, yOffset) -- Indented for settings
				checkbox.Text:SetText(checkboxItem.name)
				checkbox.Text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0) -- Add 5 pixel gap between checkbox and text
				checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])

				checkboxes[checkboxItem.dbSettingsValueName] = checkbox

				checkbox:SetScript("OnClick", function(self)
					tempSettings[checkboxItem.dbSettingsValueName] = self:GetChecked()

					-- Apply Interface Status Text rule immediately when hidePlayerFrame is toggled
					if checkboxItem.dbSettingsValueName == "hidePlayerFrame" then
						if self:GetChecked() then
							SetCVar("statusText", "0")
						end
					end

					-- Handle buff bar positioning when setting is toggled
					if
						checkboxItem.dbSettingsValueName == "buffBarOnResourceBar"
						or checkboxItem.dbSettingsValueName == "hidePlayerFrame"
					then
						if _G.UltraHardcoreHandleBuffBarSettingChange then
							_G.UltraHardcoreHandleBuffBarSettingChange()
						end
					end
				end)

				-- Add tooltip functionality
				checkbox:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(checkboxItem.tooltip)
					GameTooltip:Show()
				end)

				checkbox:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)

				yOffset = yOffset - 30 -- Reduced spacing between checkboxes
			end
		end

		-- Add extra space between sections
		yOffset = yOffset - 10
	end
end

-- X Found Mode Tab Content is now in XFoundMode.lua

-- Info Tab Content
-- Philosophy text (at top)
local philosophyText = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
philosophyText:SetPoint("CENTER", tabContents[5], "CENTER", 0, 180)
philosophyText:SetWidth(500)
philosophyText:SetText("UltraHardcore Addon\nVersion: " .. GetAddOnMetadata("UltraHardcore", "Version"))
philosophyText:SetJustifyH("CENTER")
philosophyText:SetNonSpaceWrap(true)

-- Compatibility warning (below philosophy)
local compatibilityText = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
compatibilityText:SetPoint("CENTER", tabContents[5], "CENTER", 0, 120)
compatibilityText:SetWidth(500)
compatibilityText:SetText(
	"Please note: UltraHardcore hasn't been tested with other addons. For the best experience, we recommend using UltraHardcore alone on your hardcore characters."
)
compatibilityText:SetJustifyH("CENTER")
compatibilityText:SetNonSpaceWrap(true)
compatibilityText:SetTextColor(0.9, 0.9, 0.9)

-- Bug report text
local bugReportText = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
bugReportText:SetPoint("CENTER", tabContents[5], "CENTER", 0, 80)
bugReportText:SetText("Found a bug or have suggestions? Join our Discord community!")
bugReportText:SetJustifyH("CENTER")
bugReportText:SetTextColor(0.8, 0.8, 0.8)
bugReportText:SetWidth(500)
bugReportText:SetNonSpaceWrap(true)

-- Discord Link Text (clickable)
local discordLinkText = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
discordLinkText:SetPoint("CENTER", tabContents[5], "CENTER", 0, 60)
discordLinkText:SetText("Discord Server: https://discord.gg/zuSPDNhYEN")
discordLinkText:SetJustifyH("CENTER")
discordLinkText:SetTextColor(0.4, 0.8, 1)

-- Discord instructions text
local discordInstructions = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
discordInstructions:SetPoint("CENTER", tabContents[5], "CENTER", 0, 40)
discordInstructions:SetText("Click the link above to copy it to your chatbox")
discordInstructions:SetJustifyH("CENTER")
discordInstructions:SetTextColor(0.8, 0.8, 0.8)
discordInstructions:SetWidth(500)
discordInstructions:SetNonSpaceWrap(true)

-- Patch Notes Section (at bottom)
local patchNotesTitle = tabContents[5]:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
patchNotesTitle:SetPoint("CENTER", tabContents[5], "CENTER", 0, 0)
patchNotesTitle:SetText("Patch Notes")
patchNotesTitle:SetJustifyH("CENTER")
patchNotesTitle:SetTextColor(1, 1, 0.5)

-- Create patch notes display at bottom
local patchNotesFrame = CreateFrame("Frame", nil, tabContents[5], "BackdropTemplate")
patchNotesFrame:SetSize(520, 280)
patchNotesFrame:SetPoint("CENTER", tabContents[5], "CENTER", 0, -160)
patchNotesFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
})
patchNotesFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
patchNotesFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

-- Create patch notes display using reusable component
local patchNotesScrollFrame = CreatePatchNotesDisplay(patchNotesFrame, 480, 260, 10, -10)

-- Make the text clickable
local discordLinkFrame = CreateFrame("Button", nil, tabContents[5])
discordLinkFrame:SetPoint("CENTER", discordLinkText, "CENTER", 0, 0)
discordLinkFrame:SetSize(400, 20)
discordLinkFrame:SetScript("OnClick", function()
	-- Insert the Discord link into the chat input box
	local discordLink = "https://discord.gg/zuSPDNhYEN"

	-- Get the chat input frame
	local chatFrame = DEFAULT_CHAT_FRAME
	if chatFrame and chatFrame.editBox then
		chatFrame.editBox:SetText(discordLink)
		chatFrame.editBox:HighlightText() -- Select all text for easy copying
		chatFrame.editBox:SetFocus() -- Focus the input box
	end

	-- Also print to console as backup
	print("Discord link copied to chat input box!")
	print("You can now copy it from the chat input field.")
end)

-- Add tooltip for the link
discordLinkFrame:SetScript("OnEnter", function()
	GameTooltip:SetOwner(discordLinkFrame, "ANCHOR_TOP")
	GameTooltip:SetText("Click to copy Discord link to chat input")
	GameTooltip:AddLine("The link will appear in your chat box where you can easily copy it!", 1, 1, 1, true)
	GameTooltip:Show()
end)

discordLinkFrame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

-- Achievements Tab Content (empty for now)
local achievementsTitle = tabContents[3]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
achievementsTitle:SetPoint("CENTER", tabContents[3], "CENTER", 0, 0)
achievementsTitle:SetText("Achievements Coming In Phase 3!")
achievementsTitle:SetFontObject("GameFontNormalLarge")

-- Save button for Settings tab only
local saveButton = CreateFrame("Button", nil, tabContents[2], "UIPanelButtonTemplate")
saveButton:SetSize(120, 30)
saveButton:SetPoint("BOTTOM", tabContents[2], "BOTTOM", 0, -40)
saveButton:SetText("Save and Reload")
saveButton:SetScript("OnClick", function()
	-- Copy temporary settings to GLOBAL_SETTINGS
	for key, value in pairs(tempSettings) do
		GLOBAL_SETTINGS[key] = value
	end

	-- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
	if GLOBAL_SETTINGS.hidePlayerFrame then
		SetCVar("statusText", "0")
	end

	-- Save settings for current character
	SaveCharacterSettings(GLOBAL_SETTINGS)
	ReloadUI()
end)

-- Share button for Statistics tab
local shareButton = CreateFrame("Button", nil, tabContents[1], "UIPanelButtonTemplate")
shareButton:SetSize(80, 30)
shareButton:SetPoint("BOTTOM", tabContents[1], "BOTTOM", 0, -40)
shareButton:SetText("Share")

-- Add tooltip
shareButton:SetScript("OnEnter", function()
	GameTooltip:SetOwner(shareButton, "ANCHOR_RIGHT")
	GameTooltip:SetText("Share UHC Stats to Chat")
	GameTooltip:Show()
end)
shareButton:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

shareButton:SetScript("OnClick", function()
	if CharacterStats and CharacterStats.LogStatsToChat then
		CharacterStats:LogStatsToChat()
	else
		print("UHC - CharacterStats not available. Please reload UI.")
	end
end)

-- Function to update XP breakdown display
local function UpdateXPBreakdown()
	-- Define preset sections with their settings (same order as TrackXPPerSetting.lua)
	local presetSections = {
		{
			title = "Lite Preset Settings:",
			settings = { "hidePlayerFrame", "showTunnelVision" },
		},
		{
			title = "Recommended Preset Settings:",
			settings = {
				"hideTargetFrame",
				"hideTargetTooltip",
				"disableNameplateHealth",
				"showDazedEffect",
				"hideGroupHealth",
				"hideMinimap",
				"hideBreathIndicator",
			},
		},
		{
			title = "Ultra Preset Settings:",
			settings = { "petsDiePermanently", "hideActionBars", "tunnelVisionMaxStrata" },
		},
		{
			title = "Experimental Preset Settings:",
			settings = {
				"showCritScreenMoveEffect",
				"showFullHealthIndicator",
				"showIncomingDamageEffect",
				"showHealingIndicator",
				"setFirstPersonCamera",
			},
		},
	}

	-- Update display organized by preset sections
	local yOffset = -LAYOUT.CONTENT_PADDING
	for sectionIndex, section in ipairs(presetSections) do
		-- Position section header
		local sectionHeader = xpSectionHeaders[sectionIndex]
		if sectionHeader then
			sectionHeader:SetPoint("TOPLEFT", xpGainedContent, "TOPLEFT", LAYOUT.ROW_INDENT, yOffset)
			yOffset = yOffset - LAYOUT.ROW_HEIGHT
		end

		-- Position settings for this section
		for _, settingName in ipairs(section.settings) do
			local textElement = xpBreakdownTexts[settingName]
			local labelElement = xpBreakdownLabels[settingName]

			if textElement and labelElement then
				-- Convert setting name to proper variable name format
				local xpVariable = "xpGainedWithoutOption" .. string.gsub(settingName, "^%l", string.upper)
				-- Handle camelCase conversion for multi-word settings
				xpVariable = string.gsub(xpVariable, "(%u)(%l)", "%1%2")

				local xpGained = CharacterStats:GetStat(xpVariable) or 0

				-- Position both label and text (indented for settings)
				labelElement:SetPoint("TOPLEFT", xpGainedContent, "TOPLEFT", LAYOUT.ROW_INDENT + 12, yOffset)
				textElement:SetPoint("TOPRIGHT", xpGainedContent, "TOPRIGHT", -LAYOUT.ROW_INDENT, yOffset)
				textElement:SetText(formatNumberWithCommas(xpGained))
				yOffset = yOffset - LAYOUT.ROW_HEIGHT
			end
		end

		-- Add extra space between sections
		yOffset = yOffset - LAYOUT.SECTION_SPACING
	end
end

-- Update the lowest health display
local function UpdateLowestHealthDisplay()
	if not UltraHardcoreDB then
		LoadDBData()
	end

	-- Update level display
	if levelText then
		local playerLevel = UnitLevel("player") or 1
		levelText:SetText(formatNumberWithCommas(playerLevel))
	end

	if lowestHealthText then
		local currentLowestHealth = CharacterStats:GetStat("lowestHealth") or 100
		lowestHealthText:SetText(string.format("%.1f", currentLowestHealth) .. "%")
	end

	if lowestHealthThisLevelText then
		local currentLowestHealthThisLevel = CharacterStats:GetStat("lowestHealthThisLevel") or 100
		lowestHealthThisLevelText:SetText(string.format("%.1f", currentLowestHealthThisLevel) .. "%")
	end

	if lowestHealthThisSessionText then
		local currentLowestHealthThisSession = CharacterStats:GetStat("lowestHealthThisSession") or 100
		lowestHealthThisSessionText:SetText(string.format("%.1f", currentLowestHealthThisSession) .. "%")
	end

	-- Update pet death display
	if petDeathsText then
		local currentPetDeaths = CharacterStats:GetStat("petDeaths") or 0
		petDeathsText:SetText(formatNumberWithCommas(currentPetDeaths))
	end

	if elitesSlainText then
		local elites = CharacterStats:GetStat("elitesSlain") or 0
		elitesSlainText:SetText(formatNumberWithCommas(elites))
	end

	if rareElitesSlainText then
		local rareElites = CharacterStats:GetStat("rareElitesSlain") or 0
		rareElitesSlainText:SetText(formatNumberWithCommas(rareElites))
	end

	if worldBossesSlainText then
		local worldBosses = CharacterStats:GetStat("worldBossesSlain") or 0
		worldBossesSlainText:SetText(formatNumberWithCommas(worldBosses))
	end

	if enemiesSlainText then
		local enemies = CharacterStats:GetStat("enemiesSlain") or 0
		enemiesSlainText:SetText(formatNumberWithCommas(enemies))
	end

	if dungeonBossesText then
		local dungeonBosses = CharacterStats:GetStat("dungeonBossesKilled") or 0
		dungeonBossesText:SetText(formatNumberWithCommas(dungeonBosses))
	end

	if dungeonsCompletedText then
		local dungeonsCompleted = CharacterStats:GetStat("dungeonsCompleted") or 0
		dungeonsCompletedText:SetText(formatNumberWithCommas(dungeonsCompleted))
	end

	-- Update highest crit value
	if highestCritText then
		local highestCrit = CharacterStats:GetStat("highestCritValue") or 0
		highestCritText:SetText(formatNumberWithCommas(highestCrit))
	end

	-- Update XP breakdown (always visible now)
	UpdateXPBreakdown()

	-- Update survival statistics
	if survivalTexts then
		for _, stat in ipairs(survivalStats) do
			local value = CharacterStats:GetStat(stat.key) or 0
			if survivalTexts[stat.key] then
				survivalTexts[stat.key]:SetText(formatNumberWithCommas(value))
			end
		end
	end
end

function ToggleSettings()
	if settingsFrame:IsShown() then
		settingsFrame:Hide()
	else
		-- Initialize temporary settings when opening
		initializeTempSettings()

		-- Reset preset button highlighting
		if selectedPreset then
			selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
			selectedPreset = nil
		end

		-- Set Statistics tab as default (tab 1)
		for i, content in ipairs(tabContents) do
			content:Hide()
		end
		for i, tabButton in ipairs(tabButtons) do
			tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
			tabButton:SetAlpha(0.8)
		end
		tabContents[1]:Show() -- Show Statistics tab
		tabButtons[1]:SetBackdropBorderColor(1, 1, 0) -- Highlight Statistics tab
		tabButtons[1]:SetAlpha(1.0) -- Highlight Statistics tab
		activeTab = 1

		settingsFrame:Show()
		updateCheckboxes()
		updateRadioButtons()
		UpdateLowestHealthDisplay()
	end
end

SLASH_TOGGLESETTINGS1 = "/uhc"
SlashCmdList["TOGGLESETTINGS"] = ToggleSettings

-- Function to open settings and switch to a specific tab
function OpenSettingsToTab(tabIndex)
	-- Initialize temporary settings when opening
	initializeTempSettings()

	-- Reset preset button highlighting
	if selectedPreset then
		selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
		selectedPreset = nil
	end

	-- Hide all tab contents
	for i, content in ipairs(tabContents) do
		content:Hide()
	end

	-- Reset all tab button appearances
	for i, tabButton in ipairs(tabButtons) do
		tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
		tabButton:SetAlpha(0.8)
	end

	-- Show specified tab content and highlight button
	if tabContents[tabIndex] and tabButtons[tabIndex] then
		tabContents[tabIndex]:Show()
		tabButtons[tabIndex]:SetBackdropBorderColor(1, 1, 0)
		tabButtons[tabIndex]:SetAlpha(1.0)
		activeTab = tabIndex

		-- Initialize X Found Mode tab if it's being shown
		if tabIndex == 4 and InitializeXFoundModeTab then
			InitializeXFoundModeTab()
		end
	end

	-- Show the settings frame
	settingsFrame:Show()
	updateCheckboxes()
	updateRadioButtons()
	UpdateLowestHealthDisplay()
end

-- Initialize temporary settings and create checkboxes
initializeTempSettings()
createCheckboxes()
