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

##[Here is a list of the API functions you are able to use]

--Global variable of the library to access it:
**LibSets**

###Global helper functions
--Create an example itemlink of the setItem's itemId (level 50, CP160) using the itemQuality subtype.<br>
--Standard value for the qualitySubType is 366 which means "Normal" quality.<br>
--The following qualities are available:<br>
--357:  Trash<br>
--366:  Normal<br>
--367:  Magic<br>
--368:  Arcane<br>
--369:  Artifact<br>
--370:  Legendary<br>
--> Parameters: itemId number: The item's itemId<br>
-->             itemQualitySubType number: The itemquality number of ESO, described above (standard value: 366 -> Normal)<br>
--> Returns:    itemLink String: The generated itemLink for the item with the given quality<br>
function lib.buildItemLink(itemId, itemQualitySubType)<br>
<br>
--Open the worldmap and show the map of the zoneId<br>
--> Parameters: zoneId number: The zone's zoneId<br>
function lib.openMapOfZoneId(zoneId)<br>
<br>
--Open the worldmap, get the zoneId of the wayshrine wayshrineNodeId and show the wayshrine wayshrineNodeId on the map<br>
--> Parameters: wayshrineNodeId number: The wayshrine's nodeIndex<br>
function lib.showWayshrineNodeIdOnMap(wayshrineNodeId)<br>
<br>
--Returns the armor types's name<br>
--> Parameters: armorType ESOArmorType: The ArmorType (https://wiki.esoui.com/Globals#ArmorType)<br>
--> Returns:    String armorTypeName: The name fo the armor type in the current client's language<br>
function lib.GetArmorTypeName(armorType)<br>
<br>
<br>
###Global set check functions
--Returns true if the setId provided is a craftable set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isCraftedSet<br>
function lib.IsCraftedSet(setId)<br>
<br>
--Returns true if the setId provided is a monster set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isMonsterSet<br>
function lib.IsMonsterSet(setId)<br>
<br>
--Returns true if the setId provided is a dungeon set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isDungeonSet<br>
function lib.IsDungeonSet(setId)<br>
<br>
--Returns true if the setId provided is a trial set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isTrialSet, boolean isMultiTrialSet<br>
function lib.IsTrialSet(setId)<br>
<br>
--Returns true if the setId provided is an arena set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isArenaSet<br>
function lib.IsArenaSet(setId)<br>
<br>
--Returns true if the setId provided is an overland set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isOverlandSet<br>
function lib.IsOverlandSet(setId)<br>
<br>
--Returns true if the setId provided is an cyrodiil set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isCyrodiilSet<br>
function lib.IsCyrodiilSet(setId)<br>
<br>
--Returns true if the setId provided is a battleground set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isBattlegroundSet<br>
function lib.IsBattlegroundSet(setId)<br>
<br>
--Returns true if the setId provided is an Imperial City set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isImperialCitySet<br>
function lib.IsImperialCitySet(setId)<br>
<br>
--Returns true if the setId provided is a special set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isSpecialSet<br>
function lib.IsSpecialSet(setId)<br>
<br>
--Returns true if the setId provided is a DailyRandomDungeonAndImperialCityRewardSet set<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    boolean isDailyRandomDungeonAndImperialCityRewardSet<br>
function lib.IsDailyRandomDungeonAndImperialCityRewardSet(setId)<br>
<br>
--Returns true if the setId provided is a non ESO, own defined setId<br>
--See file LibSets_SetData_(APIVersion).lua, table LibSets.lib.noSetIdSets and description above it.<br>
--> Parameters: noESOSetId number: The set's setId<br>
--> Returns:    boolean isNonESOSet<br>
function lib.IsNoESOSet(noESOSetId)<br>
<br>
--Returns information about the set if the itemId provides is a set item<br>
--> Parameters: itemId number: The item's itemId<br>
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number<br>
function lib.IsSetByItemId(itemId)<br>
<br>
--Returns information about the set if the itemlink provides is a set item<br>
--> Parameters: itemLink String/ESO ItemLink: The item's itemLink '|H1:item:itemId...|h|h'<br>
--> Returns:    isSet boolean, setName String, setId number, numBonuses number, numEquipped number, maxEquipped number<br>
function lib.IsSetByItemLink(itemLink)<br>
<br>
--Returns true/false if the set must be obtained in a veteran mode dungeon/trial/arena.<br>
--If the veteran state is not a boolean value, but a table, then this table contains the equipType as key<br>
--and the boolean value for each of these equipTypes as value. e.g. the head is a veteran setItem but the shoulders aren't (monster set).<br>
--->To check the equiptype you need to specify the 2nd parameter itemlink in this case! Or the return value will be nil<br>
--> Parameters: setId number: The set's setId<br>
-->             itemLink String: An itemlink of a setItem -> only needed if the veteran data contains equipTypes and should be checked<br>
-->                              against these.<br>
--> Returns:    isVeteranSet boolean<br>
function lib.IsVeteranSet(setId, itemLink)

###Global set get data functions
--Returns the wayshrines as table for the setId. The table contains up to 3 wayshrines for wayshrine nodes in the different factions,<br>
--e.g. wayshrines={382,382,382}. All entries can be the same, or even a negative value which means: No weayshrine is known<br>
--Else the order of the entries is 1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact<br>
--> Parameters: setId number: The set's setId<br>
-->             withRelatedZoneIds boolean: Also provide a mappingTable as 2nd return value which contains the wayshrine's zoneId<br>
-->             in this format: wayshrineNodsId2ZoneId = { [wayshrineNodeId1]= zoneId1, [wayshrineNodeId2]= zoneId2,... }<br>
--> Returns:    wayshrineNodeIds table<br>
function lib.GetWayshrineIds(setId, withRelatedZoneIds)<br>
<br>
--Returns the wayshrineNodeIds's related zoneId, where this wayshrine is located<br>
--> Parameters: wayshrineNodeId number<br>
--> Returns:    zoneId number<br>
function lib.GetWayshrinesZoneId(wayshrineNodeId)<br>
<br>
--Returns the drop zoneIds as table for the setId<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    zoneIds table<br>
function lib.GetZoneIds(setId)<br>
<br>
--Returns the dlcId as number for the setId<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    dlcId number<br>
function lib.GetDLCId(setId)<br>
<br>
--Returns the number of researched traits needed to craft this set. This will only check the craftable sets!<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    traitsNeededToCraft number<br>
function lib.GetTraitsNeeded(setId)<br>
<br>
--Returns the type of the setId!<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    LibSetsSetType number<br>
---> Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)<br>
function lib.GetSetType(setId)<br>
<br>
--Returns the setType name as String<br>
--> Parameters: libSetsSetType number: The set's setType (one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)<br>
-->             lang String the language for the setType name. Can be left nil -> The client language will be used then<br>
--> Returns:    String setTypeName<br>
function lib.GetSetTypeName(libSetsSetType, lang)<br>
<br>
--Returns the table of setTypes of LibSets (the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)<br>
function lib.GetSetTypes()<br>
<br>
--Returns the dropMechanic ID of the setId!<br>
--> Parameters: setId number:       The set's setId<br>
-->             withNames bolean:   Should the function return the dropMechanic names as well?<br>
--> Returns:    LibSetsDropMechanic number
---> Possible values are the dropMechanics of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)
function lib.GetDropMechanic(setId, withNames)<br>
<br>
--Returns the name of the drop mechanic ID (a drop locations boss, city, email, ..)<br>
--> Parameters: dropMechanicId number: The LibSetsDropMechanidIc (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)<br>
-->             lang String: The 2char language String for the used translation. If left empty the current client's<br>
-->             language will be used.<br>
--> Returns:    String dropMachanicNameLocalized: The name fo the LibSetsDropMechanidIc<br>
function lib.GetDropMechanicName(libSetsDropMechanidIc, lang)<br>
<br>
--Returns the table of dropMechanics of LibSets (the constants in LibSets.allowedDropMechanics, see file LibSets_Constants.lua)<br>
function lib.GetDropMechanics()<br>
<br>
--Returns a sorted table of all set ids. Key is the setId, value is the boolean value true.<br>
--Attention: The table can have a gap in it's index as not all setIds are gap-less in ESO!<br>
--> Returns: setIds table<br>
function lib.GetAllSetIds()<br>
<br>
--Returns all sets itemIds as table. Key is the setId, value is a subtable with the key=itemId and value = boolean value true.<br>
--> Returns: setItemIds table<br>
function lib.GetAllSetItemIds()<br>
<br>
--Returns a table containing all itemIds of the setId provided. The setItemIds contents are non-sorted.<br>
--The key is the itemId and the value is the boolean value true<br>
--> Parameters: setId number: The set's setId<br>
-->             isSpecialSet boolean: Read the set's itemIds from the special sets table or the normal?<br>
--> Returns:    table setItemIds<br>
function lib.GetSetItemIds(setId, isNoESOSetId)<br>
<br>
--If the setId only got 1 itemId this function returns this itemId of the setId provided.<br>
--If the setId got several itemIds this function returns one random itemId of the setId provided (depending on the 2nd parameter equipType)<br>
--If the 2nd parameter equipType is not specified: The first random itemId found will be returned<br>
--If the 2nd parameter equipType is specified:  Each itemId of the setId will be turned into an itemLink where the given equipType is checked against.<br>
--Only the itemId where the equipType fits will be returned. Else the return value will be nil<br>
--> Parameters: setId number: The set's setId<br>
-->             equipType number: The equipType to check the itemId against<br>
--> Returns:    number setItemId<br>
function lib.GetSetItemId(setId, equipType)<br>
<br>
--Returns the name as String of the setId provided<br>
--> Parameters: setId number: The set's setId<br>
--> lang String: The language to return the setName in. Can be left empty and the client language will be used then<br>
--> Returns:    String setName<br>
function lib.GetSetName(setId, lang)<br>
<br>
--Returns all names as String of the setId provided.<br>
--The table returned uses the key=language (2 characters String e.g. "en") and the value = name String, e.g.<br>
--{["fr"]="Les Vêtements du sorcier",["en"]="Vestments of the Warlock",["de"]="Gewänder des Hexers"}<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    table setNames<br>
----> Contains a table with the different names of the set, for each scanned language (setNames = {["de"] = String nameDE, ["en"] = String nameEN})<br>
function lib.GetSetNames(setId)<br>
<br>
--Returns the set info as a table<br>
--> Parameters: setId number: The set's setId<br>
--> Returns:    table setInfo<br>
----> Contains:<br>
----> number setId<br>
----> number dlcId (the dlcId where the set was added, see file LibSets_Constants.lua, constants DLC_BASE_GAME to e.g. DLC_ELSWEYR)<br>
----> tables LIBSETS_TABLEKEY_SETITEMIDS (="setItemIds") (which can be used with LibSets.buildItemLink(itemId) to create an itemLink of this set's item),<br>
----> table names (="setNames") ([2 character String lang] = String name),<br>
----> number traitsNeeded for the trait count needed to craft this set if it's a craftable one (else the value will be nil),<br>
----> String setType which shows the setType via the LibSets setType constant values like LIBSETS_SETTYPE_ARENA, LIBSETS_SETTYPE_DUNGEON etc. Only 1 setType is possible for each set<br>
----> isVeteran boolean value true if this set can be only obtained in veteran mode, or a table containing the key = equipType and value=boolean true/false if the equipType of the setId cen be only obtained in veteran mode (e.g. a monster set head is veteran, shoulders are normal)<br>
----> isMultiTrial boolean, only if setType == LIBSETS_SETTYPE_TRIAL (setId can be obtained in multiple trials -> see zoneIds table)<br>
----> table wayshrines containing the wayshrines to port to this setId using function LibSets.JumpToSetId(setId, factionIndex).<br>
------>The table can contain 1 to 3 entries (one for each faction e.g.) and contains the wayshrineNodeId nearest to the set's crafting table/in the drop zone<br>
----> table zoneIds containing the zoneIds (one to n) where this set drops, or can be obtained<br>
-------Example for setId 408<br>
--- ["setId"] = 408,<br>
--- ["dlcId"] = 12,    --DLC_MURKMIRE<br>
--	["setType"] = LIBSETS_SETTYPE_CRAFTED,<br>
--	[LIBSETS_TABLEKEY_SETITEMIDS] = {<br>
--      table [#0,370]<br>
--  },<br>
--	[LIBSETS_TABLEKEY_SETNAMES] = {<br>
--		["de"] = "Grabpflocksammler"<br>
--		["en"] = "Grave-Stake Collector"<br>
--		["fr"] = "Collectionneur de marqueurs funéraires"<br>
--  },<br>
--	["traitsNeeded"] = 7,<br>
--	["veteran"] = false,<br>
--	["wayshrines"] = {<br>
--		[1] = 375<br>
--		[2] = 375<br>
--		[3] = 375<br>
--  },<br>
--	["zoneIds"] = {<br>
--		[1] = 726,<br>
--  },<br>
--  ["dropMechanic"] = LIBSETS_DROP_MECHANIC_MONSTER_NAME,<br>
--  ["dropMechanicNames"] = {<br>
--      ["en"] = "DropMechanicNameEN",<br>
--      ["de"] = "DropMechanicNameDE",<br>
--      ["fr"] = "DropMechanicNameFR",<br>
--  },<br>
--}<br>
function lib.GetSetInfo(setId)

###Global set misc. functions
--Jump to a wayshrine of a set.<br>
--If it's a crafted set you can specify a faction ID in order to jump to the selected faction's zone<br>
--> Parameters: setId number: The set's setId<br>
-->             OPTIONAL factionIndex: The index of the faction (1=Admeri Dominion, 2=Daggerfall Covenant, 3=Ebonheart Pact)<br>
function lib.JumpToSetId(setId, factionIndex)<br>

###Global other get functions
--Returns the name of the DLC by help of the DLC id<br>
--> Parameters: dlcId number: The DLC id given in a set's info<br>
--> Returns:    name dlcName<br>
function lib.GetDLCName(dlcId)<br>
<br>
--Returns the name of the DLC by help of the DLC id<br>
--> Parameters: undauntedChestId number: The undaunted chest id given in a set's info<br>
--> Returns:    name undauntedChestName<br>
function lib.GetUndauntedChestName(undauntedChestId, lang)<br>
<br>
--Returns the name of the zone by help of the zoneId<br>
--> Parameters: zoneId number: The zone id given in a set's info<br>
-->             language String: ONLY possible to be used if additional library "LibZone" (https://www.esoui.com/downloads/info2171-LibZone.html) is activated<br>
--> Returns:    name zoneName<br>
function lib.GetZoneName(zoneId, lang)<br>
<br>
--Returns the set data (setType number, setIds table, itemIds table, setNames table) for specified LibSets setType<br>
--> Returns:    table with key = setId, value = table which contains (as example for setType = LIBSETS_SETTYPE_CRAFTED)<br>
---->             [LIBSETS_TABLEKEY_SETTYPE] = LIBSETS_SETTYPE_CRAFTED ("Crafted")<br>
------>             1st subtable with key LIBSETS_TABLEKEY_SETITEMIDS ("setItemIds") containing a pair of [itemId]= true (e.g. [12345]=true,)<br>
------>             2nd subtable with key LIBSETS_TABLEKEY_SETNAMES ("setNames") containing a pair of [language] = "Set name String" (e.g. ["en"]= Crafted set name 1",)<br>
---             Example:<br>
---             [setId] = {<br>
---                 setType = LIBSETS_SETTYPE_CRAFTED,<br>
---                 [LIBSETS_TABLEKEY_SETITEMIDS] = {<br>
---                     [itemId1]=true,<br>
---                     [itemId2]=true<br>
---                 },<br>
---                 [LIBSETS_TABLEKEY_SETNAMES] = {<br>
---                     ["de"]="Set name German",<br>
---                     ["en"]="Set name English",<br>
---                     ["fr"]="Set name French",<br>
---                 },<br>
---             }<br>
--Returns the set data (setType number, setIds table, itemIds table, setNames table) for the specified LibSets setType<br>
--Parameters: setType number. Possible values are the setTypes of LibSets one of the constants in LibSets.allowedSetTypes, see file LibSets_Constants.lua)<br>
--> Returns:    table -> See lib.GetCraftedSetsData for details of the table contents<br>
function lib.GetSetTypeSetsData(setType)

###Global library check functions
--Returns a boolean value, true if the sets of the game were already loaded/ false if not<br>
--> Returns:    boolean areSetsLoaded<br>
function lib.AreSetsLoaded()<br>
<br>
--Returns a boolean value, true if the sets of the game are currently scanned and added/updated/ false if not<br>
--> Returns:    boolean isCurrentlySetsScanning<br>
function lib.IsSetsScanning()<br>
<br>
--Returns a boolean value, true if the sets database is properly loaded yet and is not currently scanning<br>
--or false if not.<br>
--This functions combines the result values of the functions LibSets.AreSetsLoaded() and LibSets.IsSetsScanning()<br>
function lib.checkIfSetsAreLoadedProperly()<br>
