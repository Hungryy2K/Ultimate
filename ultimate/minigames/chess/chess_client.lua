-- Mehrspielerfähiges Schach: Pro Spieler werden alle relevanten Daten in chessData[localPlayer] gespeichert
local chessData = {}

function startNewChessParty_func ( ownColor )
    local player = localPlayer
    chessData[player] = chessData[player] or {}
    local data = chessData[player]
    data.ableToDraw = false
    data.chessFields = {}
    data.chessColor = ownColor
    data.curChessFieldSelected = { x = nil, y = nil }
    data.sideOutFigures = {}
    data.kingMoved = false
    data.leftCastleMoved = false
    data.rightCastleMoved = false
    drawList()
    setChessToBasic(player)
    local field = showChessSurface()
    redrawChessField(field)
    addEventHandler("onClientGUIClick", field, function() chessBoardClicked(player) end)
end
addEvent("startNewChessParty", true)
addEventHandler("startNewChessParty", getRootElement(), startNewChessParty_func)

function chessBoardClicked(player)
    local data = chessData[player]
    if data and data.ableToDraw then
        local special = ""
        data.ableToDraw = false
        local x, y = getElementData(source, "x"), getElementData(source, "y")
        if x and y then
            if data.chessFields[x][y] > 0 then
                local color = false
                if data.chessColor == 1 and data.chessFields[x][y] < 10 then
                    color = "white"
                elseif data.chessColor == 2 and data.chessFields[x][y] >= 10 then
                    color = "black"
                end
                if color then
                    local oldX, oldY = data.curChessFieldSelected.x, data.curChessFieldSelected.y
                    if oldX and oldY then
                        removeFieldNewBGColor(oldX, oldY)
                        drawFieldBackgroundAgain(oldX, oldY)
                    end
                    hideReachableFields()
                    setFieldNewBGColor(x, y, "selected")
                    data.curChessFieldSelected.x = x
                    data.curChessFieldSelected.y = y
                    drawFieldBackgroundAgain(x, y)
                    markReachableFieldsForFigure(x, y)
                elseif isFieldValid(x, y) then
                    if data.chessFields[x][y] == 6 or data.chessFields[x][y] == 60 then
                        endDraw(x, y, x, y, "won")
                    else
                        if figure == 1 or figure == 10 then
                            if y == 8 or y == 1 then
                                special = "queen"
                            end
                        end
                        local oldX, oldY = data.curChessFieldSelected.x, data.curChessFieldSelected.y
                        hideReachableFields()
                        removeFieldNewBGColor(oldX, oldY)
                        drawFieldBackgroundAgain(oldX, oldY)
                        changeFigurePosition_func(oldX, oldY, x, y)
                        endDraw(oldX, oldY, x, y, special)
                    end
                    return nil
                end
            elseif isFieldValid(x, y) then
                local oldX, oldY = data.curChessFieldSelected.x, data.curChessFieldSelected.y
                hideReachableFields()
                removeFieldNewBGColor(oldX, oldY)
                drawFieldBackgroundAgain(oldX, oldY)
                local figure = data.chessFields[oldX][oldY]
                if leftRookPossible and x == 3 then
                    special = "rookLeft"
                    changeFigurePosition_func(oldX, oldY, x, y, special)
                    endDraw(oldX, oldY, x, y, special)
                elseif rightRookPossible and x == 7 then
                    special = "rookRight"
                    changeFigurePosition_func(oldX, oldY, x, y, special)
                    endDraw(oldX, oldY, x, y, special)
                else
                    if data.chessFields[oldX][oldY] == 6 or data.chessFields[oldX][oldY] == 60 then
                        data.kingMoved = true
                    elseif oldX == 1 and (oldY == 1 or oldY == 8) then
                        data.leftCastleMoved = true
                    elseif oldX == 8 and (oldY == 1 or oldY == 8) then
                        data.rightCastleMoved = true
                    end
                    if figure == 1 or figure == 10 then
                        if y == 8 or y == 1 then
                            special = "queen"
                        end
                    end
                    changeFigurePosition_func(oldX, oldY, x, y, special)
                    endDraw(oldX, oldY, x, y, special)
                    return nil
                end
            end
        end
        data.ableToDraw = true
    end
