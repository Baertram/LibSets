local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

--The search UI table
local searchUI = LibSets.SearchUI
local searchUIName = searchUI.name

------------------------------------------------------------------------------------------------------------------------
--Search UI for gamepad mode
------------------------------------------------------------------------------------------------------------------------

LibSets_SearchUI_Gamepad = LibSets_SearchUI_Shared:Subclass()

function LibSets_SearchUI_Gamepad:New(...)
    return LibSets_SearchUI_Shared.New(self, ...)
end

function LibSets_SearchUI_Gamepad:Initialize(control)
    LibSets_SearchUI_Shared.Initialize(self, control)

    local content = self.content
    --self.resultsList = content:GetNamedChild("ResultsList")
    --self.counter = content:GetNamedChild("Counter")

    --self.tooltipControl = LibSets_SearchUI_Tooltip -- The set item tooltip preview -> How to show that in gamepad mode? Left/Right scrollabale list scene/fragment?

    --self:InitializeFilters() --init the multi select dropdown filters etc.

    SYSTEMS:RegisterGamepadObject(searchUIName, self)
end

------------------------------------------------
--- Filters
------------------------------------------------

function LibSets_SearchUI_Gamepad:GetSelectedMultiSelectDropdownFilters(multiSelectDropdown)
    local selectedFilterTypes = {}

    if multiSelectDropdown:GetNumSelectedItems() == 0 then return selectedFilterTypes end

    for _, item in ipairs(multiSelectDropdown:GetAllItems()) do
        if multiSelectDropdown:IsItemSelected(item) then
            selectedFilterTypes[item.filterType] = true
        end
    end
    return selectedFilterTypes
end

function LibSets_SearchUI_Gamepad:SetMultiSelectDropdownFilters(multiSelectDropdown, entriesToSelect)
    self:ResetMultiSelectDropdown(multiSelectDropdown)

    for _, item in ipairs(multiSelectDropdown:GetAllItems()) do
        for entry, shouldSelect in pairs(entriesToSelect) do
            if shouldSelect == true and entry == item.filterType then
                multiSelectDropdown:AddItemToSelected(item)
                break -- inner loop
            end
        end
    end

    multiSelectDropdown:RefreshSelectedItemText()
end


--[[ XML Handlers ]]--
function LibSets_SearchUI_Gamepad_TopLevel_OnInitialized(self)
	LIBSETS_SEARCH_UI_GAMEPAD = LibSets_SearchUI_Gamepad:New(self)
end


