# LibSets
LibSets is a library addon for the game Elder Scrolls Online.
This file can also be found included in the package, with the name: ReadMe_LibSets.md

It's based on the data mined and collected data of the item sets in the game.
The item sets got a unique setId which was used to identify the sets in this library.
The data is kept in the included excel file "LiBSets_SetData.xlsx".

The purpose of this library is to provide information like all setIds, the type of the set, set names in different languages,
the drop locations (zoneIds usable with ESO API or the other library of mine: LibZone), bosses where the sets drop,
traits needed to craft the set (if craftable), wayshrine nodeIds to jump to the set's drop location (if possible), etc.

The library got some collected data, generated from the included excel file, in the file LibSets_Data.lua.
Updating the excel file after game patches should (for the moment) be enough to generate the needed lua code, which can be copied&pasted
into the LibSets_Data.lua file.

Supported languages, some constants like the actual number of monster set chests and the names of the NPCs/chest to provide the set are
included as well.

[Here is a list of the API functions you are able to use]

--Global variable of the library to access it:
LibSets

------------------------------------------------------------------------
-- 	Global helper functions
------------------------------------------------------------------------
--Create an example itemlink of the setItem's itemId (level 50, CP160) using the itemQuality subtype.
--Standard value for the qualitySubType is 366 which means "Normal" quality.
--The following qualities are available:
--357:  Trash
--366:  Normal
--367:  Magic
--368:  Arcane
--369:  Artifact
--370:  Legendary
function lib.buildItemLink(itemId, itemQualitySubType)


------------------------------------------------------------------------
-- 	Global set check functions
------------------------------------------------------------------------
--Returns true if the setId provided is a craftable set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCraftedSet
function lib.IsCraftedSet(setId)

--Returns true if the setId provided is a monster set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isMonsterSet
function lib.IsMonsterSet(setId)

--Returns true if the setId provided is a dungeon set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDungeonSet
function lib.IsDungeonSet(setId)

--Returns true if the setId provided is a trial set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isTrialSet, boolean isMultiTrialSet
function lib.IsTrialSet(setId)

--Returns true if the setId provided is an arena set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isArenaSet
function lib.IsArenaSet(setId)

--Returns true if the setId provided is an overland set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isOverlandSet
function lib.IsOverlandSet(setId)

--Returns true if the setId provided is an cyrodiil set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isCyrodiilSet
function lib.IsCyrodiilSet(setId)

--Returns true if the setId provided is a battleground set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isBattlegroundSet
function lib.IsBattlegroundSet(setId)

--Returns true if the setId provided is an Imperial City set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isImperialCitySet
function lib.IsImperialCitySet(setId)

--Returns true if the setId provided is a special set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isSpecialSet
function lib.IsSpecialSet(setId)

--Returns true if the setId provided is a DailyRandomDungeonAndImperialCityRewardSet set
--> Parameters: setId number: The set's setId
--> Returns:    boolean isDailyRandomDungeonAndImperialCityRewardSet
function lib.IsDailyRandomDungeonAndImperialCityRewardSet(setId)

--Returns true if the setId provided is a non ESO, own defined setId
--See file LibSets_SetData_(APIVersion).lua, table LibSets.lib.noSetIdSets and description above it.
--> Parameters: noESOSetId number: The set's setId
--> Returns:    boolean isNonESOSet
function lib.IsNoESOSet(noESOSetId)

--Returns information about the set if the itemId provides is a set item
--> Parameters: itemId number: The item's itemId
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemId(itemId)

--Returns information about the set if the itemlink provides is a set item
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number
function lib.IsSetByItemLink(itemLink)

--Returns true/false if the set must be obtained in a veteran mode dungeon/trial/arena.
--If the veteran state is not a boolean value, but a table, then this table contains the equipType as key
--and the boolean value for each of these equipTypes as value. e.g. the head is a veteran setItem but the shoulders aren't (monster set).
--->To check the equiptype you need to specify the 2nd parameter itemlink in this case! Or the return value will be nil
--> Parameters: setId number: The set's setId
-->             itemLink String: An itemlink of a setItem -> only needed if the veteran data contains equipTypes and should be checked
-->                              against these.
--> Returns:    isVeteranSet boolean
function lib.IsVeteranSet(setId, itemLink)


