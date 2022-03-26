--Library base values
local MAJOR, MINOR = "LibSets", 0.44

--local ZOs variables
local zocstrfor    = ZO_CachedStrFormat
local strlower     = string.lower

--Check if the library was loaded before already + chat output
function IsLibSetsAlreadyLoaded(outputMsg)
    outputMsg = outputMsg or false
    if LibSets ~= nil and LibSets.fullyLoaded == true then
        --Was an older version loaded?
        local loadedVersion = LibSets.version
        if loadedVersion < MINOR then return false end
        if outputMsg == true then d("[" .. MAJOR .. "]Library was already loaded before, with version " .. tostring(loadedVersion) .. "!") end
        return true
    end
    return false
end
if IsLibSetsAlreadyLoaded(true) then return end

--This file contains the constant values needed for the library to work
LibSets                              = {} --Creation of the global variable
local lib                            = LibSets

------------------------------------------------------------------------------------------------------------------------
lib.name                             = MAJOR
lib.version                          = MINOR
lib.svName                           = "LibSets_SV_Data"
lib.svDebugName                      = "LibSets_SV_DEBUG_Data"
lib.svVersion                        = 0.38 -- ATTENTION: changing this will reset the SavedVariables!
lib.setsLoaded                       = false
lib.setsScanning                     = false
------------------------------------------------------------------------------------------------------------------------
lib.fullyLoaded                      = false
lib.startedLoading                   = true
------------------------------------------------------------------------------------------------------------------------
local APIVersions                    = {}
--The actual API version on the live server we are logged in
APIVersions["live"]                  = GetAPIVersion()
local APIVersionLive                 = tonumber(APIVersions["live"])
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--!!!!!!!!!!! Update this if a new scan of set data was done on the new APIversion at the PTS  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--The last checked API version for the setsData in file "LibSets_Data.lua", see table "lib.setDataPreloaded = { ..."
-->Update here after a new scan of the set itemIds was done -> See LibSets_Data.lua, description in this file
-->above the sub-table ["setItemIds"] (data from debug function LibSets.DebugScanAllSetData())
lib.lastSetsPreloadedCheckAPIVersion = 101032 --Deadlands (2021-10-23, PTS, API 101032)
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
APIVersions["PTS"]                   = 101033 -- Ascending Tide, 2022-02-12
local APIVersionPTS                  = tonumber(APIVersions["PTS"])

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Update this if PTS increases to a new APIVersion !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--Check if the PTS APIVersion is now live
local function checkIfPTSAPIVersionIsLive()
    return (APIVersionLive >= APIVersionPTS) or false
end
lib.checkIfPTSAPIVersionIsLive = checkIfPTSAPIVersionIsLive
lib.APIVersions                = APIVersions
------------------------------------------------------------------------------------------------------------------------
--These values are used inside the debug function "scanAllSetData" (see file LibSets_Debug.lua) for scanning the setIds and
--their itemIds
lib.debugNumItemIdPackages     = 50         -- Increase this to find new added set itemIds after an update. It will be
--multiplied by lib.debugNumItemIdPackageSize to build the itemIds of the
--items to scan inagme for sets -> build an itemLink->uses GetItemLinkSetInfo()
lib.debugNumItemIdPackageSize  = 5000       -- do not increase this or the client may crash!
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
local fallbackLang             = "en"
lib.fallbackLang               = fallbackLang
local supportedLanguages       = {
    ["de"] = true,
    ["en"] = true,
    ["es"] = false, --TODO not yet supported as only on PTS!
    ["fr"] = true,
    ["ru"] = true,
    ["jp"] = false, --TODO: Working on: Waiting for SetNames & other translations by Calamath
}
lib.supportedLanguages         = supportedLanguages
local numSupportedLangs        = 0
for _, isSupported in pairs(supportedLanguages) do
    if isSupported == true then numSupportedLangs = numSupportedLangs + 1 end
end
lib.numSupportedLangs = numSupportedLangs

--The actual clients language
local clientLang      = GetCVar("language.2")
clientLang            = strlower(clientLang)
if not supportedLanguages[clientLang] then
    clientLang = fallbackLang --Fallback language if client language is not supported: English
end
lib.clientLang                                         = clientLang


------------------------------------------------------------------------------------------------------------------------
--Constants for the table keys of setInfo, setNames etc.
local noSetIdString                                    = "NoSetId"
LIBSETS_TABLEKEY_NEWSETIDS                             = "NewSetIDs"
LIBSETS_TABLEKEY_NAMES                                 = "Names"
LIBSETS_TABLEKEY_SETITEMIDS                            = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID                   = LIBSETS_TABLEKEY_SETITEMIDS .. noSetIdString
LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED                 = LIBSETS_TABLEKEY_SETITEMIDS .. "_Compressed"
LIBSETS_TABLEKEY_SETS_EQUIP_TYPES                      = "setsEquipTypes"
--LIBSETS_TABLEKEY_SETS_ARMOR                     = "setsWithArmor"
LIBSETS_TABLEKEY_SETS_ARMOR_TYPES                      = "setsArmorTypes"
LIBSETS_TABLEKEY_SETS_JEWELRY                          = "setsWithJewelry"
--LIBSETS_TABLEKEY_SETS_WEAPONS                   = "setsWithWeapons"
LIBSETS_TABLEKEY_SETS_WEAPONS_TYPES                    = "setsWeaponTypes"
LIBSETS_TABLEKEY_SETNAMES                              = "set" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_SETNAMES_NO_SETID                     = "set" .. LIBSETS_TABLEKEY_NAMES .. noSetIdString
LIBSETS_TABLEKEY_LASTCHECKEDAPIVERSION                 = "lastSetsCheckAPIVersion"
LIBSETS_TABLEKEY_NUMBONUSES                            = "numBonuses"
LIBSETS_TABLEKEY_MAXEQUIPPED                           = "maxEquipped"
LIBSETS_TABLEKEY_SETTYPE                               = "setType"
LIBSETS_TABLEKEY_MAPS                                  = "maps"
LIBSETS_TABLEKEY_WAYSHRINES                            = "wayshrines"
LIBSETS_TABLEKEY_WAYSHRINE_NAMES                       = "wayshrine" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_ZONEIDS                               = "zoneIds"
LIBSETS_TABLEKEY_ZONE_DATA                             = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA                    = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES                     = "collectible" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES                 = "collectible_DLC" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID                = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_DROPMECHANIC                          = "dropMechanic"
LIBSETS_TABLEKEY_DROPMECHANIC_NAMES                    = LIBSETS_TABLEKEY_DROPMECHANIC .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES            = LIBSETS_TABLEKEY_DROPMECHANIC .. "Tooltip" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES           = LIBSETS_TABLEKEY_DROPMECHANIC .. "DropLocation" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MIXED_SETNAMES                        = "MixedSetNamesForDataAll"
LIBSETS_TABLEKEY_SET_PROCS                             = "setProcs"
LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP              = "setProcsAllowedInPvP"
LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING     = "setItemCollectionsZoneMapping"



------------------------------------------------------------------------------------------------------------------------
--Set itemId table value (key is the itemId)
LIBSETS_SET_ITEMID_TABLE_VALUE_OK                      = 1
LIBSETS_SET_ITEMID_TABLE_VALUE_NOTOK                   = 2


------------------------------------------------------------------------------------------------------------------------
--Set proc check types (e.g. event_effect_changed, event_combat_event)
--SetprocCheckTypes
LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_EFFECT_CHANGED = 1     --Check abilityId via EVENT_EFFECT_CHANGED callback function
LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT   = 2     --Check abilityId via EVENT_COMBAT_EVENT callback function
LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE           = 4     --Check if a power updated at EVENT_POWER_UPDATE
LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED         = 5     --Check if a boss changed with EVENT_BOSSES_CHANGED
LIBSETS_SETPROC_CHECKTYPE_SPECIAL                      = 99    --Check with an own defined special callback function


