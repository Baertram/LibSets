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
local MAJOR, MINOR = "LibSets", 0.06
LibSets = LibSets or {}
local lib = LibSets

lib.name        = MAJOR
lib.version     = MINOR
--SavedVariables info
lib.svDataName  = "LibSets_SV_Data"
lib.svVersion   = 0.6
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

--Current monster set bonus count (maximum)
local countMonsterSetBonus = 2
--The monster set setIds (all setIds which are not in the craftedSets table!)
local monsterSetsCount  = 0
local dungeonSetsCount  = 0
local overlandSetsCount = 0
local monsterSets       = {}
local dungeonSets       = {}
local overlandSets      = {}

--The craftable set setIds
local craftedSets = {
    [176]   = true,     --Adelssieg / Noble's Conquest
    [82]    = true,     --Alessias Bollwerk / Alessia's Bulwark
    [54]    = true,     --Aschengriff / Ashen Grip
    [323]   = true,     --Assassinenlist / Assassin's Guile
    [87]    = true,     --Augen von Mara / Eyes of Mara
    [51]    = true,     --Blick der Mutter der Nacht / Night Mother's Gaze
    [324]   = true,     --Daedrische Gaunerei / Daedric Trickery
    [161]   = true,     --Doppelstern / Twice-Born Star
    [73]    = true,     --Erinnerung / Oblivion's Foe
    [226]   = true,     --Ewige Jagd / Eternal Hunt
    [208]   = true,     --Feuertaufe / Trial by Fire
    [207]   = true,     --Gesetz von Julianos / LAw of Julianos
    [240]   = true,     --Gladiator von Kvatch / Kvatch Gladiator
    [408]   = true,     --Grabpflocksammler / Grave-Stake Collector
    [78]    = true,     --Histrinde / Hist Bark
    [80]    = true,     --Hundings Zorn / Hunding's Rage
    [92]    = true,     --Kagrenacs Hoffnung / Kagrenac's Hope
    [351]   = true,     --Kernaxiom / Innate Axiom
    [325]   = true,     --Kettensprenger / Shacklebreaker
    [386]   = true,     --Kreckenantlitz / Sload's Semblance
    [44]    = true,     --Kuss des Vampirs / Vampire's Kiss
    [81]    = true,     --Lied der Lamien / Song of Lamae
    [410]   = true,     --Macht der verlorenen Legion / Might of the Lost Legion
    [48]    = true,     --Magnus' Gabe / Magnu's Gift
    [353]   = true,     --Mechanikblick / Mechanical Acuity
    [352]   = true,     --Messingpanzer / Fortified Brass
    [219]   = true,     --Morkuldin / Morkuldin
    [409]   = true,     --Nagaschamane / Naga Shaman
    [387]   = true,     --Nocturnals Gunst / Nocturnal's Favor
    [84]    = true,     --Orgnums Schuppen / Orgnum's Scales
    [242]   = true,     --Pelinals Talent / Pelinal's Aptitude
    [43]    = true,     --Rüstung der Verführung / Armor of the Seducer
    [178]   = true,     --Rüstungsmeister / Armor Master
    [74]    = true,     --Schemenauge / Spectre's Eye
    [225]   = true,     --Schlauer Alchemist / Clever Alchemist
    [95]    = true,     --Shalidors Fluch / Shalidor's Curse
    [40]    = true,     --Stille der Nacht / Night's Silence
    [224]   = true,     --Tavas Gunst / Tava's Favor
    [37]    = true,     --Todeswind / Death's Wind
    [75]    = true,     --Torugs Pakt / Torug's Pact
    [177]   = true,     --Umverteilung / Redistributor
    [241]   = true,     --Varens Erbe / Varen's Legacy
    [385]   = true,     --Versierter Reiter / Adept Rider
    [148]   = true,     --Weg der Arnea / Way of the Arena
    [79]    = true,     --Weidenpfad / Willow's Path
    [41]    = true,     --Weißplankes Vergeltung / Whitestrake's Retribution
    [38]    = true,     --Zwielichtkuss / Twilight's Embrace
}

--Wayshrine nodes and number of traits needed for sets. All rights and work belongs to the addon "CraftStore" and "WritWorthy"!
--https://www.esoui.com/downloads/info1590-CraftStoreWrathstone.html
--https://www.esoui.com/downloads/info1605-WritWorthy.html
local setInfo = {
    --Crafted Sets (See names of setId (table key) above behind table entries of "craftedSets")
    [37]    = {wayshrines={1,177,71},        traitsNeeded=2},
    [38]    = {wayshrines={15,169,205},      traitsNeeded=3},
    [40]    = {wayshrines={216,121,65},      traitsNeeded=2},
    [41]    = {wayshrines={82,151,78},       traitsNeeded=4},
    [43]    = {wayshrines={23,164,32},       traitsNeeded=3},
    [44]    = {wayshrines={58,101,93},       traitsNeeded=5},
    [48]    = {wayshrines={13,148,48},       traitsNeeded=4},
    [51]    = {wayshrines={34,156,118},      traitsNeeded=6},
    [54]    = {wayshrines={7,175, 77},       traitsNeeded=2},
    [73]    = {wayshrines={135,135,135},     traitsNeeded=8},
    [74]    = {wayshrines={133,133,133},     traitsNeeded=8},
    [75]    = {wayshrines={19,165,24},       traitsNeeded=3},
    [78]    = {wayshrines={9,154,51},        traitsNeeded=4},
    [79]    = {wayshrines={35,144,111},      traitsNeeded=6},
    [80]    = {wayshrines={39,161,113},      traitsNeeded=6},
    [81]    = {wayshrines={137,103,89},      traitsNeeded=5},
    [82]    = {wayshrines={155,105, 95},     traitsNeeded=5},
    [84]    = {wayshrines={-2,-2,-2},        traitsNeeded=8},
    [87]    = {wayshrines={-1,-1,-1},        traitsNeeded=8},
    [92]    = {wayshrines={-2,-2,-2},        traitsNeeded=8},
    [95]    = {wayshrines={-1,-1,-1},        traitsNeeded=8},
    [148]   = {wayshrines={217,217,217},     traitsNeeded=8},
    [161]   = {wayshrines={234,234,234},     traitsNeeded=9},
    [177]   = {wayshrines={199,201,203},     traitsNeeded=5},
    [176]   = {wayshrines={199,201,203},     traitsNeeded=7},
    [178]   = {wayshrines={199,201,203},     traitsNeeded=9},
    [207]   = {wayshrines={241,241,241},     traitsNeeded=6},
    [208]   = {wayshrines={237,237,237},     traitsNeeded=3},
    [219]   = {wayshrines={237,237,237},     traitsNeeded=9},
    [224]   = {wayshrines={257,257,257},     traitsNeeded=5},
    [225]   = {wayshrines={257,257,257},     traitsNeeded=7},
    [226]   = {wayshrines={255,255,255},     traitsNeeded=9},
    [240]   = {wayshrines={254,254,254},     traitsNeeded=5},
    [241]   = {wayshrines={251,251,251},     traitsNeeded=7},
    [242]   = {wayshrines={254,254,254},     traitsNeeded=9},
    [323]   = {wayshrines={276,276,276},     traitsNeeded=3},
    [324]   = {wayshrines={329,329,329},     traitsNeeded=8},
    [351]   = {wayshrines={339,339,339},     traitsNeeded=6},
    [352]   = {wayshrines={337,337,337},     traitsNeeded=2},
    [353]   = {wayshrines={338,338,338},     traitsNeeded=4},
    [325]   = {wayshrines={282,282,282},     traitsNeeded=6},
    [385]   = {wayshrines={359,359,359},     traitsNeeded=3},
    [386]   = {wayshrines={360,360,360},     traitsNeeded=6},
    [387]   = {wayshrines={354,354,354},     traitsNeeded=9},
    --TODO
    [408]   = {wayshrines={375,375,375},     traitsNeeded=0},
    [409]   = {wayshrines={379,379,379},     traitsNeeded=0},
    [410]   = {wayshrines={379,379,379},     traitsNeeded=0},

    --Other sets (Set names can be found inside SavedVariables file LibSets.lua, after scaning of the set names within your client language finished.
    --Search for "["sets"]" inside the SV file and you'll find the ["name"] in the scanned languages e.g. ["de"] or ["en"] and an example itemId of one
    --item of this set which you can use with LibSets.buildItemLink(itemId) to generate an example itemLink of the set item)
    --TODO
    [31]    = {wayshrines={65}},                                     --Sonnenseide (Stonefalls: Davons Watch, or 41 "Fort Arnad" near to a Worldboss)
}

