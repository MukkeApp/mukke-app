# jarviz_specs/01_Projektstatus.md

Stand: 2026-02-01 (Europe/Berlin)

## 1) Was funktioniert schon?
- App startet und läuft auf Android Gerät (Smoke-Test ok).
- Flutter Setup ok, Devices erkannt.
- flutter test: grün.
- Aktiver Arbeitsbranch: feature/auth-email-password.
- Auth/Flow ist lauffähig (App läuft nach den letzten Anpassungen).

## 2) Was fehlt noch?
MVP / P0 laut Backlog & Roadmap:
- Firebase Login (E-Mail/Passwort) sauber/stabil fertigstellen (UI + AuthService + Error-Mapping + AuthGate, ggf. noch Rest-Feinschliff).
- Rollen/Permissions inkl. Boss-only (nur Florian Schulz; v1 via Allowlist aus .env).
- Mini-Avatar-Chat E2E + Offline-Fallback + lokales verschlüsseltes Memory (Opt-in + Löschen/Export).
- Codequalität: flutter analyze = 0 Errors (Ziel später: 0 Issues) + Tests grün.

Nicht-MVP / später:
- Viele Screens haben noch keine Anbindungen/keine Persistenz (z.B. Profil speichert Eingaben nicht, Daten werden nicht über Screens geteilt).
  => als separates Paket nach MVP stabilisieren einplanen (Scope-Schutz).

## 3) Was ist als Nächstes dran?
Nächster Sprint gemäß Roadmap (weiter nach Plan):
1) Android Lizenzen final akzeptieren:
  - flutter doctor --android-licenses (alle mit y bestätigen)
2) Tag 2 — Rollen/Boss-only:
  - Role/Resolver + Boss-Allowlist (.env)
  - Guards: UI + Route + Actions (Boss-only wirklich überall geschützt)

## 4) Blocker / Risiken / technische Hindernisse
- flutter analyze zeigt noch viele Infos/Warnungen (kein akuter Blocker fürs Laufen, aber Qualitätsziel später).
- Android: 1 License war offen (Doctor Hinweis), muss final akzeptiert werden.
- Profil/Screen-State: aktuell keine Persistenz/State-Sharing -> bewusst verschoben, sonst Scope Creep.

## 5) Entscheidungen (Referenz)
- Siehe jarviz_specs/decisions.md:
  - API Envelope + Legacy response Feld
  - WS Pfad /ws empfohlen
  - Auth Error-Mapping testbar auslagern
  - Boss-only Access v1 via Email Whitelist (Boss identity: Mapstar1588@web.de)


---
## HANDOFF (2026-02-01 21:53)

**Branch:** feature/auth-email-password  
**Status:** App l�uft. Auth-�nderungen & Mapper-Arbeit in Progress.  
**�nderungen aktuell (unstaged):**
- jarviz_specs/jarviz_server_spec_v1.md (aktualisiert)
- register_screen_.dart (angepasst)
- auth_service.dart (angepasst)
- error_mapper.dart entfernt
- auth_error_mapper.dart neu

**N�chste Schritte (morgen):**
1) Android Lizenzen final: lutter doctor --android-licenses (alles mit y best�tigen)
2) Boss-only Rollencheck implementieren (Allowlist via .env + Guard Widget)
3) Danach: flutter analyze schrittweise reduzieren

---
