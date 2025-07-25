-- Mehrspielerfähiges Boxen: Pro Spieler können temporäre Daten in boxData[player] gespeichert werden
local boxData = {}

boxEnterMarker = createMarker ( -2270.4819335938, -155.90458679199, 34.299884796143, "cylinder", 1.5, 255, 0, 0, 150 )
boxExitMarker = createMarker ( 1741.6705322266, 1783.4482421875, 1544.0844726563, "cylinder", 1.5, 255, 0, 0, 150 )
setElementInterior ( boxExitMarker, 5 )

function enterbox ( hit, dim )
    if hit and dim then
        if getElementType ( hit ) == "player" then
            if not getPedOccupiedVehicle ( hit ) then
                -- Pro Spieler können hier temporäre Daten gespeichert werden, falls benötigt
                boxData[hit] = boxData[hit] or {}
                local x, y, z, r = 1741.3571777344, 1775.3503417969, 1546, 0
                setElementInterior ( hit, 5, x, y, z, r )
            end
        end
    end
end
addEventHandler ( "onMarkerHit", boxEnterMarker, enterbox )

function exitbox ( hit, dim )
    if hit and dim then
        if getElementType ( hit ) == "player" then
            if not getPedOccupiedVehicle ( hit ) then
                -- Pro Spieler können hier temporäre Daten gelöscht werden, falls benötigt
                boxData[hit] = nil
                local x, y, z, r = -2267.333984375, -155.49554443359, 34.969539642334, 105
                setElementInterior ( hit, 0, x, y, z, r )
            end
        end
    end
end
addEventHandler ( "onMarkerHit", boxExitMarker, exitbox )