-- ultimate/utility/Logger.lua
local Logger = {}
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

function Logger:discord(msg)
    -- Beispiel: Discord-Webhook-Integration (Pseudo-Code)
    -- triggerDiscordWebhook(self.channel, msg)
end

function Logger:file(msg)
    -- Beispiel: Log in Datei schreiben (Pseudo-Code)
    -- writeToFile(self.channel..".log", msg)
end

return Logger 