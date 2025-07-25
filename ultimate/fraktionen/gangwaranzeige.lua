addEvent ( "startGWAnzeige", true )
addEvent ( "updateAnzeigePrepare", true )
addEvent ( "updateAnzeigeStart", true )
addEvent ( "updateAnzeigeNachJoinen", true )
addEvent ( "rechneDMGAn", true )
addEvent ( "attackereinerdazugekommen", true )
addEvent ( "defendereinerdazugekommen", true )
addEvent ( "attackereinergestorben", true )
addEvent ( "defendereinergestorben", true )
addEvent ( "attackereinerofflineohnezaehlen", true )
addEvent ( "defendereinerofflineohnezaehlen", true )
addEvent ( "stopGWAnzeige", true )
addEvent ( "stopGWAnzeigeSTOP", true )
addEvent ( "kaching", true )
addEvent ( "rechneKillAn", true )
addEvent ( "moveVehicleInGangwar", true )

-- Mehrspielerfähige Gangwar-Anzeige: Pro Spieler werden alle relevanten Daten in gangwarData[localPlayer] gespeichert
local gangwarData = {}

local gangPraefix = {
 [2]="Mafia",
 [3]="Triaden",
 [7]="Los Aztecas",
 [9]="Angels of Death",
 [12]="Ballas",
 [13]="Grove"
}

local reichweiteZumTK = 15
local zeitinsekundenbisstatistikendet = 120
local screenx, screeny = guiGetScreenSize()
local sxA, syA = screenx/1920, screeny/1080

