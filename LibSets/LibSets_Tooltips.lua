--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version

local lam

local libPrefix = "["..MAJOR.."]"
local placeHolder = ": "

--local ZOs variables
local EM = EVENT_MANAGER

local tos = tostring
local strgmatch = string.gmatch
--local strlower = string.lower
--local strlen = string.len
local strfind = string.find
local strgsub = string.gsub
--local strfor = string.format

local tins = table.insert
--local trem = table.remove
local tsort = table.sort
--local unp = unpack
local zostrfor = zo_strformat
--local zocstrfor = ZO_CachedStrFormat
local zoitf = zo_iconTextFormat
local zoitfns = zo_iconTextFormatNoSpace

local gilsetinf =   GetItemLinkSetInfo
local gilet =       GetItemLinkEquipType
local gthlil =      GetTradingHouseListingItemLink
local gmqal =       GetMailQueuedAttachmentLink
local gail =        GetAttachedItemLink
local gbil =        GetBuybackItemLink
local gsil =        GetStoreItemLink
local gqril =       GetQuestRewardItemLink
local glil =        GetLootItemLink
local gil =         GetItemLink


local dropZoneNames = {}
local dropMechanicNames = {}
local dropLocationNames = {}


local dropMechanicIdToTexture =             lib.dropMechanicIdToTexture
local setTypeToTexture =                    lib.setTypeToTexture
local vetDungTexture =                      setTypeToTexture["vet_dung"]
local undauntedChestTexture =               setTypeToTexture["undaunted chest"]
local imperialCityTexture =                 setTypeToTexture[LIBSETS_SETTYPE_IMPERIALCITY]
local setTypeToDropZoneLocalizationStr =    lib.setTypeToDropZoneLocalizationStr
local getDropMechanicName =                 lib.GetDropMechanicName


local clientLang =      lib.clientLang
local fallbackLang =    lib.fallbackLang
local localization         =    lib.localization[clientLang]
local dropLocationZonesStr =    localization.dropZones
local dlcStr =                  localization.dlc
local droppedByStr =            localization.droppedBy
local dungeonStr =              localization.dropZoneDungeon
local vetDungeonStr =           localization.dropZoneVeteranDungeon
local imperialCityStr =         localization.dropZoneImperialCity
local imperialSewersStr =       localization.dropZoneImperialSewers
local veteranDungeonIconStr =   zoitf(vetDungTexture, 24, 24, dungeonStr, nil)
local bossStr =                 localization.boss
local setTypeStr =              localization.setType
local neededTraitsStr =         localization.neededTraits
local dropMechanicStr =         localization.dropMechanic
local battlegroundStr =         GetString(SI_LEADERBOARDTYPE4) --Battleground
local undauntedChestStr =       localization.undauntedChest
local undauntedChestIdNames =   lib.undauntedChestIds[clientLang]

local monsterSetTypes = {
    [LIBSETS_SETTYPE_MONSTER] =                 true,
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER] =    true,
}
local monsterSetTypeToVeteranStr = {
    [LIBSETS_SETTYPE_MONSTER] =                 veteranDungeonIconStr,
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER] =    imperialCityStr,
}
local monsterSetTypeToNoVeteranStr = {
    [LIBSETS_SETTYPE_MONSTER] =                 undauntedChestStr,
    [LIBSETS_SETTYPE_IMPERIALCITY_MONSTER] =    imperialSewersStr,
}


--local library variables
local libSets_GetSetInfo =                  lib.GetSetInfo
local libSets_GetZoneName =                 lib.GetZoneName
--local libSets_GetDropMechanicName =         lib.GetDropMechanicName
local libSets_GetSetTypeName =              lib.GetSetTypeName
local libSets_GetDLCName =                  lib.GetDLCName

--The tooltip game data line after that the LibSets entries should be added
local tooltipGameDataEntryToAddAfter = TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN


--Possible tooltips controls
--ZO_PopupToolTip
--ZO_ItemToolTip
local tooltipCtrls = {
    ["popup"] =     PopupTooltip,
    ["info"] =      InformationTooltip,
    ["item"] =      ItemTooltip,
    ["compa1"] =    ComparativeTooltip1,
    ["compa2"] =    ComparativeTooltip2,
}
local popupTooltip =        tooltipCtrls["popup"]
local infoTooltip =         tooltipCtrls["info"]
local itemTooltip =         tooltipCtrls["item"]
--local comparativeTooltip1 = tooltipCtrls["compa1"] --not used so far
--local comparativeTooltip2 = tooltipCtrls["compa2"] --not used so far


--Other addons
local masterMerchantCtrlNames = {
    ['MasterMerchantWindowListContents'] = true,
    ['MasterMerchantWindowList'] = true,
    ['MasterMerchantGuildWindowListContents'] = true,
}
local IIfACtrlNames = {
    ["IIFA_ListItem"] = true
}


--Variables
local tooltipSV
local addDLC
local addDropLocation
local addDropMechanic
local addBossName
local addSetType
local addNeededTraits
local tooltipTextures
local anyTooltipInfoToAdd = false

local lastTooltipItemLink

local useCustomTooltip = false
--local customTooltipPlaceholdersNeeded = {}
local setTypePlaceholder = false
local dropMechanicPlaceholder = false
local dropZonesPlaceholder = false
local bossNamePlaceholder = false
local neededTraitsPlaceholder = false
local dlcNamePlaceHolder = false


--Functions
local function getLibSetsTooltipSavedVariables()
    if not lib.svData then return end
    return lib.svData.tooltipModifications
end

