-- Mehrspielerfähiges Tutorial: Pro Spieler werden alle relevanten Daten in tutorialData[localPlayer] gespeichert
addEvent ( "starttutorial", true )

local tutorialData = {} -- Hier werden alle Tutorialdaten pro Spieler gespeichert

local screenX, screenY = guiGetScreenSize()

function startTutorial ( skinid )
    local player = localPlayer
    tutorialData[player] = {
        skin = skinid,
        objects = {},
        peds = {},
        vehicles = {},
        choicegui = {},
        progress = 0,
        safetyquestion = nil,
        registersound = nil,
        dimension = getElementDimension(player)
    }
    fadeCamera ( false )
    setTimer ( function() tutintro(player) end, 2000, 1 )
end
addEventHandler ( "starttutorial", root, startTutorial )

function tutintro ( player )
    local data = tutorialData[player]
    if not data then return end
    slowDrawText ( "Auf der Flucht    \nund der Suche    \nnach einer zweiten Chance." )
    setTimer ( function() scene1(player) end, 6000, 1 )
    data.objects[1] = createObject ( 1455, -3351, 150, 0 )
    setElementAlpha ( data.objects[1], 0 )
    setElementCollisionsEnabled ( data.objects[1], false )
    data.objects[2] = createObject ( 1455, -3351, 180, 5 )
    setElementAlpha ( data.objects[2], 0 )
    setElementCollisionsEnabled ( data.objects[2], false )
    data.vehicles[1] = createVehicle ( 473, -3380, 150, 0, 0, 0, 270 )
    data.vehicles[2] = createVehicle ( 605, -2813.56, 153.144, 6.9, 0, 0, 181 )
    data.peds[1] = createPed ( 58, -3400, 150, 0, 270 )
    warpPedIntoVehicle ( data.peds[1], data.vehicles[1] )
    data.peds[2] = createPed ( 19, -3400, 140, 0, 270 )
    attachElements ( data.peds[2], data.vehicles[1], -0.6, -0.2, 1, 0, 160 )
    setPedAnimation ( data.peds[2], "BEACH", "ParkSit_M_loop" ) 
    data.peds[3] = createPed ( 26, -3400, 140, 0, 270 )
    attachElements ( data.peds[3], data.vehicles[1], -0.6, -0.2, 1, 0, 160 )
    setPedAnimation ( data.peds[3], "BEACH", "ParkSit_M_loop" ) 
    data.peds[4] = createPed ( 130, -3400, 140, 0, 270 )
    attachElements ( data.peds[4], data.vehicles[1], 0.6, -1.2, 1, 0, 160 )
    setPedAnimation ( data.peds[4], "BEACH", "ParkSit_M_loop" ) 
    data.peds[5] = createPed ( data.skin, -3400, 140, 0, 270 )
    attachElements ( data.peds[5], data.vehicles[1], 0.6, -1.2, 1, 0, 160 )  
    setPedAnimation ( data.peds[5], "BEACH", "ParkSit_M_loop" ) 
    data.peds[6] = createPed ( 15, -2907.9, 156.23, 4.613, 90 )
    setPedAnimation ( data.peds[6], "ON_LOOKERS", "wave_loop" )
    setElementFrozen ( data.peds[6], true )
    local allvehicle = getElementsByType ( "vehicle" )
    for i=1, #allvehicle do
        setElementCollidableWith ( data.vehicles[2], allvehicle[i], false )
    end
    local allplayer = getElementsByType ( "player" )
    for i=1, #allplayer do
        setElementCollidableWith ( data.vehicles[2], allplayer[i], false )
    end
    for i=1, #data.peds do
        setElementCollidableWith ( data.vehicles[2], data.peds[i], false )
    end
end


function scene1 ( player )
    local data = tutorialData[player]
    if not data then return end
    local tutsound = playSound ( "sounds/tutsound.mp3" ) 
    setSoundVolume ( tutsound, 0.6 )
    addEventHandler ( "onClientSoundStopped", tutsound, scene2 )
    setPedControlState ( data.peds[1], "accelerate", true )
    fadeCamera ( true )
    followElementWithElement ( data.objects[2], data.objects[1] )
    setTimer ( scene1follow, 1800, 1 )
end


