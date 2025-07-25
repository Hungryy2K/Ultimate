﻿-- Mehrspielerfähiges Rennen: Pro Spieler werden alle relevanten Daten in raceData[localPlayer] gespeichert
local raceData = {}

function race_func(cmd, target)
    local player = localPlayer
    raceData[player] = raceData[player] or {}
    local data = raceData[player]
    target = getPlayerFromName(target)
    if isElement(target) then
        if getPedOccupiedVehicleSeat(lp) == 0 then
            if getPedOccupiedVehicleSeat(target) == 0 then
                if not getElementClicked() and lp ~= target then
                    setElementClicked(true)
                    showCursor(true)
                    showRaceWindow(player)
                    data.raceTarget = target
                end
            else
                infobox("Der Spieler muss\nFahrer eines Fahrzeugs\nsein.", 5000, 150, 0, 0)
            end
        else
            infobox("Du musst Fahrer\neines Fahrzeugs sein!", 5000, 150, 0, 0)
        end
    else
        infobox("Gebrauch: /race [Name]", 5000, 150, 0, 0)
    end
end
addCommandHandler("race", race_func)

function showRaceWindow(player)
    local data = raceData[player]
    gWindow["raceWindow"] = guiCreateWindow(screenwidth/2-288/2,screenheight/2-222/2,288,222,"Wettrennen",false)
    guiSetAlpha(gWindow["raceWindow"],1)
    guiWindowSetSizable(gWindow["raceWindow"],false)
    gGrid["selectedRaceTarget"] = guiCreateGridList(9,26,133,146,false,gWindow["raceWindow"])
    guiGridListSetSelectionMode(gGrid["selectedRaceTarget"],2)
    gColumn["target"] = guiGridListAddColumn(gGrid["selectedRaceTarget"],"Ziel",0.8)
    guiSetAlpha(gGrid["selectedRaceTarget"],1)
    gRadio["withoutBet"] = guiCreateRadioButton(150,40,120,18,"Ohne Einsatz",false,gWindow["raceWindow"])
    guiSetAlpha(gRadio["withoutBet"],1)
    guiSetFont(gRadio["withoutBet"],"default-bold-small")
    gLabel[1] = guiCreateLabel(178,23,82,16,"Wetteinsatz:",false,gWindow["raceWindow"])
    guiSetAlpha(gLabel[1],1)
    guiLabelSetColor(gLabel[1],200,200,0)
    guiLabelSetVerticalAlign(gLabel[1],"top")
    guiLabelSetHorizontalAlign(gLabel[1],"left",false)
    guiSetFont(gLabel[1],"default-bold-small")
    guiCreateNumberField ( x, y, width, height, startValue, bool, parent, true, true )
    gEdit["moneyBet"] = guiCreateNumberField(151,102,44,33,"0",false,gWindow["raceWindow"], true, true )
    guiSetAlpha(gEdit["moneyBet"],1)
    gRadio["betMoney"] = guiCreateRadioButton(150,82,127,18,"Geld",false,gWindow["raceWindow"])
    guiSetAlpha(gRadio["betMoney"],1)
    guiSetFont(gRadio["betMoney"],"default-bold-small")
    guiRadioButtonSetSelected ( gRadio["betMoney"], true )
    gLabel[2] = guiCreateLabel(200,109,13,21,"$",false,gWindow["raceWindow"])
    guiSetAlpha(gLabel[2],1)
    guiLabelSetColor(gLabel[2],0,200,0)
    guiLabelSetVerticalAlign(gLabel[2],"top")
    guiLabelSetHorizontalAlign(gLabel[2],"left",false)
    guiSetFont(gLabel[2],"default-bold-small")
    gLabel[3] = guiCreateLabel(219,110,50,15,"Einsatz",false,gWindow["raceWindow"])
    guiSetAlpha(gLabel[3],1)
    guiLabelSetColor(gLabel[3],255,255,255)
    guiLabelSetVerticalAlign(gLabel[3],"top")
    guiLabelSetHorizontalAlign(gLabel[3],"left",false)
    guiSetFont(gLabel[3],"default-bold-small")
    gButton["raceAgainst"] = guiCreateButton(91,177,110,37,"Herausfordern",false,gWindow["raceWindow"])
    guiSetAlpha(gButton["raceAgainst"],1)
    guiSetFont(gButton["raceAgainst"],"default-bold-small")
    local row
    for i = 1, possibleRaceTargetAmount do
        row = guiGridListAddRow(gGrid["selectedRaceTarget"])
        guiGridListSetItemText(gGrid["selectedRaceTarget"], row, gColumn["target"], possibleRaceTargets["name"][i], false, false)
    end
    addEventHandler("onClientGUIClick", gButton["raceAgainst"],
        function ()
            local row, column = guiGridListGetSelectedItem(gGrid["selectedRaceTarget"])
            local text = guiGridListGetItemText(gGrid["selectedRaceTarget"], row, column)
            local betAmount = tonumber(guiGetText(gEdit["moneyBet"]))
            local betTyp = 0
            if guiRadioButtonGetSelected(gRadio["betMoney"]) then
                betTyp = 1
            else
                betAmount = 0
            end
            targetID = 1
            for i = 1, possibleRaceTargetAmount do
                if possibleRaceTargets["name"][i] == text then
                    targetID = i
                    break
                end
            end
            triggerServerEvent("invitePlayerToRace", lp, text, data.raceTarget, betTyp, betAmount, targetID)
            setElementClicked(false)
            showCursor(false)
            destroyElement(gWindow["raceWindow"])
        end,
    false)
