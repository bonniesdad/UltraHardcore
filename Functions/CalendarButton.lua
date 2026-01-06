-- Calendar Button
-- Adds a calendar button to the top right of the screen

local calendarButton = nil

local function OpenCalendar()
  -- Load the Blizzard_Calendar addon if not already loaded
  if not IsAddOnLoaded('Blizzard_Calendar') then
    local loaded = LoadAddOn('Blizzard_Calendar')
    if not loaded then
      -- Try alternative method
      if UIParentLoadAddOn then
        UIParentLoadAddOn('Blizzard_Calendar')
      end
    end
  end
  -- Toggle the calendar
  if Calendar_Toggle then
    Calendar_Toggle()
  else
    -- Fallback: try to show calendar frame directly
    if CalendarFrame then
      if CalendarFrame:IsShown() then
        CalendarFrame:Hide()
      else
        CalendarFrame:Show()
      end
    end
  end
end

-- Position persistence functions
local function SaveCalendarButtonPosition()
  if not UltraHardcoreDB or not calendarButton then return end

  local point, _, relPoint, x, y = calendarButton:GetPoint()
  UltraHardcoreDB.calendarButtonPosition = {
    point = point,
    relPoint = relPoint,
    x = x,
    y = y,
  }
  if SaveDBData then
    SaveDBData('calendarButtonPosition', UltraHardcoreDB.calendarButtonPosition)
  end
end

local function LoadCalendarButtonPosition()
  if not UltraHardcoreDB or not calendarButton then return end

  local pos = UltraHardcoreDB.calendarButtonPosition
  calendarButton:ClearAllPoints()
  if pos then
    calendarButton:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    calendarButton:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -20, -20)
  end
end

local function UpdateCalendarButtonVisibility()
  if not calendarButton then return end

  -- Only show button if player is in ULTRA guild AND setting is enabled
  -- Check if function exists (should be available since TradeRestriction loads first)
  local shouldShow = false
  if IsUltraGuildMember and IsUltraGuildMember() then
    -- Check if calendar button is enabled in settings (default to true if not set)
    local hideCalendar = GLOBAL_SETTINGS and GLOBAL_SETTINGS.hideCalendarButton
    shouldShow = not hideCalendar
  end

  if shouldShow then
    calendarButton:Show()
  else
    calendarButton:Hide()
  end
end

local function CreateCalendarButton()
  if calendarButton then return end

  -- Create the button frame
  calendarButton = CreateFrame('Button', 'UltraHardcoreCalendarButton', UIParent)
  calendarButton:SetSize(64, 64)
  calendarButton:SetFrameStrata('HIGH')
  calendarButton:SetFrameLevel(10)
  calendarButton:SetMovable(true)
  calendarButton:SetClampedToScreen(true)
  calendarButton:EnableMouse(true)
  calendarButton:RegisterForDrag('LeftButton')

  -- Load saved position or use default
  LoadCalendarButtonPosition()

  -- Create the icon texture
  local icon = calendarButton:CreateTexture(nil, 'ARTWORK')
  icon:SetAllPoints(calendarButton)
  -- Use the standard calendar button texture from the game
  icon:SetTexture('Interface\\Calendar\\UI-Calendar-Button')
  -- The texture contains both normal and pressed states side by side
  -- Use SetTexCoord to show only the left half (normal state)
  -- Left, Right, Top, Bottom (0-1 coordinates)
  icon:SetTexCoord(0, 0.5, 0, 1)
  calendarButton.icon = icon

  -- Set click handler with error protection
  calendarButton:SetScript('OnClick', function(self, button)
    if button == 'LeftButton' then
      local success, err = pcall(OpenCalendar)
      if not success then
        print('|cfff44336[ULTRA]|r Error opening calendar: ' .. tostring(err))
      end
    end
  end)

  -- Add tooltip
  calendarButton:SetScript('OnEnter', function(self)
    if GameTooltip then
      GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
      GameTooltip:SetText('Calendar')
      GameTooltip:Show()
    end
  end)

  calendarButton:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)

  -- Make draggable and save position
  calendarButton:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)

  calendarButton:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    SaveCalendarButtonPosition()
  end)

  -- Register for guild events to update visibility
  local eventFrame = CreateFrame('Frame')
  eventFrame:RegisterEvent('PLAYER_GUILD_UPDATE')
  eventFrame:RegisterEvent('GUILD_ROSTER_UPDATE')
  eventFrame:SetScript('OnEvent', function()
    UpdateCalendarButtonVisibility()
  end)

  -- Set initial visibility based on guild membership
  UpdateCalendarButtonVisibility()
end

-- Function to update calendar button visibility when setting changes
function UpdateCalendarButtonFromSettings()
  UpdateCalendarButtonVisibility()
end

function InitializeCalendarButton()
  CreateCalendarButton()
end
