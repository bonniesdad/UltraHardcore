--[[ As an american, I had to rewrite this from Color to Colours,
so as not to infuriate everyone else developing this addon.
For the record, Wikipedia says "Color" is the spelling
https://en.wikipedia.org/wiki/Color
I hope you appreciate the effort, because I care about all of you.  - Wootenblatz ]]


-- If you want to add more, this page has lots of options https://www.rapidtables.com/web/color/index.html

local Colours = {
  Reset = '|r',
  White = '|cffFFFFFF',
  Lavendar = '|cffE6E6FA',
  Violet = '|cff9400D3',
  Indigo = '|cff4B0082',
  Blue = '|cff0000FF',
  Red = '|cffFF4444',
  Yellow = '|cffffd000',
  Green = '|cff33F24C',
  Black = '|cff000000',
  Gray = '|cff808080',
  Silver = '|cffC0C0C0',
  LightBlue = '|cff87CEFA',
  DarkBlue = '|cff00008B',
  Cyan = '|cff00FFFF',
  Teal = '|cff008080',
  Orange = '|cffFFA500',
  OrangeRed = '|cffFF4500',
  Pink = '|cffFFC0CB',
  HotPink = '|cffFF69B4',
  DeepPink = '|cffFF1493',
  DarkGreen = '|cff006400',
  Chartreuse = '|cff7FFF00',
  Lime = '|cff00FF00',
  Snow = '|cffFFFAFA',
  Beige = '|cffF5F5DC',
  LightYellow = '|cffF5F5DC',
}

--- Returns the message wrapped in the specified colour with the |r reset value automatically appended.
-- @param color The name of the colour to use.
-- @param msg The message to wrap in colour.
-- @return The coloured message, or the message wrapped in reset codes if the colour is not found.
function Colours:ByName(color, msg)
  local c = Colours[color]

  if c == nil then
    c = Colours["Reset"]
  end
  return c .. tostring(msg) .. Colours["Reset"]
end

--- Returns the message wrapped in white colour codes.
-- @param text The message to wrap in white.
-- @return The message wrapped in white colour codes.
function Colours:W(text)
  return Colours["White"] .. text .. Colours["Reset"]
end

--- Returns the message wrapped in blue colour codes.
-- @param text The message to wrap in blue.
-- @return The message wrapped in blue colour codes.
function Colours:B(text)
  return Colours["Blue"] .. text .. Colours["Reset"]
end

--- Returns the message wrapped in red colour codes.
-- @param text The message to wrap in red.
-- @return The message wrapped in red colour codes.
function Colours:R(text)
  return Colours["Red"] .. text .. Colours["Reset"]
end

--- Returns the message wrapped in yellow colour codes.
-- @param text The message to wrap in yellow.
-- @return The message wrapped in yellow colour codes.
function Colours:Y(text)
  return Colours["Yellow"] .. text .. Colours["Reset"]
end

--- Returns the message wrapped in green colour codes.
-- @param text The message to wrap in green.
-- @return The message wrapped in green colour codes.
function Colours:G(text)
  return Colours["Green"] .. text .. Colours["Reset"]
end

_G.Colours = Colours
_G.Colors = Colours

