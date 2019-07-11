--Check if the library was loaded before already
assert(LibSets == nil, "[LibSets]Library was loaded before already!")

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets

--Library base values
local MAJOR, MINOR = "LibSets", 0.06
lib.name            = MAJOR
lib.version         = MINOR
lib.svName          = "LibSets_SV_Data"
lib.svVersion       = 0.6
lib.setsLoaded      = false
lib.setsScanning    = false

--The last checked API version for the setsData in file LibSets_Data.lua, see table "lib.setDataPreloaded = { ..."
-->Update here after a new scan of the set itemIds was done -> See LibSets_Data.lua, description in this file
-->above the sub-table ["setItemIds"] (data from debug function LibSets.DebugScanAllSetData())
lib.lastSetsPreloadedCheckAPIVersion    = 100027 --Elsweyr
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
--Set types
LIBSETS_SETTYPE_ARENA                           = "Arena"
LIBSETS_SETTYPE_BATTLEGROUND                    = "Battleground"
LIBSETS_SETTYPE_CRAFTED                         = "Crafted"
LIBSETS_SETTYPE_CYRODIIL                        = "Cyrodiil"
LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD   = "DailyRandomDungeonAndICReward"
LIBSETS_SETTYPE_DUNGEON                         = "Dungeon"
LIBSETS_SETTYPE_IMPERIALCITY                    = "Imperial City"
LIBSETS_SETTYPE_MONSTER                         = "Monster"
LIBSETS_SETTYPE_OVERLAND                        = "Overland"
LIBSETS_SETTYPE_SPECIAL                         = "Special"
LIBSETS_SETTYPE_TRIAL                           = "Trial"
lib.allowedSetTypes = {
    [LIBSETS_SETTYPE_ARENA                        ] = true,
    [LIBSETS_SETTYPE_BATTLEGROUND                 ] = true,
    [LIBSETS_SETTYPE_CRAFTED                      ] = true,
    [LIBSETS_SETTYPE_CYRODIIL                     ] = true,
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = true,
    [LIBSETS_SETTYPE_DUNGEON                      ] = true,
    [LIBSETS_SETTYPE_IMPERIALCITY                 ] = true,
    [LIBSETS_SETTYPE_MONSTER                      ] = true,
    [LIBSETS_SETTYPE_OVERLAND                     ] = true,
    [LIBSETS_SETTYPE_SPECIAL                      ] = true,
    [LIBSETS_SETTYPE_TRIAL                        ] = true,
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
DLC_BASE_GAME               = 0
DLC_IMPERIAL_CITY           = 1
DLC_ORSINIUM                = 2
DLC_THIEVES_GUILD           = 3
DLC_DARK_BROTHERHOOD        = 4
DLC_SHADOWS_OF_THE_HIST     = 5
DLC_MORROWIND               = 6
DLC_HORNS_OF_THE_REACH      = 7
DLC_CLOCKWORK_CITY          = 8
DLC_DRAGON_BONES            = 9
DLC_SUMMERSET               = 10
DLC_WOLFHUNTER              = 11
DLC_MURKMIRE                = 12
DLC_WRATHSTONE              = 13
DLC_ELSWEYR                 = 14
--Internal achievement example ids of the ESO DLCs and chapters (first achievementId found from each DLC category)
lib.dlcAndChapterAchievementIds = {
    --Imperial city
    [DLC_IMPERIAL_CITY] = 1267,
    --Orsinium
    [DLC_ORSINIUM] = 1393,
    --Thieves Guild
    [DLC_THIEVES_GUILD] = 1413,
    --Dark Brotherhood
    [DLC_DARK_BROTHERHOOD] = 1421,
    --Shadows of the Hist
    [DLC_SHADOWS_OF_THE_HIST] = 1520,
    --Morrowind
    [DLC_MORROWIND] = 1843,
    --Horns of the Reach
    [DLC_HORNS_OF_THE_REACH] = 1940,
    --Clockwork City
    [DLC_CLOCKWORK_CITY] = 2048,
    --Dragon Bones
    [DLC_DRAGON_BONES] = 2104,
    --Summerset
    [DLC_SUMMERSET] = 1845,
    --Wolfhunter
    [DLC_WOLFHUNTER] = 2157,
    --Murkmire
    [DLC_MURKMIRE] = 2340,
    --Wrathstone
    [DLC_WRATHSTONE] = 2265,
    --Elsweyr
    [DLC_ELSWEYR] = 2463,
}
--Internal achievement example ids of the ESO DLCs and chapters
local dlcAndChapterAchievementIds = lib.dlcAndChapterAchievementIds
--For each entry in the list of example achievements above get the name of it's parent category (DLC, chapter)
lib.DLCData = {}
local DLCandCHAPTERdata = lib.DLCData
for dlcId, dlcAchievementId in ipairs(dlcAndChapterAchievementIds) do
    if dlcId and dlcAchievementId and dlcAchievementId > 0 then
        DLCandCHAPTERdata[dlcId] = ZO_CachedStrFormat("<<C:1>>", GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(dlcAchievementId)))
    end
end
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