\# jarviz\_specs/roadmap\_7days.md



\# 7-Tage Roadmap: "Jarviz v1: online + offline fallback"



\## Tag 1 — Auth stabil (E-Mail/Passwort)

\- Register/Login Flow finalisieren (UI + AuthService).

\- AuthGate: stabile Zustände (loading/signed-out/signed-in).

\- Basis-Tests: AuthGate widget test (smoke), AuthService unit test (mock).



Deliverable:

\- Login/Signup/Logout zuverlässig, keine Crash/Loops.



\## Tag 2 — Rollen/Boss-only (nur Florian)

\- Role enum + RoleResolver (Default user).

\- Boss-Allowlist aus .env (UID/E-Mail).

\- Boss-only Guards: UI + Route + Action Checks.



Deliverable:

\- Boss-only Features sind 100% geschützt (auch via Deep Link / Route).



\## Tag 3 — Jarviz Server v1: Contract + Stub

\- Server Spec v1 final (Endpoints + Error Codes).

\- Minimaler Server Stub (Status/Chat/Modules) lokal lauffähig.

\- Curl Checks + einfache Contract Tests (optional).



Deliverable:

\- localhost:5000 liefert /api/status, /api/chat, /api/modules zuverlässig.



\## Tag 4 — Chat UI online (happy path)

\- Avatar Chat Screen MVP: message list, input, send, loading.

\- JarvizService: robustes Parsing (response, error).

\- UI: Connection Indicator (online/offline), Retry.



Deliverable:

\- Online Chat funktioniert Ende-zu-Ende gegen Stub/Server.



\## Tag 5 — Offline Fallback + Memory (verschlüsselt, Opt-in)

\- Offline Fallback Engine: lokale Antworten, Help, Status, Minimal-Commands.

\- Memory Repository: encrypted local store (device-only).

\- Opt-in Prompt + Memory löschen + Export (JSON).



Deliverable:

\- Wenn Server down: Chat bleibt nutzbar (fallback) + Memory Flows sind korrekt.



\## Tag 6 — Stabilisierung + Tests + Analyze

\- Tests erweitern: RoleResolver, Memory roundtrip, JarvizService errors/timeouts.

\- flutter analyze 0 errors, Lints fixen.

\- CI Pipeline (analyze + test) grün.



Deliverable:

\- Stabiler Build, keine Analyzer-Fehler, Tests grün.



\## Tag 7 — Polishing + Release Candidate

\- UX Polish: leere Zustände, Fehlertexte, Offline-Banner, Settings entry für Memory.

\- Docs final: decisions.md + quickstart (Server starten, App verbinden).

\- RC Smoke Test Matrix (Android/iOS Emulator).



Deliverable:

\- "Jarviz v1: online + offline fallback" RC bereit.



\## Nach Tag 7 – Bewertung

\- Was lief gut?

\- Was lief schlecht?

\- Nächste 7-Tage-Planung