--[[
--Custom tooltip placeholders
    <<1>>   Set type
    <<2>>   Drop mechanics
    <<3>>   Drop zones
    <<4>>   Boss/Dropped by names
    <<5>>   Number of needed traits researched
    <<6>>   Chapter/DLC name set was introduced with",
]]
local function isCustomTooltipEnabled(value)
    setTypePlaceholder = false
    dropMechanicPlaceholder = false
    dropZonesPlaceholder = false
    bossNamePlaceholder = false
    neededTraitsPlaceholder = false
    dlcNamePlaceHolder = false

    local useCustomTooltipPattern = value
    if useCustomTooltipPattern == nil then useCustomTooltipPattern = lib.svData.useCustomTooltipPattern end
--d(">useCustomTooltipPattern: " ..tos(useCustomTooltipPattern))
    if useCustomTooltipPattern and useCustomTooltipPattern ~= "" then
        --Check if the custom tooltip pattern contains any placeholder, else it will not be relevant
        if strfind(useCustomTooltipPattern, "<<%d>>", 1, false) ~= nil then
--d(">>drin")
            local doAdd = false
            for placeholder in strgmatch(useCustomTooltipPattern, "<<%d>>+") do
                if placeholder == "<<1>>" then
                    setTypePlaceholder = true
                    doAdd = true
                elseif placeholder == "<<1>>" then
                    setTypePlaceholder = true
                    doAdd = true
                elseif placeholder == "<<2>>" then
                    dropMechanicPlaceholder = true
                    doAdd = true
                elseif placeholder == "<<3>>" then
                    dropZonesPlaceholder = true
                    doAdd = true
                elseif placeholder == "<<4>>" then
                    bossNamePlaceholder = true
                    doAdd = true
                elseif placeholder == "<<5>>" then
                    neededTraitsPlaceholder = true
                    doAdd = true
                elseif placeholder == "<<6>>" then
                    dlcNamePlaceHolder = true
                    doAdd = true
                end
            end
--d(">>doAdd: " ..tos(doAdd))
            if doAdd == true then
                return true
            end
        end
    end
    return false
end
lib.IsLibSetsCustomTooltipEnabled = isCustomTooltipEnabled


local function isLibSetsTooltipEnabled()
    if not tooltipSV then return end
    tooltipTextures       =     tooltipSV.tooltipTextures
    veteranDungeonIconStr =     (tooltipTextures == true and zoitf(vetDungTexture, 24, 24, dungeonStr, nil)) or vetDungeonStr
    monsterSetTypeToVeteranStr[LIBSETS_SETTYPE_MONSTER] = veteranDungeonIconStr


    addDropLocation =           tooltipSV.addDropLocation
    addDropMechanic =           tooltipSV.addDropMechanic
    addDLC =                    tooltipSV.addDLC
    addBossName =               tooltipSV.addBossName
    addSetType =                tooltipSV.addSetType
    addNeededTraits =           tooltipSV.addNeededTraits

    anyTooltipInfoToAdd = ((useCustomTooltip == true
                                or (not useCustomTooltip and (addDropLocation == true or addDropMechanic == true or addDLC == true
                                                            or addBossName == true or addSetType == true or addNeededTraits == true))
                            ) and true) or false
end
lib.IsLibSetsTooltipEnabled = isLibSetsTooltipEnabled


------------------------------------------------------------------------------------------------------------------------
local function isTooltipOfSetItem(itemLink, tooltipData)
-- @return hasSet bool, setName string, numBonuses integer, numNormalEquipped integer, maxEquipped integer, setId integer, numPerfectedEquipped integer
    local isSet, _, _, _, _, setId, _ = gilsetinf(itemLink, false)
    return isSet, setId
end

local function getItemLinkFromControl(rowControl)
    local name
    local parentCtrl
    local bagId, slotIndex
    local itemLink

    if rowControl.itemLink then return rowControl.itemLink end
    if rowControl.itemlink then return rowControl.itemlink end

    if rowControl.GetParent then
        parentCtrl = rowControl:GetParent()
        name = parentCtrl:GetName()
    else
        name = rowControl:GetName()
    end

    --Inventory Insight from ashes support
    if IIfA then
        --In FCOItemSaver
        if FCOIS then
            local IIfAclicked = FCOIS.IIfAclicked
            if IIfAclicked ~= nil then
                return gil(IIfAclicked.bagId, IIfAclicked.slotIndex)
            end
        else
            --Plain IIfA
            if IIfACtrlNames[name:sub(1, 13)] then
                return rowControl.itemLink
            end
        end
    end

    --gotta do this in case deconstruction, or player equipment
    local dataEntry = rowControl.dataEntry
    local isDataEntryNil = (dataEntry == nil and true) or false
    local dataEntryData = (isDataEntryNil == false and dataEntry.data) or nil

    --use rowControl = case to handle equiped items
    --bag/index = case to handle list dialog, list dialog uses index instead of slotIndex and bag instead of bagId...?
    if isDataEntryNil == true then
        bagId = rowControl.bagId
        slotIndex = rowControl.slotIndex
    else
        if dataEntryData then
            if dataEntryData.lootId then
                return glil(dataEntryData.lootId, LINK_STYLE_BRACKETS)
            elseif rowControl.index and name == "ZO_InteractWindowRewardArea" then
                return gqril(rowControl.index, LINK_STYLE_BRACKETS)
            elseif dataEntryData.itemLink then
                return dataEntryData.itemLink
            elseif dataEntryData.itemlink then
                return dataEntryData.itemlink
            else
                bagId = dataEntryData.bagId
                bagId = bagId or dataEntryData.bag
                slotIndex = dataEntryData.slotIndex
                slotIndex = slotIndex or dataEntryData.index
            end
        end
    end

    --Is the bagId still nil: Check if it's a questItem, or a store buy item
    if bagId == nil then
        if rowControl.questIndex ~= nil then
            parentCtrl = parentCtrl or (rowControl.GetParent and rowControl:GetParent())
            local parentDataEntry = parentCtrl and parentCtrl.dataEntry and parentCtrl.dataEntry.data
            bagId, slotIndex = BAG_BACKPACK, parentDataEntry.slotIndex
        elseif rowControl.index and rowControl.slotType then
            if rowControl.slotType == SLOT_TYPE_STORE_BUY or rowControl.slotType == SLOT_TYPE_BUY_MULTIPLE then
                return gsil(rowControl.index, LINK_STYLE_BRACKETS)

            elseif rowControl.slotType == SLOT_TYPE_STORE_BUYBACK then
                return gbil(rowControl.index, LINK_STYLE_BRACKETS)
            end
        end
    end

    if bagId ~= nil and slotIndex ~= nil then
        itemLink = gil(bagId, slotIndex)
    end

    if itemLink == nil then
        if name == 'ZO_MailInboxMessageAttachments' then
            return gail(MAIL_INBOX:GetOpenMailId(), rowControl.id, LINK_STYLE_DEFAULT)
        elseif name == 'ZO_MailSendAttachments' then
            return gmqal(rowControl.id, LINK_STYLE_DEFAULT)
        elseif name == "ZO_MailInboxMessageAttachments" then
            return nil
        elseif name == "ZO_TradingHousePostedItemsListContents" then
            return gthlil(dataEntryData.slotIndex)
        elseif name == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
            if rowControl.bagId and rowControl.slotIndex then
                return gil(rowControl.bagId, rowControl.slotIndex)
            end

        --Other addons
        elseif MasterMerchant and rowControl.GetText and strfind(name, "MasterMerchant", 1, true) ~= nil then
            parentCtrl = parentCtrl or (rowControl.GetParent and rowControl:GetParent())
            local mocGPGP = parentCtrl:GetParent()
            if mocGPGP then
                name = mocGPGP:GetName()
                if masterMerchantCtrlNames[name] then
                    return rowControl:GetText()
                end
            end
        --Dolgubons Lazy Set Crafter
        elseif name == 'DolgubonSetCrafterWindowMaterialListListContents' then
            return rowControl.data[1].Name
        end
    end

    return itemLink
