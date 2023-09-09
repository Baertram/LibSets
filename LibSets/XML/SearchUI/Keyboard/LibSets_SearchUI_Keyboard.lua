local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

--The search UI table
local searchUI = LibSets.SearchUI
local searchUIName = searchUI.name

local searchUIThrottledSearchHandlerName = searchUIName .. "_ThrottledSearch"
local searchUIThrottledDelay = 500

local MAX_NUM_SET_BONUS = searchUI.MAX_NUM_SET_BONUS


LibSets._debug = {} --todo remove after debugging/testing

--Local helper functions
local function addToIndexTable(t)
    if NonContiguousCount(t) == 0 then return end
    local retTab = {}
    for k,_ in pairs(t) do
        retTab[#retTab + 1] = k
    end
    return retTab
end

------------------------------------------------------------------------------------------------------------------------
--Search results list for keyboard mode
------------------------------------------------------------------------------------------------------------------------
--- ZO_SortFilterList
LibSets_SearchUI_List = ZO_SortFilterList:Subclass()

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

local function refreshSearchFilters(selfVar)
    selfVar.resultsList:RefreshFilters()
end

function LibSets_SearchUI_List:New(listParentControl, parentObject)
	local listObject = ZO_SortFilterList.New(self, listParentControl)
    listObject._parentObject = parentObject --Points to e.g. LIBSETS_SEARCH_UI_KEYBOARD object (of class LibSets_SearchUI_Keyboard)
	listObject:Setup()
	return listObject
end

function LibSets_SearchUI_List:Setup( )
	--Scroll UI
	ZO_ScrollList_AddDataType(self.list, searchUI.scrollListDataTypeDefault, "LibSetsSearchUIRow", 30, function(control, data)
        self:SetupItemRow(control, data)
    end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

    self:SetEmptyText("No sets (matching search criteria) found")

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
	self.headerSlot =               self.headers:GetNamedChild("EquipSlot")
	self.headerSetId =              self.headers:GetNamedChild("SetId")

    --Build initial masterlist via self:BuildMasterList()
    self:RefreshData()
end

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

    local setIdColumn = control:GetNamedChild("SetId")
    setIdColumn:ClearAnchors()
    setIdColumn:SetAnchor(LEFT, slotColumn, RIGHT, 0, 0)
    setIdColumn:SetText(data.setId or "")
    setIdColumn:SetHidden(false)

    --Anchor the last column's right edge to the right edge of the row
    lastColumn = setIdColumn
    lastColumn:SetAnchor(RIGHT, control, RIGHT, -10, 0)

    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end


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
function LibSets_SearchUI_List:CommitScrollList( )
end
]]

