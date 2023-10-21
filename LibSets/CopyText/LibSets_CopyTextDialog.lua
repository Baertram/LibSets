local lib = LibSets
local MAJOR, MINOR = lib.name, lib.version
local libPrefix = lib.prefix

local tos = tostring
local strlen = string.len
local tins = table.insert
local tcon = table.concat


local clientLang = lib.clientLang
local langAllowedCheck = lib.LangAllowedCheck

--Maximum number of characters in the text editbox -> more than 200000 won't be shown properly, see XML maxInputCharacters too!
local maxCharactersInTextEditbox = 20000

--The Copydialog
lib.CopyDialog = {}
local copyDialog = lib.CopyDialog
local dialogName = MAJOR:upper() .. "_COPY_TEXT_DIALOG"

------------------------------------------------------------------------------------------------------------------------
--Local helper functions
------------------------------------------------------------------------------------------------------------------------
-- Split text, courtesy of LibOrangUtils, modified to handle multibyte characters
local function str_lensplit(text, maxChars)

    local ret                   = {}
    local text_len              = string.len(text)
    local UTFAditionalBytes = 0
    local fromWithUTFShift  = 0
    local doCut                 = true

    if(text_len <= maxChars) then
        ret[#ret+1] = text
    else

        local splittedStart = 0
        local splittedEnd = splittedStart + maxChars - 1

        local splittedString
        while doCut do

            if UTFAditionalBytes > 0 then
                fromWithUTFShift = UTFAditionalBytes
            else
                fromWithUTFShift = 0
            end

            UTFAditionalBytes = 0

            splittedEnd = splittedStart + maxChars - 1

            if(splittedEnd >= text_len) then
                splittedEnd = text_len
                doCut = false
            elseif (string.byte(text, splittedEnd, splittedEnd)) > 128 then
                UTFAditionalBytes = 1

                local lastByte = splittedString and string.byte(splittedString, -1) or 0
                local beforeLastByte = splittedString and string.byte(splittedString, -2, -2) or 0

                if (lastByte < 128) then
                    --
                elseif lastByte >= 128 and lastByte < 192 then

                    if beforeLastByte >= 192 and beforeLastByte < 224 then
                        --
                    elseif beforeLastByte >= 128 and beforeLastByte < 192 then
                        --
                    elseif beforeLastByte >= 224 and beforeLastByte < 240 then
                        UTFAditionalBytes = 1
                    end

                    splittedEnd = splittedEnd + UTFAditionalBytes
                    splittedString = text:sub(splittedStart, splittedEnd)

                elseif lastByte >= 192 and lastByte < 224 then
                    UTFAditionalBytes = 1
                    splittedEnd = splittedEnd + UTFAditionalBytes
                elseif lastByte >= 224 and lastByte < 240 then
                    UTFAditionalBytes = 2
                    splittedEnd = splittedEnd + UTFAditionalBytes
                end

            end

            --ret = ret+1
            ret[#ret+1] = string.sub(text, splittedStart, splittedEnd)

            splittedStart = splittedEnd + 1

        end
    end
    return ret
end

local function changeCopyDialogPage(copyDialogRef, newIndex)
    if not copyDialogRef then return end
    if not newIndex or newIndex == 0 or newIndex > 1 or newIndex < -1 then return end
    local messageTable = copyDialogRef.messageTable
    if messageTable == nil then return end
    local oldIndex = copyDialogRef.messageTableId
    if oldIndex == nil then return end

    local numPages = tostring(#messageTable)
    copyDialogRef.messageTableId = copyDialogRef.messageTableId + newIndex
    local messageTableId = copyDialogRef.messageTableId
    if messageTable[messageTableId] then
        -- Build button
        local prevButton     = copyDialogRef.prevButton
        local nextButton     = copyDialogRef.nextButton
        local editBox        = copyDialogRef.text
        local prevButtonText = tostring(oldIndex) .. " / " .. numPages
        local nextButtonText = tostring(messageTableId) .. " / " .. numPages
        prevButton:SetText(GetString(SI_LORE_READER_PREVIOUS_PAGE) .. " ( " ..  prevButtonText .. " )")
        nextButton:SetText(GetString(SI_LORE_READER_NEXT_PAGE) .. " ( " ..  nextButtonText .. " )")
        editBox:SetText(messageTable[messageTableId])
        editBox:SetEditEnabled(false)
        editBox:SelectAll()

        -- Don't show prev button if its the first
        if not messageTable[messageTableId - 1] then
            prevButton:SetHidden(true)
        else
            prevButton:SetHidden(false)
        end
        -- Don't show next button if its the last
        if not messageTable[messageTableId + 1] then
            nextButton:SetHidden(true)
        else
            nextButton:SetHidden(false)
        end
        editBox:TakeFocus()
    end
end

------------------------------------------------------------------------------------------------------------------------
--Copy text dialog, with pages (if text is too long for one editbox)
------------------------------------------------------------------------------------------------------------------------
LibSets_CopyTextDialog = ZO_InitializingObject:Subclass()

function LibSets_CopyTextDialog:Initialize(control)
    local selfVar = self
    self.control = control
    control._object = self

    self.dialogName = dialogName
    self.title =    control:GetNamedChild("Title")
    self.text =     control:GetNamedChild("NoteEdit")
    self.prevButton = control:GetNamedChild("Prev")
    self.nextButton = control:GetNamedChild("Next")

    ZO_Dialogs_RegisterCustomDialog(self.dialogName,
        {
            customControl = control,
            title =
            {
                text = libPrefix .. "Copy set \'<<C:1>>\'",
            },
            setup = function(dialog, data)
                selfVar:SetupDialog(control, dialog, data)
            end,
            buttons =
            {
                {
                    control =   GetControl(control, "Close"),
                    text =      SI_DIALOG_EXIT,
                    keybind =   "DIALOG_NEGATIVE",
                },
            },
            --[[
            finishedCallback = function()
            end,
            ]]
        })
end

function LibSets_CopyTextDialog:SetupDialog(control, dialog, data)
    --[Always run this code as dialog's setup function is called]
    local controlWidth = control:GetWidth() - 10
    self.title:SetDimensionConstraints(controlWidth, 75, controlWidth, 75)
    self.title:SetDimensions(controlWidth, 75)

    if dialog == nil or data == nil then return end
    local textForEdit = data.text
    if textForEdit ~= nil then
        --Prefix the editbox text with the set name and ID, as this is missing in the passed in drop locations text
        local setData = data.setData
        if setData ~= nil then
            if setData.nameClean ~= nil then
                textForEdit = setData.nameClean .. "\n".. textForEdit
            elseif setData.name ~= nil then
                textForEdit = setData.name .. "\n".. textForEdit
            end
            if setData.setId ~= nil then
                textForEdit = "[" .. setData.setId .. "]".. textForEdit
            end
        end
        self.textContent = textForEdit
    end
end


function LibSets_CopyTextDialog:IsShown()
    return not self.control:IsHidden()
end

function LibSets_CopyTextDialog:OnShow()
    self:UpdateEditAndButtons()
end

function LibSets_CopyTextDialog:Show(dialogData, textParams)
    if self:IsShown() then return end
    ZO_Dialogs_ShowDialog(self.dialogName, dialogData, textParams)
    self:OnShow()
end


function LibSets_CopyTextDialog:OnHide()
    self.title:SetText("")
    self.text:SetText("")
    self.textContent = nil
    ZO_Dialogs_ReleaseDialog(self.dialogName)
end

function LibSets_CopyTextDialog:Hide()
    if not self:IsShown() then return end
    self.control:SetHidden(true)
    self:OnHide()
end


function LibSets_CopyTextDialog:PreviousPage()
    changeCopyDialogPage(self, -1)
end

function LibSets_CopyTextDialog:NextPage()
    changeCopyDialogPage(self, 1)
end

function LibSets_CopyTextDialog:UpdateEditAndButtons()
    local textContent = self.textContent
    if not textContent then return end

    -- editbox is 20000 chars max
    local editBox = self.text

    --DO not use or the scenes with HUDUI and hud will stay switched after closing the dialog
    --control:SetHidden(false)

    if strlen(textContent) < maxCharactersInTextEditbox then
        editBox:SetText(textContent)

        editBox:SetEditEnabled(false)
        editBox:SelectAll()

        self.prevButton:SetText(GetString(SI_LORE_READER_PREVIOUS_PAGE))
        self.nextButton:SetText(GetString(SI_LORE_READER_NEXT_PAGE))
        self.nextButton:SetHidden(true)
        self.prevButton:SetHidden(true)

        copyDialog.messageTable = nil
        copyDialog.messageTableId = nil
    else
        copyDialog.messageTableId = 1
        copyDialog.messageTable = str_lensplit(textContent, maxCharactersInTextEditbox)

        editBox:SetText(copyDialog.messageTable[copyDialog.messageTableId])
        editBox:SetEditEnabled(false)
        editBox:SelectAll()
        editBox:TakeFocus()

        self.prevButton:SetText(GetString(SI_LORE_READER_PREV_PAGE))
        self.prevButton:SetHidden(true)

        local numPages = #copyDialog.messageTable
        local nextButtonText = tostring(copyDialog.messageTableId) .. " / " .. numPages
        self.nextButton:SetText(GetString(SI_LORE_READER_NEXT_PAGE) .. " ( " ..  nextButtonText .. " )")
        self.nextButton:SetHidden(false)
    end
end


--[[ XML Handlers ]]--
function LibSets_CopyDialog_OnInitialized(dialogControl)
	lib.CopyDialog = LibSets_CopyTextDialog:New(dialogControl)

    copyDialog = lib.CopyDialog
    copyDialog.messageTable = nil
    copyDialog.messageTableId = nil
end
