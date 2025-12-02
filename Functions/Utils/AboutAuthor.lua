-- Reusable About the Author component

UHC_AboutAuthor = UHC_AboutAuthor or {}

function UHC_CreateAboutAuthorSection(parent, point, relativeTo, relativePoint, xOfs, yOfs, width)
  width = width or 440

  -- About the Author section
  local aboutAuthorFrame = CreateFrame('Frame', nil, parent)
  aboutAuthorFrame:SetSize(width, 300) -- Increased height for new layout with title
  if point and relativeTo and relativePoint then
    aboutAuthorFrame:SetPoint(point, relativeTo, relativePoint, xOfs or 0, yOfs or 0)
  end

  -- Profile picture (left side) with gold border (tight to image)
  local profilePictureFrame = CreateFrame('Frame', nil, aboutAuthorFrame, 'BackdropTemplate')
  profilePictureFrame:SetSize(104, 104) -- Slightly larger to show border (2px border on each side)
  profilePictureFrame:SetPoint('TOPLEFT', aboutAuthorFrame, 'TOPLEFT', 0, 0)
  profilePictureFrame:SetBackdrop({
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 2,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  profilePictureFrame:SetBackdropBorderColor(0.8, 0.6, 0.2, 1) -- Gold border
  local profilePicture = profilePictureFrame:CreateTexture(nil, 'ARTWORK')
  profilePicture:SetSize(100, 100)
  profilePicture:SetPoint('CENTER', profilePictureFrame, 'CENTER', 0, 0)
  profilePicture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\profile-picture.png')
  profilePicture:SetTexCoord(0, 1, 0, 1)

  -- About the Author title (first row, right of profile picture, bigger font)
  local aboutAuthorTitle =
    aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
  aboutAuthorTitle:SetPoint('LEFT', profilePictureFrame, 'RIGHT', 15, 0)
  aboutAuthorTitle:SetPoint('TOP', profilePictureFrame, 'TOP', 0, 0)
  aboutAuthorTitle:SetText('About the Author')
  aboutAuthorTitle:SetTextColor(0.922, 0.871, 0.761)

  -- Bonnie's Dad streams text (right of profile picture, below About the Author)
  local streamsTitle = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  streamsTitle:SetPoint('TOPLEFT', aboutAuthorTitle, 'BOTTOMLEFT', 0, -8)
  streamsTitle:SetText('BonniesDadTV streams on twitch')
  streamsTitle:SetTextColor(0.922, 0.871, 0.761)

  -- Stream schedule text
  local streamSchedule = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  streamSchedule:SetPoint('TOPLEFT', streamsTitle, 'BOTTOMLEFT', 0, -8)
  streamSchedule:SetText('10am - 5pm GMT every weekday')
  streamSchedule:SetTextColor(0.8, 0.8, 0.8)

  -- About the Author text (below profile picture and stream info) - full width
  local aboutText = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  aboutText:SetPoint('TOPLEFT', profilePictureFrame, 'BOTTOMLEFT', 0, -15)
  aboutText:SetWidth(width) -- Full width
  aboutText:SetText(
    'What started as learning .lua code between his day job as a developer has grown into something much bigger.\n\nWith help from the community sharing ideas and feedback, ULTRA evolved from a simple pet project into the addon you see today.\n\nWe have since grown into a team of developers who are passionate about creating a fun and challenging experience for players.\n\nYou can catch us coding live on stream. We fix bugs in real-time, chat about new features, and turn your suggestions into reality. Feel free to drop by!'
  )
  aboutText:SetJustifyH('LEFT')
  aboutText:SetNonSpaceWrap(false) -- Allow line breaks
  aboutText:SetTextColor(0.8, 0.8, 0.8)

  return aboutAuthorFrame
end