------------------------------------------------------------------------------------------------------------------------
--Set types
--> If you change these be sure to check the following tables below and add/change/remove entries as well:
--lib.setTypeToLibraryInternalVariableNames
--lib.setTypesToName
local possibleSetTypes                                 = {
    [1]  = "LIBSETS_SETTYPE_ARENA", --"Arena"
    [2]  = "LIBSETS_SETTYPE_BATTLEGROUND", --"Battleground"
    [3]  = "LIBSETS_SETTYPE_CRAFTED", --"Crafted"
    [4]  = "LIBSETS_SETTYPE_CYRODIIL", --"Cyrodiil"
    [5]  = "LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD", --"DailyRandomDungeonAndICReward"
    [6]  = "LIBSETS_SETTYPE_DUNGEON", --"Dungeon"
    [7]  = "LIBSETS_SETTYPE_IMPERIALCITY", --"Imperial City"
    [8]  = "LIBSETS_SETTYPE_MONSTER", --"Monster"
    [9]  = "LIBSETS_SETTYPE_OVERLAND", --"Overland"
    [10] = "LIBSETS_SETTYPE_SPECIAL", --"Special"
    [11] = "LIBSETS_SETTYPE_TRIAL", --"Trial"
    [12] = "LIBSETS_SETTYPE_MYTHIC", --"Mythic"
    [13] = "LIBSETS_SETTYPE_IMPERIALCITY_MONSTER", --"Imperial City Monster"
}
--SetTypes only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --possibleSetTypes[13] = "..." --New LibSets set type
end
--Loop over the possible DLC ids and create them in the global table _G
for setTypeId, setTypeName in ipairs(possibleSetTypes) do
    _G[setTypeName] = setTypeId
end
local maxSetTypes               = #possibleSetTypes
LIBSETS_SETTYPE_ITERATION_BEGIN = LIBSETS_SETTYPE_ARENA
LIBSETS_SETTYPE_ITERATION_END   = _G[possibleSetTypes[maxSetTypes]]

lib.allowedSetTypes             = {}
for i = LIBSETS_SETTYPE_ITERATION_BEGIN, LIBSETS_SETTYPE_ITERATION_END do
    lib.allowedSetTypes[i] = true
