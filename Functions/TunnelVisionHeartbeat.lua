-- Track previous health percentage to detect increases
local previousHealthPercent = 100
-- Track which heartbeat sounds are currently active
local heartbeatSoundFile1 = "Interface\\AddOns\\UltraHardcore\\Sounds\\heartbeat_01.ogg"
local heartbeatSoundFile2 = "Interface\\AddOns\\UltraHardcore\\Sounds\\heartbeat_02.ogg"
local heartbeatSoundFile3 = "Interface\\AddOns\\UltraHardcore\\Sounds\\heartbeat_03.ogg"
local heartbeatSoundFile4 = "Interface\\AddOns\\UltraHardcore\\Sounds\\heartbeat_04.ogg"

local activeHeartbeatLevel = nil
local activeHeartbeatHandle = nil

local function StopActiveHeartbeat()
	if activeHeartbeatHandle then
		StopSound(activeHeartbeatHandle)
		activeHeartbeatHandle = nil
	end
end

function TunnelVisionHeartbeat(self, event, unit, heartbeatSoundOnLowHealth)
	if not heartbeatSoundOnLowHealth then
		return
	end

	local healthPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100

	-- Conditions where heartbeat should stop entirely
	if UnitIsDeadOrGhost("player") or healthPercent >= 80 or healthPercent <= 0 then
		StopActiveHeartbeat()
		activeHeartbeatLevel = nil
		previousHealthPercent = healthPercent
		return
	end

	-- Determine which heartbeat level should be active based on current health
	local newHeartbeatLevel = nil
	if healthPercent <= 20 then
		newHeartbeatLevel = 4
	elseif healthPercent <= 40 then
		newHeartbeatLevel = 3
	elseif healthPercent <= 60 then
		newHeartbeatLevel = 2
	elseif healthPercent <= 80 then
		newHeartbeatLevel = 1
	end

	-- If the heartbeat level has changed, update the sound playback
	if newHeartbeatLevel ~= activeHeartbeatLevel then
		activeHeartbeatLevel = newHeartbeatLevel

		-- Stop whatever was playing
		StopActiveHeartbeat()
		-- Start the new heartbeat (if any)
		local soundFile
		if activeHeartbeatLevel == 4 then
			soundFile = heartbeatSoundFile4
		elseif activeHeartbeatLevel == 3 then
			soundFile = heartbeatSoundFile3
		elseif activeHeartbeatLevel == 2 then
			soundFile = heartbeatSoundFile2
		elseif activeHeartbeatLevel == 1 then
			soundFile = heartbeatSoundFile1
		end

		if soundFile then
			local willPlay, handle = PlaySoundFile(soundFile, "Master")
			if willPlay then
				activeHeartbeatHandle = handle
			else
				activeHeartbeatHandle = nil
			end
		end

		previousHealthPercent = healthPercent
	end
end

