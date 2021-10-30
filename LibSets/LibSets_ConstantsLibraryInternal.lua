--Library base values
local MAJOR, MINOR = "LibSets", 0.36

--Check if the library was loaded before already + chat output
function IsLibSetsAlreadyLoaded(outputMsg)
    outputMsg = outputMsg or false
    if LibSets ~= nil and LibSets.fullyLoaded == true then
        --Was an older version loaded?
        local loadedVersion = LibSets.version
        if loadedVersion < MINOR then return false end
        if outputMsg == true then d("["..MAJOR.."]Library was already loaded before, with version " ..tostring(loadedVersion) .."!") end
        return true
    end
    return false
end
if IsLibSetsAlreadyLoaded(true) then return end

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets

------------------------------------------------------------------------------------------------------------------------
lib.name            = MAJOR
lib.version         = MINOR
lib.svName          = "LibSets_SV_Data"
lib.svVersion       = MINOR -- changing this will reset the SavedVariables!
lib.setsLoaded      = false
lib.setsScanning    = false
------------------------------------------------------------------------------------------------------------------------
lib.fullyLoaded     = false
lib.startedLoading  = true
------------------------------------------------------------------------------------------------------------------------
local APIVersions = {}
--The actual API version on the live server we are logged in
APIVersions["live"] = GetAPIVersion()
local APIVersionLive = tonumber(APIVersions["live"])
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--!!!!!!!!!!! Update this if a new scan of set data was done on the new APIversion at the PTS  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--The last checked API version for the setsData in file "LibSets_Data.lua", see table "lib.setDataPreloaded = { ..."
-->Update here after a new scan of the set itemIds was done -> See LibSets_Data.lua, description in this file
-->above the sub-table ["setItemIds"] (data from debug function LibSets.DebugScanAllSetData())
lib.lastSetsPreloadedCheckAPIVersion = 101031 --Waking Flames (2021-09-16, PTS, API 101031)
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--!!!!!!!!!!! Update this if a new scan of set data was done on the new APIversion at the PTS  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
------------------------------------------------------------------------------------------------------------------------
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Update this if PTS increases to a new APIVersion !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--The current PTS APIVersion
--Update this in order to let the API comparison function "checkIfPTSAPIVersionIsLive" work properly and recognize what version
--of the game you are playing: live or PTS
--> Several automatic routines like "scan the librray for new sets" is raised via this comparison function and LibSets' event
--> EVENT_ADD_ON_LOADED -> function LoadSets()
-- as well as setIds and zoneIds in file LibSets_Data_All.lua, tables "setsOfNewerAPIVersion" and "zoneIdsOfNewAPIVersionOnly"
-- will be excluded from the LibSets tables, if the PTS version differs from the live version (GetAPIVersion())!
-- Normally this will be the same as the "last sets preloaded check API version" above, as long as the PTS is not updated to a
-- newer API patch. But as soon as the PTS was updated the both might differ and you need to update the vaalue here if you plan
-- to test on PTS and live with the same files
--APIVersions["PTS"] = lib.lastSetsPreloadedCheckAPIVersion
APIVersions["PTS"] = 101032 -- The Deadlands, 2021-09-23
local APIVersionPTS  = tonumber(APIVersions["PTS"])

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Update this if PTS increases to a new APIVersion !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--Check if the PTS APIVersion is now live
local function checkIfPTSAPIVersionIsLive()
    return (APIVersionLive >= APIVersionPTS) or false
end
lib.checkIfPTSAPIVersionIsLive = checkIfPTSAPIVersionIsLive
lib.APIVersions = APIVersions
------------------------------------------------------------------------------------------------------------------------
--These values are used inside the debug function "scanAllSetData" (see file LibSets_Debug.lua) for scanning the setIds and
--their itemIds
lib.debugNumItemIdPackages     = 50         -- Increase this to find new added set itemIds after an update. It will be
                                            --multiplied by lib.debugNumItemIdPackageSize to build the itemIds of the
                                            --items to scan inagme for sets -> build an itemLink->uses GetItemLinkSetInfo()