function scene1follow ( )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    moveObject ( data.objects[1], 7000, -3310, 150, 5 )
    moveObject ( data.objects[2], 4000, -3351, 170, 5 )
    setTimer ( scene1fly, 6000, 1 )
end


function scene1fly ( )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    moveObject ( data.objects[1], 24000, -2000, 140, 30 )
    moveObject ( data.objects[2], 30000, -2020, 250, 70 )
    setTimer ( showScene1Logo, 30500, 1 )
end 


function showScene1Logo ( )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    addEventHandler ( "onClientRender", root, showTutUltimate )
    setElementDimension ( data.objects[1], data.dimension )
    setElementDimension ( data.objects[2], data.dimension )
    for i=1, #data.peds do
        detachElements ( data.peds[i] )
    end
    setPedControlState ( data.peds[1], "accelerate", false )
    setElementPosition ( data.vehicles[1], -2929.62, 156.1, 0.75 )
    setPedAnimation ( data.peds[6] )
    setElementPosition ( data.peds[5], -2908.9, 156.23, 5.12 )
    setElementRotation ( data.peds[5], 0, 0, 270 )
end


function showTutUltimate ( )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    dxDrawText ( "Ultimate Reallife", 0, 0, screenX, screenY, tocolor ( 25, 96, 178 ), 8, "pricedown", "center", "center", false, true, true )
end


function scene2 ( player )
    local data = tutorialData[player]
    if not data then return end
    removeEventHandler ( "onClientRender", root, showTutUltimate ) 
    setElementPosition ( data.objects[2], -2913.3, 156.23, 3.27 ) 
    setElementPosition ( data.objects[1], -2911.3, 156.23, 4.47 ) 
    moveObject ( data.objects[2], 5000, -2910.9, 156.23, 5.47 ) 
    moveObject ( data.objects[1], 5000, -2908.9, 156.23, 5.17 ) 
    setPedAnimation ( data.peds[5] )
    setPedAnimation ( data.peds[3] )
    setElementPosition ( data.peds[3], -2907.9, 154.23, 4.613 )
    setElementRotation ( data.peds[3], 0, 0, 270 )
    setElementPosition ( data.peds[2], -2905.9, 158.23, 4.713 )
    setElementRotation ( data.peds[2], 0, 0, 90 )
    setPedAnimation ( data.peds[6], "MISC", "Idle_Chat_02" )
    setTimer ( scene2Talk, 5500, 1 )
end


function scene2Talk ( player )
    local data = tutorialData[player]
    if not data then return end
    data.progress = 0
    removeEventHandler ( "onClientRender", root, showIfYouWantTut )
    addEventHandler ( "onClientRender", root, showIfYouWantTut )
end


function showIfYouWantTut ( player )
    local data = tutorialData[player]
    if not data then return end
    local x, y, z = getPedBonePosition ( data.peds[6], 8 )
    local xScreen, yScreen = getScreenFromWorldPosition ( x, y, z+0.3 )
    if not xScreen or not yScreen then return end
    local text = ""
    if data.progress <= 200 then
        text = "Willkommen in San Fierro!"
    elseif data.progress <= 400 then
        text = "Ich bin auch erst\nvor wenigen Jahren hierher geflüchtet."
    elseif data.progress <= 600 then
        text = "Daher weiß ich, wie es\nist hier neu zu sein."
    elseif data.progress <= 800 then
        text = "Oder wie hart die Flucht\nvor dem Krieg war."
    elseif data.progress <= 1000 then
        text = "Gleich zeige ich den\nLeuten hier alle wichtigen Orte."
    else
        text = "Willst du bei der Tour mitmachen?"
    end
    if data.safetyquestion then
        text = "Bist du dir sicher?"
    end
    if data.progress == 1150 then
        showCursor ( true )
        data.choicegui[1] = guiCreateButton ( 0, 0, 0.5, 1, "", true )
        data.choicegui[2] = guiCreateButton ( 0.5, 0, 1, 1, "", true )
        guiSetAlpha ( data.choicegui[1], 0 )
        guiSetAlpha ( data.choicegui[2], 0 )
        addEventHandler ( "onClientGUIClick", data.choicegui[1], clickOnTutChoice )
        addEventHandler ( "onClientGUIClick", data.choicegui[2], clickOnTutChoice )
        setPedAnimation ( data.peds[6] )
    end
    if data.progress >= 1150 then
        local xm = getCursorPosition()
        dxDrawText ( xm < 0.5 and "Ja" or "Nein", 0, screenY*0.05, screenX, screenY*0.1, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )
        dxDrawRectangle ( 0, 0, 0.5*screenX, screenY, tocolor ( 0, 255, 0, 5 ), false )
        dxDrawRectangle ( 0.5*screenX, 0, screenX, screenY, tocolor ( 255, 0, 0, 5 ), false )
    end
    dxDrawText ( text, xScreen+1, yScreen, xScreen+1, yScreen, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, xScreen+1, yScreen+1, xScreen+1, yScreen+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, xScreen, yScreen+1, xScreen, yScreen+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, xScreen, yScreen, xScreen, yScreen, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )
    data.progress = data.progress + 1
