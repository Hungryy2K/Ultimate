-- Mehrspielerfähiger Schießstand: Pro Spieler werden alle relevanten Daten in shootingRanchData[localPlayer] gespeichert
local shootingRanchData = {}

function createTargetToShoot(player, x, y, z, rx, ry, r, int, dim, points)
    local data = shootingRanchData[player]
    local frame = createObject(1587, -321.51257324219, 826.03668212891, 17.146434783936)
    data.framePos[frame] = { ["x"] = x, ["y"] = y, ["z"] = z }
    local part1 = createObject(1592, -321.49752807617, 826.03112792969, 17.175880432129)
    local part2 = createObject(1591, -321.52035522461, 826.03167724609, 17.175880432129)
    local part3 = createObject(1590, -321.52151489258, 826.03161621094, 17.154172897339)
    local part4 = createObject(1589, -321.49887084961, 826.03137207031, 17.155172348022)
    local part5 = createObject(1588, -321.51440429688, 826.03332519531, 17.134246826172)
    attachElementsInCorrectWay(part1, frame)
    attachElementsInCorrectWay(part2, frame)
    attachElementsInCorrectWay(part3, frame)
    attachElementsInCorrectWay(part4, frame)
    attachElementsInCorrectWay(part5, frame)
    setElementInterior(frame, int)
    setElementInterior(part1, int)
    setElementInterior(part2, int)
    setElementInterior(part3, int)
    setElementInterior(part4, int)
    setElementInterior(part5, int)
    setElementDimension(frame, dim)
    setElementDimension(part1, dim)
    setElementDimension(part2, dim)
    setElementDimension(part3, dim)
    setElementDimension(part4, dim)
    setElementDimension(part5, dim)
    setElementPosition(frame, x, y, z)
    setElementRotation(frame, rx, ry, r)
    data.shootingRanchItem[part1] = frame
    data.shootingRanchItem[part2] = frame
    data.shootingRanchItem[part3] = frame
    data.shootingRanchItem[part4] = frame
    data.shootingRanchItem[part5] = frame
    setElementParent(part1, frame)
    setElementParent(part2, frame)
    setElementParent(part3, frame)
    setElementParent(part4, frame)
    setElementParent(part5, frame)
    data.elementsArray[frame] = 5
    data.shootingRangeTargets[frame] = true
    return frame
end

function moveTarget(player, target, x2, y2)
    local data = shootingRanchData[player]
    local x1, y1, z1 = getElementPosition(target)
    local z2 = z1
    data.elementPos[target] = { ["x1"] = x1, ["y1"] = y1, ["z1"] = z1, ["x2"] = x2, ["y2"] = y2 }
    moveObject(target, 10000, x2, y2, z2)
    setTimer(function(element, x1, y1, z1)
        if isElement(element) then
            moveObject(element, 10000, x1, y1, z1)
        end
    end, 10000, 1, target, x1, y1, z1)
    _G[tostring(target).."Timer"] = setTimer(function(element)
        if not isElement(element) then
            killTimer(_G[tostring(element).."Timer"])
        elseif not data.flippingArray[element] then
            local x1, y1, z1 = data.elementPos[element]["x1"], data.elementPos[element]["y1"], data.elementPos[element]["z1"]
            local x2, y2 = data.elementPos[element]["x2"], data.elementPos[element]["x2"]
            local z2 = z1
            moveObject(element, 10000, x2, y2, z2)
            setTimer(function(element, x1, y1, z1)
                if isElement(element) then
                    moveObject(element, 10000, x1, y1, z1)
                end
            end, 10000, 1, element, x1, y1, z1)
        end
    end, 20000, 0, target)
end

