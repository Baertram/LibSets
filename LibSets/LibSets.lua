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
lib.setsData    = {
    ["languagesScanned"] = {},
}
lib.setsLoaded  = false
lib.setsScanning = false

--The supported languages of this library
lib.supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["jp"]  = true,
    ["ru"]  = true,
}

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
--All sets data
local sets = {}
local setsFound = 0
local setsUpdated = 0
local itemsScanned = 0

--Allowed itemTypes for the set parts
local checkItemTypes = {
    [ITEMTYPE_WEAPON] = true,
    [ITEMTYPE_ARMOR]  = true,
}

--Current monster set bonus count (maximum)
local countMonsterSetBonus = 2
--The monster set setIds (all setIds which are not in the craftedSets table!)
local monsterSetsCount  = 0
local dungeonSetsCount  = 0
local overlandSetsCount = 0
local monsterSets       = {}
local dungeonSets       = {}
local overlandSets      = {}

--The craftable set setIds
local craftedSets = {
    [176]   = true,     --Adelssieg / Noble's Conquest
    [82]    = true,     --Alessias Bollwerk / Alessia's Bulwark
    [54]    = true,     --Aschengriff / Ashen Grip
    [323]   = true,     --Assassinenlist / Assassin's Guile
    [87]    = true,     --Augen von Mara / Eyes of Mara
    [51]    = true,     --Blick der Mutter der Nacht / Night Mother's Gaze
    [324]   = true,     --Daedrische Gaunerei / Daedric Trickery
    [161]   = true,     --Doppelstern / Twice-Born Star
    [73]    = true,     --Erinnerung / Oblivion's Foe
    [226]   = true,     --Ewige Jagd / Eternal Hunt
    [208]   = true,     --Feuertaufe / Trial by Fire
    [207]   = true,     --Gesetz von Julianos / LAw of Julianos
    [240]   = true,     --Gladiator von Kvatch / Kvatch Gladiator
    [408]   = true,     --Grabpflocksammler / Grave-Stake Collector
    [78]    = true,     --Histrinde / Hist Bark
    [80]    = true,     --Hundings Zorn / Hunding's Rage
    [92]    = true,     --Kagrenacs Hoffnung / Kagrenac's Hope
    [351]   = true,     --Kernaxiom / Innate Axiom
    [325]   = true,     --Kettensprenger / Shacklebreaker
    [386]   = true,     --Kreckenantlitz / Sload's Semblance
    [44]    = true,     --Kuss des Vampirs / Vampire's Kiss
    [81]    = true,     --Lied der Lamien / Song of Lamae
    [410]   = true,     --Macht der verlorenen Legion / Might of the Lost Legion
    [48]    = true,     --Magnus' Gabe / Magnu's Gift
    [353]   = true,     --Mechanikblick / Mechanical Acuity
    [352]   = true,     --Messingpanzer / Fortified Brass
    [219]   = true,     --Morkuldin / Morkuldin
    [409]   = true,     --Nagaschamane / Naga Shaman
    [387]   = true,     --Nocturnals Gunst / Nocturnal's Favor
    [84]    = true,     --Orgnums Schuppen / Orgnum's Scales
    [242]   = true,     --Pelinals Talent / Pelinal's Aptitude
    [43]    = true,     --Rüstung der Verführung / Armor of the Seducer
    [178]   = true,     --Rüstungsmeister / Armor Master
    [74]    = true,     --Schemenauge / Spectre's Eye
    [225]   = true,     --Schlauer Alchemist / Clever Alchemist
    [95]    = true,     --Shalidors Fluch / Shalidor's Curse
    [40]    = true,     --Stille der Nacht / Night's Silence
    [224]   = true,     --Tavas Gunst / Tava's Favor
    [37]    = true,     --Todeswind / Death's Wind
    [75]    = true,     --Torugs Pakt / Torug's Pact
    [177]   = true,     --Umverteilung / Redistributor
    [241]   = true,     --Varens Erbe / Varen's Legacy
    [385]   = true,     --Versierter Reiter / Adept Rider
    [148]   = true,     --Weg der Arnea / Way of the Arena
    [79]    = true,     --Weidenpfad / Willow's Path
    [41]    = true,     --Weißplankes Vergeltung / Whitestrake's Retribution
    [38]    = true,     --Zwielichtkuss / Twilight's Embrace
}

