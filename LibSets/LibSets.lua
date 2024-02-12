--[[========================================================================
    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>
========================================================================


========================================================================================================================
 !!! TODO / BUGs list !!!
========================================================================================================================
 Last updated: 2024-02-02, Baertram, PTS AP101041 Scions of Ithelia
------------------------------------------------------------------------------------------------------------------------

 --Known bugs--

 --Todo list--

    --Unique item detection, sirinsidiator 2022-03-07 e.g. "Pulsing Dremora Ring" and "Leviathan Rings", different itemIds
    so basically convert itemId to setId+slotId back to itemId and then compare input itemId to output itemId and if it's the same you got the non-unique version, otherwise it's the unique one
    you could actually do that in LibSets while scanning sets and then mark your data accordingly



 --Currently working on--


========================================================================================================================
 !!! API VERSION UPDATE - What needs to be scanned and done in this library and the Excel file?                     !!!
========================================================================================================================
All the data of this library is handled inside the included excel document LibSets_SetData.xlsx!

If the API version of the game client updates there will be most likely new zones and maps, wayshrines, dungeons, sets and itemIds of the sets
in the game which needs to be added to the excel (itemIds are only kept in the lua files!) and then to these library's lua files.

1) At first check this library's folder if there are any LibSets_Constants_<APIVersion integer>.lua files.
   If so: Transfer the data of the now "old APIVersion" files to the file LibSets_Constants_All.lua so they will always be loaded in the future.
   If needed: Create an new file with the current APIversion, e.g. LibSets_Constants_<NEW PTS APIVersion integer>.lua and include the needed
   data which should only be available if playing on the PTS.
2) Do the same like described at 1) with files LibSets_Data_<APIVersion integer>.lua files BUT move them to file
   LibSets_Data_All.lua (and not LibSets_Constants_All.lua!)
3) Update the txt manifest file LibSets.txt and increase the ## Version, ## AddOnVersion tags, and change the ## APIVersion tag to support the new APIVersion
   e.g. change 100027 100028 to 100028 100029
4) To scan the data of the new APIVersion ingame login to the PTS (or live if the new APIversion is already live!) and check the file LibSets_Debug.lua for the
   functions to scan the data (multilanguage scans are not automatically supported so you need to change the client language in between manually!).
   The scanned data will be saved to the SavedVariables filename LibSets.lua in the SavedVariables folder.
   -> You should use the function LibSets.DebugResetSavedVariables() once before scanning all the new data so the SavedVariables are empty.
      Do a /reloadui in chat afterwards to write the empty SV file on the harddisk/ssd!

   The table inside the SavedVariables filename LibSets.lua, where all data is saved, is:
   LibSets_SV_DEBUG_Data =
    {
        ["Default"] =
        {
            ["$AllAccounts"] =
            {
                ["$AccountWide"] = {
                    --The data is stored here below subtables describing what data is held inside!
                    [subTableKeyForTheScannedData1] = {},
                    [subTableKeyForTheScannedData2] = {},
                    [subTableKeyForTheScannedData3] = {},
                    [subTableKeyForTheScannedData4] = {},
                    ...
                },
            },
        },
    }

   The table keys of the "subTableKeyForTheScannedData1 ... n" tables inside the SavedVariables are constant values defined in the file
   LibSets_ConstantsLibraryInternal.lua, below the following comment line "--Constants for the table keys of setInfo, setNames etc."
   e.g. LIBSETS_TABLEKEY_NAMES = "Names"
   Use the value of these constants to check the appropriate subTable data inside the SavedVariables!

    -> For Debug functions available check teh file /LibSets/LibSets_Debug.lua, at the header

5) After scanning the data from the game client and updating the SavedVariables file LibSets.lua you got all the data in the following tables now:

LIBSETS_TABLEKEY_SETITEMIDS                         = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED              = "setItemIds_Compressed"
LIBSETS_TABLEKEY_SETNAMES                           = "set" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MAPS                               = "maps"
LIBSETS_TABLEKEY_WAYSHRINES                         = "wayshrines"
LIBSETS_TABLEKEY_WAYSHRINE_NAMES                    = "wayshrine" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_ZONE_DATA                          = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA                 = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES                  = "collectible" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID             = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_MIXED_SETNAMES                     = "MixedSetNamesForDataAll"
LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP           = "setProcsAllowedInPvP"
LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING  = "setItemCollectionsZoneMapping"
LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES       = "enchantSearchCategories"
-> LIBSETS_TABLEKEY_NAMES: This is only a "suffix" used for the tablekeys to add "Names" at the end


-[ For All entries in the SavedVariables containing these kind of | delimited texts: "[1021] = 1021|625|1011|Soltenure," ]-

Copy the values from the subtables to a text editor e.g. Notepad++ and use regular expressions e.g. to remove the [key] = ..., surroundings:
Replace \[.*\] = \"(.*)\", with $1 ($1 is the captured value between the () -> (.*)
This will give you a string like "1021|625|1011|Soltenure"


-[ Working with the excel document ]-
ATTENTION: If the excel map columns contains a forumlar KEEP THIS FORMULA and do NOT OVERWRITE IT!
Drag&drop down formulas from the rows above to the new rows in order to update all data carefully and correct!

Copy the whole strings to an empty Excel map (create a new one) inside the LibSets_SetData.xlsx file.
Use the "Split text" function from Excel (menu "Data") to split at the delimiter | into columns.
Depending on table key (e.g. LIBSETS_TABLEKEY_WAYSHRINES) open the appropriate Excel map (e.g. "ESO wayshrine node constants").
-> Check the yellow top row of the excel's map to see if the function name used to dump this data matches the function name of the
   SavedVariables table you are currently taking the data from!

An example dataset unsplit would be:    422|37|1654|Das südliche Elsweyr|719|1133|Das südliche Elsweyr|7|Die Vier-Pfoten-Landung
An example dataset split would be:      422 37  1654    Das südliche Elsweyr    719 1133    Das südliche Elsweyr    7   Die Vier-Pfoten-Landung
What column of the split data goes to what column on the excel map?
-Check the function in file LibSets_Debug.lua used to generate the SV data. For this example this was the function lib.DebugGetAllWayshrineInfo()
Above this function is described what the values between the | delimiter are:
--Returns a list of the wayshrine data (nodes) in the current client language and saves it to the SavedVars table "wayshrines" in this format:
--wayshrines[i] = wayshrineNodeId .."|"..currentMapIndex.."|"..currentMapId.."|"..currentMapNameLocalizedInClientLanguage.."|"
--..currentMapsZoneIndex.."|"..currentZoneId.."|"..currentZoneNameLocalizedInClientLanguage.."|"..wayshrinesPOIType.."|".. wayshrineNameCleanLocalizedInClientLanguage
Check the excel map columns now to find the appropriate coilumn for the split data.
e.g. wayshrineNodeId -> "Wayshrine ESO internal node ID", currentMapIndex -> "ESO internal mapIndex", currentMapId -> "ESO internal mapId", etc.

Place the values from the split columns into the matching fields of this excel map AND ALWAYS CHECK FIRST IF THERE IS A FORUMLAR IN THE COLUMN YOU WANT TO PUT THE DATA IN!
YOU NEED TO CHECK THIS IN THE ROWs ABOVE THE NEW ROW AS THE NEW ROW MIGHT NOT HAVE A FORMULAR ALREADY APPLIED.
YOU NEED TO MANUALLY DRAG&DROP THE FORMULAS DOWN FROM TOPROWS TO THE NEW ONES!
IF THERE IS A FORUMLA BEHIND THIS FIELD DO NOT OVERWRITE THIS FIELD. THE DATA WILL BE LOOKED UP FROM ANOTHER EXCEL MAP THEN, AS YOU FILL IN THE DATA THERE.
If the formula is not able to find a proper value, after you have extracted the new dungeons, wayshrines, zones etc. into the excel maps:
Check if there is a "Fixed" column in front of a column with a formula. Some columns in the "sets data" map e.g. will use this fixed column entry instead of trying to
determine it via a formula (e.g. the DLC ID -> instead of trying to read the zoneId from the wayshrine it can also use the fixed dlc id you specify).

-[ For the setItemIds ]-
The setItemIds is a table containing the setId as key and for each setId a subtable containing ALL itemIds of this set.
There is a lot of entries so we should "minify" the table to strip unneeded spaces and linebreaks.
Use a lua minifier tool only (e.g. https://mothereff.in/lua-minifier).
Copy the whole table from the SavedVariables and change the ["setItemIds"] to setItemIds.
Also remove the last , at the end of the copied text and you should be able to see the results in the "Minified result" box then.
Copy the minified result box content to your clipboard, and then paste it into the file
"LibSets_Data_all.lua", into table "lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS]" but strip the "setItemIds=" so that the result will look like this:
lib.setDataPreloaded = {
...
    [LIBSETS_TABLEKEY_SETITEMIDS] = {[19]={[109568]=true,[109569]=true,[109570]=true,[109571]=true,[109572]=true,
        ...
    }, --setItemIds
}, --lib.setDataPreloaded


-[ For the setNames ]-
The setNames is a table containing the setId as key and for each setId a subtable containing ALL itemIds of this set.
Do the same like described above at "For the setItemIds" but for the "setNames" here.

Copy the minified result box content to your clipboard, and then paste it into the file
"LibSets_Data_all.lua", into table "lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]" but strip the "setNames=" so that the result will look like this:
lib.setDataPreloaded = {
...
    [LIBSETS_TABLEKEY_SETNAMES] = {[19]={["fr"]="Les Vêtements du sorcier",["de"]="Gewänder des Hexers",["en"]="Vestments of the Warlock"},
        ...
    }, --setNames
}, --lib.setDataPreloaded


-[ For the wayshrineInfo ]-
After you have updated the "wayshrines" SavedVariables table to the excel document you need to use the created lua code,
coming from Excel file "LibSets_SetData.xlsx", map "ESO wayshrine node constants" colum P, to the filename "LibSets_Data_All.lua".

Do the same like described above at "For the setItemIds" but for the "wayshrine 2 zone data"
here (Excel file "LibSets_SetData.xlsx", map "ESO wayshrine node constants", colum P) -> Minify all the column P code.
Copy the minified result box content to your clipboard, and then paste it into the file
"LibSets_Data_all.lua", into table "lib.setDataPreloaded[LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID]" but strip the "setNames=" so that the result will look like this:
lib.setDataPreloaded = {
...
    [LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID] = {[1]=3,[2]=3,[3]=3,[4]=3,[5]=3,[6]=3,[7]=3,
        ...
    }, --wayshrine2ZoneId
}, --lib.setDataPreloaded


6) After updating all the set relevant information to the excel file you can have a look at the excel map "Sets data".
It contains all the data combined from the other excel maps. You need to add new rows for each new set and fill in the new setIds,
and the data. Be sure to drag&drop down ALL excel formulas from the rows above to the new rows as well!
Be sure to update the columns here like washrines, settype, dlcId, traits needed, isVeteran, the drop zones and drop mechanic + dropmechanic names (of the bosses, drop location, drop info)
This info in all the columns from left to right will generate the lua data in the most right columns which your are able to copy to the file LibSets_Data_All.lua at the end!

The new setIds are the ones that are, compared to the maximum setId from the existing rows, are higher (newer).
So check the SavedVariables for their names, and information.
-Non existing API information like "traits needed to craft" must be checked ingame at the crafting stations or on websites which provide this information already.
-Wayshrines where the sets can be found/near their crafting station need to be checked on the map and need to be manually entered as well to the data row.
After all info is updated you can look at the columns AX to BB which provide the generated LUA text for the table entries.
--> Copy ALL lines of this excel map to the file "LibSets_Data_All.lua" into the table "lib.setInfo"!
--> New sets which are not known on the live server will automatically be removed as the internal LibSets tables are build (using function "checkIfSetExists(setId)"
    from file LibSets.lua). So just keep them also in this table "lib.SetInfo"!


7) -[ For the set procs ]- -> !!! Disabled since 2022-04-20 !!!
You need to find out the set procs and abilityIds of the procs and add them to the excel's tab "SetProcs" at the relevant setId.
Each setId should have 1 row and in column D you need to add the procData table in this format, 1 new row for each different
LIBSETS_SETPROC_CHECKTYPE_* (see file LibSets_ConstantsLibraryInternal.lua for the possible SetprocCheckTypes), and 1 new
index if the SetprocCheckType is the same and only a different kind of abilityId or cooldown needs to be added.
The cooldown table uses the same index as the abilityIds table, so the 1st cooldown is for abilityId1, the 2nd is for abilityId2, and so on.
    [number setId] = {
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
            [number index1toN] = {
                ["abilityIds"] = {number abilityId1, number abilityId2, ...},
                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_EFFECT_CHANGED
                    ["unitTag"] = String unitTag e.g. "player", "playerpet", "group", "boss", etc.,

                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT
                    ["source"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER
                    ["target"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE
                    ["powerType"] = number powerType e.g. POWERTYPE_STAMINA

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED
                    ["unitTag"] = String unitTagOfBoss e.g. boss1, boss2, ...

                    --Only for LIBSETS_SETPROC_CHECKTYPE_SPECIAL
                    [number index1toN] = boolean specialFunctionIsGiven e.g. true/false (if true: the abilityId1's callback function should run a special                                             function as well, which will be registered for the

                ["cooldown"] = {number cooldownForAbilityId1 e.g. 12000, number cooldownForAbilityId2, ...},
                ["icon"] = String iconPathOfTheBuffIconToUse e.g. "/esoui/art/icons/ability_buff_minor_vitality.dds"
            },
        },
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
        ...
        },
        ...
        --String comment name of the set -> description of the proc EN / description of the proc DE
After updating the columns D you are able to specify comments etc. in the columns E anf F and copy the columns G to the file
LibSets_Data.All, table lib.setDataPreloaded, key LIBSETS_TABLEKEY_SET_PROCS
-> Be sure to read and follow the comments at column G about the excel created duplicate "", "[, \ " etc. and how to remove them!
]]

--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix
local apiVersion = GetAPIVersion()
local worldName = GetWorldName()

--The actual clients language
local fallbackLang = lib.fallbackLang
local clientLang = lib.clientLang

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ISCDM = ITEM_SET_COLLECTIONS_DATA_MANAGER

local tos = tostring
local strgmatch = string.gmatch
local strlower = string.lower
--local strlen = string.len
local strfind = string.find
local strsub = string.sub
local strfor = string.format

local tins = table.insert
local trem = table.remove
local tsort = table.sort
local unp = unpack
local zocstrfor = ZO_CachedStrFormat
local zoitf = zo_iconTextFormat

local gzidx = GetZoneIndex
local gzid = GetZoneId
local gpzid = GetParentZoneId
local gcmzidx = GetCurrentMapZoneIndex
local gmidbzid = GetMapIndexByZoneId
local gznbid = GetZoneNameById

local gilsetinf = GetItemLinkSetInfo

local gilat = GetItemLinkArmorType
local gilet = GetItemLinkEquipType
local giltt = GetItemLinkTraitType
local gilwt = GetItemLinkWeaponType
local gildeid = GetItemLinkDefaultEnchantId
local gesct = GetEnchantSearchCategoryType
local gilsi = GetItemLinkSetInfo
local giliscs = GetItemLinkItemSetCollectionSlot
local id64tos = Id64ToString


------------Global variables--------------
--Get counter suffix
local counterSuffix = lib.counterSuffix or "Counter"

------------The sets--------------
--The set's setIds
local setIds = lib.setIds
--The setIds which do not exist at the current API versin (determined at LoadSets() -> CheckSetExists(setId))
local nonExistingSetIdsAtCurrentApiVersion = lib.nonExistingSetIdsAtCurrentApiVersion
--The preloaded sets data
local preloaded         = lib.setDataPreloaded      -- <-- this table contains all setData (setItemIds, setNames) of the sets, preloaded
--The set data
local setInfo           = lib.setInfo               -- <--this table contains all set information like setId, type, drop zoneIds, wayshrines, etc.
--The special sets
local noSetIdSets       = lib.noSetIdSets           -- <-- this table contains the set information for special sets which got no ESO own unique setId, but a new generated setId starting with 9999xxx

local allSetNamesCached

--Wayshrine node index -> zoneId mapping
local wayshrine2zone = preloaded[LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID]

local libZone

--local lib variables
local localizationData
local supportedLanguages =              lib.supportedLanguages
local supportedLanguageChoices =        lib.supportedLanguageChoices
local supportedLanguageChoicesValues =  lib.supportedLanguageChoicesValues
local supportedLanguageChoicesTooltips =lib.supportedLanguageChoicesTooltips

local dropZones     =                   lib.dropZones
local setId2ZoneIds =                   lib.setId2DropZones
local zoneId2SetIds =                   lib.dropZone2SetIds
local allowedDropMechanics =            lib.allowedDropMechanics
local dropLocationNames =               lib.dropLocationNames
local dropLocation2SetIds =             lib.dropLocationNames2SetIds
local setId2DropLocations =             lib.setId2DropLocationNames
local dropMechanicIdToName =            lib.dropMechanicIdToName
local dropMechanicIdToNameTooltip =     lib.dropMechanicIdToNameTooltip
local undauntedChestIds =               lib.undauntedChestIds
local possibleDlcTypes =                lib.possibleDlcTypes
--local possibleDlcIds =                  lib.possibleDlcIds
local DLCandCHAPTERdata =               lib.DLCAndCHAPTERData
--local DLCandCHAPTERLookupdata =         lib.DLCandCHAPTERLookupdata
local NONDLCData =                      lib.NONDLCData
--local NONDLCLookupdata =                lib.NONDLCLookupdata
local allowedDLCTypes =                 lib.allowedDLCTypes
local allowedDLCIds =                   lib.allowedDLCIds
local dlcAndChapterCollectibleIds =     lib.dlcAndChapterCollectibleIds

local customTooltipHooksNeeded =        lib.customTooltipHooks.needed
--local customTooltipHooksHooked =        lib.customTooltipHooks.hooked
--local customTooltipHooksEventPlayerActivatedCalled = lib.customTooltipHooks.eventPlayerActivatedCalled

local classData =                       lib.classData
local allClassSets =                    lib.classSets

local nonPerfectedSet2PerfectedSet = lib.nonPerfectedSet2PerfectedSet
local perfectedSet2NonPerfectedSet = lib.perfectedSet2NonPerfectedSet
local perfectedSetsInfo = lib.perfectedSetsInfo


--Possible SlashCommand parameters
-->help
local callHelpParams = {
    ["list"]    = true, --English
    ["help"]    = true, --English
    ["hilfe"]   = true, --German
    ["aide"]    = true, --French
    ["ヘルプ"]   = true, --Japanese
    ["ayuda"]   = true, --Spanish
    ["помощь"]  = true, --Russian
    ["帮助"]    = true, --Chinese
}
-->search
local callSearchParams = {
    ["search"]  = true, --Englisch
    ["suche"]   = true,  --German
    ["cherche"] = true, --French
    ["検索"]    = true, --Japanese
    ["buscar"]  = true, --Spanish
    ["поиск"]   = true, --Russian
    ["搜索"]    = true, --Chinese
}
-->debug functions
local callDebugParams = {
    resetsv             = "DebugResetSavedVariables",
    scanitemids         = "DebugScanAllSetData",

    getall              = "DebugGetAllData",
    getallnames         = "DebugGetAllNames",

    getzones            = "DebugGetAllZoneInfo",
    getmapnamess        = "DebugGetAllMapNames",

    getwayshrines       = "DebugGetAllWayshrineInfo",
    getwayshrinenames   = "DebugGetAllWayshrineNames",

    getsetnames         = "DebugGetAllSetNames",
    shownewsets         = "DebugShowNewSetIds",

    getdungeons         = "DebugGetDungeonFinderData",
    getcollectiblenames = "DebugGetAllCollectibleNames",
    getdlcnames         = "DebugGetAllCollectibleDLCNames",
}


--local lib functions
local checkIfSetsAreLoadedProperly
local buildItemLink
local isNoESOSet
local getDropMechanicName
local getSetInfo
local getCurrentZoneIds
local isDungeonZoneId
local isDungeonZoneIdTrial
local isPublicDungeonZoneId

------------------------------------------------------------------------
-- 	Local helper functions
------------------------------------------------------------------------
local checkIfPTSAPIVersionIsLive = lib.checkIfPTSAPIVersionIsLive

local function toboolean(value)
    local booleanStrings = {
        ["true"]    = { [1]=true, ["1"]=true, ["true"]=true },
        ["false"]   = { [0]=true, ["0"]=true, ["false"]=true },
    }
    if booleanStrings["true"][value] then
        return true
    elseif booleanStrings["false"][value] then
        return false
    end
    return value
end

local function removeLanguages(tabVar, langToKeep)
    if not tabVar or not langToKeep or langToKeep == "" then return end
    local retTab = {}
    for idx, languagesTab in ipairs(tabVar) do
        for langStr, languageData in pairs(languagesTab) do
            if langStr == langToKeep then
                retTab[idx] = {
                    [langStr] = languageData
                }
                break
            end
        end
    end
    return retTab
end

local function langAllowedCheck(lang)
    lang = lang or clientLang
    lang = strlower(lang)
    if not supportedLanguages[lang] then
        lang = fallbackLang
    end
    return lang
end
lib.LangAllowedCheck = langAllowedCheck

local function getLocalizedText(textName, lang, ...)
    localizationData = localizationData or lib.localization
    lang = langAllowedCheck(lang)
    local localizedText = localizationData[lang][textName]

    local strForParams = {...}
    if strForParams ~= nil and #strForParams <= 7 then
        localizedText = string.format(localizedText, unpack(strForParams))
    end
    return localizedText or ""
end
lib.GetLocalizedText = getLocalizedText


