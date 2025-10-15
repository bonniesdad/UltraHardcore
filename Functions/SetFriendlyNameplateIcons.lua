-- -- Friendly Nameplate Health Icon Override
-- -- Overrides friendly nameplates with health-based icons instead of health bars
--
-- -- Cache for nameplate icon frames
local FRIENDLY_NAMEPLATE_ICONS = {}
--
function SetFriendlyNameplateIcons(enabled)
	if not enabled then
		-- Hide all existing icons
		for unit, iconFrame in pairs(FRIENDLY_NAMEPLATE_ICONS) do
			if iconFrame then
				iconFrame:Hide()
			end
		end
		FRIENDLY_NAMEPLATE_ICONS = {}
		return
	end

	-- Create event frame if not exists
	if not friendlyNameplateFrame then
		friendlyNameplateFrame = CreateFrame("Frame")
		friendlyNameplateFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
		friendlyNameplateFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
		friendlyNameplateFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
		friendlyNameplateFrame:RegisterEvent("UNIT_HEALTH")

		friendlyNameplateFrame:SetScript("OnEvent", function(self, event, unit)
			if event == "NAME_PLATE_UNIT_ADDED" then
				-- Check if unit is friendly
				if UnitIsFriend("player", unit) then
					CreateFriendlyNameplateIcon(unit)
				end
			elseif event == "NAME_PLATE_UNIT_REMOVED" then
				-- Remove icon if exists
				if FRIENDLY_NAMEPLATE_ICONS[unit] then
					FRIENDLY_NAMEPLATE_ICONS[unit]:Hide()
					FRIENDLY_NAMEPLATE_ICONS[unit] = nil
				end
			elseif (event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_HEALTH") and UnitIsFriend("player", unit) then
				-- -- Update icon for friendly unit
				UpdateFriendlyNameplateIcon(unit)
			end
		end)
	end
end
--
function CreateFriendlyNameplateIcon(unit)
	local nameplateFrame = C_NamePlate.GetNamePlateForUnit(unit)
	if not nameplateFrame then
		return
	end

	-- Hide the default health bar
	if nameplateFrame.UnitFrame.healthBar then
		nameplateFrame.UnitFrame.healthBar:Hide()
	end
	-- Hide the default Level fram
	if nameplateFrame.UnitFrame.LevelFrame then
		nameplateFrame.UnitFrame.LevelFrame:Hide()
	end

	-- Create or get existing icon
	local iconFrame = FRIENDLY_NAMEPLATE_ICONS[unit]
	if not iconFrame then
		iconFrame = nameplateFrame:CreateTexture(nil, "OVERLAY")
		iconFrame:SetSize(24, 24)
		iconFrame:SetPoint("CENTER", nameplateFrame, "CENTER", 0, -10)
		FRIENDLY_NAMEPLATE_ICONS[unit] = iconFrame
	end

	-- Update the icon
	UpdateFriendlyNameplateIcon(unit)
	iconFrame:Show()
end
--
function UpdateFriendlyNameplateIcon(unit)
	local iconFrame = FRIENDLY_NAMEPLATE_ICONS[unit]
	if not iconFrame then
		return
	end

	if not UnitExists(unit) then
		iconFrame:Hide()
		return
	end

	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	if not health or not maxHealth or maxHealth == 0 then
		iconFrame:Hide()
		return
	end

	local healthRatio = health / maxHealth

	-- Handle dead units
	if health == 0 or UnitIsDead(unit) then
		healthRatio = 0
	end

	-- Find the appropriate health step
	local texture = nil
	local alpha = nil
	for _, step in pairs(PARTY_HEALTH_INDICATOR_STEPS) do
		if healthRatio <= step.health then
			texture = step.texture
			alpha = step.alpha
			break
		end
	end

	if texture then
		iconFrame:SetTexture(texture)
		iconFrame:SetAlpha(alpha)
		iconFrame:Show()
	else
		iconFrame:Hide()
	end
end