local preloaded = {
    ["maxItemIdScanned"] = 152154,
    ["lastSetsCheckAPIVersion"] = 100027,
    ["languagesScanned"] =  { ["de"] = true, ["en"] = true, ["fr"] = true },
    ["sets"] = {[19]={["name"]={["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"},["itemId"]=22200},[20]={["name"]={["fr"]="Armure d'homme-médecine",["en"]="Witchman Armor",["de"]="Hexenwerk"},["itemId"]=10973},[21]={["name"]={["fr"]="La Garde du dragon akaviroise",["en"]="Akaviri Dragonguard",["de"]="Akavirische Drachengarde"},["itemId"]=7664},[22]={["name"]={["fr"]="Manteau du rêveur",["en"]="Dreamer's Mantle",["de"]="Mantel des Träumers"},["itemId"]=2503},[23]={["name"]={["fr"]="L’Esprit de l'archer",["en"]="Archer's Mind",["de"]="Schützensinn"},["itemId"]=43761},[24]={["name"]={["fr"]="La Chance du valet",["en"]="Footman's Fortune",["de"]="Geschick des Fußsoldaten"},["itemId"]=43764},[25]={["name"]={["fr"]="La Rose du désert",["en"]="Desert Rose",["de"]="Wüstenrose"},["itemId"]=43767},[26]={["name"]={["fr"]="Les Haillons de prisonnier",["en"]="Prisoner's Rags",["de"]="Lumpen des Gefangenen"},["itemId"]=15728},[27]={["name"]={["fr"]="L’Héritage de Fiord",["en"]="Fiord's Legacy",["de"]="Fiords Erbe"},["itemId"]=7661},[28]={["name"]={["fr"]="La Peau d'écorce",["en"]="Barkskin",["de"]="Borkenhaut"},["itemId"]=15767},[29]={["name"]={["fr"]="La Cotte de mailles du sergent",["en"]="Sergeant's Mail",["de"]="Rüstung des Feldwebels"},["itemId"]=16228},[30]={["name"]={["fr"]="Carapace de foudroptère",["en"]="Thunderbug's Carapace",["de"]="Donnerkäferpanzer"},["itemId"]=10885},[31]={["name"]={["fr"]="Les Atours du soleil",["en"]="Silks of the Sun",["de"]="Sonnenseide"},["itemId"]=1530},[32]={["name"]={["fr"]="Le Froc du guérisseur",["en"]="Healer's Habit",["de"]="Bräuche des Heilers"},["itemId"]=43788},[33]={["name"]={["fr"]="La Morsure de la vipère",["en"]="Viper's Sting",["de"]="Vipernbiss"},["itemId"]=10961},[34]={["name"]={["fr"]="Étreinte de la Mère de la nuit",["en"]="Night Mother's Embrace",["de"]="Umarmung der Mutter der Nacht"},["itemId"]=4289},[35]={["name"]={["fr"]="Le Chevalier-cauchemar",["en"]="Knightmare",["de"]="Albtraumritter"},["itemId"]=29065},[36]={["name"]={["fr"]="Armure de l'Héritage voilé",["en"]="Armor of the Veiled Heritance",["de"]="Rüstung des Schleiererbes"},["itemId"]=1373},[37]={["name"]={["fr"]="Le Vent mortel",["en"]="Death's Wind",["de"]="Todeswind"},["itemId"]=43803},[38]={["name"]={["fr"]="L’Étreinte du crépuscule",["en"]="Twilight's Embrace",["de"]="Zwielichtkuss"},["itemId"]=43807},[39]={["name"]={["fr"]="L’Ordre d'Alessia",["en"]="Alessian Order",["de"]="Alessianischer Orden"},["itemId"]=43811},[40]={["name"]={["fr"]="Le Silence de la nuit",["en"]="Night's Silence",["de"]="Stille der Nacht"},["itemId"]=43815},[41]={["name"]={["fr"]="La Rétribution de Blancserpent",["en"]="Whitestrake's Retribution",["de"]="Weißplankes Vergeltung"},["itemId"]=43819},[43]={["name"]={["fr"]="L’Armure de la séductrice",["en"]="Armor of the Seducer",["de"]="Rüstung der Verführung"},["itemId"]=43827},[44]={["name"]={["fr"]="Le Baiser du vampire",["en"]="Vampire's Kiss",["de"]="Kuss des Vampirs"},["itemId"]=43831},[46]={["name"]={["fr"]="Atours du noble duelliste",["en"]="Noble Duelist's Silks",["de"]="Seide des edlen Duellanten"},["itemId"]=22161},[47]={["name"]={["fr"]="Robes de la Main de Gloire",["en"]="Robes of the Withered Hand",["de"]="Roben der Verdorrten Hand"},["itemId"]=7514},[48]={["name"]={["fr"]="Le Présent de Magnus",["en"]="Magnus' Gift",["de"]="Magnus' Gabe"},["itemId"]=43847},[49]={["name"]={["fr"]="L’Ombre du Mont Écarlate",["en"]="Shadow of the Red Mountain",["de"]="Schatten des Roten Berges"},["itemId"]=70},[50]={["name"]={["fr"]="La Morag Tong",["en"]="The Morag Tong",["de"]="Morag Tong"},["itemId"]=43855},[51]={["name"]={["fr"]="Le Regard de la Mère de la nuit",["en"]="Night Mother's Gaze",["de"]="Blick der Mutter der Nacht"},["itemId"]=43859},[52]={["name"]={["fr"]="L’Appel de l'acier",["en"]="Beckoning Steel",["de"]="Klingender Stahl"},["itemId"]=43863},[53]={["name"]={["fr"]="Le Fourneau de glace",["en"]="The Ice Furnace",["de"]="Eisschmiede"},["itemId"]=33159},[54]={["name"]={["fr"]="La Poigne de cendres",["en"]="Ashen Grip",["de"]="Aschengriff"},["itemId"]=43871},[55]={["name"]={["fr"]="Châle de prière",["en"]="Prayer Shawl",["de"]="Gebetstuch"},["itemId"]=10067},[56]={["name"]={["fr"]="L’Étreinte de Stendarr",["en"]="Stendarr's Embrace",["de"]="Stendarrs Umarmung"},["itemId"]=7668},[57]={["name"]={["fr"]="L’Emprise de Syrabane",["en"]="Syrabane's Grip",["de"]="Syrabanns Griff"},["itemId"]=1672},[58]={["name"]={["fr"]="La Peau de loup-garou",["en"]="Hide of the Werewolf",["de"]="Fell des Werwolfs"},["itemId"]=1088},[59]={["name"]={["fr"]="Le Baiser de Kyne",["en"]="Kyne's Kiss",["de"]="Kynes Kuss"},["itemId"]=43895},[60]={["name"]={["fr"]="Le Sentier obscur",["en"]="Darkstride",["de"]="Dunkelschritt"},["itemId"]=7295},[61]={["name"]={["fr"]="Le Tueur du roi dreugh",["en"]="Dreugh King Slayer",["de"]="Dreughkönigsschlächter"},["itemId"]=139},[62]={["name"]={["fr"]="Coquille du rejeton",["en"]="Hatchling's Shell",["de"]="Schlüpflingspanzer"},["itemId"]=7440},[63]={["name"]={["fr"]="Le Mastodonte",["en"]="The Juggernaut",["de"]="Koloss"},["itemId"]=43915},[64]={["name"]={["fr"]="La Parure du bateleur d'ombre",["en"]="Shadow Dancer's Raiment",["de"]="Kleidung des Schattentänzers"},["itemId"]=10878},[65]={["name"]={["fr"]="Toucher de Sangrépine",["en"]="Bloodthorn's Touch",["de"]="Spur eines Blutdorns"},["itemId"]=471},[66]={["name"]={["fr"]="Robes de l'Hist",["en"]="Robes of the Hist",["de"]="Roben des Hist"},["itemId"]=7445},[67]={["name"]={["fr"]="La Marcheuse d'ombres",["en"]="Shadow Walker",["de"]="Schattengänger"},["itemId"]=43935},[68]={["name"]={["fr"]="Le Stygien",["en"]="Stygian",["de"]="Stygier"},["itemId"]=10861},[69]={["name"]={["fr"]="La Parure de l'éclaireur",["en"]="Ranger's Gait",["de"]="Laufstil des Waldläufers"},["itemId"]=1662},[70]={["name"]={["fr"]="Brute de la septième Légion",["en"]="Seventh Legion Brute",["de"]="Rohling der siebten Legion"},["itemId"]=15600},[71]={["name"]={["fr"]="Le Fléau de Durok",["en"]="Durok's Bane",["de"]="Duroks Fluch"},["itemId"]=22182},[72]={["name"]={["fr"]="L’Armure lourde de Nikulas",["en"]="Nikulas' Heavy Armor",["de"]="Nikulas' schwere Rüstung"},["itemId"]=22162},[73]={["name"]={["fr"]="L’Adversaire d'Oblivion",["en"]="Oblivion's Foe",["de"]="Erinnerung"},["itemId"]=43965},[74]={["name"]={["fr"]="L’Œil du spectre",["en"]="Spectre's Eye",["de"]="Schemenauge"},["itemId"]=43971},[75]={["name"]={["fr"]="Le Pacte de Torug",["en"]="Torug's Pact",["de"]="Torugs Pakt"},["itemId"]=43977},[76]={["name"]={["fr"]="Les Robes de maîtrise de transformation",["en"]="Robes of Alteration Mastery",["de"]="Roben der Veränderungsbeherrschung"},["itemId"]=43983},[77]={["name"]={["fr"]="Le Croisé",["en"]="Crusader",["de"]="Glaubenskrieger"},["itemId"]=33155},[78]={["name"]={["fr"]="L’Écorce d'Hist",["en"]="Hist Bark",["de"]="Histrinde"},["itemId"]=43995},[79]={["name"]={["fr"]="Le Sentier des saules",["en"]="Willow's Path",["de"]="Weidenpfad"},["itemId"]=44001},[80]={["name"]={["fr"]="La Rage de Hunding",["en"]="Hunding's Rage",["de"]="Hundings Zorn"},["itemId"]=44007},[81]={["name"]={["fr"]="Le Chant de Lamae",["en"]="Song of Lamae",["de"]="Lied der Lamien"},["itemId"]=44013},[82]={["name"]={["fr"]="Le Rempart d'Alessia",["en"]="Alessia's Bulwark",["de"]="Alessias Bollwerk"},["itemId"]=44019},[83]={["name"]={["fr"]="Le Fléau des Elfes",["en"]="Elf Bane",["de"]="Elfenfluch"},["itemId"]=44025},[84]={["name"]={["fr"]="Les Écailles d'Orgnum",["en"]="Orgnum's Scales",["de"]="Orgnums Schuppen"},["itemId"]=44031},[85]={["name"]={["fr"]="La Clémence d'Almalexia",["en"]="Almalexia's Mercy",["de"]="Almalexias Gnade"},["itemId"]=44037},[86]={["name"]={["fr"]="Élégance de la reine",["en"]="Queen's Elegance",["de"]="Eleganz der Königin"},["itemId"]=7598},[87]={["name"]={["fr"]="Les Yeux de Mara",["en"]="Eyes of Mara",["de"]="Augen von Mara"},["itemId"]=44049},[88]={["name"]={["fr"]="Les Robes de maîtrise de la destruction",["en"]="Robes of Destruction Mastery",["de"]="Roben der Zerstörungsbeherrschung"},["itemId"]=44055},[89]={["name"]={["fr"]="La Sentinelle",["en"]="Sentry",["de"]="Wachposten"},["itemId"]=44061},[90]={["name"]={["fr"]="Morsure de senche",["en"]="Senche's Bite",["de"]="Biss des Senche"},["itemId"]=10239},[91]={["name"]={["fr"]="Le Tranchant d'Oblivion",["en"]="Oblivion's Edge",["de"]="Vorteil des Vergessens"},["itemId"]=44073},[92]={["name"]={["fr"]="L’Espoir de Kagrenac",["en"]="Kagrenac's Hope",["de"]="Kagrenacs Hoffnung"},["itemId"]=44079},[93]={["name"]={["fr"]="L’Armure de plate du chevalier-tempête",["en"]="Storm Knight's Plate",["de"]="Wut des Sturmritters"},["itemId"]=2474},[94]={["name"]={["fr"]="Armure bénie de Méridia",["en"]="Meridia's Blessed Armor",["de"]="Meridias gesegnete Rüstung"},["itemId"]=15732},[95]={["name"]={["fr"]="La Malédiction de Shalidor",["en"]="Shalidor's Curse",["de"]="Shalidors Fluch"},["itemId"]=40259},[96]={["name"]={["fr"]="L’Armure de vérité",["en"]="Armor of Truth",["de"]="Rüstung der Wahrheit"},["itemId"]=7690},[97]={["name"]={["fr"]="L’Archimage",["en"]="The Arch-Mage",["de"]="Erzmagier"},["itemId"]=44111},[98]={["name"]={["fr"]="Nécropotence",["en"]="Necropotence",["de"]="Nekropotenz"},["itemId"]=7292},[99]={["name"]={["fr"]="Le Salut",["en"]="Salvation",["de"]="Erlösung"},["itemId"]=15527},[100]={["name"]={["fr"]="L’Œil de faucon",["en"]="Hawk's Eye",["de"]="Falkenauge"},["itemId"]=44132},[101]={["name"]={["fr"]="Affliction",["en"]="Affliction",["de"]="Elend"},["itemId"]=44139},[102]={["name"]={["fr"]="Écailles de l'éventreur des dunes",["en"]="Duneripper's Scales",["de"]="Schuppen des Dünenbrechers"},["itemId"]=33273},[103]={["name"]={["fr"]="Le Fourneau de magie",["en"]="Magicka Furnace",["de"]="Magickaschmiede"},["itemId"]=33160},[104]={["name"]={["fr"]="Le Mangeur de malédiction",["en"]="Curse Eater",["de"]="Fluchfresser"},["itemId"]=44160},[105]={["name"]={["fr"]="Les Sœurs jumelles",["en"]="Twin Sisters",["de"]="Zwillingsschwestern"},["itemId"]=3158},[106]={["name"]={["fr"]="Arche de la Reine-nature",["en"]="Wilderqueen's Arch",["de"]="Bogen der Wildkönigin"},["itemId"]=10847},[107]={["name"]={["fr"]="Bénédiction du Wyrd",["en"]="Wyrd Tree's Blessing",["de"]="Segen des Wyrdbaums"},["itemId"]=317},[108]={["name"]={["fr"]="L’Ensemble du ravageur",["en"]="Ravager",["de"]="Verwüster"},["itemId"]=44188},[109]={["name"]={["fr"]="La Lumière de Cyrodiil",["en"]="Light of Cyrodiil",["de"]="Licht von Cyrodiil"},["itemId"]=44195},[110]={["name"]={["fr"]="Le Sanctuaire",["en"]="Sanctuary",["de"]="Heiligtum"},["itemId"]=7717},[111]={["name"]={["fr"]="La Défense de Cyrodiil",["en"]="Ward of Cyrodiil",["de"]="Schutz von Cyrodiil"},["itemId"]=44209},[112]={["name"]={["fr"]="Terreur nocturne",["en"]="Night Terror",["de"]="Nachtschrecken"},["itemId"]=2501},[113]={["name"]={["fr"]="Les Armoiries de Cyrodiil",["en"]="Crest of Cyrodiil",["de"]="Wappen von Cyrodiil"},["itemId"]=44223},[114]={["name"]={["fr"]="L’Âme lumineuse",["en"]="Soulshine",["de"]="Seelenschein"},["itemId"]=10914},[116]={["name"]={["fr"]="La suite de destruction",["en"]="The Destruction Suite",["de"]="Garnitur der Zerstörung"},["itemId"]=54257},[117]={["name"]={["fr"]="Les reliques du docteur Ansur",["en"]="Relics of the Physician, Ansur",["de"]="Relikte des Mediziners Ansur"},["itemId"]=55379},[118]={["name"]={["fr"]="Les Trésors de la Forgeterre",["en"]="Treasures of the Earthforge",["de"]="Schätze der Erdenschmiede"},["itemId"]=55365},[119]={["name"]={["fr"]="Les Reliques de la rébellion",["en"]="Relics of the Rebellion",["de"]="Relikte der Rebellion"},["itemId"]=55367},[120]={["name"]={["fr"]="Les Armes d'Infernace",["en"]="Arms of Infernace",["de"]="Waffen Infernals"},["itemId"]=54267},[121]={["name"]={["fr"]="Les Armes des ancêtres",["en"]="Arms of the Ancestors",["de"]="Waffen der Ahnen"},["itemId"]=55368},[122]={["name"]={["fr"]="L’Armure d'ébène",["en"]="Ebon Armory",["de"]="Ebenerzarsenal"},["itemId"]=16047},[123]={["name"]={["fr"]="La Meute d'Hircine",["en"]="Hircine's Veneer",["de"]="Hircines Schein"},["itemId"]=23666},[124]={["name"]={["fr"]="La Tenue du Ver",["en"]="The Worm's Raiment",["de"]="Garderobe des Wurms"},["itemId"]=34384},[125]={["name"]={["fr"]="La Fureur de l'Empire",["en"]="Wrath of the Imperium",["de"]="Zorn des Kaiserreichs"},["itemId"]=54287},[126]={["name"]={["fr"]="La Grâce des anciens",["en"]="Grace of the Ancients",["de"]="Anmut der Uralten"},["itemId"]=54295},[127]={["name"]={["fr"]="La Frappe mortelle",["en"]="Deadly Strike",["de"]="Tödlicher Stoß"},["itemId"]=54296},[128]={["name"]={["fr"]="La Bénédiction des monarques",["en"]="Blessing of the Potentates",["de"]="Segen des Potentaten"},["itemId"]=54300},[129]={["name"]={["fr"]="Rétribution",["en"]="Vengeance Leech",["de"]="Saugende Vergeltung"},["itemId"]=54303},[130]={["name"]={["fr"]="L’Œil d'aigle",["en"]="Eagle Eye",["de"]="Adlerauge"},["itemId"]=54328},[131]={["name"]={["fr"]="Le Bastion du continent",["en"]="Bastion of the Heartland",["de"]="Bastion des Herzlandes"},["itemId"]=54321},[132]={["name"]={["fr"]="Le Bouclier du vaillant",["en"]="Shield of the Valiant",["de"]="Schild des Tapferen"},["itemId"]=54307},[133]={["name"]={["fr"]="Le Boutoir de rapidité",["en"]="Buffer of the Swift",["de"]="Dämpfer des Geschwinden"},["itemId"]=54314},[134]={["name"]={["fr"]="Le Suaire de la liche",["en"]="Shroud of the Lich",["de"]="Tuch des Lich"},["itemId"]=16144},[135]={["name"]={["fr"]="L’Héritage du Draugr",["en"]="Draugr's Heritage",["de"]="Erbe des Draugrs"},["itemId"]=10972},[136]={["name"]={["fr"]="Le Guerrier immortel",["en"]="Immortal Warrior",["de"]="Unsterblicher Krieger"},["itemId"]=54874},[137]={["name"]={["fr"]="Le Guerrier furieux",["en"]="Berserking Warrior",["de"]="Tobender Krieger"},["itemId"]=54881},[138]={["name"]={["fr"]="Le Guerrier défenseur",["en"]="Defending Warrior",["de"]="Verteidigender Krieger"},["itemId"]=54885},[139]={["name"]={["fr"]="Le Mage avisé",["en"]="Wise Mage",["de"]="Weiser Magier"},["itemId"]=54889},[140]={["name"]={["fr"]="Le Mage destructeur",["en"]="Destructive Mage",["de"]="Zerstörerischer Magier"},["itemId"]=54896},[141]={["name"]={["fr"]="Le Mage guérisseur",["en"]="Healing Mage",["de"]="Heilender Magier"},["itemId"]=54902},[142]={["name"]={["fr"]="Le Serpent rapide",["en"]="Quick Serpent",["de"]="Flinke Schlange"},["itemId"]=54906},[143]={["name"]={["fr"]="Le Serpent venimeux",["en"]="Poisonous Serpent",["de"]="Giftschlange"},["itemId"]=54913},[144]={["name"]={["fr"]="Le Serpent à deux crocs",["en"]="Twice-Fanged Serpent",["de"]="Doppelzüngige Schlange"},["itemId"]=54917},[145]={["name"]={["fr"]="La Voie du feu",["en"]="Way of Fire",["de"]="Weg des Feuers"},["itemId"]=54921},[146]={["name"]={["fr"]="La Voie de l'air",["en"]="Way of Air",["de"]="Weg der Luft"},["itemId"]=54928},[147]={["name"]={["fr"]="La Voie de la connaissance martiale",["en"]="Way of Martial Knowledge",["de"]="Weg der Kampfkunst"},["itemId"]=54935},[148]={["name"]={["fr"]="La Voie de l'arène",["en"]="Way of the Arena",["de"]="Weg der Arena"},["itemId"]=54787},[155]={["name"]={["fr"]="Bastion indomptable",["en"]="Undaunted Bastion",["de"]="Unerschrockenen-Bastion"},["itemId"]=16213},[156]={["name"]={["fr"]="Infiltrateur indoptable",["en"]="Undaunted Infiltrator",["de"]="Unerschrockener Infiltrator"},["itemId"]=23731},[157]={["name"]={["fr"]="Détrameur indomptable",["en"]="Undaunted Unweaver",["de"]="Unerschrockener Entflechter"},["itemId"]=22157},[158]={["name"]={["fr"]="Bouclier de braise",["en"]="Embershield",["de"]="Glutschild"},["itemId"]=5832},[159]={["name"]={["fr"]="Scindeflamme",["en"]="Sunderflame",["de"]="Trennflamme"},["itemId"]=5831},[160]={["name"]={["fr"]="Le Tramesort ardent",["en"]="Burning Spellweave",["de"]="Branntzauberweber"},["itemId"]=23710},[161]={["name"]={["fr"]="Étoile gémellaire",["en"]="Twice-Born Star",["de"]="Doppelstern"},["itemId"]=58153},[162]={["name"]={["fr"]="L’Engeance de Méphala",["en"]="Spawn of Mephala",["de"]="Mephalas Brut"},["itemId"]=59380},[163]={["name"]={["fr"]="L’Engeance de sang",["en"]="Bloodspawn",["de"]="Die Blutbrut"},["itemId"]=59416},[164]={["name"]={["fr"]="Le Seigneur gardien",["en"]="Lord Warden",["de"]="Hochwärter"},["itemId"]=59452},[165]={["name"]={["fr"]="Moissonneur calamiteux",["en"]="Scourge Harvester",["de"]="Geißelernter"},["itemId"]=59488},[166]={["name"]={["fr"]="Le Gardien du moteur",["en"]="Engine Guardian",["de"]="Maschinenwächter"},["itemId"]=59524},[167]={["name"]={["fr"]="La Nocteflamme",["en"]="Nightflame",["de"]="Nachtflamme"},["itemId"]=59560},[168]={["name"]={["fr"]="Nérien'eth",["en"]="Nerien'eth",["de"]="Nerien'eth"},["itemId"]=59596},[169]={["name"]={["fr"]="Valkyn Skoria",["en"]="Valkyn Skoria",["de"]="Valkyn Skoria"},["itemId"]=59632},[170]={["name"]={["fr"]="Gueule de l'Infernal",["en"]="Maw of the Infernal",["de"]="Schlund des Infernalen"},["itemId"]=59668},[171]={["name"]={["fr"]="L’Éternel Guerrier",["en"]="Eternal Warrior",["de"]="Ewiger Krieger"},["itemId"]=59738},[172]={["name"]={["fr"]="L’Infaillible Mage",["en"]="Infallible Mage",["de"]="Unfehlbare Magierin"},["itemId"]=59752},[173]={["name"]={["fr"]="Le Cruel Serpent",["en"]="Vicious Serpent",["de"]="Boshafte Schlange"},["itemId"]=59745},[176]={["name"]={["fr"]="Le Butin du noble",["en"]="Noble's Conquest",["de"]="Adelssieg"},["itemId"]=59946},[177]={["name"]={["fr"]="Redistributeur",["en"]="Redistributor",["de"]="Umverteilung"},["itemId"]=60296},[178]={["name"]={["fr"]="Maître armurier",["en"]="Armor Master",["de"]="Rüstungsmeister"},["itemId"]=60646},[179]={["name"]={["fr"]="La Rose noire",["en"]="Black Rose",["de"]="Schwarze Rose"},["itemId"]=68432},[180]={["name"]={["fr"]="L’Assaut puissant",["en"]="Powerful Assault",["de"]="Kraftvoller Ansturm"},["itemId"]=68535},[181]={["name"]={["fr"]="Service émérite",["en"]="Meritorious Service",["de"]="Meritorischer Dienst"},["itemId"]=68615},[183]={["name"]={["fr"]="Molag Kena",["en"]="Molag Kena",["de"]="Molag Kena"},["itemId"]=68107},[184]={["name"]={["fr"]="Fers d'Imperium",["en"]="Brands of Imperium",["de"]="Male des Kaiserreichs"},["itemId"]=64760},[185]={["name"]={["fr"]="Puissance curative",["en"]="Spell Power Cure",["de"]="Magiekraftheilung"},["itemId"]=66167},[186]={["name"]={["fr"]="Armes de la décharge",["en"]="Jolting Arms",["de"]="Rüttelnde Rüstung"},["itemId"]=33167},[187]={["name"]={["fr"]="Pilleur du marais",["en"]="Swamp Raider",["de"]="Sumpfräuber"},["itemId"]=7476},[188]={["name"]={["fr"]="La Maîtrise de la tempête",["en"]="Storm Master",["de"]="Sturmmeister"},["itemId"]=33276},[190]={["name"]={["fr"]="Mage brûlant",["en"]="Scathing Mage",["de"]="Verletzender Magier"},["itemId"]=67567},[193]={["name"]={["fr"]="Élan de Suprématie",["en"]="Overwhelming Surge",["de"]="Überwältigende Woge"},["itemId"]=33176},[194]={["name"]={["fr"]="Médecin de terrain",["en"]="Combat Physician",["de"]="Feldarzt"},["itemId"]=16219},[195]={["name"]={["fr"]="Venin absolu",["en"]="Sheer Venom",["de"]="Reingift"},["itemId"]=67015},[196]={["name"]={["fr"]="Plaque sangsue",["en"]="Leeching Plate",["de"]="Auslaugende Rüstung"},["itemId"]=66440},[197]={["name"]={["fr"]="Tortionnaire",["en"]="Tormentor",["de"]="Quälender"},["itemId"]=28112},[198]={["name"]={["fr"]="Voleur d'essence",["en"]="Essence Thief",["de"]="Essenzdieb"},["itemId"]=65335},[199]={["name"]={["fr"]="Brise-bouclier",["en"]="Shield Breaker",["de"]="Schildbrecher"},["itemId"]=68711},[200]={["name"]={["fr"]="Phénix",["en"]="Phoenix",["de"]="Phönix"},["itemId"]=68791},[201]={["name"]={["fr"]="Armure réactive",["en"]="Reactive Armor",["de"]="Reaktive Rüstung"},["itemId"]=68872},[204]={["name"]={["fr"]="Endurance",["en"]="Endurance",["de"]="Beständigkeit"},["itemId"]=55963},[205]={["name"]={["fr"]="Volonté",["en"]="Willpower",["de"]="Willenskraft"},["itemId"]=64488},[206]={["name"]={["fr"]="Agilité",["en"]="Agility",["de"]="Agilität"},["itemId"]=69281},[207]={["name"]={["fr"]="Loi de Julianos",["en"]="Law of Julianos",["de"]="Gesetz von Julianos"},["itemId"]=69577},[208]={["name"]={["fr"]="Épreuve du feu",["en"]="Trial by Fire",["de"]="Feuertaufe"},["itemId"]=69927},[209]={["name"]={["fr"]="Armor of the Code",["en"]="Armor of the Code",["de"]="Armor of the Code"},["itemId"]=137543},[210]={["name"]={["fr"]="La Marque du Paria",["en"]="Mark of the Pariah",["de"]="Zeichen des Ausgestoßenen"},["itemId"]=68608},[211]={["name"]={["fr"]="Le Permafrost",["en"]="Permafrost",["de"]="Permafrost"},["itemId"]=68784},[212]={["name"]={["fr"]="Roncecœur",["en"]="Briarheart",["de"]="Dornenherz"},["itemId"]=68447},[213]={["name"]={["fr"]="Défense glorieuse",["en"]="Glorious Defender",["de"]="Ruhmreicher Verteidiger"},["itemId"]=68696},[214]={["name"]={["fr"]="Para Bellum",["en"]="Para Bellum",["de"]="Para Bellum"},["itemId"]=68623},[215]={["name"]={["fr"]="Successsion élémentaire",["en"]="Elemental Succession",["de"]="Elementarfolge"},["itemId"]=68703},[216]={["name"]={["fr"]="Le Chef de la Chasse",["en"]="Hunt Leader",["de"]="Jagdleiter"},["itemId"]=68799},[217]={["name"]={["fr"]="Nédhiver",["en"]="Winterborn",["de"]="Winterkind"},["itemId"]=68527},[218]={["name"]={["fr"]="La Valeur de Trinimac",["en"]="Trinimac's Valor",["de"]="Trinimacs Heldenmut"},["itemId"]=68439},[219]={["name"]={["fr"]="Morkuldin",["en"]="Morkuldin",["de"]="Morkuldin"},["itemId"]=70627},[224]={["name"]={["fr"]="Faveur de Tava",["en"]="Tava's Favor",["de"]="Tavas Gunst"},["itemId"]=71791},[225]={["name"]={["fr"]="Alchimiste astucieux",["en"]="Clever Alchemist",["de"]="Schlauer Alchemist"},["itemId"]=72141},[226]={["name"]={["fr"]="Chasse éternelle",["en"]="Eternal Hunt",["de"]="Ewige Jagd"},["itemId"]=72491},[227]={["name"]={["fr"]="Malédiction de Bahraha",["en"]="Bahraha's Curse",["de"]="Bahrahas Fluch"},["itemId"]=72841},[228]={["name"]={["fr"]="Les Écailles de Syvarra",["en"]="Syvarra's Scales",["de"]="Syvarras Schuppen"},["itemId"]=72913},[229]={["name"]={["fr"]="Le Remède du crépuscule",["en"]="Twilight Remedy",["de"]="Zwielichtgenesung"},["itemId"]=73011},[230]={["name"]={["fr"]="Danselune",["en"]="Moondancer",["de"]="Mondtänzer"},["itemId"]=72985},[231]={["name"]={["fr"]="Bastion lunaire",["en"]="Lunar Bastion",["de"]="Mondbastion"},["itemId"]=73060},[232]={["name"]={["fr"]="Le Rugissement d'Alkosh",["en"]="Roar of Alkosh",["de"]="Brüllen von Alkosh"},["itemId"]=73037},[234]={["name"]={["fr"]="Emblème du tireur d'élite",["en"]="Marksman's Crest",["de"]="Wappen des Meisterschützen"},["itemId"]=73873},[235]={["name"]={["fr"]="Robes de transmutation",["en"]="Robes of Transmutation",["de"]="Roben der Transmutation"},["itemId"]=74222},[236]={["name"]={["fr"]="Mort cruelle",["en"]="Vicious Death",["de"]="Grausamer Tod"},["itemId"]=74149},[237]={["name"]={["fr"]="Focalisation de Léki",["en"]="Leki's Focus",["de"]="Lekis Fokus"},["itemId"]=73935},[238]={["name"]={["fr"]="Perfidie de Fasalla",["en"]="Fasalla's Guile",["de"]="Fasallas List"},["itemId"]=73997},[239]={["name"]={["fr"]="Furie du Guerrier",["en"]="Warrior's Fury",["de"]="Raserei des Kriegers"},["itemId"]=74080},[240]={["name"]={["fr"]="Le gladiateur de Kvatch",["en"]="Kvatch Gladiator",["de"]="Gladiator von Kvatch"},["itemId"]=75386},[241]={["name"]={["fr"]="L’Héritage de Varen",["en"]="Varen's Legacy",["de"]="Varens Erbe"},["itemId"]=75736},[242]={["name"]={["fr"]="L’Aptitude de Pélinal",["en"]="Pelinal's Aptitude",["de"]="Pelinals Talent"},["itemId"]=76086},[243]={["name"]={["fr"]="La Peau de Morihaus",["en"]="Hide of Morihaus",["de"]="Haut von Morihaus"},["itemId"]=76916},[244]={["name"]={["fr"]="Le Stratège du débordement",["en"]="Flanking Strategist",["de"]="Flankierender Stratege"},["itemId"]=77076},[245]={["name"]={["fr"]="La Caresse de Sithis",["en"]="Sithis' Touch",["de"]="Sithis' Berührung"},["itemId"]=77236},[246]={["name"]={["fr"]="La vengeance de Galérion",["en"]="Galerion's Revenge",["de"]="Galerions Revanche"},["itemId"]=78048},[247]={["name"]={["fr"]="Le vice-chanoine du venin",["en"]="Vicecanon of Venom",["de"]="Vizekanoniker des Gifts"},["itemId"]=78328},[248]={["name"]={["fr"]="Les muscles du héraut",["en"]="Thews of the Harbinger",["de"]="Muskeln des Vorboten"},["itemId"]=78608},[253]={["name"]={["fr"]="Le physique impérial",["en"]="Imperial Physique",["de"]="Kaiserliche Physis"},["itemId"]=78906},[256]={["name"]={["fr"]="Gros Chudan",["en"]="Mighty Chudan",["de"]="Mächtiger Chudan"},["itemId"]=82176},[257]={["name"]={["fr"]="Velidreth",["en"]="Velidreth",["de"]="Velidreth"},["itemId"]=82128},[258]={["name"]={["fr"]="Plasme ambré",["en"]="Amber Plasm",["de"]="Bernsteinplasma"},["itemId"]=82411},[259]={["name"]={["fr"]="Châtiment d'Heem-Jas",["en"]="Heem-Jas' Retribution",["de"]="Heem-Jas' Vergeltung"},["itemId"]=82602},[260]={["name"]={["fr"]="Aspect de Mazzatun",["en"]="Aspect of Mazzatun",["de"]="Aspekt von Mazzatun"},["itemId"]=82229},[261]={["name"]={["fr"]="Diaphane",["en"]="Gossamer",["de"]="Gespinst"},["itemId"]=82966},[262]={["name"]={["fr"]="Deuil",["en"]="Widowmaker",["de"]="Witwenmacher"},["itemId"]=83157},[263]={["name"]={["fr"]="Main de Méphala",["en"]="Hand of Mephala",["de"]="Hand von Mephala"},["itemId"]=82784},[264]={["name"]={["fr"]="Araignée géante",["en"]="Giant Spider",["de"]="Riesenspinne"},["itemId"]=94452},[265]={["name"]={["fr"]="Taillombre",["en"]="Shadowrend",["de"]="Schattenriss"},["itemId"]=94460},[266]={["name"]={["fr"]="Kra'gh",["en"]="Kra'gh",["de"]="Kra'gh"},["itemId"]=94468},[267]={["name"]={["fr"]="La Mère de la nuée",["en"]="Swarm Mother",["de"]="Schwarmmutter"},["itemId"]=94476},[268]={["name"]={["fr"]="La sentinelle de Rkugamz",["en"]="Sentinel of Rkugamz",["de"]="Wachposten von Rkugamz"},["itemId"]=94484},[269]={["name"]={["fr"]="La Ronce étouffeuse",["en"]="Chokethorn",["de"]="Würgedorn"},["itemId"]=94492},[270]={["name"]={["fr"]="Rampefange",["en"]="Slimecraw",["de"]="Schleimkropf"},["itemId"]=94500},[271]={["name"]={["fr"]="Sellistrix",["en"]="Sellistrix",["de"]="Sellistrix"},["itemId"]=94508},[272]={["name"]={["fr"]="Gardien infernal",["en"]="Infernal Guardian",["de"]="Infernaler Wächter"},["itemId"]=94516},[273]={["name"]={["fr"]="Ilambris",["en"]="Ilambris",["de"]="Ilambris"},["itemId"]=94524},[274]={["name"]={["fr"]="Cœur-de-glace",["en"]="Iceheart",["de"]="Eisherz"},["itemId"]=94532},[275]={["name"]={["fr"]="Poigne-tempête",["en"]="Stormfist",["de"]="Sturmfaust"},["itemId"]=94540},[276]={["name"]={["fr"]="Tremblécaille",["en"]="Tremorscale",["de"]="Bebenschuppe"},["itemId"]=94548},[277]={["name"]={["fr"]="Pirate squelettique",["en"]="Pirate Skeleton",["de"]="Piratenskelett"},["itemId"]=94556},[278]={["name"]={["fr"]="Le roi des Trolls",["en"]="The Troll King",["de"]="Trollkönig"},["itemId"]=94564},[279]={["name"]={["fr"]="Sélène",["en"]="Selene",["de"]="Selene"},["itemId"]=94572},[280]={["name"]={["fr"]="Grothdarr",["en"]="Grothdarr",["de"]="Grothdarr"},["itemId"]=94580},[281]={["name"]={["fr"]="Armure du débutant",["en"]="Armor of the Trainee",["de"]="Rüstung des Auszubildenden"},["itemId"]=1115},[282]={["name"]={["fr"]="Cape du vampire",["en"]="Vampire Cloak",["de"]="Vampirumhang"},["itemId"]=7294},[283]={["name"]={["fr"]="Chante-épée",["en"]="Sword-Singer",["de"]="Schwertsänger"},["itemId"]=7508},[284]={["name"]={["fr"]="Ordre de Diagna",["en"]="Order of Diagna",["de"]="Orden von Diagna"},["itemId"]=7520},[285]={["name"]={["fr"]="Seigneur vampire",["en"]="Vampire Lord",["de"]="Vampirfürst"},["itemId"]=15599},[286]={["name"]={["fr"]="Ronces du spriggan",["en"]="Spriggan's Thorns",["de"]="Dornen des Zweiglings"},["itemId"]=15594},[287]={["name"]={["fr"]="Le Pacte Vert",["en"]="Green Pact",["de"]="Der Grüne Pakt"},["itemId"]=1674},[288]={["name"]={["fr"]="Harnachement de l'apiculteur",["en"]="Beekeeper's Gear",["de"]="Werkzeug des Bienenhüters"},["itemId"]=10848},[289]={["name"]={["fr"]="Tenue du trameur",["en"]="Spinner's Garments",["de"]="Gewänder des Webers"},["itemId"]=15524},[290]={["name"]={["fr"]="Traficant de skouma",["en"]="Skooma Smuggler",["de"]="Skoomaschmuggler"},["itemId"]=10921},[291]={["name"]={["fr"]="Exosquelette de shalk",["en"]="Shalk Exoskeleton",["de"]="Schröterpanzer"},["itemId"]=6900},[292]={["name"]={["fr"]="Chagrin maternel",["en"]="Mother's Sorrow",["de"]="Muttertränen"},["itemId"]=4308},[293]={["name"]={["fr"]="Médecin de la peste",["en"]="Plague Doctor",["de"]="Seuchendoktor"},["itemId"]=4305},[294]={["name"]={["fr"]="Héritage d'Ysgramor",["en"]="Ysgramor's Birthright",["de"]="Ysgramors Geburtsrecht"},["itemId"]=10150},[295]={["name"]={["fr"]="L’Évasion",["en"]="Jailbreaker",["de"]="Ausbrecher"},["itemId"]=29071},[296]={["name"]={["fr"]="Spéléologue",["en"]="Spelunker",["de"]="Höhlenforscher"},["itemId"]=29097},[297]={["name"]={["fr"]="Capuchon de l'adepte de l'Araignée",["en"]="Spider Cultist Cowl",["de"]="Spinnenkultistenkutte"},["itemId"]=28122},[298]={["name"]={["fr"]="Orateur lumineux",["en"]="Light Speaker",["de"]="Lichtsprecher"},["itemId"]=15546},[299]={["name"]={["fr"]="La Rangée de dents",["en"]="Toothrow",["de"]="Zahnreihe"},["itemId"]=7666},[300]={["name"]={["fr"]="Toucher du netch",["en"]="Netch's Touch",["de"]="Berührung des Netch"},["itemId"]=15679},[301]={["name"]={["fr"]="Force de l'automate",["en"]="Strength of the Automaton",["de"]="Stärke des Automaten"},["itemId"]=5921},[302]={["name"]={["fr"]="Le Léviathan",["en"]="Leviathan",["de"]="Leviathan"},["itemId"]=16042},[303]={["name"]={["fr"]="Chant de la Lamie",["en"]="Lamia's Song",["de"]="Lied der Lamie"},["itemId"]=16046},[304]={["name"]={["fr"]="La Méduse",["en"]="Medusa",["de"]="Versteinernder Blick"},["itemId"]=16044},[305]={["name"]={["fr"]="Le chasseur de trésors",["en"]="Treasure Hunter",["de"]="Schatzjäger"},["itemId"]=33153},[307]={["name"]={["fr"]="Le Draugr colossal",["en"]="Draugr Hulk",["de"]="Schwerfälliger Draugr"},["itemId"]=33283},[308]={["name"]={["fr"]="Haillons du pirate squelettique",["en"]="Bone Pirate's Tatters",["de"]="Lumpen des Knochenpiraten"},["itemId"]=22156},[309]={["name"]={["fr"]="Maille du Chevalier errant",["en"]="Knight-errant's Mail",["de"]="Platten des Wanderritters"},["itemId"]=22196},[310]={["name"]={["fr"]="La Danse des épées",["en"]="Sword Dancer",["de"]="Schwerttänzer"},["itemId"]=22169},[311]={["name"]={["fr"]="Le Provocateur",["en"]="Rattlecage",["de"]="Klapperkäfig"},["itemId"]=44728},[313]={["name"]={["fr"]="Le Fendoir tinanesque",["en"]="Titanic Cleave",["de"]="Titanisches Trennen"},["itemId"]=55934},[314]={["name"]={["fr"]="Le Remède perforant",["en"]="Puncturing Remedy",["de"]="Durchschlagende Genesung"},["itemId"]=55935},[315]={["name"]={["fr"]="Entailles cuisantes",["en"]="Stinging Slashes",["de"]="Stechende Schnitte"},["itemId"]=55936},[316]={["name"]={["fr"]="Flèche caustique",["en"]="Caustic Arrow",["de"]="Beißender Pfeil"},["itemId"]=55937},[317]={["name"]={["fr"]="Impact destructeur",["en"]="Destructive Impact",["de"]="Zerstörerischer Einschlag"},["itemId"]=55938},[318]={["name"]={["fr"]="Grand Rajeunissement",["en"]="Grand Rejuvenation",["de"]="Große Verjüngung"},["itemId"]=55939},[320]={["name"]={["fr"]="La Vierge guerrière",["en"]="War Maiden",["de"]="Kriegsjungfer"},["itemId"]=122792},[321]={["name"]={["fr"]="Profanateur",["en"]="Defiler",["de"]="Schänder"},["itemId"]=122983},[322]={["name"]={["fr"]="Le Guerrier-Poète",["en"]="Warrior-Poet",["de"]="Kriegerpoet"},["itemId"]=122610},[323]={["name"]={["fr"]="La Duplicité de l'assassin",["en"]="Assassin's Guile",["de"]="Assassinenlist"},["itemId"]=121551},[324]={["name"]={["fr"]="La Tromperie daedrique",["en"]="Daedric Trickery",["de"]="Daedrische Gaunerei"},["itemId"]=121901},[325]={["name"]={["fr"]="Le Brise-entraves",["en"]="Shacklebreaker",["de"]="Kettensprenger"},["itemId"]=122251},[326]={["name"]={["fr"]="Défi de l'avant-garde",["en"]="Vanguard's Challenge",["de"]="Vorhutdisput"},["itemId"]=123166},[327]={["name"]={["fr"]="Barda du couard",["en"]="Coward's Gear",["de"]="Feiglingstracht"},["itemId"]=123348},[328]={["name"]={["fr"]="Tueur de chevalier",["en"]="Knight Slayer",["de"]="Ritterschlächter"},["itemId"]=123530},[329]={["name"]={["fr"]="Riposte du sorcier",["en"]="Wizard's Riposte",["de"]="Zaubererreplik"},["itemId"]=123721},[330]={["name"]={["fr"]="La Défense automatique",["en"]="Automated Defense",["de"]="Automatisierte Verteidigung"},["itemId"]=123912},[331]={["name"]={["fr"]="La machine de guerre",["en"]="War Machine",["de"]="Kriegsmaschine"},["itemId"]=124094},[332]={["name"]={["fr"]="Le maître architecte",["en"]="Master Architect",["de"]="Meisterarchitekt"},["itemId"]=124276},[333]={["name"]={["fr"]="La Garde de l'inventeur",["en"]="Inventor's Guard",["de"]="Erfindergarde"},["itemId"]=124467},[334]={["name"]={["fr"]="Armure imprenable",["en"]="Impregnable Armor",["de"]="Unüberwindliche Rüstung"},["itemId"]=125689},[335]={["name"]={["fr"]="Le Repos du Draugr",["en"]="Draugr's Rest",["de"]="Draugrruhe"},["itemId"]=127332},[336]={["name"]={["fr"]="Pilier de Nirn",["en"]="Pillar of Nirn",["de"]="Säulen von Nirn"},["itemId"]=127523},[337]={["name"]={["fr"]="Sang de fer",["en"]="Ironblood",["de"]="Eisenblut"},["itemId"]=127150},[338]={["name"]={["fr"]="Fleur de feu",["en"]="Flame Blossom",["de"]="Flammenblüte"},["itemId"]=127935},[339]={["name"]={["fr"]="La Buveur de sang",["en"]="Blooddrinker",["de"]="Bluttrinker"},["itemId"]=128126},[340]={["name"]={["fr"]="Jardin de la harfreuse",["en"]="Hagraven's Garden",["de"]="Vettelgarten"},["itemId"]=127753},[341]={["name"]={["fr"]="Sangreterre",["en"]="Earthgore",["de"]="Erdbluter"},["itemId"]=127705},[342]={["name"]={["fr"]="Domihaus",["en"]="Domihaus",["de"]="Domihaus"},["itemId"]=128308},[343]={["name"]={["fr"]="L’Héritage de Caluurion",["en"]="Caluurion's Legacy",["de"]="Caluurions Erbe"},["itemId"]=128554},[344]={["name"]={["fr"]="Apparence de vivification",["en"]="Trappings of Invigoration",["de"]="Stärkungsprunk"},["itemId"]=128745},[345]={["name"]={["fr"]="La Faveur d'Ulfnor",["en"]="Ulfnor's Favor",["de"]="Ulfnors Gunst"},["itemId"]=128372},[346]={["name"]={["fr"]="Le Conseil de Jorvuld",["en"]="Jorvuld's Guidance",["de"]="Jorvulds Führung"},["itemId"]=129109},[347]={["name"]={["fr"]="Lance-peste",["en"]="Plague Slinger",["de"]="Seuchenschleuder"},["itemId"]=129300},[348]={["name"]={["fr"]="La Malédiction de Doylemish",["en"]="Curse of Doylemish",["de"]="Fluch von Doylemish"},["itemId"]=128927},[349]={["name"]={["fr"]="Thurvokun",["en"]="Thurvokun",["de"]="Thurvokun"},["itemId"]=129482},[350]={["name"]={["fr"]="Zaan",["en"]="Zaan",["de"]="Zaan"},["itemId"]=129530},[351]={["name"]={["fr"]="Axiome inné",["en"]="Innate Axiom",["de"]="Kernaxiom"},["itemId"]=130370},[352]={["name"]={["fr"]="Airain fortifié",["en"]="Fortified Brass",["de"]="Messingpanzer"},["itemId"]=130720},[353]={["name"]={["fr"]="Acuité mécanique",["en"]="Mechanical Acuity",["de"]="Mechanikblick"},["itemId"]=131070},[354]={["name"]={["fr"]="Bricoleur fou",["en"]="Mad Tinkerer",["de"]="Wahntüftler"},["itemId"]=132848},[355]={["name"]={["fr"]="Ténèbres insondables",["en"]="Unfathomable Darkness",["de"]="Unermessliche Dunkelheit"},["itemId"]=133039},[356]={["name"]={["fr"]="Haute tension",["en"]="Livewire",["de"]="Stromschlag"},["itemId"]=132666},[357]={["name"]={["fr"]="Entaille disciplinée (perfectionnée)",["en"]="Disciplined Slash (Perfected)",["de"]="Disziplinierter Schnitt (vollendet)"},["itemId"]=133251},[358]={["name"]={["fr"]="Position défensive (perfectionnée)",["en"]="Defensive Position (Perfected)",["de"]="Defensive Position (vollendet)"},["itemId"]=133243},[359]={["name"]={["fr"]="Tourbillon chaotique (perfectionné)",["en"]="Chaotic Whirlwind (Perfected)",["de"]="Chaotischer Wirbelwind (vollendet)"},["itemId"]=133247},[360]={["name"]={["fr"]="Jaillissement perforant (perfectionné)",["en"]="Piercing Spray (Perfected)",["de"]="Durchdringende Salve (vollendet)"},["itemId"]=133254},[361]={["name"]={["fr"]="Force concentrée (perfectionnée)",["en"]="Concentrated Force (Perfected)",["de"]="Konzentrierte Kraft (vollendet)"},["itemId"]=133255},[362]={["name"]={["fr"]="Bénédiction intemporelle (perfectionnée)",["en"]="Timeless Blessing (Perfected)",["de"]="Zeitloser Segen (vollendet)"},["itemId"]=133258},[363]={["name"]={["fr"]="Entaille disciplinée",["en"]="Disciplined Slash",["de"]="Disziplinierter Schnitt"},["itemId"]=133404},[364]={["name"]={["fr"]="Position défensive",["en"]="Defensive Position",["de"]="Defensive Position"},["itemId"]=133396},[365]={["name"]={["fr"]="Tourbillon chaotique",["en"]="Chaotic Whirlwind",["de"]="Chaotischer Wirbelwind"},["itemId"]=133400},[366]={["name"]={["fr"]="Jaillissement perforant",["en"]="Piercing Spray",["de"]="Durchdringende Salve"},["itemId"]=133407},[367]={["name"]={["fr"]="Force concentrée",["en"]="Concentrated Force",["de"]="Konzentrierte Kraft"},["itemId"]=133408},[368]={["name"]={["fr"]="Bénédiction intemporelle",["en"]="Timeless Blessing",["de"]="Zeitloser Segen"},["itemId"]=133411},[369]={["name"]={["fr"]="La Charge impitoyable",["en"]="Merciless Charge",["de"]="Gnadenloser Ansturm"},["itemId"]=71118},[370]={["name"]={["fr"]="L’Entaille ravageuse",["en"]="Rampaging Slash",["de"]="Tobender Schnitt"},["itemId"]=71106},[371]={["name"]={["fr"]="Le Déluge cruel",["en"]="Cruel Flurry",["de"]="Grausamer Schlaghagel"},["itemId"]=71100},[372]={["name"]={["fr"]="La Volée tonitruante",["en"]="Thunderous Volley",["de"]="Donnernde Salve"},["itemId"]=71142},[373]={["name"]={["fr"]="Le Mur écrasant",["en"]="Crushing Wall",["de"]="Zermalmende Mauer"},["itemId"]=71152},[374]={["name"]={["fr"]="La Régénération précise",["en"]="Precise Regeneration",["de"]="Präzise Regeneration"},["itemId"]=71170},[380]={["name"]={["fr"]="L’Ensemble du Prophète",["en"]="Prophet's",["de"]="Prophet"},["itemId"]=134799},[381]={["name"]={["fr"]="L’Âme brisée",["en"]="Broken Soul",["de"]="Zerbrochene Seele"},["itemId"]=134955},[382]={["name"]={["fr"]="Gracieuse mélancolie",["en"]="Grace of Gloom",["de"]="Anmut der Gräue"},["itemId"]=134692},[383]={["name"]={["fr"]="Férocité du griffon",["en"]="Gryphon's Ferocity",["de"]="Wildheit des Greifen"},["itemId"]=134701},[384]={["name"]={["fr"]="La Sagesse de Vanus",["en"]="Wisdom of Vanus",["de"]="Weisheit von Vanus"},["itemId"]=134696},[385]={["name"]={["fr"]="L’Adepte cavalier",["en"]="Adept Rider",["de"]="Versierter Reiter"},["itemId"]=135717},[386]={["name"]={["fr"]="L’Aspect du Sload",["en"]="Sload's Semblance",["de"]="Kreckenantlitz"},["itemId"]=136067},[387]={["name"]={["fr"]="Faveur de Nocturne",["en"]="Nocturnal's Favor",["de"]="Nocturnals Gunst"},["itemId"]=136417},[388]={["name"]={["fr"]="Égide de Galenwe",["en"]="Aegis of Galenwe",["de"]="Ägis von Galenwe"},["itemId"]=136767},[389]={["name"]={["fr"]="Armes de Relequen",["en"]="Arms of Relequen",["de"]="Waffen von Relequen"},["itemId"]=136949},[390]={["name"]={["fr"]="Manteau de Siroria",["en"]="Mantle of Siroria",["de"]="Mantel von Siroria"},["itemId"]=137131},[391]={["name"]={["fr"]="Vêture d'Olorimë",["en"]="Vestment of Olorime",["de"]="Gewandung von Olorime"},["itemId"]=137322},[392]={["name"]={["fr"]="Égide parfaite de Galenwe",["en"]="Perfect Aegis of Galenwe",["de"]="Perfekte Ägis von Galenwe"},["itemId"]=137964},[393]={["name"]={["fr"]="Armes parfaites de Relequen",["en"]="Perfect Arms of Relequen",["de"]="Perfekte Waffen von Relequen"},["itemId"]=138146},[394]={["name"]={["fr"]="Manteau parfait de Siroria",["en"]="Perfect Mantle of Siroria",["de"]="Perfekter Mantel von Siroria"},["itemId"]=138328},[395]={["name"]={["fr"]="La vêture parfaite d'Olorimë",["en"]="Perfect Vestment of Olorime",["de"]="Perfekte Gewandung von Olorime"},["itemId"]=138519},[397]={["name"]={["fr"]="Balorgh",["en"]="Balorgh",["de"]="Balorgh"},["itemId"]=141622},[398]={["name"]={["fr"]="Vykosa",["en"]="Vykosa",["de"]="Vykosa"},["itemId"]=141670},[399]={["name"]={["fr"]="La Compassion de Hanu",["en"]="Hanu's Compassion",["de"]="Hanus Mitgefühl"},["itemId"]=140694},[400]={["name"]={["fr"]="La Lune de sang",["en"]="Blood Moon",["de"]="Blutmond"},["itemId"]=140885},[401]={["name"]={["fr"]="Le Havre d'Ursus",["en"]="Haven of Ursus",["de"]="Zuflucht von Ursus"},["itemId"]=140512},[402]={["name"]={["fr"]="Le Chasseur lunaire",["en"]="Moon Hunter",["de"]="Mondjäger"},["itemId"]=141249},[403]={["name"]={["fr"]="Le Loup-garou sauvage",["en"]="Savage Werewolf",["de"]="Wilder Werwolf"},["itemId"]=141440},[404]={["name"]={["fr"]="La Ténacité du Geôlier",["en"]="Jailer's Tenacity",["de"]="Tenazität des Kerkermeisters"},["itemId"]=141067},[405]={["name"]={["fr"]="La Vantardise de Vive-Gorge",["en"]="Bright-Throat's Boast",["de"]="Hellhalsstolz"},["itemId"]=142600},[406]={["name"]={["fr"]="La Duplicité d'Aiguemortes",["en"]="Dead-Water's Guile",["de"]="Totwassertücke"},["itemId"]=142418},[407]={["name"]={["fr"]="Le Champion de l'Hist",["en"]="Champion of the Hist",["de"]="Histchampion"},["itemId"]=142236},[408]={["name"]={["fr"]="Collectionneur de marqueurs funéraires",["en"]="Grave-Stake Collector",["de"]="Grabpflocksammler"},["itemId"]=142791},[409]={["name"]={["fr"]="Le Chaman Naga",["en"]="Naga Shaman",["de"]="Nagaschamane"},["itemId"]=143161},[410]={["name"]={["fr"]="La Puissance de la Légion perdue",["en"]="Might of the Lost Legion",["de"]="Macht der Verlorenen Legion"},["itemId"]=143531},[411]={["name"]={["fr"]="Charge vaillante",["en"]="Gallant Charge",["de"]="Galanter Ansturm"},["itemId"]=145011},[412]={["name"]={["fr"]="Uppercut radial",["en"]="Radial Uppercut",["de"]="Rundum-Aufwärtsschnitt"},["itemId"]=145019},[413]={["name"]={["fr"]="Cape spectrale",["en"]="Spectral Cloak",["de"]="Spektraler Mantel"},["itemId"]=145015},[414]={["name"]={["fr"]="Tir virulent",["en"]="Virulent Shot",["de"]="Virulenter Schuss"},["itemId"]=145022},[415]={["name"]={["fr"]="Impulsion sauvage",["en"]="Wild Impulse",["de"]="Wilder Impuls"},["itemId"]=145023},[416]={["name"]={["fr"]="Garde du soigneur",["en"]="Mender's Ward",["de"]="Schutz des Pflegers"},["itemId"]=145026},[417]={["name"]={["fr"]="Fureur indomptable",["en"]="Indomitable Fury",["de"]="Unbeugsamer Zorn"},["itemId"]=143901},[418]={["name"]={["fr"]="Stratège des sorts",["en"]="Spell Strategist",["de"]="Zauberstratege"},["itemId"]=144092},[419]={["name"]={["fr"]="Acrobate du champ de bataille",["en"]="Battlefield Acrobat",["de"]="Schlachtfeldakrobat"},["itemId"]=144283},[420]={["name"]={["fr"]="Soldat de l'angoisse",["en"]="Soldier of Anguish",["de"]="Soldat der Pein"},["itemId"]=144465},[421]={["name"]={["fr"]="Héros inébranlable",["en"]="Steadfast Hero",["de"]="Standhafter Held"},["itemId"]=144647},[422]={["name"]={["fr"]="Défense du bataillon",["en"]="Battalion Defender",["de"]="Bataillonsverteidiger"},["itemId"]=144829},[423]={["name"]={["fr"]="Charge galante parfaite",["en"]="Perfect Gallant Charge",["de"]="Perfekter galanter Ansturm"},["itemId"]=145164},[424]={["name"]={["fr"]="Uppercut radial parfait",["en"]="Perfect Radial Uppercut",["de"]="Perfekter Rundum-Aufwärtsschnitt"},["itemId"]=145172},[425]={["name"]={["fr"]="Cape spectrale parfaite",["en"]="Perfect Spectral Cloak",["de"]="Perfekter spektraler Mantel"},["itemId"]=145168},[426]={["name"]={["fr"]="Tir virulent parfait",["en"]="Perfect Virulent Shot",["de"]="Perfekter virulenter Schuss"},["itemId"]=145175},[427]={["name"]={["fr"]="Impulsion sauvage parfaite",["en"]="Perfect Wild Impulse",["de"]="Perfekter wilder Impuls"},["itemId"]=145176},[428]={["name"]={["fr"]="Garde du guérisseur parfaite",["en"]="Perfect Mender's Ward",["de"]="Perfekter Schutz des Pflegers"},["itemId"]=145179},[429]={["name"]={["fr"]="Le Puissant glacier",["en"]="Mighty Glacier",["de"]="Mächtiger Gletscher"},["itemId"]=146077},[430]={["name"]={["fr"]="La Bande de guerre de Tzogvin",["en"]="Tzogvin's Warband",["de"]="Tzogvins Kriegstrupp"},["itemId"]=146259},[431]={["name"]={["fr"]="L’Invocateur glacial",["en"]="Icy Conjuror",["de"]="Eisiger Anrufer"},["itemId"]=146441},[432]={["name"]={["fr"]="Le Gardien des pierres",["en"]="Stonekeeper",["de"]="Steinwahrer"},["itemId"]=146632},[433]={["name"]={["fr"]="L’Observateur glacial",["en"]="Frozen Watcher",["de"]="Gefrorener Beobachter"},["itemId"]=146680},[434]={["name"]={["fr"]="Le Trépas des récupérateurs",["en"]="Scavenging Demise",["de"]="Ausbeutender Niedergang"},["itemId"]=146862},[435]={["name"]={["fr"]="Le Tonnerre aurorien",["en"]="Auroran's Thunder",["de"]="Donner des Auroraners"},["itemId"]=147044},[436]={["name"]={["fr"]="La Symphonie des Lames",["en"]="Symphony of Blades",["de"]="Sinfonie der Klingen"},["itemId"]=147235},[437]={["name"]={["fr"]="Élu de Havreglace",["en"]="Coldharbour's Favorite",["de"]="Kalthafens Günstling"},["itemId"]=147948},[438]={["name"]={["fr"]="La Détermination du Senche-raht",["en"]="Senche-raht's Grit",["de"]="Mut des Senche-raht"},["itemId"]=148318},[439]={["name"]={["fr"]="La Tutelle de Vastarië",["en"]="Vastarie's Tutelage",["de"]="Vastaries Vormundschaft"},["itemId"]=148688},[440]={["name"]={["fr"]="L’Alfiq rusé",["en"]="Crafty Afliq",["de"]="Listiger Alfiq"},["itemId"]=149240},[441]={["name"]={["fr"]="Le Vêtement de Darloc Brae",["en"]="Vesture of Darloc Brae",["de"]="Gewandung von Darloc Brae"},["itemId"]=149431},[442]={["name"]={["fr"]="L’Appel du Croque-mort",["en"]="Call of the Undertaker",["de"]="Ruf des Totengräbers"},["itemId"]=149058},[444]={["name"]={["fr"]="Le Dévôt du Faux dieu",["en"]="False God's Devotion",["de"]="Ergebenheit des falschen Gottes"},["itemId"]=149977},[445]={["name"]={["fr"]="La Dent de Lokkestiiz",["en"]="Tooth of Lokkestiiz",["de"]="Zahn von Lokkestiiz"},["itemId"]=149795},[446]={["name"]={["fr"]="La griffe d’Yolnahkriin",["en"]="Claw of Yolnahkriin",["de"]="Kralle von Yolnahkriin"},["itemId"]=149613}}
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

local function LoadSetsByIds(from, to)
    local buildItemLink = lib.buildItemLink
    local clientLang = lib.clientLang
    for setItemId=from, to do
        itemsScanned = itemsScanned + 1
        --Generate link for item
        local itemLink = buildItemLink(setItemId)
        if itemLink and itemLink ~= "" then
            if not IsItemLinkCrafted(itemLink) then
                local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
                if isSet then
                    local itemType = GetItemLinkItemType(itemLink)
                    --Some set items are only "containers" ...
                    if checkItemTypes[itemType] then
                        --Only add the first found item of the set as itemId!
                        if sets[setId] == nil then
                            sets[setId] = {}
                            setsFound = setsFound + 1
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
                                setsUpdated = setsUpdated + 1
                            end
                        end
                    end
                end
            end
        end
    end
    d("[LibSets]~~~Scanning sets~~~ items: " .. tostring(itemsScanned) .. ", sets new/updated: " .. tostring(setsFound) .. "/" .. tostring(setsUpdated))
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
    local allSets = { lib.setsData.sets, preloaded.sets }
    for i=1,2 do
        local data = allSets[i] or {}
        for setId, setData in pairs(data) do
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
    for setId, _ in pairs(preloaded.sets) do
        table.insert(setIds, setId)
    end
    if lib.setsData and lib.setsData.sets then
        for setId, _ in pairs(lib.setsData.sets) do
            table.insert(setIds, setId)
        end
    end
    table.sort(setIds)
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
        d("[LibSets]Starting set scan initiated by addon \'" .. tostring(fromAddonName) .. "\', APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
    else
        d("[LibSets]Starting set scan, APIVersion: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
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
    local fromVal = 0
    if preloaded["languagesScanned"][tostring(lib.clientLang)] then
        fromVal = preloaded["maxItemIdScanned"] + 1
    end
    for numItemIdPackage = 1, numItemIdPackages, 1 do
        --Set the to value to loop counter muliplied with the package size (e.g. 1*500, 2*5000, 3*5000, ...)
        local toVal = numItemIdPackage * numItemIdPackageSize
        --Add the from and to values to the totla itemId check array
        table.insert(fromTo, {from = fromVal, to = toVal})
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
            d("[LibSets]Scan finished. [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'")
            lib.setsData.sets = sets
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
            d("[LibSets]ERROR: Scan not successfull! [Totals]item count: " .. tostring(itemsScanned) .. ", sets found/updated: " .. tostring(setsFound) .."/" .. tostring(setsUpdated) .. "\nAPI version: \'" .. tostring(lib.currentAPIVersion) .. "\', language: \'" .. tostring(lib.clientLang) .. "\'\nSet data could not be saved!\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
        end
    end, miliseconds + 1000)
end


--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)
    if setId == nil then return end
    return lib.craftedSets[setId] or false
end

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)
    if setId == nil then return end
    return lib.monsterSets[setId] or false
end

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)
    if setId == nil then return end
    return lib.dungeonSets[setId] or false
end

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)
    if setId == nil then return end
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
    return setIds
