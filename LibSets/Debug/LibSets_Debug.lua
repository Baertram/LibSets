--[[
   [LibSets - Debug functions]

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
    LibSets.DebugGetAllWayshrineInfoOfCurrentMap() |   Get all the wayshrine info saved to the SavedVars key constant LIBSETS_TABLEKEY_WAYSHRINES
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
]]


--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

local lib = LibSets
local MAJOR = lib.name
local MINOR = lib.version

local LoadSavedVariables = lib.LoadSavedVariables

local EM = EVENT_MANAGER

local tos = tostring
local ton = tonumber
---local strgmatch = string.gmatch
--local strlower = string.lower
--local strlen = string.len
--local strfind = string.find
--local strsub = string.sub
local strfor = string.format

local tins = table.insert
--local trem = table.remove
local tsort = table.sort
--local unp = unpack
local zostrfor = zo_strformat
local zocstrfor = ZO_CachedStrFormat

local gzidx = GetZoneIndex
local gzid = GetZoneId
local gpzid = GetParentZoneId
local gcmzidx = GetCurrentMapZoneIndex
local gmidbzid = GetMapIndexByZoneId
local gmnbid = GetMapNameById
--local gznbid = GetZoneNameById
local gznbidx = GetZoneNameByIndex
local gnz = GetNumZones
local gftninf = GetFastTravelNodeInfo
local gnftn = GetNumFastTravelNodes

local gilsetinf = GetItemLinkSetInfo
local gilat = GetItemLinkArmorType
local gilwt = GetItemLinkWeaponType
local gilet = GetItemLinkEquipType
local gilit = GetItemLinkItemType
local isilc = IsItemLinkCrafted

local unknownName = "n/a"

local worldName = GetWorldName()
local apiVersion = GetAPIVersion()
local isPTSAPIVersionLive = lib.checkIfPTSAPIVersionIsLive()
local clientLang = lib.clientLang or GetCVar("language.2")
local fallbackLang = lib.fallbackLang
local supportedLanguages = lib.supportedLanguages
local numSupportedLangs = lib.numSupportedLangs
local nonOfficialLanguages = lib.nonOfficialLanguages

local decompressSetIdItemIds = lib.DecompressSetIdItemIds
local buildItemLink = lib.buildItemLink
local isSetByItemId = lib.IsSetByItemId

--Reused strings
local libPrefix = lib.prefix
local libPrefixWithVersion = "[".. MAJOR .. " v" .. tos(MINOR).."]"
local storedInSVFileLibSetsInTable = "->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table "
local pleaseReloadUI = ">Please do a /reloadui to update the file properly!"

-------------------------------------------------------------------------------------------------------------------------------
-- Data update functions - Only for developers of this lib to get new data from e.g. the PTS or after major patches on live.
-- e.g. to get the new wayshrines names and zoneNames
-- Uncomment to use them via the libraries global functions then
-------------------------------------------------------------------------------------------------------------------------------
local debugOutputStartLine = "==============================\n"
local newSetIdsFound = {}

local function getFirstEntryOfTable(tabName, keyOrValue)
    if not tabName then return end
    keyOrValue = keyOrValue or false
    for k, v in pairs(tabName) do
        if keyOrValue == true then
            return k
        else
            return v
        end
    end
end

local function MyCombineNonContiguousTables(dest, ...)
    if ... == nil then return dest end
    for sourceTableIndex = 1, select("#", ...) do
        local sourceTable = select(sourceTableIndex, ...)
        if sourceTable ~= nil then
            for key, data in pairs(sourceTable) do
                --assert(dest[key] == nil, "Cannot combine tables that share keys")
                if dest[key] == nil then
                    dest[key] = data
                    --else
                    --d(strfor(">Couldn't combine key \'%s\' as it it duplicate", tos(key)))
                end
            end
        end
    end
end

local function GetAllZoneInfo()
    if nonOfficialLanguages[clientLang] then return end

    d(debugOutputStartLine..libPrefixWithVersion .. "GetAllZoneInfo, language: " ..tos(clientLang))
    local maxZoneId = 2000
    local zoneData = {}
    zoneData[clientLang] = {}
    --zoneIndex1 "Clean Test"'s zoneId
    local zoneIndex1ZoneId = gzid(1) -- should be: 2
    for zoneId = 1, maxZoneId, 1 do
        local zi = gzidx(zoneId)
        if zi ~= nil then
            local pzid = gpzid(zoneId)
            --With API100027 Elsywer every non-used zoneIndex will be 1 instead 0 :-(
            --So we need to check if the zoneIndex is 1 and the zoneId <> the zoneId for index 1
            if (zi == 1 and zoneId == zoneIndex1ZoneId) or zi ~= 1 then
                local zoneNameClean = zostrfor("<<C:1>>", gznbidx(zi))
                if zoneNameClean ~= nil then
                    zoneData[clientLang][zoneId] = zoneId .. "|" .. zi .. "|" .. pzid .. "|" ..zoneNameClean
                end
            end
        end
    end
    return zoneData
end

--Execute in each map to get wayshrine data
local function GetWayshrineInfo()
    d(debugOutputStartLine..libPrefixWithVersion .. "GetWayshrineInfo")
    local errorMapNavigateText = " Please open the map and navigate to a zone map first before running this function!"
    local wayshrines = {}
    local currentMapIndex = GetCurrentMapIndex()
    if currentMapIndex == nil then d("<-Error: map index missing." .. errorMapNavigateText) end
    local currentMapId = GetCurrentMapId()
    if currentMapId == nil then d("<-Error: map id missing." .. errorMapNavigateText) return end
    local currentMapsZoneIndex = gcmzidx()
    if currentMapsZoneIndex == nil then d("<-Error: map zone index missing." .. errorMapNavigateText) return end
    local currentZoneId = gzid(currentMapsZoneIndex)
    if currentZoneId == nil then d("<-Error: map zone id missing." .. errorMapNavigateText) return end
    local currentMapName = zocstrfor("<<C:1>>", currentMapIndex and GetMapNameByIndex(currentMapIndex) or gmnbid(currentMapId))
    local currentZoneName = zocstrfor("<<C:1>>", gznbidx(currentMapsZoneIndex))
    d("->mapIndex: " .. tos(currentMapIndex) .. ", mapId: " .. tos(currentMapId) ..
            ", mapName: " .. tos(currentMapName) .. ", mapZoneIndex: " ..tos(currentMapsZoneIndex) .. ", zoneId: " .. tos(currentZoneId) ..
            ", zoneName: " ..tos(currentZoneName))
    for i=1, gnftn(), 1 do
        local wsknown, wsname, wsnormalizedX, wsnormalizedY, wsicon, wsglowIcon, wspoiType, wsisShownInCurrentMap, wslinkedCollectibleIsLocked = gftninf(i)
        if wsisShownInCurrentMap then
            local wsNameStripped = zocstrfor("<<C:1>>",wsname)
            d("->[" .. tos(i) .. "] " ..tos(wsNameStripped))
            --Export for excel split at | char
            --WayshrineNodeId, mapIndex, mapId, mapName, zoneIndex, zoneId, zoneName, POIType, wayshrineName
            wayshrines[i] = tos(i).."|"..tos(currentMapIndex).."|"..tos(currentMapId).."|"..tos(currentMapName).."|"..
                    tos(currentMapsZoneIndex).."|"..tos(currentZoneId).."|"..tos(currentZoneName).."|"..tos(wspoiType).."|".. tos(wsNameStripped)
        end
    end
    return wayshrines
end
lib.DebugGetWayshrineInfo = GetWayshrineInfo

local function GetWayshrineNames()
    if nonOfficialLanguages[clientLang] then return end

    d(debugOutputStartLine..libPrefixWithVersion .. "GetWayshrineNames, language: " ..tos(clientLang))

    local wsNames = {}
    wsNames[clientLang] = {}
    for wsNodeId=1, gnftn(), 1 do
        --** _Returns:_ *bool* _known_, *string* _name_, *number* _normalizedX_, *number* _normalizedY_, *textureName* _icon_, *textureName:nilable* _glowIcon_, *[PointOfInterestType|#PointOfInterestType]* _poiType_, *bool* _isShownInCurrentMap_, *bool* _linkedCollectibleIsLocked_
        local _, wsLocalizedName = gftninf(wsNodeId)
        if wsLocalizedName ~= nil then
            local wsLocalizedNameClean = zocstrfor("<<C:1>>", wsLocalizedName)
            wsNames[clientLang][wsNodeId] = tos(wsNodeId) .. "|" .. wsLocalizedNameClean
        end
    end
    return wsNames
end

local function GetMapNames(lang)
    lang = lang or clientLang

    if nonOfficialLanguages[lang] then return end

    d(debugOutputStartLine..libPrefixWithVersion .. "GetMapNames, language: " ..tos(lang))
    local lz = lib.libZone
    if not lz then
        if lang ~= clientLang then
            d("ERROR: Library \'LibZone\' must be loaded to get a zoneName in another language!") return
        end
    end
    local zoneIds
    local zoneIdsLocalized
    --Get zone data from LibZone
    if lz then
        if lz.GetAllZoneData then
            zoneIds = lz:GetAllZoneData()
        elseif lz.givenZoneData then
            zoneIds = lz.givenZoneData
        end
        if not zoneIds then d("ERROR: Library \'LibZone\' givenZoneData is missing!") return end
        zoneIdsLocalized = zoneIds[lang]
        if not zoneIdsLocalized then d("ERROR: Language \"" .. tos(lang) .."\" is not scanned yet in library \'LibZone\'") return end
    else
        zoneIdsLocalized = {}
    end
    --Update new/missing zoneIds
    if gnz then
        --Get the number of zoneIndices and create the zoneIds to scan from
        for zoneIndex=0, gnz(), 1 do
            local zoneId = gzid(zoneIndex)
            if zoneId and not zoneIdsLocalized[zoneId] then
                local zoneName = gznbidx(zoneIndex)
                if not zoneName or zoneName == "" then zoneName = unknownName end
                zoneIdsLocalized[zoneId] = zocstrfor("<<C:1>>", zoneName)
            end
        end
    end
    local mapNames = {}
    for zoneId, zoneNameLocalized in pairs(zoneIdsLocalized) do
        local mapIndex = gmidbzid(zoneId)
        local mapId = GetMapIdByIndex(mapIndex)
        --d(">zoneId: " ..tos(zoneId) .. ", mapIndex: " ..tos(mapIndex))
        if mapIndex ~= nil then
            local mapName = zocstrfor("<<C:1>>", GetMapNameByIndex(mapIndex))
            if mapName ~= nil then
                mapNames[mapIndex] = tos(mapId) .. "|" .. tos(mapIndex) .. "|" .. mapName .. "|" .. tos(zoneId) .. "|" .. zoneNameLocalized
            end
        end
    end
    return mapNames
end

local function checkForNewSetIds(setIdTable, funcToCallForEachSetId, combineFromSV, forceShowOtherApiVersionSets)
    if not setIdTable then return end
    combineFromSV = combineFromSV or false
    forceShowOtherApiVersionSets = forceShowOtherApiVersionSets or false
    local runFuncForEachSetId = (funcToCallForEachSetId ~= nil and type(funcToCallForEachSetId) == "function") or false
--d(strfor(">checkForNewSetIds - funcToCallForEachSetId given: %s, combineFromSavedVariables: %s", tos(runFuncForEachSetId), tos(combineFromSV)))
    newSetIdsFound = {}
    local setsOfNewerAPIVersion = lib.setsOfNewerAPIVersion
    local blacklistedSetIds = lib.blacklistedSetIds
    local setInfo = lib.setInfo
    local svLoadedAlready = false

    --Combine the preloaded setItemIds with new ones from the SV?
    local tableToProcess = {}
    if combineFromSV == true then
        LoadSavedVariables()
        svLoadedAlready = true
        --setIdTable -> lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS]
        --SV table of all new itemIds scanned: lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] -> Might have been cleared already again due to
        --itemIds having been compressed already!
        --The compressed itemIds of new scanned set itemIds are found here:
        --SV table of all new itemIds scanned AND compressed lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED]
        local loadedCompressedSetItemIdsFromSV = lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED]
--lib._loadedCompressedSetItemIdsFromSV = loadedCompressedSetItemIdsFromSV
        MyCombineNonContiguousTables(tableToProcess, setIdTable, loadedCompressedSetItemIdsFromSV)
    else
        tableToProcess = setIdTable
    end
