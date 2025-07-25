-- Ingame Admin-Dashboard: Live-Logs & Monitoring (erweitert)
-- Nutzt UniversalGUI-Template

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
    local wnd = guiCreateWindow(x, y, w, h, title, parent)
    if not wnd then outputDebugString("[AdminDashboard] Fenster konnte nicht erstellt werden!") end
    guiSetAlpha(wnd, guiTheme.windowAlpha)
    guiWindowSetSizable(wnd, false)
    return wnd
end

function createStyledButton(x, y, w, h, text, parent, isClose)
    local btn = guiCreateButton(x, y, w, h, text, parent)
    if not btn then outputDebugString("[AdminDashboard] Button konnte nicht erstellt werden!"..tostring(text)) end
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
    if not lbl then outputDebugString("[AdminDashboard] Label konnte nicht erstellt werden!"..tostring(text)) end
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

local UniversalGUI = {}
function UniversalGUI.create(opts)
    local sx, sy = guiGetScreenSize()
    local wnd = createStyledWindow(sx*0.4, sy*0.3, sx*0.2, sy*0.3, opts.title or "GUI")
    if not wnd then return end
    -- X-Button oben rechts
    local closeX = createStyledButton(0.95, 0.01, 0.04, 0.06, "✖", wnd, true)
    if closeX then
        guiBringToFront(closeX)
        addEventHandler("onClientGUIClick", closeX, function()
            if opts.onClose then opts.onClose() end
            if isElement(wnd) then destroyElement(wnd) end
            showCursor(false)
            setElementClicked(false)
        end, false)
    end
    local y = 0.08
    if opts.logo then
        guiCreateStaticImage(0.02, y, 0.12, 0.18, opts.logo, true, wnd)
    end
    y = y + 0.22
    -- Labels
    if opts.labels then
        for i, lbl in ipairs(opts.labels) do
            local label = createStyledLabel(0.16, y, 0.7, 0.08, lbl.text, wnd)
            if label and lbl.color then guiLabelSetColor(label, unpack(lbl.color)) end
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
            if button and btn.callback then
                addEventHandler("onClientGUIClick", button, btn.callback, false)
            end
        end
    end
    -- Schließen-Button unten rechts
    local closeBtn = createStyledButton(0.7, 0.88, 0.25, 0.09, "Schließen", wnd, true)
    if closeBtn then
        addEventHandler("onClientGUIClick", closeBtn, function()
            if opts.onClose then opts.onClose() end
            if isElement(wnd) then destroyElement(wnd) end
            showCursor(false)
            setElementClicked(false)
        end, false)
    end
    showCursor(true)
    setElementClicked(true)
    return wnd
end

local lastLogs = {}
local lastStats = {players=0, uptime="-", events=0, frakOnline=0}
local wnd, grid, searchEdit, typeCombo

local function colorRowByType(grid, row, logType)
    if logType == "SECURITY" or logType == "ERROR" then
        for col=1,4 do guiGridListSetItemColor(grid, row, col, 255, 0, 0) end
    elseif logType == "BAN" or logType == "KICK" then
        for col=1,4 do guiGridListSetItemColor(grid, row, col, 255, 128, 0) end
    else
        for col=1,4 do guiGridListSetItemColor(grid, row, col, 255, 255, 255) end
    end
end

