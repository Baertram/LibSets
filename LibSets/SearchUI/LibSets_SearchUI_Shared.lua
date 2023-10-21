local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

local zif = zo_iconFormat
local zoitfns = zo_iconTextFormatNoSpace
local tos = tostring
local sgmatch = string.gmatch
local tins = table.insert
local tcon = table.concat


local clientLang = lib.clientLang
local langAllowedCheck = lib.LangAllowedCheck

local getLocalizedText = lib.GetLocalizedText
local libSets_GetSetInfo = lib.GetSetInfo
--local libSets_getDropMechanicAndDropLocationNames = lib.GetDropMechanicAndDropLocationNames
local libSets_GetDropLocationNamesBySetId = lib.GetDropLocationNamesBySetId
local libSets_GetDropMechanic = lib.GetDropMechanic
local libSets_GetDropZonesBySetId = lib.GetDropZonesBySetId
local libSets_buildItemLink = lib.buildItemLink
local libSets_GetSetFirstItemId = lib.GetSetFirstItemId
local libSets_GetSetEnchantSearchCategories = lib.GetSetEnchantSearchCategories
local libSets_IsEquipTypeSet = lib.IsEquipTypeSet
local libSets_IsWeaponTypeSet = lib.IsWeaponTypeSet
local libSets_IsArmorTypeSet = lib.IsArmorTypeSet

local gilsi = GetItemLinkSetInfo

--Textures
local favoriteIcon = "EsoUI/Art/Collections/Favorite_StarOnly.dds"

--The search UI table
lib.SearchUI = {}
local searchUI = lib.SearchUI
searchUI.name = MAJOR .. "_SearchUI"
local searchUIName = searchUI.name
searchUI.favoriteIcon = favoriteIcon
searchUI.favoriteIconText = zif(favoriteIcon, 24, 24)
local favoriteIconText = searchUI.favoriteIconText
local favoriteIconWithNameText = zoitfns(favoriteIcon, 24, 24, GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER))
local settingsIconText = zif("esoui/art/chatwindow/chat_options_up.dds", 32, 32)

--Maximum number of set bonuses
searchUI.MAX_NUM_SET_BONUS = 6 --2023-09-09

--Search type - For the string comparison "processor". !!!Needs to match the SetupRow of the ZO_ScrollList!!!
searchUI.searchTypeDefault = 1

--Scroll list datatype - Default text
searchUI.scrollListDataTypeDefault = 1

--The copy text dialog
local copyDialog


--Helper functions
local function string_split (inputstr, sep)
    sep = sep or "%s"
    local t={}
    for str in sgmatch(inputstr, "([^"..sep.."]+)") do
        tins(t, str)
    end
    return t
end

local wasSetsDataScannedAndAdded = false
local function scanAndAddDataToSetsMasterListBase(defaultMasterListBase, p_setId, p_setData)
--d("[LibSets]addDropLocationDataToSetsMasterListBase")
    if p_setId ~= nil and p_setData ~= nil then
        p_setData.setId = p_setData.setId or p_setId
        --setData might be missing dropMechanicLocations and other data needed! So we will create it once per setId
        if p_setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] == nil or p_setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] == nil then
            p_setData = libSets_GetSetInfo(p_setId, false, nil)
        end
        return p_setData
    else
        for setId, setData in pairs(defaultMasterListBase) do
            setData.setId = setData.setId or setId
            --setData might be missing dropMechanicLocations and other data needed! So we will create it once per setId
            if setData[LIBSETS_TABLEKEY_DROPMECHANIC_NAMES] == nil or setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] == nil then
                setData = libSets_GetSetInfo(setId, false, nil)
                defaultMasterListBase[setId] = setData
            end
        end
        wasSetsDataScannedAndAdded = true
        return defaultMasterListBase
    end
end

--Add the drop locations, zoneIds, dropLocationNames, enchantSearchCategories per setId -> if missing
local function updateSetsInfoWithDataAndNames(selfVar)
    -->!!!This might lag the client for a few seconds on first open of the search UI!!!
    if not wasSetsDataScannedAndAdded then
        local setsData = lib.setInfo
        local setsDataNew = scanAndAddDataToSetsMasterListBase(setsData, nil, nil)
        lib.setInfo = setsDataNew

        --Now refresh the ZO_SortFilterList -> Call BuildMasterList etc.
        selfVar.resultsList:RefreshData()
    end
end

local function setMenuItemCheckboxState(checkboxIndex, newState)
    newState = newState or false
    if newState == true then
        ZO_CheckButton_SetChecked(ZO_Menu.items[checkboxIndex].checkbox)
    else
        ZO_CheckButton_SetUnchecked(ZO_Menu.items[checkboxIndex].checkbox)
    end
end

-- called from clicking the "Auto reload" label
local function OnClick_CheckBoxLabel(cbControl, currentStateVar, selfVar)
    if lib.svData[currentStateVar] == nil then return end
    local currentState = lib.svData[currentStateVar]
    local newState = not currentState
    lib.svData[currentStateVar] = newState

    --Shall the setNames be shown with/without english names? Update the list now by refreshing it and building the master list etc. new
    if selfVar ~= nil then
        if currentStateVar == "setSearchShowSetNamesInEnglishToo" then
            selfVar.resultsList:RefreshData()
        end
    end
end

local function isItemFilterTypeMatching(item, filterType)
    return item.filterType ~= nil and item.filterType == filterType
end