end

local function getMouseoverLink()
	local itemLink = getItemLinkFromControl(moc())
    return itemLink
end

local function getLastItemLink(tooltipControl)
	local itemLink
    if tooltipControl == popupTooltip then
        itemLink = lastTooltipItemLink		-- this gets set on the prehook of PopupTooltip:SetLink
    elseif tooltipControl == itemTooltip or tooltipControl == infoTooltip then
        itemLink = getMouseoverLink()
        lastTooltipItemLink = itemLink
	end
	return itemLink
end

local function checkTraitsNeededGiven(setData)
    local setType = setData.setType
    return (setType ~= nil and setData.traitsNeeded ~= nil and setType == LIBSETS_SETTYPE_CRAFTED and true) or false
end

local function tableContentsAreAllTheSame(tabToCheck)
    local entriesChecked = {}
    for _, entry in pairs(tabToCheck) do
        entriesChecked[entry] = true
    end
    if NonContiguousCount(entriesChecked) == 1 then
        --All the same
        return true
    end
    return false
end

local function condenseTable(tabToCondense)
    if tableContentsAreAllTheSame(tabToCondense) then
        local retTab
        for k, v in pairs(tabToCondense) do
            retTab = { [k]=v }
            return retTab
        end
    end
    return tabToCondense
end

------------------------------------------------------------------------------------------------------------------------
local function buildSetNeededTraitsInfo(setData)
    if not checkTraitsNeededGiven(setData) then return end
    local traitsNeeded = tos(setData.traitsNeeded)
    if not traitsNeeded then return end
    return tos(traitsNeeded)
end

local function addNonVeteranUndauntedChestName(setType, undauntedChestId)
    if not setType or not undauntedChestId or undauntedChestId == "" or undauntedChestId <= 0 then return "" end
    if setType == LIBSETS_SETTYPE_MONSTER then
        local undauntedChestName = undauntedChestIdNames[undauntedChestId]
        local undauntedChestTextureAndName
        if tooltipTextures == true then
            undauntedChestTextureAndName = zoitfns(undauntedChestTexture, 24, 24, undauntedChestName, nil)
        else
            undauntedChestTextureAndName = undauntedChestName
        end
        if not undauntedChestTextureAndName or undauntedChestTextureAndName == "" then return "" end
        return " (" .. undauntedChestTextureAndName .. ")"
    end
    return ""
end

local function getDungeonDifficultyStr(setData, itemLink)
    local veteranData = setData.veteran
    local setType = setData.setType
    if veteranData ~= nil then
        if type(veteranData) == "table" then
            local equipType = gilet(itemLink)
            if equipType then
                local isVeteran = veteranData[equipType]
                if isVeteran then
                    local veteranStr = monsterSetTypeToVeteranStr[setType] or setTypeToDropZoneLocalizationStr[setType]
                    return veteranStr, true
                else
                    local nonVeteranStr = monsterSetTypeToNoVeteranStr[setType] or setTypeToDropZoneLocalizationStr[setType]
                    if setData.undauntedChestId then
                        nonVeteranStr = nonVeteranStr .. addNonVeteranUndauntedChestName(setType, setData.undauntedChestId)
                    end
                    return nonVeteranStr, false
                end
            end
        else
            if not veteranData then
                local nonVeteranStr = monsterSetTypeToNoVeteranStr[setType] or setTypeToDropZoneLocalizationStr[setType]
                if setData.undauntedChestId then
                    nonVeteranStr = nonVeteranStr .. addNonVeteranUndauntedChestName(setType, setData.undauntedChestId)
                end
                return nonVeteranStr, false
            else
                local veteranStr = monsterSetTypeToVeteranStr[setType] or setTypeToDropZoneLocalizationStr[setType]
                return veteranStr, true
            end
        end
    end
    return setTypeToDropZoneLocalizationStr[setType], false
