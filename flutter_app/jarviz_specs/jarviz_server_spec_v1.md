\# jarviz\_specs/jarviz\_server\_spec\_v1.md



\# Jarviz Server Spec v1 (HTTP + WebSocket)

Ziel: Server ist kompatibel zu bestehendem Client (JarvizService: localhost:5000),

liefert aber v1-konforme, erweiterbare Responses.



\## 0) Konventionen



\### Base URLs

\- HTTP:  http://{host}:{port}

\- WS:    ws://{host}:{port}



Default Dev:

\- http://localhost:5000

\- ws://localhost:5000



\### Versionierung

\- Diese Spezifikation ist "v1".

\- Endpoints bleiben vorerst bei /api/\* (ohne /v1), aber jede Response enthält `api\_version: "v1"`.



\### Response-Envelope (v1)

Server soll (wo möglich) einen einheitlichen Envelope verwenden:



Success:

{

&nbsp; "ok": true,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "uuid-or-shortid",

&nbsp; "timestamp": "ISO-8601",

&nbsp; "data": { ... },

&nbsp; "meta": { ... }

}



Error:

{

&nbsp; "ok": false,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "uuid-or-shortid",

&nbsp; "timestamp": "ISO-8601",

&nbsp; "error": {

&nbsp;   "code": "invalid\_request | unauthorized | forbidden | rate\_limited | unavailable | upstream\_error | server\_error",

&nbsp;   "message": "human readable",

&nbsp;   "details": { ... }

&nbsp; }

}



\### Backward-Compatibility (WICHTIG)

Der bestehende Client erwartet bei POST /api/chat zusätzlich:

\- Top-Level Feld: `response` (string)



=> Daher MUSS /api/chat bei Erfolg immer `response` auf Top-Level liefern,

auch wenn zusätzlich `data.response` vorhanden ist.



---



\## 1) Authentifizierung / Rollen (v1 minimal)



\### Optional: Firebase ID Token

Header:

Authorization: Bearer {firebase\_id\_token}



v1-Phase (lokal/dev):

\- Token ist OPTIONAL.

\- Ohne Token darf der Server antworten, aber nur mit "user" Rolle.



\### Rollenmodell

\- boss: nur Allowlist (z.B. UID oder E-Mail)

\- user: normal

\- kid: eingeschränkt (später, aber Response kann role bereits enthalten)



Hinweis: Der Client kann zusätzlich lokal boss-only absichern.



---



\## 2) HTTP Endpoints



\### 2.1 GET /api/status

\#### Zweck

Healthcheck/Connectivity-Test.



\#### Request

\- Keine Query-Params, kein Body.



\#### Success 200

{

&nbsp; "ok": true,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "…",

&nbsp; "timestamp": "…",

&nbsp; "data": {

&nbsp;   "status": "ok",

&nbsp;   "server\_time": "ISO-8601",

&nbsp;   "uptime\_s": 12345,

&nbsp;   "environment": "dev|prod",

&nbsp;   "capabilities": {

&nbsp;     "chat": true,

&nbsp;     "modules": true,

&nbsp;     "websocket": true

&nbsp;   }

&nbsp; }

}



\#### Fehlerfälle

\- 503 Service Unavailable:

&nbsp; error.code = "unavailable"

\- 500 Internal:

&nbsp; error.code = "server\_error"



---



\### 2.2 GET /api/modules

\#### Zweck

Module-/Feature-Übersicht (Client zeigt Status/Capabilities an).



\#### Success 200

{

&nbsp; "ok": true,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "…",

&nbsp; "timestamp": "…",

&nbsp; "data": {

&nbsp;   "modules": \[

&nbsp;     {

&nbsp;       "id": "chat",

&nbsp;       "name": "Jarviz Chat",

&nbsp;       "status": "online|degraded|offline",

&nbsp;       "version": "1.0.0",

&nbsp;       "description": "Text chat / command handling",

&nbsp;       "endpoints": \["POST /api/chat", "WS /ws"],

&nbsp;       "capabilities": \["streaming", "memory\_suggest", "language\_detect"],

&nbsp;       "last\_heartbeat": "ISO-8601"

&nbsp;     }

&nbsp;   ]

&nbsp; }

}



\#### Fehlerfälle

\- 503: unavailable

\- 500: server\_error



---



\### 2.3 POST /api/chat

\#### Zweck

Chat/Command Verarbeitung.



\#### Headers

\- Content-Type: application/json

\- Optional: Authorization: Bearer {firebase\_id\_token}



\#### Request Body (v1)