------------------------------------------------------------------------------------------------------------------------
--Search UI shared class for keyboard and gamepad mode
------------------------------------------------------------------------------------------------------------------------
LibSets_SearchUI_Shared = ZO_InitializingObject:Subclass()

------------------------------------------------
--- Initialization
------------------------------------------------
function LibSets_SearchUI_Shared:Initialize(control)
    self.control = control
    control._object = self

    local filters = self.control:GetNamedChild("Filters")
    self.filtersControl = filters
    local content = self.control:GetNamedChild("Content")
    self.contentControl = content

    self.lastSearchParams = nil --the last used searchParams
    self.searchParams = nil
    --searchParams is a table with the following possible entries
    -->See function LibSets_SearchUI_Shared:OnFilterChanged()
    --[[
    searchParams = {
        --Edit fields
        names = "hunding,121, 124, test",                              --String with the names or setIds, comma separated
        bonuses = "+weapon damage,-magicka",                           --String with the bonus description contents, comma separated (use prefix + to include, or - to exclude)

        --Multiselect dropdowns
        setTypes = {[1]=true, [2]=true, [3]=true}                       --The set type selected at the multiselect dropdown box
        armorTypes = {[1]=true, [2]=true, [3]=true}                     --The armor type selected at the multiselect dropdown box
        weaponTypes = {[1]=true, [2]=true, [3]=true}                    --The weapon type selected at the multiselect dropdown box
        equipmentTypes = {[1]=true, [2]=true, [3]=true}                 --The equipment slot (head, shoulders, body, ...) selected at the multiselect dropdown box
        dlcIds = {[1]=true, [2]=true, [3]=true}                         --The DLC type selected at the multiselect dropdown box
        enchantSearchCategoryTypes = { {[1]=true, [2]=true, [3]=true}   --The enchantment search category types selected at the multiselect dropdown box
        numBonuses = { {[1]=true, [2]=true, [3]=true}                   --The number of bonuses selected at the multiselect dropdown box
    }
    ]]

    --self.searchDoneCallback = nil --callback function called as a search was done
    --self.searchErrorCallback = nil --callback function called as a search was not done due to any error
    --self.searchCanceledCallback = nil --callback function called as a search was canceled


    --ZO_StringSearch - For string comparison of setNames and setBonus
	self.stringSearch = ZO_StringSearch:New()
	self.stringSearch:AddProcessor(searchUI.searchTypeDefault, function(stringSearch, data, searchTerm, cache)
        return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache))
    end)
end


------------------------------------------------
--- Callbacks
------------------------------------------------
function LibSets_SearchUI_Shared:SetSearchCallbacks(searchDoneCallback, searchErrorCallback, searchCanceledCallback)
	--Callbacks
    self.searchDoneCallback =       searchDoneCallback
    self.searchErrorCallback =      searchErrorCallback
    self.searchCanceledCallback =   searchCanceledCallback
end


