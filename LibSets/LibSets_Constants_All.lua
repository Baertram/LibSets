--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets

--Helper function for the API check
local checkIfPTSAPIVersionIsLive = lib.checkIfPTSAPIVersionIsLive

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
DLC_DRAGONHOLD              = 16
DLC_HARROWSTORM             = 17
DLC_GREYMOOR                = 18
--End of iteration over DLC ids. !!!!! Increase this variable to the maximum DLC id if new DLC ids are added !!!!!
if checkIfPTSAPIVersionIsLive() then
    DLC_STONETHORN          = 19
end
--Iterators for the ESO dlc and chapter constants
--You can use the function
DLC_ITERATION_BEGIN = DLC_BASE_GAME
--Remember to increase the DLC id here to the newest DLC Id, for the maximum iteration
DLC_ITERATION_END = DLC_STONETHORN or DLC_GREYMOOR
lib.allowedDLCIds = {}
for i = DLC_ITERATION_BEGIN, DLC_ITERATION_END do
    lib.allowedDLCIds[i] = true
end


--Internal achievement example ids of the ESO DLCs and chapters (first achievementId found from each DLC category)
lib.dlcAndChapterAchievementIds = {
    --Base game
    [DLC_BASE_GAME] = -1,
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
    --Dragonhold
    [DLC_DRAGONHOLD] = 2534,
    --Harrowstorm
    [DLC_HARROWSTORM] = 2537,
    --Greymoor
    [DLC_GREYMOOR] = 2639,
}
if checkIfPTSAPIVersionIsLive() then
    --Greymoor
    lib.dlcAndChapterAchievementIds[DLC_STONETHORN] = 2692
end


--Internal achievement example ids of the ESO DLCs and chapters
local dlcAndChapterAchievementIds = lib.dlcAndChapterAchievementIds
--For each entry in the list of example achievements above get the name of it's parent category (DLC, chapter)
lib.DLCData = {}
local DLCandCHAPTERdata = lib.DLCData
lib.DLCData[DLC_BASE_GAME] = "Elder Scrolls Online"
for dlcId, dlcAchievementId in ipairs(dlcAndChapterAchievementIds) do
    if dlcId and dlcAchievementId and dlcAchievementId > 0 then
        DLCandCHAPTERdata[dlcId] = ZO_CachedStrFormat("<<C:1>>", GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(dlcAchievementId)))
    end
end