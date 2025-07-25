-- local Logger = require("utility.Logger") entfernt, Logger muss global sein
local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")
local discordLogger = Logger:new("Discord")
local factionLogger = Logger:new("factionlog")

AztecasLager = createObject ( 3577, -1324.4953, 2545.166, 86.82, 0, 0, 180 )
AztecaszweitLager = createObject ( 3577, 715.9721, 1966.29, 5.53 )

TriadenLager = createObject ( 3577, -2173.6677, 632.83, 49.4375 )
TriadenzweitLager = createObject ( 3577, 1896.6240, 977.2525, 10.812 )

BikerLager = createObject ( 3577, -2184.1638, -2306.4919, 30.325, 0, 0, 231 )
BikerzweitLager = createObject ( 3577, 2471.2001953125, 1534.400390625, 10.60000038147, 0, 0, 0 )

MafiaLager = createObject ( 3577, -665.8174, 939.5131, 11.833, 0, 0, 0 )
MafiazweitLager = createObject ( 3577, 2314.7544, 1760.5988, 10.820, 0, 0, 180 )

GroveLagerSF = createObject ( 3577, -2457.7001953125, -94.2998046875, 25.799999237061, 0, 0, 0)

TerrorLager = createObject ( 3577, -1973.3395996094, -1586.1295166016, 87.407867431641 ) -- TO DO

ReporterLager = createObject ( 3577, -2540.5, -623.59997558594, 132.5 )

BallasLager = createObject ( 3577, -2200.6999511719, 77.900001525879, 35.099998474121, 0, 0, 180 )

depots = { [AztecasLager]=true, [AztecaszweitLager]=true, [TriadenLager]=true, [TriadenzweitLager]=true, [BikerLager]=true, [BikerzweitLager]=true, [MafiaLager]=true, [MafiazweitLager]=true, [TerrorLager]=true, [BallasLager]=true, [GroveLagerSF]=true }

depotFactions = { [1]=true, [2]=true, [3]=true, [4]=true, [5]=true, [7]=true, [9]=true, [10]=true, [12]=true, [13]=true }
factionDepotData = {}
	factionDepotData["money"] = {}
	factionDepotData["drugs"] = {}
	factionDepotData["mats"] = {}

function depotLoad ()
	local dsatz = dbPoll ( dbQuery ( handler, "SELECT * FROM fraktionen" ), -1 )
	for i=1, #dsatz do
		local id = tonumber ( dsatz[i]["ID"] )
		factionDepotData["money"][id] = tonumber ( dsatz[i]["DepotGeld"] )
		factionDepotData["drugs"][id] = tonumber ( dsatz[i]["DepotDrogen"] )
		factionDepotData["mats"][id] = tonumber ( dsatz[i]["DepotMaterials"] )
	end
end
addEventHandler("onResourceStart", resourceRoot, depotLoad )


function saveDepotInDB ()
	for index, _ in pairs ( depotFactions ) do
		dbExec ( handler, "UPDATE ?? SET ??=?, ??=?, ??=? WHERE ?? = ?", "fraktionen", "DepotGeld", factionDepotData["money"][index], "DepotDrogen", factionDepotData["drugs"][index], "DepotMaterials", factionDepotData["mats"][index], "ID", index )
	end
end
setTimer ( saveDepotInDB, 25*60*1000, 0 )


-- Cooldown-Variable für Fraktionsbank
local frakbankCooldown = {}

