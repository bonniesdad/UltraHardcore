function IsDungeonBoss(unitGUID)
  -- Extract NPC ID from GUID
  local npcID = tonumber(unitGUID:match("Creature%-.-%-.-%-.-%-.-%-(%d+)%-"))
  if not npcID then
    return false
  end
  
  -- Comprehensive list of WoW Classic dungeon boss NPC IDs
  local dungeonBossIDs = {
    -- Ragefire Chasm (Level 13-18)
    [11517] = true, -- Oggleflint
    [11520] = true, -- Taragaman the Hungerer
    [11518] = true, -- Jergosh the Invoker
    [11519] = true, -- Bazzalan
    
    -- The Deadmines (Level 15-21)
    [1666] = true,  -- Rhahk'Zor
    [643] = true,   -- Sneed
    [1763] = true,  -- Gilnid
    [646] = true,   -- Mr. Smite
    [647] = true,   -- Captain Greenskin
    [639] = true,   -- Edwin VanCleef
    
    -- Wailing Caverns (Level 15-25)
    [3671] = true,  -- Lady Anacondra
    [3669] = true,  -- Lord Cobrahn
    [3653] = true,  -- Kresh
    [3670] = true,  -- Lord Pythas
    [3674] = true,  -- Skum
    [3673] = true,  -- Lord Serpentis
    [3655] = true,  -- Verdan the Everliving
    [3654] = true,  -- Mutanus the Devourer
    
    -- Shadowfang Keep (Level 18-25)
    [3914] = true,  -- Rethilgore
    [3886] = true,  -- Razorclaw the Butcher
    [3887] = true,  -- Baron Silverlaine
    [4278] = true,  -- Commander Springvale
    [4279] = true,  -- Odo the Blindwatcher
    [4274] = true,  -- Fenrus the Devourer
    [3927] = true,  -- Wolf Master Nandos
    [4275] = true,  -- Archmage Arugal
    
    -- Blackfathom Deeps (Level 20-27)
    [4887] = true,  -- Ghamoo-ra
    [4831] = true,  -- Lady Sarevess
    [4830] = true,  -- Gelihast
    [4832] = true,  -- Lorgus Jett
    [12876] = true, -- Baron Aquanis
    [4832] = true,  -- Twilight Lord Kelris
    [4831] = true,  -- Old Serra'kis
    [4829] = true,  -- Aku'mai
    
    -- The Stockade (Level 22-30)
    [1716] = true,  -- Targorr the Dread
    [1666] = true,  -- Kam Deepfury
    [1717] = true,  -- Hamhock
    [1663] = true,  -- Dextren Ward
    [1715] = true,  -- Bazil Thredd
    
    -- Gnomeregan (Level 24-34)
    [7361] = true,  -- Grubbis
    [7079] = true,  -- Viscous Fallout
    [6235] = true,  -- Electrocutioner 6000
    [6235] = true,  -- Crowd Pummeler 9-60
    [7800] = true,  -- Mekgineer Thermaplugg
    
    -- Razorfen Kraul (Level 25-35)
    [6168] = true,  -- Roogug
    [4424] = true,  -- Aggem Thorncurse
    [4428] = true,  -- Death Speaker Jargba
    [4420] = true,  -- Overlord Ramtusk
    [4422] = true,  -- Agathelos the Raging
    [4421] = true,  -- Charlga Razorflank
    
    -- Scarlet Monastery (Level 26-45)
    [3983] = true,  -- Interrogator Vishas
    [4543] = true,  -- Bloodmage Thalnos
    [3974] = true,  -- Houndmaster Loksey
    [6487] = true,  -- Arcanist Doan
    [3975] = true,  -- Herod
    [4542] = true,  -- High Inquisitor Fairbanks
    [3976] = true,  -- Scarlet Commander Mograine
    [3977] = true,  -- High Inquisitor Whitemane
    
    -- Razorfen Downs (Level 35-40)
    [7355] = true,  -- Tuten'kash
    [7357] = true,  -- Mordresh Fire Eye
    [8567] = true,  -- Glutton
    [7354] = true,  -- Ragglesnout
    [7358] = true,  -- Amnennar the Coldbringer
    
    -- Uldaman (Level 35-45)
    [6910] = true,  -- Revelosh
    [7228] = true,  -- Ironaya
    [7023] = true,  -- Obsidian Sentinel
    [7206] = true,  -- Ancient Stone Keeper
    [7291] = true,  -- Galgann Firehammer
    [4854] = true,  -- Grimlok
    [2748] = true,  -- Archaedas
    
    -- Zul'Farrak (Level 42-46)
    [8127] = true,  -- Antu'sul
    [7272] = true,  -- Theka the Martyr
    [7271] = true,  -- Witch Doctor Zum'rah
    [7275] = true,  -- Nekrum Gutchewer
    [7274] = true,  -- Shadowpriest Sezz'ziz
    [7273] = true,  -- Chief Ukorz Sandscalp
    [7273] = true,  -- Gahz'rilla
    
    -- Maraudon (Level 45-52)
    [13282] = true, -- Noxxion
    [12258] = true, -- Razorlash
    [12236] = true, -- Lord Vyletongue
    [12225] = true, -- Celebras the Cursed
    [12203] = true, -- Landslide
    [13601] = true, -- Tinkerer Gizlock
    [13596] = true, -- Rotgrip
    [12201] = true, -- Princess Theradras
    
    -- Temple of Atal'Hakkar (Sunken Temple) (Level 50-60)
    [8580] = true,  -- Atal'alarion
    [14327] = true, -- Dreamscythe
    [14326] = true, -- Weaver
    [5710] = true,  -- Jammal'an the Prophet
    [5711] = true,  -- Ogom the Wretched
    [5712] = true,  -- Hazzas
    [5713] = true,  -- Morphaz
    [8443] = true,  -- Avatar of Hakkar
    [5709] = true,  -- Shade of Eranikus
    
    -- Blackrock Depths (Level 52-60)
    [9019] = true,  -- High Interrogator Gerstahn
    [9319] = true,  -- Houndmaster Grebmar
    [9025] = true,  -- Lord Roccor
    [9033] = true,  -- General Angerforge
    [8983] = true,  -- Golem Lord Argelmach
    [9537] = true,  -- Hurley Blackbreath
    [9502] = true,  -- Phalanx
    [9499] = true,  -- Plugger Spazzring
    [9156] = true,  -- Ambassador Flamelash
    [9035] = true,  -- Anger'rel
    [9036] = true,  -- Seeth'rel
    [9037] = true,  -- Dope'rel
    [9038] = true,  -- Gloom'rel
    [9039] = true,  -- Hate'rel
    [9040] = true,  -- Vile'rel
    [9041] = true,  -- Doom'rel
    [9938] = true,  -- Magmus
    [9017] = true,  -- Emperor Dagran Thaurissan
    
    -- Lower Blackrock Spire (Level 55-60)
    [9196] = true,  -- Highlord Omokk
    [9236] = true,  -- Shadow Hunter Vosh'gajin
    [9237] = true,  -- War Master Voone
    [10596] = true, -- Mother Smolderweb
    [10584] = true, -- Urok Doomhowl
    [9736] = true,  -- Quartermaster Zigris
    [10220] = true, -- Halycon
    [10268] = true, -- Gizrul the Slavener
    [9568] = true,  -- Overlord Wyrmthalak
    
    -- Upper Blackrock Spire (Level 55-60)
    [9816] = true,  -- Pyroguard Emberseer
    [10264] = true, -- Solakar Flamewreath
    [10899] = true, -- Goraluk Anvilcrack
    [10429] = true, -- Warchief Rend Blackhand
    [10430] = true, -- The Beast
    [10363] = true, -- General Drakkisath
    
    -- Dire Maul (Level 55-60)
    [11490] = true, -- Zevrim Thornhoof
    [13280] = true, -- Hydrospawn
    [14322] = true, -- Lethtendris
    [11492] = true, -- Alzzin the Wildshaper
    [11489] = true, -- Tendris Warpwood
    [11488] = true, -- Illyanna Ravenoak
    [11487] = true, -- Magister Kalendris
    [11496] = true, -- Immol'thar
    [11486] = true, -- Prince Tortheldrin
    [14326] = true, -- Guard Mol'dar
    [14322] = true, -- Stomper Kreeg
    [14324] = true, -- Guard Fengus
    [14325] = true, -- Guard Slip'kik
    [14321] = true, -- Captain Kromcrush
    [11501] = true, -- King Gordok
    
    -- Scholomance (Level 58-60)
    [10506] = true, -- Kirtonos the Herald
    [10503] = true, -- Jandice Barov
    [11622] = true, -- Rattlegore
    [10433] = true, -- Marduk Blackpool
    [10432] = true, -- Vectus
    [10508] = true, -- Ras Frostwhisper
    [11661] = true, -- Instructor Malicia
    [11261] = true, -- Doctor Theolen Krastinov
    [10901] = true, -- Lorekeeper Polkelt
    [10507] = true, -- The Ravenian
    [10504] = true, -- Lord Alexei Barov
    [10502] = true, -- Lady Illucia Barov
    [1853] = true,  -- Darkmaster Gandling
    
    -- Stratholme (Level 58-60)
    [10558] = true, -- The Unforgiven
    [10808] = true, -- Timmy the Cruel
    [10430] = true, -- Commander Malor
    [10997] = true, -- Willey Hopebreaker
    [10432] = true, -- Instructor Galford
    [10811] = true, -- Balnazzar
    [10436] = true, -- Baroness Anastari
    [10437] = true, -- Nerub'enkan
    [10438] = true, -- Maleki the Pallid
    [10435] = true, -- Magistrate Barthilas
    [10439] = true, -- Ramstein the Gorger
    [10440] = true, -- Lord Aurius Rivendare
  }
  
  return dungeonBossIDs[npcID] or false
