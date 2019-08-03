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
LibSets = LibSets or {}
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------

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
--======= SETS =====================================================================================================
--Check if an itemLink is a set and return the set's data from ESO API function GetItemLinkSetInfo
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Todo: Check how many of the itemId items are currently equipped
--Get the number of equipped items with the given itemId
local function getNumEquippedItemsWithItemId(itemId)
    return 0
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
                numEquipped = getNumEquippedItemsWithItemId(itemId)
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
    --Helper function to check the set type and update the tables in the library
    local function checkSetTypeAndUpdateLibTablesAndCounters(setDataTable)
        --Check the setsData and move entries to appropriate table
        for setId, setData in pairs(setDataTable) do
            --Add the setId to the setIds table
            lib.setIds[setId] = true
            --Get the type of set and create the entry for the setId in the appropriate table
            local refToSetIdTable
            local setType = setData[LIBSETS_TABLEKEY_SETTYPE]
            if setType then
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
    lib.setsScanning = false
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

--Returns information about the set if the itemId provides is a set item
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
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local isVeteranSet = false
    local setData = setInfo[setId]
    if setData == nil then
        if lib.IsNoESOSet(setId) then
            setData = noSetIdSets[setId]
        else
            return
        end
    end
    if setData == nil then return end
    local veteranData = setData.veteran
    if veteranData == nil then return false end
    if type(veteranData) == "table" then
        if itemLink == nil then return nil end
        local equipType = GetItemLinkEquipType(itemLink)
        if equipType == nil then return nil end
        --veteran={EQUIP_TYPE_HEAD=true, EQUIP_TYPE_SHOULDERS=false}
        for equipTypeVeteranCheck, isVeteran in pairs(veteranData) do
            if equipTypeVeteranCheck == equipType then
                return isVeteran
            end
        end
        return false
    else
        isVeteranSet = veteranData or false
    end
    return isVeteranSet
end


------------------------------------------------------------------------
-- 	Global set get data functions
------------------------------------------------------------------------
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
--> Returns:    zoneIds table
function lib.GetZoneIds(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil or setData[LIBSETS_TABLEKEY_ZONEIDS] == nil then return end
    return setData[LIBSETS_TABLEKEY_ZONEIDS]
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
function lib.GetSetTypes()
    return lib.allowedSetTypes
end

--Returns the dropMechanicIDs of the setId!
--> Parameters: setId number:           The set's setId
-->             withNames bolean:       Should the function return the dropMechanic names as well?
--> Returns:    LibSetsDropMechanicIds  table, LibSetsDropMechanicNamesForEachId table
---> table LibSetsDropMechanicIds: The key is a number starting at 1 and increasing by 1, and the value is one of the dropMechanics
---> of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
---> table LibSetsDropMechanicNamesForEachId: The key is the dropMechanicId (value of each line in table LibSetsDropMechanicIds)
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
    if withNames then
        if setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] ~= nil and setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]["en"] ~= nil then
            dropMechanicNames = setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]
        else
            dropMechanicNames = {}
            local supportedLanguages = lib.supportedLanguages
            if supportedLanguages then
                for _, dropMechanicEntry in ipairs(dropMechanicIds) do
                    for supportedLanguage, isSupported in pairs(supportedLanguages) do
                        dropMechanicNames[dropMechanicEntry] = dropMechanicNames[dropMechanicEntry] or {}
                        if isSupported then
                            dropMechanicNames[dropMechanicEntry][supportedLanguage] = lib.GetDropMechanicName(dropMechanicEntry, supportedLanguage)
                        end
                    end
                end
            end
        end
    end
    return dropMechanicIds, dropMechanicNames
end

