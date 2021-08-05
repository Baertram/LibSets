--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file contains the constant values needed for the library to work
LibSets = LibSets or {}
local lib = LibSets

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
}
--Enable DLCids that are not live yet e.g. only on PTS
if checkIfPTSAPIVersionIsLive() then
    ---DLC_+++
    --possibleDlcIds[xx] = "DLC_xxx"
    possibleDlcIds[#possibleDlcIds + 1] = "DLC_WAKING_FLAME"
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
--DLC Dungeons
[375] = "375|2|Ruins of Mazzatun",
[491] = "491|2|Cradle of Shadows",
[1165] = "1165|2|Bloodroot Forge",
[1331] = "1331|2|Fang Lair",
[1355] = "1355|2|Falkreath Hold",
[5008] = "5008|2|Moon Hunter Keep",
[5009] = "5009|2|March of Sacrifices",
[6040] = "6040|2|Moongrave Fane",
[6041] = "6041|2|Lair of Maarselok",
[4703] = "4703|2|Scalecaller Peak",
[5473] = "5473|2|Frostvault",
[5474] = "5474|2|Depths of Malatar",
[6647] = "6647|2|Unhallowed Grave",
[6646] = "6646|2|Icereach",
[7430] = "7430|2|Stone Garden",
[7431] = "7431|2|Castle Thorn",
[8216] = "8216|2|Black Drake Villa",
[8217] = "8217|2|The Cauldron",
[9375] = "9375|2|The Dread Cellar",
[9374] = "9374|2|Red Petal Bastion",
--DLCs (missing some)
[154] = "154|3|Imperial City",
[215] = "215|3|Orsinium",
[254] = "254|3|Thieves Guild",
[306] = "306|3|Dark Brotherhood",
[593] = "593|3|Morrowind",
[1240] = "1240|3|Clockwork City",
[5107] = "5107|3|Summerset",
[5755] = "5755|3|Murkmire",
[5843] = "5843|3|Elsweyr",
[6920] = "6920|3|Dragonhold",
[7466] = "7466|3|Greymoor",
[8388] = "8388|3|Markarth",
[8659] = "8659|1|Blackwood",
]]

--Internal achievement example ids of the ESO DLCs and chapters (first achievementId found from each DLC category)
lib.dlcAndChapterAchievementIds = {
    --Base game
    [DLC_BASE_GAME] = -1,
    --Imperial city
    [DLC_IMPERIAL_CITY] = 154,
    --Orsinium
    [DLC_ORSINIUM] = 215,
    --Thieves Guild
    [DLC_THIEVES_GUILD] = 254,
    --Dark Brotherhood
    [DLC_DARK_BROTHERHOOD] = 306,
    --Shadows of the Hist
    [DLC_SHADOWS_OF_THE_HIST] = 1520,
    --Morrowind
    [DLC_MORROWIND] = 593,
    --Horns of the Reach
    [DLC_HORNS_OF_THE_REACH] = 1940,
    --Clockwork City
    [DLC_CLOCKWORK_CITY] = 1240,
    --Dragon Bones
    [DLC_DRAGON_BONES] = 2104,
    --Summerset
    [DLC_SUMMERSET] = 5107,
    --Wolfhunter
    [DLC_WOLFHUNTER] = 2157,
    --Murkmire
    [DLC_MURKMIRE] = 5755,
    --Wrathstone
    [DLC_WRATHSTONE] = 2265,
    --Elsweyr
    [DLC_ELSWEYR] = 5843,
    --Scalebreaker
    [DLC_SCALEBREAKER] = 2413,
    --Dragonhold
    [DLC_DRAGONHOLD] = 6920,
    --Harrowstorm
    [DLC_HARROWSTORM] = 2537,
    --Greymoor
    [DLC_GREYMOOR] = 7466,
    --Stonethorn
    [DLC_STONETHORN] = 2692,
    --Markarth
    [DLC_MARKARTH] = 8388,
    --Flames of Ambition
    [DLC_FLAMES_OF_AMBITION] = 2829,
    --Blackwood
    [DLC_BLACKWOOD] = 8659,
}
if checkIfPTSAPIVersionIsLive() then
    --lib.dlcAndChapterAchievementIds[DLC_XXXX] = xxxx
    lib.dlcAndChapterAchievementIds[DLC_WAKING_FLAME] = 2439
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