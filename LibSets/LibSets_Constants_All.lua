--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file contains the constant values needed for the library to work
local lib = LibSets

local gaci =        GetAchievementCategoryInfo
local gcifa =       GetCategoryInfoFromAchievementId
local gci =         GetCollectibleInfo
local zocstrfor =   ZO_CachedStrFormat

--Helper function for the API check
local checkIfPTSAPIVersionIsLive = lib.checkIfPTSAPIVersionIsLive

--DLC & Chapter ID constants (for LibSets)
DLC_BASE_GAME = 0
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
}
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
    ---DLC_+++
    --possibleDlcIds[#possibleDlcIds + 1] = "DLC_xxx"
    possibleDlcIds[#possibleDlcIds + 1] = "DLC_FIRESONG"
end
--Loop over the possible DLC ids and create them in the global table _G
for dlcId, dlcName in ipairs(possibleDlcIds) do
    _G[dlcName] = dlcId
end
local maxDlcId = #possibleDlcIds
--Iterators for the ESO dlc and chapter constants
DLC_ITERATION_BEGIN = DLC_BASE_GAME
DLC_ITERATION_END   = _G[possibleDlcIds[maxDlcId]]
lib.allowedDLCIds = {}
for i = DLC_ITERATION_BEGIN, DLC_ITERATION_END do
    lib.allowedDLCIds[i] = true
end

--[[
--Collectible IDs
["en"] =
    [8388] = "8388|DLC|Markarth",
    [10053] = "10053|CHAPTER|High Isle",
    [7430] = "7430|DLC|Stone Garden",
    [7431] = "7431|DLC|Castle Thorn",
    [6920] = "6920|DLC|Dragonhold",
    [1355] = "1355|DLC|Falkreath Hold",
    [1165] = "1165|DLC|Bloodroot Forge",
    [5008] = "5008|DLC|Moon Hunter Keep",
    [5009] = "5009|DLC|March of Sacrifices",
    [8659] = "8659|DLC|Blackwood",
    [9365] = "9365|DLC|The Deadlands",
    [215] = "215|DLC|Orsinium",
    [1240] = "1240|DLC|Clockwork City",
    [6041] = "6041|DLC|Lair of Maarselok",
    [154] = "154|DLC|Imperial City",
    [9374] = "9374|DLC|Red Petal Bastion",
    [4703] = "4703|DLC|Scalecaller Peak",
    [10400] = "10400|DLC|Earthen Root Enclave",
    [5473] = "5473|DLC|Frostvault",
    [5474] = "5474|DLC|Depths of Malatar",
    [10660] = "10660|DLC|Firesong",
    [7466] = "7466|DLC|Greymoor",
    [491] = "491|DLC|Cradle of Shadows",
    [6040] = "6040|DLC|Moongrave Fane",
    [10401] = "10401|DLC|Graven Deep",
    [593] = "593|DLC|Morrowind",
    [9651] = "9651|DLC|Coral Aerie",
    [306] = "306|DLC|Dark Brotherhood",
    [5107] = "5107|DLC|Summerset",
    [9652] = "9652|DLC|Shipwright's Regret",
    [5843] = "5843|DLC|Elsweyr",
    [6646] = "6646|DLC|Icereach",
    [375] = "375|DLC|Ruins of Mazzatun",
    [6647] = "6647|DLC|Unhallowed Grave",
    [8216] = "8216|DLC|Black Drake Villa",
    [8217] = "8217|DLC|The Cauldron",
    [5755] = "5755|DLC|Murkmire",
    [1331] = "1331|DLC|Fang Lair",
    [9375] = "9375|DLC|The Dread Cellar",
    [254] = "254|DLC|Thieves Guild",
    [10475] = "10475|CHAPTER|U38",
]]

--Internal collectible example ids of the ESO DLCs and chapters (first collectible found from each DLC category)
lib.dlcAndChapterCollectibleIds = {
    --Base game
    [DLC_BASE_GAME] = -1,               --OK
    --Imperial city
    [DLC_IMPERIAL_CITY] = 154,          --OK
    --Orsinium
    [DLC_ORSINIUM] = 215,               --OK
    --Thieves Guild
    [DLC_THIEVES_GUILD] = 254,          --OK
    --Dark Brotherhood
    [DLC_DARK_BROTHERHOOD] = 306,       --OK
    --Shadows of the Hist
    [DLC_SHADOWS_OF_THE_HIST] = "1796",   --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Morrowind
    [DLC_MORROWIND] = 593,              --OK
    --Horns of the Reach
    [DLC_HORNS_OF_THE_REACH] = "2098",    --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Clockwork City
    [DLC_CLOCKWORK_CITY] = 1240,        --OK
    --Dragon Bones
    [DLC_DRAGON_BONES] = "2190",          --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Summerset
    [DLC_SUMMERSET] = 5107,             --OK
    --Wolfhunter
    [DLC_WOLFHUNTER] = "2311",            --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Murkmire
    [DLC_MURKMIRE] = 5755,              --OK
    --Wrathstone
    [DLC_WRATHSTONE] = "2265",            --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Elsweyr
    [DLC_ELSWEYR] = 5843,               --OK
    --Scalebreaker
    [DLC_SCALEBREAKER] = "2584",          --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Dragonhold
    [DLC_DRAGONHOLD] = 6920,            --OK
    --Harrowstorm
    [DLC_HARROWSTORM] = "2683",           --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Greymoor
    [DLC_GREYMOOR] = 7466,              --OK
    --Stonethorn
    [DLC_STONETHORN] = "2827",            --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Markarth
    [DLC_MARKARTH] = 8388,              --OK
    --Flames of Ambition
    [DLC_FLAMES_OF_AMBITION] = "2984",    --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Blackwood
    [DLC_BLACKWOOD] = 8659,             --OK
    --Waking Flames
    [DLC_WAKING_FLAME] = "3093",          --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --Deadlands
    [DLC_DEADLANDS] = 9365,             --OK
    --Ascending Tide
    [DLC_ASCENDING_TIDE] = "3102",        --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
    --High Isle
    [DLC_HIGH_ISLE] = 10053,            --OK
    [DLC_LOST_DEPTHS] = "3133",          --not given by LibSets.DebugGetAllCollectibleDLCNames -> Only dungeon names...
}
if checkIfPTSAPIVersionIsLive() then
    --lib.dlcAndChapterCollectibleIds[DLC_<name_here>] = <id of achievement>
    lib.dlcAndChapterCollectibleIds[DLC_FIRESONG] = 10660 --OK
end

--Internal achievement example ids of the ESO DLCs and chapters
local dlcAndChapterCollectibleIds = lib.dlcAndChapterCollectibleIds
--For each entry in the list of example achievements above get the name of it's parent category (DLC, chapter)
lib.DLCData = {}
local DLCandCHAPTERdata = lib.DLCData
lib.DLCData[DLC_BASE_GAME] = "Elder Scrolls Online"
local dlcStrFormatPattern = "<<C:1>>"
for dlcId, dlcAndChapterCollectibleOrAchievementId in ipairs(dlcAndChapterCollectibleIds) do
    if dlcId and dlcAndChapterCollectibleOrAchievementId then
        if type(dlcAndChapterCollectibleOrAchievementId) == "number" then
            DLCandCHAPTERdata[dlcId] = zocstrfor(dlcStrFormatPattern, gci(dlcAndChapterCollectibleOrAchievementId))
        else
            DLCandCHAPTERdata[dlcId] = zocstrfor(dlcStrFormatPattern, gaci(gcifa(dlcAndChapterCollectibleOrAchievementId)))
        end
    end
end