local getIndexTableFromNonNumberKeyTable = function(sourceTable, useKey)
    if useKey == nil then return end
    local targetTable = {}
    for k, v in pairs(sourceTable) do
        if useKey == true then
            targetTable[#targetTable + 1] = k
        else
            targetTable[#targetTable + 1] = v
        end
    end
    return targetTable
end
lib.GetIndexTableFromNonNumberKeyTable = getIndexTableFromNonNumberKeyTable


local equipTypes = {
    EQUIP_TYPE_HEAD,
    EQUIP_TYPE_NECK,
    EQUIP_TYPE_CHEST,
    EQUIP_TYPE_SHOULDERS,
    EQUIP_TYPE_ONE_HAND,
    EQUIP_TYPE_TWO_HAND,
    EQUIP_TYPE_OFF_HAND,
    EQUIP_TYPE_WAIST,
    EQUIP_TYPE_LEGS,
    EQUIP_TYPE_FEET,
    EQUIP_TYPE_COSTUME,
    EQUIP_TYPE_RING,
    EQUIP_TYPE_HAND,
    EQUIP_TYPE_MAIN_HAND,
    EQUIP_TYPE_POISON,
}
local equipTypeIcons = {}
local function getEquipSlotTexture(equipSlot)
    if ZO_IsTableEmpty(equipTypeIcons) then
        for _, equipType in pairs(equipTypes) do
            local equipTypeIcon = ITEM_FILTER_UTILS.GetEquipTypeFilterIcons(equipType)
            if equipTypeIcon and equipTypeIcon.up then
                equipTypeIcons[equipType] = equipTypeIcon.up
            else
                --1hd, 2hd, main and off hand e.g. does not provide an icon there, but only at the equipment filter type EQUIPMENT_FILTER_TYPE_BOW
                -->Use ZOs way to determine the icon then
                --How do we determine this by the weapon type? Table EQUIPMENT_FILTER_TYPE_WEAPONTYPES in itemfilters is not global...
                --So hardcode the mapping here...
                local equipmentTypeToEquipmentFilterTypesMissingIcons = {
                    [EQUIP_TYPE_ONE_HAND] = EQUIPMENT_FILTER_TYPE_ONE_HANDED,
                    --[EQUIP_TYPE_MAIN_HAND] = EQUIPMENT_FILTER_TYPE_, --???
                    --[EQUIP_TYPE_OFF_HAND] = EQUIPMENT_FILTER_TYPE_, --???
                    [EQUIP_TYPE_TWO_HAND] = EQUIPMENT_FILTER_TYPE_TWO_HANDED,
                }
                local equipmentFilterType = equipmentTypeToEquipmentFilterTypesMissingIcons[equipType]
                if equipmentFilterType ~= nil then
                    local equipmentTypeData = ITEM_FILTER_UTILS.GetEquipmentFilterTypeFilterDisplayInfo(equipmentFilterType)
                    if equipmentTypeData and equipmentTypeData.icons and equipmentTypeData.icons.up then
                        equipTypeIcons[equipType] = equipmentTypeData.icons.up
                    end
                end
            end
        end
    end
    local equipTypeName = GetString("SI_EQUIPTYPE", equipSlot)
    local equipTypeNameStr = equipTypeName
    local equipTypeTexture = equipTypeIcons[equipSlot]
    if equipTypeTexture ~= nil then
        equipTypeNameStr = zoitf(equipTypeTexture, 24, 24, equipTypeName, nil)
    end
    return equipTypeTexture, equipTypeNameStr, equipTypeName
end
lib.GetEquipSlotTexture = getEquipSlotTexture


--Weapon types with 2hd weapons
local twoHandWeaponTypes = {
    [WEAPONTYPE_TWO_HANDED_AXE] =       true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] =    true,
    [WEAPONTYPE_TWO_HANDED_SWORD] =     true,
}

function lib.GetWeaponTypeText(weaponType)
    if weaponType == nil then return end
    local weaponTypeText = GetString("SI_WEAPONTYPE", weaponType)
    if not twoHandWeaponTypes[weaponType] then
        return weaponTypeText
    else
        return "2HD " .. weaponTypeText
    end
end
local libSets_GetWeaponTypeText = lib.GetWeaponTypeText

local weaponTypes = {
    WEAPONTYPE_AXE,
    WEAPONTYPE_HAMMER,
    WEAPONTYPE_SWORD,
    WEAPONTYPE_TWO_HANDED_SWORD,
    WEAPONTYPE_TWO_HANDED_AXE,
    WEAPONTYPE_TWO_HANDED_HAMMER,
    WEAPONTYPE_BOW,
    WEAPONTYPE_HEALING_STAFF,
    WEAPONTYPE_RUNE,
    WEAPONTYPE_DAGGER,
    WEAPONTYPE_FIRE_STAFF,
    WEAPONTYPE_FROST_STAFF,
    WEAPONTYPE_LIGHTNING_STAFF,
    WEAPONTYPE_SHIELD,
}
local weaponTypeIcons = {}
local function getWeaponTypeTexture(p_weaponType)
    if ZO_IsTableEmpty(weaponTypeIcons) then
        for _, weaponType in pairs(weaponTypes) do
            local weaponTypeIcon = ITEM_FILTER_UTILS.GetWeaponTypeFilterIcons(weaponType)
            if weaponTypeIcon and weaponTypeIcon.up then
                weaponTypeIcons[weaponType] = weaponTypeIcon.up
            else
                --Bow e.g. does not provide an icon there, but only at the equipment filetr type EQUIPMENT_FILTER_TYPE_BOW
                -->Use ZOs way to determine the icon then
                --How do we determine this by the weapon type? Table EQUIPMENT_FILTER_TYPE_WEAPONTYPES in itemfilters is not global...
                --So hardcode the mapping here...
                local equipmentTypeToWeaponTypesMissingIcons = {
                    [WEAPONTYPE_BOW] = EQUIPMENT_FILTER_TYPE_BOW,
                    [WEAPONTYPE_HEALING_STAFF] = EQUIPMENT_FILTER_TYPE_RESTO_STAFF,
                }
                local equipmentFilterType = equipmentTypeToWeaponTypesMissingIcons[weaponType]
                if equipmentFilterType ~= nil then
                    local equipmentTypeData = ITEM_FILTER_UTILS.GetEquipmentFilterTypeFilterDisplayInfo(equipmentFilterType)
                    if equipmentTypeData and equipmentTypeData.icons and equipmentTypeData.icons.up then
                        weaponTypeIcons[weaponType] = equipmentTypeData.icons.up
                    end
                end
            end
        end
    end
    local weaponTypeName = libSets_GetWeaponTypeText(p_weaponType)
    local weaponTypeNameStr = weaponTypeName
    local weaponTypeTexture = weaponTypeIcons[p_weaponType]
    if weaponTypeTexture ~= nil then
        weaponTypeNameStr = zoitf(weaponTypeTexture, 24, 24, weaponTypeName, nil)
    end
    return weaponTypeTexture, weaponTypeNameStr, weaponTypeName
end
lib.GetWeaponTypeTexture = getWeaponTypeTexture

local armorEquipmentTypes = {
    EQUIPMENT_FILTER_TYPE_LIGHT,
    EQUIPMENT_FILTER_TYPE_MEDIUM,
    EQUIPMENT_FILTER_TYPE_HEAVY,
    EQUIPMENT_FILTER_TYPE_NECK,
    EQUIPMENT_FILTER_TYPE_ONE_HANDED,
    EQUIPMENT_FILTER_TYPE_RING,
    EQUIPMENT_FILTER_TYPE_SHIELD,
    EQUIPMENT_FILTER_TYPE_TWO_HANDED,
    EQUIPMENT_FILTER_TYPE_DESTRO_STAFF,
    EQUIPMENT_FILTER_TYPE_RESTO_STAFF,
    EQUIPMENT_FILTER_TYPE_BOW,
}
local armorTypeIcons = {}
local function getArmorTypeTexture(p_armorType)
    if ZO_IsTableEmpty(armorTypeIcons) then
        for _, armorEquipmentType in pairs(armorEquipmentTypes) do
            local equipmentTypeData = ITEM_FILTER_UTILS.GetEquipmentFilterTypeFilterDisplayInfo(armorEquipmentType)
            if equipmentTypeData.icons and equipmentTypeData.icons.up then
                armorTypeIcons[armorEquipmentType] = equipmentTypeData.icons.up
            end
        end
    end
    local armorTypeName = GetString("SI_ARMORTYPE", p_armorType)
    local armorTypeNameStr = armorTypeName
    local armorTypeTexture = armorTypeIcons[p_armorType]
    if armorTypeTexture ~= nil then
        armorTypeNameStr = zoitf(armorTypeTexture, 24, 24, armorTypeName, nil)
    end
    return armorTypeTexture, armorTypeNameStr, armorTypeName
end
lib.GetArmorTypeTexture = getArmorTypeTexture

local function validateValueAgainstCheckTable(numberOrTable, checkTable, isAnyInCheckTable, doLocalDebug)
    isAnyInCheckTable = isAnyInCheckTable or false
    doLocalDebug = doLocalDebug or false
if doLocalDebug == true then
    d("[LibSets]validateValueAgainstCheckTable-isAnyInCheckTable: " ..tostring(isAnyInCheckTable))
end
    if checkTable == nil then return false end
    local result
    if type(numberOrTable) == "table" then
        for _, value in ipairs(numberOrTable) do
            result = checkTable[value] or false
if doLocalDebug == true then
    d(">>>result: " .. tostring(result))
end
            --Return false if any entry is not in the checkTable?
            if isAnyInCheckTable == false then
                if result == false then
if doLocalDebug == true then
    d("<<<FALSE entry not in checktable!")
end
                    return false
                end
            else
                --Return true if any entry is in the checkTable?
                if result == true then
if doLocalDebug == true then
    d("<<<TRUE any entry found in checktable!")
end
                    return true
                end
            end
        end
    else
        return checkTable[numberOrTable] or false
    end
    return result
end


------------------------------------------------------------------------
--======= SavedVariables ===============================================================================================
--Load the SavedVariables
local function LoadSavedVariables()
    --SavedVars were loaded already before?
    if lib.svData ~= nil then return end

    --For the library settings like tooltips
    local defaults = {
        --Tooltip set info
        modifyTooltips = false,
        tooltipModifications = {
            tooltipTextures = true,
            addSetType      = true,
            addDropLocation = true,
            addBossName     = true,
            addDropMechanic = true,
            addNeededTraits = true,
            addReconstructionCost = true, --shares the same LAM checkbox as addNeededTraits
            addDLC          = true,
        },
        useCustomTooltipPattern = "",

        --Created tooltip for set preview
        setPreviewTooltips = {
            sendToChatToo = true,
            equipType = EQUIP_TYPE_CHEST,
            traitType = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
            enchantSearchCategoryType = ENCHANTMENT_SEARCH_CATEGORY_NONE,
            quality = 370, --legendary
        },

        --UI stuff
        addSetCollectionsCurrentZoneButton = true,

        --Search UI
        setSearchTooltipsAtTextFilters = true,
        setSearchTooltipsAtFilters = true,
        setSearchTooltipsAtFilterEntries = true,
        setSearchShowSetNamesInEnglishToo = false,
        setSearchFavorites = {},
        setSearchSaveNameHistory = true,
        setSearchSaveBonusHistory = true,
        setSearchHistoryMaxEntries = 10,
        setSearchHistory = {
            ["name"] = {},
            ["bonus"] = {},
        },
    }
    lib.defaultSV = defaults
    --ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
    lib.svData = ZO_SavedVars:NewAccountWide(lib.svName, lib.svVersion, nil, defaults, worldName, "$AllAccounts")

    --Disable settings which should only be on if your clientLanguage is not "en"
    if clientLang == fallbackLang then
        lib.svData.setSearchShowSetNamesInEnglishToo = false
    end
    --------------------------------------------------------------------------------------------------------------------

    --For debugging and preloaded data
    local defaultsDebug =
    {
        [LIBSETS_TABLEKEY_NEWSETIDS]                = {},
        [LIBSETS_TABLEKEY_MAPS]                     = {},
        [LIBSETS_TABLEKEY_SETITEMIDS]               = {},
        [LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID]      = {},
        [LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED]    = {},
        [LIBSETS_TABLEKEY_SETNAMES]                 = {},
        [LIBSETS_TABLEKEY_WAYSHRINE_NAMES]          = {},
        [LIBSETS_TABLEKEY_ZONE_DATA]                = {},
        [LIBSETS_TABLEKEY_DUNGEONFINDER_DATA]       = {},
        [LIBSETS_TABLEKEY_COLLECTIBLE_NAMES]        = {},
        [LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES]    = {},
    }
    --ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
    lib.svDebugData = ZO_SavedVars:NewAccountWide(lib.svDebugName, 1, nil, defaultsDebug, nil, "$AllAccounts")
end
lib.LoadSavedVariables = LoadSavedVariables

local function getLibSetsSetPreviewTooltipSavedVariables()
    if not lib.svData then return end
    return lib.svData.setPreviewTooltips
end
lib.getLibSetsSetPreviewTooltipSavedVariables = getLibSetsSetPreviewTooltipSavedVariables

--======= SET ItemId decompression =====================================================================================
--Thanks to Dolgubon for the base function code from his LibLazyCrafting!
--entries in the SavedVariables table lib.svData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED] are of the type
--[setId] = {
--
--}
lib.tooltipSetDataWithoutItemIdsCached = {}
local tooltipSetDataWithoutItemIdsCached = lib.tooltipSetDataWithoutItemIdsCached
local CachedSetItemIdsTable = {}
lib.CachedSetItemIdsTable = CachedSetItemIdsTable
local function decompressSetIdItemIds(setId, isNonESOSet)
	if CachedSetItemIdsTable[setId] then
		return CachedSetItemIdsTable[setId]
	end
    if isNonESOSet == nil then
        isNoESOSet = isNoESOSet or lib.IsNoESOSet
        isNonESOSet = isNoESOSet(setId)
    end
    local preloadedSetItemIdsCompressed
    if isNonESOSet == true then
        preloadedSetItemIdsCompressed = preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID]
    else
        preloadedSetItemIdsCompressed = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    end
    local IdSource = preloadedSetItemIdsCompressed[setId]
	if not IdSource then return end
	local workingTable = {}
	for j = 1, #IdSource do
		--Is the itemId a number: Then use the itemId directly
        local itemIdType = type(IdSource[j])
        if itemIdType == "number" then
            workingTable[IdSource[j]] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
        --The itemId is a String (e.g. "200020, 3" -> Means itemId 200020 and 200020+1 and 200020+2 and 200020+3).
        --Split it at the , to get the starting itemId and the number of following itemIds
        elseif itemIdType == "string" then
            local commaSpot = strfind(IdSource[j],",")
			local firstPart = tonumber(strsub(IdSource[j], 1, commaSpot-1))
			local lastPart = tonumber(strsub(IdSource[j], commaSpot+1))
			for i = 0, lastPart do
				workingTable[firstPart + i] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
			end
		end
	end
    tsort(workingTable)
	CachedSetItemIdsTable[setId] = workingTable
	return workingTable
end
lib.DecompressSetIdItemIds = decompressSetIdItemIds

--======= SETS =====================================================================================================
--Check if an itemLink is a set and return the set's data from ESO API function GetItemLinkSetInfo
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = gilsetinf(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Get equipped numbers of a set's itemId, returning the setId and the item's link + equipped numbers
local function getSetEquippedInfo(itemId)
    if not itemId then return nil, nil, nil end
    buildItemLink = buildItemLink or lib.buildItemLink
    local itemLink = buildItemLink(itemId)
    local _, _, setId, _, equippedItems, maxEquipped = checkSet(itemLink)
    return setId, equippedItems, maxEquipped, itemLink
end

--Function to check if the setId is currently active with the APIversion (was determined at LoadSets() -> checkIfSetExists(setId))
local function isSetCurrentlyActiveWithAPIVersion(setId)
    if  setId == nil or nonExistingSetIdsAtCurrentApiVersion[setId] == true or setIds[setId] == nil then return false end
    return true
end
lib.IsSetCurrentlyActiveWithAPIVersion = isSetCurrentlyActiveWithAPIVersion

--Function to check if a setId is given for the current APIVersion
local function checkIfSetExists(setId)
    buildItemLink = buildItemLink or lib.buildItemLink
    if not setId or setId <= 0 then return false end
    local preloadedSetInfo      = lib.setInfo
    local preloadedSetItemIds   = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    --SetId is not known in preloaded data?
    if not preloadedSetInfo or not preloadedSetInfo[setId] or not preloadedSetItemIds or not preloadedSetItemIds[setId] then
        nonExistingSetIdsAtCurrentApiVersion[setId] = true
        return false
    end
    --SetId is known in preloaded data: get the first itemId of this setId, build an itemLink, and check if the setId for this itemId exists
    --by the help of the API function GetItemLinkSetInfo(itemLink).
    --Therefor we need to decompress the itemIds of the preloaded data first in order to get the real first itemId,
    --if the first entry of the itemIs table is "not" a number
    local compressedSetItemIdsOfSetId = preloadedSetItemIds[setId]
    local firstItemIdFound
    for _, itemId in pairs(compressedSetItemIdsOfSetId) do
        if itemId and type(itemId) == "number" and itemId > 0 then
            firstItemIdFound = itemId
            break -- exit the for loop
        end
    end
    if firstItemIdFound == nil then
        --No number itemId was found for the set, so decompress the whole setId, if not already done before
        local decompressedSetItemIdsOfSetId = decompressSetIdItemIds(setId)
        if decompressedSetItemIdsOfSetId ~= nil and not ZO_IsTableEmpty(decompressedSetItemIdsOfSetId) then
            preloadedSetInfo[setId][LIBSETS_TABLEKEY_SETITEMIDS] = decompressedSetItemIdsOfSetId

            --Update the decompressed itemIds to the setData, if no already given
            for itemId, _ in pairs(decompressedSetItemIdsOfSetId) do
                if itemId and itemId > 0 then
                    firstItemIdFound = itemId
                    break -- exit the for loop
                end
            end
        end
    end
    if firstItemIdFound ~= nil then
        --Build an itemLink of the set item and check if the set currently exists, with the same setId
        local itemLink = buildItemLink(firstItemIdFound)
        if itemLink and itemLink ~= "" then
            local isSet, _, setIdOfItemLink, _, _, _ = checkSet(itemLink)
            isSet = isSet or false
            local setExists = (isSet == true and setIdOfItemLink == setId and true) or false
            if not setExists then
                nonExistingSetIdsAtCurrentApiVersion[setId] = true
            end
            return setExists
        end
    end
    nonExistingSetIdsAtCurrentApiVersion[setId] = true
    return false
end

--Check if an itemId belongs to a special set and return the set's data from LibSets data tables
local function checkNoSetIdSet(itemId)
    if itemId == nil or itemId == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = false, "", 0, 0, 0, 0
    local noESOsetIdSetNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
    --Check the special sets data for the itemId
    for noESOSetId, specialSetData in pairs(noSetIdSets) do
        --Check if we got preloaded itemIds for the noSetIdSets
        if preloaded and preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID] and preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID][noESOSetId] then
            local specialSetsItemIds = lib.GetSetItemIds(noESOSetId, true)
            --Found the itemId in the sepcial sets itemIds table?
            if specialSetsItemIds and specialSetsItemIds[itemId] then
                isSet = true
                setName = noESOsetIdSetNames[noESOSetId][clientLang] or ""
                numBonuses = specialSetData[LIBSETS_TABLEKEY_NUMBONUSES] or 0
                numEquipped = lib.getNumEquippedItemsByItemIds(specialSetsItemIds)
                maxEquipped = specialSetData[LIBSETS_TABLEKEY_MAXEQUIPPED] or 0
                setId = noESOSetId
                return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
            end
        end
    end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

local function getSetsOfClassId(classId)
    --ClassId is valid?
    if classData.id2Index[classId] == nil then return end

    --Did we already prepare a sets list for this classId?
    if classData.setsList[classId] ~= nil then
        return classData.setsList[classId]
    end

    --No, prepare a new list
    local newSetsList = {}
    allClassSets = allClassSets or lib.classSets
    getSetInfo = getSetInfo or lib.GetSetInfo

    for setId, classSetData in pairs(allClassSets) do
        if classSetData.classId ~= nil and classSetData.classId == classId then
            newSetsList[setId] = getSetInfo(setId)
        end
    end
    if not ZO_IsTableEmpty(newSetsList) then
        classData.setsList[classId] = newSetsList
        return newSetsList
    end
    return
end


local function isAPerfectedOrNonPerfectedSetId(setId)
    if perfectedSetsInfo[setId] ~= nil then
        return true
    end
    if perfectedSet2NonPerfectedSet[setId] ~= nil then
        return true
    end
    if nonPerfectedSet2PerfectedSet[setId] ~= nil then
        return true
    end

    local setData = setInfo[setId]
    if setData.isPerfectedSet ~= nil and setData.isPerfectedSet == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
        return true
    end
    if setData.perfectedSetId ~= nil then
        return true
    end
    return false
end

local function fillPerfectedSetDataLookupTables(setId)
    if nonPerfectedSet2PerfectedSet[setId] ~= nil or perfectedSet2NonPerfectedSet[setId] ~= nil then return end

    local perfectedSetId, perfectedSetZoneId, nonPerfectedSetId, nonPerfectedSetZoneId
    local setData = setInfo[setId]

    if setData ~= nil then

        if setData.isPerfectedSet ~= nil and setData.isPerfectedSet == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
            perfectedSetId = setId
            perfectedSetZoneId = (setData.zoneIds ~= nil and setData.zoneIds[1]) or nil

            --Search the setInfo for an entry where "perfectedSetId" = setId
            for setIdOfNonPerfectedSet, setDataToSearch in pairs(setInfo) do
                if nonPerfectedSetId == nil then
                    if setId ~= setIdOfNonPerfectedSet then
                        local perfectedSetIdData = setDataToSearch.perfectedSetId
                        if perfectedSetIdData ~= nil and perfectedSetIdData == setId then
                            nonPerfectedSetId = setIdOfNonPerfectedSet
                            nonPerfectedSetZoneId = (setDataToSearch.zoneIds ~= nil and setDataToSearch.zoneIds[1]) or nil
                            break
                        end
                    end
                else
                    break
                end
            end
        end

        if setData.perfectedSetId ~= nil and ( perfectedSetId == nil or perfectedSetZoneId == nil or nonPerfectedSetId == nil or nonPerfectedSetZoneId == nil) then
            local setDataOfPerfectedSet = setInfo[setData.perfectedSetId]
            if setDataOfPerfectedSet ~= nil then
                perfectedSetId = perfectedSetId or setData.perfectedSetId
                perfectedSetZoneId = (perfectedSetZoneId or (setDataOfPerfectedSet.zoneIds ~= nil and setDataOfPerfectedSet.zoneIds[1])) or nil

                nonPerfectedSetId = nonPerfectedSetId or setId
                nonPerfectedSetZoneId = (nonPerfectedSetZoneId or (setData.zoneIds ~= nil and setData.zoneIds[1])) or nil
            end
        end

        if perfectedSetId ~= nil and perfectedSetZoneId ~= nil and nonPerfectedSetId ~= nil and nonPerfectedSetZoneId ~= nil then
            perfectedSet2NonPerfectedSet[perfectedSetId] = {
                setId = nonPerfectedSetId,
                zoneId = nonPerfectedSetZoneId,
            }
            nonPerfectedSet2PerfectedSet[nonPerfectedSetId] = {
                setId = perfectedSetId,
                zoneId = perfectedSetZoneId,
            }
        end
    end
end

--Read setInfo and get perfected/non-perfected set data, and build internal lookup tables
-->fills tables lib.nonPerfectedSet2PerfectedSet and lib.perfectedSet2NonPerfectedSet "on demand" (as API functions for non-/perfected sets are used)
local function getPerfectedSetData(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return end

    if perfectedSetsInfo[setId] ~= nil then
        return perfectedSetsInfo[setId]
    end

    local setData = setInfo[setId]
    local isPerfectedSet, perfectedSetId, perfectedSetZoneId, nonPerfectedSetId, nonPerfectedSetZoneId

    if setData.isPerfectedSet ~= nil then
        if setData.isPerfectedSet == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
            isPerfectedSet = true
            perfectedSetId = setId
        end

    elseif setData.perfectedSetId ~= nil then
        isPerfectedSet = false
        nonPerfectedSetId = setId
    else
        return nil
    end

    fillPerfectedSetDataLookupTables(setId)

    if isPerfectedSet ~= nil and (perfectedSetId ~= nil or nonPerfectedSetId ~= nil) then
        if isPerfectedSet == true then
            if perfectedSet2NonPerfectedSet[perfectedSetId] ~= nil then
                local nonPerfectedSetLookupData = perfectedSet2NonPerfectedSet[perfectedSetId]
                nonPerfectedSetId = nonPerfectedSetLookupData.setId
                nonPerfectedSetZoneId = nonPerfectedSetLookupData.zoneId
                if nonPerfectedSet2PerfectedSet[nonPerfectedSetId] ~= nil then
                    local perfectedSetLookupData = nonPerfectedSet2PerfectedSet[nonPerfectedSetId]
                    perfectedSetZoneId = perfectedSetLookupData.zoneId
                end
            end

        else
            if nonPerfectedSet2PerfectedSet[nonPerfectedSetId] ~= nil then
                local perfectedSetLookupData = nonPerfectedSet2PerfectedSet[nonPerfectedSetId]
                perfectedSetId = perfectedSetLookupData.setId
                perfectedSetZoneId = perfectedSetLookupData.zoneId
                if perfectedSet2NonPerfectedSet[perfectedSetId] ~= nil then
                    local nonPerfectedSetLookupData = perfectedSet2NonPerfectedSet[perfectedSetId]
                    nonPerfectedSetZoneId = nonPerfectedSetLookupData.zoneId
                end
            end
        end

        if perfectedSetId ~= nil and nonPerfectedSetId ~= nil and perfectedSetZoneId ~= nil and nonPerfectedSetZoneId ~= nil then
            perfectedSetsInfo[setId] = {
                isPerfectedSet = isPerfectedSet,

                perfectedSetId = perfectedSetId,
                perfectedSetZoneId = perfectedSetZoneId,

                nonPerfectedSetId = nonPerfectedSetId,
                nonPerfectedSetZoneId = nonPerfectedSetZoneId,
            }
        end
    else
        return nil
    end
    return perfectedSetsInfo[setId]
end


--Initialize the search UI now
local function InitSearchUI()
    if not lib.fullyLoaded then return end
    LibSets_SearchUI_Keyboard_TopLevel_OnInitialized(LibSets_SearchUI_TLC_Keyboard)
    --todo enable after Gamepad mode search UI xml and lua was created properly 2023-10-17
    --LibSets_SearchUI_Gamepad_TopLevel_OnInitialized(LibSets_SearchUI_TLC_Gamepad)
end


--Check which setIds were found and get the set's info from the preloaded data table "setInfo",
--sort them into their appropriate set table and increase the counter for each table
local function LoadSets()
    if lib.setsScanning then return end
    lib.setsScanning = true
    --Reset variables
    dropZones = {}
    setId2ZoneIds = {}
    zoneId2SetIds = {}
    dropLocationNames = {}
    setId2DropLocations = {}
    dropLocation2SetIds = {}
    local dropLocationNamesAdded = {}

------------------------------------------------------------------------------------------------------------------------
    lib.setTypeToSetIdsForSetTypeTable = {}
    --The mapping table for the internal library set tables and counter variables
    local setTypeToLibraryInternalVariableNames = lib.setTypeToLibraryInternalVariableNames
    if not setTypeToLibraryInternalVariableNames then return end
    --Set tables and counters (dynamic creation, depending on given LibSets SetTypes)
    for _, libSetsSetTypeVariableData in pairs(setTypeToLibraryInternalVariableNames) do
        if libSetsSetTypeVariableData then
            local libSetsSetTypeTableVariable = libSetsSetTypeVariableData["tableName"]
            local libSetsSetTypeCounterVariable = libSetsSetTypeTableVariable .. counterSuffix
            if libSetsSetTypeTableVariable then
                lib[libSetsSetTypeTableVariable] = {}
            end
            if libSetsSetTypeCounterVariable then
                lib[libSetsSetTypeCounterVariable] = 0
            end
        end
    end

    ------------------------------------------------------------------------------------------------------------------------
    --The overall setIds table
    lib.setIds = {}
    setIds = lib.setIds
    --The preloaded itemIds
    local preloadedItemIds = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    --The preloaded setNames
    local preloadedSetNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
    --The preloaded non ESO setId itemIds
    local preloadedNonESOsetIdItemIds = preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID]
    --The preloaded non ESO setId setNames
    local preloadedNonESOsetIdSetNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
    --The preloaded ESO setId with procs, allowed in PvP/AvA
    preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP] = {}
    local preloadedSetsWithProcsAllowedInPvP = preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP]