------------------------------------------------------------------------
-- 	Global set get data functions
------------------------------------------------------------------------
--Returns the wayshrines as table for the setId. The table contains up to 3 wayshrines for wayshrine nodes in the different factions,
--e.g. wayshrines={382,382,382,}. All entries can be the same, or even a negative value which means: No weayshrine is known
--Else the order of the entries is 1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact
--> Parameters: setId number: The set's setId
--> Returns:    wayshrineNodeIds table
function lib.GetWayshrineIds(setId)

--Returns the drop zoneIds as table for the setId
--> Parameters: setId number: The set's setId
--> Returns:    zoneIds table
function lib.GetZoneIds(setId)

--Returns the dlcId as number for the setId
--> Parameters: setId number: The set's setId
--> Returns:    dlcId number
function lib.GetDLCId(setId)

--Returns the number of researched traits needed to craft this set. This will only check the craftable sets!
--> Parameters: setId number: The set's setId
--> Returns:    traitsNeededToCraft number
function lib.GetTraitsNeeded(setId)

--Returns the type of the setId!
--> Parameters: setId number: The set's setId
--> Returns:    setType String
---> Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
function lib.GetSetType(setId)

--Returns the setType name as String
--> Parameters: libSetsSetType number: The set's setType (one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
-->             lang String the language for the setType name. Can be left nil -> The client language will be used then
--> Returns:    String setTypeName
function lib.GetSetTypeName(libSetsSetType, lang)

--Returns the table of setTypes of LibSets (the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
function lib.GetSetTypes()

--Returns a sorted table of all set ids. Key is the setId, value is the boolean value true.
--Attention: The table can have a gap in it's index as not all setIds are gap-less in ESO!
--> Returns: setIds table
function lib.GetAllSetIds()

--Returns all sets itemIds as table. Key is the setId, value is a subtable with the key=itemId and value = boolean value true.
--> Returns: setItemIds table
function lib.GetAllSetItemIds()

--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.
--The key is the itemId and the value is the boolean value true
--> Parameters: setId number: The set's setId
-->             isSpecialSet boolean: Read the set's itemIds from the special sets table or the normal?
--> Returns:    table setItemIds
function lib.GetSetItemIds(setId, isNoESOSetId)

--If the setId only got 1 itemId this function returns this itemId of the setId provided.
--If the setId got several itemIds this function returns one random itemId of the setId provided (depending on the 2nd parameter equipType)
--If the 2nd parameter equipType is not specified: The first random itemId found will be returned
--If the 2nd parameter equipType is specified:  Each itemId of the setId will be turned into an itemLink where the given equipType is checked against.
--Only the itemId where the equipType fits will be returned. Else the return value will be nil
--> Parameters: setId number: The set's setId
-->             equipType number: The equipType to check the itemId against
--> Returns:    number setItemId
function lib.GetSetItemId(setId, equipType)

--Returns the name as String of the setId provided
--> Parameters: setId number: The set's setId
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then
--> Returns:    String setName
function lib.GetSetName(setId, lang)

--Returns all names as String of the setId provided.
--The table returned uses the key=language (2 characters String e.g. "en") and the value = name String, e.g.
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}
--> Parameters: setId number: The set's setId
--> Returns:    table setNames
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})
function lib.GetSetNames(setId)

