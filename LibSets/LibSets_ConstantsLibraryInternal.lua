--Library base values: Name, Version
local MAJOR, MINOR = "LibSets", 0.70

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
local libPrefix                      = "["..MAJOR.."]"
lib.prefix = libPrefix
lib.version                          = MINOR
lib.svName                           = "LibSets_SV_Data"
lib.svDebugName                      = "LibSets_SV_DEBUG_Data"
lib.svVersion                        = 0.38 -- ATTENTION: changing this will reset the SavedVariables!
lib.setsLoaded                       = false
lib.setsScanning                     = false
------------------------------------------------------------------------------------------------------------------------
lib.fullyLoaded                      = false
lib.startedLoading                   = true

--The table with all relevant setIds
lib.setIds = {}
--SetIds which do not exist at the curren API version and thus get filtered automatically
lib.nonExistingSetIdsAtCurrentApiVersion = {}

------------------------------------------------------------------------------------------------------------------------
--Custom tooltip hooks to add the LibSets data, via function LibSets.RegisterCustomTooltipHook(tooltipCtrlName)
lib.customTooltipHooks = {
    needed = {},
    hooked = {},
    eventPlayerActivatedCalled = false,
}

--Custom context menu entries, added by other addons
lib.customContextMenuEntries = {
    ["setSearchUI"] = {},
}

---------------------------------------------------------------------------------
local APIVersions                    = {}
--The actual API version on the live server we are logged in
APIVersions["live"]                  = GetAPIVersion()
local APIVersionLive                 = tonumber(APIVersions["live"])
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--!!!!!!!!!!! Update this if a new scan of set data was done on the new APIversion at the PTS  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
--The last checked API version for the setsData in file "LibSets_Data.lua", see table "lib.setDataPreloaded = { ..."
-->Update here !!! AFTER !!! a new scan of the set itemIds was done -> See LibSets_Data.lua, description in this file
-->above the sub-table ["setItemIds"] (data from debug function LibSets.DebugScanAllSetData())
---->This variable is only used for visual output within the table lib.setDataPreloaded["lastSetsCheckAPIVersion"]
lib.lastSetsPreloadedCheckAPIVersion = 101042 -- Patch U43 (2024-07-13)
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
APIVersions["PTS"]                   = 101043 -- Patch U43 (2024-07-13)
local APIVersionPTS                  = tonumber(APIVersions["PTS"])



--TODO Uncomment to return the proper value if current PTS "once again" returns the old live value...
--> Change currentSimulatedPTSAPIversion to the proper current PTS APIversion in that case
----[[
local getAPIVersionOrig = GetAPIVersion
local currentSimulatedPTSAPIversion = 101043
function GetAPIVersion()
    if GetWorldName() ~= "PTS" then return getAPIVersionOrig() end
    return currentSimulatedPTSAPIversion
end
--]]


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
lib.debugNumItemIdPackages     = 55         -- Increase this to find new added set itemIds after an update. It will be
--multiplied by lib.debugNumItemIdPackageSize to build the itemIds of the
--items to scan inagme for sets -> build an itemLink->uses GetItemLinkSetInfo()
lib.debugNumItemIdPackageSize  = 5000       -- do not increase this or the client may crash!
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
local fallbackLang             = "en"
lib.fallbackLang               = fallbackLang
--During debugging these languages will be scanned for their setNames and an automatic langauge switch and reloadUI will
--be done -> If the value == true
local supportedLanguages       = {
    ["de"] = true,
    ["en"] = true,
    ["es"] = true,
    ["fr"] = true,
    ["ru"] = true,
    ["zh"] = true,
    ["jp"] = false, --TODO: Working on: Waiting for SetNames & other translations (by Calamath e.g.)
}
lib.supportedLanguages         = supportedLanguages

local numSupportedLangs        = 0
local supportedLanguagesIndex = {}
for supportedLanguage, isSupported in pairs(supportedLanguages) do
    if isSupported == true then
        numSupportedLangs = numSupportedLangs + 1
        supportedLanguagesIndex[#supportedLanguagesIndex + 1] = supportedLanguage
    end
end
lib.numSupportedLangs = numSupportedLangs
table.sort(supportedLanguagesIndex)
lib.supportedLanguagesIndex = supportedLanguagesIndex


--Sorted table of supported languages which does not change it's index!
-->Can be used as a LibAddonMenu choices table, see function LibSets.GetSupportedLanguageChoices()
local supportedLanguageChoices, supportedLanguageChoicesValues
supportedLanguageChoices = {
    [1] = "de",
    [2] = "en",
    [3] = "es",
    [4] = "fr",
    [5] = "ru",
    [6] = "zh",
    --[xx] = "jp", --not supported yet JP
}
supportedLanguageChoicesValues = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    --[xx] = xx, --not supported yet JP
}
lib.supportedLanguageChoices = supportedLanguageChoices
lib.supportedLanguageChoicesValues = supportedLanguageChoicesValues


--The actual clients language
local clientLang      = GetCVar("language.2")
clientLang            = strlower(clientLang)
if not supportedLanguages[clientLang] then
    clientLang = fallbackLang --Fallback language if client language is not supported: English
