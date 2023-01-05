--Check if the library was loaded before already w/o chat output
if IsLibSetsAlreadyLoaded(false) then return end

--This file the sets data and info (pre-loaded from the specified API version)
--It should be updated each time the APIversion increases to contain the new/changed data
local lib = LibSets

local MAJOR, MINOR = lib.name, lib.version
local libPrefix = "["..MAJOR.."]"

local tos = tostring
local strgsub = string.gsub
local strfor = string.format
local zostrlow = zo_strlower

local clientLang =      lib.clientLang
local fallbackLang =    lib.fallbackLang
--local doesClientLangEqualFallbackLang = (clientLang == fallbackLang and true) or false
local localization       = lib.localization
local supportedLanguages = lib.supportedLanguages
local supportedLanguagesIndex = lib.supportedLanguagesIndex


local cachedSetNames

local getSetName
local getAllSetNames
local createPreviewTooltipAndShow = lib.CreatePreviewTooltipAndShow

local setPreviewTooltipSV
local getLibSetsSetPreviewTooltipSavedVariables = lib.getLibSetsSetPreviewTooltipSavedVariables

------------------------------------------------------------------------
-- 	Helper functions
------------------------------------------------------------------------

------------------------------------------------------------------------
-- 	Library - Chat autocomplete functions (using LibSlashCommander)
------------------------------------------------------------------------

--Build the autocompletion entries for setNames for a given language.
--You need to use the chat slash command for the current client language /lsp or for a desired target language /lsp<language> e.g. /lspen
--You'll have to enter a space and then the set name of the language e.g. Spellpower cure.
--After that a space or press the auto completion key TABULATOR to see a list of the translated set names of other languages.
--Selecting an entry will take this translated set's ID and show a tooltip of an setItem, trying "chest divine legendary" first,
--and after that, if that item does not exist, any random item of that set.
--The itemlink will be added to the chat edit box too, so you can post it.
local function buildAutoComplete(command, langToUse)
    --Get/Create instance of LibSlashCommander
    local lscLib = lib.libSlashCommander
    if lscLib == nil then return end
    if setPreviewTooltipSV == nil then return end
    if command == nil or not supportedLanguages[langToUse] then return end

    getSetName = getSetName or lib.GetSetName
    getAllSetNames = getAllSetNames or lib.GetAllSetNames
    if cachedSetNames == nil then
        cachedSetNames = getAllSetNames()
    end

    --Add sub commands for the zoneNames
    if cachedSetNames ~= nil then
        local MyAutoCompleteProvider = {}
        MyAutoCompleteProvider = lscLib.AutoCompleteProvider:Subclass()
        function MyAutoCompleteProvider:New(resultList, lookupList, lang)
            local obj = lscLib.AutoCompleteProvider.New(self)
            obj.resultList = resultList
            obj.lookupList = lookupList
            obj.lang = langToUse
            return obj
        end

        function MyAutoCompleteProvider:GetResultList()
            return self.resultList
        end

        function MyAutoCompleteProvider:GetResultFromLabel(label)
            return self.lookupList[label] or label
        end

        --Callback to create a setItem tooltp into the chat editbox
        command:SetCallback(function(input)
            createPreviewTooltipAndShow = createPreviewTooltipAndShow or lib.CreatePreviewTooltipAndShow
            local setId = tonumber(input)
            if setId ~= nil and type(setId) == "number" then
                local itemLink = createPreviewTooltipAndShow(setId)
                if itemLink ~= nil and setPreviewTooltipSV.sendToChatToo == true then
                    StartChatInput(itemLink)
                end
            end
        end)

        local repStr = "·"
        local langUpper = localization[langToUse][langToUse]
        for setId, setLanguagesData in pairs(cachedSetNames) do
            --[[
            local setNameInClientLang = setLanguagesData[clientLang]
            --Replace the spaces in the set name so LibSlashCommander will find them with the auto complete properly
            --try to use %s instead of just a space. if that doesn't work use [\t-\r ] instead
            local setNameNoSpaces = strgsub(setNameInClientLang, "%s+", repStr)
            if setNameNoSpaces == "" then setNameNoSpaces = setNameInClientLang end
            ]]
            local setNameInSlashCommandLang = setLanguagesData[langToUse]
            if setNameInSlashCommandLang ~= nil then
                --Replace the spaces in the set name so LibSlashCommander will find them with the auto complete properly
                --try to use %s instead of just a space. if that doesn't work use [\t-\r ] instead
                local setNameInSlashCommandLangNoSpaces = strgsub(setNameInSlashCommandLang, "%s+", repStr)
                if setNameInSlashCommandLangNoSpaces == "" then setNameInSlashCommandLangNoSpaces = setNameInSlashCommandLang end

                command:AddAlias(tos(setId) .. setNameInSlashCommandLangNoSpaces)

                --Add a setName entry as subcommand so the first auto complete will show all set names as the user types /lsp into chat
                if not command:HasSubCommandAlias(setNameInSlashCommandLangNoSpaces) then
                    local setSubCommand = command:RegisterSubCommand()
                    setSubCommand:AddAlias(setNameInSlashCommandLangNoSpaces)
                    setSubCommand:SetDescription(langUpper .. " (ID: " ..tos(setId)..")")
                    setSubCommand:SetCallback(function(input)
                        createPreviewTooltipAndShow = createPreviewTooltipAndShow or lib.CreatePreviewTooltipAndShow
                        local itemLink = createPreviewTooltipAndShow(setId)
                        if itemLink ~= nil and setPreviewTooltipSV.sendToChatToo == true then
                            StartChatInput(itemLink)
                        end
                    end)
                    --Get the translated zone names
                    local otherLanguagesSetName                     = {} -- Only a temp table
                    local otherLanguagesNoDuplicateSetName          = {} -- Only a temp table
                    local alreadyAddedCleanTranslatedSetNames       = {} -- The resultsList for the autocomplete provider
                    local alreadyAddedCleanTranslatedSetNamesLookup = {} -- The lookupList for the autocomplete provider
                    for langIdx, lang in pairs(supportedLanguagesIndex) do
                        if supportedLanguages[lang] == true then
                            local otherLanguageSetName = cachedSetNames[setId][lang]
                            if otherLanguageSetName ~= nil and otherLanguageSetName ~= "" then
                                otherLanguagesSetName[langIdx] = otherLanguageSetName
                            end
                        end
                    end
                    if #otherLanguagesSetName >= 1 then
                        local langStr = ""
                        for langIdx, cleanTranslatedSetName in ipairs(otherLanguagesSetName) do
                            local lang = supportedLanguagesIndex[langIdx]
                            local upperLangStr = localization[langToUse][lang]
                            if otherLanguagesNoDuplicateSetName[cleanTranslatedSetName] == nil then
                                langStr = ""
                            else
                                langStr = otherLanguagesNoDuplicateSetName[cleanTranslatedSetName]
                            end
                            if langStr == "" then
                                langStr = upperLangStr
                            else
                                langStr = langStr .. ", " .. upperLangStr
                            end
                            otherLanguagesNoDuplicateSetName[cleanTranslatedSetName] = langStr
                        end
                        for cleanTranslatedSetNameLoop, langStrLoop in pairs(otherLanguagesNoDuplicateSetName) do
                            local label                                                               = strfor("%s|caaaaaa - %s", cleanTranslatedSetNameLoop, langStrLoop)
                            alreadyAddedCleanTranslatedSetNames[zostrlow(cleanTranslatedSetNameLoop)] = label
                            alreadyAddedCleanTranslatedSetNamesLookup[label]                          = cleanTranslatedSetNameLoop
                        end
                    end
                    local autocomplete = MyAutoCompleteProvider:New(alreadyAddedCleanTranslatedSetNames, alreadyAddedCleanTranslatedSetNamesLookup, langToUse)
                    setSubCommand:SetAutoComplete(autocomplete)
                end
            end
        end
    end
