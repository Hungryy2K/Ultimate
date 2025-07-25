-- Mehrspielerfähiges Fraktionswaffen-GUI: Pro Spieler werden alle relevanten Daten in fgunsData[localPlayer] gespeichert

-- GUI-Theme (direkt eingebunden, statt require)
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
    local wnd = guiCreateWindow(x, y, w, h, title, parent)
    if not wnd then outputDebugString("[FGuns] Fenster konnte nicht erstellt werden!") end
    guiSetAlpha(wnd, guiTheme.windowAlpha)
    guiWindowSetSizable(wnd, false)
    return wnd
end

function createStyledButton(x, y, w, h, text, parent, isClose)
    local btn = guiCreateButton(x, y, w, h, text, parent)
    if not btn then outputDebugString("[FGuns] Button konnte nicht erstellt werden!"..tostring(text)) end
    if isElement(btn) then
        if isClose then
            guiSetProperty(btn, "NormalTextColour", guiTheme.closeButtonColor)
            guiSetProperty(btn, "HoverTextColour", guiTheme.closeButtonHover)
        else
            guiSetProperty(btn, "NormalTextColour", guiTheme.buttonColor)
            guiSetProperty(btn, "HoverTextColour", guiTheme.buttonHover)
        end
        guiSetFont(btn, guiTheme.fontLabel)
    end
    return btn
end

function createStyledLabel(x, y, w, h, text, parent, isHeader)
    local lbl = guiCreateLabel(x, y, w, h, text, parent)
    if not lbl then outputDebugString("[FGuns] Label konnte nicht erstellt werden!"..tostring(text)) end
    if isElement(lbl) then
        if isHeader then
            guiSetFont(lbl, guiTheme.fontHeader)
        else
            guiSetFont(lbl, guiTheme.fontLabel)
        end
        guiLabelSetColor(lbl, unpack(guiTheme.labelColor))
    end
    return lbl
end

local fgunsData = {}

local Moneycost = {
	[1] = 100,
	[2] = 200,
	[3] = 300,
	[4] = 300,
	[5] = 300,
	[6] = 300,
	[7] = 400,
	[8] = 1500,
	[9] = 2000
}

local Matscost = {
	[1] = 10,
	[2] = 20,
	[3] = 30,
	[4] = 30,
	[5] = 30,
	[6] = 30,
	[7] = 40,
	[8] = 150,
	[9] = 200
}

function createFgunsGui(therank, thefrac)
    local player = localPlayer
    fgunsData[player] = fgunsData[player] or {GUIEditor = {button = {}, window = {}, label = {}, image = {}}, buttonID = {}}
    local data = fgunsData[player]
    local sx, sy = guiGetScreenSize()
    -- Modernes zentriertes Fenster
    data.GUIEditor.window[1] = createStyledWindow(sx*0.35, sy*0.2, sx*0.3, sy*0.5, "Fraktionslager")
    if not isElement(data.GUIEditor.window[1]) then outputDebugString("[FGuns] Fenster konnte nicht erstellt werden!") return end
    guiBringToFront(data.GUIEditor.window[1])
    showCursor(true)
    setElementClicked(true)
    -- Fraktionslogo oben links (optional, Beispielbild)
    data.GUIEditor.image[1] = guiCreateStaticImage(0.02, 0.06, 0.12, 0.18, "images/faction_logo.png", true, data.GUIEditor.window[1])
    if not isElement(data.GUIEditor.image[1]) then outputDebugString("[FGuns] Image konnte nicht erstellt werden!") end
    -- Waffen-Buttons und Labels
    local yStart = 0.25
    local yStep = 0.13
    local xBtn = 0.18
    local wBtn, hBtn = 0.6, 0.1
    local btnIdx = 1
    local labelIdx = 1
    local weaponNames = { [1]="Nahkampf", [2]="Deagle", [3]="Mp5", [4]="Spezial", [5]="Gewehr", [6]="AK47", [7]="M4", [8]="Sniper", [9]="Raketenwerfer" }
    for i=1,math.min(9,therank+4) do
        local btnY = yStart + (btnIdx-1)*yStep
        data.GUIEditor.button[i] = createStyledButton(xBtn, btnY, wBtn, hBtn, weaponNames[i] or ("Waffe "..i), data.GUIEditor.window[1])
        if isElement(data.GUIEditor.button[i]) then
            data.buttonID[data.GUIEditor.button[i]] = i
            addEventHandler("onClientGUIClick", data.GUIEditor.button[i], function(...) sendTheWeaponFromFGunsToServer(player, ...) end, false)
        end
        -- Preis- und Mats-Label unter dem Button
        data.GUIEditor.label[labelIdx] = createStyledLabel(xBtn, btnY+hBtn+0.01, wBtn/2, 0.05, Moneycost[i].."$", data.GUIEditor.window[1])
        if isElement(data.GUIEditor.label[labelIdx]) then guiLabelSetColor(data.GUIEditor.label[labelIdx], 0, 200, 0) end
        labelIdx = labelIdx + 1
        data.GUIEditor.label[labelIdx] = createStyledLabel(xBtn+wBtn/2, btnY+hBtn+0.01, wBtn/2, 0.05, Matscost[i].." Mats", data.GUIEditor.window[1])
        if isElement(data.GUIEditor.label[labelIdx]) then guiLabelSetColor(data.GUIEditor.label[labelIdx], 200, 200, 0) end
        labelIdx = labelIdx + 1
        btnIdx = btnIdx + 1
    end
    -- Schließen-Button unten rechts
    data.GUIEditor.button[99] = createStyledButton(0.7, 0.88, 0.25, 0.09, "Schließen", data.GUIEditor.window[1], true)
    if isElement(data.GUIEditor.button[99]) then
        addEventHandler("onClientGUIClick", data.GUIEditor.button[99], function(...) closeFgunsGui(player, ...) end, false)
    end
end
addEvent("startFgunsGui", true)
addEventHandler("startFgunsGui", getRootElement(), createFgunsGui)

function sendTheWeaponFromFGunsToServer(player, button, state)
    local data = fgunsData[player]
    if button == "left" and state == "up" then
        triggerServerEvent("giveFgunsWeapon", lp, guiGetText(source), Moneycost[data.buttonID[source]], Matscost[data.buttonID[source]])
    end
end

function closeFgunsGui(player, button, state)
    local data = fgunsData[player]
    if button == "left" and state == "up" then
        showCursor(false)
        setElementClicked(false)
        for i, button in pairs(data.GUIEditor.button) do
            if isElement(button) then destroyElement(button) end
            data.GUIEditor.button[i] = nil
        end
        for i, label in pairs(data.GUIEditor.label) do
            if isElement(label) then destroyElement(label) end
            data.GUIEditor.label[i] = nil
        end
        for i, img in pairs(data.GUIEditor.image) do
            if isElement(img) then destroyElement(img) end
            data.GUIEditor.image[i] = nil
        end
        if isElement(data.GUIEditor.window[1]) then destroyElement(data.GUIEditor.window[1]) end
        data.GUIEditor.window[1] = nil
    end
end
				
				