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
    possibleDlcIds[#possibleDlcIds + 1] = "DLC_WAKING_FLAMES"

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
[5473] = "Frostgewölbe",
[5474] = "Tiefen von Malatar",
[5107] = "Summerset",
[8388] = "Markarth",
[5843] = "Elsweyr",
[7430] = "Der Steingarten",
[7431] = "Kastell Dorn",
[6920] = "Dragonhold",
[8216] = "Schwarzdrachenvilla",
[7466] = "Greymoor",
[1355] = "Falkenring",
[1240] = "Clockwork City",
[1165] = "Blutquellschmiede",
[593] = "Morrowind",
[491] = "Wiege der Schatten",
[5008] = "Die Mondjägerfeste",
[5009] = "Marsch der Aufopferung",
[306] = "Dark Brotherhood",
[8659] = "Blackwood",
[215] = "Orsinium",
[8217] = "Der Kessel",
[6646] = "Eiskap",
[375] = "Ruinen von Mazzatun",
[6040] = "Mondgrab-Tempelstadt",
[6041] = "Hort von Maarselok",
[154] = "Imperial City",
[5755] = "Murkmire",
[1331] = "Krallenhort",
[6647] = "Unheiliges Grab",
[254] = "Thieves Guild",
[4703] = "Gipfel der Schuppenruferin",
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