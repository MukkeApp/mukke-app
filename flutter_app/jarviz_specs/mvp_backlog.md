\# jarviz\_specs/mvp\_backlog.md



\# MVP Backlog (Jarviz v1: online + offline fallback)

Priorität folgt:

1\) Firebase Login (E-Mail/Passwort)

2\) Rollen/Permissions (Boss-only nur Florian Schulz)

3\) Mini-Avatar-Chat + lokales verschlüsseltes Memory (Opt-in + Löschen/Export)

4\) Codequalität (flutter analyze = 0, Tests grün)



\## P0 — Muss rein (Release Candidate)

1\. Firebase Auth: Login/Signup UI finalisieren (RegisterScreen Modes), Validierung, Fehlertexte.

2\. AuthService: E-Mail/Passwort login/signup/logout + Fehler-Mapping.

3\. AuthGate Stabilität: saubere Loading/Redirects, keine Route-Loops.

4\. UserProvider: aktuelle Firebase-User Daten (uid, email, displayName) zentral bereitstellen.

5\. Rollenmodell im Client: enum Role { boss, user, kid } + RoleResolver.

6\. Boss-Allowlist: Boss nur für Florian (UID/E-Mail aus .env), Default = user.

7\. Boss-only Guard: UI verstecken + Route/Action Guard (doppelt absichern).

8\. Jarviz Chat UI (MVP): simple Chat-Ansicht (Liste, Input, Senden, Loading).

9\. JarvizService Online: POST /api/chat integrieren, Response parsing (response + error).

10\. Connectivity Switch: online wenn /api/status ok, sonst offline fallback.

11\. Offline Fallback Engine (MVP): lokale Antworten (Help/Status/“Server offline”) + Basis-Commands.

12\. Lokales Memory Repository (verschlüsselt): Datenmodell + persist (device-only).

13\. Memory Opt-in Flow: „Soll ich mir das merken?“ Ja/Nein + nur bei Ja speichern.

14\. Memory Verwaltung UI: „Memory löschen“ + „Export“ (z.B. JSON-Datei Share-Sheet).

15\. Tests P0: unit tests für RoleResolver, Memory encryption roundtrip, JarvizService error parsing.

16\. flutter analyze = 0 + CI (GitHub Actions) für analyze + test.



\## P1 — Sollte rein (wenn Zeit im 7-Tage-Fenster)

17\. WebSocket Support v1: connect/reconnect, server push anzeigen (optional streaming).

18\. Modules Screen: GET /api/modules anzeigen (Status + Capabilities).

19\. Internationalisierung: Jarviz chat berücksichtigt LanguageProvider (lang senden).

20\. Error UX: Offline-Banner, Retry-Button, Toasts, Timeouts sauber.

21\. Telemetrie minimal (opt-in): technische Logs ohne Memory-Inhalt.



\## P2 — Später (klar abgegrenzt)

22\. Serverseitige Auth-Erzwingung via Firebase Admin SDK

23\. Kids Mode (echte Einschränkungen + Content Filter)

24\. „Boss Tools“: Projekte/Deploy/Feature-Toggles aus App heraus

25\. Serverseitiges Memory (nur opt-in, DSGVO), Sync multi-device