------------------------------------------------
--- Reset
------------------------------------------------
function LibSets_SearchUI_Shared:ResetInternal()
    --Reset internal data like the search parameters
    self.searchParams = nil

    --Reset callbacks (but they won't get applied then anymore as this only happens at the self:Show(...) function,
    --or if manually added via LibSets_SearchUI_Shared:SetSearchCallbacks(searchDoneCallback, searchErrorCallback, searchCanceledCallback)
    --self:SetSearchCallbacks(nil, nil, nil)
end

function LibSets_SearchUI_Shared:ResetUI() --override
    --Reset all UI elements to the default values
end

function LibSets_SearchUI_Shared:Reset()
    --Reset all data, internal and the chanegd UI elements
    self:ResetInternal()
    self:ResetUI()
    --Apply the search without any criteria now
    self:StartSearch(nil, true)
end

function LibSets_SearchUI_Shared:ResetMultiSelectDropdown(dropdownControl)
    if dropdownControl.m_comboBox ~= nil then
        --Keyboard
        dropdownControl.m_comboBox:ClearAllSelections()
    else
        --Gamepad
        dropdownControl:ClearAllSelections()
    end
end

function LibSets_SearchUI_Shared:SelectMultiSelectDropdownEntries(dropdownControl, entriesToSelect, refreshResultsListAfterwards)
d("LibSets_SearchUI_Shared:SelectMultiSelectDropdownEntries")
lib._debugDropDownControl = dropdownControl
    refreshResultsListAfterwards = refreshResultsListAfterwards or false
    if entriesToSelect == nil or ZO_IsTableEmpty(entriesToSelect) then return end
    local comboBox = dropdownControl.m_comboBox
    if comboBox ~= nil then
        comboBox:ClearAllSelections()
        for _, filterType in ipairs(entriesToSelect) do
            local index = comboBox:GetIndexByEval(function(item) return isItemFilterTypeMatching(item, filterType) end )
            if index ~= nil then
                dropdownControl.m_comboBox:SetSelected(index, true)
            end
        end

        if refreshResultsListAfterwards == true then
            self:OnFilterChanged(dropdownControl)
            self:StartSearch(nil, false)
        end
    end
end

------------------------------------------------
--- UI
------------------------------------------------
function LibSets_SearchUI_Shared:IsShown()
    return not self.control:IsHidden()
end

function LibSets_SearchUI_Shared:ShowUI()
--d("LibSets_SearchUI_Shared:ShowUI")
    if self:IsShown() then return end
    --Run once at first UI open, so it does not run on each reloadUI!
    -->Could lag the client for ~2 seconds on initial show of UI
    updateSetsInfoWithDataAndNames(self)

    self.control:SetHidden(false)

    --Fire callback for "UI is shown"
    CM:FireCallbacks(searchUIName .. "_IsShown", self)
end

function LibSets_SearchUI_Shared:HideUI()
    if not self:IsShown() then return end
    self.control:SetHidden(true)

    --Fire callback for "UI is hidden"
    CM:FireCallbacks(searchUIName .. "_IsHidden", self)
end

--Show the Search UI and optionally pass in some searchParameters and/or callback functions
--if the searchParams are passed in the search UI will set the values at the multiselect dropdowns and editboxes accordingly
-->See format of searchParams at the Initialize function of this class, above!
function LibSets_SearchUI_Shared:Show(searchParams, searchDoneCallback, searchErrorCallback, searchCanceledCallback)

    if searchParams ~= nil and not ZO_IsTableEmpty(searchParams) then
        --Search parameters, passed in (preset UI elements with them, if provided)
        self.searchParams = searchParams

        self:ApplySearchParamsToUI()
    end

	--Callbacks
    self:SetSearchCallbacks(searchDoneCallback, searchErrorCallback, searchCanceledCallback)

    --Show the UI now
    self:ShowUI()
end

function LibSets_SearchUI_Shared:ToggleUI(slashOptions)
    if self:IsShown() then self:HideUI() else self:ShowUI(slashOptions) end
end


function LibSets_SearchUI_Shared:UpdateSearchButtonEnabledState(isEnabled)
d("LibSets_SearchUI_Shared:UpdateSearchButtonEnabledState-isEnabled: " ..tos(isEnabled))
    if isEnabled == nil then return end
    local searchButton = self.searchButton
    if searchButton == nil then return end
    searchButton:SetEnabled(isEnabled)
    searchButton:SetMouseEnabled(isEnabled)
end


------------------------------------------------
--- Search
------------------------------------------------
function LibSets_SearchUI_Shared:GetSetNameSearchString(tableOrString)
    --Build the search string from the slashOptions
    local setNameStr
    if type(tableOrString) == "table" then
        if #tableOrString > 0 then
            setNameStr = tcon(tableOrString, " ")
        else
            return
        end
    else
        setNameStr = tos(tableOrString)
    end
    return setNameStr
end


function LibSets_SearchUI_Shared:Cancel()
--d("[LibSets]LibSets_SearchUI_Shared:Cancel")

    --Fire callback for "Search was canceled"
    CM:FireCallbacks(searchUIName .. "_SearchCanceled", self)

	if self.searchCanceledCallback then
        self.searchCanceledCallback(self)
	end

    --Reset internal data
    self:ResetInternal()

    --Hide the UI again
    self:HideUI()
end

function LibSets_SearchUI_Shared:ValidateSearchParams()  --override
d("[LibSets]LibSets_SearchUI_Shared:ValidateSearchParams")
    --Validate the search parameters and raise an error message if something does not match
end

function LibSets_SearchUI_Shared:StartSearch(doNotShowUI, wasReset)
d("[LibSets]LibSets_SearchUI_Shared:StartSearch-doNotShowUI: " ..tos(doNotShowUI) .. ", wasReset: " ..tos(wasReset))
    wasReset = wasReset or false
    --Fire callback for "Search was started"
    CM:FireCallbacks(searchUIName .. "_SearchBegin", self, doNotShowUI, wasReset)

    --Validate the search parameters
    if self:ValidateSearchParams() == true then
        --Save the last used search params for later comparison/same search
        -->If we did not reset the search
        if not wasReset then
            self.lastSearchParams = ZO_ShallowTableCopy(self.searchParams)
        else
            --Nil the last search params so next changes at any filter cannot "accidently get the same" and disable the search button later
            self.lastSearchParams = nil
        end

        --Set the search button's enabled state to false so no "same" search can be done
        self:UpdateSearchButtonEnabledState(false)

        --Update the results list now
        if self.resultsList ~= nil then
            --At "BuildMasterList" the self.searchParams will be pre-filtered, and at FilterScrollList the text search filters will be added
            self.resultsList:RefreshData() --> -- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
            return true
        end
    end
    return false
end

--Start the search now
--If parameter doNotShowUI is true the search will be done without opening the UI
--You can optionally pass in searchParams which will be used to do the search. If none are specified the UI's searchParams will be used (multiselect dropdowns, editboxes, ...)
-->See format of searchParams at the Initialize function of this class, above!
function LibSets_SearchUI_Shared:Search(doNotShowUI, searchParams)
d("[LibSets]LibSets_SearchUI_Shared:Search")
    doNotShowUI = doNotShowUI or false

    if not doNotShowUI and not self:IsShown() then return end

    --Search parameters were passed in? Take them then
    if searchParams ~= nil then
        self.searchParams = searchParams
    end

	--Inherited keyboard / gamepad mode search will be done at the relating class function LibSets_SearchUI_Keyboard/Gamepad:Search() function call!
    -->See other classes' functions

    --Start the search now, based on input parameters
    if self:StartSearch(doNotShowUI) == true then
d(">Search was started")
        --Is a "search was done" callback function registered?
        if self.searchDoneCallback then
            self.searchDoneCallback(self)
        end
    else
d("<Search NOT started")
        --Is a "search was not done due to any error" callback function registered?
        if self.searchErrorCallback then
            self.searchErrorCallback(self)
        end
    end
end



------------------------------------------------
--- Search filters
------------------------------------------------
local function orderedSearch(haystack, needles)
	-- A search for "spell damage" should match "Spell and Weapon Damage" but
	-- not "damage from enemy spells", so search term order must be considered
	haystack = haystack:lower()
	needles = needles:lower()
	local i = 0
	--for needle in needles:gmatch("%S+") do -- No whitespace
    for needle in needles:gmatch("[^,]+") do --No ,
		i = haystack:find(needle, i + 1, true)
		if not i then return false end
	end
	return true
end

local function searchFilterPrefix(searchInput, searchTab)
	local curpos = 1
	local delim
	local exclude = false
    --Check the searchInput for prefix + (include) or - (exclude) and split at , to find all
    --entries in the table searchTab (e.g. bonuses)
	repeat
		local found = false
		delim = searchInput:find("[+,-]", curpos)
		if not delim then delim = 0 end
		local searchQuery = searchInput:sub(curpos, delim - 1)
		--if searchQuery:find("%S+") then   --find no whitepaces
        if searchQuery:find("[^,]+") then      --find no ,
			for i = 1, #searchTab do
				if orderedSearch(searchTab[i], searchQuery) then
					found = true
					break
				end
			end

			if found == exclude then return false end
		end
		curpos = delim + 1
		if delim ~= 0 then exclude = searchInput:sub(delim, delim) == "-" end
	until delim == 0
	return true
end

function LibSets_SearchUI_Shared:CheckForMatch(data, searchInput)
--d("[LibSets_SearchUI_Shared:CheckForMatch]searchInput: " .. tos(searchInput))
    --Search by name or setId
    local namesOrIdsTab = {}
    tins(namesOrIdsTab, data.name)
    tins(namesOrIdsTab, tos(data.setId))
    return searchFilterPrefix(searchInput, namesOrIdsTab)
end


function LibSets_SearchUI_Shared:ProcessItemEntry(stringSearch, data, searchTerm)
--d("[LibSets_SearchUI_Keyboard.ProcessItemEntry] stringSearch: " ..tos(stringSearch) .. ", setName: " .. tos(data.nameLower) .. ", searchTerm: " .. tos(searchTerm))
	if zo_plainstrfind(data.nameLower, searchTerm) then
		return true
	end
	return false
end

function LibSets_SearchUI_Shared:SearchSetBonuses(bonuses, searchInput)
    return searchFilterPrefix(searchInput, bonuses)
end


------------------------------------------------
--- Filters
------------------------------------------------
function LibSets_SearchUI_Shared:OnFilterChanged(dropdownControl)
d("[LibSets_SearchUI_Shared]OnFilterChanged - MultiSelect dropdown - hidden")
    self.searchParams = self.searchParams or {}
end

function LibSets_SearchUI_Shared:DidAnyFilterChange()
d("[LibSets_SearchUI_Shared]DidAnyFilterChange")
    local searchParams = self.searchParams
    local lastSearchParams = self.lastSearchParams
    --No search was done yet?
    if lastSearchParams == nil then
--d(">no lastSearchParams")
        if searchParams ~= nil then
            if ZO_IsTableEmpty(searchParams) then
--d(">searchParams is empty")
                return false
            else
--d(">searchParams NOT empty")
                return true
            end
        else
--d(">searchParams NIL")
            return false
        end
    end
    if lastSearchParams == searchParams then
--d(">lastSearchParams == searchParams")
        return false
    end

    local countLastSearchParams = NonContiguousCount(lastSearchParams)
    local countSearchParams = NonContiguousCount(searchParams)
--d(">Compare lastSearchParams ".. tos(countLastSearchParams) .. " & searchParams " .. tos(countSearchParams))

    --Any entry in the current search params does not match the lastSearchParams
    --or any key table is missing?
    local baseTabToSearch = (countSearchParams > countLastSearchParams and searchParams) or lastSearchParams
    local alternativeTabToSearch = (countSearchParams > countLastSearchParams and lastSearchParams) or searchParams

    for k, v in pairs(baseTabToSearch) do
        local searchParamEntry = alternativeTabToSearch[k]
        if searchParamEntry ~= nil then
            if type(v) == "table" then --and type(lastSearchParamEntry) == "table" then no need to check if lastSearchParams enty is a table too as they got copied from searchParams, so type must be same
                --The table was emptied: Changed
                if ZO_IsTableEmpty(v) then
--d(">table is empty")
                    return true
                else
                    --Table still contains entries, compare them
                    if NonContiguousCount(v) ~= NonContiguousCount(searchParamEntry) then
                        --Count of entries changed
--d(">table count differs")
                        return true
                    else
                        --Count is same, single comparison
                        for k2, v2 in pairs(v) do
                            local lastSearchParamEntry2 = searchParamEntry[k2]
                            --Subtable entry is missing, or differs from current searchParams
                            if lastSearchParamEntry2 == nil or lastSearchParamEntry2 ~= v2 then
--d(">2value is nil, or differs: " ..tos(lastSearchParamEntry2))
                                return true
                            end
                        end
                    end
                end
            else
                --Single value comparison
                if v ~= searchParamEntry then
--d(">value differs: " ..tos(v))
                    return true
                end
            end
        else
            --Table key was removed: Changed
--d(">table key was added/removed: " ..tos(k))
            return true
        end
    end
    return false
end

--Pre-Filter the masterlist table of e.g. a ZO_SortFilterScrollList
function LibSets_SearchUI_Shared:PreFilterMasterList(defaultMasterListBase)
d("[LibSets_SearchUI_Shared]PreFilterMasterList")
    if defaultMasterListBase == nil or ZO_IsTableEmpty(defaultMasterListBase) then return end
    --The search parameters of the filters (multiselect dropdowns) were provided?
    -->Passed in from the LibSets_SearchUI_Shared:StartSearch() function
    local searchParams = self.searchParams
    if searchParams ~= nil and not ZO_IsTableEmpty(searchParams) then
        local setsBaseList = {}
        --Language of client, or of not supported: fallbackLang
        local langTouse = langAllowedCheck(clientLang)

        local multiSelectFilterDropdownToSearchParamName = self.multiSelectFilterDropdownToSearchParamName

        --searchParams is a table with the following possible entries
        -->See format of searchParams at the Initialize function of this class, above!
        local searchParamsSetType = searchParams[multiSelectFilterDropdownToSearchParamName[self.setTypeFiltersControl]]
        local searchParamsArmorType = searchParams[multiSelectFilterDropdownToSearchParamName[self.armorTypeFiltersControl]]
        local searchParamsWeaponType = searchParams[multiSelectFilterDropdownToSearchParamName[self.weaponTypeFiltersControl]]
        local searchParamsEquipmentType = searchParams[multiSelectFilterDropdownToSearchParamName[self.equipmentTypeFiltersControl]]
        local searchParamsDLCId = searchParams[multiSelectFilterDropdownToSearchParamName[self.DCLIdFiltersControl]]
        local searchParamsFavorites = searchParams[multiSelectFilterDropdownToSearchParamName[self.favoritesFiltersControl]]
        local searchParamsEnchantSearchCategory = searchParams[multiSelectFilterDropdownToSearchParamName[self.enchantSearchCategoryTypeFiltersControl]]
        local searchParamsNumBonus = searchParams[multiSelectFilterDropdownToSearchParamName[self.numBonusFiltersControl]]
        local searchParamsDropZone = searchParams[multiSelectFilterDropdownToSearchParamName[self.dropZoneFiltersControl]]
        local searchParamsDropMechanic = searchParams[multiSelectFilterDropdownToSearchParamName[self.dropMechanicsFiltersControl]]
        local searchParamsDropLocation = searchParams[multiSelectFilterDropdownToSearchParamName[self.dropLocationsFiltersControl]]

        --SavedVariables dependent entries
        local setSearchFavoritesSV = lib.svData.setSearchFavorites

        --Pre-Filter the master list now, based on the Multiselect dropdowns
        for setId, setData in pairs(defaultMasterListBase) do
            local isAllowed = true


            --[Multiselect dropdown box filters]

            --First filter by SavedVariables dependent filters
            --set favorites
            if searchParamsFavorites ~= nil and setSearchFavoritesSV ~= nil then
                isAllowed = false
                for isFavorite, isFiltered in pairs(searchParamsFavorites) do
                    if isFiltered == true then
                        local setDataFavoriteValue = (isFavorite == LIBSETS_SET_ITEMID_TABLE_VALUE_OK and true) or nil
                        if setDataFavoriteValue == setSearchFavoritesSV[setId] then
    --d(">setId is favorite: " ..tos(setId) .. ", name: " ..tos(setData.nameClean))
                            isAllowed = true
                            break
                        end
                    end
                end
            end

            --Other search UI filters
            --SetTypes
            if isAllowed == true then
                if searchParamsSetType ~= nil then
                    isAllowed = false
                    if setData.setType ~= nil and searchParamsSetType[setData.setType] then
                        isAllowed = true
                    end
                end
            end
            --DLC IDs
            if isAllowed == true then
                if searchParamsDLCId ~= nil then
                    isAllowed = false
                    if setData.dlcId ~= nil and searchParamsDLCId[setData.dlcId] then
                        isAllowed = true
                    end
                end
            end
            --armorTypes
            if isAllowed == true then
                if searchParamsArmorType ~= nil then
                    isAllowed = false
                    for armorType, isFiltered in pairs(searchParamsArmorType) do
                        if isFiltered == true and libSets_IsArmorTypeSet(setId, armorType) then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            --weaponTypes
            if isAllowed == true then
                if searchParamsWeaponType ~= nil then
                    isAllowed = false
                    for weaponType, isFiltered in pairs(searchParamsWeaponType) do
                        if isFiltered == true and libSets_IsWeaponTypeSet(setId, weaponType) then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            --equipmentTypes
            if isAllowed == true then
                if searchParamsEquipmentType ~= nil then
                    isAllowed = false
                    for equipType, isFiltered in pairs(searchParamsEquipmentType) do
                        if isFiltered == true and libSets_IsEquipTypeSet(setId, equipType) then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            --enchantSearchCategory
            if isAllowed == true then
                if searchParamsEnchantSearchCategory ~= nil then
                    isAllowed = false
                    local enchantSearchCategories = setData[LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] or libSets_GetSetEnchantSearchCategories(setId, nil, nil, nil, nil)
                    if enchantSearchCategories ~= nil then
                        --Update the base setInfo table with the enchantment search category infos determined -> Already done internally in libSets_GetSetEnchantSearchCategories(...)
                        --lib.setInfo[setId][LIBSETS_TABLEKEY_ENCHANT_SEARCHCATEGORY_TYPES] = enchantSearchCategories
                        for enchantSearchCategory, isFiltered in pairs(searchParamsEnchantSearchCategory) do
                            if isFiltered == true and enchantSearchCategories[enchantSearchCategory] then
                                isAllowed = true
                                break
                            end
                        end
                    end
                end
            end
            --numBonuses
            if isAllowed == true then
                if searchParamsNumBonus ~= nil then
                    isAllowed = false
                    local numBonuses
                    if setData.numBonuses == nil then
                        local itemId = libSets_GetSetFirstItemId(setId, nil)
                        if itemId ~= nil then
                            local itemLink = libSets_buildItemLink(itemId, 370) -- Always use the legendary quality for the sets list
                            local _, _, numBonuses_l = gilsi(itemLink, false)
                            setData.numBonuses = numBonuses_l
                            numBonuses = numBonuses_l
                        end
                    else
                        numBonuses = setData.numBonuses
                    end
                    for numBonus, isFiltered in pairs(searchParamsNumBonus) do
                        if isFiltered == true then
                            if numBonuses == numBonus then
                                isAllowed = true
                                break
                            end
                        end
                    end
                end
            end
            --dropZones
            if isAllowed == true then
                if searchParamsDropZone ~= nil then
                    isAllowed = false
                    local dropZones = setData.dropZones or libSets_GetDropZonesBySetId(setId)
                    if dropZones ~= nil then
                        setData.dropZones = dropZones
                        for dropZoneId, isFiltered in pairs(searchParamsDropZone) do
                            if isFiltered == true and dropZones[dropZoneId] then
                                isAllowed = true
                                break
                            end
                        end
                    else
                        --DropZones are unknown at the setId -> And we selected the !Unknown ones?
                        if searchParamsDropZone[-1] then
                            isAllowed = true
                        end
                    end
                end
            end
            --dropMechanics
            if isAllowed == true then
                if searchParamsDropMechanic ~= nil then
                    isAllowed = false
                    local dropMechanics = setData[LIBSETS_TABLEKEY_DROPMECHANIC] or libSets_GetDropMechanic(setId, nil, nil)
                    if dropMechanics ~= nil then
                        setData[LIBSETS_TABLEKEY_DROPMECHANIC] = dropMechanics
                        for dropMechanicId, isFiltered in pairs(searchParamsDropMechanic) do
                            if isFiltered == true and ZO_IsElementInNumericallyIndexedTable(dropMechanics, dropMechanicId) then
                                isAllowed = true
                                break
                            end
                        end
                    end
                end
            end
            --dropLocations
            if isAllowed == true then
                if searchParamsDropLocation ~= nil then
                    isAllowed = false
                    local dropLocationNames = setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] or libSets_GetDropLocationNamesBySetId(setId, nil)
                    if dropLocationNames ~= nil then
                        setData[LIBSETS_TABLEKEY_DROPMECHANIC_LOCATION_NAMES] = dropLocationNames
                        for dropLocationName, isFiltered in pairs(searchParamsDropLocation) do
                            if isFiltered == true and not isAllowed then
                                for _, dropLocationNameLanguages in pairs(dropLocationNames) do
                                    local dropLocationNameInLangToUse = dropLocationNameLanguages[langTouse]
                                    if dropLocationNameInLangToUse ~= nil and dropLocationNameInLangToUse == dropLocationName then
                                        isAllowed = true
                                        break
                                    end
                                end
                            end
                            if isAllowed == true then
                                break
                            end
                        end
                    end
                end
            end


            --Edit fields
            -->Are handled at the OnTextChanged directly at the editboxes

            ------------------------------------------------------------------------------------------------------------
            --Add to masterList?
            if isAllowed == true then
                setsBaseList[setId] = setData
            end
        end -- for setId, setData in pairs(defaultMasterListBase) do
        return setsBaseList
    end
    return defaultMasterListBase