--Returns the set info as a table
--> Parameters: setId number: The set's setId
--> Returns:    table setInfo
----> Contains:
----> number setId
----> number dlcId (the dlcId where the set was added, see file LibSets_Constants.lua, constants DLC_BASE_GAME to e.g. DLC_ELSWEYR)
----> tables LIBSETS_TABLEKEY_SETITEMIDS (="setItemIds") (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's item),
----> table names (="setNames") ([2 character String lang] = String name),
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),
----> String setType which shows the setType via the LibSets setType constant values like LIBSETS_SETTYPE_ARENA, LIBSETS_SETTYPE_DUNGEON etc. Only 1 setType is possible for each set
----> isVeteran boolean value true if this set can be only obtained in veteran mode, or a table containing the key = equipType and value=boolean true/false if the equipType of the setId cen be only obtained in veteran mode (e.g. a monster set head is veteran, shoulders are normal)
----> isMultiTrial boolean, only if setType == LIBSETS_SETTYPE_TRIAL (setId can be obtained in multiple trials -> see zoneIds table)
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).
------>The table can contain 1 to 3 entries (one for each faction e.g.) and contains the wayshrineNodeId nearest to the set's crafting table/in the drop zone
----> table zoneIds containing the zoneIds (one to n) where this set drops, or can be obtained
-------Example for setId 408
--- ["setId"] = 408,
--- ["dlcId"] = 12,    --DLC_MURKMIRE
--	["setType"] = LIBSETS_SETTYPE_CRAFTED,
--	[LIBSETS_TABLEKEY_SETITEMIDS] = {
--      table [#0,370]
--  },
--	[LIBSETS_TABLEKEY_SETNAMES] = {
--		["de"] = "Grabpflocksammler"
--		["en"] = "Grave-Stake Collector"
--		["fr"] = "Collectionneur de marqueurs funéraires"
--  },
--	["traitsNeeded"] = 7,
--	["veteran"] = false,
--	["wayshrines"] = {
--		[1] = 375
--		[2] = 375
--		[3] = 375
--  },
--	["zoneIds"] = {
--		[1] = 726,
--  },
--}
function lib.GetSetInfo(setId)


------------------------------------------------------------------------
-- 	Global set misc. functions
------------------------------------------------------------------------
--Jump to a wayshrine of a set.
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone
--> Parameters: setId number: The set's setId
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)
function lib.JumpToSetId(setId, factionIndex)


------------------------------------------------------------------------
-- 	Global other get functions
------------------------------------------------------------------------
--Returns the name of the DLC by help of the DLC id
--> Parameters: dlcId number: The DLC id given in a set's info
--> Returns:    name dlcName
function lib.GetDLCName(dlcId)

--Returns the name of the DLC by help of the DLC id
--> Parameters: undauntedChestId number: The undaunted chest id given in a set's info
--> Returns:    name undauntedChestName
function lib.GetUndauntedChestName(undauntedChestId, lang)

--Returns the name of the zone by help of the zoneId
--> Parameters: zoneId number: The zone id given in a set's info
-->             language String: ONLY possible to be used if additional library "LibZone" (https://www.esoui.com/downloads/info2171-LibZone.html) is activated
--> Returns:    name zoneName
function lib.GetZoneName(zoneId, lang)

--Returns the set data (setType number, setIds table, itemIds table, setNames table) for specified LibSets setType
--> Returns:    table with key = setId, value = table which contains (as example for setType = LIBSETS_SETTYPE_CRAFTED)
---->             [LIBSETS_TABLEKEY_SETTYPE] = LIBSETS_SETTYPE_CRAFTED ("Crafted")
------>             1st subtable with key LIBSETS_TABLEKEY_SETITEMIDS ("setItemIds") containing a pair of [itemId]= true (e.g. [12345]=true,)
------>             2nd subtable with key LIBSETS_TABLEKEY_SETNAMES ("setNames") containing a pair of [language] = "Set name String" (e.g. ["en"]= Crafted set name 1",)
---             Example:
---             [setId] = {
---                 setType = LIBSETS_SETTYPE_CRAFTED,
---                 [LIBSETS_TABLEKEY_SETITEMIDS] = {
---                     [itemId1]=true,
---                     [itemId2]=true
---                 },
---                 [LIBSETS_TABLEKEY_SETNAMES] = {
---                     ["de"]="Set name German",
---                     ["en"]="Set name English",
---                     ["fr"]="Set name French",
---                 },
---             }
--Returns the set data (setType number, setIds table, itemIds table, setNames table) for the specified LibSets setType
--Parameters: setType number. Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)
--> Returns:    table -> See lib.GetCraftedSetsData for details of the table contents
function lib.GetSetTypeSetsData(setType)


------------------------------------------------------------------------
-- 	Global library check functions
------------------------------------------------------------------------
--Returns a boolean value, true if the sets of the game were already loaded/ false if not
--> Returns:    boolean areSetsLoaded
function lib.AreSetsLoaded()

--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not
--> Returns:    boolean isCurrentlySetsScanning
function lib.IsSetsScanning()

--Returns a boolean value, true if the sets database is properly loaded yet and is not currently scanning
--or false if not.
--This functions combines the result values of the functions LibSets.AreSetsLoaded() and LibSets.IsSetsScanning()
function lib.checkIfSetsAreLoadedProperly()