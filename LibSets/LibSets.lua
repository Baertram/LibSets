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
local MAJOR, MINOR = "LibSets", 0.05
LibSets = LibSets or {}
local lib = LibSets

lib.name        = MAJOR
lib.version     = MINOR
--SavedVariables info
lib.svDataName  = "LibSets_SV_Data"
lib.svVersion   = 0.5
lib.setsLoaded  = false
lib.setsScanning = false

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
--All sets data
local sets          = {}
local setIds        = {}
local setsFound     = 0
local setsUpdated   = 0
local itemsScanned  = 0

--Allowed itemTypes for the set parts
local checkItemTypes = lib.checkItemTypes
--The undaunted chest IDs
local undauntedChestIds = lib.undauntedChestIds

--Current monster set bonus count (maximum, e.g. 2 items needed for full set bonus )
local countMonsterSetBonus = lib.countMonsterSetBonus

------------The sets--------------
--The preloaded sets data
local preloaded         = lib.setItemIdsPreloaded   -- <-- this table contains all itemIds of the sets, preloaded
--The set data
local setInfo           = lib.setInfo               -- <--this table contains all set information like setId, type, drop zoneIds, wayshrines, etc.
--The set types
local craftedSets       = {}
local monsterSets       = {}
local dungeonSets       = {}
local overlandSets      = {}
local arenaSets         = {}
local trialSets         = {}
local cyrodiilSets      = {}
local battlegroundSets  = {}

--The count variables for each set type
local craftedSetsCount      = 0
local monsterSetsCount      = 0
local dungeonSetsCount      = 0
local overlandSetsCount     = 0
local arenaSetsCount        = 0
local trialSetsCount        = 0
local cyrodiilSetCount      = 0
local battlegroundSetCount  = 0

------------------------------------------------------------------------
-- 	Local helper functions
------------------------------------------------------------------------
local function getNonIndexedTableCount(tableName)
    if not tableName then return nil end
    local count = 0
    for _,_ in pairs(tableName) do
        count = count +1
    end
    return count
end
--Number of possible sets to craft (update this if table above changes!)
craftedSetsCount = getNonIndexedTableCount(craftedSets)

--Check if the item is a head or a shoulder
local function IsHeadOrShoulder(equipType)
    return (equipType == EQUIP_TYPE_HEAD or equipType == EQUIP_TYPE_SHOULDERS) or false
end

--Check if an item got less or equal "countMonsterSetBonus"
local function ItemGotMonsterSetBonusCount(maxEquipped)
    return (maxEquipped <= countMonsterSetBonus) or false
end

--Check if the item is dungeon BOP item
local function IsItemDungeonSet(itemLink)
    local itemBindType = GetItemLinkBindType(itemLink)
    return (itemBindType == BIND_TYPE_ON_PICKUP) or false
end

--local helper function for set data
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

-- This is the primary set data population function.
--> Parameters: setItemId number: The item id to use for extracting set data
--> Returns:    boolean found: true if new set data was extracted
-->             boolean updated: true if the set was known, but new language name data was extracted
local function LoadSetByItemId(setItemId)
    --Generate link for item
    local itemLink = lib.buildItemLink(setItemId)
    if not itemLink or itemLink == "" or IsItemLinkCrafted(itemLink) then return end
    --itemId check: Is a set?
    local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then return end
    local itemType = GetItemLinkItemType(itemLink)
    --Some set items are only "containers" ...
    if not checkItemTypes[itemType] then return end

    local clientLang = lib.clientLang
    local found, updated
    
    --Only add the first found item of the set as itemId!
    if sets[setId] == nil then
        sets[setId] = {}
        found = true
        sets[setId]["itemId"] = setItemId
        --Remove the gender stuff from the setname
        setName = zo_strformat("<<C:1>>", setName)
        --Update the Set names table
        sets[setId]["name"] = sets[setId]["name"] or {}
        sets[setId]["name"][clientLang] = sets[setId]["name"][clientLang] or setName
    --Update missing client languages to the set name
    elseif sets[setId] ~= nil and sets[setId]["name"] ~= nil and sets[setId]["itemId"] ~= nil then
        --The setId exists in the SavedVars but the translated string is missing for the current clientLanguage?
        if sets[setId]["name"][clientLang] == nil then
            --Remove the gender stuff from the setname
            setName = zo_strformat("<<C:1>>", setName)
            sets[setId]["name"][clientLang] = setName
            updated = true
        end
    end
    return found, updated
