-------------------------
------- (c) 2010 --------
------- by Zipper -------
-------------------------

-- Mehrspielerfähiges Fun-Race 2: Pro Spieler werden alle relevanten Daten in funRace2Data[localPlayer] gespeichert
local funRace2Data = {}

secRaceCheckpoint = {}
secRaceCheckpoint[1] = { x = 566.85723876953, y = -3765.3896484375, z = 6.5907855033875, size = 30 }
secRaceCheckpoint[2] = { x = 824.33740234375, y = -4013.0458984375, z = 6.7620401382446, size = 30 }
secRaceCheckpoint[3] = { x = 784.1025390625, y = -3671.21875, z = 6.7438087463379, size = 30 }
secRaceCheckpoint[4] = { x = 747.33636474609, y = -3268.4558105469, z = 6.7857022285461, size = 20 }

function showRaceData_func()
    local player = localPlayer
    funRace2Data[player] = funRace2Data[player] or {}
    local data = funRace2Data[player]
    data.curLaps = 0
    data.curCheckpoint = 0
    data.curCheckpointElement = nil
    showNextCheckpoint(player, false)
end
addEvent("showRaceData", true)
addEventHandler("showRaceData", getRootElement(), showRaceData_func)

function showNextCheckpoint(player, dim)
    local data = funRace2Data[player]
    if player == lp then
        if dim then
            playSoundFrontEnd(43)
            if data.curCheckpointElement then
                removeEventHandler("onClientMarkerHit", data.curCheckpointElement, function(hit, dim) showNextCheckpoint(player, dim) end)
            end
        else
            outputChatBox("Runde: "..(data.curLaps+1).."/3!", 0, 125, 0)
        end
        if data.curCheckpointElement and isElement(data.curCheckpointElement) then
            destroyElement(data.curCheckpointElement)
        end
        data.curCheckpoint = (data.curCheckpoint or 0) + 1
        if data.curCheckpoint == 5 then
            outputChatBox("Runde: "..(data.curLaps+1).."/3!", 0, 125, 0)
            data.curLaps = (data.curLaps or 0) + 1
            data.curCheckpoint = 1
        end
        if data.curLaps == 3 then
            triggerServerEvent("raceSecFinished", lp, lp)
        else
            local id = data.curCheckpoint
            local x, y, z, size = secRaceCheckpoint[id].x, secRaceCheckpoint[id].y, secRaceCheckpoint[id].z, secRaceCheckpoint[id].size
            data.curCheckpointElement = createMarker(x, y, z, "checkpoint", size, 150, 0, 0, 200)
            addEventHandler("onClientMarkerHit", data.curCheckpointElement, function(hit, dim) showNextCheckpoint(player, dim) end)
            setElementInterior(data.curCheckpointElement, 1)
            setElementDimension(data.curCheckpointElement, 1)
            local blip = createBlipAttachedTo(data.curCheckpointElement, 0, 1.5, 0, 255, 0, 0, 0, 99999.0)
            setElementInterior(blip, 1)
            setElementDimension(blip, 1)
            setElementParent(blip, data.curCheckpointElement)
        end
    end
end

--[[
<marker id="Boxengasse" color="#05FF0099" dimension="0" interior="0" posX="737.38629150391, -3437.0122070313, 5.2979731559753, 10" type="cylinder" />
]]