end
------------------------------------------------------------------------------------------------------------------------
--Mapping between the LibSets setType and the used internal library table and counter variable
--------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets setTyps !!!
--------------------------------------------------------------------------
lib.setTypeToLibraryInternalVariableNames = {
    [LIBSETS_SETTYPE_ARENA]                         = {
        ["tableName"] = "arenaSets",
    },
    [LIBSETS_SETTYPE_BATTLEGROUND]                  = {
        ["tableName"] = "battlegroundSets",
    },
    [LIBSETS_SETTYPE_CRAFTED]                       = {
        ["tableName"] = "craftedSets",
    },
    [LIBSETS_SETTYPE_CYRODIIL]                      = {
        ["tableName"] = "cyrodiilSets",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = {
        ["tableName"] = "dailyRandomDungeonAndImperialCityRewardSets",
    },
    [LIBSETS_SETTYPE_DUNGEON]                       = {
        ["tableName"] = "dungeonSets",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY]                  = {
        ["tableName"] = "imperialCitySets",
    },
    [LIBSETS_SETTYPE_MONSTER]                       = {
        ["tableName"] = "monsterSets",
    },
    [LIBSETS_SETTYPE_OVERLAND]                      = {
        ["tableName"] = "overlandSets",
    },
    [LIBSETS_SETTYPE_SPECIAL]                       = {
        ["tableName"] = "specialSets",
    },
    [LIBSETS_SETTYPE_TRIAL]                         = {
        ["tableName"] = "trialSets",
    },
    [LIBSETS_SETTYPE_MYTHIC]                        = {
        ["tableName"] = "mythicSets",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = {
        ["tableName"] = "monsterSets",
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
lib.counterSuffix    = "Counter"
--The LibSets setType mapping table for names
--------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets setTyps !!!
--------------------------------------------------------------------------
local setTypesToName = {
    [LIBSETS_SETTYPE_ARENA]                         = {
        ["de"] = "Arena",
        ["en"] = "Arena",
        ["es"] = "Arena",
        ["fr"] = "Arène",
        ["jp"] = "アリーナ",
        ["ru"] = "Aрена",
    },
    [LIBSETS_SETTYPE_BATTLEGROUND]                  = {
        ["de"] = "Schlachtfeld", --SI_LEADERBOARDTYPE4,
        ["en"] = "Battleground",
        ["es"] = "Campo de batalla",
        ["fr"] = "Champ de bataille",
        ["jp"] = "バトルグラウンド",
        ["ru"] = "Поле сражений",
    },
    [LIBSETS_SETTYPE_CRAFTED]                       = {
        ["de"] = "Handwerklich hergestellt", --SI_ITEM_FORMAT_STR_CRAFTED
        ["en"] = "Crafted",
        ["es"] = "Hecho a mano",
        ["fr"] = "Fabriqué",
        ["jp"] = "クラフトセット",
        ["ru"] = "Созданный",
    },
    [LIBSETS_SETTYPE_CYRODIIL]                      = {
        ["de"] = "Cyrodiil", --SI_CAMPAIGNRULESETTYPE1,
        ["en"] = "Cyrodiil",
        ["es"] = "Cyrodiil",
        ["fr"] = "Cyrodiil",
        ["jp"] = "シロディール",
        ["ru"] = "Сиродил",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = {
        ["de"] = "Zufälliges Verlies & Kaiserstadt Belohnung", --SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT & SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4 SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR
        ["en"] = "Random Dungeons & Imperial city " .. zocstrfor("<<c:1>>", "Reward"),
        ["es"] = "Mazmorras aleatorias y ciudad imperial " .. zocstrfor("<<c:1>>", "Recompensa"),
        ["fr"] = "Donjons aléatoires & Cité impßériale " .. zocstrfor("<<c:1>>", "Récompense"),
        ["jp"] = "デイリー報酬",
        ["ru"] = "Случайное ежедневное подземелье и награда Имперского города",
    },
    [LIBSETS_SETTYPE_DUNGEON]                       = {
        ["de"] = "Verlies", --SI_INSTANCEDISPLAYTYPE2
        ["en"] = "Dungeon",
        ["es"] = "Calabozo",
        ["fr"] = "Donjon",
        ["jp"] = "ダンジョン",
        ["ru"] = "Подземелье",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY]                  = {
        ["de"] = "Kaiserstadt", --SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4
        ["en"] = "Imperial city",
        ["es"] = "Ciudad imperial",
        ["fr"] = "Cité impériale",
        ["jp"] = "帝都",
        ["ru"] = "Имперский город",
    },
    [LIBSETS_SETTYPE_MONSTER]                       = {
        ["de"] = "Monster",
        ["en"] = "Monster",
        ["es"] = "Monstruo",
        ["fr"] = "Monstre",
        ["jp"] = "モンスター",
        ["ru"] = "Монстр",
    },
    [LIBSETS_SETTYPE_OVERLAND]                      = {
        ["de"] = "Überland",
        ["en"] = "Overland",
        ["es"] = "Zone terrestre",
        ["fr"] = "Zone ouverte",
        ["jp"] = "陸上",
        ["ru"] = "Поверхности",
    },
    [LIBSETS_SETTYPE_SPECIAL]                       = {
        ["de"] = "Besonders", --SI_HOTBARCATEGORY9
        ["en"] = "Special",
        ["es"] = "Especial",
        ["fr"] = "Spécial",
        ["jp"] = "スペシャル",
        ["ru"] = "Специальный",
    },
    [LIBSETS_SETTYPE_TRIAL]                         = {
        ["de"] = "Prüfungen", --SI_LFGACTIVITY4
        ["en"] = "Trial",
        ["es"] = "Ensayo",
        ["fr"] = "Épreuves",
        ["jp"] = "試練",
        ["ru"] = "Испытание",
    },
    [LIBSETS_SETTYPE_MYTHIC]                        = {
        ["de"] = "Mythisch",
        ["en"] = "Mythic",
        ["es"] = "Mítico",
        ["fr"] = "Mythique",
        ["jp"] = "神話上の",
        ["ru"] = "мифический",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = {
        ["de"] = "Kaiserstadt Monster",
        ["en"] = "Imperial city monster",
        ["es"] = "Ciudad imperial monstruo",
        ["fr"] = "Cité impériale monstre",
        ["jp"] = "帝都 モンスター",
        ["ru"] = "Имперский город Монстр",
    },
}
--Translations only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --[[
    setTypesToName[LIBSETS_SETTYPE_*                       ] = {
        ["de"] = "",
        ["en"] = "",
        ["fr"] = "",
        ["jp"] = "",
        ["ru"] = "",
    }
    ]]
end
lib.setTypesToName                  = setTypesToName

------------------------------------------------------------------------------------------------------------------------
--Mapping table setType to setIds for this settype.
-->Will be filled in file LibSets.lua, function LoadSets()
lib.setTypeToSetIdsForSetTypeTable  = {}
------------------------------------------------------------------------------------------------------------------------
--The itemTypes possible to be used for setItems
lib.setItemTypes                    = {
    [ITEMTYPE_ARMOR]  = true,
    [ITEMTYPE_WEAPON] = true,
}
--The equipment types valid for set items
lib.equipTypesValid                 = {
    --Not allowed
    [EQUIP_TYPE_INVALID]   = false,
    [EQUIP_TYPE_COSTUME]   = false,
    [EQUIP_TYPE_POISON]    = false,
    --Allowed
    [EQUIP_TYPE_CHEST]     = true,
    [EQUIP_TYPE_FEET]      = true,
    [EQUIP_TYPE_HAND]      = true,
    [EQUIP_TYPE_HEAD]      = true,
    [EQUIP_TYPE_LEGS]      = true,
    [EQUIP_TYPE_MAIN_HAND] = true,
    [EQUIP_TYPE_NECK]      = true,
    [EQUIP_TYPE_OFF_HAND]  = true,
    [EQUIP_TYPE_ONE_HAND]  = true,
    [EQUIP_TYPE_RING]      = true,
    [EQUIP_TYPE_SHOULDERS] = true,
    [EQUIP_TYPE_TWO_HAND]  = true,
    [EQUIP_TYPE_WAIST]     = true,
}
--The equip type check tables
--Jewelry
lib.isJewelryEquipType              = {
    [EQUIP_TYPE_NECK] = true,
    [EQUIP_TYPE_RING] = true,
}
--Weapons
lib.isWeaponEquipType               = {
    [EQUIP_TYPE_MAIN_HAND] = true,
    [EQUIP_TYPE_OFF_HAND]  = true,
    [EQUIP_TYPE_ONE_HAND]  = true,
    [EQUIP_TYPE_TWO_HAND]  = true,
}

--The trait types valid for set items
lib.traitTypesValid                 = {
    --Not allowed
    --Allowed
    [ITEM_TRAIT_TYPE_NONE]                 = true,
    --Armor
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]        = true,
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]   = true,
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]        = true,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]      = true,
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = true,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]         = true,
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = true,
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = true,
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = true,
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = true,
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]    = true,
    --Jewelry
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = true,
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]    = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]       = true,
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]   = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = true,
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = true,
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]       = true,
    --Weapons
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]      = true,
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]        = true,
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING]      = true,
}
--The enchanting EnchantmentSearchCategoryType that are valid
lib.enchantSearchCategoryTypesValid = {
    --Not allowed
    --Allowed
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_HEALTH]                 = true,
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_MAGICKA]                = true,
    [ENCHANTMENT_SEARCH_CATEGORY_ABSORB_STAMINA]                = true,
    [ENCHANTMENT_SEARCH_CATEGORY_BEFOULED_WEAPON]               = true,
    [ENCHANTMENT_SEARCH_CATEGORY_BERSERKER]                     = true,
    [ENCHANTMENT_SEARCH_CATEGORY_CHARGED_WEAPON]                = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_HEALTH]                 = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DAMAGE_SHIELD]                 = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DECREASE_PHYSICAL_DAMAGE]      = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DECREASE_SPELL_DAMAGE]         = true,
    [ENCHANTMENT_SEARCH_CATEGORY_DISEASE_RESISTANT]             = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FIERY_WEAPON]                  = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FIRE_RESISTANT]                = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FROST_RESISTANT]               = true,
    [ENCHANTMENT_SEARCH_CATEGORY_FROZEN_WEAPON]                 = true,
    [ENCHANTMENT_SEARCH_CATEGORY_HEALTH]                        = true,
    [ENCHANTMENT_SEARCH_CATEGORY_HEALTH_REGEN]                  = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_BASH_DAMAGE]          = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_PHYSICAL_DAMAGE]      = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_POTION_EFFECTIVENESS] = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INCREASE_SPELL_DAMAGE]         = true,
    [ENCHANTMENT_SEARCH_CATEGORY_INVALID]                       = true,
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA]                       = true,
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN]                 = true,
    [ENCHANTMENT_SEARCH_CATEGORY_NONE]                          = true,
    [ENCHANTMENT_SEARCH_CATEGORY_POISONED_WEAPON]               = true,
    [ENCHANTMENT_SEARCH_CATEGORY_POISON_RESISTANT]              = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_DEFENSE]             = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_ONSLAUGHT]           = true,
    [ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_REGEN]               = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_ARMOR]                  = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_BLOCK_AND_BASH]         = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_FEAT_COST]              = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POTION_COOLDOWN]        = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER]                  = true,
    [ENCHANTMENT_SEARCH_CATEGORY_REDUCE_SPELL_COST]             = true,
    [ENCHANTMENT_SEARCH_CATEGORY_SHOCK_RESISTANT]               = true,
    [ENCHANTMENT_SEARCH_CATEGORY_STAMINA]                       = true,
    [ENCHANTMENT_SEARCH_CATEGORY_STAMINA_REGEN]                 = true,
}
--Variables for the generateddata tables, coming from the preloaded setitem data
lib.equipTypesSets                  = {}
lib.armorSets                       = {}
lib.armorTypesSets                  = {}
lib.jewelrySets                     = {}
lib.weaponSets                      = {}
lib.weaponTypesSets                 = {}

------------------------------------------------------------------------------------------------------------------------
--Number of currently available set bonus for a monster set piece (2: head, shoulder)
lib.countMonsterSetBonus            = 2
------------------------------------------------------------------------------------------------------------------------
--DLC & Chapter ID constants (for LibSets)
--> LibSets_Constants_<APIVersion>.lua for the given DLC constants for each API version!
------------------------------------------------------------------------------------------------------------------------
--The undaunted chest count
lib.countUndauntedChests            = 3
--The undaunted chest NPC names
local undauntedChestIds             = {
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
    ["es"] = {
        [1] = "Glirion the Redbeard", --todo
        [2] = "Maj al-Ragath", --todo
        [3] = "Urgarlag Chief-bane", --todo
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
    }, }