end


------------------------------------------------------------------------------------------------------------------------
--Search UI shared - Helper functions
------------------------------------------------------------------------------------------------------------------------
--Run a function throttled (check if it should run already and overwrite the old call then with a new one to
--prevent running it multiple times in a short time)
function LibSets_SearchUI_Shared:ThrottledCall(callbackName, timer, callback, ...)
    if not callbackName or callbackName == "" or not callback then return end
    EM:UnregisterForUpdate(callbackName)
    local args = {...}
    local function Update()
        EM:UnregisterForUpdate(callbackName)
        callback(unpack(args))
    end
    EM:RegisterForUpdate(callbackName, timer, Update)
end

function LibSets_SearchUI_Shared:ModifyWeaponType2hd(weaponType)
    return lib.GetWeaponTypeText(weaponType)
end


------------------------------------------------
--- Tooltip
------------------------------------------------
function LibSets_SearchUI_Shared:ShowItemLinkTooltip(parent, data, anchor1, offsetX, offsetY, anchor2)
    self:HideItemLinkTooltip()

    local TT_control = self.tooltipControl
    data = data or (TT_control and TT_control.data)
    if data == nil or data.itemLink == nil then return end

    --Get the current position of the UI. If  the UI is moved to the left, show the tooltip right, and vice versa
    --local screenWidth, screenHeight = GuiRoot:GetDimensions()
    if anchor1 == nil then
        local currentLeft = self.control:GetLeft()
        if currentLeft < TT_control:GetWidth() then
            anchor1 = anchor1 or LEFT
            anchor2 = anchor2 or RIGHT
            offsetX = offsetX or 25
            offsetY = offsetY or 0
        else
            anchor1 = anchor1 or RIGHT
            anchor2 = anchor2 or LEFT
            offsetX = offsetX or -25
            offsetY = offsetY or 0
        end
    end
    --Show the tooltip
    InitializeTooltip(TT_control, parent, anchor1, offsetX, offsetY, anchor2)
    TT_control:SetLink(data.itemLink)
