# PowerShell-Skript: Ergänzt gezielt Features in dashboard.html

$dashboardFile = "dashboard.html"

# 1. Sprach-Style in <head>
$headStyle = @"
<style>
#mic-btn { background: #222; color: #fff; border: none; border-radius: 50%; width: 40px; height: 40px; font-size: 1.4em; margin-left: 8px;}
#mic-btn.active { background: #00BFFF; }
</style>
"@

# 2. Mic-Button nach "Senden"-Button (in .input-group)
$micBtn = '<button onclick="startListening()" id="mic-btn">🎤</button>'

# 3. Sprach-JS-Block ans Ende vor </body>
$voiceScript = @"
<script>
function addMessage(text, sender) {
    const messages = document.getElementById('messages');
    const div = document.createElement('div');
    div.className = 'message ' + sender;
    div.textContent = text;
    messages.appendChild(div);
    messages.scrollTop = messages.scrollHeight;
    if(sender === 'jarviz' && window.speechSynthesis) {
        let utter = new SpeechSynthesisUtterance(text);
        utter.lang = 'de-DE';
        speechSynthesis.speak(utter);
    }
}
let recognizing = false, recognition;
function startListening() {
    if (!('webkitSpeechRecognition' in window)) {
        alert('Speech Recognition wird nicht unterstützt.');
        return;
    }
    if (recognizing) {
        recognition.stop();
        return;
    }
    recognition = new webkitSpeechRecognition();
    recognition.lang = 'de-DE';
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;
    recognition.onstart = function() {
        recognizing = true;
        document.getElementById('mic-btn').classList.add('active');
    };
    recognition.onresult = function(event) {
        recognizing = false;
        document.getElementById('mic-btn').classList.remove('active');
        const text = event.results[0][0].transcript;
        document.getElementById('input').value = text;
        sendMessage();
    };
    recognition.onerror = function() {
        recognizing = false;
        document.getElementById('mic-btn').classList.remove('active');
    };
    recognition.onend = function() {
        recognizing = false;
        document.getElementById('mic-btn').classList.remove('active');
    };
    recognition.start();
}
</script>
"@

# Datei einlesen
$fileContent = Get-Content $dashboardFile -Raw

# 1. HEAD-Style einfügen
if ($fileContent -notmatch "#mic-btn.active") {
    # Nach <head> einfügen
    $fileContent = $fileContent -replace "<head>", "<head>`r`n$headStyle"
}

# 2. Mic-Button nach Senden-Button einfügen
if ($fileContent -notmatch 'id="mic-btn"') {
    # Finde die Zeile mit dem Senden-Button
    $fileContent = $fileContent -replace '(<button\s+onclick="sendMessage\(\)">Senden</button>)', "`$1`r`n$micBtn"
}

# 3. Sprach-JS-Block vor </body> einfügen
if ($fileContent -notmatch 'function startListening') {
    $fileContent = $fileContent -replace '</body>', "$voiceScript`r`n</body>"
}

# Datei speichern
Set-Content $dashboardFile $fileContent -Encoding UTF8

Write-Host "dashboard.html wurde erfolgreich gepatcht!" -ForegroundColor Green