end

function showRaceCountdown()
    local player = localPlayer
    raceData[player] = raceData[player] or {}
    local data = raceData[player]
    data.raceCountdownText = "Mach dich bereit..."
    data.raceCountdownR, data.raceCountdownG, data.raceCountdownB = 200, 200, 100
    playSoundFrontEnd(43)
    addEventHandler("onClientRender", getRootElement(), function() raceCountdown(player) end)
    setTimer(function()
        data.raceCountdownText = 3
        data.raceCountdownR, data.raceCountdownG, data.raceCountdownB = 200, 0, 0
        playSoundFrontEnd(43)
    end, 3000, 1)
    setTimer(function()
        data.raceCountdownText = 2
        playSoundFrontEnd(43)
    end, 1000 + 3000, 1)
    setTimer(function()
        data.raceCountdownText = 1
        playSoundFrontEnd(43)
    end, 2000 + 3000, 1)
    setTimer(function()
        data.raceCountdownText = "GO!"
        playSoundFrontEnd(45)
        data.raceCountdownR, data.raceCountdownG = 0, 200
    end, 3000 + 3000, 1)
    setTimer(function()
        removeEventHandler("onClientRender", getRootElement(), function() raceCountdown(player) end)
    end, 4000 + 3000, 1)
end
addEvent("showRaceCountdown", true)
addEventHandler("showRaceCountdown", getRootElement(), showRaceCountdown)

function raceCountdown(player)
    local data = raceData[player]
    dxDrawText(tostring(data.raceCountdownText),2,2,screenwidth+2,screenheight+2,tocolor(0,0,0,255),3,"pricedown","center","center",false,false,true)
    dxDrawText(tostring(data.raceCountdownText),0,0,screenwidth,screenheight,tocolor(data.raceCountdownR,data.raceCountdownG,data.raceCountdownB,255),3,"pricedown","center","center",false,false,true)
end

function raceWonDraw(player)
    local data = raceData[player]
    dxDrawText("Du hast gewonnen!"..data.raceWonText,2,2,screenwidth+2,screenheight+2,tocolor(0,0,0,255),3,"pricedown","center","center",false,false,true)
    dxDrawText("Du hast gewonnen!"..data.raceWonText,0,0,screenwidth,screenheight,tocolor(0,200,0,255),3,"pricedown","center","center",false,false,true)
end

function raceWon(betAmount)
    local player = localPlayer
    raceData[player] = raceData[player] or {}
    local data = raceData[player]
    if betAmount > 0 then
        data.raceWonText = "\n+ "..betAmount.." $"
    else
        data.raceWonText = ""
    end
    addEventHandler("onClientRender", getRootElement(), function() raceWonDraw(player) end)
    setTimer(function()
        removeEventHandler("onClientRender", getRootElement(), function() raceWonDraw(player) end)
    end, 5000, 1)
    achievsound_func()
end
addEvent("raceWon", true)
addEventHandler("raceWon", getRootElement(), raceWon)