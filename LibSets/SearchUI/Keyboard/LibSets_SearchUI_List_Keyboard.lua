local lib = LibSets

local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

local tos = tostring
local tins = table.insert
local tcon = table.concat
local zif = zo_iconFormat

local clientLang = lib.clientLang
local fallbackLang = lib.fallbackLang
local isClientLangEqualToFallbackLang = clientLang == fallbackLang

--The search UI table
local searchUI = lib.SearchUI
local searchUIName = searchUI.name
local favoriteIconText = searchUI.favoriteIconText


--Library's local helpers
local preloadedSetNames = lib.setDataPreloaded[LIBSETS_TABLEKEY_SETNAMES]

--local libSets_IsNoESOSet = lib.IsNoESOSet
local libSets_GetSetBonuses = lib.GetSetBonuses
local buildSetTypeInfo = lib.buildSetTypeInfo
local buildSetDataText = lib.BuildSetDataText
--local libSets_GetSetInfo = lib.GetSetInfo
local libSets_GetSetFirstItemId = lib.GetSetFirstItemId
--local getDropMechanicTexture = lib.GetDropMechanicTexture
--local libSets_GetSpecialZoneNameById = lib.GetSpecialZoneNameById
local getArmorTypeTexture = lib.GetArmorTypeTexture
local getWeaponTypeTexture = lib.GetWeaponTypeTexture
local getEquipSlotTexture = lib.GetEquipSlotTexture


------------------------------------------------------------------------------------------------------------------------
--Local helper functions
------------------------------------------------------------------------------------------------------------------------
local function updateFavoriteColumn(rowControl, isFavorite)
    if not rowControl or isFavorite == nil then return end
    local data = rowControl.data
    if not data then return end

    if isFavorite == true then
        if data.isFavorite == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then return end
        rowControl.data.isFavorite = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
    else
        if data.isFavorite ~= LIBSETS_SET_ITEMID_TABLE_VALUE_OK then return end
        rowControl.data.isFavorite = 0
    end
    data = rowControl.data

    local favoriteColumn = rowControl:GetNamedChild("Favorite")
    if favoriteColumn == nil then return end
    favoriteColumn:SetText((isFavorite == true and favoriteIconText) or "")
end


------------------------------------------------------------------------------------------------------------------------
--Search results list for keyboard mode
------------------------------------------------------------------------------------------------------------------------
--- ZO_SortFilterList
LibSets_SearchUI_List = ZO_SortFilterList:Subclass()

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

function LibSets_SearchUI_List:New(listParentControl, parentObject)
	local listObject = ZO_SortFilterList.New(self, listParentControl)
    listObject._parentObject = parentObject --Points to e.g. LIBSETS_SEARCH_UI_KEYBOARD object (of class LibSets_SearchUI_Keyboard)
	listObject:Setup()
	return listObject
end

--Setup the scroll list
function LibSets_SearchUI_List:Setup( )
	--Scroll UI
	ZO_ScrollList_AddDataType(self.list, searchUI.scrollListDataTypeDefault, "LibSetsSearchUIRow", 30, function(control, data)
        self:SetupItemRow(control, data)
    end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

    self:SetEmptyText("\n"..GetString(SI_TRADINGHOUSESEARCHOUTCOME2) .. "\n") --No items found, which match your filters and text

	self.masterList = { }

    --Build the sortkeys depending on the settings
    --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
	--The sort function
    self.sortFunction = function( listEntry1, listEntry2 )
        if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
            or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
            or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
            return nil
        end
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder)
	end

    --Sort headers
	self.headers =                  self.control:GetNamedChild("Headers")
    self.headerName =               self.headers:GetNamedChild("Name")
    self.headerSetType =            self.headers:GetNamedChild("SetType")
	self.headerArmorOrWeaponType =  self.headers:GetNamedChild("ArmorOrWeaponType")
	self.headerEquipSlot =          self.headers:GetNamedChild("EquipSlot")
	self.headerDropLocations =      self.headers:GetNamedChild("DropLocations")
	self.headerSetId =              self.headers:GetNamedChild("SetId")

    --Build initial masterlist via self:BuildMasterList() --> Do not automatically here but only as the LibSets search UI opens first time!
    --self:RefreshData()
end

--[[
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:CommitScrollList( )
end
]]