function fraktionsKasseTransaktion(player, fraktion, betrag, typ)
    -- Cooldown (z.B. 10 Sekunden)
    if frakbankCooldown[player] and getTickCount() - frakbankCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut eine Fraktionsbank-Transaktion durchführst.", true)
        return
    end
    frakbankCooldown[player] = getTickCount()
    -- Input-Validierung
    if not fraktion or type(fraktion) ~= "number" or fraktion < 1 or fraktion > 20 then
        securityLogger:error("[EXPLOIT] Ungültige Fraktion bei Fraktionskasse.", player)
        outputNeutralInfo(player, "Ungültige Fraktion.", true)
        return
    end
    if not betrag or type(betrag) ~= "number" or betrag < 1 or betrag > 1000000 then
        securityLogger:error("[EXPLOIT] Ungültiger Betrag bei Fraktionskasse: "..tostring(betrag), player)
        outputNeutralInfo(player, "Ungültiger Betrag (max. 1.000.000 pro Transaktion).", true)
        return
    end
    -- Rechteprüfung
    if vioGetElementData(player, "fraktion") ~= fraktion or vioGetElementData(player, "rang") < 2 then
        securityLogger:error("[SECURITY] Unberechtigte Fraktionskassen-Aktion.", player)
        outputNeutralInfo(player, "Du bist nicht berechtigt, Fraktionsbank-Transaktionen durchzuführen.", true)
        return
    end
    -- Durchführung
    if typ == "einzahlung" then
        factionDepotData["money"][fraktion] = (factionDepotData["money"][fraktion] or 0) + betrag
        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "fraktionen", "DepotGeld", factionDepotData["money"][fraktion], "ID", fraktion)
        adminLogger:info(getPlayerName(player).." hat "..betrag.."$ in die Fraktionskasse der Fraktion "..fraktion.." eingezahlt.")
        securityLogger:info("[FRAKBANK] Einzahlung: "..getPlayerName(player).." -> Fraktion "..fraktion..": "..betrag.."$.")
        discordLogger:discord("FRAKBANK: "..getPlayerName(player).." hat "..betrag.."$ in die Fraktionskasse der Fraktion "..fraktion.." eingezahlt.", getPlayerSerial(player), getPlayerIP(player))
        local serial = getPlayerSerial(player)
        local ip = getPlayerIP(player)
        factionLogger:discord("FRAKBANK-EINZAHLUNG: "..getPlayerName(player).." Fraktion: "..fraktion.." Betrag: "..betrag, serial, ip)
        outputNeutralInfo(player, "Einzahlung erfolgreich.", false)
    elseif typ == "entnahme" then
        if (factionDepotData["money"][fraktion] or 0) < betrag then
            outputNeutralInfo(player, "Die Fraktionskasse enthält nicht genug Geld.", true)
            return
        end
        factionDepotData["money"][fraktion] = factionDepotData["money"][fraktion] - betrag
        dbExec(handler, "UPDATE ?? SET ??=? WHERE ??=?", "fraktionen", "DepotGeld", factionDepotData["money"][fraktion], "ID", fraktion)
        adminLogger:info(getPlayerName(player).." hat "..betrag.."$ aus der Fraktionskasse der Fraktion "..fraktion.." entnommen.")
        securityLogger:info("[FRAKBANK] Entnahme: "..getPlayerName(player).." aus Fraktion "..fraktion..": "..betrag.."$.")
        discordLogger:discord("FRAKBANK: "..getPlayerName(player).." hat "..betrag.."$ aus der Fraktionskasse der Fraktion "..fraktion.." entnommen.", getPlayerSerial(player), getPlayerIP(player))
        local serial = getPlayerSerial(player)
        local ip = getPlayerIP(player)
        factionLogger:discord("FRAKBANK-ENTNAHME: "..getPlayerName(player).." Fraktion: "..fraktion.." Betrag: "..betrag, serial, ip)
        outputNeutralInfo(player, "Entnahme erfolgreich.", false)
    else
        securityLogger:error("[EXPLOIT] Ungültiger Typ bei Fraktionskasse: "..tostring(typ), player)
        outputNeutralInfo(player, "Ungültiger Transaktionstyp.", true)
        return
    end
end

local fDepotCooldown = {}

