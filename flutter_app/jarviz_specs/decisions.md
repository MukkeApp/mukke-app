\# jarviz\_specs/decisions.md



\# Architektur-Entscheidungen (Jarviz)



\## 2026-01-31 — API Envelope + Legacy Compatibility

Entscheidung:

\- Server Responses nutzen v1 Envelope (ok/api\_version/request\_id/timestamp/data/error),

\- ABER /api/chat liefert zusätzlich Top-Level `response` (string) als Legacy-Feld,

&nbsp; weil der aktuelle Client genau dieses Feld ausliest.



Begründung:

\- Keine stillen Breaking Changes am Client,

\- trotzdem klare v1 Struktur für spätere Erweiterungen (actions, memory\_suggestion, role, etc.).



Konsequenzen:

\- Server implementiert `response` auf Top-Level bei Erfolg.

\- Client kann später schrittweise auf data.response migrieren.



\## 2026-01-31 — WebSocket Pfad: /ws empfohlen, Root als Alias

Entscheidung:

\- v1 empfiehlt ws://host:port/ws,

\- Server akzeptiert zusätzlich ws://host:port/ (Root) als Legacy.



Begründung:

\- aktueller Client nutzt Root, wir vermeiden Client-Refactor im selben Schritt.

## 2026-01-31 — AuthService: Error-Mapping testbar machen
Entscheidung:
- FirebaseAuth-Fehlercodes werden in eine pure Dart Funktion ausgelagert (`auth_error_mapper.dart`).
- `AuthService` wirft `AuthException(code, message)` mit userfreundlicher DE-Message.

Begründung:
- Tests ohne Firebase Plugin Setup möglich (schnell, stabil).
- UI kann konsistent nur `e.message` anzeigen.

## Decision: Boss-only Access v1 via Email Whitelist

**Context:** MVP braucht Boss-only Features strikt nur für Florian Schulz.  
**Decision:** Boss-Erkennung erfolgt v1 über Whitelist (E-Mail) im Client (`BossAccessService`).  
**Boss identity:** Mapstar1588@web.de  
**Rationale:** Schnellster MVP, klare Kontrolle, später upgradebar auf Custom Claims/Firestore Roles.  
**Consequences:** E-Mail muss korrekt sein; echte Security später serverseitig (Rules/Claims) ergänzen.

