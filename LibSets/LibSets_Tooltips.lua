--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
LibSets = LibSets or {}
local lib = LibSets
local MAJOR, MINOR = lib.name, lib.versio

local EM = EVENT_MANAGER

local tos = tostring
local strgmatch = string.gmatch
local strlower = string.lower
--local strlen = string.len
local strfind = string.find
local strsub = string.sub
local strfor = string.format

local tins = table.insert
local trem = table.remove
local tsort = table.sort
local unp = unpack
local zocstrfor = ZO_CachedStrFormat

--Add set information like the drop location to the tooltips

--Possible tooltips controls
--ZO_PopupToolTip
--ZO_ItemToolTip
local tooltipCtrls = {
    PopupTooltip,
    InformationTooltip,
    ComparativeTooltip1,
    ComparativeTooltip2,
}

--todo


local function onPlayerActivatedTooltips()
    EM:UnregisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED) --only load once

    --todo hook into the tooltip types
    --check if tooltip shows a set item
    --check savedvariables of LibSets about tooltips
    --add line of set information like chosen in the LAM settings of LibSets
end

local function loadTooltipHooks()
    EM:RegisterForEvent(MAJOR .. "_Tooltips", EVENT_PLAYER_ACTIVATED, onPlayerActivatedTooltips)
end
lib.loadTooltipHooks = loadTooltipHooks