function dxdrawGangwarAnzeige(player)
    local data = gangwarData[player]
    local daminute = math.floor((data.diezeit - (getRealTime().timestamp - data.startzeit)) / 60)
    local dasekunde = math.floor((data.diezeit - (getRealTime().timestamp - data.startzeit)) % 60)
    local distance = 0
    if data.thepickup and isElement(data.thepickup) then
        local xp, yp, zp = getElementPosition(data.thepickup)
        local xpl, ypl, zpl = getElementPosition(player)
        distance = math.floor(getDistanceBetweenPoints3D(xp, yp, zp, xpl, ypl, zpl) * 10)/10
    end
    if dasekunde < 10 then dasekunde = "0"..dasekunde end
    dxDrawRectangle(screenx-400*sxA, screeny-670*syA, 180*sxA, 60*syA, tocolor(data.attackerR, data.attackerG, data.attackerB, 130), true)
    dxDrawRectangle(screenx-210*sxA, screeny-670*syA, 180*sxA, 60*syA, tocolor(data.defenderR, data.defenderG, data.defenderB, 200), true)
    dxDrawRectangle(screenx-400*sxA, screeny-725*syA, 120*sxA, 50*syA, tocolor(0, 0, 0, 200), true)
    dxDrawRectangle(screenx-275*sxA, screeny-725*syA, 120*sxA, 50*syA, tocolor(0, 0, 0, 200), true)
    dxDrawRectangle(screenx-150*sxA, screeny-725*syA, 120*sxA, 50*syA, tocolor(0, 0, 0, 200), true)
    dxDrawImage(screenx-385*sxA, screeny-713*syA, 25*sxA, 25*syA, "images/kill.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
    dxDrawImage(screenx-260*sxA, screeny-713*syA, 25*sxA, 25*syA, "images/damage.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
    dxDrawImage(screenx-135*sxA, screeny-713*syA, 25*sxA, 25*syA, "images/time.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
    dxDrawText(data.gangwarKills, screenx-335*sxA, screeny-712*syA, screenx-380*sxA, screeny-700*syA,tocolor(255, 255, 255, 255), 1.6*syA, "default-bold", "left", "top", false, false, true, false, false)
    dxDrawText(math.floor(data.gangwarDamage), screenx-210*sxA, screeny-712*syA, screenx-380*sxA, screeny-700*syA,tocolor(255, 255, 255, 255), 1.6*syA, "default-bold", "left", "top", false, false, true, false, false)
    dxDrawText(daminute..":"..dasekunde, screenx-120*sxA, screeny-712*syA, screenx-30*sxA, screeny-700*syA,tocolor(255, 255, 255, 255), 1.6*syA, "default-bold", "center", "top", false, false, true, false, false)
    dxDrawText(data.attackerfracname, screenx-400*sxA, screeny-667*syA, screenx-220*sxA, screeny-580*syA,tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false)
    dxDrawText(data.attackeralive.." / "..data.attacker, screenx-400*sxA, screeny-647*syA, screenx-220*sxA, screeny-580*syA,tocolor(255, 255, 255, 255), 2*syA, "default-bold", "center", "top", false, false, true, false, false)
    dxDrawText(data.defenderfracname, screenx-210*sxA, screeny-667*syA, screenx-30*sxA, screeny-580*syA,tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false)
    dxDrawText(data.defenderalive.." / "..data.defender, screenx-210*sxA, screeny-647*syA, screenx-30*sxA, screeny-580*syA,tocolor(255, 255, 255, 255), 2*syA, "default-bold", "center", "top", false, false, true, false, false)
    if distance > reichweiteZumTK then
        distance = "Entfernung zum Totenkopf "..distance.."m"
        dxDrawText(distance,  screenx-120*sxA, screeny-608*syA, screenx-35, screeny-700*syA, tocolor(255, 0, 0, 255), 1*syA, "default-bold", "right", "top", false, false)
    else
        distance = "Entfernung zum Totenkopf "..distance.."m"
        dxDrawText(distance,  screenx-120*sxA, screeny-608*syA, screenx-35, screeny-700*syA, tocolor(255, 255, 255, 255), 1*syA, "default-bold", "right", "top", false, false)
    end
    data.showing = true
end


function startAnzeige ( )
	gangwarData[localPlayer].gangwarlaeuft = true
	gangwarData[localPlayer].gangwarDamage = 0
	gangwarData[localPlayer].gangwarKills = 0
	addEventHandler ( "onClientRender", getRootElement(), dxdrawGangwarAnzeige )	
	addEventHandler ( "onClientKey", getRootElement(), deactivateInventar )
	removeEventHandler ( "onClientRender", getRootElement(), startStatistik )
	addEventHandler ( "onClientPlayerWasted", localPlayer, calculateGangwarKills )
	startzeit = getRealTime().timestamp
end
addEventHandler ( "startGWAnzeige", getRootElement(), startAnzeige )


function updateAnzeigePrepare_func ( zeitzumende, attackergesamt, attackerfrac, ownerfrac, pickup )
	gangwarData[localPlayer].gangwarlaeuft = true
	gangwarData[localPlayer].diezeit = zeitzumende
	gangwarData[localPlayer].attacker = attackergesamt
	gangwarData[localPlayer].attackeralive = attackergesamt
	gangwarData[localPlayer].attackerfracname = gangPraefix[attackerfrac]
	gangwarData[localPlayer].defenderfracname = gangPraefix[ownerfrac]
	gangwarData[localPlayer].thepickup = pickup
	gangwarData[localPlayer].attackerR = factionColors[attackerfrac][1]
	gangwarData[localPlayer].attackerG = factionColors[attackerfrac][2]
	gangwarData[localPlayer].attackerB = factionColors[attackerfrac][3]
	gangwarData[localPlayer].defenderR = factionColors[ownerfrac][1]
	gangwarData[localPlayer].defenderG = factionColors[ownerfrac][2]
	gangwarData[localPlayer].defenderB = factionColors[ownerfrac][3]
	startzeit = getRealTime().timestamp
end
addEventHandler ( "updateAnzeigePrepare", getRootElement(), updateAnzeigePrepare_func )


function updateAnzeigeStart_func ( zeitzumende, attackerlebend, attackergesamt )
	gangwarData[localPlayer].gangwarlaeuft = true
	gangwarData[localPlayer].diezeit = zeitzumende
	gangwarData[localPlayer].attackeralive = attackerlebend
	gangwarData[localPlayer].attacker = attackergesamt
	startzeit = getRealTime().timestamp
end
addEventHandler ( "updateAnzeigeStart", getRootElement(), updateAnzeigeStart_func )


function updateAnzeigeNachJoinen_func ( zeitzumende, attackergesamt, attackerlebend, defendergesamt, defenderlebend, attackerfrac, ownerfrac, pickup )
	gangwarData[localPlayer].gangwarlaeuft = true
	gangwarData[localPlayer].diezeit = zeitzumende
	gangwarData[localPlayer].attacker = attackergesamt
	gangwarData[localPlayer].attackeralive = attackerlebend
	gangwarData[localPlayer].defender = defendergesamt
	gangwarData[localPlayer].defenderalive = defenderlebend
	gangwarData[localPlayer].attackerfracname = gangPraefix[attackerfrac]
	gangwarData[localPlayer].defenderfracname = gangPraefix[ownerfrac]
	gangwarData[localPlayer].thepickup = pickup
	gangwarData[localPlayer].attackerR = factionColors[attackerfrac][1]
	gangwarData[localPlayer].attackerG = factionColors[attackerfrac][2]
	gangwarData[localPlayer].attackerB = factionColors[attackerfrac][3]
	gangwarData[localPlayer].defenderR = factionColors[ownerfrac][1]
	gangwarData[localPlayer].defenderG = factionColors[ownerfrac][2]
	gangwarData[localPlayer].defenderB = factionColors[ownerfrac][3]
	startzeit = getRealTime().timestamp
end
addEventHandler ( "updateAnzeigeNachJoinen", getRootElement(), updateAnzeigeNachJoinen_func )


function attackerEinerHinzugekommen ( )
	gangwarData[localPlayer].attacker = gangwarData[localPlayer].attacker + 1
	gangwarData[localPlayer].attackeralive = gangwarData[localPlayer].attackeralive + 1
end
addEventHandler ( "attackereinerdazugekommen", getRootElement(), attackerEinerHinzugekommen )


function defenderEinerHinzugekommen ( )
	gangwarData[localPlayer].defender = gangwarData[localPlayer].defender + 1
	gangwarData[localPlayer].defenderalive = gangwarData[localPlayer].defenderalive + 1
end
addEventHandler ( "defendereinerdazugekommen", getRootElement(), defenderEinerHinzugekommen )


function attackerEinerTot ( )
	gangwarData[localPlayer].attackeralive = gangwarData[localPlayer].attackeralive - 1
end
addEventHandler ( "attackereinergestorben", getRootElement(), attackerEinerTot )


function defenderEinerTot ( )
	gangwarData[localPlayer].defenderalive = gangwarData[localPlayer].defenderalive - 1
end
addEventHandler ( "defendereinergestorben", getRootElement(), defenderEinerTot )


function attackerEinerOffVorStart ( )
	gangwarData[localPlayer].attackeralive = gangwarData[localPlayer].attackeralive - 1
	gangwarData[localPlayer].attacker = gangwarData[localPlayer].attacker - 1
end
addEventHandler ( "attackereinerofflineohnezaehlen", getRootElement(), attackerEinerOffVorStart )


function defenderEinerOffVorStart ( )
	gangwarData[localPlayer].defenderalive = gangwarData[localPlayer].defenderalive - 1
	gangwarData[localPlayer].defender = gangwarData[localPlayer].defender - 1
end
addEventHandler ( "defendereinerofflineohnezaehlen", getRootElement(), defenderEinerOffVorStart )


function stopAnzeige ( dmgkilltable )
	gangwarData[localPlayer].gangwarlaeuft = false
	removeEventHandler ( "onClientRender", getRootElement(), dxdrawGangwarAnzeige )	
	removeEventHandler ( "onClientKey", getRootElement(), deactivateInventar )
	removeEventHandler ("onClientPlayerWasted", localPlayer, calculateGangwarKills)
	gangwarData[localPlayer].diezeit, gangwarData[localPlayer].startzeit, gangwarData[localPlayer].attackeralive, gangwarData[localPlayer].defenderalive, gangwarData[localPlayer].attacker, gangwarData[localPlayer].defender = 0, 0, 0, 0, 0, 0
	gangwarData[localPlayer].attackerfracname = ""
	gangwarData[localPlayer].defenderfracname = ""
	gangwarData[localPlayer].thepickup = nil
	gangwarData[localPlayer].showing = false
	gangwarData[localPlayer].sortierteStatistikTabelle = dmgkilltable
	removeEventHandler ( "onClientRender", getRootElement(), startStatistik )
	addEventHandler ( "onClientRender", getRootElement(), startStatistik )
end
addEventHandler ( "stopGWAnzeige", getRootElement(), stopAnzeige )


function stopAnzeigeSTOP ( )
	gangwarData[localPlayer].gangwarlaeuft = false
	removeEventHandler ( "onClientRender", getRootElement(), dxdrawGangwarAnzeige )	
	removeEventHandler ( "onClientKey", getRootElement(), deactivateInventar )
	gangwarData[localPlayer].diezeit, gangwarData[localPlayer].startzeit, gangwarData[localPlayer].attackeralive, gangwarData[localPlayer].defenderalive, gangwarData[localPlayer].attacker, gangwarData[localPlayer].defender = 0, 0, 0, 0, 0, 0
	gangwarData[localPlayer].attackerfracname = ""
	gangwarData[localPlayer].defenderfracname = ""
	gangwarData[localPlayer].thepickup = nil
	gangwarData[localPlayer].showing = false
end
addEventHandler ( "stopGWAnzeigeSTOP", getRootElement(), stopAnzeigeSTOP )


function calculateGangwarDamage ( dmg )
	gangwarData[localPlayer].gangwarDamage = gangwarData[localPlayer].gangwarDamage + dmg
	if not gangwarData[localPlayer].showing then
		addEventHandler ( "onClientRender", getRootElement(), dxdrawGangwarAnzeige )
	end
end
addEventHandler ("rechneDMGAn", getRootElement(), calculateGangwarDamage)


function calculateGangwarKills ( killer )
	triggerServerEvent ( "rechneKILLAnServer", source, killer )
end


addEventHandler ( "rechneKillAn", root, function ( kills )
	gangwarData[localPlayer].gangwarKills = kills
end )


function deactivateInventar ( button, press ) 
	if ( press ) and button == "i" then
		cancelEvent()
	end
end


function startStatistik()
	local ver, ang = 0, 0
	local hoehe = 0
	for index, tables in pairs ( gangwarData[localPlayer].sortierteStatistikTabelle ) do
		if tables["Attacker"] then
			hoehe = hoehe + 1
		end
	end
	for index, tables in pairs ( gangwarData[localPlayer].sortierteStatistikTabelle ) do
    	if tables["Attacker"] then
    		-- Rechteck --
    		dxDrawRectangle(screenx-400*sxA, screeny-775*syA+46*syA*(index-ang), 180*sxA, 45*syA, tocolor(gangwarData[localPlayer].attackerR, gangwarData[localPlayer].attackerG, gangwarData[localPlayer].attackerB, 200), true)  -- ATTACKER 
   			-- Stats --
    		dxDrawText("Kill: "..tables["Kills"].." | Dmg: "..tables["Damage"], screenx-400*sxA, screeny-754*syA+46*syA*(index-ang), screenx-220, screeny-740*syA+46*syA*(index-ang),tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false) -- Name
			-- Name --
			dxDrawText(tables["Player"], screenx-400*sxA, screeny-770*syA+46*syA*(index-ang), screenx-220, screeny-740*syA+46*syA*(index-ang),tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false) -- Stats
			ver = ver + 1
		else
    		-- Rechteck --
    		dxDrawRectangle(screenx-210*sxA, screeny-775*syA+46*syA*(index-ver), 180*sxA, 45*syA, tocolor(gangwarData[localPlayer].defenderR, gangwarData[localPlayer].defenderG, gangwarData[localPlayer].defenderB, 200), true) -- DEFENDER
    		-- Stats --
			dxDrawText("Kill: "..tables["Kills"].." | Dmg: "..tables["Damage"], screenx-210*sxA, screeny-754*syA+46*syA*(index-ver), screenx-30, screeny-740*syA+46*syA*(index-ver),tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false) -- Name
			-- Name --
			dxDrawText(tables["Player"], screenx-210*sxA, screeny-770*syA+46*syA*(index-ver), screenx-30, screeny-740*syA+46*syA*(index-ver),tocolor(255, 255, 255, 255), 1.2*syA, "default-bold", "center", "top", false, false, true, false, false) -- Stats
			ang = ang + 1
		end
	end
	setTimer ( function () removeEventHandler ( "onClientRender", getRootElement(), startStatistik ) end, 1000 * zeitinsekundenbisstatistikendet, 1 )
end



function kachingsound_func ( )
	playSound ( "sounds/kaching.mp3" )
end
addEventHandler ( "kaching", getRootElement(), kachingsound_func )


addEventHandler ( "moveVehicleInGangwar", root, function ( veh )
	gangwarData[localPlayer].theveh = veh
	gangwarData[localPlayer].lastvehmove = getTickCount()
	addEventHandler ( "onClientRender", root, showVehicleFlying )
	showCursor ( true )
	bindKey ( "mouse1", "up", triggerTheVehiclePosition ) 
	bindKey ( "mouse_wheel_up", "both", setVehicleRotationUpDown, 3 )
	bindKey ( "mouse_wheel_down", "both", setVehicleRotationUpDown, -3 )
end )


function showVehicleFlying ( )
	local _, _, worldx, worldy, worldz = getCursorPosition()
    local px, py, pz = getCameraMatrix()
	local playerx, playery, playerz = getElementPosition ( localPlayer )
	setCameraMatrix ( playerx, playery, playerz+50, playerx, playery, playerz )
    local hit, x, y, z, elementHit = processLineOfSight ( px, py, pz, worldx, worldy, worldz )
	local _, _, rz = getElementRotation ( gangwarData[localPlayer].theveh )
	if x and y and z then
		z = getGroundPosition ( x, y, z )
		setElementPosition ( gangwarData[localPlayer].theveh, x, y, z+0.6 )
	end
	setElementRotation ( gangwarData[localPlayer].theveh, 0, 0, rz )
end


function triggerTheVehiclePosition ( )
	if gangwarData[localPlayer].lastvehmove+500 <= getTickCount() then
		unbindKey ( "mouse1", "both", triggerTheVehiclePosition ) 
		unbindKey ( "mouse_wheel_up", "both", setVehicleRotationUpDown )
		unbindKey ( "mouse_wheel_down", "both", setVehicleRotationUpDown )
		removeEventHandler ( "onClientRender", root, showVehicleFlying )
		local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
		local px, py, pz = getCameraMatrix()
		local hit, x, y, z, elementHit = processLineOfSight ( px, py, pz, worldx, worldy, worldz )
		z = getGroundPosition ( x, y, z )
		local _, _, rz = getElementRotation ( gangwarData[localPlayer].theveh )
		triggerServerEvent ( "triggerActualVehiclePositionForGangwar", player, gangwarData[localPlayer].theveh, x, y, z+0.9, rz )
		setCameraTarget ( localPlayer )
		gangwarData[localPlayer].theveh = nil
	end
end


function setVehicleRotationUpDown ( button, _, value )
	local _, _, rz = getElementRotation ( gangwarData[localPlayer].theveh )
	setElementRotation ( gangwarData[localPlayer].theveh, 0, 0, rz+value )
end




	
		

 