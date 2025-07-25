-- local Logger = require("utility.Logger") entfernt, Logger muss global sein
local securityLogger = Logger:new("Security")

local function isPlayerAllowedToMisfire(player)
    -- Beispiel: Spieler darf nicht im Tutorial oder in einer Safezone sein
    if not isElement(player) then return false end
    if getElementData(player, "inTutorial") then return false end
    if getElementData(player, "inSafezone") then return false end
    -- Weitere Checks nach Bedarf
    return true
end

function misfire ()
    if not isPlayerAllowedToMisfire(client) then
        securityLogger:error("[MISFIRE] Versuch von unberechtigtem Spieler: "..tostring(getPlayerName(client)))
        return
    end
    local x, y, z = getElementPosition ( client )
    createExplosion ( x, y, z, 2, client )
    takeWeapon ( client, getPedWeapon ( client ), 1 )
end
addEvent ( "misfire", true )
addEventHandler ( "misfire", getRootElement(), misfire )