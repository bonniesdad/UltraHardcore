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

function Colours:ByName(color, msg)
  local c = Colours[color]

  if c == nil then
    c = Colours["Reset"]
  end
  return c .. tostring(msg) .. Colours["Reset"]
end

function Colours:W(text)
  return Colours["White"] .. text .. Colours["Reset"]
end

function Colours:B(text)
  return Colours["Blue"] .. text .. Colours["Reset"]
end

function Colours:R(text)
  return Colours["Red"] .. text .. Colours["Reset"]
end

function Colours:Y(text)
  return Colours["Yellow"] .. text .. Colours["Reset"]
end

function Colours:G(text)
  return Colours["Green"] .. text .. Colours["Reset"]
end

_G.Colours = Colours
_G.Colors = Colours