--Returns the name of the drop mechanic ID (a drop locations boss, city, email, ..)
--> Parameters: dropMechanicId number: The LibSetsDropMechanidIc (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
-->             lang String: The 2char language String for the used translation. If left empty the current client's
-->             language will be used.
--> Returns:    String dropMachanicNameLocalized: The name fo the LibSetsDropMechanidIc
function lib.GetDropMechanicName(libSetsDropMechanicId, lang)
    local allowedDropMechanics = lib.allowedDropMechanics
    if libSetsDropMechanicId == nil or libSetsDropMechanicId <= 0 then return end
    if not allowedDropMechanics[libSetsDropMechanicId] then return end
    lang = lang or lib.clientLang
    if not lib.supportedLanguages[lang] then return end
    local dropMechanicNames = lib.dropMechanicIdToName[lang]
    if dropMechanicNames == nil then return false end
    local dropMechanicName = dropMechanicNames[libSetsDropMechanicId]
    if dropMechanicName then
        if not dropMechanicName[lang] then return end
    end
    return dropMechanicName[lang]
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
    return preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
end

--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.
--The key is the itemId and the value is the boolean value true
--> Parameters: setId number: The set's setId
-->             isSpecialSet boolean: Read the set's itemIds from the special sets table or the normal?
--> Returns:    table setItemIds
function lib.GetSetItemIds(setId, isNoESOSetId)
    if setId == nil then return end
    isNoESOSetId = isNoESOSetId or false
    if isNoESOSetId == false then
        isNoESOSetId = lib.IsNoESOSet(setId)
    end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemIds
    if isNoESOSetId then
        setItemIds = preloaded[LIBSETS_TABLEKEY_SETITEMIDS_NO_SETID]
    else
        setItemIds = preloaded[LIBSETS_TABLEKEY_SETITEMIDS]
    end
    if setItemIds[setId] == nil then return end
    return setItemIds[setId]
end

--If the setId only got 1 itemId this function returns this itemId of the setId provided.
--If the setId got several itemIds this function returns one random itemId of the setId provided (depending on the 2nd parameter equipType)
--If the 2nd parameter equipType is not specified: The first random itemId found will be returned
--If the 2nd parameter equipType is specified:  Each itemId of the setId will be turned into an itemLink where the given equipType is checked against.
--Only the itemId where the equipType fits will be returned. Else the return value will be nil
--> Parameters: setId number: The set's setId
-->             equipType number: The equipType to check the itemId against
--> Returns:    number setItemId
function lib.GetSetItemId(setId, equipType)
    if setId == nil then return end
    local equipTypesValid = lib.equipTypesValid
    local equipTypeValid = false
    if equipType ~= nil then
        equipTypeValid = equipTypesValid[equipType] or false
    end
    local setItemIds = lib.GetSetItemIds(setId)
    if not setItemIds then return end
    for setItemId, isCorrect in pairs(setItemIds) do
        if equipTypeValid == true then
            --Create itemLink of the itemId
            local itemLink = lib.buildItemLink(setItemId)
            if itemLink then
                local ilEquipType = GetItemLinkEquipType(itemLink)
                if ilEquipType ~= nil and ilEquipType == equipType then return setItemId end
            end
            --Check the equipType against the itemLink's equipType
        else
            if setItemId ~= nil and isCorrect == true then return setItemId end
        end
    end
    return
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
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
    local setInfoTable
    local itemIds
    local setNames
    local preloadedSetItemIdsTableKey = LIBSETS_TABLEKEY_SETITEMIDS
    local preloadedSetNamesTableKey = LIBSETS_TABLEKEY_SETNAMES
    if lib.IsNoESOSet(setId) then
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
    itemIds = preloaded[preloadedSetItemIdsTableKey][setId]
    setNames = preloaded[preloadedSetNamesTableKey][setId]
    if itemIds then setInfoTable[LIBSETS_TABLEKEY_SETITEMIDS] = itemIds end
    if setNames then setInfoTable[LIBSETS_TABLEKEY_SETNAMES] = setNames end
    return setInfoTable
end

--Returns the possible armor types's of a set
--> Parameters: setId number: The set's id
--> Returns:    table armorTypesOfSet: Contains all armor types possible as key and the Boolean value
-->             true/false if this setId got items of this armorType
function lib.GetSetArmorTypes(setId)
    local armorTypesOfSet = {}
    if not lib.armorTypeNames then return end
    for armorType,_ in pairs(lib.armorTypeNames) do
        armorTypesOfSet[armorType] = false
    end
    --Get all itemIds of this set
    local setItemIds = lib.GetSetItemIds(setId)
    if not setItemIds then return false end
    --Build an itemLink from the itemId
    for itemId, _ in pairs(setItemIds) do
        local itemLink = lib.buildItemLink(itemId)
        if itemLink then
            --Scan each itemId and get the armor type.
            --* GetItemLinkArmorType(*string* _itemLink_)
            --** _Returns:_ *[ArmorType|#ArmorType]* _armorType_
            local armorTypeOfSetItem = GetItemLinkArmorType(itemLink)
            if armorTypeOfSetItem and armorTypeOfSetItem ~= ARMORTYPE_NONE then
                if not armorTypesOfSet[armorTypeOfSetItem] then
                    armorTypesOfSet[armorTypeOfSetItem] = true
                end
            end
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
        --* GetItemLinkArmorType(*string* _itemLink_)
        --** _Returns:_ *[ArmorType|#ArmorType]* _armorType_
        local armorTypeOfSetItem = GetItemLinkArmorType(itemLink)
        if armorTypeOfSetItem and armorTypeOfSetItem ~= ARMORTYPE_NONE then
            return armorTypeOfSetItem
        end
    end
    --If it's not already added to the armorTypesOfSet table add it
    --Return the armorTypesOfSet table
    return nil
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
    local zoneName = ""
    if lib.libZone ~= nil then
        zoneName = lib.libZone:GetZoneName(zoneId, lang)
    else
        zoneName = ZO_CachedStrFormat("<<C:1>>", GetZoneNameById(zoneId) )
    end
    return zoneName
end


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

--Returns the set data (setType number, setIds table, itemIds table, setNames table) for specified LibSets setType
--> Returns:    table with key = setId, value = table which contains (as example for setType = LIBSETS_SETTYPE_CRAFTED)
---->             [LIBSETS_TABLEKEY_SETTYPE] = LIBSETS_SETTYPE_CRAFTED ("Crafted")
------>             1st subtable with key LIBSETS_TABLEKEY_SETITEMIDS ("setItemIds") containing a pair of [itemId]= true (e.g. [12345]=true,)
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

--Returns the set data (setType number, setIds table, itemIds table, setNames table) for the specified LibSets setType
--Parameters: setType number. Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
--> Returns:    table -> See lib.GetCraftedSetsData for details of the table contents
function lib.GetSetTypeSetsData(setType)
    local setsData = getSetTypeSetsData(setType)
    return setsData
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
--or false if not.
--This functions combines the result values of the functions LibSets.AreSetsLoaded() and LibSets.IsSetsScanning()
function lib.checkIfSetsAreLoadedProperly()
    if lib.IsSetsScanning() or not lib.AreSetsLoaded() then return false end
    return true
end

------------------------------------------------------------------------
--Load the SavedVariables
local function LoadSavedVariables()
    --SavedVars were loaded already before?
    if lib.svData ~= nil then return end
    local defaults =
    {
        [LIBSETS_TABLEKEY_MAPS]                 = {},
        [LIBSETS_TABLEKEY_SETITEMIDS]           = {},
        [LIBSETS_TABLEKEY_SETNAMES]             = {},
        [LIBSETS_TABLEKEY_WAYSHRINE_NAMES]      = {},
        [LIBSETS_TABLEKEY_ZONE_DATA]            = {},
        [LIBSETS_TABLEKEY_DUNGEONFINDER_DATA]   = {},
        [LIBSETS_TABLEKEY_COLLECTIBLE_NAMES]    = {},
    }
    --ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
    lib.svData = ZO_SavedVars:NewAccountWide(lib.svName, lib.svVersion, nil, defaults, nil, "$AllAccounts")
end
lib.LoadSavedVariables = LoadSavedVariables

--Addon loaded function
local function OnLibraryLoaded(event, name)
    --Only load lib if ingame
    if name ~= MAJOR then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    lib.setsLoaded = falsez
    --The actual clients language
    lib.clientLang = GetCVar("language.2")
    if not lib.supportedLanguages[lib.clientLang] then
        lib.clientLang = "en" --Fallback language if client language is not supported: English
    end
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

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)