function fDepotServer_func ( player, take, money, drugs, mats )
    if player ~= client then return end
    if fDepotCooldown[player] and getTickCount() - fDepotCooldown[player] < 10000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut eine Depot-Transaktion durchführst.", true)
        return
    end
    fDepotCooldown[player] = getTickCount()
    local fraktion = vioGetElementData ( player, "fraktion" )
    if fraktion == 11 then fraktion = 10 end
    if not depotFactions[fraktion] then
        outputNeutralInfo(player, "Du bist in einer ungültigen Fraktion!", true)
        securityLogger:error("[FDEPOT] Ungültige Fraktion: "..getPlayerName(player))
        return
    end
    money = tonumber(money) or 0
    drugs = tonumber(drugs) or 0
    mats = tonumber(mats) or 0
    if (money + drugs + mats) <= 0 then
        outputNeutralInfo(player, "Ungültige Eingabe!", true)
        return
    end
    local pmoney = tonumber(vioGetElementData(player, "money"))
    local pdrugs = tonumber(vioGetElementData(player, "drugs"))
    local pmats = tonumber(vioGetElementData(player, "mats"))
    money = math.floor(math.abs(money))
    drugs = math.floor(math.abs(drugs))
    mats = math.floor(math.abs(mats))
    if take then
        if (money > 0 or drugs > 0 or mats > 0) and tonumber(vioGetElementData(player, "rang")) < 5 then
            outputNeutralInfo(player, "Du bist nicht befugt, etwas zu entnehmen!", true)
            securityLogger:error("[FDEPOT] Unberechtigte Entnahme: "..getPlayerName(player))
            return
        end
        if factionDepotData["money"][fraktion] < money then
            outputNeutralInfo(player, "In der Fraktionskasse ist nicht genug Geld!", true)
        elseif factionDepotData["drugs"][fraktion] < drugs then
            outputNeutralInfo(player, "In der Fraktionskasse sind nicht genug Drogen!", true)
        elseif factionDepotData["mats"][fraktion] < mats then
            outputNeutralInfo(player, "In der Fraktionskasse sind nicht genug Materialien!", true)
        else
            local msg = getPlayerName(player).." hat "..money.." $, "..drugs.." Gramm Drogen und "..mats.." Materialien aus dem Depot genommen."
            adminLogger:info(msg)
            discordLogger:discord("FDEPOT-ENTNAHME: "..msg, getPlayerSerial(player), getPlayerIP(player))
            vioSetElementData(player, "money", pmoney + money)
            vioSetElementData(player, "drugs", pdrugs + drugs)
            vioSetElementData(player, "mats", pmats + mats)
            factionDepotData["money"][fraktion] = factionDepotData["money"][fraktion] - money
            factionDepotData["drugs"][fraktion] = factionDepotData["drugs"][fraktion] - drugs
            factionDepotData["mats"][fraktion] = factionDepotData["mats"][fraktion] - mats
            triggerClientEvent(player, "showFDepot", getRootElement(), factionDepotData["money"][fraktion], factionDepotData["mats"][fraktion], factionDepotData["drugs"][fraktion])
            outputNeutralInfo(player, "Entnahme erfolgreich.", false)
        end
    else
        if money > pmoney then
            outputNeutralInfo(player, "Du hast nicht genug Geld dafür!", true)
        elseif drugs > pdrugs then
            outputNeutralInfo(player, "Du hast nicht genug Drogen dafür!", true)
        elseif mats > pmats then
            outputNeutralInfo(player, "Du hast nicht genug Materialen dafür!", true)
        else
            vioSetElementData(player, "money", pmoney - money)
            vioSetElementData(player, "drugs", pdrugs - drugs)
            vioSetElementData(player, "mats", pmats - mats)
            factionDepotData["money"][fraktion] = factionDepotData["money"][fraktion] + money
            factionDepotData["drugs"][fraktion] = factionDepotData["drugs"][fraktion] + drugs
            factionDepotData["mats"][fraktion] = factionDepotData["mats"][fraktion] + mats
            local msg = getPlayerName(player).." hat "..money.." $, "..drugs.." Gramm Drogen und "..mats.." Materialien in das Depot gelegt."
            adminLogger:info(msg)
            discordLogger:discord("FDEPOT-EINZAHLUNG: "..msg, getPlayerSerial(player), getPlayerIP(player))
            triggerClientEvent(player, "showFDepot", getRootElement(), factionDepotData["money"][fraktion],  factionDepotData["mats"][fraktion], factionDepotData["drugs"][fraktion])
            outputNeutralInfo(player, "Einzahlung erfolgreich.", false)
        end
    end
end
addEvent ( "fDepotServer", true )
addEventHandler ( "fDepotServer", getRootElement(), fDepotServer_func )

