<--[========================================================================[
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

------------The sets--------------
--The preloaded sets data
local preloaded         = lib.setDataPreloaded      -- <-- this table contains all setData (itemIds, names) of the sets, preloaded
--The set data
local setInfo           = lib.setInfo               -- <--this table contains all set information like setId, type, drop zoneIds, wayshrines, etc.
--The special sets
local specialSets       = lib.specialSets           -- <-- this table contains the set information for special sets like Maelstrom or Master

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

--Check if an itemLink is a set and return the set's data from ESO API function GetItemLinkSetInfo
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Check if an itemId belongs to a special set and return the set's data from LibSets data tables
local function checkSpecialSet(itemId)
    if itemId == nil or itemId == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = false, "", 0, 0, 0, 0
    local specialSetNames = preloaded["setNamesSpecial"]
    --Check the special sets data for the itemId
    for specialSetId, specialSetData in pairs(specialSets) do
        --Check if we got preloaded itemIds for the specialSetId
        if preloaded and preloaded["setItemIdsSpecial"] and preloaded["setItemIdsSpecial"][specialSetId] then
            local specialSetsItemIds = lib.GetSetItemIds(specialSetId, true)
            --Found the itemId in the sepcial sets itemIds table?
            if specialSetsItemIds and specialSetsItemIds[itemId] then
                isSet = true
                setName = specialSetNames[specialSetId][lib.clientLang] or ""
                numBonuses = specialSetData["numBonuses"] or 0
                numEquipped = 0 --Todo: Check how many of the itemId items are currently equipped
                maxEquipped = specialSetData["maxEquipped"] or 0
                setId = specialSetId
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
--Create an example itemlink of the setItem's itemId
function lib.buildItemLink(itemId, itemQualitySubType)
    if itemId == nil or itemId == 0 then return end
    --itemQualitySubType is used for the itemLinks quality, see UESP website for a description of the itemLink: https://en.uesp.net/wiki/Online:Item_Link
    itemQualitySubType = itemQualitySubType or 366 -- Normal
    --itemQualitySubType values for Level 50 items:
    --357:  Trash
    --366:  Normal
    --367:  Magic
    --368:  Arcane
    --369:  Artifact
    --370:  Legendary
    --return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, itemQualitySubType, ITEMSTYLE_NONE, 0, 10000)
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
    local isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSet(itemLink)
    if not isSet then
        --Maybe it is a special set
        isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSpecialSet(itemId)
    end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

--Returns information about the set if the itemlink provides is a set item
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemLink(itemLink)
    local isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSet(itemLink)
    if not isSet then
        --Maybe it is a special set
        isSet, setName, setId, numBonuses, numEquipped, maxEquipped = checkSpecialSet(itemId)
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
--e.g. wayshrines={382,382,382,}. All entries can be the same, or even a negative value which means: No weayshrine is known
--Else the order of the entries is 1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact
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
---> Possible values are:
--   setType = "Arena"
--   setType = "Battleground"
--   setType = "Crafted"
--   setType = "Cyrodiil"
--   setType = "DailyRandomDungeonAndICReward"
--   setType = "Dungeon"
--   setType = "Imperial City"
--   setType = "Monster"
--   setType = "Overland"
--   setType = "Special"
--   setType = "Trial"
function lib.GetSetType(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setData = setInfo[setId]
    if setData == nil then return end
    local setType = ""
    if     setData.isArena then
        setType = "Arena"
    elseif setData.isBattleground then
        setType = "Battleground"
    elseif setData.isCrafted then
        setType = "Crafted"
    elseif setData.isCyrodiil then
        setType = "Cyrodiil"
    elseif setData.isDailyRandomDungeonAndImperialCityReward then
        setType = "DailyRandomDungeonAndICReward"
    elseif setData.isDungeon then
        setType = "Dungeon"
    elseif setData.isImperialCity then
        setType = "Imperial City"
    elseif setData.isMonster then
        setType = "Monster"
    elseif setData.isOverland then
        setType = "Overland"
    elseif setData.isSpecial then
        setType = "Special"
    elseif setData.isTrial then
        setType = "Trial"
    end
    return setType
end

--Returns a sorted array of all set ids. Key is the setId, value is the boolean value true
--> Returns: setIds table
function lib.GetAllSetIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.setIds
end

--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.
--The key is the itemId and the value is the boolean value true
--> Parameters: setId number: The set's setId
-->             isSpecialSet boolean: Read the set's itemIds from the special sets table or the normal?
--> Returns:    table setItemIds
function lib.GetSetItemIds(setId, isSpecialSet)
    if setId == nil then return end
    isSpecialSet = isSpecialSet or false
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemIds
    if isSpecialSet then
        setItemIds = preloaded["setItemIdsSpecial"]
    else
        setItemIds = preloaded["setItemIds"]
        if setItemIds[setId] == nil then
            --Check if the setId is not in the normal sets but in the in the special sets table
            setItemIds = preloaded["setItemIdsSpecial"]
        end
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
    local equipTypesValid = {
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
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setNames = preloaded["setNames"]
    if setId == nil or not lib.supportedLanguages[lang]
        or setNames[setId] == nil
        or setNames[setId][lang] == nil then return end
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
    local setNames = preloaded["setNames"]
    if setNames[setId] == nil then return end
    return setNames[setId]
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains:
----> number setId
----> number dlcId (the dlcId where the set was added, see file LibSets_Constants.lua, constants DLC_BASE_GAME to e.g. DLC_ELSWEYR)
----> tables itemIds (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's item),
----> table names ([2 character String lang] = String name),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> isDungeon, isTrial, IsCraftable, ... boolean value. Only one of the values will be given, all other values will be nil
----> isVeteran boolean value true if this set can be only obtained in veteran mode, or a table containing the key = equipType and value=boolean true/false if the equipType of the setId cen be only obtained in veteran mode (e.g. a monster set head is veteran, shoulders are normal)
----> isMultiTrial boolean, only if isTrial == true (setId can be obtained in multiple trials -> see zoneIds table)
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table can contain 1 to 3 entries (one for each faction e.g.) and contains the wayshrineNodeId nearest to the set's crafting table/in the drop zone
----> table zoneIds containing the zoneIds (one to n) where this set drops, or can be obtained
-------Example for setId 408
--- ["setId"] = 408,
--- ["dlcId"] = 12    --DLC_MURKMIRE
--	["isCrafted"] = true
--	["itemIds"] = table [#0,370]
--	["names"] = table [#0,3]
--		["de"] = "Grabpflocksammler"
--		["en"] = "Grave-Stake Collector"
--		["fr"] = "Collectionneur de marqueurs funéraires"
--	["traitsNeeded"] = 7
--	["veteran"] = false
--	["wayshrines"] = table [#3,3]
--		[1] = 375
--		[2] = 375
--		[3] = 375
--	["zoneIds"] = table [#1,1]
--		[1] = 726
function lib.GetSetInfo(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if setInfo[setId] == nil then return end
    local setInfoTable = setInfo[setId]
    setInfoTable["setId"] = setId
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
    if setId == nil or setInfo[setId] == nil or setInfo[setId].wayshrines == nil then return false end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    --Then use the faction Id 1 (AD), 2 (DC) to 3 (EP)
    factionIndex = factionIndex or 1
    if factionIndex < 1 or factionIndex > 3 then factionIndex = 1 end
    local jumpToNode = -1
    local setWayshrines = setInfo[setId].wayshrines
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
    if lang and not lib.supportedLanguages[lang] then return end
    lang = lang or lib.clientLang
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
        ["maps"]            = {},
        ["setItemIds"]      = {},
        ["setNames"]        = {},
        ["wayshrineNames"]  = {},
        ["zoneData"]        = {},
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
