-- Utility function to check if the game is TBC or Classic
-- Returns true if TBC (expansion level > 0), false if Classic (expansion level = 0)
function IsTBC()
  if GetExpansionLevel() and GetExpansionLevel() > 0 then
    return true
  else
    return false
  end
end

-- Returns true if Classic (expansion level = 0), false if TBC
function IsClassic()
  return not IsTBC()
end
