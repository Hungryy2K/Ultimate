-- local Logger = require("utility.Logger") entfernt, Logger muss global sein
local adminLogger = Logger:new("Admin")
local securityLogger = Logger:new("Security")

factionColours = {}
factionRankNames = {}
	local i = 0
	
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 50, 50, 255
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Cadet"
		factionRankNames[i][1] = "Officer"
		factionRankNames[i][2] = "Sergeant"
		factionRankNames[i][3] = "Lieutenant"
		factionRankNames[i][4] = "Captain"
		factionRankNames[i][5] = "Chief of Police"
	
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 150, 0, 150
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Picciotto"
		factionRankNames[i][1] = "Button Man"
		factionRankNames[i][2] = "Capodecina"
		factionRankNames[i][3] = "Capo"
		factionRankNames[i][4] = "Consiglieri"
		factionRankNames[i][5] = "Don"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 100, 0, 0
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Tin"
		factionRankNames[i][1] = "Heung Chu"
		factionRankNames[i][2] = "Heung Kwan"
		factionRankNames[i][3] = "Sin Fung"
		factionRankNames[i][4] = "Fu Shan Chu"
		factionRankNames[i][5] = "Shan Chu"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 100, 0, 0
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Sympathisant"
		factionRankNames[i][1] = "Genosse"
		factionRankNames[i][2] = "Bombenleger"
		factionRankNames[i][3] = "Freiheitskaempfer"
		factionRankNames[i][4] = "Kommandant"
		factionRankNames[i][5] = "Revolutionsfuehrer"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 125, 50, 200
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Zeitungsjunge"
		factionRankNames[i][1] = "Klatschtante"
		factionRankNames[i][2] = "Zeitungsreporter"
		factionRankNames[i][3] = "Reporter"
		factionRankNames[i][4] = "Journalist"
		factionRankNames[i][5] = "Chefredakteur"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 50, 50, 255
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Trainee"
		factionRankNames[i][1] = "Agent"
		factionRankNames[i][2] = "Special Agent Trainee"
		factionRankNames[i][3] = "Special Agent"
		factionRankNames[i][4] = "Assistant Director"
		factionRankNames[i][5] = "Director"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 125, 125, 0
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Novato"
		factionRankNames[i][1] = "Principiante"
		factionRankNames[i][2] = "Socia"
		factionRankNames[i][3] = "Veterano"
		factionRankNames[i][4] = "Interino"
		factionRankNames[i][5] = "Jefa"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 0, 125, 0
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Private"
		factionRankNames[i][1] = "Corporal"
		factionRankNames[i][2] = "Staff Sergeant"
		factionRankNames[i][3] = "Major"
		factionRankNames[i][4] = "Colonel"
		factionRankNames[i][5] = "General"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 100, 50, 100
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Associate"
		factionRankNames[i][1] = "Member"
		factionRankNames[i][2] = "Sergeant at Arms"
		factionRankNames[i][3] = "Road Captain"
		factionRankNames[i][4] = "Vice-President"
		factionRankNames[i][5] = "President"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 255, 51, 51
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Krankenpfleger"
		factionRankNames[i][1] = "Assistenzarzt"
		factionRankNames[i][2] = "Arzt"
		factionRankNames[i][3] = "Oberarzt"
		factionRankNames[i][4] = "ltd. Oberarzt"
		factionRankNames[i][5] = "Chefarzt"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 204, 204, 0
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Praktikant"
		factionRankNames[i][1] = "Azubi"
		factionRankNames[i][2] = "Geselle"
		factionRankNames[i][3] = "Mechatroniker"
		factionRankNames[i][4] = "Meister"
		factionRankNames[i][5] = "Chef"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 138,43,226
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Anhänger"
		factionRankNames[i][1] = "Dealer"
		factionRankNames[i][2] = "Bro"
		factionRankNames[i][3] = "Hustler"
		factionRankNames[i][4] = "Thug"
		factionRankNames[i][5] = "Banger"
	i = i + 1
	factionColours[i] = {}
		factionColours[i][1], factionColours[i][2], factionColours[i][3] = 85, 107, 47
	factionRankNames[i] = {}
		factionRankNames[i][0] = "Anhänger"
		factionRankNames[i][1] = "Dealer"
		factionRankNames[i][2] = "Bro"
		factionRankNames[i][3] = "Rider"
		factionRankNames[i][4] = "BigSmoke"
		factionRankNames[i][5] = "Sweet"

local teamchatCooldown = {}
local gteamchatCooldown = {}
local bteamchatCooldown = {}