--lib._tableToProcess = tableToProcess

    for setId, setItemIds in pairs(tableToProcess) do
        local doAddAsNew = false
        --Do not add any blacklisted setIds
        if not blacklistedSetIds[setId] then
            if setItemIds ~= nil and setInfo ~= nil then
                --Not yet in the preloaded sets data table?
                --No matter why: It needs to be added then!
                if setInfo[setId] == nil then
                    doAddAsNew = true
                else
                    --Already manually added to the "newer APIversion" table in LibSets_Data_All.lua?
                    -->Could be already in lib.setInfo but does count as "new" then until the PTS APIversion is live!
                    if setsOfNewerAPIVersion ~= nil and (forceShowOtherApiVersionSets == true or not isPTSAPIVersionLive) then
                        for _, setIdOfNewerAPIVersion in ipairs(setsOfNewerAPIVersion) do
                            if setId == setIdOfNewerAPIVersion then
                                doAddAsNew = true
                                break -- exit the inner loop
                            end
                        end
                    end
                end
                if doAddAsNew == true then
--d(">checkForNewSetIds-Add setId to new: " ..tos(setId))
                    tins(newSetIdsFound, setId)
                end
                if runFuncForEachSetId == true then
                    funcToCallForEachSetId(setId)
                end
            end
        --else
            --d(">Skipped blacklisted setId: " ..tos(setId))
        end
    end

    if combineFromSV == true then
        if not svLoadedAlready then
            LoadSavedVariables()
        end
        local newSetIdsFromSV = lib.svDebugData and lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS]
                                    and lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName] and lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName][apiVersion]
--lib._newSetIdsFromSV = newSetIdsFromSV
        if newSetIdsFromSV ~= nil and #newSetIdsFromSV > 0 then
            d(strfor(">>found newSetData in the SavedVariables - WorldName: %s, APIVersion: %s", tos(worldName), tos(apiVersion)))
            for idx, newSetIdToCheck in ipairs(newSetIdsFromSV) do
                --Prevent any string variables accidently created as setId
                if type(newSetIdToCheck) == "number" then
                    local addNow = true
                    --local newSetIdToCheck
                    --A line [idx] = newSetData looks like this: [1] = "209|Rüstung des Kodex|N/a",
                    --local newSetIdToCheckStr = strsub(newSetData, 1, strfind(newSetData, "|"))
                    --if newSetIdToCheckStr ~= nil and newSetIdToCheckStr ~= "" then
                    --    newSetIdToCheck = ton(newSetIdToCheckStr)
                    if newSetIdToCheck ~= nil then
                        --Is the setId of a scaned newSetId (from debug SavedVariables NewSetIDs) already the same as an entry in the above scanned
                        --newSetIdsFound table (from debug SavedVariables setItemIds_Compressed): Then skip it
                        for _, newSetIdLoadedBefore in ipairs(newSetIdsFound) do
                            --d(">>>newSetIdToCheck: " ..tos(newSetIdToCheck) .. ", newSetIdLoadedBefore: " ..tos(newSetIdLoadedBefore))
                            if newSetIdToCheck == newSetIdLoadedBefore then
                                addNow = false
                                break
                            end
                        end
                    end
                    --end
                    if addNow == true and newSetIdToCheck ~= nil then
--d(">checkForNewSetIds-added new setId now: " ..tos(newSetIdToCheck))
                        newSetIdsFound[idx] = newSetIdToCheck
                        if runFuncForEachSetId == true then
                            funcToCallForEachSetId(newSetIdToCheck)
                        end
                    end
                --else
--d("<checkForNewSetIds-newSetIdsFromSV new setId is not a number: " ..tos(newSetIdToCheck))
                end
            end
        end
    end
    tsort(newSetIdsFound)
lib._newSetIdsFound_checkForNewSetIds = newSetIdsFound
end

--Return all the setId's itemIds as table, from file LibSets_Data_All.lua, table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS]
local function getAllSetItemIds()
    checkForNewSetIds(lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS], lib.DecompressSetIdItemIds, true, false)
    return lib.CachedSetItemIdsTable
end

--This function will reset all SavedVariables to nil (empty them) to speed up the loading of the library
function lib.DebugResetSavedVariables(noReloadInfo, onlyNames)
    onlyNames = onlyNames or false
    noReloadInfo = noReloadInfo or false
    local onlyNamesText = (not onlyNames and "") or " of names"
    LoadSavedVariables()
    if onlyNames == true then
        lib.svDebugData[LIBSETS_TABLEKEY_MAPS] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_MIXED_SETNAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES] = nil

    else
        lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETS_EQUIP_TYPES]   = nil
        --lib.svDebugData[LIBSETS_TABLEKEY_SETS_ARMOR]         = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETS_ARMOR_TYPES]   = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETS_JEWELRY]       = nil
        --lib.svDebugData[LIBSETS_TABLEKEY_SETS_WEAPONS]       = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETS_WEAPONS_TYPES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_DUNGEONFINDER_DATA] = nil

        lib.svDebugData[LIBSETS_TABLEKEY_MAPS] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_MIXED_SETNAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES] = nil
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES] = nil
    end
    d(libPrefix .. "Cleared all SavedVariables".. onlyNamesText .." in file \'" .. MAJOR .. ".lua\'.")
    if noReloadInfo == true then return end
    d(">Please do a /reloadui or logout to update the SavedVariables data now!")
end
local debugResetSavedVariables = lib.DebugResetSavedVariables

------------------------------------------------------------------------------------------------------------------------
-- Scan for zone names -> Save them in the SavedVariables "zoneData"
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the zone data in the current client language and saves it to the SavedVars table "zoneData" in this format:
--zoneData[lang][zoneId] = zoneId .. "|" .. zoneIndex .. "|" .. parentZoneId .. "|" ..zoneNameCleanLocalizedInClientLanguage
-->RegEx to transfer [1]= "1|2|1|Zone Name Clean", to 1|2|1|Zone Name Clean:   \[\d*\] = \"(.*)\" -> replace with $1
--->Afterwards put into excel and split at | into columns
function lib.DebugGetAllZoneInfo()
    local zoneData = GetAllZoneInfo()
    if zoneData ~= nil then
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA] = lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA][clientLang] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_ZONE_DATA][clientLang] = zoneData[clientLang]
        d(storedInSVFileLibSetsInTable .. "\'".. LIBSETS_TABLEKEY_ZONE_DATA .. "\', language: \'" ..tos(clientLang).."\'")
    end
end
local debugGetAllZoneInfo = lib.DebugGetAllZoneInfo

------------------------------------------------------------------------------------------------------------------------
-- Scan for map names -> Save them in the SavedVariables "maps"
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the maps data in the current client language and saves it to the SavedVars table "maps" in this format:
--maps[mapIndex] = mapIndex .. "|" .. localizedCleanMapNameInClientLanguage .. "|" .. zoneId .. "|" .. zoneNameLocalizedInClientLanguage
-->RegEx to transfer [1]= "1|2|1|Zone Name Clean", to 1|2|1|Zone Name Clean:   \[\d*\] = \"(.*)\" -> replace with $1
--->Afterwards put into excel and split at | into columns
function lib.DebugGetAllMapNames()
    local maps = GetMapNames(clientLang)
    if maps ~= nil then
        tsort(maps)
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_MAPS] = lib.svDebugData[LIBSETS_TABLEKEY_MAPS] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_MAPS][clientLang] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_MAPS][clientLang] = maps
        d(storedInSVFileLibSetsInTable .. "\'"..LIBSETS_TABLEKEY_MAPS.."\', language: \'" ..tos(clientLang).."\'")
    end
end
local debugGetAllMapNames = lib.DebugGetAllMapNames

------------------------------------------------------------------------------------------------------------------------
-- Scan for wayshrines -> Save them in the SavedVariables "wayshrines"
--> You need to open a map (zone map, no city or sub-zone maps!) in order to let the function work properly
--> It will not get all wayshrines of ALL maps, only the currently opened one!
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the wayshrine data (nodes) in the current client language and saves it to the SavedVars table "wayshrines" in this format:
--wayshrines[i] = wayshrineNodeId .."|"..currentMapIndex.."|"..currentMapId.."|"..currentMapNameLocalizedInClientLanguage.."|"
--..currentMapsZoneIndex.."|"..currentZoneId.."|"..currentZoneNameLocalizedInClientLanguage.."|"..wayshrinesPOIType.."|".. wayshrineNameCleanLocalizedInClientLanguage
-->RegEx to transfer [1]= "1|WayshrineNodeId|mapIndex|mapId|mapName|zoneIndex|zoneId|zoneName|POIType|wayshrineName", to 1|WayshrineNodeId|mapIndex|mapId|mapName|zoneIndex|zoneId|zoneName|POIType|wayshrineName:   \[\d*\] = \"(.*)\" -> replace with $1
--->Afterwards put into excel and split at | into columns
function lib.DebugGetAllWayshrineInfoOfCurrentMap()
    local delay = 0
    local wayshrinesAvailable = false
    if not ZO_WorldMap_IsWorldMapShowing() then
        --Show the map
        ZO_WorldMap_ShowWorldMap()
        delay = 250
    end
    --Try 5 times to check for wayshrines and no city etc, just a zone map!
    -->right click on the map to get 1 level up
    local mapRightClickCounter = 1
    while (mapRightClickCounter <= 5 and wayshrinesAvailable == false) do
        mapRightClickCounter = mapRightClickCounter + 1
        --Detect if we are in a city or not on the parent map
        wayshrinesAvailable = (ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES) and (GetCurrentMapIndex() ~= nil)) or false
        --Unzoom once to get to the parent map (hopefully it's a zone map)
        if wayshrinesAvailable == false then
            ZO_WorldMap_MouseUp(nil, MOUSE_BUTTON_INDEX_RIGHT, true)
        else
            mapRightClickCounter = 9
            wayshrinesAvailable = true
            break -- leave the while ... do
        end
    end
    if wayshrinesAvailable == true then
        zo_callLater(function()
            local ws = GetWayshrineInfo()
            if ws ~= nil then
                tsort(ws)
                LoadSavedVariables()
                lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINES] = lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINES] or {}
                for wsNodeId, wsData in pairs(ws) do
                    lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINES][wsNodeId] = wsData
                end
                d(storedInSVFileLibSetsInTable .. "\'"..LIBSETS_TABLEKEY_WAYSHRINES.."\'")
            end
        end, delay)
    end
end
local debugGetAllWayshrineInfoOfCurrentMap = lib.DebugGetAllWayshrineInfoOfCurrentMap

--Returns a list of the wayshrine names in the current client language and saves it to the SavedVars table "wayshrineNames" in this format:
--wayshrineNames[clientLanguage][wayshrineNodeId] = wayshrineNodeId .. "|" .. wayshrineLocalizedNameCleanInClientLanguage
-->RegEx to transfer [1]= "1|Wayshrine name", to 1|Wayshrine name:   \[\d*\] = \"(.*)\" -> replace with $1
--->Afterwards put into excel and split at | into columns
function lib.DebugGetAllWayshrineNames()
    local wsNames = GetWayshrineNames()
    if wsNames ~= nil and wsNames[clientLang] ~= nil then
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES] = lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES][clientLang] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_WAYSHRINE_NAMES][clientLang] = wsNames[clientLang]
        d(storedInSVFileLibSetsInTable .. "\'"..LIBSETS_TABLEKEY_WAYSHRINE_NAMES.."\', language: \'" ..tos(clientLang).."\'")
    end
end
local debugGetAllWayshrineNames = lib.DebugGetAllWayshrineNames

------------------------------------------------------------------------------------------------------------------------
-- Scan for set names in client language -> Save them in the SavedVariables "setNames"
------------------------------------------------------------------------------------------------------------------------

