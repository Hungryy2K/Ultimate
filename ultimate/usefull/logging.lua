-- Zentrale Logging-Utility für das Projekt

local Logger = require("utility.Logger")

local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")
local discordLogger = Logger:new("Discord")

-- Erweiterung: Logging für Admin-Dashboard
adminLogs = adminLogs or {}

function logAdminAction(type, msg, player)
    table.insert(adminLogs, {
        timestamp = getRealTime().timestamp,
        type = type,
        msg = msg,
        player = player and getPlayerName(player) or "SYSTEM"
    })
    -- Optional: Discord-Webhook, Datei, etc.
end

-- Beispiel: Log-Eintrag
-- logAdminAction("BAN", "Spieler Max gebannt", admin)

addEvent("requestAdminLogs", true)
addEventHandler("requestAdminLogs", root, function()
    local player = client or source
    if isAdminLevel and isAdminLevel(player, 3) then
        local logs = {}
        for i = math.max(1, #adminLogs-99), #adminLogs do
            table.insert(logs, adminLogs[i])
        end
        triggerClientEvent(player, "showAdminDashboard", player, logs)
    else
        outputChatBox("Keine Berechtigung!", player, 255, 0, 0)
    end
end)

addCommandHandler("admindashboard", function(player)
    if isAdminLevel and isAdminLevel(player, 3) then
        local logs = {}
        for i = math.max(1, #adminLogs-99), #adminLogs do
            table.insert(logs, adminLogs[i])
        end
        triggerClientEvent(player, "showAdminDashboard", player, logs)
    else
        outputChatBox("Keine Berechtigung!", player, 255, 0, 0)
    end
end)

function logSecurity(msg, player)
    securityLogger:error(msg)
    if player then
        -- Hier könnte man noch player-spezifische Logik ergänzen
    end
end

function sendDiscordAlert(msg, channel, serial, ip)
    local logger
    if channel then
        logger = Logger:new(channel)
    else
        logger = discordLogger
    end
    logger:discord(msg, serial, ip)
end 

-- Kick/Ban Schnellaktionen
addEvent("adminDashboardKick", true)
addEventHandler("adminDashboardKick", root, function(targetName)
    local admin = client or source
    if isAdminLevel and isAdminLevel(admin, 3) then
        local target = getPlayerFromName(targetName)
        if target then
            kickPlayer(target, admin, "Admin-Dashboard Kick")
            logAdminAction("KICK", "Spieler gekickt via Dashboard", admin)
        else
            outputChatBox("Spieler nicht gefunden!", admin, 255, 0, 0)
        end
    end
end)

addEvent("adminDashboardBan", true)
addEventHandler("adminDashboardBan", root, function(targetName)
    local admin = client or source
    if isAdminLevel and isAdminLevel(admin, 3) then
        local target = getPlayerFromName(targetName)
        if target then
            banPlayer(target, admin, "Admin-Dashboard Ban", 0, "", "Permanent")
            logAdminAction("BAN", "Spieler gebannt via Dashboard", admin)
        else
            outputChatBox("Spieler nicht gefunden!", admin, 255, 0, 0)
        end
    end
end)

-- Discord-Export
addEvent("adminDashboardExportDiscord", true)
addEventHandler("adminDashboardExportDiscord", root, function(logs)
    local admin = client or source
    if isAdminLevel and isAdminLevel(admin, 3) then
        -- Hier Discord-Webhook-Aufruf einbauen (Platzhalter):
        local msg = "[Dashboard-Export] "..getPlayerName(admin).." exportiert "..tostring(#logs).." Logs."
        -- discordLogger:discord(msg, getPlayerSerial(admin), getPlayerIP(admin))
        outputChatBox("Export an Discord gesendet! (Platzhalter)", admin, 0, 200, 0)
        logAdminAction("INFO", "Logs nach Discord exportiert", admin)
    end
end)

-- Live-Statistiken
addEvent("requestAdminStats", true)
addEventHandler("requestAdminStats", root, function()
    local admin = client or source
    if isAdminLevel and isAdminLevel(admin, 3) then
        local players = #getElementsByType("player")
        local uptime = getTickCount() // 1000
        local events = 0 -- Hier ggf. echte Event-Zahl einbauen
        local frakOnline = 0 -- Hier ggf. echte Fraktionszahl einbauen
        triggerClientEvent(admin, "showAdminDashboardStats", admin, {
            players = players,
            uptime = string.format("%02d:%02d:%02d", uptime//3600, (uptime%3600)//60, uptime%60),
            events = events,
            frakOnline = frakOnline
        })
    end
end) 