local triadFgunsMarker = createMarker( -2186.9372558594, 698.5894165039, 53.9163284301761, "corona", 1, 255, 255, 0, 255 )
local triad2FgunsMarker = createMarker( 1909.1752, 1016.0863, 9.82, "corona", 1, 255, 255, 0, 255 )
local rifasFgunsMarker = createMarker( -1319.382, 2545.64, 87.784, "corona", 1, 255, 255, 0, 255 )
local rifas2FgunsMarker = createMarker( 1210.8363, 4.4482, 999.921, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( rifas2FgunsMarker, 2 )
local mafiaFgunsMarker = createMarker( -50.0453, 1405.4531, 1084.4297, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( mafiaFgunsMarker, 8 )
local mafia2FgunsMarker = createMarker( 2176.2729, 1619.136, 1000.976, "corona", 1, 255, 255, 0, 255 )
setElementInterior ( mafia2FgunsMarker, 1 )
local bikerFgunsMarker = createMarker( -2197.4792, -2329.2456, 30.625, "corona", 1, 255, 255, 0, 255 )
local biker2FgunsMarker = createMarker( 2461.2998046875, 1558.400390625,11.800000190735, "corona", 1, 255, 255, 0, 255 )
local ballasFgunsMarker = createMarker( -2209.6999511719, 78.400001525879, 35.299999237061, "corona", 1, 0, 125, 0 )
local groveFgunsMarker = createMarker(2533.6000976563, -1664.3000488281, 15.199999809265,"corona",2,255,0,0)
local grove2FgunsMarker = createMarker(-2482.4033203125, -122.8857421875, 25.623662948608,"corona",1,255,0,0)

function showFgunsInfo ( hitElement, dim )
	if getElementType ( hitElement ) == "player" and dim then
		local frac = vioGetElementData ( hitElement, "fraktion" )
		if ( source == triadFgunsMarker or source == triad2FgunsMarker ) and frac == 3 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == rifasFgunsMarker or source == rifas2FgunsMarker ) and frac == 7 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == mafiaFgunsMarker or source == mafia2FgunsMarker ) and frac == 2 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == bikerFgunsMarker or source == biker2FgunsMarker ) and frac == 9 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif source == ballasFgunsMarker and frac == 12 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		elseif ( source == groveFgunsMarker or source == grove2FgunsMarker ) and frac == 13 then
			infobox ( hitElement, "Mit /fguns\nkannst du dich\nhier ausrüsten!", 4000, 0, 200, 0 )
		end
	end