end

function IsDungeonFinalBoss(unitGUID)
  -- Extract NPC ID from GUID
  local npcID = tonumber(unitGUID:match("Creature%-.-%-.-%-.-%-.-%-(%d+)%-"))
  if not npcID then
    return false
  end
  
  -- List of final bosses for each dungeon (the last boss that needs to be killed to complete the dungeon)
  local dungeonFinalBossIDs = {
    -- Ragefire Chasm (Level 13-18)
    [11519] = true, -- Bazzalan (final boss)
    
    -- The Deadmines (Level 15-21)
    [639] = true,   -- Edwin VanCleef (final boss)
    
    -- Wailing Caverns (Level 15-25)
    [3654] = true,  -- Mutanus the Devourer (final boss)
    
    -- Shadowfang Keep (Level 18-25)
    [4275] = true,  -- Archmage Arugal (final boss)
    
    -- Blackfathom Deeps (Level 20-27)
    [4829] = true,  -- Aku'mai (final boss)
    
    -- The Stockade (Level 22-30)
    [1715] = true,  -- Bazil Thredd (final boss)
    
    -- Gnomeregan (Level 24-34)
    [7800] = true,  -- Mekgineer Thermaplugg (final boss)
    
    -- Razorfen Kraul (Level 25-35)
    [4421] = true,  -- Charlga Razorflank (final boss)
    
    -- Scarlet Monastery (Level 26-45)
    [3977] = true,  -- High Inquisitor Whitemane (final boss of Cathedral)
    
    -- Razorfen Downs (Level 35-40)
    [7358] = true,  -- Amnennar the Coldbringer (final boss)
    
    -- Uldaman (Level 35-45)
    [2748] = true,  -- Archaedas (final boss)
    
    -- Zul'Farrak (Level 42-46)
    [7273] = true,  -- Chief Ukorz Sandscalp (final boss)
    
    -- Maraudon (Level 45-52)
    [12201] = true, -- Princess Theradras (final boss)
    
    -- Temple of Atal'Hakkar (Sunken Temple) (Level 50-60)
    [5709] = true,  -- Shade of Eranikus (final boss)
    
    -- Blackrock Depths (Level 52-60)
    [9017] = true,  -- Emperor Dagran Thaurissan (final boss)
    
    -- Lower Blackrock Spire (Level 55-60)
    [9568] = true,  -- Overlord Wyrmthalak (final boss)
    
    -- Upper Blackrock Spire (Level 55-60)
    [10363] = true, -- General Drakkisath (final boss)
    
    -- Dire Maul (Level 55-60)
    [11501] = true, -- King Gordok (final boss of North wing)
    
    -- Scholomance (Level 58-60)
    [1853] = true,  -- Darkmaster Gandling (final boss)
    
    -- Stratholme (Level 58-60)
    [10440] = true, -- Lord Aurius Rivendare (final boss)
  }
  
  return dungeonFinalBossIDs[npcID] or false
end