end

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)
    if setId == nil then return end
    lang = lang or lib.clientLang
    if not lib.supportedLanguages[lang] then return end
    
    if preloaded.sets[tonumber(setId)] and preloaded.sets[tonumber(setId)]["name"][lang] then
        return preloaded.sets[tonumber(setId)]["name"][lang]
    end
    if lib.setsData.sets == nil 
       or lib.setsData.sets[tonumber(setId)] == nil 
       or lib.setsData.sets[tonumber(setId)]["name"] == nil
    then return end
    local setName = lib.setsData.sets[tonumber(setId)]["name"][lang]
    return setName
end

--Returns all names as String of the setId provided
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)
    if setId == nil then return end
    local setNames
    if preloaded.sets[tonumber(setId)] then
        setNames = {}
        for language, setName in pairs(preloaded.sets[tonumber(setId)]["name"]) do
            setNames[language] = setName
        end
    end
    if lib.setsData.sets == nil or lib.setsData.sets[tonumber(setId)] == nil
        or lib.setsData.sets[tonumber(setId)]["name"] == nil then return setNames end
    local svSetNames = lib.setsData.sets[tonumber(setId)]["name"]
    for language, setName in pairs(svSetNames) do
        if not setNames[language] then
            setNames[language] = setName
        end
    end
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
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, fractionIndex).
------>The table will contain 1 entry if it's a NON-craftable setId (wayshrines = {[1] = WSNodeNoFraction})
------>and 3 entries (one for each fraction) if it's a craftable setId (wayshrines = {[1] = WSNodeFraction1, [2] = WSNodeFraction2, [3] = WSNodeFraction3})
function lib.GetSetInfo(setId)
    if setId == nil 
       or not preloaded.sets[tonumber(setId)] 
          and (lib.setsData.sets == nil 
               or lib.setsData.sets[tonumber(setId)] == nil)
    then
        return
    end
    local setInfoTable = {}
    local setInfoFromSV = preloaded.sets[tonumber(setId)] or lib.setsData.sets[tonumber(setId)]
    setInfoTable.setId = setId
    setInfoTable.itemId = setInfoFromSV["itemId"]
    setInfoTable.names = {}
    setInfoTable.names = setInfoFromSV["name"]
    setInfoTable.setTypes = {
        ["isCrafted"]   = false,
        ["isDungeon"]   = false,
        ["isMonster"]   = false,
        ["isOverland"]  = false,
    }
    setInfoTable.traitsNeeded   = 0
    local isCraftedSet = (craftedSets[setId]) or false
    --Craftable set
    if isCraftedSet then
        local craftedSetsData = setInfo[setId]
        if craftedSetsData then
            setInfoTable.traitsNeeded   = craftedSetsData.traitsNeeded
            setInfoTable.wayshrines     = craftedSetsData.wayshrines
            setInfoTable.setTypes["isCrafted"] = true
        end
    --Non-craftable set
    else
        local nonCraftedSetsData = setInfo[setId]
        if nonCraftedSetsData then
            setInfoTable.wayshrines     = nonCraftedSetsData.wayshrines
            --Check the type of the set
            if monsterSets[setId] then      setInfoTable.setTypes["isMonster"]  = true
            elseif dungeonSets[setId] then  setInfoTable.setTypes["isDungeon"]  = true
            elseif overlandSets[setId] then setInfoTable.setTypes["isOverland"] = true
            end
        end
    end
    return setInfoTable
