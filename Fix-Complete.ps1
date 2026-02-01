# Fix-Complete.ps1
# Behebt Encoding und Einrückungsprobleme

$filePath = "start_server.py"
$backupPath = "start_server.py.backup"

Write-Host "🔧 Behebe Encoding und Einrückungsprobleme..." -ForegroundColor Yellow

# Backup erstellen
Copy-Item $filePath $backupPath
Write-Host "💾 Backup erstellt: $backupPath" -ForegroundColor Green

# Lese Datei mit korrektem Encoding
$content = Get-Content $filePath -Raw -Encoding UTF8

# Fixe kaputte Umlaute
$replacements = @{
    "DrÃƒÂ¼cke" = "Drücke"
    "fÃƒÂ¼r" = "für"
    "Ãƒâ€ž" = "Ä"
    "ÃƒÂ¶" = "ö"
    "ÃƒÂ¼" = "ü"
    "ÃƒÂ¤" = "ä"
    "ÃƒÅ¸" = "ß"
    "Ã¼" = "ü"
    "Ã¤" = "ä"
    "Ã¶" = "ö"
}

foreach ($key in $replacements.Keys) {
    $content = $content -replace [regex]::Escape($key), $replacements[$key]
}

Write-Host "✓ Encoding-Fehler behoben" -ForegroundColor Green

# Speichere mit korrektem Encoding
[System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)

# Jetzt nochmal autopep8 ausführen für saubere Einrückung
Write-Host "`n🔧 Führe autopep8 aus..." -ForegroundColor Yellow
$autopep8Result = & autopep8 --in-place --aggressive --aggressive $filePath 2>&1

# Falls autopep8 nicht reicht, manuelle Korrektur für bekannte Problemstellen
Write-Host "`n🔧 Prüfe spezifische Problemstellen..." -ForegroundColor Yellow

$lines = Get-Content $filePath -Encoding UTF8
$fixedLines = @()
$inIfBlock = $false
$expectedIndent = 0

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    $trimmed = $line.TrimStart()
    
    # Skip leere Zeilen
    if ($trimmed.Length -eq 0) {
        $fixedLines += ""
        continue
    }
    
    # Finde problematische if-Blöcke
    if ($line -match "if\s+response\.lower\(\)\s*==\s*'j':") {
        $inIfBlock = $true
        # Berechne Basis-Einrückung
        $line -match "^(\s*)" | Out-Null
        $expectedIndent = $matches[1].Length + 4
        $fixedLines += $line
        continue
    }
    
    # Korrigiere Zeilen im if-Block
    if ($inIfBlock -and $trimmed.StartsWith("subprocess.Popen")) {
        $fixedLines += (" " * $expectedIndent) + $trimmed
        $inIfBlock = $false
        continue
    }
    
    # Normale Zeilen
    $fixedLines += $line
}

# Speichere korrigierte Version
$fixedLines | Out-File $filePath -Encoding UTF8

Write-Host "✓ Einrückung korrigiert" -ForegroundColor Green

# Finale Syntax-Prüfung
Write-Host "`n🔍 Finale Syntax-Prüfung..." -ForegroundColor Yellow
$syntaxCheck = & python -m py_compile $filePath 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Alle Probleme behoben! Die Datei ist jetzt lauffähig." -ForegroundColor Green
    Write-Host "`n🚀 Du kannst jetzt ausführen: python start_server.py" -ForegroundColor Cyan
} else {
    Write-Host "❌ Es gibt noch Syntax-Fehler:" -ForegroundColor Red
    Write-Host $syntaxCheck
    Write-Host "`n💡 Tipp: Verwende das Backup falls nötig: $backupPath" -ForegroundColor Yellow
}

# Zeige die korrigierten Zeilen
Write-Host "`n📋 Korrigierte Problemstellen:" -ForegroundColor Cyan
$problemLines = @(2080, 2081, 2085)
foreach ($lineNum in $problemLines) {
    if ($lineNum -le $fixedLines.Count) {
        Write-Host "Zeile $lineNum`: $($fixedLines[$lineNum-1])" -ForegroundColor Gray
    }
}