end

local function buildTextLinesFromTable(tableVar, prefixStr, alwaysNewLine, doSort)
    alwaysNewLine = alwaysNewLine or false
    doSort = doSort or false
    local retStrVar
    local numEntries = #tableVar
    if numEntries >= 1 then
        if doSort then tsort(tableVar) end
        for idx, tableEntryStr in ipairs(tableVar) do
            if tableEntryStr ~= "" then
                if idx == 1 then
                    retStrVar = tableEntryStr
                else
                    retStrVar = retStrVar .. tableEntryStr
                end
                if idx < numEntries then
                    if alwaysNewLine then
                        retStrVar = retStrVar .. "\n"
                    else
                        retStrVar = retStrVar .. ", "
                    end
                end
            end
        end
    end
    return (prefixStr ~= nil and prefixStr ~= "" and prefixStr .. retStrVar) or retStrVar
end


local function getSetDropMechanicInfo(setData)
    local dropMechanicTab = setData.dropMechanic
    if not dropMechanicTab then return end
    local setType = setData.setType
    local dropZoneIds = setData[LIBSETS_TABLEKEY_ZONEIDS]
    if not dropZoneIds then
        d("[LibSets]ERROR getSetDropMechanicInfo - dropZoneIds MISSING! setId: " ..tos(setData.setId))
        return
    end
    local dropMechanicNamesOfSet = setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES]
    local dropMechanicDropLocationNamesOfSet = setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES]
    dropZoneNames = {}
    dropMechanicNames = {}
    dropLocationNames = {}

    --Loop the drop zones
    for idx, zoneId in ipairs(dropZoneIds) do
        --Get the zone names
        local zoneName
        if zoneId >= 0 then
            zoneName = libSets_GetZoneName(zoneId)
            if zoneName == nil then
                if setType == LIBSETS_SETTYPE_BATTLEGROUND then
                    zoneName = battlegroundStr
                end
            end
            dropZoneNames[idx] = zoneName
        end

        --Get the drop mechanic at the zoneId
        local dropMechanicIdOfZone = dropMechanicTab[idx]
        if dropMechanicIdOfZone then

            --Add the drop mechanic name
            local dropMechanicNameOfZone
            if dropMechanicNamesOfSet == nil or dropMechanicNamesOfSet[idx] == nil or dropMechanicNamesOfSet[idx][clientLang] == nil then
                dropMechanicNameOfZone = getDropMechanicName(dropMechanicIdOfZone, clientLang)
--d(">1")
            else
                dropMechanicNameOfZone = dropMechanicNamesOfSet[idx][clientLang]
--d(">2")
            end
            if dropMechanicNameOfZone ~= nil then
--d(">dropMechanicNameOfZone: " ..tos(dropMechanicNameOfZone))
                if tooltipTextures == true then
                local dropMechanicTexture = dropMechanicIdToTexture[dropMechanicIdOfZone]
                    if dropMechanicTexture then
                        local dropMechanicNameIconStr = zoitfns(dropMechanicTexture, 24, 24, dropMechanicNameOfZone, nil)
                        dropMechanicNameOfZone = dropMechanicNameIconStr
                    end
                end
                dropMechanicNames[idx] = dropMechanicNameOfZone
            end

            --Add the drop mechanic drop location text (if given)
            if dropMechanicDropLocationNamesOfSet ~= nil and dropMechanicDropLocationNamesOfSet[idx] then
                local dropMechanicDropLocationNameOfZone = dropMechanicDropLocationNamesOfSet[idx][clientLang]
                if (dropMechanicDropLocationNameOfZone == nil or dropMechanicDropLocationNameOfZone == "") and fallbackLang ~= clientLang then
                    dropMechanicDropLocationNameOfZone = dropMechanicDropLocationNamesOfSet[idx][fallbackLang]
                end
                if dropMechanicDropLocationNameOfZone ~= nil then
                    dropLocationNames[idx] = dropMechanicDropLocationNameOfZone
                end
            end
        end
    end
end

local function buildSetDropMechanicInfo(setData, itemLink)
    if not dropZoneNames or not dropMechanicNames then return end
    local setDropZoneStr = buildTextLinesFromTable(dropZoneNames, nil, false, false)
    local setDropMechanicText
    local setDropLocationsText, isVeteranMonsterSet = getDungeonDifficultyStr(setData, itemLink)
    local setDropOverallTextsPerZone = {}

--d(">addDropLocation: " ..tos(addDropLocation) ..", addDropMechanic: " ..tos(addDropMechanic) ..", addBossName: " ..tos(addBossName))

    --Check if all zoneNames are the same
    -->Output string of the zones will be 1 zone and all drop mechanics and dropLocationNames afterwards then
    local allZonesTheSame = (not useCustomTooltip and tableContentsAreAllTheSame(dropZoneNames)) or false

--d(">>setDropLocationsText: " ..tos(setDropLocationsText) ..", isVeteranMonsterSet: " ..tos(isVeteranMonsterSet))
    --Default format <Zone Name> <Drop Mechanic texture><Drop Mechanic Name> (<Drop Mechanic Drop Location texture> '<Drop Mechanic Drop Location name>')
    --Check tables dropZoneNames, dropMechanicNames, dropLocationNames.
    ---Loop over dropZoneNames, get the drop mechanic name and the dropLocation and build a multi-line string (1 line for each zone) for the output
    local numDropZoneNames = #dropZoneNames
    local setDropOverallTextPerZone
    local bracketOpened = false
    local dropMechanicNamesAdded = {}
    local dropMechanicDropLocationNamesAdded = {}
    for idx, dropZoneName in ipairs(dropZoneNames) do
        if not allZonesTheSame then
            setDropOverallTextPerZone = nil
            bracketOpened = false
        end
        local dropMechanicName = dropMechanicNames[idx]
        local dropMechanicDropLocationName = dropLocationNames[idx]