--======= SET ItemId compression =====================================================================================
--Thanks to Dolgubon for the base function code from his LibLazyCrafting!
-- Will compress the itemIds which are next to each other (e.g. 20000, 20001, 20002, etc.) by transfering them to a string
--value containing the starting itemId followed by a "," and then the number of non-gap following itemIds, e.g.: 20000,3
--> means 20000, 20001, 20002, 20003
--Decompressed in function LibSets.DecompressSetIdItemIds(setId) and held in cache table (if decompressed) LibSets.CachedSetItemIdsTable
local function compressSetItemIdTable(toMinify)
    local minifiedTable={}
    local numConsecutive,lastPosition = 0,1
    for i = 2, #toMinify do
        if toMinify[lastPosition]+numConsecutive+1==toMinify[i] then
            numConsecutive=numConsecutive+1
        else
            if numConsecutive>0 then
                tins(minifiedTable,tos(toMinify[lastPosition])..","..numConsecutive)
            else
                tins(minifiedTable,toMinify[lastPosition])
            end
            numConsecutive=0
            lastPosition=i
        end
    end
    if numConsecutive>0 then
        tins(minifiedTable,tos(toMinify[lastPosition])..","..numConsecutive)
    else
        tins(minifiedTable,toMinify[lastPosition])
    end
    tsort(minifiedTable)
    return minifiedTable
end

--Compress the itemIds of a set to lower the filesize of LibSets_Data_All.lua, table LIBSETS_TABLEKEY_SETITEMIDS.
local function compressSetItemIdsNow(setsDataTable, noReloadInfo)
    noReloadInfo = noReloadInfo or false
    d(libPrefix .. " Compressing the set itemIds now...")
    LoadSavedVariables()
    if setsDataTable == nil then setsDataTable = lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] end
    if not setsDataTable then
        d("<Aborting: setsDataTable is missing")
        return
    end

    lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED] = {}
    for setId, setItemIdsOfSetId in pairs(setsDataTable) do
        --Transfer the setItemIds to an integer key table without gaps
        local helperTabNoGapIndex = {}
        for k, _ in pairs(setItemIdsOfSetId) do
            tins(helperTabNoGapIndex, k)
        end
        tsort(setItemIdsOfSetId)
        lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED][setId] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED][setId] = compressSetItemIdTable(helperTabNoGapIndex)
    end
    d(">>> " .. libPrefix .. " Compression of set itemIds has finished and was saved to SavedVariables file \'" .. MAJOR .. ".lua\' table \'" .. LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED .. "\'")
    if noReloadInfo == true then return end
    d(pleaseReloadUI)
end
lib.DebugCompressSetItemIdsNow = compressSetItemIdsNow

--Returns a list of the set names in the current client language and saves it to the SavedVars table "setNames" in this format:
--setNames[setId][clientLanguage] = localizedAndCleanSetNameInClientLanguage
--
-->!!!!!!! ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION ATTENTION !!!!!!!
-->The table LibSets.setItemIds in file LibSets_Data.lua must be updated with all setId and itemIds in order to make this debug function scan ALL actual setIds!
-->Read above the table for instructions how to update it, e.g. using LibSets.DebugScanAllSetData() to scan for new itemIds
--If new sets were scanned using function LibSets.DebugScanAllSetData() before using THIS function "DebugGetAllSetNames" here
--(and there were found new sets which are not already in the table LibSets_Data.lua->LibSets.setItemIds), then the new setIds
--will be added here and dumped to the SavedVariables as well!
function lib.DebugGetAllSetNames(noReloadInfo)
    d(debugOutputStartLine..libPrefix .. "GetAllSetNames, language: " .. tos(clientLang))
    noReloadInfo = noReloadInfo or false
    --Use the SavedVariables to get the setNames of the current client language
    local svLoadedAlready = false
    local setNamesAdded = 0

    local setWasChecked = false
    local setIdsTable = {}
    local setNamesOfLangTable = {}
    local maxSetIdChecked = 0

    local isNonOfficialLanguage = nonOfficialLanguages[clientLang] or false

    --Does not work as new setIds are unknown to table lib.setInfo until we scan the data and add it to the excel, to generate the code for this table!
    --So we FIRST need to call the function LibSets.DebugScanAllSetData(), update the table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS] with the scanned
    --setIds and their compressed itemIds, and afterwards we can use this fucntion DebugGetAllSetNames to rad this table, to get the new setIds
    local allSetItemIds = getAllSetItemIds()
    if allSetItemIds ~= nil then
        --Transfer new scanned setIds with their setItemIds temporarily to the table of the preloaded setItemIds "allSetItemIds"
        --so looping over this table further down in this function will also add the names of new found sets!
        -->Done within checkForNewSetIds/getAllSetItemIds now already and transfered to lib.CachedSetItemIdsTable, which here is
        -->allSetItemIds now!
        --[[
        if lib.svDebugData and lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED] then
            local scannedSVSetItemIds = lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS_COMPRESSED]
            for setId, setItemIds in pairs(scannedSVSetItemIds) do
                if not allSetItemIds[setId] then
                    allSetItemIds[setId] = setItemIds
                end
            end
        end
        ]]

       --Check the set names now
       for setIdToCheck, setsItemIds in pairs(allSetItemIds) do
            setWasChecked = false
            if setsItemIds then
                for itemIdToCheck, _ in pairs(setsItemIds) do
                    if not setWasChecked and itemIdToCheck ~= nil then
                        local isSet, setName, setId = isSetByItemId(itemIdToCheck)
                        if isSet and setId == setIdToCheck then
                            --[[
                            local isNewSet = false
                            for _, setIdNewFound in ipairs(newSetIdsFound) do
                                if setIdNewFound == setId then
                                    isNewSet = true
                                    break
                                end
                            end
                            ]]
                            setWasChecked = true

                            --Non official language is scanned, so use the already provided setName in that language
                            --or the English setName as fallback
                            if isNonOfficialLanguage == true then
                                setName = ""
                                setName = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][setId][clientLang] or lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][setId][fallbackLang] or "n/a"
                            else
                                setName = zocstrfor("<<C:1>>", setName)
                            end

                            --if isNewSet == true then
    --d(">new SetId found: " ..tos(setId) .. ", name: " ..tos(setName))
                            --end

                            if setName ~= "" then
                                --Load the SV once
                                if not svLoadedAlready then
                                    LoadSavedVariables()
                                    svLoadedAlready = true
                                end
                                --lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] = lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] or {}
                                --lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId][clientLang] = setName
                                tins(setIdsTable, setId)
                                setNamesOfLangTable[setId] = setName
                                setNamesAdded = setNamesAdded +1
                            end
                        end
                    end
                end
            end
            --Remember the highest setId which was checked
            if setIdToCheck > maxSetIdChecked then
                maxSetIdChecked = setIdToCheck
            end
        end
    end
    --Did we add setNames?
    if setNamesAdded > 0 then
        if not svLoadedAlready then
            LoadSavedVariables()
            svLoadedAlready = true
        end
        if svLoadedAlready == true then
            tsort(setIdsTable)
            for _, setId in ipairs(setIdsTable) do
                local setName = setNamesOfLangTable[setId]
                if setName and setName ~= "" then
                    lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] = lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] or {}
                    lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] = lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] or {}
                    lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId][clientLang] = setName
                end
            end
        end
        local foundNewSetsCount = (newSetIdsFound and #newSetIdsFound) or 0
        d("-->Maximum setId found: " ..tos(maxSetIdChecked) .. " / Added set names: " ..tos(setNamesAdded) .. " / New setIds found: " .. tos(foundNewSetsCount))
        if foundNewSetsCount > 0 then
            for _, setIdNewFound in ipairs(newSetIdsFound) do
                local setNameOfNewSet = (lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setIdNewFound] and lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setIdNewFound][clientLang]) or unknownName
                d("--->new setId: " ..tos(setIdNewFound) .. ", name: " .. tos(setNameOfNewSet))
            end
        end
        d(storedInSVFileLibSetsInTable .. "\'" .. LIBSETS_TABLEKEY_SETNAMES .. "\', language: \'" ..tos(clientLang).."\'")
        if noReloadInfo == true then return end
        d(pleaseReloadUI)
    end
end
local debugGetAllSetNames = lib.DebugGetAllSetNames

------------------------------------------------------------------------------------------------------------------------
-- Scan for sets and their itemIds -> Save them in the SavedVariables "setItemIds"
---------------------------------------------------------------------------------------------------------------------------
--Variables needed for the functions below (Scan itemIds for sets and itemIds)
local sets = {}
local setsEquipTypes= {}
local setsArmor = {}
local setsArmorTypes = {}
local setsJewelry = {}
local setsWeapons = {}
local setsWeaponTypes = {}

local setCount = 0
local itemCount = 0
local itemArmorCount = 0
local itemJewelryCount = 0
local itemWeaponsCount = 0
local itemIdsScanned = 0

local lastSetsCount = 0
local lastFoundPackageNr = 0
local noFurtherItemsFound = false
local function showSetCountsScanned(finished, keepUncompressedetItemIds, noReloadInfo, packageNr)
    noReloadInfo = noReloadInfo or false
    keepUncompressedetItemIds = keepUncompressedetItemIds or false
    finished = finished or false
    --No more itemIds to scan as we did not find any new setIds since 5 packages? Finish then!
    if not finished and noFurtherItemsFound == true then finished = true end

    d(debugOutputStartLine ..libPrefix .. "Scanned package \'" .. tos(packageNr) .."\' - itemIds: " .. tos(itemIdsScanned))
    d("-> Sets found: "..tos(setCount))
    d("-> Set items found: "..tos(itemCount))
    df("-->Armor: %s / Jewelry: %s / Weapons: %s", tos(itemArmorCount), tos(itemJewelryCount), tos(itemWeaponsCount))

    if finished == true then
        noFurtherItemsFound = true
        newSetIdsFound = {}
        local newSetsFound = 0
        local temporarilyText = ""
        if not keepUncompressedetItemIds then
            temporarilyText = " temporarily"
        end
        d(">>> " .. libPrefix .. " Scanning of sets has finished! SavedVariables file \'" .. MAJOR .. ".lua\' table \'" .. LIBSETS_TABLEKEY_SETITEMIDS .. "\' was"..temporarilyText.." written! <<<")
        --Save the data to the SavedVariables now
        if setCount > 0 then
            --Check how many new setId were found
            if sets ~= nil then
                checkForNewSetIds(sets, nil, false, false)
            end
            newSetsFound = (newSetIdsFound ~= nil and #newSetIdsFound) or 0
            if newSetsFound > 0 then
                d(">> !!! Found " .. tos(newSetsFound) .. " new setIds !!!")
                for idx, newSetId in pairs(newSetIdsFound) do
                    local newSetName = nil
                    if lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId] ~= nil then
                        newSetName = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId][clientLang] or lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId][fallbackLang]
                    end
                    if newSetName == nil then newSetName = unknownName end
                    if newSetName ~= unknownName then
                        newSetName = zocstrfor("<<C:1>>", newSetName)
                    else
                        newSetName = unknownName .. " - Name unknown in LibSets.setDataPreloaded[\'" .. LIBSETS_TABLEKEY_SETNAMES .. "\']"
                    end
                    d(strfor(">>>New setId found at index %s: %s -> name: %s", tos(idx), tos(newSetId), tos(newSetName)))
                    --Update the value of the table entry with the index|setId
                    newSetIdsFound[idx] = newSetId
                end
            end

            --For debugging:
            --lib._newSetIdsFound = ZO_ShallowTableCopy(newSetIdsFound)

            LoadSavedVariables()
            --First save the new found setIds to the SavedVariables table ""
            if newSetsFound > 0 then
                --Add the dateTime and APIversion the new setIds were scanned
                local apiVersionUpdatedStr = tos(apiVersion) .. "_UpdateInfo"
                lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS] = lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS] or {}
                lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName] = lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName] or {}
                lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName][apiVersion] = newSetIdsFound
                lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName][apiVersionUpdatedStr] = {
                    ["UpdateType"]  = "LibSets.DebugScanAllSetData()",
                    ["DateTime"]    = os.date("%c")
                }
            end

            --Save the set data to the SV
            lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] = {}
            lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] = sets
            --Save the set's armorType, equipmentTypes, weaponTypes and jewelryTypes to the SV
            lib.svDebugData[LIBSETS_TABLEKEY_SETS_EQUIP_TYPES]   = setsEquipTypes
            --lib.svDebugData[LIBSETS_TABLEKEY_SETS_ARMOR]         = setsArmor
            lib.svDebugData[LIBSETS_TABLEKEY_SETS_ARMOR_TYPES]   = setsArmorTypes
            lib.svDebugData[LIBSETS_TABLEKEY_SETS_JEWELRY]       = setsJewelry
            --lib.svDebugData[LIBSETS_TABLEKEY_SETS_WEAPONS]       = setsWeapons
            lib.svDebugData[LIBSETS_TABLEKEY_SETS_WEAPONS_TYPES] = setsWeaponTypes

            --Compress the itemIds now to lower the fileSize of LibSets_Data_all.lua later (copied setItemIds from SavedVariables)
            compressSetItemIdsNow(sets, noReloadInfo)
            --Keep the uncompressed setItemIds, or delete them again?
            if not keepUncompressedetItemIds then
                --Free the SavedVariables of the uncompressed set itemIds
                lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] = nil
                d(">>> SavedVariables file \'" .. MAJOR .. ".lua\'s table \'" .. LIBSETS_TABLEKEY_SETITEMIDS .. "\' was deleted again to free space and speed-up the loading screens! <<<")
            end
        end

    else
        --Did the last sets count not increase since 5 scanned packages?
        --Then set the abort flag. itemId numbers seems to be too high then (-> future itemIds)
        if lastSetsCount > 0 and setCount > 0 then
            if (lastFoundPackageNr > 0 and (packageNr - lastFoundPackageNr) >= 10) then
                if lastSetsCount == setCount then
                    noFurtherItemsFound = true
                end
            end
        end
        if not noFurtherItemsFound then
            --Were the first sets found, or new sets found?
            if setCount > 0 and (lastSetsCount == 0 or setCount > lastSetsCount) then
                lastFoundPackageNr = packageNr
            end
            --Save the setsCount of the current loop
            lastSetsCount = setCount
        end
    end
    d("<<" .. debugOutputStartLine)