end


function clickOnTutChoice ( button, state, x, y )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    if button == "left" and state == "up" then
        if x < screenX*0.5 then
            if data.safetyquestion == 1 then
                showTutorialImportantPlaces(player)
            elseif data.safetyquestion == 2 then
                setTimer ( endtutorial, 2000, 1 )
                fadeCamera ( false )
            else
                data.safetyquestion = 1
            end
        else
            if data.safetyquestion then
                data.safetyquestion = nil
            else
                data.safetyquestion = 2 
            end
            return 
        end
        if isElement(data.choicegui[1]) then destroyElement ( data.choicegui[1] ) end
        if isElement(data.choicegui[2]) then destroyElement ( data.choicegui[2] ) end
        showCursor ( false )
        removeEventHandler ( "onClientRender", root, showIfYouWantTut )
    end
end



function showTutorialImportantPlaces ( player )
    local data = tutorialData[player]
    if not data then return end
    local registersound = playSound ( "sounds/registermusik.mp3" )
    setSoundVolume ( registersound, 0.3 )
    setElementPosition ( data.peds[5], -2814.56, 153.144, 6.87 )
    setElementRotation ( data.peds[5], 0, 0, 180 )
    warpPedIntoVehicle ( data.peds[2], data.vehicles[2], 1 )
    warpPedIntoVehicle ( data.peds[6], data.vehicles[2] )
    attachElements ( data.peds[3], data.vehicles[2], -0.5, -0.9, 0.8, 0, 0, 90 )
    attachElements ( data.peds[5], data.vehicles[2], 0.5, -0.9, 0.8, 0, 0, 270 )
    attachElements ( data.objects[1], data.vehicles[2] )
    attachElements ( data.objects[2], data.vehicles[2], 0, -10, 3 )
    setPedAnimation ( data.peds[3], "BEACH", "ParkSit_M_loop" ) 
    setPedAnimation ( data.peds[5], "BEACH", "ParkSit_M_loop" ) 
    setTimer ( tutorialStartTheCarFirst, 2000, 1 )
    fadeCamera ( false, 4 )
end 


function tutorialStartTheCarFirst ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", true )
    setTimer ( tutorialFadeCameraForFirstPlace, 3000, 1 )
end


function tutorialFadeCameraForFirstPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", false )
    setElementPosition ( data.vehicles[2], -2751.805, 407.687, 3.932 )
    setElementRotation ( data.vehicles[2], 0, 0, 180 )
    fadeCamera ( true )
    setTimer ( tutorialShowFirstPlace, 3500, 1 )
end


function tutorialShowFirstPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    detachElements ( data.objects[1] )
    setElementPosition ( data.objects[1], -2751.7802734375, 374.80633544922, 3.9852495193481 )
    detachElements ( data.objects[2] )
    setElementPosition ( data.objects[2], -2751.7802734375, 384.80633544922, 6.9852495193481 )
    moveObject ( data.objects[1], 3000, -2761.7802734375, 378.80633544922, 6.9852495193481 )
    data.progress = 0
    addEventHandler ( "onClientRender", root, tutorialDrawFirstPlaceText )
end