--Create a row at teh resultslist, and respect the search filters (multiselect dropdowns of armor, weapon, equipment type,
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

    LibSets._debug.setToItemIds = LibSets._debug.setToItemIds or {}
    LibSets._debug.setToItemIds[setId] = itemId

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

    --Table entry for the ZO_ScrollList data
	return({
        --Internal, for text search etc.
        type                = searchUI.searchTypeDefault,     -- for the search function -> Processor. !!!Needs to match!!!

        --Set info
        setId               = setId,
        dlcId               = setData.dlcId,
        setType             = setData.setType,
        traitsNeeded        = setData.traitsNeeded, --will be nil for non-craftable sets

        --Itemlink
        itemLink            = itemLink,
        itemId              = itemId,

        --Single columns for the output row -> See function self:SetupItemRow
        name                = nameColumnValue,
        armorOrWeaponType   = armorOrWeaponType,
        equipSlot           = equipType,

        --Set bonuses
        numBonuses          = numBonuses,
        bonuses             = setData.bonuses,

        --Pass in whole table of set's info
        setData             = setData,
	})
end

function LibSets_SearchUI_List:BuildSortKeys()
    --Get the tiebraker for the 2nd sort after the selected column
    self.sortKeys = {
        --["timestamp"]               = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
        --["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        --["gearId"]                  = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        ["name"]                    = { caseInsensitive = true },
        ["armorOrWeaponType"]       = { isId64 = true,              tiebreaker = "name" },
        ["equipSlot"]               = { isId64 = true,              tiebreaker = "name" },
        ["setId"]                   = { isId64 = true,              tiebreaker = "name" },
        --["traitName"]               = { caseInsensitive = true, tiebreaker = "name" },
        --["quality"]                 = { caseInsensitive = true, tiebreaker = "name" },
        --["username"]                = { caseInsensitive = true, tiebreaker = "name" },
        --["locality"]                = { caseInsensitive = true, tiebreaker = "name" },
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





--======================================================================================================================
--======================================================================================================================
--======================================================================================================================

------------------------------------------------------------------------------------------------------------------------
--Search UI for keyboard mode
------------------------------------------------------------------------------------------------------------------------

LibSets_SearchUI_Keyboard = LibSets_SearchUI_Shared:Subclass()

------------------------------------------------
--- Initialization
------------------------------------------------
function LibSets_SearchUI_Keyboard:New(...)
    return LibSets_SearchUI_Shared.New(self, ...)
end

function LibSets_SearchUI_Keyboard:Initialize(control)
    LibSets_SearchUI_Shared.Initialize(self, control)

    local backGround = self.control:GetNamedChild("BG")
    backGround:SetAlpha(1)

    local filters = self.filtersControl
    local content = self.contentControl

    local selfVar = self

    --Buttons
    self.resetButton = self.control:GetNamedChild("ButtonReset")
    self.searchButton = self.control:GetNamedChild("ButtonSearch")


    --Filters
    self.searchEditBoxControl = filters:GetNamedChild("TextSearchBox")
    self.searchEditBoxControl:SetDefaultText("Name/ID , separated")
    --ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
    self.searchEditBoxControl:SetHandler("OnTextChanged", function()
        selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar)
    end)
    self.searchEditBoxControl:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
        --d("[LibSets]LibSets_SearchUI_Keyboard - searchEditBox - OnMouseUp")
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            --self:OnSearchEditBoxContextMenu(self.searchEditBoxControl)
        end
    end)

    self.bonusSearchEditBoxControl = filters:GetNamedChild("BonusTextSearchBox")
    self.bonusSearchEditBoxControl:SetDefaultText("(+/-)Bonus , separated")
    self.bonusSearchEditBoxControl:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, self.bonusSearchEditBoxControl, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, "Enter multiple bonus separated by a space.\nUse the + or - prefix to include or exclude a bonus from the search results.")
    end)
    self.bonusSearchEditBoxControl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip)  end)
    --ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
    self.bonusSearchEditBoxControl:SetHandler("OnTextChanged", function()
        selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar)
    end)
    self.bonusSearchEditBoxControl:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
        --d("[LibSets]LibSets_SearchUI_Keyboard - bonusSearchEditBoxControl - OnMouseUp")
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            --self:OnSearchEditBoxContextMenu(self.searchEditBoxControl)
        end
    end)

    --The editbox filters
    self.editBoxFilters = {
        self.searchEditBoxControl,
        self.bonusSearchEditBoxControl,
    }
    --Mapping between edibox and it's name in the searchParams
    self.editBoxFilterToSearchParamName = {
        [self.searchEditBoxControl] =                       "names",
        [self.bonusSearchEditBoxControl] =                  "bonuses",
    }


    --Multiselect dropdowns
    self.setTypeFiltersControl =                   filters:GetNamedChild("SetTypeFilter")
    self.armorTypeFiltersControl =                 filters:GetNamedChild("ArmorTypeFilter")
    self.weaponTypeFiltersControl =                filters:GetNamedChild("WeaponTypeFilter")
    self.equipmentTypeFiltersControl =             filters:GetNamedChild("EquipmentTypeFilter")
    self.DCLIdFiltersControl =                     filters:GetNamedChild("DLCIdFilter")
    self.enchantSearchCategoryTypeFiltersControl = filters:GetNamedChild("EnchantSearchCategoryTypeFilter")
    --todo Disabled for the moment as it does not work! Maybe the self created itemLink does not contain the proper enchanting info?
    self.enchantSearchCategoryTypeFiltersControl:SetHidden(true)

    self.numBonusFiltersControl =                  filters:GetNamedChild("NumBonusFilter")

    --The multiselect dropdown box filters
    self.multiSelectFilterDropdowns = {
        self.setTypeFiltersControl,
        self.armorTypeFiltersControl,
        self.weaponTypeFiltersControl,
        self.equipmentTypeFiltersControl,
        self.DCLIdFiltersControl,
        self.enchantSearchCategoryTypeFiltersControl,
        self.numBonusFiltersControl,
    }
    --Mapping between multiselect dropdown and it's name in the searchParams
    self.multiSelectFilterDropdownToSearchParamName = {
        [self.setTypeFiltersControl] =                      "setTypes",
        [self.armorTypeFiltersControl] =                    "armorTypes",
        [self.weaponTypeFiltersControl] =                   "weaponTypes",
        [self.equipmentTypeFiltersControl] =                "equipmentTypes",
        [self.DCLIdFiltersControl] =                        "DLCIds",
        [self.enchantSearchCategoryTypeFiltersControl] =    "enchantSearchCategoryTypes",
        [self.numBonusFiltersControl] =                     "numBonuses",
    }
    --Is this multiselect dropdown relevant to change the itemIds of setIds (for the itemLink creation at the results list)
    self.isItemIdRelevantMultiSelectFilterDropdown = {
        [self.armorTypeFiltersControl] =                    true,
        [self.weaponTypeFiltersControl] =                   true,
        [self.equipmentTypeFiltersControl] =                true,
        [self.enchantSearchCategoryTypeFiltersControl] =    true,
    }

    self:InitializeFilters() --> Filter data (masterlist base for ZO_SortFilterScrollList) was prepared at LibSets.lua, EVENT_ADD_ON_LOADED -> after function LoadSets() was called


    --Results list -> ZO_SortFilterList
    self.counterControl = content:GetNamedChild("Counter")

    self.resultsListControl = content:GetNamedChild("List")
    self.resultsList = LibSets_SearchUI_List:New(content, self) --pass in the parent control of "Headers" and "List" -> "Contents"



    --Tooltip
    self.tooltipControl = LibSets_SearchUI_Tooltip -- The set item tooltip preview
    self.tooltipKeyboardHookWasDone = false


    SYSTEMS:RegisterKeyboardObject(searchUIName, self)