end

function LibSets_SearchUI_Shared:HideItemLinkTooltip()
    ClearTooltip(self.tooltipControl)
end


function LibSets_SearchUI_Shared:ShowItemLinkPopupTooltip(parent, data, anchor1, offsetX, offsetY, anchor2)
    self:HideItemLinkPopupTooltip()

    local TT_control = PopupTooltip
    if data == nil or data.itemLink == nil then return end

    --Get the current position of the UI. If  the UI is moved to the left, show the tooltip right, and vice versa
    --local screenWidth, screenHeight = GuiRoot:GetDimensions()
    if anchor1 == nil then
        local currentLeft = self.control:GetLeft()
        if currentLeft < TT_control:GetWidth() then
            anchor1 = anchor1 or LEFT
            anchor2 = anchor2 or RIGHT
            offsetX = offsetX or 25
            offsetY = offsetY or 0
        else
            anchor1 = anchor1 or RIGHT
            anchor2 = anchor2 or LEFT
            offsetX = offsetX or -25
            offsetY = offsetY or 0
        end
    end
    --Show the tooltip
    InitializeTooltip(TT_control, parent, anchor1, offsetX, offsetY, anchor2)
    TT_control:SetLink(data.itemLink)
end

function LibSets_SearchUI_Shared:HideItemLinkPopupTooltip()
    ClearTooltip(PopupTooltip)
