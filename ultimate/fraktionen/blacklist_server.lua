-- local Logger = require("utility.Logger") entfernt, Logger muss global sein
local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")
local discordLogger = Logger:new("Discord")
local gangLogger = Logger:new("ganglog")

blacklistPlayers = {}
 blacklistPlayers[2] = {}
 blacklistPlayers[3] = {}
 blacklistPlayers[7] = {}
 blacklistPlayers[9] = {}
 blacklistPlayers[12] = {}
 blacklistPlayers[13] = {}
 
blacklistReason = {}
 blacklistReason[2] = {}
 blacklistReason[3] = {}
 blacklistReason[7] = {}
 blacklistReason[9] = {}
 blacklistReason[12] = {}
 blacklistReason[13] = {}

local playersAddetToBlacklist = {}
for i = 1, 13 do
	playersAddetToBlacklist[i] = {}
end

validBlackListFactions = {
 [2]=true,
 [3]=true,
 [7]=true,
 [9]=true,
 [12]=true,
 [13]=true
 }

factionBlackListGuns = {
 [2]=26,
 [3]=8,
 [7]=18,
 [9]=28,
 [12]=32,
 [13]=32
}

local blacklistAddCooldown = {}
local blacklistDeleteCooldown = {}
local blacklistShowCooldown = {}


function blacklistLogin ( pname )
	local player = getPlayerFromName(pname)
	local frac = vioGetElementData ( player, "fraktion" )
	local result = dbPoll ( dbQuery ( handler, "SELECT * FROM blacklist WHERE UID = ?", playerUID[pname] ), -1 )
	if result and result[1] then
		if frac == 0 then
			for i=1, #result do
				local fraktion = tonumber ( result[i]["Fraktion"] )
				blacklistPlayers[fraktion][pname] = true
				blacklistReason[fraktion][pname] = result[i]["Grund"]
				for playeritem, _ in pairs ( fraktionMembers[fraktion] ) do
					triggerClientEvent ( playeritem, "playerInBlacklistJoined", playeritem, pname )
				end
			end
		else
			dbExec ( handler, "DELETE FROM ?? WHERE ??=?", "blacklist", "UID", playerUID[pname] )
		end		
	end
	if validBlackListFactions[frac] then
		triggerClientEvent ( player, "triggeredBlacklist", player, blacklistPlayers[frac] )
	end
end


function blackListKillCheck ( player, killer, weapon )
	local killerFaction = vioGetElementData ( killer, "fraktion" )
	local name = getPlayerName ( player )
	if validBlackListFactions[killerFaction] then
		if blacklistPlayers[killerFaction][name] then
			local prizeMoney = 200
			local prizeText = "Du erhälst 200 $"
			if factionBlackListGuns[killerFaction] == weapon then
				prizeText = prizeText.." + 100 $ wegen der verwendeten Waffe."
				prizeMoney = prizeMoney + 100
			else
				prizeText = prizeText.."."
			end
			blacklistPlayers[killerFaction][name] = nil
			blacklistReason[killerFaction][name] = nil
			dbExec ( handler, "DELETE FROM ?? WHERE ??=? AND ??=?", "blacklist", "UID", playerUID[name], "Fraktion", killerFaction )
			for playeritem, _ in pairs ( fraktionMembers[killerFaction] ) do
				triggerClientEvent ( playeritem, "playerInBlacklistDied", playeritem, name )
			end
			givePlayerSaveMoney ( killer, prizeMoney )
			outputChatBox ( "Du wurdest von einem Fraktionsmitglied erledigt, weil du auf der Blacklist warst.", player, 200, 0, 0 )
			outputChatBox ( "Du hast jemanden von der Blacklist erledigt!", killer, 0, 200, 0 )
			outputChatBox ( prizeText, killer, 0, 200, 0 )
		end
	end
end


