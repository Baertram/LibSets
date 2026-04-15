local lib = LibSets
--local MAJOR, MINOR = lib.name, lib.version
--local libPrefix = lib.prefix

local tos = tostring


--The search UI table
local searchUI = lib.SearchUI
local searchUIKeyboardVars    = searchUI.KeyboardVars
local TLC_SEARCH_UI_MIN_WIDTH =   searchUIKeyboardVars.minWidth
local TLC_SEARCH_UI_MIN_HEIGHT=  searchUIKeyboardVars.minHeight


--[[ XML API functions ]]--
--LibSets.XMLGetDynamicMinWidth - Calculate the minimum width based on the width of the TopLevelControl
function lib.XMLGetDynamicWidth(XMLcontrol, minWidth, maxWidth, applyValues, minHeight, maxHeight, forceMaxWidth)
    minHeight = minHeight or 10
    maxHeight = maxHeight or 30
    applyValues = applyValues or false
    forceMaxWidth = forceMaxWidth or false
--d("[LibSets]XMLGetDynamicMinWidth - XMLControl: " .. tos(XMLcontrol:GetName()) .. ", minWidth: " .. tos(minWidth) .. ", maxWidth: " .. tos(maxWidth) .. ", applyValues: " ..tos(applyValues) .. ", forceMaxWidth: " .. tos(forceMaxWidth))
    if XMLcontrol == nil then return end

    local newWidth = 0

    --XMLControl's TopLevelControl
    local tlcOfXMLControl = XMLcontrol:GetOwningWindow()
    if tlcOfXMLControl == nil then return end

    local minWidthValue, maxWidthValue

    --d(">TLControl: " .. tos(tlcOfXMLControl:GetName()))

    local factorMultiplier = XMLcontrol.factorMultiplier or 1

    --XML Control's minX and maxX have been set or future usage in this API function?
    if minWidth == nil then
        minWidth = XMLcontrol.minX
        if minWidth == nil then return end
    end
    if maxWidth == nil then
        maxWidth = XMLcontrol.maxX
    end

--d(">>minWidthNow: " .. tos(minWidth) .. "; maxWidthNow: " ..tos(maxWidth))

    --XML Control's minimum width
    local minWidthType = type(minWidth)
    if minWidthType == "function" then
        minWidthValue = minWidth(XMLcontrol)  --must return a number
    elseif minWidthType == "string" then
        minWidthValue = minWidth
    elseif minWidthType == "number" then
        minWidthValue = minWidth
    end

    --No TLC width determined -> Use passed in minWidth instead
    local tlcWidth = tlcOfXMLControl:GetWidth()
--d(">>tlcWidth: " .. tos(tlcWidth) .. "; minWidthValue: " ..tos(minWidthValue) .. "; minWidthType: " ..tos(minWidthType) .."; TLCMinWidth: " ..tos(TLC_SEARCH_UI_MIN_WIDTH))
    if tlcWidth == nil or tlcWidth <= 0 then
--d("<<ABORT tlcWidth")
        return minWidthValue
    end

        --Calculate the minimum width now: If TLC's width is bigger than the default minimum width then we calculate the
    --actual XML control's width according to that (with a factor)
    if minWidthValue ~= nil then
        if minWidthType == "string" then
            newWidth = minWidthValue
        else
            if minWidthValue < 0 then minWidthValue = 0 end
            --Was the TLC control's size changed > the usual width? Calucalte how much it was resized, using a factor
            --CurrentTLCWidth divided by TLCdefaultMinimumWidth
            if tlcWidth > TLC_SEARCH_UI_MIN_WIDTH then
                local calculationFactor = (zo_clamp(tlcWidth / TLC_SEARCH_UI_MIN_WIDTH, 1, 10)) * factorMultiplier --max factor *10
--d(">>calculated factor: " .. tos(calculationFactor) .. ", widthFactorCalcBase: " ..tos(tlcWidth / TLC_SEARCH_UI_MIN_WIDTH) .. "; factorMultiplier: " .. tos(factorMultiplier))
                newWidth = zo_clamp(minWidthValue * calculationFactor, minWidthValue, tlcWidth) --the minimum size multiplied by the factor = new desired width
            else
--d(">>using minWidthValue")
                newWidth = minWidthValue
            end
        end
--d(">newWidth: " .. tos(newWidth))
    end

    --Check if maxWidth was given, then check if our cotrol would be wider now, and resize to the maximum width then
    --XML Control's maxmum width
    if maxWidth ~= nil then
        local maxWidthType = type(maxWidth)
        if maxWidthType == "function" then
            maxWidthValue = maxWidth(XMLcontrol) --must return a number
        elseif maxWidthType == "string" then
            maxWidthValue = maxWidth
--d("[------ MAX WIDTH = String")
            if zo_plainstrfind(maxWidthValue, "calcByTLCWidth,") ~= nil then
                --Get the value behind the , (usually a negative value)
                local value = tonumber(string.sub(maxWidthValue, 16))
--d(">>found calcByTLCWidth, value: " .. tos(value))
                if type(value) == "number" then
                    maxWidthValue = tlcWidth + value
                    maxWidthType = "number"
                end
            end

        elseif maxWidthType == "number" then
            maxWidthValue = maxWidth
        end
        if maxWidthValue ~= nil and maxWidthType ~= "string" then
            newWidth = zo_clamp(newWidth, minWidthValue, maxWidthValue)
--d(">newWidth changed due to maxWidth: " .. tos(newWidth) .. ", maxWidth: " .. tos(maxWidthValue))
        end
    end

    --Apply the new width to the XML control now?
    if applyValues then
        if XMLcontrol.SetDimensionConstraints then
--d("!>>Applying newWidth " ..tos(newWidth) .." to the control now, maxWidthValue: " ..tos(maxWidthValue))
            XMLcontrol:SetDimensionConstraints(newWidth, minHeight, (not forceMaxWidth and newWidth) or maxWidthValue, maxHeight) --minX, minY, maxX, maxY
        end
    end
    return newWidth
end