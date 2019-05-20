LibSets = LibSets or {}

local askBeforeReloadUIDialogEventHandler = "LibSets_ReShowAskBeforeReloadUIDialog"

--Show the ask before reloadui dialog
local function ShowAskBeforeReloadUIDialog()
    ZO_Dialogs_ShowDialog("LIBSETS_ASK_BEFORE_RELOADUI_DIALOG", {})
end

--Show the ask before reloadui dialog again in 10 minutes
local function reShowAksBeforeReloadUIDialog()
    EVENT_MANAGER:UnregisterForUpdate(askBeforeReloadUIDialogEventHandler)
    --Do once after 10 minutes
    EVENT_MANAGER:RegisterForUpdate(askBeforeReloadUIDialogEventHandler, (60*1000) * 10, function()
        EVENT_MANAGER:UnregisterForUpdate(askBeforeReloadUIDialogEventHandler)
        LibSets.ShowAskBeforeReloadUIDialog()
    end)
end

function LibSets.AskBeforeReloadUIDialogInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    local titleText = "LibSets - ReloadUI is needed!"

    ZO_Dialogs_RegisterCustomDialog("LIBSETS_ASK_BEFORE_RELOADUI_DIALOG", {
        customControl = control,
        title = { text = titleText  },
        mainText = { text = "" },
        setup = function(_, data)
            local formattedText = "A reloadui is needed to save the scanned sets to\n the SavedVariables.\nDo you want to reload the UI now?\n\nIf you click \'No\' this popup will occur again in\n10 minutes until you click \'Yes\', or manually do\n a reloadui!"
            descLabel:SetText(formattedText)
        end,
        noChoiceCallback = function()
            --Todo: Re-Register the reloadui dialog again to show in 10 Minutes.
            reShowAksBeforeReloadUIDialog()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    ReloadUI()
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function()
                    --Todo: Re-Register the reloadui dialog again to show in 10 Minutes.
                    reShowAksBeforeReloadUIDialog()
                end,
            },
        },
    })
end