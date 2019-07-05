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