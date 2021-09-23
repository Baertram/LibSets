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
   LibSets_SV_Data =
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

   The debug/scan functions possible are:
   ---------------------------------------------------------------------------------------------------------------------------------------------
    Function name (execute with /script in chat)|   Description
   ---------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllData(resetCurrentAPI)
                                                |  Attention: This function will need some time to scan all + realoduis for each supported client language. But it should update all needed
                                                |              SV tables with 1 function call!
                                                |
                                                |   Scans all set itemIds, get's the current client language setName, wayshrine names, wayshrines ids, etc.
                                                |   It basically does all the debug funcitons below after another! It will reload the UI after the current client language data was
                                                |   loaded and transfered to the SavedVariables table "DebugGetAllData". Then it will go on with the next supported language which was
                                                |   not scanned for yet.
                                                |   Parameter resetCurrentAPI boolean: If set to true it will reset already scanned data for the current APIVersion and rescans it new!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugResetSavedVariables()          |   Reset ALL data in the SavedVariables. Should be run ONCE before new data is scanned!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugScanAllSetData()               |   Get all the set IDs and their item's itemIds saved to the SavedVars key constant LIBSETS_TABLEKEY_SETITEMIDS,
                                                |   and then compress the itemIds from 1 itemId each to the table LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED, where itemIds
                                                |   which are "in a range" (e.g. 200020, 200021, 200022, 200023) will be saved as 1 String entry with the starting itemId (e.g. 200020)
                                                |   and the number of following itemIds (e.g. 3): "200020, 3" -> This can be "decompressed" again via function LibSets.decompressSetIdItemIds(setId)
                                                |   resulting in the real timeIds 200020, 200020+1=200021, 200020+2=200022 and 200020+3=200023.
                                                |   The real itemIds are cached in the table LibSets.CachedSetItemIdsTable[setId], once the itemIds of a setId were asked for in a session.
                                                |-> This function is not client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllZoneInfo()               |   Get all the zone info saved to the SavedVars key constant LIBSETS_TABLEKEY_ZONE_DATA
                                                |-> This function is not client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllMapNames()               |   Get all the map names saved to the SavedVars key constant LIBSETS_TABLEKEY_MAPS
                                                |   ->  Use /script SetCVar("language.2", "<lang>") (where <lang> is e.g. "de", "en", "fr") to change the client language
                                                |       and then scan the names again with the new client language!
                                                |-> This function IS client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllWayshrineInfo()          |   Get all the wayshrine info saved to the SavedVars key constant LIBSETS_TABLEKEY_WAYSHRINES
                                                |   --> You need to open a map (zone map, no city or sub-zone maps!) in order to let the function work properly
                                                |   ---> The function will try to do this automatically for you at the current zone, if you have not opened the map for any zone
                                                |-> This function is not client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllWayshrineNames()         |   Get all the wayshrine names saved to the SavedVars key constant LIBSETS_TABLEKEY_WAYSHRINE_NAMES
                                                    |-> Use /script SetCVar("language.2", "<lang>") (where <lang> is e.g. "de", "en", "fr") to change the client language
                                                |       and then scan the names again with the new client language!
                                                |-> This function IS client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetDungeonFinderData()         |   Get all the dungeon ids and names saved to the SavedVars key constant LIBSETS_TABLEKEY_DUNGEONFINDER_DATA
                                                |   --->!!!Attention!!!You MUST open the dungeon finder->go to specific dungeon dropdown entry in order to build the dungeons list needed first!!!
                                                |   ---> The function will try to do this automatically for you
                                                |-> This function is not client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllCollectibleNames()       |   Get all the collectible ids and names saved to the SavedVars key constant LIBSETS_TABLEKEY_COLLECTIBLE_NAMES
                                                |   ->  Use /script SetCVar("language.2", "<lang>") (where <lang> is e.g. "de", "en", "fr") to change the client language
                                                |       and then scan the names again with the new client language!
                                                |-> This function IS client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllSetNames()               |   Get all the set names saved to the SavedVars key constant LIBSETS_TABLEKEY_SETNAMES
                                                |   ->  You need to scan the setIds BEFORE (language independent!) to scan all setnames properly afterwards.
                                                |       Use the script /script LibSets.DebugScanAllSetData() to do this.
                                                |   ->  Use /script SetCVar("language.2", "<lang>") (where <lang> is e.g. "de", "en", "fr") to change the client language
                                                |       and then scan the names again with the new client language!
                                                |-> This function IS client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugGetAllNames()                  |   Run the following functions described above:
                                                |   LibSets.DebugGetAllCollectibleNames()
                                                |   LibSets.DebugGetAllMapNames()
                                                |   LibSets.DebugGetAllSetNames()
                                                |   LibSets.DebugGetAllWayshrineNames()
                                                |   LibSets.DebugGetAllZoneInfo()
                                                |-> This function IS client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.debugBuildMixedSetNames()           |    MIXING NEW SET NAMES INTO THE PRELOADED DATA
                                                |    Put other language setNames here in the variable called "otherLangSetNames" below a table key representing the language
                                                |    you want to "mix" into the LibSets_Data_All.lua file's table "lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]" (e.g. ["jp"]).
                                                |    For further details please read the function's description and comments in file LibSets_Debug.lua
                                                |-> This function is not client language dependent!
-------------------------------------------------------------------------------------------------------------------------------------------------
    LibSets.DebugShowNewSetIds()                |    Output the new found (scanned and not inside base LibSets data yet, but only the Savedvariables) setIds to the chat.
-------------------------------------------------------------------------------------------------------------------------------------------------

5) After scanning the data from the game client and updating the SavedVariables file LibSets.lua you got all the data in the following tables now:

LIBSETS_TABLEKEY_SETITEMIDS                     = "setItemIds"
LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED          = "setItemIds_Compressed"
LIBSETS_TABLEKEY_SETNAMES                       = "set" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_MAPS                           = "maps"
LIBSETS_TABLEKEY_WAYSHRINES                     = "wayshrines"
LIBSETS_TABLEKEY_WAYSHRINE_NAMES                = "wayshrine" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_ZONE_DATA                      = "zoneData"
LIBSETS_TABLEKEY_DUNGEONFINDER_DATA             = "dungeonFinderData"
LIBSETS_TABLEKEY_COLLECTIBLE_NAMES              = "collectible" .. LIBSETS_TABLEKEY_NAMES
LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID         = "wayshrineNodeId2zoneId"
LIBSETS_TABLEKEY_MIXED_SETNAMES                 = "MixedSetNamesForDataAll"
-> This is only a "suffix" used for the tablekeys: LIBSETS_TABLEKEY_NAMES= "Names"


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
Be sure to update the columns here like washrines, settype, dlcId, traits needed, isVeteran, the drop zones and drop mechanic + dropmechanic names of the bosses etc.
This info in all the columns from left to right will generate the lua data in the most right columns which your are able to copy to the file LibSets_Data_All.lua at the end!

