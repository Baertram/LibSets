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


--Search type - For the string comparison "processor". !!!Needs to match the SetupRow of the ZO_ScrollList!!!
searchUI.searchTypeDefault = 1

--Scroll list datatype - Default text
searchUI.scrollListDataTypeDefault = 1



------------------------------------------------------------------------------------------------------------------------
--Search UI shared class for keyboard and gamepad mode
------------------------------------------------------------------------------------------------------------------------
LibSets_SearchUI_Shared = ZO_Object:Subclass()

------------------------------------------------
--- Initialization
------------------------------------------------
function LibSets_SearchUI_Shared:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LibSets_SearchUI_Shared:Initialize(control)
    self.control = control
    control._object = self

    local filters = self.control:GetNamedChild("Filters")
    self.filtersControl = filters
    local content = self.control:GetNamedChild("Content")
    self.contentControl = content

    self.searchResults = nil
    --[[
    {
        setIds = {
            --[setId1]= true, [setId2] = true, ...
        },
        itemIds = {
            --[setId] = {[1] = itemId1, [2] = itemId2, ...}
        },
    } ]] --table with found sets, and items of these sets matching the search params
    --self.searchDoneCallback = nil --callback function called as a search was done
    --self.searchErrorCallback = nil --callback function called as a search was not done due to any error
    --self.searchCanceledCallback = nil --callback function called as a search was canceled

    --ZO_StringSearch
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

function LibSets_SearchUI_Shared:Show(searchParams, searchDoneCallback, searchErrorCallback, searchCanceledCallback)
    --Search parameters, passed in (preset UI elements with them, if provided)
    self.searchParams = searchParams
    --searchParams is a table with the following possible entries
    --[[
    searchParams = {
        name = {"hunding", 111, "test}           --The text entered at the name search editbox, as a table, split at spaces. Could contain setIds too, so it will be a mixed nameString!
        armorType = {1, 2, 3}       --The armor type selected at the multiselect dropdown box
        weaponType = {1, 2, 3}      --The weapon type selected at the multiselect dropdown box
        jewelryType = {1, 2, 3}     --The jewelry type selected at the multiselect dropdown box
        equipmentType = {1, 2, 3}   --The equipment slot (head, shoulders, body, ...) selected at the multiselect dropdown box
        dlcType = {1, 2, 3}         --The DLC type selected at the multiselect dropdown box
        setType = {1, 2, 3}         --The set type selected at the multiselect dropdown box

--TODO Other search options
        dropZone = {1, 2, 3}        --The drop zones selected at the multiselect dropdown box
        ...
    }
    ]]


	--Callbacks
    self.searchDoneCallback = searchDoneCallback
    self.searchErrorCallback = searchErrorCallback
    self.searchCanceledCallback = searchCanceledCallback

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
d("[LibSets]LibSets_SearchUI_Shared:Cancel")

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
    --Validate the search parameters and raise an error message if something does not match

    local searchParams = self.searchParams
    if searchParams == nil or NonContiguousCount(searchParams) == 0 then return end

    --todo Pass in the searched set name, and other data to self.searchParams, afterwards validate them here


    return true --all search parameters are valid
end

function LibSets_SearchUI_Shared:StartSearch()
    --Fire callback for "Search was started"
    CM:FireCallbacks(searchUIName .. "_SearchBegin", self)

    return self:ValidateSearchParams()
end


function LibSets_SearchUI_Shared:Search()
d("[LibSets]LibSets_SearchUI_Shared:Search")
    if not self:IsShown() then return end

	--Inherited keyboard / gamepad mode search will be done at the relating class function LibSets_SearchUI_Keyboard/Gamepad:Search() function call!
    -->See other classes' functions

    --Start the search now, based on input parameters
    if self:StartSearch() == true then
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
d("[LibSets_SearchUI_Keyboard.ProcessItemEntry] stringSearch: " ..tostring(stringSearch) .. ", setName: " .. tostring(data.name:lower()) .. ", searchTerm: " .. tostring(searchTerm))
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
	for needle in needles:gmatch("%S+") do
		i = haystack:find(needle, i + 1, true)
		if not i then return false end
	end
	return true
end

function LibSets_SearchUI_Shared:SearchSetBonuses(bonuses, searchInput)
	local curpos = 1
	local delim
	local exclude = false

	repeat
		local found = false
		delim = searchInput:find("[+,-]", curpos)
		if not delim then delim = 0 end
		local searchQuery = searchInput:sub(curpos, delim - 1)
		if searchQuery:find("%S+") then
			for i = 1, #bonuses do
				if self:OrderedSearch(bonuses[i], searchQuery) then
					found = true
					break
				end
			end

			if (found == exclude) then return(false) end
		end
		curpos = delim + 1
		if delim ~= 0 then exclude = searchInput:sub(delim, delim) == "-" end
	until delim == 0
	return true
end

function LibSets_SearchUI_Shared:SearchByCriteria(data, searchInput, searchType)
    --todo combine all passed in search criteria and filter the results list
end


------------------------------------------------------------------------------------------------------------------------
--Search UI shared - Helper functions
------------------------------------------------------------------------------------------------------------------------
--Run a function throttled (check if it should run already and overwrite the old call then with a new one to
--prevent running it multiple times in a short time)
function LibSets_SearchUI_Shared:ThrottledCall(callbackName, timer, callback, ...)
    if not callbackName or callbackName == "" or not callback then return end
    EM:UnregisterForUpdate(callbackName)
    local args
    if ... ~= nil then
        args = {...}
    end
    local function Update()
        EM:UnregisterForUpdate(callbackName)
        if args ~= nil then
            callback(unpack(args))
        else
            callback()
        end
    end
    EM:RegisterForUpdate(callbackName, timer, Update)
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