--d(">>>Zone: " ..tos(dropZoneName) .. ", dropMechanicName: " ..tos(dropMechanicName) .. ", dropMechanicDropLocationName: " ..tos(dropMechanicDropLocationName))
        if addDropLocation then
            if allZonesTheSame == true then
                --Only add the zoneName once if all zones are the same
                if idx == 1 then
                    setDropOverallTextPerZone  = dropZoneName
                end
            else
                setDropOverallTextPerZone  = dropZoneName
            end
        end
        if addDropMechanic then
            if dropMechanicName and dropMechanicName ~= "" then
                if allZonesTheSame == true then
                    if not dropMechanicNamesAdded[dropMechanicName] then
                        dropMechanicNamesAdded[dropMechanicName] = true
                        if setDropOverallTextPerZone == nil then
                            setDropOverallTextPerZone = "(" .. dropMechanicName
                            bracketOpened = true
                        else
                            if idx == 1 then
                                setDropOverallTextPerZone = setDropOverallTextPerZone .. " (" .. dropMechanicName
                                bracketOpened = true
                            else
                                setDropOverallTextPerZone = setDropOverallTextPerZone .. "; " .. dropMechanicName
                            end
                        end
                    end
                else
                    if setDropOverallTextPerZone == nil then
                        setDropOverallTextPerZone = dropMechanicName
                    else
                        setDropOverallTextPerZone = setDropOverallTextPerZone .. " (" .. dropMechanicName
                        bracketOpened = true
                    end
                end
            end
        end
        if addBossName then
            if allZonesTheSame == true then
                if dropMechanicDropLocationName ~= nil and dropMechanicDropLocationName ~= "" then
                    if not dropMechanicDropLocationNamesAdded[dropMechanicDropLocationName] then
                        dropMechanicDropLocationNamesAdded[dropMechanicDropLocationName] = true
                        if setDropOverallTextPerZone == nil then
                            setDropOverallTextPerZone = "\'" .. dropMechanicDropLocationName .. "\'"
                        else
                            if addDropMechanic then
                                if not dropMechanicNamesAdded[dropMechanicName] then
                                    dropMechanicNamesAdded[dropMechanicName] = true
                                end
                                if idx == 1 then
                                    setDropOverallTextPerZone = setDropOverallTextPerZone .. ": \'" .. dropMechanicDropLocationName .. "\'"
                                else
                                    setDropOverallTextPerZone = setDropOverallTextPerZone .. ": \'" .. dropMechanicDropLocationName .. "\'"
                                end
                            else
                                if idx == 1 then
                                    setDropOverallTextPerZone = setDropOverallTextPerZone .. "(\'" .. dropMechanicDropLocationName .. "\'"
                                    bracketOpened = true
                                else
                                    setDropOverallTextPerZone = setDropOverallTextPerZone .. "; \'" .. dropMechanicDropLocationName .. "\'"
                                end
                            end
                        end
                    end
                end
            else
                if dropMechanicDropLocationName ~= nil and dropMechanicDropLocationName ~= "" then
                    if setDropOverallTextPerZone == nil then
                        setDropOverallTextPerZone = "\'" .. dropMechanicDropLocationName .. "\'"
                    else
                        if addDropMechanic then
                            setDropOverallTextPerZone = setDropOverallTextPerZone .. ": \'" .. dropMechanicDropLocationName .. "\'"
                        else
                            setDropOverallTextPerZone = setDropOverallTextPerZone .. " (\'" .. dropMechanicDropLocationName .. "\'"
                            bracketOpened = true
                        end
                    end
                end
            end
        end
--d(">idx: " ..tos(idx) ..", bracketOpened: " ..tos(bracketOpened) .. ", setDropOverallTextPerZone: " ..tos(setDropOverallTextPerZone))
        if bracketOpened and setDropOverallTextPerZone ~= nil then
            if allZonesTheSame == true then
                if idx == numDropZoneNames then
                    setDropOverallTextPerZone = setDropOverallTextPerZone .. ")"
                --else
                    --setDropOverallTextPerZone = setDropOverallTextPerZone .. ", "
                end
            else
                setDropOverallTextPerZone = setDropOverallTextPerZone .. ")"
            end
        end

        if not allZonesTheSame then
            --Do not add the same line again
            if not ZO_IsElementInNumericallyIndexedTable(setDropOverallTextsPerZone, setDropOverallTextPerZone) then
                --setDropOverallTextPerZone = ""
                table.insert(setDropOverallTextsPerZone, setDropOverallTextPerZone)
            end
        else
            --Only add 1 line
            if idx == numDropZoneNames then
--d(">>>adding 1 output line")
                table.insert(setDropOverallTextsPerZone, setDropOverallTextPerZone)
            end
        end
    end
--lib._setDropOverallTextsPerZone = setDropOverallTextsPerZone
    return setDropZoneStr, setDropMechanicText, setDropLocationsText, setDropOverallTextsPerZone
end

local function buildSetDLCInfo(setData)
    local DLCid = setData.dlcId
    if not DLCid then return end
    local dlcName = libSets_GetDLCName(DLCid)
    return dlcName
end

local function buildSetTypeInfo(setData)
    local setType = setData.setType
    if not setType then return end
    local setTypeName = libSets_GetSetTypeName(setType)
    local setTypeTexture
    if tooltipTextures == true then
        if setData.isVeteran ~= nil then
            setTypeTexture = vetDungTexture
        else
            setTypeTexture = setTypeToTexture[setType]
        end
    end
    return setTypeName, setTypeTexture
end

local function addTooltipLine(tooltipControl, setData, itemLink)
    if not setData then return end
