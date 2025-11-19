-- Utility function to format numbers with comma separators
function formatNumberWithCommas(number)
  if type(number) ~= 'number' then
    number = tonumber(number) or 0
  end

  local isNegative = number < 0
  if isNegative then
    number = -number
  end

  local formatted = tostring(math.floor(number))
  local k
  while true do
    formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
    if k == 0 then
      break
    end
  end

  if isNegative then
    formatted = '-' .. formatted
  end

  return formatted
end

function getDigitsFromString(num)
    local num_str = tostring(num)
    local digits = {}
    for i = 1, #num_str do
        table.insert(digits, tonumber(num_str:sub(i, i)))
    end
    return digits
end