end

--If LibSlashCommander is present and activated: Build the auto completion entries for each supported language (/lzt<language>) + 1 major slash command (/lzt)
function lib.buildLSCSetSearchAutoComplete()
    --Get/Create instance of LibSlashCommander
    local lscLib = lib.libSlashCommander
    if lscLib == nil then return end

    setPreviewTooltipSV = getLibSetsSetPreviewTooltipSavedVariables()
    if not lib.svData or not setPreviewTooltipSV then return end

    lib.commandsLsp = {}
    --Add auto completion for client language
    lib.commandsLsp["all"] = lscLib:Register({"/libsetspreview", "/setpreview", "/setsp", "/lsp"},
            nil,
            libPrefix .. localization[clientLang]["slashCommandDescriptionClient"])
    buildAutoComplete(lib.commandsLsp["all"], clientLang)

    --Add auto completion for all other languages
    for _, lang in pairs(supportedLanguagesIndex) do
        if supportedLanguages[lang] == true then
            local langStr = tostring(lang)
            local transForLang = localization[langStr]
            if transForLang ~= nil and transForLang["slashCommandDescription"] ~= nil then
                lib.commandsLsp[langStr] = lscLib:Register({"/libsetspreview" .. langStr, "/setpreview" .. langStr, "/setsp" .. langStr, "/lsp" .. langStr},
                        nil,
                        libPrefix .. transForLang["slashCommandDescription"])
                buildAutoComplete(lib.commandsLsp[langStr], langStr)
            end
        end
    end
end