------------------------------------------------------------------------------------------------------------------------
    --Helper function to check the set type and update the tables in the library
    local function checkSetTypeAndUpdateLibTablesAndCounters(setDataTable)
        --Check the setsData and move entries to appropriate table
        for setId, setData in pairs(setDataTable) do
            local isNonESOSet = (noSetIdSets[setId] ~= nil and true) or false
            --Does this setId exist within the current APIVersion? Or is it a custom setId?
            if isNonESOSet == true or checkIfSetExists(setId) == true then
                --Add the setId to the setIds table
                setIds[setId] = true
                --Get the type of set and create the entry for the setId in the appropriate table
                local refToSetIdTable
                local setType = setData[LIBSETS_TABLEKEY_SETTYPE]
                if setType ~= nil then
                    local internalLibsSetVariableNames = setTypeToLibraryInternalVariableNames[setType]
                    local internalLibsSetTableName = internalLibsSetVariableNames ~= nil and internalLibsSetVariableNames["tableName"]
                    if internalLibsSetTableName ~= nil then
                        local internalLibsSetCounterName = internalLibsSetTableName .. counterSuffix
                        if lib[internalLibsSetTableName] and lib[internalLibsSetCounterName] then
                            lib[internalLibsSetTableName][setId] = setData
                            local counterVarCurrent = lib[internalLibsSetCounterName]
                            lib[internalLibsSetCounterName] = counterVarCurrent +1
                            refToSetIdTable = lib[internalLibsSetTableName][setId]
                        end
                    end
                end

                --Store all other data to the set's table
                if refToSetIdTable ~= nil then
                    --Get the itemIds stored for the setId and add them to the set's ["itemIds"] table
                    --Decompress the real itemIds
                    local itemIds = decompressSetIdItemIds(setId, isNonESOSet)
                    if itemIds ~= nil and not ZO_IsTableEmpty(itemIds) then
                        refToSetIdTable[LIBSETS_TABLEKEY_SETITEMIDS] = itemIds
                        --Also add the decompressed itemIds to the overall setInfo table entry of the set
                        if isNonESOSet == true then
                            noSetIdSets[setId][LIBSETS_TABLEKEY_SETITEMIDS] = itemIds
                        else
                            setInfo[setId][LIBSETS_TABLEKEY_SETITEMIDS] = itemIds
                        end
                    end

                    --Get the names stored for the setId and add them to the set's ["names"] table
                    local setNames
                    if isNonESOSet == true then
                        setNames = preloadedNonESOsetIdSetNames[setId]
                    else
                        setNames = preloadedSetNames[setId]
                    end
                    if setNames ~= nil then
                        refToSetIdTable[LIBSETS_TABLEKEY_SETNAMES] = setNames
                        --Also add the setNames to the overall setInfo table entry of the set
                        if isNonESOSet == true then
                            noSetIdSets[setId][LIBSETS_TABLEKEY_SETNAMES] = setNames
                        else
                            setInfo[setId][LIBSETS_TABLEKEY_SETNAMES] = setNames
                        end
                    end

                    --Is the setsData containing the entry for "allowed proc set in PvP"?
                    if setInfo[setId] ~= nil and (setInfo[setId].isProcSetAllowedInPvP ~= nil and
                            setInfo[setId].isProcSetAllowedInPvP == LIBSETS_SET_ITEMID_TABLE_VALUE_OK) then
                        preloadedSetsWithProcsAllowedInPvP[setId] = refToSetIdTable
                    end
                end

                --Zone and drop location data
                local setInfoTableRef
                if isNonESOSet == true then
                    setInfoTableRef = noSetIdSets
                else
                    setInfoTableRef = setInfo
                end
                if setInfoTableRef ~= nil then
                    if setInfoTableRef[setId] ~= nil then
                        if setInfoTableRef[setId].zoneIds ~= nil then
                            setId2ZoneIds[setId] = {}
                            for _, zoneId in ipairs(setInfoTableRef[setId].zoneIds) do
                                dropZones[zoneId] = true
                                setId2ZoneIds[setId][zoneId] = true
                                zoneId2SetIds[zoneId] = zoneId2SetIds[zoneId] or {}
                                zoneId2SetIds[zoneId][setId] = true
                            end
                        end
                        if setInfoTableRef[setId].dropMechanicDropLocationNames ~= nil then
                            for languageOfDropLocationName, dropLocationNamesInLang in pairs(setInfoTableRef[setId].dropMechanicDropLocationNames) do
                                for _, dropLocationNameInLang in ipairs(dropLocationNamesInLang) do
                                    if dropLocationNameInLang ~= "" then
                                        --Prevent duplicate entries, per language
                                        if dropLocationNamesAdded[languageOfDropLocationName] == nil or not dropLocationNamesAdded[languageOfDropLocationName][dropLocationNameInLang] then
                                            dropLocationNamesAdded[languageOfDropLocationName] = dropLocationNamesAdded[languageOfDropLocationName] or {}
                                            dropLocationNamesAdded[languageOfDropLocationName][dropLocationNameInLang] = true

                                            dropLocationNames[languageOfDropLocationName] = dropLocationNames[languageOfDropLocationName] or {}
                                            dropLocationNames[languageOfDropLocationName][#dropLocationNames[languageOfDropLocationName] + 1] = dropLocationNameInLang
                                        end

                                        setId2DropLocations[setId] = setId2DropLocations[setId] or {}
                                        setId2DropLocations[setId][languageOfDropLocationName] = setId2DropLocations[setId][languageOfDropLocationName] or {}
                                        setId2DropLocations[setId][languageOfDropLocationName][dropLocationNameInLang] = true
                                        dropLocation2SetIds[languageOfDropLocationName] = dropLocation2SetIds[languageOfDropLocationName] or {}
                                        dropLocation2SetIds[languageOfDropLocationName][dropLocationNameInLang] = dropLocation2SetIds[languageOfDropLocationName][dropLocationNameInLang] or {}
                                        dropLocation2SetIds[languageOfDropLocationName][dropLocationNameInLang][setId] = true
                                    end
                                end
                            end
                        end
                    else
                        setId2ZoneIds[setId] = nil
                        if not ZO_IsTableEmpty(zoneId2SetIds) then
                            for zoneId, setIdsInZone in pairs(zoneId2SetIds) do
                                for setIdInZone, isActive in pairs(setIdsInZone) do
                                    if setIdInZone == setId and isActive == true then
                                        zoneId2SetIds[zoneId][setId] = nil
                                    end
                                end
                            end
                        end
                        setId2DropLocations[setId] = nil
                        if not ZO_IsTableEmpty(dropLocation2SetIds) then
                            for languageOfDropLocationName, dropLocationNamesInLang in pairs(dropLocation2SetIds) do
                                for dropLocationNameInLang, setIdsOfDropLocationInLang in pairs(dropLocationNamesInLang) do
                                    for setIdForDropLocation, isActive in pairs(setIdsOfDropLocationInLang) do
                                        if setIdForDropLocation == setId and isActive == true then
                                            dropLocation2SetIds[languageOfDropLocationName][dropLocationNameInLang][setIdForDropLocation] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local setInfoTableRefToClear
                if isNonESOSet == true then
                    setInfoTableRefToClear = noSetIdSets
                else
                    setInfoTableRefToClear = setInfo
                end
                if setInfoTableRefToClear ~= nil then
                    --Set does not exist, so remove it from the setInfo table and all other "preloaded" tables as well
                    setInfoTableRefToClear[setId] = nil

                    preloadedItemIds[setId] = nil
                    CachedSetItemIdsTable[setId] = nil
                    preloadedNonESOsetIdItemIds[setId] = nil
                    preloadedSetNames[setId] = nil
                    preloadedNonESOsetIdSetNames[setId] = nil
                    preloadedSetsWithProcsAllowedInPvP[setId] = nil

                    setId2ZoneIds[setId] = nil
                    if not ZO_IsTableEmpty(zoneId2SetIds) then
                        for zoneId, setIdsInZone in pairs(zoneId2SetIds) do
                            for setIdInZone, isActive in pairs(setIdsInZone) do
                                if setIdInZone == setId and isActive == true then
                                    zoneId2SetIds[zoneId][setId] = nil
                                end
                            end
                        end
                    end
                    setId2DropLocations[setId] = nil
                    if not ZO_IsTableEmpty(dropLocation2SetIds) then
                        for languageOfDropLocationName, dropLocationNamesInLang in pairs(dropLocation2SetIds) do
                            for dropLocationNameInLang, setIdsOfDropLocationInLang in pairs(dropLocationNamesInLang) do
                                for setIdForDropLocation, isActive in pairs(setIdsOfDropLocationInLang) do
                                    if setIdForDropLocation == setId and isActive == true then
                                        dropLocation2SetIds[languageOfDropLocationName][dropLocationNameInLang][setIdForDropLocation] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end --for setId, setData in pairs(setDataTable) do
    end
------------------------------------------------------------------------------------------------------------------------

    --Get the setTypes for the normal ESO setIds
    checkSetTypeAndUpdateLibTablesAndCounters(setInfo)
    --And now get the settypes for the non ESO "self created" setIds
    if noSetIdSets ~= nil and not ZO_IsTableEmpty(noSetIdSets) then
        checkSetTypeAndUpdateLibTablesAndCounters(noSetIdSets)
    end
------------------------------------------------------------------------------------------------------------------------

    --Update the setType mapping to setType's setId tables within LibSets in order to have the current values, after
    -- they got updated, inside this mapping table. WIll be used within the local function getSetTypeSetsData which
    -- is used within the API functions to get the set data for the searched LibSets setType
    --Loop over table lib.setTypeToLibraryInternalTableAndCounterNames and for each tableName add the output to
    --lib.setTypeToSetIdsForSetTypeTable:
    for libSetsSetType, libSetsSetTypeVariableData in pairs(setTypeToLibraryInternalVariableNames) do
        if libSetsSetTypeVariableData then
            local libSetsSetTypeTableVariable = libSetsSetTypeVariableData["tableName"]
            if libSetsSetTypeTableVariable ~= nil then
                lib.setTypeToSetIdsForSetTypeTable[libSetsSetType] = lib[libSetsSetTypeTableVariable]
            end
        end
    end

    --Get equipTypes, armorTypes, weaponTypes, isJewelry from preloaded data and transfer them to internal library
    --tables, used for the API functions
    --Equip Types
    local preloadedEquipTypeData    = preloaded[LIBSETS_TABLEKEY_SETS_EQUIP_TYPES]
    lib.equipTypesSets = {}
    for equipType, setsDataOfEquipType in pairs(preloadedEquipTypeData) do
        lib.equipTypesSets[equipType] = lib.equipTypesSets[equipType] or {}
        for setId, isSetIdInEquipType in pairs(setsDataOfEquipType) do
            if lib.setIds[setId] ~= nil and isSetIdInEquipType == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
                --Add the setId to the equipTypes table
                lib.equipTypesSets[equipType][setId] = true
            end
        end
    end

    --Armor
    local preloadedArmorTypeData    = preloaded[LIBSETS_TABLEKEY_SETS_ARMOR_TYPES]
    lib.armorSets = {}
    lib.armorTypesSets = {}
    for armorType, setsDataOfArmorType in pairs(preloadedArmorTypeData) do
        lib.armorTypesSets[armorType] = lib.armorTypesSets[armorType] or {}
        for setId, isSetIdInArmorType in pairs(setsDataOfArmorType) do
            lib.armorSets[setId] = true
            if lib.setIds[setId] ~= nil and isSetIdInArmorType == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
                --Add the setId to the equipTypes table
                lib.armorTypesSets[armorType][setId] = true
            end
        end
    end

    --Weapons
    local preloadedWeaponTypeData   = preloaded[LIBSETS_TABLEKEY_SETS_WEAPONS_TYPES]
    lib.weaponSets = {}
    lib.weaponTypesSets = {}
    for weaponType, setsDataOfWeaponType in pairs(preloadedWeaponTypeData) do
        lib.weaponTypesSets[weaponType] = lib.weaponTypesSets[weaponType] or {}
        for setId, isSetIdInWeaponType in pairs(setsDataOfWeaponType) do
            lib.weaponSets[setId] = true
            if lib.setIds[setId] ~= nil and isSetIdInWeaponType == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
                --Add the setId to the equipTypes table
                lib.weaponTypesSets[weaponType][setId] = true
            end
        end
    end

    --Jewelry
    local preloadedIsJewelryData    = preloaded[LIBSETS_TABLEKEY_SETS_JEWELRY]
    lib.jewelrySets = {}
    for setId, isSetIdJewelry in pairs(preloadedIsJewelryData) do
        lib.weaponSets[setId] = true
        if lib.setIds[setId] ~= nil and isSetIdJewelry == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
            --Add the setId to the equipTypes table
            lib.jewelrySets[setId] = true
        end
    end

    --SetItemCollection data
    --Generate the table with the zoneId as key, and a table with the categoryId as key
    local preloadedSetItemCollectionMappingToZone = preloaded[LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING]
    lib.setItemCollectionZoneId2Category = {}
    lib.setItemCollectionCategory2ZoneId = {}
    lib.setItemCollectionParentCategories = {}
    lib.setItemCollectionCategories = {}
    for _, category2ZoneData in ipairs(preloadedSetItemCollectionMappingToZone) do
        local parentCategoryId = category2ZoneData.parentCategory
        local categoryId = category2ZoneData.category
        --Parent categories table
        lib.setItemCollectionParentCategories[parentCategoryId] = lib.setItemCollectionParentCategories[parentCategoryId] or {}
        lib.setItemCollectionParentCategories[parentCategoryId][categoryId] = category2ZoneData
        --Categories table
        lib.setItemCollectionCategories[categoryId] = category2ZoneData
        --Zone to categories / category to zones mapping tables
        if category2ZoneData.zoneIds ~= nil then
            lib.setItemCollectionCategory2ZoneId[categoryId] = lib.setItemCollectionCategory2ZoneId[categoryId] or {}
            for _, zoneId in ipairs(category2ZoneData.zoneIds) do
                lib.setItemCollectionZoneId2Category[zoneId] =  lib.setItemCollectionZoneId2Category[zoneId] or {}
                tins(lib.setItemCollectionZoneId2Category[zoneId], categoryId)
                tins(lib.setItemCollectionCategory2ZoneId[categoryId], zoneId)
            end
        end
    end

    --Enchantment Search Category
    --> Will only be updated as the search UI is used and filters that, as it needs some time to crawl all the sets and itemIds etc.
    --> Or as the API function is used, see function lib.GetSetEnchantSearchCategories(setId, equipType, traitType, armorType, weaponType)

    --Update the library tables with internally build data
    lib.dropZones = dropZones
    lib.setId2DropZones = setId2ZoneIds
    lib.dropZone2SetIds = zoneId2SetIds
    lib.allowedDropMechanics = allowedDropMechanics
    lib.dropLocationNames = dropLocationNames
    lib.dropLocationNames2SetIds = dropLocation2SetIds
    lib.setId2DropLocationNames = setId2DropLocations


    lib.setsScanning = false
    lib.setsLoaded = true
end

--======= Set itemIds ==================================================================================================
--Get the itemID(s) of a setId, filtered (if filter parameters are not nil).
--Returns 1 matching itemId if returnSingleItemId == true, else it will return a table with key [itemId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
--And as 2nd return value (only if returnSingleItemId == false and any param was passed in with teh value "all" instead of a number/id!):
-->A table returnTableData with e.g. a key LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES containing the relevant Ids (in this example { [search category type] = boolean, ... })
local function getSetItemIdsFiltered(returnSingleItemId, setId, allSetItemIds, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
    local doLocalDebug = false
    local getAllEnchantSearchCategoryTypesOfSetId = (enchantSearchCategoryType ~= nil and enchantSearchCategoryType == "all" and true) or false
    local enchantSearchCategoriesOfSetId = {}
    local returnTableData
    --todo: For debugging
    --[[
    if GetDisplayName() == "@Baertram" and setId == 600 then
        lib._debugGetSetItemIdsFiltered = lib._debugGetSetItemIdsFiltered or {}
        lib._debugGetSetItemIdsFiltered[setId] = {
            returnSingleItemId = returnSingleItemId,
            setId = setId,
            allSetItemIds = allSetItemIds,
            equipType = equipType,
            traitType = traitType,
            enchantSearchCategoryType = enchantSearchCategoryType,
            armorType = armorType,
            weaponType = weaponType,
        }
        doLocalDebug = true
        d("[LibSets]getSetItemIdsFiltered-setId: " ..tostring(setId))
    end
    ]]

    if returnSingleItemId == nil then return nil, nil end
    if allSetItemIds == nil or ZO_IsTableEmpty(allSetItemIds) then return nil, nil end

    local anyItemIdFound = false
    local foundItemIdsTable
    if returnSingleItemId == false then
        foundItemIdsTable = {}
    end

    local equipTypesValid = lib.equipTypesValid
    local traitTypesValid = lib.traitTypesValid
    local enchantSearchCategoryTypesValid = lib.enchantSearchCategoryTypesValid
    local isArmorEquipType = lib.isArmorEquipType
    local isWeaponEquipType = lib.isWeaponEquipType

    local equipTypeValid = false
    local traitTypeValid = false
    local enchantSearchCategoryTypeValid = false
    local armorTypeValid = false
    local weaponTypeValid = false

    if equipType ~= nil then
        equipTypeValid = validateValueAgainstCheckTable(equipType, equipTypesValid, nil, doLocalDebug)
        if doLocalDebug == true then d(">equipTypeValid: " ..tostring(equipTypeValid)) end
    end
    if traitType ~= nil then
        traitTypeValid = validateValueAgainstCheckTable(traitType, traitTypesValid, nil, doLocalDebug)
        if doLocalDebug == true then d(">traitTypeValid: " ..tostring(traitTypeValid)) end
    end
    if enchantSearchCategoryType ~= nil then
        enchantSearchCategoryTypeValid = validateValueAgainstCheckTable(enchantSearchCategoryType, enchantSearchCategoryTypesValid, nil, doLocalDebug)
        if doLocalDebug == true then d(">enchantSearchCategoryTypeValid: " ..tostring(enchantSearchCategoryTypeValid)) end
    end
    if armorType ~= nil then
        if equipType ~= nil then
            armorTypeValid = validateValueAgainstCheckTable(equipType, isArmorEquipType, nil, doLocalDebug)
            if not armorTypeValid then return nil, nil end
        end
        if doLocalDebug == true then d(">armorTypeValid: " ..tostring(armorTypeValid)) end
        armorTypeValid = true
    end
    if weaponType ~= nil then
        if equipType ~= nil then
            weaponTypeValid = validateValueAgainstCheckTable(equipType, isWeaponEquipType, nil, doLocalDebug)
            if not weaponTypeValid then return nil, nil end
        end
        if doLocalDebug == true then d(">weaponTypeValid: " ..tostring(weaponTypeValid)) end
        weaponTypeValid = true
    end
    if armorTypeValid == true and weaponTypeValid == true then return nil, nil end

if doLocalDebug == true then d(">---> got here") end

    local returnGenericItemId = true
    --Do we need to create an itemLink of the itemId to check equipType etc.?
    local needItemLinkOfItemId = (equipTypeValid == true or traitTypeValid == true or armorTypeValid == true or weaponTypeValid == true or enchantSearchCategoryTypeValid == true) or false
    if needItemLinkOfItemId == true then returnGenericItemId = false end
if doLocalDebug == true then d(">>>returnGenericItemId: " .. tostring(returnGenericItemId) .. ", needItemLinkOfItemId: " .. tostring(needItemLinkOfItemId)) end


    --Check all passed in set's itemIds now: Filter if needed
    local foundItemId
    for setItemId, isCorrect in pairs(allSetItemIds) do
        foundItemId = nil
        if setItemId ~= nil and isCorrect == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
            --Anything we need an itemlink for?
            if needItemLinkOfItemId == true then
                --Create itemLink of the itemId
                local itemLink = buildItemLink(setItemId, nil) --Default quality (quality does not matter)
if doLocalDebug == true then d(">>itemId: " .. tostring(setItemId) .. " " .. itemLink) end
                if itemLink ~= nil and itemLink ~= "" then
                    local isValidItemId = true

                    if isValidItemId == true and equipTypeValid == true then
                        isValidItemId = false
                        local ilEquipType = gilet(itemLink)
                        if ilEquipType ~= nil and validateValueAgainstCheckTable(equipType, {[ilEquipType]=true}, true) then isValidItemId = true end
if doLocalDebug == true then d(">>>ilEquipType: " .. tostring(ilEquipType) .. ", isValid: " .. tostring(isValidItemId)) end
                    end
                    if isValidItemId == true and traitTypeValid == true then
                        isValidItemId = false
                        local ilTraitType = giltt(itemLink)
                        if ilTraitType ~= nil and validateValueAgainstCheckTable(traitType, {[ilTraitType]=true}, true)  then isValidItemId = true end
if doLocalDebug == true then d(">>>ilTraitType: " .. tostring(ilTraitType) .. ", isValid: " .. tostring(isValidItemId)) end
                    end
                    if isValidItemId == true and armorTypeValid == true then
                        isValidItemId = false
                        local ilArmorType = gilat(itemLink)
                        if ilArmorType ~= nil and validateValueAgainstCheckTable(armorType, {[ilArmorType]=true}, true) then isValidItemId = true end
if doLocalDebug == true then d(">>>ilArmorType: " .. tostring(ilArmorType) .. ", isValid: " .. tostring(isValidItemId)) end
                    elseif isValidItemId == true and weaponTypeValid == true then
                        isValidItemId = false
                        local ilWeaponType = gilwt(itemLink)
                        if ilWeaponType ~= nil and validateValueAgainstCheckTable(weaponType, {[ilWeaponType]=true}, true, doLocalDebug) then isValidItemId = true end
if doLocalDebug == true then d(">>>ilWeaponType: " .. tostring(ilWeaponType) .. ", isValid: " .. tostring(isValidItemId)) end
                    end
                    if isValidItemId == true and enchantSearchCategoryTypeValid == true then
                        isValidItemId = false
                        local ilenchantId = gildeid(itemLink)
                        local ilenchantSearchCategoryType = gesct(ilenchantId)
if doLocalDebug == true then d(">>>ilenchantSearchCategoryType: " .. tostring(ilenchantSearchCategoryType) .. ", isValid: " .. tostring(isValidItemId)) end
                        if ilenchantSearchCategoryType ~= nil then
                            if getAllEnchantSearchCategoryTypesOfSetId == true then
                                isValidItemId = true
                                enchantSearchCategoriesOfSetId[ilenchantSearchCategoryType] = true
                            else
                                isValidItemId = validateValueAgainstCheckTable(enchantSearchCategoryType, {[ilenchantSearchCategoryType]=true}, true)
                            end
                        end
                    end

                    --Found a matching itemId?
                    if isValidItemId == true then
                        foundItemId = setItemId
                    end
                end

            else
                --No matching itemId needed. Return "any" (first found) itemId
                if returnGenericItemId == true then
                    foundItemId = setItemId
                end
            end

        end

        --Found a valid itemId in the loop?
        if foundItemId ~= nil then
if doLocalDebug == true then d(">>>foundItemId: " .. tostring(foundItemId)) end
            --Only return 1 itemId?
            if returnSingleItemId == true then
                return foundItemId, returnTableData
            else
                --Return all itemIds matching the criteria? -> Add to return table
                foundItemIdsTable[foundItemId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
                anyItemIdFound = true
            end
        end
    end --for

    --Return table with multiple founds itemIds?
    if returnSingleItemId == false and foundItemIdsTable ~= nil and anyItemIdFound == true then
        if getAllEnchantSearchCategoryTypesOfSetId == true then
            returnTableData = returnTableData or {}
            returnTableData[LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] = enchantSearchCategoriesOfSetId
        end
        return foundItemIdsTable, returnTableData
    end
    return nil, nil
end

--======= WORLDMAP =====================================================================================================
local function showWorldMap()
    if not ZO_WorldMap_IsWorldMapShowing() then
        if IsInGamepadPreferredMode() then
            SCENE_MANAGER:Push("gamepad_worldMap")
        else
            MAIN_MENU_KEYBOARD:ShowCategory(MENU_CATEGORY_MAP)
        end
    end
end


--======= Set type =====================================================================================================
--Helper function to return the setIds, itemIds and setNames for a given setType
local function getSetTypeSetsData(setType)
    if setType == nil then return end
    --Check if the setType is allowed within LiBSets
    local allowedSetTypes = lib.allowedSetTypes
    local allowedSetType  = allowedSetTypes[setType] or false
    if not allowedSetType then return end
    --Get the setIds tablefor the setType
    local setTypes2SetIdsTable = lib.setTypeToSetIdsForSetTypeTable
    local setType2SetIdsTable = setTypes2SetIdsTable[setType]
    if not setType2SetIdsTable then return false end
    --Loop over that table now and get each setId and transfer the data to the outputTable
    --+ enrich it with the setType and other needed information
    local setsDataForSetTypeTable
    local cnt = 0
    for setIdForSetType, setDataForSetType in pairs(setType2SetIdsTable) do
        setsDataForSetTypeTable = setsDataForSetTypeTable or {}
        setsDataForSetTypeTable[setIdForSetType] = setDataForSetType
        setsDataForSetTypeTable[setIdForSetType][LIBSETS_TABLEKEY_SETTYPE] = setType
        cnt = cnt +1
    end
    if cnt > 0 then
        return setsDataForSetTypeTable
    else
        return nil
    end
end

--======= Drop mechanic ================================================================================================
--Helper function to return the custom dropMechnicLocationNames (if a setId is specified)
local function getDropMechanicAndDropLocationNames(setId, langToUse, setData)
--d("getDropMechanicAndDropLocationNames-setId: " ..tos(setId) .. ", langToUse: " ..tos(langToUse))
    local dropMechanicNamesTable, dropMechanicDropLocationNamesTable, dropMechanicTooltipsTable
    if setId == nil and setData == nil then return nil, nil, nil, setData end
    if setData == nil then
        local isNonEsoSetId = isNoESOSet(setId)
        local preloadedSetItemIdsTableKey = LIBSETS_TABLEKEY_SETITEMIDS
        --local preloadedSetNamesTableKey = LIBSETS_TABLEKEY_SETNAMES
        if isNonEsoSetId == true then
            setData                     = noSetIdSets[setId]
            preloadedSetItemIdsTableKey = LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID
            --preloadedSetNamesTableKey   = LIBSETS_TABLEKEY_SETNAMES_NO_SETID
        else
            if setInfo[setId] == nil then return nil, nil, nil, nil end
            setData = setInfo[setId]
        end
        if setData == nil then return nil, nil, nil, nil end
        setData["setId"] = setId
    end
--lib._setData = setData
    local dropMechanicTable = setData[LIBSETS_TABLEKEY_DROPMECHANIC]
    if dropMechanicTable ~= nil then
        if supportedLanguages then
            local supportedLanguageData
            local onlyOneLanguage = (langToUse ~= nil and true) or false
--d(">onlyOneLanguage: " ..tos(onlyOneLanguage))
            if onlyOneLanguage then
                supportedLanguageData = supportedLanguages[langToUse]
                if not supportedLanguageData and langToUse ~= fallbackLang then
                    langToUse = fallbackLang
                    supportedLanguageData = supportedLanguages[langToUse]
                end
                if not supportedLanguageData then return nil, nil, nil, setData end
            end
--d(">onlyOneLanguage: " ..tos(onlyOneLanguage) .. ", langTouse: " ..tos(langToUse))

            local dropMechanicProvidedDropLocationNames = setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES]
--d(">2")

            --For each entry in the drop mechanic table: Check if a custom name is given, else determine the standard dropMechanic name via API function
            for idx, dropMechanic in ipairs(dropMechanicTable) do
--d(">idx: " ..tos(idx) .. ", dropMechanic: " ..tos(dropMechanic))
                --The drop mechanic is no monster name, so get the names of the drop mechanic via LibSets API function
                if onlyOneLanguage then
                    dropMechanicNamesTable                 = dropMechanicNamesTable or {}
                    dropMechanicNamesTable[idx]            = dropMechanicNamesTable[idx] or {}
                    dropMechanicTooltipsTable              = dropMechanicTooltipsTable or {}
                    dropMechanicTooltipsTable[idx]         = dropMechanicTooltipsTable[idx] or {}
                    dropMechanicNamesTable[idx][langToUse], dropMechanicTooltipsTable[idx][langToUse] = getDropMechanicName(dropMechanic, langToUse)
--d(">>3")
                    --Are custom drop names added (monster name, mob type, etc.)
                    if dropMechanicProvidedDropLocationNames ~= nil then
                        --First client language or language to use from parameter
                        --Is the language of the dropLocation not given in the desired language: Use EN fallback then
                        local langTouseForProvidedNames = langToUse
                        if dropMechanicProvidedDropLocationNames[langTouseForProvidedNames] == nil then
                            if langToUse ~= fallbackLang and dropMechanicProvidedDropLocationNames[fallbackLang] ~= nil then
                                langTouseForProvidedNames = fallbackLang
                            end
                        end
--d(">>>dropMechanicProvidedDropLocationNames-langTouseForProvidedNames: " ..tos(langTouseForProvidedNames))
                        if dropMechanicProvidedDropLocationNames[langTouseForProvidedNames] ~= nil and dropMechanicProvidedDropLocationNames[langTouseForProvidedNames][idx]
                            and dropMechanicProvidedDropLocationNames[langTouseForProvidedNames][idx] ~= "" then
                            dropMechanicDropLocationNamesTable                                 = dropMechanicDropLocationNamesTable or {}
                            dropMechanicDropLocationNamesTable[idx]                            = dropMechanicDropLocationNamesTable[idx] or {}
                            dropMechanicDropLocationNamesTable[idx][langTouseForProvidedNames] = dropMechanicProvidedDropLocationNames[langTouseForProvidedNames][idx]
                        end
                    end
                else
                    for supportedLanguage, isSupported in pairs(supportedLanguages) do
                        if isSupported == true then
                            dropMechanicNamesTable                         = dropMechanicNamesTable or {}
                            dropMechanicNamesTable[idx]                    = dropMechanicNamesTable[idx] or {}
                            dropMechanicTooltipsTable                      = dropMechanicTooltipsTable or {}
                            dropMechanicTooltipsTable[idx]                 = dropMechanicTooltipsTable[idx] or {}
                            dropMechanicNamesTable[idx][supportedLanguage], dropMechanicTooltipsTable[idx][supportedLanguage] = getDropMechanicName(dropMechanic, supportedLanguage)
                        end
                    end
                    --Are custom names added (monster name, mob type, etc.)
                    if dropMechanicProvidedDropLocationNames ~= nil then
--d(">>4")
                        --All languages - Take same index of dropMechanics for the dropLocationName
                        for supportedLanguage, isSupported in pairs(supportedLanguages) do
                            if isSupported == true then
                                if dropMechanicProvidedDropLocationNames[supportedLanguage] and dropMechanicProvidedDropLocationNames[supportedLanguage][idx]
                                    and dropMechanicProvidedDropLocationNames[supportedLanguage][idx] ~= "" then
                                    dropMechanicDropLocationNamesTable      = dropMechanicDropLocationNamesTable or {}
                                    dropMechanicDropLocationNamesTable[idx] = dropMechanicDropLocationNamesTable[idx] or {}
                                    dropMechanicDropLocationNamesTable[idx][supportedLanguage] = dropMechanicProvidedDropLocationNames[supportedLanguage][idx]
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return dropMechanicNamesTable, dropMechanicDropLocationNamesTable, dropMechanicTooltipsTable, setData
end
lib.GetDropMechanicAndDropLocationNames = getDropMechanicAndDropLocationNames

------------------------------------------------------------------------
-- 	Global helper functions
------------------------------------------------------------------------
--Create an example itemlink of the setItem's itemId (level 50, CP160) using the itemQuality subtype.
--Standard value for the qualitySubType is 366 which means "Normal" quality.
--The following qualities are available:
--357:  Trash
--366:  Normal
--367:  Magic
--368:  Arcane
--369:  Artifact
--370:  Legendary
--> Parameters: itemId number: The item's itemId
-->             itemQualitySubType number: The itemquality number of ESO, described above (standard value: 366 -> Normal)
--> Returns:    itemLink String: The generated itemLink for the item with the given quality
function lib.buildItemLink(itemId, itemQualitySubType)
    if itemId == nil or itemId == 0 then return end
    buildItemLink = buildItemLink or lib.buildItemLink
    --itemQualitySubType is used for the itemLinks quality, see UESP website for a description of the itemLink: https://en.uesp.net/wiki/Online:Item_Link
    itemQualitySubType = itemQualitySubType or 366 -- Normal
    --itemQualitySubType values for Level 50 items:
    --return '|H1:item:'..tos(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
    return strfor("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, itemQualitySubType, ITEMSTYLE_NONE, 0, 10000)
end
buildItemLink = lib.buildItemLink


--Open the worldmap and show the map of the zoneId
--> Parameters: zoneId number: The zone's zoneId
local openMapOfZoneId
function lib.openMapOfZoneId(zoneId, isParentZoneId)
    if not zoneId then return false end
    isParentZoneId = isParentZoneId or false
    local mapIndex = gmidbzid(zoneId)
    if mapIndex then
        showWorldMap()
        zo_callLater(function()
            ZO_WorldMap_SetMapByIndex(mapIndex)
        end, 50)
    else
        if isParentZoneId then return end
        --MapIndex was nil so maybe the zoneId was a dungeon/trial
        isDungeonZoneId = isDungeonZoneId or lib.IsDungeonZoneId
        isDungeonZoneIdTrial = isDungeonZoneIdTrial or lib.IsDungeonZoneIdTrial
        isPublicDungeonZoneId = isPublicDungeonZoneId or lib.IsPublicDungeonZoneId
        if isDungeonZoneId(zoneId) or isDungeonZoneIdTrial(zoneId) or isPublicDungeonZoneId(zoneId) then
            --Show the parent zoneId on the map then
            local parentZoneId = GetParentZoneId(zoneId)
            if parentZoneId ~= nil and parentZoneId ~= zoneId then
                openMapOfZoneId = openMapOfZoneId or lib.openMapOfZoneId
                openMapOfZoneId(parentZoneId, true)
            end
        end
    end
end
openMapOfZoneId = lib.openMapOfZoneId

--Open the worldmap, get the zoneId of the wayshrine wayshrineNodeId and show the wayshrine wayshrineNodeId on the map
--> Parameters: wayshrineNodeId number: The wayshrine's nodeIndex
function lib.showWayshrineNodeIdOnMap(wayshrineNodeId)
    if not wayshrineNodeId then return false end
    local zoneId = lib.GetWayshrinesZoneId(wayshrineNodeId)
    if not zoneId then return end
    openMapOfZoneId(zoneId)
    zo_callLater(function()
        ZO_WorldMap_PanToWayshrine(wayshrineNodeId)
    end, 100)
end


------------------------------------------------------------------------
-- 	Global set check functions
------------------------------------------------------------------------
--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.craftedSets[setId] ~= nil or false
end
local isCraftedSet = lib.IsCraftedSet

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.monsterSets[setId] ~= nil or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.dungeonSets[setId] ~= nil or false
end

--Returns true if the setId provided is a trial set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isTrialSet, boolean isMultiTrialSet
function lib.IsTrialSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local trialSetData = lib.trialSets[setId] or false
    local isTrialSet = false
    local isMultiTrialSet = false
    if trialSetData then
        isTrialSet = true
        if trialSetData.multiTrialSet then
            isMultiTrialSet = true
        end
    end
    return isTrialSet, isMultiTrialSet
end

--Returns true if the setId provided is an arena set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isArenaSet
function lib.IsArenaSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.arenaSets[setId] ~= nil or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.overlandSets[setId] ~= nil or false
end

--Returns true if the setId provided is an cyrodiil set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCyrodiilSet
function lib.IsCyrodiilSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.cyrodiilSets[setId] ~= nil or false
end

--Returns true if the setId provided is a battleground set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isBattlegroundSet
function lib.IsBattlegroundSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.battlegroundSets[setId] ~= nil or false
end

--Returns true if the setId provided is an Imperial City set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isImperialCitySet
function lib.IsImperialCitySet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.imperialCitySets[setId] ~= nil or false
end

--Returns true if the setId provided is a special set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSpecialSet
function lib.IsSpecialSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.specialSets[setId] ~= nil or false
end

--Returns true if the setId provided is a DailyRandomDungeonAndImperialCityRewardSet set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDailyRandomDungeonAndImperialCityRewardSet
function lib.IsDailyRandomDungeonAndImperialCityRewardSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.dailyRandomDungeonAndImperialCityRewardSets[setId] ~= nil or false
end

--Returns true if the setId provided is a mythic set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMythicSet
function lib.IsMythicSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return lib.mythicSets[setId] ~= nil or false
end

--Returns true if the setId provided is a class specific set
--> Parameters: setId number: The set's setId
-->             classId number:optional A class's Id
--              if the classId is provided the set's data will be checked against compatibility with this class
--> Returns:    boolean isClassSet
function lib.IsClassSet(setId, classId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end

    local classSetData = lib.classSets[setId]
    if classSetData == nil then return false end

    if classId ~= nil then
        if classSetData.classId ~= nil then
            return classSetData.classId == classId
        else
            return false
        end
    else
        return true
    end
end

--Returns boolean if the setId provided is a perfected or non perfected set from e.g. an Arena, Trial, etc.
--> Parameters: setId number: The set's setId
--> Returns:    boolean isAPerfectedOrNonPerfectedSetId
function lib.IsAPerfectedOrNonPerfectedSetId(setId)
    return isAPerfectedOrNonPerfectedSetId(setId)
end

--Returns true if the setId provided is a perfected set from e.g. an Arena, Trial, etc.
--> Parameters: setId number: The set's setId
--> Returns:    boolean isPerfectedSet
function lib.IsPerfectedSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local perfectedSetData = getPerfectedSetData(setId)
    local isPerfectedSet = (perfectedSetData ~= nil and perfectedSetData.isPerfectedSet == LIBSETS_SET_ITEMID_TABLE_VALUE_OK and true) or false
    return isPerfectedSet
end

--Returns true if the setId provided is a non-perfected set from e.g. an Arena, Trial, etc.
--> Parameters: setId number: The set's setId
--> Returns:    boolean isNonPerfectedSet
function lib.IsNonPerfectedSet(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local perfectedSetData = getPerfectedSetData(setId)
    local isNonPerfectedSet = (perfectedSetData ~= nil and (perfectedSetData.isPerfectedSet == nil or perfectedSetData.isPerfectedSet == LIBSETS_SET_ITEMID_TABLE_VALUE_NOTOK)
                                and perfectedSetData.perfectedSetId ~= nil and true) or false
    return isNonPerfectedSet
end


--Returns table perfectedSetInfo about the setId provided if it's a perfected set, or a non perfected set
--> Parameters: setId number: The set's setId (non perfected or perfected)
---> Attention: Table returned is nil if setId provided is neither a perfected nor a non perfected set
--> Returns:    nilable:table perfectedSetInfo = {
-->                 nilable:boolean isPerfectedSet,
-->
-->                 nilable:number  nonPerfectedSetId=<setIdOfNonPerfectedSet>,
-->                 nilable:number  nonPerfectedSetZoneId=<zoneIdOfNonPerfectedSet>,
-->
-->                 nilable:number  perfectedSetId=<setIdOfPerfectedSet>,
-->                 nilable:number  perfectedSetZoneId=<zoneIdOfPerfectedSet>,
-->             }
function lib.GetPerfectedSetInfo(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    if isAPerfectedOrNonPerfectedSetId(setId) == false then return end

    local perfectedSetData = getPerfectedSetData(setId)
    if perfectedSetData == nil then return nil end
    return perfectedSetData
end


--Returns true if the setId provided is a non ESO, own defined setId
--See file LibSets_SetData_(APIVersion).lua, table LibSets.lib.noSetIdSets and description above it.
--> Parameters: noESOSetId number: The set's setId
--> Returns:    boolean isNonESOSet
function lib.IsNoESOSet(noESOSetId)
    if noESOSetId == nil then return false end
    if not checkIfSetsAreLoadedProperly(noESOSetId) then return false end
    local isNoESOSetId = (noSetIdSets[noESOSetId] ~= nil and true) or false
    return isNoESOSetId
end
isNoESOSet = lib.IsNoESOSet

--Returns information about the set if the itemId provides it is a set item
--> Parameters: itemId number: The item's itemId
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemId(itemId)
    if itemId == nil then return end
    local itemLink = buildItemLink(itemId)
    local isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSet(itemLink)
    if not isSet then
        --Maybe it is a set with no ESO setId, but an own defined setId
        isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkNoSetIdSet(itemId)
    end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Returns information about the set if the itemlink provides is a set item
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemLink(itemLink)
    local isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSet(itemLink)
    if not isSet then
        --Maybe it is a set with no ESO setId, but an own defined setId
        isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkNoSetIdSet(GetItemLinkItemId(itemLink))
    end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Returns true/false if the set must be obtained in a veteran mode dungeon/trial/arena.
--If the veteran state is not a boolean value, but a table, then this table contains the equipType as key
--and the boolean value for each of these equipTypes as value. e.g. the head is a veteran setItem but the shoulders aren't (monster set).
--->To check the equiptype you need to specify the 2nd parameter itemlink in this case! Or the return value will be nil
--> Parameters: setId number: The set's setId
-->             itemLink String: An itemlink of a setItem -> only needed if the veteran data contains equipTypes and should be checked
-->                              against these.
--> Returns:    isVeteranSet boolean
function lib.IsVeteranSet(setId, itemLink)
	if not checkIfSetsAreLoadedProperly(setId) then return false end
	local isVeteranSet = false
	if setId and itemLink then
		local setData = setInfo[setId] or noSetIdSets[setId]
		if setData then
			local veteranData = setData.veteran
			if veteranData then
				if type(veteranData) == "table" then
					local equipType = gilet(itemLink)
					if equipType then
						for equipTypeVeteranCheck, isVeteran in pairs(veteranData) do
							if equipTypeVeteranCheck == equipType then
								return isVeteran
							end
						end
					end
				else
					isVeteranSet = veteranData
				end
			end
		end
	end
	return isVeteranSet
end

--Returns true/false if the set got items with a given armorType
--> Parameters: setId number: The set's setId
-->             armorType number: The armorType to check for
--> Returns:    isArmorTypeSet boolean
function lib.IsArmorTypeSet(setId, armorType)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId or not armorType then return end
    if not lib.armorTypesSets[armorType] then return end
    return lib.armorTypesSets[armorType][setId] or false
end

--Returns true/false if the set got items with light armor
--> Parameters: setId number: The set's setId
--> Returns:    isLightArmorSet boolean
function lib.IsLightArmorSet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_LIGHT][setId] or false
end

--Returns true/false if the set got items with medium armor
--> Parameters: setId number: The set's setId
--> Returns:    isMediumArmorSet boolean
function lib.IsMediumArmorSet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_MEDIUM][setId] or false
end

--Returns true/false if the set got items with heavy armor
--> Parameters: setId number: The set's setId
--> Returns:    isHeavyArmorSet boolean
function lib.IsHeavyArmorSet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_HEAVY][setId] or false
end

--Returns true/false if the set got items with armor
--> Parameters: setId number: The set's setId
--> Returns:    isArmorSet boolean
function lib.IsArmorSet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.armorSets[setId] or false
end

--Returns true/false if the set got items with jewelry
--> Parameters: setId number: The set's setId
--> Returns:    isJewelrySet boolean
function lib.IsJewelrySet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.jewelrySets[setId] or false
end

--Returns true/false if the set got items with weapons
--> Parameters: setId number: The set's setId
--> Returns:    isWeaponSet boolean
function lib.IsWeaponSet(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId then return end
    return lib.weaponSets[setId] or false
end

--Returns true/false if the set got items with a given weaponType
--> Parameters: setId number: The set's setId
-->             weaponType number: The weaponType to check for
--> Returns:    isWeaponTypeSet boolean
function lib.IsWeaponTypeSet(setId, weaponType)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId or not weaponType then return end
    if not lib.weaponTypesSets[weaponType] then return end
    return lib.weaponTypesSets[weaponType][setId] or false
end

--Returns true/false if the set got items with a given equipType
--> Parameters: setId number: The set's setId
-->             equipType number: The equipType to check for
--> Returns:    isEquipTypeSet boolean
function lib.IsEquipTypeSet(setId, equipType)
    if not checkIfSetsAreLoadedProperly(setId) then return false end
    if not setId or not equipType then return end
    if not lib.equipTypesSets[equipType] then return end
    return lib.equipTypesSets[equipType][setId] or false
end


------------------------------------------------------------------------
-- 	Global set get data functions
------------------------------------------------------------------------
--Returns a table of setIds where the set got items with a given armorType
--> Parameters: armorType number: The armorType to check for
--> Returns:    armorTypeSetIds table
function lib.GetAllArmorTypeSets(armorType)
    if not checkIfSetsAreLoadedProperly() then return false end
    if not armorType then return end
    return lib.armorTypesSets[armorType]
end

--Returns a table of setIds where the set got items with an armorType
--> Returns:    armorSet table
function lib.GetAllArmorSets()
    if not checkIfSetsAreLoadedProperly() then return false end
    return lib.armorSets
end

--Returns a table of setIds where the set got items with a jewelryType
--> Returns:    jewelrySets table
function lib.GetAllJewelrySets()
    if not checkIfSetsAreLoadedProperly() then return false end
    return lib.jewelrySets
end


--Returns a table of setIds where the set got items with a weaponType
--> Returns:    weaponSets table
function lib.GetAllWeaponSets()
    if not checkIfSetsAreLoadedProperly() then return false end
    return lib.weaponSets
end

--Returns a table of setIds where the set got items with a given weaponType
--> Parameters: weaponType number: The weaponType to check for
--> Returns:    weaponTypeSetIds table
function lib.GetAllWeaponTypeSets(weaponType)
    if not checkIfSetsAreLoadedProperly() then return false end
    if not weaponType then return end
    return lib.weaponTypesSets[weaponType]
end

--Returns a table of setIds where the set got items with a given equipType
--> Parameters: equipType number: The equipType to check for
--> Returns:    equipTypeSetIds table
function lib.GetAllEquipTypeSets(equipType)
    if not checkIfSetsAreLoadedProperly() then return false end
    if not equipType then return end
    return lib.equipTypesSets[equipType]
end


--Returns the wayshrines as table for the setId. The table contains up to 3 wayshrines for wayshrine nodes in the different factions,
--e.g. wayshrines={382,382,382}. All entries can be the same, or even a negative value which means: No weayshrine is known
--Else the order of the entries is 1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact
--> Parameters: setId number: The set's setId
-->             withRelatedZoneIds boolean: Also provide a mappingTable as 2nd return value which contains the wayshrine's zoneId
-->             in this format: wayshrineNodsId2ZoneId = { [wayshrineNodeId1]= zoneId1, [wayshrineNodeId2]= zoneId2,... }
--> Returns:    wayshrineNodeIds table
function lib.GetWayshrineIds(setId, withRelatedZoneIds)
    withRelatedZoneIds = withRelatedZoneIds or false
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setData = setInfo[setId]
    if setData == nil or setData[LIBSETS_TABLEKEY_WAYSHRINES] == nil then return end
    local wayshrineNodsId2ZoneId
    if withRelatedZoneIds then
        if not wayshrine2zone then return end
        wayshrineNodsId2ZoneId = {}
        --Get the zoneId for each wayshrineNodeId, read it from the preloaded setdata
        for _, wayshrineNodeId in ipairs(setData[LIBSETS_TABLEKEY_WAYSHRINES]) do
            wayshrineNodsId2ZoneId[wayshrineNodeId] = wayshrine2zone[wayshrineNodeId]
        end
    end
    return setData[LIBSETS_TABLEKEY_WAYSHRINES], wayshrineNodsId2ZoneId
end

--Returns the wayshrineNodeIds's related zoneId, where this wayshrine is located
--> Parameters: wayshrineNodeId number
--> Returns:    zoneId number
function lib.GetWayshrinesZoneId(wayshrineNodeId)
    if wayshrineNodeId == nil then return end
    if not checkIfSetsAreLoadedProperly() then return end
    --Get the zoneId for each wayshrineNodeId, read it from the preloaded setdata
    if not wayshrine2zone then return end
    return wayshrine2zone[wayshrineNodeId]
end

--Returns the drop zoneIds as table for the setId
--> Parameters: setId number: The set's setId
--> Returns:    zoneIds table, or NIL if set's DLCid is unknown
function lib.GetZoneIds(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setData = setInfo[setId]
    if setData == nil or setData[LIBSETS_TABLEKEY_ZONEIDS] == nil then return end
    return setData[LIBSETS_TABLEKEY_ZONEIDS]
end

--Returns the dlcId as number for the setId
--> Parameters: setId number: The set's setId
--> Returns:    dlcId number, or NIL if set's DLCid is unknown
function lib.GetDLCId(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setData = setInfo[setId]
    if setData == nil or setData.dlcId == nil then return end
    return setData.dlcId
end
local lib_GetDLCId = lib.GetDLCId

--Returns Boolean true/false if the set's dlcId is the currently active DLC.
--Means the set is "new added with this DLC".
--> Parameters: setId number: The set's setId
--> Returns:    wasAddedWithCurrentDLC Boolean, or NIL if set's DLCid is unknown
function lib.IsCurrentDLC(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setData = setInfo[setId]
    if setData == nil or setData.dlcId == nil then return end
    local wasAddedWithCurrentDLC = (DLC_ITERATION_END and setData.dlcId >= DLC_ITERATION_END) or false
    return wasAddedWithCurrentDLC
end

--Returns the table of DLCIDs of LibSets (the constants in LibSets.allowedDLCIds, see file LibSets_ConstantsLibraryInternal.lua)
function lib.GetAllDLCIds()
    return allowedDLCIds
end

--Returns the dlcType as number for the setId
--> Parameters: setId number: The set's setId
--> Returns:    dlcType number, or NIL if set's DLCType is unknown
function lib.GetDLCType(setId)
    local dlcId = lib_GetDLCId(setId)
    if dlcId ~= nil and allowedDLCIds[dlcId] then
        local dlcType = dlcAndChapterCollectibleIds[dlcId].type
        if allowedDLCTypes[dlcType] then
            return dlcType
        end
    end
    return
end

--Returns the name of the DLC type by help of the DLC type id
--> Parameters: dlcId number: The DLC id given in a set's info
--> Returns:    name dlcTypeName
function lib.GetDLCTypeName(dlcTypeId)
    if not lib.possibleDlcTypes then return end
    local dlcTypeName = lib.possibleDlcTypes[dlcTypeId] or ""
    return dlcTypeName
end

--Returns the table of DLC types of LibSets (the constants in LibSets.allowedDLCTypes, see file LibSets_ConstantsLibraryInternal.lua)
function lib.GetAllDLCTypes()
    return lib.allowedDLCTypes
end

--Returns the number of researched traits needed to craft this set. This will only check the craftable sets!
--> Parameters: setId number: The set's setId
--> Returns:    traitsNeededToCraft number
function lib.GetTraitsNeeded(setId)
    if setId == nil then return end
    if not isCraftedSet(setId) then return end
    local setData = setInfo[setId]
    if setData == nil or setData.traitsNeeded == nil then return end
    return setData.traitsNeeded
end

--Returns the type of the setId!
--> Parameters: setId number: The set's setId
--> Returns:    LibSetsSetType number
---> Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
function lib.GetSetType(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setData = setInfo[setId]
    if setData == nil then
        if isNoESOSet(setId) then
            setData = noSetIdSets[setId]
        else
            return
        end
    end
    if setData == nil then return end
    return setData[LIBSETS_TABLEKEY_SETTYPE]
end

--Returns the setType name as String
--> Parameters: libSetsSetType number: The set's setType (one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
-->             lang String the language for the setType name. Can be left nil -> The client language will be used then
--> Returns:    String setTypeName
function lib.GetSetTypeName(libSetsSetType, lang)
    if libSetsSetType == nil then return end
    lang = langAllowedCheck(lang)
    local allowedLibSetsSetTypes = lib.allowedSetTypes
    local allowedSetType = allowedLibSetsSetTypes[libSetsSetType] or false
    if not allowedSetType then return end
    local setTypeName
    local libSetsSetTypeNames = lib.setTypesToName
    local setTypeNameAllLang = libSetsSetTypeNames[libSetsSetType]
    if setTypeNameAllLang and setTypeNameAllLang[lang] then
        setTypeName = setTypeNameAllLang[lang]
    end
    return setTypeName
end

--Returns the table of setTypes of LibSets (the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
function lib.GetAllSetTypes()
    return lib.allowedSetTypes
end

--Returns the name of the drop mechanic ID (Aren cstage chest, worldboss, city, email rewards for the worthy, ...)
-->Will not contain the dropLocationName like boss name, mob name, loot name, etc.! Use function lib.GetDropMechanic(setId, withNames)
--> Parameters: dropMechanicId number: The LibSetsDropMechanidIc (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
-->             lang String: The 2char language String for the used translation. If left empty the current client's
-->             language will be used.
--> Returns:    String dropMachanicNameLocalized: The name fo the LibSetsDropMechanidIc, String dropMechanicNameTooltipLocalized: The tooltip of the dropMechanic
function lib.GetDropMechanicName(libSetsDropMechanicId, lang)
    if libSetsDropMechanicId == nil or libSetsDropMechanicId <= 0 then return nil, nil end
    if not allowedDropMechanics[libSetsDropMechanicId] then return nil, nil end
    lang = langAllowedCheck(lang)
    local dropMechanicNames = dropMechanicIdToName[lang]
    local dropMechanicTooltipNames = dropMechanicIdToNameTooltip[lang]
    if dropMechanicNames == nil or dropMechanicTooltipNames == nil then return nil, nil end
    local dropMechanicName = dropMechanicNames[libSetsDropMechanicId]
    local dropMechanicTooltip = dropMechanicTooltipNames[libSetsDropMechanicId]
    if not dropMechanicName or dropMechanicName == "" then return nil, nil end
    return dropMechanicName, dropMechanicTooltip
end
getDropMechanicName = lib.GetDropMechanicName

--Returns the dropMechanicIDs of the setId!
--> Parameters: setId number:           The set's setId
-->             withNames bolean:       Should the function return the dropMechanic names as well?
--> Returns:    LibSetsDropMechanicIds  table, LibSetsDropMechanicNamesForEachId table, LibSetsDropMechanicTooltipForEachId table, LibSetsDropMechanicLocationNames table, LibSetsZoneIdsOfDrop table
---> table LibSetsDropMechanicIds: The key is a number starting at 1 and increasing by 1, and the value is one of the dropMechanics
--->   of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
---> table LibSetsDropMechanicNamesForEachId: The key is an index, same as the index in table LibSetsDropMechanicIds,
--->   and the value is a subtable containing each language as key and the localized String as the value.
--->   table LibSetsDropMechanicTooltipForEachId: The key is an index, same as the index in table LibSetsDropMechanicIds,
--->   and the value is a subtable containing each language as key and the localized String as the value.
--->   table LibSetsDropMechanicLocationNames: The key is an index, same as the index in table LibSetsDropMechanicIds,
--->   and the value is a subtable containing each language as key and the localized String of the dropLocation (e.g. monster name, loot, mob type, ...) as the value.
--->   table LibSetsZoneIdsOfDrop: The key is an index, same as the index in table LibSetsDropMechanicIds,
--->   and the value is the zoneId where the setItem drops
function lib.GetDropMechanic(setId, withNames, lang)
    if setId == nil then return nil, nil, nil, nil, nil end
    if not checkIfSetsAreLoadedProperly(setId) then return nil, nil, nil, nil, nil end
    withNames = withNames or false
    local supportedLanguageData
    local onlyOneLanguage = (lang ~= nil and true) or false
    if onlyOneLanguage then
        supportedLanguageData = supportedLanguages[lang]
        if not supportedLanguageData and lang ~= fallbackLang then
            lang = fallbackLang
            supportedLanguageData = supportedLanguages[lang]
        end
--d(">lang: " ..tos(lang))
        if not supportedLanguageData then return nil, nil, nil, nil, nil end
    end

    local setData = setInfo[setId]
    if setData == nil then
        if isNoESOSet(setId) then
            setData = noSetIdSets[setId]
        end
    end
    if setData == nil or setData[LIBSETS_TABLEKEY_DROPMECHANIC] == nil then return nil, nil, nil, nil, nil end
--d(">setData found")
    local dropMechanicIds = setData[LIBSETS_TABLEKEY_DROPMECHANIC]
    local dropZoneIds = setData[LIBSETS_TABLEKEY_ZONEIDS]
    local dropMechanicNames
    local dropMechanicLocationNames
    local dropMechanicTooltips
    if withNames == true then
        local buildNames = false
        if setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] ~= nil then
            dropMechanicNames = ZO_ShallowTableCopy(setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES])
            if lang ~= nil then
                dropMechanicNames = removeLanguages(dropMechanicNames, lang)
            end
        else
            buildNames = true
        end
        if not buildNames and setData[LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES] ~= nil then
            dropMechanicTooltips = ZO_ShallowTableCopy(setData[LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES])
            if lang ~= nil then
                dropMechanicTooltips = removeLanguages(dropMechanicTooltips, lang)
            end
        else
            buildNames = true
        end
        if not buildNames and setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] ~= nil then
            dropMechanicLocationNames = ZO_ShallowTableCopy(setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES])
            if lang ~= nil then
                dropMechanicLocationNames = removeLanguages(dropMechanicLocationNames, lang)
            end
        else
            buildNames = true
        end
        if buildNames then
--d(">>buildNames")
            dropMechanicNames, dropMechanicLocationNames, dropMechanicTooltips = getDropMechanicAndDropLocationNames(setId, lang, setData)
        end
    end
    return dropMechanicIds, dropMechanicNames, dropMechanicTooltips, dropMechanicLocationNames, dropZoneIds
end

--Returns the table of dropMechanics of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
function lib.GetAllDropMechanics()
    return allowedDropMechanics
end

--Returns the table of dropZones of LibSets: All sets data was scanned for zoneIds where it could drop, and a complete list
--of lib.dropZones = {[zoneId] = true, ... } was created
function lib.GetAllDropZones()
    if not checkIfSetsAreLoadedProperly() then return end
    return dropZones
end

--Returns table LibSets.zoneId2SetId
function lib.GetDropZonesBySetId(setId)
    if not checkIfSetsAreLoadedProperly(setId) then return end
    if setId == nil or setId2ZoneIds[setId] == nil then return end
    return setId2ZoneIds[setId]
end

--Returns table LibSets.setId2ZoneId was created.
function lib.GetSetIdsByDropZone(zoneId)
    if not checkIfSetsAreLoadedProperly() then return end
    if zoneId == nil or zoneId2SetIds[zoneId] == nil then return end
    return zoneId2SetIds[zoneId]
end
local getSetIdsByDropZone = lib.GetSetIdsByDropZone

--Returns table:nilable setIdsOfCurrentZone
--with key = [zoneId] and value = table { [setId] = boolean, ... }
--number currentZoneId, number currentZoneParentId
function lib.GetSetIdsOfCurrentZone()
    getCurrentZoneIds = getCurrentZoneIds or lib.GetCurrentZoneIds
    local setIdsOfCurrentZone

    --Get current zoneId
    local currentZoneId, currentZoneParentId, currentZoneIndex, currentZoneParentIndex = getCurrentZoneIds()
    if currentZoneId == nil and currentZoneParentId == nil then return end

--d(">currentZoneId: " ..tos(currentZoneId))

    --Get setIds of current zone
    if currentZoneId ~= nil then
        setIdsOfCurrentZone = getSetIdsByDropZone(currentZoneId)
    end
    --ParentZone is different and maybe provide sets? Use this zoneId then
    if setIdsOfCurrentZone == nil and currentZoneParentId ~= nil and currentZoneParentId ~= currentZoneId then
--d(">>parentZoneId: " ..tos(currentZoneParentId))
        currentZoneId = currentZoneParentId
        setIdsOfCurrentZone = getSetIdsByDropZone(currentZoneId)
    end
--lib._debugSetIdsOfCurrentZone = setIdsOfCurrentZone
    return setIdsOfCurrentZone, currentZoneId, currentZoneParentId
end

--Returns the table of dropLocationNames of LibSets: All sets data was scanned for dropLocation names, and a complete list
--of lib.dropLocationNames = {["de"] = { "Name1", "Name2", ... }, ["en"] = { "Name1", "Name2", ...} } was created
function lib.GetAllDropLocationNames(lang)
    if not checkIfSetsAreLoadedProperly() then return end
    lang = langAllowedCheck(lang)
    return dropLocationNames[lang]
end

--Returns table LibSets.setId2DropLocationNames
function lib.GetDropLocationNamesBySetId(setId, lang)
    if not checkIfSetsAreLoadedProperly(setId) then return end
    if setId == nil or setId2DropLocations[setId] == nil then return end
    lang = langAllowedCheck(lang)
    return setId2DropLocations[setId][lang]
end

--Returns table LibSets.dropLocationNames2SetIds was created.
function lib.GetSetIdsByDropLocationName(dropLocationName, lang)
    if not checkIfSetsAreLoadedProperly() then return end
    lang = langAllowedCheck(lang)
    if dropLocationName == nil or dropLocation2SetIds[lang] == nil then return end
    return dropLocation2SetIds[lang][dropLocationName]
end


--Returns a sorted table of all set ids. Key is the setId, value is the boolean value true.
--Attention: The table can have a gap in it's index as not all setIds are gap-less in ESO!
--> Returns: setIds table
function lib.GetAllSetIds()
    if not checkIfSetsAreLoadedProperly() then return end
    return lib.setIds
end
local lib_GetAllSetIds = lib.GetAllSetIds

--Returns all sets itemIds as table. Key is the setId, value is a subtable with the key=itemId and value = boolean value true.
--> Returns: setItemIds table
function lib.GetAllSetItemIds()
    if not checkIfSetsAreLoadedProperly() then return end
    --Decompress all the setId's itemIds (if not already done before)
    --and create the whole cached table CachedSetItemIdsTable this way
    for setId, isActive in pairs(setIds) do
        if isActive == true then
            decompressSetIdItemIds(setId, false)
        end
    end
    --No ESO setIds
    for nonESOsetId, _ in pairs(noSetIdSets) do
        decompressSetIdItemIds(nonESOsetId, true)
    end
    return CachedSetItemIdsTable
end


--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.
--The key is the itemId and the value is the value LIBSETS_SET_ITEMID_TABLE_VALUE_OK
--If the 2nd to ... parameter *Type is not specified: All  itemIds found for the setId will be returned
--If the 2rd to ... parameter *Type is specified: Each itemId of the setId will be turned into an itemLink where the given *type is cheched against.
--Only the itemIds where the parameters fit will be returned as table. Else the return value will be nil
--> Parameters: setId number: The set's setId
-->             isNoESOSetId boolean: Read the set's itemIds from the special sets table or the normal?
-->             equipType optional number, or table with value = equipType number: The equipType to check the itemId against
-->             traitType optional number, or table with value = traitType number: The traitType to check the itemId against
-->             enchantSearchCategoryType optional number, or table with value = enchantSearchCategory number: The enchanting search category to check the itemId against
-->             armorType optional number, or table with value = armorType number: The armorType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the armorType does not match the equipType the function will return nil)
-->             weaponType optional number, or table with value = weaponType number: The weaponType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the weaponType does not match the equipType the function will return nil))
--> Returns:    table:nilable setItemIds = {[setItemId1]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK,[setItemId2]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK, ...},
-->             table:nilable returnTableData = {[e.g. LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES]={[itemLinkEnchantSearchCategoryType]=boolean, ... }
function lib.GetSetItemIds(setId, isNoESOSetId, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
    if setId == nil then return end
    if armorType ~= nil and weaponType ~= nil then return end

    if not checkIfSetsAreLoadedProperly(setId) then return end
    if isNoESOSetId == nil then
        isNoESOSetId = isNoESOSet(setId)
    end
    local setItemIds = decompressSetIdItemIds(setId, isNoESOSetId)
    if setItemIds == nil then return end
--d("[LibSets]GetSetItemIds-setId: " ..tos(setId) .. " -> found itemIds!")

    --Anything to filter?
    if equipType ~= nil or traitType ~= nil or enchantSearchCategoryType ~= nil or armorType ~= nil or weaponType ~= nil then
        --Return all found itemIds matching the search criteria
        local validItemIds, returnTab = getSetItemIdsFiltered(false, setId, setItemIds, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
        return validItemIds, returnTab
    end
    return setItemIds, nil
end
local lib_GetSetItemIds = lib.GetSetItemIds

--Returns an itemId of the setId, matching the filter criteria passed in as parameters (params 2 to ... can be a single number or a table where the value is the number).
--If the setId got several itemIds this function returns one random itemId of the setId provided (depending on the 2nd parameter equipType)
--If the 2nd to ... parameter *Type is not specified: The first random itemId found will be returned
--If the 2rd to ... parameter *Type is specified: Each itemId of the setId will be turned into an itemLink where the given *type is cheched against.
--Only the itemId where the parameters fits will be returned. Else the return value will be nil
--> Parameters: setId number: The set's setId
-->             isNoESOSetId boolean: Read the set's itemIds from the special sets table or the normal?
-->             equipType optional number, or table with value = equipType number: The equipType to check the itemId against
-->             traitType optional number, or table with value = traitType number: The traitType to check the itemId against
-->             enchantSearchCategoryType optional number, or table with value = enchantSearchCategory number: The enchanting search category to check the itemId against
-->             armorType optional number, or table with value = armorType number: The armorType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the armorType does not match the equipType the function will return nil)
-->             weaponType optional number, or table with value = weaponType number: The weaponType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the weaponType does not match the equipType the function will return nil))
--> Returns:    number:nilable setItemId
function lib.GetSetItemId(setId, isNoESOSetId, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
    --Get all itemIds of the setId
    local setItemIds, _ = lib_GetSetItemIds(setId, isNoESOSetId) --do not filter any itemId here to speed things up -> Filters will be applied further down at return getSetItemIdsFiltered!
    if setItemIds == nil then return end

    --Return the first found itemId matching the search criteria
    local setItemId, _ = getSetItemIdsFiltered(true, setId, setItemIds, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
    return setItemId
end
local libSets_GetSetItemId = lib.GetSetItemId

--Returns the first itemId of a passed in setId
--> Parameters: setId number: The set's setId
-->             isNoESOSetId boolean: Read the set's itemIds from the special sets table or the normal?
-->             equipType optional number, or table with value = equipType number: The equipType to check the itemId against
-->             traitType optional number, or table with value = traitType number: The traitType to check the itemId against
-->             enchantSearchCategoryType optional number, or table with value = enchantSearchCategory number: The enchanting search category to check the itemId against
-->             armorType optional number, or table with value = armorType number: The armorType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the armorType does not match the equipType the function will return nil)
-->             weaponType optional number, or table with value = weaponType number: The weaponType to check the itemId against (Attention: either armorType or weaponType can be specified! If equipType was provided and the weaponType does not match the equipType the function will return nil))
--> Returns:    number setItemId
function lib.GetSetFirstItemId(setId, isNoESOSetId, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
    return libSets_GetSetItemId(setId, isNoESOSetId, equipType, traitType, enchantSearchCategoryType, armorType, weaponType)
end

--Returns the Enchantment search categories of a passed in setId
--> Parameters: setId number: The set's setId
--> Returns:    table:nilable { [enchantSearchCategory] = boolean }
function lib.GetSetEnchantSearchCategories(setId, equipType, traitType, armorType, weaponType)
    if not checkIfSetsAreLoadedProperly(setId) then return end
--d("[LibSets]GetSetEnchantSC-setId: " ..tos(setId))
    local enchantSearchCategoriesOfSetId
    local isNonEsoSetId = isNoESOSet(setId)
    --Does the setData contain the enchantSearchCategories already?
    if isNonEsoSetId == true then
        enchantSearchCategoriesOfSetId = noSetIdSets[setId][LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES]
    else
        enchantSearchCategoriesOfSetId = setInfo[setId][LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES]
    end
    if enchantSearchCategoriesOfSetId ~= nil and not ZO_IsTableEmpty(enchantSearchCategoriesOfSetId) then
        return enchantSearchCategoriesOfSetId
    end

    --Get all itemIds filtered where an enchantSearchCategory is used. 2nd return param will be a table containing a subtable with key LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES
    --which contains the enchantSearchCategories of the setId
    local _, returnTab = lib_GetSetItemIds(setId, isNonEsoSetId, equipType, traitType, "all", armorType, weaponType)
--lib._debugGetSetEnchantSearchCategories = lib._debugGetSetEnchantSearchCategories or {}
--lib._debugGetSetEnchantSearchCategories[setId] = returnTab
    if returnTab == nil or returnTab[LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] == nil then return end
    enchantSearchCategoriesOfSetId = returnTab[LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES]

    --Update the preloaded setData with the enchant search category types, if we did not filter any other criteria -> As we only want to store ALL enchantSearchCategoryTypes at the prelaoded setData!
    if (not equipType and not traitType and not armorType and not weaponType) and not ZO_IsTableEmpty(enchantSearchCategoriesOfSetId) then
        if isNonEsoSetId == true then
            noSetIdSets[setId][LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] = enchantSearchCategoriesOfSetId
        else
            setInfo[setId][LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] = enchantSearchCategoriesOfSetId
        end
    end
    return enchantSearchCategoriesOfSetId
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    lang = langAllowedCheck(lang)
    local setNames = {}
    if allSetNamesCached == nil or allSetNamesCached[setId] == nil or allSetNamesCached[setId][lang] == nil then
        if isNoESOSet(setId) then
            setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
        else
            setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
        end
    else
        setNames =  allSetNamesCached
    end
    if setNames[setId] == nil or setNames[setId][lang] == nil then return end
    return setNames[setId][lang]
end

--Returns all names of the setId as a table
--The table returned uses the key=language (2 characters String e.g. "en") and the value = name String, e.g.
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local setNames = {}
    if allSetNamesCached == nil or allSetNamesCached[setId] == nil then
        if isNoESOSet(setId) then
            setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
        else
            setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
        end
    else
        setNames =  allSetNamesCached
    end
    if setNames[setId] == nil then return end
    return setNames[setId]
end
local lib_GetSetNames = lib.GetSetNames

--Returns all sets names as table.
--The table returned uses the key=setId and value = table of setNames.
--The key in the table of setNames is [language] (2 characters String e.g. "en") and the value = name String, e.g.
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}
--> Returns: setNames table
function lib.GetAllSetNames()
    if not checkIfSetsAreLoadedProperly() then return end
    if allSetNamesCached == nil then
        local setNames = {}
        local allSetIds = lib_GetAllSetIds()
        if not allSetIds then return end
        for setId, isActive in pairs(allSetIds) do
            if isActive == true then
                local setNamesOfSetId = lib_GetSetNames(setId)
                if setNamesOfSetId then
                    setNames[setId] = setNamesOfSetId
                end
            end
        end
        allSetNamesCached = setNames
    end
    return allSetNamesCached
end


--Returns the set info as a table
--> Parameters: setId number: The set's setId,
-->             noItemIds boolean optional: Set this to true if you do not need the itemIds subtable LIBSETS_TABLEKEY_SETITEMIDS in the return table. Dafault will be false
-->             lang String optional: The 2char language String to use for language dependent info. If left nil all supported languages will be returned.
--> Returns:    table setInfo
----> Contains:
----> number setId
----> number dlcId (the dlcId where the set was added, see file LibSets_Constants.lua, constants DLC_BASE_GAME to e.g. DLC_ELSWEYR)
----> tables LIBSETS_TABLEKEY_SETITEMIDS (="setItemIds") (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's item),
----> table names (="setNames") ([2 character String lang] = String name),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> String setType which shows the setType via the LibSets setType constant values like LIBSETS_SETTYPE_ARENA, LIBSETS_SETTYPE_DUNGEON etc. Only 1 setType is possible for each set
----> isVeteran boolean value true if this set can be only obtained in veteran mode, or a table containing the key = equipType and value=boolean true/false if the equipType of the setId cen be only obtained in veteran mode (e.g. a monster set head is veteran, shoulders are normal)
----> isMultiTrial boolean, only if setType == LIBSETS_SETTYPE_TRIAL (setId can be obtained in multiple trials -> see zoneIds table)
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table can contain 1 to 3 entries (one for each faction e.g.) and contains the wayshrineNodeId nearest to the set's crafting table/in the drop zone
----> table zoneIds containing the zoneIds (one to n) where this set drops, or can be obtained
----> table dropMechanic containing a number non-gap key and the LibSetsDropMechanic of the set as value
--->  table dropMechanicNames: The key is the same index as used within table "dropMechanic". And the value is a subtable containing each (or the specified lang parameter) language as key,
--->  and the localized String as the value. dropMechanicNames returns the names of the dropMechanic, e.g. "worldboss", "delve boss", ...
--->  table dropMechanicLocationNames: The key is the same index as used within table "dropMechanic". And the value is a subtable containing each (or the specified lang parameter) language as key.
-----> dropMechanicLocationNames returns the names of the mob/boss/... that drops the setItem, e.g. "Velidreth", "Mob type Daedra", ...
-----> !!!Attention: dropMechanicLocationNames can now apply to all setTypes, not only anymore to monster sets!!!
--->  number isPerfectedSet = LIBSETS_SET_ITEMID_TABLE_VALUE_OK or LIBSETS_SET_ITEMID_TABLE_VALUE_NOTOK,
--->  number perfectedSetId = <setIdOfPerfectedSetBelongingToThisNonPerfectedSetId>
-------Example:
--- optional:["setId"] = 408,
--- optional:["dlcId"] = 12,    --DLC_MURKMIRE
--	optional:[LIBSETS_TABLEKEY_SETTYPE] = LIBSETS_SETTYPE_CRAFTED,
--	optional:[LIBSETS_TABLEKEY_SETITEMIDS] = {
--      table [#0,370]
--  },
--	optional:[LIBSETS_TABLEKEY_SETNAMES] = {
--		["de"] = "Grabpflocksammler"
--		["en"] = "Grave-Stake Collector"
--		["fr"] = "Collectionneur de marqueurs funéraires"
--  },
--	optional:["traitsNeeded"] = 7,
--	optional:["veteran"] = false,
--  optional:["classId"] = 1,
--	optional:["wayshrines"] = {
--		[1] = 375
--		[2] = 375
--		[3] = 375
--  },
--	optional:["zoneIds"] = {
--		[1] = 726,
--  },
--  optional:["dropMechanic"] = {
--      [1] = LIBSETS_DROP_MECHANIC_MONSTER_NAME,
--      [2] = LIBSETS_DROP_MECHANIC_...,
--  },
--  optional:["dropMechanicNames"] = {
--      [1] = {
--        ["en"] = "DropMechanicNameEN",
--          ["de"] = "DropMechanicNameDE",
--          ["fr"] = "DropMechanicNameFR",
--          [...] = "...",
--      },
--      [2] = {
--        ["en"] = "DropMechanic...NameEN",
--        ["de"] = "DropMechanic...NameDE",
--        ["fr"] = "DropMechanic....NameFR",
--        [...] = "...",
--      },
--  },
--  optional:["dropMechanicLocationNames"] = {
--      [1] = {
--        ["en"] = "DropMechanicMonsterNameEN",
--          ["de"] = "DropMechanicMonsterNameDE",
--          ["fr"] = "DropMechanicMonsterNameFR",
--          [...] = "...",
--      },
--      [2] = nil, --as it got no monster or other dropMechanicLocation name,
--  },
--  optional:isPerfectedSet=LIBSETS_SET_ITEMID_TABLE_VALUE_OK,
--  optional:perfectedSetId=<setId>,
--}

--Table to store already processed setIds with boolean -> If true we can directly return setInfoTable without further trying to add data!
local wasSetIdProcessedForSetInfoInTotal = {}
function lib.GetSetInfo(setId, noItemIds, lang)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    noItemIds = noItemIds or false
    local isNonEsoSetId = isNoESOSet(setId)
    local setInfoTable
    local itemIds
    local setNames
    local langToUse
    local setNamesEmpty = true
    local gotSetItemIds =           false
    local gotSetNames =             false
    local gotSetDropMechanicNames = false

    local returnTab

    --local supportedLanguageData
    local onlyOneLanguage = (lang ~= nil and true) or false
    if onlyOneLanguage == true then
        if noItemIds == true then
            local cachedTooltipsSetDataWithoutItemIdsAndOnlyOneLang = tooltipSetDataWithoutItemIdsCached[setId]
            if cachedTooltipsSetDataWithoutItemIdsAndOnlyOneLang ~= nil and not ZO_IsTableEmpty(cachedTooltipsSetDataWithoutItemIdsAndOnlyOneLang) then
                return cachedTooltipsSetDataWithoutItemIdsAndOnlyOneLang
            end
        end

        langToUse = langAllowedCheck(lang)
    end
    --[[
    if onlyOneLanguage == true then
        langToUse = lang
        supportedLanguageData = supportedLanguages[langToUse]
        if not supportedLanguageData and lang ~= fallbackLang then
            langToUse = fallbackLang
            supportedLanguageData = supportedLanguages[langToUse]
        end
    end
    ]]

    --Get the set's itemIds and name's table keys, and get the setData then
    local preloadedSetItemIdsTableKey = LIBSETS_TABLEKEY_SETITEMIDS
    local preloadedSetNamesTableKey = LIBSETS_TABLEKEY_SETNAMES
    if isNonEsoSetId == true then
        setInfoTable = noSetIdSets[setId]
        preloadedSetItemIdsTableKey = LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID
        preloadedSetNamesTableKey = LIBSETS_TABLEKEY_SETNAMES_NO_SETID
    else
        if setInfo[setId] == nil then return end
        setInfoTable = setInfo[setId]
    end
    if setInfoTable == nil then return end
    setInfoTable["setId"] = setId

    --Did we already process this setData before in total
    if not wasSetIdProcessedForSetInfoInTotal[setId] then

        --Update itemIds at the setInfo data (if missing and we want itemIds to be returned too)
        if not noItemIds then
            if setInfoTable[LIBSETS_TABLEKEY_SETITEMIDS] == nil then
                if isNonEsoSetId == true then
                    itemIds = preloaded[preloadedSetItemIdsTableKey][setId]
                else
                    itemIds = decompressSetIdItemIds(setId)
                end
                if not ZO_IsTableEmpty(itemIds) then
                    setInfoTable[LIBSETS_TABLEKEY_SETITEMIDS] = itemIds
                    gotSetItemIds = true
                end
            end
        else
            gotSetItemIds = false
        end

        --Get the drop dropMechanicNames and dropLocationNames -- If missing
        if setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] == nil or setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] == nil then
            local gotSetDropMechanicData = false
            local gotSetDropMechanicLocationData = false

            local dropMechanicNamesTable, dropMechanicDropLocationNamesTable = getDropMechanicAndDropLocationNames(setId, langToUse, setInfoTable)
            if not ZO_IsTableEmpty(dropMechanicNamesTable) then
                setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] = dropMechanicNamesTable
                gotSetDropMechanicData = true
            end
            if not ZO_IsTableEmpty(dropMechanicDropLocationNamesTable) then
                setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] = dropMechanicDropLocationNamesTable
                gotSetDropMechanicLocationData = true
            end
            if gotSetDropMechanicData == true and gotSetDropMechanicLocationData == true then
                gotSetDropMechanicNames = true
            end
        else
            gotSetDropMechanicNames = true
        end

        --Update only 1 language?
        if onlyOneLanguage == true then
            local setNameInLang = preloaded[preloadedSetNamesTableKey][setId] ~= nil and preloaded[preloadedSetNamesTableKey][setId][langToUse]
            if setNameInLang ~= nil then
                setNames = {
                    [langToUse] = setNameInLang
                }
            end
        else
            setNames = preloaded[preloadedSetNamesTableKey][setId]
        end

        setNamesEmpty = ZO_IsTableEmpty(setNames)
        if not setNamesEmpty then
            if not onlyOneLanguage then
                setInfoTable[LIBSETS_TABLEKEY_SETNAMES] = setNames
                gotSetNames = true
            end
        end

        --Everything found and updated to setInfotab once?
        if gotSetItemIds == true and gotSetDropMechanicNames == true and gotSetNames == true then
            --Mark this setId as update so we can directly read it's data from lib.setInfo/lib.noSetIdSets on next call to this function with this setId
            wasSetIdProcessedForSetInfoInTotal[setId] = true
        end

    end   --if not wasSetIdProcessedForSetInfoInTotal[setId] then

    --Check the isCurrentDLC data
    if setInfoTable.isCurrentDLC == nil then
        local isCurrentDLC = (DLC_ITERATION_END ~= nil and setInfoTable["dlcId"] ~= nil and setInfoTable["dlcId"] >= DLC_ITERATION_END) or false
        setInfoTable.isCurrentDLC = isCurrentDLC
    end

    --Copy the return table so that we cannot accidently directly change LibSets.setInfo[setId] by changing the return table!!!
    --Also: lib.setInfo[setId]["setNames"]["en"] will be overwritten as function lib.GetSetInfo is called and passing in ONLY 1 language!
    --So we need to assure that original setInfoTable[LIBSETS_TABLEKEY_SETNAMES] is not manipulated!
    returnTab = ZO_ShallowTableCopy(setInfoTable)

    --Only now check if itemIds are needed "in the copied return table" (but kep them in the original LibSets.setInfo[setId] !!!
    if noItemIds == true then
        returnTab[LIBSETS_TABLEKEY_SETITEMIDS] = nil
    end

    --SetNames
    if not setNamesEmpty and onlyOneLanguage == true then
        returnTab[LIBSETS_TABLEKEY_SETNAMES] = setNames
        if noItemIds == true then
            --Cache the setsData (without itemIds and only 1 language) at the tooltipsCache
            tooltipSetDataWithoutItemIdsCached[setId] = returnTab
        end
    end

    return returnTab
end
getSetInfo = lib.GetSetInfo

--Returns the possible armor types's of a set
--> Parameters: setId number: The set's id
--> Returns:    table armorTypesOfSet: Contains all armor types possible as key and the Boolean value
-->             true/false if this setId got items of this armorType
function lib.GetSetArmorTypes(setId)
    local armorTypesOfSet = {}
    if not lib.armorTypeNames then return end
   --[[
    --Get all itemIds of this set
    local setItemIds = lib.GetSetItemIds(setId)
    if not setItemIds then return false end
    --Build an itemLink from the itemId
    for itemId, _ in pairs(setItemIds) do
        local itemLink = buildItemLink(itemId)
        if itemLink then
            --Scan each itemId and get the armor type.
            local armorTypeOfSetItem = GetItemLinkArmorType(itemLink)
            if armorTypeOfSetItem and armorTypeOfSetItem ~= ARMORTYPE_NONE then
                if not armorTypesOfSet[armorTypeOfSetItem] then
                    armorTypesOfSet[armorTypeOfSetItem] = true
                end
            end
        end
    end
    ]]
    --Use preloaded data now
    for armorType,_ in pairs(lib.armorTypeNames) do
        local armorTypeData = lib.armorTypesSets[armorType]
        if armorTypeData ~= nil then
            armorTypesOfSet[armorType] = armorTypeData[setId] or false
        end
    end
    --If it's not already added to the armorTypesOfSet table add it
    --Return the armorTypesOfSet table
    return armorTypesOfSet
end

--Returns the armor types's name
--> Parameters: armorType ESOArmorType: The ArmorType (https://wiki.esoui.com/Globals#ArmorType)
--> Returns:    String armorTypeName: The name fo the armor type in the current client's language
function lib.GetArmorTypeName(armorType)
    if armorType == ARMORTYPE_NONE then return end
    local armorTypeNames = lib.armorTypeNames
    if not armorType or not armorTypeNames then return end
    local armorTypeName = armorTypeNames[armorType]
    return armorTypeName
end

--Returns the armor types of a set's item
--> Parameters: itemId number: The set item's itemId
--> Returns:    number armorTypeOfSetItem: The armorType (https://wiki.esoui.com/Globals#ArmorType) of the setItem
function lib.GetItemsArmorType(itemId)
    --Build an itemLink from the itemId
    local itemLink = buildItemLink(itemId)
    if itemLink then
        --Scan each itemId and get the armor type.
        local armorTypeOfSetItem = GetItemLinkArmorType(itemLink)
        if armorTypeOfSetItem and armorTypeOfSetItem ~= ARMORTYPE_NONE then
            return armorTypeOfSetItem
        end
    end
    return nil
end

--Returns the possible weapon types's of a set
--> Parameters: setId number: The set's id
--> Returns:    table weaponTypesOfSet: Contains all weapon types possible as key and the Boolean value
-->             true/false if this setId got items of this weaponType
function lib.GetSetWeaponTypes(setId)
    local weaponTypesOfSet = {}
    if not lib.weaponTypeNames then return end
    --[[
    --Get all itemIds of this set
    local setItemIds = lib.GetSetItemIds(setId)
    if not setItemIds then return false end
    --Build an itemLink from the itemId
    for itemId, _ in pairs(setItemIds) do
        local itemLink = buildItemLink(itemId)
        if itemLink then
            --Scan each itemId and get the weapon type.
            local weaponTypeOfSetItem = GetItemLinkWeaponType(itemLink)
            if weaponTypeOfSetItem and weaponTypeOfSetItem ~= WEAPONTYPE_NONE then
                if not weaponTypesOfSet[weaponTypeOfSetItem] then
                    weaponTypesOfSet[weaponTypeOfSetItem] = true
                end
            end
        end
    end
    ]]
    --Use preloaded data now
    for weaponType,_ in pairs(lib.weaponTypeNames) do
        local weaponTypeData = lib.weaponTypesSets[weaponType]
        if weaponTypeData ~= nil then
            weaponTypesOfSet[weaponType] = weaponTypeData[setId] or false
        end
    end
    --If it's not already added to the weaponTypesOfSet table add it
    --Return the weaponTypesOfSet table
    return weaponTypesOfSet
end

--Returns the weapon types of a set's item
--> Parameters: itemId number: The set item's itemId
--> Returns:    number weaponTypeOfSetItem: The weaponType (https://wiki.esoui.com/Globals#WeaponType) of the setItem
function lib.GetItemsWeaponType(itemId)
    --Build an itemLink from the itemId
    local itemLink = buildItemLink(itemId)
    if itemLink then
        --Scan each itemId and get the weapon type.
        local weaponTypeOfSetItem = GetItemLinkWeaponType(itemLink)
        if weaponTypeOfSetItem and weaponTypeOfSetItem ~= WEAPONTYPE_NONE then
            return weaponTypeOfSetItem
        end
    end
    return nil
end

--Check if any item within the table "setsItemIds", are currently equipped, and count the number of them.
--> Parameters: setsItemIds table: The itemIds that need to be chedked in addition to the itemId parameter
-->The tables key must be the itemId and the value a boolean value e.g.
-->Example setsItemIds = { [123456]=true, [12678]=true, ... }
--> Returns: equippedItems number
function lib.GetNumEquippedItemsByItemIds(setsItemIds)
    if not setsItemIds then return 0 end
    local equippedItems = 0
    --Get the equipped item's data
    local equippedItemsIds = {}
    --Get the itemIds of the equipped items in BAG_WORN
    local bagWornItemCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_WORN)
    for _, data in pairs(bagWornItemCache) do
        tins(equippedItemsIds, data.slotIndex)
    end
    if equippedItemsIds and #equippedItemsIds > 0 then
        --Compare equipped item's itemIds with the given non ESO set itemIds
        for _, equippedItemSlot in pairs(equippedItemsIds) do
            local wornItemId = tonumber(GetItemId(BAG_WORN, equippedItemSlot))
            if wornItemId ~= nil and setsItemIds[wornItemId] ~= nil then
                equippedItems = equippedItems +1
            end
        end
    end
    return equippedItems
end

--Check if any item of the setId specified is currently equipped and return the number of the equipped, and the maximum
--equipped number of items of this set.
--> Parameters: setId number: The setId
--> Returns:
-->          equippedItems number Number of currently equipped items of this setId
-->          maxEquipped number Number of maximum equipped items of this setId
-->          itemId number The itemId of an example item of the setId
function lib.GetNumEquippedItemsBySetId(setId)
    if not setId then return nil, nil, nil end
    --Get any itemId of the setId
    local itemId = lib.GetSetItemId(setId)
    local setIdRet, equippedItems, maxEquipped, _ = getSetEquippedInfo(itemId)
    if not setIdRet then return nil, nil, nil end
    return equippedItems, maxEquipped, itemId
end

--Check if any item of the itemId specified is currently equipped and return the setId, the number of the equipped, and
--the maximum equipped number of items of this set.
--> Parameters: itemId number: The itemId of any set's item
--> Returns:
-->          equippedItems number Number of currently equipped items of this setId
-->          maxEquipped number Number of maximum equipped items of this setId
-->          setId number The setId of the itemId specified
function lib.GetNumEquippedItemsByItemId(itemId)
    if not itemId then return nil, nil, nil end
    --Get any itemId of the setId
    local setIdRet, equippedItems, maxEquipped, _ = getSetEquippedInfo(itemId)
    if not setIdRet then return nil, nil, nil end
    return equippedItems, maxEquipped, setIdRet
end


--Returns the possible equip types's of a set
--> Parameters: setId number: The set's id
--> Returns:    table equipTypesOfSet: Contains all equip types possible as key and the Boolean value
-->             true/false if this setId got items of this equipType
function lib.GetSetEquipTypes(setId)
    local equipTypesOfSet = {}
    if not lib.equipTypesValid then return end
    --Use preloaded data now
    for equipType,_ in pairs(lib.equipTypesValid) do
        local equipTypeData = lib.weaponTypesSets[equipType]
        if equipTypeData ~= nil then
            equipTypesOfSet[equipType] = equipTypeData[setId] or false
        end
    end
    --Return the equipTypesOfSet table
    return equipTypesOfSet
end


--Returns the id number of the set name provided
--> Parameters: setName String: The set's name
--> lang String: The language to check for. Can be left empty and the client language will be used then
--> Returns:  NILABLE number setId, NILABLE table setNames
function lib.GetSetByName(setName, lang)
    if not checkIfSetsAreLoadedProperly() then return end
    lang = langAllowedCheck(lang)
    local setNamesNonESO = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
    local setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
    for setId, namesOfSets in pairs(setNames) do
        local setNameInLanguageToSearch = namesOfSets[lang]
        if setNameInLanguageToSearch ~= nil and setNameInLanguageToSearch == setName then
            return setId, namesOfSets
        end
    end
    for setId, namesOfSetsNonESO in pairs(setNamesNonESO) do
        local setNameNonESOInLanguageToSearch = namesOfSetsNonESO[lang]
        if setNameNonESOInLanguageToSearch ~= nil and setNameNonESOInLanguageToSearch == setName then
            return setId, namesOfSetsNonESO
        end
    end
    return nil
end

--Returns the bonus description text of a set itemlink, as a table (each bonus description text = 1 table entry)
--> Parameters: itemLink String: The set item's itemlink
--> Returns:  NILABLE table bonuses
function lib.GetSetBonuses(itemLink, numBonuses)
    local bonuses
    if numBonuses > 0 then
        bonuses = { }
        for i = 1, numBonuses do
            local _, description = GetItemLinkSetBonusInfo(itemLink, false, i)
            table.insert(bonuses, description)
        end
    else
        -- Arena weapons are not sets, use the enchantment description instead
        local _, _, description = GetItemLinkEnchantInfo(itemLink)
        bonuses = { description }
    end
    return bonuses
end

--Returns table with setData for all sets that are class sets and match the classId specified
--> Parameters: classId number:optional A class's Id
--> Returns:    table setsInfo
function lib.GetClassSets(classId)
    if classId == nil then return end
    if not checkIfSetsAreLoadedProperly() then return end
    return getSetsOfClassId(classId)
end

--Returns a table of setIds where the set is a class specific one
--> Returns:    classSets table
function lib.GetAllClassSets()
    if not checkIfSetsAreLoadedProperly() then return false end
    return lib.classSets
end


------------------------------------------------------------------------
-- 	Global set misc. functions
------------------------------------------------------------------------
--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil or setInfo[setId] == nil or setInfo[setId][LIBSETS_TABLEKEY_WAYSHRINES] == nil then return false end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    --Then use the faction Id 1 (AD), 2 (DC) to 3 (EP)
    factionIndex = factionIndex or 1
    if factionIndex < 1 or factionIndex > 3 then factionIndex = 1 end
    local jumpToNode = -1
    local setWayshrines
    if isNoESOSet(setId) then
        setWayshrines = setInfo[setId][LIBSETS_TABLEKEY_WAYSHRINES]
    else
        setWayshrines = noSetIdSets[setId][LIBSETS_TABLEKEY_WAYSHRINES]
    end
    if setWayshrines == nil then return false end
    jumpToNode = setWayshrines[factionIndex]
    --Jump now?
    if jumpToNode and jumpToNode > 0 then
        FastTravelToNode(jumpToNode)
        return true
    end
    return false
end

------------------------------------------------------------------------
-- 	Global other get functions
------------------------------------------------------------------------
--Returns the name of the DLC by help of the DLC id
--> Parameters: dlcId number: The DLC id given in a set's info
--> Returns:    name dlcName
function lib.GetDLCName(dlcId)
    if not DLCandCHAPTERdata then return end
    local dlcName = DLCandCHAPTERdata[dlcId] or NONDLCData[dlcId] or ""
    return dlcName
end

--Returns the name of the DLC by help of the DLC id
--> Parameters: undauntedChestId number: The undaunted chest id given in a set's info
--> Returns:    name undauntedChestName
function lib.GetUndauntedChestName(undauntedChestId, lang)
    if undauntedChestId < 1 or undauntedChestId > lib.countUndauntedChests then return end
    lang = langAllowedCheck(lang)
    if not undauntedChestIds or not undauntedChestIds[lang] or not undauntedChestIds[lang][undauntedChestId] then return end
    local undauntedChestNameLang = undauntedChestIds[lang]
    --Fallback language "EN"
    if not undauntedChestNameLang then undauntedChestNameLang = undauntedChestIds["en"] end
    return undauntedChestNameLang[undauntedChestId]
end


--Returns the name of the zone by help of the zoneId, if the zoneId is 0 or below
--> Parameters: zoneIdEqualsOrBelowZero number: The zone id given in a set's info
-->             lang String the language for the zone name. Can be left nil -> The client language will be used then
--> Returns:    name zoneNameSpecial
function lib.GetSpecialZoneNameById(zoneIdEqualsOrBelowZero, lang)
    if zoneIdEqualsOrBelowZero == nil then return end
    lang = langAllowedCheck(lang)
    local specialZoneNames = lib.specialZoneNames[lang]
    if specialZoneNames == nil then return end
    return specialZoneNames[zoneIdEqualsOrBelowZero]
end
local libSets_GetSpecialZoneNameById =  lib.GetSpecialZoneNameById

--Returns the name of the zone by help of the zoneId
--> Parameters: zoneId number: The zone id given in a set's info
-->             language String: ONLY possible to be used if additional library "LibZone" (https://www.esoui.com/downloads/info2171-LibZone.html) is activated
--> Returns:    name zoneName
function lib.GetZoneName(zoneId, lang)
    if not zoneId then return end
    lang = langAllowedCheck(lang)
    local zoneName = ""
    if zoneId > LIBSETS_SPECIAL_ZONEID_ALLZONES_OF_TAMRIEL then
        if libZone ~= nil then
            zoneName = libZone:GetZoneName(zoneId, lang)
        else
            zoneName = zocstrfor("<<C:1>>", gznbid(zoneId) )
        end
    else
        zoneName = libSets_GetSpecialZoneNameById(zoneId, lang)
    end
    return zoneName
end
local getZoneName = lib.GetZoneName

--Returns the name of the current zone's zoneId, and the parentZone's name
--> Parameters: language String: ONLY possible to be used if additional library "LibZone" (https://www.esoui.com/downloads/info2171-LibZone.html) is activated
--> Returns:    name zoneName, name parentZoneName
function lib.GetCurrentZoneName(lang)
    getCurrentZoneIds = getCurrentZoneIds or lib.GetCurrentZoneIds
    local currentZoneId, currentZoneParentId, currentZoneIndex, currentZoneParentIndex = getCurrentZoneIds()
    if currentZoneId == nil and currentZoneParentId ~= nil then
        currentZoneId = currentZoneParentId
    end
    local currentZoneName = getZoneName(currentZoneId, lang)
    local currentParentZoneName = currentZoneName
    if currentZoneId ~= currentZoneParentId then
        currentParentZoneName = getZoneName(currentZoneParentId, lang)
    end
    return currentZoneName, currentParentZoneName
end



--[[
[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] = {
        [638]={parentZoneId=888,isTrial=true},   --Aetherian Archive
]]
--Returns a boolean isZoneIdADungeon by the help of a zoneId
--> Parameters: zoneId number: The zone id given
--> Returns:    boolean isZoneIdADungeon
function lib.IsDungeonZoneId(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] == nil then return false end
    return (preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId] ~= nil and true) or false
end
isDungeonZoneId = lib.IsDungeonZoneId

--Returns a table dungeonZoneData by the help of a zoneId
--> Parameters: zoneId number: The zone id given
--> Returns:    table:nilable dungeonZoneData = { parentZoneId=number,isTrial=boolean }
function lib.GetDungeonZoneData(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] == nil then return end
    return preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId]
end

--Returns boolean isZoneIdATrialDungeon. If the zoneId is no dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
--> Returns:    boolean:nilable isZoneIdATrialDungeon
function lib.IsDungeonZoneIdTrial(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    return preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId]["isTrial"]
end
isDungeonZoneIdTrial = lib.IsDungeonZoneIdTrial

--Returns boolean isTrial of zoneId. If the zoneId is no dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
--> Returns:    boolean:nilable isTrial
function lib.GetDungeonZoneIdIsTrial(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    return preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId]["isTrial"]
end

--Returns number parentZoneId. If the zoneId is no dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
--> Returns:    number:nilable parentZoneId
function lib.GetDungeonZoneIdParentZoneId(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    return preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING][zoneId]["parentZoneId"]
end


--Returns a table of zoneIds which are a dungeon
--> Returns:    dungeonZoneIdData table = { [zoneIdOfDungeon] = { parentZoneId=number, isTrial=boolean }, ... }
function lib.GetAllDungeonZoneIdData()
    return preloaded[LIBSETS_TABLEKEY_DUNGEON_ZONE_MAPPING]
end


--[[
[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] = {
        [638]={parentZoneId=xxx, DLCID=DLC_xxx},   --Public dungeon name
]]
--Returns a boolean isZoneIdAPublicDungeon by the help of a zoneId
--> Parameters: zoneId number: The zone id given
--> Returns:    boolean isZoneIdAPublicDungeon
function lib.IsPublicDungeonZoneId(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] == nil then return false end
    return (preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId] ~= nil and true) or false
end
isPublicDungeonZoneId = lib.IsPublicDungeonZoneId

--Returns a table publicDungeonZoneData by the help of a zoneId
--> Parameters: zoneId number: The zone id given
--> Returns:    table:nilable publicDungeonZoneData = { parentZoneId=number, DLCID=DLC_xxx constant number }
function lib.GetPublicDungeonZoneData(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] == nil then return end
    return preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId]
end

--Returns boolean isZoneIdAPublicDungeonOfDLCId. If the zoneId is no public dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
-->             DLCId number constant DLC_xxx
--> Returns:    boolean:nilable isZoneIdAPublicDungeonOfDLCId
function lib.IsPublicDungeonZoneIdDLCId(zoneId, DLCId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    local DLCIdOfZoneId = preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId]["DLCId"]
    return (DLCIdOfZoneId ~= nil and DLCIdOfZoneId == DLCId and true) or false
end

--Returns number constant DLC_xxx DLCId of zoneId. If the zoneId is no public dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
--> Returns:    DLC_xxx:nilable DLCIdOfPublicDungeonZoneId
function lib.GetPublicDungeonZoneIdDLCId(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    return preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId]["DLCId"]
end

--Returns number parentZoneId. If the zoneId is no public dungeon the return value will be nil
--> Parameters: zoneId number: The zone id given
--> Returns:    number:nilable parentZoneId
function lib.GetPublicDungeonZoneIdParentZoneId(zoneId)
    if zoneId == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING] == nil or preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId] == nil then return nil end
    return preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING][zoneId]["parentZoneId"]
end

--Returns a table of zoneIds which are a dungeon
--> Returns:    publicDungeonZoneIdData table = { [zoneIdOfPublicDungeon] = { parentZoneId=number, DLCID=DLC_xxx constant number }, ... }
function lib.GetAllPublicDungeonZoneIdData()
    return preloaded[LIBSETS_TABLEKEY_PUBLICDUNGEON_ZONE_MAPPING]
end


--Returns the set data (setType number, setIds table, itemIds table, setNames table) for the specified LibSets setType
--Parameters: setType number. Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_ConstantsLibraryInternal.lua,
--            e.g. LIBSETS_SETTYPE_MONSTER
--> Returns:    table with key = setId, value = table which contains (as example for setType = LIBSETS_SETTYPE_CRAFTED)
---->             [LIBSETS_TABLEKEY_SETTYPE] = LIBSETS_SETTYPE_CRAFTED ("Crafted")
------>             1st subtable with key LIBSETS_TABLEKEY_SETITEMIDS ("setItemIds") containing a pair of [itemId]= 1 (e.g. [12345]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK,)
------>             2nd subtable with key LIBSETS_TABLEKEY_SETNAMES ("setNames") containing a pair of [language] = "Set name String" (e.g. ["en"]= Crafted set name 1",)
---             Example:
---             [setId] = {
---                 setType = LIBSETS_SETTYPE_CRAFTED,
---                 [LIBSETS_TABLEKEY_SETITEMIDS] = {
---                     [itemId1]=true,
---                     [itemId2]=true
---                 },
---                 [LIBSETS_TABLEKEY_SETNAMES] = {
---                     ["de"]="Set name German",
---                     ["en"]="Set name English",
---                     ["fr"]="Set name French",
---                 },
---             }
function lib.GetSetTypeSetsData(setType)
    local setsData = getSetTypeSetsData(setType)
    return setsData
end


------------------------------------------------------------------------
-- 	Global LibAddonMenu helper functions
------------------------------------------------------------------------
--Returns 3 tables for a libAddonMenu-2.0 dropdown widget:
--table choices
--table choicesValues
--table choicesValuesTooltip
function lib.GetSupportedLanguageChoices()
    return supportedLanguageChoices, supportedLanguageChoicesValues, supportedLanguageChoicesTooltips
end


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Item set collections functions
------------------------------------------------------------------------
--Returns string itemSetCollectionKey "setId:itemSetCollectionSlotId" of the itemLink
--identifying a set item by setId and the equipment slot (e.g. hands, chest, ...) which potentially could have different
--itemIds
function lib.GetItemSetCollectionsSlotKey(itemLink)
    if not itemLink then return nil end
    local setId = select(6, gilsi(itemLink))
    if not setId or setId <= 0 then
        return
    end
    local itemSetCollectionSlot = giliscs(itemLink)
    if not itemSetCollectionSlot or itemSetCollectionSlot == "" then return end
    return strfor("%d:%s", setId, id64tos(itemSetCollectionSlot))
end


--Get the current map's zoneIndex and via the index get the zoneId, the parent zoneId, and return them
--+ the current zone's index and parent zone index
--> Returns: number currentZoneId, number currentZoneParentId, number currentZoneIndex, number currentZoneParentIndex
function lib.GetCurrentZoneIds()
    --If we are in a Battleground: Return the custom zoneId of LibSets
    if IsActiveWorldBattleground() then
        return LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS, LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS, LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS, LIBSETS_SPECIAL_ZONEID_BATTLEGROUNDS
    end
    --All other zones
    local currentZoneIndex = gcmzidx()
    local currentZoneId = gzid(currentZoneIndex)
    local currentZoneParentId = gpzid(currentZoneId)
    local currentZoneParentIndex = gzidx(currentZoneParentId)
    return currentZoneId, currentZoneParentId, currentZoneIndex, currentZoneParentIndex
end
getCurrentZoneIds = lib.GetCurrentZoneIds


--Returns the complete mapping table between set item collections parentCategory, category and zoneIds
--> See file LibSets_Data_All.lua, table lib.setDataPreloaded[LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING]
local preloadedSetItemCollectionMappingToZoneCopy
function lib.GetItemSetCollectionToZoneIds()
    preloadedSetItemCollectionMappingToZoneCopy = preloadedSetItemCollectionMappingToZoneCopy or ZO_ShallowTableCopy(preloaded[LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING])
    return preloadedSetItemCollectionMappingToZoneCopy
end

--Returns the zoneIds (table) which are linked to a item set collection's categoryId
--Not all categories are connected to a zone though! The result will be nil in these cases.
--Example return table: {148}
function lib.GetItemSetCollectionZoneIds(categoryId)
    if not checkIfSetsAreLoadedProperly() then return end
    if categoryId == nil then return end
    if lib.setItemCollectionCategory2ZoneId[categoryId] then
        return lib.setItemCollectionCategory2ZoneId[categoryId]
    end
    return
end
local getItemSetCollectionZoneIds = lib.GetItemSetCollectionZoneIds

--Returns the categoryIds (table) which are linked to a item set collection's zoneId
--Not all zoneIds are connected to a category though! The result will be nil in these cases.
--Example return table: {39}
function lib.GetItemSetCollectionCategoryIds(zoneId)
    if not checkIfSetsAreLoadedProperly() then return end
    if zoneId == nil then return end
    if lib.setItemCollectionZoneId2Category[zoneId] ~= nil then
        return lib.setItemCollectionZoneId2Category[zoneId]
    end
    return
end
local getItemSetCollectionCategoryIds = lib.GetItemSetCollectionCategoryIds

--Returns the parent category data (table) containing the zoneIds, and possible boolean parameters
--isDungeon, isArena, isTrial of ALL categoryIds below this parent -> See file LibSets_data_all.lua ->
--table lib.setDataPreloaded -> table key LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING
--Example return table: { parentCategory=5, category=39, zoneIds={148}, isDungeon=true},--Arx Corinium
function lib.GetItemSetCollectionParentCategoryData(parentCategoryId)
    if not checkIfSetsAreLoadedProperly() then return end
    if parentCategoryId == nil then return end
    local parentCategorySubCategories = lib.setItemCollectionParentCategories[parentCategoryId]
    if parentCategorySubCategories then
        return parentCategorySubCategories
    end
    return
end

--Returns the category data (table) containing the zoneIds, and possible boolean parameters
--isDungeon, isArena, isTrial -> See file LibSets_data_alllua -> table lib.setDataPreloaded ->
--table key LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING
--Example return table: { parentCategory=5, category=39, zoneIds={148}, isDungeon=true},--Arx Corinium
function lib.GetItemSetCollectionCategoryData(categoryId)
    if not checkIfSetsAreLoadedProperly() then return end
    if categoryId == nil then return end
    if lib.setItemCollectionCategories[categoryId] then
        return lib.setItemCollectionCategories[categoryId]
    end
    return
end
local getItemSetCollectionCategoryData = lib.GetItemSetCollectionCategoryData


local function getItemSetCollectionUnlockedAndTotal(zoneId)
    local sumNumUnlocked = 0
    local sumNumTotal = 0
    local categoryIds = getItemSetCollectionCategoryIds(zoneId)
    if not categoryIds or type(categoryIds) ~= "table" then return nil, nil end
    for _, categoryId in ipairs(categoryIds) do
        local categoryData = ISCDM:GetItemSetCollectionCategoryData(categoryId)
        if categoryData == nil then return nil, nil end
        local numUnlocked, numTotal = categoryData:GetNumUnlockedAndTotalPieces()
        sumNumUnlocked = sumNumUnlocked + numUnlocked
        sumNumTotal = sumNumTotal + numTotal
    end
    return sumNumUnlocked, sumNumTotal
end

--Get the number of unlocked and total itemSetCollection pieces in a categoryId (categoryId needs to be the categoryId of
--the Item Set Collections UI, see mapping table at file LibSets_Data_All.lua ->
--number categoryId The zone's categoryId
--returns number sumNumUnlocked, number sumNumTotal
function lib.GetNumItemSetCollectionCategoryUnlockedPieces(categoryId)
    if not categoryId then return nil, nil end
    local zoneIdsOfCategory = getItemSetCollectionZoneIds(categoryId)
    local sumNumUnlocked, sumNumTotal
    for _, zoneId in ipairs(zoneIdsOfCategory) do
        local numUnlockedOfZone, numTotalOfZone = getItemSetCollectionUnlockedAndTotal(zoneId)
        sumNumUnlocked = sumNumUnlocked + numUnlockedOfZone
        sumNumTotal = sumNumTotal + numTotalOfZone
    end
    return sumNumUnlocked, sumNumTotal
end


--Get the number of unlocked and total itemSetCollection pieces in a zoneId
--number zoneId The zone's ID
--returns number sumNumUnlocked, number sumNumTotal
function lib.GetNumItemSetCollectionZoneUnlockedPieces(zoneId)
    if not zoneId or zoneId == 0 then return nil, nil end
    return getItemSetCollectionUnlockedAndTotal(zoneId)
end


--Open a node in the item set collections book for teh given category data table
-->the table categoryData must be determined via lib.GetItemSetCollectionCategoryData before
-->categoryData.parentId must be given and > 0! categoryData.category can be nil or <= 0, then the parentId will be shown
local openItemSetCollectionBookOfCategoryData
function lib.OpenItemSetCollectionBookOfCategoryData(categoryData)
    if not checkIfSetsAreLoadedProperly() then return end
    openItemSetCollectionBookOfCategoryData = openItemSetCollectionBookOfCategoryData or lib.OpenItemSetCollectionBookOfCategoryData
    if not categoryData or type(categoryData) ~= "table"
            or categoryData.parentCategory == nil or categoryData.parentCategory <= 0 then
        return
    end
    if SCENE_MANAGER.currentScene.name ~= "itemSetsBook" then
        MAIN_MENU_KEYBOARD:ToggleSceneGroup("collectionsSceneGroup", "itemSetsBook")
    end
    local categoryTree = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD.categoryTree
    if not categoryTree then return end
    --How to get the node control ZO_ItemSetsBook_Keyboard_TopLevelCategoriesScrollChildZO_TreeStatusLabelSubCategory14.node
    --Scan all entries in ITEM_SET_COLLECTIONS_BOOK_KEYBOARD.categoryTree.nodes.dataEntry.data somehow?
    --Or via categoryTree:GetTreeNodeByData or categoryTree:GetTreeNodeInTreeByData? Might not work as the equalityFunction
    --which GetTreeNodeInTreeByData uses only checks via GetId() function
    --
    --From the categoryTree, by help of the parentCategory and the categoryId:
    -->loop over categoryTree.rootNode.children
    --->local parentCategoryData = categoryTree.rootNode.children[n].data.dataSource.categoryId == categoryData.parentCategory
    --->select subCategory from the parentCategory: parentCategoryData.children.data.dataSource.categoryId == categoryData.category
    ---->nodeToOpen = parentCategoryData.children.data.node
    local nodeToOpen --= ZO_ItemSetsBook_Keyboard_TopLevelCategoriesScrollChildZO_TreeStatusLabelSubCategory14.node
    local parentCategoryIdToFind = categoryData.parentCategory
    local categoryIdToFind = categoryData.category
    local parentCategories = categoryTree.rootNode.children
    --Nothing found? Try again after 250ms
    if not parentCategories then
        zo_callLater(function()
            return openItemSetCollectionBookOfCategoryData(categoryData)
        end, 250)
        return
    end
    for _, parentCategoryData in pairs(parentCategories) do
        if nodeToOpen == nil then
            if parentCategoryData.data and parentCategoryData.data.dataSource and parentCategoryData.data.dataSource.categoryId
                    and parentCategoryData.data.dataSource.categoryId == parentCategoryIdToFind then
                --No subCategory given?
                if categoryIdToFind == nil or categoryIdToFind <= 0 then
                    --return the node of the parentCategory
                    nodeToOpen = parentCategoryData.data.node
                    break
                else
                    --Search for the correct subCategory
                    for _, subCategoryData in pairs(parentCategoryData.children) do
                        if nodeToOpen == nil then
                            if subCategoryData.data and subCategoryData.data.dataSource and subCategoryData.data.dataSource.categoryId
                                    and subCategoryData.data.dataSource.categoryId == categoryIdToFind then
                                nodeToOpen = subCategoryData.data.node
                                break
                            end
                        end
                    end
                end
            end
        else
            break
        end
    end
    if nodeToOpen == nil then return end
    if categoryTree.selectedNode == nodeToOpen then return true end
    categoryTree:SelectNode(nodeToOpen)
    return (categoryTree.selectedNode == nodeToOpen) or false
end
openItemSetCollectionBookOfCategoryData = lib.OpenItemSetCollectionBookOfCategoryData


--Local helper function to open the categoryData of a categoryId in the item set collections book UI
local function openItemSetCollectionBookOfZoneCategoryData(categoryId)
    local itemSetCollectionCategoryDataOfParentZone = getItemSetCollectionCategoryData(categoryId)
    if not itemSetCollectionCategoryDataOfParentZone then return end
    local retVar = openItemSetCollectionBookOfCategoryData(itemSetCollectionCategoryDataOfParentZone)
    return retVar
end

local function openItemSetCollectionsBookOfZoneId(zoneId)
    local categoryIdsOfZone = getItemSetCollectionCategoryIds(zoneId)
    if not categoryIdsOfZone or type(categoryIdsOfZone) ~= "table" then return false end
    if #categoryIdsOfZone == 1 then
        return openItemSetCollectionBookOfZoneCategoryData(categoryIdsOfZone[1])
    else
        for _, categoryId in ipairs(categoryIdsOfZone) do
            if openItemSetCollectionBookOfZoneCategoryData(categoryId) then
                return true
            end
        end
        return false
    end
end

--Open the item set collections book of the current parentZoneId. If more than 1 categoryId was found for the parentZoneId,
--the 1st will be opened!
function lib.OpenItemSetCollectionBookOfCurrentParentZone()
    local _, currentParentZone, _, _ = getCurrentZoneIds()
    if not currentParentZone or currentParentZone <= 0 then return end
    return openItemSetCollectionsBookOfZoneId(currentParentZone)
end
local openItemSetCollectionBookOfCurrentParentZone = lib.OpenItemSetCollectionBookOfCurrentParentZone

--Open the item set collections book of the current zoneId. If more than 1 categoryId was found for the zoneId,
--the 1st will be opened!
function lib.OpenItemSetCollectionBookOfCurrentZone()
    local currentZone, _, _, _ = getCurrentZoneIds()
    if not currentZone or currentZone <= 0 then return end
    return openItemSetCollectionsBookOfZoneId(currentZone)
end
local openItemSetCollectionBookOfCurrentZone = lib.OpenItemSetCollectionBookOfCurrentZone

--Open the item set collections book of the zoneId. If more than 1 categoryId was found for the zoneId,
--the 1st will be opened!
function lib.OpenItemSetCollectionBookOfZone(zoneId)
    if not zoneId or zoneId <= 0 then return end
    return openItemSetCollectionsBookOfZoneId(zoneId)
end


function lib.OpenSetItemCollectionBrowserForCurrentZone(useParentZone)
    if useParentZone == true then
        return openItemSetCollectionBookOfCurrentParentZone()
    else
        return openItemSetCollectionBookOfCurrentZone()
    end
end
local openSetItemCollectionBrowserForCurrentZone = lib.OpenSetItemCollectionBrowserForCurrentZone



------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Tooltips API
------------------------------------------------------------------------
--Register a custom tooltip control of type CT_TOOLTIP that inherits from ZO_ItemIconTooltip for the LibSets added tooltip data
--(added to the bottom, during function OnAddGameData is called)
-->Important: The tooltipCtrl of tooltipCtrlName !must! have a subtable dataEntry.data or .data which contains an entry .itemLink with the itemLink of the item,
-->           or the tooltipCtrl of tooltipCtrlName !must! have the entries .bagIndex and .slotIndex where the itemLink can be build from!
--tooltipCtrlName String
--addonName String
-->Returns true if LibSets tooltip hook was added to the internal tables (will be hooked at EVENT_PLAYER_ACTIVATED once, or if a new hook is added later via this function)
-->Returns false if it was already added
-->Returns nil if any error happens
local tooltipControlNameAndInheritErrorStr = "[" .. MAJOR .. "]:RegisterCustomTooltipHook ERROR - addon: %q - parameter \'tooltipCtrlName\' (%s) must be the name of an existing TooltipControl of type CT_TOOLTIP, inheriting from ZO_ItemIconTooltip, providing function \'OnAddGameData\'"
function lib.RegisterCustomTooltipHook(tooltipCtrlName, addonName)
    --TooltipControl name is provided and a String
    assert(tooltipCtrlName ~= nil and tooltipCtrlName ~= "", strfor(tooltipControlNameAndInheritErrorStr, tos(addonName), tos(tooltipCtrlName)))
--d(">customTooltipControlName found")
    --Tooltip Control is provided and it's type is CT_TOOLTIP (11) and got the function 'OnAddGameData'
    local ttCtrl = GetControl(tooltipCtrlName)
    local ttCtrltype = (ttCtrl.GetType ~= nil and ttCtrl:GetType()) or nil
--d(">ttCtrltype: " ..tos(ttCtrltype))
    assert(ttCtrl ~= nil and ttCtrltype ~= nil and ttCtrltype == CT_TOOLTIP, strfor(tooltipControlNameAndInheritErrorStr, tos(addonName), tos(tooltipCtrlName))) --and ttCtrl.OnAddGameData ~= nil
--d(">customTooltipControl found")
    --Check if the same conrolName was already added and provide feedback
    local customTooltipHooks = lib.customTooltipHooks
    for index, ttData in ipairs(customTooltipHooks.needed) do
        local tooltipCtrlNameAlreadyAdded = ttData.tooltipCtrlName
        if tooltipCtrlNameAlreadyAdded ~= nil and tooltipCtrlNameAlreadyAdded ~= "" and tooltipCtrlNameAlreadyAdded == tooltipCtrlName then
            d("[" .. MAJOR .. "]Tooltip control name \'" .. tos(tooltipCtrlNameAlreadyAdded) .. "\' was already added with addon \'" .. tos(ttData.addonName) .. "\'")
            return false
        end
    end

    --Add the needed hook to the internal tables
    tins(customTooltipHooksNeeded, {
        tooltipCtrlName =   tooltipCtrlName,
        addonName =         addonName,
    })

    --Check if EVENT_PLAYER_ACTIVATED was already run and if so: Apply the hook for the new registered TooltipControl now
    if lib.customTooltipHooks.eventPlayerActivatedCalled == true then
        lib.HookTooltipControls(true, ttCtrl)
    end
    return true
end


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Set PROC functions
------------------------------------------------------------------------
--[[
2022-04-20 Disabled as there is no reliable "1 source" of sets that proc or not, in PVP. As ZOs changes that with every patch,
or at least did in the past, and did not inform what was changed (At least not all changes and ppl had to test it over and over again)
it was not possible to maintain these lists properly without hours of testing and manual effort :-(

--Internal helper function to read the set's procData, if it exists
local function getSetProcData(setId)
    if setId == nil then return end
    local setProcData = preloaded[LIBSETS_TABLEKEY_SET_PROCS] and preloaded[LIBSETS_TABLEKEY_SET_PROCS][setId]
    return setProcData
end

--Internal helper function to loop over a table and add the "dataName" entries in the table "setProcDataOfSetProcCheckTypeTable"
--to a table "dataReturnTable"
local function getSetProcDataOfIndex(setProcDataOfSetProcCheckTypeTable, dataName, dataReturnTable)
    for _, setProcDataOfIndex in ipairs(setProcDataOfSetProcCheckTypeTable) do
        local setprocDataOfIndexData = setProcDataOfIndex[dataName]
        if setprocDataOfIndexData then
            for _, data in ipairs(setprocDataOfIndexData) do
                tins(dataReturnTable, data)
            end
        end
    end
end

--Internal helper function to read abilityIds, debuffIds (dataTableKey) from the setProc data tables
local function getSetProcDataIds(setId, setProcCheckType, procIndex, dataTableKey)
    local setProcData = getSetProcData(setId)
    local setProcDataIds
    if not setProcData then return end
    if setProcCheckType and procIndex then
        setProcDataIds = setProcData and setProcData[setProcCheckType]
                and setProcData[setProcCheckType][procIndex]
                and setProcData[setProcCheckType][procIndex][dataTableKey]
    else
        if setProcCheckType then
            --No index given, so collect all of the setProcCheckType
            local setProcDataOfSetProcCheckType = setProcData[setProcCheckType]
            if not setProcDataOfSetProcCheckType then return end
            setProcDataIds = {}
            getSetProcDataOfIndex(setProcDataOfSetProcCheckType, dataTableKey, setProcDataIds)
        else
            --No setProcCheckType and no index given, so collect all setProcChecktypes and all indices of them
            setProcDataIds = {}
            for _, setProcDataOfSetProcCheckType in ipairs(setProcData) do
                getSetProcDataOfIndex(setProcDataOfSetProcCheckType, dataTableKey, setProcDataIds)
            end
        end
    end
    return setProcDataIds
end
------------------------------------------------------------------------------------------------------------------------

--Returns true if the setId provided got a set proc which is currently allowed within PvP/AvA campaigns
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSetWithProcAllowedInPvP
function lib.IsSetWithProcAllowedInPvP(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local isSetWithProcAllowedInPvP = ( preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP] ~= nil
            and preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP][setId] ~= nil ) or false
    return isSetWithProcAllowedInPvP
end

--Returns the setsData of all the setIds which are allowed proc sets in PvP/AvA campaigns
--> Parameters: none
--> Returns:    nilable:LibSetsAllSetProcDataAllowedInPvP table
function lib.GetAllSetDataWithProcAllowedInPvP()
    if not checkIfSetsAreLoadedProperly() then return end
    return preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP]
end


--Returns true if the setId provided got a set proc
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSetWithProc
function lib.IsSetWithProc(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local isSetWithProc = ( preloaded[LIBSETS_TABLEKEY_SET_PROCS] ~= nil and preloaded[LIBSETS_TABLEKEY_SET_PROCS][setId] ~= nil ) or false
    return isSetWithProc
end


--Returns the procData of all the setIds
--> Parameters: none
--> Returns:    nilable:LibSetsAllSetProcData table
function lib.GetAllSetProcData()
    if not checkIfSetsAreLoadedProperly() then return end
    return preloaded[LIBSETS_TABLEKEY_SET_PROCS]
end


--Returns the procData of the setId as table, containing the abilityIds, unitTag, cooldown, icon, etc.
--> Parameters: setId number: The set's setId
--> Returns:    nilable:LibSetsSetProcData table
--[ [
    [number setId] = {
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
            [number index1toN] = {
                ["abilityIds"] = {number abilityId1, number abilityId2, ...},
                ["debuffIds"] = {number debuffId1, number debuffId1, ...},
                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_EFFECT_CHANGED
                    ["unitTag"] = String unitTag e.g. "player", "playerpet", "group", "boss", etc.,

                    --Only for LIBSETS_SETPROC_CHECKTYPE_ABILITY_EVENT_COMBAT_EVENT
                    ["source"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER
                    ["target"] = number combatUnitType e.g. COMBAT_UNIT_TYPE_PLAYER

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_POWER_UPDATE
                    ["powerType"] = number powerType e.g. POWERTYPE_STAMINA

                    --Only for LIBSETS_SETPROC_CHECKTYPE_EVENT_BOSSES_CHANGED
                    ["unitTag"] = String unitTagOfBoss e.g. boss1, boss2, ...

                    --Only for LIBSETS_SETPROC_CHECKTYPE_SPECIAL
                    [number index1toN] = boolean specialFunctionIsGiven e.g. true/false (if true: the abilityId1's callback function should run a special                                             function as well, which will be registered for the

                ["cooldown"] = {number cooldownForAbilityId1 e.g. 12000, number cooldownForAbilityId2, ...},
                ["icon"] = String iconPathOfTheBuffIconToUse e.g. "/esoui/art/icons/ability_buff_minor_vitality.dds"
            },
        },
        [number LIBSETS_SETPROC_CHECKTYPE_ constant from LibSets_ConstantsLibraryInternal.lua] = {
        ...
        },
        ...
        --String comment name of the set -> description of the proc EN / description of the proc DE
    },
   ] ]
function lib.GetSetProcData(setId)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    return getSetProcData(setId)
end

--Returns the abilityIds of the setId's procData
--> Parameters: setId number: The set's setId
-->             nilable:setProcCheckType number: The setProcCheckType (See file LibSets_ConstantsLibryInternal.lua) to search
-->             the abilityIds in. If left entry all setprocCheckTypes will be read and the abilityIds taken from their indices.
-->             nilable:procIndex number: The procIndex to get the abilityIds from. If left entry all abilityIds of all indices
-->             of the setProcCheckType will be read
--> Returns:    nilable:LibSetsSetProcDataAbilityIds table {[index1] = abilityId1, [index2] = abilityId2}
function lib.GetSetProcAbilityIds(setId, setProcCheckType, procIndex)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local dataTableKey = "abilityIds"
    local setProcDataAbilityIds = getSetProcDataIds(setId, setProcCheckType, procIndex, dataTableKey)
    return setProcDataAbilityIds
end

--Returns the debuffIds of the setId's procData
--> Parameters: setId number: The set's setId
-->             nilable:setProcCheckType number: The setProcCheckType (See file LibSets_ConstantsLibryInternal.lua) to search
-->             the debuffIds in. If left entry all setprocCheckTypes will be read and the debuffIds taken from their indices.
-->             nilable:procIndex number: The procIndex to get the debuffIds from. If left entry all debuffIds of all indices
-->             of the setProcCheckType will be read
--> Returns:    nilable:LibSetsSetProcDataDebuffIds table {[index1] = debuffId1, [index2] = debuffId2}
function lib.GetSetProcDebuffIds(setId, setProcCheckType, procIndex)
    if setId == nil then return end
    if not checkIfSetsAreLoadedProperly(setId) then return end
    local dataTableKey = "debuffIds"
    local setProcDataDebuffIds = getSetProcDataIds(setId, setProcCheckType, procIndex, dataTableKey)
    return setProcDataDebuffIds
end

------------
-- EVENTS --
------------
lib.eventListSetProcs = {}

local function GetRegisteredSetProcEventDatatOfAbilityId(eventListTable, eventId, addOnEventNamespace, setId, abilityId, unregisterCheck)
    --Find the eventId
    unregisterCheck = unregisterCheck or false
    local eventIdTableData = eventListTable[eventId]
    if eventIdTableData then
        if setId == nil and unregisterCheck == true then
            return true
        else
            local eventIdAddonNamespaceTableData = eventIdTableData[addOnEventNamespace]
            if eventIdAddonNamespaceTableData then
                local eventIdAddonNamespaceSetIdTableData = eventIdAddonNamespaceTableData[setId]
                if eventIdAddonNamespaceSetIdTableData then
                    if abilityId == nil and unregisterCheck == true then
                        return true
                    else
                        local eventIdAddonNamespaceSetIdAbilityIdTableData = eventIdAddonNamespaceSetIdTableData[abilityId]
                        if eventIdAddonNamespaceSetIdAbilityIdTableData then
                            return true
                        end
                    end
                end
            end
        end
    end
	return false
end

local supportedSetprocEventIds = {
    [EVENT_EFFECT_CHANGED]  = true,
    [EVENT_COMBAT_EVENT]    = true,
}

local function buildUniqueEventFilterAddonNamespaceTag(addOnEventNamespace, abilityId)
    local uniqueAddonNamespaceEventName = addOnEventNamespace
    if abilityId ~= nil then
        uniqueAddonNamespaceEventName = uniqueAddonNamespaceEventName .. "_" .. tos(abilityId)
    end
    return uniqueAddonNamespaceEventName
end

-- Add a callback function to any of the possible events:
--  EVENT_EFFECT_CHANGED
--  EVENT_COMBAT_EVENT
-- Specify the abilityIds of the set's proc which should be checked. Those abilityIds will be automatically filtered at
-- the event to speed up the performance.
-- You can define additional filterTypes at the ... parameters, where there are always 2 parameters for each additional
-- filterTyp which you want to add. e.g. filterType1, filterParameter1, filterType2, filterParameter2, ...
-- Possible additional filterTypes are:
-- REGISTER_FILTER_UNIT_TAG, REGISTER_FILTER_UNIT_TAG_PREFIX or more https://wiki.esoui.com/AddFilterForEvent ,
-- Attention: DO NOT USE the filterType REGISTER_FILTER_ABILITY_ID, because this is already handled by this function internally!
-- Returns nilable:successfulRegister boolean
--
--Example call, will register EVENT_COMBAT_EVENT for the abilityId 135659 of th setId 487 (Winter), and call the function myCombatEventFunc
--which's parameters must be the ones of the EVENT_COMBAT_EVENT (w/o the first eventId)->result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow
--plus it will register a unitTag filter on "player"
--LibSets.RegisterSetProcEventCallbackForAbilityIds(addOnEventNamespace, EVENT_COMBAT_EVENT, 487, {135659}, myCombatEventFunc, REGISTER_FILTER_UNIT_TAG, "player")
function lib.RegisterSetProcEventCallbackForAbilityIds(addOnEventNamespace, eventId, setId, abilityIds, callbackFunc, ...)
    if addOnEventNamespace == nil or addOnEventNamespace == "" or eventId == nil or abilityIds == nil or setId == nil
            or callbackFunc == nil then return nil end
    if not supportedSetprocEventIds[eventId] then return end

    local typeNamespace = type(addOnEventNamespace) == "string"
    local typeFunc = type(callbackFunc) == "function"
    local typeAbilities = type(abilityIds) == "table"
    if typeNamespace == true and typeFunc == true and typeAbilities == true then
        --For each abilityId provided: Register the eventId and add a filter to the abilityId + add the additional filters
        --provided
        for _, abilityIdToRegister in ipairs(abilityIds) do
            local alreadyRegistered = GetRegisteredSetProcEventDatatOfAbilityId(lib.eventListSetProcs, eventId, addOnEventNamespace, setId, abilityIdToRegister, false)
            if not alreadyRegistered then
                local uniqueEventFilterAddonNamespaceTag = buildUniqueEventFilterAddonNamespaceTag(addOnEventNamespace, abilityIdToRegister)
                --Not registered for the eventId, setId and addOnEventNamespace yet? So register it now
                EVENT_MANAGER:RegisterForEvent(uniqueEventFilterAddonNamespaceTag, eventId, function(_, ...)
                    --Get the abilityId from the event's normal callback function
                    local abilityId
                    -- EVENT_EFFECT_CHANGED:
                    -- Returns 16:  changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
                    -- EVENT_COMBAT_EVENT:
                    --Returns 17:   actionResultType, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                    if eventId == EVENT_EFFECT_CHANGED then
                        abilityId = select(15, ...)
                    elseif eventId == EVENT_COMBAT_EVENT then
                        abilityId = select(16, ...)
                    end
                    callbackFunc(...)
                end)
                --Add the filter on the abilityId for the same uniqueEventName
                EVENT_MANAGER:AddFilterForEvent(uniqueEventFilterAddonNamespaceTag, eventId, REGISTER_FILTER_ABILITY_ID, abilityIdToRegister)

                -- Add additonal filters, e.g. on a unitTag
                -- Multiple filters are handled here:
                -- ... is a table like { filterType1, filterParameter1, filterType2, filterParameter2, filterType3, filterParameter3, ... }
                -- You can only have one filterParameter for each filterType.
                local filterParams = { ... }
                if next(filterParams) then
                    for i = 1, select("#", filterParams), 2 do
                        local filterType = select(i, filterParams)
                        local filterParameter = select(i + 1, filterParams)
                        EVENT_MANAGER:AddFilterForEvent(uniqueEventFilterAddonNamespaceTag, eventId, filterType, filterParameter)
                    end
                end

                --Keep track of the registered eventIds, setId, addonNameSpaces + abilityIds
                lib.eventListSetProcs[eventId] = lib.eventListSetProcs[eventId] or {}
                lib.eventListSetProcs[eventId][addOnEventNamespace] = lib.eventListSetProcs[eventId][addOnEventNamespace] or {}
                lib.eventListSetProcs[eventId][addOnEventNamespace][setId] = lib.eventListSetProcs[eventId][addOnEventNamespace][setId] or {}
                lib.eventListSetProcs[eventId][addOnEventNamespace][setId][abilityIdToRegister] = {
                        eventId = eventId,
                        setId = setId,
                        addOnEventNamespace = addOnEventNamespace,
                        abilityIds = abilityIds,
                        abilityIdFiltered = abilityIdToRegister,
                        callbackFunc = callbackFunc,
                        filterParams = filterParams
                }
                return true
            end
        end
    end
    return nil
end

--Local helper fucntion to unregister an eventId (clear all filters on it) and clear up internal tables
local function unregisterSetProcEventAndDeleteEventList(eventId, addOnEventNamespace, setId, abilityId)
    local alreadyRegistered = GetRegisteredSetProcEventDatatOfAbilityId(lib.eventListSetProcs, eventId, addOnEventNamespace, setId, abilityId, true)
    if alreadyRegistered == true then
        local uniqueAddonNamespaceEventName = buildUniqueEventFilterAddonNamespaceTag(addOnEventNamespace, abilityId)
        EVENT_MANAGER:UnregisterForEvent(uniqueAddonNamespaceEventName, eventId)
        if setId ~= nil then
            if abilityId ~= nil then
                lib.eventListSetProcs[eventId][addOnEventNamespace][setId][abilityId] = nil
            else
                lib.eventListSetProcs[eventId][addOnEventNamespace][setId] = nil
            end
        else
            lib.eventListSetProcs[eventId][addOnEventNamespace] = nil
        end
        return true
    end
    return false
end

-- Unregister the registered callback functions for the Set procs eventId at the addOnEventNamespace
-- Returns nilable:succesfulUnregister boolean
function lib.UnRegisterSetProcEventCallbackForEventId(addOnEventNamespace, eventId)
    if not addOnEventNamespace or addOnEventNamespace == "" then return end
    if eventId ~= nil then
        return unregisterSetProcEventAndDeleteEventList(eventId, addOnEventNamespace, nil, nil)
    else
        local retVar
        for eventIdInTable, _ in pairs(lib.eventListSetProcs) do
            local wasUnregistered = unregisterSetProcEventAndDeleteEventList(eventIdInTable, addOnEventNamespace, nil, nil)
            if wasUnregistered == true then
                retVar = true
            end
        end
        return retVar
    end
    return nil
end

-- Unregister the registered callback functions for the Set procs eventId at the addOnEventNamespace, setId and abilityId
-- Returns nilable:succesfulUnregister boolean
function lib.UnRegisterSetProcEventCallbackForAbilityId(addOnEventNamespace, eventId, setId, abilityId)
    if not addOnEventNamespace or addOnEventNamespace == "" or not setId or not abilityId then return end
    if eventId ~= nil then
        return unregisterSetProcEventAndDeleteEventList(eventId, addOnEventNamespace, setId, abilityId)
    else
        local retVar
        for eventIdInTable, _ in pairs(lib.eventListSetProcs) do
            local wasUnregistered = unregisterSetProcEventAndDeleteEventList(eventIdInTable, addOnEventNamespace, setId, abilityId)
            if wasUnregistered == true then
                retVar = true
            end
        end
        return retVar
    end
    return nil
end

-- Unregister the registered callback functions for the Set procs eventId at the addOnEventNamespace and setId
-- Returns nilable:succesfulUnregister boolean
function lib.UnRegisterSetProcEventCallbackForSetId(addOnEventNamespace, eventId, setId)
    if not addOnEventNamespace or addOnEventNamespace == "" or not setId then return end
    if eventId ~= nil then
        return unregisterSetProcEventAndDeleteEventList(eventId, addOnEventNamespace, setId, nil)
    else
        local retVar
        for eventIdInTable, _ in pairs(lib.eventListSetProcs) do
            local wasUnregistered = unregisterSetProcEventAndDeleteEventList(eventIdInTable, addOnEventNamespace, setId, nil)
            if wasUnregistered == true then
                retVar = true
            end
        end
        return retVar
    end
    return nil
end
]] -- 2022-04-20 Disabled



------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	API - Custom context menu entries at the set search UI results list
------------------------------------------------------------------------
local customContextMenuErrorPrefixStr = "[" .. MAJOR .. "]:RegisterCustomSetSearchResultsListContextMenu ERROR - addon: %q"
local customContextMenuSetSearchParamErrorStr = customContextMenuErrorPrefixStr .. " - parameter \'headerName\' must be nil or a String. Parameter \'submenuName\' must be nil or a String. Parameter \'submenuEntries\' (%s) must be a table of submenu entries (See library \'LibCustomMenu\', and the addon name must be a string. Parameter visibleFunc must be nil or a function with 1st parameter \'rowControl\' of the menu parent and 2nd optinonal parameter \'setId\', returning a boolean."
local customContextMenuSetSearchExistsAlreadyErrorStr = customContextMenuErrorPrefixStr .. " was already registered!"
function lib.RegisterCustomSetSearchResultsListContextMenu(addonName, headerName, submenuName, submenuEntries, visibleFunc)
    assert(type(addonName) == "string" and (headerName == nil or type(headerName) == "string") and (submenuName == nil or type(submenuName) == "string") and type(submenuEntries) == "table" and (visibleFunc == nil or type(visibleFunc) == "function"), strfor(customContextMenuSetSearchParamErrorStr, tos(addonName), tos(submenuName), tos(submenuEntries)))
    local customContextMenuEntriesSetSearch = lib.customContextMenuEntries["setSearchUI"]
    assert(customContextMenuEntriesSetSearch[addonName] == nil, strfor(customContextMenuSetSearchExistsAlreadyErrorStr, tos(addonName)))

    customContextMenuEntriesSetSearch[addonName] = {
        headerName  = headerName,
        name        = submenuName or addonName,
        entries     = submenuEntries,
        visible     = visibleFunc,
    }
end



------------------------------------------------------------------------
-- 	UI related stuff
------------------------------------------------------------------------
local function addButton(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY, buttonData)
    if not buttonData or not buttonData.parentControl or not buttonData.buttonName or not buttonData.callback then return end
    local button
    --Does the button already exist?
    local btnName = buttonData.parentControl:GetName() .. MAJOR .. buttonData.buttonName
    button = WM:GetControlByName(btnName, "")
    if button == nil then
        --Create the button control at the parent
        button = WM:CreateControl(btnName, buttonData.parentControl, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        --Set the button's size
        button:SetDimensions(buttonData.width or 32, buttonData.height or 32)

        --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
        button:SetAnchor(myAnchorPoint, relativeTo, relativePoint, offsetX, offsetY)

        --Texture
        local texture

        --Check if texture exists
        texture = WM:GetControlByName(btnName, "Texture")
        if texture == nil then
            --Create the texture for the button to hold the image
            texture = WM:CreateControl(btnName .. "Texture", button, CT_TEXTURE)
        end
        texture:SetAnchorFill()

        --Set the texture for normale state now
        texture:SetTexture(buttonData.normal)

        --Do we have seperate textures for the button states?
        button.upTexture 	  = buttonData.normal
        button.mouseOver 	  = buttonData.highlight
        button.clickedTexture = buttonData.pressed

        button.tooltipText	= buttonData.tooltip
        button.tooltipAlign = TOP
        button:SetHandler("OnMouseEnter", function(self)
        self:GetChild(1):SetTexture(self.mouseOver)
            ZO_Tooltips_ShowTextTooltip(self, self.tooltipAlign, self.tooltipText)
        end)
        button:SetHandler("OnMouseExit", function(self)
            self:GetChild(1):SetTexture(self.upTexture)
            ZO_Tooltips_HideTextTooltip()
        end)
        --Set the callback function of the button
        button:SetHandler("OnClicked", function(...)
            buttonData.callback(...)
        end)
        button:SetHandler("OnMouseUp", function(butn, mouseButton, upInside)
            if upInside then
                butn:GetChild(1):SetTexture(butn.upTexture)
            end
        end)
        button:SetHandler("OnMouseDown", function(butn)
            butn:GetChild(1):SetTexture(butn.clickedTexture)
        end)

        --Show the button and make it react on mouse input
        button:SetHidden(false)
        button:SetMouseEnabled(true)

        --Return the button control
        return button
    end
end
---
local function addUIButtons()
    local addSetCollectionsCurrentZoneButton = lib.svData.addSetCollectionsCurrentZoneButton
    if addSetCollectionsCurrentZoneButton == true then

        if lib.itemSetCollectionBookMoreOptionsButton == nil then
            local localization = lib.localization[clientLang]

            --ZO_CreateStringId(LIBSETS_SHOW_ITEM_SET_COLLECTION_MORE_OPTIONS,            localization.moreOptions)   --"More Options")
            --ZO_CreateStringId(LIBSETS_SHOW_ITEM_SET_COLLECTION_CURRENT_PARENT_ZONE,     localization.parentZone)    --"Parent zone")
            --ZO_CreateStringId(LIBSETS_SHOW_ITEM_SET_COLLECTION_CURRENT_ZONE,            localization.currentZone)   --"Current zone")

            --Add "show current parent zone" button to item set collection UI top right corner
            local moreOptionsButtonTooltip = (LibCustomMenu ~= nil and tos(localization.moreOptions)) or tos(localization.currentZone)
            local buttonDataOpenCurrentParentZone =
            {
                buttonName      = "MoreOptions",
                parentControl   = ZO_ItemSetsBook_Keyboard_TopLevelFilters,
                tooltip         = libPrefix .. moreOptionsButtonTooltip,
                callback        = function()
                    if LibCustomMenu ~= nil then
                        ClearMenu()
                        AddCustomMenuItem(localization.parentZone, function()
                            openSetItemCollectionBrowserForCurrentZone(true)
                        end)
                        AddCustomMenuItem(localization.currentZone, function()
                            if not openSetItemCollectionBrowserForCurrentZone(false) then
                                openSetItemCollectionBrowserForCurrentZone(true)
                            end
                        end)
                        ShowMenu(lib.itemSetCollectionBookMoreOptionsButton)
                    else
                        if not openSetItemCollectionBrowserForCurrentZone(false) then
                            openSetItemCollectionBrowserForCurrentZone(true)
                        end
                    end
                end,
                width           = 20,
                height          = 20,
                normal          = "/esoui/art/buttons/dropbox_arrow_normal.dds",
                pressed         = "/esoui/art/buttons/dropbox_arrow_mousedown.dds",
                highlight       = "/esoui/art/buttons/dropbox_arrow_mouseover.dds",
                disabled        = "/esoui/art/buttons/dropbox_arrow_disabled.dds",
            }
            lib.itemSetCollectionBookMoreOptionsButton = addButton(LEFT, ZO_ItemSetsBook_Keyboard_TopLevelFilters, RIGHT, (buttonDataOpenCurrentParentZone.width+4)*-1, 10, buttonDataOpenCurrentParentZone)
            lib.itemSetCollectionBookMoreOptionsButton:SetHidden(false)
        else
            lib.itemSetCollectionBookMoreOptionsButton:SetHidden(false)
        end
    elseif not addSetCollectionsCurrentZoneButton then
        if lib.itemSetCollectionBookMoreOptionsButton ~= nil then
            lib.itemSetCollectionBookMoreOptionsButton:SetHidden(true)
        end
    end

    --Register a fragment stateChange callback so the buttons get hidden at Transmute station -> Reconstruction tab
    local function fragmentChange(oldState, newState)
        if (newState == SCENE_FRAGMENT_SHOWN ) then
            lib.itemSetCollectionBookMoreOptionsButton:SetHidden(true)
        elseif (newState == SCENE_FRAGMENT_HIDING ) then
            lib.itemSetCollectionBookMoreOptionsButton:SetHidden(false)
        end
    end
    RETRAIT_STATION_RECONSTRUCT_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
end
lib.addUIButtons = addUIButtons

local function createUIStuff()
    --Add buttons to jump to current zon at the set collections
    addUIButtons()

    --Search UI
    InitSearchUI()
end

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Global library check functions
------------------------------------------------------------------------
--Returns a boolean value, true if the sets of the game were already loaded/ false if not
--> Returns:    boolean areSetsLoaded
function lib.AreSetsLoaded()
    local areSetsLoaded = (lib.setsLoaded and lib.setIds ~= nil) or false
    return areSetsLoaded
end
local areSetsLoaded = lib.AreSetsLoaded

--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not
--> Returns:    boolean isCurrentlySetsScanning
function lib.IsSetsScanning()
    return lib.setsScanning
end
local isSetsScanning = lib.IsSetsScanning

--Returns a boolean value, true if the sets database is properly loaded yet and is not currently scanning
--or false if not.
--This functions combines the result values of the functions LibSets.AreSetsLoaded() and LibSets.IsSetsScanning()
function lib.checkIfSetsAreLoadedProperly(setId)
    checkIfSetsAreLoadedProperly = checkIfSetsAreLoadedProperly or lib.checkIfSetsAreLoadedProperly
    if isSetsScanning() or not areSetsLoaded() then return false end
    if setId ~= nil then return isSetCurrentlyActiveWithAPIVersion(setId) end
    return true
end
checkIfSetsAreLoadedProperly = checkIfSetsAreLoadedProperly or lib.checkIfSetsAreLoadedProperly



------------------------------------------------------------------------------------------------------------------------
--SLASH COMMANDS
--Parse the arguments string
local function getOptionsFromSlashCommandString(slashCommandString)
    local options = {}
    --local searchResult = {} --old: searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for param in strgmatch(slashCommandString, "([^%s]+)%s*") do
        if (param ~= nil and param ~= "") then
            local paramBoolOrOther = toboolean(strlower(param))

            options[#options+1] = paramBoolOrOther
        end
    end
    return options
end


local function slash_search(slashOptions)
    --LibSets_SearchUI_Shared:Show(searchParams, searchDoneCallback, searchErrorCallback, searchCanceledCallback)
    if LibSets_SearchUI_Shared_IsShown() == true then
        if slashOptions ~= nil and #slashOptions > 0 then
            --Keep the UI shown -> Pass in search options form slash command
            LibSets_SearchUI_Shared_UpdateSearch(slashOptions)
        else
            LibSets_SearchUI_Shared_ToggleUI() --hide the UI again
        end
    else
        --Show the UI -> Pass in search options form slash command
        LibSets_SearchUI_Shared_ToggleUI(slashOptions)
    end
end

local function slash_search_helper(args)
    local options = getOptionsFromSlashCommandString(args)
    slash_search(options)
end


local dlcsInOrderLookupTable
local chaptersInOrderLookupTable

local function outputDLCorChapterRow(dlcId, dlcName, dlcType)
    local dlcTypeSuffix = ""
    if dlcType ~= nil then
        dlcTypeSuffix = "  (".. tos(possibleDlcTypes[dlcType])  .. ")"
    end
    local releaseDateTimestamp = dlcAndChapterCollectibleIds[dlcId].releaseDate
    local releaseDateStr
    local onlyDateWithoutTimeStr
    if releaseDateTimestamp ~= nil and type(releaseDateTimestamp) == "number" and releaseDateTimestamp >= 0 and releaseDateTimestamp <= 2147483647 then
        releaseDateStr = os.date("%c", releaseDateTimestamp)
        --Strip the hours, minutes, seconds at the space
        if string.find(releaseDateStr, " ", 1, true) ~= nil then
            for param in strgmatch(releaseDateStr, "([^%s]+)%s*") do
                if param ~= nil and param ~= "" then
                    onlyDateWithoutTimeStr =  param
                    break
                end
            end
        else
            onlyDateWithoutTimeStr = releaseDateStr
        end
    end
    if onlyDateWithoutTimeStr == nil then
        onlyDateWithoutTimeStr = ""
    end
    if onlyDateWithoutTimeStr ~= "" then
        onlyDateWithoutTimeStr = onlyDateWithoutTimeStr .. ": "
    end

    d("> [".. tos(dlcId) .."] " .. onlyDateWithoutTimeStr .. dlcName .. dlcTypeSuffix)
end

local function slashcommand_dlcs()
    if DLCandCHAPTERdata == nil then return end
    if dlcsInOrderLookupTable == nil then
        for dlcId, dlcName in ipairs(DLCandCHAPTERdata) do
            local dlcType = dlcAndChapterCollectibleIds[dlcId].type
            if dlcType == DLC_TYPE_DUNGEONS or dlcType == DLC_TYPE_ZONE then
                dlcsInOrderLookupTable = dlcsInOrderLookupTable or {}
                tins(dlcsInOrderLookupTable, {dlcId=dlcId, name=dlcName})
            end
        end
    end
    d(libPrefix .. "DLCs in order of appearance [<LibSetsDLCId>] <name>  (<LibSetsDLCtype>)")
    for _, chapterData in ipairs(dlcsInOrderLookupTable) do
        local dlcId = chapterData.dlcId
        outputDLCorChapterRow(dlcId, chapterData.name, dlcAndChapterCollectibleIds[dlcId].type)
    end
end

local function slashcommand_chapters()
    if DLCandCHAPTERdata == nil then return end
    if chaptersInOrderLookupTable == nil then
        for dlcId, dlcName in ipairs(DLCandCHAPTERdata) do
            if dlcAndChapterCollectibleIds[dlcId].type == DLC_TYPE_CHAPTER then
                chaptersInOrderLookupTable = chaptersInOrderLookupTable or {}
                tins(chaptersInOrderLookupTable, {dlcId=dlcId, name=dlcName})
            end
        end
    end
    d(libPrefix .. "Chapters in order of appearance [<LibSetsDLCId>] <name>  (DLC_TYPE_CHAPTER)")
    for _, chapterData in ipairs(chaptersInOrderLookupTable) do
        local dlcId = chapterData.dlcId
        outputDLCorChapterRow(dlcId, chapterData.name, dlcAndChapterCollectibleIds[dlcId].type)
    end
end

local function slashcommand_dlcsandchapter()
    if DLCandCHAPTERdata == nil then return end
    d(libPrefix .. "DLCs & chapters in order of appearance [<LibSetsDLCId>] <name>  (<LibSetsDLCtype>)")
    for dlcId, dlcName in ipairs(DLCandCHAPTERdata) do
        outputDLCorChapterRow(dlcId, dlcName, dlcAndChapterCollectibleIds[dlcId].type)
    end
end

local function slash_help()
    d(">>> [" .. lib.name .. "] |c0000FFSlash command help -|r BEGIN >>>")
    d("|-> \'/libsets help\'              Write this information to the chat")
    d("|-> \'/libsets chapters\'          Write the list of chapters to the chat")
    d("|-> \'/libsets dlcs\'              Write the list of dlcs to the chat")
    d("|-> \'/libsets dlcsandchapters\'   Write the list of dlcs and chapters to the chat")
    d("|-> \'/lss\' or \'libsets search\' <optional search term>        Show the search UI. If <optional search term> was provided the search UI will search this set name directly.")
    d("|-> \'/lsp\' <optional search term>\'        Start a set search in the chat editbox and show found sets directly (only if LibSlashCommander is activated!). You can search by name or setId. Selecting a found set will show a preview of a set's item, and (if enabled in your LibSets settings menu) provide the itemlink in the chat editbox too.")
    d("|-> \'/libsets debug\' <optional debug option>       Write debugging information to the chat. If <optional debug option> was provided, this function will be called (if valid).")
    d("<<< [" .. lib.name .. "] |c0000FFSlash command help -|r END <<<")
end

local function slash_debug_help()
    d(">>> [" .. lib.name .. "] |c0000FFSlash command DEBUG help -|r BEGIN >>>")
    d("|--------------------------------------------------------")
    d("| DEBUGING ")
    d("|-> \'/libSets debug\' <optional debug option>       Write debugging information to the chat. If <optional debug option> was provided, this function will be called (if valid).")
    d("|-> Valid functions are:")
    d("|--------------------------------------------------------")
    d("|-> \'getall\'               Scan all set's and itemIds, maps, zones, wayshrines, dungeons, update the language dependent variables and put them into the SavedVariables.\n|cFF0000Attention:|r |cFFFFFFThe UI will reload several times for the supported languages of the library!|r")
    d("|-> \'getallnames\'          Get all names (sets, zones, maps, wayshrines, DLCs) of the current client language")
    d("|-> \'getzones\'             Get all zone data")
    d("|-> \'getmapnamess\'         Get all map names of the current client language")
    d("|-> \'getwayshrines\'        Get all wayshrine data of the currently shown zone. If the map is not opened it will be opened")
    d("|-> \'getwayshrinenames\'    Get all wayshrine names of the current client language")
    d("|-> \'getsetnames\'          Get all set names of the current client language")
    d("|-> \'getdungeons\'          Get the dungeon data. If the dungeon's view at the group window is not yet opened it will be opened.")
    d("|-> \'getcollectiblenames\'  Get the collectible names of all collectibles of the current client language.")
    d("|-> \'getdlcnames\'          Get the DLC collectible names of the current client language.")
    d("|-> \'shownewsets\'          Show the new setIds and names of sets which were scanned and found but not transfered to the preoaded data yet. Needs to run \'scanitemids\' first!")
    d("|-> \'scanitemids\'          Scan all itemIds of sets")
    d("|-> \'resetsv\'              Resets the SavedVariables")
    d("<<< [" .. lib.name .. "] |c0000FFSlash command DEBUG help -|r END <<<")
end

local function command_handler(args)
    local options = getOptionsFromSlashCommandString(args)

    --Help / status
    local firstParam = options and options[1]
    local secondParam = options and options[2]
    if #options == 0 or firstParam == nil or firstParam == "" or callHelpParams[firstParam] == true then
        slash_help()
    elseif firstParam ~= nil then
        if callSearchParams[firstParam] == true then
            trem(options, 1)
            trem(options, 2)
            slash_search(options)
        elseif firstParam == "dlcs" then
            slashcommand_dlcs()
        elseif firstParam == "chapters" then
            slashcommand_chapters()
        elseif firstParam == "dlcsandchapters" then
            slashcommand_dlcsandchapter()
        elseif firstParam == "debug" then
            if secondParam ~= nil then
                local debugFunc = callDebugParams[secondParam]
                if debugFunc ~= nil then
                    trem(options, 1)
                    trem(options, 2)
                    if lib[debugFunc] ~= nil then
                        lib[debugFunc](unp(options))
                    end
                end
            else
                slash_debug_help()
            end
        end
    end
end


local function createSlashCommands()
    SLASH_COMMANDS["/libsets"] = command_handler
    if SLASH_COMMANDS["/sets"] == nil then
        SLASH_COMMANDS["/sets"] = command_handler
    end
    if SLASH_COMMANDS["/ls"] == nil then
        SLASH_COMMANDS["/ls"] = command_handler
    end
    SLASH_COMMANDS["/libsetssearch"] = slash_search_helper
    if SLASH_COMMANDS["/lss"] == nil then
        SLASH_COMMANDS["/lss"] = slash_search_helper
    end

    --Add the slash command for the DLC/chapter info
    SLASH_COMMANDS["/libsetsdlcsandchapters"] = slashcommand_dlcsandchapter
    SLASH_COMMANDS["/dlcsandchapters"] = slashcommand_dlcsandchapter
    SLASH_COMMANDS["/libsetsdlcs"] = slashcommand_dlcs
    SLASH_COMMANDS["/dlcs"] = slashcommand_dlcs
    SLASH_COMMANDS["/libsetschapters"] = slashcommand_chapters
    SLASH_COMMANDS["/chapters"] = slashcommand_chapters
end


local function onPlayerActivated(eventId, isFirst)
    EM:UnregisterForEvent(MAJOR, EVENT_PLAYER_ACTIVATED)

    if lib.debugGetAllDataIsRunning == true then
        --Continue to get all data until it is finished
        d("[" .. lib.name .."]Resuming scan of \'DebugGetAllData\' after reloadui - language now: " ..tos(clientLang))
        lib.DebugGetAllData(false)
    end
end

--Addon loaded function
local function onLibraryLoaded(event, name)
    --Only load lib if ingame
    if name ~= MAJOR then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    lib.startedLoading = true
    lib.setsLoaded = false

    --Check for libraries
    -->LibZone
    libZone = LibZone
    lib.libZone = libZone
    lib.libAddonMenu = LibAddonMenu2
    lib.libSlashCommander = LibSlashCommander

    --The actual API version
    lib.APIVersions["live"] = lib.APIVersions["live"] or GetAPIVersion()
    lib.currentAPIVersion = lib.APIVersions["live"]

    --Check if any tasks are active via the SavedVariables -> Debug reloadUIs e.g.
    local goOn = false
    LoadSavedVariables()

    --Is the DebugGetAllData function running and reloadUI's are done? -> See EVENT_PLAYER_ACTIVATED then
    lib.debugGetAllDataIsRunning = false
    if lib.svDebugData and lib.svDebugData.DebugGetAllData and lib.svDebugData.DebugGetAllData[apiVersion] then
        if lib.svDebugData.DebugGetAllData[apiVersion].running == true and lib.svDebugData.DebugGetAllData[apiVersion].finished == false then
            lib.debugGetAllDataIsRunning = true
            goOn = false
            EM:RegisterForEvent(MAJOR, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
        elseif not lib.svDebugData.DebugGetAllData[apiVersion].running or lib.svDebugData.DebugGetAllData[apiVersion].finished == true then
            goOn = true
        end
    else
        goOn = true
    end
    if not goOn then
        lib.setsScanning = true
        lib.fullyLoaded = false
    else
        --Remove future APIversion setsData (ids, itemIds, names, wayshrines, zones, ..) from the PreLoaded data
        -->But do not do this if the automatic reloadUIs of the debug functions are taking place and data is still collected!
        -->Else new scanned setItemIds will get the new itemIds removed, and the names of the new setIds cannot be build properly
        lib.removeFutureSetData()
        --...and then remove this function from the library
        lib.removeFutureSetData = nil

        --Get the different setTypes from the preloaded "all sets table" setInfo in file LibSets_Data.lua and put them in their
        --own tables of the library, to be used from the LibSets API functions
        LoadSets()

        --Tooltips
        lib.loadTooltipHooks()

        --Slash commands
        createSlashCommands()

        --All library data was loaded and scanned, so set the variables to "successfull" now, in order to let the API functions
        --work properly now
        lib.fullyLoaded = true

        --Add UI related stuff like the "jump to set collections' current zone", and the search UI
        createUIStuff()

        --Optional: Build the libSlashCommander autocomplete stuff, if LibSlashCommander is present and activated
        -->See file LibSet_AutoCompletion.lua
        lib.buildLSCSetSearchAutoComplete()

        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        --For debugging only!
        --[[
        if GetDisplayName() == "@Baertram" then
            function lib.testDropMechanic(setId, lang)
                lib._dropMechanicIds, lib._dropMechanicNames, lib._dropMechanicTooltips, lib._dropMechanicLocationNames, lib._dropZoneIds = lib.GetDropMechanic(setId, true, lang)
            end
        end
        ]]
        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
        --TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
    end
end

--Load the addon now
EM:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, onLibraryLoaded)