lib.undauntedChestIds               = undauntedChestIds
------------------------------------------------------------------------------------------------------------------------
lib.armorTypeNames                  = {
    [ARMORTYPE_LIGHT]  = GetString(SI_ARMORTYPE1) or "Light",
    [ARMORTYPE_MEDIUM] = GetString(SI_ARMORTYPE2) or "Medium",
    [ARMORTYPE_HEAVY]  = GetString(SI_ARMORTYPE3) or "Heavy",
}
------------------------------------------------------------------------------------------------------------------------
lib.weaponTypeNames                 = {
    [WEAPONTYPE_NONE]              = GetString(SI_WEAPONTYPE0),
    [WEAPONTYPE_AXE]               = GetString(SI_WEAPONTYPE1),
    [WEAPONTYPE_BOW]               = GetString(SI_WEAPONTYPE8),
    [WEAPONTYPE_DAGGER]            = GetString(SI_WEAPONTYPE11),
    [WEAPONTYPE_FIRE_STAFF]        = GetString(SI_WEAPONTYPE12),
    [WEAPONTYPE_FROST_STAFF]       = GetString(SI_WEAPONTYPE13),
    [WEAPONTYPE_HAMMER]            = GetString(SI_WEAPONTYPE2),
    [WEAPONTYPE_HEALING_STAFF]     = GetString(SI_WEAPONTYPE9),
    [WEAPONTYPE_LIGHTNING_STAFF]   = GetString(SI_WEAPONTYPE15),
    [WEAPONTYPE_RUNE]              = GetString(SI_WEAPONTYPE10),
    [WEAPONTYPE_SHIELD]            = GetString(SI_WEAPONTYPE14),
    [WEAPONTYPE_SWORD]             = GetString(SI_WEAPONTYPE3),
    [WEAPONTYPE_TWO_HANDED_AXE]    = GetString(SI_WEAPONTYPE5),
    [WEAPONTYPE_TWO_HANDED_HAMMER] = GetString(SI_WEAPONTYPE6),
    [WEAPONTYPE_TWO_HANDED_SWORD]  = GetString(SI_WEAPONTYPE4),
}
------------------------------------------------------------------------------------------------------------------------
--Drop mechanics / cities / etc. for additional drop location information
local possibleDropMechanics         = {
    [1]  = "LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY", --Rewards for the worthy (Cyrodiil/Battleground mail)
    [2]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA", --City Bruma (quartermaster)
    [3]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD", --City Cropsford (quartermaster)
    [4]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS", --City Vlastarus (quartermaster)
    [5]  = "LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST", --Arena stage chest
    [6]  = "LIBSETS_DROP_MECHANIC_MONSTER_NAME", --The name of a monster (e.g. a boss in a dungeon) is specified in the excel and transfered to the setInfo table entry with the attribute "dropMechanicNames" (a table containing the monster name in different languages)
    [7]  = "LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE", --Overland delve bosses
    [8]  = "LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS", --Overland world group bosses
    [9]  = "LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON", --Overland public dungeon bosses
    [10] = "LIBSETS_DROP_MECHANIC_OVERLAND_CHEST", --Overland chests
    [11] = "LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD", --Battleground rewards
    [12] = "LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD", --Daily random dungeon mail rewards
    [13] = "LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS", --Imperial city vaults
    [14] = "LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD", --Level up reward
    [15] = "LIBSETS_DROP_MECHANIC_ANTIQUITIES", --Antiquities (Mythic set items)
    [16] = "LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR", --Battleground vendor
    [17] = "LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT", --Tel Var equipment lockbox merchant
    [18] = "LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT", --Alliance points Elite gear merchant
    [19] = "LIBSETS_DROP_MECHANIC_REWARD_BY_NPC", --A named NPC rewards this item
    [20] = "LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST", --Oblivion portal final boss chest
    [21] = "LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES", --Dolmen, Harrowstorms, Magical anomalies reward
    [22] = "LIBSETS_DROP_MECHANIC_DUNGEON_CHEST", --Chests in a dungeon	Truhen in einem Verlies
    [23] = "LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER", --Daily quest reward coffer	Tägliche Quest Belohnungs-Kisten
    [24] = "LIBSETS_DROP_MECHANIC_FISHING_HOLE", --Fishing hole
    [25] = "LIBSETS_DROP_MECHANIC_OVERLAND_LOOT", --Loot from overland items
    [26] = "LIBSETS_DROP_MECHANIC_TRIAL_BOSS", --Trial bosses
    [27] = "LIBSETS_DROP_MECHANIC_MOB_TYPE", --A type of mob/critter
    [28] = "LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS", --Bosses in group dungeons
    [29] = "LIBSETS_DROP_MECHANIC_CRAFTED", --Crafted
}
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
    --LIBSETS_DROP_MECHANIC_... = number
    --possibleDropMechanics[xx] = "LIBSETS_DROP_MECHANIC_..." --new dropmechanic ...
end
--Loop over the possible DLC ids and create them in the global table _G
for dropMechanicId, dropMechanicName in ipairs(possibleDropMechanics) do
    _G[dropMechanicName] = dropMechanicId
end
local maxDropMechanicIds              = #possibleDropMechanics
LIBSETS_DROP_MECHANIC_ITERATION_BEGIN = 1
LIBSETS_DROP_MECHANIC_ITERATION_END   = _G[possibleDropMechanics[maxDropMechanicIds]]

lib.allowedDropMechanics              = { }
for i = LIBSETS_DROP_MECHANIC_ITERATION_BEGIN, LIBSETS_DROP_MECHANIC_ITERATION_END do
    lib.allowedDropMechanics[i] = true
