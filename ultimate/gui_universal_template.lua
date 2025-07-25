-- Universelles GUI-Template für moderne, einheitliche GUIs im Projekt
-- Nutzt gui_theme.lua für Farben, Fonts und Styles
-- Beispielnutzung siehe unten!

local guiTheme = require("gui_theme")

local UniversalGUI = {}

--[[
UniversalGUI.create(
    {
        title = "Fenstertitel",
        logo = "images/logo.png", -- optional, nil wenn kein Logo
        buttons = {
            {text = "Kaufen", callback = function() ... end},
            {text = "Verkaufen", callback = function() ... end},
        },
        labels = {
            {text = "Preis: 100$", color = {0,200,0}},
            {text = "Info: ...", color = {255,255,255}},
        },
        onClose = function() ... end -- optional
    }
)
]]

function UniversalGUI.create(opts)
    local sx, sy = guiGetScreenSize()
    local wnd = createStyledWindow(sx*0.4, sy*0.3, sx*0.2, sy*0.3, opts.title or "GUI")
    local y = 0.08
    if opts.logo then
        guiCreateStaticImage(0.02, y, 0.12, 0.18, opts.logo, true, wnd)
    end
    y = y + 0.22
    -- Labels
    if opts.labels then
        for i, lbl in ipairs(opts.labels) do
            local label = createStyledLabel(0.16, y, 0.7, 0.08, lbl.text, wnd)
            if lbl.color then guiLabelSetColor(label, unpack(lbl.color)) end
            y = y + 0.09
        end
    end
    -- Buttons
    local btnY = 0.7
    local btnW, btnH = 0.3, 0.15
    if opts.buttons then
        local btnCount = #opts.buttons
        local btnSpacing = 0.05
        local totalW = btnCount*btnW + (btnCount-1)*btnSpacing
        local xStart = 0.5 - totalW/2
        for i, btn in ipairs(opts.buttons) do
            local x = xStart + (i-1)*(btnW+btnSpacing)
            local button = createStyledButton(x, btnY, btnW, btnH, btn.text, wnd)
            if btn.callback then
                addEventHandler("onClientGUIClick", button, btn.callback, false)
            end
        end
    end
    -- Schließen-Button unten rechts
    local closeBtn = createStyledButton(0.7, 0.88, 0.25, 0.09, "Schließen", wnd, true)
    addEventHandler("onClientGUIClick", closeBtn, function()
        if opts.onClose then opts.onClose() end
        if isElement(wnd) then destroyElement(wnd) end
        showCursor(false)
        setElementClicked(false)
    end, false)
    showCursor(true)
    setElementClicked(true)
    return wnd
end

return UniversalGUI 