end

local function LoadSetsByIds(from, to)
    local clientLang = lib.clientLang
    for setItemId=from, to do
        itemsScanned = itemsScanned + 1
        local setFound, setUpdated = LoadSetByItemId(setItemId)
        if setFound then
            setsFound = setsFound + 1
        elseif setUpdated then
            setsUpdated = setsUpdated + 1
        end
    end
    d("[" .. MAJOR .. "]~~~Scanning sets~~~ items: " .. tostring(itemsScanned) .. ", sets new/updated: " .. tostring(setsFound) .. "/" .. tostring(setsUpdated))
end

--Load the SavedVariables
local function librarySavedVariables()
    lib.worldName = GetWorldName()
    local defaultSetsData = {}
    lib.svData = ZO_SavedVars:NewAccountWide(lib.svDataName, lib.svVersion, "SetsData", defaultSetsData, lib.worldName)
    if lib.svData.sets ~= nil then lib.setsLoaded = true end
end

--Check which setIds were found and compare them to the craftedSets list.
--All non-craftable will be checked if they are head and shoulder and got only 1 or 2 set bonus: monsterSets table
--All non-craftable will be checked if they are bound on pickup but tradeable: dungeonSets table
--All non-craftable will be checked if they are no monster or dungeon set: overlandSets table
local function distinguishSetTypes()
    monsterSetsCount  = 0
    dungeonSetsCount  = 0
    overlandSetsCount = 0
    arenaSetsCount = 0
    trialSetsCount = 0
    monsterSets = {}
    dungeonSets = {}
    overlandSets = {}
    arenaSets = {}
    trialSets = {}
    local buildItemLink = lib.buildItemLink
    if craftedSets ~= nil and lib.svData.sets ~= nil then
        for setId, setData in pairs(lib.svData.sets) do
            local isMonsterSet = false
            if not craftedSets[setId] then
                --Get the itemId stored for the setId and build the itemLink
                local itemId = setData.itemId
                if itemId ~= nil then
                    local itemLink = buildItemLink(itemId)
                    if itemLink ~= nil then
                        --Get the maxEquipped attribute of the set
                        local _, _, _, _, maxEquipped, _ = GetItemLinkSetInfo(itemLink)
                        --Check if the item is a monster set
                        if ItemGotMonsterSetBonusCount(maxEquipped) then
                            local equipType = GetItemLinkEquipType(itemLink)
                            if IsHeadOrShoulder(equipType) then
                                --It's a monster set (helm or shoulder with defined number of max bonus)
                                monsterSets[setId] = true
                                monsterSetsCount = monsterSetsCount + 1
                                isMonsterSet = true
                            end
                        end
                        --Item is no monster set, so check for dungeon or
                        if not isMonsterSet then
                            --Is a dungeon set (bound on pickup but tradeable)?
                            if IsItemDungeonSet(itemLink) then
                                --Item binds on pickup, so check if it is in the list of setInfo marked as arena or trial set
                                local isDungeonSet = false
                                if setInfo[setId] then
                                    --Arena set?
                                    if setInfo[setId]["isArena"] then
                                        arenaSets[setId] = true
                                        arenaSetsCount = arenaSetsCount + 1
                                        --Trial set?
                                    elseif setInfo[setId]["isTrial"] then
                                        trialSets[setId] = true
                                        trialSetsCount = trialSetsCount + 1
                                    else
                                        isDungeonSet = true
                                    end
                                else
                                    isDungeonSet = true
                                end
                                --Normal dungeon set?
                                if isDungeonSet then
                                    dungeonSets[setId] = true
                                    dungeonSetsCount = dungeonSetsCount + 1
                                end
                            else
                                --Is an overland set
                                overlandSets[setId] = true
                                overlandSetsCount = overlandSetsCount + 1
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Loads the setIds array with a sorted list of all set ids
local function loadSetIds()
    if lib.svData and lib.svData.sets then
        for setId, _ in pairs(lib.svData.sets) do
            table.insert(setIds, setId)
        end
    end
    table.sort(setIds)
end

