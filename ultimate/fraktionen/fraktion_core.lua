-- Zentrales Fraktionssystem-Modul
-- Basisdatenstruktur, Rechteverwaltung, Platzhalter für spätere Features

Fraktionen = {
    -- Beispiel: Fraktion 1 (SFPD)
    [1] = {
        name = "SFPD",
        leader = "",
        coLeaders = {},
        members = {
            -- [Spielername] = {rang = 3, lastLogin = 0, invitedBy = "", joined = 0}
        },
        rights = {
            -- [Rang] = {invite = true, kick = true, bank = true, event = false}
            [5] = {invite = true, kick = true, bank = true, event = true},
            [4] = {invite = true, kick = false, bank = true, event = false},
            [3] = {invite = false, kick = false, bank = false, event = false},
        },
        kasse = 0,
        kassenLog = {},
        bewerbungen = {},
        board = {},
        events = {},
        blacklist = {},
    },
    -- Weitere Fraktionen können hier ergänzt werden
}

-- Utility: Prüft, ob ein Spieler ein bestimmtes Recht in der Fraktion hat
function hasFraktionRight(fraktionId, player, right)
    if not Fraktionen[fraktionId] then return false end
    local pname = type(player) == "string" and player or getPlayerName(player)
    local member = Fraktionen[fraktionId].members[pname]
    if not member then return false end
    local rang = member.rang
    return Fraktionen[fraktionId].rights[rang] and Fraktionen[fraktionId].rights[rang][right] or false
end

-- === Bewerbungs-System ===

-- Spieler bewirbt sich bei einer Fraktion
function fraktion_addApplication(fraktionId, player, text)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if Fraktionen[fraktionId].members[pname] then
        return false, "Du bist bereits Mitglied dieser Fraktion."
    end
    if Fraktionen[fraktionId].bewerbungen[pname] then
        return false, "Du hast dich bereits beworben."
    end
    Fraktionen[fraktionId].bewerbungen[pname] = {
        text = text or "",
        datum = getRealTime().timestamp or os.time(),
    }
    -- Logging (später: Discord, Datenbank, etc.)
    outputDebugString("[Fraktion] "..pname.." hat sich bei "..Fraktionen[fraktionId].name.." beworben.")
    return true
end

-- Bewerbung annehmen
function fraktion_acceptApplication(fraktionId, admin, player)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not Fraktionen[fraktionId].bewerbungen[pname] then
        return false, "Keine Bewerbung vorhanden."
    end
    -- Mitglied aufnehmen
    Fraktionen[fraktionId].members[pname] = {
        rang = 1,
        lastLogin = getRealTime().timestamp or os.time(),
        invitedBy = type(admin) == "string" and admin or getPlayerName(admin),
        joined = getRealTime().timestamp or os.time(),
    }
    Fraktionen[fraktionId].bewerbungen[pname] = nil
    -- Logging
    outputDebugString("[Fraktion] "..pname.." wurde von "..(type(admin)=="string" and admin or getPlayerName(admin)).." in "..Fraktionen[fraktionId].name.." aufgenommen.")
    return true
end

-- Bewerbung ablehnen
function fraktion_rejectApplication(fraktionId, admin, player)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not Fraktionen[fraktionId].bewerbungen[pname] then
        return false, "Keine Bewerbung vorhanden."
    end
    Fraktionen[fraktionId].bewerbungen[pname] = nil
    -- Logging
    outputDebugString("[Fraktion] "..pname.." wurde von "..(type(admin)=="string" and admin or getPlayerName(admin)).." abgelehnt (Fraktion: "..Fraktionen[fraktionId].name..").")
    return true
end

-- Bewerbungen einer Fraktion abrufen
function fraktion_getApplications(fraktionId)
    if not Fraktionen[fraktionId] then return {} end
    return Fraktionen[fraktionId].bewerbungen
end

-- === Mitgliederverwaltung ===

-- Mitglied aus Fraktion entfernen (Kick)
function fraktion_kickMember(fraktionId, admin, player)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local adminName = type(admin) == "string" and admin or getPlayerName(admin)
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not Fraktionen[fraktionId].members[pname] then
        return false, "Spieler ist kein Mitglied."
    end
    if not hasFraktionRight(fraktionId, admin, "kick") then
        return false, "Keine Berechtigung."
    end
    Fraktionen[fraktionId].members[pname] = nil
    outputDebugString("[Fraktion] "..pname.." wurde von "..adminName.." aus "..Fraktionen[fraktionId].name.." entfernt.")
    return true