end
lib.clientLang        = clientLang


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
LIBSETS_TABLEKEY_ZONEIDS_SORTED                        = "zoneIdsSorted"
LIBSETS_TABLEKEY_ZONE_DATA                             = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA                    = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES                     = "collectible" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES                 = "collectible_DLC" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID                = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_DROPMECHANIC                          = "dropMechanic"
LIBSETS_TABLEKEY_DROPMECHANIC_SORTED                   = "dropMechanicSorted"
LIBSETS_TABLEKEY_DROPMECHANIC_NAMES                    = LIBSETS_TABLEKEY_DROPMECHANIC .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES            = LIBSETS_TABLEKEY_DROPMECHANIC .. "Tooltip" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES           = LIBSETS_TABLEKEY_DROPMECHANIC .. "DropLocation" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MIXED_SETNAMES                        = "MixedSetNamesForDataAll"
--LIBSETS_TABLEKEY_SET_PROCS                             = "setProcs" --2022-04-20 Disabled
LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP              = "setProcsAllowedInPvP"
LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING     = "setItemCollectionsZoneMapping"
LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES          = "enchantSearchCategories"
LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING                  = "dungeonZoneMapping"
LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING            = "publicDungeonZoneMapping"



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
    [14] = "LIBSETS_SETTYPE_CYRODIIL_MONSTER", --"Cyrodiil Monster"
    [15] = "LIBSETS_SETTYPE_CLASS",  --Class specific
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
    [LIBSETS_SETTYPE_CYRODIIL_MONSTER]              = {
        ["tableName"] = "monsterSets",
    },
    [LIBSETS_SETTYPE_CLASS]                         = {
        ["tableName"] = "classSets",
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
--Special zone IDS
LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL = 0
LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD = -99
LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS = -98
--Special zone names
local specialZoneNames = {
    ["de"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "Alle Zonen (in Tamriel)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "Levelaufstieg",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "Schlachtfelder",
    },
    ["en"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "All Zones (in Tamriel)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "Level-Up",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "Battlegrounds",
    },
    ["es"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "Todas las zonas (en Tamriel)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "Elevar a mismo nivel",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "Campos de batalla",
    },
    ["fr"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "Toutes les zones (en Tamriel)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "Montée de niveau",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "Champs de bataille",
    },
    ["ru"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "Все зоны (в Тамриэле)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "Уровень повышен",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "Поля боя",
    },
    ["jp"] = {
        [LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "すべてのゾーン (タムリエル)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "レベルアップ",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "戦場",
    },
    ["zh"] = { --by Lykeion, 2024029
		[LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL] = "所有地区 (于塔姆瑞尔)",
        [LIBSETS_SPECIAL_ZONEID_LEVELUPREWARD] = "升级",
        [LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS] = "战场",
    },
}
lib.specialZoneNames = specialZoneNames

local specialZoneNamesEn        = specialZoneNames[fallbackLang]  --fallback value English

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
        ["zh"] = "竞技场",
    },
    [LIBSETS_SETTYPE_BATTLEGROUND]                  = {
        ["de"] = "Schlachtfeld", --SI_LEADERBOARDTYPE4,
        ["en"] = "Battleground",
        ["es"] = "Campo de batalla",
        ["fr"] = "Champ de bataille",
        ["jp"] = "バトルグラウンド",
        ["ru"] = "Поле боя",
        ["zh"] = "战场",
    },
    [LIBSETS_SETTYPE_CRAFTED]                       = {
        ["de"] = "Handwerklich hergestellt", --SI_ITEM_FORMAT_STR_CRAFTED
        ["en"] = "Crafted",
        ["es"] = "Hecho a mano",
        ["fr"] = "Artisanal",
        ["jp"] = "クラフトセット",
        ["ru"] = "Созданный",
        ["zh"] = "制造",
    },
    [LIBSETS_SETTYPE_CYRODIIL]                      = {
        ["de"] = "Cyrodiil", --SI_CAMPAIGNRULESETTYPE1,
        ["en"] = "Cyrodiil",
        ["es"] = "Cyrodiil",
        ["fr"] = "Cyrodiil",
        ["jp"] = "シロディール",
        ["ru"] = "Сиродил",
        ["zh"] = "西罗帝尔",
    },
    [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = {
        ["de"] = "Zufälliges Verlies & Kaiserstadt Belohnung", --SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT & SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4 SI_LEVEL_UP_REWARDS_GAMEPAD_REWARD_SECTION_HEADER_SINGULAR
        ["en"] = "Random Dungeons & Imperial city " .. zocstrfor("<<c:1>>", "Reward"),
        ["es"] = "Mazmorras aleatorias y ciudad imperial " .. zocstrfor("<<c:1>>", "Recompensa"),
        ["fr"] = "Donjons aléatoires & Cité impériale " .. zocstrfor("<<c:1>>", "Récompense"),
        ["jp"] = "デイリー報酬",
        ["ru"] = "Случайное ежедневное подземелье и награда Имперского города",
        ["zh"] = "随机地下城 & 帝都 " .. zocstrfor("<<c:1>>", "奖励"),
    },
    [LIBSETS_SETTYPE_DUNGEON]                       = {
        ["de"] = "Verlies", --SI_ZONEDISPLAYTYPE2 SI_INSTANCEDISPLAYTYPE2
        ["en"] = "Dungeon",
        ["es"] = "Calabozo",
        ["fr"] = "Donjon",
        ["jp"] = "ダンジョン",
        ["ru"] = "Подземелье",
        ["zh"] = "地下城",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY]                  = {
        ["de"] = "Kaiserstadt", --SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES4
        ["en"] = "Imperial city",
        ["es"] = "Ciudad imperial",
        ["fr"] = "Cité impériale",
        ["jp"] = "帝都",
        ["ru"] = "Имперский город",
        ["zh"] = "帝都",
    },
    [LIBSETS_SETTYPE_MONSTER]                       = {
        ["de"] = "Monster",
        ["en"] = "Monster",
        ["es"] = "Monstruo",
        ["fr"] = "Monstre",
        ["jp"] = "モンスター",
        ["ru"] = "Монстр",
        ["zh"] = "怪物",
    },
    [LIBSETS_SETTYPE_OVERLAND]                      = {
        ["de"] = "Überland",
        ["en"] = "Overland",
        ["es"] = "Zone terrestre",
        ["fr"] = "Zone",
        ["jp"] = "陸上",
        ["ru"] = "Поверхности",
        ["zh"] = "陆上",
    },
    [LIBSETS_SETTYPE_SPECIAL]                       = {
        ["de"] = "Besonders", --SI_HOTBARCATEGORY9
        ["en"] = "Special",
        ["es"] = "Especial",
        ["fr"] = "Spécial",
        ["jp"] = "スペシャル",
        ["ru"] = "Специальный",
        ["zh"] = "特殊",
    },
    [LIBSETS_SETTYPE_TRIAL]                         = {
        ["de"] = "Prüfungen", --SI_LFGACTIVITY4
        ["en"] = "Trial",
        ["es"] = "Ensayo",
        ["fr"] = "Épreuves",
        ["jp"] = "試練",
        ["ru"] = "Испытание",
        ["zh"] = "试炼",
    },
    [LIBSETS_SETTYPE_MYTHIC]                        = {
        ["de"] = "Mythisch",
        ["en"] = "Mythic",
        ["es"] = "Mítico",
        ["fr"] = "Mythique",
        ["jp"] = "神話上の",
        ["ru"] = "мифический",
        ["zh"] = "神话",
    },
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = {
        ["de"] = "Kaiserstadt Monster",
        ["en"] = "Imperial city monster",
        ["es"] = "Ciudad imperial monstruo",
        ["fr"] = "Monstre de la Cité impériale",
        ["jp"] = "帝都 モンスター",
        ["ru"] = "Имперский город Монстр",
        ["zh"] = "帝都怪物",
    },
    [LIBSETS_SETTYPE_CYRODIIL_MONSTER]          = {
        ["de"] = "Cyrodiil Monster",
        ["en"] = "Cyrodiil monster",
        ["es"] = "Cyrodiil monstruo",
        ["fr"] = "Monstre de Cyrodiil",
        ["jp"] = "シロディール モンスター",
        ["ru"] = "Сиродил Монстр",
        ["zh"] = "西罗帝尔怪物",
    },
    [LIBSETS_SETTYPE_CLASS] = {
        ["de"] = "Klassen spezifisch",
        ["en"] = "Class specific",
        ["es"] = "Específico de la clase",
        ["fr"] = "Spécifique à la classe",
        ["jp"] = "クラス固有の",
        ["ru"] = "Зависит от класса",
        ["zh"] = "职业限定",
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
        ["zh"] = "",
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
--Armor
lib.isArmorEquipType               = {
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
--The trait type check tables
--Jewelry
lib.isJewelryTraitType              = {
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
}
--Weapons
lib.isWeaponTraitType               = {
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
--Armor
lib.isArmorTraitType               = {
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
}


--The enchanting EnchantmentSearchCategoryType that are valid
lib.enchantSearchCategoryTypesValid = {
    --Not allowed
    --Allowed
    ["all"]                                                     = true,
    --[ENCHANTMENT_SEARCH_CATEGORY_INVALID]                       = true,
    [ENCHANTMENT_SEARCH_CATEGORY_NONE]                          = true,
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
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA]                       = true,
    [ENCHANTMENT_SEARCH_CATEGORY_MAGICKA_REGEN]                 = true,
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
--Nn-/Perfected sets data
lib.nonPerfectedSet2PerfectedSet = {}
lib.perfectedSet2NonPerfectedSet = {}
lib.perfectedSetsInfo = {}
lib.perfectedSets = {}
lib.nonPerfectedSets = {}


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
        [1] = "Glirion el Barbarroja",
        [2] = "Maj al-Ragath",
        [3] = "Urgarlag la Castradora",
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
    ["zh"] = {
        [1] = "紅胡子格利里恩",
        [2] = "瑪吉·阿示拉加斯",
        [3] = "烏示加拉格·酋長克星",
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
    [2]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA", --Cyrodiil City Bruma (quartermaster)
    [3]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD", --Cyrodiil City Cropsford (quartermaster)
    [4]  = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS", --Cyrodiil City Vlastarus (quartermaster)
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
    [30] = "LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST", --Chest in a public dungeon
    [31] = "LIBSETS_DROP_MECHANIC_HARVEST_NODES", --Harvest crafting nodes
    [32] = "LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP", --Imperial city treasure scamps	Kaiserstadt Schatzgoblin
    [33] = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL", -- Cyrodiil Cheydinhal city
    [34] = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY", -- Cyrodiil Weyon Priory, Chorrol
    [35] = "LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY",  -- Cyrodiil Cheydinhal city / Weyon Priory, Chorrol
    [36] = "LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS", -- Cyrodiil board missions
    [37] = "LIBSETS_DROP_MECHANIC_ENDLESS_ARCHIVE", -- Endless/Infinite Archive dungeon
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

--For API usage
lib.dropZones = {}
lib.dropZone2SetIds = {}
lib.setId2DropZones = {}
lib.dropLocationNames = {}
lib.dropLocationNames2SetIds = {}
lib.setId2DropLocationNames = {}


------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--!!! Attention: Change this table if you add/remove LibSets drop mechanics !!!
-------------------------------------------------------------------------------
---The names of the drop mechanics
local cyrodiilAndBattlegroundText = GetString(SI_CAMPAIGNRULESETTYPE1) .. "/" .. GetString(SI_LEADERBOARDTYPE4)
lib.dropMechanicIdToName          = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Gerechter Lohn (" .. cyrodiilAndBattlegroundText .. " eMail)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil Stadt: Bruma (Quartiermeister/Tägliche Quest)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil Stadt: Erntefurt (Quartiermeister/Tägliche Quest)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil Stadt: Vlastarus (Quartiermeister/Tägliche Quest)",
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
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "Truhen in Öffentlichen Verlieses",
        [LIBSETS_DROP_MECHANIC_HARVEST_NODES]                        = "Handwerks-Knoten abernten",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Kaiserstadt Gier Schatzgoblin",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Stadt Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Weynon Priorei, bei Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Cyrodiil: Stadt Cheydinhal / Weynon Priorei, bei Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Cyrodiil Auftragstafeln",
    },
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Rewards for the worthy",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil City: Bruma (quartermaster/daily quest)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil City: Cropsford (quartermaster/daily quest)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil City: Vlastarus (quartermaster/daily quest)",
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
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "Chests in public dungeons",
        [LIBSETS_DROP_MECHANIC_HARVEST_NODES]                        = "Harvest crafting nodes",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Imperial city treasure Trove scamp",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Cyrodiil City: Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Cyrodiil: Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Cyrodiil City: Cheydinhal / Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Cyrodiil Board missions",
        --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                          = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE11),
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR]                  = GetString(SI_LEADERBOARDTYPE4) .. " " .. GetString(SI_MAPDISPLAYFILTER2), --Battleground vendors
        [LIBSETS_DROP_MECHANIC_CRAFTED]                              = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        [LIBSETS_DROP_MECHANIC_ENDLESS_ARCHIVE]                      = GetString(SI_ZONEDISPLAYTYPE12),
    },
    ["es"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Recompensa por el mérito",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Ciudad Cyrodiil: Bruma (intendente/búsqueda diaria)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Ciudad Cyrodiil: Cropsford (intendente/búsqueda diaria)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Ciudad Cyrodiil: Vlastarus (intendente/búsqueda diaria)",
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
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "Cofres en mazmorra públicas",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Imperial city treasure Trove scamp",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Cyrodiil City: Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Cyrodiil: Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Cyrodiil City: Cheydinhal / Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Cyrodiil Board missions",
    },
    ["fr"] = {
	    [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Récompenses des dignes",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cité de Cyrodiil : Bruma (intendant/quête quotidienne)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cité de Cyrodiil : Cropsford (intendant/quête quotidienne)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cité de Cyrodiil : Vlastarus (intendant/quête quotidienne)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "Coffre de scène d'arène",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "Nom du monstre",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "Boss de delves",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "Boss de groupe en zone",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "Boss de donjons publics",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "Coffres de zone/souterrains",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "Récompenses des champs de bataille",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "Récompense quotidienne de donjon aléatoire par courrier",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "Chambres fortes de la Cité impériale",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "Récompense de montée de niveau",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Marchand de coffres verrouillés d'équipement Tel Var, base des égouts de la Cité impériale",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Marchand de coffres verrouillés d'équipement élite contre des points d'alliance, Cyrodiil/Vvardenfell",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "Un PNJ nommé récompense avec cet objet",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Coffre du boss final des portails d'Oblivion",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Récompense des dolmens, tempêtes ravageuses, anomalies magiques",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Coffres dans un donjon",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Coffre de récompense de quête quotidienne",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Point de pêche",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Butin des objets de zone",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Boss de Raid",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Type de monstre",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Boss dans les donjons de groupe",
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "Coffres dans les donjons publics",
        [LIBSETS_DROP_MECHANIC_HARVEST_NODES]                        = "Récolte des ressources d'artisanat",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Galopin  de la Cité impériale",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Ville de Cyrodiil : Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Cyrodiil : Prieuré de Weynon, Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Ville de Cyrodiil : Cheydinhal / Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Missions du tableau de Cyrodiil",
        --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                          = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE11),
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_VENDOR]                  = GetString(SI_LEADERBOARDTYPE4) .. " " .. GetString(SI_MAPDISPLAYFILTER2), -- Battleground vendors
        [LIBSETS_DROP_MECHANIC_CRAFTED]                              = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
        [LIBSETS_DROP_MECHANIC_ENDLESS_ARCHIVE]                      = GetString(SI_ZONEDISPLAYTYPE12),
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "Награда достойным",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Сиродил: город Брума (квартирмейстер/ежедневный квест)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Сиродил: город Кропсфорд (квартирмейстер/ежедневный квест)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Сиродил: город Властарус (квартирмейстер/ежедневный квест)",
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
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "Тель-Вар, торговец сейфами с оборудованием, канализационная база IC",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "Очки Альянса Торговец элитным снаряжением, Сиродил/Вварденфелл",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "Именованный NPC награждает этим предметом",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "Сундук финального босса портала Обливион",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "Дольмены, Мрачные бури, Награда за магические аномалии",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "Сундуки в подземелье",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "Сундук с наградами за ежедневные квесты",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "Рыболовная яма",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "Добыча из сухопутных предметов",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "Боссы в пробных подземельях",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "Тип моба/животного",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "Боссы в групповых подземельях",
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "Сундуки открытых подземелий",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Imperial city treasure Trove scamp",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Cyrodiil City: Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Cyrodiil: Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Cyrodiil City: Cheydinhal / Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Cyrodiil Board missions",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "貢献に見合った報酬です",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "Cyrodiil シティ: ブルーマ (補給係/デイリークエスト)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "Cyrodiil シティ: クロップスフォード (補給係/デイリークエスト)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "Cyrodiil シティ: ヴラスタルス (補給係/デイリークエスト)",
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
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "テルバー装備保管庫商人、IC下水道基地",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "アライアンス ポイント エリート ギア ロックボックス マーチャント、シロディール/ヴァーデンフェル",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "指名されたNPCはこのアイテムで報酬を得る",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "オブリビオンポータルの最終ボスのチェスト",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "ドルメン、Harrowstorms、魔法の異常の報酬",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "ダンジョンの宝箱",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "デイリークエストの報酬箱",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "釣り穴",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "陸上アイテムから略奪する",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "試練のダンジョンのボス",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "モブ/クリッターの種類",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "グループダンジョンのボス",
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "パブリックダンジ 宝箱",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "Imperial city treasure Trove scamp",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "Cyrodiil City: Cheydinhal",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "Cyrodiil: Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "Cyrodiil City: Cheydinhal / Weynon Priory, Chorrol",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "Cyrodiil Board missions",
    },
    ["zh"] = { --by Lykeion, 2024029
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]      = "给有价值的人的奖励",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA]                  = "西罗帝尔城镇: 布鲁玛 (军需官/日常任务)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD]              = "西罗帝尔城镇: 克罗普斯福特 (军需官/日常任务)",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS]              = "西罗帝尔城镇: 瓦拉斯塔努斯 (军需官/日常任务)",
        [LIBSETS_DROP_MECHANIC_ARENA_STAGE_CHEST]                    = "竞技场关卡宝箱",
        [LIBSETS_DROP_MECHANIC_MONSTER_NAME]                         = "怪物名",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]                  = "洞穴Boss",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                   = "世界Boss",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]         = "公共地下城Boss",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                       = "世界/洞穴宝箱",
        [LIBSETS_DROP_MECHANIC_BATTLEGROUND_REWARD]                  = "战场奖励",
        [LIBSETS_DROP_MECHANIC_MAIL_DAILY_RANDOM_DUNGEON_REWARD]     = "每日随机地下城奖励邮件",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_VAULTS]                 = "帝都宝库",
        [LIBSETS_DROP_MECHANIC_LEVEL_UP_REWARD]                      = "升级奖励",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT]    = "生命石装备箱商人, 位于帝都下水道基地",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]       = "联盟点数装备箱商人, 位于西罗帝尔/瓦登费尔",
        [LIBSETS_DROP_MECHANIC_REWARD_BY_NPC]                        = "来自一位具名的NPC的奖励",
        [LIBSETS_DROP_MECHANIC_OVERLAND_OBLIVION_PORTAL_FINAL_CHEST] = "湮灭传送门最终Boss奖励",
        [LIBSETS_DROP_MECHANIC_DOLMEN_HARROWSTORM_MAGICAL_ANOMALIES] = "暗锚, 苦痛风暴, 魔力异常点奖励",
        [LIBSETS_DROP_MECHANIC_DUNGEON_CHEST]                        = "地下城宝箱",
        [LIBSETS_DROP_MECHANIC_DAILY_QUEST_REWARD_COFFER]            = "日常任务奖励箱",
        [LIBSETS_DROP_MECHANIC_FISHING_HOLE]                         = "渔获",
        [LIBSETS_DROP_MECHANIC_OVERLAND_LOOT]                        = "从陆上节点捡拾获得",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                           = "试炼Boss",
        [LIBSETS_DROP_MECHANIC_MOB_TYPE]                             = "普通怪物",
        [LIBSETS_DROP_MECHANIC_GROUP_DUNGEON_BOSS]                   = "组队地下城Boss",
        [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "公共地下城宝箱",
        [LIBSETS_DROP_MECHANIC_HARVEST_NODES]                        = "采集制造节点",
        [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]   = "帝都宝藏魔",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]             = "西罗帝尔城镇: 香丁赫尔",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY]  = "西罗帝尔城镇: 文扬修道院, 科洛尔",
        [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "西罗帝尔城镇: 香丁赫尔 / 文扬修道院, 科洛尔",
        [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]              = "西罗帝尔公告板任务",
    },
}