--Get the data of the masterlist entries and add it to the list columns
function LibSets_SearchUI_List:SetupItemRow(control, data)
    --local clientLang = WL.clientLang or WL.fallbackSetLang
    --d(">>>      [LibSets_SearchUI_List:SetupItemRow] " ..tos(data.names[clientLang]))
    control.data = data

    local lastColumn

    local favoriteColumn = control:GetNamedChild("Favorite")
    favoriteColumn.normalColor = ZO_DEFAULT_TEXT
    favoriteColumn:ClearAnchors()
    favoriteColumn:SetAnchor(LEFT, control, nil, 0, 0)
    local favoriteIconColumnText = ""
    if data.isFavorite == LIBSETS_SET_ITEMID_TABLE_VALUE_OK then
        favoriteIconColumnText = favoriteIconText
    end
    favoriteColumn:SetText(favoriteIconColumnText)
    favoriteColumn:SetHidden(false)


    local nameColumn = control:GetNamedChild("Name")
    nameColumn.normalColor = ZO_DEFAULT_TEXT
    nameColumn:ClearAnchors()
    nameColumn:SetAnchor(LEFT, favoriteColumn, RIGHT, 0, 0)
    nameColumn:SetText(data.name)
    nameColumn:SetHidden(false)

    local setTypeColumn = control:GetNamedChild("SetType")
    setTypeColumn:ClearAnchors()
    setTypeColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
    setTypeColumn:SetText(data.setTypeTexture or data.setType or "")
    setTypeColumn:SetHidden(false)

    local armorOrWeaponTypeColumn = control:GetNamedChild("ArmorOrWeaponType")
    armorOrWeaponTypeColumn:ClearAnchors()
    armorOrWeaponTypeColumn:SetAnchor(LEFT, setTypeColumn, RIGHT, 0, 0)
    armorOrWeaponTypeColumn:SetText(data.armorOrWeaponTypeTexture or "")
    armorOrWeaponTypeColumn:SetHidden(false)

    local slotColumn = control:GetNamedChild("EquipSlot")
    slotColumn:ClearAnchors()
    slotColumn:SetAnchor(LEFT, armorOrWeaponTypeColumn, RIGHT, 0, 0)
    slotColumn:SetText(data.equipSlotTexture or data.equipSlotText or "")
    slotColumn:SetHidden(false)

    local dropLocationsColumn = control:GetNamedChild("DropLocations")
    dropLocationsColumn:ClearAnchors()
    dropLocationsColumn:SetAnchor(LEFT, slotColumn, RIGHT, 0, 0)
    dropLocationsColumn:SetText(data.dropLocationText or "")
    dropLocationsColumn:SetHidden(false)

    local setIdColumn = control:GetNamedChild("SetId")
    setIdColumn:ClearAnchors()
    setIdColumn:SetAnchor(LEFT, dropLocationsColumn, RIGHT, 0, 0)
    setIdColumn:SetText(data.setId or "")
    setIdColumn:SetHidden(false)

    --Anchor the last column's right edge to the right edge of the row
    lastColumn = setIdColumn
    lastColumn:SetAnchor(RIGHT, control, RIGHT, -10, 0)

    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end

--Create a row at the resultslist, and respect the search filters (multiselect dropdowns of armor, weapon, equipment type,
--enchantment, etc.)
function LibSets_SearchUI_List:CreateEntryForSet(setId, setData)
    local parentObject = self._parentObject -- Get the SearchUI object
    --SavedVariables check
    local settings = lib.svData
    local setSearchShowSetNamesInEnglishToo = settings.setSearchShowSetNamesInEnglishToo

    local itemId
    --The name column
    local nameColumnValue, nameColumnValueClean
    if not isClientLangEqualToFallbackLang then