lib.debugNumItemIdPackageSize  = 5000       -- do not increase this or the client may crash!
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
local supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["ru"]  = true,
    ["jp"]  = false, --TODO: Working on: Waiting for SetNames & other translations by Calamath
}
lib.supportedLanguages = supportedLanguages
local numSupportedLangs = 0
for _, isSupported in pairs(supportedLanguages) do
    if isSupported == true then numSupportedLangs = numSupportedLangs + 1 end
end
lib.numSupportedLangs = numSupportedLangs
------------------------------------------------------------------------------------------------------------------------
--Constants for the table keys of setInfo, setNames etc.
local noSetIdString = "NoSetId"
LIBSETS_TABLEKEY_NEWSETIDS                      = "NewSetIDs"
LIBSETS_TABLEKEY_NAMES                          = "Names"
LIBSETS_TABLEKEY_SETITEMIDS                     = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID            = LIBSETS_TABLEKEY_SETITEMIDS .. noSetIdString
LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED          = LIBSETS_TABLEKEY_SETITEMIDS .."_Compressed"
LIBSETS_TABLEKEY_SETS_EQUIP_TYPES               = "setsEquipTypes"
--LIBSETS_TABLEKEY_SETS_ARMOR                     = "setsWithArmor"
LIBSETS_TABLEKEY_SETS_ARMOR_TYPES               = "setsArmorTypes"
LIBSETS_TABLEKEY_SETS_JEWELRY                   = "setsWithJewelry"
--LIBSETS_TABLEKEY_SETS_WEAPONS                   = "setsWithWeapons"
LIBSETS_TABLEKEY_SETS_WEAPONS_TYPES             = "setsWeaponTypes"
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
LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES          = "collectible_DLC" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID         = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_DROPMECHANIC                   = "dropMechanic"
LIBSETS_TABLEKEY_DROPMECHANIC_NAMES             = LIBSETS_TABLEKEY_DROPMECHANIC .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES     = LIBSETS_TABLEKEY_DROPMECHANIC .. "Tooltip" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MIXED_SETNAMES                 = "MixedSetNamesForDataAll"
LIBSETS_TABLEKEY_SET_PROCS                      = "setProcs"
LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP       = "setProcsAllowedInPvP"
LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING = "setItemCollectionsZoneMapping"

------------------------------------------------------------------------------------------------------------------------
--Set types
--> If you change these be sure to check the following tables below and add/change/remove entries as well:
--lib.setTypeToLibraryInternalVariableNames
--lib.setTypesToName
local possibleSetTypes = {
    [1]  = "LIBSETS_SETTYPE_ARENA",                         --"Arena"
    [2]  = "LIBSETS_SETTYPE_BATTLEGROUND",                  --"Battleground"
    [3]  = "LIBSETS_SETTYPE_CRAFTED",                       --"Crafted"
    [4]  = "LIBSETS_SETTYPE_CYRODIIL",                      --"Cyrodiil"
    [5]  = "LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD", --"DailyRandomDungeonAndICReward"
    [6]  = "LIBSETS_SETTYPE_DUNGEON",                       --"Dungeon"
    [7]  = "LIBSETS_SETTYPE_IMPERIALCITY",                  --"Imperial City"
    [8]  = "LIBSETS_SETTYPE_MONSTER",                       --"Monster"
    [9]  = "LIBSETS_SETTYPE_OVERLAND",                      --"Overland"
    [10] = "LIBSETS_SETTYPE_SPECIAL",                       --"Special"
    [11] = "LIBSETS_SETTYPE_TRIAL",                         --"Trial"
    [12] = "LIBSETS_SETTYPE_MYTHIC",                        --"Mythic"
}
--SetTypes only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --possibleSetTypes[13] = "..." --New LibSets set type
end
--Loop over the possible DLC ids and create them in the global table _G
for setTypeId, setTypeName in ipairs(possibleSetTypes) do
    _G[setTypeName] = setTypeId