The new setids are the ones that are, compared to the maximum setId from the existing rows, are higher (newer).
So check the SavedVariables for their names, and information.
-Non existing API information like "traits needed to craft" must be checked ingame at the crafting stations or on websites which provide this information already.
-Wayshrines where the sets can be found/near their crafting station need to be checked on the map and need to be manually entered as well to the data row.
After all info is updated you can look at the columns AX to BB which provide the generated LUA text for the table entries.
--> Copy ALL lines of this excel map to the file "LibSets_Data_All.lua" into the table "lib.setInfo"!
--> New sets which are not known on the live server will automatically be removed as the internal LibSets tables are build (using function "checkIfSetExists(setId)"
    from file LibSets.lua). So just keep them also in this table "lib.SetInfo"!


7) -[ For the set procs ]-
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

LibSets = LibSets or {}
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local apiVersion = GetAPIVersion()

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
local EM = EVENT_MANAGER
local strgmatch = string.gmatch
local strlower = string.lower
--local strlen = string.len
local tins = table.insert
local trem = table.remove
local unp = unpack

------------Global variables--------------
--Get counter suffix
local counterSuffix = lib.counterSuffix or "Counter"

------------The sets--------------
--The preloaded sets data
local preloaded         = lib.setDataPreloaded      -- <-- this table contains all setData (setItemIds, setNames) of the sets, preloaded
--The set data
local setInfo           = lib.setInfo               -- <--this table contains all set information like setId, type, drop zoneIds, wayshrines, etc.
--The special sets
local noSetIdSets       = lib.noSetIdSets           -- <-- this table contains the set information for special sets which got no ESO own unique setId, but a new generated setId starting with 9999xxx

--Wayshrine node index -> zoneId mapping
local wayshrine2zone = preloaded[LIBSETS_TABLEKEY_WAYSHRINENODEID2ZONEID]

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

------------------------------------------------------------------------
--======= SavedVariables ===============================================================================================
--Load the SavedVariables
local function LoadSavedVariables()
    --SavedVars were loaded already before?
    if lib.svData ~= nil then return end
    local defaults =
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
    lib.svData = ZO_SavedVars:NewAccountWide(lib.svName, lib.svVersion, nil, defaults, nil, "$AllAccounts")
end
lib.LoadSavedVariables = LoadSavedVariables


--======= SET ItemId decompression =====================================================================================
--Thanks to Dolgubon for the base function code from his LibLazyCrafting!
--entries in the SavedVariables table lib.svData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED] are of the type
--[setId] = {
--
--}
local CachedSetItemIdsTable = {}
lib.CachedSetItemIdsTable = CachedSetItemIdsTable
local function decompressSetIdItemIds(setId)
	if CachedSetItemIdsTable[setId] then
		return CachedSetItemIdsTable[setId]
	end
	local preloadedSetItemIdsCompressed = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    local IdSource = preloadedSetItemIdsCompressed[setId]
	if not IdSource then
		return
	end
	local workingTable = {}
	for j = 1, #IdSource do
		--Is the itemId a number: Then use the itemId directly
        local itemIdType = type(IdSource[j])
        if itemIdType=="number" then
            workingTable[IdSource[j]] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
        --The itemId is a String (e.g. "200020, 3" -> Means itemId 200020 and 200020+1 and 200020+2 and 200020+3).
        --Split it at the , to get the starting itemId and the number of following itemIds
        elseif itemIdType == "string" then
            local commaSpot = string.find(IdSource[j],",")
			local firstPart = tonumber(string.sub(IdSource[j], 1, commaSpot-1))
			local lastPart = tonumber(string.sub(IdSource[j], commaSpot+1))
			for i = 0, lastPart do
				workingTable[firstPart + i] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
			end
		end
	end
    table.sort(workingTable)
	CachedSetItemIdsTable[setId] = workingTable
	return workingTable
end
lib.DecompressSetIdItemIds = decompressSetIdItemIds

--======= SETS =====================================================================================================
--Check if an itemLink is a set and return the set's data from ESO API function GetItemLinkSetInfo
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Get equipped numbers of a set's itemId, returnin the setId and the item's link + equipped numbers
local function getSetEquippedInfo(itemId)
    if not itemId then return nil, nil, nil end
    local itemLink = lib.buildItemLink(itemId)
    local _, _, setId, _, equippedItems, maxEquipped = checkSet(itemLink)
    return setId, equippedItems, maxEquipped, itemLink
end

--Function to check if a setId is given for the current APIVersion
local function checkIfSetExists(setId)
    if not setId or setId <= 0 then return false end
    local setDoesExist = false
    local preloadedSetInfo      = lib.setInfo
    local preloadedSetItemIds   = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    --SetId is not known in preloaded data?
    if not preloadedSetInfo or not preloadedSetInfo[setId] or not preloadedSetItemIds or not preloadedSetItemIds[setId] then return false end
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
        --No number itemId was found for the set, so decompress the whole setId
        local decompressedSetItemIdsOfSetId = decompressSetIdItemIds(setId)
        for itemId, _ in pairs(decompressedSetItemIdsOfSetId) do
            if itemId and itemId > 0 then
                firstItemIdFound = itemId
                break -- exit the for loop
            end
        end
    end
    if firstItemIdFound ~= nil then
        local itemLink = lib.buildItemLink(firstItemIdFound)
        if itemLink and itemLink ~= "" then
            local isSet, _, _, _, _, _ = checkSet(itemLink)
            isSet = isSet or false
            return isSet
        end
    end
    return setDoesExist
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
                setName = noESOsetIdSetNames[noESOSetId][lib.clientLang] or ""
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


