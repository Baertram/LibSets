--Check if the library was loaded before already
assert(LibSets == nil, "[LibSets]Library was loaded before already!")

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets
------------------------------------------------------------------------------------------------------------------------
--Library base values
local MAJOR, MINOR = "LibSets", 0.16
lib.name            = MAJOR
lib.version         = MINOR
lib.svName          = "LibSets_SV_Data"
lib.svVersion       = 0.16
lib.setsLoaded      = false
lib.setsScanning    = false

------------------------------------------------------------------------------------------------------------------------
--These values are used inside the debug function "scanAllSetData" (see file LibSets_Debug.lua) for scanning the setIds and
--their itemIds
lib.debugNumItemIdPackages     = 50        -- Increase this to find new added set itemIds after and update
lib.debugNumItemIdPackageSize  = 5000      -- do not increase this or the client may crash!
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
lib.supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["ru"]  = true,
    ["jp"]  = false, --TODO: Working on: Waiting for SetNames & other translations by Calamath
}
------------------------------------------------------------------------------------------------------------------------
--Constants for the table keys of setInfo, setNames etc.
local noSetIdString = "NoSetId"
LIBSETS_TABLEKEY_NAMES                          = "Names"
LIBSETS_TABLEKEY_SETITEMIDS                     = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID            = LIBSETS_TABLEKEY_SETITEMIDS .. noSetIdString
LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED          = LIBSETS_TABLEKEY_SETITEMIDS .."_Compressed"
LIBSETS_TABLEKEY_SETNAMES                       = "set" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_SETNAMES_NO_SETID              = "set" .. LIBSETS_TABLEKEY_NAMES .. noSetIdString
LIBSETS_TABLEKEY_LASTCHECKEDAPIVERSION          = "lastSetsCheckAPIVersion"
LIBSETS_TABLEKEY_NUMBONUSES                     = "numBonuses"
LIBSETS_TABLEKEY_MAXEQUIPPED                    = "maxEquipped"
LIBSETS_TABLEKEY_SETTYPE                        = "setType"
LIBSETS_TABLEKEY_MAPS                           = "maps"
LIBSETS_TABLEKEY_WAYSHRINES                     = "wayshrines"
LIBSETS_TABLEKEY_WAYSHRINE_NAMES                = "wayshrine" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_ZONEIDS                        = "zoneIds"
LIBSETS_TABLEKEY_ZONE_DATA                      = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA             = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES              = "collectible" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID         = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_DROPMECHANIC                   = "dropMechanic"
LIBSETS_TABLEKEY_DROPMECHANIC_NAMES             = LIBSETS_TABLEKEY_DROPMECHANIC .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MIXED_SETNAMES                 = "MixedSetNamesForDataAll"
------------------------------------------------------------------------------------------------------------------------
--Set types
--> If you change these be sure to check the following tables below and add/change/remove entries as well:
--lib.setTypeToLibraryInternalVariableNames
--lib.setTypesToName
LIBSETS_SETTYPE_ITERATION_BEGIN                 = 1 -- Start of iteration over allowed SetTypes
LIBSETS_SETTYPE_ARENA                           = 1 --"Arena"
LIBSETS_SETTYPE_BATTLEGROUND                    = 2 --"Battleground"
LIBSETS_SETTYPE_CRAFTED                         = 3 --"Crafted"
LIBSETS_SETTYPE_CYRODIIL                        = 4 --"Cyrodiil"
LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD   = 5 --"DailyRandomDungeonAndICReward"
LIBSETS_SETTYPE_DUNGEON                         = 6 --"Dungeon"
LIBSETS_SETTYPE_IMPERIALCITY                    = 7 --"Imperial City"
LIBSETS_SETTYPE_MONSTER                         = 8 --"Monster"
LIBSETS_SETTYPE_OVERLAND                        = 9 --"Overland"
LIBSETS_SETTYPE_SPECIAL                         = 10 --"Special"
LIBSETS_SETTYPE_TRIAL                           = 11 --"Trial"
LIBSETS_SETTYPE_MYTHIC                          = 12 --"Mythic"
LIBSETS_SETTYPE_ITERATION_END                   = LIBSETS_SETTYPE_MYTHIC --End of iteration over SetTypes. !!!!! Increase this variable to the maximum setType if new setTypes are added !!!!!
lib.allowedSetTypes = {}
for i = LIBSETS_SETTYPE_ITERATION_BEGIN, LIBSETS_SETTYPE_ITERATION_END do
    lib.allowedSetTypes[i] = true
