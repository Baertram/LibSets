--[========================================================================[
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
--]========================================================================]
local MAJOR, MINOR = "LibSets", 0.06
LibSets = LibSets or {}
local lib = LibSets

lib.name        = MAJOR
lib.version     = MINOR
lib.svName      = "LibSets_SV_Data"
lib.svVersion   = 0.6
lib.setsLoaded  = false
lib.setsScanning = false

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------

------------The sets--------------
--The preloaded sets data
local preloaded         = lib.setDataPreloaded      -- <-- this table contains all setData (itemIds, names) of the sets, preloaded
--The set data
local setInfo           = lib.setInfo               -- <--this table contains all set information like setId, type, drop zoneIds, wayshrines, etc.

------------------------------------------------------------------------
-- 	Local helper functions
------------------------------------------------------------------------
--[[
--Get the count of a table with a non-index table key
local function getNonIndexedTableCount(tableName)
    if not tableName then return nil end
    local count = 0
    for _,_ in pairs(tableName) do
        count = count +1
    end
    return count
end
]]

--local helper function for set data
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Check which setIds were found and get the set's info from the preloaded data table "setInfo",
--sort them into their appropriate set table and increase the counter for each table
local function LoadSets()
    if lib.setsScanning then return end
    lib.setsScanning = true

    --Counters
    lib.arenaSetsCount = 0
    lib.craftedSetsCount = 0
    lib.dailyRandomDungeonAndImperialCityRewardSetsCount = 0
    lib.dungeonSetsCount  = 0
    lib.monsterSetsCount  = 0
    lib.overlandSetsCount = 0
    lib.battlegroundSetsCount = 0
    lib.cyrodiilSetsCount = 0
    lib.imperialCitySetsCount = 0
    lib.specialSetsCount = 0
    lib.trialSetsCount = 0

    --Set tables
    lib.arenaSets = {}
    lib.craftedSets = {}
    lib.dailyRandomDungeonAndImperialCityRewardSets = {}
    lib.dungeonSets = {}
    lib.monsterSets = {}
    lib.overlandSets = {}
    lib.battlegroundSets = {}
    lib.cyrodiilSets = {}
    lib.imperialCitySets = {}
    lib.specialSets = {}
    lib.trialSets = {}
    --The overall setIds table
    lib.setIds = {}

    --The preloaded itemIds
    local preloadedItemIds = preloaded.setItemIds
    --The preloaded setNames
    local preloadedSetNames = preloaded.setNames

    --Check the setsData and move entries to appropriate table
    for setId, setData in pairs(setInfo) do
        --Add the setId to the setIds table
        lib.setIds[setId] = true
        --Get the type of set and create the entry for the setId in the appropriate table
        local refToSetIdTable
        if     setData.isArena then
            lib.arenaSets[setId] = setData
            lib.arenaSetsCount = lib.arenaSetsCount +1
            refToSetIdTable = lib.arenaSets[setId]
        elseif setData.isCrafted then
            lib.craftedSets[setId] = setData
            lib.craftedSetsCount = lib.craftedSetsCount +1
            refToSetIdTable = lib.craftedSets[setId]
        elseif setData.isDailyRandomDungeonAndImperialCityReward then
            lib.dailyRandomDungeonAndImperialCityRewardSets[setId] = setData
            lib.dailyRandomDungeonAndImperialCityRewardSetsCount = lib.dailyRandomDungeonAndImperialCityRewardSetsCount +1
            refToSetIdTable = lib.dailyRandomDungeonAndImperialCityRewardSets[setId]
        elseif setData.isDungeon then
            lib.dungeonSets[setId] = setData
            lib.dungeonSetsCount = lib.dungeonSetsCount +1
            refToSetIdTable = lib.dungeonSets[setId]
        elseif setData.isMonster then
            lib.monsterSets[setId] = setData
            lib.monsterSetsCount = lib.monsterSetsCount +1
            refToSetIdTable = lib.monsterSets[setId]
        elseif setData.isOverland then
            lib.overlandSets[setId] = setData
            lib.overlandSetsCount = lib.overlandSetsCount +1
            refToSetIdTable = lib.overlandSets[setId]
        elseif setData.isBattleground then
            lib.battlegroundSets[setId] = setData
            lib.battlegroundSetsCount = lib.battlegroundSetsCount +1
            refToSetIdTable = lib.battlegroundSets[setId]
        elseif setData.isCyrodiil then
            lib.cyrodiilSets[setId] = setData
            lib.cyrodiilSetsCount = lib.cyrodiilSetsCount +1
            refToSetIdTable = lib.cyrodiilSets[setId]
        elseif setData.isImperialCity then
            lib.imperialCitySets[setId] = setData
            lib.imperialCitySetsCount = lib.imperialCitySetsCount +1
            refToSetIdTable = lib.imperialCitySets[setId]
        elseif setData.isSpecial then
            lib.specialSets[setId] = setData
            lib.specialSetsCount = lib.specialSetsCount +1
            refToSetIdTable = lib.specialSets[setId]
        elseif setData.isTrial then
            lib.trialSets[setId] = setData
            lib.trialSetsCount = lib.trialSetsCount +1
            refToSetIdTable = lib.trialSets[setId]
        end
        --Store all other data to the set's table
        if refToSetIdTable ~= nil then
            --Get the itemIds stored for the setId and add them to the set's ["itemIds"] table
            local itemIds = preloadedItemIds[setId]
            if itemIds ~= nil then
                refToSetIdTable["itemIds"] = itemIds
            end
            --Get the names stored for the setId and add them to the set's ["names"] table
            local setNames = preloadedSetNames[setId]
            if setNames ~= nil then
                refToSetIdTable["names"] = setNames
            end
        end
    end
    lib.setsScanning = false
