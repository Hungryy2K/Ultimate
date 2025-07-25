-- ultimate/utility/Logger.lua
-- require("settings.discord_webhooks") entfernt, DiscordWebhooks muss global sein
-- HINWEIS: Discord Webhooks funktionieren nur auf dem Server (fetchRemote benötigt Internetzugang und funktioniert nicht im lokalen MTA-Client/Entwicklungsmodus)
Logger = {}
Logger.__index = Logger

function Logger:new(channel)
    local self = setmetatable({}, Logger)
    self.channel = channel or "General"
    return self
end

function Logger:info(msg)
    outputDebugString("["..self.channel.."][INFO] "..msg)
end

function Logger:warn(msg)
    outputDebugString("["..self.channel.."][WARN] "..msg, 2)
end

function Logger:error(msg)
    outputDebugString("["..self.channel.."][ERROR] "..msg, 1)
end

function Logger:discord(msg, serial, ip)
    if not DiscordWebhooks.enabled then
        outputDebugString("[Logger:discord] DiscordWebhooks ist deaktiviert!")
        return
    end
    local webhookUrl = DiscordWebhooks[self.channel:lower()] or DiscordWebhooks.adminlog
    if not webhookUrl or webhookUrl == "" then
        outputDebugString("[Logger:discord] Kein gültiger Webhook-URL für Channel: "..tostring(self.channel))
        return
    end
    local content = msg
    if serial then
        content = content .. "\nSerial: " .. tostring(serial)
    end
    if ip then
        content = content .. "\nIP: " .. tostring(ip)
    end
    local payload = toJSON({
        username = DiscordWebhooks.defaultUsername or "UltimateBot",
        content = content
    }, true)
    outputDebugString("[Logger:discord] Sende an Webhook: "..tostring(webhookUrl))
    outputDebugString("[Logger:discord] Payload: "..tostring(payload))
    fetchRemote(webhookUrl, function(responseData, errno)
        if errno ~= 0 then
            outputDebugString("[Logger:discord] Discord Webhook Fehler: "..tostring(errno).." Antwort: "..tostring(responseData))
        else
            outputDebugString("[Logger:discord] Discord Webhook erfolgreich gesendet.")
        end
    end, payload, true, { ["Content-Type"] = "application/json" })
end

function Logger:file(msg)
    -- Beispiel: Log in Datei schreiben (Pseudo-Code)
    -- writeToFile(self.channel..".log", msg)
end

-- Beispiel für Warn- und Mute-Logger:
-- local warnLogger = Logger:new("warnlog")
-- warnLogger:discord("WARN: "..getPlayerName(player).." wurde verwarnt. Grund: ...", getPlayerSerial(player), getPlayerIP(player))
-- local muteLogger = Logger:new("mutelog")
-- muteLogger:discord("MUTE: "..getPlayerName(player).." wurde gemutet. Grund: ...", getPlayerSerial(player), getPlayerIP(player))

function sendDiscordAlert(msg, channel, serial, ip)
    local logger = Logger:new(channel)
    logger:discord(msg, serial, ip)
end

Logger = Logger

return Logger 