end
--Load a package of 5000 itemIds and scan it:
--Build an itemlink from the itemId, check if the itemLink is not crafted, if the itemType is a possible set itemType, check if the item is a set:
--If yes: Update the table sets and setNames, and add the itemIds found for this set to the sets table
--Format of the sets table is: sets[setId] = {[itemIdOfSetItem]=LIBSETS_SET_ITEMID_TABLE_VALUE_OK, ...}
local function loadSetsByIds(packageNr, from, to, noReloadInfo)
    noReloadInfo = noReloadInfo or false
    if not noFurtherItemsFound then
        local isJewelryEquiptype = lib.isJewelryEquipType
        local isWeaponEquipType = lib.isWeaponEquipType
        local setNames = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]

        for setItemId=from, to do
            itemIdsScanned = itemIdsScanned + 1
            --Generate link for item
            local itemLink = buildItemLink(setItemId)
            if itemLink and itemLink ~= "" then
                --No crafted sets
                if not isilc(itemLink) then
                    -- hasSet bool, setName string, numBonuses integer, numEquipped integer, maxEquipped integer, setId integer
                    local isSet, setName, _, _, _, setId = gilsetinf(itemLink, false)
                    if isSet == true then
                        --Check the itemType etc.
                        local itemType = gilit(itemLink)
                        --Some set items are only "containers" ...
                        if lib.setItemTypes[itemType] then
                            if sets[setId] == nil then
                                sets[setId] = {}
                                --Update the set counts value
                                setCount = setCount + 1

                                --Update the set name of the client language, if missing
                                if setName ~= nil and not setNames[setId] or setNames[setId] ~= nil and not setNames[setId][clientLang] then
                                    local setNameClean = zocstrfor("<<C:1>>", setName)
                                    if setNameClean ~= nil then
                                        setNames[setId] = setNames[setId] or {}
                                        setNames[setId][clientLang] = setNameClean
                                    end
                                end
                            end
                            sets[setId][setItemId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
                            --Update the set's item count
                            itemCount = itemCount + 1

                            --Add the table entries to the set's equiptypes, armor, jewelry and weapon types,
                            --and the general armor, jewelry, weapon tables, and armor class (light, medium, heavy)
                            --[[
                                setsEquipTypes= {}
                                setsArmor = {}
                                setsArmorTypes = {}
                                setsJewelry = {}
                                setsJewelryTypes = {}
                                setsWeapons = {}
                                setsWeaponTypes = {}
                            ]]
                            --Check the item's equipment type
                            local equipType = gilet(itemLink)
                            if equipType > EQUIP_TYPE_INVALID then
                                setsEquipTypes[equipType] = setsEquipTypes[equipType] or {}
                                setsEquipTypes[equipType][setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK

                                if isJewelryEquiptype[equipType] then
                                    if not setsJewelry[setId] then
                                        itemJewelryCount = itemJewelryCount + 1
                                    end
                                    setsJewelry[setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK

                                elseif isWeaponEquipType[equipType] then
                                    if not setsWeapons[setId] then
                                        itemWeaponsCount = itemWeaponsCount + 1
                                    end
                                    setsWeapons[setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK

                                    local weaponType = gilwt(itemLink)
                                    if weaponType > WEAPONTYPE_NONE then
                                        setsWeaponTypes[weaponType] = setsWeaponTypes[weaponType] or {}
                                        setsWeaponTypes[weaponType][setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
                                    end

                                else
                                    if not setsArmor[setId] then
                                        itemArmorCount = itemArmorCount + 1
                                    end
                                    setsArmor[setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK

                                    local armorType = gilat(itemLink)
                                    if armorType > ARMORTYPE_NONE then
                                        setsArmorTypes[armorType] = setsArmorTypes[armorType] or {}
                                        setsArmorTypes[armorType][setId] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    showSetCountsScanned(false, nil, noReloadInfo, packageNr)
end

--Scan all sets data by scanning all itemIds in the game via a 5000 itemId package size (5000 itemIds scanned at once),
--for x loops (where x is the multiplier number e.g. 40, so 40x5000 itemIds will be scanned for set data)
--This takes some time and the chat will show information about found sets and item counts during the packages get scanned.
--The parameter doNotKeepUncompressedetItemIds boolean specifies if the table lib.svDebugData[LIBSETS_TABLEKEY_SETITEMIDS] will be
--kept after the set itemIds were scanned. The SV file is pretty big because of this table so normally only the compressed
--itemIds will be kept!
local summaryAndPostprocessingDelay = 0
local function scanAllSetData(keepUncompressedetItemIds, noReloadInfo)
    noReloadInfo = noReloadInfo or false
    keepUncompressedetItemIds = keepUncompressedetItemIds or false
    local numItemIdPackages     = lib.debugNumItemIdPackages
    local numItemIdPackageSize  = lib.debugNumItemIdPackageSize

    if not numItemIdPackages or numItemIdPackages == 0 or not numItemIdPackageSize or numItemIdPackageSize == 0 then return end
    local itemIdsToScanTotal = numItemIdPackages * numItemIdPackageSize
    d(debugOutputStartLine)
    d(libPrefix .. "Start to load all set data. This could take a few minutes to finish!\nWatch the chat output for further information.")
    d(">Scanning " ..tos(numItemIdPackages) .. " packages with each " .. tos(numItemIdPackageSize) .. " itemIds (total: " .. tos(itemIdsToScanTotal) ..") now...")

    --Clear all set data
    sets = {}
    setsEquipTypes= {}
    setsArmor = {}
    setsArmorTypes = {}
    setsJewelry = {}
    setsWeapons = {}
    setsWeaponTypes = {}

    --Clear counters
    setCount = 0
    itemCount = 0
    itemArmorCount = 0
    itemJewelryCount = 0
    itemWeaponsCount = 0

    itemIdsScanned = 0

    --Loop through all item ids and save all sets to an array
    --Split the itemId packages into 5000 itemIds each, so the client is not lagging that
    --much and is not crashing!
    --> Change variable numItemIdPackages and increase it to support new added set itemIds
    --> Total itemIds collected: 0 to (numItemIdPackages * numItemIdPackageSize)
    local milliseconds = 0
    local fromTo = {}
    local fromVal = 0
    local summaryMet = false

    noFurtherItemsFound = false
    for numItemIdPackage = 1, numItemIdPackages, 1 do
        --Set the to value to loop counter muliplied with the package size (e.g. 1*500, 2*5000, 3*5000, ...)
        local toVal = numItemIdPackage * numItemIdPackageSize
        --Add the from and to values to the totla itemId check array
        tins(fromTo, {from = fromVal, to = toVal})
        --For the next loop: Set the from value to the to value + 1 (e.g. 5000+1, 10000+1, ...)
        fromVal = toVal + 1
    end
    --Add itemIds and scan them for set parts!
    local numPackageLoops = #fromTo
    for packageNr, packageData in pairs(fromTo) do
        local isLastLoop = (packageNr == numPackageLoops) or false

        zo_callLater(function()
            --There were further sets found?
            if not summaryMet and not noFurtherItemsFound then
d(">loadSetsByIds, packageNr: " ..tos(packageNr))
                loadSetsByIds(packageNr, packageData.from, packageData.to, noReloadInfo)
            end
            --Last loop or no further setIds were found during the last 5 loops
            if (noFurtherItemsFound == true or isLastLoop == true) and not summaryMet then
d(">lastLoop, or noFurtherItemsFound!")
                summaryMet = true
                --No further sets found. Abort here and show the results now. Decrease the delay again by 1000 for each
                --missing call in the loop, so that results are shown "now" (+2 seconds)
                local loopsLeft = numPackageLoops - packageNr
                if loopsLeft < 0 then loopsLeft = 0 end
d(">>#fromTo: " ..tos(#fromTo) ..", packageNr: " ..tos(packageNr) .. ", loopsLeft: " ..tos(loopsLeft) .. ", summaryAndPostprocessingDelay: " ..tos(summaryAndPostprocessingDelay))
                --Were all item IDs scanned? Show the results list and update the SavedVariables
                showSetCountsScanned(true, keepUncompressedetItemIds, noReloadInfo, "Summary")
            end
        end, milliseconds)

        milliseconds = milliseconds + 1000 -- scan item ID packages every 1 second to get not kicked/crash the client!
    end
end
lib.DebugScanAllSetData = scanAllSetData

--Get the setName by help of already scanned itemIds, or itemId of the preloaded data
local function getNewSetName(newSetId)
    if newSetId == nil then return unknownName end
    local itemId
    if sets[newSetId] ~= nil then
        itemId = getFirstEntryOfTable(sets[newSetId], true)
    end
    if not itemId then
        local itemIdsPreloaded = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS]
        if not itemIdsPreloaded[newSetId] then return unknownName end
        itemId = getFirstEntryOfTable(decompressSetIdItemIds(newSetId), true)
    end
    if not itemId then return unknownName end
    local setItemLink = buildItemLink(itemId)
    if not setItemLink or setItemLink == "" then return unknownName end
    --                hasSet bool, setName string, numBonuses integer, numEquipped integer, maxEquipped integer, setId integer
    local hasSet, setName, _, _, _, setId = gilsetinf(setItemLink, false)
    if hasSet == true and setId == newSetId then return zocstrfor("<<C:1>>", setName) end
    return unknownName
end

--Local helper function to get the dungeon finder data node entries of normal and/or veteran dungeons
local retTableDungeons
local function getDungeonFinderDataFromChildNodes(dungeonFinderRootNodeChildrenTable)
    local veteranIconString = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t "
    local veteranIconStringPattern = "|t.-:.-:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t%s*"
    local dungeonsAddedCounter = 0
    if dungeonFinderRootNodeChildrenTable == nil or dungeonFinderRootNodeChildrenTable.children == nil then return 0 end
    for _, childData in ipairs(dungeonFinderRootNodeChildrenTable.children) do
        if childData and childData.data then
            retTableDungeons = retTableDungeons or {}
            local data = childData.data
            --Check the name for the veteran icon and remove if + update the isVeteran boolean in the table
            local name = data.nameKeyboard
            local nameClean = name
            local substMadeCount=0
            local isVeteranDungeon = false
            nameClean, substMadeCount = zo_strgsub(name, veteranIconStringPattern, "")
            if substMadeCount > 0 then
                isVeteranDungeon = true
            end
            --zoneId can be determined via GetActivityZoneId(activityId) where activityId = data.id

            local dungeonData = data.id .. "|" .. nameClean .. "|" .. data.zoneId .. "|" .. tos(isVeteranDungeon)
            tins(retTableDungeons, dungeonData)
            dungeonsAddedCounter = dungeonsAddedCounter +1
        end
    end
    tsort(retTableDungeons)
    return dungeonsAddedCounter
end


--Read all dungeons from the dungeon finder and save them to the SavedVariables key "dungeonFinderData" (LIBSETS_TABLEKEY_DUNGEONFINDER_DATA).
--The format will be:
--dungeonFinderData[integerIndexIncreasedBy1] = dungeonId .. "|" .. dungeonName .. "|" .. zoneId .. "|" .. isVeteranDungeon
--This string can be easily copy&pasted to Excel and split at the | delimiter
--Example:
--["dungeonFinderData"] =
--{
--  [1] = "2|Pilzgrotte I|283|false",
--  [2] = "18|Pilzgrotte II|934|false",
--..
--}
--->!!!Attention!!!You MUST open the dungeon finder->go to specific dungeon dropdown entry in order to build the dungeons list needed first!!!
--Parameter: dungeonFinderIndex number. Possible values are 1=Normal or 2=Veteran or 3=Both dungeons. Leave empty to use 3=Both dungeons
local preventEndlessCallDungeonFinderData = false
function lib.DebugGetDungeonFinderData(dungeonFinderIndex, noReloadInfo)
    noReloadInfo = noReloadInfo or false
    d(libPrefix .. "Start to load all dungeon data from the keyboard dungeon finder...")
    dungeonFinderIndex = dungeonFinderIndex or 3
    local dungeonFinder = DUNGEON_FINDER_KEYBOARD
    retTableDungeons = nil
    local dungeonsAddedNormal = 0
    local dungeonsAddedVet = 0
    local dungeonsAdded = 0
    local openDungeonFinderNow = false
    if dungeonFinder and dungeonFinder.navigationTree and dungeonFinder.navigationTree.rootNode then
        local dfRootNode = dungeonFinder.navigationTree.rootNode
        if dfRootNode.children then
            if dungeonFinderIndex == 3 then
                --Normal
                local dungeonsData = dfRootNode.children[1]
                if dungeonsData ~= nil then
                    dungeonsAddedNormal = getDungeonFinderDataFromChildNodes(dungeonsData)
                end
                --Veteran (if already given for the char)
                dungeonsData = dfRootNode.children[2]
                if dungeonsData ~= nil then
                    dungeonsAddedVet = getDungeonFinderDataFromChildNodes(dungeonsData)
                end
                dungeonsAdded = dungeonsAddedNormal + dungeonsAddedVet
            else
                local dungeonsData = dfRootNode.children[dungeonFinderIndex]
                dungeonsAdded = getDungeonFinderDataFromChildNodes(dungeonsData)
            end
        else
            if preventEndlessCallDungeonFinderData == true then
                d("<Please open the dungeon finder and choose the \'Specific dungeon\' entry from the dropdown box at the top-right edge! Then try this function again.")
                preventEndlessCallDungeonFinderData = false
                return
            else
                preventEndlessCallDungeonFinderData = true
                openDungeonFinderNow = true
            end
        end
    end
    if not openDungeonFinderNow and retTableDungeons and #retTableDungeons > 0 and dungeonsAdded > 0 then
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_DUNGEONFINDER_DATA] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_DUNGEONFINDER_DATA] = retTableDungeons
        d("->Stored " .. tos(dungeonsAdded) .." entries in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'" .. LIBSETS_TABLEKEY_DUNGEONFINDER_DATA .. "\', language: \'" ..tos(clientLang).."\'")
        if noReloadInfo == true then return end
        d(pleaseReloadUI)
    else
        local noDataFoundText = "<No dungeon data was found!"
        if preventEndlessCallDungeonFinderData == true and openDungeonFinderNow == true then
            --Select the category of the dungeon finder
            --ZO_UI_SYSTEM_MANAGER:RequestOpenUISystem(UI_SYSTEM_DUNGEON_FINDER)
            GROUP_MENU_KEYBOARD:ShowCategory(DUNGEON_FINDER_KEYBOARD:GetFragment()) --> TODO 20220715 Does not work anymore!!!???
            --Open the group menu -> Should be done within GROUP_MENU_KEYBOARD:ShowCategory(categoryFragment)
            if not KEYBOARD_GROUP_MENU_SCENE:IsShowing() then
              SCENE_MANAGER:Show("groupMenuKeyboard")
            end
            --[[
            --Hide the currently shown fragment
            if GROUP_MENU_KEYBOARD.currentCategoryFragment then
                SCENE_MANAGER:RemoveFragment(GROUP_MENU_KEYBOARD.currentCategoryFragment)
            end
            local dungeonFinderKeyboardFragment = dungeonFinder:GetFragment()
            SCENE_MANAGER:AddFragment(dungeonFinderKeyboardFragment)
            GROUP_MENU_KEYBOARD.currentCategoryFragment = dungeonFinderKeyboardFragment
            ]]
            if not dungeonFinder or not dungeonFinder.navigationTree or not dungeonFinder.navigationTree.rootNode
                    or not dungeonFinder.navigationTree.rootNode.children then
                ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader3:OnMouseUp(MOUSE_BUTTON_INDEX_LEFT, true)
            end
            zo_callLater(function()
                --Select entry "Sepcific dungeon" from dungeon dropdown
                ZO_DungeonFinder_KeyboardFilter.m_comboBox:SelectItemByIndex(3)
                --Redundant call to the same function
                lib.DebugGetDungeonFinderData(dungeonFinderIndex, noReloadInfo)
            end, 250)
        end
        d(noDataFoundText)
    end
end
local debugGetDungeonFinderData = lib.DebugGetDungeonFinderData

--This function scans the collectibles for their names to provide a list for the new DLCs and chapters
--Parameters: collectibleStartId number, the start ID of the collectibles to start the scan FROM
--            collectibleEndId number, the end ID of the collectibles to start the scan TO
function lib.DebugGetAllCollectibleNames(collectibleStartId, collectibleEndId, noReloadInfo)
    collectibleStartId = collectibleStartId or 1
    collectibleEndId = collectibleEndId or lib.debugMaxCollectibleIds
    noReloadInfo = noReloadInfo or false

    if nonOfficialLanguages[clientLang] then return end

    if collectibleEndId < collectibleStartId then collectibleEndId = collectibleStartId end
    d(libPrefix .. "Start to load all collectibles with start ID ".. collectibleStartId .. " to end ID " .. collectibleEndId .. "...")
    local collectiblesAdded = 0
    local collectibleDataScanned
    for i=collectibleStartId, collectibleEndId, 1 do
        local topLevelIndex, categoryIndex = GetCategoryInfoFromAchievementId(i)
        local collectibleName = zocstrfor("<<C:1>>", GetAchievementCategoryInfo(topLevelIndex))
        if collectibleName and collectibleName ~= "" then
            collectibleDataScanned = collectibleDataScanned or {}
            collectibleDataScanned[i] = tos(i) .. "|" .. collectibleName
            collectiblesAdded = collectiblesAdded +1
        end
    end
    if collectiblesAdded > 0 then
        tsort(collectibleDataScanned)
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES] = lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES][clientLang] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_NAMES][clientLang] = collectibleDataScanned
        d("->Stored " .. tos(collectiblesAdded) .." entries in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'" .. LIBSETS_TABLEKEY_COLLECTIBLE_NAMES .. "\', language: \'" ..tos(clientLang).."\'\nPlease do a /reloadui or logout to update the SavedVariables data now!")
        if noReloadInfo == true then return end
        d("Please do a /reloadui or logout to update the SavedVariables data now!")
    end
end
local debugGetAllCollectibleNames = lib.DebugGetAllCollectibleNames

--This function scans the collectibles for their DLC names to provide a list for the new DLCs and chapters
--Saves a line with collectibleId .. "|" .. collectibleSubCategoryIndex .. "|" .. collectibleName
function lib.DebugGetAllCollectibleDLCNames(noReloadInfo)
    noReloadInfo = noReloadInfo or false

    if nonOfficialLanguages[clientLang] then return end

    local dlcNames = {}
    local collectiblesAdded = 0
    d(libPrefix .. "Start to load all DLC collectibles")
    --DLCs
    --[[
    WRONG as of ZOs_DanBatson because GetCollectibleCategoryInfo needs a opLevelIndex and not a collectible category type id!)
    local _, numSubCategories, _, _, _, _ = GetCollectibleCategoryInfo(COLLECTIBLE_CATEGORY_TYPE_DLC)
    for collectibleSubCategoryIndex=1, numSubCategories do
        local _, numCollectibles, _, _ = GetCollectibleSubCategoryInfo(COLLECTIBLE_CATEGORY_TYPE_DLC, collectibleSubCategoryIndex)
        for i=1, numCollectibles do
            local collectibleId = GetCollectibleId(COLLECTIBLE_CATEGORY_TYPE_DLC, collectibleSubCategoryIndex, i)
            local collectibleName, _, _, _, _ = GetCollectibleInfo(collectibleId) -- Will return true or false. If the user unlocked throught ESO+ without buying DLC it will return true.
            collectibleName = zocstrfor("<<C:1>>", collectibleName)
            dlcNames[collectibleId] = collectibleId .. "|" .. collectibleSubCategoryIndex .. "|" .. collectibleName
            collectiblesAdded = collectiblesAdded +1
        end
    end
    --Chapters
    local _, numSubCategories, _, _, _, _ = GetCollectibleCategoryInfo(COLLECTIBLE_CATEGORY_TYPE_CHAPTER)
    for collectibleSubCategoryIndex=1, numSubCategories do
        local _, numCollectibles, _, _ = GetCollectibleSubCategoryInfo(COLLECTIBLE_CATEGORY_TYPE_CHAPTER, collectibleSubCategoryIndex)
        for i=1, numCollectibles do
            local collectibleId = GetCollectibleId(COLLECTIBLE_CATEGORY_TYPE_CHAPTER, collectibleSubCategoryIndex, i)
            local collectibleName, _, _, _, _ = GetCollectibleInfo(collectibleId) -- Will return true or false. If the user unlocked throught ESO+ without buying DLC it will return true.
            collectibleName = zocstrfor("<<C:1>>", collectibleName)
            dlcNames[collectibleId] = collectibleId .. "|" .. collectibleSubCategoryIndex .. "|" .. collectibleName
            collectiblesAdded = collectiblesAdded +1
        end
    end
    ]]

    for collectibleIndex=1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_DLC) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_DLC, collectibleIndex)
        local collectibleName, _, _, _, _ = GetCollectibleInfo(collectibleId) -- Will return true or false. If the user unlocked throught ESO+ without buying DLC it will return true.
        collectibleName = zocstrfor("<<C:1>>", collectibleName)
        dlcNames[collectibleId] = collectibleId .. "|DLC|" .. collectibleName
        collectiblesAdded = collectiblesAdded +1
    end
    for collectibleIndex=1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_CHAPTER) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_CHAPTER, collectibleIndex)
        local collectibleName, _, _, _, _ = GetCollectibleInfo(collectibleId) -- Will return true or false. If the user unlocked throught ESO+ without buying DLC it will return true.
        collectibleName = zocstrfor("<<C:1>>", collectibleName)
        dlcNames[collectibleId] = collectibleId .. "|CHAPTER|" .. collectibleName
        collectiblesAdded = collectiblesAdded +1
    end
    if collectiblesAdded > 0 then
        LoadSavedVariables()
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES] = lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES][clientLang] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES][clientLang] = dlcNames
        d("->Stored " .. tos(collectiblesAdded) .." entries in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'" .. LIBSETS_TABLEKEY_COLLECTIBLE_DLC_NAMES .. "\', language: \'" ..tos(clientLang).."\'")
        if noReloadInfo == true then return end
        d("Please do a /reloadui or logout to update the SavedVariables data now!")
    end
