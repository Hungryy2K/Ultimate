local Logger = require("utility.Logger")
local securityLogger = Logger:new("Security")

addEvent ( "robberJobAccepted", true )
function givePlayerJob ( )
	vioSetElementData ( source, "job", "robber")
	setElementModel ( source, 2 )
end
addEventHandler ( "robberJobAccepted", root, givePlayerJob )

local function isPlayerAllowedToReceiveRobberPay(player)
    -- Beispiel: Spieler muss den Job aktiv haben
    if not isElement(player) then return false end
    if not getElementData(player, "isRobberJobActive") then return false end
    -- Weitere Checks nach Bedarf
    return true
end

addEvent("givePlayerPay", true)
addEventHandler("givePlayerPay", root, function()
    if not isPlayerAllowedToReceiveRobberPay(client) then
        securityLogger:error("[ROBBER] Unberechtigter givePlayerPay-Versuch: "..tostring(getPlayerName(client)))
        return
    end
    money = math.random ( 100, 500 )
	vioSetElementData ( source, "money", vioGetElementData ( source, "money" ) + money )
	outputChatBox ( "Du bist in das Haus eingebrochen und hast verdient: $" ..money, source )
	fadeCamera ( source, false, 1, 0, 0, 0 )
	setTimer ( fadeCamera, 1000, 1, source, true, 1 )
end)