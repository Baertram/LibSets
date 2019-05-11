--[========================================================================[
    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>
--]========================================================================]
local MAJOR, MINOR = "LibSets", 0.05
LibSets = LibSets or {}
local lib = LibSets

lib.name        = MAJOR
lib.version     = MINOR
--SavedVariables info
lib.svDataName  = "LibSets_SV_Data"
lib.svVersion   = 0.5
lib.setsData    = {
    ["languagesScanned"] = {},
}
lib.setsLoaded  = false
lib.setsScanning = false

--The supported languages of this library
lib.supportedLanguages = {
    ["de"]  = true,
    ["en"]  = true,
    ["fr"]  = true,
    ["jp"]  = true,
    ["ru"]  = true,
}

------------------------------------------------------------------------
-- 	Local variables, global for the library
------------------------------------------------------------------------
--All sets data
local sets = {}
local setIds = {}
local setsFound = 0
local setsUpdated = 0
local itemsScanned = 0

--Allowed itemTypes for the set parts
local checkItemTypes = {
    [ITEMTYPE_WEAPON] = true,
    [ITEMTYPE_ARMOR]  = true,
}

--Current monster set bonus count (maximum, e.g. 2 items needed for full set bonus )
local countMonsterSetBonus = 2
local monsterSetsCount  = 0
local dungeonSetsCount  = 0
local overlandSetsCount = 0
--The other setIds (non-crafted)
local monsterSets       = {}
local dungeonSets       = {}
local overlandSets      = {}

local dlc_suffix        = " " .. GetString(SI_COLLECTIBLECATEGORYTYPE1)
local chapter_suffix    = " " .. GetString(SI_COLLECTIBLECATEGORYTYPE22)