end
local debugGetAllCollectibleDLCNames = lib.DebugGetAllCollectibleDLCNames

--Only show the setIds that were added with the latest "Set itemId scan" via function "LibSets.DebugScanAllSetData()".
-->The function will compare the setIds of this table with the setIds in the file LibSets_Data_All.lua table lib.setInfo!
--->If there are no new setIds you either did NOT use the function "LibSets.DebugScanAllSetData()" before, did a reloadui,
--->copied the contents from the SavedVariables table to the lua minifier AND have transfered the scanned itemIds to the
---<file LibSets_Data_All.lua table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS].
--->Or there are no new setIds since the last time you updated this table.
function lib.DebugShowNewSetIds(noChatOutput)
    noChatOutput = noChatOutput or false
    if not noChatOutput then d(libPrefix .. "DebugShowNewSetIds - Checking for new setIds...") end

    --Is the local table still filled? Else: Fill it up again, either from SavedVariables of the current server and API version,
    --or by comparing setItemIds etc.
    local newSetsLoadedFromSV = false
    local tempSetNamesOfClientLang
    checkForNewSetIds(lib.setDataPreloaded[LIBSETS_TABLEKEY_SETITEMIDS], nil, true, true)
    --Output the new sets data (id and name)
    local newSetsFound = (newSetIdsFound and #newSetIdsFound) or 0
    if newSetsFound > 0 then
        if not noChatOutput then d(">Found " .. tos(newSetsFound) .. " new setIds!") end
        for idx, newSetId in ipairs(newSetIdsFound) do
            local newSetName = (lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId] ~= nil and
                    (lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId][clientLang] or lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES][newSetId][fallbackLang]))
            if newSetName == nil or newSetName == "" then
                newSetName = getNewSetName(newSetId)
            end
            newSetName = zocstrfor("<<C:1>>", newSetName)
            if not noChatOutput then d(strfor(">>New setId found: %s -> name: %s", tos(newSetId), tos(newSetName))) end
            if newSetName and newSetName ~= unknownName then
                tempSetNamesOfClientLang = tempSetNamesOfClientLang or {}
                tempSetNamesOfClientLang[newSetId] = newSetName
            end
            --Update the value of the table entry with the setId, --newSetName
            -->!!!This will make ALL access to the table go mad as the value is no the setId anymore and thus SavedVars save wrong setNames!!!
            --> DO NOT DO THIS!!! newSetIdsFound[idx] = newSetId .. ", --" .. newSetName
        end
    end
    if newSetsFound == 0 then
        if not noChatOutput then return end
        d("<No new setIds were found!\nDid you run function \'LibSets.DebugScanAllSetData()\' already?")
        d("Please read the function's description text in file \'LibSets_Debug.lua\' to be able to update the internal needed tables \'LibSets.setDataPreloaded[\'setItemIds\'] properly, before you try to search for new setIds!")
    else
        if not newSetsLoadedFromSV then
            LoadSavedVariables()
        end
        --First save the new found setIds to the SavedVariables table ""
        --Add the dateTime and APIversion the new setIds were scanned
        local apiVersionUpdatedStr = tos(apiVersion) .. "_UpdateInfo"
        lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS] = lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName] = lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName] or {}
        lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName][apiVersion] = newSetIdsFound
        lib.svDebugData[LIBSETS_TABLEKEY_NEWSETIDS][worldName][apiVersionUpdatedStr] = {
            ["UpdateType"]  = "LibSets.DebugShowNewSetIds()",
            ["DateTime"]    = os.date("%c")
        }
        if tempSetNamesOfClientLang ~= nil then
            lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] = lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES] or {}
            for setId, setName in pairs(tempSetNamesOfClientLang) do
                lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] = lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId] or {}
                lib.svDebugData[LIBSETS_TABLEKEY_SETNAMES][setId][clientLang] = setName
            end
        end
    end