end
local maxSetTypes = #possibleSetTypes
LIBSETS_SETTYPE_ITERATION_BEGIN     = LIBSETS_SETTYPE_ARENA
LIBSETS_SETTYPE_ITERATION_END       = _G[possibleSetTypes[maxSetTypes]]

lib.allowedSetTypes = {}
for i = LIBSETS_SETTYPE_ITERATION_BEGIN, LIBSETS_SETTYPE_ITERATION_END do
    lib.allowedSetTypes[i] = true
end
------------------------------------------------------------------------------------------------------------------------
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
    [LIBSETS_SETTYPE_MYTHIC                       ] = {
        ["tableName"] = "mythicSets",
    },
}
--setTypeToLibraryInternalVariableNames only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --[[
    lib.setTypeToLibraryInternalVariableNames[LIBSETS_SETTYPE_*                       ] ={
        ["tableName"] = "",
    }
    ]]
end
------------------------------------------------------------------------------------------------------------------------
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
        ["de"] = "Schlachtfeld", --SI_LEADERBOARDTYPE4,
        ["en"] = "Battleground",
        ["fr"] = "Champ de bataille",
        ["jp"] = "バトルグラウンド",
        ["ru"] = "Поле сражений",
    },
    [LIBSETS_SETTYPE_CRAFTED                        ] = {
        ["de"] = "Handwerklich hergestellt", --SI_ITEM_FORMAT_STR_CRAFTED
        ["en"] = "Crafted",
        ["fr"] = "Fabriqué",
        ["jp"] = "クラフトセット",
        ["ru"] = "Созданный",
    },
    [LIBSETS_SETTYPE_CYRODIIL                        ] = {
        ["de"] = "Cyrodiil", --SI_CAMPAIGNRULESETTYPE1,
        ["en"] = "Cyrodiil",
        ["fr"] = "Cyrodiil",
        ["jp"] = "シロディール",
        ["ru"] = "Сиродил",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD  ] = {
        ["de"] = "Zufälliges Verlies & Kaiserstadt Belohnung", --SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT & SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4 SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR
        ["en"] = "Random Dungeonds & Imperial city " .. ZO_CachedStrFormat("<<c:1>>", "Reward"),
        ["fr"] = "Donjons aléatoires & Cité impßériale " .. ZO_CachedStrFormat("<<c:1>>", "Récompense"),
        ["jp"] = "デイリー報酬",
        ["ru"] = "Случайное ежедневное подземелье и награда Имперского города",
    },
    [LIBSETS_SETTYPE_DUNGEON                        ] = {
        ["de"] = "Verlies", --SI_INSTANCEDISPLAYTYPE2
        ["en"] = "Dungeon",
        ["fr"] = "Donjon",
        ["jp"] = "ダンジョン",
        ["ru"] = "Подземелье",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY                        ] = {
        ["de"] = "Kaiserstadt", --SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4
        ["en"] = "Imperial city",
        ["fr"] = "Cité impériale",
        ["jp"] = "帝都",
        ["ru"] = "Имперский город",
    },
    [LIBSETS_SETTYPE_MONSTER                        ] = {
        ["de"] = "Monster",
        ["en"] = "Monster",
        ["fr"] = "Monstre",
        ["jp"] = "モンスター",
        ["ru"] = "Монстр",
    },
    [LIBSETS_SETTYPE_OVERLAND                        ] = {
        ["de"] = "Überland",
        ["en"] = "Overland",
        ["fr"] = "Overland",
        ["jp"] = "陸上",
        ["ru"] = "Поверхности",
    },
    [LIBSETS_SETTYPE_SPECIAL                        ] = {
        ["de"] = "Besonders", --SI_HOTBARCATEGORY9
        ["en"] = "Special",
        ["fr"] = "Spécial",
        ["jp"] = "スペシャル",
        ["ru"] = "Специальный",
    },
    [LIBSETS_SETTYPE_TRIAL                        ] = {
        ["de"] = "Prüfungen", --SI_LFGACTIVITY4
        ["en"] = "Trial",
        ["fr"] = "Épreuves",
        ["jp"] = "試練",
        ["ru"] = "Испытание",
    },
    [LIBSETS_SETTYPE_MYTHIC                       ] = {
        ["de"] = "Mythisch",
        ["en"] = "Mythic",
        ["fr"] = "Mythique",
        ["jp"] = "神話上の",
        ["ru"] = "мифический",
    },
}
--Translations only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --[[
    lib.setTypesToName[LIBSETS_SETTYPE_*                       ] = {
        ["de"] = "",
        ["en"] = "",
        ["fr"] = "",
        ["jp"] = "",
        ["ru"] = "",
    }
    ]]