function blacklist_func ( player, cmd, add, target, ... )
    local fraktion = vioGetElementData ( player, "fraktion" )
    local rang = vioGetElementData ( player, "rang" ) or 0
    if not add then
        outputNeutralInfo(player, "Gebrauch: /blacklist [add/delete/show] [Name]", true)
        return
    end
    if not validBlackListFactions[fraktion] then
        outputNeutralInfo(player, "Du bist in einer ungültigen Fraktion!", true)
        securityLogger:error("[BLACKLIST] Ungültige Fraktion: "..getPlayerName(player))
        return
    end
    if add == "add" then
        if blacklistAddCooldown[player] and getTickCount() - blacklistAddCooldown[player] < 10000 then
            outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut jemanden auf die Blacklist setzt.", true)
            return
        end
        blacklistAddCooldown[player] = getTickCount()
        if rang < 2 then
            outputNeutralInfo(player, "Du bist nicht befugt!", true)
            securityLogger:error("[BLACKLIST] Unberechtigter Add-Versuch: "..getPlayerName(player))
            return
        end
        local parametersTable = {...}
        local text = table.concat(parametersTable, " ")
        if not target or not text or text == "" then
            outputNeutralInfo(player, "Gebrauch: /blacklist add Name Grund", true)
            return
        end
        addBlacklist_func(player, target, text)
        adminLogger:info(getPlayerName(player).." hat "..tostring(target).." zur Blacklist der Fraktion "..tostring(fraktionNames[fraktion]).." hinzugefügt. Grund: "..text)
        gangLogger:discord("BLACKLIST-ADD: "..getPlayerName(player).." hat "..target.." zur Blacklist der Fraktion "..tostring(fraktion).." hinzugefügt. Grund: "..text, getPlayerSerial(player), getPlayerIP(player))
    elseif add == "delete" then
        if blacklistDeleteCooldown[player] and getTickCount() - blacklistDeleteCooldown[player] < 10000 then
            outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut jemanden von der Blacklist entfernst.", true)
            return
        end
        blacklistDeleteCooldown[player] = getTickCount()
        if rang < 2 then
            outputNeutralInfo(player, "Du bist nicht befugt!", true)
            securityLogger:error("[BLACKLIST] Unberechtigter Delete-Versuch: "..getPlayerName(player))
            return
        end
        if not target then
            outputNeutralInfo(player, "Gebrauch: /blacklist delete Name", true)
            return
        end
        blacklistdelete_func(player, target)
        adminLogger:info(getPlayerName(player).." hat "..tostring(target).." aus der Blacklist der Fraktion "..tostring(fraktionNames[fraktion]).." entfernt.")
    elseif add == "show" then
        if blacklistShowCooldown[player] and getTickCount() - blacklistShowCooldown[player] < 5000 then
            outputNeutralInfo(player, "Bitte warte kurz, bevor du die Blacklist erneut anzeigst.", true)
            return
        end
        blacklistShowCooldown[player] = getTickCount()
        showblacklist_func(player)
    else
        outputNeutralInfo(player, "Gebrauch: /blacklist [add/delete/show] [Name]", true)
    end
end
addCommandHandler ( "blacklist", blacklist_func )


function blacklistdelete_func ( player, name )
	if name then
		local fraktion = vioGetElementData ( player, "fraktion" )
		if blacklistPlayers[fraktion][name] then
			blacklistPlayers[fraktion][name] = nil
			blacklistReason[fraktion][name] = nil
			dbExec ( handler, "DELETE FROM ?? WHERE ??=? AND ??=?", "blacklist", "UID", playerUID[name], "Fraktion", fraktion )
			sendMSGForFaction ( getPlayerName(player).." hat "..name.." aus der Blacklist gelöscht.", fraktion, 0, 125, 0 )
			local target = getPlayerFromName ( name )
			if isElement ( target ) then
				outputChatBox ( "Du wurdest aus die Blacklist der "..fraktionNames[fraktion].." entfernt.", target, 0, 200, 0 )
			end
			for playeritem, _ in pairs ( fraktionMembers[fraktion] ) do
				triggerClientEvent ( playeritem, "playerInBlacklistDied", playeritem, name )
			end
			adminLogger:info(getPlayerName(player).." hat "..name.." aus der Blacklist der Fraktion "..fraktionNames[fraktion].." entfernt.")
		else
			infobox ( player, "Der Spieler ist\nnicht auf\nder Blacklist!", 4000, 200, 0, 0 )
		end
	else
		infobox ( player, "Gebrauch:\nblacklist delete\n[Name]", 4000, 200, 0, 0 )
	end
