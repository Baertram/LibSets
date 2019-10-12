--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets

local APIVersions = {}
--The actual API version on the live server we are logged in
APIVersions["live"] = GetAPIVersion()

--The current PTS APIVersion
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Update this if PTS increases to a new APIVersion !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
APIVersions["PTS"] = 100029 --Dragonhold
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

lib.APIVersions = APIVersions

--Check if the PTS APIVersion is now live
local function checkIfPTSAPIVersionIsLive()
    local APIVersionLive = APIVersions["live"]
    local APIVersionPTS  = APIVersions["PTS"]
    return (APIVersionLive >= APIVersionPTS) or false
end

------------------------------------------------------------------------------------------------------------------------
--The last checked API version for the setsData in file LibSets_Data.lua, see table "lib.setDataPreloaded = { ..."
-->Update here after a new scan of the set itemIds was done -> See LibSets_Data.lua, description in this file
-->above the sub-table ["setItemIds"] (data from debug function LibSets.DebugScanAllSetData())
lib.lastSetsPreloadedCheckAPIVersion    = 100029 --Scalebreaker
------------------------------------------------------------------------------------------------------------------------
--DLC & Chapter ID constants (for LibSets)
DLC_BASE_GAME               = 0
DLC_IMPERIAL_CITY           = 1
DLC_ORSINIUM                = 2
DLC_THIEVES_GUILD           = 3
DLC_DARK_BROTHERHOOD        = 4
DLC_SHADOWS_OF_THE_HIST     = 5
DLC_MORROWIND               = 6
DLC_HORNS_OF_THE_REACH      = 7
DLC_CLOCKWORK_CITY          = 8
DLC_DRAGON_BONES            = 9
DLC_SUMMERSET               = 10
DLC_WOLFHUNTER              = 11
DLC_MURKMIRE                = 12
DLC_WRATHSTONE              = 13
DLC_ELSWEYR                 = 14
DLC_SCALEBREAKER            = 15
if checkIfPTSAPIVersionIsLive() then
    DLC_DRAGONHOLD            = 16
end

--Internal achievement example ids of the ESO DLCs and chapters (first achievementId found from each DLC category)
lib.dlcAndChapterAchievementIds = {
    --Imperial city
    [DLC_IMPERIAL_CITY] = 1267,
    --Orsinium
    [DLC_ORSINIUM] = 1393,
    --Thieves Guild
    [DLC_THIEVES_GUILD] = 1413,
    --Dark Brotherhood
    [DLC_DARK_BROTHERHOOD] = 1421,
    --Shadows of the Hist
    [DLC_SHADOWS_OF_THE_HIST] = 1520,
    --Morrowind
    [DLC_MORROWIND] = 1843,
    --Horns of the Reach
    [DLC_HORNS_OF_THE_REACH] = 1940,
    --Clockwork City
    [DLC_CLOCKWORK_CITY] = 2048,
    --Dragon Bones
    [DLC_DRAGON_BONES] = 2104,
    --Summerset
    [DLC_SUMMERSET] = 1845,
    --Wolfhunter
    [DLC_WOLFHUNTER] = 2157,
    --Murkmire
    [DLC_MURKMIRE] = 2340,
    --Wrathstone
    [DLC_WRATHSTONE] = 2265,
    --Elsweyr
    [DLC_ELSWEYR] = 2463,
    --Scalebreaker
    [DLC_SCALEBREAKER] = 2413,
}
if checkIfPTSAPIVersionIsLive() then
    lib.dlcAndChapterAchievementIds[DLC_DRAGONHOLD] = 2534
end


--Internal achievement example ids of the ESO DLCs and chapters
local dlcAndChapterAchievementIds = lib.dlcAndChapterAchievementIds
--For each entry in the list of example achievements above get the name of it's parent category (DLC, chapter)
lib.DLCData = {}
local DLCandCHAPTERdata = lib.DLCData
for dlcId, dlcAchievementId in ipairs(dlcAndChapterAchievementIds) do
    if dlcId and dlcAchievementId and dlcAchievementId > 0 then
        DLCandCHAPTERdata[dlcId] = ZO_CachedStrFormat("<<C:1>>", GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(dlcAchievementId)))
    end
end