end
addEventHandler ( "onMarkerHit", triadFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", triad2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", rifasFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", rifas2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", mafiaFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", mafia2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", bikerFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", biker2FgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", ballasFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", groveFgunsMarker, showFgunsInfo )
addEventHandler ( "onMarkerHit", grove2FgunsMarker, showFgunsInfo )

addCommandHandler("fguns",
function ( player, cmd )
	local fac = vioGetElementData ( player, "fraktion" )
	local rank = vioGetElementData ( player, "rang" )
	
	if not gotLastHit[player] or gotLastHit[player] + healafterdmgtime <= getTickCount() then
	
		if fac == 13 then
			local px, py, pz = getElementPosition(player)
			local tx, ty, tz = getElementPosition(groveFgunsMarker)
			local tx2, ty2, tz2 = getElementPosition(grove2FgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, tx, ty, tz) < 10 or getDistanceBetweenPoints3D( px, py, pz, tx2, ty2, tz2) < 10 then	
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)	
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
			
		elseif fac == 12 then
			local px, py, pz = getElementPosition(player)
			local tx, ty, tz = getElementPosition(ballasFgunsMarker)
			local tx2, ty2, tz2 = getElementPosition(ballasFgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, tx, ty, tz) < 10 or getDistanceBetweenPoints3D( px, py, pz, tx2, ty2, tz2) < 10 then	
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)	
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
		
		elseif fac == 7 then
			local px, py, pz = getElementPosition(player)
			local tx, ty, tz = getElementPosition(rifasFgunsMarker)
			local tx2, ty2, tz2 = getElementPosition(rifas2FgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, tx, ty, tz) < 10 or getDistanceBetweenPoints3D( px, py, pz, tx2, ty2, tz2) < 10 then	
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)	
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
		
		elseif fac == 3 then
		
			local px, py, pz = getElementPosition(player)
			local rx, ry, rz = getElementPosition(triadFgunsMarker)
			local rx2, ry2, rz2 = getElementPosition(triad2FgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, rx, ry, rz) < 10 or getDistanceBetweenPoints3D( px, py, pz, rx2, ry2, rz2) < 10 then
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)	
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
			
		elseif fac == 2 then
		
			local px, py, pz = getElementPosition(player)
			local rx, ry, rz = getElementPosition(mafiaFgunsMarker)
			local rx2, ry2, rz2 = getElementPosition(mafia2FgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, rx, ry, rz ) < 10 or getDistanceBetweenPoints3D( px, py, pz, rx2, ry2, rz2 ) < 10 then
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)	
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
		
		elseif fac == 9 then
		
			local px, py, pz = getElementPosition(player)
			local rx, ry, rz = getElementPosition(bikerFgunsMarker)
			local rx2, ry2, rz2 = getElementPosition(bikerFgunsMarker)
			
			if getDistanceBetweenPoints3D( px, py, pz, rx, ry, rz) < 10 or getDistanceBetweenPoints3D( px, py, pz, rx2, ry2, rz2) < 10 then
				triggerClientEvent (player, "startFgunsGui", player, rank, fac)
			else
				infobox( player, "Du bist nicht\nam Waffenlager!", 3500, 255, 0, 0 )
			end
		else
			infobox( player, "\nKeine Befugnis!", 3500, 255, 0, 0 )
		end
	else
		outputChatBox ( "Es muss dafür "..( healafterdmgtime/1000 ) .." Sekunden nach dem letzten Schuss vergangen sein!", player, 200, 0, 0 )
	end
end)

addEvent ("giveFgunsWeapon", true)
addEventHandler ("giveFgunsWeapon", getRootElement(), function (waffe, moneycost, matscost)
	if waffe and moneycost and matscost then
		local fac = getPlayerFaction(client)
		if factionDepotData["mats"][fac] >= matscost then
			if vioGetElementData ( client, "money" ) >= moneycost then
				setPedArmor( client, 100 )
				if waffe == "Baseball" then
					giveWeapon ( client, 5, 1, true )
				elseif waffe == "Messer" then
					giveWeapon ( client, 4, 1, true )
				elseif waffe == "Queue" then
					giveWeapon ( client, 7, 1, true )
				elseif waffe == "Deagle" then
					giveWeapon ( client, 24, 49, true )
				elseif waffe == "Mp5" then
					giveWeapon ( client, 29, 180, true )
				elseif waffe == "M4" then
					giveWeapon ( client, 31, 350, true )
				elseif waffe == "Katana" then
					giveWeapon ( client, 8, 1, true )
				elseif waffe == "Molotov" then
					giveWeapon ( client, 18, 4, true )
				elseif waffe == "Lupara" then
					giveWeapon ( client, 26, 22, true )
				elseif waffe == "Gewehr" then
					giveWeapon ( client, 33, 51, true )
				elseif waffe == "AK47" then
					giveWeapon ( client, 30, 180, true )
				elseif waffe == "Sniper" then
					giveWeapon ( client, 34, 21, true )
				elseif waffe == "Raketenwerfer" then
					giveWeapon ( client, 35, 3, true )
				end
				vioSetElementData ( client, "money", vioGetElementData ( client, "money" ) - moneycost )

				factionDepotData["money"][fac] = factionDepotData["money"][fac] + moneycost
				factionDepotData["mats"][fac] = factionDepotData["mats"][fac] - matscost
				adminLogger:info(getPlayerName(client) .. " hat ein(e) "..waffe.." gekauft.", "fguns")
			else
				outputChatBox ( "Nicht genug Geld auf der Hand!", client, 155, 0, 0 )
			end
		else
			outputChatBox ( "Nicht genug Mats im Lager", client, 155, 0, 0 )
		end
	end
end)


-- 