end

-- Mitglied befördern (Rang erhöhen)
function fraktion_promoteMember(fraktionId, admin, player)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local adminName = type(admin) == "string" and admin or getPlayerName(admin)
    local pname = type(player) == "string" and player or getPlayerName(player)
    local member = Fraktionen[fraktionId].members[pname]
    if not member then return false, "Spieler ist kein Mitglied." end
    if not hasFraktionRight(fraktionId, admin, "invite") then
        return false, "Keine Berechtigung."
    end
    if member.rang >= 5 then return false, "Maximalrang erreicht." end
    member.rang = member.rang + 1
    outputDebugString("[Fraktion] "..pname.." wurde von "..adminName.." auf Rang "..member.rang.." befördert ("..Fraktionen[fraktionId].name..")")
    return true
end

-- Mitglied degradieren (Rang verringern)
function fraktion_demoteMember(fraktionId, admin, player)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local adminName = type(admin) == "string" and admin or getPlayerName(admin)
    local pname = type(player) == "string" and player or getPlayerName(player)
    local member = Fraktionen[fraktionId].members[pname]
    if not member then return false, "Spieler ist kein Mitglied." end
    if not hasFraktionRight(fraktionId, admin, "invite") then
        return false, "Keine Berechtigung."
    end
    if member.rang <= 1 then return false, "Minimalrang erreicht." end
    member.rang = member.rang - 1
    outputDebugString("[Fraktion] "..pname.." wurde von "..adminName.." auf Rang "..member.rang.." degradiert ("..Fraktionen[fraktionId].name..")")
    return true
end

-- === Fraktionskasse & Kassenlog ===

-- Geld in die Fraktionskasse einzahlen
function fraktion_deposit(fraktionId, player, amount)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    if amount <= 0 then return false, "Ungültiger Betrag" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not Fraktionen[fraktionId].members[pname] then return false, "Kein Mitglied" end
    -- Rechteprüfung: Jeder darf einzahlen
    Fraktionen[fraktionId].kasse = Fraktionen[fraktionId].kasse + amount
    table.insert(Fraktionen[fraktionId].kassenLog, {
        typ = "Einzahlung",
        name = pname,
        betrag = amount,
        zeit = getRealTime().timestamp or os.time(),
    })
    outputDebugString("[Fraktion] "..pname.." hat "..amount.."$ in die Kasse von "..Fraktionen[fraktionId].name.." eingezahlt.")
    return true
end

-- Geld aus der Fraktionskasse auszahlen
function fraktion_withdraw(fraktionId, player, amount)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    if amount <= 0 then return false, "Ungültiger Betrag" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not Fraktionen[fraktionId].members[pname] then return false, "Kein Mitglied" end
    if not hasFraktionRight(fraktionId, player, "bank") then return false, "Keine Berechtigung" end
    if Fraktionen[fraktionId].kasse < amount then return false, "Nicht genug Geld in der Kasse" end
    Fraktionen[fraktionId].kasse = Fraktionen[fraktionId].kasse - amount
    table.insert(Fraktionen[fraktionId].kassenLog, {
        typ = "Auszahlung",
        name = pname,
        betrag = amount,
        zeit = getRealTime().timestamp or os.time(),
    })
    outputDebugString("[Fraktion] "..pname.." hat "..amount.."$ aus der Kasse von "..Fraktionen[fraktionId].name.." entnommen.")
    return true
end

-- Kassenlog abrufen
function fraktion_getKassenLog(fraktionId, limit)
    if not Fraktionen[fraktionId] then return {} end
    local log = Fraktionen[fraktionId].kassenLog
    if not limit or #log <= limit then return log end
    -- Nur die letzten N Einträge
    local res = {}
    for i = #log-limit+1, #log do
        table.insert(res, log[i])
    end
    return res
end

-- === Anti-Abuse & Fairness ===

