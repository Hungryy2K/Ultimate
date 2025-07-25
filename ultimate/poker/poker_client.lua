function joinPokerTable_func ( dim )

	setPokerCamera ()
	createPokerDecoration ( dim )
end
addEvent ( "joinPokerTable", true )
addEventHandler ( "joinPokerTable", getRootElement(), joinPokerTable_func )

function createPokerDecoration ( dim )
    for i = 1, #pokerDekoration["id"] do
        local int = pokerDekoration["int"][i]
        local model = pokerDekoration["id"][i]
        local x, y, z, r = pokerDekoration["x"][i], pokerDekoration["y"][i], pokerDekoration["z"][i], pokerDekoration["r"][i]
        -- Hier kannst du die Dekoration erstellen
    end
end

function setPokerCamera ()

	local x, y, z = pokerChipPositions["x"][0], pokerChipPositions["y"][0], pokerChipZPosition
	local tx, ty = pokerChipPositions["x"][0], pokerChipPositions["y"][0]
	setCameraMatrix ( x, y, pokerCamAddHight + z, tx, ty, z )
end