end
local debugShowNewSetIds = lib.DebugShowNewSetIds


--Run all the debug functions for the current client language where one does not need to open any menus, dungeon finder or map for
function lib.DebugGetAllNames(noReloadInfo)
    noReloadInfo = noReloadInfo or false
    debugGetAllCollectibleNames(nil, nil, noReloadInfo)
    d(">>>--------------->>>")
    debugGetAllCollectibleDLCNames(noReloadInfo)
    d(">>>--------------->>>")
    debugGetAllMapNames(noReloadInfo)
    d(">>>--------------->>>")
    debugGetAllWayshrineNames(noReloadInfo)
    d(">>>--------------->>>")
    debugGetAllZoneInfo(noReloadInfo)
    d(">>>--------------->>>")
    -->Attention, you need to run LibSets.DebugScanAllSetData() first to scan for all setIds and setItemIds AND update
    -->the file LibSets_Data.lua, table LibSets.setItemIds, with them first, in order to let this function work properly
    -->and let it scan and get names of all current data! We need at least 1 itemId of the new setIds to build an itemlink
    -->to get the set name!
    debugGetAllSetNames(noReloadInfo)
end
local debugGetAllNames = lib.DebugGetAllNames

--Run this once after a new PTS was released to get all the new data scanned to the SV tables.
--The UI wil automatically change the language to the supported languages, once after another, and update the language
--dependent variables each time!
--If the parameter resetApiData is true the current scanned data of the apiversion will be reset and all will be
--scanned new again, includig the set itemIds.
--If parameter noItemIds is true all data will be rescanned, excluding the itemIds
--if the parameter onlyNames is true then only the name SavedVariables will be deleted and completely updated
--todo: Find bug within GetAllSetNames -> New setNames in languages AFTER the clientLanguage where the setItemIds were scanned,
--todo: do not update and just find "n/a" -> Somehow the setItemIds or setIds are missing and not read properly from SavedVariables
--todo: (where they have been scanned to before) after the reladoui to next language