function tutorialDrawFirstPlaceText ( player )
    local data = tutorialData[player]
    if not data then return end
    local text = ""
    if data.progress <= 200 then
        text = "Hier ist die Stadthalle\nbzw. das Rathaus"
    elseif data.progress <= 400 then
        text = "Sie ist das Herzstück\ndieser kleinen Stadt."
    elseif data.progress <= 600 then
        text = "Falls du Lizenzen oder Scheine brauchst,\nkannst du sie hier bekommen."
    elseif data.progress <= 800 then
        text = "Außerdem kannst du hier\ndie Erlaubnis für mehr Fahrzeuge\nerkaufen oder alle Jobs sehen."
    end
    if data.progress == 700 then
        local x, y, z = getElementPosition ( data.objects[1] )
        moveObject ( data.objects[1], 3000, x+20, y, z )
    end
    if data.progress == 1000 then
        removeEventHandler ( "onClientRender", root, tutorialDrawFirstPlaceText )
        attachElements ( data.objects[1], data.vehicles[2] )
        attachElements ( data.objects[2], data.vehicles[2], 0, -10, 3 )
        setTimer ( tutorialStartTheCarSecond, 2000, 1 )
        fadeCamera ( false, 4 )
    end
    dxDrawText ( text, screenX/2+1, screenY/3+1, screenX/2+1, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2+1, screenY/3, screenX/2+1, screenY/3, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3+1, screenX/2, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3, screenX/2, screenY/3, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )  
    data.progress = data.progress + 1
end


function tutorialStartTheCarSecond ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", true )
    setTimer ( tutorialStartSecondPlace, 3000, 1 )
end


function tutorialStartSecondPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", false )
    setElementPosition ( data.vehicles[2], -2009.278, 199.189, 27.305832 )
    setElementRotation ( data.vehicles[2], 0, 0, 180 )
    fadeCamera ( true )
    setTimer ( tutorialShowSecondPlace, 3500, 1 )
end


function tutorialShowSecondPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    detachElements ( data.objects[1] )
    setElementPosition ( data.objects[1], -2009.2779541016, 150.17945861816, 27.377531051636 )
    detachElements ( data.objects[2] )
    setElementPosition ( data.objects[2], -2009.2779541016, 160.17945861816, 30.377531051636 )
    moveObject ( data.objects[1], 3000, -1999.2779541016, 154.17945861816, 30.377531051636 )
    data.progress = 0
    addEventHandler ( "onClientRender", root, tutorialDrawSecondPlaceText )
end


function tutorialDrawSecondPlaceText ( player )
    local data = tutorialData[player]
    if not data then return end
    local text = ""
    if data.progress <= 200 then
        text = "Das ist der Treffpunkt\nder Bürger von SF."
    elseif data.progress <= 400 then
        text = "Es ist der Bahnhof\nvon San Fierro."
    elseif data.progress <= 600 then
        text = "Hier halten sich\ndie meisten auf.\nDaher ist hier das meiste los."
    elseif data.progress <= 800 then
        text = "Komm also her,\nwenn du dich mit\nanderen Leuten unterhalten willst."
    end
    if data.progress == 700 then
        local x, y, z = getElementPosition ( data.objects[1] )
        moveObject ( data.objects[1], 3000, x-20, y, z )
    end
    if data.progress == 1000 then
        removeEventHandler ( "onClientRender", root, tutorialDrawSecondPlaceText )
        attachElements ( data.objects[1], data.vehicles[2] )
        attachElements ( data.objects[2], data.vehicles[2], 0, -10, 3 )
        setTimer ( tutorialStartTheCarThird, 2000, 1 )
        fadeCamera ( false, 4 )
    end
    dxDrawText ( text, screenX/2+1, screenY/3+1, screenX/2+1, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2+1, screenY/3, screenX/2+1, screenY/3, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3+1, screenX/2, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3, screenX/2, screenY/3, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )  
    data.progress = data.progress + 1
end


function tutorialStartTheCarThird ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", true )
    setTimer ( tutorialStartThirdPlace, 3000, 1 )
end


function tutorialStartThirdPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", false )
    setElementPosition ( data.vehicles[2], -1583.587, 736.078, 8 )
    setElementRotation ( data.vehicles[2], 0, 0, 90 )
    setElementFrozen ( data.vehicles[2], true )
    fadeCamera ( true )
    setTimer ( tutorialShowThirdPlace, 3500, 1 )
end


function tutorialShowThirdPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    detachElements ( data.objects[1] )
    setElementPosition ( data.objects[1], -1583.3830566406, 740.07946777344, 7.6930375099182 )
    detachElements ( data.objects[2] )
    setElementPosition ( data.objects[2], -1579.3830566406, 740.07946777344, 10.6930375099182 )
    moveObject ( data.objects[1], 3000, -1587.3830566406, 730.07946777344, 11.6930375099182 )
    data.progress = 0
    addEventHandler ( "onClientRender", root, tutorialDrawThirdPlaceText )
end


function tutorialDrawThirdPlaceText ( player )
    local data = tutorialData[player]
    if not data then return end
    local text = ""
    if data.progress <= 150 then
        text = "Das ist das\nPolice Department."
    elseif data.progress <= 300 then
        text = "Es ist die Hauptbasis\nder Polizisten."
    elseif data.progress <= 450 then
        text = "Falls du gesucht wirst\nkannst du dich hier stellen."
    elseif data.progress <= 600 then
        text = "In und außerhalb San Fierro\ngibt es noch viele Basen ..."
    elseif data.progress <= 800 then
        text = "Da wäre die\nBasis des FBI"
    elseif data.progress <= 1000 then
        text = "oder die Area51,\nBasis der Army"
    elseif data.progress <= 1100 then
        text = "Die Basis der Triaden,\nder chinesischen Mafia."
    elseif data.progress <= 1200 then
        text = "Die italienische Mafia\nCosa Nostra."
    elseif data.progress <= 1300 then
        text = "Angels of Death,\nBiker"
    elseif data.progress <= 1400 then
        text = "Grove Street"
    elseif data.progress <= 1500 then
        text = "Mexikanische Mafia\nLos Aztecas."
    elseif data.progress <= 1600 then
        text = "Ballas"
    elseif data.progress <= 1700 then
        text = "Mechaniker"
    elseif data.progress <= 1800 then
        text = "Medic"
    elseif data.progress <= 1900 then
        text = "und zuletzt Reporter"
    end
    if data.progress == 600 then
        setElementPosition ( data.objects[1], -2392.37, 496.68, 33.48 )
        setElementPosition ( data.objects[2], -2388.055, 495.03, 34.563 )
    elseif data.progress == 800 then
        setElementPosition ( data.objects[1], 80.8246, 1922.54895, 38.95 )
        setElementPosition ( data.objects[2], 49.8246, 1922.54895, 40.86 )
    elseif data.progress == 1000 then
        setElementPosition ( data.objects[1], -2268.18, 650.44, 49.1 )
        setElementPosition ( data.objects[2], -2270.35864, 652.45, 49.06 )
    elseif data.progress == 1100 then
        setElementPosition ( data.objects[1], -735.806, 982.2967, 25.442 )
        setElementPosition ( data.objects[2], -741.68, 987.0436, 27.8 )
    elseif data.progress == 1200 then
        setElementPosition ( data.objects[1], -2203.665, -2373.256347, 50.4415 )
        setElementPosition ( data.objects[2], -2202.576, -2379.777, 53.677 )
    elseif data.progress == 1300 then
        setElementPosition ( data.objects[1], -2492.59497, -130, 40.8 )
        setElementPosition ( data.objects[2], -2525.766357, -130, 44.2 )
    elseif data.progress == 1400 then
        setElementPosition ( data.objects[1], -1245.434, 2479.83, 109.4 )
        setElementPosition ( data.objects[2], -1232.8033, 2474.05, 111.73 )
    elseif data.progress == 1500 then
        setElementPosition ( data.objects[1], -2208, 20, 52.41 )
        setElementPosition ( data.objects[2], -2208, 10, 53.41 )
    elseif data.progress == 1600 then
        setElementPosition ( data.objects[1], -2352.78, -108.52, 50.43 )
        setElementPosition ( data.objects[2], -2348.98, -103.6846, 51.455 )
    elseif data.progress == 1700 then
        setElementPosition ( data.objects[1], -2607.223, 587.654, 23.21 )
        setElementPosition ( data.objects[2], -2603.1, 584.95, 23.86 )
    elseif data.progress == 1800 then
        setElementPosition ( data.objects[1], -2474.964, -595.31, 141.77 )
        setElementPosition ( data.objects[2], -2467.79, -591.1854, 143.3886 )	
    elseif data.progress == 1900 then
        removeEventHandler ( "onClientRender", root, tutorialDrawThirdPlaceText )
        attachElements ( data.objects[1], data.vehicles[2] )
        attachElements ( data.objects[2], data.vehicles[2], 0, -10, 3 )
        setTimer ( tutorialStartTheCarFourth, 2000, 1 )
        setElementFrozen ( data.vehicles[2], false )
        fadeCamera ( false, 4 )
    end
    dxDrawText ( text, screenX/2+1, screenY/3+1, screenX/2+1, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2+1, screenY/3, screenX/2+1, screenY/3, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3+1, screenX/2, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3, screenX/2, screenY/3, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )  
    data.progress = data.progress + 1
