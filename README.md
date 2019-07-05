# LibSets
LibSets is a library addon for the game Elder Scrolls Online.

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

