local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

local zif = zo_iconFormat
local zoitfns = zo_iconTextFormatNoSpace
local tos = tostring
local sgmatch = string.gmatch
local strlow = string.lower
local tins = table.insert
local tsort = table.sort
local tcon = table.concat


local clientLang = lib.clientLang
local fallbackLang = lib.fallbackLang
local langAllowedCheck = lib.LangAllowedCheck

local localization = lib.localization
local booleanToOnOff = localization[fallbackLang].booleanToOnOff

local getIndexTableFromNonNumberKeyTable = lib.GetIndexTableFromNonNumberKeyTable

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
local libSets_IsArmorTypeSet         = lib.IsArmorTypeSet
local libSets_getCurrentZoneName = lib.GetCurrentZoneName
local libSets_getsetIdsOfCurrentZone = lib.GetSetIdsOfCurrentZone
local libSets_GetWayshrineIds = lib.GetWayshrineIds
local libSets_GetZoneName = lib.GetZoneName
local libSets_ShowWayshrineNodeIdOnMap = lib.showWayshrineNodeIdOnMap
local libSets_OpenMapOfZoneId = lib.openMapOfZoneId

local libSets_showSettingsMenu = lib.ShowSettingsMenu


local gilsi = GetItemLinkSetInfo

--ZOs references
---Tooltips
local TT_Popup = PopupTooltip
local TT_Text = InformationTooltip


--Event upater names
local searchHistoryEventUpdaterName = MAJOR .. "_SearchHistory_Update"

--Strings
local droppedByStr = getLocalizedText("droppedBy")
local clearSearchHistoryStr = getLocalizedText("clearHistory")
local dropZonesStr = getLocalizedText("dropZones")
local wayshrinesStr = getLocalizedText("wayshrines")
local dropZoneAndWayshrinesStr = dropZonesStr .. " / " .. wayshrinesStr
local invertSelectionStr = getLocalizedText("invertSelection")
local defaultActionLeftClickStr = getLocalizedText("defaultActionLeftClick")
local linkToChatStr = getLocalizedText("linkToChat")
local popupTooltipStr = getLocalizedText("popupTooltip")
local tooltipsStr = getLocalizedText("tooltips")
local showAsTooltipStr = getLocalizedText("showAsTooltip")
local setNamesStr = getLocalizedText("setNames")
local favoritesStr = getLocalizedText("favorites")
local showLibSetsSettingsStr = getLocalizedText("showLibSetsSettingsMenu")


--Textures
local possibleSetSearchFavoriteCategories = lib.possibleSetSearchFavoriteCategories
local possibleSetSearchFavoriteCategoriesUnsorted = lib.possibleSetSearchFavoriteCategoriesUnsorted

--Favorite textures
local favoriteIconStar =        possibleSetSearchFavoriteCategoriesUnsorted.star
local favoriteIconTank =        possibleSetSearchFavoriteCategoriesUnsorted.tank
local favoriteIconStamDD =      possibleSetSearchFavoriteCategoriesUnsorted.stamDD
local favoriteIconMagDD =       possibleSetSearchFavoriteCategoriesUnsorted.magDD
local favoriteIconStamHeal =    possibleSetSearchFavoriteCategoriesUnsorted.stamHeal
local favoriteIconMagHeal=      possibleSetSearchFavoriteCategoriesUnsorted.magHeal
local favoriteIconHybrid =      possibleSetSearchFavoriteCategoriesUnsorted.hybrid
local favoriteIconPVPTank =     possibleSetSearchFavoriteCategoriesUnsorted.PVPTank
local favoriteIconPVPStamDD =   possibleSetSearchFavoriteCategoriesUnsorted.PVPStamDD
local favoriteIconPVPMagDD =    possibleSetSearchFavoriteCategoriesUnsorted.PVPMagDD
local favoriteIconPVPStamHeal = possibleSetSearchFavoriteCategoriesUnsorted.PVPStamHeal
local favoriteIconPVPMagHeal=   possibleSetSearchFavoriteCategoriesUnsorted.PVPMagHeal
local favoriteIconPVPHybrid =   possibleSetSearchFavoriteCategoriesUnsorted.PVPHybrid
local favoriteIconFarm =        possibleSetSearchFavoriteCategoriesUnsorted.farm
local favoriteIconSneak =       possibleSetSearchFavoriteCategoriesUnsorted.sneak
local favoriteIconBow =         possibleSetSearchFavoriteCategoriesUnsorted.bow
local favoriteIconDualWield =   possibleSetSearchFavoriteCategoriesUnsorted.dualWield
local favoriteIcon2HD =         possibleSetSearchFavoriteCategoriesUnsorted.twoHand
local favoriteIconFrostStaff =  possibleSetSearchFavoriteCategoriesUnsorted.frostStaff
local favoriteIconFireStaff =   possibleSetSearchFavoriteCategoriesUnsorted.fireStaff
local favoriteIconLightningStaff=possibleSetSearchFavoriteCategoriesUnsorted.lightningStaff


--The search UI table
lib.SearchUI = {}
local searchUI = lib.SearchUI
searchUI.name = MAJOR .. "_SearchUI"
local searchUIName = searchUI.name

--For the XML sort header
searchUI.favoriteIcon = favoriteIconStar

--Favorite icons and texts - Add to SearchUI
searchUI.favoriteIconStar = favoriteIconStar
searchUI.favoriteIconTank = favoriteIconTank
searchUI.favoriteIconStamDD = favoriteIconStamDD
searchUI.favoriteIconMagDD = favoriteIconMagDD
searchUI.favoriteIconStamHeal = favoriteIconStamHeal
searchUI.favoriteIconMagHeal = favoriteIconMagHeal
searchUI.favoriteIconHybrid = favoriteIconHybrid
searchUI.favoriteIconPVPTank = favoriteIconPVPTank
searchUI.favoriteIconPVPStamDD = favoriteIconPVPStamDD
searchUI.favoriteIconPVPMagDD = favoriteIconPVPMagDD
searchUI.favoriteIconPVPStamHeal = favoriteIconPVPStamHeal
searchUI.favoriteIconPVPMagHeal = favoriteIconPVPMagHeal
searchUI.favoriteIconPVPHybrid = favoriteIconPVPHybrid
searchUI.favoriteIconFarm = favoriteIconFarm
searchUI.favoriteIconSneak = favoriteIconSneak
searchUI.favoriteIconBow = favoriteIconBow
searchUI.favoriteIconDualWield = favoriteIconDualWield
searchUI.favoriteIcon2HD = favoriteIcon2HD
searchUI.favoriteIconFrostStaff = favoriteIconFrostStaff
searchUI.favoriteIconFireStaff = favoriteIconFireStaff
searchUI.favoriteIconLightningStaff = favoriteIconLightningStaff

