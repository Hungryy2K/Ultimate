-- Zentrale Settings-Datei für Discord Webhooks
-- Hier alle Webhook-URLs und Einstellungen eintragen

DiscordWebhooks = {
    adminlog = "https://discord.com/api/webhooks/ADMINLOG_PLACEHOLDER", -- Admin-Aktionen
    warnlog = "https://discord.com/api/webhooks/WARNLOG_PLACEHOLDER", -- Verwarnungen
    mutelog = "https://discord.com/api/webhooks/MUTELOG_PLACEHOLDER", -- Mutes
    ganglog = "https://discord.com/api/webhooks/GANGLOG_PLACEHOLDER", -- Gang-/Blacklist-/Gangwar-Aktionen
    houselog = "https://discord.com/api/webhooks/HOUSELOG_PLACEHOLDER", -- Haus-Transaktionen
    vehiclelog = "https://discord.com/api/webhooks/VEHICLELOG_PLACEHOLDER", -- Fahrzeug-Transaktionen
    supportlog = "https://discord.com/api/webhooks/SUPPORTLOG_PLACEHOLDER", -- Support-/Ticketsystem
    eventlog = "https://discord.com/api/webhooks/EVENTLOG_PLACEHOLDER", -- Server-Events, Minigames
    economylog = "https://discord.com/api/webhooks/ECONOMYLOG_PLACEHOLDER", -- Wirtschafts-/Ökonomie-Logs
    banklog = "https://discord.com/api/webhooks/BANKLOG_PLACEHOLDER", -- Bank- und Geldtransaktionen
    ticketlog = "https://discord.com/api/webhooks/TICKETLOG_PLACEHOLDER", -- Ticketsystem
    shoplog = "https://discord.com/api/webhooks/SHOPLOG_PLACEHOLDER", -- Shop-Käufe/-Verkäufe
    casinolog = "https://discord.com/api/webhooks/CASINOLOG_PLACEHOLDER", -- Casino-/Lotto-Logs
    anticheatlog = "https://discord.com/api/webhooks/ANTICHEATLOG_PLACEHOLDER", -- Anticheat-/Security-Events
    factionlog = "https://discord.com/api/webhooks/FACTIONLOG_PLACEHOLDER", -- Fraktions-Aktionen
    errorlog = "https://discord.com/api/webhooks/ERRORLOG_PLACEHOLDER", -- Fehler/Crashes
    joinlog = "https://discord.com/api/webhooks/JOINLOG_PLACEHOLDER", -- Spieler-Joins
    leavelog = "https://discord.com/api/webhooks/LEAVELOG_PLACEHOLDER", -- Spieler-Leaves
    damage = "https://discord.com/api/webhooks/DAMAGELOG_PLACEHOLDER", -- Spieler-Schaden-Logs
    cardamage = "https://discord.com/api/webhooks/CARDAMAGELOG_PLACEHOLDER", -- Fahrzeug-Schaden-Logs
    -- weitere Webhooks nach Bedarf hinzufügen

    enabled = true, -- globales Ein-/Ausschalten aller Webhooks
    defaultUsername = "UltimateBot" -- Standardname für Webhook-Nachrichten
}

return DiscordWebhooks 