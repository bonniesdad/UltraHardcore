-- Deep copy for saving/loading option profiles (nested tables e.g. resourceBarColors)

function UHC_DeepCopy(orig, seen)
  if type(orig) ~= 'table' then
    return orig
  end
  seen = seen or {}
  if seen[orig] then
    return seen[orig]
  end
  local copy = {}
  seen[orig] = copy
  for k, v in pairs(orig) do
    copy[k] = UHC_DeepCopy(v, seen)
  end
  return copy
end