searchUI.favoriteIconTextStar = zif(favoriteIconStar, 24, 24)
searchUI.favoriteIconTextTank = zif(favoriteIconTank, 24, 24)
searchUI.favoriteIconTextStamDD = zif(favoriteIconStamDD, 24, 24)
searchUI.favoriteIconTextMagDD = zif(favoriteIconMagDD, 24, 24)
searchUI.favoriteIconTextStamHeal = zif(favoriteIconStamHeal, 24, 24)
searchUI.favoriteIconTextMagHeal = zif(favoriteIconMagHeal, 24, 24)
searchUI.favoriteIconTextHybrid = zif(favoriteIconHybrid, 24, 24)
searchUI.favoriteIconTextPVPTank = zif(favoriteIconPVPTank, 24, 24)
searchUI.favoriteIconTextPVPStamDD = zif(favoriteIconPVPStamDD, 24, 24)
searchUI.favoriteIconTextPVPMagDD = zif(favoriteIconPVPMagDD, 24, 24)
searchUI.favoriteIconTextPVPStamHeal = zif(favoriteIconPVPStamHeal, 24, 24)
searchUI.favoriteIconTextPVPMagHeal = zif(favoriteIconPVPMagHeal, 24, 24)
searchUI.favoriteIconTextPVPHybrid = zif(favoriteIconPVPHybrid, 24, 24)
searchUI.favoriteIconTextFarm = zif(favoriteIconFarm, 24, 24)
searchUI.favoriteIconTextSneak = zif(favoriteIconSneak, 24, 24)
searchUI.favoriteIconTextBow = zif(favoriteIconBow, 24, 24)
searchUI.favoriteIconTextDualWield = zif(favoriteIconDualWield, 24, 24)
searchUI.favoriteIconText2HD = zif(favoriteIcon2HD, 24, 24)
searchUI.favoriteIconTextFrostStaff = zif(favoriteIconFrostStaff, 24, 24)
searchUI.favoriteIconTextFireStaff = zif(favoriteIconFireStaff, 24, 24)
searchUI.favoriteIconTextLightningStaff = zif(favoriteIconLightningStaff, 24, 24)

local favoriteIconTextStar = searchUI.favoriteIconTextStar

searchUI.favoriteIconTexts = {
    star = favoriteIconTextStar,
    --PvE
    tank = searchUI.favoriteIconTextTank,
    stamDD = searchUI.favoriteIconTextStamDD,
    magDD = searchUI.favoriteIconTextMagDD,
    stamHeal = searchUI.favoriteIconTextStamHeal,
    magHeal = searchUI.favoriteIconTextMagHeal,
    hybrid = searchUI.favoriteIconTextHybrid,
    --PvP
    PVPTank = searchUI.favoriteIconTextPVPTank,
    PVPStamDD = searchUI.favoriteIconTextPVPStamDD,
    PVPMagDD = searchUI.favoriteIconTextPVPMagDD,
    PVPStamHeal = searchUI.favoriteIconTextPVPStamHeal,
    PVPMagHeal = searchUI.favoriteIconTextPVPMagHeal,
    PVPHybrid = searchUI.favoriteIconTextPVPHybrid,
    --Other
    farm = searchUI.favoriteIconTextFarm,
    sneak = searchUI.favoriteIconTextSneak,
    --Weapon types
    bow = searchUI.favoriteIconTextBow,
    dualWield = searchUI.favoriteIconTextDualWield,
    twoHand = searchUI.favoriteIconText2HD,
    frostStaff = searchUI.favoriteIconTextFrostStaff,
    fireStaff = searchUI.favoriteIconTextFireStaff,
    lightningStaff = searchUI.favoriteIconTextLightningStaff,
}
local favoriteIconTexts    = searchUI.favoriteIconTexts

local favoriteIconWithNameTexts = {}
for favoriteIconCategory, favoriteIconTexture in pairs(lib.possibleSetSearchFavoriteCategoriesUnsorted) do
    favoriteIconWithNameTexts[favoriteIconCategory] = zoitfns(favoriteIconTexture, 24, 24, getLocalizedText("favorites"))
end

local settingsIconText             = zif("esoui/art/chatwindow/chat_options_up.dds", 32, 32)

--Maximum number of set bonuses
searchUI.MAX_NUM_SET_BONUS = 12 --2023-11-05 Druids
local specialBonusSets = lib.specialBonusSets

--Search type - For the string comparison "processor". !!!Needs to match the SetupRow of the ZO_ScrollList!!!
searchUI.searchTypeDefault = 1

--Scroll list datatype - Default text
searchUI.scrollListDataTypeDefault = 1

--The text search types
local SEARCH_TYPE_NAME = "name"
local SEARCH_TYPE_BONUS = "bonus"

--The copy text dialog
local copyDialog

--Settings radio button groups (multiple checkboxes that update their checked state to false if any other of them is checked)
local radioButtonGroupsSettings = {}


--Helper functions
local function getComboBoxFromDropdownControl(dropdownControl)
    return dropdownControl.m_comboBox or dropdownControl
end


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

local function setMenuItemCheckboxState(checkboxIndex, newState, ifMatchesValue)
    if ifMatchesValue ~= nil then
        if newState == ifMatchesValue then
            ZO_CheckButton_SetChecked(ZO_Menu.items[checkboxIndex].checkbox)
        else
            ZO_CheckButton_SetUnchecked(ZO_Menu.items[checkboxIndex].checkbox)
        end
    else
        newState = newState or false
        if newState == true then
            ZO_CheckButton_SetChecked(ZO_Menu.items[checkboxIndex].checkbox)
        else
            ZO_CheckButton_SetUnchecked(ZO_Menu.items[checkboxIndex].checkbox)
        end
    end
end

-- called from clicking the "Auto reload" label
local function OnClick_CheckBoxLabel(cbControl, svEntryName, selfVar, svValueName)
    local currentState = lib.svData[svEntryName]
    if currentState == nil then return end

    --Update a SV key with a real value (not only toggling a boolean!) -> for radio groups (by checkboxes)
    if svValueName ~= nil and currentState ~= svValueName then
        lib.svData[svEntryName] = svValueName
    else
        --Only toggle a boolean
        local newState = not currentState
        lib.svData[svEntryName] = newState
    end

    --Shall the setNames be shown with/without english names? Update the list now by refreshing it and building the master list etc. new
    if selfVar ~= nil then
        if svEntryName == "setSearchShowSetNamesInEnglishToo" then
            selfVar.resultsList:RefreshData()
        end
    end
end

local function updateSettingsRadioButtonGroup(radioButtonGroupName, svEntryName, svEntryToSkip, cboxCtrl, selfVar)
    if radioButtonGroupName == nil or radioButtonGroupName == "" or ZO_IsTableEmpty(radioButtonGroupsSettings[radioButtonGroupName])
            or svEntryName == nil or lib.svData[svEntryName] == nil or svEntryToSkip == nil then return end

    for key, ZO_MenuCboxIndex in pairs(radioButtonGroupsSettings[radioButtonGroupName]) do
        --Set all checkboxes in the radio group to unchecked, except the "svEntryToSkip" one
        if key ~= svEntryToSkip then
            --Uncheck the checkbox
            setMenuItemCheckboxState(ZO_MenuCboxIndex, false)
        else
            if cboxCtrl ~= nil and selfVar ~= nil then
                --Checkbox was clicked: Set it's state = checked and update the SavedVars
                OnClick_CheckBoxLabel(cboxCtrl, svEntryName, selfVar, svEntryToSkip)
            end
        end
    end
end


local function isItemFilterTypeMatching(item, filterType)
    return item.filterType ~= nil and item.filterType == filterType
end

local function clearSearchHistory(searchType)
    --d("Clear search history, type: " ..tos(searchType))
    local settings = lib.svData
    local searchHistory = settings.setSearchHistory
    if ZO_IsTableEmpty(searchHistory[searchType]) then return end
    lib.svData.setSearchHistory[searchType] = {}
end