lib.dropMechanicIdToNameTooltip   = {
    ["de"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = cyrodiilAndBattlegroundText .. " mail - Enthält nur die neuesten Gegenstandssets!\nDa weiterhin neue Sets hinzugefügt werden, werden ältere Sets hier entfernt und anderen Cyrodiil-Quellen hinzugefügt:\nAlle PvP-Gegenstandssets werden jetzt in Cyrodiil-Dungeons, Dolmen und Missionen gefunden.\nTägliche Quests und Händler in der Stadt werden nach Leicht, Mittel und Schwer aufgeteilt. Ausnahme: Cheydinhal und Chorrol/Weynon Priory droppen jedes Set.\nAlle PvP-Sets sind als Einzelcontainer sowohl bei Stadthändlern als auch bei Elite-Ausrüstungshändlern erhältlich.\nDungeons lassen Taillen- und Fuß-Gegenstandssets fallen.\nDolmen lassen Schmuck fallen.\nBoard-Missionen lassen alle anderen Rüstungsteile fallen.\nBei Kopfgeld- und Scout-Missionen erhältst du Rüstungsteile.\nKampf- und Kriegsfront-Missionen geben Waffenslot-Items.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Bosse in Gewölben haben die Chance, eine Taille oder Füße fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Überland Gruppenbosse haben eine Chance von 100%, Kopf, Brust, Beine oder Waffen fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Öffentliche Dungeon-Bosse haben die Möglichkeit, eine Schulter, Handschuhe oder eine Waffe fallen zu lassen.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Truhen, die durch das Besiegen eines Dunklen Ankers gewonnen wurden, haben eine Chance von 100%, einen Ring oder ein Amulett fallen zu lassen.\nSchatztruhen, welche man in der Zone findet, haben eine Chance irgendein Setteil zu gewähren, das in dieser Zone droppen kann:\n-Einfache Truhen haben eine geringe Chance\n-Mittlere Truhen haben eine gute Chance\n-Fortgeschrittene- und Meisterhafte-Truhen haben eine garantierte Chance\n-Schatztruhen, die durch eine Schatzkarte gefunden wurden, haben eine garantierte Chance",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Truhe, welche man bei einem TelVar Ausrüstungs Händler in der eigenne Fraktionsbasis in der Kaiserstadt Kanalisation für TelVar Steine eintauschen kann.",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]    = "Truhe, welche man bei einem Elite Gear Händler in Cyrodiil (Östliches Elsweyr Tor, Südliches Hochfels Tor, Nördliches Morrowind Tor), oder in Vvardenfall für Schlachtfelder (Ald Carac, Foyada Quarry, Ularra), für Allianzpunkte kaufen kann.",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "Alle Bosse: Hände, Taille, Füße, Brust, Schultern, Kopf, Beine\nLetzte Bosse: Waffen, Schild\nQuest Belohnung: Schmuck, Waffe, Schild (Gebunden beim Aufheben)",
    },
    ["en"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Rewards for the worthy (" .. cyrodiilAndBattlegroundText .. " mail) - Contains only newest item sets!\nAs new sets continue to get added, older sets will be removed here and added into other Cyrodiil sources:\nAll PvP item sets will now drop from Cyrodiil delves, dolmens and board missions.\nTown Daily Quest and Merchants will be divided by Light, Medium and Heavy. Exception: Cheydinhal and Chorrol/Weynon Priory reward any set.\nAll PvP sets are available as individual containers on both Town Merchants and Elite Gear Vendors.\nDelves will drop waist and feet item sets\nDolmens will drop jewelry\nBoard Missions will drop all other armor pieces.\nBounty and Scout missions will award armor pieces.\nBattle and Warfront missions will reward weapon slot pieces.",
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
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Recompensa por el mérito (" .. cyrodiilAndBattlegroundText .. " mail) - ¡Contiene solo conjuntos de artículos más nuevos!\nA medida que se sigan agregando nuevos conjuntos, los conjuntos más antiguos se eliminarán aquí y se agregarán a otras fuentes de Cyrodiil:\nTodos los conjuntos de elementos PvP ahora aparecerán en las excavaciones, dólmenes y misiones de tablero de Cyrodiil.\nLas misiones diarias de la ciudad y los comerciantes se dividirán por Luz , Medio y Pesado. Excepción: Cheydinhal y Chorrol/Weynon Priory recompensan cualquier conjunto.\nTodos los conjuntos PvP están disponibles como contenedores individuales tanto en los comerciantes de la ciudad como en los vendedores de equipo de élite.\nLos excavadores arrojarán conjuntos de artículos para cintura y pies\nLos dólmenes arrojarán joyas\nLas misiones del tablero arrojarán todos otras piezas de armadura.\nLas misiones de recompensa y exploración otorgarán piezas de armadura.\nLas misiones de batalla y frente de guerra recompensarán piezas de ranuras para armas.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Los jefes de cuevas pueden soltar cinturones o calzado.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Los jefes del mundo sueltan siempre piezas de cabeza, pecho, piernas, o armas.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Los jefes de mazmorras públicas pueden soltar hombreras, guantes, o armas.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Los cofres de áncoras oscuras sueltan siempre anillos o amuletos.\nLos cofres encontrados por el mundo pueden soltar cualquier pieza de armadura de un conjunto propio de la zona:\n-Los cofres sencillos tienen una ligera probabilidad\n-Los cofres intermedios tienen una buena probabilidad\n-Los cofres avanzados o de maestro tienen 100% de probabilidad\n-Los cofres encontrados con un mapa del tesoro tienen 100% de probabilidad",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Cofre que se puede canjear por Piedras TelVar en un vendedor de equipos TelVar en la base de tu facción, en las alcantarillas de la Ciudad Imperial.",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "Todos los jefes: manos, cintura, pies, pecho, hombros, cabeza, piernas\nJefes finales: arma, escudo\nContenedores de recompensa de misión: joyas, arma, escudo (se vincula al recogerlo))",
    },
    ["fr"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Récompenses des dignes (" .. cyrodiilAndBattlegroundText .. " par courrier) - Ne contient que les ensembles d'objets les plus récents !\nÀ mesure que de nouveaux ensembles sont ajoutés, les anciens seront retirés d'ici et ajoutés à d'autres sources en Cyrodiil :\nTous les ensembles d'objets JcJ seront désormais obtenus à partir des antres, dolmens et missions du tableau de Cyrodiil.\nLes quêtes quotidiennes de la ville et les marchands seront divisés par Léger, Moyen et Lourd. Exception : Cheydinhal et Chorrol/Weynon Priory récompensent n'importe quel ensemble.\nTous les ensembles JcJ sont disponibles en tant que conteneurs individuels chez les marchands de la ville et les vendeurs d'équipement d'élite.\nLes antres feront tomber les ensembles de taille et de pieds.\nLes dolmens feront tomber des bijoux.\nLes missions du tableau feront tomber toutes les autres pièces d'armure.\nLes missions de prime et d'éclaireur récompenseront des pièces d'armure.\nLes missions de bataille et de front de guerre récompenseront des pièces d'arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Les boss des antres ont une chance de faire tomber une taille ou des pieds.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Les boss de groupe en zone ont 100% de chances de faire tomber une tête, une poitrine, des jambes ou une arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Les boss des donjons publics ont une chance de faire tomber une épaule, une main ou une arme.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Les coffres obtenus en vainquant une ancre noire ont 100% de chances de faire tomber une bague ou un amulette.\nLes coffres au trésor trouvés dans le monde ont une chance de donner n'importe quelle pièce d'ensemble qui peut tomber dans cette zone :\n-Les coffres simples ont une légère chance\n-Les coffres intermédiaires ont une bonne chance\n-Les coffres avancés et maîtres ont une chance garantie\n-Les coffres au trésor trouvés grâce à une carte au trésor ont une chance garantie",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                       = GetString(SI_ANTIQUITY_TOOLTIP_TAG), --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Coffre échangeable contre des Pierres de TelVar chez un marchand d'équipement TelVar dans la base de votre faction, dans les égouts de la Cité impériale.",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]    = "Coffre échangeable contre des Points d'Alliance chez un marchand de coffres d'équipement élite à Cyrodiil (Porte orientale d'Elsweyr, Porte méridionale de Haute-Roche, Porte septentrionale de Morrowind) ou chez un marchand de champs de bataille à Vvardenfell (Ald Carac, Foyada Quarry, Ularra)",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "Tous les boss : Mains, Taille, Pieds, Poitrine, Épaule, Tête, Jambes\nBoss final : Arme, Bouclier\nConteneurs de récompenses de quête : Bijoux, Arme, Bouclier (Liés quand ramassés)",
    },
    ["ru"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "Награда достойным (" .. cyrodiilAndBattlegroundText .. " почта) - Содержит только новейшие наборы предметов!\nПо мере добавления новых наборов старые наборы будут удалены отсюда и добавлены в другие источники Сиродила:\nВсе наборы PvP-предметов теперь будут выпадать из подземелий, дольменов и миссий на доске Сиродила.\nГородские ежедневные задания и торговцы будут разделены по Свету. , средний и тяжелый. Исключение: Чейдинхол и Приорат Коррола/Вейнона дают награду за любой набор.\nВсе PvP-наборы доступны в виде отдельных контейнеров как у городских торговцев, так и у продавцов элитного снаряжения.\nВ Дельвах из комплектов предметов для талии и ног выпадут все.\nИз дольменов выпадут драгоценности.\nИз настольных миссий выпадут все. другие части доспехов.\nЗа миссии Bounty и Scout будут выдаваться части доспехов.\nЗа миссии Battle and Warfront будут выдаваться части слотов для оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "Боссы вылазок дают шанс выпадания талии или голени.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "Групповые боссы дают 100% шанс выпадания головы, груди, ног или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "Боссы открытых подземелий дают шанс выпадания плечей, рук или оружия.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "Сундуки, полученные после побед над Тёмными якорями, имеют 100% шанс выпадания кольца или амулета.\nСундуки сокровищ, найденные в мире, дают шанс получить любую часть комплекта, выпадающую в этой зоне:\n- простые сундуки дают незначительный шанс\n- средние сундуки дают хороший шанс\n- продвинутые и мастерские сундуки дают гарантированный шанс\n- сундуки сокровищ, найденные по Карте сокровищ, дают гарантированный шанс",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "Сундук, который можно обменять на камни ТелВар у продавца оборудования ТелВар на базе вашей фракции в канализации Имперского города",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "Все боссы: Руки, Поясница, Ноги, Грудь, Плечо, Голова, Ноги\Финальные боссы: Оружие, Щит\nКонтейнеры с наградами за квест: Ювелирные изделия, Оружие, Щит (привязывается при получении))",
    },
    ["jp"] = {
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "貢献に見合った報酬です (" .. cyrodiilAndBattlegroundText .. " メール) - 最新アイテムセットのみを収録！\n新しいセットが追加され続けるため、古いセットはここで削除され、シロディールの他のソースに追加されます:\nすべての PvP アイテム セットはシロディールの洞窟、ドルメン、ボード ミッションからドロップされます。\nタウンのデイリー クエストと商人は光によって分割されます。 、ミディアムとヘビー。 例外: シェイディンハルとチョロル/ウェイノン修道院はどのセットでも報酬を獲得します。\nすべての PvP セットは、町の商人およびエリート装備ベンダーの両方で個別のコンテナとして入手できます。\nデルブは腰と足のアイテム セットをドロップします\nドルメンはジュエリーをドロップします\nボード ミッションはすべてをドロップします 他のアーマー ピース。\n賞金稼ぎミッションとスカウト ミッションではアーマー ピースが獲得できます。\nバトル ミッションとウォーフロント ミッションでは武器スロット ピースが獲得できます。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "洞窟ボスは、胴体や足装備をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "ワールドボスは、頭、腰、脚の各防具、または武器のいずれかが必ずドロップします。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "パブリックダンジョンのボスは、肩、手の各防具、または武器をドロップすることがあります。",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "ダークアンカー撃破報酬の宝箱からは、指輪かアミュレットが必ずドロップします。\n地上エリアで見つけた宝箱からは、そのゾーンでドロップするセット装備を入手できます。:\n-簡単な宝箱からは低確率で入手できます。\n-中級の宝箱からは高確率で入手できます。\n-上級やマスターの宝箱からは100%入手できます。\n-「宝の地図」で見つけた宝箱からは100%入手できます。",
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "「インペリアルシティ下水道の派閥基地にあるTelVar機器ベンダーでTelVarストーンと交換できるチェスト。」",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "すべてのボス: 手、腰、足、胸、肩、頭、脚\n最終ボス: 武器、盾\nクエスト報酬コンテナ: ジュエリー、武器、盾 (ピックアップ時にバインド))",
    },
    ["zh"] = { --by Lykeion, 2024029
        [LIBSETS_DROP_MECHANIC_MAIL_PVP_REWARDS_FOR_THE_WORTHY]   = "给有价值的人的奖励 (" .. cyrodiilAndBattlegroundText .. " 邮件) - 只包含最新的套装!\n随着新套装的不断加入, 就套装将被从此获取途径中移除并被加入到西罗帝尔的其他获取途径中:\n所有Pvp套装现将从西罗帝尔洞穴, 暗锚和任务中掉落.\n城镇日常任务和商人将会以轻, 中, 重区分. 特例: 香丁赫尔和克洛文/文扬修道院将会奖励任意套装.\n所有PvP套装都可以宝箱形式从城镇商人或精选装备商人处获取.\n洞穴会掉落腰部和足部装备\n暗锚会掉落珠宝\n公告板任务会掉落其他身体部位装备.\n赏金和侦查任务奖励服装.\n战斗和前线作战任务奖励武器.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_DELVE]               = "洞穴Boss有几率掉落腰部或足部装备.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_WORLDBOSS]                = "陆上组队Boss必定掉落头, 胸, 腿或武器.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_BOSS_PUBLIC_DUNGEON]      = "公共地下城Boss有几率掉落肩, 手或武器.",
        [LIBSETS_DROP_MECHANIC_OVERLAND_CHEST]                    = "粉碎暗锚所获的宝箱必定掉落首饰.\n陆上宝箱有几率掉落当前区域套装的任何部位部件:\n-简单箱子有微小概率\n-中等箱子有良好概率\n-进阶和大师箱子必定掉落\n-藏宝图挖出的宝箱必定掉落",
        [LIBSETS_DROP_MECHANIC_ANTIQUITIES]                       = GetString(SI_ANTIQUITY_TOOLTIP_TAG), --Will be used in other languages via setmetatable below!
        [LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT] = "可在帝都下水道用生命石从基地的生命石商人处兑换的宝箱.",
        [LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT]    = "可在西罗帝尔用联盟点数从精选装备商人, 或瓦登费尔的战场商人处兑换的宝箱",
        [LIBSETS_DROP_MECHANIC_TRIAL_BOSS]                        = "所有Boss: 手, 腰, 足, 胸, 肩, 头, 腿\n尾王: 武器, 盾牌\n任务奖励箱: 首饰, 武器, 盾 (拾取时绑定))",
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
local booleanToOnOff = {
    [false] = GetString(SI_CHECK_BUTTON_OFF):upper(),
    [true]  = GetString(SI_CHECK_BUTTON_ON):upper(),
}


local undauntedStr               = GetString(SI_VISUALARMORTYPE4)
local dungeonStr                 = GetString(SI_ZONEDISPLAYTYPE2) -- SI_INSTANCEDISPLAYTYPE2
local setTypeArenaName           = setTypesToName[LIBSETS_SETTYPE_ARENA]
lib.localization                 = {
    ["de"] = {
        de                       = "Deutsch",
        en                       = "Englisch",
        fr                       = "Französisch",
        jp                       = "Japanisch",
        ru                       = "Russisch",
        pl                       = "Polnisch",
        es                       = "Spanisch",
        zh                       = "Chinesisch",
        dlc                      = "Kapitel,DLC&Patch",
        dropZones                = "Drop Zonen",
        dropZoneArena            = setTypeArenaName["de"],
        dropZoneImperialSewers   = "Kanalisation der Kaiserstadt",
        droppedBy                = "Drop durch",
        setId                    = "Set ID",
        setType                  = "Set Art",
        armorType                = "Rüstungsart",
        weaponType               = "Waffenart",
        armorOrWeaponType        = "Rüstungs-/Waffenart",
        equipmentType            = "Ausrüstungs Slot",
        equipSlot                = "Slot",
        enchantmentSearchCategory = "Verzaub. Kategorie",
        numBonuses               = "# Bonus",
        reconstructionCosts      = "Rekonstruktions Kosten",
        neededTraits             = "Eigenschaften benötigt",
        neededTraitsOrReconstructionCost = "Eigenschaften (Analyse)/Rekonstruktion Kosten",
        dropMechanic             = "Drop Mechanik",
        undauntedChest           = undauntedStr .. " Truhe",
        modifyTooltip            = "Tooltip um Set Infos erweitern",
        tooltipTextures          = "Zeige Tooltip Symbole",
        tooltipTextures_T        = "Zeige Symbole für Set Art, Drop Mechanik, Location/Boss Name, ... im Tooltip",
        defaultTooltipPattern    = "Voreingestellter Tooltip",
        defaultTooltipPattern_TT = "Nutze die Auswahlfelder um die entsprechende Information über die Set Gegenstände im Gegenstandstooltip anzuzeigen.\nDas standard Ausgabeformat ist:\n\n<Symbol><Set Art Name> <wenn handwerklich herstellbar: (Eigenschaften benötigt)/wenn nicht Handwerklich herstellbar: (Rekonstruktionskosten)>\n<Drop Zonen Info> [bestehend aus <ZonenName> (<DropMechanik>: <DropMechanikDropName>)]\<DLC Name>\nWenn alle Zonen identisch sind werden DropMechanic und Ort/Boss Namen ; getrennt als 1 Zeile ausgegeben.",
        customTooltipPattern     = "Selbst definierter Tooltip Text",
        customTooltipPattern_TT  = "Definiere deinen eigenen Tooltip Text, inklusive vor-definierter Platzhalter. Beispiel: \'Art <<1>>/Drop <<2>> <<3>> <<4>>\'.\nLasse dieses Textfeld leer, um den eigenen Tooltip Text zu deaktivieren!\nPlatzhalter müssen mit << beginnen, danach folt eine 1stellige Nummer, und beendet werden diese mit >>, z.B. <<1>> oder <<5>>. Es gibt maximal 6 Platzhalter in einem Text. Zeilenumbruch: <br>\n\nMögliche Platzhalter sind:\n<<1>>   Set Art\n<<2>>   Drop Mechaniken [können mehrere \',\' getrennte sein, je Zone 1]\n<<3>>   Drop Zonen [können mehrere \',\' getrennte sein, je Zone 1] Sind alle Zonen identisch wird nur 1 ausgegeben\n<<4>>   Boss/Drop durch Namen [können mehrere \',\' getrennte sein, je Zone 1]\n<<5>>   Benötigte Anzahl analysierter Eigenschaten, oder Rekonstruktionskosten\n<<6>>   Kapitel/DLC Name mit dem das Set eingeführt wurde.\n\n|cFF0000Achtung|r: Wenn du einen ungültigen Tooltip Text, ohne irgendeinen <<Nummer>> Platzhalter, eingibst wird sich das Textfeld automatisch selber leeren!",
        slashCommandDescription         = "Suche übersetzte Set Namen",
        slashCommandDescriptionClient   = "Suche Set ID/Namen (Spiel Sprache)",
        previewTT                = "Set Vorschau",
        previewTT_TT             = "Benutze den SlashCommand /lsp <setId> oder /lsp <setName oder setID> um eine Vorschau von einem Gegenstand dieses Sets zu erhalten.\n\nWenn du LibSlashCommander aktiv hast wird dir bei der Eingabe des Set Namens/der ID bereits eine Liste der passenden Sets zur Auswahl angezeigt.\nIst ein Set in der Liste per TAB Taste/Maus ausgewählt (Name steht im Chat Feld) kann mit der \'Leerzeichen\' Taste der Setname in anderen Sprachen angezeigt werden. Klick auf den SetNamen in der anderen Sprache oder presse die Enter Taste, um den SetNamen in deiner aktiven Sprache und der ausgewählten anderen Sprache in der Chat Eingabebox anzuzeigen, so dass du diese markieren und kopieren kannst.\n\n\nBenutze den SlashCommand /lss <setName oder ID> um die Set Such Oberfläche zu zeigen/zuverstecken",
        previewTTToChatToo       = "Vorschauf ItemLink in den Chat",
        previewTTToChatToo_TT    = "Wenn diese Option aktiviert ist wird der ItemLink des Vorschau Set Gegenstandes auch in deine Chat Eingabebox gesendet, damit du diesen jemanden schicken/ihn mit der Maus und STRG+C in deine Zwischenablage kopieren kannst.",
        headerUIStuff            = "Benutzer Oberfläche",
        headerTooltips            = "Tooltips",
        addSetCollectionsCurrentZoneButton = "Set Sammlung: Aktuelle Zone Knopf",
        addSetCollectionsCurrentZoneButton_TT = "Füge einen \'Aktuelle Zone\'/ \'Aktuelle Parent Zone\' Knopf in den Set Sammlungen hinzu.",
        moreOptions =           "Zeige mehr Optionen",
        parentZone =            "Übergeordnete Zone",
        currentZone =           "Aktuelle Zone",
        --Search UI
        multiSelectFilterSelectedText = "<<1[$d %s/$d %s]>>",
        noMultiSelectFiltered = "Keine %s gefiltert",
        nameTextSearch = "(+/-)Name/ID , getrennt",
        nameTextSearchTT = "Gib mehrere Namen/IDs durch Komma (,) getrennt ein.\nVerwende ein vorangestelltes + oder - um den Namen/die ID in der Textsuche ein- bzw. auszuschließen.",
        bonusTextSearch = "(+/-)Bonus , getrennt",
        bonusTextSearchTT = "Gib mehrere Bonus durch Komma (,) getrennt ein.\nVerwende ein vorangestelltes + oder - um den Bonus in der Textsuche ein- bzw. auszuschließen.\nFüge :<bonusZeilen#> hinzu, um den Bonus explizit in einer der Bonuszeilen zu suchen\n\nBeispiele:\n+krit,-leben findet alle Sets mit Bonus Text Krit (z.B. Kritische Chance) aber ohne Text Leben\n+krit:2 Findet alle sets mit 2. Bonuszeile Text krit",
        showAsText =        "Zeige als Text",
        showAsTextWithIcons = "Zeige als Text (mit Symbolen)",
        textBoxFilterTooltips = "Text Filter: Tooltips",
        dropdownFilterTooltips = "Dropdown Filter: Tooltips",
        dropdownFilterEntryTooltips = "Dropdown Filter: Einträge Tooltips",
        searchUIShowSetNameInEnglishToo = "Set Namen ebenfalls Englisch anzeigen/suchen",
        popupTooltip                = "Angehefteter Tooltip",
        setInfos                    = "Set Infos",
        showAsTooltip               = "Zeige als Tooltip",
        showCurrentZoneSets         = "Zeige Sets der aktuellen Zone",
        clearHistory                = "Historie leeren",
        wayshrines                  = "Wegschreine",
        invertSelection             = "≠ Auswahl invertieren",
        defaultActionLeftClick      = "Aktion beim",
        popupTooltipPosition        = "Angehefteter Tooltip Position",
    },
    ["en"] = {
        de  = "German",
        en  = "English",
        fr  = "French",
        jp  = "Japanese",
        ru  = "Russian",
        pl  = "Polish",
        es  = "Spanish",
        zh  = "Chinese",
        dlc                      = "Chapter,DLC&Patch",
        dropZones                = "Drop zones",
        dropZoneDelve            = GetString(SI_ZONEDISPLAYTYPE7), --SI_INSTANCEDISPLAYTYPE7
        dropZoneDungeon          = dungeonStr,
        dropZoneVeteranDungeon   = GetString(SI_DUNGEONDIFFICULTY2) .. " " .. dungeonStr,
        dropZonePublicDungeon    = GetString(SI_ZONEDISPLAYTYPE6), -- SI_INSTANCEDISPLAYTYPE6
        dropZoneBattleground     = GetString(SI_ZONEDISPLAYTYPE9), -- SI_INSTANCEDISPLAYTYPE9
        dropZoneTrial            = GetString(SI_LFGACTIVITY4),
        dropZoneArena            = setTypeArenaName["en"],
        dropZoneMail             = GetString(SI_WINDOW_TITLE_MAIL),
        dropZoneCrafted          = GetString(SI_SPECIALIZEDITEMTYPE213),
        dropZoneCyrodiil         = GetString(SI_CAMPAIGNRULESETTYPE1),
        dropZoneMonster          = dungeonStr,
        dropZoneImperialCity     = GetString(SI_CAMPAIGNRULESETTYPE4),
        dropZoneImperialSewers   = "Imperial City Sewers",
        dropZoneEndlessArchive   = GetString(SI_ZONEDISPLAYTYPE12),
        --dropZoneOverland =          GetString(),
        dropZoneSpecial          = GetString(SI_HOTBARCATEGORY9),
        dropZoneMythic           = GetString(SI_ITEMDISPLAYQUALITY6),
        droppedBy                = "Dropped by",
        reconstructionCosts      = "Reconstruction cost",
        setId                    = "Set ID",
        setType                  = "Set type",
        armorType                = "Armor type",
        weaponType               = "Weapon type",
        armorOrWeaponType        = "Armor-/Weapon type",
        equipmentType            = "Equipment slot",
        equipSlot                = "Slot",
        enchantmentSearchCategory = "Enchantment cat.",
        numBonuses               = "# bonus",
        neededTraits             = "Traits needed (research)",
        neededTraitsOrReconstructionCost = "Traits (research)/Reconstruction costs",
        dropMechanic             = "Drop mechanics",
        undauntedChest           = undauntedStr .. " chest",
        boss                     = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES501),
        modifyTooltip            = "Enhance tooltip by set info",
        tooltipTextures          = "Show tooltip textures",
        tooltipTextures_T        = "Show textures for the set type, drop mechanics and location/boss names ... within the tooltip",
        defaultTooltipPattern    = "Default tooltip",
        defaultTooltipPattern_TT = "Use the checkboxes to add this information about set items at the item tooltips.\nThe default output format is:\n\n<texture><set type name> <if craftable set: (traits needed)/if not craftable: (reconstruction costs)>\n<Drop zone info> [containing <zoneName> (<dropMechanic>: dropMechanicDropLocation>)]\n<DLC name>\nIf all zones are the same the dropMechanic and locatiton/boss names will be added as 1 line ; separated.",
        customTooltipPattern     = "Custom tooltip text",
        customTooltipPattern_TT  = "Define your own custom tooltip text, including the possibility to use some pre-defined placeholders in your text. Example: \'Type <<1>>/Drops <<2>> <<3>> <<4>>\'.\nLeave the text field empty to disable this custom tooltip!\nPlaceholders need to start with prefix << followed by a 1 digit number and a suffix of >>, e.g. <<1>> or <<5>>.\nThere can be only a maximum of 6 placeholders in the text. Line break: <br>\n\nBelow you'll find the possible placeholders:\n<<1>>   Set type\n<<2>>   Drop mechanics [could be several, for each zone, separated by \',\']\n<<3>>   Drop zones [could be several, for each zone, separated by \',\'] If all zones are the same they will be condensed\n<<4>>   Boss/Dropped by names [could be several, for each zone, separated by \',\']\n<<5>>   Number of needed traits researched, or reconstruction costs\n<<6>>   Chapter/DLC name set was introduced with.\n\n|cFF0000Attention|r: If you enter an invalid tooltip text, without any <<number>> placeholder the editfield will automatically clear itsself!",
        slashCommandDescription         = "Search translations of set names",
        slashCommandDescriptionClient   = "Search set ID/names (game client language)",
        previewTT                = "Set preview",
        previewTT_TT             = "Use the SlashCommand /lsp <setId> or /lsp <setName or setId> to get a preview tooltip of a set item.\n\nIf you got LibSlashCommander enabled the set names will show a list of possible entries as you type the name/id already.\nWas a set selected (name is written to the chat entry editbox) via the TAB key/mouse you can show the translated set names in other languages via the \'space\' key. Pressing the return key on that setName in another language (or clicking it) will show the current client language setName and the other chosen language setName in the chat edit box so you can mark and copy it.\n\n\nUse the SlashCommand /lss <setname or setId> to show/hide the set search UI.",
        previewTTToChatToo       = "Preview itemLink to chat",
        previewTTToChatToo_TT    = "With this setting enabled the preview itemlink of the set item will be send to your chat edit box too, so you can post it/mark it with your mouse an copy it to your clipboard using CTRL+C.",
        headerUIStuff            = "UI",
        headerTooltips            = "Tooltips",
        addSetCollectionsCurrentZoneButton = "Set coll.: Current zone button",
        addSetCollectionsCurrentZoneButton_TT = "Add a current zone/parent zone button to the set collections UI",
        moreOptions = "More options",
        parentZone = "Parent zone",
        currentZone = "Current zone",
        --Search UI
        multiSelectFilterSelectedText = "<<1[$d %s/$d %s]>>",
        noMultiSelectFiltered = "No %s filtered",
        nameTextSearch = "(+/-)Name/ID , separated",
        nameTextSearchTT = "Enter multiple names/IDs separated by a comma (,).\nUse the + or - prefix to include or exclude a name/ID from the search results.",
        bonusTextSearch = "(+/-)Bonus , separated",
        bonusTextSearchTT = "Enter multiple bonus separated by a comma (,).\nUse the + or - prefix to include or exclude a bonus from the search results.\nAdd :<bonusLine#> to explicitly search in that bonus line\n\nExamples:\n+crit,-life finds all sets with bonus text crit (e.g. criticial chance) but w/o text life\n+crit:2 Finds all sets with 2nd bonus line's text crit",
        showAsText =        "Show as text",
        showAsTextWithIcons = "Show as text (with icons)",
        textBoxFilterTooltips = "Text filter: Tooltips",
        dropdownFilterTooltips = "Dropdown filter: Tooltips",
        dropdownFilterEntryTooltips = "Dropdown filter: Entry tooltips",
        searchUIShowSetNameInEnglishToo = "Show/Search Set names in English too",
        popupTooltip                = "Popup tooltip",
        setInfos                    = "Set infos",
        showAsTooltip               = "Show as tooltip",
        showCurrentZoneSets         = "Show current zone\'s sets",
        clearHistory                = "Clear history",
        wayshrines                  = "Wayshrines",
        invertSelection             = "≠ Invert selection",
        setNames                    = GetString(SI_INVENTORY_SORT_TYPE_NAME),
        favorites                   = GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER),
        tooltips                    = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1306),
        defaultActionLeftClick      = "Default action at",
        popupTooltipPosition        = "Popup tooltip position",
        linkToChat                  = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),
    },
    ["es"] = {
        de  = "Alemán",
        en  = "Inglés",
        fr  = "Francés",
        jp  = "Japonés",
        ru  = "Ruso",
        pl  = "Polaco",
        es  = "Español",
        zh  = "Chino",
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
        de  = "Allemand",
        en  = "Anglais",
        fr  = "Français",
        jp  = "Japonais",
        ru  = "Russe",
        pl  = "Polonais",
        es  = "Espagnol",
        zh  = "Chinois",
        dlc                      = "Chapitre,DLC et Correctif",
        dropZones                = "Zones de drop",
        dropZoneDelve            = GetString(SI_ZONEDISPLAYTYPE7),
        dropZoneDungeon          = dungeonStr,
        dropZoneVeteranDungeon   = GetString(SI_DUNGEONDIFFICULTY2) .. " " .. dungeonStr,
        dropZonePublicDungeon    = GetString(SI_ZONEDISPLAYTYPE6),
        dropZoneBattleground     = GetString(SI_ZONEDISPLAYTYPE9),
        dropZoneTrial            = GetString(SI_LFGACTIVITY4),
        dropZoneArena            = setTypeArenaName["fr"],
        dropZoneMail             = GetString(SI_WINDOW_TITLE_MAIL),
        dropZoneCrafted          = GetString(SI_SPECIALIZEDITEMTYPE213),
        dropZoneCyrodiil         = GetString(SI_CAMPAIGNRULESETTYPE1),
        dropZoneMonster          = dungeonStr,
        dropZoneImperialCity     = GetString(SI_CAMPAIGNRULESETTYPE4),
        dropZoneImperialSewers   = "Égouts de la cité impériale",
        dropZoneEndlessArchive   = GetString(SI_ZONEDISPLAYTYPE12),
        --dropZoneOverland =          GetString(),
        dropZoneSpecial          = GetString(SI_HOTBARCATEGORY9),
        dropZoneMythic           = GetString(SI_ITEMDISPLAYQUALITY6),
        droppedBy                = "Obtenu par",
        reconstructionCosts      = "Coût de reconstruction",
        setId                    = "ID de l'ensemble",
        setType                  = "Type d'ensemble",
        armorType                = "Type d'armure",
        weaponType               = "Type d'arme",
        armorOrWeaponType        = "Type d'armure/arme",
        equipmentType            = "Emplacement de l'équipement",
        equipSlot                = "Emplacement",
        enchantmentSearchCategory = "Catégorie d'enchantement",
        numBonuses               = "# bonus",
        neededTraits             = "Traits nécessaires (recherche)",
        neededTraitsOrReconstructionCost = "Traits (recherche)/Coûts de reconstruction",
        dropMechanic             = "Mécanique de drop",
        undauntedChest           = undauntedStr .. " coffre",
        boss                     = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES501),
        modifyTooltip            = "Améliorer l'info-bulle avec les infos de l'ensemble",
        tooltipTextures          = "Afficher les textures dans l'info-bulle",
        tooltipTextures_T        = "Afficher les textures du type d'ensemble, de la mécanique de drop et des noms de lieu/boss ... dans l'info-bulle",
        defaultTooltipPattern    = "Info-bulle par défaut",
        defaultTooltipPattern_TT = "Utilisez les cases à cocher pour ajouter ces informations sur les objets de l'ensemble dans l'info-bulle.\nLe format de sortie par défaut est :\n\n<texture><nom du type d'ensemble> <si l'ensemble est fabriquable: (traits nécessaires)/sinon: (coûts de reconstruction)>\n<Info de la zone de drop> [contenant <NomZone> (<mécanique de drop>: dropMechanicDropLocation>)]\n<Nom du DLC>\nSi toutes les zones sont identiques, la mécanique de drop et les noms de lieu/boss seront ajoutés sur une seule ligne, séparés par ';'.",
        customTooltipPattern     = "Texte personnalisé pour l'info-bulle",
        customTooltipPattern_TT  = "Définissez votre propre texte personnalisé pour l'info-bulle, en utilisant des espaces réservés prédéfinis dans votre texte. Exemple : 'Taper <<1>>/Drops <<2>> <<3>> <<4>>'.\nLaissez le champ de texte vide pour désactiver cette info-bulle personnalisée!\nLes espaces réservés doivent commencer par le préfixe << suivi d'un chiffre à un seul chiffre et d'un suffixe >>, par exemple <<1>> ou <<5>>.\nIl ne peut y avoir qu'un maximum de 6 espaces réservés dans le texte. Saut de ligne : <br>\n\nCi-dessous, vous trouverez les espaces réservés possibles :\n<<1>>   Type d'ensemble\n<<2>>   Mécanique de drop [peut être multiple, pour chaque zone, séparées par \',\']\n<<3>>   Zones de drop [multiple, pour chaque zone, séparées par \',\'] Si toutes les zones sont identiques, elles seront condensées\n<<4>>   Boss/Obtenu par nom [multiple, pour chaque zone, séparés par \',\']\n<<5>>   Nombre de traits nécessaires recherchés, ou coûts de reconstruction\n<<6>>   Nom du chapitre/DLC avec lequel l'ensemble a été introduit.\n\n|cFF0000Attention|r: Si vous entrez un texte d'info-bulle invalide, sans aucun espace réservé <<numéro>>, le champ de texte sera automatiquement effacé !",
        slashCommandDescription         = "Rechercher des traductions de noms d'ensembles",
        slashCommandDescriptionClient   = "Rechercher des ID/noms d'ensembles (langue du client de jeu)",
        previewTT                = "Aperçu de l'ensemble",
        previewTT_TT             = "Utilisez la commande /lsp <setId> ou /lsp <Nom ou setId de l'ensemble> pour obtenir un aperçu de l'ensemble dans une info-bulle.\n\nSi vous avez activé LibSlashCommander, les noms d'ensembles afficheront déjà une liste d'entrées possibles lorsque vous tapez le nom/id.\nSi un ensemble est sélectionné (le nom est écrit dans la boîte d'édition de texte du chat) via la touche TAB/souris, vous pouvez afficher les noms d'ensembles traduits dans d'autres langues via la touche \'espace\'. Appuyer sur la touche de retour sur ce nom d'ensemble dans une autre langue (ou le cliquer) affichera le nom d'ensemble actuel dans la langue du client et l'autre nom d'ensemble choisi dans la boîte d'édition du chat afin que vous puissiez le sélectionner et le copier.\n\n\nUtilisez la commande /lss <nom ou setId de l'ensemble> pour afficher/masquer l'interface de recherche d'ensembles.",
        previewTTToChatToo       = "Aperçu de l'objet vers le chat",
        previewTTToChatToo_TT    = "Avec ce paramètre activé, l'aperçu de l'objet de l'ensemble sera également envoyé dans votre boîte d'édition du chat, afin que vous puissiez le poster/sélectionner avec la souris et le copier dans votre presse-papiers en utilisant CTRL+C.",
        headerUIStuff            = "Interface utilisateur",
        headerTooltips            = "Info-bulles",
        addSetCollectionsCurrentZoneButton = "Bouton de collections d'ensemble : Zone actuelle",
        addSetCollectionsCurrentZoneButton_TT = "Ajouter un bouton de zone actuelle/zone parente à l'interface des collections d'ensembles",
        moreOptions = "Plus d'options",
        parentZone = "Zone parente",
        currentZone = "Zone actuelle",
        --Search UI
        multiSelectFilterSelectedText = "<<1[$d %s/$d %s]>>",
        noMultiSelectFiltered = "Aucun %s filtré",
        nameTextSearch = "(+/-)Nom/ID , séparés",
        nameTextSearchTT = "Entrez plusieurs noms/IDs séparés par une virgule (,).\nUtilisez le préfixe + ou - pour inclure ou exclure un nom/ID des résultats de la recherche.",
        bonusTextSearch = "(+/-)Bonus , séparés",
        bonusTextSearchTT = "Entrez plusieurs bonus séparés par une virgule (,).\nUtilisez le préfixe + ou - pour inclure ou exclure un bonus des résultats de la recherche.\nAjoutez :<numéro de ligne de bonus> pour rechercher explicitement dans cette ligne de bonus\n\nExemples :\n+crit,-life trouve tous les ensembles avec le texte de bonus 'crit' (par exemple chance critique) mais sans le texte 'life'\n+crit:2 Trouve tous les ensembles avec le texte de la 2e ligne de bonus 'crit'",
        showAsText =        "Afficher en texte",
        showAsTextWithIcons = "Afficher en texte (avec icônes)",
        textBoxFilterTooltips = "Filtre de texte : Info-bulles",
        dropdownFilterTooltips = "Filtre déroulant : Info-bulles",
        dropdownFilterEntryTooltips = "Filtre déroulant : Info-bulles d'entrée",
        searchUIShowSetNameInEnglishToo = "Afficher/Rechercher les noms d'ensemble en anglais aussi",
        popupTooltip                = "Info-bulle contextuelle",
        setInfos                    = "Infos de l'ensemble",
        showAsTooltip               = "Afficher dans l'info-bulle",
        showCurrentZoneSets         = "Afficher les ensembles de la zone actuelle",
        clearHistory                = "Effacer l'historique",
        wayshrines                  = "Autels",
        invertSelection             = "≠ Inverser la sélection",
    },
    ["ru"] = {
        de  = "Нeмeцкий",
        en  = "Aнглийcкий",
        fr  = "Фpaнцузcкий",
        jp  = "Япoнcкий",
        ru  = "Pуccкий",
        pl  = "польский",
        es  = "испанский",
        zh  = "Китайский",
        dlc                    = "Глава/DLC",
        dropZones              = "Зоны сброса",
        dropZoneArena          = setTypeArenaName["ru"],
        dropZoneImperialSewers = "Канализация Имперского города",
        droppedBy              = "Снизился на",
        setType                = "Тип набора",
        dropMechanic           = "Механика падения",
        undauntedChest         = undauntedStr .. " грудь",
        modifyTooltip          = "Улучшить всплывающую подсказку с помощью информации о наборе элементов",
        slashCommandDescription = "Найти переводы названий наборов",
        slashCommandDescriptionClient = "Поиск по названию набора (язык игры)",
    },
    ["jp"] = {
        de  = "ドイツ語",
        en  = "英語",
        fr  = "フランス語",
        jp  = "日本語",
        ru  = "ロシア",
        pl  = "ポーランド語",
        es  = "スペイン語",
        zh  = "中国語",
        dlc                    = "チャプター/ DLC",
        dropZones              = "ドロップゾーン",
        dropZoneArena          = setTypeArenaName["jp"],
        dropZoneImperialSewers = "インペリアルシティ下水道",
        droppedBy              = "によってドロップ",
        setType                = "セットの種類",
        dropMechanic           = "ドロップメカニック",
        undauntedChest         = undauntedStr .. " 胸",
        modifyTooltip          = "アイテムセット情報によるツールチップの強化",
        slashCommandDescription = "セット名の翻訳を検索",
        slashCommandDescriptionClient = "セット名の検索 (ゲーム言語)",
    },
    ["zh"] = {
        --By Lykeion - 20240229
        de  = "德文",
        en  = "英文",
        fr  = "法文",
        jp  = "日文",
        ru  = "俄文",
        pl  = "波兰文",
        es  = "西班牙文",
        zh  = "中文",
        dlc                      = "章节, DLC & 补丁",
        dropZones                = "掉落区域",
        dropZoneDelve            = GetString(SI_ZONEDISPLAYTYPE7),
        dropZoneDungeon          = dungeonStr,
        dropZoneVeteranDungeon   = GetString(SI_DUNGEONDIFFICULTY2) .. " " .. dungeonStr,
        dropZonePublicDungeon    = GetString(SI_ZONEDISPLAYTYPE6),
        dropZoneBattleground     = GetString(SI_ZONEDISPLAYTYPE9),
        dropZoneTrial            = GetString(SI_LFGACTIVITY4),
        dropZoneArena            = setTypeArenaName["zh"],
        dropZoneMail             = GetString(SI_WINDOW_TITLE_MAIL),
        dropZoneCrafted          = GetString(SI_SPECIALIZEDITEMTYPE213),
        dropZoneCyrodiil         = GetString(SI_CAMPAIGNRULESETTYPE1),
        dropZoneMonster          = dungeonStr,
        dropZoneImperialCity     = GetString(SI_CAMPAIGNRULESETTYPE4),
        dropZoneImperialSewers   = "帝都下水道",
        dropZoneEndlessArchive   = GetString(SI_ZONEDISPLAYTYPE12),
        --dropZoneOverland =          GetString(),
        dropZoneSpecial          = GetString(SI_HOTBARCATEGORY9),
        dropZoneMythic           = GetString(SI_ITEMDISPLAYQUALITY6),
        droppedBy                = "掉落于",
        reconstructionCosts      = "重铸消耗",
        setId                    = "套装 ID",
        setType                  = "套装类型",
        armorType                = "护甲类型",
        weaponType               = "武器类型",
        armorOrWeaponType        = "护甲/武器类型",
        equipmentType            = "装备栏位",
        equipSlot                = "栏位",
        enchantmentSearchCategory = "附魔目录.",
        numBonuses               = "# 加成",
        neededTraits             = "需要特质 (研究)",
        neededTraitsOrReconstructionCost = "特质 (研究)/重铸消耗",
        dropMechanic             = "掉落机制",
        undauntedChest           = undauntedStr .. " 宝箱",
        boss                     = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES501),
        modifyTooltip            = "根据套装信息改进提示",
        tooltipTextures          = "在提示中显示材质",
        tooltipTextures_T        = "在提示中显示为套装类型, 掉落机制以及地点/Boss名等显示材质",
        defaultTooltipPattern    = "默认提示",
        defaultTooltipPattern_TT = "使用复选框在物品工具提示中添加有关套装物品的信息\n默认输出格式为：\n\n<材质><套装类型名> <如果是制造套: (所需特质)/如果不是制造套: (重铸消耗)>\n<掉落区域信息> [包含 <地区名> (<掉落机制>: 掉落机制掉落地区>)]\n<DLC 名>\n如果掉落地区一致, 掉落机制和地区/Boss名将会在一行中列出, 以;分割",
        customTooltipPattern     = "自定义提示文本",
        customTooltipPattern_TT  = "自定义你的提示文本, 可以在其中使用一些预定义的占位符. 例如: \'类型 <<1>>/掉落于 <<2>> <<3>> <<4>>\'.\n将文本留空会让提示无效!\n占位符必须以 << 作为前缀, 然后是一位数字, 然后以 >> 作为后缀, e.g. <<1>> 或 <<5>>.\n在文本中最多包含6个占位符. 换行: <br>\n\n以下是一个可能的占位符:\n<<1>>   套装类型\n<<2>>   掉落机制 [可能有好几种, 对于不同者, 以 \',\'分割]\n<<3>>   掉落区域 [可能有好几种, 对于不同者, 以 \',\'分割] 如果所有地区都在一起它们将被汇总\n<<4>>   Boss/署名掉落 [可能有好几种, 对于不同者, 以 \',\'分割]\n<<5>>   所需特质研究的数量, 或重铸消耗\n<<6>>   套装登场的章节/DLC 名.\n\n|cFF0000注意|r: 如果你输入了不包含任何占位符<<数字>>的无效提示文本, 输入框将会自行清空!",
        slashCommandDescription         = "查找套装名的翻译",
        slashCommandDescriptionClient   = "查找套装ID/名称 (根据客户端语言)",
        previewTT                = "套装预览",
        previewTT_TT             = "使用斜杠指令 /lsp <套装ID> or /lsp <套装名 或 套装ID> 来获取套装的预览提示.\n\n如果你拥有并启用了LibSlashCommander, 套装ID/套装名会自动在列表中补全.\n你可以通过空格键来显示在聊天输入框中通过TAB/鼠标选中的套装的翻译后名称. 在其他语言的套装名上按回退键(或点击它)会显示对应当前客户端语言的套装名并在聊天输入框中显示其他语言的名称以便你复制使用.\n\n\n使用斜杠命令 /lss <套装名 或 套装ID> 来展示/隐藏 查找界面.",
        previewTTToChatToo       = "发送物品预览链接到聊天栏",
        previewTTToChatToo_TT    = "当此选项启用时, 预览的物品链接也会被发送到聊天输入框, 以便你发送/复制它.",
        headerUIStuff            = "UI",
        headerTooltips            = "提示",
        addSetCollectionsCurrentZoneButton = "套装收集: 当前区域按键",
        addSetCollectionsCurrentZoneButton_TT = "在套装收集界面增加一个当前区域/父级区域按键",
        moreOptions = "更多选项",
        parentZone = "父级区域",
        currentZone = "当前区域",
        --Search UI
        multiSelectFilterSelectedText = "<<1[$d %s/$d %s]>>",
        noMultiSelectFiltered = "无 %s 被筛选",
        nameTextSearch = "(+/-)名称/ID , 单独",
        nameTextSearchTT = "在输入多个名称/ID时用逗号(,)分割.\n用+或-前缀来从搜索结果中包含或排除某个名称/ID.",
        bonusTextSearch = "(+/-)加成 , 单独",
        bonusTextSearchTT = "在输入多个加成用逗号(,)分割.\n用+或-前缀来从搜索结果中包含或排除某个加成.\n添加 :<加成条数#> 来特定搜索复数条的加成\n\n示例:\n+暴击t,-生命 搜索所有有暴击 (e.g. 暴击率) 加成但没有生命加成的套装\n+暴击:2 搜索所有有两条暴击词条的套装",
        showAsText =        "以文本展示",
        showAsTextWithIcons = "以文本展示 (和图标一起)",
        textBoxFilterTooltips = "文本过滤: 提示",
        dropdownFilterTooltips = "下拉过滤: 提示",
        dropdownFilterEntryTooltips = "下拉过滤: 入口提示",
        searchUIShowSetNameInEnglishToo = "也使用英语展示/搜索套装名",
        popupTooltip                = "弹出提示",
        setInfos                    = "套装信息",
        showAsTooltip               = "以提示形式展示",
        showCurrentZoneSets         = "显示当前地区的套装",
        clearHistory                = "清除历史",
        wayshrines                  = "传送祭坛",
        invertSelection             = "≠ 反选"
    },
}
lib.localization[fallbackLang].booleanToOnOff = booleanToOnOff


