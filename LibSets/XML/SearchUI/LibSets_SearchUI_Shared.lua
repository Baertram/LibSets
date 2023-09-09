local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

--The search UI table
LibSets.SearchUI = {}
local searchUI = LibSets.SearchUI
searchUI.name = MAJOR .. "_SearchUI"
local searchUIName = searchUI.name

--Maximum number of set bonuses
searchUI.MAX_NUM_SET_BONUS = 6 --2023-09-09

--Search type - For the string comparison "processor". !!!Needs to match the SetupRow of the ZO_ScrollList!!!
searchUI.searchTypeDefault = 1

--Scroll list datatype - Default text
searchUI.scrollListDataTypeDefault = 1

--Weapon types with 2hd weapons
local twoHandWeaponTypes = {
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
}

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

    self.searchResults = nil --table with found setIds, and below the data table with the names and itemIds etc. (from table LibSets.setInfo). Basically this is the masterList of the ZO_SortFilterScollList

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
--- Reset
------------------------------------------------
function LibSets_SearchUI_Shared:ResetInternal()
    --Reset internal data like the search results
    self.searchParams = nil
    self.searchResults = nil

    --Reset callbacks
    self.searchDoneCallback = nil
    self.searchErrorCallback = nil
    self.searchCanceledCallback = nil
end

function LibSets_SearchUI_Shared:ResetUI()
    --Reset all UI elements to the default values
end

function LibSets_SearchUI_Shared:Reset()
    --Reset all data, internal and the chanegd UI elements
    self:ResetInternal()
    self:ResetUI()
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


------------------------------------------------
--- UI
------------------------------------------------
function LibSets_SearchUI_Shared:IsShown()
    return not self.control:IsHidden()
end

function LibSets_SearchUI_Shared:ShowUI()
    if self:IsShown() then return end
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

    if searchParams ~= nil then
        --Search parameters, passed in (preset UI elements with them, if provided)
        self.searchParams = searchParams

        self:ApplySearchParamsToUI()
    end

	--Callbacks
    self.searchDoneCallback =       searchDoneCallback
    self.searchErrorCallback =      searchErrorCallback
    self.searchCanceledCallback =   searchCanceledCallback

    --Show the UI now
    self:ShowUI()
end

function LibSets_SearchUI_Shared:ToggleUI()
    if self:IsShown() then self:HideUI() else self:ShowUI() end
end



------------------------------------------------
--- Search
------------------------------------------------
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

function LibSets_SearchUI_Shared:ValidateSearchParams()
--d("[LibSets]LibSets_SearchUI_Shared:ValidateSearchParams")
    --Validate the search parameters and raise an error message if something does not match

    --todo Other validation needed?

    return true --all search parameters are valid
end

function LibSets_SearchUI_Shared:StartSearch(doNotShowUI)
--d("[LibSets]LibSets_SearchUI_Shared:StartSearch-doNotShowUI: " ..tostring(doNotShowUI))
    --Fire callback for "Search was started"
    CM:FireCallbacks(searchUIName .. "_SearchBegin", self)

    if self:ValidateSearchParams() == true then
        if self.resultsList ~= nil then
            --At "BuildMasterList" the self.searchParams will be pre-filtered, and at FilterScrollList the text search filters will be added
            self.resultsList:RefreshData() --> -- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
        end
        return true
    end
    return false
end

--Start the search now. The search results will be accessible in self.searchResults
--If parameter doNotShowUI is true the search will be done without opening the UI
--You can optionally pass in searchParams which will be used to do the search. If none are specified the UI's searchParams will be used (multiselect dropdowns, editboxes, ...)
-->See format of searchParams at the Initialize function of this class, above!
function LibSets_SearchUI_Shared:Search(doNotShowUI, searchParams)
--d("[LibSets]LibSets_SearchUI_Shared:Search")
    doNotShowUI = doNotShowUI or false

    if not doNotShowUI and not self:IsShown() then return end

    if searchParams ~= nil then
        self.searchParams = searchParams
    end

	--Inherited keyboard / gamepad mode search will be done at the relating class function LibSets_SearchUI_Keyboard/Gamepad:Search() function call!
    -->See other classes' functions

    --Start the search now, based on input parameters
    if self:StartSearch(doNotShowUI) == true then
        --Is a "search was done" callback function registered?
        if self.searchDoneCallback then
            self.searchDoneCallback(self) --passes in the object so that the callback function got access to self.searchResults table
        end
    else
        --Is a "search was not done due to any error" callback function registered?
        if self.searchErrorCallback then
            self.searchErrorCallback(self) --passes in the object so that the callback function got access to self.searchResults table
        end
    end
end



------------------------------------------------
--- Filters
------------------------------------------------

local function string_split (inputstr, sep)
    sep = sep or "%s"
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function LibSets_SearchUI_Shared:CheckForMatch(data, searchInput)
    --d("[LibSets_SearchUI_Shared:CheckForMatch]searchInput: " .. tostring(searchInput))
    --Search by name or setId
    -->Split at ,
    local namesOrIdsTab = string_split(searchInput, ",")
    if namesOrIdsTab == nil or #namesOrIdsTab == 0 then return false end

    local isMatch = false
    for _, nameOrId in ipairs(namesOrIdsTab) do
        isMatch = false
        local searchInputNumber = tonumber(nameOrId)
        if searchInputNumber ~= nil then
            local searchValueType = type(searchInputNumber)
            if searchValueType == "number" then
                isMatch = searchInputNumber == data.setId or false
            end
        else
            isMatch = self.stringSearch:IsMatch(nameOrId, data)
        end
        if isMatch == true then return true end
    end
    return false
