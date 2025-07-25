-- GUI-Theme und UniversalGUI-Template (direkt eingebunden, kein require!)
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

local UniversalGUI = {}
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

-- Wrapper für ein modernes Bank-GUI (nutzt gui_universal_template)
local BankGUI = {}

--[[
BankGUI.show(1500, function(amount)
    outputChatBox("Einzahlung: "..amount)
end, function(amount)
    outputChatBox("Auszahlung: "..amount)
end, function()
    outputChatBox("Bankfenster geschlossen!")
end)
]]

function BankGUI.show(accountBalance, onDeposit, onWithdraw, onClose)
    local sx, sy = guiGetScreenSize()
    local wnd = UniversalGUI.create{
        title = "Bank",
        logo = "images/bank_icon.png",
        labels = {
            {text = "Kontostand: " .. accountBalance .. " $", color = {0,200,0}},
            {text = "Betrag eingeben:", color = {255,255,255}},
        },
        buttons = {}, -- Buttons werden unten hinzugefügt
        onClose = onClose
    }
    -- Eingabefeld für Betrag
    local amountEdit = guiCreateEdit(sx*0.44, sy*0.45, sx*0.12, sy*0.04, "", false, wnd)
    guiSetFont(amountEdit, "default-bold-small")
    -- Einzahlungs-Button
    local depositBtn = createStyledButton(0.18, 0.7, 0.25, 0.13, "Einzahlen", wnd)
    addEventHandler("onClientGUIClick", depositBtn, function()
        local amount = tonumber(guiGetText(amountEdit))
        if amount and amount > 0 then
            if onDeposit then onDeposit(amount) end
        else
            outputChatBox("Bitte gültigen Betrag eingeben!", 255, 0, 0)
        end
    end, false)
    -- Auszahlungs-Button
    local withdrawBtn = createStyledButton(0.57, 0.7, 0.25, 0.13, "Auszahlen", wnd)
    addEventHandler("onClientGUIClick", withdrawBtn, function()
        local amount = tonumber(guiGetText(amountEdit))
        if amount and amount > 0 then
            if onWithdraw then onWithdraw(amount) end
        else
            outputChatBox("Bitte gültigen Betrag eingeben!", 255, 0, 0)
        end
    end, false)
    return wnd
end

return BankGUI 