function lib.DebugGetAllData(resetApiData, noItemIds, onlyNames)
    resetApiData = resetApiData or false
    noItemIds = noItemIds or false

    local newRun = false
    local languageToScanNext
    local alreadyFinished = false

    LoadSavedVariables()
    --Is the function called the 1st time for the current APIversion?
    --or is it executed after a reloadui e.g.?
    lib.svDebugData.DebugGetAllData = lib.svDebugData.DebugGetAllData or {}

    if resetApiData == true or lib.svDebugData.DebugGetAllData[apiVersion] == nil then
        newRun = true
        lib.svDebugData.DebugGetAllData[apiVersion] = {}
        --Save the original chosen client language
        lib.svDebugData.DebugGetAllData[apiVersion].clientLang = clientLang
        lib.svDebugData.DebugGetAllData[apiVersion].running = true
        lib.svDebugData.DebugGetAllData[apiVersion].DateTimeStart = os.date("%c")
    elseif lib.svDebugData.DebugGetAllData[apiVersion] ~= nil and lib.svDebugData.DebugGetAllData[apiVersion].running ~= nil then
        alreadyFinished = (lib.svDebugData.DebugGetAllData[apiVersion].finished == true) or false
    else
        return
    end

    d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    d(libPrefix .. ">>>DebugGetAllData START for API \'" ..  tos(apiVersion) .. "\' - newRun: " .. tos(newRun) .. ", resetApiData: " ..tos(resetApiData) .. ", noItemIds: " ..tos(noItemIds))
    if not alreadyFinished then
        if newRun == true then
            debugResetSavedVariables(true, onlyNames)
            --If no itemIds are requested: Skip the scan
            if not noItemIds then
                d(">>>--------------->>>")
                --This will take some time! Will only be done once per first reloadui as it will get the setIds and itemIds of the sets
                scanAllSetData(false, true)
                d(">>>--------------->>>")
            else
                noFurtherItemsFound = true
            end
        else
            noFurtherItemsFound = true
        end
        --Try every 2 seconds: If variable noFurtherItemsFound == true then run teh code below:
        local noFurtherItemsFoundUpdateName = lib.name .. "_RunIfNoFurtherItemsFound"
        EM:UnregisterForUpdate(noFurtherItemsFoundUpdateName)
        local function runIfNoFurtherItemsFound()
            if not noFurtherItemsFound then return end
            noFurtherItemsFound = false
            EM:UnregisterForUpdate(noFurtherItemsFoundUpdateName)

            --Update the SavedVariables with the current scanned language
            lib.svDebugData.DebugGetAllData[apiVersion].langDone = lib.svDebugData.DebugGetAllData[apiVersion].langDone or {}
            lib.svDebugData.DebugGetAllData[apiVersion].langDone[clientLang] = os.date("%c")

            --Skip non official languages as they might be missing/not enabled!
            for langStr, _ in pairs(nonOfficialLanguages) do
                --Add the languages to the already scanned ones -> Right from the start, to skip these
                lib.svDebugData.DebugGetAllData[apiVersion].langDone[langStr] = true
            end


            --Get all client language dependent data now
            --if not noItemIds then
            debugShowNewSetIds(true) -- Update internal tables with the new itemIds of the new determimed setIds
            --end
            debugGetAllNames(true)
            d(">>>--------------->>>")

            local delay = 0
            if newRun == true then
                --Will open the group menu, then select "specific dungeon", delayed by 250ms after group menu open
                debugGetDungeonFinderData(nil, true)
                d(">>>--------------->>>")
                --Will open the map and right click until at the current zone map
                delay = 500
                -->Delay by 500ms so that the dungeon finder data was collected properly
                zo_callLater(function()
                    debugGetAllWayshrineInfoOfCurrentMap()
                end, delay)
            end

            --Call the language check and switch via reloadui delayed by 500ms
            delay = delay + 500
            zo_callLater(function()
                d(libPrefix .. "<<<DebugGetAllData END - lang: " .. tos(clientLang))
                d("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

                --Get the language to scan as next one, if not all were scanned already
                local runData = lib.svDebugData.DebugGetAllData[apiVersion]
                local numLangsScanned = NonContiguousCount(runData.langDone)
                if numLangsScanned < numSupportedLangs then
                    for langStr, isSupported in pairs(supportedLanguages) do
                        if isSupported == true then
                            if not runData.langDone[langStr] then
                                languageToScanNext = langStr
                                break
                            end
                        end
                    end
                    --Reload the UI via client language switch or do a normal reload
                    if languageToScanNext ~= nil and languageToScanNext ~= "" and supportedLanguages[languageToScanNext] == true then
                        lib.svDebugData.DebugGetAllData[apiVersion].finished = false
                        lib.svDebugData.DebugGetAllData[apiVersion].running = true
                        lib.svDebugData.DebugGetAllData[apiVersion].LanguageChangeDateTime = os.date("%c")
                        lib.svDebugData.DebugGetAllData[apiVersion].LanguageChangeTo = languageToScanNext
                        SetCVar("language.2", languageToScanNext) --> Will do a reloadUI and change the client language
                    else
                        local errorText = "<<<[ERROR]Language to scan next \'".. tos(languageToScanNext) .. "\' is not supported! Aborting now..."
                        d(errorText)
                        lib.svDebugData.DebugGetAllData[apiVersion].running = false
                        lib.svDebugData.DebugGetAllData[apiVersion].finished = true
                        local dateTime = os.date("%c")
                        lib.svDebugData.DebugGetAllData[apiVersion].DateTimeEnd = dateTime
                        lib.svDebugData.DebugGetAllData[apiVersion].LastErrorDateTime = dateTime
                        lib.svDebugData.DebugGetAllData[apiVersion].LastError = errorText
                    end
                else
                    local origClientLang = lib.svDebugData.DebugGetAllData[apiVersion].clientLang
                    origClientLang = origClientLang or fallbackLang
                    d(libPrefix .. "DebugGetAllData was finished! Resetting to your original language again: " .. tos(origClientLang))
                    --All languages were scanned already. Switch back to original client language, or "en" as fallback
                    lib.svDebugData.DebugGetAllData[apiVersion].running = false
                    lib.svDebugData.DebugGetAllData[apiVersion].finished = true
                    lib.svDebugData.DebugGetAllData[apiVersion].DateTimeEnd = os.date("%c")
                    SetCVar("language.2", origClientLang) --> Will do a reloadUI and change the client language
                end

            end, delay)
        end
        EM:RegisterForUpdate(noFurtherItemsFoundUpdateName, 2000, runIfNoFurtherItemsFound)
    else
        local errorText = "> APIversion \'".. tos(apiVersion) .. "\' was scanned and updated already on: " ..tos(lib.svDebugData.DebugGetAllData[apiVersion].DateTimeEnd)
        lib.svDebugData.DebugGetAllData[apiVersion].LastErrorDateTime = os.date("%c")
        lib.svDebugData.DebugGetAllData[apiVersion].LastError = errorText
        d(errorText)
        d(libPrefix .. "<<<DebugGetAllData END - lang: " .. tos(clientLang))
        d("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    end
end

------------------------------------------------------------------------------------------------------------------------
-- MIXING NEW SET NAMES INTO THE PRELOADED DATA
-- Put other language setNames here in the variable called "otherLangSetNames" below a table key representing the language
-- you want to "mix" into the LibSets_Data_All.lua file's table "lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]" (e.g. ["jp"])
------------------------------------------------------------------------------------------------------------------------
local otherLangSetNames={
    --Example
    --["jp"] = {[19]={["jp"]="妖術師の法衣"},[20]={["jp"]="魔法使いの鎧"},[21]={["jp"]="アカヴィリのドラゴンガード"},...}
    --Last updated: API 100029 Scalebreaker -> Provided by esoui user Calamath 2020-01-18
    --Uncomment the table below to activate it!
    --["jp"] = {[19]={["jp"]="妖術師の法衣"},[20]={["jp"]="魔法使いの鎧"},[21]={["jp"]="アカヴィリのドラゴンガード"},[22]={["jp"]="夢見人のマント"},[23]={["jp"]="射手の精神"},[24]={["jp"]="歩兵の幸運"},[25]={["jp"]="砂漠バラ"},[26]={["jp"]="囚人のぼろ服"},[27]={["jp"]="フィヨルドの遺産"},[28]={["jp"]="バークスキン"},[29]={["jp"]="軍曹の鎧"},[30]={["jp"]="サンダーバグの甲殻"},[31]={["jp"]="太陽の絹服"},[32]={["jp"]="治癒師の衣服"},[33]={["jp"]="毒蛇の針"},[34]={["jp"]="夜母の抱擁"},[35]={["jp"]="ナイト・メア"},[36]={["jp"]="ベールの継承者の鎧"},[37]={["jp"]="死を招く風"},[38]={["jp"]="黄昏の抱擁"},[39]={["jp"]="アレッシア教団"},[40]={["jp"]="寂夜"},[41]={["jp"]="ホワイトストレークの報復"},[43]={["jp"]="誘惑者の武具"},[44]={["jp"]="吸血鬼の口づけ"},[46]={["jp"]="高貴なる決闘者の衣装"},[47]={["jp"]="ウィサード・ハンドのローブ"},[48]={["jp"]="マグナスの贈物"},[49]={["jp"]="レッドマウンテンの影"},[50]={["jp"]="モラグ・トング"},[51]={["jp"]="夜母の注視"},[52]={["jp"]="誘引の鋼"},[53]={["jp"]="氷炉"},[54]={["jp"]="青白い柄"},[55]={["jp"]="祈りのショール"},[56]={["jp"]="ステンダールの抱擁"},[57]={["jp"]="シラベインの捕縛"},[58]={["jp"]="ウェアウルフの皮"},[59]={["jp"]="カイネの口づけ"},[60]={["jp"]="闇歩み"},[61]={["jp"]="ドゥルー王殺し"},[62]={["jp"]="幼虫の殻"},[63]={["jp"]="ジャガーノート"},[64]={["jp"]="シャドウダンサーの衣服"},[65]={["jp"]="ブラッドソーンの接触"},[66]={["jp"]="ヒストのローブ"},[67]={["jp"]="影の歩き手"},[68]={["jp"]="ステュクス"},[69]={["jp"]="レンジャーの足どり"},[70]={["jp"]="第七軍団のブルート"},[71]={["jp"]="デュロクの破滅"},[72]={["jp"]="ニクラスの重装鎧"},[73]={["jp"]="反オブリビオン"},[74]={["jp"]="霊なる瞳"},[75]={["jp"]="トラグパクト"},[76]={["jp"]="変性術師の衣服"},[77]={["jp"]="聖戦士"},[78]={["jp"]="ヒスト樹皮"},[79]={["jp"]="ウィロー路"},[80]={["jp"]="怒れるフンディング"},[81]={["jp"]="ラマエ歌"},[82]={["jp"]="アレッシア守護"},[83]={["jp"]="エルフ殺し"},[84]={["jp"]="オルグヌム鱗"},[85]={["jp"]="アルマレクシアの慈愛"},[86]={["jp"]="女王の雅"},[87]={["jp"]="マーラの目"},[88]={["jp"]="熟練なる破壊術のローブ"},[89]={["jp"]="哨戒兵"},[90]={["jp"]="センチの牙"},[91]={["jp"]="オブリビオンの刃"},[92]={["jp"]="カグレナクの希望"},[93]={["jp"]="ストームナイトの防具"},[94]={["jp"]="メリディアの祝福の武具"},[95]={["jp"]="呪えしシャリドール"},[96]={["jp"]="真実の鎧"},[97]={["jp"]="アークメイジ"},[98]={["jp"]="ネクロポーテンス"},[99]={["jp"]="救済"},[100]={["jp"]="ホークアイ"},[101]={["jp"]="感染者"},[102]={["jp"]="デューンリッパーの鱗"},[103]={["jp"]="マジカ炉"},[104]={["jp"]="呪いを喰らう者"},[105]={["jp"]="双子姉妹"},[106]={["jp"]="さまよえる女王のアーチ"},[107]={["jp"]="ウィルドの樹の祝福"},[108]={["jp"]="破壊者"},[109]={["jp"]="シロディールの光"},[110]={["jp"]="聖域"},[111]={["jp"]="シロディールの結界"},[112]={["jp"]="夜の恐怖"},[113]={["jp"]="シロディールの頂飾"},[114]={["jp"]="魂の輝き"},[116]={["jp"]="破壊の一組"},[117]={["jp"]="医薬師アンスールの遺物"},[118]={["jp"]="アースフォージの宝物"},[119]={["jp"]="反乱の遺物"},[120]={["jp"]="インファーナンスの武具"},[121]={["jp"]="先人の武器"},[122]={["jp"]="黒檀の武具"},[123]={["jp"]="ハーシーンの虚飾"},[124]={["jp"]="虫の教団装備"},[125]={["jp"]="帝国の憤怒"},[126]={["jp"]="古代の恩寵"},[127]={["jp"]="致死の一撃"},[128]={["jp"]="最高顧問の加護"},[129]={["jp"]="復讐の吸血"},[130]={["jp"]="鷲の目"},[131]={["jp"]="防衛のハートランド"},[132]={["jp"]="守護のバリアント"},[133]={["jp"]="防護のスイフト"},[134]={["jp"]="リッチの覆い"},[135]={["jp"]="ドラウグルの遺産"},[136]={["jp"]="不死身の戦士"},[137]={["jp"]="凶暴な戦士"},[138]={["jp"]="守護の戦士"},[139]={["jp"]="博学の魔術師"},[140]={["jp"]="破壊の魔術師"},[141]={["jp"]="治癒の魔術師"},[142]={["jp"]="素早さの大蛇"},[143]={["jp"]="毒の大蛇"},[144]={["jp"]="双牙蛇"},[145]={["jp"]="炎の流儀"},[146]={["jp"]="大気の流儀"},[147]={["jp"]="武術知識の道"},[148]={["jp"]="アリーナの流儀"},[155]={["jp"]="アンドーンテッド砦"},[156]={["jp"]="アンドーンテッドの潜入者"},[157]={["jp"]="アンドーンテッドのほころびた装備"},[158]={["jp"]="エンバーシールド"},[159]={["jp"]="サンダーフレイム"},[160]={["jp"]="炎上するスペルウィーブ"},[161]={["jp"]="双子星"},[162]={["jp"]="メファーラの落とし子"},[163]={["jp"]="ブラッドスポーン"},[164]={["jp"]="看守長"},[165]={["jp"]="スカージの収穫者"},[166]={["jp"]="エンジンのガーディアン"},[167]={["jp"]="夜の炎"},[168]={["jp"]="ネリエンエス"},[169]={["jp"]="ヴァルキン・スコリア"},[170]={["jp"]="業火のモー"},[171]={["jp"]="不滅の戦士"},[172]={["jp"]="完全なる魔術師"},[173]={["jp"]="残忍な大蛇"},[176]={["jp"]="大親征"},[177]={["jp"]="再分配"},[178]={["jp"]="鎧匠"},[179]={["jp"]="ブラックローズ"},[180]={["jp"]="強襲者"},[181]={["jp"]="勲功"},[183]={["jp"]="モラグ・キーナ"},[184]={["jp"]="帝国の印"},[185]={["jp"]="呪文攻撃治癒"},[186]={["jp"]="大揺れの武具"},[187]={["jp"]="沼の襲撃者"},[188]={["jp"]="嵐マスター"},[190]={["jp"]="辛辣な魔術師"},[193]={["jp"]="圧倒するサージ"},[194]={["jp"]="戦闘医薬師"},[195]={["jp"]="純粋な毒"},[196]={["jp"]="吸血プレート"},[197]={["jp"]="拷問者"},[198]={["jp"]="エキス盗賊"},[199]={["jp"]="シールドブレイカー"},[200]={["jp"]="不死鳥"},[201]={["jp"]="反応型鎧"},[204]={["jp"]="持久力"},[205]={["jp"]="意志"},[206]={["jp"]="俊敏"},[207]={["jp"]="ジュリアノスの掟"},[208]={["jp"]="炎の試練"},[209]={["jp"]="掟の鎧"},[210]={["jp"]="追放者の印"},[211]={["jp"]="永久凍土層"},[212]={["jp"]="ブライア・ハート"},[213]={["jp"]="栄光の守り手"},[214]={["jp"]="パラベルム"},[215]={["jp"]="継承の属性"},[216]={["jp"]="狩猟の先導者"},[217]={["jp"]="ウィンターボーン"},[218]={["jp"]="トリニマクの武勇"},[219]={["jp"]="モークルディン"},[224]={["jp"]="ターヴァの寵"},[225]={["jp"]="賢明な錬金術師"},[226]={["jp"]="エターナルハント"},[227]={["jp"]="バーラハの呪い"},[228]={["jp"]="シヴァラの鱗"},[229]={["jp"]="黄昏なる救済"},[230]={["jp"]="ムーンダンサー"},[231]={["jp"]="月の砦"},[232]={["jp"]="アルコシュの咆哮"},[234]={["jp"]="射手の頂飾"},[235]={["jp"]="変化の武具"},[236]={["jp"]="残忍な死"},[237]={["jp"]="レキのフォーカス"},[238]={["jp"]="ファサラの策謀"},[239]={["jp"]="戦士の激昂"},[240]={["jp"]="クヴァッチ剣闘士"},[241]={["jp"]="ヴァレンレガシー"},[242]={["jp"]="ペリナルの適性"},[243]={["jp"]="モリハウスの皮"},[244]={["jp"]="奇襲攻撃の戦略家"},[245]={["jp"]="シシスの接触"},[246]={["jp"]="ガレリオンの復讐"},[247]={["jp"]="バイスカノンの毒"},[248]={["jp"]="導き手の力"},[253]={["jp"]="インペリアルフィジカル"},[256]={["jp"]="強きチュダン"},[257]={["jp"]="ヴェリドレス"},[258]={["jp"]="琥珀のプラズム"},[259]={["jp"]="ヘーム・ジャスの報復"},[260]={["jp"]="マザッタンの姿"},[261]={["jp"]="流れ糸"},[262]={["jp"]="ウィドウメーカー"},[263]={["jp"]="メファーラの手"},[264]={["jp"]="ジャイアントスパイダー"},[265]={["jp"]="シャドウレンド"},[266]={["jp"]="クラグ"},[267]={["jp"]="スワームマザー"},[268]={["jp"]="ルクガムズの守衛"},[269]={["jp"]="チョークソーン"},[270]={["jp"]="スライムクロー"},[271]={["jp"]="セリストリクス"},[272]={["jp"]="業火のガーディアン"},[273]={["jp"]="イランブリス"},[274]={["jp"]="アイスハート"},[275]={["jp"]="ストームフィスト"},[276]={["jp"]="トレモルスケール"},[277]={["jp"]="海賊スケルトン"},[278]={["jp"]="トロールキング"},[279]={["jp"]="セレーン"},[280]={["jp"]="グロスダール"},[281]={["jp"]="訓練生の鎧"},[282]={["jp"]="吸血鬼のクローク"},[283]={["jp"]="ソードシンガー"},[284]={["jp"]="ダイアグナ騎士団"},[285]={["jp"]="吸血鬼の王"},[286]={["jp"]="スプリガンのいばら"},[287]={["jp"]="グリーンパクト"},[288]={["jp"]="養蜂家の装備"},[289]={["jp"]="紡ぎ手の衣服"},[290]={["jp"]="スクゥーマ密売人"},[291]={["jp"]="ショークの外骨格"},[292]={["jp"]="母の悲しみ"},[293]={["jp"]="疫病医"},[294]={["jp"]="イスグラモルの生得権"},[295]={["jp"]="牢破り"},[296]={["jp"]="スペランカー"},[297]={["jp"]="クモの教団信者の頭巾"},[298]={["jp"]="光の代弁者"},[299]={["jp"]="トゥースロウ"},[300]={["jp"]="ネッチの接触"},[301]={["jp"]="オートマトンの力"},[302]={["jp"]="リヴァイアサン"},[303]={["jp"]="ラミアの歌"},[304]={["jp"]="メドゥーサ"},[305]={["jp"]="トレジャーハンター"},[307]={["jp"]="ドラウグル・ハルキング"},[308]={["jp"]="骨の海賊のボロ"},[309]={["jp"]="遍歴の騎士の鎧"},[310]={["jp"]="ソードダンサー"},[311]={["jp"]="ラトルケージ"},[313]={["jp"]="大切断"},[314]={["jp"]="穿刺回復"},[315]={["jp"]="ひりつく斬撃"},[316]={["jp"]="腐食の矢"},[317]={["jp"]="破壊の衝撃"},[318]={["jp"]="大いなる再生"},[320]={["jp"]="戦乙女"},[321]={["jp"]="冒涜者"},[322]={["jp"]="戦詩人"},[323]={["jp"]="アサシンの幻惑"},[324]={["jp"]="デイドラの策略"},[325]={["jp"]="シャックルブレイカー"},[326]={["jp"]="挑む先遣隊"},[327]={["jp"]="臆病な歯車"},[328]={["jp"]="騎士殺し"},[329]={["jp"]="魔術師カウンター"},[330]={["jp"]="自律防御"},[331]={["jp"]="ウォーマシン"},[332]={["jp"]="匠の技"},[333]={["jp"]="発明家の守り"},[334]={["jp"]="非貫通アーマー"},[335]={["jp"]="ドラウグルズレスト"},[336]={["jp"]="ニルンの柱"},[337]={["jp"]="アイアンブラッド"},[338]={["jp"]="炎の花"},[339]={["jp"]="ブラッドドリンカー"},[340]={["jp"]="ハグレイヴン庭園"},[341]={["jp"]="アースゴア"},[342]={["jp"]="ドミーハウス"},[343]={["jp"]="カルウリオンの遺産"},[344]={["jp"]="活力の証"},[345]={["jp"]="ウルフノールの加護"},[346]={["jp"]="ジョルバルドの導き"},[347]={["jp"]="疫病の運び手"},[348]={["jp"]="ドイルミッシュの呪い"},[349]={["jp"]="サーヴォクン"},[350]={["jp"]="ザーン"},[351]={["jp"]="内在公理"},[352]={["jp"]="強化真鍮"},[353]={["jp"]="機械的精度"},[354]={["jp"]="狂気の鋳掛屋"},[355]={["jp"]="深淵の暗黒"},[356]={["jp"]="ライブワイヤー"},[357]={["jp"]="熟練したスラッシュ(完全)"},[358]={["jp"]="防御姿勢(完全)"},[359]={["jp"]="混沌の旋風(完全)"},[360]={["jp"]="貫通散布(完全)"},[361]={["jp"]="集中フォース(完全)"},[362]={["jp"]="朽ちぬ祝福(完全)"},[363]={["jp"]="熟練したスラッシュ"},[364]={["jp"]="防御姿勢"},[365]={["jp"]="混沌の旋風"},[366]={["jp"]="貫通散布"},[367]={["jp"]="集中フォース"},[368]={["jp"]="朽ちぬ祝福"},[369]={["jp"]="無慈悲なチャージ"},[370]={["jp"]="ランペイジスラッシュ"},[371]={["jp"]="冷酷な猛攻"},[372]={["jp"]="斉射(雷)"},[373]={["jp"]="壁破壊"},[374]={["jp"]="精密再生"},[380]={["jp"]="預言者"},[381]={["jp"]="壊れた魂"},[382]={["jp"]="闇の気品"},[383]={["jp"]="グリフォンの獰猛"},[384]={["jp"]="ヴァヌスの叡智"},[385]={["jp"]="熟練騎手"},[386]={["jp"]="スロードの装い"},[387]={["jp"]="ノクターナルの寵愛"},[388]={["jp"]="ガレンウェの盾"},[389]={["jp"]="レレクエンの腕"},[390]={["jp"]="シロリアのマント"},[391]={["jp"]="オロライムのベスト"},[392]={["jp"]="ガレンウェの完璧な盾"},[393]={["jp"]="レレクエンの完璧な武器"},[394]={["jp"]="シロリアの完璧なマント"},[395]={["jp"]="オロライムの完璧なベスト"},[397]={["jp"]="バローグ"},[398]={["jp"]="ヴィコサ"},[399]={["jp"]="ハヌの慈悲"},[400]={["jp"]="血の月"},[401]={["jp"]="ウルサスの避難所"},[402]={["jp"]="月狩人"},[403]={["jp"]="獰猛なウェアウルフ"},[404]={["jp"]="看守の執念"},[405]={["jp"]="ブライトスロートの自慢"},[406]={["jp"]="デッドウォーターの奸智"},[407]={["jp"]="ヒストの勇者"},[408]={["jp"]="墓標コレクター"},[409]={["jp"]="ナガ呪術師"},[410]={["jp"]="失われた軍団の力"},[411]={["jp"]="勇士の突撃"},[412]={["jp"]="放射アッパーカット"},[413]={["jp"]="形なきクローク"},[414]={["jp"]="有毒ショット"},[415]={["jp"]="激しい衝撃"},[416]={["jp"]="癒し手の結界"},[417]={["jp"]="不屈の激昂"},[418]={["jp"]="魔法戦略家"},[419]={["jp"]="戦場アクロバット"},[420]={["jp"]="苦痛の戦士"},[421]={["jp"]="頑強な英雄"},[422]={["jp"]="大隊の守り手"},[423]={["jp"]="完全な勇士の突撃"},[424]={["jp"]="完全な放射アッパーカット"},[425]={["jp"]="完全な形なきクローク"},[426]={["jp"]="完全な有毒ショット"},[427]={["jp"]="完全な衝撃"},[428]={["jp"]="完全な癒し手の結界"},[429]={["jp"]="強き氷河"},[430]={["jp"]="ツォグヴィンの軍団"},[431]={["jp"]="氷の召喚士"},[432]={["jp"]="石の番人"},[433]={["jp"]="凍った監視人"},[434]={["jp"]="スカベンジングの殺到"},[435]={["jp"]="オーロランの雷"},[436]={["jp"]="シンフォニー・オブ・ブレイズ"},[437]={["jp"]="コールドハーバーの流行"},[438]={["jp"]="センチラートの底力"},[439]={["jp"]="ヴァスタリーの教え"},[440]={["jp"]="狡猾なるアルフィク"},[441]={["jp"]="ダルロック・ブレイの礼装"},[442]={["jp"]="墓堀の呼び声"},[443]={["jp"]="ナーヴィンタースの目"},[444]={["jp"]="偽りの神への献身"},[445]={["jp"]="ロクケスティーズの歯"},[446]={["jp"]="ヨルナークリンの爪"},[448]={["jp"]="完全なナーヴィンタースの目"},[449]={["jp"]="完全な偽りの神への献身"},[450]={["jp"]="完全なロクケスティーズの歯"},[451]={["jp"]="完全なヨルナークリンの爪"},[452]={["jp"]="ホロウファングの渇き"},[453]={["jp"]="ドロザカールの爪"},[454]={["jp"]="レナルドの決意"},[455]={["jp"]="ズェンの矯正"},[456]={["jp"]="アズールブライトの死神"},[457]={["jp"]="ドラゴンの冒涜"},[458]={["jp"]="グランドウルフ"},[459]={["jp"]="マーセロク"},[465]={["jp"]="センシャルの守り手"},[466]={["jp"]="略奪者の加速"},[467]={["jp"]="ドラゴンガードの精鋭"},[468]={["jp"]="大胆な海賊"},[469]={["jp"]="古代ドラゴンガード"},[470]={["jp"]="新たなる月の侍者"}},
}
--Manual tasks before
--1. Add a new subtable above to table "otherLangSetNames" where the key is the language you want to add e.g. ["jp"]
--2. Add a new subtable to this new key containing the [setId] as key and the setName String as value
-- Example:  ["jp"] = { [19]={["jp"]="妖術師の法衣"},[20]={["jp"]="魔法使いの鎧"},[21]={["jp"]="アカヴィリのドラゴンガード"}, ... },

--Run the function LibSets.debugBuildMixedSetNames() (see below) ingame to:
--3. Get the existing data of table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES] from file "LibSets_Data_All.lua"
--4. Let it parse the table otherLangSetNames above
--5. For each language detected update the table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES] with the (new) entries of the language above
--6. Dump the table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES] to the SavedVariables of LibSets, with the key "MixedSetNamesForDataAll"

