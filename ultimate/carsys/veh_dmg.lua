function veh_indestr_func (loss)

	if not getVehicleOccupant ( source, 0 ) then
		setElementHealth ( source, getElementHealth ( source ) + loss )
	end
	-- Discord Car-Damage Log
	local driver = getVehicleOccupant(source, 0)
	if driver then
		local carDamageLogger = Logger:new("cardamage")
		local weapon = getPedWeapon(driver) or "unbekannt"
		carDamageLogger:discord("CARDAMAGE: "..getPlayerName(driver).." (Serial: "..tostring(getPlayerSerial(driver))..", IP: "..tostring(getPlayerIP(driver))..") hat Fahrzeug (Modell: "..tostring(getElementModel(source))..") Schaden zugefügt: "..tostring(loss).." mit Waffe: "..tostring(weapon), getPlayerSerial(driver), getPlayerIP(driver))
	end
end
addEventHandler ( "onVehicleDamage", getRootElement(), veh_indestr_func )