function startShootingRanchTest_func()
    local player = localPlayer
    shootingRanchData[player] = {
        flippingArray = {},
        elementPos = {},
        framePos = {},
        shootingRanchItem = {},
        elementsArray = {},
        targetY = {},
        shootingRangeTargets = {},
        totalShootingRangeHitTargets = 0,
        totalShootingRangeShots = 0,
        shootingRanchCountdountVal = "3",
        shootingRanchCountdountR = 200,
        shootingRanchCountdountG = 0,
        shootingRanchCountdountB = 0,
        shootingRanchTimeLeftVal = 600,
        shootingRanchTimeLeft = "60.0"
    }
    local data = shootingRanchData[player]
    setWalkable(false)
    setInvulnerable(true)
    setPedControlState("aim_weapon", true)
    local dim = getElementDimension(lp)
    local target1 = createTargetToShoot(player, 290, -140.5 + 1.74, 1004.180480957 + 2.04, 90, 0, 270, 7, dim, 0)
    local target2 = createTargetToShoot(player, 286, -129.5 + 1.74, 1004.180480957 + 2.04, 90, 0, 270, 7, dim, 0)
    local target3 = createTargetToShoot(player, 274, -140.5 + 1.74, 1004.8396606445 + 2.04, 90, 0, 270, 7, dim, 0)
    data.targetY[target1] = -129.5
    data.targetY[target2] = -140.5
    data.targetY[target3] = -129.5
    local targetMoveTime = 2000
    flapTarget(player, target1, false, targetMoveTime)
    flapTarget(player, target2, false, targetMoveTime)
    flapTarget(player, target3, false, targetMoveTime)
    targetMoveTime = 2100
    setTimer(moveTarget, targetMoveTime, 1, player, target1, 290, -129.5)
    setTimer(moveTarget, targetMoveTime + 500, 1, player, target2, 286, -140.5)
    setTimer(moveTarget, targetMoveTime + 1000, 1, player, target3, 274, -129.5)
    addEventHandler("onClientPlayerWeaponFire", lp, function(...) shootingRanchTargetHit(player, ...) end)
    setTimer(function()
        data.shootingRanchCountdountVal = "2"
        playSoundFrontEnd(43)
    end, 1000, 1)
    setTimer(function()
        data.shootingRanchCountdountVal = "1"
        playSoundFrontEnd(43)
    end, 2000, 1)
    setTimer(function()
        data.shootingRanchCountdountVal = "GO!"
        playSoundFrontEnd(45)
        data.shootingRanchCountdountR = 0
        data.shootingRanchCountdountG = 200
        toggleControl("fire", true)
        setTimer(function()
            removeEventHandler("onClientRender", getRootElement(), function() shootingRanchCountdown_render(player) end)
        end, 1000, 1)
        data.shootingRanchTimeLeftVal = 600
        data.shootingRanchTimeLeft = "60.0"
        addEventHandler("onClientRender", getRootElement(), function() shootingRanchDraw_render(player) end)
        setTimer(function()
            if data.shootingRanchTimeLeft == "0.0" then
                setPedControlState("fire", false)
                toggleControl("fire", false)
                for key, _ in pairs(data.shootingRangeTargets) do
                    if isElement(key) then
                        if not data.flippingArray[key] then
                            flapTarget(player, key, true, 2000)
                        end
                    end
                end
                setTimer(function() endShootingRanchTest_func(player) end, 3000, 1)
            else
                data.shootingRanchTimeLeftVal = data.shootingRanchTimeLeftVal - 1
                local secs = math.floor(data.shootingRanchTimeLeftVal / 10)
                local ms = data.shootingRanchTimeLeftVal - secs * 10
                data.shootingRanchTimeLeft = secs.."."..ms
            end
        end, 100, 601)
    end, 3000, 1)
    addEventHandler("onClientRender", getRootElement(), function() shootingRanchCountdown_render(player) end)
end
addEvent("startShootingRanchTest", true)
addEventHandler("startShootingRanchTest", getRootElement(), startShootingRanchTest_func)

function endShootingRanchTest_func(player)
    local data = shootingRanchData[player]
    setPedControlState("aim_weapon", false)
    removeEventHandler("onClientRender", getRootElement(), function() shootingRanchDraw_render(player) end)
    for key, _ in pairs(data.shootingRangeTargets) do
        if isElement(key) then
            destroyElement(key)
        end
        data.shootingRangeTargets[key] = nil
    end
    local percent = tostring(math.floor(data.totalShootingRangeHitTargets / data.totalShootingRangeShots * 1000) / 10)
    percent = string.sub(percent, 1, 4)
    infobox("\nKugeln verbraucht: \n"..data.totalShootingRangeShots..",\nGetroffene Ziele :\n"..data.totalShootingRangeHitTargets.."\nGenauigkeit: "..percent.." %", 5000, 255, 255, 0)
    setWalkable(true)
    setInvulnerable(false)
    removeEventHandler("onClientPlayerWeaponFire", lp, function(...) shootingRanchTargetHit(player, ...) end)
    triggerServerEvent("endShootingRanchTest", lp, percent, data.totalShootingRangeHitTargets)
end