end


function tutorialStartTheCarFourth ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", true )
    setTimer ( tutorialStartFourthPlace, 3000, 1 )
end


function tutorialStartFourthPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    setPedControlState ( data.peds[6], "accelerate", false )
    setElementPosition ( data.vehicles[2], -2009.2779541016, 196.17945861816, 27.377531051636 )
    setElementRotation ( data.vehicles[2], 0, 0, 180 )
    setElementFrozen ( data.vehicles[2], true )
    fadeCamera ( true )
    setTimer ( tutorialShowFourthPlace, 3500, 1 )
end


function tutorialShowFourthPlace ( player )
    local data = tutorialData[player]
    if not data then return end
    data.progress = 0
    addEventHandler ( "onClientRender", root, tutorialDrawFourthPlaceText )
end


function tutorialDrawFourthPlaceText ( player )
    local data = tutorialData[player]
    if not data then return end
    local text = ""
    if data.progress <= 200 then
        text = "Das war es mit der Tour."
    elseif data.progress <= 400 then
        text = "Bevor ihr geht noch\nein paar Geschenke."
    elseif data.progress <= 600 then
        text = "Hier, eine Karte für euch."
    elseif data.progress <= 800 then
        text = "Damit wisst ihr immer, wo ihr seid und wo etwas ist."
    elseif data.progress <= 1100 then
        text = "Außerdem gebe ich noch etwas Geld mit."
    elseif data.progress <= 1300 then
        text = "Wir sehen uns hoffentlich bald wieder."	
    end
    if data.progress == 400 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 420 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 440 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 460 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 480 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 500 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 520 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 540 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 560 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 580 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 600 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 620 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 640 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 660 then
        setPlayerHudComponentVisible ( "radar", false )
    elseif data.progress == 680 then
        setPlayerHudComponentVisible ( "radar", true )
    elseif data.progress == 1200 then
        triggerServerEvent ( "setPlayerTutorialMoney", player )
    elseif data.progress == 1300 then
        fadeCamera ( false )
        setTimer ( endtutorial, 2000, 1 )
    end
    dxDrawText ( text, screenX/2+1, screenY/3+1, screenX/2+1, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2+1, screenY/3, screenX/2+1, screenY/3, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3+1, screenX/2, screenY/3+1, tocolor ( 0, 0, 0 ), 3, "default", "center", "center", false, false, true )
    dxDrawText ( text, screenX/2, screenY/3, screenX/2, screenY/3, tocolor ( 255, 255, 255 ), 3, "default", "center", "center", false, false, true )  
    data.progress = data.progress + 1
end

-- Rathaus: -2751.7802734375 369.80633544922 3.9852495193481
-- Bahnhof: -2009.2779541016 196.17945861816 27.377531051636
-- PD: -1583.3830566406 736.07946777344 7.6930375099182

function endtutorial ( )
    local player = localPlayer
    local data = tutorialData[player]
    if not data then return end
    setCameraTarget ( player )
    for _, v in pairs ( data.objects ) do
        if isElement(v) then destroyElement ( v ) end
    end
    for _, v in pairs ( data.peds ) do
        if isElement(v) then destroyElement ( v ) end
    end
    for _, v in pairs ( data.vehicles ) do
        if isElement(v) then destroyElement ( v ) end
    end
    for _, v in pairs ( data.choicegui ) do
        if isElement ( v ) then
            destroyElement ( v )
        end
    end
    fadeCamera ( true )
    if data.registersound then stopSound ( data.registersound ) end
    bindKey ("b", "down", showOtherHud)
    setPlayerHudComponentVisible ( "all", true )
    showOtherHud ()
    triggerServerEvent ( "tutorialended", player )
    tutorialData[player] = nil -- Speicher freigeben
end