end


------------------------------------------------
--- Context menu
------------------------------------------------

function LibSets_SearchUI_Shared:ItemLinkToChat(data)
    if data and data.itemLink ~= nil then
        d(libPrefix .."SetId \'".. tos(data.setId) .."\': " ..data.itemLink)
        StartChatInput(data.itemLink)
    end
end

function LibSets_SearchUI_Shared:IsSetIdInFavorites(setId)
    return lib.svData.setSearchFavorites[setId] or false
end

function LibSets_SearchUI_Shared:AddSetIdToFavorites(rowControl, setId)
    if self:IsSetIdInFavorites(setId) then return end
    lib.svData.setSearchFavorites[setId] = true

    self.resultsList:AddFavorite(rowControl)
end

function LibSets_SearchUI_Shared:RemoveSetIdFromFavorites(rowControl, setId)
    if not self:IsSetIdInFavorites(setId) then return end
    lib.svData.setSearchFavorites[setId] = nil

    self.resultsList:RemoveFavorite(rowControl)
end

function LibSets_SearchUI_Shared:RemoveAllSetFavorites()
    local setFavorites = lib.svData.setSearchFavorites
    if ZO_IsTableEmpty(setFavorites) then return end
    lib.svData.setSearchFavorites = {}
    self.resultsList:RefreshData() --To remove the Favorite markers
