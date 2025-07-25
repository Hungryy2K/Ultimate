-- Mehrspielerfähiges Fun-Race: Pro Spieler werden alle relevanten Daten in funRaceData[localPlayer] gespeichert
local funRaceData = {}

function defreeze(player)
    local data = funRaceData[player]
    data.veh = getPedOccupiedVehicle(player)
    if data.frozentimer == 5 then
        outputChatBox("GO!", 0, 125, 0)
        data.racetime = 0
        data.ms, data.s, data.m = 0, 0, 0
        data.racetimer = setTimer(function() showNewRaceTime(player) end, 100, 1)
        if data.gLabel["DeineZeit"] then
            guiSetVisible(data.gLabel["DeineZeit"], true)
        else
            data.gLabel["DeineZeit"] = guiCreateLabel(1,0,400,62,"Deine Zeit:",false)
            guiLabelSetColor(data.gLabel["DeineZeit"],200,200,000)
            guiLabelSetVerticalAlign(data.gLabel["DeineZeit"],"top")
            guiLabelSetHorizontalAlign(data.gLabel["DeineZeit"],"left",false)
            guiSetFont(data.gLabel["DeineZeit"],"sa-header")
        end
        toggleAllControls(true)
        if data.gLabel["TotalTime"] then
            guiSetVisible(data.gLabel["TotalTime"], true)
        else
            data.gLabel["TotalTime"] = guiCreateLabel(82,45,400,100,"0:00:0",false)
            guiLabelSetColor(data.gLabel["TotalTime"],255,255,255)
            guiLabelSetVerticalAlign(data.gLabel["TotalTime"],"top")
            guiLabelSetHorizontalAlign(data.gLabel["TotalTime"],"left",false)
            guiSetFont(data.gLabel["TotalTime"],"sa-gothic")
        end
        playSoundFrontEnd(45)
    else
        outputChatBox("Rennen startet in "..(5-data.frozentimer), 0, 0, 200)
        playSoundFrontEnd(43)
    end
    data.frozentimer = data.frozentimer + 1
end

function startRaceRoundTime_func(sx, sy, sz)
    local player = localPlayer
    funRaceData[player] = funRaceData[player] or {gLabel = {}}
    local data = funRaceData[player]
    data.fmarkerx, data.fmarkery, data.fmarkerz = sx, sy, sz
    data.frozentimer = 0
    toggleAllControls(false)
    toggleControl("enter_exit", false)
    data.raceMarker = createMarker(-780.19860839844, 1221.1427001953, 1012.18264770508, "checkpoint", 23, getColorFromString("#FF000000"))
    setElementDimension(data.raceMarker, 1)
    addEventHandler("onClientMarkerHit", data.raceMarker, function(hitElement) raceMarkerHit(player, hitElement, data.raceMarker) end)
    setTimer(function() defreeze(player) end, 1000, 6)
end
addEvent("startRaceRoundTime", true)
addEventHandler("startRaceRoundTime", getRootElement(), startRaceRoundTime_func)

function showNewRaceTime(player)
    local data = funRaceData[player]
    data.ms = data.ms + 1
    data.s = tonumber(data.s)
    if data.ms >= 10 then
        data.ms = 0
        data.s = data.s + 1
    end
    if data.s >= 60 then
        data.s = 0
        data.m = data.m + 1
    end
    if data.s <= 9 then
        data.s = "0"..data.s
    end
    guiSetText(data.gLabel["TotalTime"], data.m..":"..data.s..":"..data.ms)
    if guiGetVisible(data.gLabel["TotalTime"]) then
        data.racetimer = setTimer(function() showNewRaceTime(player) end, 100, 1)
    end
end

function killRaceClient_func()
    local player = localPlayer
    local data = funRaceData[player]
    if data and data.raceMarker and isElement(data.raceMarker) then
        destroyElement(data.raceMarker)
    end
    if data and data.raceMarkerFinish and isElement(data.raceMarkerFinish) then
        destroyElement(data.raceMarkerFinish)
    end
    if data and data.gLabel["DeineZeit"] then
        guiSetVisible(data.gLabel["DeineZeit"], false)
    end
    if data and data.gLabel["TotalTime"] then
        guiSetVisible(data.gLabel["TotalTime"], false)
    end
end
addEvent("killRaceClient", true)
addEventHandler("killRaceClient", getRootElement(), killRaceClient_func)

function raceMarkerHit(player, hitElement, marker)
    local data = funRaceData[player]
    if hitElement == player then
        if marker == data.raceMarker then
            destroyElement(data.raceMarker)
            data.raceMarkerFinish = createMarker(data.fmarkerx, data.fmarkery, data.fmarkerz, "checkpoint", 23, 0, 200, 0, 255)
            setElementDimension(data.raceMarkerFinish, 1)
            addEventHandler("onClientMarkerHit", data.raceMarkerFinish, function(hitElement) raceMarkerHit(player, hitElement, data.raceMarkerFinish) end)
        elseif data.raceMarkerFinish == marker then
            destroyElement(data.raceMarkerFinish)
            killRaceClient_func()
            triggerServerEvent("raceFinished", hitElement, player, data.ms, data.s, data.m)
        end
    end
end