local function updateSearchHistory(searchType, searchValue)
    local settings = lib.svData
    local maxSearchHistoryEntries = settings.setSearchHistoryMaxEntries
    local searchHistory = settings.setSearchHistory
    searchHistory[searchType] = searchHistory[searchType] or {}
    local searchHistoryOfSearchType = searchHistory[searchType]
    local toSearch = strlow(searchValue)
    if not ZO_IsElementInNumericallyIndexedTable(searchHistoryOfSearchType, toSearch) then
        --Only keep the last 10 search entries
        tins(searchHistory[searchType], 1, searchValue)
        local countEntries = #searchHistory[searchType]
        if countEntries > maxSearchHistoryEntries then
            for i=maxSearchHistoryEntries+1, countEntries, 1 do
                searchHistory[searchType][i] = nil
            end
        end
    end
end

local function updateSearchHistoryDelayed(searchType, searchValue)
    EM:UnregisterForUpdate(searchHistoryEventUpdaterName)
    EM:RegisterForUpdate(searchHistoryEventUpdaterName, 1500, function()
        EM:UnregisterForUpdate(searchHistoryEventUpdaterName)
        updateSearchHistory(searchType, searchValue)
    end)
end

local wayshrinesAdded = {}
local wayshrineNames = {}
local function checkAndGetWayshrineName(p_wayShrines)
    if p_wayShrines and type(p_wayShrines) == "table" then
        for _, wsIndex in ipairs(p_wayShrines) do
            if wsIndex > 0 and not wayshrinesAdded[wsIndex] then
                local wsNameLocalized = nil
                --@return known bool,name string,normalizedX number,normalizedY number,icon textureName,glowIcon textureName:nilable,poiType [PointOfInterestType|#PointOfInterestType],isShownInCurrentMap bool,linkedCollectibleIsLocked bool
                --function GetFastTravelNodeInfo(nodeIndex) end
                local _, wsName = GetFastTravelNodeInfo(wsIndex)
                if wsName and wsName ~= "" then
                    wsNameLocalized = ZO_CachedStrFormat("<<C:1>>", wsName)
                    if wsNameLocalized and wsNameLocalized ~= "" then
                        wayshrinesAdded[wsIndex] = true
                        wayshrineNames[wsIndex] = wsNameLocalized
                    end
                end
            end
        end
    end
end




--Check for other addons which have added context menu entries here via API function
--LibSets.RegisterCustomSetSearchResultsListContextMenu(addonName, submenuEntries)
local function addOtherAddonsContextMenuEntries(rowControl, setId)
    local customContextMenuEntriesSetSearch = lib.customContextMenuEntries["setSearchUI"]
    --[[
    customContextMenuEntriesSetSearch[addonName] = {
        headerName  = headerName,
        name        = submenuName or addonName,
        entries     = submenuEntries,
        visible     = visibleFunc,
    }
    ]]
    local dividerWasAdded = false
    local customAddonContextmenuEntries = {}
    for addonName, _ in pairs(customContextMenuEntriesSetSearch) do
        --Loop over all entries and sort by addonName (in case any addon added multiple submenus)
        tins(customAddonContextmenuEntries, addonName)
    end
    tsort(customAddonContextmenuEntries)

    for _, addonName in ipairs(customAddonContextmenuEntries) do
        local customContextMenuEntriesData = customContextMenuEntriesSetSearch[addonName]
        if customContextMenuEntriesData ~= nil then
            local submenuName = customContextMenuEntriesData.name
            local submenuEntries = customContextMenuEntriesData.entries
            if submenuName ~= nil and submenuEntries ~= nil then
                local isVisible = true
                local isVisibleFunc = customContextMenuEntriesData.visibleFunc
                if isVisibleFunc ~= nil then
                    isVisible = isVisibleFunc(rowControl)
                end
                if isVisible == true then
                    if not dividerWasAdded then
                        AddCustomMenuItem("-", function() end)
                        dividerWasAdded = true
                    end
                    --Custom addon's name header
                    local headerName = customContextMenuEntriesData.headerName
                    if headerName ~= nil then
                        AddCustomMenuItem(headerName, function() end, MENU_ADD_OPTION_HEADER)
                    end
                    --Addon name submenu
                    AddCustomSubMenuItem(submenuName, submenuEntries)
                end
            end
        end
    end
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
    local comboBox = getComboBoxFromDropdownControl(dropdownControl)
    if comboBox:GetNumSelectedEntries() == 0 then return end
    comboBox:ClearAllSelections()
end

function LibSets_SearchUI_Shared:SelectAllAtMultiSelectDropdown(dropdownControl)
    local comboBox = getComboBoxFromDropdownControl(dropdownControl)
    comboBox:ClearAllSelections()
    for index, _ in ipairs(comboBox:GetItems()) do
        comboBox:SetSelected(index, true)
    end
end

function LibSets_SearchUI_Shared:SelectInvertMultiSelectDropdown(dropdownControl)
    local comboBox = getComboBoxFromDropdownControl(dropdownControl)
    for index, item in ipairs(comboBox:GetItems()) do
        local isCurrentlySelected = comboBox:IsItemSelected(item)
        comboBox:SetSelected(index, not isCurrentlySelected)
    end
end


function LibSets_SearchUI_Shared:SelectMultiSelectDropdownEntries(dropdownControl, entriesToSelect, refreshResultsListAfterwards)
--d("LibSets_SearchUI_Shared:SelectMultiSelectDropdownEntries")
--lib._debugDropDownControl = dropdownControl
    refreshResultsListAfterwards = refreshResultsListAfterwards or false
    if ZO_IsTableEmpty(entriesToSelect) then return end
    local comboBox = getComboBoxFromDropdownControl(dropdownControl)
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
--d("LibSets_SearchUI_Shared:UpdateSearchButtonEnabledState-isEnabled: " ..tos(isEnabled))
    if isEnabled == nil then return end
    local searchButton = self.searchButton
    if searchButton == nil then return end
    searchButton:SetEnabled(isEnabled)
    searchButton:SetMouseEnabled(isEnabled)
end


------------------------------------------------
--- Search
------------------------------------------------

function LibSets_SearchUI_Shared:UpdateSearchHistory(editBoxCtrl)
    --Get the editbox text and the searchType
    local searchValue = editBoxCtrl:GetText()
    local isEmptySearch = (searchValue == nil or searchValue == "" and true) or false
    if isEmptySearch then return end

    local searchType = (editBoxCtrl == self.searchEditBoxControl and SEARCH_TYPE_NAME) or SEARCH_TYPE_BONUS
    local settings = lib.svData
    local searchSaveHistory = (searchType == SEARCH_TYPE_NAME and settings.setSearchSaveNameHistory) or settings.setSearchSaveBonusHistory

    --Check if saving the search history is enabled for that box
    if searchSaveHistory == true then
        updateSearchHistoryDelayed(searchType, searchValue)
    end
end

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
--d("[LibSets]LibSets_SearchUI_Shared:ValidateSearchParams")
    --Validate the search parameters and raise an error message if something does not match
end

function LibSets_SearchUI_Shared:StartSearch(doNotShowUI, wasReset)
--d("[LibSets]LibSets_SearchUI_Shared:StartSearch-doNotShowUI: " ..tos(doNotShowUI) .. ", wasReset: " ..tos(wasReset))
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
--d("[LibSets]LibSets_SearchUI_Shared:Search")
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
--d(">Search was started")
        --Is a "search was done" callback function registered?
        if self.searchDoneCallback then
            self.searchDoneCallback(self)
        end
    else
--d("<Search NOT started")
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

--[[ Old func before bonus:<number> change
local function searchFilterPrefix(searchInput, searchTab)
    isBonusearch = isBonusearch or false
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
]]

local function searchFilterPrefix(searchInput, searchTab, isBonusearch, setId)
    isBonusearch = isBonusearch or false
    specialBonusSets = specialBonusSets or lib.specialBonusSets
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
--d(">searchQuery: " .. tostring(searchQuery) .. ", delim: " ..tostring(delim) .. ", curpos: " ..tostring(curpos))
		--if searchQuery:find("%S+") then   --find no whitepaces
        if searchQuery:find("[^,]+") then      --find no ,
--d(">>found no ,")
            --If bonuses are searched: searchInput could contain +crit or +crit:2 (means: +critical chance at bonus 2)
            -->So check the "current" searchInput part for a : delimiter
            local bonusLineNr, realBonusLineNr
            if isBonusearch == true then
                local searchColonOffset
                if delim == 0 then
                    searchColonOffset = 1 --Search from 1st char
                else
                    searchColonOffset = curpos --Search from cursor pos
                end
                local bonusLineNrOffset, bonusLineNrOffsetEnd = searchQuery:find("%:+", searchColonOffset) --check for :<1 digit number> in front of the , delimiter
--d(">>>bonusLineNrOffset: " .. tostring(bonusLineNrOffset))
                if bonusLineNrOffsetEnd ~= nil then
                    bonusLineNr = searchQuery:sub(bonusLineNrOffsetEnd+1, -1)
                    --Clean the searchQuery end
                    searchQuery = searchQuery:sub(1, bonusLineNrOffset-1)
                    --Check if this is a special set and get the "real" bonus line then, e.g. user enters 12 but the actual set got only 3 lines, then 12 -> 3
                    if setId ~= nil then
                        local specialBonusSetData = specialBonusSets[setId]
                        if specialBonusSetData ~= nil then
                            realBonusLineNr = specialBonusSetData[tonumber(bonusLineNr)]
--d(">>>setId: " .. tos(setId) ..", realBonusLineNr: " .. tostring(realBonusLineNr) .. "; bonusLineNr: " ..tos(bonusLineNr))
                            if realBonusLineNr ~= nil then
                                bonusLineNr = realBonusLineNr
                            end
                        end
                    end
                end
--d(">>>searchQuery: " .. tostring(searchQuery) .. ", searchColonOffset: " .. tostring(searchColonOffset) .. ", bonusLineNr: " .. tostring(bonusLineNr))
            end
            for i = 1, #searchTab do
                --No bonus line to searc? Else: Only if the current line of the table is the bonus line nr. specified
                if not isBonusearch or (bonusLineNr == nil or tonumber(bonusLineNr) == i or (realBonusLineNr ~= nil and tonumber(realBonusLineNr) == i)) then
                    if orderedSearch(searchTab[i], searchQuery) then
--d(">found string!!!")
                        found = true
                        break
                    end
                end
			end

			if found == exclude then
--d("<excluded!")
                return false
            end
		end
		curpos = delim + 1
		if delim ~= 0 then exclude = searchInput:sub(delim, delim) == "-" end
--d(">>curpos: " ..tostring(curpos) .. ", delim: " .. tostring(delim) .. ", exclude: " .. tostring(exclude))

    until delim == 0
	return true
end

function LibSets_SearchUI_Shared:CheckForMatch(data, searchInput)
--d("[LibSets_SearchUI_Shared:CheckForMatch]searchInput: " .. tos(searchInput))
    --Search by name or setId
    local namesOrIdsTab = {}
    tins(namesOrIdsTab, data.name)
    tins(namesOrIdsTab, tos(data.setId))
    return searchFilterPrefix(searchInput, namesOrIdsTab, nil, data.setId)
end


function LibSets_SearchUI_Shared:ProcessItemEntry(stringSearch, data, searchTerm)
--d("[LibSets_SearchUI_Keyboard.ProcessItemEntry] stringSearch: " ..tos(stringSearch) .. ", setName: " .. tos(data.nameLower) .. ", searchTerm: " .. tos(searchTerm))
	if zo_plainstrfind(data.nameLower, searchTerm) then
		return true
	end
	return false
end

function LibSets_SearchUI_Shared:SearchSetBonuses(bonuses, searchInput, setId)
    return searchFilterPrefix(searchInput, bonuses, true, setId)
end


------------------------------------------------
--- Filters
------------------------------------------------
function LibSets_SearchUI_Shared:OnFilterChanged(dropdownControl)
--d("[LibSets_SearchUI_Shared]OnFilterChanged - MultiSelect dropdown - hidden")
    self.searchParams = self.searchParams or {}
end

function LibSets_SearchUI_Shared:DidAnyFilterChange()
--d("[LibSets_SearchUI_Shared]DidAnyFilterChange")
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
--d("[LibSets_SearchUI_Shared]PreFilterMasterList")
--lib._debugDefaultMasterListBase = ZO_ShallowTableCopy(defaultMasterListBase)

    if defaultMasterListBase == nil or ZO_IsTableEmpty(defaultMasterListBase) then return end
    --The search parameters of the filters (multiselect dropdowns) were provided?
    -->Passed in from the LibSets_SearchUI_Shared:StartSearch() function
    local searchParams = self.searchParams
    if searchParams ~= nil and not ZO_IsTableEmpty(searchParams) then
        local setsBaseList = {}
        --Language of client, or of not supported: fallbackLang
        local langTouse = langAllowedCheck(clientLang)
        local settings = lib.svData
        local setSearchShowSetNamesInEnglishToo = settings.setSearchShowSetNamesInEnglishToo

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

            --set favorites: All icons

            if setSearchFavoritesSV ~= nil then
                for _, favoriteCategoryData in ipairs(possibleSetSearchFavoriteCategories) do
                    local favoriteCategory = favoriteCategoryData.category
                    if searchParamsFavorites ~= nil and setSearchFavoritesSV[favoriteCategory] ~= nil then
                        isAllowed = false
                        local searchParamsFavoritesOfCategoryIdIsFiltered = searchParamsFavorites[favoriteCategory]
                        if searchParamsFavoritesOfCategoryIdIsFiltered ~= nil and searchParamsFavoritesOfCategoryIdIsFiltered == true then
                            if setSearchFavoritesSV[favoriteCategory][setId] then
--d(">setId is favorite: " ..tos(setId) .. ", name: " ..tos(setData.nameClean) .. ", category: " ..tos(favoriteCategory))
                                isAllowed = true
                                break
                            end
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
            --Add to preFiltered masterList as it matches the search criteria?
            if isAllowed == true then
                setsBaseList[setId] = setData
            end
        end -- for setId, setData in pairs(defaultMasterListBase) do

--lib._debugSetsBaseList = ZO_ShallowTableCopy(setsBaseList)

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

function LibSets_SearchUI_Shared:SetSearchEditBoxValue(editBoxControl, searchTerm)
    if editBoxControl and editBoxControl.SetText then
        editBoxControl:SetText(searchTerm)
    end
end

------------------------------------------------
--- Tooltip
------------------------------------------------
local function getTooltipsPositionBasedOnSpaceLeft(control, TT_control)
    --control = search UI, or ther tooltip already shown (e.g. PopupTooltip) / TT_control = tooltip's controls to add new
    if control == nil or TT_control == nil then return end
    local anchor1, offsetX, offsetY, anchor2, shownLeftOfControl

    --Get the current position of the UI. If  the UI is moved to the left, show the tooltip right, and vice versa
    --local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local currentLeft = control:GetLeft()
    if currentLeft < TT_control:GetWidth() then
        --Show right of control
        anchor1 = LEFT
        anchor2 = RIGHT
        offsetX = 25
        offsetY = 0
    else
        --Show left of control
        anchor1 = RIGHT
        anchor2 = LEFT
        offsetX = -25
        offsetY = 0
    end
    shownLeftOfControl = anchor2 == LEFT
    return anchor1, offsetX, offsetY, anchor2, shownLeftOfControl
end

local function anchorAllTooltipsAutomatically(selfVar, rowControl, tooltipCtrl, anchorCtrl, itemLinkTooltipShownLeftOfControl)
    local isPopupTooltipCurrentlyShown = not TT_Popup:IsHidden()
    local anchor1, offsetX, offsetY, anchor2, showLeft = getTooltipsPositionBasedOnSpaceLeft(selfVar.control, tooltipCtrl)
    local anchorTo = showLeft == true and LEFT or RIGHT

    local itemLinkTooltipCtrl = selfVar.tooltipControl
    if tooltipCtrl == itemLinkTooltipCtrl and itemLinkTooltipShownLeftOfControl == nil then
        itemLinkTooltipShownLeftOfControl = showLeft
    end

    --Is the itemLinkTooltip shown too?
    if itemLinkTooltipShownLeftOfControl ~= nil then
        --Position the text tooltip on the same side of self.tooltipControlTLC (see LibSets_SearchUI_Shared:ShowItemLinkTooltip)
        --or at the other side of the setsSearchUI?
        --ItemLinkTooltip is shown left of the setSearchUI
        if itemLinkTooltipShownLeftOfControl == true then
            --[[
            if isPopupTooltipCurrentlyShown then
                if tooltipCtrl ~= TT_Popup then
                    local anchor_1, offset_X, offset_Y, anchor_2, showLeftOfItemlinkTooltip = getTooltipsPositionBasedOnSpaceLeft(TT_Popup, tooltipCtrl)
                    anchorTo = showLeftOfItemlinkTooltip == true and LEFT or RIGHT
                    if anchorTo == LEFT then
                        anchorCtrl = TT_Popup
                    end
                end
            else
            ]]
                if tooltipCtrl ~= itemLinkTooltipCtrl then
                    local anchor_1, offset_X, offset_Y, anchor_2, showLeftOfItemlinkTooltip = getTooltipsPositionBasedOnSpaceLeft(itemLinkTooltipCtrl, tooltipCtrl)
                    anchorTo = showLeftOfItemlinkTooltip == true and LEFT or RIGHT
                    if anchorTo == LEFT then
                        anchorCtrl = itemLinkTooltipCtrl
                    end
                end
            --end
        else
            --ItemLinkTooltip is shown right of the setSearchUI
            --textTooltip should be shown on right too?
            --[[
            if isPopupTooltipCurrentlyShown then
                if tooltipCtrl ~= TT_Popup then
                    local anchor_1, offset_X, offset_Y, anchor_2, showLeftOfItemlinkTooltip = getTooltipsPositionBasedOnSpaceLeft(TT_Popup, tooltipCtrl)
                    if not showLeftOfItemlinkTooltip then
                        anchorTo = RIGHT
                        anchorCtrl = TT_Popup
                    end
                end
            else
            ]]
                if not showLeft then
                    anchorTo = RIGHT
                    if tooltipCtrl ~= itemLinkTooltipCtrl then
                        anchorCtrl = itemLinkTooltipCtrl
                    end
                end
            --end
        end
    end
    return anchorCtrl, anchorTo, anchor1, offsetX, offsetY, anchor2, showLeft
end


function LibSets_SearchUI_Shared:ShowItemLinkTooltip(rowControl, data)
    self:HideItemLinkTooltip()

    local TT_control = self.tooltipControl
    data = data or (TT_control and TT_control.data)
    if data == nil or data.itemLink == nil then return end
    --local anchor1, offsetX, offsetY, anchor2, shownLeftOfControl = getTooltipsPositionBasedOnSpaceLeft(self.control, TT_control)
    local anchorCtrl, anchorTo, anchor1, offsetX, offsetY, anchor2, shownLeftOfControl = anchorAllTooltipsAutomatically(self, rowControl, TT_control, self.control, nil)

    --Show the tooltip
    InitializeTooltip(TT_control, anchorCtrl, anchor1, offsetX, offsetY, anchor2)
    TT_control:SetLink(data.itemLink)

    self.tooltipControlTLC:BringWindowToTop()

    return shownLeftOfControl
end

function LibSets_SearchUI_Shared:HideItemLinkTooltip()
    ClearTooltip(self.tooltipControl)
end


function LibSets_SearchUI_Shared:ShowItemLinkPopupTooltip(parent, data, auto)
    self:HideItemLinkPopupTooltip()
    auto = auto or false

    if data == nil or data.itemLink == nil then return end

    local TT_control = TT_Popup
    local anchor1, offsetX, offsetY, anchor2

    if not auto then
        local setSearchPopupTooltipPosition = lib.svData.setSearchPopupTooltipPosition
        if setSearchPopupTooltipPosition == LEFT then
            anchor1 = RIGHT
            anchor2 = LEFT
            offsetX = -10
            offsetY = 0
        elseif setSearchPopupTooltipPosition == RIGHT then
            anchor1 = LEFT
            anchor2 = RIGHT
            offsetX = 10
            offsetY = 0
        else
            return
        end
    else
        anchor1, offsetX, offsetY, anchor2 = getTooltipsPositionBasedOnSpaceLeft(self.control, TT_control)
    end
    --Show the tooltip
    InitializeTooltip(TT_control, parent, anchor1, offsetX, offsetY, anchor2)
    TT_control:SetLink(data.itemLink)
end

function LibSets_SearchUI_Shared:HideItemLinkPopupTooltip()
    ClearTooltip(TT_Popup)
end

function LibSets_SearchUI_Shared:ShowSetDropLocationTooltip(rowControl, data, itemLinkTooltipShownLeftOfControl)
    ZO_Tooltips_HideTextTooltip()
    if not lib.svData.showSetSearchDropLocationTooltip then return end
    if data.setDataText == nil then return end

    local owningCtrl = rowControl:GetOwningWindow()
    local anchorCtrl = owningCtrl
    local anchorTo = RIGHT
    anchorCtrl, anchorTo = anchorAllTooltipsAutomatically(self, rowControl, TT_Text, anchorCtrl, itemLinkTooltipShownLeftOfControl)

    local dropLocationText = "|cF0F0F0" .. data.name .. "|r\n\n" .. data.setDataText
    ZO_Tooltips_ShowTextTooltip(anchorCtrl, anchorTo, dropLocationText)
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

function LibSets_SearchUI_Shared:GetNextFavoritesCategory(setId)
    local setSearchFavorites = lib.svData.setSearchFavorites
    for favoriteCategory, data in pairs(setSearchFavorites) do
        if data ~= nil and data[setId] then
            return favoriteCategory
        end
    end
    return
end

function LibSets_SearchUI_Shared:IsSetIdInFavorites(setId, favoriteCategory)
    if favoriteCategory == nil then return false end
    local setSearchFavorites = lib.svData.setSearchFavorites
    return (setSearchFavorites[favoriteCategory] ~= nil and setSearchFavorites[favoriteCategory][setId]) or false
end

function LibSets_SearchUI_Shared:AddSetIdToFavorites(rowControl, setId, favoriteCategory)
    if self:IsSetIdInFavorites(setId, favoriteCategory) then return end
    if favoriteCategory == nil then return end
    if possibleSetSearchFavoriteCategoriesUnsorted[favoriteCategory] == nil then return end

    lib.svData.setSearchFavorites[favoriteCategory] = lib.svData.setSearchFavorites[favoriteCategory] or {}
    lib.svData.setSearchFavorites[favoriteCategory][setId] = true

    self.resultsList:AddFavorite(rowControl, favoriteCategory)
end

function LibSets_SearchUI_Shared:RemoveSetIdFromFavorites(rowControl, setId, favoriteCategory)
    if not self:IsSetIdInFavorites(setId, favoriteCategory) then return end
    if possibleSetSearchFavoriteCategoriesUnsorted[favoriteCategory] == nil then return end
    if lib.svData.setSearchFavorites[favoriteCategory] ~= nil then
        lib.svData.setSearchFavorites[favoriteCategory][setId] = nil
    end

    self.resultsList:RemoveFavorite(rowControl, favoriteCategory)
    self.resultsList:RefreshData() --To update filtered rows
end

function LibSets_SearchUI_Shared:RemoveAllSetFavorites(favoriteCategory)
    if possibleSetSearchFavoriteCategoriesUnsorted[favoriteCategory] == nil then return end
    local setFavorites = lib.svData.setSearchFavorites[favoriteCategory]
    if ZO_IsTableEmpty(setFavorites) then return end
    lib.svData.setSearchFavorites[favoriteCategory] = {}
    self.resultsList:RefreshData() --To remove the Favorite markers
end

function LibSets_SearchUI_Shared:ShowSettingsMenu(anchorControl)
    if not LibCustomMenu then return end
    local selfVar = self
    ClearMenu()
    --Settings headline
    AddCustomMenuItem(settingsIconText .. " " .. GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1305), function() end, MENU_ADD_OPTION_HEADER)

    --Show LibSets settings
    AddCustomMenuItem(showLibSetsSettingsStr, function() libSets_showSettingsMenu() end)


    --What should happen by default if we left click a row?
    -->Multiple checkboxes here, just auto uncheck others via the table radioButtonGroupRowLeftLickDefaultAction
    radioButtonGroupsSettings["rowLeftLickDefaultAction"] = {}

    --Default left click action = link to chat
    AddCustomMenuItem(defaultActionLeftClickStr .." |t100.000000%:100.000000%:EsoUI/Art/Miscellaneous/icon_LMB.dds|t", function() end, MENU_ADD_OPTION_HEADER)
    local cbDefaultActionLeftClickOnRowLinkToChatIndex = AddCustomMenuItem(linkToChatStr,
            function(cboxCtrl)
                --OnClick_CheckBoxLabel(cboxCtrl, "setSearchUIRowLeftClickDefaultAction", selfVar, "linkToChat")
                updateSettingsRadioButtonGroup("rowLeftLickDefaultAction", "setSearchUIRowLeftClickDefaultAction", "linkToChat", cboxCtrl, selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbDefaultActionLeftClickOnRowLinkToChatIndex, lib.svData.setSearchUIRowLeftClickDefaultAction, "linkToChat")
    radioButtonGroupsSettings["rowLeftLickDefaultAction"]["linkToChat"] = cbDefaultActionLeftClickOnRowLinkToChatIndex

    --Default left click action = Popup tooltip
    local cbDefaultActionLeftClickOnRowPopupTooltipIndex = AddCustomMenuItem(popupTooltipStr,
            function(cboxCtrl)
                --OnClick_CheckBoxLabel(cboxCtrl, "setSearchUIRowLeftClickDefaultAction", selfVar, "popupTooltip")
                updateSettingsRadioButtonGroup("rowLeftLickDefaultAction", "setSearchUIRowLeftClickDefaultAction", "popupTooltip", cboxCtrl, selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbDefaultActionLeftClickOnRowPopupTooltipIndex, lib.svData.setSearchUIRowLeftClickDefaultAction, "popupTooltip")
    radioButtonGroupsSettings["rowLeftLickDefaultAction"]["popupTooltip"] = cbDefaultActionLeftClickOnRowPopupTooltipIndex



    --Tooltips
    AddCustomMenuItem(tooltipsStr, function() end, MENU_ADD_OPTION_HEADER)
    local cbShowTextFilterTooltipsIndex = AddCustomMenuItem(getLocalizedText("textBoxFilterTooltips"),
            function(cboxCtrl)
                OnClick_CheckBoxLabel(cboxCtrl, "setSearchTooltipsAtTextFilters", selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbShowTextFilterTooltipsIndex, lib.svData.setSearchTooltipsAtTextFilters)
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


    --Dropped by
    AddCustomMenuItem(getLocalizedText("droppedBy"), function() end, MENU_ADD_OPTION_HEADER)
    local cbShowSetDroppedByExtraTooltipIndex = AddCustomMenuItem(showAsTooltipStr,
            function(cboxCtrl)
                OnClick_CheckBoxLabel(cboxCtrl, "showSetSearchDropLocationTooltip", selfVar)
            end,
            MENU_ADD_OPTION_CHECKBOX)
    setMenuItemCheckboxState(cbShowSetDroppedByExtraTooltipIndex, lib.svData.showSetSearchDropLocationTooltip)

    --Set names
    if clientLang ~= fallbackLang then
        AddCustomMenuItem(setNamesStr, function() end, MENU_ADD_OPTION_HEADER)
        --AddCustomMenuItem("-", function() end)
        local cbShowSetNamesInEnglishTooIndex = AddCustomMenuItem(getLocalizedText("searchUIShowSetNameInEnglishToo"),
                function(cboxCtrl)
                    OnClick_CheckBoxLabel(cboxCtrl, "setSearchShowSetNamesInEnglishToo", selfVar)
                end,
                MENU_ADD_OPTION_CHECKBOX)
        setMenuItemCheckboxState(cbShowSetNamesInEnglishTooIndex, lib.svData.setSearchShowSetNamesInEnglishToo)
    end

    --Favorites
    local setSearchFavorites = lib.svData.setSearchFavorites
    local wasFavoriteHeaderAdded = false
    for _, favoriteCategoryData in ipairs(possibleSetSearchFavoriteCategories) do
        local favoriteCategory = favoriteCategoryData.category
        if not ZO_IsTableEmpty(setSearchFavorites[favoriteCategory]) then
            if not wasFavoriteHeaderAdded then
                AddCustomMenuItem(favoritesStr, function() end, MENU_ADD_OPTION_HEADER)
                wasFavoriteHeaderAdded = true
            end
            AddCustomMenuItem(favoriteIconWithNameTexts[favoriteCategory] .. " " .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .. " '" .. zo_strformat("<<C:1>>", favoriteCategory) .. "'", function()
                self:RemoveAllSetFavorites(favoriteCategory)
            end)
        end
    end

    ShowMenu(anchorControl)
end

function LibSets_SearchUI_Shared:ShowRowContextMenu(rowControl)
    if not LibCustomMenu then return end
    local data = rowControl.data
    if data == nil then return end
    local setId = rowControl.data.setId
    local owningWindow = rowControl:GetOwningWindow()

    ClearMenu()

    --Link to chat
    AddCustomMenuItem(getLocalizedText("linkToChat"), function()
        self:ItemLinkToChat(rowControl.data)
    end)

    --Tooltips
    AddCustomMenuItem(getLocalizedText("tooltips"), function() end, MENU_ADD_OPTION_HEADER)

    --Popup tooltip
    local popupTooltipSubmenu = {
        {
            label = GetString(SI_KEYBINDDISPLAYMODE2), --Automatic
            callback =function()
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, true)
            end
        },
        {
            label = "-",
            callback = function() end,
        },
        {
            label = GetString(SI_NAMEPLATEDISPLAYCHOICE10), --Left (SI_KEYCODE_NARRATIONTEXTPS4125)
            callback = function()
                lib.svData.setSearchPopupTooltipPosition = LEFT
                --self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, RIGHT, -10, nil, LEFT)
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data)
            end
        },
        {
            label = GetString(SI_BINDING_NAME_TURN_RIGHT), --Right (SI_KEYCODE_NARRATIONTEXTPS4126)
            callback =function()
                lib.svData.setSearchPopupTooltipPosition = RIGHT
                --self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data, RIGHT, -10, nil, LEFT)
                self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data)
            end
        },
    }
    AddCustomMenuItem(getLocalizedText("popupTooltip"), function() self:ShowItemLinkPopupTooltip(owningWindow, rowControl.data) end)
    AddCustomSubMenuItem(getLocalizedText("popupTooltipPosition"), popupTooltipSubmenu)

    --Set favorites
    if setId ~= nil then
        --Set search favorites
        local setSearchFavorites = lib.svData.setSearchFavorites
        local wasFavoriteHeaderAdded = false
        local favoriteCategoriesToAddSubmenuEntries = {}
        for _, favoriteCategoryData in ipairs(possibleSetSearchFavoriteCategories) do
            local favoriteCategory = favoriteCategoryData.category