end


function LibSets_SearchUI_Shared:ShowRowContextMenu(rowControl)
    if not LibCustomMenu then return end
    local data = rowControl.data
    if data == nil then return end
    local setId = rowControl.data.setId
    local owningWindow = rowControl:GetOwningWindow()
    ClearMenu()
    AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
        self:ItemLinkToChat(rowControl.data)
    end)
    local popupTooltipSubmenu = {
        {
            label = GetString(SI_KEYBINDDISPLAYMODE2),
            callback =function()
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, nil, nil, nil, nil)
            end
        },
        {
            label = "-", --Left
            callback = function() end,
        },
        {
            label = GetString(SI_KEYCODE_NARRATIONTEXTPS4125), --Left
            callback = function()
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, RIGHT, -10, nil, LEFT)
            end
        },
        {
            label = GetString(SI_KEYCODE_NARRATIONTEXTPS4126), --Right
            callback =function()
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, LEFT, 10, nil, RIGHT)
            end
        },
    }
    AddCustomSubMenuItem("Popup toooltip", popupTooltipSubmenu)

    if setId ~= nil then
        AddCustomMenuItem(favoriteIconWithNameText, function() end, MENU_ADD_OPTION_HEADER)
        if self:IsSetIdInFavorites(setId) then
            AddCustomMenuItem(GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE), function()
                self:RemoveSetIdFromFavorites(rowControl, setId)
            end)
        else
            AddCustomMenuItem(GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE), function()
                self:AddSetIdToFavorites(rowControl, setId)
            end)
        end

        if data.setDataText ~= nil then
            local function getSetTextForCopyDialog(withTextures)
                copyDialog = copyDialog or lib.CopyDialog
                local setName = data.name
                if data.setTypeTexture ~= nil then
                    setName = data.setTypeTexture .. " " .. setName
                end
                local textParams = {
                    titleParams = { [1] = setName }
                }
                copyDialog:Show({ text=(withTextures == true and data.setDataText) or data.setDataTextClean, setData=data }, textParams)
            end

            AddCustomMenuItem(getLocalizedText("droppedBy"), function() end, MENU_ADD_OPTION_HEADER)
            AddCustomMenuItem(getLocalizedText("showAsText"), function()
                getSetTextForCopyDialog(false)
            end)
            AddCustomMenuItem(getLocalizedText("showAsTextWithIcons"), function()
                getSetTextForCopyDialog(true)
            end)
        end
    end
    ShowMenu(rowControl)
end