end


------------------------------------------------
--- UI
------------------------------------------------

function LibSets_SearchUI_Keyboard:ShowUI(control)
    if not self.tooltipKeyboardHookWasDone then
        --Activate the LibSets toolip hooks at the LibSets set search preview tooltip
        if lib.RegisterCustomTooltipHook("LibSets_SearchUI_Tooltip", searchUIName) == true then
            self.tooltipKeyboardHookWasDone = true
        end
    end

    LibSets_SearchUI_Shared.ShowUI(self)
end

function LibSets_SearchUI_Keyboard:ResetUI()
    LibSets_SearchUI_Shared.ResetUI()

    --Reset all UI elements to the default values
    for _, editBoxControl in ipairs(self.editBoxFilters) do
        editBoxControl:SetText("")
    end

    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        self:ResetMultiSelectDropdown(dropdownControl)
    end
end

function LibSets_SearchUI_Keyboard:ApplySearchParamsToUI()
    if not self:IsShown() then return end

    local searchParams = self.searchParams
    if searchParams == nil then return end

    --Apply each searchParam entry to the UI's multiselect dropdown box, editfields, etc.
    --Multi select dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        local entriesToSelect = searchParams[self.multiSelectFilterDropdownToSearchParamName[dropdownControl]]
        if entriesToSelect ~= nil and NonContiguousCount(entriesToSelect) > 0 then
            self:SetMultiSelectDropdownFilters(dropdownControl, entriesToSelect)
        end
    end

    --Edit fields
    for _, editBoxControl in ipairs(self.editBoxFilters) do
        local entryToSetText = searchParams[self.editBoxFilterToSearchParamName[editBoxControl]]
        if entryToSetText ~= nil then
            editBoxControl:SetText(entryToSetText)
        end
    end