end


function showblacklist_func ( player )
	local fraktion = vioGetElementData ( player, "fraktion" )
	if blacklistPlayers[fraktion] then
		outputChatBox ( "Spieler auf der Blacklist:", player, 200, 200, 0 )
		outputChatBox ( "__________________________", player, 200, 200, 0 )
		for key, index in pairs ( blacklistPlayers[fraktion] ) do
			if getPlayerFromName ( key ) then
				outputChatBox ( key ..": "..blacklistReason[fraktion][key], player, 200, 200, 0 )
				outputChatBox ( "__________________________", player, 200, 200, 0 )
			else
				blacklistPlayers[fraktion][key] = nil
				blacklistReason[fraktion][key] = nil
			end
		end
	else
		outputChatBox ( "Du bist in einer ungültigen Fraktion!", player, 125, 0, 0 )
	end
end


function addBlacklist_func ( player, member, text )
	if member and text then
		local pname = getPlayerName ( player )
		local target = getPlayerFromName ( member )
		if target then
			local fraktion = vioGetElementData ( player, "fraktion" )
			if vioGetElementData ( player, "rang" ) >= 2 then
				if blacklistPlayers[fraktion][member] then
					infobox ( player, "\n\nDer Spieler ist\nbereits auf\nder Blacklist!", 5000, 125, 0, 0 )
				else
					if vioGetElementData ( target, "fraktion" ) == 0 then
						if not playersAddetToBlacklist[fraktion][member] then
							playersAddetToBlacklist[fraktion][member] = true
							dbExec ( handler, "INSERT INTO ?? ( ??, ??, ??, ??, ?? ) VALUES (?,?,?,?,?)", "blacklist", "UID", "EintraegerUID", "Fraktion", "Grund", "Eintragungsdatum", playerUID[member], playerUID[pname], fraktion, text, getSecTime ( 0 ) )
							infobox ( player, "\nDu hast den\nSpieler auf die\nBlacklist gesetzt!", 5000, 125, 0, 0 )
							outputChatBox ( "Du wurdest auf die Blacklist der "..fraktionNames[fraktion].." gesetzt. Grund: "..text, target, 255, 0, 0 )
							blacklistPlayers[fraktion][member] = true
							blacklistReason[fraktion][member] = text
							for playeritem, _ in pairs ( fraktionMembers[fraktion] ) do
								triggerClientEvent ( playeritem, "playerInBlacklistJoined", playeritem, member )
							end
							adminLogger:info(getPlayerName(player).." hat "..member.." zur Blacklist der Fraktion "..fraktionNames[fraktion].." hinzugefügt. Grund: "..text)
						else
							infobox ( player, "\n\nDer Spieler war heute bereits auf der Blacklist deiner Fraktion!", 5000, 125, 0, 0 )
						end
					else
						infobox ( player, "\n\nDer Spieler ist\nkein Zivilist!", 5000, 125, 0, 0 )
					end
				end
			else
				infobox ( player, "\n\nDu bist nicht\nbefugt!", 5000, 125, 0, 0 )
			end
		else
			infobox ( player, "\n\nDer Spieler ist\nnicht online!", 5000, 125, 0, 0 )
		end
	else
		infobox ( player, "Gebrauch:\n/blacklist add\n[Name] [Grund!", 5000, 125, 0, 0 )
	end
end


function getBlacklistGrund ( pname, fraktion )
	local result = dbPoll ( dbQuery ( handler, "SELECT ?? FROM ?? WHERE ??=? AND ??=?", "Grund", "blacklist", "UID", playerUID[pname], "Fraktion", fraktion ), -1 )
	if result and result[1] then
		return result[1]["Grund"]
	end
	return false
end