-- Cooldown- und Invite-Limit-Tracking (im RAM, für Persistenz später DB)
FraktionInviteCooldowns = {} -- [playerName] = timestamp
FraktionInviteCounts = {}    -- [playerName] = {tag = yyyymmdd, count = n}
INVITE_COOLDOWN = 60        -- Sekunden
INVITE_LIMIT_PER_DAY = 5    -- Einladungen pro Tag

-- Hilfsfunktion: Gibt das heutige Datum als Zahl zurück (yyyymmdd)
local function getToday()
    local t = getRealTime()
    return t.year*10000 + (t.month+1)*100 + t.monthday
end

-- Prüft, ob ein Spieler eingeladen werden darf (Cooldown & Tageslimit)
function fraktion_canInvite(player)
    local pname = type(player) == "string" and player or getPlayerName(player)
    local now = getRealTime().timestamp or os.time()
    -- Cooldown
    if FraktionInviteCooldowns[pname] and now - FraktionInviteCooldowns[pname] < INVITE_COOLDOWN then
        return false, "Bitte warte vor der nächsten Einladung."
    end
    -- Tageslimit
    local today = getToday()
    local info = FraktionInviteCounts[pname]
    if info and info.tag == today and info.count >= INVITE_LIMIT_PER_DAY then
        return false, "Tageslimit für Einladungen erreicht."
    end
    return true
end

-- Nach erfolgreicher Einladung aufrufen
function fraktion_registerInvite(player)
    local pname = type(player) == "string" and player or getPlayerName(player)
    local now = getRealTime().timestamp or os.time()
    FraktionInviteCooldowns[pname] = now
    local today = getToday()
    if not FraktionInviteCounts[pname] or FraktionInviteCounts[pname].tag ~= today then
        FraktionInviteCounts[pname] = {tag = today, count = 1}
    else
        FraktionInviteCounts[pname].count = FraktionInviteCounts[pname].count + 1
    end
end

-- Logging von Abuse-Versuchen
function fraktion_logAbuse(player, action, reason)
    local pname = type(player) == "string" and player or getPlayerName(player)
    outputDebugString("[Fraktion-ABUSE] "..pname.." bei Aktion "..action..": "..(reason or "Unbekannt"))
    -- Später: Discord-Webhook, Datenbank, etc.
end

-- === Discord-Logging (Webhook) ===

local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/DEIN_WEBHOOK_URL" -- TODO: In Settings auslagern