--Check which setIds were found and get the set's info from the preloaded data table "setInfo",
--sort them into their appropriate set table and increase the counter for each table
local function LoadSets()
    if lib.setsScanning then return end
    lib.setsScanning = true
    --Reset variables
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
    --The overall setIds table
    lib.setIds = {}
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
    --Helper function to check the set type and update the tables in the library
    local function checkSetTypeAndUpdateLibTablesAndCounters(setDataTable)
        --Check the setsData and move entries to appropriate table
        for setId, setData in pairs(setDataTable) do
            --Does this setId exist within the current APIVersion?
            if checkIfSetExists(setId) then
                --Add the setId to the setIds table
                lib.setIds[setId] = true
                --Get the type of set and create the entry for the setId in the appropriate table
                local refToSetIdTable
                local setType = setData[LIBSETS_TABLEKEY_SETTYPE]
                if setType ~= nil then
                    local internalLibsSetVariableNames = setTypeToLibraryInternalVariableNames[setType]
                    if internalLibsSetVariableNames and internalLibsSetVariableNames["tableName"] then
                        local internalLibsSetTableName = internalLibsSetVariableNames["tableName"]
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
                    local itemIds = preloadedItemIds[setId]
                    if itemIds == nil then
                        itemIds = preloadedNonESOsetIdItemIds[setId]
                    else
                        --Decompress the real itemIds
                        itemIds = decompressSetIdItemIds(setId)
                    end
                    if itemIds ~= nil then
                        refToSetIdTable[LIBSETS_TABLEKEY_SETITEMIDS] = itemIds
                    end
                    --Get the names stored for the setId and add them to the set's ["names"] table
                    local setNames = preloadedSetNames[setId]
                    if setNames == nil then
                        setNames = preloadedNonESOsetIdSetNames[setId]
                    end
                    if setNames ~= nil then
                        refToSetIdTable[LIBSETS_TABLEKEY_SETNAMES] = setNames
                    end
                    --Is the setsData containing the entry for "allowed proc set in PvP"?
                    if setInfo[setId] ~= nil and (setInfo[setId].isProcSetAllowedInPvP ~= nil and
                        setInfo[setId].isProcSetAllowedInPvP == LIBSETS_SET_ITEMID_TABLE_VALUE_OK) then
                        preloadedSetsWithProcsAllowedInPvP[setId] = refToSetIdTable
                    end
                end
            else
                --Set does not exist, so remove it from the setInfo table and all other "preloaded" tables as well
                setInfo[setId] = nil
                preloadedItemIds[setId] = nil
                CachedSetItemIdsTable[setId] = nil
                preloadedNonESOsetIdItemIds[setId] = nil
                preloadedSetNames[setId] = nil
                preloadedNonESOsetIdSetNames[setId] = nil
                preloadedSetsWithProcsAllowedInPvP[setId] = nil
            end
        end
    end
    --Get the setTypes for the normal ESO setIds
    checkSetTypeAndUpdateLibTablesAndCounters(setInfo)
    --And now get the settypes for the non ESO "self created" setIds
    if noSetIdSets ~= nil then
        checkSetTypeAndUpdateLibTablesAndCounters(noSetIdSets)
    end
    --Update the setType mapping to setType's setId tables within LibSets in order to have the current values, after
    -- they got updated, inside this mapping table. WIll be uised within the local function getSetTypeSetsData which
    -- is used within the API functions to get the set data for the searched LibSets setType
    --Loop over table lib.setTypeToLibraryInternalTableAndCounterNames and for each tableName add the output to
    --lib.setTypeToSetIdsForSetTypeTable:
    for libSetsSetType, libSetsSetTypeVariableData in pairs(setTypeToLibraryInternalVariableNames) do
        if libSetsSetTypeVariableData then
            local libSetsSetTypeTableVariable = libSetsSetTypeVariableData["tableName"]
            if libSetsSetTypeTableVariable then
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

    lib.setsScanning = false
    lib.setsLoaded = true
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
    --itemQualitySubType is used for the itemLinks quality, see UESP website for a description of the itemLink: https://en.uesp.net/wiki/Online:Item_Link
    itemQualitySubType = itemQualitySubType or 366 -- Normal
    --itemQualitySubType values for Level 50 items:
    --return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, itemQualitySubType, ITEMSTYLE_NONE, 0, 10000)
end

--Open the worldmap and show the map of the zoneId
--> Parameters: zoneId number: The zone's zoneId
function lib.openMapOfZoneId(zoneId)
    if not zoneId then return false end
    local mapIndex = GetMapIndexByZoneId(zoneId)
    if mapIndex then
        showWorldMap()
        zo_callLater(function()
            ZO_WorldMap_SetMapByIndex(mapIndex)
        end, 50)
    end
end

--Open the worldmap, get the zoneId of the wayshrine wayshrineNodeId and show the wayshrine wayshrineNodeId on the map
--> Parameters: wayshrineNodeId number: The wayshrine's nodeIndex
function lib.showWayshrineNodeIdOnMap(wayshrineNodeId)
    if not wayshrineNodeId then return false end
    local zoneId = lib.GetWayshrinesZoneId(wayshrineNodeId)
    if not zoneId then return end
    lib.openMapOfZoneId(zoneId)
    zo_callLater(function()
        ZO_WorldMap_PanToWayshrine(wayshrineNodeId)
    end, 100)
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

------------------------------------------------------------------------
-- 	Global set check functions
------------------------------------------------------------------------
--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.craftedSets[setId] ~= nil or false
end

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.monsterSets[setId] ~= nil or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.dungeonSets[setId] ~= nil or false
end

--Returns true if the setId provided is a trial set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isTrialSet, boolean isMultiTrialSet
function lib.IsTrialSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.arenaSets[setId] ~= nil or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.overlandSets[setId] ~= nil or false
end

--Returns true if the setId provided is an cyrodiil set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCyrodiilSet
function lib.IsCyrodiilSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.cyrodiilSets[setId] ~= nil or false
end

--Returns true if the setId provided is a battleground set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isBattlegroundSet
function lib.IsBattlegroundSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.battlegroundSets[setId] ~= nil or false
end

--Returns true if the setId provided is an Imperial City set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isImperialCitySet
function lib.IsImperialCitySet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.imperialCitySets[setId] ~= nil or false
end

--Returns true if the setId provided is a special set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSpecialSet
function lib.IsSpecialSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.specialSets[setId] ~= nil or false
end

--Returns true if the setId provided is a DailyRandomDungeonAndImperialCityRewardSet set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDailyRandomDungeonAndImperialCityRewardSet
function lib.IsDailyRandomDungeonAndImperialCityRewardSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.dailyRandomDungeonAndImperialCityRewardSets[setId] ~= nil or false
end

--Returns true if the setId provided is a mythic set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMythicSet
function lib.IsMythicSet(setId)
    if not checkIfPTSAPIVersionIsLive() then return false end
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.mythicSets[setId] ~= nil or false
end

--Returns true if the setId provided is a non ESO, own defined setId
--See file LibSets_SetData_(APIVersion).lua, table LibSets.lib.noSetIdSets and description above it.
--> Parameters: noESOSetId number: The set's setId
--> Returns:    boolean isNonESOSet
function lib.IsNoESOSet(noESOSetId)
    if noESOSetId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isNoESOSetId = noSetIdSets[noESOSetId] ~= nil or false
    return isNoESOSetId
end

--Returns information about the set if the itemId provides it is a set item
--> Parameters: itemId number: The item's itemId
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemId(itemId)
    if itemId == nil then return end
    local itemLink = lib.buildItemLink(itemId)
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
        isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkNoSetIdSet(itemId)
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
	if not lib.checkIfSetsAreLoadedProperly() then return false end
	local isVeteranSet = false
	if setId and itemLink then
		local setData = setInfo[setId] or noSetIdSets[setId]
		if setData then
			local veteranData = setData.veteran
			if veteranData then
				if type(veteranData) == "table" then
					local equipType = GetItemLinkEquipType(itemLink)
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
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId or not armorType then return end
    return lib.armorTypesSets[armorType][setId] or false
