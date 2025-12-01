-- Reusable Discord invite dialog and button helpers

UHC_DiscordInvite = UHC_DiscordInvite or {}

do
  local dialogFrame
  local editBox
  local inviteUrl = 'https://discord.gg/zuSPDNhYEN'

  function UHC_DiscordInvite_ShowDialog()
    if dialogFrame and dialogFrame:IsShown() then
      dialogFrame:Raise()
      if editBox then
        if C_Timer and C_Timer.After then
          C_Timer.After(0.05, function()
            editBox:SetFocus()
            editBox:HighlightText()
            editBox:SetCursorPosition(0)
            dialogFrame:Raise()
          end)
        else
          editBox:SetFocus()
          editBox:HighlightText()
          editBox:SetCursorPosition(0)
          dialogFrame:Raise()
        end
      end
      return
    end

    if not dialogFrame then
      dialogFrame = CreateFrame('Frame', 'UltraHardcoreDiscordDialog', UIParent, 'BackdropTemplate')
      dialogFrame:SetFrameStrata('FULLSCREEN_DIALOG')
      dialogFrame:SetToplevel(true)
      dialogFrame:SetSize(420, 145)
      dialogFrame:SetPoint('CENTER')
      -- Solid black background texture (fully opaque)
      local bgTexture = dialogFrame:CreateTexture(nil, 'BACKGROUND')
      bgTexture:SetAllPoints()
      bgTexture:SetColorTexture(0, 0, 0, 1) -- Almost black background
      dialogFrame:SetBackdrop({
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
      dialogFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

      local title = dialogFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
      title:SetPoint('TOP', dialogFrame, 'TOP', 0, -16)
      title:SetText('Discord Invite')
      title:SetJustifyH('CENTER')

      local message = dialogFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      message:SetPoint('TOP', title, 'BOTTOM', 0, -8)
      message:SetWidth(380)
      message:SetJustifyH('CENTER')
      message:SetNonSpaceWrap(true)
      message:SetText('Copy the invite link below and paste it into your web browser:')

      editBox = CreateFrame('EditBox', nil, dialogFrame, 'InputBoxTemplate')
      editBox:SetSize(360, 30)
      editBox:SetPoint('TOP', message, 'BOTTOM', 0, -10)
      editBox:SetAutoFocus(false)
      editBox:SetText(inviteUrl)
      editBox:SetScript('OnEscapePressed', function(self)
        self:ClearFocus()
      end)
      editBox:SetScript('OnEditFocusGained', function(self)
        self:HighlightText()
      end)

      local closeButton = CreateFrame('Button', nil, dialogFrame, 'UIPanelButtonTemplate')
      closeButton:SetSize(100, 22)
      closeButton:SetText('Close')
      closeButton:SetPoint('TOP', editBox, 'BOTTOM', 0, -8)
      closeButton:SetScript('OnClick', function()
        dialogFrame:Hide()
      end)

      dialogFrame:SetScript('OnShow', function()
        if editBox then
          editBox:SetText(inviteUrl)
          if C_Timer and C_Timer.After then
            C_Timer.After(0.05, function()
              editBox:SetFocus()
              editBox:HighlightText()
              editBox:SetCursorPosition(0)
              dialogFrame:Raise()
            end)
          else
            editBox:SetFocus()
            editBox:HighlightText()
            editBox:SetCursorPosition(0)
            dialogFrame:Raise()
          end
        end
      end)
    end

    dialogFrame:Show()
    dialogFrame:Raise()
  end

  function UHC_CreateDiscordInviteButton(
  parent,
    point,
    relativeTo,
    relativePoint,
    xOfs,
    yOfs,
    width,
    height,
    label
  )
    local button = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
    if width and height then
      button:SetSize(width, height)
    end
    if point and relativeTo and relativePoint then
      button:SetPoint(point, relativeTo, relativePoint, xOfs or 0, yOfs or 0)
    end
    button:SetText(label or 'Discord Invite Link')
    button:SetScript('OnClick', function()
      UHC_DiscordInvite_ShowDialog()
    end)
    return button
  end
end