function LibSets_SearchUI_Shared:ShowSettingsMenu(anchorControl)
    if not LibCustomMenu then return end
    local selfVar = self
    ClearMenu()
    AddCustomMenuItem(settingsIconText .. " " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1305), function() end, MENU_ADD_OPTION_HEADER)
    local cbShowDropDownFilterTooltipsIndex = AddCustomMenuItem(getLocalizedText("dropdownFilterTooltips"),
            function(cboxCtrl)
                OnClick_CheckBoxLabel(cboxCtrl, "setSearchTooltipsAtFilters", selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbShowDropDownFilterTooltipsIndex, lib.svData.setSearchTooltipsAtFilters)
    local cbShowDropDownFilterEntryTooltipsIndex = AddCustomMenuItem(getLocalizedText("dropdownFilterEntryTooltips"),
            function(cboxCtrl)
                OnClick_CheckBoxLabel(cboxCtrl, "setSearchTooltipsAtFilterEntries", selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbShowDropDownFilterEntryTooltipsIndex, lib.svData.setSearchTooltipsAtFilterEntries)

    if clientLang ~= "en" then
        AddCustomMenuItem("-", function() end)
        local cbShowSetNamesInEnglishTooIndex = AddCustomMenuItem(getLocalizedText("searchUIShowSetNameInEnglishToo"),
                function(cboxCtrl)
                    OnClick_CheckBoxLabel(cboxCtrl, "setSearchShowSetNamesInEnglishToo", selfVar)
                end,
                MENU_ADD_OPTION_CHECKBOX)
        setMenuItemCheckboxState(cbShowSetNamesInEnglishTooIndex, lib.svData.setSearchShowSetNamesInEnglishToo)
    end

    if not ZO_IsTableEmpty(lib.svData.setSearchFavorites) then
        AddCustomMenuItem(favoriteIconWithNameText, function() end, MENU_ADD_OPTION_HEADER)
        AddCustomMenuItem(GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1), function()
            self:RemoveAllSetFavorites()
        end)
    end
    ShowMenu(anchorControl)
end

function LibSets_SearchUI_Shared:ShowDropdownContextMenu(dropdownControl, shift, alt, ctrl, command)
    if LibCustomMenu == nil then return end
    --Multiselect filter dropdown context menu?
    local selfVar = self
    if selfVar.multiSelectFilterDropdowns ~= nil and ZO_IsElementInNumericallyIndexedTable(selfVar.multiSelectFilterDropdowns, dropdownControl) then
        ClearMenu()
        AddCustomMenuItem(GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1), function()
            selfVar:ResetMultiSelectDropdown(dropdownControl)
            selfVar:OnFilterChanged(dropdownControl)
        end)

        --Favorite filter muliselect dropdown?
        if dropdownControl == self.favoritesFiltersControl then
            AddCustomMenuItem("-")
            local entriesToSelect = { [1] = LIBSETS_SET_ITEMID_TABLE_VALUE_OK }
            AddCustomMenuItem(favoriteIconWithNameText, function() selfVar:SelectMultiSelectDropdownEntries(dropdownControl, entriesToSelect, true) end)
        end

        ShowMenu(dropdownControl)
    end
end


--[[ XML Handlers ]]--
function LibSets_SearchUI_Shared_ControlTooltip(control, myAnchorPoint, anchorTo, toAnchorPoint, offsetX, offsetY)
    if not lib.svData or not lib.svData.setSearchTooltipsAtFilters then return end
    if control == nil or control.tooltipText == nil or control.tooltipText == "" then return end
    myAnchorPoint = myAnchorPoint or BOTTOM
    anchorTo = anchorTo or control
    toAnchorPoint = toAnchorPoint or TOP
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    InitializeTooltip(InformationTooltip, anchorTo, myAnchorPoint, offsetX, offsetY, toAnchorPoint)
    SetTooltipText(InformationTooltip, control.tooltipText)
end

function LibSets_SearchUI_Shared_SortHeaderTooltip(sortHeaderColumn)
    if sortHeaderColumn == nil or sortHeaderColumn.name == nil or sortHeaderColumn.name == "" then return end
    local nameLabel = sortHeaderColumn:GetNamedChild("Name")
    if nameLabel ~= nil and nameLabel:WasTruncated() then
        InitializeTooltip(InformationTooltip, sortHeaderColumn, BOTTOM, 0, -10, TOP)
        SetTooltipText(InformationTooltip, sortHeaderColumn.name)
    end
end

function LibSets_SearchUI_Shared_Dropdown_OnMouseUp(dropdownControl, mouseButton, upInside, shift, alt, ctrl, command)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:OnDropdownMouseUp(dropdownControl, mouseButton, upInside, shift, alt, ctrl, command)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:OnDropdownMouseUp(dropdownControl, mouseButton, upInside, shift, alt, ctrl, command)
        end
    end
end

function LibSets_SearchUI_Shared_Row_OnMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:OnRowMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:OnRowMouseUp(rowControl, mouseButton, upInside, shift, alt, ctrl, command)
        end
    end
end

function LibSets_SearchUI_Shared_Row_OnMouseEnter(rowControl)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:OnRowMouseEnter(rowControl)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:OnRowMouseEnter(rowControl)
        end
    end
end

function LibSets_SearchUI_Shared_Row_OnMouseExit(rowControl)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:OnRowMouseExit(rowControl)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:OnRowMouseExit(rowControl)
        end
    end
end


function LibSets_SearchUI_Shared_ToggleUI(slashOptions)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:ToggleUI(slashOptions)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:ToggleUI(slashOptions)
        end
    end
end

function LibSets_SearchUI_Shared_IsShown()
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            return LIBSETS_SEARCH_UI_GAMEPAD:IsShown()
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            return LIBSETS_SEARCH_UI_KEYBOARD:IsShown()
        end
    end
    return
end

function LibSets_SearchUI_Shared_UpdateSearch(slashOptions)
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:UpdateSearchParamsFromSlashcommand(slashOptions)
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:UpdateSearchParamsFromSlashcommand(slashOptions)
        end
    end
end