end

--Returns true/false if the set got items with light armor
--> Parameters: setId number: The set's setId
--> Returns:    isLightArmorSet boolean
function lib.IsLightArmorSet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_LIGHT][setId] or false
end

--Returns true/false if the set got items with medium armor
--> Parameters: setId number: The set's setId
--> Returns:    isMediumArmorSet boolean
function lib.IsMediumArmorSet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_MEDIUM][setId] or false
end

--Returns true/false if the set got items with heavy armor
--> Parameters: setId number: The set's setId
--> Returns:    isHeavyArmorSet boolean
function lib.IsHeavyArmorSet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.armorTypesSets[ARMORTYPE_HEAVY][setId] or false
end

--Returns true/false if the set got items with armor
--> Parameters: setId number: The set's setId
--> Returns:    isArmorSet boolean
function lib.IsArmorSet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.armorSets[setId] or false
end

--Returns true/false if the set got items with jewelry
--> Parameters: setId number: The set's setId
--> Returns:    isJewelrySet boolean
function lib.IsJewelrySet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.jewelrySets[setId] or false
end

--Returns true/false if the set got items with weapons
--> Parameters: setId number: The set's setId
--> Returns:    isWeaponSet boolean
function lib.IsWeaponSet(setId)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId then return end
    return lib.weaponSets[setId] or false
end

--Returns true/false if the set got items with a given weaponType
--> Parameters: setId number: The set's setId
-->             weaponType number: The weaponType to check for
--> Returns:    isWeaponTypeSet boolean
function lib.IsWeaponTypeSet(setId, weaponType)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId or not weaponType then return end
    return lib.weaponTypesSets[weaponType][setId] or false
end

--Returns true/false if the set got items with a given equipType
--> Parameters: setId number: The set's setId
-->             equipType number: The equipType to check for
--> Returns:    isEquipTypeSet boolean
function lib.IsEquipTypeSet(setId, equipType)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not setId or not equipType then return end
    return lib.equipTypesSets[equipType][setId] or false
end


------------------------------------------------------------------------
-- 	Global set get data functions
------------------------------------------------------------------------
--Returns a table of setIds where the set got items with a given armorType
--> Parameters: armorType number: The armorType to check for
--> Returns:    armorTypeSetIds table
function lib.GetAllArmorTypeSets(armorType)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not armorType then return end
    return lib.armorTypesSets[armorType]
end

--Returns a table of setIds where the set got items with an armorType
--> Returns:    armorSet table
function lib.GetAllArmorSets()
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    return lib.armorSets
end

--Returns a table of setIds where the set got items with a jewelryType
--> Returns:    jewelrySets table
function lib.GetAllJewelrySets()
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    return lib.jewelrySets
end


--Returns a table of setIds where the set got items with a weaponType
--> Returns:    weaponSets table
function lib.GetAllWeaponSets()
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    return lib.weaponSets
end

--Returns a table of setIds where the set got items with a given weaponType
--> Parameters: weaponType number: The weaponType to check for
--> Returns:    weaponTypeSetIds table
function lib.GetAllWeaponTypeSets(weaponType)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
    if not weaponType then return end
    return lib.weaponTypesSets[weaponType]
end

--Returns a table of setIds where the set got items with a given equipType
--> Parameters: equipType number: The equipType to check for
--> Returns:    equipTypeSetIds table
function lib.GetAllEquipTypeSets(equipType)
    if not lib.checkIfSetsAreLoadedProperly() then return false end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    --Get the zoneId for each wayshrineNodeId, read it from the preloaded setdata
    if not wayshrine2zone then return end
    return wayshrine2zone[wayshrineNodeId]
end

--Returns the drop zoneIds as table for the setId
--> Parameters: setId number: The set's setId
--> Returns:    zoneIds table, or NIL if set's DLCid is unknown
function lib.GetZoneIds(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData[LIBSETS_TABLEKEY_ZONEIDS] == nil then return end
    return setData[LIBSETS_TABLEKEY_ZONEIDS]
end

--Returns the dlcId as number for the setId
--> Parameters: setId number: The set's setId
--> Returns:    dlcId number, or NIL if set's DLCid is unknown
function lib.GetDLCId(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData.dlcId == nil then return end
    return setData.dlcId
end

--Returns Boolean true/false if the set's dlcId is the currently active DLC.
--Means the set is "new added with this DLC".
--> Parameters: setId number: The set's setId
--> Returns:    wasAddedWithCurrentDLC Boolean, or NIL if set's DLCid is unknown
function lib.IsCurrentDLC(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData.dlcId == nil then return end
    local wasAddedWithCurrentDLC = (DLC_ITERATION_END and setData.dlcId >= DLC_ITERATION_END) or false
    return wasAddedWithCurrentDLC
end

--Returns the table of DLCIDs of LibSets (the constants in LibSets.allowedDLCIds, see file LibSets_ConstantsLibraryInternal.lua)
function lib.GetAllDLCIds()
    return lib.allowedDLCIds
end

--Returns the number of researched traits needed to craft this set. This will only check the craftable sets!
--> Parameters: setId number: The set's setId
--> Returns:    traitsNeededToCraft number
function lib.GetTraitsNeeded(setId)
    if setId == nil then return end
    if not lib.IsCraftedSet(setId) then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil then
        if lib.IsNoESOSet(setId) then
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
    lang = lang or lib.clientLang
    lang = string.lower(lang)
    if not lib.supportedLanguages[lang] then return end
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

--Returns the dropMechanicIDs of the setId!
--> Parameters: setId number:           The set's setId
-->             withNames bolean:       Should the function return the dropMechanic names as well?
--> Returns:    LibSetsDropMechanicIds  table, LibSetsDropMechanicNamesForEachId table, LibSetsDropMechanicTooltipForEachId table
---> table LibSetsDropMechanicIds: The key is a number starting at 1 and increasing by 1, and the value is one of the dropMechanics
---> of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
---> table LibSetsDropMechanicNamesForEachId: The key is the dropMechanicId (value of each line in table LibSetsDropMechanicIds)
---> and the value is a subtable containing each language as key and the localized String as the value.
---> table LibSetsDropMechanicTooltipForEachId: The key is the dropMechanicId (value of each line in table LibSetsDropMechanicIds)
---> and the value is a subtable containing each language as key and the localized String as the value.
function lib.GetDropMechanic(setId, withNames)
    if setId == nil then return nil, nil end
    if not lib.checkIfSetsAreLoadedProperly() then return nil, nil end
    withNames = withNames or false
    local setData = setInfo[setId]
    if setData == nil then
        if lib.IsNoESOSet(setId) then
            setData = noSetIdSets[setId]
        else
            return
        end
    end
    if setData == nil or setData[LIBSETS_TABLEKEY_DROPMECHANIC] == nil then return nil, nil end
    local dropMechanicIds = setData[LIBSETS_TABLEKEY_DROPMECHANIC]
    local dropMechanicNames
    local dropMechanicTooltips
    if withNames then
        if setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] ~= nil and setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]["en"] ~= nil then
            dropMechanicNames = setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]
            if setData[LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES] ~= nil and setData[LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES]["en"] ~= nil then
                dropMechanicTooltips =  setData[LIBSETS_TABLEKEY_DROPMECHANIC_TOOLTIP_NAMES]
            end
        else
            dropMechanicNames = {}
            dropMechanicTooltips = {}
            local supportedLanguages = lib.supportedLanguages
            if supportedLanguages then
                for _, dropMechanicEntry in ipairs(dropMechanicIds) do
                    for supportedLanguage, isSupported in pairs(supportedLanguages) do
                        dropMechanicNames[dropMechanicEntry] = dropMechanicNames[dropMechanicEntry] or {}
                        dropMechanicTooltips[dropMechanicEntry] = dropMechanicTooltips[dropMechanicEntry] or {}
                        if isSupported then
                            local dropMechanicName, dropMechanicTooltip = lib.GetDropMechanicName(dropMechanicEntry, supportedLanguage)
                            dropMechanicNames[dropMechanicEntry][supportedLanguage] = dropMechanicName
                            dropMechanicTooltips[dropMechanicEntry][supportedLanguage] = dropMechanicTooltip
                        end
                    end
                end
            end
        end
    end
    return dropMechanicIds, dropMechanicNames, dropMechanicTooltips