--d("addTooltipLine")
    --local isPopupTooltip = tooltipControl == popupTooltip or false
    --local isInformationTooltip = tooltipControl == infoTooltip or false
    --local isItemTooltip = tooltipControl == itemTooltip or false
    --local isComparativeTooltip = (tooltipControl == comparativeTooltip1 or tooltipControl == comparativeTooltip2) or false

    local setInfoText
    local setInfoTextWasCreated = false
    local function addSetInfoText(textToAdd)
        setInfoTextWasCreated = (setInfoText ~= nil and setInfoText ~= "") or false
        if textToAdd ~= nil and textToAdd ~= "" then
            --Add setInfoText
            setInfoText = (setInfoTextWasCreated and (setInfoText .. "\n" .. textToAdd)) or textToAdd
            setInfoTextWasCreated = true
        end
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
    --  ["dropMechanicLocationNames"] = {
    --      [1] = {
    --        ["en"] = "DropMechanicMonsterNameEN",
    --          ["de"] = "DropMechanicMonsterNameDE",
    --          ["fr"] = "DropMechanicMonsterNameFR",
    --          [...] = "...",
    --      },
    --      [2] = nil, --as it got no monster or other dropMechanicLocation name,
    --  },
    --}
    local setTypeText, setTypeTexture
    local setNeededTraitsText
    local setDropZoneStr
    local setDropMechanicText
    local setDropLocationsText
    local setDropOverallTextsPerZone
    local setDLCText
    --dropZoneNames, dropMechanicNames, dropLocationNames

    --[[
        setTypePlaceholder =        placeholder == "<<1>>"
        dropMechanicPlaceholder =   placeholder == "<<2>>"
        dropZonesPlaceholder =      placeholder == "<<3>>"
        bossNamePlaceholder =       placeholder == "<<4>>"
        neededTraitsPlaceholder =   placeholder == "<<5>>"
        dlcNamePlaceHolder =        placeholder == "<<6>>"
    ]]

--d(string.format("<<1>> %s, <<2>> %s, <<3>> %s, <<4>> %s, <<5>> %s, <<6>> %s",
--        tos(setTypePlaceholder), tos(dropMechanicPlaceholder), tos(dropZonesPlaceholder), tos(bossNamePlaceholder), tos(neededTraitsPlaceholder), tos(dlcNamePlaceHolder)))

    if (useCustomTooltip and setTypePlaceholder) or (not useCustomTooltip and addSetType) then
        setTypeText, setTypeTexture = buildSetTypeInfo(setData)
--d(">setTypeText: " ..tos(setTypeText))
    end
    if (useCustomTooltip and neededTraitsPlaceholder) or (not useCustomTooltip and addNeededTraits) then
        setNeededTraitsText = buildSetNeededTraitsInfo(setData)
--d(">setNeededTraitsText: " ..tos(setNeededTraitsText))
    end
    if (useCustomTooltip and dlcNamePlaceHolder) or (not useCustomTooltip and addDLC) then
        setDLCText = buildSetDLCInfo(setData, useCustomTooltip)
--d(">setDLCText: " ..tos(setDLCText))
    end

    local runDropMechanic = (useCustomTooltip and (dropMechanicPlaceholder or bossNamePlaceholder or dropZonesPlaceholder))
                            or (not useCustomTooltip and (addDropMechanic or addBossName or addDropLocation))
    if runDropMechanic then
        --dropZoneNames, dropMechanicNames, dropLocationNames
        getSetDropMechanicInfo(setData)

        if useCustomTooltip then
            --All zoneNames are the same = Condense them to 1, else keep them as same dropZones could have diffeferent dropMechanics and dropLocations and the order needs to be kept!
            local dropZoneNamesNew = condenseTable(dropZoneNames)
            dropZoneNames = dropZoneNamesNew
            local dropMechanicNamesNew = condenseTable(dropMechanicNames)
            dropMechanicNames = dropMechanicNamesNew
            local dropLocationNamesNew = condenseTable(dropLocationNames)
            dropLocationNames = dropLocationNamesNew

            --Build , separated texts of dropZones, dropMechanics, dropLocationNames
            setDropZoneStr =        buildTextLinesFromTable(dropZoneNames,      nil, false, false)
            setDropMechanicText =   buildTextLinesFromTable(dropMechanicNames,  nil, false, false)
            setDropLocationsText =  buildTextLinesFromTable(dropLocationNames,  nil, false, false)
        else
            setDropZoneStr, setDropMechanicText, setDropLocationsText, setDropOverallTextsPerZone = buildSetDropMechanicInfo(setData, itemLink)
        end
--d(">setDropZoneStr: " ..tos(setDropZoneStr) .. ", setDropMechanicText: " ..tos(setDropMechanicText) .. ", setDropLocationsText: " ..tos(setDropLocationsText).. ", setDropOverallTextsPerZone: " ..tos(setDropOverallTextsPerZone))
    end

    --Remove duplicate SetType and SetDropLocation texts (e.g. "Dungeon")
    if setDropLocationsText ~= nil and setDropLocationsText ~= "" then
        if setTypeText ~= nil and setTypeText ~= "" then
            if setTypeText == setDropLocationsText then setDropLocationsText = "" end
        end
    end

    --d(">useCustomTooltip: " ..tos(useCustomTooltip))

    --Use custom defined string? -> Build output string for the tooltip, based on chosen LAM settings
    if useCustomTooltip == true then
        --Check which placeholder is used and pass in the texts
        if not setTypePlaceholder then
            setTypeText = ""
            setTypeTexture = ""
            --d(">1")
        else
            if tooltipTextures == true and setTypeTexture ~= nil and setTypeTexture ~= "" then
                setTypeText = zoitf(setTypeTexture, 24, 24, setTypeText, nil)
            end
        end
        if not neededTraitsPlaceholder then
            setNeededTraitsText = ""