end

------------------------------------------------------------------------
-- 	Global helper functions
------------------------------------------------------------------------
--Create an exmaple itemlink of the setItem's itemId
function lib.buildItemLink(itemId)
    if itemId == nil or itemId == 0 then return end
    return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
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
    return lib.craftedSets[setId] or false
end

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.monsterSets[setId] or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.dungeonSets[setId] or false
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
    return lib.arenaSets[setId] or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.overlandSets[setId] or false
end

--Returns true if the setId provided is an cyrodiil set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCyrodiilSet
function lib.IsCyrodiilSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.cyrodiilSets[setId] or false
end

--Returns true if the setId provided is a battleground set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isBattlegroundSet
function lib.IsBattlegroundSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.battlegroundSets[setId] or false
end

--Returns true if the setId provided is an Imperial City set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isImperialCitySet
function lib.IsImperialCitySet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.imperialCitySets[setId] or false
end

--Returns true if the setId provided is a special set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSpecialSet
function lib.IsSpecialSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.specialSets[setId] or false
end

--Returns true if the setId provided is a DailyRandomDungeonAndImperialCityRewardSet set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDailyRandomDungeonAndImperialCityRewardSet
function lib.IsDailyRandomDungeonAndImperialCityRewardSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.dailyRandomDungeonAndImperialCityRewardSets[setId] or false
end

--Returns information about the set if the itemId provides is a set item
--> Parameters: itemId number: The item's itemId
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemId(itemId)
    if itemId == nil then return end
    local itemLink = lib.buildItemLink(itemId)
    return checkSet(itemLink)
end

--Returns information about the set if the itemlink provides is a set item
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemLink(itemLink)
    return checkSet(itemLink)
end

--Returns true/false if the set must be obtained in a veteran mode dungeon/trial/arena
--> Parameters: setId number: The set's setId
--> Returns:    isVeteranSet boolean
function lib.IsVeteranSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isVeteranSet = false
    local setData = setInfo[setId]
    if setData == nil then return end
    isVeteranSet = setData.veteran or false
    return isVeteranSet
end

