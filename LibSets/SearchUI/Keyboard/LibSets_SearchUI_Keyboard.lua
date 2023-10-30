local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

local zoitf = zo_iconTextFormat
local getLocalizedText = lib.GetLocalizedText
local buildSetTypeInfo = lib.buildSetTypeInfo
local getDropMechanicTexture = lib.GetDropMechanicTexture
local libSets_GetSpecialZoneNameById = lib.GetSpecialZoneNameById
local getEquipSlotTexture = lib.GetEquipSlotTexture
local getArmorTypeTexture = lib.GetArmorTypeTexture
local getWeaponTypeTexture = lib.GetWeaponTypeTexture
local libSets_GetSetItemId = lib.GetSetItemId
local libSets_GetSetItemIds = lib.GetSetItemIds

--The search UI table
local searchUI = lib.SearchUI
local searchUIName = searchUI.name

local searchUIThrottledSearchHandlerName = searchUIName .. "_ThrottledSearch"
local searchUIThrottledDelay = 500

local MAX_NUM_SET_BONUS = searchUI.MAX_NUM_SET_BONUS


local favoriteIconText = searchUI.favoriteIconText


--Debugging - TODO: Disable again
--LibSets._debug = {} --todo remove after debugging/testing

--Local helper functions
local function addToIndexTable(t)
    if ZO_IsTableEmpty(t) then return end
    local retTab = {}
    for k,_ in pairs(t) do
        retTab[#retTab + 1] = k
    end
    return retTab
end

--Called from editbox filters -> OnTextChanged
local function refreshSearchFilters(selfVar, editBoxControl)
    --This would only refresh the currently prefiltered MasterList. But what if we changed any dropdown filter too?
    -->So changed to the StartSearch() function here now to properly update the last searchParams etc.
    --selfVar.resultsList:RefreshFilters()
    --Update the searchParams with the editbox text
    selfVar:OnFilterChanged(nil, editBoxControl)
    --Start the search now
    selfVar:StartSearch(nil, false)
end

local function onFilterDropdownEntryMouseEnterCallback(comboBox, entry)
    if not lib.svData or not lib.svData.setSearchTooltipsAtFilterEntries then return end
    if entry == nil or entry.m_data == nil or entry.m_data.tooltipText == nil then return end
    InitializeTooltip(InformationTooltip, entry, BOTTOM, 0, -10)
    SetTooltipText(InformationTooltip, entry.m_data.tooltipText)
end

local function onFilterDropdownEntryMouseExitCallback(comboBox, entry)
    ClearTooltip(InformationTooltip)
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
    self.searchEditBoxControl:SetDefaultText(getLocalizedText("nameTextSearch"))
    self.searchEditBoxControl:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, self.searchEditBoxControl, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, getLocalizedText("nameTextSearchTT"))
    end)
    self.searchEditBoxControl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip)  end)
    --ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
    self.searchEditBoxControl:SetHandler("OnTextChanged", function(editBoxCtrl)
        selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar, selfVar.searchEditBoxControl)
        selfVar:UpdateSearchHistory(editBoxCtrl)
    end)
    self.searchEditBoxControl:SetHandler("OnMouseUp", function(editBoxCtrl, mouseButton, upInside, shift, ctrl, alt, command)
        --d("[LibSets]LibSets_SearchUI_Keyboard - searchEditBox - OnMouseUp - upInside: " ..tostring(upInside))
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            selfVar:OnSearchEditBoxContextMenu(editBoxCtrl, shift, ctrl, alt, command)
        end
    end)

    self.bonusSearchEditBoxControl = filters:GetNamedChild("BonusTextSearchBox")
    self.bonusSearchEditBoxControl:SetDefaultText(getLocalizedText("bonusTextSearch"))
    self.bonusSearchEditBoxControl:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, self.bonusSearchEditBoxControl, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, getLocalizedText("bonusTextSearchTT"))
    end)
    self.bonusSearchEditBoxControl:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip)  end)
    --ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
    self.bonusSearchEditBoxControl:SetHandler("OnTextChanged", function(editBoxCtrl)
        selfVar:ThrottledCall(searchUIThrottledSearchHandlerName, searchUIThrottledDelay, refreshSearchFilters, selfVar, selfVar.bonusSearchEditBoxControl)
        selfVar:UpdateSearchHistory(editBoxCtrl)
    end)
    self.bonusSearchEditBoxControl:SetHandler("OnMouseUp", function(editBoxCtrl, mouseButton, upInside, shift, ctrl, alt, command)
        --d("[LibSets]LibSets_SearchUI_Keyboard - searchEditBox - OnMouseUp - upInside: " ..tostring(upInside))
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            selfVar:OnSearchEditBoxContextMenu(editBoxCtrl, shift, ctrl, alt, command)
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
    self.favoritesFiltersControl =                 filters:GetNamedChild("FavoritesFilter")
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
        self.favoritesFiltersControl,
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
        [self.favoritesFiltersControl] =                    "favorites",
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
    if slashOptions ~= nil and not ZO_IsTableEmpty(slashOptions) then
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
end

function LibSets_SearchUI_Keyboard:ShowUI(slashOptions)
    if not self.tooltipKeyboardHookWasDone then
        --Activate the LibSets toolip hooks at the LibSets set search preview tooltip so that the drop info is shown at the tooltip
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
    --EditBoxes
    for _, editBoxControl in ipairs(self.editBoxFilters) do
        self:SetSearchEditBoxValue(editBoxControl, "")
    end
    --Multiselect dropdowns
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        self:ResetMultiSelectDropdown(dropdownControl)
    end

    --Reset the buttons
    self:UpdateSearchButtonEnabledState(false)
end

function LibSets_SearchUI_Keyboard:ApplySearchParamsToUI()
    if not self:IsShown() then return end

    local searchParams = self.searchParams
    if searchParams == nil or ZO_IsTableEmpty(searchParams) then return end

    --Apply each searchParam entry to the UI's multiselect dropdown box, editfields, etc.
    --Multi select dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        local entriesToSelect = searchParams[self.multiSelectFilterDropdownToSearchParamName[dropdownControl]]
        if entriesToSelect ~= nil and not ZO_IsTableEmpty(entriesToSelect) then
            self:SetMultiSelectDropdownFilters(dropdownControl, entriesToSelect)
        end
    end

    --Edit fields
    for _, editBoxControl in ipairs(self.editBoxFilters) do
        local entryToSetText = searchParams[self.editBoxFilterToSearchParamName[editBoxControl]]
        if entryToSetText ~= nil then
            editBoxControl:SetText(entryToSetText) --this will start the search as OnTextChanged of the editBox will be called!
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

function LibSets_SearchUI_Keyboard:ValidateSearchParams()
    local searchWasValid = LibSets_SearchUI_Shared.ValidateSearchParams(self)
    if searchWasValid == nil then
        searchWasValid = true
    end
    return searchWasValid
end

function LibSets_SearchUI_Keyboard:StartSearch(doNotShowUI, wasReset)
    local searchWasValid = LibSets_SearchUI_Shared.StartSearch(self, doNotShowUI, wasReset)
    --Show error?
    if not searchWasValid then
        --Show error message
        d(libPrefix .. "-StartSearch: Search parameters were not valid!")
    end
    return searchWasValid
end


------------------------------------------------
--- Filters
------------------------------------------------
local SORT_BY_FILTERTYPE_NUMERIC =  { ["filterType"]    = { isNumeric = true } }
local SORT_BY_NAMECLEAN =           { ["nameClean"]     = {} }
local function sortFilterComboBox(setTypeDropdown, sortType)
    --Sort the entries of setTypeDropdown by their entry.filterType?
    if sortType == "filterType" then
        table.sort(setTypeDropdown.m_sortedItems, function(item1, item2)
            return ZO_TableOrderingFunction(item1, item2, "filterType", SORT_BY_FILTERTYPE_NUMERIC, setTypeDropdown.m_sortOrder)
        end)
    elseif sortType == "nameClean" then
        table.sort(setTypeDropdown.m_sortedItems, function(item1, item2)
            return ZO_TableOrderingFunction(item1, item2, "nameClean", SORT_BY_NAMECLEAN, setTypeDropdown.m_sortOrder)
        end)
    end
end

function LibSets_SearchUI_Keyboard:InitializeFilters()
    local function OnFilterChanged(dropdownControl)
        self:OnFilterChanged(dropdownControl)
    end

    --Initialize the search button: Disabled (until any filter get's changed)
    self:UpdateSearchButtonEnabledState(false)

    -- Initialize the Set Types multiselect combobox.
    local setTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.setTypeFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        setTypeDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.setTypeFiltersDropdown = setTypeDropdown
    setTypeDropdown:ClearItems()
    setTypeDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.setTypeFiltersControl) end)
    local filterTypeText = getLocalizedText("setType")
    self.setTypeFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        setTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    setTypeDropdown:SetSortsItems(false)

    for setType, isValid in pairs(lib.allowedSetTypes) do
        if isValid == true then
            local setTypeName, setTypeTexture = buildSetTypeInfo({setType = setType}, true)
            local setTypeNameStr = setTypeName
            if setTypeTexture ~= nil then
                setTypeNameStr = zoitf(setTypeTexture, 24, 24, setTypeName, nil)
            end
            local entry = setTypeDropdown:CreateItemEntry(setTypeNameStr)
            entry.filterType = setType
            entry.nameClean = setTypeName
            setTypeDropdown:AddItem(entry)
        end
    end
    sortFilterComboBox(setTypeDropdown, "nameClean")

    -- Initialize the armor Types multiselect combobox.
    local armorTypeDropdown     = ZO_ComboBox_ObjectFromContainer(self.armorTypeFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        armorTypeDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.armorTypeFiltersDropdown = armorTypeDropdown
    armorTypeDropdown:ClearItems()
    armorTypeDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.armorTypeFiltersControl) end)
    local filterTypeText = getLocalizedText("armorType")
    self.armorTypeFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        armorTypeDropdown:EnableMultiSelect(SI_ITEM_SETS_BOOK_APPAREL_TYPES_DROPDOWN_TEXT, getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    armorTypeDropdown:SetSortsItems(false)

    for armorType, _ in pairs(lib.armorTypesSets) do
        local _, armorTypeNameStr, armorTypeName = getArmorTypeTexture(armorType)
        local entry = armorTypeDropdown:CreateItemEntry(armorTypeNameStr)
        entry.filterType = armorType
        entry.nameClean = armorTypeName
        armorTypeDropdown:AddItem(entry)
    end
    sortFilterComboBox(armorTypeDropdown, "nameClean")

    -- Initialize the weapon Types multiselect combobox.
    local weaponTypeDropdown    = ZO_ComboBox_ObjectFromContainer(self.weaponTypeFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        weaponTypeDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.weaponTypeFiltersDropdown = weaponTypeDropdown
    weaponTypeDropdown:ClearItems()
    weaponTypeDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.weaponTypeFiltersControl) end)
    local filterTypeText = getLocalizedText("weaponType")
    self.weaponTypeFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        weaponTypeDropdown:EnableMultiSelect(SI_ITEM_SETS_BOOK_WEAPON_TYPES_DROPDOWN_TEXT, getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    weaponTypeDropdown:SetSortsItems(false)

    for weaponType, _ in pairs(lib.weaponTypesSets) do
        local _, weaponTypeNameStr, weaponTypeName = getWeaponTypeTexture(weaponType)
        local entry = weaponTypeDropdown:CreateItemEntry(weaponTypeNameStr)
        entry.filterType = weaponType
        entry.nameClean = weaponTypeName
        weaponTypeDropdown:AddItem(entry)
    end
    sortFilterComboBox(weaponTypeDropdown, "nameClean")

    -- Initialize the equipment Types multiselect combobox.
    local equipmentTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.equipmentTypeFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        equipmentTypeDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.equipmentTypeFiltersDropdown = equipmentTypeDropdown
    equipmentTypeDropdown:ClearItems()
    equipmentTypeDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.equipmentTypeFiltersControl) end)
    local filterTypeText = getLocalizedText("equipmentType")
    self.equipmentTypeFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        equipmentTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    equipmentTypeDropdown:SetSortsItems(false)

    --local alreadyCheckedEquipTypes = {}
    for equipType, isValid in pairs(lib.equipTypesValid) do
        if isValid == true then
            local _, equipTypeNameStr, equipTypeName = getEquipSlotTexture(equipType)
            local entry = equipmentTypeDropdown:CreateItemEntry(equipTypeNameStr)
            entry.filterType = equipType
            entry.nameClean = equipTypeName
            equipmentTypeDropdown:AddItem(entry)
        end
    end
    sortFilterComboBox(equipmentTypeDropdown, "nameClean")


    -- Initialize the DLC Types multiselect combobox.
    local DLCIdDropdown       = ZO_ComboBox_ObjectFromContainer(self.DCLIdFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        DLCIdDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.DLCIdFiltersDropdown = DLCIdDropdown
    DLCIdDropdown:ClearItems()
    DLCIdDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.DCLIdFiltersControl) end)
    local filterTypeText = getLocalizedText("dlc")
    self.DCLIdFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        DLCIdDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    DLCIdDropdown:SetSortsItems(true)

    for DLCId, isValid in pairs(lib.allowedDLCIds) do
        if isValid == true then
            local entry = DLCIdDropdown:CreateItemEntry(lib.GetDLCName(DLCId))
            entry.filterType = DLCId
            DLCIdDropdown:AddItem(entry)
        end
    end

    -- Initialize the enchantment search category Types multiselect combobox.
    local enchantmentSearchCategoryTypeDropdown = ZO_ComboBox_ObjectFromContainer(self.enchantSearchCategoryTypeFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        enchantmentSearchCategoryTypeDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.enchantSearchCategoryTypeFiltersDropdown = enchantmentSearchCategoryTypeDropdown
    enchantmentSearchCategoryTypeDropdown:ClearItems()
    enchantmentSearchCategoryTypeDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.enchantSearchCategoryTypeFiltersControl) end)
    local filterTypeText = getLocalizedText("enchantmentSearchCategory")
    self.enchantSearchCategoryTypeFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        enchantmentSearchCategoryTypeDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    enchantmentSearchCategoryTypeDropdown:SetSortsItems(true)

    for enchantSearchCategoryType, isValid in pairs(lib.enchantSearchCategoryTypesValid) do
        if isValid == true and enchantSearchCategoryType ~= "all" then
            local enchantmentSearchCategoryName = GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", enchantSearchCategoryType)
            if enchantmentSearchCategoryName ~= nil and enchantmentSearchCategoryName ~= "" then
                local entry = enchantmentSearchCategoryTypeDropdown:CreateItemEntry(enchantmentSearchCategoryName)
                entry.filterType = enchantSearchCategoryType
                enchantmentSearchCategoryTypeDropdown:AddItem(entry)
            end
        end
    end

    -- Initialize the Favorite sets multiselect combobox.
    local favoritesDropdown = ZO_ComboBox_ObjectFromContainer(self.favoritesFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        favoritesDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.favoritesDropdown = favoritesDropdown
    favoritesDropdown:ClearItems()
    favoritesDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.favoritesFiltersControl) end)
    local filterTypeText = GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER)
    self.favoritesFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        favoritesDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    favoritesDropdown:SetSortsItems(false)

    local entry = favoritesDropdown:CreateItemEntry(GetString(SI_ARMORTYPE0))
    entry.filterType = 0
    entry.nameClean = "No favorite"
    favoritesDropdown:AddItem(entry)
    entry = favoritesDropdown:CreateItemEntry(favoriteIconText .. " " .. GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER))
    entry.filterType = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
    entry.nameClean = "Favorite"
    favoritesDropdown:AddItem(entry)

    -- Initialize the Number of bonuses multiselect combobox.
    local numBonusDropdown = ZO_ComboBox_ObjectFromContainer(self.numBonusFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        numBonusDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.numBonusFiltersDropdown = numBonusDropdown
    numBonusDropdown:ClearItems()
    numBonusDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.numBonusFiltersControl) end)
    local filterTypeText = getLocalizedText("numBonuses")
    self.numBonusFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        numBonusDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    numBonusDropdown:SetSortsItems(true)

    for numBonus=1, MAX_NUM_SET_BONUS, 1 do
        local entry = numBonusDropdown:CreateItemEntry(tostring(numBonus))
        entry.filterType = numBonus
        numBonusDropdown:AddItem(entry)
    end

    -- Initialize the Drop zones multiselect combobox.
    local dropZoneDropdown      = ZO_ComboBox_ObjectFromContainer(self.dropZoneFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        dropZoneDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.dropZoneFiltersDropdown = dropZoneDropdown
    dropZoneDropdown:ClearItems()
    dropZoneDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.dropZoneFiltersControl) end)
    local filterTypeText = getLocalizedText("dropZones")
    self.dropZoneFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        dropZoneDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    dropZoneDropdown:SetSortsItems(true)

    local dropZoneIds = lib.GetAllDropZones()
    if dropZoneIds ~= nil then
        for dropZoneId, isValid in pairs(dropZoneIds) do
            if isValid == true then
                local dropZoneName, zoneDesc, filterType
                if dropZoneId <= 0 then
                    dropZoneName = libSets_GetSpecialZoneNameById(dropZoneId)
                    filterType = dropZoneId
                else
                    --[[
                    local mapId = GetMapIdByZoneId(dropZoneId)
                    if mapId ~= nil then
                        dropZoneName = zo_strformat(SI_UNIT_NAME, GetMapInfoById(mapId))
                    end
                    if dropZoneName == "" then
                    ]]
                    dropZoneName = zo_strformat(SI_UNIT_NAME, GetZoneNameById(dropZoneId))
                    --end
                    zoneDesc = GetZoneDescriptionById(dropZoneId)
                    filterType = dropZoneId
                end
                local entry = dropZoneDropdown:CreateItemEntry(dropZoneName)
                if zoneDesc ~= nil and zoneDesc ~= "" then
                    entry.tooltipText = zoneDesc
                end
                entry.filterType = filterType
                dropZoneDropdown:AddItem(entry)
            end
        end
    end

    -- Initialize the Drop mechanics multiselect combobox.
    local dropMechanicsDropdown  = ZO_ComboBox_ObjectFromContainer(self.dropMechanicsFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        dropMechanicsDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.dropMechanicsFiltersDropdown = dropMechanicsDropdown

    dropMechanicsDropdown:ClearItems()
    dropMechanicsDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.dropMechanicsFiltersControl) end)
    local filterTypeText = getLocalizedText("dropMechanic")
    self.dropMechanicsFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        dropMechanicsDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
    dropMechanicsDropdown:SetSortsItems(false)

    for dropMechanicId, isValid in pairs(lib.allowedDropMechanics) do
        if isValid == true then
            local dropMechnicNameStr
            local dropMechanicName, dropMechanicTooltip = lib.GetDropMechanicName(dropMechanicId)
            dropMechnicNameStr = dropMechanicName
            local dropMechnicTexture = getDropMechanicTexture(dropMechanicId)
            if dropMechnicTexture ~= nil then
                dropMechnicNameStr = zoitf(dropMechnicTexture, 24, 24, dropMechanicName, nil)
            end
            local entry = dropMechanicsDropdown:CreateItemEntry(dropMechnicNameStr)
            if dropMechanicTooltip ~= nil and dropMechanicTooltip ~= "" then
                entry.tooltipText = dropMechanicTooltip
            end
            entry.filterType = dropMechanicId
            entry.nameClean = dropMechanicName
            dropMechanicsDropdown:AddItem(entry)
        end
    end
    sortFilterComboBox(dropMechanicsDropdown, "nameClean")

    -- Initialize the Drop locations multiselect combobox.
    local dropLocationsDropdown  = ZO_ComboBox_ObjectFromContainer(self.dropLocationsFiltersControl)
    if ZO_ComboBox.SetEntryMouseOverCallbacks ~= nil then
        dropLocationsDropdown:SetEntryMouseOverCallbacks(onFilterDropdownEntryMouseEnterCallback, onFilterDropdownEntryMouseExitCallback)
    end
    self.dropLocationsFiltersDropdown = dropLocationsDropdown
    dropLocationsDropdown:ClearItems()
    dropLocationsDropdown:SetHideDropdownCallback(function() OnFilterChanged(self.dropLocationsFiltersControl) end)
    local filterTypeText = getLocalizedText("droppedBy")
    self.dropLocationsFiltersControl.tooltipText = filterTypeText
    if ZO_ComboBox.EnableMultiSelect ~= nil then
        dropLocationsDropdown:EnableMultiSelect(getLocalizedText("multiSelectFilterSelectedText", nil, filterTypeText, filterTypeText), getLocalizedText("noMultiSelectFiltered", nil, filterTypeText))
    end
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
    if searchParams == nil or ZO_IsTableEmpty(searchParams) then return false end

    --Multiselect dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        if self.isItemIdRelevantMultiSelectFilterDropdown[dropdownControl] then
            local searchParamEntryKey = self.multiSelectFilterDropdownToSearchParamName[dropdownControl]
            local searchParamEntry = searchParams[searchParamEntryKey]
            if searchParamEntry ~= nil and not ZO_IsTableEmpty(searchParamEntry) then
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
    if searchParams == nil or ZO_IsTableEmpty(searchParams) then return false end

    --Multiselect dropdown boxes
    for _, dropdownControl in ipairs(self.multiSelectFilterDropdowns) do
        if self.isItemIdRelevantMultiSelectFilterDropdown[dropdownControl] then
            local searchParamKey = self.multiSelectFilterDropdownToSearchParamName[dropdownControl]
            local searchParamEntry = searchParams[searchParamKey]
            if searchParamEntry ~= nil and not ZO_IsTableEmpty(searchParamEntry) then
                searchParamKeysOfItemIdAffectingFilters[searchParamKey] = true
            end
        end
    end

    --Edit fields
    -->Currently no itemId changes

    return searchParamKeysOfItemIdAffectingFilters