-- Utility: Discord-Webhook-Log
function fraktion_discordLog(title, description)
    -- Nur Beispiel: HTTP-Request an Discord senden (MTA:SA http-Funktion)
    local payload = toJSON({
        username = "Fraktion-Log",
        embeds = {{
            title = title,
            description = description,
            color = 3447003,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })
    fetchRemote(DISCORD_WEBHOOK_URL, function() end, payload, true, { ["Content-Type"] = "application/json" })
end

-- Beispielhafte Integration in zentrale Aktionen:

local _fraktion_addApplication = fraktion_addApplication
function fraktion_addApplication(fraktionId, player, text)
    local ok, msg = _fraktion_addApplication(fraktionId, player, text)
    if ok then
        fraktion_discordLog("Neue Fraktionsbewerbung", getPlayerName(player).." bewirbt sich bei "..Fraktionen[fraktionId].name)
    end
    return ok, msg
end

local _fraktion_deposit = fraktion_deposit
function fraktion_deposit(fraktionId, player, amount)
    local ok, msg = _fraktion_deposit(fraktionId, player, amount)
    if ok then
        fraktion_discordLog("Fraktionskasse Einzahlung", getPlayerName(player).." zahlt "..amount.."$ in "..Fraktionen[fraktionId].name.." ein.")
    end
    return ok, msg
end

local _fraktion_withdraw = fraktion_withdraw
function fraktion_withdraw(fraktionId, player, amount)
    local ok, msg = _fraktion_withdraw(fraktionId, player, amount)
    if ok then
        fraktion_discordLog("Fraktionskasse Auszahlung", getPlayerName(player).." hebt "..amount.."$ aus "..Fraktionen[fraktionId].name.." ab.")
    end
    return ok, msg
end

local _fraktion_postBoard = fraktion_postBoard
function fraktion_postBoard(fraktionId, player, text)
    local ok, msg = _fraktion_postBoard(fraktionId, player, text)
    if ok then
        fraktion_discordLog("Fraktions-Board", getPlayerName(player).." postet: "..text)
    end
    return ok, msg
end

local _fraktion_requestAlliance = fraktion_requestAlliance
function fraktion_requestAlliance(fraktionId, targetId, player)
    local ok, msg = _fraktion_requestAlliance(fraktionId, targetId, player)
    if ok then
        fraktion_discordLog("Bündnis-Anfrage", Fraktionen[fraktionId].name.." fragt Bündnis mit "..Fraktionen[targetId].name.." an.")
    end
    return ok, msg
end

local _fraktion_acceptAlliance = fraktion_acceptAlliance
function fraktion_acceptAlliance(fraktionId, targetId, player)
    local ok, msg = _fraktion_acceptAlliance(fraktionId, targetId, player)
    if ok then
        fraktion_discordLog("Bündnis angenommen", Fraktionen[fraktionId].name.." und "..Fraktionen[targetId].name.." sind jetzt verbündet.")
    end
    return ok, msg
end

-- Platzhalter für spätere Module:
--  * Bewerbungen (bewerbungen)
--  * Kassenlog (kassenLog)
--  * Board (board)
--  * Events (events)
--  * Blacklist (blacklist)

-- === Fraktions-GUI: Server-API & Events ===

-- Bewerbungen abrufen (für GUI)
addEvent("fraktion:requestApplications", true)
addEventHandler("fraktion:requestApplications", root, function(fraktionId)
    local apps = fraktion_getApplications(fraktionId)
    triggerClientEvent(client, "fraktion:receiveApplications", resourceRoot, apps)
end)

-- Mitgliederliste abrufen (für GUI)
addEvent("fraktion:requestMembers", true)
addEventHandler("fraktion:requestMembers", root, function(fraktionId)
    if not Fraktionen[fraktionId] then return end
    triggerClientEvent(client, "fraktion:receiveMembers", resourceRoot, Fraktionen[fraktionId].members)
end)

-- Kassenlog abrufen (für GUI)
addEvent("fraktion:requestKassenLog", true)
addEventHandler("fraktion:requestKassenLog", root, function(fraktionId, limit)
    local log = fraktion_getKassenLog(fraktionId, limit)
    triggerClientEvent(client, "fraktion:receiveKassenLog", resourceRoot, log)
end)

-- Mitglied einladen (GUI-Button)
addEvent("fraktion:inviteMember", true)
addEventHandler("fraktion:inviteMember", root, function(fraktionId, targetName)
    local can, msg = fraktion_canInvite(client)
    if not can then
        fraktion_logAbuse(client, "invite", msg)
        triggerClientEvent(client, "fraktion:inviteResult", resourceRoot, false, msg)
        return
    end
    local ok, err = fraktion_addApplication(fraktionId, targetName, "[Einladung]")
    if ok then
        fraktion_registerInvite(client)
        triggerClientEvent(client, "fraktion:inviteResult", resourceRoot, true)
    else
        triggerClientEvent(client, "fraktion:inviteResult", resourceRoot, false, err)
    end
end)

-- Mitglied befördern (GUI-Button)
addEvent("fraktion:promoteMember", true)
addEventHandler("fraktion:promoteMember", root, function(fraktionId, targetName)
    local ok, err = fraktion_promoteMember(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:promoteResult", resourceRoot, ok, err)
end)

-- Mitglied kicken (GUI-Button)
addEvent("fraktion:kickMember", true)
addEventHandler("fraktion:kickMember", root, function(fraktionId, targetName)
    local ok, err = fraktion_kickMember(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:kickResult", resourceRoot, ok, err)
end)

-- Bewerbung annehmen (GUI-Button)
addEvent("fraktion:acceptApplication", true)
addEventHandler("fraktion:acceptApplication", root, function(fraktionId, targetName)
    local ok, err = fraktion_acceptApplication(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:acceptApplicationResult", resourceRoot, ok, err)
end)

-- Bewerbung ablehnen (GUI-Button)
addEvent("fraktion:rejectApplication", true)
addEventHandler("fraktion:rejectApplication", root, function(fraktionId, targetName)
    local ok, err = fraktion_rejectApplication(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:rejectApplicationResult", resourceRoot, ok, err)
end)

-- Auszahlung aus der Fraktionskasse (GUI-Button)
addEvent("fraktion:withdraw", true)
addEventHandler("fraktion:withdraw", root, function(fraktionId, amount)
    local ok, err = fraktion_withdraw(fraktionId, client, amount)
    triggerClientEvent(client, "fraktion:withdrawResult", resourceRoot, ok, err)
end)

-- Beförderung (GUI-Button, alternative zu promoteMember)
addEvent("fraktion:promoteMemberGui", true)
addEventHandler("fraktion:promoteMemberGui", root, function(fraktionId, targetName)
    local ok, err = fraktion_promoteMember(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:promoteMemberGuiResult", resourceRoot, ok, err)
end)

-- Degradierung (GUI-Button)
addEvent("fraktion:demoteMember", true)
addEventHandler("fraktion:demoteMember", root, function(fraktionId, targetName)
    local ok, err = fraktion_demoteMember(fraktionId, client, targetName)
    triggerClientEvent(client, "fraktion:demoteMemberResult", resourceRoot, ok, err)
end)

-- === Fraktions-Board ===

-- Board-Nachricht posten
function fraktion_postBoard(fraktionId, player, text)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local pname = type(player) == "string" and player or getPlayerName(player)
    if not hasFraktionRight(fraktionId, player, "event") then
        return false, "Keine Berechtigung."
    end
    local msg = {
        author = pname,
        text = text,
        zeit = getRealTime().timestamp or os.time(),
    }
    table.insert(Fraktionen[fraktionId].board, msg)
    outputDebugString("[Fraktion-Board] "..pname.." postet: "..text)
    return true
end

-- Board abrufen
function fraktion_getBoard(fraktionId, limit)
    if not Fraktionen[fraktionId] then return {} end
    local board = Fraktionen[fraktionId].board
    if not limit or #board <= limit then return board end
    local res = {}
    for i = #board-limit+1, #board do
        table.insert(res, board[i])
    end
    return res
end

-- Board-Nachricht löschen (nur mit Recht)
function fraktion_deleteBoardMsg(fraktionId, player, idx)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    if not hasFraktionRight(fraktionId, player, "event") then
        return false, "Keine Berechtigung."
    end
    if not Fraktionen[fraktionId].board[idx] then return false, "Nachricht existiert nicht." end
    table.remove(Fraktionen[fraktionId].board, idx)
    outputDebugString("[Fraktion-Board] Nachricht #"..idx.." wurde gelöscht.")
    return true
end

-- Board abrufen (GUI)
addEvent("fraktion:requestBoard", true)
addEventHandler("fraktion:requestBoard", root, function(fraktionId, limit)
    local board = fraktion_getBoard(fraktionId, limit)
    triggerClientEvent(client, "fraktion:receiveBoard", resourceRoot, board)
end)

-- Board-Nachricht posten (GUI)
addEvent("fraktion:postBoard", true)
addEventHandler("fraktion:postBoard", root, function(fraktionId, text)
    local ok, err = fraktion_postBoard(fraktionId, client, text)
    triggerClientEvent(client, "fraktion:postBoardResult", resourceRoot, ok, err)
end)

-- Board-Nachricht löschen (GUI)
addEvent("fraktion:deleteBoardMsg", true)
addEventHandler("fraktion:deleteBoardMsg", root, function(fraktionId, idx)
    local ok, err = fraktion_deleteBoardMsg(fraktionId, client, idx)
    triggerClientEvent(client, "fraktion:deleteBoardMsgResult", resourceRoot, ok, err)
end)

-- === Interne Fraktionsnachrichten ===

-- Nachrichtenstruktur: Fraktionen[fraktionId].messages = { {from=, to=, text=, zeit=} }

-- Nachricht senden
function fraktion_sendMessage(fraktionId, fromPlayer, toPlayer, text)
    if not Fraktionen[fraktionId] then return false, "Fraktion existiert nicht" end
    local fromName = type(fromPlayer) == "string" and fromPlayer or getPlayerName(fromPlayer)
    local toName = type(toPlayer) == "string" and toPlayer or getPlayerName(toPlayer)
    if not Fraktionen[fraktionId].members[fromName] or not Fraktionen[fraktionId].members[toName] then
        return false, "Beide Spieler müssen Mitglied sein."
    end
    if not Fraktionen[fraktionId].messages then Fraktionen[fraktionId].messages = {} end
    local msg = {
        from = fromName,
        to = toName,
        text = text,
        zeit = getRealTime().timestamp or os.time(),
    }
    table.insert(Fraktionen[fraktionId].messages, msg)
    outputDebugString("[Fraktion-Message] "..fromName.." -> "..toName.." (Fraktion: "..Fraktionen[fraktionId].name..")")
    return true
end

-- Nachrichten abrufen (optional: nur für einen Empfänger)
function fraktion_getMessages(fraktionId, player)
    if not Fraktionen[fraktionId] or not Fraktionen[fraktionId].messages then return {} end
    local pname = type(player) == "string" and player or getPlayerName(player)
    local res = {}
    for _, msg in ipairs(Fraktionen[fraktionId].messages) do
        if msg.to == pname or msg.from == pname then
            table.insert(res, msg)
        end
    end
    return res
end

-- Nachricht senden (GUI)
addEvent("fraktion:sendMessage", true)
addEventHandler("fraktion:sendMessage", root, function(fraktionId, toName, text)
    local ok, err = fraktion_sendMessage(fraktionId, client, toName, text)
    triggerClientEvent(client, "fraktion:sendMessageResult", resourceRoot, ok, err)
end)

-- Nachrichten abrufen (GUI)
addEvent("fraktion:requestMessages", true)
addEventHandler("fraktion:requestMessages", root, function(fraktionId)
    local msgs = fraktion_getMessages(fraktionId, client)
    triggerClientEvent(client, "fraktion:receiveMessages", resourceRoot, msgs)
end)

-- === Fraktions-Bündnisse (Allianzen) ===

-- Datenstruktur: Fraktionen[fraktionId].alliances = { [andereFraktionId] = {status="active"/"pending", requestedBy=, seit=timestamp} }

-- Bündnis anfragen
function fraktion_requestAlliance(fraktionId, targetId, player)
    if not Fraktionen[fraktionId] or not Fraktionen[targetId] then return false, "Fraktion existiert nicht" end
    if not hasFraktionRight(fraktionId, player, "event") then return false, "Keine Berechtigung." end
    if not Fraktionen[fraktionId].alliances then Fraktionen[fraktionId].alliances = {} end
    if Fraktionen[fraktionId].alliances[targetId] then return false, "Bündnis existiert bereits oder ist ausstehend." end
    Fraktionen[fraktionId].alliances[targetId] = {status="pending", requestedBy=getPlayerName(player), seit=getRealTime().timestamp or os.time()}
    outputDebugString("[Fraktion-Buendnis] "..Fraktionen[fraktionId].name.." fragt Bündnis mit "..Fraktionen[targetId].name.." an.")
    return true
end

-- Bündnis annehmen
function fraktion_acceptAlliance(fraktionId, targetId, player)
    if not Fraktionen[fraktionId] or not Fraktionen[targetId] then return false, "Fraktion existiert nicht" end
    if not hasFraktionRight(fraktionId, player, "event") then return false, "Keine Berechtigung." end
    if not Fraktionen[fraktionId].alliances or not Fraktionen[fraktionId].alliances[targetId] or Fraktionen[fraktionId].alliances[targetId].status ~= "pending" then
        return false, "Keine ausstehende Anfrage."
    end
    Fraktionen[fraktionId].alliances[targetId].status = "active"
    Fraktionen[targetId].alliances = Fraktionen[targetId].alliances or {}
    Fraktionen[targetId].alliances[fraktionId] = {status="active", requestedBy=Fraktionen[fraktionId].alliances[targetId].requestedBy, seit=getRealTime().timestamp or os.time()}
    outputDebugString("[Fraktion-Buendnis] "..Fraktionen[fraktionId].name.." und "..Fraktionen[targetId].name.." sind jetzt verbündet.")
    return true
end

-- Bündnis beenden
function fraktion_endAlliance(fraktionId, targetId, player)
    if not Fraktionen[fraktionId] or not Fraktionen[targetId] then return false, "Fraktion existiert nicht" end
    if not hasFraktionRight(fraktionId, player, "event") then return false, "Keine Berechtigung." end
    if not Fraktionen[fraktionId].alliances or not Fraktionen[fraktionId].alliances[targetId] then
        return false, "Kein Bündnis vorhanden."
    end
    Fraktionen[fraktionId].alliances[targetId] = nil
    if Fraktionen[targetId].alliances then Fraktionen[targetId].alliances[fraktionId] = nil end
    outputDebugString("[Fraktion-Buendnis] Bündnis zwischen "..Fraktionen[fraktionId].name.." und "..Fraktionen[targetId].name.." wurde beendet.")
    return true
end

-- Bündnisse abrufen
function fraktion_getAlliances(fraktionId)
    if not Fraktionen[fraktionId] or not Fraktionen[fraktionId].alliances then return {} end
    return Fraktionen[fraktionId].alliances
end

-- Events für die GUI
addEvent("fraktion:requestAlliance", true)
addEventHandler("fraktion:requestAlliance", root, function(fraktionId, targetId)
    local ok, err = fraktion_requestAlliance(fraktionId, targetId, client)
    triggerClientEvent(client, "fraktion:requestAllianceResult", resourceRoot, ok, err)
end)

addEvent("fraktion:acceptAlliance", true)
addEventHandler("fraktion:acceptAlliance", root, function(fraktionId, targetId)
    local ok, err = fraktion_acceptAlliance(fraktionId, targetId, client)
    triggerClientEvent(client, "fraktion:acceptAllianceResult", resourceRoot, ok, err)
end)

addEvent("fraktion:endAlliance", true)
addEventHandler("fraktion:endAlliance", root, function(fraktionId, targetId)
    local ok, err = fraktion_endAlliance(fraktionId, targetId, client)
    triggerClientEvent(client, "fraktion:endAllianceResult", resourceRoot, ok, err)
end)

addEvent("fraktion:requestAlliances", true)
addEventHandler("fraktion:requestAlliances", root, function(fraktionId)
    local alliances = fraktion_getAlliances(fraktionId)
    triggerClientEvent(client, "fraktion:receiveAlliances", resourceRoot, alliances)
end)

-- === Datenbank-Persistenz (MySQL) ===

-- Platzhalter: MySQL-Connection (ggf. anpassen)
local db = db or nil -- z.B. db = exports.mysql:getConnection()

-- Fraktionsdaten speichern (vereinfachtes Beispiel)
function fraktion_saveAll()
    -- TODO: Hier alle Fraktionsdaten serialisieren und in die DB schreiben
    -- Beispiel: dbExec(db, "UPDATE fraktionen SET data=?", toJSON(Fraktionen))
    outputDebugString("[Fraktion-DB] Fraktionsdaten gespeichert.")
end

-- Fraktionsdaten laden (vereinfachtes Beispiel)
function fraktion_loadAll()
    -- TODO: Hier Fraktionsdaten aus der DB laden und Fraktionen-Tabelle befüllen
    -- Beispiel: dbQuery(db, "SELECT data FROM fraktionen LIMIT 1")
    outputDebugString("[Fraktion-DB] Fraktionsdaten geladen.")
end

-- Integration: Nach zentralen Änderungen speichern
local _fraktion_addApplication = fraktion_addApplication
function fraktion_addApplication(fraktionId, player, text)
    local ok, msg = _fraktion_addApplication(fraktionId, player, text)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

local _fraktion_deposit = fraktion_deposit
function fraktion_deposit(fraktionId, player, amount)
    local ok, msg = _fraktion_deposit(fraktionId, player, amount)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

local _fraktion_withdraw = fraktion_withdraw
function fraktion_withdraw(fraktionId, player, amount)
    local ok, msg = _fraktion_withdraw(fraktionId, player, amount)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

local _fraktion_postBoard = fraktion_postBoard
function fraktion_postBoard(fraktionId, player, text)
    local ok, msg = _fraktion_postBoard(fraktionId, player, text)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

local _fraktion_requestAlliance = fraktion_requestAlliance
function fraktion_requestAlliance(fraktionId, targetId, player)
    local ok, msg = _fraktion_requestAlliance(fraktionId, targetId, player)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

local _fraktion_acceptAlliance = fraktion_acceptAlliance
function fraktion_acceptAlliance(fraktionId, targetId, player)
    local ok, msg = _fraktion_acceptAlliance(fraktionId, targetId, player)
    if ok then
        fraktion_saveAll()
    end
    return ok, msg
end

return Fraktionen, hasFraktionRight 