--Returns the wayshrines as table for the setId
--> Parameters: setId number: The set's setId
--> Returns:    wayshrineNodeIds table
function lib.GetWayshrineIds(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData.wayshrines == nil then return end
    return setData.wayshrines
end

--Returns the drop zoneIds as table for the setId
--> Parameters: setId number: The set's setId
--> Returns:    zoneIds table
function lib.GetZoneIds(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData.zoneIds == nil then return end
    return setData.zoneIds
end

--Returns the dlcId as number for the setId
--> Parameters: setId number: The set's setId
--> Returns:    dlcId number
function lib.GetDLCId(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData.dlcId == nil then return end
    return setData.dlcId
end

--Returns the number of researched traits needed to craft this set. This will only check the craftable sets!
--> Parameters: setId number: The set's setId
--> Returns:    traitsNeededToCraft number
function lib.GetTraitsNeeded(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or not setData.isCrafted or setData.traitsNeeded == nil then return end
    return setData.traitsNeeded
end

--Returns the type of the setId!
--> Parameters: setId number: The set's setId
--> Returns:    setType String
function lib.GetSetType(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil then return end
    local setType = ""
    if     setData.isArena then
        setType = "Arena"
    elseif setData.isCrafted then
        setType = "Crafted"
    elseif setData.isDailyRandomDungeonAndImperialCityReward then
        setType = "DailyRandomDungeonAndICReward"
    elseif setData.isDungeon then
        setType = "Dungeon"
    elseif setData.isMonster then
        setType = "Monster"
    elseif setData.isOverland then
        setType = "Overland"
    elseif setData.isBattleground then
        setType = "Battleground"
    elseif setData.isCyrodiil then
        setType = "Cyrodiil"
    elseif setData.isImperialCity then
        setType = "Imperial City"
    elseif setData.isSpecial then
        setType = "Special"
    elseif setData.isTrial then
        setType = "Trial"
    end
    return setType
end


------------------------------------------------------------------------
-- 	Global set get functions
------------------------------------------------------------------------
--Returns a sorted array of all set ids
--> Returns: setIds table
function lib.GetAllSetIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.setIds
end

--Returns all itemIds of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setItemIds
function lib.GetSetItemIds(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemIds = preloaded["setItemIds"]
    if setItemIds[tonumber(setId)] == nil then return end
    return setItemIds[tonumber(setId)]
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = preloaded["setNames"]
    if setId == nil or not lib.supportedLanguages[lang]
        or setNames[tonumber(setId)] == nil
        or setNames[tonumber(setId)][lang] == nil then return end
    return setNames[tonumber(setId)][lang]
end

--Returns all names as String of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = preloaded["setNames"]
    if setNames[tonumber(setId)] == nil then return end
    return setNames[tonumber(setId)]
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains the number setId,
----> tables itemIds (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's item),
----> table names ([String lang] = String name),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> isDungeon, isTrial, IsCraftable, ... boolean value
----> isVeteran boolean value. true if this set can be only obtained in veteran mode
----> isMultiTrial boolean, only if isTrial == true (setId can be obtained in multiple trials -> see zoneIds table)
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table will contain 1 entry if it's a NON-craftable setId (wayshrines = {[1] = WSNodeNoFaction})
------>and 3 entries (one for each faction) if it's a craftable setId (wayshrines = {[1] = WSNodeFactionAD, [2] = WSNodeFactionDC, [3] = WSNodeFactionEP})
----> table zoneIds containing the zoneIds where this set drops or can be obtained
function lib.GetSetInfo(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if setInfo[tonumber(setId)] == nil then return end
    local setInfoTable = setInfo[tonumber(setId)]
    local itemIds = preloaded["setItemIds"][setId]
    if itemIds then setInfoTable["itemIds"] = itemIds end
    local setNames = preloaded["setNames"][setId]
    if setNames then setInfoTable["names"] = setNames end
    return setInfoTable
end

------------------------------------------------------------------------
-- 	Global set misc. functions
------------------------------------------------------------------------
--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil then return false end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local jumpToNode = -1
    --Is a crafted set?
    if lib.craftedSets[setId] then
        --Then use the faction Id 1 (AD), 2 (DC) to 3 (EP)
        factionIndex = factionIndex or 1
        if factionIndex < 1 or factionIndex > 3 then factionIndex = 1 end
        local craftedSetWSData = setInfo[setId].wayshrines
        if craftedSetWSData ~= nil and craftedSetWSData[factionIndex] ~= nil then
            jumpToNode = craftedSetWSData[factionIndex]
        end
        --Other sets wayshrines
    else
        jumpToNode = setInfo[setId].wayshrines[1]
    end
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
    if not lib.undauntedChestIds then return end
    lang = lang or lib.clientLang
    local undauntedChestNameLang = lib.undauntedChestIds[lang]
    --Fallback language "EN"
    if not undauntedChestNameLang then undauntedChestNameLang = lib.undauntedChestIds["en"] end
    if not undauntedChestNameLang[undauntedChestId] then return "" end
    return undauntedChestNameLang[undauntedChestId]
end

--Returns the name of the DLC by help of the DLC id
--> Parameters: zoneId number: The zone id given in a set's info
-->             language String: ONLY possible to be used if LibZone is activated
--> Returns:    name zoneName
function lib.GetZoneName(zoneId, lang)
    if not zoneId then return end
    lang = lang or lib.clientLang
    local zoneName = ""
    if lib.libZone ~= nil then
        zoneName = lib.libZone:GetZoneName(zoneId, lang)
    else
        zoneName = GetZoneNameById(zoneId)
        zoneName = ZO_CachedStrFormat("<<C:1>>", zoneName)
    end
    return zoneName
end

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
--or false if not
function lib.checkIfSetsAreLoadedProperly()
    if lib.IsSetsScanning() or not lib.AreSetsLoaded() then return false end
    return true
end

------------------------------------------------------------------------
--Load the SavedVariables
local function LoadSavedVariables()
    --SavedVars were loaded already before?
    if lib.svData ~= nil then return end
    local defaults = {
        ["setNames"]        = {},
        ["zoneData"]        = {},
        ["maps"]            = {},
        ["wayshrineNames"]  = {},
    }
    lib.svData = ZO_SavedVars:NewAccountWide(lib.svName, lib.svVersion, nil, defaults, nil, "$InstallationWide")
end

--Addon loaded function
local function OnLibraryLoaded(event, name)
    --Only load lib if ingame
    if name ~= MAJOR then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    lib.setsLoaded = falsez
    --The actual clients language
    lib.clientLang = GetCVar("language.2")
    --The actual API version
    lib.currentAPIVersion = GetAPIVersion()
    --Get the different setTypes from the "all sets table" setInfo in file LibSets_Data.lua and put them in their
    --own tables
    LoadSets()
    lib.setsLoaded = true
    --Check for library LibZone
    lib.libZone = LibZone
    if lib.libZone == nil and LibStub then
        lib.libZone = LibStub:GetLibrary("LibZone", true)
    end

end

-------------------------------------------------------------------------------------------------------------------------------
-- Data update functions - Only for developers of this lib to get new data from e.g. the PTS or after major patches on live.
-- e.g. to get the new wayshrines names and zoneNames
-- Uncomment to use them via the libraries global functions then
-------------------------------------------------------------------------------------------------------------------------------
local debugOutputStartLine = "==============================\n"
local function GetAllZoneInfo()
    local lang = GetCVar("language.2")
    d(debugOutputStartLine.."[".. MAJOR .. "]GetAllZoneInfo, language: " ..tostring(lang))
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
    d(debugOutputStartLine.."[".. MAJOR .. "]GetWayshrineInfo")
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
    d(debugOutputStartLine.."[".. MAJOR .. "]GetWayshrineNames, language: " ..tostring(lang))
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
    d(debugOutputStartLine.."[".. MAJOR .. "]GetMapNames, language: " ..tostring(lang))
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

function lib.GetAllZoneInfo()
    local zoneData = GetAllZoneInfo()
    if zoneData ~= nil then
        LoadSavedVariables()
        lib.svData.zoneData = lib.svData.zoneData or {}
        lib.svData.zoneData[lib.clientLang] = {}
        lib.svData.zoneData[lib.clientLang] = zoneData[lib.clientLang]
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'zoneData\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

function lib.GetAllMapNames()
    local maps = GetMapNames(lib.clientLang)
    if maps ~= nil then
        LoadSavedVariables()
        lib.svData.maps = lib.svData.maps or {}
        lib.svData.maps[lib.clientLang] = {}
        lib.svData.maps[lib.clientLang] = maps
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'maps\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

function lib.GetAllWayshrineInfo()
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

function lib.GetAllWayshrineNames()
    local wsNames = GetWayshrineNames()
    if wsNames ~= nil and wsNames[lib.clientLang] ~= nil then
        LoadSavedVariables()
        lib.svData.wayshrineNames = lib.svData.wayshrineNames or {}
        lib.svData.wayshrineNames[lib.clientLang] = {}
        lib.svData.wayshrineNames[lib.clientLang] = wsNames[lib.clientLang]
        d("->Stored in SaveVariables file \'" .. MAJOR .. ".lua\', in the table \'wayshrineNames\', language: \'" ..tostring(lib.clientLang).."\'")
    end
end

function lib.GetAllSetNames()
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

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)