end
------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets drop mechanics !!!
-------------------------------------------------------------------------------
---The names of the drop mechanics
local cyrodiilAndBattlegroundText = GetString(SI_CAMPAIGNRULESETTYPE1) .. "/" .. GetString(SI_LEADERBOARDTYPE4)
lib.dropMechanicIdToName          = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Gerechter Lohn (" .. cyrodiilAndBattlegroundText .. " eMail)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil Stadt: Bruma (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil Stadt: Erntefurt (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil Stadt: Vlastarus (Quartiermeister)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Arena-Phasen Schatztruhe",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Monster Name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Bosse in Gewölben",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Überland Gruppenbosse",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Öffentliche Dungeon-Bosse",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Überland/Verlies Truhen",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Belohnung in Schlachtfeldern",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Tägliches Zufallsverlies Belohnungsemail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Kaiserstadt Bunker",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Level Aufstieg Belohnung",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Tel Var Ausrüstungs Box Händler, IC Kanalisation Basis",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Allianzpunkte Elite Gear Box Händler, Cyrodiil",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "Ein benannter NPC belohnt mit diesem Gegenstand",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Oblivion Portal letzte Boss Kiste",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Belohnungen von Dolmen, Gramstürmen, Magischen Anomalien",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Truhen in einem Verlies", --Chests in a dungeon
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Tägliche Quest Belohnungs-Kisten", --Daily quest reward coffer
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Fischloch",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Überland Loot Gegenstände",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Bosse in Prüfungen",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Gegner Typ",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Bosse in Gruppenverliesen",
    },
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Rewards for the worthy",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil City: Bruma (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil City: Cropsford (quartermaster)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil City: Vlastarus (quartermaster)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Arena stage chest",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Monster name",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Delve bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Overland group bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Public dungeon bosses",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Overland/Delve chests",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Battlegounds reward",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Daily random dungeon reward mail",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Imperial city vaults",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Level up reward",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Tel Var equipment lockbox merchant, IC sewer base",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Alliance points elite gear lockbox merchant, Cyrodiil/Vvardenfell",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "A named NPC rewards with this item",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Oblivion portal final boss chest",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Dolmen, Harrowstorms, Magical anomalies reward",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Chests in a dungeon",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Daily quest reward coffer",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Fishing hole",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Loot from overland items",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Bosses in trial dungeons",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Mob/Critter type",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Bosses in group dungeons",
        --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                          = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE11),
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR]                  = GetString(SI_LEADERBOARDTYPE4) .. " " .. GetString(SI_MAPDISPLAYFILTER2), --Battleground vendors
        [LIBSETS_DROP_MECHANIC_CRAFTED]                              = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
    },
    ["es"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Recompensa por el mérito",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Ciudad Cyrodiil: Bruma (intendente)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Ciudad Cyrodiil: Cropsford (intendente)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Ciudad Cyrodiil: Vlastarus (intendente)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Cofre de escenario Arena",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Nombre del monstruo",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Los jefes de cuevas",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Los jefes del mundo",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Los jefes de mazmorras públicas",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Los cofres encontrados por el mundo",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Recompensa de campos de batalla",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Mail de recompensa de mazmorra aleatorio diario",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Bóvedas de la ciudad imperial",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Recompensa por subir de nivel",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Mercader de cofres de equipamiento de Tel Var, base de las alcantarillas de la Ciudad Imperial",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Mercader de cofres de equipamiento de élite por Puntos de Alianza, Cyrodiil/Páramo de Vvarden",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "Recompensa dada por un PNJ con nombre propio",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Cofre del jefe final de un portal de Oblivion",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Recompensa de áncoras, tormentas segadoras y anomalías mágicas",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Cofres de mazmorra",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Cofre de recompensa de misión diaria",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Bancos de peces",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Encontrado en contenedores del mundo",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Jefes en mazmorras de prueba",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Tipo de enemigo/bicho",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Jefes en mazmorras grupales",
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "La récompense des braves",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil Ville: Bruma (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil Ville: Gué-les-Champs (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil Ville: Vlastrus (maître de manœuvre)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Coffre d'étape Arena",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Nom du monstre",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Les boss de petit donjon",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Les boss de zone ouvertes",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Les boss de donjon public",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Les coffres de zone/donjon ouvertes",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Récompense de Champ de bataille",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Courrier de récompense de donjon journalière",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Cité impériale voûte",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Récompense de niveau supérieur",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Tel Var equipment lockbox merchant, IC sewer base",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Alliance points elite gear lockbox merchant, Cyrodiil/Vvardenfell",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "A named NPC rewards with this item",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Oblivion portal final boss chest",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Dolmen, Harrowstorms, Magical anomalies reward",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Chests in a dungeon",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Daily quest reward coffer",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Fishing hole",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Loot from overland items",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Bosses in trial dungeons",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Mob/Critter type",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Bosses in group dungeons",
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Награда достойным",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Сиродил: город Брума (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Сиродил: город Кропсфорд (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Сиродил: город Властарус (квартирмейстер)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Этап арены",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Имя монстра",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Боссы вылазок",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Групповые боссы",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Боссы открытых подземелий",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Сундуки",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Награды полей сражений",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Письмо с наградой за ежедневное случайное подземелье",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Хранилища Имперского города",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Вознаграждение за повышение уровня",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Tel Var equipment lockbox merchant, IC sewer base",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Alliance points elite gear lockbox merchant, Cyrodiil/Vvardenfell",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "A named NPC rewards with this item",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Oblivion portal final boss chest",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Dolmen, Harrowstorms, Magical anomalies reward",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Chests in a dungeon",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Daily quest reward coffer",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Fishing hole",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Loot from overland items",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Bosses in trial dungeons",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Mob/Critter type",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Bosses in group dungeons",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "貢献に見合った報酬です",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil シティ: ブルーマ (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil シティ: クロップスフォード (補給係)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil シティ: ヴラスタルス (補給係)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "アリーナステージチェスト",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "モンスター名",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "洞窟ボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "ワールドボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "パブリックダンジョンのボス",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "宝箱",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "バトルグラウンドの報酬",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "デイリーランダムダンジョン報酬メール",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "帝都の宝物庫",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "レベルアップ報酬",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Tel Var equipment lockbox merchant, IC sewer base",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Alliance points elite gear lockbox merchant, Cyrodiil/Vvardenfell",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "A named NPC rewards with this item",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Oblivion portal final boss chest",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Dolmen, Harrowstorms, Magical anomalies reward",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Chests in a dungeon",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Daily quest reward coffer",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Fishing hole",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Loot from overland items",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Bosses in trial dungeons",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Mob/Critter type",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Bosses in group dungeons",
    },
}
lib.dropMechanicIdToNameTooltip   = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = cyrodiilAndBattlegroundText .. " mail",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Bosse in Gewölben haben die Chance, eine Taille oder Füße fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Überland Gruppenbosse haben eine Chance von 100%, Kopf, Brust, Beine oder Waffen fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Öffentliche Dungeon-Bosse haben die Möglichkeit, eine Schulter, Handschuhe oder eine Waffe fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Truhen, die durch das Besiegen eines Dunklen Ankers gewonnen wurden, haben eine Chance von 100%, einen Ring oder ein Amulett fallen zu lassen.\nSchatztruhen, welche man in der Zone findet, haben eine Chance irgendein Setteil zu gewähren, das in dieser Zone droppen kann:\n-Einfache Truhen haben eine geringe Chance\n-Mittlere Truhen haben eine gute Chance\n-Fortgeschrittene- und Meisterhafte-Truhen haben eine garantierte Chance\n-Schatztruhen, die durch eine Schatzkarte gefunden wurden, haben eine garantierte Chance",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Truhe, welche man bei einem TelVar Ausrüstungs Händler in der eigenne Fraktionsbasis in der Kaiserstadt Kanalisation für TelVar Steine eintauschen kann.",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]    = "Truhe, welche man bei einem Elite Gear Händler in Cyrodiil (Östliches Elsweyr Tor, Südliches Hochfels Tor, Nördliches Morrowind Tor), oder in Vvardenfall für Schlachtfelder (Ald Carac, Foyada Quarry, Ularra), für Allianzpunkte kaufen kann.",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "Alle Bosse: Hände, Taille, Füße, Brust, Schultern, Kopf, Beine\nLetzte Bosse: Waffen, Schild\nQuest Belohnung: Schmuck, Waffe, Schild (Gebunden beim Aufheben)",
    },
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Rewards for the worthy (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Delve bosses have a chance to drop a waist or feet.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Overland group bosses have a 100% chance to drop head, chest, legs, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Public dungeon bosses have a chance to drop a shoulder, hand, or weapon.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Chests gained from defeating a Dark Anchor have a 100% chance to drop a ring or amulet.\nTreasure chests found in the world have a chance to grant any set piece that can drop in that zone:\n-Simple chests have a slight chance\n-Intermediate chests have a good chance\n-Advanced and Master chests have a guaranteed chance\n-Treasure chests found from a Treasure Map have a guaranteed chance",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                       = GetString(SI_ANTIQUITY_TOOLTIP_TAG), --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Chest that can be exchanged for TelVar Stones at a TelVar equipment vendor in your faction's base, in the Imperial City sewers.",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]    = "Chest that can be exchanged for Alliance Points at a elite gear lockbox merchant in Cyrodiil (Eastern Elsweyr Gate, Southern High Rock Gate, Northern Morrowind Gate), or a battleground merchant in Vvardenfell (Ald Carac, Foyada Quarry, Ularra)",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "All bosses: Hands, Waist, Feet, Chest, Shoulder, Head, Legs\nFinal bosses: Weapon, Shield\nQuest reward containers: Jewelry, Weapon, Shield (Binds on pickup))",
    },
    ["es"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Recompensa por el mérito (" .. cyrodiilAndBattlegroundText .. " mail)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Los jefes de cuevas pueden soltar cinturones o calzado.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Los jefes del mundo sueltan siempre piezas de cabeza, pecho, piernas, o armas.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Los jefes de mazmorras públicas pueden soltar hombreras, guantes, o armas.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Los cofres de áncoras oscuras sueltan siempre anillos o amuletos.\nLos cofres encontrados por el mundo pueden soltar cualquier pieza de armadura de un conjunto propio de la zona:\n-Los cofres sencillos tienen una ligera probabilidad\n-Los cofres intermedios tienen una buena probabilidad\n-Los cofres avanzados o de maestro tienen 100% de probabilidad\n-Los cofres encontrados con un mapa del tesoro tienen 100% de probabilidad",
        --todo
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Chest that can be exchanged for TelVar Stones at a TelVar equipment vendor in your faction's base, in the Imperial City sewers.",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "All bosses: Hands, Waist, Feet, Chest, Shoulder, Head, Legs\nFinal bosses: Weapon, Shield\nQuest reward containers: Jewelry, Weapon, Shield (Binds on pickup))",
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "La récompense des braves (" .. cyrodiilAndBattlegroundText .. " email)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Les boss de petit donjon ont une chance de laisser tomber une taille ou des pieds.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Les boss de zone ouvertes ont 100% de chances de laisser tomber la tête, la poitrine, les jambes ou l'arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Les boss de donjon public ont une chance de laisser tomber une épaule, une main ou une arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Les coffres obtenus en battant une ancre noire ont 100% de chances de laisser tomber un anneau ou une amulette.\nLes coffres au trésor trouvés dans le monde ont une chance d'accorder n'importe quelle pièce fixe qui peut tomber dans cette zone:\n-les coffres simples ont une légère chance \n-Les coffres intermédiaires ont de bonnes chances\n-Les coffres avancés et les maîtres ont une chance garantie\n-Les coffres au trésor trouvés sur une carte au trésor ont une chance garantie",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Coffre qui peut être échangé contre des pierres TelVar auprès d'un vendeur d'équipement TelVar dans votre base de faction, dans les égouts de la cité impériale.",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "All bosses: Hands, Waist, Feet, Chest, Shoulder, Head, Legs\nFinal bosses: Weapon, Shield\nQuest reward containers: Jewelry, Weapon, Shield (Binds on pickup))",
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Награда достойным (" .. cyrodiilAndBattlegroundText .. " почта)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Боссы вылазок дают шанс выпадания талии или голени.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Групповые боссы дают 100% шанс выпадания головы, груди, ног или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Боссы открытых подземелий дают шанс выпадания плечей, рук или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Сундуки, полученные после побед над Тёмными якорями, имеют 100% шанс выпадания кольца или амулета.\nСундуки сокровищ, найденные в мире, дают шанс получить любую часть комплекта, выпадающую в этой зоне:\n- простые сундуки дают незначительный шанс\n- средние сундуки дают хороший шанс\n- продвинутые и мастерские сундуки дают гарантированный шанс\n- сундуки сокровищ, найденные по Карте сокровищ, дают гарантированный шанс",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Сундук, который можно обменять на камни ТелВар у продавца оборудования ТелВар на базе вашей фракции в канализации Имперского города",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "All bosses: Hands, Waist, Feet, Chest, Shoulder, Head, Legs\nFinal bosses: Weapon, Shield\nQuest reward containers: Jewelry, Weapon, Shield (Binds on pickup))",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "貢献に見合った報酬です (" .. cyrodiilAndBattlegroundText .. " メール)",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "洞窟ボスは、胴体や足装備をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "ワールドボスは、頭、腰、脚の各防具、または武器のいずれかが必ずドロップします。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "パブリックダンジョンのボスは、肩、手の各防具、または武器をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "ダークアンカー撃破報酬の宝箱からは、指輪かアミュレットが必ずドロップします。\n地上エリアで見つけた宝箱からは、そのゾーンでドロップするセット装備を入手できます。:\n-簡単な宝箱からは低確率で入手できます。\n-中級の宝箱からは高確率で入手できます。\n-上級やマスターの宝箱からは100%入手できます。\n-「宝の地図」で見つけた宝箱からは100%入手できます。",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "「インペリアルシティ下水道の派閥基地にあるTelVar機器ベンダーでTelVarストーンと交換できるチェスト。」",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "All bosses: Hands, Waist, Feet, Chest, Shoulder, Head, Legs\nFinal bosses: Weapon, Shield\nQuest reward containers: Jewelry, Weapon, Shield (Binds on pickup))",
    },
}
--DropMechanic translations only available on current PTS, or automatically available if PTS->live
if checkIfPTSAPIVersionIsLive() then
    --[[
    lib.dropMechanicIdToName["en"][LIBSETS_DROP_MECHANIC_*] = GetString(SI_*)
    lib.dropMechanicIdToNameTooltip["en"][LIBSETS_DROP_MECHANIC_*] = ""
    ]]
