# Ultimate

## Inhaltsverzeichnis
1. [Installation & Start](#installation--start)
2. [Befehle & Kommandos](#befehle--kommandos)
3. [Changelog](#4-changelog)
4. [Screenshots](#5-screenshots)
5. [Mitmachen & Support](#6-mitmachen--support)
6. [Credits & Hinweise](#7-credits--hinweise)

## Installation & Start
1. Voraussetzungen:
   - MTA:SA Server (empfohlen: aktuelle Version)
   - MySQL-Datenbank (MTA dbConnect wird genutzt, kein externes MySQL-Modul nötig)
2. Datenbank:
   - Importiere die Datei `Datenbank.sql` in deine Datenbank.
3. Ressourcen:
   - Lege das Verzeichnis `ultimate` als Ressource im MTA-Server an.
   - Stelle sicher, dass alle Unterordner und Dateien vorhanden sind.
4. Discord-Webhooks:
   - Trage deine Webhook-URLs in die Datei `ultimate/settings/discord_webhooks.lua` ein, damit Discord-Logs korrekt funktionieren.
5. Start:
   - Starte den Server und lade die Ressource `ultimate`.
   - Weitere optionale Ressourcen (z.B. `realdriveby`) können geladen werden.

- Hinweis: Discord Webhooks funktionieren nur auf dem Server (fetchRemote benötigt Internetzugang und funktioniert nicht im lokalen MTA-Client/Entwicklungsmodus).

## 3. Sicherheit & Logging
- Zentrales Logger-Modul:
  - Einheitliche Logger-Instanzen für Admin, Security, Discord etc. in allen Modulen
  - Alle Logging-Aufrufe (logAdminAction, logSecurity, sendDiscordAlert, outputDebugString) wurden auf das neue System umgestellt
  - Vorteile: Wartbarkeit, klare Log-Kanäle, einfache Erweiterbarkeit (z.B. Discord, Datei, Datenbank)
  - Das Logger-Modul ist die zentrale Schnittstelle für alle Logs im Projekt
  - **Discord-Webhook:** Trage deine Discord-Webhook-URL in der Datei `ultimate/usefull/logging.lua` oder direkt im Logger-Modul (`ultimate/utility/Logger.lua`) ein, um Security- und Admin-Logs an Discord zu senden.
- Security-Features:
  - Rechteprüfung, Input-Validierung, Cooldown/Rate-Limiting, Exploit-Logging, Discord-Webhook, Prepared Statements, neutrales User-Feedback, Performance-Optimierungen

## 4. Changelog

### 24.07.2025: Fraktionssystem – Modularisierung, Security & Features
- Neu: Zentrale Settings-Datei `ultimate/settings/discord_webhooks.lua` für alle Discord Webhook-URLs und Einstellungen. Webhooks müssen nicht mehr einzeln in jedem Script eingetragen werden, sondern können zentral gepflegt und importiert werden.
- Logger-Modul nutzt jetzt die zentrale Datei `ultimate/settings/discord_webhooks.lua` für Discord-Webhook-URLs und Einstellungen. Die Webhook-URL wird automatisch anhand des Log-Channels gewählt.
- NEU: Discord-Webhook-Leave-Log (leavelogs) hinzugefügt. Wenn ein Spieler den Server verlässt, wird dies nun per Discord-Webhook gemeldet.
- NEU: Damage-Logger (damage) für Spielerschaden inkl. Waffe, Serial, IP
- NEU: Car-Damage-Logger (cardamage) für Fahrzeugschaden inkl. Waffe, Serial, IP
- Alle Discord-Logger loggen jetzt immer Serial und IP
- Webhook-Settings um alle Logger ergänzt und sortiert
- Diverse Security- und Logging-Verbesserungen
- Komplettes Fraktionssystem modular und sicher neu aufgebaut:
  - Zentrale Datenstruktur für Mitglieder, Rechte, Bewerbungen, Kasse, Board, Nachrichten, Bündnisse
  - Flexible Rechteverwaltung für alle Aktionen (Einladen, Kasse, Board, Bündnisse, etc.)
  - Bewerbungs-System: Bewerben, Annehmen/Ablehnen, Logging, API-Events
  - Mitgliederverwaltung: Kick, Beförderung, Degradierung, Logging, API-Events
  - Fraktionskasse & Kassenlog: Ein-/Auszahlungen, Log, Rechteprüfung, API-Events
  - Anti-Abuse: Cooldown, Invite-Limit, Abuse-Logging
  - Fraktions-Board: Nachrichten posten, abrufen, löschen, Logging, API-Events
  - Interne Fraktionsnachrichten: Private Nachrichten, Logging, API-Events
  - Bündnisse/Allianzen: Anfragen, Annehmen, Beenden, Logging, API-Events
  - Discord-Logging: Wichtige Aktionen werden an einen Discord-Webhook gemeldet
  - Datenbank-Persistenz: Platzhalter für Speichern/Laden aller Fraktionsdaten in MySQL, Integration in alle Kernaktionen
  - Serverseitige API/Events für vollständige GUI-Anbindung
- Alle Änderungen dokumentiert, Logging und Security weiter vereinheitlicht

### 23.07.2025: Security, Refactoring & Logger-Update
- **Banksystem: Neue Anti-Abuse- und Admin-Tools:**
  - IP/Serial-Check: Blockiert Überweisungen zwischen Accounts mit gleicher IP oder Serial, loggt und sendet Discord-Alert
  - Bank-Blacklist: Admins können Bankkonten per `/bankban [Name]` sperren und per `/bankunban [Name]` wieder freigeben
  - Alle Bankfunktionen prüfen, ob ein Konto gesperrt ist, bevor eine Transaktion durchgeführt wird
  - Discord-Alerts und Security-Logging bei Missbrauchsversuchen
  - Alle sicherheitsrelevanten Aktionen werden ins zentrale Logging geschrieben
- Einführung eines zentralen Logger-Moduls (OOP/Utility-Stil) für das gesamte Projekt
- Systematische Absicherung aller kritischen Admin- und Fraktions-Kommandos
- Exploit-Logging, Discord-Webhook-Integration, Prepared Statements, Performance-Optimierungen
- Alle Änderungen modular, nachvollziehbar und systematisch dokumentiert

## 5. Screenshots


## 6. Mitmachen & Support
- Pull Requests und Bugreports sind willkommen!
- Für Fragen, Support oder Feature-Wünsche nutze bitte GitHub Issues oder Discord.
- Lies den Quellcode, kommentiere und verbessere – jede Hilfe ist willkommen!

## 7. Credits & Hinweise
- Ursprüngliche Entwicklung: Ultimate-RL Team, basierend auf Vio-Extended
- Originalentwickler: [emre1702](https://github.com/emre1702)
- Viele Community-Features und Bugfixes
- Das Script ist Open Source und kann beliebig weiterentwickelt werden

---

## Befehle & Kommandos

### Allgemeine Spieler-Befehle

Die wichtigsten Kommandos für alle Spieler, sortiert nach Kategorie. Nutze `/commands [Kategorie]` im Spiel für eine Übersicht.

| Kategorie   | Befehl & Beschreibung |
|-------------|----------------------|
| **Account** | /newpw [neuesPW] [neuesPW] – Ändert das Passwort  <br> /auto [0/1] – Speichert Passwort für nächsten Login  <br> /self – Zeigt das Selfmenü  <br> /shader – Öffnet das Shader-Fenster  <br> /save – Speichert Position & Waffen und geht Offline |
| **Fahrzeug** | /race [Name] – Fordert jemanden zum Rennen heraus  <br> /eject [Name/all] – Schmeißt jemanden/alle aus dem Auto  <br> /userc – Benutzt ein RC-Fahrzeug  <br> /limit [Anzahl] – Benutzt das Tempomat  <br> /stoplimit – Stoppt das Tempomat  <br> /dellack – Löscht den Lack  <br> /navi – Benutzt das Navigationsgerät  <br> /fill – Benutzt einen Benzinkanister  <br> /vehhelp – Zeigt Befehle für Fahrzeuge |
| **Admin** | /report – Öffnet das Report-Fenster  <br> /warns – Zeigt alle Warns an  <br> /checkwarns [Name] – Zeigt alle Warns eines Spielers an  <br> /admins – Zeigt alle Admins an  <br> /admincommands – Zeigt Adminbefehle für deinen Rang an |
| **Polizei** | /ergeben – Stellen mit Wanteds am PD  <br> /jailtime – Zeigt die verbleibende Knastzeit an  <br> /bail – Bezahlt die Kaution falls vorhanden  <br> /accept test – Nimmt den Drogentest vom Polizisten an  <br> /accept ticket – Nimmt ein Ticket vom Polizisten an |
| **Spiele** | /blocks – Startet Tetris  <br> /stopblocks – Stoppt Tetris  <br> /chess – Startet Schach  <br> /accept chess – Nimmt Schachangebot an  <br> /dice – Würfelt |
| **Job** | /job – Nimmt einen Job an  <br> /quitjob – Legt einen Job ab  <br> /zugjob – Startet Zugjob  <br> /endjob – Bricht Mülljob ab  <br> /sellhotdog [Preis] [Ziel] – Verkauft jemandem Hotdogs  <br> /accepthotdog – Nimmt das Angebot für den Hotdog an  <br> /cancel job – Bricht einen Job ab  <br> /fish – Benutzt die Angel  <br> /sellfish [Slot] – Verkauft Fisch |
| **Taxi** | /service taxi – Das selbe wie /call 400  <br> /accept taxi – Nimmt einen Taxiauftrag an  <br> /cancel taxi – Bricht einen Taxiauftrag ab |
| **Mechaniker** | /repair [Name] [Preis] – Repariert das Auto von jemandem für Geld  <br> /acceptrepair – Nimmt das Angebot einer Reperatur an  <br> /tunen [Name] [Preis] – Bietet jemanden Nitro für sein Auto an  <br> /accepttune – Nimmt das Angebot für Nitro an |
| **Mats** | /buymats – Kauft Mats am Waffendealer-Jobmarker  <br> /gunhelp – Zeigt Matspreise der Waffen an  <br> /sellgun [Name] [Waffe] [Ammo] – Verkauft eine Waffen an jemanden |
| **Handy** | /handy – Zeigt das Handy  <br> /sms [Nummer] [Text] – Schreibt einer Nummer einen Text  <br> /call [Nummber] – Ruft eine Nummer an  <br> /hup – Legt auf  <br> /pup – Nimmt einen Anruf an  <br> /number [Name] – Ruft Nummer des Spielers auf |
| **Drogen** | /usedrugs – Benutzt Drogen  <br> /buydrugs [Anzahl] – Kauft Drogen  <br> /givedrugs [Ziel] [Anzahl] – Gibt jemandem Drogen  <br> /grow weed – Pflanzt Drogen an |
| **Reporter** | /endlive – Beendet den Live-Chat  <br> /newspaper – Kauft eine Zeitung  <br> /readnewspaper – Liest die Zeitung |
| **Sonstiges** | /ad [Text] – Schreibt eine Werbung  <br> /internet – Öffnet das Internet  <br> /animlist – Zeigt alle Animationen an  <br> /fglass – Benutzt das Fernglas  <br> /cselect – Zeigt Farbenpalette an  <br> /pay [Name] [Anzahl] – Zahlt jemandem Geld  <br> /rebind – Legt Nachladen auf R neu an  <br> /delmyobjects – Löscht alle eigenen platzierten Objekte  <br> /fraktioncommands – Zeigt alle Fraktionbefehle an  <br> /coin – Sammelt einen Coin bei einem Hausmarker ein  <br> /coinshop – Zeigt den Coinshop |
| **Haus** | /in – Betretet eine Wohnung  <br> /out – Verlässt eine Wohnung  <br> /rent – Mietet sich in eine Wohnung ein  <br> /unrent – Mietet sich aus einer Wohnung aus  <br> /sellhouse – Verkauft deine Wohnung  <br> /setrent [Preis/0] – Bestimmt die Miete deiner Wohnung  <br> /hlock – Öffnet/Schließt deine Wohnung  <br> /buyhouse [bar/bank] – Kauft eine Wohnung |
| **Club** | /quitclub – Kündigt Gartenclub-Mitgliedschaft  <br> /leaveclub – Kündigt Verein-/Club-Mitgliedschaft |
| **Schuss** | /reddot – Aktiviert Laservisier beim Zielen  <br> /hitglocke – Aktiviert Hitglocke beim Schießen |
| **Gang** | /creategang – Erstellt eine Gang  <br> /leavegang – Verlässt die Gang  <br> /ganguninvite [Name] – Wirft jemanden aus der Gang (ab Rang 3)  <br> /ganginvite [Name] – Laded jemanden in die Gang ein (ab Rang 3)  <br> /ganggiverank [Name] [Rang] – Gibt jemandem in der Gang einen Rang (ab Rang 3) |
| **Aktion** | /payrob – Bezahlt das Geld bei einem Überfall  <br> /parachute – Geht Fallschirmspringen (Flughafen)  <br> /highscore – Zeigt Highscore vom Canyon-Rennen an  <br> /aufgeben – Gibt beim Boxer auf |
| **Chat** | /meCMD [Text] – Benutzt einen violetten Chat  <br> /s [Text] – Schreit  <br> /l [Text] – Flüstert |
| **Prestige** | /buyprestige – Kauft ein Prestige-Objekt  <br> /sellprestige – Verkauft das Prestige-Objekt |
| **Biz** | /buybiz [bar/bank] – Kauft ein Biz  <br> /sellbiz – Verkauft ein Biz  <br> /bizhelp – Zeigt Infos über das Biz an  <br> /bizdraw [Anzahl] – Nimmt Geld aus der Biz-Kasse  <br> /bizstore [Anzahl] – Zahlt Geld in die Biz-Kasse |
| **Tramjob** | /tramjob – Nimmt den Tramjob an  <br> /tramjobstart – Startet den Tramjob |

---

### Fraktionsbefehle

Fraktionsbefehle sind je nach Fraktion und Rang unterschiedlich. Nutze `/fraktioncommands [0-5]` im Spiel für Details. Beispiele:

- **Polizei (Fraktion 1):**
  - /mv – Öffnet die Tore/Schranken
  - /t [Text] – Teamchat (Fraktion)
  - /g [Text] – Beamtenchat
  - /arrest [Name] [0/1] – Knastet jemanden ein
  - ...
- **Gang (Fraktion 2, 3, 7, 9, 12, 13):**
  - /matstruck – Startet einen Matstruck
  - /robbank – Raubt die Bank aus
  - /rob [Name] – Raubt einen Zivilisten aus
  - /drogentruck – Startet einen Drogentruck
  - /bankrob – Startet einen Bankraub
  - /fguns – Öffnet das Fguns-Menü
  - ...
- **Reporter (Fraktion 5):**
  - /news [Text] – News-Chat
  - /live [Name] – Live-Chat starten
  - /endlive – Live-Chat beenden
  - ...

Weitere Fraktionen und Ränge siehe `/fraktioncommands` im Spiel!

---

### Admin-Befehle

Adminbefehle sind nach Rang gestaffelt. Nutze `/admincommands [1-6]` im Spiel für Details. Beispiele:

- **Rang 1 (VIP):**
  - /a [Text] – VIP Chat
  - /muted [Name] – (Ent-)Mutet einen Spieler
  - /premium – Premium-Panel
  - /status [Status] – Status ändern
- **Rang 3 (Supporter):**
  - /aduty – Adminduty
  - /ausknasten [Ziel] – Knastet jemanden aus
  - /pm [Name] [Nachricht] – Private Nachricht
  - ...
- **Rang 6 (Projektleiter):**
  - /settestgeld [Anzahl] – Testgeld setzen
  - /gmx [Minuten] – Server-Reload
  - /setadmin [Name] [Rang] – Adminrang vergeben

Weitere Adminbefehle siehe `/admincommands` im Spiel!

---

### Animations-Befehle

| Befehl         | Beschreibung                |
|----------------|----------------------------|
| /sex           | Sex-Animation              |
| /piss          | Pinkel-Animation           |
| /wank          | Wichs-Animation            |
| /ground        | Auf den Boden legen        |
| /fucku         | Mittelfinger zeigen        |
| /chat          | Chat-Animation             |
| /taichi        | Taichi                     |
| /chairsit      | Hinsetzen                  |
| /vomit         | Kotzen                     |
| /eat           | Essen                      |
| /wave          | Winken                     |
| /slapass       | Hintern klatschen          |
| /deal          | Deal-Animation             |
| /crack         | Crack rauchen              |
| /animlist      | Zeigt alle Animationen     |
| /handsup       | Hände hoch                 |
| /stopanim      | Animation stoppen          |
| /phoneout      | Handy rausholen            |
| /phonein       | Handy einstecken           |
| /drunk         | Betrunken laufen           |
| /bomb          | Bombe legen                |
| /smoke         | Rauchen                    |
| /robman        | Raub-Animation             |
| /getarrested   | Festgenommen werden        |
| /laugh         | Lachen                     |
| /lookout       | Umschauen                  |
| /crossarms     | Arme verschränken          |
| /lay           | Hinlegen                   |
| /hide          | Verstecken                 |
| /dance [1-7]   | Verschiedene Tanzstile     |

---

### Gangwar-Befehle

| Befehl         | Beschreibung                                  |
|----------------|-----------------------------------------------|
| /attack        | Attacken                                      |
| /joinattack    | Attack teilnehmen                             |
| /defend        | Verteidigung teilnehmen                       |
| /ganggebiete   | Ganggebiete anzeigen                          |
| /allowattack   | Attack erlauben                               |
| /allowjoin     | Gegner erlauben zum Gangwar zu joinen         |
| /burritoback   | Stellt die Burritos zurück                    |
| /gwbreak       | Ein Fahrzeug breaken                          |
| /areareset     | Area-Schutz aktivieren/deaktivieren (Admin)   |
| /stopgangwar   | Gangwar stoppen (Admin)                       |
| /setganggebiet | Ganggebiet setzen (Admin)                     |
| /setgwattacks  | Attack einer Fraktion setzen (Admin)          |

---

Viel Spaß beim Spielen und Entwickeln! 