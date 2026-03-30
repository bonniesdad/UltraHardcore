-- Credits Tab Content - Same pattern as UltraHardcore CreditsTab
function InitializeCreditsTab(tabContents)
  if not tabContents or not tabContents[5] then return end
  if tabContents[5].initialized then return end
  tabContents[5].initialized = true

  local parent = tabContents[5]

  local contentBackground = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  contentBackground:SetPoint('TOP', parent, 'TOP', 0, -60)
  contentBackground:SetPoint('LEFT', parent, 'LEFT', 10, 0)
  contentBackground:SetPoint('RIGHT', parent, 'RIGHT', -10, 0)
  contentBackground:SetPoint('BOTTOM', parent, 'BOTTOM', 0, 30)
  contentBackground:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  contentBackground:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  contentBackground:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  local scrollFrame =
    CreateFrame('ScrollFrame', nil, contentBackground, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', contentBackground, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', contentBackground, 'BOTTOMRIGHT', -30, 10)

  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollChild:SetSize(1, 1)
  scrollFrame:SetScrollChild(scrollChild)

  local function updateScrollChildWidth()
    local gutter = 2
    local w = scrollFrame:GetWidth() - gutter
    if w and w > 0 then
      scrollChild:SetWidth(w)
    end
  end

  scrollFrame:SetScript('OnSizeChanged', function()
    updateScrollChildWidth()
  end)
  updateScrollChildWidth()

  local contentBgW = scrollChild:GetWidth()
  local aboutAuthorW = (contentBgW and contentBgW > 100) and (contentBgW - 40) or 470
  local aboutAuthorFrame =
    UHC_CreateAboutAuthorSection(
      scrollChild,
      'TOPLEFT',
      scrollChild,
      'TOPLEFT',
      10,
      -10,
      aboutAuthorW
    )

  local familyTitle = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  familyTitle:SetPoint('TOP', aboutAuthorFrame, 'BOTTOM', 0, 24)
  familyTitle:SetText('Ultra Family Addons')
  familyTitle:SetTextColor(0.922, 0.871, 0.761)

  local ADDON_BOX_SIZE = 80
  local ADDON_BOX_GAP = 12
  local ADDON_TITLE_GAP = 12
  local addonTitles = { 'Ultra HC', 'Ultra Stats', 'Ultra Found' }
  local addonTextures =
    {
      'Interface\\AddOns\\UltraHardcore\\Textures\\Ultra HC Icon.png',
      'Interface\\AddOns\\UltraHardcore\\Textures\\stats.png',
      'Interface\\AddOns\\UltraHardcore\\Textures\\bonnie-round.png',
    }
  local contentW = (contentBgW and contentBgW > 100) and contentBgW or 490
  local numAddons = #addonTitles
  local rowWidth = (ADDON_BOX_SIZE * numAddons) + (ADDON_BOX_GAP * (numAddons - 1))
  local rowStartX = math.max(10, (contentW - rowWidth) / 2)

  local addonRowBottom = familyTitle

  for i = 1, numAddons do
    local colX = rowStartX + (i - 1) * (ADDON_BOX_SIZE + ADDON_BOX_GAP)

    local titleLabel = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    titleLabel:SetPoint('TOP', familyTitle, 'BOTTOM', 0, -ADDON_TITLE_GAP)
    titleLabel:SetPoint('LEFT', scrollChild, 'LEFT', colX, 0)
    titleLabel:SetWidth(ADDON_BOX_SIZE)
    titleLabel:SetJustifyH('CENTER')
    titleLabel:SetText(addonTitles[i])
    titleLabel:SetTextColor(0.922, 0.871, 0.761)

    local box = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    box:SetSize(ADDON_BOX_SIZE, ADDON_BOX_SIZE)
    box:SetPoint('TOP', titleLabel, 'BOTTOM', 0, -ADDON_TITLE_GAP)
    box:SetPoint('LEFT', scrollChild, 'LEFT', colX, 0)
    local tex = box:CreateTexture(nil, 'BACKGROUND')
    tex:SetTexture(addonTextures[i])
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    tex:SetPoint('CENTER', box, 'CENTER', 0, 0)
    tex:SetSize(ADDON_BOX_SIZE * 0.9, ADDON_BOX_SIZE * 0.9)
    box:SetBackdrop({
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      edgeSize = 12,
      insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
      },
    })
    box:SetBackdropBorderColor(0.6, 0.5, 0.35, 0.9)

    addonRowBottom = box
  end

  local joinDeveloperText = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  joinDeveloperText:SetPoint('TOP', addonRowBottom, 'BOTTOM', 0, -24)
  joinDeveloperText:SetPoint('LEFT', scrollChild, 'LEFT', 8, 0)
  joinDeveloperText:SetPoint('RIGHT', scrollChild, 'RIGHT', -8, 0)
  joinDeveloperText:SetText(
    "Join the developers' Discord community and Twitch channel to help support us and have your say on the future of this addon!"
  )
  joinDeveloperText:SetJustifyH('CENTER')
  joinDeveloperText:SetTextColor(0.95, 0.95, 0.9)
  joinDeveloperText:SetNonSpaceWrap(true)

  local BUTTON_W = 220

  local discordButton =
    UHC_CreateDiscordInviteButton(
      scrollChild,
      'TOP',
      joinDeveloperText,
      'BOTTOM',
      0,
      -10,
      BUTTON_W,
      24,
      'Discord Invite Link'
    )

  local twitchButton =
    UHC_CreateTwitchInviteButton(
      scrollChild,
      'TOP',
      discordButton,
      'BOTTOM',
      0,
      0,
      BUTTON_W,
      28,
      'Twitch Channel'
    )

  local function finalizeScrollHeight()
    updateScrollChildWidth()
    joinDeveloperText:SetWidth(scrollChild:GetWidth() - 16)
    local jh = (joinDeveloperText.GetStringHeight and joinDeveloperText:GetStringHeight()) or 56
    local h =
      10 + 300 + 24 + 20 + ADDON_TITLE_GAP + 12 + ADDON_TITLE_GAP + ADDON_BOX_SIZE + 24 + jh + 10 + 24 + 28 + 28
    scrollChild:SetHeight(math.max(200, h))
  end

  scrollFrame:SetScript('OnSizeChanged', function()
    updateScrollChildWidth()
    finalizeScrollHeight()
  end)

  C_Timer.After(0, finalizeScrollHeight)
end