end
------------------------------------------------------------------------------------------------------------------------
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
--The equip type check tables
--Jewelry
lib.isJewelryEquipType = {
    [EQUIP_TYPE_NECK] = true,
    [EQUIP_TYPE_RING] = true,
}
--Weapons
lib.isWeaponEquipType = {
    [EQUIP_TYPE_MAIN_HAND]  = true,
    [EQUIP_TYPE_OFF_HAND]   = true,
    [EQUIP_TYPE_ONE_HAND]   = true,
    [EQUIP_TYPE_TWO_HAND]   = true,
}

--The trait types valid for set items
lib.traitTypesValid = {
    --Not allowed
    --Allowed
    [ITEM_TRAIT_TYPE_NONE] = true,
    --Armor
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = true,
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = true,
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = true,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = true,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = true,
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = true,
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = true,
    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = true,
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = true,
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = true,
    --Jewelry
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = true,
    --Weapons
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = true,
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = true,
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = true,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = true,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = true,
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = true,
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = true,
}
--The enchanting EnchantmentSearchCategoryType that are valid
lib.enchantSearchCategoryTypesValid = {
    --Not allowed
    --Allowed
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_BERSERKER] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_HEALTH] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INVALID] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_NONE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_DEFENSE] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_ONSLAUGHT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_REGEN] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_STAMINA] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN] = true,
}
--Variables for the generateddata tables, coming from the preloaded setitem data
lib.equipTypesSets = {}
lib.armorSets = {}
lib.armorTypesSets = {}
lib.jewelrySets = {}
lib.weaponSets = {}
lib.weaponTypesSets = {}

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
    ["jp"] = {
        [1] = "赤髭グリリオン",
        [2] = "マジ・アルラガス",
        [3] = "族長殺しのウルガルラグ",
    },}
