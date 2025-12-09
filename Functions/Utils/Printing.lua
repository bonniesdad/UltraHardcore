local Printing = {
    DEBUG = false,
    Prefix = Colours:Y("[") .. Colours:R("ULTRA") .. Colours:Y("]") .. " "
}

function Printing:EnableDebug()
  self.DEBUG = true
end
function Printing:DisableDebug()
  self.DEBUG = false
end

function Printing:Debug(msg)
  if self.DEBUG ~= true then
    return
  end
  print(self.Prefix .. "(" .. Colours:ByName("Orange", "DEBUG") .. ") " .. msg)
end

function Printing:P(msg)
  print(self.Prefix .. msg)
end

function Printing:Print(msg)
  return self:P(msg)
end

function Printing:Msg(msg)
  return self:P(msg)
end

_G.Printing = Printing