end

-->Get the itemIds matching the searchParam entries of the multiselect dropdown boxes, and other filter controls, which change the
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

    --Only 1 itemId:
    local itemIdsMatchingFilters
    if onlyOneItemId == true then
        local itemIdMatchingFilters = libSets_GetSetItemId(setId, nil, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
        --LibSets._debug.itemIdMatchingFilters = itemIdMatchingFilters
        if itemIdMatchingFilters ~= nil then
            itemIdsMatchingFilters = {}
            itemIdsMatchingFilters[itemIdMatchingFilters] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK
        end
    else
        --All itemIds:
        itemIdsMatchingFilters = libSets_GetSetItemIds(setId, nil, equipmentTypes, traitTypes, enchantSearchCategoryTypes, armorTypes, weaponTypes)
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
function LibSets_SearchUI_Keyboard:OnFilterChanged(dropdownControl, editControl)
    --d("[LibSets_SearchUI_Keyboard]OnFilterChanged - MultiSelect dropdown - hidden")
    LibSets_SearchUI_Shared.OnFilterChanged(self, dropdownControl)
    local didAnyFilterChange = false

    local searchParams = {}
    if editControl == nil then
        if dropdownControl == nil then
            --Multiselect dropdown boxes
            for _, lDropdownControl in ipairs(self.multiSelectFilterDropdowns) do
                local selectedEntries = self:GetSelectedMultiSelectDropdownFilters(lDropdownControl)
                if selectedEntries ~= nil then
                    if ZO_IsTableEmpty(selectedEntries) then
                        selectedEntries = nil --make it nil so the searchParams can be totally empty -> For self:DidAnyFilterChange() check
                    end
                    searchParams[self.multiSelectFilterDropdownToSearchParamName[lDropdownControl]] = selectedEntries

                    didAnyFilterChange = true
                end
            end
        else
            --Single dropdown filters did change
            local selectedEntries = self:GetSelectedMultiSelectDropdownFilters(dropdownControl)
            if selectedEntries ~= nil then
                if ZO_IsTableEmpty(selectedEntries) then
                    selectedEntries = nil --make it nil so the searchParams can be totally empty -> For self:DidAnyFilterChange() check
                end
                self.searchParams[self.multiSelectFilterDropdownToSearchParamName[dropdownControl]] = selectedEntries

                didAnyFilterChange = true
            end
        end
    end

    --Editboxes
    if dropdownControl == nil then
        if editControl == nil then
            for _, editBoxControl in ipairs(self.editBoxFilters) do
                searchParams[self.editBoxFilterToSearchParamName[editBoxControl]] = editBoxControl:GetText()

                didAnyFilterChange = true
            end

        else
            self.searchParams[self.editBoxFilterToSearchParamName[editControl]] = editControl:GetText()

            didAnyFilterChange = true
        end
    end


    lib._debugSearchUIKeyboardSelf = self

    --Enable the search button again now?
    if didAnyFilterChange == true then
        if dropdownControl == nil and editControl == nil then
            self.searchParams = searchParams
        end

        --Check if the search params changed compared to last search params
        local isSearchButtonEnabled = self:DidAnyFilterChange()
        self:UpdateSearchButtonEnabledState(isSearchButtonEnabled)
    end
end

------------------------------------------------
--- Handlers
------------------------------------------------
function LibSets_SearchUI_Keyboard:OnRowMouseEnter(rowControl)
    self.resultsList:Row_OnMouseEnter(rowControl)

    self.tooltipControl.data = rowControl.data
    self:ShowItemLinkTooltip(self.control, rowControl.data, nil, nil, nil, nil)

    self:ShowSetDropLocationTooltip(rowControl, rowControl.data)
end

function LibSets_SearchUI_Keyboard:OnRowMouseExit(rowControl)
    self.resultsList:Row_OnMouseExit(rowControl)

    self:HideItemLinkTooltip()
    self.tooltipControl.data = nil
end

function LibSets_SearchUI_Keyboard:OnRowMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
    if upInside then
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            self:ItemLinkToChat(rowControl.data)
        elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowRowContextMenu(rowControl)
        end
    end
end

function LibSets_SearchUI_Keyboard:OnDropdownMouseUp(dropdownControl, mouseButton, upInside, shift, alt, ctrl, command)
    if upInside then
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowDropdownContextMenu(dropdownControl, shift, alt, ctrl, command)
        end
    end
end


--[[ XML Handlers ]]--
function LibSets_SearchUI_Keyboard_TopLevel_OnInitialized(self)
	LIBSETS_SEARCH_UI_KEYBOARD = LibSets_SearchUI_Keyboard:New(self)
end