--d("[LibSets]LibSets_SearchUI_Shared:ShowRowContextMenu - favoriteCategory: " ..tos(favoriteCategory))
            --if not ZO_IsTableEmpty(setSearchFavorites[favoriteCategory]) then
                if not wasFavoriteHeaderAdded then
                    AddCustomMenuItem(favoriteIconWithNameTexts[favoriteCategory], function() end, MENU_ADD_OPTION_HEADER)
                    wasFavoriteHeaderAdded = true
                end
                if self:IsSetIdInFavorites(setId, favoriteCategory) then
                    AddCustomMenuItem(favoriteIconTexts[favoriteCategory] .. " " .. GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE) .. " '" .. zo_strformat("<<C:1>>", favoriteCategory) .. "'", function()
                        self:RemoveSetIdFromFavorites(rowControl, setId, favoriteCategory)
                    end)
                else
                    --Add submenu with favorites that could be added
                    --[[
                    AddCustomMenuItem(favoriteIconTexts[favoriteCategory] .. " " .. GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE) .. " '" .. zo_strformat("<<C:1>>", favoriteCategory) .. "'", function()
                        self:AddSetIdToFavorites(rowControl, setId, favoriteCategory)
                    end)
                    ]]
                    local subMenuEntry = {
                        label 		    = favoriteIconTexts[favoriteCategory] .. zo_strformat("<<C:1>>", favoriteCategory),
                        callback 	    = function() self:AddSetIdToFavorites(rowControl, setId, favoriteCategory) end
                    }
                    table.insert(favoriteCategoriesToAddSubmenuEntries, subMenuEntry)
                end
            --end
        end
        if not ZO_IsTableEmpty(favoriteCategoriesToAddSubmenuEntries) then
            AddCustomSubMenuItem(GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE), favoriteCategoriesToAddSubmenuEntries)
        end

        --Drop zones
        local setDropZones = libSets_GetDropZonesBySetId(setId)
        local zoneIdSubmenuEntries = {}
        if not ZO_IsTableEmpty(setDropZones) then
            local alreadyAddedZoneIds = {}
            for _, zoneId in ipairs(data.zoneIds) do
                if zoneId ~= -1 and not alreadyAddedZoneIds[zoneId] then
                    local zoneName = libSets_GetZoneName(zoneId)
                    local subMenuEntry = {
                        label 		    = zoneName,
                        callback 	    = function() libSets_OpenMapOfZoneId(zoneId) end
                    }
                    table.insert(zoneIdSubmenuEntries, subMenuEntry)
                    alreadyAddedZoneIds[zoneId] = true
                end
            end
        end

        --Wayshrines
        --Get the drop location wayshrines
        local wayshrinesSubmenuEntries = {}
        local setWayshrines = libSets_GetWayshrineIds(setId)
        if not ZO_IsTableEmpty(setWayshrines) then
            checkAndGetWayshrineName(setWayshrines)

            local alreadyAddedWayshrines = {}
            for _, wayshrineNodeIndex in ipairs(setWayshrines) do
                if wayshrineNodeIndex > 0 and not alreadyAddedWayshrines[wayshrineNodeIndex] then
                    --GetFastTravelNodeInfo(*luaindex* _nodeIndex_)
                    --** _Returns:_ *bool* _known_, *string* _name_, *number* _normalizedX_, *number* _normalizedY_, *textureName* _icon_, *textureName:nilable* _glowIcon_, *[PointOfInterestType|#PointOfInterestType]* _poiType_, *bool* _isShownInCurrentMap_, *bool* _linkedCollectibleIsLocked_
                    local wsKnown, wsName = GetFastTravelNodeInfo(wayshrineNodeIndex)
                    local wayshrineName = ZO_CachedStrFormat("<<C:1>>", wsName)
                    if not wsKnown then
                        wayshrineName = wayshrineName .. " <|cFF0000" .. GetString(SI_INPUT_LANGUAGE_UNKNOWN) .. "|r>"
                    end
                    local subMenuEntry = {
                        label 		    = wayshrineName,
                        callback 	    = function() libSets_ShowWayshrineNodeIdOnMap(wayshrineNodeIndex) end
                    }
                    table.insert(wayshrinesSubmenuEntries, subMenuEntry)
                    alreadyAddedWayshrines[wayshrineNodeIndex] = true
                end
            end

        end

        local gotDropZones = not ZO_IsTableEmpty(zoneIdSubmenuEntries)
        local gotWayshrines = not ZO_IsTableEmpty(wayshrinesSubmenuEntries)
        if gotDropZones or gotWayshrines then
            AddCustomMenuItem(dropZoneAndWayshrinesStr, function() end, MENU_ADD_OPTION_HEADER)
            if gotDropZones then
                AddCustomSubMenuItem(dropZonesStr, zoneIdSubmenuEntries)
            end
            if gotWayshrines then
                AddCustomSubMenuItem(wayshrinesStr, wayshrinesSubmenuEntries)
            end
        end

        --SetData text
        if data.setDataText ~= nil then
            --Tooltip enhancements are enabled

            --Show a special tooltip with the set drop location text only
            -->Moved to SavedVariables as general setting
            --[[
            local function toggleSetDropLocationTooltip()
                lib.showSetSearchDropLocationTooltip = not lib.showSetSearchDropLocationTooltip
            end

            AddCustomMenuItem(getLocalizedText("droppedBy"), function() end, MENU_ADD_OPTION_HEADER)
            local showAsTooltipEnabledState = getLocalizedText("showAsTooltip") .. ": " .. tos(booleanToOnOff[not lib.showSetSearchDropLocationTooltip])
            AddCustomMenuItem(showAsTooltipEnabledState, function()
                ZO_Tooltips_HideTextTooltip()
                toggleSetDropLocationTooltip()
                self:ShowSetDropLocationTooltip(rowControl, data)
            end)
            ]]


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

            AddCustomMenuItem(getLocalizedText("setInfos"), function() end, MENU_ADD_OPTION_HEADER)
            AddCustomMenuItem(getLocalizedText("showAsText"), function()
                getSetTextForCopyDialog(false)
            end)
            AddCustomMenuItem(getLocalizedText("showAsTextWithIcons"), function()
                getSetTextForCopyDialog(true)
            end)
        end

        --Check for other addons which have added context menu entries here via API function
        --LibSets.AddSetSearchResultsListContextMenuEntries(addonName, submenuEntries)
        addOtherAddonsContextMenuEntries(rowControl, setId)
    end
    ShowMenu(rowControl)
end

function LibSets_SearchUI_Shared:ShowDropdownContextMenu(dropdownControl, shift, alt, ctrl, command)
    if LibCustomMenu == nil then return end
    local selfVar = self
    local comboBox = getComboBoxFromDropdownControl(dropdownControl)

    --Multiselect filter dropdown context menu?
    if selfVar.multiSelectFilterDropdowns ~= nil and ZO_IsElementInNumericallyIndexedTable(selfVar.multiSelectFilterDropdowns, dropdownControl) then
        ClearMenu()
        local numEntries = comboBox:GetNumItems()
        local numSelectedEntries = comboBox:GetNumSelectedEntries()
        local notAllSelected = numSelectedEntries < numEntries

        if notAllSelected then
            --Select all
            AddCustomMenuItem(GetString(SI_ITEMFILTERTYPE0), function()
                selfVar:SelectAllAtMultiSelectDropdown(dropdownControl)
                selfVar:OnFilterChanged(dropdownControl)
            end)
        end

        if numSelectedEntries > 0 then
            if notAllSelected then
                --Invert selection
                AddCustomMenuItem(invertSelectionStr, function()
                    selfVar:SelectInvertMultiSelectDropdown(dropdownControl)
                    selfVar:OnFilterChanged(dropdownControl)
                end)
            end

            --Clear all selections
            AddCustomMenuItem(GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1), function()
                selfVar:ResetMultiSelectDropdown(dropdownControl)
                selfVar:OnFilterChanged(dropdownControl)
            end)
        end

        --Favorite filter muliselect dropdown?
        if dropdownControl == self.favoritesFiltersControl then
            AddCustomMenuItem("-")
            for _, favoriteCategoryData in ipairs(possibleSetSearchFavoriteCategories) do
                local favoriteCategory = favoriteCategoryData.category
                local entriesToSelect = { [1] = favoriteCategory }
                AddCustomMenuItem(favoriteIconWithNameTexts[favoriteCategory] .. " '" .. zo_strformat("<<C:1>>", favoriteCategory) .. "'", function() selfVar:SelectMultiSelectDropdownEntries(dropdownControl, entriesToSelect, true) end)
            end

            --Zones filter muliselect dropdown?
        elseif dropdownControl == self.dropZoneFiltersControl then
            AddCustomMenuItem("-")
            local setIdsOfCurrentZone, currentZoneId, currentParentZoneId = libSets_getsetIdsOfCurrentZone()
            if not ZO_IsTableEmpty(setIdsOfCurrentZone) then
                local currentZoneName, currentParentZoneName = libSets_getCurrentZoneName()
                local currentZoneSetStr = getLocalizedText("showCurrentZoneSets") .. " \'" .. currentZoneName .. "\' (" ..tos(currentZoneId) .. ")"

                local entriesToSelect = { [1] = currentZoneId }
                AddCustomMenuItem(currentZoneSetStr, function() selfVar:SelectMultiSelectDropdownEntries(dropdownControl, entriesToSelect, true) end)
                if currentParentZoneId ~= nil and currentParentZoneId ~= currentZoneId then
                    local currentParentZoneSetStr = getLocalizedText("showCurrentZoneSets") .. " \'" .. currentParentZoneName .. "\' (" ..tos(currentParentZoneId) .. ")"
                    local entriesForParentZoneToSelect = { [1] = currentParentZoneId }
                    AddCustomMenuItem(currentParentZoneSetStr, function() selfVar:SelectMultiSelectDropdownEntries(dropdownControl, entriesForParentZoneToSelect, true) end)
                end
            end
        end

        ShowMenu(dropdownControl)
    end
