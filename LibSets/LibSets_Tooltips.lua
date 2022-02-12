--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.versio

local libPrefix = "["..MAJOR.."]"
local placeHolder = ": "

local clientLang = lib.clientLang
local localization         =    lib.localization[clientLang]
local dropLocationZonesStr =    localization.dropZones
local dlcStr =                  localization.dlc
local droppedByStr =            localization.droppedBy
local setTypeStr =              localization.setType
local neededTraitsStr =         localization.neededTraits
local dropMechanicStr =         localization.dropMechanic
local battlegroundStr =         GetString(SI_LEADERBOARDTYPE4) --Battleground


--local ZOs variables
local EM = EVENT_MANAGER

local tos = tostring
local strgmatch = string.gmatch
local strlower = string.lower
--local strlen = string.len
local strfind = string.find
local strsub = string.sub
local strfor = string.format

local tins = table.insert
local trem = table.remove
local tsort = table.sort
local unp = unpack
local zocstrfor = ZO_CachedStrFormat

local gilsetinf = GetItemLinkSetInfo


--local library variables
local libSets_GetSetInfo =                  lib.GetSetInfo
local libSets_GetZoneName =                 lib.GetZoneName
--local libSets_GetDropMechanicName =         lib.GetDropMechanicName
local libSets_GetSetTypeName =              lib.GetSetTypeName
local libSets_GetDLCName =                  lib.GetDLCName

--The tooltip game data line after that the LibSets entries should be added
local tooltipGameDataEntryToAddAfter = TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN

--Add set information like the drop location to the tooltips

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
--local comparativeTooltip1 = tooltipCtrls["compa1"]
--local comparativeTooltip2 = tooltipCtrls["compa2"]


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
local hookTooltips = false
local tooltipSV
local addDLC
local addDropLocation
local addDropMechanic
local addBossName
local addSetType
local addNeededTraits


local lastTooltipItemLink

--Functions
local function getLibSetsTooltipSavedVariables()
    local sv = lib.svData
    if not sv or not sv.modifyTooltips then return nil end
    return sv.tooltipModifications
end

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
                return GetItemLink(IIfAclicked.bagId, IIfAclicked.slotIndex)
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
                return GetLootItemLink(dataEntryData.lootId, LINK_STYLE_BRACKETS)
            elseif rowControl.index and name == "ZO_InteractWindowRewardArea" then
                return GetQuestRewardItemLink(rowControl.index, LINK_STYLE_BRACKETS)
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
                return GetStoreItemLink(rowControl.index, LINK_STYLE_BRACKETS)

            elseif rowControl.slotType == SLOT_TYPE_STORE_BUYBACK then
                return GetBuybackItemLink(rowControl.index, LINK_STYLE_BRACKETS)
            end
        end
    end

    if bagId ~= nil and slotIndex ~= nil then
        itemLink = GetItemLink(bagId, slotIndex)
    end

    if itemLink == nil then
        if name == 'ZO_MailInboxMessageAttachments' then
            return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), rowControl.id, LINK_STYLE_DEFAULT)
        elseif name == 'ZO_MailSendAttachments' then
            return GetMailQueuedAttachmentLink(rowControl.id, LINK_STYLE_DEFAULT)
        elseif name == "ZO_MailInboxMessageAttachments" then
            return nil
        elseif name == "ZO_TradingHousePostedItemsListContents" then
            return GetTradingHouseListingItemLink(dataEntryData.slotIndex)
        elseif name == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
            if rowControl.bagId and rowControl.slotIndex then
                return GetItemLink(rowControl.bagId, rowControl.slotIndex)
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


local function buildTextLinesFromTable(tableVar, prefixStr, alwaysNewLine, doSort)
    alwaysNewLine = alwaysNewLine or false
    doSort = doSort or false
    local retStrVar
    local numEntries = #tableVar
    if numEntries >= 1 then
        if doSort then tsort(tableVar) end
        for idx, tableEntryStr in ipairs(tableVar) do
            retStrVar = tableEntryStr
            if idx < numEntries then
                if alwaysNewLine then
                    retStrVar = retStrVar .. "\n"
                else
                    retStrVar = retStrVar .. ", "
                end
            end
        end
    end
    return (prefixStr ~= nil and prefixStr ~= "" and prefixStr .. retStrVar) or retStrVar
end

