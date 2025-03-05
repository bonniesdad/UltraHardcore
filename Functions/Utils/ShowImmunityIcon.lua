function ShowImmunityIcon()
  local fontString = UIParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  fontString:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 150)
  fontString:SetText('You suspect this enemy\nis immune to your damage')
  fontString:SetTextColor(1, 1, 1)
  fontString:SetAlpha(1)
  fontString:SetFont('Fonts\\FRIZQT__.TTF', 18, 'OUTLINE')

  C_Timer.After(4, function()
    fontString:SetAlpha(0)
  end)
end
