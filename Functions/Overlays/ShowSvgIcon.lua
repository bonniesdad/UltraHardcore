local svgIconFrame
local svgTextureLoaded = false
local svgTexturePath = "Interface\\AddOns\\UltraHardcore\\Textures\\icn_hs.svg"

local function TrimString(text)
  if type(text) ~= "string" then
    return ""
  end

  local trimmed = text:match("^%s*(.-)%s*$")
  if not trimmed then
    return ""
  end

  return trimmed
end

local function EnsureSvgIconFrame()
  if svgIconFrame and svgIconFrame.texture then
    return svgIconFrame
  end

  if not UIParent then
    return nil
  end

  svgIconFrame = CreateFrame("Frame", "UltraHardcoreSvgIconFrame", UIParent)
  svgIconFrame:SetSize(64, 64)
  svgIconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 160)
  svgIconFrame:SetFrameStrata("HIGH")
  svgIconFrame:SetClampedToScreen(true)
  svgIconFrame:EnableMouse(true)
  svgIconFrame:SetMovable(true)
  svgIconFrame:RegisterForDrag("LeftButton")
  svgIconFrame:SetScript("OnDragStart", svgIconFrame.StartMoving)
  svgIconFrame:SetScript("OnDragStop", svgIconFrame.StopMovingOrSizing)

  local texture = svgIconFrame:CreateTexture(nil, "ARTWORK")
  svgIconFrame.texture = texture
  texture:SetAllPoints()

  local loadResult = texture:SetTexture(svgTexturePath)
  svgTextureLoaded = loadResult and true or false

  if not svgTextureLoaded then
    texture:SetColorTexture(0.6, 0.1, 0.1, 0.8)
  end

  local statusText = svgIconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  svgIconFrame.statusText = statusText
  statusText:SetPoint("TOP", svgIconFrame, "BOTTOM", 0, -4)
  if svgTextureLoaded then
    statusText:SetText("@Textures/icn_hs.svg reportedly loaded")
  else
    statusText:SetText("SVG failed; convert to PNG/BLP/TGA")
  end

  svgIconFrame:Hide()

  return svgIconFrame
end

function UltraHardcore_ShowSvgIcon()
  local frame = EnsureSvgIconFrame()
  if not frame then
    print("UltraHardcore: UI not ready for SVG test frame.")
    return
  end

  frame:Show()
end

function UltraHardcore_HideSvgIcon()
  if svgIconFrame then
    svgIconFrame:Hide()
  end
end

SLASH_UHCSVG1 = "/uhcsvg"
SlashCmdList["UHCSVG"] = function(msg)
  local command = string.lower(TrimString(msg))

  if command == "hide" or command == "off" then
    UltraHardcore_HideSvgIcon()
    print("UltraHardcore: SVG test frame hidden.")
    return
  end

  UltraHardcore_ShowSvgIcon()
  if svgTextureLoaded then
    print("UltraHardcore: Client reported icn_hs.svg loaded; if nothing appears, SVGs are not rendered.")
  else
    print("UltraHardcore: Client could not render the SVG; showing fallback block.")
  end
end