end

------------------------------------------------
--- Search
------------------------------------------------
function LibSets_SearchUI_Keyboard:StartSearch(doNotShowUI)
    local searchWasValid = LibSets_SearchUI_Shared.StartSearch(self, doNotShowUI)

    --Show error?
    if not searchWasValid then
        --todo Show error message
        d(libPrefix .. "Search parameters were not valid!")
    end
    return searchWasValid
end


------------------------------------------------
--- Filters
------------------------------------------------

function LibSets_SearchUI_Keyboard:InitializeFilters()
    local function OnFilterChanged()
        self:OnFilterChanged()
    end

    -- Initialize the Set Types multiselect combobox.
    local setTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.setTypeFiltersControl)
    self.setTypeFiltersDropdown = setTypeDropdown
    setTypeDropdown:ClearItems()
    setTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    setTypeDropdown:SetNoSelectionText("No set type filtered")
    setTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    setTypeDropdown:SetSortsItems(true)

    for setType, isValid in pairs(lib.allowedSetTypes) do
        if isValid == true then
            local entry = setTypeDropdown:CreateItemEntry(lib.GetSetTypeName(setType, nil))
            entry.filterType = setType
            setTypeDropdown:AddItem(entry)
        end
    end

    -- Initialize the armor Types multiselect combobox.
    local armorTypeDropdown     = ZO_ComboBox_ObjectFromContainer(self.armorTypeFiltersControl)
    self.armorTypeFiltersDropdown = armorTypeDropdown
    armorTypeDropdown:ClearItems()
    armorTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    armorTypeDropdown:SetNoSelectionText("No armor type filtered")
    armorTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    armorTypeDropdown:SetSortsItems(true)

    for armorType, _ in pairs(lib.armorTypesSets) do
        local entry = armorTypeDropdown:CreateItemEntry(GetString("SI_ARMORTYPE", armorType))
        entry.filterType = armorType
        armorTypeDropdown:AddItem(entry)
    end

    -- Initialize the weapon Types multiselect combobox.
    local weaponTypeDropdown    = ZO_ComboBox_ObjectFromContainer(self.weaponTypeFiltersControl)
    self.weaponTypeFiltersDropdown = weaponTypeDropdown
    weaponTypeDropdown:ClearItems()
    weaponTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    weaponTypeDropdown:SetNoSelectionText("No weapon type filtered")
    weaponTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    weaponTypeDropdown:SetSortsItems(true)

    for weaponType, _ in pairs(lib.weaponTypesSets) do
        local entry = weaponTypeDropdown:CreateItemEntry(self:ModifyWeaponType2hd(weaponType))
        entry.filterType = weaponType
        weaponTypeDropdown:AddItem(entry)
    end

    -- Initialize the equipment Types multiselect combobox.
    local equipmentTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.equipmentTypeFiltersControl)
    self.equipmentTypeFiltersDropdown = equipmentTypeDropdown
    equipmentTypeDropdown:ClearItems()
    equipmentTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    equipmentTypeDropdown:SetNoSelectionText("No equip. type filtered")
    equipmentTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    equipmentTypeDropdown:SetSortsItems(true)

    --local alreadyCheckedEquipTypes = {}
    --for equipSlot, equipTypes in ZO_Character_EnumerateEquipSlotToEquipTypes() do
        --for _, equipType in ipairs(equipTypes) do
    for equipType, isValid in pairs(lib.equipTypesValid) do
            --if not alreadyCheckedEquipTypes[equipType] and lib.equipTypesSets[equipType] ~= nil then
                --alreadyCheckedEquipTypes[equipType] = true
        if isValid == true then
                local entry = equipmentTypeDropdown:CreateItemEntry(GetString("SI_EQUIPTYPE", equipType))
                entry.filterType = equipType
                equipmentTypeDropdown:AddItem(entry)
        end
            --end
        --end
    --end
    end

    -- Initialize the DLC Types multiselect combobox.

    local DLCIdDropdown       = ZO_ComboBox_ObjectFromContainer(self.DCLIdFiltersControl)
    self.DLCIdFiltersDropdown = DLCIdDropdown
    DLCIdDropdown:ClearItems()
    DLCIdDropdown:SetHideDropdownCallback(OnFilterChanged)
    DLCIdDropdown:SetNoSelectionText("No DLC ID filtered")
    DLCIdDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    DLCIdDropdown:SetSortsItems(true)

    for DLCId, isValid in pairs(lib.allowedDLCIds) do
        if isValid == true then
            local entry = DLCIdDropdown:CreateItemEntry(lib.GetDLCName(DLCId, nil))
            entry.filterType = DLCId
            DLCIdDropdown:AddItem(entry)
        end
    end

    -- Initialize the enchantment search category Types multiselect combobox.
    local enchantmentSearchCategoryTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.enchantSearchCategoryTypeFiltersControl)
    self.enchantSearchCategoryTypeFiltersDropdown = enchantmentSearchCategoryTypeDropdown
    enchantmentSearchCategoryTypeDropdown:ClearItems()
    enchantmentSearchCategoryTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    enchantmentSearchCategoryTypeDropdown:SetNoSelectionText("No enchantm. search cat. type filtered")
    enchantmentSearchCategoryTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    enchantmentSearchCategoryTypeDropdown:SetSortsItems(true)

    for enchantSearchCategoryType, isValid in pairs(lib.enchantSearchCategoryTypesValid) do
        if isValid == true then
            local entry = enchantmentSearchCategoryTypeDropdown:CreateItemEntry(GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", enchantSearchCategoryType))
            entry.filterType = enchantSearchCategoryType
            enchantmentSearchCategoryTypeDropdown:AddItem(entry)
        end
    end

    -- Initialize the Number of bonuses multiselect combobox.
    local numBonusDropdown = ZO_ComboBox_ObjectFromContainer(self.numBonusFiltersControl)
    self.numBonusFiltersDropdown = numBonusDropdown
    numBonusDropdown:ClearItems()
    numBonusDropdown:SetHideDropdownCallback(OnFilterChanged)
    numBonusDropdown:SetNoSelectionText("# bonus")
    numBonusDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    numBonusDropdown:SetSortsItems(true)

    for numBonus=1, MAX_NUM_SET_BONUS, 1 do
        local entry = numBonusDropdown:CreateItemEntry(tostring(numBonus))
        entry.filterType = numBonus
        numBonusDropdown:AddItem(entry)
    end
end

function LibSets_SearchUI_Keyboard:GetSelectedMultiSelectDropdownFilters(multiSelectDropdown)
    local selectedFilterTypes = {}
    local dropdownComboBox = multiSelectDropdown.m_comboBox

    if dropdownComboBox:GetNumSelectedEntries() == 0 then return selectedFilterTypes end

    for _, item in ipairs(dropdownComboBox:GetItems()) do
        if dropdownComboBox:IsItemSelected(item) then
            selectedFilterTypes[item.filterType] = true
        end
    end
    return selectedFilterTypes
end

function LibSets_SearchUI_Keyboard:SetMultiSelectDropdownFilters(multiSelectDropdown, entriesToSelect)
    self:ResetMultiSelectDropdown(multiSelectDropdown)
    local dropdownComboBox = multiSelectDropdown.m_comboBox

    for _, item in ipairs(dropdownComboBox:GetItems()) do
        for entry, shouldSelect in pairs(entriesToSelect) do
            if shouldSelect == true and entry == item.filterType then
                dropdownComboBox:AddItemToSelected(item)
                break -- inner loop
            end
        end
    end

    multiSelectDropdown:RefreshSelectedItemText()
end

-->Check the searchParams for entries of the multiselect dropdown boxes, and other filter controls, which change the
-->possible itemIds of an itemLink at the resultsList row
function LibSets_SearchUI_Keyboard:IsAnyItemIdRelevantFilterActive()
--d("LibSets_SearchUI_Keyboard:IsAnyItemIdRelevantFilterActive")
    local searchParams = self.searchParams
LibSets._debug.searchParams = searchParams
    if searchParams == nil or NonContiguousCount(searchParams) == 0 then return false end

    --Multiselect dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        if self.isItemIdRelevantMultiSelectFilterDropdown[dropdownControl] then
            local searchParamEntryKey = self.multiSelectFilterDropdownToSearchParamName[dropdownControl]
            local searchParamEntry = searchParams[searchParamEntryKey]
            if searchParamEntry ~= nil and NonContiguousCount(searchParamEntry) > 0 then
--d(">found filtered data in: " .. tostring(searchParamEntryKey))
                return true
            end
        end
    end

    --Edit fields
    -->Currently no itemId changes

    return false
end

-->Get the searchParam entries of the multiselect dropdown boxes, and other filter controls, which change the
-->possible itemIds of an itemLink at the resultsList row
--Returns a table with key = searchParams key and value = boolean true, so you can loop over self.searchParams where key = returned key
--and build a logic for the itemIds that you need
function LibSets_SearchUI_Keyboard:GetItemIdRelevantFilterKeys()
    --d("LibSets_SearchUI_Keyboard:GetItemIdRelevantFilterKeys")
    local searchParamKeysOfItemIdAffectingFilters = {}
    local searchParams = self.searchParams
    if searchParams == nil or NonContiguousCount(searchParams) == 0 then return false end

    --Multiselect dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        if self.isItemIdRelevantMultiSelectFilterDropdown[dropdownControl] then
            local searchParamKey = self.multiSelectFilterDropdownToSearchParamName[dropdownControl]
            local searchParamEntry = searchParams[searchParamKey]
            if searchParamEntry ~= nil and NonContiguousCount(searchParamEntry) > 0 then
                searchParamKeysOfItemIdAffectingFilters[searchParamKey] = true
            end
        end
    end

    --Edit fields
    -->Currently no itemId changes

    return searchParamKeysOfItemIdAffectingFilters
end

-->Get the itemIds mathcing to the searchParam entries of the multiselect dropdown boxes, and other filter controls, which change the
-->possible itemIds of an itemLink at the resultsList row
--Returns a table with key = counter and value = itemId
function LibSets_SearchUI_Keyboard:GetItemIdsForSetIdRespectingFilters(setId, onlyOneItemId)
    --d("LibSets_SearchUI_Keyboard:GetItemIdsForSetIdRespectingFilters-setId: " ..tostring(setId) .. ", onlyOneItemId: " ..tostring(onlyOneItemId))
    onlyOneItemId = onlyOneItemId or false
    local relevantItemIds = {}
    local equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes

    local itemIdFilterKeys = self.itemIdRelevantFilterKeys
    if itemIdFilterKeys == nil then return end
    local searchParams = self.searchParams

    --Get the searchParam subtables and map their contents (e.g. [<armorTypeId>] = true) to the needed format for
    --the LibSets API function calls (e.g. LibSets.GetSetItemId, where armorType needs a format like { [1]=<armorTypeId>, [2]=<armorTypeId>, ...})
    for filterKey, _ in pairs(itemIdFilterKeys) do
        local searchParamEntries = searchParams[filterKey]
        if searchParamEntries ~= nil then
            if filterKey == "armorTypes" then
                armorTypes = addToIndexTable(searchParamEntries)
            elseif filterKey == "weaponTypes" then
                weaponTypes = addToIndexTable(searchParamEntries)
            elseif filterKey == "equipmentTypes" then
                equipmentTypes = addToIndexTable(searchParamEntries)
            elseif filterKey == "enchantSearchCategoryTypes" then
                enchantSearchCategoryTypes = addToIndexTable(searchParamEntries)
            end
        end
    end

    LibSets._debug.armorTypes = armorTypes
    LibSets._debug.weaponTypes = weaponTypes
    LibSets._debug.equipmentTypes = equipmentTypes
    LibSets._debug.enchantSearchCategoryTypes = enchantSearchCategoryTypes

    --Only 1 itemId:
    local itemIdsMatchingFilters
    if onlyOneItemId == true then
        local itemIdMatchingFilters = lib.GetSetItemId(setId, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
        LibSets._debug.itemIdMatchingFilters = itemIdMatchingFilters
        if itemIdMatchingFilters ~= nil then
            itemIdsMatchingFilters = {}
            itemIdsMatchingFilters[itemIdMatchingFilters] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
        end
    else
        --All itemIds:
        itemIdsMatchingFilters = lib.GetSetItemIds(setId, nil, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
    end

    LibSets._debug.itemIdsMatchingFilters = itemIdsMatchingFilters

    if itemIdsMatchingFilters ~= nil then
        relevantItemIds = {}
        for itemId, _ in pairs(itemIdsMatchingFilters) do
            relevantItemIds[#relevantItemIds + 1] = itemId
        end
        --Sort the itemIds so the same always are at the top
        table.sort(relevantItemIds)

        --d("LibSets_SearchUI_Keyboard:GetItemIdsForSetIdRespectingFilters-setId: " ..tostring(setId) .. ", itemId: " ..tostring(relevantItemIds[1]))
    end

    LibSets._debug.relevantItemIds = relevantItemIds

    return relevantItemIds
end



--Will be called as the multiselect dropdown boxes got closed again (and entries might have changed)
function LibSets_SearchUI_Keyboard:OnFilterChanged()
    --d("[LibSets_SearchUI_Shared]OnFilterChanged - MultiSelect dropdown - hidden")
    LibSets_SearchUI_Shared.OnFilterChanged(self)

    local searchParams = {}

    --Multiselect dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        local selectedEntries = self:GetSelectedMultiSelectDropdownFilters(dropdownControl)
        if NonContiguousCount(selectedEntries) > 0 then
            searchParams[self.multiSelectFilterDropdownToSearchParamName[dropdownControl]] = selectedEntries
        end
    end

    --Editboxes
    -->Will be handled at OnTextChanged handler directly at the editboxes

    self.searchParams = searchParams
end


------------------------------------------------
--- Handlers
------------------------------------------------
function LibSets_SearchUI_Keyboard:OnRowMouseEnter(rowControl)
    self.resultsList:Row_OnMouseEnter(rowControl)

    self.tooltipControl.data = rowControl.data
    self:ShowItemLinkTooltip(self.control, rowControl.data, nil, nil, nil, nil)
end

function LibSets_SearchUI_Keyboard:OnRowMouseExit(rowControl)
    self.resultsList:Row_OnMouseExit(rowControl)

    self:HideItemLinkTooltip()
    self.tooltipControl.data = nil
end

function LibSets_SearchUI_Keyboard:OnRowMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
    if upInside then
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            local data = rowControl.data
            if data.itemLink ~= nil then
                d(libPrefix .."SetId \'".. tostring(data.setId) .."\': " ..data.itemLink)
                StartChatInput(data.itemLink)
            end
        end
    end
end


--[[ XML Handlers ]]--
function LibSets_SearchUI_Keyboard_TopLevel_OnInitialized(self)
	LIBSETS_SEARCH_UI_KEYBOARD = LibSets_SearchUI_Keyboard:New(self)
end