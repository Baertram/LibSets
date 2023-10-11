local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

local getLocalizedText = lib.GetLocalizedText

--The search UI table
local searchUI = LibSets.SearchUI
local searchUIName = searchUI.name

local searchUIThrottledSearchHandlerName = searchUIName .. "_ThrottledSearch"
local searchUIThrottledDelay = 500

local MAX_NUM_SET_BONUS = searchUI.MAX_NUM_SET_BONUS


--Debugging - TODO: Disable again
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

local function refreshSearchFilters(selfVar)
    selfVar.resultsList:RefreshFilters()
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
    self.dropZoneFiltersControl =                  filters:GetNamedChild("DropZoneFilter")
    self.dropMechanicsFiltersControl =             filters:GetNamedChild("DropMechanicsFilter")
    self.dropLocationsFiltersControl =             filters:GetNamedChild("DropLocationsFilter")

    self.numBonusFiltersControl =                  filters:GetNamedChild("NumBonusFilter")

    --The multiselect dropdown box filters
    self.multiSelectFilterDropdowns = {
        self.setTypeFiltersControl,
        self.armorTypeFiltersControl,
        self.weaponTypeFiltersControl,
        self.equipmentTypeFiltersControl,
        self.DCLIdFiltersControl,
        self.enchantSearchCategoryTypeFiltersControl,
        self.dropZoneFiltersControl,
        self.dropMechanicsFiltersControl,
        self.dropLocationsFiltersControl,
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
        [self.dropZoneFiltersControl] =                     "dropZones",
        [self.dropMechanicsFiltersControl] =                "dropMechanics",
        [self.dropLocationsFiltersControl] =                "dropLocations",
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

function LibSets_SearchUI_Keyboard:UpdateSearchParamsFromSlashcommand(slashOptions)
lib._debug._slashOptions = slashOptions
    if slashOptions ~= nil then
        --Reset all current search parameters
        self:ResetUI()

        local setNameSearchStr = self:GetSetNameSearchString(slashOptions)
        if setNameSearchStr == nil or setNameSearchStr == "" then return end

        --Put the slash commands options to the editbox "name" of the search params
        self.searchParams = self.searchParams or {}
        self.searchParams[self.editBoxFilterToSearchParamName[self.searchEditBoxControl]] = setNameSearchStr

        --Apply the search by name now
        self:ApplySearchParamsToUI()
    end
lib._debug.searchParams = self.searchParams
end

function LibSets_SearchUI_Keyboard:ShowUI(slashOptions)
    if not self.tooltipKeyboardHookWasDone then
        --Activate the LibSets toolip hooks at the LibSets set search preview tooltip
        if lib.RegisterCustomTooltipHook("LibSets_SearchUI_Tooltip", searchUIName) == true then
            self.tooltipKeyboardHookWasDone = true
        end
    end

    LibSets_SearchUI_Shared.ShowUI(self)

    --Was called from slash command and any search term was entered?
    self:UpdateSearchParamsFromSlashcommand(slashOptions)
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
--[[
function LibSets_SearchUI_Keyboard:GetSetNameSearchString(tableOrString)
    return LibSets_SearchUI_Shared.GetSetNameSearchString(LibSets_SearchUI_Keyboard, tableOrString)
end
]]

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
    local filterTypeText = getLocalizedText("setType")
    setTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("armorType")
    armorTypeDropdown:EnableMultiSelect(SI_ITEM_SETS_BOOK_APPAREL_TYPES_DROPDOWN_TEXT, getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("weaponType")
    weaponTypeDropdown:EnableMultiSelect(SI_ITEM_SETS_BOOK_WEAPON_TYPES_DROPDOWN_TEXT, getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("equipmentType")
    equipmentTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("dlc")
    DLCIdDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("enchantmentSearchCategory")
    enchantmentSearchCategoryTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
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
    local filterTypeText = getLocalizedText("numBonuses")
    numBonusDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    numBonusDropdown:SetSortsItems(true)

    for numBonus=1, MAX_NUM_SET_BONUS, 1 do
        local entry = numBonusDropdown:CreateItemEntry(tostring(numBonus))
        entry.filterType = numBonus
        numBonusDropdown:AddItem(entry)
    end

    -- Initialize the Drop zones multiselect combobox.
    local dropZoneDropdown      = ZO_ComboBox_ObjectFromContainer(self.dropZoneFiltersControl)
    self.dropZoneFiltersDropdown = dropZoneDropdown
    dropZoneDropdown:ClearItems()
    dropZoneDropdown:SetHideDropdownCallback(OnFilterChanged)
    local filterTypeText = getLocalizedText("dropZones")
    dropZoneDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    dropZoneDropdown:SetSortsItems(true)

    local dropZoneIds = lib.GetAllDropZones()
    if dropZoneIds ~= nil then
        for dropZone, isValid in pairs(dropZoneIds) do
            if isValid == true then
                local entry = dropZoneDropdown:CreateItemEntry(zo_strformat(SI_UNIT_NAME, GetZoneNameById(dropZone)))
                entry.filterType = dropZone
                dropZoneDropdown:AddItem(entry)
            end
        end
    end

    -- Initialize the Drop mechanics multiselect combobox.
    local dropMechanicsDropdown  = ZO_ComboBox_ObjectFromContainer(self.dropMechanicsFiltersControl)
    self.dropMechanicsFiltersDropdown = dropMechanicsDropdown
    dropMechanicsDropdown:ClearItems()
    dropMechanicsDropdown:SetHideDropdownCallback(OnFilterChanged)
    local filterTypeText = getLocalizedText("dropMechanic")
    dropMechanicsDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    dropMechanicsDropdown:SetSortsItems(true)

    for dropMechanic, isValid in pairs(lib.allowedDropMechanics) do
        if isValid == true then
            local entry = dropMechanicsDropdown:CreateItemEntry(lib.GetDropMechanicName(dropMechanic))
            entry.filterType = dropMechanic
            dropMechanicsDropdown:AddItem(entry)
        end
    end

    -- Initialize the Drop locations multiselect combobox.
    local dropLocationsDropdown  = ZO_ComboBox_ObjectFromContainer(self.dropLocationsFiltersControl)
    self.dropLocationsFiltersDropdown = dropLocationsDropdown
    dropLocationsDropdown:ClearItems()
    dropLocationsDropdown:SetHideDropdownCallback(OnFilterChanged)
    local filterTypeText = getLocalizedText("droppedBy")
    dropLocationsDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    dropLocationsDropdown:SetSortsItems(true)

    local dropLocationNamesInClientLang = lib.GetAllDropLocationNames()
    if dropLocationNamesInClientLang ~= nil then
        for _, dropLocationName in pairs(dropLocationNamesInClientLang) do
            local entry = dropLocationsDropdown:CreateItemEntry(dropLocationName)
            entry.filterType = dropLocationName
            dropLocationsDropdown:AddItem(entry)
        end
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

    --LibSets._debug.armorTypes = armorTypes
    --LibSets._debug.weaponTypes = weaponTypes
    --LibSets._debug.equipmentTypes = equipmentTypes
    --LibSets._debug.enchantSearchCategoryTypes = enchantSearchCategoryTypes

    --Only 1 itemId:
    local itemIdsMatchingFilters
    if onlyOneItemId == true then
        local itemIdMatchingFilters = lib.GetSetItemId(setId, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
        --LibSets._debug.itemIdMatchingFilters = itemIdMatchingFilters
        if itemIdMatchingFilters ~= nil then
            itemIdsMatchingFilters = {}
            itemIdsMatchingFilters[itemIdMatchingFilters] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
        end
    else
        --All itemIds:
        itemIdsMatchingFilters = lib.GetSetItemIds(setId, nil, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
    end

    --LibSets._debug.itemIdsMatchingFilters = itemIdsMatchingFilters

    if itemIdsMatchingFilters ~= nil then
        relevantItemIds = {}
        for itemId, _ in pairs(itemIdsMatchingFilters) do
            relevantItemIds[#relevantItemIds + 1] = itemId
        end
        --Sort the itemIds so the same always are at the top
        table.sort(relevantItemIds)

        --d("LibSets_SearchUI_Keyboard:GetItemIdsForSetIdRespectingFilters-setId: " ..tostring(setId) .. ", itemId: " ..tostring(relevantItemIds[1]))
    end

    --LibSets._debug.relevantItemIds = relevantItemIds

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