--Internal IDs of the ESO DLCs
local DLCandCHAPTERdata = {
    [1] = {
        ["name"] = GetCollectibleName(154),
        ["de"] = "Kein",
        ["en"] = "Imperial city" .. dlc_suffix,
        ["fr"] = "None",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [2] = {
        ["name"] = GetCollectibleName(215),
        ["de"] = "Kein",
        ["en"] = "Orsinium" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [3] = {
        ["name"] = GetCollectibleName(254),
        ["de"] = "Kein",
        ["en"] = "Thieves Guild" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [4] = {
        ["name"] = GetCollectibleName(306),
        ["de"] = "Kein",
        ["en"] = "Dark Brotherhood" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [5] = {
        ["name"] = "",
        ["de"] = "Kein",
        ["en"] = "Shadows of the Hist" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [6] = {
        ["name"] = GetCollectibleName(593),
        ["de"] = "Kein",
        ["en"] = "Morrowind"  .. chapter_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [7] = {
        ["name"] = "",
        ["de"] = "Kein",
        ["en"] = "Horns of the Reach" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [8] = {
        ["name"] = GetCollectibleName(1240),
        ["de"] = "Kein",
        ["en"] = "Clockwork City" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [9] = {
        ["name"] = "", --No collectible present as only dungeons were added. Achievement name?
        ["de"] = "Kein",
        ["en"] = "Dragon Bones" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [10] = {
        ["name"] = GetCollectibleName(5107),
        ["de"] = "Kein",
        ["en"] = "Summerset"  .. chapter_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [11] = {
        ["name"] = "", --No collectible present as only dungeons were added. Achievement name?
        ["de"] = "Kein",
        ["en"] = "Wolfhunter" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [12] = {
        ["name"] = GetCollectibleName(5755),
        ["de"] = "Kein",
        ["en"] = "Murkmire" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [13] = {
        ["name"] = "", --No collectible present as only dungeons were added. Achievement name?
        ["de"] = "Kein",
        ["en"] = "Wrathstone" .. dlc_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
    [14] = {
        ["name"] = GetCollectibleName(5843),
        ["de"] = "Kein",
        ["en"] = "Elsweyr"  .. chapter_suffix,
        ["fr"] = "NOne",
        ["ru"] = "None",
        ["jp"] = "None",
    },
}

--The craftable set setIds
local craftedSets = {
    [37] = true,        -- Death's Wind / Todeswind
    [38] = true,        -- Twilight's Embrace / Zwielichtkuss
    [40] = true,        -- Night's Silence / Stille der Nacht
    [41] = true,        -- Whitestrake's Retribution / Weißplankes Vergeltung
    [43] = true,        -- Armor of the Seducer / Rüstung der Verführung
    [44] = true,        -- Vampire's Kiss / Kuss des Vampirs
    [48] = true,        -- Magnu's Gift / Magnus' Gabe
    [51] = true,        -- Night Mother's Gaze / Blick der Mutter der Nacht
    [54] = true,        -- Ashen Grip / Aschengriff
    [73] = true,        -- Oblivion's Foe / Erinnerung
    [74] = true,        -- Spectre's Eye / Schemenauge
    [75] = true,        -- Torug's Pact / Torugs Pakt
    [78] = true,        -- Hist Bark / Histrinde
    [79] = true,        -- Willow's Path / Weidenpfad
    [80] = true,        -- Hunding's Rage / Hundings Zorn
    [81] = true,        -- Song of Lamae / Lied der Lamien
    [82] = true,        -- Alessia's Bulwark / Alessias Bollwerk
    [84] = true,        -- Orgnum's Scales / Orgnums Schuppen
    [87] = true,        -- Eyes of Mara / Augen von Mara
    [92] = true,        -- Kagrenac's Hope / Kagrenacs Hoffnung
    [95] = true,        -- Shalidor's Curse / Shalidors Fluch
    [148] = true,        -- Way of the Arena / Weg der Arnea
    [161] = true,        -- Twice Born Star / Doppelstern
    [176] = true,        -- Noble's Conquest / Adelssieg
    [177] = true,        -- Redistributor / Umverteilung
    [178] = true,        -- Armor Master / Rüstungsmeister
    [207] = true,        -- LAw of Julianos / Gesetz von Julianos
    [208] = true,        -- Trial by Fire / Feuertaufe
    [219] = true,        -- Morkuldin / Morkuldin
    [224] = true,        -- Tava's Favor / Tavas Gunst
    [225] = true,        -- Clever Alchemist / Schlauer Alchemist
    [226] = true,        -- Eternal Hunt / Ewige Jagd
    [240] = true,        -- Kvatch Gladiator / Gladiator von Kvatch
    [241] = true,        -- Varen's Legacy / Varens Erbe
    [242] = true,        -- Pelinal's Aptitude / Pelinals Talent
    [323] = true,        -- Assassin's Guile / Assassinenlist
    [324] = true,        -- Daedric Trickery / Daedrische Gaunerei
    [325] = true,        -- Shacklebreaker / Kettensprenger
    [351] = true,        -- Innate Axiom / Kernaxiom
    [352] = true,        -- Fortified Brass / Messingpanzer
    [353] = true,        -- Mechanical Acuity / Mechanikblick
    [385] = true,        -- Adept Rider / Versierter Reiter
    [386] = true,        -- Sload's Semblance / Kreckenantlitz
    [387] = true,        -- Nocturnal's Favor / Nocturnals Gunst
    [408] = true,        -- Grave Stake Collector / Grabpflocksammler
    [409] = true,        -- Naga Shaman / Nagaschamane
    [410] = true,        -- Might of the Lost Legion / Macht der verlorenen Legion
}

--Wayshrine nodes and number of traits needed for sets. All rights and work belongs to the addon "CraftStore" and "WritWorthy"!
--https://www.esoui.com/downloads/info1590-CraftStoreWrathstone.html
--https://www.esoui.com/downloads/info1605-WritWorthy.html
local setInfo = {
    --Crafted Sets (See names of setId (table key) above behind table entries of "craftedSets")
    --wayshrines:   table of wayshrine nodeIds to jump to. You'll be near the set's crafting station then. 1st table key=EP, 2nd table key=AD, 3rd table key= DC
    --> If a table entry is negative (e.g. -1 or -2) the jump won#t work as no wayshrine is knwon or it is a special one like the Mages's guild island Augvea
    --traitsNeeded: the number of traits you need to research to be able to craft this set
    --dlcId:        the dlcId from table DLCandCHAPTERdata (key) as the set was added
------------------------------------------------------------------------------------------------------------------------
--Content of crafted sets below:
------------------------------------------------------------------------------------------------------------------------
    [37] = {wayshrines={1,177,71},        traitsNeeded=2,        dlcId=0},        -- Death's Wind / Todeswind
    [38] = {wayshrines={15,169,205},        traitsNeeded=3,        dlcId=0},        -- Twilight's Embrace / Zwielichtkuss
    [40] = {wayshrines={216,121,65},        traitsNeeded=2,        dlcId=0},        -- Night's Silence / Stille der Nacht
    [41] = {wayshrines={82,151,78},        traitsNeeded=4,        dlcId=0},        -- Whitestrake's Retribution / Weißplankes Vergeltung
    [43] = {wayshrines={23,164,32},        traitsNeeded=3,        dlcId=0},        -- Armor of the Seducer / Rüstung der Verführung
    [44] = {wayshrines={58,101,93},        traitsNeeded=5,        dlcId=0},        -- Vampire's Kiss / Kuss des Vampirs
    [48] = {wayshrines={13,148,48},        traitsNeeded=4,        dlcId=0},        -- Magnu's Gift / Magnus' Gabe
    [51] = {wayshrines={34,156,118},        traitsNeeded=6,        dlcId=0},        -- Night Mother's Gaze / Blick der Mutter der Nacht
    [54] = {wayshrines={7,175,77},        traitsNeeded=2,        dlcId=0},        -- Ashen Grip / Aschengriff
    [73] = {wayshrines={135,135,135},        traitsNeeded=8,        dlcId=0},        -- Oblivion's Foe / Erinnerung
    [74] = {wayshrines={133,133,133},        traitsNeeded=8,        dlcId=0},        -- Spectre's Eye / Schemenauge
    [75] = {wayshrines={19,165,24},        traitsNeeded=3,        dlcId=0},        -- Torug's Pact / Torugs Pakt
    [78] = {wayshrines={9,154,51},        traitsNeeded=4,        dlcId=0},        -- Hist Bark / Histrinde
    [79] = {wayshrines={35,144,111},        traitsNeeded=6,        dlcId=0},        -- Willow's Path / Weidenpfad
    [80] = {wayshrines={39,161,113},        traitsNeeded=6,        dlcId=0},        -- Hunding's Rage / Hundings Zorn
    [81] = {wayshrines={137,103,89},        traitsNeeded=5,        dlcId=0},        -- Song of Lamae / Lied der Lamien
    [82] = {wayshrines={155,105,95},        traitsNeeded=5,        dlcId=0},        -- Alessia's Bulwark / Alessias Bollwerk
    [84] = {wayshrines={-2,-2,-2},        traitsNeeded=8,        dlcId=0},        -- Orgnum's Scales / Orgnums Schuppen
    [87] = {wayshrines={-1,-1,-1},        traitsNeeded=8,        dlcId=0},        -- Eyes of Mara / Augen von Mara
    [92] = {wayshrines={-2,-2,-2},        traitsNeeded=8,        dlcId=0},        -- Kagrenac's Hope / Kagrenacs Hoffnung
    [95] = {wayshrines={-1,-1,-1},        traitsNeeded=8,        dlcId=0},        -- Shalidor's Curse / Shalidors Fluch
    [148] = {wayshrines={217,217,217},        traitsNeeded=8,        dlcId=0},        -- Way of the Arena / Weg der Arnea
    [161] = {wayshrines={234,234,234},        traitsNeeded=9,        dlcId=0},        -- Twice Born Star / Doppelstern
    [176] = {wayshrines={199,201,203},        traitsNeeded=7,        dlcId=0},        -- Noble's Conquest / Adelssieg
    [177] = {wayshrines={199,201,203},        traitsNeeded=5,        dlcId=0},        -- Redistributor / Umverteilung
    [178] = {wayshrines={199,201,203},        traitsNeeded=9,        dlcId=0},        -- Armor Master / Rüstungsmeister
    [207] = {wayshrines={241,241,241},        traitsNeeded=6,        dlcId=0},        -- LAw of Julianos / Gesetz von Julianos
    [208] = {wayshrines={237,237,237},        traitsNeeded=3,        dlcId=0},        -- Trial by Fire / Feuertaufe
    [219] = {wayshrines={237,237,237},        traitsNeeded=9,        dlcId=0},        -- Morkuldin / Morkuldin
    [224] = {wayshrines={257,257,257},        traitsNeeded=5,        dlcId=0},        -- Tava's Favor / Tavas Gunst
    [225] = {wayshrines={257,257,257},        traitsNeeded=7,        dlcId=0},        -- Clever Alchemist / Schlauer Alchemist
    [226] = {wayshrines={255,255,255},        traitsNeeded=9,        dlcId=0},        -- Eternal Hunt / Ewige Jagd
    [240] = {wayshrines={254,254,254},        traitsNeeded=5,        dlcId=0},        -- Kvatch Gladiator / Gladiator von Kvatch
    [241] = {wayshrines={251,251,251},        traitsNeeded=7,        dlcId=0},        -- Varen's Legacy / Varens Erbe
    [242] = {wayshrines={254,254,254},        traitsNeeded=9,        dlcId=0},        -- Pelinal's Aptitude / Pelinals Talent
    [323] = {wayshrines={276,276,276},        traitsNeeded=3,        dlcId=0},        -- Assassin's Guile / Assassinenlist
    [324] = {wayshrines={329,329,329},        traitsNeeded=8,        dlcId=0},        -- Daedric Trickery / Daedrische Gaunerei
    [325] = {wayshrines={282,282,282},        traitsNeeded=6,        dlcId=0},        -- Shacklebreaker / Kettensprenger
    [351] = {wayshrines={339,339,339},        traitsNeeded=6,        dlcId=0},        -- Innate Axiom / Kernaxiom
    [352] = {wayshrines={337,337,337},        traitsNeeded=2,        dlcId=0},        -- Fortified Brass / Messingpanzer
    [353] = {wayshrines={338,338,338},        traitsNeeded=4,        dlcId=0},        -- Mechanical Acuity / Mechanikblick
    [385] = {wayshrines={359,359,359},        traitsNeeded=3,        dlcId=0},        -- Adept Rider / Versierter Reiter
    [386] = {wayshrines={360,360,360},        traitsNeeded=6,        dlcId=0},        -- Sload's Semblance / Kreckenantlitz
    [387] = {wayshrines={354,354,354},        traitsNeeded=9,        dlcId=0},        -- Nocturnal's Favor / Nocturnals Gunst
    [408] = {wayshrines={375,375,375},        traitsNeeded=0,        dlcId=0},        -- Grave Stake Collector / Grabpflocksammler
    [409] = {wayshrines={379,379,379},        traitsNeeded=0,        dlcId=0},        -- Naga Shaman / Nagaschamane
    [410] = {wayshrines={379,379,379},        traitsNeeded=0,        dlcId=0},        -- Might of the Lost Legion / Macht der verlorenen Legion


------------------------------------------------------------------------------------------------------------------------
--Content of monster sets below
------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------
--Content of overland sets below
------------------------------------------------------------------------------------------------------------------------
    --Other sets (Set names can be found inside SavedVariables file LibSets.lua, after scaning of the set names within your client language finished.
    --Search for "["sets"]" inside the SV file and you'll find the ["name"] in the scanned languages e.g. ["de"] or ["en"] and an example itemId of one
    --item of this set which you can use with LibSets.buildItemLink(itemId) to generate an example itemLink of the set item)
    --TODO
    [31]    = {wayshrines={65},              traitsNeeded=0,    dlcId=0},  --Sonnenseide (Stonefalls: Davons Watch, or 41 "Fort Arnad" near to a Worldboss)
}

--[[
    Monster sets

]]

local preloaded = {
    -- lookup this id for the current patch with the following script:
    -- /script local maxId=147664 for itemId=maxId,200000 do local itemType = GetItemLinkItemType('|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h') if itemType>0 then maxId=itemId end end d(maxId)
    ["maxItemIdScanned"] = 152154,
    ["lastSetsCheckAPIVersion"] = 100027,
    --[[ to generate the following list:
         * /reloadui with the latest patch version after scan is complete
         * copy the entire ["sets"] array from the LibSets.lua saved vars into a lua minifier
         * find/replace the following regex with an empty string in Notepad++
           ,?\["name"\]=\{[^}]+\},?
         * find/replace the following regex with \1 in Notepad++
           \{\["itemId"\]=([0-9]+)\}
      ]]--
    ["sets"] = {
        [19]=22200, [20]=10973, [21]=7664, [22]=2503, [23]=43761, [24]=43764, [25]=43767, [26]=15728, [27]=7661, [28]=15767, [29]=16228, [30]=10885, [31]=1530, 
        [32]=43788, [33]=10961, [34]=4289, [35]=29065, [36]=1373, [37]=43803, [38]=43807, [39]=43811, [40]=43815, [41]=43819, [43]=43827, [44]=43831, 
        [46]=22161, [47]=7514, [48]=43847, [49]=70, [50]=43855, [51]=43859, [52]=43863, [53]=33159, [54]=43871, [55]=10067, [56]=7668, [57]=1672, [58]=1088, 
        [59]=43895, [60]=7295, [61]=139, [62]=7440, [63]=43915, [64]=10878, [65]=471, [66]=7445, [67]=43935, [68]=10861, [69]=1662, [70]=15600, [71]=22182, 
        [72]=22162, [73]=43965, [74]=43971, [75]=43977, [76]=43983, [77]=33155, [78]=43995, [79]=44001, [80]=44007, [81]=44013, [82]=44019, [83]=44025, 
        [84]=44031, [85]=44037, [86]=7598, [87]=44049, [88]=44055, [89]=44061, [90]=10239, [91]=44073, [92]=44079, [93]=2474, [94]=15732, [95]=40259, 
        [96]=7690, [97]=44111, [98]=7292, [99]=15527, [100]=44132, [101]=44139, [102]=33273, [103]=33160, [104]=44160, [105]=3158, [106]=10847, [107]=317, 
        [108]=44188, [109]=44195, [110]=7717, [111]=44209, [112]=2501, [113]=44223, [114]=10914, [116]=54257, [117]=55379, [118]=55365, [119]=55367, 
        [120]=54267, [121]=55368, [122]=16047, [123]=23666, [124]=34384, [125]=54287, [126]=54295, [127]=54296, [128]=54300, [129]=54303, [130]=54328, 
        [131]=54321, [132]=54307, [133]=54314, [134]=16144, [135]=10972, [136]=54874, [137]=54881, [138]=54885, [139]=54889, [140]=54896, [141]=54902, 
        [142]=54906, [143]=54913, [144]=54917, [145]=54921, [146]=54928, [147]=54935, [148]=54787, [155]=16213, [156]=23731, [157]=22157, [158]=5832,
        [159]=5831, [160]=23710, [161]=58153, [162]=59380, [163]=59416, [164]=59452, [165]=59488, [166]=59524, [167]=59560, [168]=59596, [169]=59632, 
        [170]=59668, [171]=59738, [172]=59752, [173]=59745, [176]=59946, [177]=60296, [178]=60646, [179]=68432, [180]=68535, [181]=68615, [183]=68107, 
        [184]=64760, [185]=66167, [186]=33167, [187]=7476, [188]=33276, [190]=67567, [193]=33176, [194]=16219, [195]=67015, [196]=66440, [197]=28112, 
        [198]=65335, [199]=68711, [200]=68791, [201]=68872, [204]=55963, [205]=64488, [206]=69281, [207]=69577, [208]=69927, [209]=137543, [210]=68608, 
        [211]=68784, [212]=68447, [213]=68696, [214]=68623, [215]=68703, [216]=68799, [217]=68527, [218]=68439, [219]=70627, [224]=71791, [225]=72141, 
        [226]=72491, [227]=72841, [228]=72913, [229]=73011, [230]=72985, [231]=73060, [232]=73037, [234]=73873, [235]=74222, [236]=74149, [237]=73935, 
        [238]=73997, [239]=74080, [240]=75386, [241]=75736, [242]=76086, [243]=76916, [244]=77076, [245]=77236, [246]=78048, [247]=78328, [248]=78608, 
        [253]=78906, [256]=82176, [257]=82128, [258]=82411, [259]=82602, [260]=82229, [261]=82966, [262]=83157, [263]=82784, [264]=94452, [265]=94460, 
        [266]=94468, [267]=94476, [268]=94484, [269]=94492, [270]=94500, [271]=94508, [272]=94516, [273]=94524, [274]=94532, [275]=94540, [276]=94548, 
        [277]=94556, [278]=94564, [279]=94572, [280]=94580, [281]=1115, [282]=7294, [283]=7508, [284]=7520, [285]=15599, [286]=15594, [287]=1674, [288]=10848, 
        [289]=15524, [290]=10921, [291]=6900, [292]=4308, [293]=4305, [294]=10150, [295]=29071, [296]=29097, [297]=28122, [298]=15546, [299]=7666, 
        [300]=15679, [301]=5921, [302]=16042, [303]=16046,  [304]=16044, [305]=33153, [307]=33283, [308]=22156, [309]=22196, [310]=22169, [311]=44728, 
        [313]=55934, [314]=55935, [315]=55936, [316]=55937, [317]=55938, [318]=55939, [320]=122792, [321]=122983, [322]=122610, [323]=121551, [324]=121901, 
        [325]=122251, [326]=123166, [327]=123348, [328]=123530, [329]=123721, [330]=123912, [331]=124094, [332]=124276, [333]=124467, [334]=125689, 
        [335]=127332, [336]=127523, [337]=127150, [338]=127935, [339]=128126, [340]=127753, [341]=127705, [342]=128308, [343]=128554, [344]=128745, 
        [345]=128372, [346]=129109, [347]=129300, [348]=128927, [349]=129482, [350]=129530, [351]=130370, [352]=130720, [353]=131070, [354]=132848, 
        [355]=133039, [356]=132666, [357]=133251, [358]=133243, [359]=133247, [360]=133254, [361]=133255, [362]=133258, [363]=133404, [364]=133396, 
        [365]=133400, [366]=133407, [367]=133408, [368]=133411, [369]=71118, [370]=71106, [371]=71100, [372]=71142, [373]=71152, [374]=71170, [380]=134799, 
        [381]=134955, [382]=134692, [383]=134701, [384]=134696, [385]=135717, [386]=136067, [387]=136417, [388]=136767, [389]=136949, [390]=137131, 
        [391]=137322, [392]=137964, [393]=138146, [394]=138328, [395]=138519, [397]=141622, [398]=141670, [399]=140694, [400]=140885, [401]=140512, 
        [402]=141249, [403]=141440, [404]=141067, [405]=142600, [406]=142418, [407]=142236, [408]=142791, [409]=143161, [410]=143531, [411]=145011, 
        [412]=145019, [413]=145015, [414]=145022, [415]=145023, [416]=145026, [417]=143901, [418]=144092, [419]=144283, [420]=144465, [421]=144647, 
        [422]=144829, [423]=145164, [424]=145172, [425]=145168, [426]=145175, [427]=145176, [428]=145179, [429]=146077, [430]=146259, [431]=146441, 
        [432]=146632, [433]=146680, [434]=146862, [435]=147044, [436]=147235, [437]=147948, [438]=148318, [439]=148688, [440]=149240, [441]=149431, 
        [442]=149058, [444]=149977, [445]=149795, [446]=149613
    }
}

------------------------------------------------------------------------
-- 	Local helper functions
------------------------------------------------------------------------
local function getNonIndexedTableCount(tableName)
    if not tableName then return nil end
    local count = 0
    for _,_ in pairs(tableName) do
        count = count +1
    end
    return count
end
--Number of possible sets to craft (update this if table above changes!)
local craftedSetsCount = getNonIndexedTableCount(craftedSets)

--Check if the item is a head or a shoulder
local function IsHeadOrShoulder(equipType)
    return (equipType == EQUIP_TYPE_HEAD or equipType == EQUIP_TYPE_SHOULDERS) or false
end

--Check if an item got less or equal "countMonsterSetBonus"
local function IsItemMonsterSet(maxEquipped)
    return (maxEquipped <= countMonsterSetBonus) or false
end

--Check if the item is dungeon BOP item
local function IsItemDungeonSet(itemLink)
    local itemBindType = GetItemLinkBindType(itemLink)
    return (itemBindType == BIND_TYPE_ON_PICKUP) or false
end

--local helper function for set data
local function checkSet(itemLink)
    if itemLink == nil or itemLink == "" then return false, "", 0, 0, 0, 0 end
    local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then isSet = false end
    return isSet, setName, setId, numBonuses, numEquipped, maxEquipped
end

-- This is the primary set data population function.
--> Parameters: setItemId number: The item id to use for extracting set data
--> Returns:    boolean found: true if new set data was extracted
-->             boolean updated: true if the set was known, but new language name data was extracted
local function LoadSetByItemId(setItemId)
    --Generate link for item
    local itemLink = lib.buildItemLink(setItemId)
    if not itemLink or itemLink == "" or IsItemLinkCrafted(itemLink) then return end
    
    local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if not isSet then return end
    
    local itemType = GetItemLinkItemType(itemLink)
    --Some set items are only "containers" ...
    if not checkItemTypes[itemType] then return end
    
    local clientLang = lib.clientLang
    local found, updated
    
    --Only add the first found item of the set as itemId!
    if sets[setId] == nil then
        sets[setId] = {}
        found = true
        sets[setId]["itemId"] = setItemId
        --Remove the gender stuff from the setname
        setName = zo_strformat("<<C:1>>", setName)
        --Update the Set names table
        sets[setId]["name"] = sets[setId]["name"] or {}
        sets[setId]["name"][clientLang] = sets[setId]["name"][clientLang] or setName
    --Update missing client languages to the set name
    elseif sets[setId] ~= nil and sets[setId]["name"] ~= nil and sets[setId]["itemId"] ~= nil then
        --The setId exists in the SavedVars but the translated string is missing for the current clientLanguage?
        if sets[setId]["name"][clientLang] == nil then
            --Remove the gender stuff from the setname
            setName = zo_strformat("<<C:1>>", setName)
            sets[setId]["name"][clientLang] = setName
            updated = true
        end
    end
    
    return found, updated
end

local function LoadSetsByIds(from, to)
    local clientLang = lib.clientLang
    for setItemId=from, to do
        itemsScanned = itemsScanned + 1
        local setFound, setUpdated = LoadSetByItemId(setItemId)
        if setFound then
            setsFound = setsFound + 1
        elseif setUpdated then
            setsUpdated = setsUpdated + 1
        end
    end
    d("[" .. MAJOR .. "]~~~Scanning sets~~~ items: " .. tostring(itemsScanned) .. ", sets new/updated: " .. tostring(setsFound) .. "/" .. tostring(setsUpdated))
end

--Load the SavedVariables
local function librarySavedVariables()
    lib.worldName = GetWorldName()
    local defaultSetsData = {}
    lib.setsData = ZO_SavedVars:NewAccountWide(lib.svDataName, lib.svVersion, "SetsData", defaultSetsData, lib.worldName)
    if lib.setsData.sets ~= nil then lib.setsLoaded = true end
end

--Check which setIds were found and compare them to the craftedSets list.
--All non-craftable will be checked if they are head and shoulder and got only 1 or 2 set bonus: monsterSets table
--All non-craftable will be checked if they are bound on pickup but tradeable: dungeonSets table
--All non-craftable will be checked if they are no monster or dungeon set: overlandSets table
local function distinguishSetTypes()
    monsterSetsCount  = 0
    dungeonSetsCount  = 0
    overlandSetsCount = 0
    monsterSets = {}
    dungeonSets = {}
    overlandSets = {}
    local buildItemLink = lib.buildItemLink
    if craftedSets ~= nil and lib.setsData.sets ~= nil then
        for setId, setData in pairs(lib.setsData.sets) do
            local isMonsterSet = false
            if not craftedSets[setId] then
                --Get the itemId stored for the setId and build the itemLink
                local itemId = setData.itemId
                if itemId ~= nil then
                    local itemLink = buildItemLink(itemId)
                    if itemLink ~= nil then
                        --Get the maxEquipped attribute of the set
                        local _, _, _, _, maxEquipped, _ = GetItemLinkSetInfo(itemLink)
                        --Check if the item is a monster set
                        if IsItemMonsterSet(maxEquipped) then
                            local equipType = GetItemLinkEquipType(itemLink)
                            if IsHeadOrShoulder(equipType) then
                                --It's a monster set (helm or shoulder with defined number of max bonus)
                                monsterSets[setId] = true
                                monsterSetsCount = monsterSetsCount + 1
                                isMonsterSet = true
                            end
                        end
                        --Item is no monster set, so check for dungeon or
                        if not isMonsterSet then
                            --Is a dungeon set (bound on pickup but tradeable)?
                            if IsItemDungeonSet(itemLink) then
                                dungeonSets[setId] = true
                                dungeonSetsCount = dungeonSetsCount + 1
                            else
                                --Is an overland set
                                overlandSets[setId] = true
                                overlandSetsCount = overlandSetsCount + 1
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Loads the setIds array with a sorted list of all set ids
local function loadSetIds()
    if lib.setsData and lib.setsData.sets then
        for setId, _ in pairs(lib.setsData.sets) do
            table.insert(setIds, setId)
        end
    end
    table.sort(setIds)
end

-- Populates saved vars for set ids that are known ahead of time in preloaded.sets.
local function loadPreloadedSetNames()
    if not lib.setsData then return end
    if not lib.setsData["preloadedLanguagesScanned"] then
        lib.setsData["preloadedLanguagesScanned"] = {}
    end
    if not lib.setsData["preloadedLanguagesScanned"][lib.currentAPIVersion] then 
        lib.setsData["preloadedLanguagesScanned"][lib.currentAPIVersion] = {}
    end
    if lib.setsData["preloadedLanguagesScanned"][lib.currentAPIVersion][tostring(lib.clientLang)] then
        return
    end
    if lib.setsData.sets == nil then
        lib.setsData.sets = {}
    end
    sets = lib.setsData.sets
    for _, itemId in pairs(preloaded["sets"]) do
        LoadSetByItemId(itemId)
    end
    lib.setsData["preloadedLanguagesScanned"][lib.currentAPIVersion][tostring(lib.clientLang)]  = true
end


------------------------------------------------------------------------
-- 	Global functions
------------------------------------------------------------------------
--Create an exmaple itemlink of the setItem's itemId
function lib.buildItemLink(itemId)
    if itemId == nil or itemId == 0 then return end
    return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
end

--Show the ask before reloadui dialog
function lib.ShowAskBeforeReloadUIDialog()
    ZO_Dialogs_ShowDialog("LIBSETS_ASK_BEFORE_RELOADUI_DIALOG", {})
end

--Load all available sets by the help of itemIds (in package size of 5000 itemIds, and 30 tries = 30 * 5000 itemIds)
function lib.LoadSets(override, fromAddonName)
    override = override or false

    if lib.setsScanning then return end
    lib.setsScanning = true
    if fromAddonName ~= nil and fromAddonName ~= "" then
        d("[" .. MAJOR .. "]Starting set scan initiated by addon \'" .. tostring(fromAddonName) .. "\', APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
    else
        d("[" .. MAJOR .. "]Starting set scan, APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
    end
    --Clear all set data
    sets = {}
    --Take exisitng SavedVars sets and update them, or override them with a new scan?
    if not override then
        if lib.setsData ~= nil and lib.setsData.sets ~= nil then
            sets = lib.setsData.sets
        end
    end
    setsFound = 0
    setsUpdated = 0
    itemsScanned = 0

    lib.setsLoaded = false

    --Loop through all item ids and save all sets to an array
    --Split the itemId packages into 5000 itemIds each, so the client is not lagging that
    --much and is not crashing!
    --> Change variable numItemIdPackages and increase it to support new added set itemIds
    --> Total itemIds collected: 0 to (numItemIdPackages * numItemIdPackageSize)
    local miliseconds = 0
    local numItemIdPackages = 30       -- Increase this to find new added set itemIds after and update

    local numItemIdPackageSize = 5000  -- do not increase this or the client may crash!
    local fromTo = {}
    local startVal = preloaded["maxItemIdScanned"] + 1
    local fromVal = startVal
    for numItemIdPackage = 1, numItemIdPackages, 1 do
        --Set the to value to loop counter muliplied with the package size (e.g. 1*500, 2*5000, 3*5000, ...)
        local toVal = startVal + numItemIdPackage * numItemIdPackageSize - 1
        --Add the from and to values to the totla itemId check array
        table.insert(fromTo, {from = fromVal, to = toVal})
        local itemLink = lib.buildItemLink(toVal)
        -- Break early if toVal isn't a valid item
        if GetItemLinkItemType(itemLink) == 0 then
            break
        end
        --For the next loop: Set the from value to the to value + 1 (e.g. 5000+1, 10000+1, ...)
        fromVal = toVal + 1
    end
    --Add itemIds and scan them for set parts!
    for _, v in pairs(fromTo) do
        zo_callLater(function()
            LoadSetsByIds(v.from, v.to)
        end, miliseconds)
        miliseconds = miliseconds + 2000 -- scan item ID packages every 2 seconds to get not kicked/crash the client!
    end
    zo_callLater(function()
        if sets ~= nil then
            d("[" .. MAJOR .. "]Scan finished. [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
            lib.setsData.sets = sets
            loadPreloadedSetNames()
            distinguishSetTypes()
            loadSetIds()
            lib.setsData.monsterSets        = monsterSets
            lib.setsData.dungeonSets        = dungeonSets
            lib.setsData.overlandSets       = overlandSets
            lib.setsData.monsterSetsCount   = monsterSetsCount
            lib.setsData.dungeonSetsCount   = dungeonSetsCount
            lib.setsData.overlandSetsCount  = overlandSetsCount
            d(">>> Crafted sets: " .. tostring(craftedSetsCount))
            d(">>> Monster sets: " .. tostring(monsterSetsCount))
            d(">>> Dungeon sets: " .. tostring(dungeonSetsCount))
            d(">>> Overland sets: " .. tostring(overlandSetsCount))
            d("\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
            --Set the last scanned API version to the SavedVariables
            lib.setsData["languagesScanned"] = lib.setsData["languagesScanned"] or {}
            lib.setsData["languagesScanned"][lib.currentAPIVersion] = lib.setsData["languagesScanned"][lib.currentAPIVersion] or {}
            lib.setsData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] = true
            --Set the flag "sets were scanned for current API"
            lib.setsData.lastSetsCheckAPIVersion = lib.currentAPIVersion
            lib.setsScanning = false
            --Start confirmation dialog and let the user do a reloadui so the SetData gets stored to the SavedVars and depending addons will work afterwards
            lib.ShowAskBeforeReloadUIDialog()
        else
            lib.setsScanning = false
            d("[" .. MAJOR .. "]ERROR: Scan not successfull! [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'\nSet data could not be saved!\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end
    end, miliseconds + 1000)
end


--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.craftedSets[setId] or false
end

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.monsterSets[setId] or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.dungeonSets[setId] or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return lib.overlandSets[setId] or false
end


--Returns information about the set if the itemId provides is a set item
--> Parameters: itemId number: The item's itemId
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemId(itemId)
    if itemId == nil then return end
    local itemLink = lib.buildItemLink(itemId)
    return checkSet(itemLink)
end

--Returns information about the set if the itemlink provides is a set item
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemLink(itemLink)
    return checkSet(itemLink)
end

--Returns a sorted array of all set ids
--> Returns: setIds table
function lib.GetAllSetIds()
    if not lib.checkIfSetsAreLoadedProperly() then return end
    return setIds
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    lang = lang or lib.clientLang
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if setId == nil or not lib.supportedLanguages[lang]
        or lib.setsData.sets[tonumber(setId)] == nil or lib.setsData.sets[tonumber(setId)]["name"] == nil
        or lib.setsData.sets[tonumber(setId)]["name"][lang] == nil then return end
    local setName = lib.setsData.sets[tonumber(setId)]["name"][lang]
    return setName
end

--Returns all names as String of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if lib.setsData.sets[tonumber(setId)] == nil or lib.setsData.sets[tonumber(setId)]["name"] == nil then return end
    local setNames = {}
    setNames = lib.setsData.sets[tonumber(setId)]["name"]
    return setNames
end

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains the number setId,
----> number itemId of an example setItem (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's example item),
----> table names ([String lang] = String name),
----> table setTypes (table containing booleans for isCrafted, isDungeon, isMonster, isOverland),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table will contain 1 entry if it's a NON-craftable setId (wayshrines = {[1] = WSNodeNoFraction})
------>and 3 entries (one for each faction) if it's a craftable setId (wayshrines = {[1] = WSNodeFraction1, [2] = WSNodeFraction2, [3] = WSNodeFraction3})
function lib.GetSetInfo(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    if lib.setsData.sets[tonumber(setId)] == nil then return end
    local setInfoTable = {}
    local setInfoFromSV = lib.setsData.sets[tonumber(setId)]
    setInfoTable.setId = setId
    setInfoTable.itemId = setInfoFromSV["itemId"]
    setInfoTable.names = setInfoFromSV["name"] or {}
    setInfoTable.setTypes = {
        ["isCrafted"]   = false,
        ["isDungeon"]   = false,
        ["isMonster"]   = false,
        ["isOverland"]  = false,
    }
    setInfoTable.traitsNeeded   = 0
    local isCraftedSet = (lib.craftedSets[setId]) or false
    --Craftable set
    local setsData = setInfo[setId]
    if isCraftedSet then
        if setsData then
            setInfoTable.traitsNeeded   = setsData.traitsNeeded
            setInfoTable.wayshrines     = setsData.wayshrines
            setInfoTable.setTypes["isCrafted"] = true
        end
        --Non-craftable set
    else
        if setsData then
            setInfoTable.wayshrines     = setsData.wayshrines
        end
        --Check the type of the set
        if lib.monsterSets[setId] then      setInfoTable.setTypes["isMonster"]  = true
        elseif lib.dungeonSets[setId] then  setInfoTable.setTypes["isDungeon"]  = true
        elseif lib.overlandSets[setId] then setInfoTable.setTypes["isOverland"] = true
        end
    end
    return setInfoTable
end

--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Ebonheart Pact, 2=Admeri Dominion, 3=Daggerfall Covenant)
function lib.JumpToSetId(setId, factionIndex)
    if setId == nil then return false end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local jumpToNode = -1
    --Is a crafted set?
    if craftedSets[setId] then
        --Then use the faction Id 1 to 3
        factionIndex = factionIndex or 1
        if factionIndex < 1 or factionIndex > 3 then factionIndex = 1 end
        local craftedSetWSData = setInfo[setId].wayshrines
        if craftedSetWSData ~= nil and craftedSetWSData[factionIndex] ~= nil then
            jumpToNode = craftedSetWSData[factionIndex]
        end
        --Other sets wayshrines
    else
        jumpToNode = setInfo[setId].wayshrines[1]
    end
    --Jump now?
    if jumpToNode and jumpToNode > 0 then
        FastTravelToNode(jumpToNode)
        return true
    end
    return false
end

--Returns an itemId of an item of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    number setItemId
function lib.GetSetItemId(setId)
    if setId == nil then return end
    if not lib.checkIfSetsAreLoadedProperly() then return end
    local setItemId = lib.setsData.sets[tonumber(setId)]["itemId"]
    return setItemId
end

--Returns a boolean value, true if the sets of the game were already loaded/ false if not
--> Returns:    boolean areSetsLoaded
function lib.AreSetsLoaded()
    local areSetsLoaded = false
    local lastCheckedSetsAPIVersion = math.max( lib.setsData.lastSetsCheckAPIVersion or 0, preloaded.lastSetsCheckAPIVersion )
    areSetsLoaded = (lib.setsLoaded == true and (lastCheckedSetsAPIVersion >= lib.currentAPIVersion)) or false
    return areSetsLoaded
end

--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not
--> Returns:    boolean isCurrentlySetsScanning
function lib.IsSetsScanning()
    return lib.setsScanning
end

--Returns a boolean value, true if the sets database is properly loaded yet and is not currently scanning
--or false if not
function lib.checkIfSetsAreLoadedProperly()
    if lib.IsSetsScanning() or not lib.AreSetsLoaded() then return false end
    if not lib.setsData or not lib.setsData.sets then return false end
    return true
end

------------------------------------------------------------------------
--Addon loaded function
local function OnLibraryLoaded(event, name)
    --Only load lib if ingame
    if name:find("^ZO_") then return end
    EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
    --The actual clients language
    lib.clientLang = GetCVar("language.2")
    --The actual API version
    lib.currentAPIVersion = GetAPIVersion()

    --Load the SavedVariables
    librarySavedVariables()

    --Initialize the ask before reloadui dialog
    lib.AskBeforeReloadUIDialogInitialize(LibSetsAskBeforeReloadUIDialogXML)

    --Did the API version change since last sets check? Then rebuild the sets now!
    local lastCheckedSetsAPIVersion = math.max( lib.setsData.lastSetsCheckAPIVersion or 0, preloaded.lastSetsCheckAPIVersion)
    --API version changed?
    if lastCheckedSetsAPIVersion < lib.currentAPIVersion then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]API version changed from \'" .. tostring(lastCheckedSetsAPIVersion) .. "\'to \'" .. tostring(lib.currentAPIVersion) .. "\nNew set IDs and names need to be scanned!\nThis will take a few seconds.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(true)
        end, 1000)
        --Client language changed and language is not yet in the SavedVariables?
    elseif lib.supportedLanguages and lib.clientLang and lib.supportedLanguages[lib.clientLang] == true
            and lib.setsData and lib.setsData.sets and lib.setsData["languagesScanned"] and
            (lib.setsData["languagesScanned"][lib.currentAPIVersion] == nil or (lib.setsData["languagesScanned"][lib.currentAPIVersion] and lib.setsData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] == nil)) then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]Sets data for your current client language \'" .. tostring(lib.clientLang) .. "\' and the current API version \'" .. tostring(lib.currentAPIVersion) .. "\' was not added yet.\nNew set names need to be scanned!\nThis will take a few seconds.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(false)
        end, 1000)
    else
        --Load preloaded set names
        loadPreloadedSetNames()
        loadSetIds()
        if lib.setsData
                and (lib.setsData.monsterSets == nil or lib.setsData.dungeonSets == nil or lib.setsData.overlandSets == nil
                or lib.setsData.monsterSetsCount == nil or lib.setsData.dungeonSetsCount == nil or lib.setsData.overlandSetsCount == nil
                or not next(lib.setsData.monsterSets) or not next(lib.setsData.dungeonSets) or not next(lib.setsData.overlandSets)
                or lib.setsData.monsterSetsCount == 0 or lib.setsData.dungeonSetsCount == 0 or lib.setsData.overlandSetsCount == 0)
        then
            distinguishSetTypes()
            lib.setsData.monsterSets        = monsterSets
            lib.setsData.dungeonSets        = dungeonSets
            lib.setsData.overlandSets       = overlandSets
            lib.setsData.monsterSetsCount   = monsterSetsCount
            lib.setsData.dungeonSetsCount   = dungeonSetsCount
            lib.setsData.overlandSetsCount  = overlandSetsCount
        end
        lib.setsLoaded = true
    end
    --Provide the library the "list of set types" and counts
    lib.craftedSets         = craftedSets
    lib.craftedSetsCount    = craftedSetsCount
    lib.monsterSets         = lib.setsData.monsterSets
    lib.dungeonSets         = lib.setsData.dungeonSets
    lib.overlandSets        = lib.setsData.overlandSets
    lib.monsterSetsCount    = lib.setsData.monsterSetsCount
    lib.dungeonSetsCount    = lib.setsData.dungeonSetsCount
    lib.overlandSetsCount   = lib.setsData.overlandSetsCount
    lib.preloaded           = preloaded
end

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)