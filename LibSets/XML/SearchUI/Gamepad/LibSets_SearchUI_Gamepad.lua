local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
--local libPrefix = "["..MAJOR.."]"

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

--[[
function LibSets_SearchUI_Gamepad:InitializeFilters()
    self.craftingTypeFilterEntries = ZO_MultiSelection_ComboBox_Data_Gamepad:New()
    for _, craftingType in ipairs(ZO_UNIVERSAL_DECONSTRUCTION_CRAFTING_TYPES) do
        local entry = ZO_ComboBox_Base:CreateItemEntry(GetString("SI_TRADESKILLTYPE", craftingType))
        entry.craftingType = craftingType

        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            entry.onEnter = function(control, data)
                local tooltipText = ZO_GetJewelryCraftingLockedMessage()
                if tooltipText then
                    GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(GAMEPAD_LEFT_TOOLTIP, tooltipText)
                end
            end

            entry.onExit = function(control, data)
                local label = GetString(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_LABEL)
                local description = GetString(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DESCRIPTION)
                GAMEPAD_TOOLTIPS:LayoutTitleAndDescriptionTooltip(GAMEPAD_LEFT_TOOLTIP, label, description)
            end
        end

        self.craftingTypeFilterEntries:AddItem(entry)
    end
    self:RefreshAccessibleCraftingTypeFilters()

    self.filters =
    {
        [FILTER_INCLUDE_BANKED] =
        {
            header = GetString(SI_GAMEPAD_SMITHING_FILTERS),
            filterName = GetString(SI_CRAFTING_INCLUDE_BANKED),
            filterTooltip = GetString(SI_CRAFTING_INCLUDE_BANKED_TOOLTIP),
            checked = false,
        },
        [FILTER_CRAFTING_TYPES] =
        {
            dropdownData = self.craftingTypeFilterEntries,
            filterName = GetString(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_LABEL),
            filterTooltip = GetString(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DESCRIPTION),
            multiSelection = true,
            multiSelectionTextFormatter = SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT,
            noSelectionText = GetString(SI_SMITHING_DECONSTRUCTION_CRAFTING_TYPES_DROPDOWN_TEXT_DEFAULT),
            sorted = true,
        },
    }
end

function LibSets_SearchUI_Gamepad:RefreshAccessibleCraftingTypeFilters()
    local craftingTypeItems = self.craftingTypeFilterEntries:GetAllItems()
    for _, craftingTypeItem in ipairs(craftingTypeItems) do
        local enabled = not (craftingTypeItem.craftingType == CRAFTING_TYPE_JEWELRYCRAFTING and not ZO_IsJewelryCraftingEnabled())
        self.craftingTypeFilterEntries:SetItemEnabled(craftingTypeItem, enabled)
    end
end
]]

--[[ XML Handlers ]]--
function LibSets_SearchUI_Gamepad_TopLevel_OnInitialized(self)
	LIBSETS_SEARCH_UI_GAMEPAD = LibSets_SearchUI_Gamepad:New(self)
end