local dropLocationZonesWithPlaceholder
local function buildSetDropLocationInfo(setData)
    local dropZonesStr
    --Got drop zones of the item?
    local alreadyAddedZoneIds = {}
    local setZonsIds = setData.zoneIds
    local setType = setData.setType
    local dropZoneNames = {}
    if setZonsIds then
        for _, zoneId in ipairs(setZonsIds) do
            if zoneId ~= -1 and not alreadyAddedZoneIds[zoneId] then
                local zoneName = libSets_GetZoneName(zoneId)
                if zoneName == nil then
                    if setType == LIBSETS_SETTYPE_BATTLEGROUND then
                        zoneName = battlegroundStr
                    end
                end
                tins(dropZoneNames, zoneName)
                alreadyAddedZoneIds[zoneId] = true
            end
        end
        dropLocationZonesStr = dropLocationZonesStr or localization.dropZones
        dropLocationZonesWithPlaceholder = dropLocationZonesWithPlaceholder or dropLocationZonesStr .. placeHolder
        dropZonesStr = buildTextLinesFromTable(dropZoneNames, dropLocationZonesWithPlaceholder, false, true)
    end
    return dropZonesStr
end

local neededTraitsStrWithPlaceholder
local function buildSetNeededTraitsInfo(setData)
    local traitsNeeded = tos(setData.traitsNeeded)
    if not traitsNeeded then return end
    neededTraitsStr = neededTraitsStr or localization.neededTraits
    neededTraitsStrWithPlaceholder = neededTraitsStrWithPlaceholder or neededTraitsStr .. placeHolder
    return neededTraitsStrWithPlaceholder .. traitsNeeded
end

local droppedByStrWithPlaceholder
local function buildSetDropBossInfo(setData)
    droppedByStr = droppedByStr or localization.droppedBy
    droppedByStrWithPlaceholder = droppedByStrWithPlaceholder or droppedByStr .. placeHolder

    local droppedByName = " Example bossname"

    return droppedByStrWithPlaceholder .. droppedByName
end

local dropMechanicStrWithPlaceholder
local function buildSetDropMechanicInfo(setData)
    local dropMechanicTab = setData.dropMechanic
    if not dropMechanicTab then return end

    local dropMechanicNamesStr
    local dropMechanicNames = {}
    local dropMechanicNamesOfSet = setData.dropMechanicNames
    if not dropMechanicNamesOfSet then return end

    local alreadyAddedDropMechanics = {}
    for dropMechanicId, dropMechanicNamesData in pairs(dropMechanicNamesOfSet) do
        if dropMechanicId ~= -1 and not alreadyAddedDropMechanics[dropMechanicId] then
            local dropMechanicName = dropMechanicNamesData[clientLang]
            if dropMechanicName and dropMechanicName ~= "" then
                tins(dropMechanicNames, dropMechanicName)
                alreadyAddedDropMechanics[dropMechanicId] = true
            end
        end
    end

    dropMechanicStr = dropMechanicStr or localization.dropMechanic
    dropMechanicStrWithPlaceholder = dropMechanicStrWithPlaceholder or dropMechanicStr .. placeHolder
    dropMechanicNamesStr = buildTextLinesFromTable(dropMechanicNames, dropMechanicStrWithPlaceholder, false, true)
    return dropMechanicNamesStr
end

local dlcStrWithPlaceholder
local function buildSetDLCInfo(setData)
    local DLCid = setData.dlcId
    if not DLCid then return end

    dlcStr = dlcStr or localization.dlc
    dlcStrWithPlaceholder = dlcStrWithPlaceholder or dlcStr .. placeHolder

    return dlcStrWithPlaceholder .. libSets_GetDLCName(DLCid)
end

local setTypeStrWithPlaceholder
local function buildSetTypeInfo(setData)
    local setType = setData.setType
    if not setType then return end

    setTypeStr = setTypeStr or localization.setType
    setTypeStrWithPlaceholder = setTypeStrWithPlaceholder or setTypeStr .. placeHolder

    return setTypeStrWithPlaceholder .. libSets_GetSetTypeName(setType)
end