-- Populates saved vars for set ids that are known ahead of time in preloaded.sets.
local function loadPreloadedSetNames()
    if not lib.svData then return end
    lib.svData["preloadedLanguagesScanned"] = lib.svData["preloadedLanguagesScanned"] or {}
    lib.svData["preloadedLanguagesScanned"][lib.currentAPIVersion] = lib.svData["preloadedLanguagesScanned"][lib.currentAPIVersion] or {}
    --Was this client language already added from the preloaded data for the current API version? Then abort
    if lib.svData["preloadedLanguagesScanned"][lib.currentAPIVersion][tostring(lib.clientLang)] then
        return
    end
    lib.svData.sets = lib.svData.sets or {}
    sets = lib.svData.sets
    for _, itemId in pairs(preloaded["sets"]) do
        LoadSetByItemId(itemId)
    end
    lib.svData["preloadedLanguagesScanned"][lib.currentAPIVersion][tostring(lib.clientLang)]  = true
end


------------------------------------------------------------------------
-- 	Global functions
------------------------------------------------------------------------
--Create an exmaple itemlink of the setItem's itemId
function lib.buildItemLink(itemId)
    if itemId == nil or itemId == 0 then return end
    return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
end

--Show the ask before reloadui dialog
function lib.ShowAskBeforeReloadUIDialog()
    ZO_Dialogs_ShowDialog("LIBSETS_ASK_BEFORE_RELOADUI_DIALOG", {})
end