--Set metatable to get EN entries for missing other languages (fallback values)
local dropMechanicNames          = lib.dropMechanicIdToName
local dropMechanicNamesEn        = dropMechanicNames[fallbackLang]  --fallback value English

local dropMechanicTooltipNames   = lib.dropMechanicIdToNameTooltip
local dropMechanicTooltipNamesEn = dropMechanicTooltipNames[fallbackLang]  --fallback value English

local localization               = lib.localization
local localizationEn             = lib.localization[fallbackLang] --fallback value English

for supportedLanguage, isSupported in pairs(supportedLanguages) do
    if isSupported == true and supportedLanguage ~= fallbackLang then
        if specialZoneNames[supportedLanguage] ~= nil then
            setmetatable(specialZoneNames[supportedLanguage],          { __index = specialZoneNamesEn })
        end
        if dropMechanicNames[supportedLanguage] ~= nil then
            setmetatable(dropMechanicNames[supportedLanguage],          { __index = dropMechanicNamesEn })
        end
        if dropMechanicTooltipNames[supportedLanguage] ~= nil then
            setmetatable(dropMechanicTooltipNames[supportedLanguage],   { __index = dropMechanicTooltipNamesEn })
        end
        if localization[supportedLanguage] ~= nil then
            setmetatable(localization[supportedLanguage],               { __index = localizationEn })
        end
    end
