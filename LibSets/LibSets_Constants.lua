--This file contains the constant values needed for the library to work
LibSets = {}
local lib = LibSets
------------------------------------------------------------------------------------------------------------------------
--The setsData
lib.setsData    = {
    ["languagesScanned"] = {},
}
------------------------------------------------------------------------------------------------------------------------
--The supported languages of this library
lib.supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["jp"]  = true,
    ["ru"]  = true,
}
------------------------------------------------------------------------------------------------------------------------
--Allowed itemTypes for the set parts
lib.checkItemTypes = {
    [ITEMTYPE_WEAPON] = true,
    [ITEMTYPE_ARMOR]  = true,
}
------------------------------------------------------------------------------------------------------------------------
--Number of currently available set bonus for a monster set piece (2: head, shoulder)
lib.countMonsterSetBonus = 2
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
}
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
------------------------------------------------------------------------------------------------------------------------
--The undaunted chests
local undauntedChestIds = {
    [1] = "Gilirion the Redbeard",
    [2] = "Maj al-Ragath",
    [3] = "Urgalarg Chief-bane",
}
lib.undauntedChestIds = undauntedChestIds
------------------------------------------------------------------------------------------------------------------------