--Load all available sets by the help of itemIds (in package size of 5000 itemIds, and 30 tries = 30 * 5000 itemIds)
function lib.LoadSets(override, fromAddonName)
    override = override or false
    if lib.setsScanning then return end
    lib.setsScanning = true
    local setScanStringStandard = ", APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'"
    local otherAddonScanString = " initiated by addon \'" .. tostring(fromAddonName) .. "\'"
    local setScanString = setScanStringStandard
    if fromAddonName ~= nil and fromAddonName ~= "" then
        setScanString = otherAddonScanString .. setScanStringStandard
    end
    d("[" .. MAJOR .. "]Starting set scan" .. setScanString)
    --Clear all set data
    sets = {}
    --Take exisitng SavedVars sets and update them, or override them with a new scan?
    if not override then
        if lib.svData ~= nil and lib.svData.sets ~= nil then
            sets = lib.svData.sets
        end
    end
    setsFound = 0
    setsUpdated = 0
    itemsScanned = 0

    lib.setsLoaded = false

    --Loop through all item ids and save all sets to an array
    --Split the itemId packages into 5000 itemIds each, so the client is not lagging that
    --much and is not crashing!
    --> Change variable numItemIdPackages and increase it to support new added set itemIds
    --> Total itemIds collected: 0 to (numItemIdPackages * numItemIdPackageSize)
    local miliseconds = 0
    local numItemIdPackages = 30       -- Increase this to find new added set itemIds after and update
    local numItemIdPackageSize = 5000  -- do not increase this or the client may crash!
    local fromTo = {}
    --The start value is the maximum scnaned itemId from the preloaded data + 1
    local startVal = preloaded["maxItemIdScanned"] + 1
    local fromVal = startVal
    for numItemIdPackage = 1, numItemIdPackages, 1 do
        --Set the to value to loop counter muliplied with the package size (e.g. 1*500, 2*5000, 3*5000, ...)
        local toVal = startVal + numItemIdPackage * numItemIdPackageSize - 1
        --Add the from and to values to the totla itemId check array
        table.insert(fromTo, {from = fromVal, to = toVal})
        local itemLink = lib.buildItemLink(toVal)
        -- Break early if toVal isn't a valid item
        if GetItemLinkItemType(itemLink) == 0 then
            break
        end
        --For the next loop: Set the from value to the to value + 1 (e.g. 5000+1, 10000+1, ...)
        fromVal = toVal + 1
    end
    --Add itemIds and scan them for set parts!
    for _, v in pairs(fromTo) do
        zo_callLater(function()
            LoadSetsByIds(v.from, v.to)
        end, miliseconds)
        miliseconds = miliseconds + 2000 -- scan item ID packages every 2 seconds to get not kicked/crash the client!
    end
    zo_callLater(function()
        if sets ~= nil then
            d("[" .. MAJOR .. "]Scan finished. [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
            lib.svData.sets = sets
            loadPreloadedSetNames()
            distinguishSetTypes()
            loadSetIds()
            lib.svData.monsterSets        = monsterSets
            lib.svData.dungeonSets        = dungeonSets
            lib.svData.arenaSets          = arenaSets
            lib.svData.trialSets          = trialSets
            lib.svData.overlandSets       = overlandSets
            lib.svData.monsterSetsCount   = monsterSetsCount
            lib.svData.dungeonSetsCount   = dungeonSetsCount
            lib.svData.arenaSetsCount     = arenaSetsCount
            lib.svData.trialSetsCount     = trialSetsCount
            lib.svData.overlandSetsCount  = overlandSetsCount
            d(">>> Crafted sets: " .. tostring(craftedSetsCount))
            d(">>> Monster sets: " .. tostring(monsterSetsCount))
            d(">>> Dungeon sets: " .. tostring(dungeonSetsCount))
            d(">>> Arena sets: " .. tostring(arenaSetsCount))
            d(">>> Trial sets: " .. tostring(trialSetsCount))
            d(">>> Overland sets: " .. tostring(overlandSetsCount))
            d("\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
            --Set the last scanned API version to the SavedVariables
            lib.svData["languagesScanned"] = lib.svData["languagesScanned"] or {}
            lib.svData["languagesScanned"][lib.currentAPIVersion] = lib.svData["languagesScanned"][lib.currentAPIVersion] or {}
            lib.svData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] = true
            --Set the flag "sets were scanned for current API"
            lib.svData.lastSetsCheckAPIVersion = lib.currentAPIVersion
            lib.setsScanning = false
            --Start confirmation dialog and let the user do a reloadui so the SetData gets stored to the SavedVars and depending addons will work afterwards
            lib.ShowAskBeforeReloadUIDialog()
        else
            lib.setsScanning = false
            d("[" .. MAJOR .. "]ERROR: Scan not successfull! [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'\nSet data could not be saved!\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end
    end, miliseconds + 1000)
end


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
--> Returns:    boolean isDungeonSet
function lib.IsTrialSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.trialSets[setId] or false
end

--Returns true if the setId provided is an arena set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
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

--Returns a sorted array of all set ids
--> Returns: setIds table
function lib.GetAllSetIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return setIds
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if setId == nil or not lib.supportedLanguages[lang]
        or lib.svData.sets[tonumber(setId)] == nil or lib.svData.sets[tonumber(setId)]["name"] == nil
        or lib.svData.sets[tonumber(setId)]["name"][lang] == nil then return end
    local setName = lib.svData.sets[tonumber(setId)]["name"][lang]
    return setName
end

--Returns all names as String of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if lib.svData.sets[tonumber(setId)] == nil or lib.svData.sets[tonumber(setId)]["name"] == nil then return end
    local setNames = {}
    setNames = lib.svData.sets[tonumber(setId)]["name"]
    return setNames
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains the number setId,
----> number itemId of an example setItem (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's example item),
----> table names ([String lang] = String name),
----> table setTypes (table containing booleans for isCrafted, isDungeon, isTrial, isArena, isMonster, isOverland),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table will contain 1 entry if it's a NON-craftable setId (wayshrines = {[1] = WSNodeNoFaction})
------>and 3 entries (one for each faction) if it's a craftable setId (wayshrines = {[1] = WSNodeFactionAD, [2] = WSNodeFactionDC, [3] = WSNodeFactionEP})
function lib.GetSetInfo(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if lib.svData.sets[tonumber(setId)] == nil then return end
    local setInfoTable = {}
    local setInfoFromSV = lib.svData.sets[tonumber(setId)]
    setInfoTable.setId = setId
    setInfoTable.itemId = setInfoFromSV["itemId"]
    setInfoTable.names = setInfoFromSV["name"] or {}
    setInfoTable.setTypes = {
        ["isCrafted"]   = false,
        ["isDungeon"]   = false,
        ["isTrial"]     = false,
        ["isArena"]     = false,
        ["isMonster"]   = false,
        ["isOverland"]  = false,
    }
    setInfoTable.traitsNeeded   = 0
    local isCraftedSet = (lib.craftedSets[setId]) or false
    --Craftable set
    local setsData = setInfo[setId]
    if isCraftedSet then
        if setsData then
            setInfoTable.traitsNeeded   = setsData.traitsNeeded
            setInfoTable.wayshrines     = setsData.wayshrines
            setInfoTable.setTypes["isCrafted"] = true
        end
        --Non-craftable set
    else
        if setsData then
            setInfoTable.wayshrines     = setsData.wayshrines
        end
        --Check the type of the set
        if lib.monsterSets[setId] then      setInfoTable.setTypes["isMonster"]  = true
        elseif lib.trialSets[setId] then    setInfoTable.setTypes["isTrial"]    = true
        elseif lib.arenaSets[setId] then    setInfoTable.setTypes["isArena"]    = true
        elseif lib.dungeonSets[setId] then  setInfoTable.setTypes["isDungeon"]  = true
        elseif lib.overlandSets[setId] then setInfoTable.setTypes["isOverland"] = true
        end
    end
    return setInfoTable
end

--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil then return false end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local jumpToNode = -1
    --Is a crafted set?
    if craftedSets[setId] then
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

--Returns an itemId of an item of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    number setItemId
function lib.GetSetItemId(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemId = lib.svData.sets[tonumber(setId)]["itemId"]
    return setItemId
end

--Returns a boolean value, true if the sets of the game were already loaded/ false if not
--> Returns:    boolean areSetsLoaded
function lib.AreSetsLoaded()
    local areSetsLoaded = false
    local lastCheckedSetsAPIVersion = math.max( lib.svData.lastSetsCheckAPIVersion or 0, preloaded.lastSetsCheckAPIVersion )
    areSetsLoaded = (lib.setsLoaded == true and (lastCheckedSetsAPIVersion >= lib.currentAPIVersion)) or false
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
    if not lib.svData or not lib.svData.sets then return false end
    return true
end

------------------------------------------------------------------------
--Addon loaded function
local function OnLibraryLoaded(event, name)
    --Only load lib if ingame
    if name:find("^ZO_") then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    --The actual clients language
    lib.clientLang = GetCVar("language.2")
    --The actual API version
    lib.currentAPIVersion = GetAPIVersion()

    --Load the SavedVariables
    librarySavedVariables()

    --Initialize the ask before reloadui dialog
    lib.AskBeforeReloadUIDialogInitialize(LibSetsAskBeforeReloadUIDialogXML)

    --Did the API version change since last sets check? Then rebuild the sets now!
    local lastCheckedSetsAPIVersion = math.max( lib.svData.lastSetsCheckAPIVersion or 0, preloaded.lastSetsCheckAPIVersion)
    --API version changed?
    if lastCheckedSetsAPIVersion < lib.currentAPIVersion then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]API version changed from \'" .. tostring(lastCheckedSetsAPIVersion) .. "\'to \'" .. tostring(lib.currentAPIVersion) .. "\nNew set IDs and names need to be scanned!\nThis will take a few seconds.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(true)
        end, 1000)
        --Client language changed and language is not yet in the SavedVariables?
    elseif lib.supportedLanguages and lib.clientLang and lib.supportedLanguages[lib.clientLang] == true
            and lib.svData and lib.svData.sets and lib.svData["languagesScanned"] and
            (lib.svData["languagesScanned"][lib.currentAPIVersion] == nil or (lib.svData["languagesScanned"][lib.currentAPIVersion] and lib.svData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] == nil)) then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]Sets data for your current client language \'" .. tostring(lib.clientLang) .. "\' and the current API version \'" .. tostring(lib.currentAPIVersion) .. "\' was not added yet.\nNew set names need to be scanned!\nThis will take a few seconds.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(false)
        end, 1000)
    else
        --Load preloaded set names
        loadPreloadedSetNames()
        loadSetIds()
        if lib.svData
                and (lib.svData.monsterSets == nil or lib.svData.dungeonSets == nil or lib.svData.overlandSets == nil
                or lib.svData.monsterSetsCount == nil or lib.svData.dungeonSetsCount == nil or lib.svData.overlandSetsCount == nil
                or not next(lib.svData.monsterSets) or not next(lib.svData.dungeonSets) or not next(lib.svData.overlandSets)
                or lib.svData.monsterSetsCount == 0 or lib.svData.dungeonSetsCount == 0 or lib.svData.overlandSetsCount == 0)
        then
            distinguishSetTypes()
            lib.svData.monsterSets        = monsterSets
            lib.svData.dungeonSets        = dungeonSets
            lib.svData.overlandSets       = overlandSets
            lib.svData.monsterSetsCount   = monsterSetsCount
            lib.svData.dungeonSetsCount   = dungeonSetsCount
            lib.svData.overlandSetsCount  = overlandSetsCount
        end
        lib.setsLoaded = true
    end
    --Provide the library the "list of set types" and counts
    lib.craftedSets         = craftedSets
    lib.craftedSetsCount    = craftedSetsCount
    lib.monsterSets         = lib.svData.monsterSets
    lib.dungeonSets         = lib.svData.dungeonSets
    lib.overlandSets        = lib.svData.overlandSets
    lib.monsterSetsCount    = lib.svData.monsterSetsCount
    lib.dungeonSetsCount    = lib.svData.dungeonSetsCount
    lib.overlandSetsCount   = lib.svData.overlandSetsCount
    lib.preloaded           = preloaded