function teamchat_func ( player, cmd, ... )
    if teamchatCooldown[player] and getTickCount() - teamchatCooldown[player] < 2000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut im Fraktionschat schreibst.", true)
        return
    end
    teamchatCooldown[player] = getTickCount()
    local parametersTable = {...}
    local text = table.concat( parametersTable, " " )
    local Fraktion = vioGetElementData ( player, "fraktion" )
    local FRank = vioGetElementData ( player, "rang" )
    if not Fraktion or Fraktion < 1 then
        outputNeutralInfo(player, "Du bist in keiner Fraktion!", true)
        securityLogger:error("[TEAMCHAT] Versuch ohne Fraktion: "..getPlayerName(player))
        return
    end
    if not text or text == "" then
        outputNeutralInfo(player, "Bitte einen Text eingeben!", true)
        return
    end
    local red, green, blue = 0, 0, 0
    local title = "intern"
    if factionRankNames[Fraktion][FRank] then
        title = factionRankNames[Fraktion][FRank]
        red, green, blue = factionColours[Fraktion][1], factionColours[Fraktion][2], factionColours[Fraktion][3]
    end
    for playeritem, index in pairs(fraktionMembers[Fraktion]) do 
        if isElement ( playeritem ) then
            outputChatBox ( "[ "..title.." "..getPlayerName(player)..": "..text.." ]", playeritem, red, green, blue )
        else
            fraktionMembers[Fraktion][playeritem] = nil
        end
    end
    adminLogger:info("[TEAMCHAT] "..getPlayerName(player)..": "..text)
end
addCommandHandler ( "t", teamchat_func )
addCommandHandler ( "teamsay", teamchat_func )


function gteamchat_func ( player, cmd, ... )
    if gteamchatCooldown[player] and getTickCount() - gteamchatCooldown[player] < 2000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut im Gruppenchat schreibst.", true)
        return
    end
    gteamchatCooldown[player] = getTickCount()
    local parametersTable = {...}
    local text = table.concat( parametersTable, " " )
    local Fraktion = tonumber(vioGetElementData ( player, "fraktion" ))
    local FRank = tonumber(vioGetElementData ( player, "rang" ))
    if not (Fraktion == 1 or Fraktion == 6 or Fraktion == 8 or Fraktion == 10 or Fraktion == 11) then
        outputNeutralInfo(player, "Du bist in keiner gültigen Fraktion für diesen Chat!", true)
        securityLogger:error("[GTEAMCHAT] Versuch ohne gültige Fraktion: "..getPlayerName(player))
        return
    end
    if not text or text == "" then
        outputNeutralInfo(player, "Bitte einen Text eingeben!", true)
        return
    end
    local red, green, blue = 140, 10, 10
    local title = "intern"
    if factionRankNames[Fraktion][FRank] then
        title = factionRankNames[Fraktion][FRank]
    end
    for _, fid in ipairs({1,6,8,10,11}) do
        for playeritem, key in pairs(fraktionMembers[fid]) do
            if isElement(playeritem) then
                outputChatBox ( "[ "..title.." "..getPlayerName(player)..": "..text.." ]", playeritem, red, green, blue )
            else
                fraktionMembers[fid][playeritem] = nil
            end
        end
    end
    adminLogger:info("[GTEAMCHAT] "..getPlayerName(player)..": "..text)
end
addCommandHandler ("g", gteamchat_func )




function bteamchat_func ( player, cmd, ... )
    if bteamchatCooldown[player] and getTickCount() - bteamchatCooldown[player] < 2000 then
        outputNeutralInfo(player, "Bitte warte kurz, bevor du erneut im Bündnischat schreibst.", true)
        return
    end
    bteamchatCooldown[player] = getTickCount()
    local FRank = tonumber(vioGetElementData ( player, "rang" ))
    if FRank < 4 then
        outputNeutralInfo(player, "Erst ab Rang 4!", true)
        securityLogger:error("[BTEAMCHAT] Versuch ohne Rang: "..getPlayerName(player))
        return
    end
    local parametersTable = {...}
    local text = table.concat( parametersTable, " " )
    local Fraktion = tonumber(vioGetElementData ( player, "fraktion" ))
    if not (Fraktion == 2 or Fraktion == 3 or Fraktion == 4 or Fraktion == 7 or Fraktion == 9 or Fraktion == 12 or Fraktion == 13) then
        outputNeutralInfo(player, "Du bist in keiner gültigen Fraktion für diesen Chat!", true)
        securityLogger:error("[BTEAMCHAT] Versuch ohne gültige Fraktion: "..getPlayerName(player))
        return
    end
    if not text or text == "" then
        outputNeutralInfo(player, "Bitte einen Text eingeben!", true)
        return
    end
    local red, green, blue = 107, 107, 107
    local title = "intern"
    if factionRankNames[Fraktion][FRank] then
        title = factionRankNames[Fraktion][FRank]
    end
    for _, fid in ipairs({2,3,4,7,9,12,13}) do
        for playeritem, key in pairs(fraktionMembers[fid]) do
            if isElement(playeritem) then
                outputChatBox ( "[ "..title.." "..getPlayerName(player)..": "..text.." ]", playeritem, red, green, blue )
            else
                fraktionMembers[fid][playeritem] = nil
            end
        end
    end
    adminLogger:info("[BTEAMCHAT] "..getPlayerName(player)..": "..text)
end
addCommandHandler ("b", bteamchat_func )