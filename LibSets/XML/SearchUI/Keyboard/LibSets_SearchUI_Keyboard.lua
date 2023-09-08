local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

--The search UI table
local searchUI = LibSets.SearchUI
local searchUIName = searchUI.name

local twoHandWeaponTypes = {
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
}



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

function LibSets_SearchUI_List:Setup( )
	--Scroll UI
	ZO_ScrollList_AddDataType(self.list, 1, "LibSetsSearchUIRow", 30, function(control, data)
        self:SetupItemRow(control, data)
    end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

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
	self.headers = self.parentControl:GetNamedChild("Headers")
    self.headerName = self.headers:GetNamedChild("Name")
	self.headerArmorOrWeaponType = self.headers:GetNamedChild("ArmorOrWeaponType")
	self.headerSlot = self.headers:GetNamedChild("Slot")

    --Build initial masterlist via self:BuildMasterList()
    self:RefreshData()
end

function LibSets_SearchUI_List:SetupItemRow(control, data)
    --local clientLang = WL.clientLang or WL.fallbackSetLang
    --d(">>>      [LibSets_SearchUI_List:SetupItemRow] " ..tostring(data.names[clientLang]))
    control.data = data

    local nameColumn = control:GetNamedChild("Name")
    nameColumn.normalColor = ZO_DEFAULT_TEXT
    if not data.columnWidth then data.columnWidth = 200 end
    nameColumn:SetDimensions(data.columnWidth, 30)

    nameColumn:ClearAnchors()
    nameColumn:SetAnchor(LEFT, control, nil, 0, 0)
    nameColumn:SetHidden(false)
    nameColumn:SetText(data.name or "test name")

    local armorOrWeaponTypeColumn = control:GetNamedChild("ArmorOrWeaponType")
    armorOrWeaponTypeColumn:SetHidden(false)
    armorOrWeaponTypeColumn:SetText(data.armorOrWeaponType or "")

    local slotColumn = control:GetNamedChild("Slot")
    slotColumn:SetHidden(false)
    slotColumn:SetText(data.equipSlot or "")
    slotColumn:SetAnchor(RIGHT, control, RIGHT, -16, 0)

    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end

function LibSets_SearchUI_List:BuildMasterList(calledFromFilterFunction)
    calledFromFilterFunction = calledFromFilterFunction or false
d("[LibSets_SearchUI_List:BuildMasterList]calledFromFilterFunction: " ..tostring(calledFromFilterFunction))
    --Sets tab row creation from savedvars sets list
------------------------------------------------------------------------------------------------------------------------
    self.masterList = {}
    local setsData = lib.setInfo
    for setId, setData in pairs(setsData) do
        table.insert(self.masterList, self:CreateEntryForSet(setId, setData))
    end

    --self:updateSortHeaderAnchorsAndPositions(maxNameColumnWidth, 32)
end

function LibSets_SearchUI_List:FilterScrollList()
--d("[WishListWindow:FilterScrollList]")
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

    --Get the search method chosen at the search dropdown
    --self.searchType = self.searchDrop:GetSelectedItemData().id

    --Check the search text

    local searchInput = self._parentObject.searchEditBox:GetText()

    for i = 1, #self.masterList do
        --Get the data of each set item
        local data = self.masterList[i]
        --Search for text/set bonuses
        if searchInput == "" or self._parentObject:CheckForMatch(data, searchInput) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
    end

    --Update the counter
    self:UpdateCounter(scrollData)
end


function LibSets_SearchUI_List:CreateEntryForSet(setId, setData)
    local nameColumnValue = setData.setNames[lib.clientLang] or setData.setNames[lib.fallbackLang]

    --[[
	local itemId = lib.GetFirstItemIdOfSetId(setId, nil)
    if itemId == nil then return nil end
    local itemLink = lib.buildItemLink(itemId, 370) -- Always use the legendary quality for the sets list
    local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
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

    --Table entry for the ZO_ScrollList data
	return({
        type                = 1,     -- for the search function!!!
        setId               = setId,
        --Single columns for the output row -> See function self:SetupItemRow
        name                = nameColumnValue,
        armorOrWeaponType   = "",
        equipSlot           = "",

        --Pass in whole table of set's info
        setData     = setData,
	})
end

function LibSets_SearchUI_List:BuildSortKeys()
    --Get the tiebraker for the 2nd sort after the selected column
    self.sortKeys = {
        --["timestamp"]               = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
        --["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        --["gearId"]                  = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
        ["name"]                    = { caseInsensitive = true },
        ["armorOrWeaponTypeName"]   = { caseInsensitive = true, tiebreaker = "name" },
        ["slotName"]                = { caseInsensitive = true, tiebreaker = "name" },
        --["traitName"]               = { caseInsensitive = true, tiebreaker = "name" },
        --["quality"]                 = { caseInsensitive = true, tiebreaker = "name" },
        --["username"]                = { caseInsensitive = true, tiebreaker = "name" },
        --["locality"]                = { caseInsensitive = true, tiebreaker = "name" },
    }
end

function LibSets_SearchUI_List:SortScrollList( )
    --Build the sortkeys depending on the settings
    self:BuildSortKeys()
    --Get the current sort header's key and direction
    self.currentSortKey = self.sortHeaderGroup:GetCurrentSortKey()
    self.currentSortOrder = self.sortHeaderGroup:GetSortDirection()
d("[LibSets_SearchUI_List:SortScrollList] sortKey: " .. tostring(self.currentSortKey) .. ", sortOrder: " ..tostring(self.currentSortOrder))
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end

function LibSets_SearchUI_List:UpdateCounter(scrollData)
    --Update the counter (found by search/total) at the bottom right of the scroll list
    local listCountAndTotal = ""
    if self.masterList == nil or (self.masterList ~= nil and #self.masterList == 0) then
        listCountAndTotal = "0 / 0"
    else
        listCountAndTotal = string.format("%d / %d", #scrollData, #self.masterList)
    end
    self.parentControl:GetNamedChild("Counter"):SetText(listCountAndTotal)
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

    local filters = self.filters
    local content = self.content

    self.resetButton = self.control:GetNamedChild("ButtonReset")
    self.searchButton = self.control:GetNamedChild("ButtonSearch")


    --Results list -> ZO_SortFilterList
    self.counter = content:GetNamedChild("Counter")
    self.resultsListControl = content:GetNamedChild("List")
    self.resultsList = LibSets_SearchUI_List:New(content, self) --pass in the parent control of "Headers" and "List" -> "Contents"

    --Filters
    self.searchEditBox = filters:GetNamedChild("TextSearchBox")
	--ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
    self.searchEditBox:SetHandler("OnTextChanged", function() self.resultsList:RefreshFilters() end)
    self.searchEditBox:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
d("[LibSets]LibSets_SearchUI_Keyboard - searchEditBox - OnMouseUp")
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            --self:OnSearchEditBoxContextMenu(self.searchEditBox)
        end
    end)

    --Multiselect dropdowns
    self.setTypeFilters =                   filters:GetNamedChild("SetTypeFilter")
    self.armorTypeFilters =                 filters:GetNamedChild("ArmorTypeFilter")
    self.weaponTypeFilters =                filters:GetNamedChild("WeaponTypeFilter")
    self.equipmentTypeFilters =             filters:GetNamedChild("EquipmentTypeFilter")
    self.DCLIdFilters =                     filters:GetNamedChild("DLCIdFilter")
    self.enchantSearchCategoryTypeFilters = filters:GetNamedChild("EnchantSearchCategoryTypeFilter")


    self:InitializeFilters() --> Filter data was prepared at LibSets.lua, EVENT_ADD_ON_LOADED -> after function LoadSets() was called


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
    self.searchEditBox:SetText("")
    self.setTypeFilters.m_comboBox:ClearAllSelections()
    self.armorTypeFilters.m_comboBox:ClearAllSelections()
    self.weaponTypeFilters.m_comboBox:ClearAllSelections()
    self.equipmentTypeFilters.m_comboBox:ClearAllSelections()
    self.DCLIdFilters.m_comboBox:ClearAllSelections()
    self.enchantSearchCategoryTypeFilters.m_comboBox:ClearAllSelections()
end

------------------------------------------------
--- Search
------------------------------------------------
function LibSets_SearchUI_Keyboard:StartSearch(control)
    local searchWasValid = LibSets_SearchUI_Shared.StartSearch(self)

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
local function OnFilterChanged()
    d("[LibSets]OnFilterChanged - MultiSelect dropdown - hidden")
end

function LibSets_SearchUI_Keyboard:InitializeFilters()
    -- Initialize the Set Types multiselect combobox.
    local setTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.setTypeFilters)
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
    local armorTypeDropdown     = ZO_ComboBox_ObjectFromContainer(self.armorTypeFilters)
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
    local weaponTypeDropdown    = ZO_ComboBox_ObjectFromContainer(self.weaponTypeFilters)
    self.weaponTypeFiltersDropdown = weaponTypeDropdown
    weaponTypeDropdown:ClearItems()
    weaponTypeDropdown:SetHideDropdownCallback(OnFilterChanged)
    weaponTypeDropdown:SetNoSelectionText("No weapon type filtered")
    weaponTypeDropdown:SetMultiSelectionTextFormatter(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT)
    weaponTypeDropdown:SetSortsItems(true)

    local function modifyWeaponType2hd(weaponType)
        local weaponTypeText = GetString("SI_WEAPONTYPE", weaponType)
        if not twoHandWeaponTypes[weaponType] then
            return weaponTypeText
        else
           return "2HD " .. weaponTypeText
        end
    end

    for weaponType, _ in pairs(lib.weaponTypesSets) do
        local entry = weaponTypeDropdown:CreateItemEntry(modifyWeaponType2hd(weaponType))
        entry.filterType = weaponType
        weaponTypeDropdown:AddItem(entry)
    end

    -- Initialize the equipment Types multiselect combobox.
    local equipmentTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.equipmentTypeFilters)
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

    local DLCIdDropdown         = ZO_ComboBox_ObjectFromContainer(self.DCLIdFilters)
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
    local enchantmentSearchCategoryTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.enchantSearchCategoryTypeFilters)
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
end


------------------------------------------------
--- Handlers
------------------------------------------------
function LibSets_SearchUI_Keyboard:OnRowMouseEnter(rowControl)
    self.tooltipControl.data = rowControl.data
    self:ShowItemLinkTooltip(rowControl, rowControl.data, nil, nil, nil, nil)
end

function LibSets_SearchUI_Keyboard:OnRowMouseExit(rowControl)
    self:HideItemLinkTooltip()
    self.tooltipControl.data = nil
end

function LibSets_SearchUI_Keyboard:OnRowMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)

end


--[[ XML Handlers ]]--
function LibSets_SearchUI_Keyboard_TopLevel_OnInitialized(self)
	LIBSETS_SEARCH_UI_KEYBOARD = LibSets_SearchUI_Keyboard:New(self)
end