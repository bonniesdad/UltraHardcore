function IsDungeonBoss(unitGUID)

  -- Early return if player isn't in a dungeon or raid instance
  local inInstance, instanceType = IsInInstance()
  if not inInstance or (instanceType ~= "party" and instanceType ~= "raid") then
      return false, false
  end
  
  -- Extract NPC ID from GUID (5th numeric segment; allow trailing hex)
  local npcID = tonumber(unitGUID:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$"))
              or tonumber(unitGUID:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)$"))
  if not npcID then
    return false, false
  end
  
  -- Comprehensive list of WoW Classic dungeon boss NPC IDs
  local dungeonBossIDs = {
    -- Ragefire Chasm (Zone ID: 2437)
    [11520] = true, -- Taragaman the Hungerer
    [11517] = true, -- Oggleflint
    [11518] = true, -- Jergosh the Invoker
    [11519] = true, -- Bazzalan
    
    -- The Deadmines (Zone ID: 1581)
    [644] = true,   -- Rhahk'Zor
    [3586] = true,  -- Miner Johnson (Rare)
    [643] = true,   -- Sneed's Shredder
    [1763] = true,  -- Gilnid
    [646] = true,   -- Mr. Smite
    [647] = true,   -- Captain Greenskin
    [639] = true,   -- Edwin VanCleef
    [645] = true,   -- Cookie (Bonus)
    
    -- Wailing Caverns (Zone ID: 718)
    [3653] = true,  -- Kresh
    [3671] = true,  -- Lady Anacondra
    [3669] = true,  -- Lord Cobrahn
    [5912] = true,  -- Deviate Faerie Dragon (Rare)
    [3670] = true,  -- Lord Pythas
    [3674] = true,  -- Skum
    [3673] = true,  -- Lord Serpentis
    [5775] = true,  -- Verdan the Everliving
    [3654] = true,  -- Mutanus the Devourer
    
    -- Shadowfang Keep (Zone ID: 209)
    [3914] = true,  -- Rethilgore
    [3886] = true,  -- Razorclaw the Butcher
    [3887] = true,  -- Baron Silverlaine
    [4278] = true,  -- Commander Springvale
    [4279] = true,  -- Odo the Blindwatcher
    [3872] = true,  -- Deathsworn Captain
    [4274] = true,  -- Fenrus the Devourer
    [3927] = true,  -- Wolf Master Nandos
    [4275] = true,  -- Archmage Arugal
    [14682] = true, -- Sever (scourge)
    
    -- Blackfathom Deeps (Zone ID: 719)
    [4887] = true,  -- Ghamoo-ra
    [4831] = true,  -- Lady Sarevess
    [6243] = true,  -- Gelihast
    [12902] = true, -- Lorgus Jett
    [12876] = true, -- Baron Aquanis
    [4832] = true,  -- Twilight Lord Kelris
    [4830] = true,  -- Old Serra'kis
    [4829] = true,  -- Aku'mai
    
    -- The Stockade (Zone ID: 717)
    [1696] = true,  -- Targorr the Dread
    [1666] = true,  -- Kam Deepfury
    [1717] = true,  -- Hamhock
    [1663] = true,  -- Dextren Ward
    [1716] = true,  -- Bazil Thredd
    [1720] = true,  -- Bruegal Ironknuckle (Rare)
    
    -- Gnomeregan (Zone ID: 721)
    [7361] = true,  -- Grubbis
    [7079] = true,  -- Viscous Fallout
    [6235] = true,  -- Electrocutioner 6000
    [6229] = true,  -- Crowd Pummeler 9-60
    [6228] = true,  -- Dark Iron Ambassador
    [7800] = true,  -- Mekgineer Thermaplugg
    
    -- Razorfen Kraul (Zone ID: 491)
    [6168] = true,  -- Roogug
    [4424] = true,  -- Aggem Thorncurse
    [4428] = true,  -- Death Speaker Jargba
    [4420] = true,  -- Overlord Ramtusk
    [4422] = true,  -- Agathelos the Raging
    [4421] = true,  -- Charlga Razorflank
    
    -- Scarlet Monastery (Zone ID: 796)
    [3983] = true,  -- Interrogator Vishas
    [4543] = true,  -- Bloodmage Thalnos
    [6490] = true,  -- Azshir the Sleepless (Rare)
    [6488] = true,  -- Fallen Champion (Rare)
    [6489] = true,  -- Ironspine (Rare)
    [3974] = true,  -- Houndmaster Loksey
    [6487] = true,  -- Arcanist Doan
    [3975] = true,  -- Herod
    [3976] = true,  -- Scarlet Commander Mograine
    [3977] = true,  -- High Inquisitor Whitemane
    [4542] = true,  -- High Inquisitor Fairbanks
    [14693] = true, -- Scorn (scourge)
    
    -- Razorfen Downs (Zone ID: 722)
    [7355] = true,  -- Tuten'kash
    [7356] = true,  -- Plaguemaw the Rotting
    [7357] = true,  -- Mordresh Fire Eye
    [7354] = true,  -- Ragglesnout
    [8567] = true,  -- Glutton
    [7358] = true,  -- Amnennar the Coldbringer
    [14686] = true, -- Lady Falther'ess (scourge)
    
    -- Uldaman (Zone ID: 1337)
    [6910] = true,  -- Revelosh
    [6906] = true,  -- Baelog
    [7228] = true,  -- Ironaya
    [7023] = true,  -- Obsidian Sentinel
    [7206] = true,  -- Ancient Stone Keeper
    [7291] = true,  -- Galgann Firehammer
    [4854] = true,  -- Grimlok
    [2748] = true,  -- Archaedas
    
    -- Maraudon (Zone ID: 2100)
    [13282] = true, -- Noxxion
    [12258] = true, -- Razorlash
    [12236] = true, -- Lord Vyletongue
    [12225] = true, -- Celebras the Cursed
    [12203] = true, -- Landslide
    [13601] = true, -- Tinkerer Gizlock
    [13596] = true, -- Rotgrip
    [12201] = true, -- Princess Theradras
    
    -- Zul'Farrak (Zone ID: 1176)
    [8127] = true,  -- Antu'sul
    [7272] = true,  -- Theka the Martyr
    [7271] = true,  -- Witch Doctor Zum'rah
    [7796] = true,  -- Nekrum Gutchewer
    [7275] = true,  -- Shadowpriest Sezz'ziz
    [7604] = true,  -- Sergeant Bly
    [7795] = true,  -- Hydromancer Velratha
    [10081] = true, -- Dustwraith (Rare)
    [7267] = true,  -- Chief Ukorz Sandscalp
    [7797] = true,  -- Ruuzlu
    [10082] = true, -- Zerillis (Rare)
    [10080] = true, -- Sandarr Dunereaver (Rare)

    -- Maraudon (Zone ID: 2100)
    [13282] = true, -- Noxxion
    [12258] = true, -- Razorlash
    [12236] = true, -- Lord Vyletongue
    [12237] = true, -- Meshlok the Harvester (rare)
    [12225] = true, -- Celebras the Cursed
    [12203] = true, -- Landslide
    [13601] = true, -- Tinkerer Gizlock
    [13596] = true, -- Rotgrip
    [12201] = true, -- Princess Theradras
    
    -- The Temple of Atal'Hakkar (Zone ID: 1477)
    [5713] = true,  -- Atal'ai Defenders
    [8580] = true,  -- Atal'alarion
    [5721] = true,  -- Dreamscythe
    [5720] = true,  -- Weaver
    [5710] = true,  -- Jammal'an the Prophet
    [5711] = true,  -- Ogom the Wretched
    [5719] = true,  -- Morphaz
    [5722] = true,  -- Hazzas
    [8443] = true,  -- Avatar of Hakkar
    [5709] = true,  -- Shade of Eranikus
    
    -- Blackrock Depths (Zone ID: 1584)
    [9025] = true,  -- Lord Roccor
    [9016] = true,  -- Bael'Gar
    [9319] = true,  -- Houndmaster Grebmar
    [9018] = true,  -- High Interrogator Gerstahn
    [10096] = true, -- High Justice Grimstone
    [9024] = true,  -- Pyromancer Loregrain
    [9033] = true,  -- General Angerforge
    [8983] = true,  -- Golem Lord Argelmach
    [9543] = true,  -- Ribbly Screwspigot
    [9537] = true,  -- Hurley Blackbreath
    [9499] = true,  -- Plugger Spazzring
    [9502] = true,  -- Phalanx
    [9017] = true,  -- Lord Incendius
    [9056] = true,  -- Fineous Darkvire
    [9041] = true,  -- Warder Stilgiss
    [9042] = true,  -- Verek
    [9156] = true,  -- Ambassador Flamelash
    [9938] = true,  -- Magmus
    [8929] = true,  -- Princess Moira Bronzebeard
    [9019] = true,  -- Emperor Dagran Thaurissan
    [9438] = true,  -- Dark Keeper Bethek
    [9442] = true,  -- Dark Keeper Ofgut
    [9443] = true,  -- Dark Keeper Pelver
    [9439] = true,  -- Dark Keeper Uggel
    [9437] = true,  -- Dark Keeper Vorfalk
    [9441] = true,  -- Dark Keeper Zimrel
    [9034] = true,  -- Hate'rel
    [9035] = true,  -- Anger'rel
    [9036] = true,  -- Vile'rel
    [9037] = true,  -- Gloom'rel
    [9038] = true,  -- Seeth'rel
    [9040] = true,  -- Dope'rel
    
    -- Blackrock Spire (Zone ID: 1583)
    [9196] = true,  -- Highlord Omokk
    [9236] = true,  -- Shadow Hunter Vosh'gajin
    [9237] = true,  -- War Master Voone
    [10596] = true, -- Mother Smolderweb
    [10584] = true, -- Urok Doomhowl
    [9736] = true,  -- Quartermaster Zigris
    [10268] = true, -- Gizrul the Slavener
    [10220] = true, -- Halycon
    [9568] = true,  -- Overlord Wyrmthalak
    [9816] = true,  -- Pyroguard Emberseer
    [10429] = true, -- Warchief Rend Blackhand
    [10339] = true, -- Gyth
    [10430] = true, -- The Beast
    [10363] = true, -- General Drakkisath
    
    -- Stratholme (Zone ID: 2017)
    [11058] = true, -- Ezra Grimm
    [10393] = true, -- Skul
    [10558] = true, -- Hearthsinger Forresten
    [10516] = true, -- The Unforgiven
    [11143] = true, -- Postmaster Malown
    [10808] = true, -- Timmy the Cruel
    [11032] = true, -- Malor the Zealous
    [10997] = true, -- Cannon Master Willey
    [11120] = true, -- Crimson Hammersmith
    [10811] = true, -- Archivist Galford
    [10813] = true, -- Balnazzar
    [10435] = true, -- Magistrate Barthilas
    [10809] = true, -- Stonespine
    [10437] = true, -- Nerub'enkan
    [11121] = true, -- Black Guard Swordsmith
    [10438] = true, -- Maleki the Pallid
    [10436] = true, -- Baroness Anastari
    [10439] = true, -- Ramstein the Gorger
    [10440] = true, -- Baron Rivendare
    [14684] = true, -- Balzaphon (scourge)
    
    -- Dire Maul (Zone ID: 2557)
    [14354] = true, -- Pusillin
    [14327] = true, -- Lethtendris
    [13280] = true, -- Hydrospawn
    [11490] = true, -- Zevrim Thornhoof
    [11492] = true, -- Alzzin the Wildshaper
    [14326] = true, -- Guard Mol'dar
    [14322] = true, -- Stomper Kreeg
    [14321] = true, -- Guard Fengus
    [14323] = true, -- Guard Slip'kik
    [14325] = true, -- Captain Kromcrush
    [14324] = true, -- Cho'Rush the Observer
    [11501] = true, -- King Gordok
    [11489] = true, -- Tendris Warpwood
    [11487] = true, -- Magister Kalendris
    [11467] = true, -- Tsu'zee
    [11488] = true, -- Illyanna Ravenoak
    [11496] = true, -- Immol'thar
    [11486] = true, -- Prince Tortheldrin
    [14506] = true, -- Lord Hel'nurath (Summoned)
    [14690] = true, -- Revanchion (scourge)
    
    -- Scholomance (Zone ID: 2057)
    [10506] = true, -- Kirtonos the Herald
    [10503] = true, -- Jandice Barov
    [11622] = true, -- Rattlegore
    [10433] = true, -- Marduk Blackpool
    [10432] = true, -- Vectus
    [10508] = true, -- Ras Frostwhisper
    [10505] = true, -- Instructor Malicia
    [11261] = true, -- Doctor Theolen Krastinov
    [10901] = true, -- Lorekeeper Polkelt
    [10507] = true, -- The Ravenian
    [10504] = true, -- Lord Alexei Barov
    [10502] = true, -- Lady Illucia Barov
    [1853] = true,  -- Darkmaster Gandling
    [14695] = true, -- Lord Blackwood (scourge)
  }

  -- Raid boss NPC IDs
  local RaidBossIDs = {
    -- Molten Core (2717)
    [12118] = true, -- Lucifron
    [11982] = true, -- Magmadar
    [12259] = true, -- Gehennas
    [12057] = true, -- Garr
    [12264] = true, -- Shazzrah
    [12056] = true, -- Baron Geddon
    [11988] = true, -- Golemagg the Incinerator
    [12098] = true, -- Sulfuron Harbinger
    [12018] = true, -- Majordomo Executus
    [11502] = true, -- Ragnaros

    -- Onyxia's Lair (2159)
    [10184] = true, -- Onyxia

    -- Blackwing Lair (2677)
    [12435] = true, -- Razorgore the Untamed
    [13020] = true, -- Vaelastrasz the Corrupt
    [12017] = true, -- Broodlord Lashlayer
    [11983] = true, -- Firemaw
    [14601] = true, -- Ebonroc
    [11981] = true, -- Flamegor
    [14020] = true, -- Chromaggus
    [11583] = true, -- Nefarian

    -- Zul'Gurub (1977)
    [14507] = true, -- High Priest Venoxis
    [14517] = true, -- High Priestess Jeklik
    [14510] = true, -- High Priestess Mar'li
    [14509] = true, -- High Priest Thekal
    [14515] = true, -- High Priestess Arlokk
    [14834] = true, -- Hakkar (fixed)
    [11382] = true, -- Bloodlord Mandokir (optional)
    [14988] = true, -- Ohgan (optional)
    [15083] = true, -- Edge of Madness (optional, rotating)
    [15114] = true, -- Gahz'ranka (optional)
    [11380] = true, -- Jin'do the Hexxer (optional)

    -- Ruins of Ahn'Qiraj (AQ20, 3429)
    [15348] = true, -- Kurinnaxx
    [15341] = true, -- General Rajaxx
    [15340] = true, -- Moam
    [15370] = true, -- Buru the Gorger
    [15369] = true, -- Ayamiss the Hunter
    [15339] = true, -- Ossirian the Unscarred

    -- Ahn'Qiraj Temple (AQ40, 3428)
    [15263] = true, -- The Prophet Skeram
    [15516] = true, -- Battleguard Sartura
    [15510] = true, -- Fankriss the Unyielding
    [15509] = true, -- Princess Huhuran
    [15276] = true, -- Twin Emperors: Vek'lor
    [15275] = true, -- Twin Emperors: Vek'nilash
    [15727] = true, -- C'Thun
    [15543] = true, -- Bug Trio: Princess Yauj
    [15544] = true, -- Bug Trio: Vem (fixed name)
    [15511] = true, -- Bug Trio: Lord Kri
    [15299] = true, -- Viscidus
    [15517] = true, -- Ouro

    -- Naxxramas (3456)
    [15956] = true, -- Anub'Rekhan
    [15953] = true, -- Grand Widow Faerlina
    [15952] = true, -- Maexxna
    [15954] = true, -- Noth the Plaguebringer
    [15936] = true, -- Heigan the Unclean
    [16011] = true, -- Loatheb
    [16061] = true, -- Instructor Razuvious
    [16060] = true, -- Gothik the Harvester
    [16064] = true, -- Thane Korth'azz
    [16065] = true, -- Lady Blaumeux
    [16062] = true, -- Highlord Mograine
    [16063] = true, -- Sir Zeliek
    [16028] = true, -- Patchwerk
    [15931] = true, -- Grobbulus
    [15932] = true, -- Gluth
    [15928] = true, -- Thaddius
    [15989] = true, -- Sapphiron
    [15990] = true, -- Kel'Thuzad
  }
    
  local isDungeon = dungeonBossIDs[npcID] or false
  local isRaid = RaidBossIDs[npcID] or false
  return isDungeon, isRaid
end

function IsDungeonFinalBoss(unitGUID)

  -- Early return if player isn't in a dungeon or raid instance
  local inInstance, instanceType = IsInInstance()
  if not inInstance or (instanceType ~= "party" and instanceType ~= "raid") then
      return false, false
  end
  
  local npcID = tonumber(unitGUID:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$"))
              or tonumber(unitGUID:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)$"))
  if not npcID then
    return false, false
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
    [1716] = true,  -- Bazil Thredd (final boss)
    
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
    [7267] = true,  -- Chief Ukorz Sandscalp (final boss)
    
    -- Maraudon (Level 45-52)
    [12201] = true, -- Princess Theradras (final boss)
    
    -- Temple of Atal'Hakkar (Sunken Temple) (Level 50-60)
    [5709] = true,  -- Shade of Eranikus (final boss)
    
    -- Blackrock Depths (Level 52-60)
    [9019] = true,  -- Emperor Dagran Thaurissan (final boss)
    
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

  -- Final bosses for each raid
  local raidFinalBossIDs = {
    [11502] = true, -- Ragnaros (Molten Core)
    [10184] = true, -- Onyxia (Onyxia's Lair)
    [11583] = true, -- Nefarian (Blackwing Lair)
    [14834] = true, -- Hakkar (Zul'Gurub)
    [15339] = true, -- Ossirian the Unscarred (AQ20)
    [15727] = true, -- C'Thun (AQ40)
    [15990] = true, -- Kel'Thuzad (Naxxramas)
  }
  
  local isDungeonFinal = dungeonFinalBossIDs[npcID] or false
  local isRaidFinal = raidFinalBossIDs[npcID] or false
  return isDungeonFinal, isRaidFinal
end