end


function LibSets_SearchUI_Shared:ProcessItemEntry(stringSearch, data, searchTerm)
--d("[LibSets_SearchUI_Keyboard.ProcessItemEntry] stringSearch: " ..tostring(stringSearch) .. ", setName: " .. tostring(data.name:lower()) .. ", searchTerm: " .. tostring(searchTerm))
	if zo_plainstrfind(data.name:lower(), searchTerm) then
		return true
	end
	return false
end

function LibSets_SearchUI_Shared:OrderedSearch(haystack, needles)
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

function LibSets_SearchUI_Shared:SearchSetBonuses(bonuses, searchInput)
	local curpos = 1
	local delim
	local exclude = false
    --Check the searchInput for prefix + (include) or - (exclude) and split at , to find all
    --set bonuses
	repeat
		local found = false
		delim = searchInput:find("[+,-]", curpos)
		if not delim then delim = 0 end
		local searchQuery = searchInput:sub(curpos, delim - 1)
		--if searchQuery:find("%S+") then   --find no whitepaces
        if searchQuery:find("[^,]+") then      --find no ,
			for i = 1, #bonuses do
				if self:OrderedSearch(bonuses[i], searchQuery) then
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

function LibSets_SearchUI_Shared:OnFilterChanged() --Override!
    --d("[LibSets_SearchUI_Shared]OnFilterChanged - MultiSelect dropdown - hidden")
    self.searchParams = nil
end

--Pre-Filter the masterlist table of e.g. a ZO_SortFilterScrollList
function LibSets_SearchUI_Shared:PreFilterMasterList(defaultMasterListBase)
    --The search parameters of the filters (multiselect dropdowns) were provided?
    -->Passed in from the LibSets_SearchUI_Shared:StartSearch() function
    local searchParams = self.searchParams
    if searchParams ~= nil and NonContiguousCount(searchParams) > 0 then
        local setsBaseList = {}

        --searchParams is a table with the following possible entries
        -->See format of searchParams at the Initialize function of this class, above!

        --Pre-Filter the master list now, based on the Multiselect dropdowns
        for setId, setData in pairs(defaultMasterListBase) do
            local isAllowed = true


            --Multiselect dropdown boxes
            if searchParams.setTypes ~= nil then
                isAllowed = false
                if setData.setType ~= nil and searchParams.setTypes[setData.setType] then
                    isAllowed = true
                end
            end
            if isAllowed == true then
                if searchParams.dlcIds ~= nil then
                    isAllowed = false
                    if setData.dlcId ~= nil and searchParams.dlcIds[setData.dlcId] then
                        isAllowed = true
                    end
                end
            end
            if isAllowed == true then
                if searchParams.armorTypes ~= nil then
                    isAllowed = false
                    for armorType, isFiltered in pairs(searchParams.armorTypes) do
                        if isFiltered == true and lib.armorTypesSets[armorType][setId] then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            if isAllowed == true then
                if searchParams.weaponTypes ~= nil then
                    isAllowed = false
                    for weaponType, isFiltered in pairs(searchParams.weaponTypes) do
                        if isFiltered == true and lib.weaponTypesSets[weaponType][setId] then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            if isAllowed == true then
                if searchParams.equipmentTypes ~= nil then
                    isAllowed = false
                    for equipType, isFiltered in pairs(searchParams.equipmentTypes) do
                        if isFiltered == true and lib.equipTypesSets[equipType][setId] then
                            isAllowed = true
                            break
                        end
                    end
                end
            end
            if isAllowed == true then
                if searchParams.numBonuses ~= nil then
                    isAllowed = false
                    local itemId = lib.GetSetFirstItemId(setId, nil)
                    if itemId ~= nil then
                        local itemLink = lib.buildItemLink(itemId, 370) -- Always use the legendary quality for the sets list
                        local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)

                        for numBonus, isFiltered in pairs(searchParams.numBonuses) do
                            if isFiltered == true then
                                if numBonuses == numBonus then
                                    isAllowed = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            --todo
            if isAllowed == true then
                if searchParams.enchantSearchCategoryTypes ~= nil then
                    isAllowed = false
                end
            end


            --Edit fields
            -->Are handled at the OnTextChanged directly at the editboxes

            ------------------------------------------------------------------------------------------------------------
            --Add to masterList?
            if isAllowed == true then
                setsBaseList[setId] = setData
            end
        end

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
    local weaponTypeText = GetString("SI_WEAPONTYPE", weaponType)
    if not twoHandWeaponTypes[weaponType] then
        return weaponTypeText
    else
       return "2HD " .. weaponTypeText
    end
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

    --Show the tooltip
    InitializeTooltip(TT_control, parent, anchor1, offsetX, offsetY, anchor2)
    TT_control:SetLink(data.itemLink)
end

function LibSets_SearchUI_Shared:HideItemLinkTooltip()
    ClearTooltip(self.tooltipControl)
end



--[[ XML Handlers ]]--
function LibSets_SearchUI_Shared_ToggleUI()
    if IsInGamepadPreferredMode() then
        if LIBSETS_SEARCH_UI_GAMEPAD ~= nil then
            LIBSETS_SEARCH_UI_GAMEPAD:ToggleUI()
        end
    else
        if LIBSETS_SEARCH_UI_KEYBOARD ~= nil then
            LIBSETS_SEARCH_UI_KEYBOARD:ToggleUI()
        end
    end
end