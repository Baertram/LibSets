LibSets = LibSets or {}
local lib = LibSets
local MAJOR = lib.name
local MINOR = lib.version
local LoadSavedVariables = lib.LoadSavedVariables

-------------------------------------------------------------------------------------------------------------------------------
-- Data update functions - Only for developers of this lib to get new data from e.g. the PTS or after major patches on live.
-- e.g. to get the new wayshrines names and zoneNames
-- Uncomment to use them via the libraries global functions then
-------------------------------------------------------------------------------------------------------------------------------
local debugOutputStartLine = "==============================\n"
local function GetAllZoneInfo()
    local lang = GetCVar("language.2")
    d(debugOutputStartLine.."[".. MAJOR .. " v" .. tostring(MINOR).."]GetAllZoneInfo, language: " ..tostring(lang))
    local maxZoneId = 2000
    local zoneData = {}
    zoneData[lang] = {}
    --zoneIndex1 "Clean Test"'s zoneId
    local zoneIndex1ZoneId = GetZoneId(1) -- should be: 2
    for zoneId = 1, maxZoneId, 1 do
        local zi = GetZoneIndex(zoneId)
        if zi ~= nil then
            local pzid = GetParentZoneId(zoneId)
            --With API100027 Elsywer every non-used zoneIndex will be 1 instead 0 :-(
            --So we need to check if the zoneIndex is 1 and the zoneId <> the zoneId for index 1
            if (zi == 1 and zoneId == zoneIndex1ZoneId) or zi ~= 1 then
                local zoneNameClean = zo_strformat("<<C:1>>", GetZoneNameByIndex(zi))
                if zoneNameClean ~= nil then
                    zoneData[lang][zoneId] = zoneId .. "|" .. zi .. "|" .. pzid .. "|" ..zoneNameClean
                end
            end
        end
    end
    return zoneData
end

--Execute in each map to get wayshrine data
local function GetWayshrineInfo()
    d(debugOutputStartLine.."[".. MAJOR .. " v" .. tostring(MINOR).."]GetWayshrineInfo")
    local errorMapNavigateText = " Please open the map and navigate to a zone map first before running this function!"
    local wayshrines = {}
    local currentMapIndex = GetCurrentMapIndex()
    if currentMapIndex == nil then d("<-Error: map index missing." .. errorMapNavigateText) return end
    local currentMapId = GetCurrentMapId()
    if currentMapId == nil then d("<-Error: map id missing." .. errorMapNavigateText) return end
    local currentMapsZoneIndex = GetCurrentMapZoneIndex()
    if currentMapsZoneIndex == nil then d("<-Error: map zone index missing." .. errorMapNavigateText) return end
    local currentZoneId = GetZoneId(currentMapsZoneIndex)
    if currentZoneId == nil then d("<-Error: map zone id missing." .. errorMapNavigateText) return end
    local currentMapName = ZO_CachedStrFormat("<<C:1>>", GetMapNameByIndex(currentMapIndex))
    local currentZoneName = ZO_CachedStrFormat("<<C:1>>", GetZoneNameByIndex(currentMapsZoneIndex))
    --d("->mapIndex: " .. tostring(currentMapIndex) .. ", mapId: " .. tostring(currentMapId) ..
    --        ", mapName: " .. tostring(currentMapName) .. ", mapZoneIndex: " ..tostring(currentMapsZoneIndex) .. ", zoneId: " .. tostring(currentZoneId) ..
    --        ", zoneName: " ..tostring(currentZoneName))
    for i=1, GetNumFastTravelNodes(), 1 do
        local wsknown, wsname, wsnormalizedX, wsnormalizedY, wsicon, wsglowIcon, wspoiType, wsisShownInCurrentMap, wslinkedCollectibleIsLocked = GetFastTravelNodeInfo(i)
        if wsisShownInCurrentMap then
            local wsNameStripped = ZO_CachedStrFormat("<<C:1>>",wsname)
            d("->[" .. tostring(i) .. "] " ..tostring(wsNameStripped))
            --Export for excel split at | char
            --WayshrineNodeId, mapIndex, mapId, mapName, zoneIndex, zoneId, zoneName, POIType, wayshrineName
            wayshrines[i] = tostring(i).."|"..tostring(currentMapIndex).."|"..tostring(currentMapId).."|"..tostring(currentMapName).."|"..
                    tostring(currentMapsZoneIndex).."|"..tostring(currentZoneId).."|"..tostring(currentZoneName).."|"..tostring(wspoiType).."|".. tostring(wsNameStripped)
        end
    end
    return wayshrines
end

local function GetWayshrineNames()
    local lang = GetCVar("language.2")
    d(debugOutputStartLine.."[".. MAJOR .. " v" .. tostring(MINOR).."]GetWayshrineNames, language: " ..tostring(lang))
    local wsNames = {}
    wsNames[lang] = {}
    for wsNodeId=1, GetNumFastTravelNodes(), 1 do
        --** _Returns:_ *bool* _known_, *string* _name_, *number* _normalizedX_, *number* _normalizedY_, *textureName* _icon_, *textureName:nilable* _glowIcon_, *[PointOfInterestType|#PointOfInterestType]* _poiType_, *bool* _isShownInCurrentMap_, *bool* _linkedCollectibleIsLocked_
        local _, wsLocalizedName = GetFastTravelNodeInfo(wsNodeId)
        if wsLocalizedName ~= nil then
            local wsLocalizedNameClean = ZO_CachedStrFormat("<<C:1>>", wsLocalizedName)
            wsNames[lang][wsNodeId] = tostring(wsNodeId) .. "|" .. wsLocalizedNameClean
        end
    end
    return wsNames
end

local function GetMapNames(lang)
    lang = lang or GetCVar("language.2")
    d(debugOutputStartLine.."[".. MAJOR .. " v" .. tostring(MINOR).."]GetMapNames, language: " ..tostring(lang))
    local lz = lib.libZone
    if not lz then d("ERROR: Library LibZone must be loaded!") return end
    local zoneIds = lz.givenZoneData
    if not zoneIds then d("ERROR: Library LibZone givenZoneData is missing!") return end
    local zoneIdsLocalized = zoneIds[lang]
    if not zoneIdsLocalized then d("ERROR: Language \"" .. tostring(lang) .."\" is not scanned yet in library LibZone") return end
    local mapNames = {}
    for zoneId, zoneNameLocalized in pairs(zoneIdsLocalized) do
        local mapIndex = GetMapIndexByZoneId(zoneId)
        --d(">zoneId: " ..tostring(zoneId) .. ", mapIndex: " ..tostring(mapIndex))
        if mapIndex ~= nil then
            local mapName = ZO_CachedStrFormat("<<C:1>>", GetMapNameByIndex(mapIndex))
            if mapName ~= nil then
                mapNames[mapIndex] = tostring(mapIndex) .. "|" .. mapName .. "|" .. tostring(zoneId) .. "|" .. zoneNameLocalized
            end
        end
    end
    return mapNames
end

------------------------------------------------------------------------------------------------------------------------
-- Scan for zone names -> Save them in the SavedVariables "zoneData"
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the zone data in the current client language and saves it to the SavedVars table "zoneData" in this format:
--zoneData[lang][zoneId] = zoneId .. "|" .. zoneIndex .. "|" .. parentZoneId .. "|" ..zoneNameCleanLocalizedInClientLanguage
function lib.DebugGetAllZoneInfo()
    local zoneData = GetAllZoneInfo()
    if zoneData ~= nil then
        LoadSavedVariables()
        lib.svData.zoneData = lib.svData.zoneData or {}
        lib.svData.zoneData[lib.clientLang] = {}
        lib.svData.zoneData[lib.clientLang] = zoneData[lib.clientLang]
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'zoneData\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Scan for map names -> Save them in the SavedVariables "maps"
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the maps data in the current client language and saves it to the SavedVars table "maps" in this format:
--maps[mapIndex] = mapIndex .. "|" .. localizedCleanMapNameInClientLanguage .. "|" .. zoneId .. "|" .. zoneNameLocalizedInClientLanguage
function lib.DebugGetAllMapNames()
    local maps = GetMapNames(lib.clientLang)
    if maps ~= nil then
        LoadSavedVariables()
        lib.svData.maps = lib.svData.maps or {}
        lib.svData.maps[lib.clientLang] = {}
        lib.svData.maps[lib.clientLang] = maps
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'maps\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Scan for wayshrines -> Save them in the SavedVariables "wayshrines"
--> You need to open a map (zone map, no city or sub-zone maps!) in order to let the function work properly
------------------------------------------------------------------------------------------------------------------------
--Returns a list of the wayshrine data (nodes) in the current client language and saves it to the SavedVars table "wayshrines" in this format:
--wayshrines[i] = wayshrineNodeId .."|"..currentMapIndex.."|"..currentMapId.."|"..currentMapNameLocalizedInClientLanguage.."|"
--..currentMapsZoneIndex.."|"..currentZoneId.."|"..currentZoneNameLocalizedInClientLanguage.."|"..wayshrinesPOIType.."|".. wayshrineNameCleanLocalizedInClientLanguage
function lib.DebugGetAllWayshrineInfo()
    local ws = GetWayshrineInfo()
    if ws ~= nil then
        LoadSavedVariables()
        lib.svData.wayshrines = lib.svData.wayshrines or {}
        for wsNodeId, wsData in pairs(ws) do
            lib.svData.wayshrines[wsNodeId] = wsData
        end
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'wayshrines\'")
    end
end

--Returns a list of the wayshrine names in the current client language and saves it to the SavedVars table "wayshrineNames" in this format:
--wayshrineNames[clientLanguage][wayshrineNodeId] = wayshrineNodeId .. "|" .. wayshrineLocalizedNameCleanInClientLanguage
function lib.DebugGetAllWayshrineNames()
    local wsNames = GetWayshrineNames()
    if wsNames ~= nil and wsNames[lib.clientLang] ~= nil then
        LoadSavedVariables()
        lib.svData.wayshrineNames = lib.svData.wayshrineNames or {}
        lib.svData.wayshrineNames[lib.clientLang] = {}
        lib.svData.wayshrineNames[lib.clientLang] = wsNames[lib.clientLang]
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'wayshrineNames\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Scan for set names in client language -> Save them in the SavedVariables "setNames"
---------------------------------------------------------------------------------------------------------------------------
function lib.DebugGetAllSetNames()
    d(debugOutputStartLine.."[".. MAJOR .. "]GetAllSetNames, language: " .. tostring(lib.clientLang))
    --Use the SavedVariables to get the setNames of the current client language
    local svLoadedAlready = false
    local setIdsToCheck = lib.GetAllSetIds()
    if setIdsToCheck then
        local setNamesAdded = 0
        for setIdToCheck, _ in pairs(setIdsToCheck) do
            local itemIdsToCheck = lib.GetSetItemIds(setIdToCheck)
            if itemIdsToCheck then
                for itemIdToCheck, _ in pairs(itemIdsToCheck) do
                    if itemIdToCheck then
                        local isSet, setName, setId = lib.IsSetByItemId(itemIdToCheck)
                        if isSet and setId == setIdToCheck then
                            setName = ZO_CachedStrFormat("<<C:1>>", setName)
                            if setName ~= "" then
                                --Load the SV once
                                if not svLoadedAlready then
                                    LoadSavedVariables()
                                    svLoadedAlready = true
                                end
                                lib.svData["setNames"][setId] = lib.svData["setNames"][setId] or {}
                                lib.svData["setNames"][setId][lib.clientLang] = setName
                                setNamesAdded = setNamesAdded +1
                            end
                        end
                    end
                end
            end
        end
        if setNamesAdded > 0 then
            d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'setNames\', language: \'" ..tostring(lib.clientLang).."\'")
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Scan for sets and their itemIds -> Save them in the SavedVariables "setItemIds"
---------------------------------------------------------------------------------------------------------------------------
--Variables needed for the functions below (Scan itemIds for sets and itemIds)
local sets = {}
local setCount = 0
local itemCount = 0
local itemIdsScanned = 0
local function showSetCountsScanned(finished)
    finished = finished or false
    d(debugOutputStartLine .."[" .. MAJOR .."]Scanned itemIds: " .. tostring(itemIdsScanned))
    d("-> Sets found: "..tostring(setCount))
    d("-> Set items found: "..tostring(itemCount))
    if finished then
        d(">>> [" .. MAJOR .. "] Scanning of sets has finished! Please do a /reloadui to update the SavedVariables properly! <<<")
        --Save the data to the SavedVariables now
        if setCount > 0 then
            LoadSavedVariables()
            lib.svData.setItemIds = {}
            lib.svData.setItemIds = sets
        end
    end
    d("<<" .. debugOutputStartLine)
end
--Load a package of 5000 itemIds and scan it:
--Build an itemlink from the itemId, check if the itemLink is not crafted, if the itemType is a possibel set itemType, check if the item is a set:
--If yes: Update the table sets and setNames, and add the itemIds found for this set to the sets table
--Format of the sets table is: sets[setId] = {[itemIdOfSetItem]=true, ...}
local function loadSetsByIds(from,to)
    for setItemId=from,to do
        itemIdsScanned = itemIdsScanned + 1
        --Generate link for item
        local itemLink = lib.buildItemLink(setItemId)
        if itemLink and itemLink ~= "" then
            if not IsItemLinkCrafted(itemLink) then
                local isSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                if isSet then
                    local itemType = GetItemLinkItemType(itemLink)
                    --Some set items are only "containers" ...
                    if lib.setItemTypes[itemType] then
                        if sets[setId] == nil then
                            sets[setId] = {}
                            --Update the set counts value
                            setCount = setCount + 1
                        end
                        sets[setId][setItemId] = true
                        --Update the set's item count
                        itemCount = itemCount + 1
                    end
                end
            end
        end
    end
    showSetCountsScanned(false)
end

--Scan all sets data by scanning all itemIds in the game via a 5000 itemId package size (5000 itemIds scanned at once),
--for x loops (where x is the multiplier number e.g. 40, so 40x5000 itemIds will be scanned for set data)
--This takes some time and the chat will show information about found sets and item counts during the packages get scanned.
local function scanAllSetData()
    local numItemIdPackages = 40       -- Increase this to find new added set itemIds after and update
    local numItemIdPackageSize = 5000  -- do not increase this or the client may crash!
    local itemIdsToScanTotal = numItemIdPackages * numItemIdPackageSize
    d(debugOutputStartLine)
    d("[" .. MAJOR .."]Start to load all set data. This could take some minutes to finish!\nWatch the chat output for further information.")
    d("Scanning " ..tostring(numItemIdPackages) .. " packages with each " .. tostring(numItemIdPackageSize) .. " itemIds (total: " .. tostring(itemIdsToScanTotal) ..") now...")

    --Clear all set data
    sets = {}
    --Clear counters
    setCount = 0
    itemCount = 0
    itemIdsScanned = 0

    --Loop through all item ids and save all sets to an array
    --Split the itemId packages into 5000 itemIds each, so the client is not lagging that
    --much and is not crashing!
    --> Change variable numItemIdPackages and increase it to support new added set itemIds
    --> Total itemIds collected: 0 to (numItemIdPackages * numItemIdPackageSize)
    local miliseconds = 0
    local fromTo = {}
    local fromVal = 0
    for numItemIdPackage = 1, numItemIdPackages, 1 do
        --Set the to value to loop counter muliplied with the package size (e.g. 1*500, 2*5000, 3*5000, ...)
        local toVal = numItemIdPackage * numItemIdPackageSize
        --Add the from and to values to the totla itemId check array
        table.insert(fromTo, {from = fromVal, to = toVal})
        --For the next loop: Set the from value to the to value + 1 (e.g. 5000+1, 10000+1, ...)
        fromVal = toVal + 1
    end
    --Add itemIds and scan them for set parts!
    for _, v in pairs(fromTo) do
        zo_callLater(function()
            loadSetsByIds(v.from,v.to)
        end, miliseconds)
        miliseconds = miliseconds + 2000 -- scan item ID packages every 2 seconds to get not kicked/crash the client!
    end
    --Were all item IDs scanned? Show the results list now
    zo_callLater(function()
        showSetCountsScanned(true)
    end, miliseconds + 2000)
end
lib.DebugScanAllSetData = scanAllSetData

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
            local dungeonData = data.id .. "|" .. nameClean .. "|" .. data.zoneId .. "|" .. tostring(isVeteranDungeon)
            table.insert(retTableDungeons, dungeonData)
            dungeonsAddedCounter = dungeonsAddedCounter +1
        end
    end
    return dungeonsAddedCounter
end

--Read all dungeons from the dungeon finder and save them to the SavedVariables key "dungeonFinderData" (LIBSETS_TABLEKEY_DUNGEONFINDER_DATA).
--The format will be:
--dungeonFinderData[integerIndexIncreasedBy1] = dungeonId .. "|" .. dungeonName .. "|" .. zoneId .. "|" .. isVeteranDungeon
--This string can be easily copy&pasted to Excel and split at the | delimiter
--Example:
--["dungeonFinderData"] =
--{
--  [1] = "2|Pilzgrotte I|283|false",
--  [2] = "18|Pilzgrotte II|934|false",
--..
--}
--->!!!Attention!!!You MUST open the dungeon finder->go to specific dungeon dropdown entry in order to build the dungeons list needed first!!!
--Parameter: dungeonFinderIndex number. Possible values are 1=Normal or 2=Veteran or 3=Both dungeons. Leave empty to get both
function lib.DebugGetDungeonFinderData(dungeonFinderIndex)
    d("[" .. MAJOR .."]Start to load all dungeon data from the keyboard dungeon finder...")
    dungeonFinderIndex = dungeonFinderIndex or 3
    local dungeonFinder = DUNGEON_FINDER_KEYBOARD
    retTableDungeons = nil
    local dungeonsAdded = 0
    if dungeonFinder and dungeonFinder.navigationTree and dungeonFinder.navigationTree.rootNode then
        local dfRootNode = dungeonFinder.navigationTree.rootNode
        if dfRootNode.children then
            if dungeonFinderIndex == 3 then
                local dungeonsData = dfRootNode.children[1]
                getDungeonFinderDataFromChildNodes(dungeonsData)
                dungeonsData = dfRootNode.children[2]
                dungeonsAdded = getDungeonFinderDataFromChildNodes(dungeonsData)
            else
                local dungeonsData = dfRootNode.children[dungeonFinderIndex]
                dungeonsAdded = getDungeonFinderDataFromChildNodes(dungeonsData)
            end
        else
            d("<Please open the dungeon finder and choose the \'Specifiy dungeon\' entry from the dropdown box at the top-right edge! Then try this function again.")
        end
    end
    if retTableDungeons and #retTableDungeons>0 and dungeonsAdded >0 then
        LoadSavedVariables()
        lib.svData[LIBSETS_TABLEKEY_DUNGEONFINDER_DATA] = {}
        lib.svData[LIBSETS_TABLEKEY_DUNGEONFINDER_DATA] = retTableDungeons
        d("->Stored " .. tostring(dungeonsAdded) .." entries in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'" .. LIBSETS_TABLEKEY_DUNGEONFINDER_DATA .. "\', language: \'" ..tostring(lib.clientLang).."\'")
    else
        d("<No dungeon data was found!")
    end
end