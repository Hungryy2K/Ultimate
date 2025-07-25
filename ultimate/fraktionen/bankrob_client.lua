-- Mehrspielerfähiger Fraktions-Bankraub: Pro Spieler werden alle relevanten Daten in bankrobData[localPlayer] gespeichert
local bankrobData = {}

function cancelPedDamageBank(attacker)
    if not attacker then
        cancelEvent()
        return
    end
    local fac = getElementData(attacker, "fraktion")
    if fac == 2 or fac == 3 or fac == 7 or fac == 9 or fac == 12 or fac == 13 then
        -- Erlaubte Fraktionen
    else
        cancelEvent()
    end
end

function makeTheBankPedCool(ped)
    local player = localPlayer
    bankrobData[player] = bankrobData[player] or {coolPeds = {}}
    local data = bankrobData[player]
    -- Event-Handler vor dem Hinzufügen entfernen, um doppelte Handler zu vermeiden
    removeEventHandler("onClientPedDamage", ped, cancelPedDamageBank)
    addEventHandler("onClientPedDamage", ped, cancelPedDamageBank)
    table.insert(data.coolPeds, ped)
end

addEvent("onBankPedGetsCool", true)
addEventHandler("onBankPedGetsCool", getRootElement(), makeTheBankPedCool)