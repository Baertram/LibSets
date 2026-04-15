--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file contains the constant values needed for the library to work
local lib = LibSets


local strgmatch =   string.gmatch
local zogcn     =   GetCollectibleName
local zogaci    =   GetAchievementCategoryInfo
local zocstrfor =   ZO_CachedStrFormat
local gaci
local gci

--Helper function for the API check
local checkIfPTSAPIVersionIsLive = lib.checkIfPTSAPIVersionIsLive


--Other helper functions
--- Captures all returns from GetAchievementCategoryInfo.
---@param topLevelIndex number
---@return string name
local function GetAchievementCategoryInfoName(topLevelIndex)
    return zogaci(topLevelIndex)
end
gaci = GetAchievementCategoryInfoName

--- Captures all returns from GetCollectibleInfo.
---@param collectibleId number
---@return string name
local function GetCollectibleInfoName(collectibleId)
    --name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint
    return zogcn(collectibleId)
end
gci = GetCollectibleInfoName


--DLC & chapter type constants
DLC_TYPE_BASE_GAME = 0
local DLC_TYPE_BASE_GAME = DLC_TYPE_BASE_GAME
local possibleDlcTypes = {
    [1] = "DLC_TYPE_CHAPTER",
    [2] = "DLC_TYPE_DUNGEONS",
    [3] = "DLC_TYPE_ZONE",
    [4] = "DLC_TYPE_NORMAL_PATCH",
    [5] = "DLC_TYPE_SEASON_PART",
}
lib.possibleDlcTypes = possibleDlcTypes
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
    ---DLC_TYPE_+++
    --possibleDlcTypes[#possibleDlcTypes + 1] = "DLC_TYPE_xxx"
end
--Loop over the possible DLC types and create them in the global table _G
for dlcTypeId, dlcTypeName in ipairs(possibleDlcTypes) do
    _G[dlcTypeName] = dlcTypeId
end
local maxDlcTypes = #possibleDlcTypes
local DLC_TYPE_CHAPTER = DLC_TYPE_CHAPTER
local DLC_TYPE_DUNGEONS = DLC_TYPE_DUNGEONS
local DLC_TYPE_ZONE = DLC_TYPE_ZONE
local DLC_TYPE_NORMAL_PATCH = DLC_TYPE_NORMAL_PATCH
local DLC_TYPE_SEASON_PART = DLC_TYPE_SEASON_PART


--Iterators for the ESO dlc and chapter constants
local DLC_TYPE_ITERATION_BEGIN = DLC_TYPE_BASE_GAME
local DLC_TYPE_ITERATION_END   = _G[possibleDlcTypes[maxDlcTypes]]
DLC_TYPE_ITERATION_BEGIN = DLC_TYPE_ITERATION_BEGIN
DLC_TYPE_ITERATION_END = DLC_TYPE_ITERATION_END
lib.allowedDLCTypes = {}
for i = DLC_TYPE_ITERATION_BEGIN, DLC_TYPE_ITERATION_END do
    lib.allowedDLCTypes[i] = true
end

--DLC & Chapter ID constants (for LibSets)
DLC_BASE_GAME = 0
local DLC_BASE_GAME = DLC_BASE_GAME
local possibleDlcIds = {
    [1]  = "DLC_IMPERIAL_CITY",
    [2]  = "DLC_ORSINIUM",
    [3]  = "DLC_THIEVES_GUILD",
    [4]  = "DLC_DARK_BROTHERHOOD",
    [5]  = "DLC_SHADOWS_OF_THE_HIST",
    [6]  = "DLC_MORROWIND",
    [7]  = "DLC_HORNS_OF_THE_REACH",
    [8]  = "DLC_CLOCKWORK_CITY",
    [9]  = "DLC_DRAGON_BONES",
    [10] = "DLC_SUMMERSET",
    [11] = "DLC_WOLFHUNTER",
    [12] = "DLC_MURKMIRE",
    [13] = "DLC_WRATHSTONE",
    [14] = "DLC_ELSWEYR",
    [15] = "DLC_SCALEBREAKER",
    [16] = "DLC_DRAGONHOLD",
    [17] = "DLC_HARROWSTORM",
    [18] = "DLC_GREYMOOR",
    [19] = "DLC_STONETHORN",
    [20] = "DLC_MARKARTH",
    [21] = "DLC_FLAMES_OF_AMBITION",
    [22] = "DLC_BLACKWOOD",
    [23] = "DLC_WAKING_FLAME",
    [24] = "DLC_DEADLANDS",
    [25] = "DLC_ASCENDING_TIDE",
    [26] = "DLC_HIGH_ISLE",
    [27] = "DLC_LOST_DEPTHS",
    [28] = "DLC_FIRESONG",
    [29] = "DLC_SCRIBES_OF_FATE",
    [30] = "DLC_NECROM",
    [31] = "NO_DLC_UPDATE39",
    [32] = "NO_DLC_SECRET_OF_THE_TELVANNI",
    [33] = "DLC_SCIONS_OF_ITHELIA",
    [34] = "DLC_GOLD_ROAD",
    [35] = "NO_DLC_UPDATE43",
    [36] = "NO_DLC_UPDATE44",
    [37] = "DLC_FALLEN_BANNERS",
    [38] = "DLC_SEASONS_OF_THE_WORMCULT1",
    [39] = "DLC_FEAST_OF_SHADOWS",
    [40] = "DLC_SEASONS_OF_THE_WORMCULT2",
    [41] = "DLC_SEASON0",
    [42] = "DLC_SEASON0_PART2",
}
lib.possibleDlcIds = possibleDlcIds
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
    ---DLC_+++
    --possibleDlcIds[#possibleDlcIds + 1] = "DLC_***"
end
--Loop over the possible DLC ids and create them in the global table _G
for dlcId, dlcName in ipairs(possibleDlcIds) do
    _G[dlcName] = dlcId
end
local maxDlcId = #possibleDlcIds
--Iterators for the ESO dlc and chapter constants
DLC_ITERATION_BEGIN = DLC_BASE_GAME
local DLC_ITERATION_BEGIN = DLC_ITERATION_BEGIN
DLC_ITERATION_END   = _G[possibleDlcIds[maxDlcId]]
local DLC_ITERATION_END = DLC_ITERATION_END
lib.allowedDLCIds = {}
for i = DLC_ITERATION_BEGIN, DLC_ITERATION_END do
    lib.allowedDLCIds[i] = true
end

--To get the collectibleIds of the DLC names from list at ZO_DLCBook_Keyboard -> DLC_BOOK_KEYBOARD.categoryLayoutObject.categorizedLists.categorizedLists[2].collectibles
--[[

]]

--Internal collectible example ids of the ESO DLCs and chapters (first collectible found from each DLC category)
-->https://eso-hub.com/en/dlc / https://en.uesp.net/wiki/Online:Chapters /
lib.dlcAndChapterCollectibleIds = {
    --Base game
    [DLC_BASE_GAME] =               {collectibleId=-1, achievementCategoryId=-1, type=DLC_TYPE_BASE_GAME, releaseDate=1396569600}, --text ok 260331
    --Imperial city
    [DLC_IMPERIAL_CITY] =           {collectibleId=154, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1440979200}, --text ok 260331
    --Orsinium
    [DLC_ORSINIUM] =                {collectibleId=215, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1446422400}, --text ok 260331
    --Thieves Guild
    [DLC_THIEVES_GUILD] =           {collectibleId=254, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1457308800}, --text ok 260331
    --Dark Brotherhood
    [DLC_DARK_BROTHERHOOD] =        {collectibleId=306, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1464652800}, --text ok 260331
    --Shadows of the Hist
    [DLC_SHADOWS_OF_THE_HIST] =     {collectibleId=nil, achievementCategoryId=43, type=DLC_TYPE_DUNGEONS, releaseDate=1470009600}, --text ok 260331
    --Morrowind
    [DLC_MORROWIND] =               {collectibleId=593, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1496620800},  --text ok 260331
    --Horns of the Reach
    [DLC_HORNS_OF_THE_REACH] =      {collectibleId=nil, achievementCategoryId=42, type=DLC_TYPE_DUNGEONS, releaseDate=1502668800}, --text ok 260331
    --Clockwork City
    [DLC_CLOCKWORK_CITY] =          {collectibleId=1240, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1508716800}, --text ok 260331
    --Dragon Bones
    [DLC_DRAGON_BONES] =            {collectibleId=nil, achievementCategoryId=40, type=DLC_TYPE_DUNGEONS, releaseDate=1518393600},  --text ok 260331
    --Summerset
    [DLC_SUMMERSET] =               {collectibleId=5107, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1528156800}, --text ok 260331
    --Wolfhunter
    [DLC_WOLFHUNTER] =              {collectibleId=nil, achievementCategoryId=39, type=DLC_TYPE_DUNGEONS, releaseDate=1534118400}, --text ok 260331
    --Murkmire
    [DLC_MURKMIRE] =                {collectibleId=5755, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1540166400}, --text ok 260331
    --Wrathstone
    [DLC_WRATHSTONE] =              {collectibleId=nil, achievementCategoryId=37, type=DLC_TYPE_DUNGEONS, releaseDate=1551052800}, --text ok 260331
    --Elsweyr
    [DLC_ELSWEYR] =                 {collectibleId=5843, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1558310400}, --text ok 260331
    --Scalebreaker
    [DLC_SCALEBREAKER] =            {collectibleId=nil, achievementCategoryId=36, type=DLC_TYPE_DUNGEONS, releaseDate=1565568000}, --text ok 260331
    --Dragonhold
    [DLC_DRAGONHOLD] =              {collectibleId=6920, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1571616000},  --text ok 260331
    --Harrowstorm
    [DLC_HARROWSTORM] =             {collectibleId=nil, achievementCategoryId=34, type=DLC_TYPE_DUNGEONS, releaseDate=1582502400}, --text ok 260331
    --Greymoor
    [DLC_GREYMOOR] =                {collectibleId=7466, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1590451200}, --text ok 260331
    --Stonethorn
    [DLC_STONETHORN] =              {collectibleId=nil, achievementCategoryId=33, type=DLC_TYPE_DUNGEONS, releaseDate=1598227200}, --text ok 260331
    --Markarth
    [DLC_MARKARTH] =                {collectibleId=8388, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1604275200}, --text ok 260331
    --Flames of Ambition
    [DLC_FLAMES_OF_AMBITION] =      {collectibleId=nil, achievementCategoryId=31, type=DLC_TYPE_DUNGEONS, releaseDate=1615161600}, --text ok 260331
    --Blackwood
    [DLC_BLACKWOOD] =               {collectibleId=8659, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1622505600}, --text ok 260331
    --Waking Flames
    [DLC_WAKING_FLAME] =            {collectibleId=nil, achievementCategoryId=30, type=DLC_TYPE_DUNGEONS, releaseDate=1635724800}, --text ok 260331
    --Deadlands
    [DLC_DEADLANDS] =               {collectibleId=9365, achievementCategoryId=nil, type=DLC_TYPE_ZONE, releaseDate=1635724800}, --text ok 260331
    --Ascending Tide
    [DLC_ASCENDING_TIDE] =          {collectibleId=nil, achievementCategoryId=28, type=DLC_TYPE_DUNGEONS, releaseDate=1647216000}, --text ok 260331
    --High Isle
    [DLC_HIGH_ISLE] =               {collectibleId=10053, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1654473600},  --text ok 260331
    --Lost Depths
    [DLC_LOST_DEPTHS] =             {collectibleId=nil, achievementCategoryId=27, type=DLC_TYPE_DUNGEONS, releaseDate=1661126400}, --text ok 260331
    --Firesong
    [DLC_FIRESONG] =                {collectibleId=10660, achievementCategoryId=nil, type=DLC_TYPE_DUNGEONS, releaseDate=1667260800}, --text ok 260331
    --Scribes of Fate
    [DLC_SCRIBES_OF_FATE] =         {collectibleId=nil, achievementCategoryId=25, type=DLC_TYPE_DUNGEONS, releaseDate=1678662000}, --text ok 260331
    --Necrom
    [DLC_NECROM] =                  {collectibleId=10475, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1685916000},  --text ok 260331
    --Update 39 QOL patch
    [NO_DLC_UPDATE39] =             {name="Update 39", type=DLC_TYPE_NORMAL_PATCH, releaseDate=1692604800}, --August 21st 2023 --text ok 260331
    --Update 40
    [NO_DLC_SECRET_OF_THE_TELVANNI] = {name="Update 40: Secret of the Telvanni", achievementCategoryId=nil, type=DLC_TYPE_NORMAL_PATCH, releaseDate=1698663600}, --Ocotber 30th 2023 --text ok 260331
    --Update 41
    [DLC_SCIONS_OF_ITHELIA] =       {collectibleId=nil, achievementCategoryId=24, type=DLC_TYPE_DUNGEONS, releaseDate=1709294400}, --March 11th 2024  --text ok 260331
    --Update 42
    [DLC_GOLD_ROAD] =               {collectibleId=11871, achievementCategoryId=nil, type=DLC_TYPE_CHAPTER, releaseDate=1717365600}, --June 3rd 2024 --text ok 260331
    --Update 43 House tours and QOL patch
    [NO_DLC_UPDATE43] =             {name="Update 43", type=DLC_TYPE_NORMAL_PATCH, releaseDate=1724068800}, --August 19th 2024 --text ok 260331
    --Update 44 new Battleground types and QOL patch
    [NO_DLC_UPDATE44] =             {name="Update 44", type=DLC_TYPE_NORMAL_PATCH, releaseDate=1730116800}, --October 28th 2024 --text ok 260331
    --Fallen Banners
    [DLC_FALLEN_BANNERS] =          {collectibleId=nil, achievementCategoryId=23, type=DLC_TYPE_DUNGEONS, releaseDate=1741608000}, --March 10th 2025 --text ok 260331
    --Seasons of the Wormcult Part1
    [DLC_SEASONS_OF_THE_WORMCULT1] = {collectibleId=nil, achievementCategoryId=13, type=DLC_TYPE_SEASON_PART, releaseDate=1748865600}, --June 2nd 2025 --text ok 260331
    --Feast of Shadows
    [DLC_FEAST_OF_SHADOWS] =        {collectibleId=nil, achievementCategoryId=22, type=DLC_TYPE_DUNGEONS, releaseDate=1755511200}, -- August 18th 2025  --text ok 260331
    --Seasons of the Wormcult Part2
    [DLC_SEASONS_OF_THE_WORMCULT2] = {collectibleId=nil, achievementCategoryId=13, type=DLC_TYPE_SEASON_PART, releaseDate=1760702400}, --October 17th 2025  --text ok 260331
    --Season 0
    [DLC_SEASON0]                  = {name="Season 0", type=DLC_TYPE_SEASON_PART, releaseDate=1773057600}, -- March 9th 2026
    --Season 0 Part 2
    [DLC_SEASON0_PART2]            = {name="Season 0, Part 2", type=DLC_TYPE_SEASON_PART, releaseDate=1780898400}, -- June 8th 2026
}
if checkIfPTSAPIVersionIsLive() then
    --lib.dlcAndChapterCollectibleIds[DLC_<name_here>] = {collectibleId=<nilable:number>, achievementCategoryId=<nilable:number>, type=DLC_TYPE_xxx, releaseDate=<timeStampOfReleaseDate>}
end

local function cleanDLCTimeStamp(releaseDateTimestamp, withoutColon)
    local releaseDateStr, onlyDateWithoutTimeStr
    if releaseDateTimestamp ~= nil and type(releaseDateTimestamp) == "number" and releaseDateTimestamp >= 0 and releaseDateTimestamp <= 2147483647 then
        releaseDateStr = os.date("%c", releaseDateTimestamp)
        --Strip the hours, minutes, seconds at the space
        if string.find(releaseDateStr, " ", 1, true) ~= nil then
            for param in strgmatch(releaseDateStr, "([^%s]+)%s*") do
                if param ~= nil and param ~= "" then
                    onlyDateWithoutTimeStr =  param
                    break
                end
            end
        else
            onlyDateWithoutTimeStr = releaseDateStr
        end
    end

    if releaseDateStr == nil then releaseDateStr = "" end
    if onlyDateWithoutTimeStr == nil then
        onlyDateWithoutTimeStr = ""
    end
    if not withoutColon and onlyDateWithoutTimeStr ~= "" then
        onlyDateWithoutTimeStr = onlyDateWithoutTimeStr .. ": "
    end
    return releaseDateStr, onlyDateWithoutTimeStr
end
lib.CleanDLCTimeStamp = cleanDLCTimeStamp

--Internal achievement example ids of the ESO DLCs and chapters
local dlcAndChapterCollectibleIds = lib.dlcAndChapterCollectibleIds
--For each entry in the list of example achievements above get the name of it's parent category (DLC, chapter)
lib.DLCAndCHAPTERData = {}
lib.DLCAndCHAPTERDataOrdered = {}
lib.DLCandCHAPTERLookupdata = {}
lib.NONDLCData = {}
lib.NONDLCLookupdata = {}
local DLCandCHAPTERdata =   lib.DLCAndCHAPTERData
local DLCAndCHAPTERDataOrdered = lib.DLCAndCHAPTERDataOrdered
local DLCandCHAPTERLookupdata = lib.DLCandCHAPTERLookupdata
local NONDLCData = lib.NONDLCData
local NONDLCLookupdata = lib.NONDLCLookupdata
DLCandCHAPTERdata[DLC_BASE_GAME] = "Elder Scrolls Online"
DLCandCHAPTERLookupdata[DLC_TYPE_BASE_GAME] = {
    [DLC_BASE_GAME] = DLCandCHAPTERdata[DLC_BASE_GAME]
}
DLCAndCHAPTERDataOrdered[1] = DLC_BASE_GAME

--CHAPTERdata[DLC_BASE_GAME] = "Elder Scrolls Online"
local dlcStrFormatPattern = "<<C:1>>"
for dlcId, dlcAndChapterData in ipairs(dlcAndChapterCollectibleIds) do
    local collectibleId = dlcAndChapterData.collectibleId
    local achievementCategoryId = dlcAndChapterData.achievementCategoryId
    local dlcType = dlcAndChapterData.type
    if dlcType ~= nil then
        --DLC type = NOT PATCH
        if dlcType ~= DLC_TYPE_NORMAL_PATCH then
            local name
            if collectibleId ~= nil and collectibleId ~= -1 then
                name = zocstrfor(dlcStrFormatPattern, gci(collectibleId))
            elseif achievementCategoryId ~= nil and achievementCategoryId ~= -1 then
                name = zocstrfor(dlcStrFormatPattern, gaci(achievementCategoryId))
            end
            if name == nil then
                name = dlcAndChapterData.name
                if name == nil then
                    --use the timestamp as name
                    if dlcAndChapterData.releaseDate ~= nil then
                        local nameWithoutTime
                        name, nameWithoutTime = cleanDLCTimeStamp(dlcAndChapterData.releaseDate, true)
                        name = nameWithoutTime
                    else
                        name = "n/a"
                    end
                end
            end
            if name ~= nil then
                DLCandCHAPTERLookupdata[dlcType] = DLCandCHAPTERLookupdata[dlcType] or {}
                DLCandCHAPTERdata[dlcId] = name
                DLCandCHAPTERLookupdata[dlcType][dlcId] = name
                DLCAndCHAPTERDataOrdered[#DLCAndCHAPTERDataOrdered + 1] = dlcId
            end
        else    --DLC type = PATCH
            NONDLCLookupdata[dlcType] = NONDLCLookupdata[dlcType] or {}
            local name = dlcAndChapterData.name or "n/a"
            NONDLCLookupdata[dlcType][dlcId] = name
            NONDLCData[dlcId] = name
        end
    end
end


--Class specific data
local classData = {
    index2Id = {},
    id2Index = {},
    names = {},
    icons = {},
    colors = {},
    --
    setsList = {}, --Will be dynamically filled upon need, by API function lib.GetClassSets(classId)
}
for i = 1, GetNumClasses(), 1 do
    local classId = GetClassInfo(i)
    if classId ~= nil then
        local classIndex = GetClassIndexById(classId)
        classData.index2Id[classIndex] = classId
        classData.id2Index[classId] = classIndex
        classData.names[classId] = zo_strformat(SI_CLASS_NAME, GetClassName(GENDER_MALE, classId))
        classData.icons[classId] = ZO_GetClassIcon(classId)
        classData.colors[classId] = GetClassColor(classId)
    end
end
lib.classData = classData
