-- Maybe move these to a globals file?
function HasFlag(mask, flag)
  return bit.band(mask, flag) ~= 0
end

function AddFlag(mask, flag)
  return bit.bor(mask, flag)
end

function RemoveFlag(mask, flag)
  return bit.band(mask, bit.bnot(flag))
end