end

--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a fraction ID in order to jump to the selected fraction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL fractionIndex: The index of the fraction (1=Ebonheart Pact, 2=Admeri Dominion, 3=Daggerfall Covenant)
function lib.JumpToSetId(setId, fractionIndex)
    if setId == nil then return false end
    local jumpToNode = -1
    --Is a crafted set?
    if craftedSets[setId] then
        --Then use the fraction Id 1 to 3
        fractionIndex = fractionIndex or 1
        if fractionIndex < 1 or fractionIndex > 3 then fractionIndex = 1 end
        local craftedSetWSData = setInfo[setId].wayshrines
        if craftedSetWSData ~= nil and craftedSetWSData[fractionIndex] ~= nil then
            jumpToNode = craftedSetWSData[fractionIndex]
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
    local setItemId = preloaded.sets[tonumber(setId)]["itemId"] or lib.setsData.sets[tonumber(setId)]["itemId"]
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
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]API version changed from \'" .. tostring(lastCheckedSetsAPIVersion) .. "\'to \'" .. tostring(lib.currentAPIVersion) .. "\nAll set IDs and names need to be rescanned!\nThis will take about 2 minutes.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nYour client might lag and be hardly responsive during this time!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(true)
        end, 1000)
    
    --Client language changed and language is not yet in the SavedVariables?
    elseif lib.supportedLanguages and lib.clientLang and lib.supportedLanguages[lib.clientLang] == true 
           and not preloaded["languagesScanned"][lib.clientLang]
           and lib.setsData and lib.setsData.sets
           and lib.setsData["languagesScanned"] 
           and (lib.setsData["languagesScanned"][lib.currentAPIVersion] == nil 
                or (lib.setsData["languagesScanned"][lib.currentAPIVersion] 
                    and lib.setsData["languagesScanned"][lib.currentAPIVersion][lib.clientLang] == nil))
    then
        --Delay to chat output works
        zo_callLater(function()
            d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n[LibSets]Sets data for your current client language \'" .. tostring(lib.clientLang) .. "\' and the current API version \'" .. tostring(lib.currentAPIVersion) .. "\' was not added yet.\nAll set IDs and names need to be rescanned!\nThis will take about 2 minutes.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nYour client might lag and be hardly responsive during this time!\nPlease just wait for this action to finish.\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            lib.LoadSets(false)
        end, 1000)
    else
        loadSetIds()
        if lib.setsData 
           and (6 ~= #{lib.setsData.monsterSets, lib.setsData.dungeonSets, lib.setsData.overlandSets, lib.setsData.monsterSetsCount, lib.setsData.dungeonSetsCount, lib.setsData.overlandSetsCount}
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
    lib.preloaded           = lib.preloaded
end

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)