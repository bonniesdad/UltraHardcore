--[[ As an american, I had to rewrite this from Color to Colours,
so as not to infuriate everyone else developing this addon.
For the record, Wikipedia says "Color" is the spelling
https://en.wikipedia.org/wiki/Color
I hope you appreciate the effort, because I care about all of you.  - Wootenblatz ]]


-- If you want to add more, this page has lots of options https://www.rapidtables.com/web/color/index.html

local colours = {
  Reset = '|r',
  White = '|cfFFFFFF',
  Lavendar = '|cfE6E6FA',
  Violet = '|cf9400D3',
  Indigo = '|cf4B0082',
  Blue = '|cff0000FF',
  Red = '|cffFF4444',
  Yellow = '|cffffd000',
  Green = '|cff33F24C',
  Black = '|cf000000',
  Gray = '|cf808080',
  Silver = '|cfC0C0C0',
  LightBlue = '|cf87CEFA',
  DarkBlue = '|cf00008B',
  Cyan = '|cf00FFFF',
  Teal = '|cf008080',
  Orange = '|cfFFA500',
  OrangeRed = '|cfFF4500',
  Pink = '|cfFFC0CB',
  HotPink = '|cfFF69B4',
  DeepPink = '|cfFF1493',
  DarkGreen = '|cf006400',
  Chartreuse = '|cf7FFF00',
  Lime = '|cf00FF00',
  Snow = '|cfFFFAFA',
  Beige = '|cfF5F5DC',
  LightYellow = '|cfF5F5DC',
}

function Colours:Get(colour)
  local value = colours[colour]
  if value ~= nil then
      return value
  else
      return colours.White
  end
end

function Colours:ByName(colour, msg)
  return self:Get(colour) .. msg .. self:Reset()
end

function Colours:Reset()
  return self.White
end

function Colours:White(text)
  return self.White .. text .. self:Reset()
end

function Colours:Blue(text)
  return self.Blue .. text .. self:Reset()
end

function Colours:Red(text)
  return self.Red .. text .. self:Reset()
end

function Colours:Yellow(text)
  return self.Yellow .. text .. self:Reset()
end

function Colours:Green(text)
  return self.Green .. text .. self:Reset()
end

_G.Colours = colours
_G.Colors = colours