lib.undauntedChestIds = undauntedChestIds
------------------------------------------------------------------------------------------------------------------------
lib.armorTypeNames =  {
    [ARMORTYPE_LIGHT]               = GetString(SI_ARMORTYPE1) or "Light",
    [ARMORTYPE_MEDIUM]              = GetString(SI_ARMORTYPE2) or "Medium",
    [ARMORTYPE_HEAVY]               = GetString(SI_ARMORTYPE3) or "Heavy",
}
------------------------------------------------------------------------------------------------------------------------
lib.weaponTypeNames = {
    [WEAPONTYPE_NONE]               = GetString(SI_WEAPONTYPE0),
    [WEAPONTYPE_AXE]                = GetString(SI_WEAPONTYPE1),
    [WEAPONTYPE_BOW]                = GetString(SI_WEAPONTYPE8),
    [WEAPONTYPE_DAGGER]             = GetString(SI_WEAPONTYPE11),
    [WEAPONTYPE_FIRE_STAFF]         = GetString(SI_WEAPONTYPE12),
    [WEAPONTYPE_FROST_STAFF]        = GetString(SI_WEAPONTYPE13),
    [WEAPONTYPE_HAMMER]             = GetString(SI_WEAPONTYPE2),
    [WEAPONTYPE_HEALING_STAFF]      = GetString(SI_WEAPONTYPE9),
    [WEAPONTYPE_LIGHTNING_STAFF]    = GetString(SI_WEAPONTYPE15),
    [WEAPONTYPE_RUNE]               = GetString(SI_WEAPONTYPE10),
    [WEAPONTYPE_SHIELD]             = GetString(SI_WEAPONTYPE14),
    [WEAPONTYPE_SWORD]              = GetString(SI_WEAPONTYPE3),
    [WEAPONTYPE_TWO_HANDED_AXE]     = GetString(SI_WEAPONTYPE5),
    [WEAPONTYPE_TWO_HANDED_HAMMER]  = GetString(SI_WEAPONTYPE6),
    [WEAPONTYPE_TWO_HANDED_SWORD]   = GetString(SI_WEAPONTYPE4),
}
------------------------------------------------------------------------------------------------------------------------
--Drop mechanics / cities / etc. for additional drop location information
local possibleDropMechanics = {
    [1]  = "LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY",     --Rewards for the worthy (Cyrodiil/Battleground mail)
    [2]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA",                 --City Bruma (quartermaster)
    [3]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT",             --City Erntefurt (quartermaster)
    [4]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS",             --City Vlastarus (quartermaster)
    [5]  = "LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST",                   --Arena stage chest
    [6]  = "LIBSETS_DROP_MECHANIC_MONSTER_NAME",                        --The name of a monster (e.g. a boss in a dungeon) is specified in the excel and transfered to the setInfo table entry with the attribute dropMechanicNames (a table containing the monster name in different languages)
    [7]  = "LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE",                 --Overland delve bosses
    [8]  = "LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS",                  --Overland world group bosses
    [9]  = "LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON",        --Overland public dungeon bosses
    [10] = "LIBSETS_DROP_MECHANIC_OVERLAND_CHEST",                      --Overland chests
    [11] = "LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD",                 --Battleground rewards
    [12] = "LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD",    --Daily random dungeon mail rewards
    [13] = "LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS",                --Imperial city vaults
    [14] = "LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD",                     --Level up reward
    [15] = "LIBSETS_DROP_MECHANIC_ANTIQUITIES",                         --Antiquities (Mythic set items)
    [16] = "LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR",                 --Battleground vendor
}
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
     --LIBSETS_DROP_MECHANIC_ = number
    --possibleDropMechanics[xx] = "LIBSETS_DROP_MECHANIC_..." --new dropmechanic ...
end
--Loop over the possible DLC ids and create them in the global table _G
for dropMechanicId, dropMechanicName in ipairs(possibleDropMechanics) do
    _G[dropMechanicName] = dropMechanicId
end
local maxDropMechanicIds = #possibleDropMechanics
LIBSETS_DROP_MECHANIC_ITERATION_BEGIN                             = 1
LIBSETS_DROP_MECHANIC_ITERATION_END                     = _G[possibleDropMechanics[maxDropMechanicIds]]

lib.allowedDropMechanics = { }
for i = LIBSETS_DROP_MECHANIC_ITERATION_BEGIN, LIBSETS_DROP_MECHANIC_ITERATION_END do
    lib.allowedDropMechanics[i] = true
