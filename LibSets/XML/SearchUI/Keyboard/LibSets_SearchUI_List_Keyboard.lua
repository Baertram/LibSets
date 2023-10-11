local lib = LibSets

local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

--The search UI table
local searchUI = LibSets.SearchUI
local searchUIName = searchUI.name

--Library's local helpers
local buildSetDataText = lib.BuildSetDataText

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
	self.headerArmorOrWeaponType =  self.headers:GetNamedChild("ArmorOrWeaponType")
	self.headerEquipSlot =               self.headers:GetNamedChild("EquipSlot")
	self.headerDropLocations =      self.headers:GetNamedChild("DropLocations")
	self.headerSetId =              self.headers:GetNamedChild("SetId")

    --Build initial masterlist via self:BuildMasterList()
    self:RefreshData()
end

--Get the data of the masterlist entries and add it to the list columns
function LibSets_SearchUI_List:SetupItemRow(control, data)
    --local clientLang = WL.clientLang or WL.fallbackSetLang
    --d(">>>      [LibSets_SearchUI_List:SetupItemRow] " ..tostring(data.names[clientLang]))
    control.data = data

    local lastColumn

    local nameColumn = control:GetNamedChild("Name")
    nameColumn.normalColor = ZO_DEFAULT_TEXT
    nameColumn:ClearAnchors()
    nameColumn:SetAnchor(LEFT, control, nil, 0, 0)
    nameColumn:SetText(data.name or "test name")
    nameColumn:SetHidden(false)

    local armorOrWeaponTypeColumn = control:GetNamedChild("ArmorOrWeaponType")
    armorOrWeaponTypeColumn:ClearAnchors()
    armorOrWeaponTypeColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
    armorOrWeaponTypeColumn:SetText(data.armorOrWeaponType or "")
    armorOrWeaponTypeColumn:SetHidden(false)

    local slotColumn = control:GetNamedChild("EquipSlot")
    slotColumn:ClearAnchors()
    slotColumn:SetAnchor(LEFT, armorOrWeaponTypeColumn, RIGHT, 0, 0)
    slotColumn:SetText(data.equipSlot or "")
    slotColumn:SetHidden(false)

    local dropLocationsColumn = control:GetNamedChild("DropLocations")
    dropLocationsColumn:ClearAnchors()
    dropLocationsColumn:SetAnchor(LEFT, slotColumn, RIGHT, 0, 0)
    dropLocationsColumn:SetText(data.dropLocationsText or "")
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

--Build the masterlist based of the sets searched/filtered
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:BuildMasterList()
--d("[LibSets_SearchUI_List:BuildMasterList]")
    local setsData = lib.setInfo
    self.masterList = {}

    --Pr-Filter the masterlist and hide any sets that do not match e.g. the setType, DLCId etc.
    local setsBaseList = self._parentObject:PreFilterMasterList(setsData)

    --Check if any other filters which need the set itemIds are active (multiselect dropdown boxes for armor/weapon/equipment type etc.)
    local isAnyItemIdRelevantFilterActive = self._parentObject:IsAnyItemIdRelevantFilterActive()
    self.isAnyItemIdRelevantFilterActive = isAnyItemIdRelevantFilterActive
    if isAnyItemIdRelevantFilterActive == true then
        self._parentObject.itemIdRelevantFilterKeys = self._parentObject:GetItemIdRelevantFilterKeys()
    end

    for setId, setData in pairs(setsBaseList) do
        table.insert(self.masterList, self:CreateEntryForSet(setId, setData))
    end
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

        --Search for text/set bonuses
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
--d("[LibSets_SearchUI_List:SortScrollList] sortKey: " .. tostring(self.currentSortKey) .. ", sortOrder: " ..tostring(self.currentSortOrder))
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end


--[[
-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()
function LibSets_SearchUI_List:CommitScrollList( )
end
]]