end
--Set here first/again so that metatables already added fallbackLang (en) entries!
localization                     = lib.localization
dropMechanicNames                = lib.dropMechanicIdToName
dropMechanicTooltipNames         = lib.dropMechanicIdToNameTooltip
local clientLocalization         = localization[clientLang]

--Tooltips in client language, for LibAddonMenu-2.0 dropdown widget choices and choicesTooltips
local supportedLanguageChoicesTooltips = {}
for langIndex, langStr in ipairs(supportedLanguageChoices) do
    local langStrLong = clientLocalization[langStr]
    if langStrLong == nil or langStrLong == "" then langStrLong = langStr end
    supportedLanguageChoicesTooltips[langIndex] = langStrLong
    --Update the table lib.supportedLanguageChoices too!
    if langStr ~= langStrLong then
        supportedLanguageChoices[langIndex] = langStrLong
    end
end
lib.supportedLanguageChoicesTooltips = supportedLanguageChoicesTooltips


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
    [LIBSETS_DROP_MECHANIC_PUBLIC_DUNGEON_CHEST]                 = "/esoui/art/icons/undaunted_mediumcoffer.dds",
    [LIBSETS_DROP_MECHANIC_HARVEST_NODES]                        = "/esoui/art/crafting/smithing_tabicon_refine_up.dds",
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL]            = "/esoui/art/icons/poi/poi_town_complete.dds", -- Cyrodiil Cheydinhal city
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHORROL_WEYNON_PRIORY] = "/esoui/art/icons/poi/poi_town_complete.dds", -- Cyrodiil Weyon Priory, Chorrol
    [LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CHEYDINHAL_CHORROL_WEYNON_PRIORY] = "/esoui/art/icons/poi/poi_town_complete.dds",  -- Cyrodiil Cheydinhal city / Weyon Priory, Chorrol
    [LIBSETS_DROP_MECHANIC_CYRODIIL_BOARD_MISSIONS]             = "/esoui/art/icons/housing_gen_lsb_announcementboard001.dds", -- Cyrodiil board missions
    [LIBSETS_DROP_MECHANIC_IMPERIAL_CITY_TREASURE_TROVE_SCAMP]  = "/esoui/art/icons/achievement_ic_treasurescamp.dds", --Imperial city treasure scamps	Kaiserstadt Schatzgoblin
    [LIBSETS_DROP_MECHANIC_ENDLESS_ARCHIVE]                     = "/esoui/art/icons/poi/poi_endlessdungeon_incomplete.dds",

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
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER]          = "/esoui/art/icons/quest_head_monster_012.dds", --"Imperial City monster"
    [LIBSETS_SETTYPE_CYRODIIL_MONSTER]              = "/esoui/art/icons/quest_head_monster_011.dds", --"Cyrodiil monster"
    [LIBSETS_SETTYPE_CLASS]                         = "/esoui/art/icons/poi/poi_endlessdungeon_incomplete.dds", --"Class specific -> Endless Archive" -> Will be using classIcon at tooltip!
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
    [LIBSETS_SETTYPE_CYRODIIL_MONSTER]              = clientLocalization.dropZoneCyrodiil,
    [LIBSETS_SETTYPE_CLASS]                         = clientLocalization.dropZoneEndlessArchive,
    ["vet_dung"]                                    = clientLocalization.dropZoneDungeon,
}
lib.setTypeToDropZoneLocalizationStr   = setTypeToDropZoneLocalizationStr


