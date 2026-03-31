-- Function to abandon pet when it dies
function CheckAndAbandonPet()
  if not GLOBAL_SETTINGS.petsDiePermanently then return end

  -- Check if player has a pet
  if not UnitExists('pet') then return end

  -- Check if pet is dead
  local isDead = UnitIsDead('pet')
  if not isDead then return end

  -- Check if the player is a hunter
  local _, playerClass = UnitClass('player')
  if playerClass ~= 'HUNTER' then return end

  if GLOBAL_SETTINGS.isDueling then
    DEFAULT_CHAT_FRAME:AddMessage(
      '|cFFFF0000[ULTRA]|r You are dueling, so your pet will not be abandoned.',
      1,
      0,
      0
    )
    return
  end

  -- Pet is dead, abandon it immediately
  PetAbandon()
  DEFAULT_CHAT_FRAME:AddMessage(
    '|cFFFF0000[ULTRA]|r Your pet has died and been abandoned.',
    1,
    0,
    0
  )
end
