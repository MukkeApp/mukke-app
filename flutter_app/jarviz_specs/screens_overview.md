\# Screens Overview (Stand 2026-02-02)



\## Auth / Navigation



\### AuthGate (lib/auth\_gate.dart)

\- Logik: authStateChanges()

&nbsp; - nicht eingeloggt -> RegisterScreen

&nbsp; - eingeloggt -> HomeScreen (aus mukke\_home\_screen.dart)

\- Risiko: keine, sauberer Einstiegspunkt



\### Main / Routes (lib/main.dart)

\- home: AuthGate()

\- Definierte Named Routes:

&nbsp; - /profile, /music, /music/ki, /dating, /sport, /challenges, /games, /avatar,

&nbsp;   /tracking, /fashion, /language, /live, /feedback, /account-linking, /agb

&nbsp; - /boss (über BossGuard geschützt)

&nbsp; - /register, /login (RegisterScreen initialMode)

\- Auffällig:

&nbsp; - HomeScreen nutzt aktuell /improvements, aber main.dart kennt /feedback



\## Screens (hochgeladen)



\### HomeScreen (class HomeScreen)

\- Navigation: Grid mit menuItems -> Navigator.pushNamed(context, item\['route'])

\- Problem: menuItem "Verbesserungsvorschläge" routet auf /improvements (nicht in main.dart)

\- Tag2-Relevanz:

&nbsp; - Optional später: Boss-only Entry "Boss Panel" nur für Boss sichtbar



\### BossPanelScreen

\- Anzeige: einfacher Platzhalter, zeigt currentUser mail/uid

\- Tag2: Route /boss ist bereits vorhanden, muss aber Rollen-Check zentral haben (nicht irgendwo hardcoded)



\### MukkeFeedbackScreen

\- Features:

&nbsp; - Vorschlag einreichen (Firestore suggestions)

&nbsp; - Voting (thumb up/down)

&nbsp; - Admin Panel Tab + Admin Decisions (approved/rejected)

\- Problem (P0 für Tag2):

&nbsp; - Admin wird aktuell über Hardcode geprüft:

&nbsp;   `final isDeveloper = \_auth.currentUser?.email == 'mapstar1588@web.de';`

&nbsp; - => Muss auf zentrale Boss-Rollenlogik umgestellt werden (Boss-only = Florian)

\- Tag2: Boss-only Schutz für:

&nbsp; - Admin Tab

&nbsp; - \_adminDecision() Action (Button/Backend Update)

&nbsp; - Admin Notifications Collection optional nur Boss sichtbar



\### MukkeGamesScreen

\- Features:

&nbsp; - Firestore + Auth

&nbsp; - Dialoge navigieren zu: /subscription, /payout, /leaderboard

\- Risiko:

&nbsp; - In main.dart Snapshot fehlen diese Routes -> führt zu "Seite nicht gefunden"



\### DatingProfileScreen

\- Features:

&nbsp; - Firestore + Storage + Auth

&nbsp; - Mehrseitiges Profil-Setup (Wizard)

\- Hinweis:

&nbsp; - Erwartet eingeloggten User. Falls null, sollte UI defensiv reagieren (später)



\### KiMusicScreen

\- Lokale UI, keine externen Services, nutzt Navigator.pop + Snackbars



\### MukkeAvatarScreen

\- Features:

&nbsp; - Auth + Firestore

&nbsp; - Chat UI + TTS

&nbsp; - HTTP Call OpenAI Endpoint

\- Security Hinweis:

&nbsp; - API Key ist aktuell als Placeholder const `YOUR\_OPENAI\_API\_KEY\_HERE` hardcoded

&nbsp; - Später: Key aus .env oder Proxy über Server (nicht jetzt Tag2)



\### MukkeFashionScreen

\- Features:

&nbsp; - Auth + Firestore

&nbsp; - Größen speichern, Outfit Vorschläge, ShoppingCartScreen (local)



\### AccountLinkingScreen

\- Features: Social Links Form, keine Navigation



\### AGBScreen

\- Features:

&nbsp; - Terms UI, Acceptance -> Navigator.pop(true/false)

\- Hinweis:

&nbsp; - Gut, um Acceptance in Register/Login Flow einzubauen (Tag1/Tag2 abhängig)



