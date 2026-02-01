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