{

&nbsp; "message": "string, required, 1..4000 chars",

&nbsp; "user\_id": "string, optional (client sends default if missing)",

&nbsp; "project\_id": "string, optional (client sends default if missing)",

&nbsp; "lang": "de|en|… optional",

&nbsp; "client": {

&nbsp;   "app": "mukke\_app",

&nbsp;   "platform": "ios|android|web",

&nbsp;   "version": "x.y.z"

&nbsp; },

&nbsp; "context": {

&nbsp;   "timezone": "Europe/Berlin",

&nbsp;   "screen": "avatar\_chat",

&nbsp;   "session\_id": "optional"

&nbsp; }

}



\#### Success 200 (MUSS `response` enthalten)

{

&nbsp; "ok": true,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "…",

&nbsp; "timestamp": "…",



&nbsp; "response": "string (legacy for current client)",



&nbsp; "data": {

&nbsp;   "message\_id": "uuid",

&nbsp;   "response": "same string as top-level response",

&nbsp;   "mode": "online",

&nbsp;   "role": "boss|user|kid",

&nbsp;   "actions": \[

&nbsp;     {

&nbsp;       "type": "open\_route|show\_toast|suggest\_memory|module\_hint",

&nbsp;       "payload": { }

&nbsp;     }

&nbsp;   ],

&nbsp;   "memory\_suggestion": {

&nbsp;     "should\_ask\_opt\_in": true,

&nbsp;     "items": \[

&nbsp;       { "key": "favorite\_genre", "value": "Techno", "ttl\_days": 365 }

&nbsp;     ]

&nbsp;   }

&nbsp; }

}



\#### Fehlerfälle (Statuscodes + error.code)

\- 400 invalid JSON / missing message / message too long

&nbsp; - code: "invalid\_request"

\- 401 invalid/expired token (wenn Server Token erzwingt)

&nbsp; - code: "unauthorized"

\- 403 role not allowed (boss-only operation)

&nbsp; - code: "forbidden"

\- 429 rate limit

&nbsp; - code: "rate\_limited"

\- 502/503 upstream/model unavailable

&nbsp; - code: "upstream\_error" oder "unavailable"

\- 500 internal

&nbsp; - code: "server\_error"



\#### Minimale Error Response

{

&nbsp; "ok": false,

&nbsp; "api\_version": "v1",

&nbsp; "request\_id": "…",

&nbsp; "timestamp": "…",

&nbsp; "error": {

&nbsp;   "code": "invalid\_request",

&nbsp;   "message": "Field 'message' is required",

&nbsp;   "details": { "field": "message" }

&nbsp; }

}



---



\## 3) WebSocket (v1)



\### 3.1 URL

Empfohlen:

\- ws://{host}:{port}/ws



Legacy (für aktuellen Client, wenn Root genutzt wird):

\- ws://{host}:{port}/



Server SOLL beide akzeptieren (Root = Alias zu /ws), bis Client umgestellt ist.



\### 3.2 Message Format

Alle WS Messages sind JSON (Text Frames).



\#### Client -> Server: hello

{

&nbsp; "type": "hello",

&nbsp; "api\_version": "v1",

&nbsp; "user\_id": "optional",

&nbsp; "project\_id": "optional",

&nbsp; "token": "optional firebase id token"

}



\#### Server -> Client: hello\_ack

{

&nbsp; "type": "hello\_ack",

&nbsp; "ok": true,

&nbsp; "api\_version": "v1",

&nbsp; "session\_id": "uuid",

&nbsp; "server\_time": "ISO-8601",

&nbsp; "role": "boss|user|kid"

}



\#### Client -> Server: chat

{

&nbsp; "type": "chat",

&nbsp; "message\_id": "uuid",

&nbsp; "message": "string",

&nbsp; "lang": "optional",

&nbsp; "context": { }

}



\#### Server -> Client: chat\_delta (streaming optional)

{

&nbsp; "type": "chat\_delta",

&nbsp; "message\_id": "uuid",

&nbsp; "delta": "partial text"

}



\#### Server -> Client: chat\_done

{

&nbsp; "type": "chat\_done",

&nbsp; "message\_id": "uuid",

&nbsp; "response": "full text",

&nbsp; "meta": { "tokens": 123 }

}



\#### Server -> Client: error

{

&nbsp; "type": "error",

&nbsp; "message\_id": "optional",

&nbsp; "error": { "code": "...", "message": "...", "details": {} }

}



\### 3.3 Heartbeat

\- Server sendet alle 30s:

&nbsp; { "type": "ping", "ts": "ISO-8601" }

\- Client antwortet:

&nbsp; { "type": "pong", "ts": "ISO-8601" }



---



\## 4) Non-Goals v1 (explizit)

\- Kein serverseitiges Speichern von User-Memory (Default: aus)

\- Keine verpflichtende Account-Verknüpfung zum Chat in dev

\- Keine komplexen Toolchains/Plugins; nur minimaler Module-Status + Chat



