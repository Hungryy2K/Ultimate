local Logger = require("utility.Logger")
local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")
local discordLogger = Logger:new("Discord")
local bankLogger = Logger:new("banklog")

-- Tabelle für gebannte Bank-Accounts
bankBlacklist = {}

function isAbuseTransfer(sender, receiver)
    local senderIP = getPlayerIP(sender)
    local receiverIP = getPlayerIP(receiver)
    local senderSerial = getPlayerSerial(sender)
    local receiverSerial = getPlayerSerial(receiver)
    if senderIP == receiverIP or senderSerial == receiverSerial then
        return true
    end
    return false
end

function canUseBank(player)
    return not bankBlacklist[getPlayerName(player)]
end

function adminBanBankAccount(admin, player)
    local pname = getPlayerName(player)
    bankBlacklist[pname] = true
    adminLogger:info("[BANK-ADMIN] "..getPlayerName(admin).." hat das Bankkonto von "..pname.." gesperrt.")
    outputChatBox("Das Bankkonto von "..pname.." wurde gesperrt.", admin, 255, 0, 0)
    bankLogger:discord("BANKBAN: "..getPlayerName(admin).." hat das Bankkonto von "..pname.." gesperrt.", getPlayerSerial(admin), getPlayerIP(admin))
end

function adminUnbanBankAccount(admin, pname)
    bankBlacklist[pname] = nil
    adminLogger:info("[BANK-ADMIN] "..getPlayerName(admin).." hat das Bankkonto von "..pname.." entsperrt.")
    outputChatBox("Das Bankkonto von "..pname.." wurde entsperrt.", admin, 0, 255, 0)
    bankLogger:discord("BANKUNBAN: "..getPlayerName(admin).." hat das Bankkonto von "..pname.." entsperrt.", getPlayerSerial(admin), getPlayerIP(admin))
end

addCommandHandler("bankban", function(admin, cmd, targetName)
    local target = findPlayerByName(targetName)
    if target then
        adminBanBankAccount(admin, target)
    else
        outputChatBox("Spieler nicht gefunden!", admin, 255, 0, 0)
    end
end)

addCommandHandler("bankunban", function(admin, cmd, targetName)
    adminUnbanBankAccount(admin, targetName)
end)

-- Beispiel für Banküberweisung mit Abuse-Check und Blacklist
function transferMoney(sender, receiver, amount)
    if not canUseBank(sender) then
        outputChatBox("Dein Bankkonto ist gesperrt. Bitte Support kontaktieren.", sender, 255, 0, 0)
        return false
    end
    if not canUseBank(receiver) then
        outputChatBox("Das Zielkonto ist gesperrt. Bitte Support kontaktieren.", sender, 255, 0, 0)
        return false
    end
    if isAbuseTransfer(sender, receiver) then
        securityLogger:error("[BANK-ABUSE] Verdächtige Überweisung: "..getPlayerName(sender).." -> "..getPlayerName(receiver).." ("..amount..")")
        outputChatBox("Überweisung aus Sicherheitsgründen abgelehnt. Support kontaktieren.", sender, 255, 0, 0)
        local serial = getPlayerSerial(sender)
        local ip = getPlayerIP(sender)
        bankLogger:discord("BANK-ABUSE: "..getPlayerName(sender).." -> "..getPlayerName(receiver).." ("..amount..")", serial, ip)
        return false
    end
    -- ... Restliche Prüfungen und eigentliche Überweisung ...
    -- (Hier folgt die eigentliche Logik für den Geldtransfer)
    local serial = getPlayerSerial(sender)
    local ip = getPlayerIP(sender)
    bankLogger:discord("BANK-TRANSFER: "..getPlayerName(sender).." -> "..getPlayerName(receiver).." ("..amount..")", serial, ip)
    return true
end 