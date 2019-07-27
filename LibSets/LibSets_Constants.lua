--Check if the library was loaded before already
assert(LibSets == nil, "[LibSets]Library was loaded before already!")

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets
------------------------------------------------------------------------------------------------------------------------
--Library base values
local MAJOR, MINOR = "LibSets", 0.09
lib.name            = MAJOR
lib.version         = MINOR
lib.svName          = "LibSets_SV_Data"
lib.svVersion       = 0.9
lib.setsLoaded      = false
lib.setsScanning    = false
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
lib.supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["jp"]  = false,
    ["ru"]  = false,
}
------------------------------------------------------------------------------------------------------------------------
--Constants for the table keys of setInfo, setNames etc.
local noSetIdString = "NoSetId"
LIBSETS_TABLEKEY_SETITEMIDS                     = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID            = "setItemIds" .. noSetIdString
LIBSETS_TABLEKEY_SETNAMES                       = "setNames"
LIBSETS_TABLEKEY_SETNAMES_NO_SETID              = "setNames" .. noSetIdString
LIBSETS_TABLEKEY_LASTCHECKEDAPIVERSION          = "lastSetsCheckAPIVersion"
LIBSETS_TABLEKEY_NUMBONUSES                     = "numBonuses"
LIBSETS_TABLEKEY_MAXEQUIPPED                    = "maxEquipped"
LIBSETS_TABLEKEY_SETTYPE                        = "setType"
LIBSETS_TABLEKEY_MAPS                           = "maps"
LIBSETS_TABLEKEY_WAYSHRINES                     = "wayshrines"
LIBSETS_TABLEKEY_WAYSHRINE_NAMES                = "wayshrineNames"
LIBSETS_TABLEKEY_ZONE_DATA                      = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA             = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES              = "collectibleNames"
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID         = "wayshrineNodeId2zoneId"
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
LIBSETS_SETTYPE_ITERATION_END                   = LIBSETS_SETTYPE_TRIAL --End of iteration over SetTypes. !!!!! Increase this variable to the maximum setType if new setTypes are added !!!!!
lib.allowedSetTypes = { }
for i = LIBSETS_SETTYPE_ITERATION_BEGIN, LIBSETS_SETTYPE_ITERATION_END do
    lib.allowedSetTypes[i] = true
end
--Mapping between the LibSets setType and the used internal library table and counter variable
--------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets setTyps !!!
--------------------------------------------------------------------------
--[[
lib.setTypeToSetIdsForSetTypeTable = {
    [LIBSETS_SETTYPE_ARENA                        ] = lib.arenaSets,
    [LIBSETS_SETTYPE_BATTLEGROUND                 ] = lib.battlegroundSets,
    [LIBSETS_SETTYPE_CRAFTED                      ] = lib.craftedSets,
    [LIBSETS_SETTYPE_CYRODIIL                     ] = lib.cyrodiilSets,
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = lib.dailyRandomDungeonAndImperialCityRewardSets,
    [LIBSETS_SETTYPE_DUNGEON                      ] = lib.dungeonSets,
    [LIBSETS_SETTYPE_IMPERIALCITY                 ] = lib.imperialCitySets,
    [LIBSETS_SETTYPE_MONSTER                      ] = lib.monsterSets,
    [LIBSETS_SETTYPE_OVERLAND                     ] = lib.overlandSets,
    [LIBSETS_SETTYPE_SPECIAL                      ] = lib.specialSets,
    [LIBSETS_SETTYPE_TRIAL                        ] = lib.trialSets,
}
]]
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
        ["jp"] = GetString(SI_LEADERBOARDTYPE4),
        ["ru"] = GetString(SI_LEADERBOARDTYPE4),
    },
    [LIBSETS_SETTYPE_CRAFTED                        ] = {
        ["de"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["en"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["fr"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["jp"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        ["ru"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
    },
    [LIBSETS_SETTYPE_CYRODIIL                        ] = {
        ["de"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["en"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["fr"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["jp"] = GetString(SI_CAMPAIGNRULESETTYPE1),
        ["ru"] = GetString(SI_CAMPAIGNRULESETTYPE1),
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD  ] = {
        ["de"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["en"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["fr"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["jp"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
        ["ru"] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT) .. " & " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4) .. " " .. GetString(SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR),
    },
    [LIBSETS_SETTYPE_DUNGEON                        ] = {
        ["de"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
        ["en"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
        ["fr"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
        ["jp"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
        ["ru"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
    },
    [LIBSETS_SETTYPE_IMPERIALCITY                        ] = {
        ["de"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["en"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["fr"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["jp"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
        ["ru"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4),
    },
    [LIBSETS_SETTYPE_MONSTER                        ] = {
        ["de"] = GetString(SI_SPECIALIZEDITEMTYPE406),
        ["en"] = GetString(SI_SPECIALIZEDITEMTYPE406),
        ["fr"] = GetString(SI_SPECIALIZEDITEMTYPE406),
        ["jp"] = GetString(SI_SPECIALIZEDITEMTYPE406),
        ["ru"] = GetString(SI_SPECIALIZEDITEMTYPE406),
    },
    [LIBSETS_SETTYPE_OVERLAND                        ] = {
        ["de"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
        ["en"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
        ["fr"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
        ["jp"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
        ["ru"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
    },
    [LIBSETS_SETTYPE_SPECIAL                        ] = {
        ["de"] = GetString(SI_HOTBARCATEGORY9),
        ["en"] = GetString(SI_HOTBARCATEGORY9),
        ["fr"] = GetString(SI_HOTBARCATEGORY9),
        ["jp"] = GetString(SI_HOTBARCATEGORY9),
        ["ru"] = GetString(SI_HOTBARCATEGORY9),
    },
    [LIBSETS_SETTYPE_TRIAL                        ] = {
        ["de"] = GetString(SI_LFGACTIVITY4),
        ["en"] = GetString(SI_LFGACTIVITY4),
        ["fr"] = GetString(SI_LFGACTIVITY4),
        ["jp"] = GetString(SI_LFGACTIVITY4),
        ["ru"] = GetString(SI_LFGACTIVITY4),
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
    --English translations used at the moment! Todo: Translate
    --Asked for assistance: https://www.esoui.com/forums/showthread.php?p=38559#post38559
    ["ru"] = {
        [1] = "Glirion the Redbeard",
        [2] = "Maj al-Ragath",
        [3] = "Urgarlag Chief-bane",
    },
    ["jp"] = {
        [1] = "Glirion the Redbeard",
        [2] = "Maj al-Ragath",
        [3] = "Urgarlag Chief-bane",
    },
}
lib.undauntedChestIds = undauntedChestIds
------------------------------------------------------------------------------------------------------------------------
