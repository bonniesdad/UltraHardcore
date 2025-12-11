local Printing = {
    DEBUG = false,
    Prefix = Colours:Y("[") .. Colours:R("ULTRA") .. Colours:Y("]") .. " "
}

--- Enables debug mode for Printing. Debug messages will be printed when Printing:Debug(msg) is called.
function Printing:EnableDebug()
  self.DEBUG = true
end

--- Disables debug mode for Printing. Debug messages will not be printed when Printing:Debug(msg) is called.
function Printing:DisableDebug()
  self.DEBUG = false
end

--- Prints a debug message if debug mode is enabled. Use Printing:EnableDebug() to enable.
-- @param msg The debug message to print.
function Printing:Debug(msg)
  if self.DEBUG ~= true then
    return
  end
  print(self.Prefix .. "(" .. Colours:ByName("Orange", "DEBUG") .. ") " .. msg)
end

--- Prints a message with the Ultra prefix. Aliases Printing:Print and Printing:Msg.
-- @param msg The message to print.
function Printing:P(msg)
  print(self.Prefix .. msg)
end

--- Alias for Printing:P.
-- @param msg The message to print.
function Printing:Print(msg)
  return self:P(msg)
end

--- Alias for Printing:P.
-- @param msg The message to print.
function Printing:Msg(msg)
  return self:P(msg)
end

_G.Printing = Printing
