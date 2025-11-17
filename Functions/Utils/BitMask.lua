-- Maybe move these to a globals file?
MINIMAP_FLAG_CLOCK  = 0x01 -- 0001
MINIMAP_FLAG_MAIL = 0x02 -- 0010
miniMapMask = 0x0

function HasFlag(mask, flag)
  return bit.band(mask, flag) ~= 0
end

function AddFlag(mask, flag)
  return bit.bor(mask, flag)
end

function RemoveFlag(mask, flag)
  return bit.band(mask, bit.bnot(flag))
end