--[[
    if setData.setNames[fallbackLang] == nil then
    d(">setName['en'] is missing-setId: " .. tos(setData.setId) .. " - "..tos(setData.setNames[clientLang]))
    end
]]
        nameColumnValueClean = setData.setNames[clientLang] or setData.setNames[fallbackLang]
    else
        nameColumnValueClean = setData.setNames[clientLang]
    end
    --Show English set names too?
    if setSearchShowSetNamesInEnglishToo == true and not isClientLangEqualToFallbackLang then
        local setNameFallback = setData.setNames[fallbackLang] or preloadedSetNames[fallbackLang]
        if setNameFallback ~= nil then
            nameColumnValueClean = nameColumnValueClean .. " / " .. setNameFallback
        end
    end
    nameColumnValue = nameColumnValueClean

    --Favorite
    local isFavorite = parentObject:IsSetIdInFavorites(setId)
    local isFavoriteColumnText = (isFavorite == true and LIBSETS_SET_ITEMID_TABLE_VALUE_OK) or 0

    --The set type
    local setTypeName, setTypeTexture = buildSetTypeInfo(setData, true)

    --Get an itemId for the itemLink
    if self.isAnyItemIdRelevantFilterActive == true then
        --Get a matching (to the multiselect dropdown filters) itemId
        local itemIds = parentObject:GetItemIdsForSetIdRespectingFilters(setId, true) --only 1 itemId
        if itemIds == nil then return end
        --Use the first itemId found
        itemId = itemIds[1]
    else
        --Get "any" itemId (the first found of the setId)
        itemId = libSets_GetSetFirstItemId(setId, nil)
    end

    if itemId == nil then return nil end
    local itemLink = lib.buildItemLink(itemId, 370) -- Always use the legendary quality for the sets list

    --Prepare the itemtypes, and their textures
    local armorOrWeaponTypeTexture, armorOrWeaponTypeTextWithTexture, armorOrWeaponTypeText, equipSlotTexture, equipSlotTextWithTexture, equipSlotText
    local equipType = GetItemLinkEquipType(itemLink)
    equipSlotTexture, equipSlotTextWithTexture, equipSlotText = getEquipSlotTexture(equipType)
    local itemType = GetItemLinkItemType(itemLink)
    local armorOrWeaponType
    --Jewelry got no armor or weaapon type -> And thus no texture there
    if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
        armorOrWeaponType = ITEMTYPE_NONE
        armorOrWeaponTypeTexture, armorOrWeaponTypeTextWithTexture, armorOrWeaponTypeText = getEquipSlotTexture(equipType)
    else
        if itemType == ITEMTYPE_ARMOR then
            armorOrWeaponType = GetItemLinkArmorType(itemLink)
            armorOrWeaponTypeTexture, armorOrWeaponTypeTextWithTexture, armorOrWeaponTypeText = getArmorTypeTexture(armorOrWeaponType)
        elseif itemType == ITEMTYPE_WEAPON then
            armorOrWeaponType = GetItemLinkWeaponType(itemLink)
            --Shield?
            if armorOrWeaponType == WEAPONTYPE_SHIELD and equipType == EQUIP_TYPE_OFF_HAND then
                armorOrWeaponTypeTexture, armorOrWeaponTypeTextWithTexture, armorOrWeaponTypeText = getWeaponTypeTexture(armorOrWeaponType)
                equipSlotTexture = armorOrWeaponTypeTexture
                equipSlotTextWithTexture = armorOrWeaponTypeTextWithTexture
                equipSlotText = armorOrWeaponTypeText
            else
                armorOrWeaponTypeTexture, armorOrWeaponTypeTextWithTexture, armorOrWeaponTypeText = getWeaponTypeTexture(armorOrWeaponType)
            end
        end
    end

    --Get the bonuses info
    local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
    local bonuses = (numBonuses == 0 and {}) or setData.bonuses
    setData.numBonuses = numBonuses
    if numBonuses > 0 and (bonuses == nil or type(bonuses) == "number") then
        -- Lazy initialization of set bonus data
        setData.bonuses = libSets_GetSetBonuses(itemLink, numBonuses)
        bonuses = setData.bonuses
    end

    --[[
        --Get the drop location(s) of the set via LibSets
        -->The base info for that: DropZones, mechanics and location names are already loaded into setData once -> See function updateSetsInfoWithDropLocationsAndNames in LibSets_SearchUI_Shared.lua -> ShowUI()
    ]]
    local setDataText, setInfoParts, setDataTextClean = buildSetDataText(setData, itemLink, false)
    --[[
        Table setInfoParts contains subtables with keys
        "setType"
        "DLC" -- OPTIONAL
        "crafted" -- OPTIONAL
        "reconstruction" -- OPTIONAL
        "dropMechanics" -- OPTIONAL
        "dropZones" -- OPTIONAL
        "dropLocations" -- OPTIONAL
        "overallTextsPerZone" -- OPTIONAL

        Each providing a table with:
            {
                enabled = boolean,
                data = value or table, --OPTIONAL
                text = string, --OPTIONAL
                icon = string, --OPTIONAL
            }

        If enabled == true then the optional data can be parsed, and/or the optional text and/or the optional icon can be used
        to provide additional output info at the columns
    ]]

    local dropLocationText --a string containing the zone names and their drop locations and boss names etc. just like in the tooltips (including icons if enabled at settings)
    local dropLocationSort --A string containing the zoneId of a drop location first, and then the dropLocationIds at that zone? Used to sort the drop location column properly

    local dropMechanicTab = setData.dropMechanic
    if dropMechanicTab ~= nil and not ZO_IsTableEmpty(dropMechanicTab) then
        local overallTextsPerZone = setInfoParts["overallTextsPerZone"]
        if overallTextsPerZone ~= nil and overallTextsPerZone.enabled == true then
            dropLocationText = overallTextsPerZone.data[1]
        end

        local dropZoneIds = setData[LIBSETS_TABLEKEY_ZONEIDS]
        if dropZoneIds ~= nil and not ZO_IsTableEmpty(dropZoneIds) then
            dropLocationSort = ""

            --Remove duplicate dropZone Ids
            local dropZonesNonDuplicateKey = {}
            local dropZonesNonDuplicate = {}
            for dropMechanicIdx, dropZoneId in ipairs(dropZoneIds) do
                if not dropZonesNonDuplicateKey[dropZoneId] then
                    dropZonesNonDuplicateKey[dropZoneId] = true
                    tins(dropZonesNonDuplicate, dropZoneId)
                end
            end
            --Now concatenate the non-dupplicate zoneIds as ; separated string
            dropLocationSort = dropLocationSort .. "Z" .. tcon(dropZonesNonDuplicate, ";")

            --Remove duplicate dropMechnic Ids
            local dropMechnicsNonDuplicateKey = {}
            local dropMechnicsNonDuplicate = {}
            for dropMechanicIdx, dropMechanicId in ipairs(dropMechanicTab) do
                if not dropMechnicsNonDuplicateKey[dropMechanicId] then
                    dropMechnicsNonDuplicateKey[dropMechanicId] = true
                    tins(dropMechnicsNonDuplicate, dropMechanicId)
                end
            end
            --Now concatenate the non-dupplicate dropMechnicId as , separated string
            dropLocationSort = dropLocationSort .. "M" .. tcon(dropMechnicsNonDuplicate, ",")
        end
        --[[
        local dropZoneNames = setInfoParts["dropZones"]
        if dropZoneNames ~= nil and dropZoneNames.enabled == true then
            local dropZoneNames = dropZoneNames.data
        end
        ]]
    end


    --The row's data table of each item/entry in the ZO_ScrollFilterList
    local itemData = {
        type = searchUI.searchTypeDefault     -- for the search function -> Processor. !!!Needs to match -> See LibSets_SearchUI_Shared.lua, function self.stringSearch:AddProcessor(searchUI.searchTypeDefault...)
    }

    --todo: Pass in whole table of set's info (for debugging!)
    itemData._LibSets_setData    = setData

    --Mix in the missing setData (setId, setType, bonuses, numBonuses, zoneIds, ...) directly to the itemData
    zo_mixin(itemData, setData)

    --And now add additional itemData
    --Itemlink
    itemData.itemLink            =              itemLink
    itemData.itemId              =              itemId

    --Set info
    itemData.setTypeName         =              setTypeName
    itemData.setTypeTexture      =              setTypeTexture ~= nil and zif(setTypeTexture, 24, 24)

    itemData.name                =              nameColumnValue --Shows multi language xx / en (if enabled at the searchUI settings context menu)
    itemData.nameLower           =              nameColumnValueClean:lower() --Always add that for the string text search!!!
    itemData.nameClean           =              nameColumnValueClean

    --Favorite
    itemData.isFavorite          =              isFavoriteColumnText

    --Set item related
    itemData.armorOrWeaponType   =              armorOrWeaponType
    itemData.armorOrWeaponTypeText =            armorOrWeaponTypeText
    itemData.armorOrWeaponTypeTextWithTexture = armorOrWeaponTypeTextWithTexture
    itemData.armorOrWeaponTypeTexture =         armorOrWeaponTypeTexture ~= nil and zif(armorOrWeaponTypeTexture, 24, 24)
    itemData.equipSlot           =              equipType
    itemData.equipSlotText       =              equipSlotText
    itemData.equipSlotTextWithTexture =         equipSlotTextWithTexture
    itemData.equipSlotTexture =                 equipSlotTexture ~= nil and zif(equipSlotTexture, 24, 24)

    --Drop zones and locations (and boss names)
    itemData.dropLocationText    =              dropLocationText
    itemData.dropLocationSort    =              dropLocationSort

    --Pass in generated tooltip text
    itemData.setDataText         =              setDataText
    itemData.setDataTextClean    =              setDataTextClean
    --Pass in generated tooltip parts table
    itemData.setInfoParts        =              setInfoParts

    --Table entry for the ZO_ScrollList data
	return itemData
