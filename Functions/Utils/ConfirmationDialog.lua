-- Reusable Confirmation Dialog Utility
-- Provides a simple, clean confirmation dialog that can be reused throughout the addon

local confirmationDialog = nil

-- Show a confirmation dialog
-- @param title string - The title of the dialog
-- @param message string - The message to display
-- @param onConfirm function - Callback when user confirms
-- @param onCancel function (optional) - Callback when user cancels
-- @param confirmText string (optional) - Text for confirm button (default: "Confirm")
-- @param cancelText string (optional) - Text for cancel button (default: "Cancel")
function ShowConfirmationDialog(title, message, onConfirm, onCancel, confirmText, cancelText)
  confirmText = confirmText or 'Confirm'
  cancelText = cancelText or 'Cancel'

  -- Create dialog if it doesn't exist
  if not confirmationDialog then
    confirmationDialog =
      CreateFrame('Frame', 'UltraHardcoreConfirmationDialog', UIParent, 'BackdropTemplate')
    confirmationDialog:SetFrameStrata('FULLSCREEN_DIALOG')
    confirmationDialog:SetFrameLevel(100)
    confirmationDialog:SetToplevel(true)
    confirmationDialog:SetSize(400, 120)
    confirmationDialog:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
    confirmationDialog:SetMovable(true)
    confirmationDialog:EnableMouse(true)
    confirmationDialog:RegisterForDrag('LeftButton')
    confirmationDialog:SetScript('OnDragStart', function(self)
      self:StartMoving()
    end)
    confirmationDialog:SetScript('OnDragStop', function(self)
      self:StopMovingOrSizing()
    end)

    -- Background
    local bg = confirmationDialog:CreateTexture(nil, 'BACKGROUND')
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.9)
    confirmationDialog:SetBackdrop({
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = false,
      edgeSize = 16,
      insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
      },
    })
    confirmationDialog:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Title
    local titleText = confirmationDialog:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    titleText:SetPoint('TOP', confirmationDialog, 'TOP', 0, -16)
    titleText:SetText(title)
    titleText:SetJustifyH('CENTER')
    confirmationDialog.titleText = titleText

    -- Message
    local messageText = confirmationDialog:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    messageText:SetPoint('TOP', titleText, 'BOTTOM', 0, -12)
    messageText:SetWidth(360)
    messageText:SetJustifyH('CENTER')
    messageText:SetJustifyV('TOP')
    messageText:SetNonSpaceWrap(true)
    confirmationDialog.messageText = messageText

    -- Confirm button
    local confirmButton = CreateFrame('Button', nil, confirmationDialog, 'UIPanelButtonTemplate')
    confirmButton:SetSize(140, 30)
    confirmButton:SetPoint('BOTTOM', confirmationDialog, 'BOTTOM', -70, 16)
    confirmationDialog.confirmButton = confirmButton

    -- Cancel button
    local cancelButton = CreateFrame('Button', nil, confirmationDialog, 'UIPanelButtonTemplate')
    cancelButton:SetSize(100, 30)
    cancelButton:SetPoint('BOTTOM', confirmationDialog, 'BOTTOM', 70, 16)
    confirmationDialog.cancelButton = cancelButton
  end

  -- Reset position to center each time (in case user moved it somewhere weird)
  confirmationDialog:ClearAllPoints()
  confirmationDialog:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)

  -- Update dialog content
  confirmationDialog.titleText:SetText(title)
  confirmationDialog.messageText:SetText(message)
  confirmationDialog.confirmButton:SetText(confirmText)
  confirmationDialog.cancelButton:SetText(cancelText)

  -- Auto-size dialog based on message (estimate based on line count)
  local lineCount = math.ceil(#message / 50) -- Rough estimate: ~50 chars per line
  local minHeight = 120
  local calculatedHeight = math.max(minHeight, 80 + (lineCount * 15) + 50) -- Title + message lines + buttons
  confirmationDialog:SetHeight(calculatedHeight)

  -- Set callbacks
  confirmationDialog.onConfirm = onConfirm
  confirmationDialog.onCancel = onCancel

  -- Button handlers
  confirmationDialog.confirmButton:SetScript('OnClick', function()
    confirmationDialog:Hide()
    if confirmationDialog.onConfirm then
      confirmationDialog.onConfirm()
    end
  end)

  confirmationDialog.cancelButton:SetScript('OnClick', function()
    confirmationDialog:Hide()
    if confirmationDialog.onCancel then
      confirmationDialog.onCancel()
    end
  end)

  -- Show dialog
  confirmationDialog:Show()
end

-- Hide the confirmation dialog
function HideConfirmationDialog()
  if confirmationDialog then
    confirmationDialog:Hide()
  end
end

-- Make functions globally accessible
_G.ShowConfirmationDialog = ShowConfirmationDialog
_G.HideConfirmationDialog = HideConfirmationDialog