end
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets drop mechanics !!!
-------------------------------------------------------------------------------
---The names of the drop mechanics
local cyrodiilAndBattlegroundText = GetString(SI_CAMPAIGNRULESETTYPE1) .. "/" .. GetString(SI_LEADERBOARDTYPE4)
lib.dropMechanicIdToName = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Gerechter Lohn (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Cyrodiil Stadt: Bruma (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Cyrodiil Stadt: Erntefurt (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Cyrodiil Stadt: Vlastarus (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Arena-Phasen Schatztruhe",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Monster Name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Bosse in Gewölben",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Überland Gruppenbosse",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Öffentliche Dungeon-Bosse",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Truhen",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Belohnung in Schlachtfeldern",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Tägliches Zufallsverlies Belohnungsemail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Kaiserstadt Bunker",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Level Aufstieg Belohnung",
},
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Rewards for the worthy",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Cyrodiil City: Bruma (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Cyrodiil City: Cropsford (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Cyrodiil City: Vlastarus (quartermaster)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Arena stage chest",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Monster name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Delve bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Overland group bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Public dungeon bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Chests",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Battlegounds reward",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Daily random dungeon reward mail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Imperial city vaults",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Level up reward",
        --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE11),
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR]             = GetString(SI_LEADERBOARDTYPE4) .. " " .. GetString(SI_MAPDISPLAYFILTER2), --Battleground vendors
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "La récompense des braves",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Cyrodiil Ville: Bruma (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Cyrodiil Ville: Gué-les-Champs (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Cyrodiil Ville: Vlastrus (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Coffre d'étape Arena",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Nom du monstre",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Les boss de petit donjon",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Les boss de zone ouvertes",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Les boss de donjon public",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Les coffres",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Récompense de Champ de bataille",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Courrier de récompense de donjon journalière",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Cité impériale voûte",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Récompense de niveau supérieur",
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Награда достойным",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Сиродил: город Брума (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Сиродил: город Кропсфорд (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Сиродил: город Властарус (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "Этап арены",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "Имя монстра",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Боссы вылазок",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Групповые боссы",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Боссы открытых подземелий",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Сундуки",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "Награды полей сражений",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "Письмо с наградой за ежедневное случайное подземелье",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "Хранилища Имперского города",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "Вознаграждение за повышение уровня",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "貢献に見合った報酬です",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]             = "Cyrodiil シティ: ブルーマ (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_ERNTEFURT]         = "Cyrodiil シティ: クロップスフォード (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]         = "Cyrodiil シティ: ヴラスタルス (補給係)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]               = "アリーナステージチェスト",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                    = "モンスター名",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "洞窟ボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "ワールドボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "パブリックダンジョンのボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "宝箱",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]             = "バトルグラウンドの報酬",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]= "デイリーランダムダンジョン報酬メール",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]            = "帝都の宝物庫",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                 = "レベルアップ報酬",
    },
}
lib.dropMechanicIdToNameTooltip = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = cyrodiilAndBattlegroundText .. " mail",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Bosse in Gewölben haben die Chance, eine Taille oder Füße fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Überland Gruppenbosse haben eine Chance von 100%, Kopf, Brust, Beine oder Waffen fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Öffentliche Dungeon-Bosse haben die Möglichkeit, eine Schulter, Handschuhe oder eine Waffe fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Truhen, die durch das Besiegen eines Dunklen Ankers gewonnen wurden, haben eine Chance von 100%, einen Ring oder ein Amulett fallen zu lassen.\nSchatztruhen, welche man in der Zone findet, haben eine Chance irgendein Setteil zu gewähren, das in dieser Zone droppen kann:\n-Einfache Truhen haben eine geringe Chance\n-Mittlere Truhen haben eine gute Chance\n-Fortgeschrittene- und Meisterhafte-Truhen haben eine garantierte Chance\n-Schatztruhen, die durch eine Schatzkarte gefunden wurden, haben eine garantierte Chance",
},
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Rewards for the worthy (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Delve bosses have a chance to drop a waist or feet.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Overland group bosses have a 100% chance to drop head, chest, legs, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Public dungeon bosses have a chance to drop a shoulder, hand, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Chests gained from defeating a Dark Anchor have a 100% chance to drop a ring or amulet.\nTreasure chests found in the world have a chance to grant any set piece that can drop in that zone:\n-Simple chests have a slight chance\n-Intermediate chests have a good chance\n-Advanced and Master chests have a guaranteed chance\n-Treasure chests found from a Treasure Map have a guaranteed chance",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                     = GetString(SI_ANTIQUITY_TOOLTIP_TAG), --Will be used in other languages via setmetatable below!
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "La récompense des braves (" .. cyrodiilAndBattlegroundText .. " email)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Les boss de petit donjon ont une chance de laisser tomber une taille ou des pieds.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Les boss de zone ouvertes ont 100% de chances de laisser tomber la tête, la poitrine, les jambes ou l'arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Les boss de donjon public ont une chance de laisser tomber une épaule, une main ou une arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Les coffres obtenus en battant une ancre noire ont 100% de chances de laisser tomber un anneau ou une amulette.\nLes coffres au trésor trouvés dans le monde ont une chance d'accorder n'importe quelle pièce fixe qui peut tomber dans cette zone:\n-les coffres simples ont une légère chance \n-Les coffres intermédiaires ont de bonnes chances\n-Les coffres avancés et les maîtres ont une chance garantie\n-Les coffres au trésor trouvés sur une carte au trésor ont une chance garantie",
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "Награда достойным (" .. cyrodiilAndBattlegroundText .. " почта)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "Боссы вылазок дают шанс выпадания талии или голени.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "Групповые боссы дают 100% шанс выпадания головы, груди, ног или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "Боссы открытых подземелий дают шанс выпадания плечей, рук или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "Сундуки, полученные после побед над Тёмными якорями, имеют 100% шанс выпадания кольца или амулета.\nСундуки сокровищ, найденные в мире, дают шанс получить любую часть комплекта, выпадающую в этой зоне:\n- простые сундуки дают незначительный шанс\n- средние сундуки дают хороший шанс\n- продвинутые и мастерские сундуки дают гарантированный шанс\n- сундуки сокровищ, найденные по Карте сокровищ, дают гарантированный шанс",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY] = "貢献に見合った報酬です (" .. cyrodiilAndBattlegroundText .. " メール)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]             = "洞窟ボスは、胴体や足装備をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]              = "ワールドボスは、頭、腰、脚の各防具、または武器のいずれかが必ずドロップします。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]    = "パブリックダンジョンのボスは、肩、手の各防具、または武器をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                  = "ダークアンカー撃破報酬の宝箱からは、指輪かアミュレットが必ずドロップします。\n地上エリアで見つけた宝箱からは、そのゾーンでドロップするセット装備を入手できます。:\n-簡単な宝箱からは低確率で入手できます。\n-中級の宝箱からは高確率で入手できます。\n-上級やマスターの宝箱からは100%入手できます。\n-「宝の地図」で見つけた宝箱からは100%入手できます。",
    },
}
--DropMechanic translations only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --[[
    lib.dropMechanicIdToName["en"][LIBSETS_DROP_MECHANIC_*] = GetString(SI_*)
    lib.dropMechanicIdToNameTooltip["en"][LIBSETS_DROP_MECHANIC_*] = ""
    ]]