--Wayshrine nodes and number of traits needed for sets. All rights and work belongs to the addon "CraftStore" and "WritWorthy"!
--https://www.esoui.com/downloads/info1590-CraftStoreWrathstone.html
--https://www.esoui.com/downloads/info1605-WritWorthy.html
local setInfo = {
    --Crafted Sets (See names of setId (table key) above behind table entries of "craftedSets")
    [37]    = {wayshrines={1,177,71},        traitsNeeded=2},
    [38]    = {wayshrines={15,169,205},      traitsNeeded=3},
    [40]    = {wayshrines={216,121,65},      traitsNeeded=2},
    [41]    = {wayshrines={82,151,78},       traitsNeeded=4},
    [43]    = {wayshrines={23,164,32},       traitsNeeded=3},
    [44]    = {wayshrines={58,101,93},       traitsNeeded=5},
    [48]    = {wayshrines={13,148,48},       traitsNeeded=4},
    [51]    = {wayshrines={34,156,118},      traitsNeeded=6},
    [54]    = {wayshrines={7,175, 77},       traitsNeeded=2},
    [73]    = {wayshrines={135,135,135},     traitsNeeded=8},
    [74]    = {wayshrines={133,133,133},     traitsNeeded=8},
    [75]    = {wayshrines={19,165,24},       traitsNeeded=3},
    [78]    = {wayshrines={9,154,51},        traitsNeeded=4},
    [79]    = {wayshrines={35,144,111},      traitsNeeded=6},
    [80]    = {wayshrines={39,161,113},      traitsNeeded=6},
    [81]    = {wayshrines={137,103,89},      traitsNeeded=5},
    [82]    = {wayshrines={155,105, 95},     traitsNeeded=5},
    [84]    = {wayshrines={-2,-2,-2},        traitsNeeded=8},
    [87]    = {wayshrines={-1,-1,-1},        traitsNeeded=8},
    [92]    = {wayshrines={-2,-2,-2},        traitsNeeded=8},
    [95]    = {wayshrines={-1,-1,-1},        traitsNeeded=8},
    [148]   = {wayshrines={217,217,217},     traitsNeeded=8},
    [161]   = {wayshrines={234,234,234},     traitsNeeded=9},
    [177]   = {wayshrines={199,201,203},     traitsNeeded=5},
    [176]   = {wayshrines={199,201,203},     traitsNeeded=7},
    [178]   = {wayshrines={199,201,203},     traitsNeeded=9},
    [207]   = {wayshrines={241,241,241},     traitsNeeded=6},
    [208]   = {wayshrines={237,237,237},     traitsNeeded=3},
    [219]   = {wayshrines={237,237,237},     traitsNeeded=9},
    [224]   = {wayshrines={257,257,257},     traitsNeeded=5},
    [225]   = {wayshrines={257,257,257},     traitsNeeded=7},
    [226]   = {wayshrines={255,255,255},     traitsNeeded=9},
    [240]   = {wayshrines={254,254,254},     traitsNeeded=5},
    [241]   = {wayshrines={251,251,251},     traitsNeeded=7},
    [242]   = {wayshrines={254,254,254},     traitsNeeded=9},
    [323]   = {wayshrines={276,276,276},     traitsNeeded=3},
    [324]   = {wayshrines={329,329,329},     traitsNeeded=8},
    [351]   = {wayshrines={339,339,339},     traitsNeeded=6},
    [352]   = {wayshrines={337,337,337},     traitsNeeded=2},
    [353]   = {wayshrines={338,338,338},     traitsNeeded=4},
    [325]   = {wayshrines={282,282,282},     traitsNeeded=6},
    [385]   = {wayshrines={359,359,359},     traitsNeeded=3},
    [386]   = {wayshrines={360,360,360},     traitsNeeded=6},
    [387]   = {wayshrines={354,354,354},     traitsNeeded=9},
    --TODO
    [408]   = {wayshrines={375,375,375},     traitsNeeded=0},
    [409]   = {wayshrines={379,379,379},     traitsNeeded=0},
    [410]   = {wayshrines={379,379,379},     traitsNeeded=0},

    --Other sets (Set names can be found inside SavedVariables file LibSets.lua, after scaning of the set names within your client language finished.
    --Search for "["sets"]" inside the SV file and you'll find the ["name"] in the scanned languages e.g. ["de"] or ["en"] and an example itemId of one
    --item of this set which you can use with LibSets.buildItemLink(itemId) to generate an example itemLink of the set item)
    --TODO
    [31]    = {wayshrines={65}},                                     --Sonnenseide (Stonefalls: Davons Watch, or 41 "Fort Arnad" near to a Worldboss)
}
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
local craftedSetsCount = getNonIndexedTableCount(craftedSets)