end

--Returns the name of the drop mechanic ID (a drop locations boss, city, email, ..)
--> Parameters: dropMechanicId number: The LibSetsDropMechanidIc (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
-->             lang String: The 2char language String for the used translation. If left empty the current client's
-->             language will be used.
--> Returns:    String dropMachanicNameLocalized: The name fo the LibSetsDropMechanidIc, String dropMechanicNameTooltipLocalized: The tooltip of the dropMechanic
function lib.GetDropMechanicName(libSetsDropMechanicId, lang)
    if libSetsDropMechanicId == nil or libSetsDropMechanicId <= 0 then return end
    local allowedDropMechanics = lib.allowedDropMechanics
    if not allowedDropMechanics[libSetsDropMechanicId] then return end
    lang = lang or lib.clientLang
    lang = string.lower(lang)
    if not lib.supportedLanguages[lang] then return end
    local dropMechanicNames = lib.dropMechanicIdToName[lang]
    local dropMechanicTooltipNames = lib.dropMechanicIdToNameTooltip[lang]
    if dropMechanicNames == nil or dropMechanicTooltipNames == nil then return false end
    local dropMechanicName = dropMechanicNames[libSetsDropMechanicId]
    local dropMechanicTooltip = dropMechanicTooltipNames[libSetsDropMechanicId]
    if not dropMechanicName or dropMechanicName == "" then return end
    return dropMechanicName, dropMechanicTooltip
end

--Returns the table of dropMechanics of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
function lib.GetAllDropMechanics()
    return lib.allowedDropMechanics
end

--Returns a sorted table of all set ids. Key is the setId, value is the boolean value true.
--Attention: The table can have a gap in it's index as not all setIds are gap-less in ESO!
--> Returns: setIds table
function lib.GetAllSetIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.setIds
end

--Returns all sets itemIds as table. Key is the setId, value is a subtable with the key=itemId and value = boolean value true.
--> Returns: setItemIds table
function lib.GetAllSetItemIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    --Decompress all the setId's itemIds (if not already done before)
    --and create the whole cached table CachedSetItemIdsTable this way
    for setId, isActive in pairs(lib.setIds) do
        if isActive == true then
            decompressSetIdItemIds(setId)
        end
    end
    return CachedSetItemIdsTable
end

--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.
--The key is the itemId and the value is the boolean value true
--> Parameters: setId number: The set's setId
-->             isSpecialSet boolean: Read the set's itemIds from the special sets table or the normal?
--> Returns:    table setItemIds = {[setItemId1]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK,[setItemId2]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK, ...}
function lib.GetSetItemIds(setId, isNoESOSetId)
    if setId == nil then return end
    isNoESOSetId = isNoESOSetId or false
    if isNoESOSetId == false then
        isNoESOSetId = lib.IsNoESOSet(setId)
    end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemIds
    if isNoESOSetId == true then
        if preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID][setId] ~= nil then
            setItemIds = preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID][setId]
        end
    else
        setItemIds = decompressSetIdItemIds(setId)
    end
    if setItemIds == nil then return end
    return setItemIds
end

