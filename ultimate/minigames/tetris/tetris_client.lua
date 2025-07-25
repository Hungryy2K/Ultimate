-- Mehrspielerfähiges Tetris: Pro Spieler werden alle relevanten Daten in tetrisData[localPlayer] gespeichert
local tetrisData = {}

function startTetris ( cmd, diff )
    local player = localPlayer
    if vioClientGetElementData ( "gameboy" ) == 1 then
        if tetrisData[player] and tetrisData[player].gImage and isElement(tetrisData[player].gImage["Back"]) then
            outputChatBox ( "Du kannst nur ein Spiel zur selben Zeit spielen.", 125, 0, 0 )
        else
            local diff = math.abs ( math.floor ( tonumber ( diff ) ) )
            if diff and diff <= 10 then
                tetrisData[player] = {
                    level = diff,
                    speed = 1100 - diff * 100,
                    gImage = {},
                    gLabel = {},
                    gButton = {},
                    gWindow = {},
                    fields = {},
                    fixedFields = {},
                    fixedFieldsM = {},
                    showFields = {},
                    blockFalling = false,
                    keysBound = false,
                    music = nil,
                    gameTimer = nil,
                    ncurClass = nil,
                    ncurPos = nil,
                    ncurModel = nil,
                    curClass = nil,
                    curPos = nil,
                    curModel = nil
                }
                createTetrisField(player, nil)
                outputChatBox ( "Tippe /stopblocks, um das Spiel zu beenden.", 125, 0, 0 )
                toggleAllControls ( false, true, false )
            else
                outputChatBox ( "Bitte nutze /blocks [1-10]", 125, 0, 0 )
            end
        end
    end
end
addCommandHandler ( "blocks", startTetris )

function stoptetris_func ()
    local player = localPlayer
    local data = tetrisData[player]
    if not data then return end
    for i = 1, 4 do
        _G["x"..i] = nil
        _G["y"..i] = nil
    end
    for x = 1, 10 do
        for y = 1, 18 do
            removeBlock(player, x, y)
        end
    end
    if data.gImage and isElement(data.gImage["Back"]) then destroyElement(data.gImage["Back"]) end
    if data.music and isElement(data.music) then destroyElement(data.music) end
    if data.gameTimer and isTimer(data.gameTimer) then killTimer(data.gameTimer) end
    if data.keysBound then
        unbindKey ( "arrow_l", "down", moveLeft )
        unbindKey ( "arrow_r", "down", moveRight )
        unbindKey ( "arrow_d", "down", moveDown )
        unbindKey ( "enter", "down", moveTurn )
    end
    data.keysBound = false
    data.blockFalling = false
    toggleAllControls ( true, true, false )
    tetrisData[player] = nil
end
addCommandHandler ( "stopblocks", stoptetris_func )

function createTetrisField (player, parent)
    local data = tetrisData[player]
    if not data then return end
    for x = 1, 10 do
        data.fields[x] = {}
        data.fixedFields[x] = {}
        data.fixedFieldsM[x] = {}
        for y = 1, 18 do
            data.fields[x][y] = false
            data.fixedFields[x][y] = false
            data.fixedFieldsM[x][y] = false
        end
    end
    for x = 1, 4 do
        data.showFields[x] = {}
        for y = 1, 4 do
            data.showFields[x][y] = false
        end
    end
    data.music = playSound ( "sounds/tetris.mp3", true )
    -- (Restliche GUI-Erstellung analog, aber mit data.gImage, data.gLabel, ...)
    -- ...
    if not data.keysBound then
        bindKey ( "arrow_l", "down", moveLeft )
        bindKey ( "arrow_r", "down", moveRight )
        bindKey ( "arrow_d", "down", moveDown )
        bindKey ( "enter", "down", moveTurn )
        data.keysBound = true
    end
    startGame(player)
end

-- Alle weiteren Funktionen (moveLeft, moveRight, moveDown, startGame, startBlock, etc.) müssen analog angepasst werden:
-- Immer zuerst: local data = tetrisData[player]; if not data then return end
-- Und alle Zugriffe auf Felder, GUI, Timer, etc. über data machen.

-- Beispiel für removeBlock:
function removeBlock(player, x, y)
    local data = tetrisData[player]
    if not data then return end
    if data.fields[x][y] and isElement(data.fields[x][y]) then
        destroyElement(data.fields[x][y])
        data.fields[x][y] = false
    end
end

-- Die restlichen Funktionen müssen analog angepasst werden!
-- (Das Muster ist identisch wie beim Tutorial-Refactoring.)