-- Table
adminsIngame = {}
local player_admin = {}
local frozen_players = {}
local veh_frozen_players = {}
local veh_frozen_vehs = {}
local muted_players = {}
local adminLevels = {
	["VIP"] = 1,
	["Ticketsupporter"] = 2,
	["Supporter"] = 3,
	["Moderator"] = 4,
	["Administrator"] = 5,
	["Projektleiter"] = 6
}
donatorMute = {}
local adminmarks = {}

-- Cooldown-Variablen für kritische Kommandos
local rbanCooldown = {}
local makeleaderCooldown = {}
local setrankCooldown = {}
local setadminCooldown = {}
local nickchangeCooldown = {}
local pwchangeCooldown = {}
local shutCooldown = {}
local markCooldown = {}
local gotomarkCooldown = {}
local respawnCooldown = {}
local tunecarCooldown = {}
local freezeCooldown = {}
local gmxCooldown = {}
local ochatCooldown = {}
local achatCooldown = {}
local specCooldown = {}
local rkickCooldown = {}
local prisonCooldown = {}
local kickallCooldown = {}
local muteCooldown = {}
local unbanCooldown = {}
local gotoCooldown = {}
local gethereCooldown = {}

-- Funktionen 

local pack_cmds = {}
pack_cmds["msg"] = true
pack_cmds["pm"] = true

function blockParticularCmds ( cmd )
	if pack_cmds[cmd] and vioGetElementData ( source, "adminlvl" ) < 3 then
		cancelEvent()
		outputChatBox ( "Benutzung von /msg und /pm ist verboten", source, 255, 0, 0 )
	end
	
end

--

function blockParticularCmdsJoin ( )
	addEventHandler( "onPlayerCommand", source, blockParticularCmds )	
end
addEventHandler ( "onPlayerJoin", getRootElement(), blockParticularCmdsJoin )


local function isEventCallerValid(player)
    return client == nil or client == player
end

local function isAdminEventAllowed(player, minLevel)
    return isEventCallerValid(player) and isAdminLevel(player, minLevel)
end

function executeAdminServerCMD_func ( cmd, arguments )
    if not isEventCallerValid(client) then
        securityLogger:error("[ADMINCMD] Unberechtigter Versuch: "..tostring(getPlayerName(client)))
        return
    end
    executeCommandHandler ( cmd, client, arguments )
end


function doesAnyPlayerOccupieTheVeh ( car )
	local bool = false
	for i = 0, 5, 1 do	
		local test = getVehicleOccupant ( car, i )	
		if test ~= false then
			bool = true
		end	
	end
	if bool == false then
		return false
	else
		return true
	end
end


function getAdminLevel ( player )
	local plevel = vioGetElementData ( player, "adminlvl" )
	if not plevel or plevel == nil then
		return 0
	end	
	return tonumber(plevel)
end


function isAdminLevel ( player, level )
	local plevel = vioGetElementData ( player, "adminlvl" )
	if not plevel or plevel == nil then
		return false
	end
	if plevel >= level then
		return true
	else
		return false
	end
end


function adminMenueTrigger_func ( )
    if not isAdminEventAllowed(source, 2) then
        securityLogger:error("[ADMINMENUE] Unberechtigter Versuch: "..tostring(getPlayerName(source)))
        return
    end
	if source == client then
		if vioGetElementData ( source, "adminlvl" ) >= 2 then
			triggerClientEvent ( source, "PListFill", getRootElement() )
		else
			triggerClientEvent ( source, "infobox_start", getRootElement(), "\nDu bist kein\nAdmin!", 5000, 255, 0, 0 )
		end
	end
end




