-- Utility für Rechteprüfungen

function isPlayerAdmin(player)
    return getElementData(player, "adminlvl") and getElementData(player, "adminlvl") > 0
end

function hasPlayerRight(player, right)
    -- Beispiel: Rechte können als Tabelle im ElementData gespeichert werden
    local rights = getElementData(player, "rights")
    if type(rights) == "table" then
        return rights[right] == true
    end
    return false
end

-- Beispiel für weitere Checks (kann erweitert werden)
function isPlayerInFaction(player, factionId)
    return getElementData(player, "fraktion") == factionId
end 