end
--Mapping between the LibSets setType and the used internal library table and counter variable
--------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets setTyps !!!
--------------------------------------------------------------------------
lib.setTypeToLibraryInternalVariableNames = {
    [LIBSETS_SETTYPE_ARENA                        ] = {
        ["tableName"] = "arenaSets",
    },
    [LIBSETS_SETTYPE_BATTLEGROUND                 ] = {
        ["tableName"] = "battlegroundSets",
    },
    [LIBSETS_SETTYPE_CRAFTED                      ] ={
        ["tableName"] = "craftedSets",
    },
    [LIBSETS_SETTYPE_CYRODIIL                     ] ={
        ["tableName"] = "cyrodiilSets",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] ={
        ["tableName"] = "dailyRandomDungeonAndImperialCityRewardSets",
    },
    [LIBSETS_SETTYPE_DUNGEON                      ] ={
        ["tableName"] = "dungeonSets",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY                 ] ={
        ["tableName"] = "imperialCitySets",
    },
    [LIBSETS_SETTYPE_MONSTER                      ] ={
        ["tableName"] = "monsterSets",
    },
    [LIBSETS_SETTYPE_OVERLAND                     ] ={
        ["tableName"] = "overlandSets",
    },
    [LIBSETS_SETTYPE_SPECIAL                      ] ={
        ["tableName"] = "specialSets",
    },
    [LIBSETS_SETTYPE_TRIAL                        ] ={
        ["tableName"] = "trialSets",
    },
    [LIBSETS_SETTYPE_MYTHIC                       ] ={
        ["tableName"] = "mythicSets",
    },
}
--The suffix for the counter variables of the setType tables. e.g. setType LIBSETS_SETTYPE_OVERLAND table is called overlandSets.
--The suffix is "Counter" so the variable for the counter is "overlandSetsCounter"
lib.counterSuffix = "Counter"
--The LibSets setType mapping table for names
--------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets setTyps !!!
--------------------------------------------------------------------------
lib.setTypesToName = {
    [LIBSETS_SETTYPE_ARENA                        ] = {
        ["de"] = "Arena",
        ["en"] = "Arena",
        ["fr"] = "Arène",
        ["jp"] = "アリーナ",
        ["ru"] = "Aрена",
    },
    [LIBSETS_SETTYPE_BATTLEGROUND                        ] = {
        ["de"] = GetString(SI_LEADERBOARDTYPE4),
        ["en"] = GetString(SI_LEADERBOARDTYPE4),
        ["fr"] = GetString(SI_LEADERBOARDTYPE4),
        ["jp"] = GetString(SI_LEADERBOARDTYPE4) or "バトルグラウンド",
        ["ru"] = GetString(SI_LEADERBOARDTYPE4) or "Поле сражений",
    },
    [LIBSETS_SETTYPE_CRAFTED                        ] = {
        ["de"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["en"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["fr"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["jp"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED) or "クラフトセット",
        ["ru"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED) or "Созданный",
    },
    [LIBSETS_SETTYPE_CYRODIIL                        ] = {
        ["de"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["en"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["fr"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["jp"] = GetString(SI_CAMPAIGNRULESETTYPE1) or "シロディール",
        ["ru"] = GetString(SI_CAMPAIGNRULESETTYPE1) or "Сиродил",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD  ] = {
        ["de"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["en"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["fr"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["jp"] = (GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR))  or "デイリー報酬",
        ["ru"] = (GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR))  or "Случайное ежедневное подземелье и награда Имперского города",
    },
    [LIBSETS_SETTYPE_DUNGEON                        ] = {
        ["de"] = GetString(SI_INSTANCEDISPLAYTYPE2),
        ["en"] = GetString(SI_INSTANCEDISPLAYTYPE2),
        ["fr"] = GetString(SI_INSTANCEDISPLAYTYPE2),
        ["jp"] = GetString(SI_INSTANCEDISPLAYTYPE2) or "ダンジョン",
        ["ru"] = GetString(SI_INSTANCEDISPLAYTYPE2 or "Подземелье"),
    },
    [LIBSETS_SETTYPE_IMPERIALCITY                        ] = {
        ["de"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["en"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["fr"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["jp"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) or "帝都",
        ["ru"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) or "Имперский город",
    },
    [LIBSETS_SETTYPE_MONSTER                        ] = {
        ["de"] = "Monster",
        ["en"] = "Monster",
        ["fr"] = "Monster",
        ["jp"] = "モンスター",
        ["ru"] = "Монстр",
    },
    [LIBSETS_SETTYPE_OVERLAND                        ] = {
        ["de"] = "Überland",
        ["en"] = "Overland",
        ["fr"] = "Overland",
        ["jp"] = "陸上",
        ["ru"] = "Cухопутный",
    },
    [LIBSETS_SETTYPE_SPECIAL                        ] = {
        ["de"] = GetString(SI_HOTBARCATEGORY9),
        ["en"] = GetString(SI_HOTBARCATEGORY9),
        ["fr"] = GetString(SI_HOTBARCATEGORY9),
        ["jp"] = GetString(SI_HOTBARCATEGORY9) or "スペシャル",
        ["ru"] = GetString(SI_HOTBARCATEGORY9) or "Специальный",
    },
    [LIBSETS_SETTYPE_TRIAL                        ] = {
        ["de"] = GetString(SI_LFGACTIVITY4),
        ["en"] = GetString(SI_LFGACTIVITY4),
        ["fr"] = GetString(SI_LFGACTIVITY4),
        ["jp"] = GetString(SI_LFGACTIVITY4) or "試練",
        ["ru"] = GetString(SI_LFGACTIVITY4) or "Испытание",
    },
    [LIBSETS_SETTYPE_MYTHIC                       ] = {
        ["de"] = GetString(SI_ITEMDISPLAYQUALITY6),
        ["en"] = GetString(SI_ITEMDISPLAYQUALITY6),
        ["fr"] = GetString(SI_ITEMDISPLAYQUALITY6),
        ["jp"] = GetString(SI_ITEMDISPLAYQUALITY6) or "神話上の",
        ["ru"] = GetString(SI_ITEMDISPLAYQUALITY6) or "мифический",
    },

}
--Mapping table setType to setIds for this settype.
-->Will be filled in file LibSets.lua, function LoadSets()
lib.setTypeToSetIdsForSetTypeTable = {}
------------------------------------------------------------------------------------------------------------------------
--The itemTypes possible to be used for setItems
lib.setItemTypes = {
    [ITEMTYPE_ARMOR]    = true,
    [ITEMTYPE_WEAPON]   = true,
}
--The equipment types valid for set items
lib.equipTypesValid = {
    --Not allowed
    [EQUIP_TYPE_INVALID]    = false,
    [EQUIP_TYPE_COSTUME]    = false,
    [EQUIP_TYPE_POISON]     = false,
    --Allowed
    [EQUIP_TYPE_CHEST]      = true,
    [EQUIP_TYPE_FEET]       = true,
    [EQUIP_TYPE_HAND]       = true,
    [EQUIP_TYPE_HEAD]       = true,
    [EQUIP_TYPE_LEGS]       = true,
    [EQUIP_TYPE_MAIN_HAND]  = true,
    [EQUIP_TYPE_NECK]       = true,
    [EQUIP_TYPE_OFF_HAND]   = true,
    [EQUIP_TYPE_ONE_HAND]   = true,
    [EQUIP_TYPE_RING]       = true,
    [EQUIP_TYPE_SHOULDERS]  = true,
    [EQUIP_TYPE_TWO_HAND]   = true,
    [EQUIP_TYPE_WAIST]      = true,
}
------------------------------------------------------------------------------------------------------------------------
--Number of currently available set bonus for a monster set piece (2: head, shoulder)
lib.countMonsterSetBonus = 2
------------------------------------------------------------------------------------------------------------------------
--DLC & Chapter ID constants (for LibSets)
--> LibSets_Constants_<APIVersion>.lua for the given DLC constants for each API version!
------------------------------------------------------------------------------------------------------------------------
--The undaunted chest count
lib.countUndauntedChests = 3
--The undaunted chest NPC names
local undauntedChestIds = {
    ["de"] = {
        [1] = "Glirion der Rotbart",
        [2] = "Maj al-Ragath",
        [3] = "Urgarlag Häuptlingsfluch",
    },
    ["en"] = {
        [1] = "Glirion the Redbeard",
        [2] = "Maj al-Ragath",
        [3] = "Urgarlag Chief-bane",
    },
    ["fr"] = {
        [1] = "Glirion Barbe-Rousse",
        [2] = "Maj al-Ragath",
        [3] = "Urgalarg l'Èmasculatrice",
    },
    ["ru"] = {
        [1] = "Глирион Краснобородый",
        [2] = "Мадж аль-Рагат",
        [3] = "Ургарлаг Бич Вождей",
    },
    --Thanks to Calamath 2020-01-18
    ["jp"] = {
        [1] = "赤髭グリリオン",           -- "Glirion the Redbeard"
        [2] = "マジ・アルラガス",         -- "Maj al-Ragath"
        [3] = "族長殺しのウルガルラグ",   -- "Urgarlag Chief-bane"
    },}
lib.undauntedChestIds = undauntedChestIds
------------------------------------------------------------------------------------------------------------------------
lib.armorTypeNames =  {
    [ARMORTYPE_LIGHT]   = GetString(SI_ARMORTYPE1) or "Light",
    [ARMORTYPE_MEDIUM]  = GetString(SI_ARMORTYPE2) or "Medium",
    [ARMORTYPE_HEAVY]   = GetString(SI_ARMORTYPE3) or "Heavy",
}
------------------------------------------------------------------------------------------------------------------------
--Drop mechanics / cities / etc. for additional drop location information
LIBSETS_DROP_MECHANIC_ITERATION_BEGIN                             = 1
LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY   = 1	    --Rewards for the worthy (Cyrodiil/Battleground mail)
LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA	            = 2	    --City Bruma (quartermaster)
LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT	        = 3	    --City Erntefurt (quartermaster)
LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS	        = 4	    --City Vlastarus (quartermaster)
LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST                 = 5     --Arena stage chest
LIBSETS_DROP_MECHANIC_MONSTER_NAME                      = 6     --The name of a monster (e.g. a boss in a dungeon) is specified in the excel and transfered to the setInfo table entry with the attribute dropMechanicNames (a table containing the monster name in different languages)
LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE               = 7     --Overland delve bosses
LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS                = 8     --Overland world group bosses
LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON      = 9     --Overland public dungeon bosses
LIBSETS_DROP_MECHANIC_OVERLAND_CHEST                    = 10    --Overland chests
LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD               = 11    --Battleground rewards
LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD  = 12    --Daily random dungeon mail rewards
LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS              = 13    --Imperial city vaults
LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD                   = 14    --Level up reward
LIBSETS_DROP_MECHANIC_ANTIQUITIES                       = 15    --Antiquities (Mythic set items)
LIBSETS_DROP_MECHANIC_ITERATION_END                     = LIBSETS_DROP_MECHANIC_ANTIQUITIES
lib.allowedDropMechanics = { }
for i = LIBSETS_DROP_MECHANIC_ITERATION_BEGIN, LIBSETS_DROP_MECHANIC_ITERATION_END do
    lib.allowedDropMechanics[i] = true
end
-------------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets drop mechanics !!!
-------------------------------------------------------------------------------
---The names of the drop mechanics
local cyrodiilAndBattlegroundText = GetString(SI_CAMPAIGNRULESETTYPE1) .. "/" .. GetString(SI_LEADERBOARDTYPE4)
lib.dropMechanicIdToName = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Gerechter Lohn (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Stadt: Bruma (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Stadt: Erntefurt (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Stadt: Vlastarus (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Arena-Phasen Schatztruhe",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Monster Name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Bosse in Gewölben haben die Chance, eine Taille oder Füße fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Überland Gruppenbosse haben eine Chance von 100%, Kopf, Brust, Beine oder Waffen fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Öffentliche Dungeon-Bosse haben die Möglichkeit, eine Schulter, Handschuhe oder eine Waffe fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Truhen, die durch das Besiegen eines Dunklen Ankers gewonnen wurden, haben eine Chance von 100%, einen Ring oder ein Amulett fallen zu lassen.\nSchatztruhen, welche man in der Zone findet, haben eine Chance irgendein Setteil zu gewähren, das in dieser Zone droppen kann:\n-Einfache Truhen haben eine geringe Chance\n-Mittlere Truhen haben eine gute Chance\n-Fortgeschrittene- und Meisterhafte-Truhen haben eine garantierte Chance\n-Schatztruhen, die durch eine Schatzkarte gefunden wurden, haben eine garantierte Chance",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Belohnung in Schlachtfeldern",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Tägliches Zufallsverlies Belohnungsemail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Kaiserstadt Bunker",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Level up reward",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG),
},
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Rewards for the worthy (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "City: Bruma (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "City: Cropsford (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "City: Vlastarus (quartermaster)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Arena stage chest",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Monster name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Delve bosses have a chance to drop a waist or feet.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Overland group bosses have a 100% chance to drop head, chest, legs, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Public dungeon bosses have a chance to drop a shoulder, hand, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Chests gained from defeating a Dark Anchor have a 100% chance to drop a ring or amulet.\nTreasure chests found in the world have a chance to grant any set piece that can drop in that zone:\n-Simple chests have a slight chance\n-Intermediate chests have a good chance\n-Advanced and Master chests have a guaranteed chance\n-Treasure chests found from a Treasure Map have a guaranteed chance",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Battlegounds reward",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Daily random dungeon reward mail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Imperial city vaults",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Level Aufstieg Belohnung",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG),
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "La récompense des braves (" .. cyrodiilAndBattlegroundText .. " email)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Ville: Bruma (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Ville: Gué-les-Champs (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Ville: Vlastrus (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Coffre d'étape Arena",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Nom du monstre",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Les boss de petit donjon ont une chance de laisser tomber une taille ou des pieds.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Les boss de zone ouvertes ont 100% de chances de laisser tomber la tête, la poitrine, les jambes ou l'arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Les boss de donjon public ont une chance de laisser tomber une épaule, une main ou une arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Les coffres obtenus en battant une ancre noire ont 100% de chances de laisser tomber un anneau ou une amulette.\nLes coffres au trésor trouvés dans le monde ont une chance d'accorder n'importe quelle pièce fixe qui peut tomber dans cette zone:\n-les coffres simples ont une légère chance \n-Les coffres intermédiaires ont de bonnes chances\n-Les coffres avancés et les maîtres ont une chance garantie\n-Les coffres au trésor trouvés sur une carte au trésor ont une chance garantie",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Récompense de Champ de bataille",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Courrier de récompense de donjon journalière",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Cité impériale voûte",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Récompense de niveau supérieur",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG),
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Награда достойным (" .. cyrodiilAndBattlegroundText .. " Эл. адрес)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "город: Брума (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "город: Кропсфорд (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "город: Властарус (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Стадион арены",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Имя монстра",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Боссы вылазок дают шанс выпадания талии или голени.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Групповые боссы дают 100% шанс выпадания головы, груди, ног или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Боссы публичных подземелий дают шанс выпадания плечей, рук или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Сундуки, полученные от побед над Темным якорем, имеют 100% шанс выпадания кольца или амулета.\nСундуки сокровищ, найденные в мире, дают шанс получить любой сетовый кусок, выпадающий в этой зоне:\n- простые сундуки дают незначительный шанс\n- средние сундуки дают хороший шанс\n- продвинутые и мастерские сундуки дают гарантированный шанс\n- сундуки сокровищ, найденные по Карте сокровищ, дают гарантированный шанс",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Награды полей сражений",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Письмо с наградой за ежедневное рандомное подземелье",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Убежище Имперского города",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Вознаграждение за повышение уровня",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG),
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "貢献に見合った報酬です (" .. cyrodiilAndBattlegroundText .. " メール)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "シティ: ブルーマ (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "シティ: クロップスフォード (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "シティ: ヴラスタルス (補給係)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "アリーナステージチェスト",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "モンスター名",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "洞窟ボスは、胴体や足装備をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "ワールドボスは、頭、腰、脚の各防具、または武器のいずれかが必ずドロップします。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "パブリックダンジョンのボスは、肩、手の各防具、または武器をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "ダークアンカー撃破報酬の宝箱からは、指輪かアミュレットが必ずドロップします。\n地上エリアで見つけた宝箱からは、そのゾーンでドロップするセット装備を入手できます。:\n-簡単な宝箱からは低確率で入手できます。\n-中級の宝箱からは高確率で入手できます。\n-上級やマスターの宝箱からは100%入手できます。\n-「宝の地図」で見つけた宝箱からは100%入手できます。",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "バトルグラウンドの報酬",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "デイリーランダムダンジョン報酬メール",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "帝都の宝物庫",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "レベルアップ報酬",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG),
    },
}
--Set metatable to get EN entries for missing other languages
local dropMechanicNames = lib.dropMechanicIdToName
local dropMechanicNamesEn = dropMechanicNames["en"]
setmetatable(dropMechanicNames["de"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["fr"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["jp"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["ru"], {__index = dropMechanicNamesEn})

--Set itemId table value (key is the itemId)
LIBSETS_SET_TEMID_TABLE_VALUE_OK    = 1
LIBSETS_SET_TEMID_TABLE_VALUE_NOTOK = 2