end

--Build the masterlist based of the sets searched/filtered
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:BuildMasterList()
--d("[LibSets_SearchUI_List:BuildMasterList]")
    local setsData = lib.setInfo
    self.masterList = {}

    --Pr-Filter the masterlist and hide any sets that do not match e.g. the setType, DLCId etc.
    local setsBaseList = self._parentObject:PreFilterMasterList(setsData)
--lib._debugSetsBaseList = setsBaseList
    if setsBaseList == nil or ZO_IsTableEmpty(setsBaseList) then return end

    --Check if any other filters which need the set itemIds are active (multiselect dropdown boxes for armor/weapon/equipment type/enchantment search category/ etc.)
    local isAnyItemIdRelevantFilterActive = self._parentObject:IsAnyItemIdRelevantFilterActive()
    self.isAnyItemIdRelevantFilterActive = isAnyItemIdRelevantFilterActive
    if isAnyItemIdRelevantFilterActive == true then
        --Will be used at function LibSets_SearchUI_Keyboard:GetItemIdsForSetIdRespectingFilters(setId, onlyOneItemId) -> Called at self:CreateEntryForSet(setId, setData)
        self._parentObject.itemIdRelevantFilterKeys = self._parentObject:GetItemIdRelevantFilterKeys()
    end

    for setId, setData in pairs(setsBaseList) do
        table.insert(self.masterList, self:CreateEntryForSet(setId, setData))
    end