end

function LibSets_SearchUI_Shared:OnSearchEditBoxContextMenu(editBoxControl, shift, alt, ctrl, command)
--d("LibSets_SearchUI_Shared:OnSearchEditBoxContextMenu")
    if LibCustomMenu == nil then return end
    local selfVar = self
    local settings = lib.svData
    local doShowMenu = false

    --Search set name/id text field
    if editBoxControl == selfVar.searchEditBoxControl then
        --Add search history entries
        if settings.setSearchSaveNameHistory then
            local searchHistory = settings.setSearchHistory
            local searchType = SEARCH_TYPE_NAME
            local searchHistoryOfSearchMode = searchHistory[searchType]
            if searchHistoryOfSearchMode ~= nil and #searchHistoryOfSearchMode > 0 then
                ClearMenu()
                for _, searchTerm in ipairs(searchHistoryOfSearchMode) do
                    AddCustomMenuItem(searchTerm, function()
                        selfVar:SetSearchEditBoxValue(editBoxControl, searchTerm)
                        ClearMenu()
                    end)
                end
                AddCustomMenuItem("-", function() end)
                AddCustomMenuItem(clearSearchHistoryStr, function()
                    clearSearchHistory(searchType)
                    ClearMenu()
                end)
                doShowMenu = true
            end
        end
    --Bonus text field
    elseif editBoxControl == selfVar.bonusSearchEditBoxControl then
        ClearMenu()
        if settings.setSearchSaveBonusHistory then
            local searchHistory = settings.setSearchHistory
            local searchType = SEARCH_TYPE_BONUS
            local searchHistoryOfSearchMode = searchHistory[searchType]
            if searchHistoryOfSearchMode ~= nil and #searchHistoryOfSearchMode > 0 then
                ClearMenu()
                for _, searchTerm in ipairs(searchHistoryOfSearchMode) do
                    AddCustomMenuItem(searchTerm, function()
                        selfVar:SetSearchEditBoxValue(editBoxControl, searchTerm)
                        ClearMenu()
                    end)
                end
                AddCustomMenuItem("-", function() end)
                AddCustomMenuItem(clearSearchHistoryStr, function()
                    clearSearchHistory(searchType)
                    ClearMenu()
                end)
                doShowMenu = true
            end
        end
    end
    --Show the context menu now?
    if doShowMenu == true then
        ShowMenu(editBoxControl)
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
    InitializeTooltip(TT_Text, anchorTo, myAnchorPoint, offsetX, offsetY, toAnchorPoint)
    SetTooltipText(TT_Text, control.tooltipText)
end

function LibSets_SearchUI_Shared_SortHeaderTooltip(sortHeaderColumn)
    if sortHeaderColumn == nil or sortHeaderColumn.name == nil or sortHeaderColumn.name == "" then return end
    local nameLabel = sortHeaderColumn:GetNamedChild("Name")
    if nameLabel ~= nil and nameLabel:WasTruncated() then
        InitializeTooltip(TT_Text, sortHeaderColumn, BOTTOM, 0, -10, TOP)
        SetTooltipText(TT_Text, sortHeaderColumn.name)
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
    ZO_Tooltips_HideTextTooltip()
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
    ZO_Tooltips_HideTextTooltip()
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