--d(">2")
        end
        if not dlcNamePlaceHolder then
            setDLCText = ""
--d(">3")
        end
        if not dropZonesPlaceholder then
            setDropZoneStr = ""
--d(">4")
        end
        if not dropMechanicPlaceholder then
            setDropMechanicText = ""
--d(">5")
        end
        if not bossNamePlaceholder then
            setDropLocationsText = ""
--d(">6")
        end
        --[[
        --Custom tooltip placeholders
            <<1>>   Set type
            <<2>>   Drop mechanics
            <<3>>   Drop zones
            <<4>>   Boss/Dropped by names
            <<5>>   Number of needed traits researched
            <<6>>   Chapter/DLC name set was introduced with",
        ]]
        --replace special characters like <br> with \n
        local patternNew = strgsub(lib.svData.useCustomTooltipPattern, "<br>", "\n")
        setInfoText = zostrfor(patternNew,
                setTypeText,
                setDropMechanicText,
                setDropZoneStr,
                setDropLocationsText,
                setNeededTraitsText,
                setDLCText
        )

    else
        --Use default output tooltip:
        if addSetType then
            if tooltipTextures == true then
                setInfoText = zoitf(setTypeTexture, 24, 24, setTypeText, nil)
            else
                setInfoText = setTypeText
            end
        end
        if setDropLocationsText and setDropLocationsText ~= "" then
            if setInfoText ~= nil then
                setInfoText = setInfoText .. " " .. setDropLocationsText
            else
                setInfoText = setDropLocationsText
            end
        end
        if addNeededTraits and setData.setType and setData.setType == LIBSETS_SETTYPE_CRAFTED then
            if addSetType then
                if setInfoText ~= nil then
                    setInfoText = setInfoText .. " (" .. setNeededTraitsText .. ")"
                end
            else
                if setInfoText ~= nil then
                    setInfoText = setInfoText .. neededTraitsStr .. ": " .. setNeededTraitsText
                else
                    setInfoText = neededTraitsStr .. ": " .. setNeededTraitsText
                end
            end
        end
        if runDropMechanic then
            local setDropMechanicDropLocationsText = buildTextLinesFromTable(setDropOverallTextsPerZone, nil, true, false)
            if setDropMechanicDropLocationsText and setDropMechanicDropLocationsText ~= "" then
                local prefix = ""
                if addBossName and not addDropLocation and not addDropMechanic then
                    prefix = droppedByStr .. ": "
                elseif not addBossName and not addDropLocation and addDropMechanic then
                    prefix = dropMechanicStr .. ": "
                elseif not addBossName and addDropLocation and not addDropMechanic then
                    prefix = dropLocationZonesStr .. ": "
                end
                addSetInfoText(prefix .. setDropMechanicDropLocationsText)
            end
        end
        if addDLC then
            addSetInfoText(setDLCText)
        end
    end

--d(">>setInfoText: " ..tos(setInfoText))

   --[[
    lib._tooltipData = {
        setTypeText = setTypeText,
        setTypeTexture = setTypeTexture,
        setNeededTraitsText = setNeededTraitsText,
        setDropZoneStr = setDropZoneStr,
        setDropMechanicText = setDropMechanicText,
        setDropLocationsText = setDropLocationsText,
        setDLCText = setDLCText,
        dropZoneNames = dropZoneNames,
        dropMechanicNames = dropMechanicNames,
        dropLocationNames = dropLocationNames,
        setData = setData,
        setDropOverallTextsPerZone = setDropOverallTextsPerZone,
        --
        setInfoText = setInfoText,
    }
    ]]

    --Output of the tooltip line at the bottom
    if setInfoText == nil or setInfoText == "" then return end
    if tooltipControl.AddVerticalPadding then
        tooltipControl:AddVerticalPadding(15)
    end
    ZO_Tooltip_AddDivider(tooltipControl)
    tooltipControl:AddLine(setInfoText)
end

local function tooltipItemCheck(tooltipControl, tooltipData)
    --Get the item
    local itemLink = getLastItemLink(tooltipControl)
    if not itemLink or itemLink == "" then return false, nil end
    --Check if tooltip shows a set item
    local isSet, setId = isTooltipOfSetItem(itemLink, tooltipData)
    return isSet, setId, itemLink
end