--lib._debugSetsMasterList = self.masterList
end

--Filter the scroll list by fiter data
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:FilterScrollList()
--d("[LibSets_SearchUI_List:FilterScrollList]")
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

    --Get the search method chosen at the search dropdown
    --self.searchType = self.searchDrop:GetSelectedItemData().id

    --Check the search text
    local searchInput = self._parentObject.searchEditBoxControl:GetText()
    local searchIsEmpty = (searchInput == "" and true) or false

    --Check the bonus search text
    local bonusSearchInput = self._parentObject.bonusSearchEditBoxControl:GetText()
    local bonusSearchIsEmpty = (bonusSearchInput == "" and true) or false

    for i = 1, #self.masterList do
        --Get the data of each set item
        local data = self.masterList[i]

        local addItemToList = false

        --Search for name/ID text, set bonuses text
        if searchIsEmpty == true or self._parentObject:CheckForMatch(data, searchInput) then
            if bonusSearchIsEmpty == true or self._parentObject:SearchSetBonuses(data.bonuses, bonusSearchInput) then
                addItemToList = true
            end
        end

        if addItemToList == true then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(searchUI.scrollListDataTypeDefault, data))
        end
    end

    --Update the counter
    self:UpdateCounter(scrollData)
end

--The sort keys for the sort headers of the list
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:SortScrollList( )
    --Build the sortkeys depending on the settings
    self:BuildSortKeys()
    --Get the current sort header's key and direction
    self.currentSortKey = self.sortHeaderGroup:GetCurrentSortKey()
    self.currentSortOrder = self.sortHeaderGroup:GetSortDirection()
--d("[LibSets_SearchUI_List:SortScrollList] sortKey: " .. tos(self.currentSortKey) .. ", sortOrder: " ..tos(self.currentSortOrder))
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end


--The sort keys for the sort headers of the list
function LibSets_SearchUI_List:BuildSortKeys()
    --Get the tiebraker for the 2nd sort after the selected column
    self.sortKeys = {
        --["timestamp"]               = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
        --["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        --["gearId"]                  = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        ["isFavorite"]              = { isNumeric = true,               tiebreaker = "name" },
        ["name"]                    = { caseInsensitive = true },
        ["setType"]                 = { isNumeric = true,               tiebreaker = "name" },
        ["armorOrWeaponType"]       = { isNumeric = true,               tiebreaker = "name" },
        ["equipSlot"]               = { isNumeric = true,               tiebreaker = "name" },
        ["dropLocationSort"]        = { caseInsensitive = true,         tiebreaker = "name" },
        ["setId"]                   = { isNumeric = true,               tiebreaker = "name" },
        ["DLCID"]                   = { isNumeric = true,               tiebreaker = "name" },
    }
end

function LibSets_SearchUI_List:UpdateCounter(scrollData)
    --Update the counter (found by search/total) at the bottom right of the scroll list
    local listCountAndTotal = ""
    if self.masterList == nil or (self.masterList ~= nil and #self.masterList == 0) then
        listCountAndTotal = "0 / 0"
    else
        listCountAndTotal = string.format("%d / %d", #scrollData, #self.masterList)
    end
    self._parentObject.counterControl:SetText(listCountAndTotal)
end

function LibSets_SearchUI_List:AddFavorite(rowControl)
    updateFavoriteColumn(rowControl, true)
end

function LibSets_SearchUI_List:RemoveFavorite(rowControl)
    updateFavoriteColumn(rowControl, false)
end