end

--Localized texts
local undauntedStr               = GetString(SI_VISUALARMORTYPE4)
local dungeonStr                 = GetString(SI_INSTANCEDISPLAYTYPE2)
local setTypeArenaName           = setTypesToName[LIBSETS_SETTYPE_ARENA]
lib.localization                 = {
    ["de"] = {
        dlc                      = "Kapitel/DLC",
        dropZones                = "Drop Zonen",
        dropZoneArena            = setTypeArenaName["de"],
        dropZoneImperialSewers   = "Kanalisation der Kaiserstadt",
        droppedBy                = "Drop durch",
        setType                  = "Set Art",
        reconstructionCosts      = "Rekonstruktions Kosten",
        neededTraits             = "Eigenschaften benötigt (Analyse)",
        dropMechanic             = "Drop Mechanik",
        undauntedChest           = undauntedStr .. " Truhe",
        modifyTooltip            = "Tooltip um Set Infos erweitern",
        tooltipTextures          = "Zeige Tooltip Symbole",
        tooltipTextures_T        = "Zeige Symbole für Set Art, Drop Mechanik, Location/Boss Name, ... im Tooltip",
        defaultTooltipPattern    = "Voreingestellter Tooltip",
        defaultTooltipPattern_TT = "Nutze die Auswahlfelder um die entsprechende Information über die Set Gegenstände im Gegenstandstooltip anzuzeigen.\nDas standard Ausgabeformat ist:\n\n\<Symbol><Set Art Name> <wenn handwerklich herstellbar: (Eigenschaften benötigt)>\n<Drop Zonen Info> [bestehend aus <ZonenName> (<DropMechanik>: <DropMechanikDropName>)]\<DLC Name>\nWenn alle Zonen identisch sind werden DropMechanic und Ort/Boss Namen ; getrennt als 1 Zeile ausgegeben.",
        customTooltipPattern     = "Selbst definierter Tooltip Text",
        customTooltipPattern_TT  = "Definiere deinen eigenen Tooltip Text, inklusive vor-definierter Platzhalter. Beispiel: \'Art <<1>>/Drop <<2>> <<3>> <<4>>\'.\nLasse dieses Textfeld leer, um den eigenen Tooltip Text zu deaktivieren!\nPlatzhalter müssen mit << beginnen, danach folt eine 1stellige Nummer, und beendet werden diese mit >>, z.B. <<1>> oder <<5>>. Es gibt maximal 6 Platzhalter in einem Text. Zeilenumbruch: <br>\n\nMögliche Platzhalter sind:\n<<1>>   Set Art\n<<2>>   Drop Mechaniken [können mehrere \',\' getrennte sein, je Zone 1]\n<<3>>   Drop Zonen [können mehrere \',\' getrennte sein, je Zone 1] Sind alle Zonen identisch wird nur 1 ausgegeben\n<<4>>   Boss/Drop durch Namen [können mehrere \',\' getrennte sein, je Zone 1]\n<<5>>   Benötigte Anzahl analysierter Eigenschaten\n<<6>>   Kapitel/DLC Name mit dem das Set eingeführt wurde.\n\n|cFF0000Achtung|r: Wenn du einen ungültigen Tooltip Text, ohne irgendeinen <<Nummer>> Platzhalter, eingibst wird sich das Textfeld automatisch selber leeren!",
    },
    ["en"] = {
        dlc                      = "Chapter/DLC",
        dropZones                = "Drop zones",
        dropZoneDelve            = GetString(SI_INSTANCEDISPLAYTYPE7),
        dropZoneDungeon          = dungeonStr,
        dropZoneVeteranDungeon   = GetString(SI_DUNGEONDIFFICULTY2) .. " " .. dungeonStr,
        dropZonePublicDungeon    = GetString(SI_INSTANCEDISPLAYTYPE6),
        dropZoneBattleground     = GetString(SI_INSTANCEDISPLAYTYPE9),
        dropZoneTrial            = GetString(SI_LFGACTIVITY4),
        dropZoneArena            = setTypeArenaName["en"],
        dropZoneMail             = GetString(SI_WINDOW_TITLE_MAIL),
        dropZoneCrafted          = GetString(SI_SPECIALIZEDITEMTYPE213),
        dropZoneCyrodiil         = GetString(SI_CAMPAIGNRULESETTYPE1),
        dropZoneMonster          = dungeonStr,
        dropZoneImperialCity     = GetString(SI_CAMPAIGNRULESETTYPE4),
        dropZoneImperialSewers   = "Imperial City Sewers",
        --dropZoneOverland =          GetString(),
        dropZoneSpecial          = GetString(SI_HOTBARCATEGORY9),
        dropZoneMythic           = GetString(SI_ITEMDISPLAYQUALITY6),
        droppedBy                = "Dropped by",
        reconstructionCosts      = "Reconstruction cost",
        setType                  = "Set type",
        neededTraits             = "Traits needed (research)",
        dropMechanic             = "Drop mechanics",
        undauntedChest           = undauntedStr .. " chest",
        boss                     = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES501),
        modifyTooltip            = "Enhance tooltip by set info",
        tooltipTextures          = "Show tooltip textures",
        tooltipTextures_T        = "Show textures for the set type, drop mechanics and location/boss names ... within the tooltip",
        defaultTooltipPattern    = "Default tooltip",
        defaultTooltipPattern_TT = "Use the checkboxes to add this information about set items at the item tooltips.\nThe default output format is:\n\n<texture><set type name> <if craftable set: (traits needed>)\n<Drop zone info> [containing <zoneName> (<dropMechanic>: dropMechanicDropLocation>)]\n<DLC name>\nIf all zones are the same the dropMechanic and locatiton/boss names will be added as 1 line ; separated.",
        customTooltipPattern     = "Custom tooltip text",
        customTooltipPattern_TT  = "Define your own custom tooltip text, including the possibility to use some pre-defined placeholders in your text. Example: \'Type <<1>>/Drops <<2>> <<3>> <<4>>\'.\nLeave the text field empty to disable this custom tooltip!\nPlaceholders need to start with prefix << followed by a 1 digit number and a suffix of >>, e.g. <<1>> or <<5>>.\nThere can be only a maximum of 6 placeholders in the text. Line break: <br>\n\nBelow you'll find the possible placeholders:\n<<1>>   Set type\n<<2>>   Drop mechanics [could be several, for each zone, separated by \',\']\n<<3>>   Drop zones [could be several, for each zone, separated by \',\'] If all zones are the same they will be condensed\n<<4>>   Boss/Dropped by names [could be several, for each zone, separated by \',\']\n<<5>>   Number of needed traits researched\n<<6>>   Chapter/DLC name set was introduced with.\n\n|cFF0000Attention|r: If you enter an invalid tooltip text, without any <<number>> placeholder the editfield will automatically clear itsself!",
    },
    ["es"] = {
        dlc                    = "Capítulo/DLC",
        dropZones              = "Zonas de caída",
        dropZoneArena          = setTypeArenaName["es"],
        dropZoneImperialSewers = "Alcantarillas de la Ciudad Imperial",
        droppedBy              = "Dejado por",
        setType                = "Tipo de conjunto",
        dropMechanic           = "Mecanica de caída",
        undauntedChest         = undauntedStr .. " cofre",
        modifyTooltip          = "Mejorar información sobre herramientas por información de conjunto",
    },
    ["fr"] = {
        dlc                    = "Chapitre/DLC",
        dropZones              = "Zones de largage",
        dropZoneArena          = setTypeArenaName["fr"],
        dropZoneImperialSewers = "Égouts de la cité impériale",
        droppedBy              = "Dépouillé par",
        setType                = "Type de set",
        dropMechanic           = "Mécanique de largage",
        undauntedChest         = "Poitrine de " .. undauntedStr,
        modifyTooltip          = "Améliorer l'info-bulle par les informations sur l'ensemble",
    },
    ["ru"] = {
        dlc                    = "Глава/DLC",
        dropZones              = "Зоны сброса",
        dropZoneArena          = setTypeArenaName["ru"],
        dropZoneImperialSewers = "Канализация Имперского города",
        droppedBy              = "Снизился на",
        setType                = "Тип набора",
        dropMechanic           = "Механика падения",
        undauntedChest         = undauntedStr .. " грудь",
        modifyTooltip          = "Улучшить всплывающую подсказку с помощью информации о наборе элементов",
    },
    ["jp"] = {
        dlc                    = "チャプター/ DLC",
        dropZones              = "ドロップゾーン",
        dropZoneArena          = setTypeArenaName["jp"],
        dropZoneImperialSewers = "インペリアルシティ下水道",
        droppedBy              = "によってドロップ",
        setType                = "セットの種類",
        dropMechanic           = "ドロップメカニック",
        undauntedChest         = undauntedStr .. " 胸",
        modifyTooltip          = "アイテムセット情報によるツールチップの強化",
    },
}