local function addTooltipLine(tooltipControl, setData)
    if not setData then return end
    --local isPopupTooltip = tooltipControl == popupTooltip or false
    --local isInformationTooltip = tooltipControl == infoTooltip or false
    --local isItemTooltip = tooltipControl == itemTooltip or false
    --local isComparativeTooltip = (tooltipControl == comparativeTooltip1 or tooltipControl == comparativeTooltip2) or false

    local setInfoText
    local setInfoTextWasCreated = false
    local function addSetInfoText(textToAdd)
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
    --        ["en"] = "DropMechanicMonsterNameEN",
    --          ["de"] = "DropMechanicMonsterNameDE",
    --          ["fr"] = "DropMechanicMonsterNameFR",
    --      },
    --      [2] = {
    --        ["en"] = "DropMechanic...NameEN",
    --        ["de"] = "DropMechanic...NameDE",
    --        ["fr"] = "DropMechanic....NameFR",
    --      },
    --  },
    --}

    local setType = setData.setType


    if addSetType and setType then
        local setTypeText = buildSetTypeInfo(setData)
        addSetInfoText(setTypeText)
    end

    if addDLC then
        local setDLCText = buildSetDLCInfo(setData)
        addSetInfoText(setDLCText)
    end

    if addDropMechanic then
        local setDropMechanicText = buildSetDropMechanicInfo(setData)
        addSetInfoText(setDropMechanicText)
    end

    if addDropLocation then
        local setDropLocationsText = buildSetDropLocationInfo(setData)
        addSetInfoText(setDropLocationsText)
    end

    if addBossName then
        local setDropBossNameText = buildSetDropBossInfo(setData)
        addSetInfoText(setDropBossNameText)
    end

    if addNeededTraits then
        if setType and setData.traitsNeeded ~= nil and setType == LIBSETS_SETTYPE_CRAFTED then
            local setNeededTraitsText = buildSetNeededTraitsInfo(setData)
            addSetInfoText(setNeededTraitsText)
        end
    end


    --Output of the tooltip line at the bottom
    if not setInfoText or setInfoText == "" then return end
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
    return isTooltipOfSetItem(itemLink, tooltipData)
end

--[[
local function tooltipOnHide(tooltipControl, tooltipData)
    --todo
end
]]

local function tooltipOnAddGameData(tooltipControl, tooltipData)
    --Add line below the currently "last" line (mythic or stolen info at date 2022-02-12)
    if tooltipData == tooltipGameDataEntryToAddAfter then
        if not tooltipSV then return end
        if not addDropLocation then addDropLocation = tooltipSV.addDropLocation end
        if not addDropMechanic then addDropMechanic = tooltipSV.addDropMechanic end
        if not addDLC then addDLC = tooltipSV.addDLC end
        if not addBossName then addBossName = tooltipSV.addBossName end
        if not addSetType then addSetType = tooltipSV.addSetType end
        if not addNeededTraits then addNeededTraits = tooltipSV.addNeededTraits end

        local anyTooltipInfoToAdd = (addDropLocation == true or addDropMechanic == true or addDLC == true
                                    or addBossName == true or addSetType == true or addNeededTraits == true) or false
        if not anyTooltipInfoToAdd then return end

        local isSet, setId = tooltipItemCheck(tooltipControl, tooltipData)
        if not isSet then return end
        local setData = libSets_GetSetInfo(setId, true, clientLang) --without itemIds, and names only in client laguage

        addTooltipLine(tooltipControl, setData)
    end
end

local function onPlayerActivatedTooltips()
    EM:UnregisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED) --only load once

    clientLang = clientLang or lib.clientLang
    localization = localization or lib.localization[clientLang]

    --Get the settngs for the tooltips
    tooltipSV = getLibSetsTooltipSavedVariables()
    if not tooltipSV then return end

    --add line of set information like chosen in the LAM settings of LibSets
    -->Drop location
    addDropLocation =   tooltipSV.addDropLocation
    addDropMechanic =   tooltipSV.addDropMechanic
    addDLC =            tooltipSV.addDLC
    addBossName =       tooltipSV.addBossName
    addSetType =        tooltipSV.addSetType
    addNeededTraits =   tooltipSV.addNeededTraits

    if addDropLocation or addDropMechanic or addDLC or addBossName or addSetType or addNeededTraits then
        hookTooltips = true
    end

    --hook into the tooltip types?
    if hookTooltips then
        ZO_PreHookHandler(popupTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(popupTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHookHandler(itemTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(itemTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) lastTooltipItemLink = itemLink end)
    end
end

local function loadTooltipHooks()
    EM:RegisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED, onPlayerActivatedTooltips)
end
lib.loadTooltipHooks = loadTooltipHooks