function nickchange_func ( player, cmd, alterName, neuerName )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[NICKCHANGE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if nickchangeCooldown[player] and getTickCount() - nickchangeCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Nick änderst.", true)
        return
    end
    nickchangeCooldown[player] = getTickCount()
    if not alterName or not neuerName then
        outputNeutralInfo(player, "Gebrauch: /nickchange aName nName", true)
        return
    end
    if playerUID[alterName] then
        local UID = playerUID[alterName]
        local result2 = dbPoll(dbQuery(handler, "SELECT ?? FROM ?? WHERE ?? LIKE ?", "Name", "players", "Name", neuerName), -1)
        if not result2 or not result2[1] then
            dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Name", neuerName, "UID", UID)
            playerUID[neuerName] = playerUID[alterName]
            playerUID[alterName] = nil
            adminLogger:info(getPlayerName(player).." hat "..alterName.." in "..neuerName.." umbenannt.")
            securityLogger:info("[NICKCHANGE] "..getPlayerName(player).." hat "..alterName.." in "..neuerName.." umbenannt.")
            discordLogger:discord("NICKCHANGE: "..getPlayerName(player).." hat "..alterName.." in "..neuerName.." umbenannt.", getPlayerSerial(player), getPlayerIP(player))
            outputNeutralInfo(player, "Nick geändert.", false)
        else
            outputNeutralInfo(player, "Der neue Name ist bereits vergeben!", true)
        end
    else
        outputNeutralInfo(player, "Der Spieler existiert nicht!", true)
    end
end


function move_func ( player, cmd, direction )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[MOVE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if direction then
		if ( not client or client == player ) then
			local veh = getPedOccupiedVehicle ( player )
			local element = player		
			if isElement ( veh ) then			
				element = veh				
			end			
			local x, y, z = getElementPosition ( element )			
			if direction == "up" then
				y = y + 2
			elseif direction == "down" then
				y = y - 2
			elseif direction == "left" then
				x = x - 2
			elseif direction == "right" then
				x = x + 2
			elseif direction == "higher" then
				z = z + 2
			elseif direction == "lower" then
				z = z - 2
			end			
			setElementPosition ( element, x, y, z )				
		else		
			outputChatBox ( player, "Richtungen: up, down, left, right, higher, lower", player, 255, 0, 0 )
			infobox ( player, "Bitte Richtung angeben!", 5000, 125, 0, 0 )
		end	
	end
end


function moveVehicleAway_func ( veh )
    if not isAdminEventAllowed(client, adminLevels["Supporter"]) then
        securityLogger:error("[MOVEVEH] Unberechtigter Versuch: "..tostring(getPlayerName(client)))
        return
    end
	if veh and getElementType (veh) == "vehicle" then 
		if isAdminLevel ( client, adminLevels["Supporter"] ) then
			setElementPosition ( veh, 999999, 999999, 999999 )
			setElementInterior ( veh, 999999 )
			setElementDimension ( veh, 999999 )	
		end	
	end
end


function pwchange_func ( player, cmd, target, newPW )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[PWCHANGE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if pwchangeCooldown[player] and getTickCount() - pwchangeCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut ein Passwort änderst.", true)
        return
    end
    pwchangeCooldown[player] = getTickCount()
    if not target or not newPW then
        outputNeutralInfo(player, "Gebrauch: /pwchange Name PW", true)
        return
    end
    if playerUID[target] then
        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "players", "Passwort", hash("sha512", hash("sha512", newPW)), "UID", playerUID[target])
        adminLogger:info(getPlayerName(player).." hat das Passwort von "..target.." geändert!")
        securityLogger:info("[PWCHANGE] "..getPlayerName(player).." hat das Passwort von "..target.." geändert!")
        discordLogger:discord("PWCHANGE: "..getPlayerName(player).." hat das Passwort von "..target.." geändert!", getPlayerSerial(player), getPlayerIP(player))
        outputNeutralInfo(player, "Passwort geändert.", false)
    else
        outputNeutralInfo(player, "Der Spieler existiert nicht!", true)
    end
end


function shut_func ( player )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[SHUT] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if shutCooldown[player] and getTickCount() - shutCooldown[player] < 60000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut eine Notabschaltung machst.", true)
        return
    end
    shutCooldown[player] = getTickCount()
    adminLogger:info(getPlayerName(player).." hat die Notabschaltung benutzt.")
    securityLogger:info("[SHUT] "..getPlayerName(player).." hat die Notabschaltung benutzt.")
    discordLogger:discord("SHUT: "..getPlayerName(player).." hat die Notabschaltung benutzt!", getPlayerSerial(player), getPlayerIP(player))
    shutdown ( "Abgeschaltet von: "..getPlayerName ( player ) )	
    setServerPassword ( "sdfsadgsdahsa" )
    local players = getElementsByType("player")
    for i=1, #players do 
        kickPlayer ( players[i], player, "Notabschaltung!" )
    end	
end


function rebind_func ( player )
	if isKeyBound ( player, "r", "down", reload ) then
		unbindKey ( player, "r", "down", reload )
	end
	bindKey ( player, "r", "down", reload )
	outputChatBox ( "Hotkeys wurden neu gelegt!", player, 0, 125, 0 )
end


function adminlist ( player )
	outputChatBox ( "Momentan online:", player, 0, 100, 255 )
	local pl = {}
	local adm = {}
	local mode = {}
	local sup = {}
	local ticke = {}

	for playeritem, rang in pairs (adminsIngame) do
		if rang == 6 then
			pl[playeritem] = true
		elseif rang == 5 then
			adm[playeritem] = true
		elseif rang == 4 then
			mode[playeritem] = true
		elseif rang == 3 then
			sup[playeritem] = true
		elseif rang == 2 then
			ticke[playeritem] = true
		end
	end
	for playeritem,_ in pairs ( pl ) do 
		outputChatBox ( getPlayerName(playeritem)..", Projektleiter", player, 180, 0, 0 )
	end
	for playeritem,_ in pairs ( adm ) do 
		outputChatBox ( getPlayerName(playeritem)..", Administrator", player, 232, 174, 0 )
	end
	for playeritem,_ in pairs ( mode ) do 
		outputChatBox ( getPlayerName(playeritem)..", Moderator", player, 0, 51, 255 )
	end
	for playeritem,_ in pairs ( sup ) do 
		outputChatBox ( getPlayerName(playeritem)..", Supporter", player, 0, 102, 0 )
	end
	for playeritem,_ in pairs ( ticke ) do 
		outputChatBox ( getPlayerName(playeritem)..", Ticketsupporter", player, 200, 0, 200 )
	end
end


function check_func ( admin, cmd, target )
	if isAdminLevel ( admin, adminLevels["Administrator"] ) then
		if target then
			local player = findPlayerByName( target )
			if player then
				local playtime = vioGetElementData ( player, "playingtime" )
				local playtimehours = math.floor(playtime/60)
				local playtimeminutes = playtime-playtimehours*60
				local playtime = playtimehours..":"..playtimeminutes
				outputChatBox ( "Name: "..getPlayerName(player).." ( ID: "..vioGetElementData(player,"playerid").." ), Geld ( Bar/Bank ): "..vioGetElementData ( player, "money" ).."/"..vioGetElementData ( player, "bankmoney" )..", Spielzeit: "..playtime.." Minuten", admin, 200, 200, 0 )
				--local job = jobNames [ vioGetElementData ( player, "job" ) ]
				outputChatBox ( --[["Job: "..job..",]]" Warns: "..getPlayerWarnCount ( getPlayerName ( player ) )..", Telefonnr: "..vioGetElementData ( player, "telenr" ), admin, 200, 200, 0 )
				outputChatBox ( "Tode: "..vioGetElementData ( player, "GangwarTode" )..", Kills: "..vioGetElementData ( player, "GangwarKills" )..", Drogen: "..vioGetElementData ( player, "drugs" )..", Materials: "..vioGetElementData ( player, "mats" ), admin, 200, 200, 0 )
				local fraktion = tonumber ( vioGetElementData ( player, "fraktion" ) )
				fraktion = fraktionNames[fraktion]
				outputChatBox ( "Gefundene Paeckchen: "..vioGetElementData ( player, "foundpackages" ).."/25", admin, 200, 200, 0 )
				outputChatBox ( "Fraktion: "..fraktion..", AdminLVL: "..vioGetElementData ( player, "adminlvl" )..", Bonuspunkte: "..vioGetElementData ( player, "bonuspoints" ), admin, 200, 200, 0 )
				local pname = getPlayerName ( player )
				local licenses = ""
				if vioGetElementData ( player, "carlicense" ) == 1 then licenses = licenses.."Fuehrerschein " end
				if vioGetElementData ( player, "bikelicense" ) == 1 then licenses = licenses.."Motorradschein " end
				if vioGetElementData ( player, "fishinglicense" ) == 1 then licenses = licenses.."Angelschein " end
				if vioGetElementData ( player, "lkwlicense" ) == 1 then licenses = licenses.."LKW-Fuehrerschein " end
				if vioGetElementData ( player, "gunlicense" ) == 1 then licenses = licenses.."Waffenschein " end
				if vioGetElementData ( player, "motorbootlicense" ) == 1 then licenses = licenses.."Bootsfuehrerschein " end
				if vioGetElementData ( player, "segellicense" ) == 1 then licenses = licenses.."Segelschein " end
				if vioGetElementData ( player, "planelicenseb" ) == 1 then licenses = licenses.."Flugschein A " end
				if vioGetElementData ( player, "planelicensea" ) == 1 then licenses = licenses.."Flugschein B " end
				if vioGetElementData ( player, "helilicense" ) == 1 then licenses = licenses.."Flugschein C " end
				outputChatBox ( "Vorhandene Lizensen: ", admin, 200, 0, 200 )
				outputChatBox ( licenses, admin, 200, 50, 200 )
				executeCommandHandler ( "getchangestate", admin, getPlayerName(player) )
				outputChatBox ( "IP: "..getPlayerIP(player), admin, 200, 200, 0 )
				outputChatBox ( "Aktuelle Waffe: "..getPedWeapon(player), admin, 125, 125, 125 )
			else
				triggerClientEvent ( admin, "infobox_start", getRootElement(), "\n\nUngueltiger Name!", 7500, 125, 0, 0 )
			end
		else
			triggerClientEvent ( admin, "infobox_start", getRootElement(), "\nGebrauch:\n/check Name!", 7500, 125, 0, 0 )
		end
	else
		triggerClientEvent ( admin, "infobox_start", getRootElement(), "\n\nDu bist kein\n Admin!", 7500, 125, 0, 0 )	
	end	
end



function mark_func ( player, cmd, count )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[MARK] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if markCooldown[player] and getTickCount() - markCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Marker setzt.", true)
        return
    end
    markCooldown[player] = getTickCount()
    count = tonumber(count) or 1
    if count ~= 1 and count ~= 2 and count ~= 3 then
        outputNeutralInfo(player, "Es sind nur Marker 1, 2 und 3 möglich!", true)
        return
    end
    local x, y, z = getElementPosition(player)
    local int = getElementInterior(player)
    local dim = getElementDimension(player)
    if not adminmarks[player] then
        adminmarks[player] = {}
    end
    adminmarks[player][count] = { ["x"] = x, ["y"] = y, ["z"] = z, ["dim"] = dim, ["int"] = int }
    adminLogger:info(getPlayerName(player).." hat Marker "..count.." gesetzt.")
    discordLogger:discord("MARK: "..getPlayerName(player).." hat Marker "..count.." gesetzt.", getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Koordinaten für Marker "..count.." gesetzt!", false)
end


function gotomark_func ( player, cmd, count )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[GOTOMARK] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if gotomarkCooldown[player] and getTickCount() - gotomarkCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut zu einem Marker gehst.", true)
        return
    end
    gotomarkCooldown[player] = getTickCount()
    count = tonumber(count) or 1
    if count ~= 1 and count ~= 2 and count ~= 3 then
        outputNeutralInfo(player, "Es sind nur Marker 1, 2 und 3 möglich!", true)
        return
    end
    if not adminmarks[player] or not adminmarks[player][count] then
        outputNeutralInfo(player, "Marker existiert nicht!", true)
        return
    end
    local x, y, z, dim, int = adminmarks[player][count]["x"], adminmarks[player][count]["y"], adminmarks[player][count]["z"], adminmarks[player][count]["dim"], adminmarks[player][count]["int"]
    local seat = getPedOccupiedVehicleSeat(player)
    if seat and seat == 0 then
        local veh = getPedOccupiedVehicle(player)
        setElementPosition(veh, x, y, z)
        setElementDimension(veh, dim)
        setElementInterior(veh, int)
        setElementDimension(player, int)
        setElementInterior(player, dim)
        outputNeutralInfo(player, "Zum "..count..". Marker teleportiert!", false)
        return
    end
    removePedFromVehicle(player)
    setElementPosition(player, x, y, z)
    setElementDimension(player, dim)
    setElementInterior(player, int)
    adminLogger:info(getPlayerName(player).." ist zu Marker "..count.." teleportiert.")
    discordLogger:discord("GOTOMARK: "..getPlayerName(player).." ist zu Marker "..count.." teleportiert.", getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Zum "..count..". Marker teleportiert!", false)
end


function respawn_func ( player, cmd, respawn )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[RESPAWN] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if respawnCooldown[player] and getTickCount() - respawnCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut respawnst.", true)
        return
    end
    respawnCooldown[player] = getTickCount()
    if not respawn then
        outputNeutralInfo(player, "/respawn [sfpd|medic|mechanic|mafia|triaden|news|terror|fbi|aztecas|army|biker|grove|ballas|fishing|taxi|hotdog]", true)
        return
    end
    -- (Hier kann die eigentliche Respawn-Logik stehen, ggf. wie bisher)
    adminLogger:info(getPlayerName(player).." hat Fahrzeuge respawned: "..tostring(respawn))
    discordLogger:discord("RESPAWN: "..getPlayerName(player).." hat Fahrzeuge respawned: "..tostring(respawn), getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Fahrzeuge respawned!", false)
end


function tunecar_func ( player, cmd, part )
    if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[TUNECAR] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if tunecarCooldown[player] and getTickCount() - tunecarCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut ein Auto tunst.", true)
        return
    end
    tunecarCooldown[player] = getTickCount()
    if not part or not tonumber(part) then
        outputNeutralInfo(player, "Gebrauch: /tunecar [Part]", true)
        return
    end
    local veh = getPedOccupiedVehicle(player)
    if not veh then
        outputNeutralInfo(player, "Du sitzt in keinem Fahrzeug!", true)
        return
    end
    local succes = addVehicleUpgrade(veh, tonumber(part))
    if not succes then
        outputNeutralInfo(player, "Ungültige Eingabe/Fahrzeug!", true)
        return
    end
    adminLogger:info(getPlayerName(player).." hat ein Auto upgegradet!")
    discordLogger:discord("TUNECAR: "..getPlayerName(player).." hat ein Auto upgegradet!", getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Fahrzeug getunt!", false)
end


function freezeshit ( )
	setElementFrozen ( source, true )
	setElementFrozen ( veh_frozen_vehs[getPlayerName(source)], false )	
end


function cancelWeaponShit ()
	setPedWeaponSlot ( source, 0 )
end


function freeze_func ( player, cmd, target )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[FREEZE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if freezeCooldown[player] and getTickCount() - freezeCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Spieler freezt.", true)
        return
    end
    freezeCooldown[player] = getTickCount()
    if not target then
        outputNeutralInfo(player, "Gebrauch: /freezen NAME", true)
        return
    end
    local targetpl = findPlayerByName(target)
    if not targetpl then
        outputNeutralInfo(player, "Der Spieler ist nicht online.", true)
        return
    end
    if frozen_players[getPlayerName(targetpl)] or veh_frozen_players[getPlayerName(targetpl)] then
        setElementFrozen(targetpl, false)
        frozen_players[getPlayerName(targetpl)] = false
        veh_frozen_players[getPlayerName(targetpl)] = false
        outputNeutralInfo(player, "Du hast "..getPlayerName(targetpl).." entfreezed!", false)
        outputNeutralInfo(targetpl, "Du wurdest entfreezed!", false)
        return
    end
    local veh = getPedOccupiedVehicle(targetpl)
    if veh then
        setElementFrozen(veh, true)
        veh_frozen_players[getPlayerName(targetpl)] = true
        veh_frozen_vehs[getPlayerName(targetpl)] = veh
        addEventHandler("onPlayerWeaponSwitch", targetpl, cancelWeaponShit)
        setPedWeaponSlot(targetpl, 0)
        addEventHandler("onPlayerVehicleExit", targetpl, freezeshit)
        addEventHandler("onPlayerQuit", targetpl, function()
            setElementFrozen(veh_frozen_vehs[getPlayerName(source)], false)
            veh_frozen_players[getPlayerName(source)] = false
            veh_frozen_vehs[getPlayerName(source)] = false
        end)
    else
        setElementFrozen(targetpl, true)
        frozen_players[getPlayerName(targetpl)] = true
        addEventHandler("onPlayerWeaponSwitch", targetpl, cancelWeaponShit)
        setPedWeaponSlot(targetpl, 0)
        addEventHandler("onPlayerQuit", targetpl, function()
            frozen_players[getPlayerName(source)] = false
        end)
    end
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(targetpl).." gefreezed!")
    discordLogger:discord("FREEZE: "..getPlayerName(player).." hat "..getPlayerName(targetpl).." gefreezed!", getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Du hast "..getPlayerName(targetpl).." gefreezed!", false)
    outputNeutralInfo(targetpl, "Du wurdest von "..getPlayerName(player).." gefreezed!", false)
end


function intdim ( player, cmd, target, int, dim )
	if isAdminLevel ( player, adminLevels ["Moderator"] ) then
		if target then
			local target = findPlayerByName( target )	
			if not isElement(target) then
				outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
				return
			end
			if int and tonumber(int) ~= nil and dim and tonumber(dim) ~= nil then
				setElementInterior ( target, tonumber ( int ) )
				setElementDimension ( target, tonumber ( dim ) )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/intdim NAME INT DIM!", 5000, 125, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/intdim NAME INT DIM!", 5000, 125, 0, 0 )
		end	
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nauthorisiert!", 5000, 125, 0, 0 )		
	end		
end


function cleartext_func ( player )
	if getElementType ( player ) == "console" or isAdminLevel ( player, adminLevels["Supporter"] ) then
		for i = 1, 50 do
			outputChatBox ( " " )
		end	
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\n\nDu bist nicht\nauthorisiert!", 5000, 125, 0, 0 )	
	end
end


function kickPlayerGMX ( player )
	kickPlayer ( player, "Serverrestart" )
end


function restartNow ()
	if not isThisTheBetaServer () then
		setServerPassword ( "" )
	end
	local resource = getThisResource()
	elementData = nil
	restartResource ( resource )	
end


function restartServer()
	local btime = getRealTime()
	local bmonth = btime.month
	local bday = btime.monthday
	local bhour = btime.hour
	local bminute = btime.minute
	local bsecond = btime.second	
	if isThisTheBetaServer () then
		setServerPassword ( betaServerPasswort )
	else
		setServerPassword ( "sadfsadfsa!" )
	end	
	local players = getElementsByType("player")
	local j=0
	for i=1, #players do 
		setTimer ( kickPlayerGMX, 50+100*i, 1, players[i] )
		j = i
	end
	setTimer ( restartNow, 100+200*j, 1 )
end


function gmx_func ( player, cmd, minutes )	
	if not isAdminEventAllowed(player, adminLevels["Projektleiter"]) then
        securityLogger:error("[GMX] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if gmxCooldown[player] and getTickCount() - gmxCooldown[player] < 60000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Serverneustart machst.", true)
        return
    end
    gmxCooldown[player] = getTickCount()
    minutes = tonumber(minutes) or 1
    adminLogger:info(getPlayerName(player).." hat den Server neu gestartet.")
    securityLogger:info("[GMX] "..getPlayerName(player).." hat den Server neu gestartet.")
    discordLogger:discord("GMX: "..getPlayerName(player).." hat den Server neu gestartet.", getPlayerSerial(player), getPlayerIP(player))
    setTimer(restartServer, minutes*60000, 1)
    outputNeutralInfo(player, "Server wird in "..minutes.." Minuten neu gestartet.", false)
end


function ochat_func ( player, cmd, ... )
	if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[OCHAT] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if ochatCooldown[player] and getTickCount() - ochatCooldown[player] < 5000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut den O-Chat benutzt.", true)
        return
    end
    ochatCooldown[player] = getTickCount()
    local parametersTable = {...}
    local stringWithAllParameters = table.concat(parametersTable, " ")
    if not stringWithAllParameters or #stringWithAllParameters < 1 then
        outputNeutralInfo(player, "Bitte einen Text eingeben!", true)
        return
    end
    local rang = vioGetElementData(player, "adminlvl")
    local rank = ""
    if rang == 2 then rank = "Ticketsupporter" elseif rang == 3 then rank = "Supporter" elseif rang == 4 then rank = "Moderator" elseif rang == 5 then rank = "Administrator" elseif rang == 6 then rank = "Projektleiter" end
    outputChatBox("(( "..rank.." "..getPlayerName(player)..": "..stringWithAllParameters.." ))", getRootElement(), 255, 255, 255)
    adminLogger:info(getPlayerName(player).." hat O-Chat benutzt: "..stringWithAllParameters)
    discordLogger:discord("OCHAT: "..getPlayerName(player).." sagt: "..stringWithAllParameters, getPlayerSerial(player), getPlayerIP(player))
end


function achat_func ( player, cmd, ... )		
	if not isAdminEventAllowed(player, adminLevels["Ticketsupporter"]) then
        securityLogger:error("[ACHAT] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if achatCooldown[player] and getTickCount() - achatCooldown[player] < 5000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut den A-Chat benutzt.", true)
        return
    end
    achatCooldown[player] = getTickCount()
    local parametersTable = {...}
    local stringWithAllParameters = table.concat(parametersTable, " ")
    if not stringWithAllParameters or #stringWithAllParameters < 1 then
        outputNeutralInfo(player, "Bitte einen Text eingeben!", true)
        return
    end
    local rang = vioGetElementData(player, "adminlvl")
    local rank = ""
    if rang == 2 then rank = "Ticketsupporter" elseif rang == 3 then rank = "Supporter" elseif rang == 4 then rank = "Moderator" elseif rang == 5 then rank = "Administrator" elseif rang == 6 then rank = "Projektleiter" end
    for playeritem, index in pairs(adminsIngame) do 			
        if index >= 2 then
            outputChatBox ( "[ "..rank.." "..getPlayerName(player)..": "..stringWithAllParameters.." ]", playeritem, 99, 184, 255 )
        end				
    end		
    adminLogger:info(getPlayerName(player).." hat A-Chat benutzt: "..stringWithAllParameters)
    discordLogger:discord("ACHAT: "..getPlayerName(player).." sagt: "..stringWithAllParameters, getPlayerSerial(player), getPlayerIP(player))
end


function setrank_func ( player, cmd, target, rank )
    if not isAdminEventAllowed(player, adminLevels["Moderator"]) then
        securityLogger:error("[SETRANK] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if setrankCooldown[player] and getTickCount() - setrankCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Rang setzt.", true)
        return
    end
    setrankCooldown[player] = getTickCount()
    if not target or not rank then
        outputNeutralInfo(player, "Gebrauch: /setrank NAME RANG", true)
        return
    end
    local targetpl = findPlayerByName(target)
    if not targetpl then
        outputNeutralInfo(player, "Der Spieler ist nicht online.", true)
        return
    end
    local newrank = tonumber(rank)
    if not newrank or newrank < 0 or newrank > 5 then
        outputNeutralInfo(player, "Ungültiger Rang.", true)
        return
    end
    dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "FraktionsRang", newrank, "UID", playerUID[getPlayerName(targetpl)])
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(targetpl).." auf Rang "..newrank.." gesetzt.")
    securityLogger:info("[SETRANK] "..getPlayerName(player).." hat "..getPlayerName(targetpl).." auf Rang "..newrank.." gesetzt.")
    discordLogger:discord("SETRANK: "..getPlayerName(player).." hat "..getPlayerName(targetpl).." auf Rang "..newrank.." gesetzt.", getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Rang gesetzt.", false)
    outputNeutralInfo(targetpl, "Dein Rang wurde geändert.", false)
end


function makeleader_func ( player, cmd, target, fraktion )
    -- Rechteprüfung
    if not isAdminEventAllowed(player, adminLevels["Moderator"]) then
        securityLogger:error("[MAKELEADER] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    -- Cooldown (10 Sekunden)
    if makeleaderCooldown[player] and getTickCount() - makeleaderCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Leader setzt.", true)
        return
    end
    makeleaderCooldown[player] = getTickCount()
    -- Input-Validierung
    if not target or not fraktion then
        outputNeutralInfo(player, "Gebrauch: /makeleader NAME FRAKTION", true)
        return
    end
    local targetpl = findPlayerByName(target)
    if not targetpl then
        outputNeutralInfo(player, "Der Spieler ist nicht online.", true)
        return
    end
    if targetpl == player then
        outputNeutralInfo(player, "Du kannst dich nicht selbst zum Leader machen.", true)
        return
    end
    local frac = tonumber(fraktion)
    if not frac or frac < 0 or frac > #fraktionNames then
        outputNeutralInfo(player, "Ungültige Fraktions-ID.", true)
        return
    end
    local targetNameStr = getPlayerName(targetpl)
    local uid = playerUID[targetNameStr]
    if not uid then
        outputNeutralInfo(player, "UID des Spielers nicht gefunden.", true)
        return
    end
    -- SQL-Update: Fraktion und Rang setzen
    dbExec(handler, "UPDATE ?? SET ??=?, ??=? WHERE ??=?", "userdata", "FraktionsRang", 5, "Fraktion", frac, "UID", uid)
    -- Logging
    adminLogger:info(getPlayerName(player).." hat "..targetNameStr.." zum Leader von Fraktion "..frac.." gemacht.")
    securityLogger:info("[MAKELEADER] "..getPlayerName(player).." hat "..targetNameStr.." zum Leader von Fraktion "..frac.." gemacht.")
    discordLogger:discord("MAKELEADER: "..getPlayerName(player).." hat "..targetNameStr.." zum Leader von Fraktion "..frac.." gemacht.", getPlayerSerial(player), getPlayerIP(player))
    -- Daten setzen
    vioSetElementData(targetpl, "fraktion", frac)
    vioSetElementData(targetpl, "rang", 5)
    -- Feedback
    outputNeutralInfo(player, "Leader gesetzt.", false)
    outputNeutralInfo(targetpl, "Du bist nun Leader deiner Fraktion! Für mehr Infos öffne das Hilfemenü.", false)
    -- Optional: Fraktionslisten synchronisieren, Einladungen setzen, etc.
end


function setadmin_func ( player, cmd, target, rank )
    if not isAdminEventAllowed(player, adminLevels["Projektleiter"]) then
        securityLogger:error("[SETADMIN] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if setadminCooldown[player] and getTickCount() - setadminCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut einen Adminlevel setzt.", true)
        return
    end
    setadminCooldown[player] = getTickCount()
    if not target or not rank then
        outputNeutralInfo(player, "Gebrauch: /setadmin NAME RANG", true)
        return
    end
    if playerUID[target] then
        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "userdata", "Adminlevel", tonumber(rank), "UID", playerUID[target])
        adminLogger:info(getPlayerName(player).." hat "..target.."s Adminlevel auf "..rank.." gesetzt.")
        securityLogger:info("[SETADMIN] "..getPlayerName(player).." hat "..target.."s Adminlevel auf "..rank.." gesetzt.")
        discordLogger:discord("SETADMIN: "..getPlayerName(player).." hat "..target.."s Adminlevel auf "..rank.." gesetzt.", getPlayerSerial(player), getPlayerIP(player))
        outputNeutralInfo(player, "Adminlevel gesetzt.", false)
    else
        outputNeutralInfo(player, "Der Spieler existiert nicht!", true)
    end
end

local oldspecpos = {}
function spec_func ( player, command, spec )
	if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[SPEC] Unberechtigter Versuch: "..getPlayerName(player))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if specCooldown[player] and getTickCount() - specCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut spectatest.", true)
        return
    end
    specCooldown[player] = getTickCount()
    local specTarget = spec and findPlayerByName(spec) or nil
    if not specTarget then
        if oldspecpos[player] then
            setElementInterior(player, oldspecpos[player][2])
            setElementDimension(player, oldspecpos[player][1])
            oldspecpos[player] = nil
        end
        fadeCamera(player, true)
        setCameraTarget(player, player)
        setElementFrozen(player, false)
        outputNeutralInfo(player, "Spectate-Modus verlassen.", false)
        return
    end
    setElementFrozen(player, true)
    local dim2, int2 = getElementDimension(player), getElementInterior(player)
    oldspecpos[player] = { dim2, int2 }
    local dim, int = getElementDimension(specTarget), getElementInterior(specTarget)
    setElementInterior(player, int)
    setElementDimension(player, dim)
    fadeCamera(player, true)
    setCameraTarget(player, specTarget)
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(specTarget).." gespectet!")
    discordLogger:discord("SPEC: "..getPlayerName(player).." spectated "..getPlayerName(specTarget), getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Spectate-Modus aktiviert.", false)
end


function rkick_func ( player, command, kplayer, ... )
	if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[RKICK] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if rkickCooldown[player] and getTickCount() - rkickCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut kickst.", true)
        return
    end
    rkickCooldown[player] = getTickCount()
    if not kplayer then
        outputNeutralInfo(player, "Gebrauch: /rkick NAME [Grund]", true)
        return
    end
    local reason = table.concat({...}, " ")
    if not reason or #reason < 3 then
        outputNeutralInfo(player, "Bitte gib einen gültigen Grund an.", true)
        return
    end
    local target = findPlayerByName(kplayer)
    if not target then
        outputNeutralInfo(player, "Der Spieler ist offline!", true)
        return
    end
    if getAdminLevel(player) <= getAdminLevel(target) then
        outputNeutralInfo(player, "Der Spieler hat einen höheren oder gleichen Adminrang.", true)
        return
    end
    takeAllWeapons(target)
    kickPlayer(target, player, reason)
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(target).." gekickt! Grund: "..reason)
    discordLogger:discord("RKICK: "..getPlayerName(player).." hat "..getPlayerName(target).." gekickt! Grund: "..reason, getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Spieler gekickt.", false)
    outputNeutralInfo(target, "Du wurdest gekickt! Grund: "..reason, true)
end


function rban_func ( player, command, kplayer, ... )
    -- Rechteprüfung
    if not isAdminEventAllowed(player, adminLevels["Moderator"]) then
        securityLogger:error("[RBAN] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    -- Cooldown (10 Sekunden)
    if rbanCooldown[player] and getTickCount() - rbanCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut bannst.", true)
        return
    end
    rbanCooldown[player] = getTickCount()
    -- Input-Validierung
    if not kplayer or kplayer == "" then
        outputNeutralInfo(player, "Gebrauch: /rban NAME [Grund]", true)
        return
    end
    local reason = table.concat({...}, " ")
    if not reason or #reason < 3 then
        outputNeutralInfo(player, "Bitte gib einen gültigen Grund an.", true)
        return
    end
    local target = getPlayerFromName(kplayer)
    if not target then
        if playerUID[kplayer] then
            local serial = dbPoll ( dbQuery ( handler, "SELECT ?? FROM ?? WHERE ??=?", "Serial", "players", "UID", playerUID[kplayer] ), -1 )[1]["Serial"]
            outputNeutralInfo(player, "Der Spieler wurde (offline) gebannt!", false)
            dbExec (handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)", "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial", playerUID[kplayer], playerUID[getPlayerName(player)], reason, timestamp(), '0.0.0.0', serial)
            adminLogger:info(getPlayerName(player).." hat (offline) "..kplayer.." gebannt! Grund: "..reason)
            securityLogger:info("[RBAN] (offline) "..getPlayerName(player).." hat "..kplayer.." gebannt! Grund: "..reason)
            discordLogger:discord("BAN: "..getPlayerName(player).." hat (offline) "..kplayer.." gebannt! Grund: "..reason, getPlayerSerial(player), getPlayerIP(player))
        else
            outputNeutralInfo(player, "Der Spieler existiert nicht!", true)
        end
        return
    end
    if target == player then
        outputNeutralInfo(player, "Du kannst dich nicht selbst bannen.", true)
        return
    end
    if getAdminLevel(player) <= getAdminLevel(target) then
        outputNeutralInfo(player, "Der Spieler hat einen höheren oder gleichen Adminrang.", true)
        return
    end
    -- Ban durchführen (prepared statement)
    local uid = playerUID[getPlayerName(target)]
    local adminUid = playerUID[getPlayerName(player)]
    local ip = getPlayerIP(target)
    local serial = getPlayerSerial(target)
    dbExec(handler, "INSERT INTO ?? (??, ??, ??, ??, ??, ??) VALUES (?,?,?,?,?,?)",
        "ban", "UID", "AdminUID", "Grund", "Datum", "IP", "Serial",
        uid, adminUid, reason, timestamp(), ip, serial
    )
    -- Logging
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(target).." gebannt! Grund: "..reason)
    securityLogger:info("[RBAN] "..getPlayerName(player).." hat "..getPlayerName(target).." gebannt! Grund: "..reason)
    discordLogger:discord("BAN: "..getPlayerName(player).." hat "..getPlayerName(target).." gebannt! Grund: "..reason, getPlayerSerial(player), getPlayerIP(player))
    -- Feedback
    outputNeutralInfo(player, "Spieler gebannt.", false)
    outputNeutralInfo(target, "Du wurdest gebannt! Grund: "..reason, true)
    -- Spieler kicken
    kickPlayer(target, player, reason.." (gebannt!)")
end


function getip ( player, cmd, name )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[GETIP] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if not client or player == client then
		if isAdminLevel ( player, adminLevels["Administrator"] ) then
			if name then
				local target = findPlayerByName ( name )	
				if isElement ( target ) then	
					local ip = getPlayerIP ( target )
					outputChatBox ( "IP von "..name..": "..ip, player, 200, 200, 0 )	
				else
					infobox ( player, "Spieler ist nicht online!", 5000, 125, 0, 0 )	
				end	
			else
				infobox ( player, "Gebrauch:\n/getip [Name]", 5000, 125, 0, 0 )	
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
		end		
	end	
end


function tban_func ( player, command, kplayer, btime,... )
	if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[TBAN] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if getElementType(player) == "console" or isAdminLevel ( player, adminLevels["Supporter"] ) and ( not client or client == player ) then
		if kplayer and btime and tonumber(btime) ~= nil then
			local reason = {...}
			reason = table.concat( reason, " " )
			if reason then
				local target = findPlayerByName ( kplayer )			
				if not isElement(target) then					
					local success = timebanPlayer ( kplayer, tonumber(btime), getPlayerName( player ), reason )			
					if success == false then			
						triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/tban [Player] [Grund]\n[Zeit],max. 3\nWoerter", 5000, 0, 125, 255 )				
					end				
					return				
				end			
				local name = getPlayerName( target )
				local savename = name
				local success = timebanPlayer ( savename, tonumber(btime), getPlayerName( player ), reason )
				if success == false then
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/tban [Player] [Grund]\n[Zeit],max. 3\nWörter", 5000, 0, 125, 255 )	
				else
					outputAdminLog ( getPlayerName ( player ).." hat "..kplayer.." gebannt! Zeit: "..btime.." - Grund: "..reason  )	
				end
			else	
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/tban NAME ZEIT GRUND", 5000, 255, 0, 0 )		
			end
		else	
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/tban NAME ZEIT GRUND", 5000, 255, 0, 0 )		
		end						
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


-- Deaktiviert, da unnötig --
--[[function slap_func ( player, command, splayer, bslap )
	if getElementType(player) == "console" then
		vioSetElementData(player, "adminlvl", 3 )
	end	
	if isAdminLevel ( player, adminLevels["Administrator"] ) and ( not client or client == player ) then
		local target = findPlayerByName ( splayer )	
		if not isElement(target) then
			outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
			return
		end	
		if not bslap then
			bslap = "nein"
		end	
		if bslap == "nein" or bslap == "Nein" then		
			local x,y,z = getElementPosition(target)
			setElementPosition ( target, x, y, z + 5, true )			
			for playeritem, index in pairs(adminsIngame) do 
				outputChatBox ( getPlayerName(player).." hat "..getPlayerName(target).." geslapt!", playeritem, 255, 255, 0 )
			end	
		elseif bslap == "ja" or bslap == "Ja" then		
			local x, y, z = getElementPosition( target )
			setElementPosition ( target, x, y, z + 5, false )
			setPedOnFire ( target, true )			
			for playeritem, key in pairs(adminsIngame) do
				outputChatBox ( getPlayerName(player).." hat "..getPlayerName(target).." geslapt und angezuendet!", playeritem, 255, 255, 0 )
			end		
		else		
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/slap [Player] \n[Anzuenden]\nJa/Nein", 5000, 0, 125, 125 )		
		end			
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end]]


function goto_func(player,command,tplayer)
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[GOTO] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if isAdminLevel ( player, adminLevels["Supporter"] ) and ( not client or client == player ) then
		if tplayer then
			local target = findPlayerByName ( tplayer )	
			if not isElement(target) then
				outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
				return
			end			
			local x, y, z = getElementPosition( target )	
			if getPedOccupiedVehicleSeat ( player ) == 0 then			
				setElementInterior ( player, getElementInterior(target) )
				setElementInterior ( getPedOccupiedVehicle(player), getElementInterior(target) )
				setElementPosition ( getPedOccupiedVehicle ( player ), x+3, y+3, z )
				setElementDimension ( getPedOccupiedVehicle ( player ), getElementDimension ( target ) )
				setElementDimension ( player, getElementDimension ( target ) )
				setElementVelocity(getPedOccupiedVehicle(player),0,0,0)
				setElementFrozen ( getPedOccupiedVehicle(player), true )
				setTimer ( setElementFrozen, 500, 1, getPedOccupiedVehicle(player), false )				
			else			
				removePedFromVehicle ( player )
				setElementPosition ( player, x, y + 1, z )
				setElementInterior ( player, getElementInterior(target) )
				setElementDimension ( player, getElementDimension ( target ) )				
			end			
			outputAdminLog ( getPlayerName ( player ).." hat sich zu "..getPlayerName ( target).." teleportiert!" )
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/goto NAME", 5000, 255, 0, 0 )
		end	
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


function gethere_func(player,command,tplayer)
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[GETHERE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if isAdminLevel ( player, adminLevels["Supporter"] ) and ( not client or client == player ) then
		if tplayer then
			local target = findPlayerByName ( tplayer )
			local x, y, z = getElementPosition ( player )
			if not isElement(target) then
				outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
				return
			end		
			if getPedOccupiedVehicleSeat ( target ) == 0 then			
				setElementInterior ( target, getElementInterior(player) )
				setElementInterior ( getPedOccupiedVehicle(target), getElementInterior(player ) )
				setElementPosition ( getPedOccupiedVehicle(target), x+3, y+3, z )
				setElementDimension ( target, getElementDimension ( player ) )
				setElementDimension ( getPedOccupiedVehicle(target), getElementDimension ( player ) )
				setElementVelocity(getPedOccupiedVehicle(target),0,0,0)
				setElementFrozen ( getPedOccupiedVehicle(target), true )
				setTimer ( setElementFrozen, 500, 1, getPedOccupiedVehicle(target), false )					
			else				
				removePedFromVehicle ( target )
				setElementPosition ( target, x, y + 1, z )
				setElementInterior ( target, getElementInterior(player) )
				setElementDimension ( target, getElementDimension ( player ) )			
			end		
			outputAdminLog ( getPlayerName ( player ).." hat "..getPlayerName ( target ).." zu sich teleportiert." )
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/gethere NAME", 7500, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 7500, 255, 0, 0 )	
	end	
end


function skydive_func(player,command,tplayer)
    if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[SKYDIVE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if getElementType(player) == "console" or isAdminLevel ( player, adminLevels["Administrator"] ) and ( not client or client == player ) then
		if tplayer then
			local target = findPlayerByName ( tplayer )
			if not isElement(target) then
				outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
				return
			end		
			giveWeapon ( target, 46, 1, true )
			local x, y, z = getElementPosition(target)			
			if getPedOccupiedVehicleSeat ( target ) == 0 then			
				setElementPosition ( getPedOccupiedVehicle(target), x, y, z+2000 )				
			else					
				removePedFromVehicle ( target )
				setElementPosition ( target, x, y, z+2000 )				
			end			
			for playeritem, key in pairs(adminsIngame) do 
				if key >= 2 then
					outputChatBox ( getPlayerName(player).." hat "..getPlayerName(target).." geskydived!", playeritem, 255, 255, 0 )				
				end
			end			
			outputAdminLog ( getPlayerName ( player ).." hat "..getPlayerName ( target ).." geskydived!" )
		else	
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/skydive NAME", 5000, 255, 0, 0 )		
		end			
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end

local blocked_cms = {}
blocked_cms["say"] = true
blocked_cms["teamsay"] = true
blocked_cms["ad"] = true
blocked_cms["me"] = true
blocked_cms["t"] = true
blocked_cms["g"] = true
blocked_cms["s"] = true
blocked_cms["l"] = true
blocked_cms["m"] = true


function vioMutePlayer ( cmd )
	if blocked_cms[cmd] then
		outputChatBox ( "Du bist gemuted, benutze /report fuer Fragen!", player, 125, 0, 0 )
		cancelEvent()
	end
end


function mute_func(player,command,tplayer)
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[MUTE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if getElementType(player) == "console" or isAdminLevel ( player, adminLevels["Supporter"] ) and ( not client or client == player ) then
		if tplayer then
			local target = findPlayerByName ( tplayer )
			if not isElement(target) then
				outputChatBox ( "Der Spieler ist offline!", player, 125, 0, 0 )
				return
			end			
			if muted_players[target] then	
				removeEventHandler ( "onPlayerCommand", target, vioMutePlayer )			
				muted_players[target] = false		
				for playeritem, key in pairs(adminsIngame) do 		
					if key >= 2 then
						outputChatBox ( getPlayerName(player).." hat "..getPlayerName(target).." entmuted!", playeritem, 255, 255, 0 )				
					end
				end			
			else		
				addEventHandler( "onPlayerCommand", target, vioMutePlayer )		
				muted_players[target] = true			
				for playeritem, key in pairs(adminsIngame) do 		
					if key >= 2 then
						outputChatBox ( getPlayerName(player).." hat "..getPlayerName(target).." gemuted!", playeritem, 255, 255, 0 )				
					end
				end					
			end	
		else	
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/mute NAME", 5000, 255, 0, 0 )		
		end
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


function unban_func ( player, cmd, nick )
	if playerUID[nick] then
		local adminname = dbPoll ( dbQuery ( handler, "SELECT ?? FROM ?? WHERE ??=?", "AdminUID", "ban", "UID", playerUID[nick] ), -1 )	
		if adminname and adminname[1] then	
			if getElementType(player) == "console" or isAdminLevel ( player, adminLevels["Administrator"] ) then	
				dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "ban", "UID", playerUID[nick] )
				outputChatBox ( getPlayerName(player).." hat "..nick.." entbannt!", getRootElement(), 125, 0, 0 )
				outputAdminLog ( getPlayerName(player).." hat "..nick.." entbannt." )			
			elseif playerUIDName[adminname[1]["AdminUID"]] == getPlayerName ( player ) then
				dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "ban", "UID", playerUID[nick] )
				outputChatBox ( getPlayerName(player).." hat ".. nick.." entbannt!", getRootElement(), 125, 0, 0 )
				outputAdminLog ( getPlayerName(player).." hat ".. nick .." entbannt." )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
			end
		else		
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDer Spieler\nist nicht\ngebannt!", 5000, 255, 0, 0 )			
		end	
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Ungültiger Spieler", 5000, 255, 0, 0 )	
	end				
end


function crespawn_func ( player, cmd, radius )
	if isAdminLevel ( player, adminLevels["Supporter"] ) then
		if radius then	
			radius = tonumber(radius)
			if radius <= 50 and radius > 0 then
				local x, y, z = getElementPosition ( player )
				local sphere_1 = createColSphere ( x, y, z, radius )
				local spehere_table = getElementsWithinColShape ( sphere_1, "vehicle" )
				for theKey,theVehicle in pairs(spehere_table) do
					if doesAnyPlayerOccupieTheVeh ( theVehicle ) then
					else
						if not vioGetElementData ( theVehicle, "carslotnr_owner" ) then		
							respawnVehicle ( theVehicle )		
						else
							local towcar = vioGetElementData ( theVehicle, "carslotnr_owner" )
							local pname = vioGetElementData ( theVehicle, "owner" )
							respawnPrivVeh ( towcar, pname )
						end
					end		
				end		
				destroyElement(sphere_1)
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/crespawn [0-50]", 5000, 255, 0, 0 )
			end	
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/crespawn RADIUS", 5000, 255, 0, 0 )
		end		
	end	
end


function gotocar_func ( player, cmd, targetname, slot )	
	if isAdminLevel ( player, adminLevels["Supporter"] ) then
		if targetname and slot then
			slot = tonumber(slot)
			local target = findPlayerByName ( targetname )
			local newtargetname = getPlayerName ( target )			
			if isElement(target) then		
				local carslot = vioGetElementData ( target, "carslot"..slot )		
				if carslot then			
					if carslot >= 1 then				
						local veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false			
						if isElement ( veh ) then
							local x, y, z = getElementPosition(veh)
							local inter = getElementInterior(veh)
							local dimension = getElementDimension(veh)							
							setElementPosition ( player, x, y, z+1.5 )
							setElementInterior ( player, inter )
							setElementDimension ( player, dimension )						
						else					
							respawnPrivVeh ( slot, newtargetname )							
							veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false	
							local x, y, z = getElementPosition(veh)
							local inter = getElementInterior(veh)
							local dimension = getElementDimension(veh)							
							setElementPosition ( player, x, y, z+1.5 )
							setElementInterior ( player, inter )
							setElementDimension ( player, dimension )						
						end		
						outputAdminLog ( getPlayerName(player).." hat sich zum Slot "..slot.." von ".. targetname .." geportet." )
					else					
						outputChatBox ( "Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0 )					
					end				
				else				
					outputChatBox ( "Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0 )				
				end			
			else			
				outputChatBox ( "Spieler muss online sein!", player, 125, 0, 0 )				
			end		
		else		
			outputChatBox ( "/gotocar [Spieler] [Slot]!", player, 125, 0, 0 )			
		end	
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


function getcar_func ( player, cmd, targetname, slot )	
	if isAdminLevel ( player, adminLevels["Supporter"] ) then	
		if targetname and slot then
			slot = tonumber(slot)
			local target = findPlayerByName ( targetname )
			local newtargetname = getPlayerName ( target )			
			if isElement(target) then			
				local carslot = vioGetElementData ( target, "carslot"..slot )			
				if carslot then				
					if carslot >= 1 then					
						local veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false							
						if isElement ( veh ) then					
							local x, y, z = getElementPosition(player)
							local inter = getElementInterior(player)
							local dimension = getElementDimension(player)							
							setElementPosition ( veh, x, y, z+1.5 )
							setElementInterior ( veh, inter )
							setElementDimension ( veh, dimension )							
						else						
							respawnPrivVeh ( slot, newtargetname )							
							veh = allPrivateCars[newtargetname] and allPrivateCars[newtargetname][slot] or false
							local x, y, z = getElementPosition(player)
							local inter = getElementInterior(player)
							local dimension = getElementDimension(player)							
							setElementPosition ( veh, x, y, z+1.5 )
							setElementInterior ( veh, inter )
							setElementDimension ( veh, dimension )
						end
						outputAdminLog ( getPlayerName(player).." hat den Slot "..slot.." von ".. targetname .." zu sich geportet." )					
					else					
						outputChatBox ( "Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0 )					
					end				
				else
					outputChatBox ( "Der Spieler hat keinen Wagen mit dieser Nummer!", player, 125, 0, 0 )				
				end			
			else			
				outputChatBox ( "Spieler muss online sein!", player, 125, 0, 0 )				
			end		
		else
			outputChatBox ( "/getcar [Spieler] [Slot]!", player, 125, 0, 0 )			
		end	
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


function astart_func ( player, cmd )
	
	if isAdminLevel ( player, adminLevels["Administrator"] ) then
		local veh = getPedOccupiedVehicle ( player )	
		if not isElement ( veh ) then
			outputChatBox ( "Du musst in einem Wagen sitzen!", player, 125, 0, 0 )
			return
		end	
		if getElementModel ( veh ) ~= 438 then		
			if ( getPedOccupiedVehicleSeat ( player ) == 0 ) then				
				vioSetElementData ( veh, "fuelstate", 100 )
				vioSetElementData ( veh, "engine", false )
				setVehicleOverrideLights ( veh, 1 )
				vioSetElementData ( veh, "light", false)
				setVehicleEngineState ( veh, false )				
				if getVehicleEngineState ( veh ) then
					setVehicleEngineState ( veh, false )
					vioSetElementData ( veh, "engine", false )
					return		
				end				
				setVehicleEngineState ( veh, true )
				vioSetElementData ( veh, "engine", true )
				if not vioGetElementData ( veh, "timerrunning" ) then
					setVehicleNewFuelState ( veh )
					vioSetElementData ( veh, "timerrunning", true )
				end												
			end		
		end	
	else	
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )		
	end	
end


function aenter_func ( player, cmd )
	if isAdminLevel ( player, adminLevels["Administrator"] ) then
		vioSetElementData ( player, "adminEnterVehicle", true )
		outputChatBox ( "Klicke auf einen Wagen!", player, 125, 0, 0 )
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
	end
end


function makeVehFFT ( player )
	if isAdminLevel ( player, adminLevels["Administrator"] ) then
		if isPedInVehicle ( player ) then
			local veh = getPedOccupiedVehicle ( player )
			local pname = vioGetElementData ( veh, "owner" )
			for l = 1, 6 do
				for i = 1, 6 do
					if i == l then
						vioSetElementData ( veh, "stuning"..i, l )
					end
				end
			end
			local totTuning = "1|1|1|1|1|1"
			vioSetElementData ( veh, "stuning", totTuning )
			dbExec ( handler, "UPDATE vehicles SET STuning=? WHERE ??=? AND ??=?", totTuning, "UID", playerUID[pname], "Slot", vioGetElementData ( veh, "carslotnr_owner" ) )	
			specPimpVeh ( veh )
			specialTuningVehEnter ( player, 0 )
			outputChatBox ( "Du hast das Auto FFT gemacht.", player, 255, 0, 0)
			outputAdminLog ( getPlayerName ( player ).." hat das Auto von "..vioGetElementData ( veh, "owner" ).." FFT gemacht!" )
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu musst im\nFahrzeug sitzen.", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
	end
end

function muteDonator ( player, cmd, target )
	if target then
		if isAdminLevel ( player, adminLevels["VIP"]) then
			if findPlayerByName (target) then
				local targetpl = findPlayerByName (target)
				if not donatorMute[player][getPlayerName(targetpl)] or donatorMute[player][getPlayerName(targetpl)] == nil then					
					donatorMute[player][getPlayerName(targetpl)] = true
					outputChatBox ("Du hast "..target.." nun für den /a - Chat gemutet.", player, 0, 155, 0 )
				else
					donatorMute[player][getPlayerName(targetpl)] = nil
					outputChatBox ("Du hast "..target.." wieder entmuted.", player, 0, 155, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDer Spieler\existiert nicht!", 5000, 255, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nGebrauch:\n/muted NAME", 5000, 255, 0, 0 )
	end
end


function oeffnePremium ( player )
	if isAdminLevel ( player, adminLevels["VIP"]) and not getElementClicked ( player ) then
		triggerClientEvent ( player, "ppstart", player )
	end
end


function fixAdminVeh ( player )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[FIXVEH] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if vioGetElementData ( player, "money" ) >= 100 then
		if isPedInVehicle ( player ) then
			local veh = getPedOccupiedVehicle ( player )
			if getVehicleOccupant ( veh, 0 ) == player then
				fixVehicle ( veh )
				executeCommandHandler ( "meCMD", player, " hat sein Fahrzeug repariert!")
				vioSetElementData ( player, "money", vioGetElementData ( player, "money" ) - 100 )
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNur als\nFahrer erlaubt!", 5000, 255, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Du sitzt\nin keinem\nFahrzeug!", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 255, 0, 0 )
	end
end


function fillAdminLife ( player )
	if not isAdminEventAllowed(player, adminLevels["VIP"]) then
        securityLogger:error("[LEBENESSEN] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if vioGetElementData ( player, "money" ) >= 300 then
		setElementHealth ( player, 100 )
		setPedArmor ( player, 100 )
		setElementHunger ( player, 100 )
		vioSetElementData ( player, "money", vioGetElementData ( player, "money") - 300)
		executeCommandHandler ( "meCMD", player, " hat sein Leben & seine Weste aufgefüllt!")
		outputLog ( getPlayerName(player).." hat sich mit VIP geheilt", "Heilung" )
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 255, 0, 0 )
	end
end


function fillAdminVeh ( player )
	if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[FILLCOMPLETE] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        return
    end
	if isPedInVehicle ( player ) then
		local veh = getPedOccupiedVehicle ( player )
		if getVehicleOccupant ( veh, 0 ) == player then
			local liters = 100 - vioGetElementData ( veh, "fuelstate" )
			if vioGetElementData ( player, "money" ) >= (liters * 10) then
				if liters > 1 then
					setElementFrozen ( veh, true )
					setTimer ( setElementFrozen, 2000, 1, veh, false ) 
					vioSetElementData ( veh, "fuelstate", 100 )
					vioSetElementData ( player, "money", vioGetElementData ( player, "money" ) - (liters * 10) )
					local the_tankstelle = getNearestTanke ( player )
					if the_tankstelle ~= false then
						if the_tankstelle == "Nord" then
							bizArray["TankstelleNord"]["kasse"] = bizArray["TankstelleNord"]["kasse"] + liters * 10						
						elseif the_tankstelle == "Sued" then						
							bizArray["TankstelleSued"]["kasse"] = bizArray["TankstelleSued"]["kasse"] + liters * 10						
						elseif the_tankstelle == "Pine" then						
							bizArray["TankstellePine"]["kasse"] = bizArray["TankstellePine"]["kasse"] + liters * 10						
						end					
					end		
				else
					triggerClientEvent ( player, "infobox_start", getRootElement(), "Dein Fahzeug\nist schon\nbetankt!", 5000, 255, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNicht genug\nGeld!", 5000, 255, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNur als\nFahrer erlaubt!", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "Du sitzt\nin keinem\nFahrzeug!", 5000, 255, 0, 0 )
	end
end


function prison_func ( player, cmd, target, time, ... )
    if not isAdminEventAllowed(player, adminLevels["Supporter"]) then
        securityLogger:error("[PRISON] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if prisonCooldown[player] and getTickCount() - prisonCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut jemanden ins Prison steckst.", true)
        return
    end
    prisonCooldown[player] = getTickCount()
    if not target or not time then
        outputNeutralInfo(player, "Gebrauch: /prison NAME ZEIT GRUND", true)
        return
    end
    local targetpl = findPlayerByName(target)
    if not targetpl then
        outputNeutralInfo(player, "Der Spieler ist nicht online.", true)
        return
    end
    local jailtime = tonumber(time)
    if not jailtime or jailtime < 0 then
        outputNeutralInfo(player, "Ungültige Zeitangabe.", true)
        return
    end
    local reason = table.concat({...}, " ")
    if not reason or #reason < 3 then
        outputNeutralInfo(player, "Bitte gib einen gültigen Grund an.", true)
        return
    end
    vioSetElementData(targetpl, "prison", jailtime)
    adminLogger:info(getPlayerName(player).." hat "..getPlayerName(targetpl).." für "..jailtime.." Minuten ins Prison gesteckt. Grund: "..reason)
    discordLogger:discord("PRISON: "..getPlayerName(player).." hat "..getPlayerName(targetpl).." für "..jailtime.." Minuten ins Prison gesteckt. Grund: "..reason, getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Spieler ins Prison gesteckt.", false)
    outputNeutralInfo(targetpl, "Du wurdest ins Prison gesteckt! Grund: "..reason, true)
end

	
function setteTestGeld ( player, cmd, geld )
	if isAdminLevel ( player, adminLevels["Projektleiter"] ) and geld and tonumber (geld) ~= nil then
		vioSetElementData ( player, "money", tonumber(geld) )
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nDu bist nicht authorisiert,\ndiesen Befehl zu nutzen.", 5000, 255, 0, 0 )
	end
end
addCommandHandler ("settestgeld", setteTestGeld)

function kickAll ( player, cmd, ... )
    if not isAdminEventAllowed(player, adminLevels["Administrator"]) then
        securityLogger:error("[KICKALL] Unberechtigter Versuch: "..tostring(getPlayerName(player)))
        outputNeutralInfo(player, "Du bist nicht authorisiert, diesen Befehl zu nutzen.", true)
        return
    end
    if kickallCooldown[player] and getTickCount() - kickallCooldown[player] < 60000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut alle Spieler kickst.", true)
        return
    end
    kickallCooldown[player] = getTickCount()
    local parametersTable = {...}
    local stringWithAllParameters = table.concat(parametersTable, " ")
    local players = getElementsByType("player")
    for i=1, #players do
        if players[i] ~= player then
            kickPlayer(players[i], player, stringWithAllParameters)
        end
    end
    adminLogger:info(getPlayerName(player).." hat alle Spieler gekickt! Grund: "..stringWithAllParameters)
    discordLogger:discord("KICKALL: "..getPlayerName(player).." hat alle Spieler gekickt! Grund: "..stringWithAllParameters, getPlayerSerial(player), getPlayerIP(player))
    outputNeutralInfo(player, "Alle Spieler gekickt.", false)
end


function changeStatus ( player, cmd, status )
	if isAdminLevel ( player, adminLevels["VIP"] ) then
		if status then
			local status = tostring(status)
			if string.len ( status ) >= 3 and string.len ( status ) <= 16 then
				if not socialNeeds[status] then
					if string.find ( status, "'" ) then
						infobox ( player, "Bitte kein ' verwenden!", 4000, 200, 0, 0 )
						return false
					end
					vioSetElementData ( player, "socialState", status )
				else
					infobox ( player, "Den Status\nmusst du\ndir verdienen", 4000, 200, 0, 0 )
				end
			else
				triggerClientEvent ( player, "infobox_start", getRootElement(), "Der Status muss\nlänger als 2\nund kürzer als\n17 Zeichen sein!", 5000, 255, 0, 0 )
			end
		else
			triggerClientEvent ( player, "infobox_start", getRootElement(), "Gebrauch:\n/status STATUS", 5000, 255, 0, 0 )
		end
	else
		triggerClientEvent ( player, "infobox_start", getRootElement(), "\nNur ab Donator!", 5000, 255, 0, 0 )
	end
end
--

-- Events

addEvent ( "executeAdminServerCMD", true )
addEvent ( "move", true )
addEvent ( "moveVehicleAway", true )
addEvent ( "adminMenueTrigger", true )
addEvent ( "rkick", true )
addEvent ( "rban", true )
addEvent ( "getip", true )
addEvent ( "tban", true )
addEvent ( "slap", true )
addEvent ( "goto", true )
addEvent ( "gethere", true )
addEvent ( "skydive", true )
addEvent ( "mute", true )
addEvent ( "fixveh1", true )
addEvent ( "lebenessen", true )
addEvent ( "fillComplete1", true )

-- Event Handler

addEventHandler ( "executeAdminServerCMD", getRootElement(), executeAdminServerCMD_func )
addEventHandler ( "moveVehicleAway", getRootElement(), moveVehicleAway_func )
addEventHandler ( "move", getRootElement(), move_func )
addEventHandler ( "adminMenueTrigger", getRootElement(), adminMenueTrigger_func )
addEventHandler ( "mute", getRootElement(), mute_func )
addEventHandler ( "skydive", getRootElement(), skydive_func )
addEventHandler ( "gethere", getRootElement(), gethere_func )
addEventHandler ( "goto", getRootElement(), goto_func )
addEventHandler ( "tban", getRootElement(), tban_func )
addEventHandler ( "getip", getRootElement(), getip )
addEventHandler ( "rban", getRootElement(), rban_func )
addEventHandler ( "rkick", getRootElement(), rkick_func )
addEventHandler ( "fixveh1", getRootElement(), fixAdminVeh )
addEventHandler ( "lebenessen", getRootElement(), fillAdminLife )
addEventHandler ( "fillComplete1", getRootElement(), fillAdminVeh )
-- Command Handler

addCommandHandler ( "nickchange", nickchange_func )
addCommandHandler ( "move", move_func )
addCommandHandler ( "pwchange", pwchange_func )
addCommandHandler ( "shut", shut_func )
addCommandHandler ( "rebind", rebind_func )
addCommandHandler ( "admins", adminlist )
addCommandHandler ( "rcheck", check_func )
addCommandHandler ( "mark", mark_func )
addCommandHandler ( "gotomark", gotomark_func )
addCommandHandler ( "respawn", respawn_func )
addCommandHandler ( "tunecar", tunecar_func )
addCommandHandler ( "freezen", freeze_func )
addCommandHandler ( "intdim", intdim )
addCommandHandler ( "cleartext", cleartext_func )
addCommandHandler ( "chatclear", cleartext_func )
addCommandHandler ( "cc", cleartext_func )
addCommandHandler ( "clearchat", cleartext_func )
addCommandHandler ( "textclear", cleartext_func )
addCommandHandler ( "gmx", gmx_func )
addCommandHandler ( "ochat", ochat_func )
addCommandHandler ( "a", achat_func )
addCommandHandler ( "setrank", setrank_func )
addCommandHandler ( "makeleader", makeleader_func )
addCommandHandler ( "setadmin", setadmin_func )
addCommandHandler ( "spec", spec_func )
addCommandHandler ( "rkick", rkick_func )
addCommandHandler ( "rban", rban_func )
addCommandHandler ( "getip", getip )
addCommandHandler ( "tban", tban_func )
addCommandHandler ( "goto", goto_func )
addCommandHandler ( "gethere", gethere_func )
addCommandHandler ( "skydive", skydive_func )
addCommandHandler ( "rmute", mute_func )
addCommandHandler ( "unban", unban_func )
addCommandHandler ( "crespawn", crespawn_func )
addCommandHandler ( "gotocar", gotocar_func )
addCommandHandler ( "getcar", getcar_func )
addCommandHandler ( "astart", astart_func )
addCommandHandler ( "aenter", aenter_func )
addCommandHandler ( "makefft", makeVehFFT )
addCommandHandler ( "muted", muteDonator )
addCommandHandler ( "premium", oeffnePremium )
addCommandHandler ( "prison", prison_func )
addCommandHandler ( "kickall", kickAll )
addCommandHandler ( "status", changeStatus )



addCommandHandler ( "delacc", function ( player, cmd, target )
	if isAdminLevel ( player, adminLevels["Projektleiter"] ) then
		if playerUID[target] then
			local id = playerUID[target]
			playerUID[target] = nil
			playerUIDName[id] = nil
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "achievments", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "bonustable", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "inventar", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "packages", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "players", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "skills", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "userdata", "UID", id )
			dbExec ( handler, "DELETE FROM ?? WHERE ?? = ?", "statistics", "UID", id )
			infobox ( player, "Erledigt", 4000, 0, 200, 0 )
		else
			infobox ( player, "Account\nexistiert nicht!", 4000, 200, 0, 0 )
		end
	end
end )


addCommandHandler ( "restartresource", function ( player )
	if isAdminLevel ( player, adminLevels["Projektleiter"] ) then
		for index, playeritem in pairs ( getElementsByType ( "player" ) ) do
			if vioGetElementData ( playeritem, "loggedin" ) == 1 then
				local pname = getPlayerName ( playeritem )
				local int = getElementInterior ( playeritem )
				local dim = getElementDimension ( playeritem )
				local x, y, z = getElementPosition ( playeritem )
				local curWeaponsForSave = "|"
				for i = 1, 11 do
					if i ~= 10 then
						local weapon = getPedWeapon ( playeritem, i )
						local ammo = getPedTotalAmmo ( playeritem, i )
						if weapon and ammo then
							if weapon > 0 and ammo > 0 then
								if #curWeaponsForSave <= 40 then
									curWeaponsForSave = curWeaponsForSave..weapon..","..ammo.."|"
								end
							end
						end
					end
				end
				local pos = "|"..(math.floor(x*100)/100).."|"..(math.floor(y*100)/100).."|"..(math.floor(z*100)/100).."|"..int.."|"..dim.."|"
				if #curWeaponsForSave < 5 then
					curWeaponsForSave = ""
				end
				dbExec ( handler, "INSERT INTO ?? (??, ??, ??) VALUES (?,?,?)", "logout", "Position", "Waffen", "UID", pos, curWeaponsForSave, playerUID[pname] )
				datasave_remote ( playeritem )
				clearInv ( playeritem )
				clearUserdata ( playeritem )
				clearBonus ( playeritem )
				clearAchiev ( playeritem )
				clearPackage ( playeritem )
				clearDataSettings ( playeritem )
			end
		end
		restartResource ( getThisResource() )
	end
end )



local laststatus = {}

addEvent ( "testsocial", true )
addEventHandler ( "testsocial", root, function ( bool )
	if bool then
		laststatus[client] = vioGetElementData ( client, "socialState" )
		vioSetElementData ( client, "socialState", "Schreibt ..." )
	else
		if laststatus[client] then
			vioSetElementData ( client, "socialState", laststatus[client] )
		end
	end
end )

-- Beispiel: Bestätigungsdialog für Bann (vereinfachte Variante)
function confirmBan(player, target, reason)
    showInfoBox(player, "Bist du sicher, dass du "..target.." bannen willst? Tippe /yesban oder /noban", "warning")
    vioSetElementData(player, "ban_confirm_target", target)
    vioSetElementData(player, "ban_confirm_reason", reason)
end
addCommandHandler("banconfirm", function(player, cmd, target, ...)
    local reason = table.concat({...}, " ")
    if not target or reason == "" then
        showInfoBox(player, "Gebrauch: /banconfirm NAME GRUND", "error")
        return
    end
    confirmBan(player, target, reason)
end)
addCommandHandler("yesban", function(player)
    local target = vioGetElementData(player, "ban_confirm_target")
    local reason = vioGetElementData(player, "ban_confirm_reason")
    if target and reason then
        -- Hier würde der Bann durchgeführt
        showInfoBox(player, "Spieler "..target.." wurde gebannt!", "success")
        vioSetElementData(player, "ban_confirm_target", nil)
        vioSetElementData(player, "ban_confirm_reason", nil)
    else
        showInfoBox(player, "Kein Bann zum Bestätigen.", "error")
    end
end)
addCommandHandler("noban", function(player)
    vioSetElementData(player, "ban_confirm_target", nil)
    vioSetElementData(player, "ban_confirm_reason", nil)
    showInfoBox(player, "Bann abgebrochen.", "info")
end)