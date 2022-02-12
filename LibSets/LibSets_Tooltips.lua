--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.versio

local libPrefix = "["..MAJOR.."]"

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

local libSets_GetSetInfo = lib.GetSetInfo
local libSets_GetZoneName = lib.GetZoneName
local libSets_GetDropMechanic = lib.GetDropMechanic

--Add set information like the drop location to the tooltips

--Possible tooltips controls
--ZO_PopupToolTip
--ZO_ItemToolTip
--local tooltipCtrls = {
--    PopupTooltip,
--    InformationTooltip,
--    ComparativeTooltip1,
--    ComparativeTooltip2,
--}

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
local addDropLocation
local lastTooltipItemLink

local addTypeDropLocation = "dropLocation"

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
        elseif MasterMerchant and rowControl.GetText and string.find(name, "MasterMerchant", 1, true) ~= nil then
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
    if tooltipControl == PopupTooltip then
        itemLink = lastTooltipItemLink		-- this gets set on the prehook of PopupTooltip:SetLink
    elseif tooltipControl == ItemTooltip or tooltipControl == InformationTooltip then
        itemLink = getMouseoverLink()
        lastTooltipItemLink = itemLink
	end
	return itemLink
end


local function buildTextLinesFromTable(tableVar, prefixStr, doSort)
    doSort = doSort or false
    local retStrVar
    local numEntries = #tableVar
    if numEntries >= 1 then
        if doSort then tsort(tableVar) end
        for idx, tableEntryStr in ipairs(tableVar) do
            retStrVar = tableEntryStr
            if idx < numEntries then
                retStrVar = retStrVar .. "\n"
            end
        end
    end
    return (prefixStr ~= nil and prefixStr ~= "" and prefixStr .. retStrVar) or retStrVar
end

local function buildSetDropLocationInfo(setData)
    local dropZonesStr
    --Got drop zones of the item?
    local alreadyAddedZoneIds = {}
    local setZonsIds = setData.zoneIds
    local dropZoneNames = {}
    if setZonsIds then
        for _, zoneId in ipairs(setZonsIds) do
            if zoneId ~= -1 and not alreadyAddedZoneIds[zoneId] then
                local zoneName = libSets_GetZoneName(zoneId)
                if zoneName == nil then
                    if setData.setType == LIBSETS_SETTYPE_BATTLEGROUND then
                        zoneName = GetString(SI_LEADERBOARDTYPE4) --Battleground
                    end
                end
                tins(dropZoneNames, zoneName)
                alreadyAddedZoneIds[zoneId] = true
            end
        end
        dropZonesStr = buildTextLinesFromTable(dropZoneNames, libPrefix .. "Drop locations:\n", true)
    end
    return dropZonesStr
end

local function addTooltipLine(tooltipControl, setId, addType)
    if not setId then return end
    local isPopupTooltip = tooltipControl == PopupTooltip or false
    local isInformationTooltip = tooltipControl == InformationTooltip or false
    local isItemTooltip = tooltipControl == ItemTooltip or false
    local isComparativeTooltip = (tooltipControl == ComparativeTooltip1 or tooltipControl == ComparativeTooltip2) or false

    local setInfoText

    local setData = libSets_GetSetInfo(setId)
    if not setData then return end
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

    --Add drop locaiton to tooltip?
    if addType == addTypeDropLocation then
        --Get the set's drop location name as string
        local setDropLocationsText = buildSetDropLocationInfo(setData)
        if setDropLocationsText then
            --Add setInfoText
            setInfoText = setInfoText .. setDropLocationsText
        end
    end
    if not setInfoText or setInfoText == "" then return end
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
    if not tooltipSV then return end
    if addDropLocation == nil then addDropLocation = tooltipSV.addDropLocation end

    if addDropLocation then
        --Add line below the currently "last" line (mythic or stolen info)
        if tooltipData == TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN then
            local isSet, setId = tooltipItemCheck(tooltipControl, tooltipData)
            if not isSet then return end
            addTooltipLine(tooltipControl, setId, addTypeDropLocation)
        end
    end
end

local function onPlayerActivatedTooltips()
    EM:UnregisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED) --only load once
    --Get the settngs for the tooltips
    tooltipSV = getLibSetsTooltipSavedVariables()
    if not tooltipSV then return end

    --add line of set information like chosen in the LAM settings of LibSets
    -->Drop location
    addDropLocation = tooltipSV.addDropLocation
    if addDropLocation then

        hookTooltips = true
    end

    --hook into the tooltip types?
    if hookTooltips then
        ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(PopupTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', tooltipOnAddGameData)
        --ZO_PreHookHandler(ItemTooltip, 'OnHide', tooltipOnHide)

        ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) lastTooltipItemLink = itemLink end)
    end
end

local function loadTooltipHooks()
    EM:RegisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED, onPlayerActivatedTooltips)
end
lib.loadTooltipHooks = loadTooltipHooks