--Create a row at the resultslist, and respect the search filters (multiselect dropdowns of armor, weapon, equipment type,
--enchantment, etc.)
function LibSets_SearchUI_List:CreateEntryForSet(setId, setData)
    local nameColumnValue = setData.setNames[lib.clientLang] or setData.setNames[lib.fallbackLang]

    local itemId

    local parentObject = self._parentObject
    if self.isAnyItemIdRelevantFilterActive == true then
        --Get a matching (to the multiselect dropdown filters) itemId
        local itemIds = parentObject:GetItemIdsForSetIdRespectingFilters(setId, true) --only 1 itemId
        if itemIds == nil then return end
        --Use the first itemId found
        itemId = itemIds[1]
    else
        --Get "any" itemId (the first found of the setId)
        itemId = lib.GetSetFirstItemId(setId, nil)
    end

    --LibSets._debug.setToItemIds = LibSets._debug.setToItemIds or {}
    --LibSets._debug.setToItemIds[setId] = itemId

    if itemId == nil then return nil end


    local itemLink = lib.buildItemLink(itemId, 370) -- Always use the legendary quality for the sets list
    --[[
    --Get the drop location(s) of the set via LibSets
    local dropLocationsText = ""
    local dropLocationsZoneIds = setData.zoneIds
    --Get the drop location wayshrines
    local setWayshrines = setData.wayshrines
    --Get the DLC id
    local dlcName = lib.GetDLCName(setData.dlcId)
    --Get set type
    local setType = setData.setType
    local setTypeName = lib.GetSetTypeName(setType)
    --Get traits needed for craftable sets
    local traitsNeeded = lib.GetTraitsNeeded(setId)
    ]]

    local armorOrWeaponTypeText, equipSlotText --todo: fill with textures of the armorType, weaponType, equipSlot
    local equipType = GetItemLinkEquipType(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local armorOrWeaponType
    if itemType == ITEMTYPE_ARMOR then
        armorOrWeaponType = GetItemLinkArmorType(itemLink)
    elseif itemType == ITEMTYPE_WEAPON then
        armorOrWeaponType = GetItemLinkWeaponType(itemLink)
    end

    local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
    local bonuses = (numBonuses == 0 and {}) or setData.bonuses
    if numBonuses > 0 and (bonuses == nil or type(bonuses) == "number") then
        -- Lazy initialization of set bonus data
        setData.bonuses = lib.GetSetBonuses(itemLink, numBonuses)
        bonuses = setData.bonuses
    end

    local dropLocationText --a string containing the zone names and their drop locations and boss names etc. just like in the tooltips (including icons if enabled at settings)
    local dropLocationSort --a string containing the zoneId of a drop location first, and then the dropLocationIds at that zone?

    local setDataText, setInfoParts = buildSetDataText(setData, itemLink, false)
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


    --Table entry for the ZO_ScrollList data
	return({
        --Internal, for text search etc.
        type                = searchUI.searchTypeDefault,     -- for the search function -> Processor. !!!Needs to match!!!

        --Itemlink
        itemLink            = itemLink,
        itemId              = itemId,

        --Set info
        setId               = setId,
        setType             = setData.setType,
        name                = nameColumnValue,

        --Set item related
        armorOrWeaponType   = armorOrWeaponType,
        armorOrWeaponTypeText = armorOrWeaponTypeText,
        equipSlot           = equipType,
        equipSlotText       = equipSlotText,

        --Crafting related
        traitsNeeded        = setData.traitsNeeded, --will be nil for non-craftable sets

        --Set bonuses
        numBonuses          = numBonuses,
        bonuses             = setData.bonuses,

        --Drop zones and locations (and boss names)
        dropLocationText    = dropLocationText,
        dropLocationSort    = dropLocationSort,

        --DLC
        dlcId               = setData.dlcId,

        --Pass in whole table of set's info
        setData             = setData,

        --Pass in generated tooltip text
        setDataText         = setDataText,
        --Pass in generated tooltip parts
        setInfoParts        = setInfoParts,
	})
end

--The sort keys for the sort headers of the list
function LibSets_SearchUI_List:BuildSortKeys()
    --Get the tiebraker for the 2nd sort after the selected column
    self.sortKeys = {
        --["timestamp"]               = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
        --["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        --["gearId"]                  = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        ["name"]                    = { caseInsensitive = true },
        ["armorOrWeaponType"]       = { isId64 = true,              tiebreaker = "name" },
        ["equipSlot"]               = { isId64 = true,              tiebreaker = "name" },
        ["dropLocationSort"]        = { caseInsensitive = true,     tiebreaker = "name" },
        ["setId"]                   = { isId64 = true,              tiebreaker = "name" },
        ["setType"]                 = { isId64 = true,              tiebreaker = "name" },
        ["DLCID"]                   = { isId64 = true,              tiebreaker = "name" },
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
