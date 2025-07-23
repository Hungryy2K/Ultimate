-- Zentrale Logging-Utility für das Projekt

local Logger = require("utility.Logger")

local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")
local discordLogger = Logger:new("Discord")

function logAdminAction(msg)
    adminLogger:info(msg)
end

function logSecurity(msg, player)
    securityLogger:error(msg)
    if player then
        -- Hier könnte man noch player-spezifische Logik ergänzen
    end
end

function sendDiscordAlert(msg)
    discordLogger:discord(msg)
end 