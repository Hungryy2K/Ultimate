-- local Logger = require("utility.Logger") entfernt, Logger muss global sein
local securityLogger = Logger:new("Security")

function gluePlayer(vehicle, x, y, z, rotX, rotY, rotZ)
	if source == client then
		attachElements(source, vehicle, x, y, z, rotX, rotY, rotZ)
		setPedWeaponSlot(source, 0)
		bindKey ( source, "mouse_wheel_up", "down", weaponsup )
		bindKey ( source, "mouse_wheel_down", "down", weaponsdown )
	end
end

local function isPlayerAllowedToGlue(player, vehicle)
    if not isElement(player) or not isElement(vehicle) then return false end
    if getElementType(player) ~= "player" or getElementType(vehicle) ~= "vehicle" then return false end
    if getPedOccupiedVehicle(player) then return false end -- Spieler darf nicht schon im Fahrzeug sitzen
    -- Weitere Checks nach Bedarf
    return true
end

addEvent("gluePlayer", true)
addEventHandler("gluePlayer", root, function(vehicle, x, y, z, rotX, rotY, rotZ)
    if not isPlayerAllowedToGlue(client, vehicle) then
        securityLogger:error("[CODRIVER] Unberechtigter gluePlayer-Versuch: "..tostring(getPlayerName(client)))
        return
    end
	attachElements(source, vehicle, x, y, z, rotX, rotY, rotZ)
	setPedWeaponSlot(source, 0)
	bindKey ( source, "mouse_wheel_up", "down", weaponsup )
	bindKey ( source, "mouse_wheel_down", "down", weaponsdown )
end)

function ungluePlayer()
	if source == client then
		detachElements(source)
		unbindKey ( source, "mouse_wheel_up", "down", weaponsup )
		unbindKey ( source, "mouse_wheel_down", "down", weaponsdown )
	end
end
addEvent("ungluePlayer",true)
addEventHandler("ungluePlayer",root,function()
    if not isElement(client) then return end
	detachElements(source)
	unbindKey ( source, "mouse_wheel_up", "down", weaponsup )
	unbindKey ( source, "mouse_wheel_down", "down", weaponsdown )
end)