--Set metatable to get EN entries for missing other languages
local dropMechanicNames          = lib.dropMechanicIdToName
local dropMechanicNamesEn        = dropMechanicNames["en"]

local dropMechanicTooltipNames   = lib.dropMechanicIdToNameTooltip
local dropMechanicTooltipNamesEn = dropMechanicTooltipNames["en"]

local localization               = lib.localization
local localizationEn             = lib.localization["en"]

setmetatable(dropMechanicNames["de"], { __index = dropMechanicNamesEn })
setmetatable(dropMechanicNames["es"], { __index = dropMechanicNamesEn })
setmetatable(dropMechanicNames["fr"], { __index = dropMechanicNamesEn })
setmetatable(dropMechanicNames["jp"], { __index = dropMechanicNamesEn })
setmetatable(dropMechanicNames["ru"], { __index = dropMechanicNamesEn })

setmetatable(dropMechanicTooltipNames["de"], { __index = dropMechanicTooltipNamesEn })
setmetatable(dropMechanicTooltipNames["es"], { __index = dropMechanicTooltipNamesEn })
setmetatable(dropMechanicTooltipNames["fr"], { __index = dropMechanicTooltipNamesEn })
setmetatable(dropMechanicTooltipNames["jp"], { __index = dropMechanicTooltipNamesEn })
setmetatable(dropMechanicTooltipNames["ru"], { __index = dropMechanicTooltipNamesEn })