--Manual tasks afterwards
--7. You need to logout then and copy the SavedVariables table "MixedSetNamesForDataAll"
--8. Use a lua minifier to shrink the code, e.g. https://mothereff.in/lua-minifier
--9* Put the shrinked lua table contents in the preloaded data table lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES] in file "LibSets_Data_All.lua"
--   Now all new/ changed entries should be in there, old ones + the ones from table "otherLangSetNames" above!
--11. Delete the contents of table "otherLangSetNames" above in this file "LibSets_Debug.lua" again
function lib.debugBuildMixedSetNames()
    d(libPrefix .. "Start to combine entries from table \'otherLangSetNames\' in file \'LibSets_Debug.lua\' into table \'LibSets.setDataPreloaded["..LIBSETS_TABLEKEY_SETNAMES.."]\'")
    --SavedVariables table key: LIBSETS_TABLEKEY_MIXED_SETNAMES
    if not otherLangSetNames then return end
    if not lib.setDataPreloaded then return end
    local preloadedSetNames = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]
    if not preloadedSetNames then return end
    local copyOfPreloadedSetNames = ZO_DeepTableCopy(preloadedSetNames)
    if not copyOfPreloadedSetNames then return end
    --[[
        --Debug output of all given preloaded setIds, languages and names
        for setId, setData in pairs(copyOfPreloadedSetNames) do
            for lang, setName in pairs(setData) do
                d(strfor(">setId: %s, lang: %s, name: %s", tos(setId), tos(lang), tos(setName)))
            end
        end
    ]]
    local setIdsFound = 0
    local setIdsChanged = 0
    local setIdsChangedTotal = 0
    --Each language which needs to be combined from otherLangSetNames into lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]
    for lang, langDataToCombine in pairs(otherLangSetNames) do
        setIdsFound = 0
        setIdsChanged = 0
        --Each setId which needs to be combined from otherLangSetNames[lang] into lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]
        for setId, setDataToCombine  in pairs(langDataToCombine) do
            setIdsFound = setIdsFound + 1
            --Does a subtable entry in otherLangSetNames exist with the same language as key which should be updated?
            local setDataToCombineForLangKey = setDataToCombine[lang]
            if setDataToCombineForLangKey and setDataToCombineForLangKey ~= "" then
                --Use existing or create setId in the new table for the SavedVariables
                copyOfPreloadedSetNames[ton(setId)] = copyOfPreloadedSetNames[ton(setId)] or {}
                --Use existing or create lang subtable in the new setId table entry for the SavedVariables
                copyOfPreloadedSetNames[ton(setId)][lang] = copyOfPreloadedSetNames[ton(setId)][lang] or {}
                copyOfPreloadedSetNames[ton(setId)][lang] = setDataToCombineForLangKey
                setIdsChanged = setIdsChanged + 1
                setIdsChangedTotal = setIdsChangedTotal + setIdsChanged
            end
        end
        --Update the SavedVariables now
        if setIdsChanged > 0 then
            d("<Updated " ..tos(setIdsChanged).. "/" .. tos(setIdsFound) .." setNames for language: " ..tos(lang))
        end
    end
    if setIdsChangedTotal > 0 then
        LoadSavedVariables()
        --Reset the combined setNames table in the SavedVariables
        lib.svDebugData[LIBSETS_TABLEKEY_MIXED_SETNAMES] = {}
        lib.svDebugData[LIBSETS_TABLEKEY_MIXED_SETNAMES] = copyOfPreloadedSetNames
        d(storedInSVFileLibSetsInTable .. "\'"..LIBSETS_TABLEKEY_MIXED_SETNAMES.."\'\nPlease do a /reloadui or logout to update the SavedVariables data now!")
    else
        d("<No setIds were updated!")
    end
end