--If the setId only got 1 itemId this function returns this itemId of the setId provided.
--If the setId got several itemIds this function returns one random itemId of the setId provided (depending on the 2nd parameter equipType)
--If the 2nd parameter equipType is not specified: The first random itemId found will be returned
--If the 2nd parameter equipType is specified:  Each itemId of the setId will be turned into an itemLink where the given equipType is checked against.
--If the 3rd to ... parameter *Type is specified: Each itemId of the setId will be turned into an itemLink where the given *type is cheched against.
--Only the itemId where the parameters fits will be returned. Else the return value will be nil
--> Parameters: setId number: The set's setId
-->             equipType optional number: The equipType to check the itemId against
-->             traitType optional number: The traitType to check the itemId against
-->             enchantSearchCategoryType optional EnchantmentSearchCategoryType: The enchanting search category to check the itemId against
--> Returns:    number setItemId
function lib.GetSetItemId(setId, equipType, traitType, enchantSearchCategoryType)
    if setId == nil then return end
    local equipTypesValid = lib.equipTypesValid
    local traitTypesValid = lib.traitTypesValid
    local enchantSearchCategoryTypesValid = lib.enchantSearchCategoryTypesValid
    local equipTypeValid = false
    local traitTypeValid = false
    local enchantSearchCategoryTypeValid = false

    if equipType ~= nil then
        equipTypeValid = equipTypesValid[equipType] or false
    end
    if traitType ~= nil then
        traitTypeValid = traitTypesValid[traitType] or false
    end
    if enchantSearchCategoryType ~= nil then
        enchantSearchCategoryTypeValid = enchantSearchCategoryTypesValid[enchantSearchCategoryType] or false
    end

    local setItemIds = lib.GetSetItemIds(setId)
    if not setItemIds then return end

    local needItemLinkOfItemId = (equipTypeValid == true or traitTypeValid == true or enchantSearchCategoryTypeValid == true) or false
    local returnGenericItemId = true
    if needItemLinkOfItemId == true then
        returnGenericItemId = false
    end

    for setItemId, isCorrect in pairs(setItemIds) do
        --Anything we need an itemlink for?
        if needItemLinkOfItemId == true then
            --Create itemLink of the itemId
            local itemLink = lib.buildItemLink(setItemId)
            if itemLink ~= nil and itemLink ~= "" then
                local isValidItemId = false

                if equipTypeValid == true then
                    local ilEquipType = GetItemLinkEquipType(itemLink)
                    if ilEquipType ~= nil and ilEquipType == equipType then isValidItemId = true end
                end
                if isValidItemId == true and traitTypeValid == true then
                    local ilTraitType = GetItemLinkTraitType(itemLink)
                    if ilTraitType ~= nil and ilTraitType == traitType then isValidItemId = true end
                end
                if isValidItemId == true and enchantSearchCategoryTypeValid == true then
                    local ilenchantId = GetItemLinkDefaultEnchantId(itemLink)
                    local ilenchantSearchCategoryType = GetEnchantSearchCategoryType(ilenchantId)
                    if ilenchantSearchCategoryType ~= nil and ilenchantSearchCategoryType == enchantSearchCategoryType then isValidItemId = true end
                end
                if isValidItemId == true then
                    return setItemId
                end
            end
        end
        if returnGenericItemId == true then
            if setItemId ~= nil and isCorrect == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then return setItemId end
        end
    end --for
    return
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
    lang = string.lower(lang)
    if not lib.supportedLanguages[lang] then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = {}
    if lib.IsNoESOSet(setId) then
        setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
    else
        setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
    end
    if setId == nil or setNames[setId] == nil or setNames[setId][lang] == nil then return end
    return setNames[setId][lang]
end

--Returns all names as String of the setId provided.
--The table returned uses the key=language (2 characters String e.g. "en") and the value = name String, e.g.
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = {}
    if lib.IsNoESOSet(setId) then
        setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES_NO_SETID]
    else
        setNames = preloaded[LIBSETS_TABLEKEY_SETNAMES]
    end
    if setNames[setId] == nil then return end
    return setNames[setId]
end

--Returns all sets names as table.
--The table returned uses the key=language (2 characters String e.g. "en") and the value = name String, e.g.
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}
--> Returns: setNames table
function lib.GetAllSetNames()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = {}
    local setIds = lib.GetAllSetIds()
    if not setIds then return end
    for setId, isActive in pairs(setIds) do
        if isActive == true then
            local setNamesOfSetId = lib.GetSetNames(setId)
            if setNamesOfSetId then
                setNames[setId] = setNamesOfSetId
            end
        end
    end
    return setNames
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
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
--->  table dropMechanicNames: The key is the dropMechanicId (value of each line in table dropMechanics) and the value is a subtable containing each language as key
-----> and the localized String as the value.
-------Example for setId 408
--- ["setId"] = 408,
--- ["dlcId"] = 12,    --DLC_MURKMIRE
--	["setType"] = LIBSETS_SETTYPE_CRAFTED,
--	[LIBSETS_TABLEKEY_SETITEMIDS] = {
--      table [#0,370]
--  },
--	[LIBSETS_TABLEKEY_SETNAMES] = {
--		["de"] = "Grabpflocksammler"
--		["en"] = "Grave-Stake Collector"
--		["fr"] = "Collectionneur de marqueurs funéraires"
--  },
--	["traitsNeeded"] = 7,
--	["veteran"] = false,
--	["wayshrines"] = {
--		[1] = 375
--		[2] = 375
--		[3] = 375
--  },
--	["zoneIds"] = {
--		[1] = 726,
--  },
--  ["dropMechanic"] = {
--      [1] = LIBSETS_DROP_MECHANIC_MONSTER_NAME,
--      [2] = LIBSETS_DROP_MECHANIC_...,
--  },
--  ["dropMechanicNames"] = {
--      ["en"] = "DropMechanicNameEN",
--      ["de"] = "DropMechanicNameDE",
--      ["fr"] = "DropMechanicNameFR",
--  },
--}
function lib.GetSetInfo(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isNonEsoSetId = lib.IsNoESOSet(setId)
    local setInfoTable
    local itemIds
    local setNames
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
    local dropMechanicNamesTable
    if setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC] ~= nil then
        local dropMechanicTable = setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC]
        --For each entry in the drop mechanic table:
        for _, dropMechanic in ipairs(dropMechanicTable) do
            --The drop mechanic is no monster name, so get the names of the drop mechanic via LibSets API function
            if dropMechanic ~= LIBSETS_DROP_MECHANIC_MONSTER_NAME then
                local supportedLanguages = lib.supportedLanguages
                if supportedLanguages then
                    for supportedLanguage, isSupported in pairs(supportedLanguages) do
                        if isSupported then
                            dropMechanicNamesTable = dropMechanicNamesTable or {}
                            dropMechanicNamesTable[dropMechanic] = {}
                            dropMechanicNamesTable[dropMechanic][supportedLanguage] = lib.GetDropMechanicName(dropMechanic, supportedLanguage)
                        end
                    end
                end
            else
                --DropMechanic is a monster's name: So use the specified names from the setInfo's table LIBSETS_TABLEKEY_DROPMECHANIC_NAMES
                if setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] ~= nil and setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]["en"] ~= nil then
                    dropMechanicNamesTable = dropMechanicNamesTable or {}
                    dropMechanicNamesTable[dropMechanic] = setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]
                end
            end
        end
    end
    setInfoTable[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] = dropMechanicNamesTable
    --itemIds = preloaded[preloadedSetItemIdsTableKey][setId]
    if isNonEsoSetId == true then
        itemIds = preloaded[preloadedSetItemIdsTableKey][setId]
    else
        itemIds = decompressSetIdItemIds(setId)
    end
    setNames = preloaded[preloadedSetNamesTableKey][setId]
    if itemIds then setInfoTable[LIBSETS_TABLEKEY_SETITEMIDS] = itemIds end
    if setNames then setInfoTable[LIBSETS_TABLEKEY_SETNAMES] = setNames end
    local isCurrentDLC = (DLC_ITERATION_END and setInfoTable["dlcId"] and setInfoTable["dlcId"] >= DLC_ITERATION_END) or false
    setInfoTable.isCurrentDLC = isCurrentDLC
    return setInfoTable
end

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
        local itemLink = lib.buildItemLink(itemId)
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