--Set search favorite categories and their icons *.dds files
local possibleSetSearchFavoriteCategoriesUnsorted = {
    star = "EsoUI/Art/Collections/Favorite_StarOnly.dds",
    --PvE
    tank = "/esoui/art/inventory/inventory_tabicon_1handed_up.dds",
    stamDD = "/esoui/art/icons/store_staminapotion_001.dds",
    magDD = "/esoui/art/icons/store_magickadrink_001.dds",
    stamHeal = "/esoui/art/icons/alchemy/crafting_poison_trait_increasehealing.dds",
    magHeal = "/esoui/art/icons/alchemy/crafting_alchemy_trait_restorehealth_match.dds",
    hybrid = "/esoui/art/icons/crowncrate_staminahealth_drink.dds",
    --PvP
    PVPTank = "/esoui/art/progression/health_points_frame.dds",
    PVPStamDD = "/esoui/art/progression/stamina_points_frame.dds",
    PVPMagDD = "/esoui/art/progression/magicka_points_frame.dds",
    PVPStamHeal = "/esoui/art/icons/ability_healer_035.dds",
    PVPMagHeal = "/esoui/art/icons/ability_healer_024.dds",
    PVPHybrid = "/esoui/art/icons/ability_healer_029.dds",
    --Other
    farm = "/esoui/art/inventory/inventory_tabicon_crafting_up.dds",
    sneak = "/esoui/art/icons/ability_legerdemain_improvedsneak.dds",
    --Weapon types
    bow = "/esoui/art/progression/icon_bows.dds",
    dualWield = "/esoui/art/progression/icon_dualwield.dds",
    twoHand = "/esoui/art/progression/icon_2handed.dds",
    frostStaff = "/esoui/art/progression/icon_icestaff.dds",
    fireStaff = "/esoui/art/progression/icon_firestaff.dds",
    lightningStaff = "/esoui/art/progression/icon_lightningstaff.dds",
}
lib.possibleSetSearchFavoriteCategoriesUnsorted = possibleSetSearchFavoriteCategoriesUnsorted
local possibleSetSearchFavoriteCategoriesForSort = {
    "star",
    --PvE
    "tank",
    "stamDD",
    "magDD",
    "stamHeal",
    "magHeal",
    "hybrid",
    --PvP
    "PVPTank",
    "PVPStamDD",
    "PVPMagDD",
    "PVPStamHeal",
    "PVPMagHeal",
    "PVPHybrid",
    --Other
    "farm",
    "sneak",
    --Weapon types
    "bow",
    "dualWield",
    "twoHand",
    "frostStaff",
    "fireStaff",
    "lightningStaff",
}
local possibleSetSearchFavoriteCategoriesSorted = {}
for index, setSearchFavoriteCategory in ipairs(possibleSetSearchFavoriteCategoriesForSort) do
    possibleSetSearchFavoriteCategoriesSorted[index] = {
        category = setSearchFavoriteCategory,
        texture = possibleSetSearchFavoriteCategoriesUnsorted[setSearchFavoriteCategory],
    }
end
lib.possibleSetSearchFavoriteCategories = possibleSetSearchFavoriteCategoriesSorted
