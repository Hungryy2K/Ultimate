-- Zentrales GUI-Theme für einheitliches, modernes Design

local guiTheme = {
    windowAlpha = 0.92,
    mainColor = {0, 120, 255},
    buttonColor = "FF0078FF",
    buttonHover = "FF00FF00",
    labelColor = {255,255,255},
    fontHeader = "sa-header",
    fontLabel = "default-bold-small",
    closeButtonColor = "FFFF4444",
    closeButtonHover = "FFFF8888",
}

function createStyledWindow(x, y, w, h, title, parent)
    local wnd = guiCreateWindow(x, y, w, h, title, parent or false)
    guiSetAlpha(wnd, guiTheme.windowAlpha)
    guiWindowSetSizable(wnd, false)
    return wnd
end

function createStyledButton(x, y, w, h, text, parent, isClose)
    local btn = guiCreateButton(x, y, w, h, text, parent)
    if isClose then
        guiSetProperty(btn, "NormalTextColour", guiTheme.closeButtonColor)
        guiSetProperty(btn, "HoverTextColour", guiTheme.closeButtonHover)
    else
        guiSetProperty(btn, "NormalTextColour", guiTheme.buttonColor)
        guiSetProperty(btn, "HoverTextColour", guiTheme.buttonHover)
    end
    guiSetFont(btn, guiTheme.fontLabel)
    return btn
end

function createStyledLabel(x, y, w, h, text, parent, isHeader)
    local lbl = guiCreateLabel(x, y, w, h, text, parent)
    if isHeader then
        guiSetFont(lbl, guiTheme.fontHeader)
    else
        guiSetFont(lbl, guiTheme.fontLabel)
    end
    guiLabelSetColor(lbl, unpack(guiTheme.labelColor))
    return lbl
end

return guiTheme 