--Returns the armor types of a set's item
--> Parameters: itemId number: The set item's itemId
--> Returns:    number armorTypeOfSetItem: The armorType (https://wiki.esoui.com/Globals#ArmorType) of the setItem
function lib.GetItemsArmorType(itemId)
    --Build an itemLink from the itemId
    local itemLink = lib.buildItemLink(itemId)
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
        local itemLink = lib.buildItemLink(itemId)
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
    local itemLink = lib.buildItemLink(itemId)
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


------------------------------------------------------------------------
-- 	Global set misc. functions
------------------------------------------------------------------------
--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil or setInfo[setId] == nil or setInfo[setId][LIBSETS_TABLEKEY_WAYSHRINES] == nil then return false end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    --Then use the faction Id 1 (AD), 2 (DC) to 3 (EP)
    factionIndex = factionIndex or 1
    if factionIndex < 1 or factionIndex > 3 then factionIndex = 1 end
    local jumpToNode = -1
    local setWayshrines
    if lib.IsNoESOSet(setId) then
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
    if not lib.DLCData then return end
    local dlcName = lib.DLCData[dlcId] or ""
    return dlcName
end

--Returns the name of the DLC by help of the DLC id
--> Parameters: undauntedChestId number: The undaunted chest id given in a set's info
--> Returns:    name undauntedChestName
function lib.GetUndauntedChestName(undauntedChestId, lang)
    if undauntedChestId < 1 or undauntedChestId > lib.countUndauntedChests then return end
    lang = lang or lib.clientLang
    lang = string.lower(lang)
    if not lib.supportedLanguages[lang] then return end
    if not lib.undauntedChestIds or not lib.undauntedChestIds[lang] or not lib.undauntedChestIds[lang][undauntedChestId] then return end
    local undauntedChestNameLang = lib.undauntedChestIds[lang]
    --Fallback language "EN"
    if not undauntedChestNameLang then undauntedChestNameLang = lib.undauntedChestIds["en"] end
    return undauntedChestNameLang[undauntedChestId]
end

--Returns the name of the zone by help of the zoneId
--> Parameters: zoneId number: The zone id given in a set's info
-->             language String: ONLY possible to be used if additional library "LibZone" (https://www.esoui.com/downloads/info2171-LibZone.html) is activated
--> Returns:    name zoneName
function lib.GetZoneName(zoneId, lang)
    if not zoneId then return end
    lang = lang or lib.clientLang
    lang = string.lower(lang)
    local zoneName = ""
    if lib.libZone ~= nil then
        zoneName = lib.libZone:GetZoneName(zoneId, lang)
    else
        zoneName = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(zoneId) )
    end
    return zoneName
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
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Item set collections functions
------------------------------------------------------------------------
--Local helper function to open the categoryData of a categoryId in the item set collections book UI
local function openItemSetCollectionBookOfZoneCategoryData(categoryId)
    local itemSetCollectionCategoryDataOfParentZone = lib.GetItemSetCollectionCategoryData(categoryId)
    if not itemSetCollectionCategoryDataOfParentZone then return end
    local retVar = lib.OpenItemSetCollectionBookOfCategoryData(itemSetCollectionCategoryDataOfParentZone)
    return retVar
end


--Get the current map's zoneIndex and via the index get the zoneId, the parent zoneId, and return them
--+ the current zone's index and parent zone index
--> Returns: number currentZoneId, number currentZoneParentId, number currentZoneIndex, number currentZoneParentIndex
function lib.GetCurrentZoneIds()
    local currentZoneIndex = GetCurrentMapZoneIndex()
    local currentZoneId = GetZoneId(currentZoneIndex)
    local currentZoneParentId = GetParentZoneId(currentZoneId)
    local currentZoneParentIndex = GetZoneIndex(currentZoneParentId)
    return currentZoneId, currentZoneParentId, currentZoneIndex, currentZoneParentIndex
end


--Returns the zoneIds (table) which are linked to a item set collection's categoryId
--Not all categories are connected to a zone though! The result will be nil in these cases.
--Example return table: {148}
function lib.GetItemSetCollectionZoneIds(categoryId)
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if categoryId == nil then return end
    if lib.setItemCollectionCategory2ZoneId[categoryId] then
        return lib.setItemCollectionCategory2ZoneId[categoryId]
    end
    return
end

--Returns the categoryIds (table) which are linked to a item set collection's zoneId
--Not all zoneIds are connected to a category though! The result will be nil in these cases.
--Example return table: {39}
function lib.GetItemSetCollectionCategoryIds(zoneId)
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if zoneId == nil then return end
    if lib.setItemCollectionZoneId2Category[zoneId] then
        return lib.setItemCollectionZoneId2Category[zoneId]
    end
    return
end

--Returns the parent category data (table) containing the zoneIds, and possible boolean parameters
--isDungeon, isArena, isTrial of ALL categoryIds below this parent -> See file LibSets_data_all.lua ->
--table lib.setDataPreloaded -> table key LIBSETS_TABLEKEY_SET_ITEM_COLLECTIONS_ZONE_MAPPING
--Example return table: { parentCategory=5, category=39, zoneIds={148}, isDungeon=true},--Arx Corinium
function lib.GetItemSetCollectionParentCategoryData(parentCategoryId)
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if categoryId == nil then return end
    if lib.setItemCollectionCategories[categoryId] then
        return lib.setItemCollectionCategories[categoryId]
    end
    return
end

--Open a node in the item set collections book for teh given category data table
-->the table categoryData must be determined via lib.GetItemSetCollectionCategoryData before
-->categoryData.parentId must be given and > 0! categoryData.category can be nil or <= 0, then the parentId will be shown
function lib.OpenItemSetCollectionBookOfCategoryData(categoryData)
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
            return lib.OpenItemSetCollectionBookOfCategoryData(categoryData)
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

--Open the item set collections book of the current parentZoneId. If more than 1 categoryId was found for the parentZoneId,
--the 1st will be opened!
function lib.OpenItemSetCollectionBookOfCurrentParentZone()
    local _, currentParentZone, _, _ = lib.GetCurrentZoneIds()
    if not currentParentZone or currentParentZone <= 0 then return end
    local categoryIdsOfParentZone = lib.GetItemSetCollectionCategoryIds(currentParentZone)
    if not categoryIdsOfParentZone then return end
    if #categoryIdsOfParentZone == 1 then
        return openItemSetCollectionBookOfZoneCategoryData(categoryIdsOfParentZone[1])
    else
        for _, categoryId in ipairs(categoryIdsOfParentZone) do
            if openItemSetCollectionBookOfZoneCategoryData(categoryId) then
                return true
            end
        end
        return false
    end
end

--Open the item set collections book of the current zoneId. If more than 1 categoryId was found for the zoneId,
--the 1st will be opened!
function lib.OpenItemSetCollectionBookOfCurrentZone()
    local currentZone, _, _, _ = lib.GetCurrentZoneIds()
    if not currentZone or currentZone <= 0 then return end
    local categoryIdsOfZone = lib.GetItemSetCollectionCategoryIds(currentZone)
    if not categoryIdsOfZone then return end
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


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- 	Set PROC functions
------------------------------------------------------------------------
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isSetWithProcAllowedInPvP = ( preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP] ~= nil and preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP][setId] ~= nil ) or false
    return isSetWithProcAllowedInPvP