------------------------------------------------------------------------------------------------------------------------
-- SETTINGS MENU
------------------------------------------------------------------------------------------------------------------------
local function loadLAMSettingsMenu()
    if not lam then return end

    local panelData = {
        type 				= 'panel',
        name 				= MAJOR,
        displayName 		= MAJOR,
        author 				= "Baertram",
        version 			= MINOR,
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand 		= "/libsetss",
        website             = "https://www.esoui.com/downloads/info2241-LibSets.html",
        feedback            = "https://www.esoui.com/portal.php?id=136&a=bugreport",
        donation            = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131",
    }
    local LAMPanelName = MAJOR .. "_LAM"
    --The LibAddonMenu2.0 settings panel reference variable
    local LAMsettingsPanel = lam:RegisterAddonPanel(LAMPanelName, panelData)
    lib.LAMsettingsPanel = LAMsettingsPanel

    local settings = lib.svData
    local defaultSettings                         = lib.defaultSV
    local preventLAMTooltipEditSetFuncEndlessLoop = false

    local optionsTable                            =
    {
        {
            type =      "checkbox",
            name =      localization.modifyTooltip,
            tooltip =   localization.modifyTooltip,
            getFunc =   function() return settings.modifyTooltips end,
            setFunc =   function(value)
                lib.svData.modifyTooltips = value
                useCustomTooltip = isCustomTooltipEnabled()
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.modifyTooltips,
            disabled =  function() return false end,
            requiresReload = true,
            width =     "full",
        },

        ----------------------------------------------------------------------------------------------------------------
        {
            type =      "checkbox",
            name =      localization.tooltipTextures,
            tooltip =   localization.tooltipTextures_TT,
            getFunc =   function() return settings.tooltipModifications.tooltipTextures end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.tooltipTextures = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.tooltipTextures,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },

        ----------------------------------------------------------------------------------------------------------------
        --- Default tooltip
        {
            type = "description",
            title = localization.defaultTooltipPattern,
            text  = localization.defaultTooltipPattern_TT
        },
        {
            type =      "checkbox",
            name =      localization.setType,
            tooltip =   localization.setType,
            getFunc =   function() return settings.tooltipModifications.addSetType end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addSetType = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addSetType,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },
        {
            type =      "checkbox",
            name =      localization.dropZones,
            tooltip =   localization.dropZones,
            getFunc =   function() return settings.tooltipModifications.addDropLocation end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addDropLocation = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addDropLocation,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },
        {
            type =      "checkbox",
            name =      localization.dropMechanic,
            tooltip =   localization.dropMechanic,
            getFunc =   function() return settings.tooltipModifications.addDropMechanic end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addDropMechanic = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addDropMechanic,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },
        {
            type =      "checkbox",
            name =      localization.droppedBy,
            tooltip =   localization.droppedBy .. "/" .. localization.boss .. "/" .. GetString(SI_CHARACTER_SELECT_LOCATION_LABEL),
            getFunc =   function() return settings.tooltipModifications.addBossName end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addBossName = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addBossName,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },
        {
            type =      "checkbox",
            name =      localization.neededTraits,
            tooltip =   localization.neededTraits,
            getFunc =   function() return settings.tooltipModifications.addNeededTraits end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addNeededTraits = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addNeededTraits,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },
        {
            type =      "checkbox",
            name =      localization.dlc,
            tooltip =   localization.dlc,
            getFunc =   function() return settings.tooltipModifications.addDLC end,
            setFunc =   function(value)
                lib.svData.tooltipModifications.addDLC = value
                isLibSetsTooltipEnabled()
            end,
            default =   defaultSettings.tooltipModifications.addDLC,
            disabled =  function() return not settings.modifyTooltips or isCustomTooltipEnabled() end,
            width =     "full",
        },

        ----------------------------------------------------------------------------------------------------------------
        --- Custom tooltip
        {
            type  = "description",
            title = localization.customTooltipPattern,
            text  = localization.customTooltipPattern_TT
        },
        {
            type = "editbox",
            name = localization.customTooltipPattern,
            tooltip = localization.customTooltipPattern,
            getFunc = function() return settings.useCustomTooltipPattern end,
            setFunc = function(value)
                if not preventLAMTooltipEditSetFuncEndlessLoop then
                    useCustomTooltip = isCustomTooltipEnabled(value)
                    if not useCustomTooltip then
                        value = ""
                        settings.useCustomTooltipPattern = value
                        if LibSets_LAM_EditBox_CustomTooltipPattern ~= nil then
                            preventLAMTooltipEditSetFuncEndlessLoop = true
                            LibSets_LAM_EditBox_CustomTooltipPattern.editbox:SetText(value)
                            preventLAMTooltipEditSetFuncEndlessLoop = false
                        end
                    else
                        settings.useCustomTooltipPattern = value
                    end
                    isLibSetsTooltipEnabled()
                end
            end,
            default = defaultSettings.useCustomTooltipPattern,
            reference = "LibSets_LAM_EditBox_CustomTooltipPattern",
            --requiresReload = true,
        }
    }
    lam:RegisterOptionControls(LAMPanelName, optionsTable)
end


------------------------------------------------------------------------------------------------------------------------
-- HOOKs
------------------------------------------------------------------------------------------------------------------------
--[[
local function tooltipOnHide(tooltipControl, tooltipData)
    --todo
end
]]

local function tooltipOnAddGameData(tooltipControl, tooltipData)
    --Add line below the currently "last" line (mythic or stolen info at date 2022-02-12)
    if tooltipData == tooltipGameDataEntryToAddAfter then
--d("anyTooltipInfoToAdd: " ..tos(anyTooltipInfoToAdd) .. ", useCustomTooltip: " ..tos(useCustomTooltip))
        if not anyTooltipInfoToAdd then return end

        local isSet, setId, itemLink = tooltipItemCheck(tooltipControl, tooltipData)
        if not isSet then return end
        local setData = libSets_GetSetInfo(setId, true, clientLang) --without itemIds, and names only in client laguage

        addTooltipLine(tooltipControl, setData, itemLink)
    end
end


------------------------------------------------------------------------------------------------------------------------
-- EVENTs
------------------------------------------------------------------------------------------------------------------------
local function onPlayerActivatedTooltips()
    EM:UnregisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED) --only load once
    if not lam then return end

    clientLang = clientLang or lib.clientLang
    localization = localization or lib.localization[clientLang]

    --Get the settngs for the tooltips
    tooltipSV = getLibSetsTooltipSavedVariables()
    if not lib.svData or not tooltipSV then return end

    --Get current enabled state of the tooltip settings
    useCustomTooltip = isCustomTooltipEnabled()
--d(">useCustomTooltip: " ..tos(useCustomTooltip))
    isLibSetsTooltipEnabled()

    --Build the settings menu for the tooltip
    loadLAMSettingsMenu()


    --hook into the tooltip types?
    if lib.svData.modifyTooltips == true then
--d("Hooks loaded")
        ZO_PreHookHandler(popupTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(popupTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHookHandler(itemTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(itemTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) lastTooltipItemLink = itemLink end)
    end
end

local function loadTooltipHooks()
    lam = lib.libAddonMenu
    if not lam then return end

    EM:RegisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED, onPlayerActivatedTooltips)
end
lib.loadTooltipHooks = loadTooltipHooks