function shootingRanchTargetHit(player, weapon, _, _, _, _, _, element)
    local data = shootingRanchData[player]
    if element then
        local frame = data.shootingRanchItem[element]
        if frame then
            data.elementsArray[frame] = data.elementsArray[frame] - 1
            data.shootingRanchItem[element] = nil
            data.totalShootingRangeHitTargets = data.totalShootingRangeHitTargets + 1
            if data.elementsArray[frame] == 0 then
                local x, y, z = data.framePos[frame]["x"], data.framePos[frame]["y"], data.framePos[frame]["z"]
                local ty = data.targetY[frame]
                local dim = getElementDimension(lp)
                local newTarget = createTargetToShoot(player, x, y, z, 90, 0, 270, 7, dim, 0)
                local targetMoveTime = 2000
                flapTarget(player, newTarget, false, targetMoveTime)
                setTimer(moveTarget, targetMoveTime, 1, player, newTarget, x, ty)
                data.targetY[newTarget] = ty
                flapTarget(player, frame, true, 1000)
                setTimer(destroyElement, 1000, 1, frame)
                playSoundFrontEnd(101)
            end
        end
    end
    data.totalShootingRangeShots = data.totalShootingRangeShots + 1
end

function flapTarget(player, target, up, time)
    local data = shootingRanchData[player]
    if not time then time = 1000 end
    data.flippingArray[target] = true
    local x, y, z = getElementPosition(target)
    if up then
        moveObject(target, time, x + 1.74, y, z + 2.04, 90, 0, 0)
    else
        moveObject(target, time, x - 1.74, y, z - 2.04, -90, 0, 0)
    end
    setTimer(function(target) data.flippingArray[target] = nil end, time, 1, target)
end

function shootingRanchCountdown_render(player)
    local data = shootingRanchData[player]
    dxDrawText(data.shootingRanchCountdountVal,2,2,screenwidth+2,screenheight+2,tocolor(0,0,0,255),3,"pricedown","center","center",false,false,true)
    dxDrawText(data.shootingRanchCountdountVal,0,0,screenwidth,screenheight,tocolor(data.shootingRanchCountdountR,data.shootingRanchCountdountG,data.shootingRanchCountdountB,255),3,"pricedown","center","center",false,false,true)
end

function shootingRanchDraw_render(player)
    local data = shootingRanchData[player]
    dxDrawText("Zeit: "..data.shootingRanchTimeLeft.." Sekunden", screenwidth / 2 - 614 / 2, 0, 614, 49, tocolor(255,255,255,255), 2.5, "sans", "left", "top", false, false, false)
end

--[[
################## GUI ##################
]]

function showShootingRangeSelection_func()
    if gWindow["shootingRange"] then
        guiSetVisible(gWindow["shootingRange"], true)
    else
        gWindow["shootingRange"] = guiCreateWindow(screenwidth/2-251/2,screenheight/2-178,251,178,"Schiesstand",false)
        guiSetAlpha(gWindow["shootingRange"],1)
        gGrid["shootingRange"] = guiCreateGridList(12,29,143,138,false,gWindow["shootingRange"])
        guiGridListSetSelectionMode(gGrid["shootingRange"],0)
        guiSetAlpha(gGrid["shootingRange"],1)
        gColumn["shootingRange"] = guiGridListAddColumn(gGrid["shootingRange"],"Waffen",0.8)
        gButton["shootingRangeTest"] = guiCreateButton(167,39,72,45,"Waffe testen",false,gWindow["shootingRange"])
        guiSetAlpha(gButton["shootingRangeTest"],1)
        guiSetFont(gButton["shootingRangeTest"],"default-bold-small")
        gButton["shootingRangeClose"] = guiCreateButton(167,107,72,45,"Schliessen",false,gWindow["shootingRange"])
        guiSetAlpha(gButton["shootingRangeClose"],1)
        guiSetFont(gButton["shootingRangeClose"],"default-bold-small")
        addEventHandler("onClientGUIClick", gButton["shootingRangeClose"],
            function ()
                guiSetVisible(gWindow["shootingRange"], false)
                showCursor(false)
                setElementClicked(false)
            end,
        false)
        addEventHandler("onClientGUIClick", gButton["shootingRangeTest"],
            function ()
                local row = guiGridListGetSelectedItem(gGrid["shootingRange"])
                local gun = guiGridListGetItemText(gGrid["shootingRange"], row, gColumn["shootingRange"])
                local id = shootingRangeGunIDs[gun]
                guiSetVisible(gWindow["shootingRange"], false)
                showCursor(false)
                setElementClicked(false)
                if tonumber(id) then
                    triggerServerEvent("startShootingRanch", lp, gun)
                end
            end,
        false)
        for key, index in pairs(shootingRangeGuns["name"]) do
            local name = shootingRangeGuns["name"][key]
            local id = shootingRangeGuns["id"][key]
            local row = guiGridListAddRow(gGrid["shootingRange"])
            guiGridListSetItemText(gGrid["shootingRange"], row, gColumn["shootingRange"], name, false, false)
        end
    end
end
addEvent("showShootingRangeSelection", true)
addEventHandler("showShootingRangeSelection", getRootElement(), showShootingRangeSelection_func)