local printing = {
    DEBUG = false
}

local msgPrefix = Colours:Yellow("[") .. Colours:Red("ULTRA") .. Colours:Yellow("]") .. " "

function EnableDebug()
  self.DEBUG = true
end
function DisableDebug()
  self.DEBUG = false
end

function Printing:Debug(msg)
  if self.DEBUG ~= true then
    return
  end
  print(msgPrefix .. "(" .. Colours:Yellow("DEBUG") .. ") " .. msg)
end

function Printing:P(msg)
  print(msgPrefix .. msg)
end

function Printing:Print(msg)
  return self:P(msg)
end

function Printing:Msg(msg)
  return self:P(msg)
end

_G.Printing = printing