end

-------------------------------------------------------------------------------------------------------------------------------
-- Data update functions - Only for developers of this lib to get new data from e.g. the PTS or after major patches on live.
-- e.g. to get the new wayshrines names and zoneNames
-- Uncomment to use them via the libraries global functions then
-------------------------------------------------------------------------------------------------------------------------------

--[[
local function GetAllZoneInfo()
    local maxZoneId = 2000
    local zoneData = {}
    local lang = GetCVar("language.2")
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
    d("GetWayshrineInfo")
    local wayshrines = {}
    local currentMapIndex = GetCurrentMapIndex()
    if currentMapIndex == nil then d("<-Error: map index") return end
    local currentMapId = GetCurrentMapId()
    if currentMapId == nil then d("<-Error: map id") return end
    local currentMapsZoneIndex = GetCurrentMapZoneIndex()
    if currentMapsZoneIndex == nil then d("<-Error: map zone index") return end
    local currentZoneId = GetZoneId(currentMapsZoneIndex)
    if currentZoneId == nil then d("<-Error: map zone id") return end
    local currentMapName = ZO_CachedStrFormat("<<C:1>>", GetMapNameByIndex(currentMapIndex))
    local currentZoneName = ZO_CachedStrFormat("<<C:1>>", GetZoneNameByIndex(currentMapsZoneIndex))
    d("->mapIndex: " .. tostring(currentMapIndex) .. ", mapId: " .. tostring(currentMapId) ..
            ", mapName: " .. tostring(currentMapName) .. ", mapZoneIndex: " ..tostring(currentMapsZoneIndex) .. ", zoneId: " .. tostring(currentZoneId) ..
            ", zoneName: " ..tostring(currentZoneName))
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
    d("[GetWayshrineNames]")
    local wsNames = {}
    local lang = GetCVar("language.2")
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
    d("[GetMapNames]lang: " ..tostring(lang))
    local lz = LibZone
    if not lz then d("LibZone must be loaded!") return end
    local zoneIds = lz.givenZoneData
    if not zoneIds then d("LibZone givenZoneData is missing!") return end
    local zoneIdsLocalized = zoneIds[lang]
    if not zoneIdsLocalized then d("Language \"" .. tostring(lang) .."\" is not scanned yet in LibZone") return end
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
    local zoneData = {}
    zoneData = GetAllZoneInfo()
    lib.svData.zoneData = lib.svData.zoneData or {}
    lib.svData.zoneData[lib.clientLang] = {}
    lib.svData.zoneData[lib.clientLang] = zoneData[lib.clientLang]
end

function lib.GetMapNames()
    local maps = GetMapNames(lib.clientLang)
    if maps ~= nil then
        lib.svData.maps = lib.svData.maps or {}
        lib.svData.maps[lib.clientLang] = {}
        lib.svData.maps[lib.clientLang] = maps
    end
end

function lib.GetWayshrineInfo()
    local ws = GetWayshrineInfo()
    if ws ~= nil then
        lib.svData.wayshrines = lib.svData.wayshrines or {}
        for wsNodeId, wsData in pairs(ws) do
            lib.svData.wayshrines[wsNodeId] = wsData
        end
    end
end

function lib.GetWayshrineNames()
    local wsNames = GetWayshrineNames()
    if wsNames ~= nil and wsNames[lib.clientLang] ~= nil then
        lib.svData.wayshrineNames = lib.svData.wayshrineNames or {}
        lib.svData.wayshrineNames[lib.clientLang] = {}
        lib.svData.wayshrineNames[lib.clientLang] = wsNames[lib.clientLang]
    end
end
]]

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)