setmetatable(localization["de"], { __index = localizationEn })
setmetatable(localization["es"], { __index = localizationEn })
setmetatable(localization["fr"], { __index = localizationEn })
setmetatable(localization["jp"], { __index = localizationEn })
setmetatable(localization["ru"], { __index = localizationEn })
local clientLocalization               = localization[clientLang]


--Mapping for tooltips
--Textures for the drop mechanic tooltips
local dropMechanicIdToTexture          = {
    [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "/esoui/art/chatwindow/chat_mail_up.dds",
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "/esoui/art/icons/mapkey/mapkey_avatown.dds",
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "/esoui/art/icons/mapkey/mapkey_avatown.dds",
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "/esoui/art/icons/mapkey/mapkey_avatown.dds",
    [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "/esoui/art/icons/undaunted_dungeoncoffer.dds",
    [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "/esoui/art/icons/quest_head_monster_014.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "/esoui/art/zonestories/completiontypeicon_delve.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "/esoui/art/icons/mapkey/mapkey_groupboss.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "/esoui/art/journal/journal_quest_dungeon.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "/esoui/art/icons/undaunted_smallcoffer.dds",
    [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_up.dds",
    [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "/esoui/art/icons/quest_letter_001.dds", --"/esoui/art/chatwindow/chat_mail_up.dds",
    [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "/esoui/art/icons/servicemappins/ic_monstrousteeth_complete.dds", --/esoui/art/icons/rewardbox_imperialcity.dds
    [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "/esoui/art/menubar/menubar_levelup_up.dds",
    [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                          = "/esoui/art/hud/gamepad/gp_loothistory_icon_antiquities.dds", --"/esoui/art/mappins/antiquity_trackeddigsite.dds",
    [LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR]                  = "/esoui/art/icons/quest_container_001.dds",
    [LIBSETS_DROP_MECHANIC_CRAFTED]                              = "/esoui/art/zonestories/completiontypeicon_setstation.dds",
    [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "/esoui/art/tutorial/loot_telvarbag.dds", --todo Undaunted dungeon coffer icon, and/or TelVar stones /esoui/art/icons/quest_container_001.dds
    [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
    [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "/esoui/art/icons/achievement_u26_skyrim_mainquest_3.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "/esoui/art/icons/achievement_u30_obliviongate.dds",
    [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "/esoui/art/icons/mapkey/mapkey_u26_harrowstorm_complete.dds",
    [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "/esoui/art/icons/housing_alt_fur_treasurechest001.dds",
    [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "/esoui/art/icons/achievements_indexicon_quests_up.dds",
    [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "/esoui/art/treeicons/achievements_indexicon_fishing_up.dds",
    [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "/esoui/art/icons/housing_cre_exc_minlootpile001.dds",
    [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_trialgroup.dds",
    [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "/esoui/art/icons/pet_slateskinneddaedrat.dds",
    [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "/esoui/art/journal/journal_quest_group_instance.dds",
    --["veteran dungeon"] =     "/esoui/art/lfg/lfg_veterandungeon_up.dds", --"/esoui/art/leveluprewards/levelup_veteran_dungeon.dds"
    --["undaunted"] =           "/esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_undaunted.dds",
    --["golden chest"] =        "/esoui/art/icons/undaunted_dungeoncoffer.dds",
}
lib.dropMechanicIdToTexture            = dropMechanicIdToTexture

--Textures for the set type tooltips
local setTypeToTexture                 = {
    [LIBSETS_SETTYPE_ARENA]                         = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_arenasolo.dds", --"Arena" (Group Arena /esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_arenagroup.dds)
    [LIBSETS_SETTYPE_BATTLEGROUND]                  = "/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_up.dds", --"Battleground"
    [LIBSETS_SETTYPE_CRAFTED]                       = "/esoui/art/zonestories/completiontypeicon_setstation.dds", --"Crafted"
    [LIBSETS_SETTYPE_CYRODIIL]                      = "/esoui/art/lfg/gamepad/lfg_activityicon_cyrodiil.dds", --"Cyrodiil"
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = "/esoui/art/lfg/gamepad/gp_lfg_menuicon_random.dds", --"DailyRandomDungeonAndICReward"
    [LIBSETS_SETTYPE_DUNGEON]                       = "/esoui/art/lfg/gamepad/lfg_activityicon_normaldungeon.dds", --"Dungeon"
    [LIBSETS_SETTYPE_IMPERIALCITY]                  = "/esoui/art/mappins/ava_imperialcity_neutral.dds", --"Imperial City"
    [LIBSETS_SETTYPE_MONSTER]                       = "/esoui/art/icons/quest_head_monster_014.dds", --"Monster"
    [LIBSETS_SETTYPE_OVERLAND]                      = "/esoui/art/icons/undaunted_smallcoffer.dds", --"Overland"
    [LIBSETS_SETTYPE_SPECIAL]                       = "/esoui/art/tutorial/campaignbrowser_indexicon_specialevents_up.dds", --"Special"
    [LIBSETS_SETTYPE_TRIAL]                         = "/esoui/art/treeicons/gamepad/gp_reconstruction_tabicon_trialgroup.dds", --"Trial"
    [LIBSETS_SETTYPE_MYTHIC]                        = "/esoui/art/icons/antiquities_u30_mythic_ring02.dds", --"Mythic"
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = "/esoui/art/icons/quest_head_monster_012.dds", --"Imperial City monster" --todo change to other monster icon!
    ["vet_dung"]                                    = "/esoui/art/lfg/gamepad/lfg_activityicon_veterandungeon.dds", --"Veteran Dungeon"
    ["undaunted chest"]                             = "/esoui/art/icons/housing_uni_con_undauntedchestsml001.dds",
}
lib.setTypeToTexture                   = setTypeToTexture

local setTypeToDropZoneLocalizationStr = {
    [LIBSETS_SETTYPE_ARENA]                         = clientLocalization.dropZoneArena,
    [LIBSETS_SETTYPE_BATTLEGROUND]                  = clientLocalization.dropZoneBattleground,
    [LIBSETS_SETTYPE_CRAFTED]                       = clientLocalization.dropZoneCrafted,
    [LIBSETS_SETTYPE_CYRODIIL]                      = clientLocalization.dropZoneCyrodiil,
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = clientLocalization.dropZoneMail,
    [LIBSETS_SETTYPE_DUNGEON]                       = clientLocalization.dropZoneDungeon,
    [LIBSETS_SETTYPE_IMPERIALCITY]                  = clientLocalization.dropZoneArena,
    [LIBSETS_SETTYPE_MONSTER]                       = clientLocalization.dropZoneMonster,
    [LIBSETS_SETTYPE_OVERLAND]                      = clientLocalization.dropZoneOverland,
    [LIBSETS_SETTYPE_SPECIAL]                       = clientLocalization.dropZoneSpecial,
    [LIBSETS_SETTYPE_TRIAL]                         = clientLocalization.dropZoneTrial,
    [LIBSETS_SETTYPE_MYTHIC]                        = clientLocalization.dropZoneMythic,
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = clientLocalization.dropZoneImperialCity,
    ["vet_dung"]                                    = clientLocalization.dropZoneDungeon,
}
lib.setTypeToDropZoneLocalizationStr   = setTypeToDropZoneLocalizationStr