end
--Set metatable to get EN entries for missing other languages
local dropMechanicNames = lib.dropMechanicIdToName
local dropMechanicTooltipNames = lib.dropMechanicIdToNameTooltip
local dropMechanicNamesEn = dropMechanicNames["en"]
setmetatable(dropMechanicNames["de"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["fr"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["jp"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicNames["ru"], {__index = dropMechanicNamesEn})

setmetatable(dropMechanicTooltipNames["de"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicTooltipNames["fr"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicTooltipNames["jp"], {__index = dropMechanicNamesEn})
setmetatable(dropMechanicTooltipNames["ru"], {__index = dropMechanicNamesEn})
------------------------------------------------------------------------------------------------------------------------
--Set itemId table value (key is the itemId)
LIBSETS_SET_ITEMID_TABLE_VALUE_OK    = 1
LIBSETS_SET_ITEMID_TABLE_VALUE_NOTOK = 2
------------------------------------------------------------------------------------------------------------------------
--Set proc check types (e.g. event_effect_changed, event_combat_event)
--SetprocCheckTypes
LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_EFFECT_CHANGED  = 1     --Check abilityId via EVENT_EFFECT_CHANGED callback function
LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT    = 2     --Check abilityId via EVENT_COMBAT_EVENT callback function
LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE	        = 4     --Check if a power updated at EVENT_POWER_UPDATE
LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED	        = 5     --Check if a boss changed with EVENT_BOSSES_CHANGED
LIBSETS_SETPROC_CHECKTYPE_SPECIAL                       = 99    --Check with an own defined special callback function