end

--Returns the setsData of all the setIds which are allowed proc sets in PvP/AvA campaigns
--> Parameters: none
--> Returns:    nilable:LibSetsAllSetProcDataAllowedInPvP table
function lib.GetAllSetDataWihtProcAllowedInPvP()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return preloaded[LIBSETS_TABLEKEY_SET_PROCS_ALLOWED_IN_PVP]
end

------------------------------------------------------------------------------------------------------------------------

--Returns true if the setId provided got a set proc
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSetWithProc
function lib.IsSetWithProc(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isSetWithProc = ( preloaded[LIBSETS_TABLEKEY_SET_PROCS] ~= nil and preloaded[LIBSETS_TABLEKEY_SET_PROCS][setId] ~= nil ) or false
    return isSetWithProc
end


--Returns the procData of all the setIds
--> Parameters: none
--> Returns:    nilable:LibSetsAllSetProcData table
function lib.GetAllSetProcData()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return preloaded[LIBSETS_TABLEKEY_SET_PROCS]
end


--Returns the procData of the setId as table, containing the abilityIds, unitTag, cooldown, icon, etc.
--> Parameters: setId number: The set's setId
--> Returns:    nilable:LibSetsSetProcData table
--[[
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
]]
function lib.GetSetProcData(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
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
        uniqueAddonNamespaceEventName = uniqueAddonNamespaceEventName .. "_" .. tostring(abilityId)
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

--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not
--> Returns:    boolean isCurrentlySetsScanning
function lib.IsSetsScanning()
    return lib.setsScanning
end

--Returns a boolean value, true if the sets database is properly loaded yet and is not currently scanning
--or false if not.
--This functions combines the result values of the functions LibSets.AreSetsLoaded() and LibSets.IsSetsScanning()
function lib.checkIfSetsAreLoadedProperly()
    if lib.IsSetsScanning() or not lib.AreSetsLoaded() then return false end
    return true
end


--SLASH COMMANDS
local function slash_help()
    d(">>> [" .. lib.name .. "] |c0000FFSlash command help -|r BEGIN >>>")
    d("|-> \'resetsv\'              Resets the SavedVariables")
    d("|-> \'getall\'               Scan all set's and itemIds, maps, zones, wayshrines, dungeons, update the language dependent variables and put them into the SavedVariables.\n|cFF0000Attention:|r |cFFFFFFThe UI will reload several times for the supported languages of the library!|r")
    d("|-> \'scanitemids\'          Scan all itemIds of sets")
    d("|-> \'getallnames\'          Get all names (sets, zones, maps, wayshrines, DLCs) of the current client language")
    d("|-> \'getzones\'             Get all zone data")
    d("|-> \'getmapnamess\'         Get all map names of the current client language")
    d("|-> \'getwayshrines\'        Get all wayshrine data of the currently shown zone. If the map is not opened it will be opened")
    d("|-> \'getwayshrinenames\'    Get all wayshrine names of the current client language")
    d("|-> \'getsetnames\'          Get all set names of the current client language")
    d("|-> \'shownewsets\'          Show the new setIds and names of sets which were scanned and found but not transfered to the preoaded data yet. Needs to run \'scanitemids\' first!")
    d("|-> \'getdungeons\'          Get the dungeon data. If the dungeon's view at the group window is not yet opened it will be opened.")
    d("|-> \'getcollectiblenames\'  Get the collectible names of all collectibles of the current client language.")
    d("|-> \'getdlcnames\'          Get the DLC collectible names of the current client language.")
    d("<<< [" .. lib.name .. "] |c0000FFSlash command help -|r END <<<")
end

local function command_handler(args)
    --Parse the arguments string
    local options = {}
    --local searchResult = {} --old: searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for param in strgmatch(args, "([^%s]+)%s*") do
        if (param ~= nil and param ~= "") then
            local paramBoolOrOther = toboolean(strlower(param))

            options[#options+1] = paramBoolOrOther
        end
    end

    --Possible parameters
    -->help
    local callHelpParams = {
        help    = true,
        hilfe   = true,
        list    = true,
        aide    = true,
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


    --Help / status
    local firstParam = options and options[1]
    if #options == 0 or firstParam == nil or firstParam == "" or callHelpParams[firstParam] == true then
        slash_help()
    elseif firstParam ~= nil and firstParam ~= "" then
        local debugFunc = callDebugParams[firstParam]
        if debugFunc ~= nil then
            trem(options, 1)
            if lib[debugFunc] ~= nil then
                lib[debugFunc](unp(options))
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
end


local function onPlayerActivated(eventId, isFirst)
    EM:UnregisterForEvent(MAJOR, EVENT_PLAYER_ACTIVATED)

    if lib.debugGetAllDataIsRunning == true then
        --Continue to get all data until it is finished
        d("[" .. lib.name .."]Resuming scan of \'DebugGetAllData\' after reloadui - language now: " ..tostring(lib.clientLang))
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
    lib.libZone = LibZone

    --The actual clients language
    lib.clientLang = GetCVar("language.2")
    lib.clientLang = string.lower(lib.clientLang)
    if not lib.supportedLanguages[lib.clientLang] then
        lib.clientLang = "en" --Fallback language if client language is not supported: English
    end

    --The actual API version
    lib.APIVersions["live"] = lib.APIVersions["live"] or GetAPIVersion()
    lib.currentAPIVersion = lib.APIVersions["live"]

    --Check if any tasks are active via the SavedVariables -> Debug reloadUIs e.g.
    local goOn = false
    LoadSavedVariables()

    --Is the DebugGetAllData function running and reloadUI's are done? -> See EVENT_PLAYER_ACTIVATED then
    lib.debugGetAllDataIsRunning = false
    if lib.svData and lib.svData.DebugGetAllData and lib.svData.DebugGetAllData[apiVersion] then
        if lib.svData.DebugGetAllData[apiVersion].running == true and lib.svData.DebugGetAllData[apiVersion].finished == false then
            lib.debugGetAllDataIsRunning = true
            goOn = false
            EM:RegisterForEvent(MAJOR, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
        elseif not lib.svData.DebugGetAllData[apiVersion].running or lib.svData.DebugGetAllData[apiVersion].finished == true then
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

        --Slash commands
        createSlashCommands()

        --All library data was loaded and scanned, so set the variables to "successfull" now, in order to let the API functions
        --work properly now
        lib.fullyLoaded = true
    end
end

--Load the addon now
EM:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, onLibraryLoaded)