end

function looseChessGame()
    outputChatBox("You loose.")
end

function changeFigurePosition_func(x1, y1, x2, y2, special)
    local data = chessData[localPlayer]
    if special == "rookRight" then
        data.chessFields[x2][y2] = data.chessFields[x1][y1]
        data.chessFields[x1][y1] = 0
        data.chessFields[6][y1] = data.chessFields[8][y2]
        data.chessFields[8][y1] = 0
        for i = 5, 8 do drawFieldBackgroundAgain(i, y1) end
        addToDrawList("0-0")
    elseif special == "rookLeft" then
        data.chessFields[x2][y2] = data.chessFields[x1][y1]
        data.chessFields[x1][y1] = 0
        data.chessFields[4][y2] = data.chessFields[1][y2]
        data.chessFields[1][y2] = 0
        for i = 1, 5 do drawFieldBackgroundAgain(i, y1) end
        addToDrawList("0-0-0")
    else
        local figure = data.chessFields[x1][y1]
        if data.chessFields[x2][y2] > 0 then
            drawBeatenFigure(data.chessFields[x2][y2])
        end
        data.chessFields[x2][y2] = figure
        data.chessFields[x1][y1] = 0
        if special == "queen" then
            if data.chessFields[x2][y2] == 1 then
                newFigure = 5
            else
                newFigure = 50
            end
            data.chessFields[x2][y2] = newFigure
            if data.chessFields[x2][y2] < 10 then
                drawBeatenFigure(1)
            else
                drawBeatenFigure(10)
            end
        end
        drawFieldBackgroundAgain(x1, y1)
        drawFieldBackgroundAgain(x2, y2)
        local l1, l2, n1, n2
        l1 = string.char(x1 + 64)
        l2 = string.char(x2 + 64)
        n1 = y1
        n2 = y2
        addToDrawList(l1..n1.."-"..l2..n2)
    end
end
addEvent("changeFigurePosition", true)
addEventHandler("changeFigurePosition", getRootElement(), changeFigurePosition_func)

function endDraw(x1, y1, x2, y2, special)
    triggerServerEvent("endDraw", getLocalPlayer(), x1, y1, x2, y2, special)
    showCursor(false)
end

function startChessDraw_func()
    local data = chessData[localPlayer]
    showCursor(true)
    data.ableToDraw = true
    local x, y = getKingPosition(data.chessColor)
    if wouldFieldBeDangerousForKing(x, y) then
        outputChatBox("Du stehst im Schach!", 125, 0, 0)
    end
end
addEvent("startChessDraw", true)
addEventHandler("startChessDraw", getRootElement(), startChessDraw_func)

function endGame_func()
    if isElement(chessDrawWindow) then destroyElement(chessDrawWindow) end
    if isElement(getChessSurface()) then destroyElement(getChessSurface()) end
    showCursor(false)
end
addEvent("endGame", true)
addEventHandler("endGame", getRootElement(), endGame_func)

function setChessToBasic(player)
    local data = chessData[player]
    data.ableToDraw = false
    data.chessFields = {}
    for x = 1, 8 do
        data.chessFields[x] = {}
        for y = 1, 8 do
            data.chessFields[x][y] = 0
        end
    end
    data.chessFields[1][1] = 20
    data.chessFields[2][1] = 30
    data.chessFields[3][1] = 40
    data.chessFields[4][1] = 50
    data.chessFields[5][1] = 60
    data.chessFields[6][1] = 40
    data.chessFields[7][1] = 30
    data.chessFields[8][1] = 20
    for i = 1, 8 do data.chessFields[i][2] = 10 end
    for i = 1, 8 do data.chessFields[i][7] = 1 end
    data.chessFields[1][8] = 2
    data.chessFields[2][8] = 3
    data.chessFields[3][8] = 4
    data.chessFields[4][8] = 5
    data.chessFields[5][8] = 6
    data.chessFields[6][8] = 4
    data.chessFields[7][8] = 3
    data.chessFields[8][8] = 2
end