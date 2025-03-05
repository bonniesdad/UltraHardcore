-- 🟢 Reset the vengeance score
function ResetVengeanceScore()
  vengeanceScore = 0
  SaveDBData('vengeanceScore', vengeanceScore)
end