--Check if the item is a head or a shoulder
local function IsHeadOrShoulder(equipType)
    return (equipType == EQUIP_TYPE_HEAD or equipType == EQUIP_TYPE_SHOULDERS) or false
end

--Check if an item got less or equal "countMonsterSetBonus"
local function IsItemMonsterSet(maxEquipped)
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

local function LoadSetsByIds(from, to)
    local buildItemLink = lib.buildItemLink
    local clientLang = lib.clientLang
    for setItemId=from, to do
        itemsScanned = itemsScanned + 1
        --Generate link for item
        local itemLink = buildItemLink(setItemId)
        if itemLink and itemLink ~= "" then
            if not IsItemLinkCrafted(itemLink) then
                local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                if isSet then
                    local itemType = GetItemLinkItemType(itemLink)
                    --Some set items are only "containers" ...
                    if checkItemTypes[itemType] then
                        --Only add the first found item of the set as itemId!
                        if sets[setId] == nil then
                            sets[setId] = {}
                            setsFound = setsFound + 1
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
                                setsUpdated = setsUpdated + 1
                            end
                        end
                    end
                end
            end
        end
    end
    d("[LibSets]~~~Scanning sets~~~ items: " .. tostring(itemsScanned) .. ", sets new/updated: " .. tostring(setsFound) .. "/" .. tostring(setsUpdated))
end

--Load the SavedVariables
local function librarySavedVariables()
    lib.worldName = GetWorldName()
    local defaultSetsData = {}
    lib.setsData = ZO_SavedVars:NewAccountWide(lib.svDataName, lib.svVersion, "SetsData", defaultSetsData, lib.worldName)
    if lib.setsData.sets ~= nil then lib.setsLoaded = true end
end

--Update the set types tables for the given set id and data.
--All non-craftable head and shoulder with only 1 or 2 set bonus: monsterSets table
--All non-craftable, non-monster sets that are bound on pickup: dungeonSets table
--All non-craftable, non-monster, non-dungeon set: overlandSets table
local function distinguishSetType(setId, setData)
    local buildItemLink = lib.buildItemLink
    
    if craftedSets[setId] then return end
  
    --Get the itemId stored for the setId and build the itemLink
    local itemId = setData.itemId
    if itemId == nil then return end
    
    local itemLink = buildItemLink(itemId)
    if itemLink == nil then return end
    
    --Get the maxEquipped attribute of the set
    local _, _, _, _, maxEquipped, _ = GetItemLinkSetInfo(itemLink)
    
    --Check if the item is a monster set
    if IsItemMonsterSet(maxEquipped) then
        local equipType = GetItemLinkEquipType(itemLink)
        if IsHeadOrShoulder(equipType) then
            --It's a monster set (helm or shoulder with defined number of max bonus)
            monsterSets[setId] = true
            monsterSetsCount = monsterSetsCount + 1
            return
        end
    end
    
    --Item is no monster set, so check for dungeon or
    --Is a dungeon set (bound on pickup but tradeable)?
    if IsItemDungeonSet(itemLink) then
        dungeonSets[setId] = true
        dungeonSetsCount = dungeonSetsCount + 1
    else
        --Is an overland set
        overlandSets[setId] = true
        overlandSetsCount = overlandSetsCount + 1
    end
