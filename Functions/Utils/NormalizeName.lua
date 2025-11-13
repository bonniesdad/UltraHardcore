-- Helper: normalize name to character name without realm
function NormalizeName(name)
  if not name then
    return nil
  end
  local short = name
  local dashPos = string.find(short, '-')
  if dashPos then
    short = string.sub(short, 1, dashPos - 1)
  end
  return short
end