local function updateLogGrid()
    if not grid then return end
    guiGridListClear(grid)
    local search = guiGetText(searchEdit):lower()
    local typeIdx = guiComboBoxGetSelected(typeCombo)
    local typeFilter = guiComboBoxGetItemText(typeCombo, typeIdx)
    for i, log in ipairs(lastLogs) do
        local show = true
        if search ~= "" and not (log.player and log.player:lower():find(search)) then
            show = false
        end
        if typeFilter and typeFilter ~= "Alle" and log.type ~= typeFilter then
            show = false
        end
        if show then
            local row = guiGridListAddRow(grid)
            if isElement(grid) then
                guiGridListSetItemText(grid, row, 1, os.date("%H:%M:%S", log.timestamp), false, false)
                guiGridListSetItemText(grid, row, 2, log.type or "-", false, false)
                guiGridListSetItemText(grid, row, 3, log.player or "-", false, false)
                guiGridListSetItemText(grid, row, 4, log.msg or "-", false, false)
                colorRowByType(grid, row, log.type)
            end
            -- Schnellaktionen: Kick/Ban
            if log.player and log.player ~= "SYSTEM" then
                local btnKick = guiCreateButton(0.82, 0.01+row*0.04, 0.07, 0.035, "Kick", true, grid)
                if isElement(btnKick) then
                    addEventHandler("onClientGUIClick", btnKick, function()
                        triggerServerEvent("adminDashboardKick", localPlayer, log.player)
                    end, false)
                end
                local btnBan = guiCreateButton(0.90, 0.01+row*0.04, 0.07, 0.035, "Ban", true, grid)
                if isElement(btnBan) then
                    addEventHandler("onClientGUIClick", btnBan, function()
                        triggerServerEvent("adminDashboardBan", localPlayer, log.player)
                    end, false)
                end
            end
        end
    end
end

function showAdminDashboard(logs, stats)
    lastLogs = logs or lastLogs
    lastStats = stats or lastStats
    if isElement(wnd) then destroyElement(wnd) end
    local sx, sy = guiGetScreenSize()
    wnd = UniversalGUI.create{
        title = "Admin-Dashboard",
        logo = "images/gui/fraktion.png", -- Platzhalter-Icon
        labels = {
            {text = "Live-Logs & Monitoring", color = {255,255,255}},
            {text = "Spieler online: "..tostring(lastStats.players), color = {0,255,0}},
            {text = "Uptime: "..tostring(lastStats.uptime), color = {255,255,255}},
            {text = "Events: "..tostring(lastStats.events), color = {255,255,0}},
            {text = "Fraktionsmitglieder online: "..tostring(lastStats.frakOnline), color = {0,200,255}},
        },
        buttons = {
            {text = "Aktualisieren", callback = function() triggerServerEvent("requestAdminLogs", localPlayer) end},
            {text = "Export nach Discord", callback = function() triggerServerEvent("adminDashboardExportDiscord", localPlayer, lastLogs) end},
        },
        onClose = function() outputChatBox("Dashboard geschlossen!") end
    }
    if not wnd then return end
    -- Filter & Suche
    searchEdit = guiCreateEdit(sx*0.41, sy*0.35, sx*0.09, sy*0.03, "", false, wnd)
    if isElement(searchEdit) then
        guiSetProperty(searchEdit, "PlaceholderText", "Spielername suchen...")
    end
    typeCombo = guiCreateComboBox(sx*0.51, sy*0.35, sx*0.08, sy*0.03, "Alle Typen", false, wnd)
    if isElement(typeCombo) then
        guiComboBoxAddItem(typeCombo, "Alle")
        guiComboBoxAddItem(typeCombo, "BAN")
        guiComboBoxAddItem(typeCombo, "KICK")
        guiComboBoxAddItem(typeCombo, "SECURITY")
        guiComboBoxAddItem(typeCombo, "ERROR")
        guiComboBoxAddItem(typeCombo, "INFO")
        guiComboBoxSetSelected(typeCombo, 0)
    end
    if isElement(searchEdit) then
        addEventHandler("onClientGUIChanged", searchEdit, updateLogGrid, false)
    end
    if isElement(typeCombo) then
        addEventHandler("onClientGUIComboBoxAccepted", typeCombo, updateLogGrid, false)
    end
    -- Logs als GridList anzeigen
    grid = guiCreateGridList(sx*0.41, sy*0.39, sx*0.18, sy*0.3, false, wnd)
    if isElement(grid) then
        guiGridListAddColumn(grid, "Zeit", 0.2)
        guiGridListAddColumn(grid, "Typ", 0.2)
        guiGridListAddColumn(grid, "Spieler", 0.2)
        guiGridListAddColumn(grid, "Nachricht", 0.4)
        updateLogGrid()
    end
end

addEvent("showAdminDashboard", true)
addEventHandler("showAdminDashboard", root, showAdminDashboard)

-- Optional: Command für lokale Tests
addCommandHandler("admindashboard", function()
    showAdminDashboard(lastLogs)
end) 