end

-- Populates the various set type arrays (monsterSets, dungeonSets, overlandSets)
-- and their associated totals (monsterSetsCount, dungeonSetsCount, overlandSetsCount)
local function distinguishSetTypes()
    monsterSetsCount  = 0
    dungeonSetsCount  = 0
    overlandSetsCount = 0
    monsterSets = {}
    dungeonSets = {}
    overlandSets = {}
    for setId, setData in pairs(lib.setsData.sets) do
        distinguishSetType(setId, setData)
    end
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
    if fromAddonName ~= nil and fromAddonName ~= "" then
        d("[LibSets]Starting set scan initiated by addon \'" .. tostring(fromAddonName) .. "\', APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
    else
        d("[LibSets]Starting set scan, APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
    end
    --Clear all set data
    sets = {}
    --Take exisitng SavedVars sets and update them, or override them with a new scan?
    if not override then
        if lib.setsData ~= nil and lib.setsData.sets ~= nil then
            sets = lib.setsData.sets
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
            LoadSetsByIds(v.from, v.to)
        end, miliseconds)
        miliseconds = miliseconds + 2000 -- scan item ID packages every 2 seconds to get not kicked/crash the client!
    end
    zo_callLater(function()
        if sets ~= nil then
            d("[LibSets]Scan finished. [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
            lib.setsData.sets = sets
            distinguishSetTypes()
            lib.setsData.monsterSets        = monsterSets
            lib.setsData.dungeonSets        = dungeonSets
            lib.setsData.overlandSets       = overlandSets
            lib.setsData.monsterSetsCount   = monsterSetsCount
            lib.setsData.dungeonSetsCount   = dungeonSetsCount
            lib.setsData.overlandSetsCount  = overlandSetsCount
            d(">>> Crafted sets: " .. tostring(craftedSetsCount))
            d(">>> Monster sets: " .. tostring(monsterSetsCount))
            d(">>> Dungeon sets: " .. tostring(dungeonSetsCount))
            d(">>> Overland sets: " .. tostring(overlandSetsCount))
            d("\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
            --Set the last scanned API version to the SavedVariables
            lib.setsData["languagesScanned"] = lib.setsData["languagesScanned"] or {}
            lib.setsData["languagesScanned"][lib.currentAPIVersion] = lib.setsData["languagesScanned"][lib.currentAPIVersion] or {}
            lib.setsData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] = true
            --Set the flag "sets were scanned for current API"
            lib.setsData.lastSetsCheckAPIVersion = lib.currentAPIVersion
            lib.setsScanning = false
            --Start confirmation dialog and let the user do a reloadui so the SetData gets stored to the SavedVars and depending addons will work afterwards
            lib.ShowAskBeforeReloadUIDialog()
        else
            lib.setsScanning = false
            d("[LibSets]ERROR: Scan not successfull! [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'\nSet data could not be saved!\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end
    end, miliseconds + 1000)
end


--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)
    if setId == nil then return end
    return lib.craftedSets[setId] or false
end

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    return lib.monsterSets[setId] or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    return lib.dungeonSets[setId] or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
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

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
    if setId == nil or not lib.supportedLanguages[lang] or lib.setsData.sets == nil
        or lib.setsData.sets[tonumber(setId)] == nil or lib.setsData.sets[tonumber(setId)]["name"] == nil
        or lib.setsData.sets[tonumber(setId)]["name"][lang] == nil then return end
    local setName = lib.setsData.sets[tonumber(setId)]["name"][lang]
    return setName
end

--Returns all names as String of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil or lib.setsData.sets == nil or lib.setsData.sets[tonumber(setId)] == nil
        or lib.setsData.sets[tonumber(setId)]["name"] == nil then return end
    local setNames = {}
    setNames = lib.setsData.sets[tonumber(setId)]["name"]
    return setNames
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains the number setId,
----> number itemId of an example setItem (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's example item),
----> table names ([String lang] = String name),
----> table setTypes (table containing booleans for isCrafted, isDungeon, isMonster, isOverland),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table will contain 1 entry if it's a NON-craftable setId (wayshrines = {[1] = WSNodeNoFraction})
------>and 3 entries (one for each faction) if it's a craftable setId (wayshrines = {[1] = WSNodeFraction1, [2] = WSNodeFraction2, [3] = WSNodeFraction3})
function lib.GetSetInfo(setId)
    if setId == nil or lib.setsData.sets == nil or lib.setsData.sets[tonumber(setId)] == nil then return end
    local setInfoTable = {}
    local setInfoFromSV = lib.setsData.sets[tonumber(setId)]
    setInfoTable.setId = setId
    setInfoTable.itemId = setInfoFromSV["itemId"]
    setInfoTable.names = setInfoFromSV["name"] or {}
    setInfoTable.setTypes = {
        ["isCrafted"]   = false,
        ["isDungeon"]   = false,
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
        elseif lib.dungeonSets[setId] then  setInfoTable.setTypes["isDungeon"]  = true
        elseif lib.overlandSets[setId] then setInfoTable.setTypes["isOverland"] = true
        end
    end
    return setInfoTable
end

--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Ebonheart Pact, 2=Admeri Dominion, 3=Daggerfall Covenant)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil then return false end
    local jumpToNode = -1
    --Is a crafted set?
    if craftedSets[setId] then
        --Then use the faction Id 1 to 3
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
    local setItemId = lib.setsData.sets[tonumber(setId)]["itemId"]
    return setItemId
end

--Returns a boolean value, true if the sets of the game were already loaded/ false if not
--> Returns:    boolean areSetsLoaded
function lib.AreSetsLoaded()
    local areSetsLoaded = false
    local lastCheckedSetsAPIVersion = lib.setsData.lastSetsCheckAPIVersion
    areSetsLoaded = (lib.setsLoaded == true and (lastCheckedSetsAPIVersion ~= nil and lastCheckedSetsAPIVersion == lib.currentAPIVersion)) or false
    return areSetsLoaded
end

--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not
--> Returns:    boolean isCurrentlySetsScanning
function lib.IsSetsScanning()
    return lib.setsScanning
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
    local lastCheckedSetsAPIVersion = lib.setsData.lastSetsCheckAPIVersion
    --API version changed?
    if lastCheckedSetsAPIVersion == nil or lastCheckedSetsAPIVersion ~= lib.currentAPIVersion then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]API version changed from \'" .. tostring(lastCheckedSetsAPIVersion) .. "\'to \'" .. tostring(lib.currentAPIVersion) .. "\nAll set IDs and names need to be rescanned!\nThis will take about 2 minutes.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nYour client might lag and be hardly responsive during this time!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(true)
        end, 1000)
    --Client language changed and language is not yet in the SavedVariables?
    elseif lib.supportedLanguages and lib.clientLang and lib.supportedLanguages[lib.clientLang] == true
        and lib.setsData and lib.setsData.sets and lib.setsData["languagesScanned"] and
            (lib.setsData["languagesScanned"][lib.currentAPIVersion] == nil or (lib.setsData["languagesScanned"][lib.currentAPIVersion] and lib.setsData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] == nil)) then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]Sets data for your current client language \'" .. tostring(lib.clientLang) .. "\' and the current API version \'" .. tostring(lib.currentAPIVersion) .. "\' was not added yet.\nAll set IDs and names need to be rescanned!\nThis will take about 2 minutes.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nYour client might lag and be hardly responsive during this time!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(false)
        end, 1000)
    end
    --Provide the library the "list of set types" and counts
    lib.craftedSets         = craftedSets
    lib.craftedSetsCount    = craftedSetsCount
    lib.monsterSets         = lib.setsData.monsterSets
    lib.dungeonSets         = lib.setsData.dungeonSets
    lib.overlandSets        = lib.setsData.overlandSets
    lib.monsterSetsCount    = lib.setsData.monsterSetsCount
    lib.dungeonSetsCount    = lib.setsData.dungeonSetsCount
    lib.overlandSetsCount   = lib.setsData.overlandSetsCount
end

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)