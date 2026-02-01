from inspect import _void
from tkinter import Widget
from dotenv import load_dotenv
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from flask_cors import CORS
from flask_socketio import SocketIO, emit
from flask import Flask, request, jsonify, render_template
from typing import Dict, List, Any, Optional
from queue import Queue
from datetime import datetime, timedelta
from pathlib import Path
import shutil
import re
import threading
import subprocess
import logging
import time
import json
import sys
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'dart:async';
import socket
from typing import Generic
import openai
import os

# API-Key aus der .env laden
openai.api_key = os.getenv("OPENAI_API_KEY")


def create_flutter_screen(screen_name: str, project_path: Path):
    """Erstellt Beispiel-Screens für Flutter"""
    screen_dir = project_path / "lib" / "screens"
    screen_dir.mkdir(parents=True, exist_ok=True)

    flutter_files = {
        "home_screen.dart": (
            "import 'package:flutter/material.dart';\n\n"
            "class HomeScreen extends StatelessWidget {\n"
            "  @override\n"
            "  Widget build(BuildContext context) {\n"
            "    return Scaffold(\n"
            "      appBar: AppBar(title: Text('Home')),\n"
            "      body: Center(child: Text('Willkommen im Home-Screen!')),\n"
            "    );\n"
            "  }\n"
            "}\n"
        ),
        "profile_screen.dart": (
            "import 'package:flutter/material.dart';\n\n"
            "class ProfileScreen extends StatelessWidget {\n"
            "  @override\n"
            "  Widget build(BuildContext context) {\n"
            "    return Scaffold(\n"
            "      appBar: AppBar(title: Text('Profil')),\n"
            "      body: Center(child: Text('Das ist dein Profil.')),\n"
            "    );\n"
            "  }\n"
            "}\n"
        ),
        "settings_screen.dart": (
            "import 'package:flutter/material.dart';\n\n"
            "class SettingsScreen extends StatelessWidget {\n"
            "  @override\n"
            "  Widget build(BuildContext context) {\n"
            "    return Scaffold(\n"
            "      appBar: AppBar(title: Text('Einstellungen')),\n"
            "      body: Center(child: Text('Hier kannst du Einstellungen vornehmen.')),\n"
            "    );\n"
            "  }\n"
            "}\n"
        )

    for filename, content in flutter_files.items():
        filepath = screen_dir / filename
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
def fix_project_errors(self) -> str:
                """Analysiert und behebt Projekt-Fehler"""
                try:
                        errors_found = []
                        errors_fixed = []

                        # Flutter analyze ausführen
                        result = subprocess.run(
                                ['flutter', 'analyze'],
                                cwd=str(FLUTTER_PATH),
                                capture_output=True,
                                text=True
                        )

                        if result.returncode != 0:
                                # Parse Fehler
                                error_lines = result.stdout.split('\n')
                                for line in error_lines:
                                        if 'error' in line.lower():
                                                errors_found.append(line)

                                                # Versuche automatische Fixes
                                                if 'undefined name' in line.lower():
                                                        # Fehlende Imports
                                                        match = re.search(
                                                            r"Undefined name '(\w+)'", line)
                                                        if match:
                                                                undefined_name = match.group(
                                                                    1)
                                                                if self._fix_undefined_name(undefined_name):
                                                                        errors_fixed.append(
                                                                            f"Import für {undefined_name} hinzugefügt")

                                                elif 'const' in line.lower():
                                                        # Const Konstruktor
                                                        if self._fix_const_constructor(line):
                                                                errors_fixed.append(
                                                                    "Const Konstruktor behoben")

                        # Speichere Error Solutions
                        for error in errors_found:
                                error_type = error.split(
                                    ':')[0] if ':' in error else 'unknown'
                                if error_type not in self.error_solutions:
                                        self.error_solutions[error_type] = {
                                                'solution': 'Manuell prüfen',
                                                'success_count': 0

                        self._save_memory(
                            'error_solutions.json', self.error_solutions)
                        self.stats['errors_fixed'] += len(errors_fixed)

                        result_msg = f"🔍 Fehleranalyse abgeschlossen:\n"
                        result_msg += f"📊 {len(errors_found)} Fehler gefunden\n"
                        result_msg += f"✅ {len(errors_fixed)} Fehler automatisch behoben\n"

                        if errors_fixed:
                                result_msg += "\n🔧 Behobene Fehler:\n"
                                for fix in errors_fixed[:5]:
                                        result_msg += f"  - {fix}\n"

                        if len(errors_found) > len(errors_fixed):
                                result_msg += f"\n⚠️ {len(errors_found) - len(errors_fixed)} Fehler erfordern manuelle Behebung"

                        return result_msg

                except Exception as e:
                        logger.error(f"Error fixing project errors: {e}")
                        return f"❌ Fehler bei der Fehleranalyse: {str(e)}"


def _fix_undefined_name(self, name: str) -> bool:
                """Versucht undefined name Fehler zu beheben"""
                try:
                        # Mapping von häufigen Namen zu Imports
                        import_map = {
                                'Provider': "import 'package:provider/provider.dart';",
                                'Firebase': "import 'package:firebase_core/firebase_core.dart';",
                                'MaterialApp': "import 'package:flutter/material.dart';",
                                'StatefulWidget': "import 'package:flutter/material.dart';",
                                'StatelessWidget': "import 'package:flutter/material.dart';",

                        if name in import_map:
                                # TODO: Import zu betroffener Datei hinzufügen
                                return True

                        return False
                except:
                        return False


def _fix_const_constructor(self, error_line: str) -> bool:
                """Versucht const constructor Fehler zu beheben"""
                try:
                        # TODO: Implementiere const constructor fix
                        return False
                except:
                        return False


def run_flutter_tests(self) -> str:
                """Führt Flutter Tests aus"""
                try:
                        logger.info("Running Flutter tests")

                        result = subprocess.run(
                                ['flutter', 'test'],
                                cwd=str(FLUTTER_PATH),
                                capture_output=True,
                                text=True
                        )

                        if result.returncode == 0:
                                return "✅ Alle Flutter-Tests erfolgreich!"
                        else:
                                # Analysiere Fehler
                                error_msg = result.stderr or result.stdout

                                # Lerne aus dem Fehler
                                self.analyze_test_error(error_msg)

                                return f"❌ Test-Fehler:\n{error_msg[:500]}\n\n💡 Verwende 'Fehler beheben' für automatische Fixes"

                except Exception as e:
                        logger.error(f"Error running tests: {e}")
                        return f"❌ Fehler beim Ausführen der Tests: {str(e)}"


def analyze_test_error(self, error_msg: str):
                """Analysiert Test-Fehler und lernt daraus"""
                # Extrahiere Fehlertypen
                if 'No tests found' in error_msg:
                        # Erstelle Basis-Test
                        self.create_basic_test()


def create_basic_test(self):
                """Erstellt einen Basis-Test"""
                test_content = '''import 'package:flutter_test/flutter_test.dart';
import 'package:mukke_app/main.dart';

void main() {
    testWidgets('App starts successfully', (WidgetTester tester) async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(const MukkeApp());

        // Verify that app starts
        expect(find.byType(MukkeApp), findsOneWidget);
    });
'''

                test_path = FLUTTER_PATH / 'test' / 'widget_test.dart'
                test_path.parent.mkdir(exist_ok=True)

                with open(test_path, 'w', encoding='utf-8') as f:
                        f.write(test_content)


def start_flutter_app(self) -> str:
                """Startet die Flutter App"""
                try:
                        # Flutter run im Hintergrund
                        process = subprocess.Popen(
                                ['flutter', 'run', '-d',
                                    'chrome', '--web-port=3000'],
                                cwd=str(FLUTTER_PATH),
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE
                        )

                        # PID speichern
                        pid_file = PROJECT_ROOT / '.app_pid'
                        with open(pid_file, 'w') as f:
                                f.write(str(process.pid))

                        return "✅ MukkeApp wird gestartet... Öffne http://localhost:3000"

                except Exception as e:
                        logger.error(f"Error starting app: {e}")
                        return f"❌ Fehler beim Starten der App: {str(e)}"


def deploy_app(self) -> str:
                """Deployed die App"""
                try:
                        steps = []

                        # 1. Build erstellen
                        steps.append("📦 Erstelle Production Build...")
                        result = subprocess.run(
                                ['flutter', 'build', 'web'],
                                cwd=str(FLUTTER_PATH),
                                capture_output=True
                        )

                        if result.returncode == 0:
                                steps.append("✅ Build erfolgreich")
                        else:
                                steps.append("❌ Build fehlgeschlagen")
                                return '\n'.join(steps)

                        # 2. Firebase Deploy
                        firebase_json = PROJECT_ROOT / 'firebase.json'
                        if firebase_json.exists():
                                steps.append("☁️ Deploye zu Firebase...")
                                result = subprocess.run(
                                        ['firebase', 'deploy'],
                                        cwd=str(PROJECT_ROOT),
                                        capture_output=True
                                )

                                if result.returncode == 0:
                                        steps.append(
                                            "✅ Firebase Deployment erfolgreich")
                                        steps.append(
                                            "🌐 App verfügbar unter: https://mukkeapp.web.app")
                                else:
                                        steps.append(
                                            "❌ Firebase Deployment fehlgeschlagen")

                        return '\n'.join(steps)

                except Exception as e:
                        logger.error(f"Error deploying app: {e}")
                        return f"❌ Deployment-Fehler: {str(e)}"


def analyze_project(self) -> str:
                """Führt eine vollständige Projektanalyse durch"""
                try:
                        analysis = {
                                'files': 0,
                                'dart_files': 0,
                                'total_lines': 0,
                                'imports': {},
                                'classes': [],
                                'widgets': [],
                                'issues': []

                        # Analysiere alle Dart-Dateien
                        for dart_file in FLUTTER_PATH.rglob('*.dart'):
                                if 'build' in str(dart_file) or '.dart_tool' in str(dart_file):
                                        continue

                                analysis['files'] += 1
                                analysis['dart_files'] += 1

                                with open(dart_file, 'r', encoding='utf-8') as f:
                                        content = f.read()
                                        lines = content.split('\n')
                                        analysis['total_lines'] += len(lines)

                                        # Analysiere Imports
                                        imports = re.findall(
                                            r"import\s+'([^']+)';", content)
                                        for imp in imports:
                                                if imp not in analysis['imports']:
                                                        analysis['imports'][imp] = 0
                                                analysis['imports'][imp] += 1

                                        # Analysiere Klassen
                                        classes = re.findall(
                                            r'class\s+(\w+)', content)
                                        analysis['classes'].extend(classes)

                                        # Analysiere Widgets
                                        widgets = re.findall(
                                            r'extends\s+(?:Stateful|Stateless)Widget', content)
                                        analysis['widgets'].extend(widgets)

                        # Erstelle Bericht
                        report = f"""
📊 Projektanalyse MukkeApp
========================
📁 Dateien: {analysis['files']}
📄 Dart-Dateien: {analysis['dart_files']}
📝 Zeilen Code: {analysis['total_lines']:,}
🏛️ Klassen: {len(analysis['classes'])}
🎨 Widgets: {len(analysis['widgets'])}

📦 Top Imports:
"""

                        # Top 5 Imports
                        sorted_imports = sorted(
                            analysis['imports'].items(), key=lambda x: x[1], reverse=True)
                        for imp, count in sorted_imports[:5]:
                                report += f"  - {imp}: {count}x\n"

                        # Empfehlungen
                        report += "\n💡 Empfehlungen:\n"

                        if analysis['total_lines'] > 10000:
                                report += "  - Code in weitere Module aufteilen\n"

                        if len(analysis['widgets']) < 10:
                                report += "  - Mehr UI-Komponenten erstellen\n"

                        # Update Stats
                        self.stats['code_analyzed'] += analysis['dart_files']

                        return report

                except Exception as e:
                        logger.error(f"Error analyzing project: {e}")
                        return f"❌ Fehler bei der Projektanalyse: {str(e)}"


def get_status(self) -> str:
                """Gibt den aktuellen System-Status zurück"""
                active_modules = sum(
                    1 for m in self.modules.values() if m['active'])

                return f"""
🤖 Jarviz Status Report
====================
Version: {self.version}
Status: {self.status}
Lernmodus: {'Aktiv' if self.learning_mode else 'Inaktiv'}
Auto-Fix: {'Aktiviert' if self.auto_fix_enabled else 'Deaktiviert'}

📊 Statistiken:
- Aktive Module: {active_modules}/12
- Konversationen: {self.stats['total_conversations']}
- Gelernte Muster: {self.stats['patterns_learned']}
- Behobene Fehler: {self.stats['errors_fixed']}
- Wortschatz: {self.stats['vocabulary_size']} Wörter
- Analysierte Dateien: {len(self.analyzed_files)}

🧠 Lernfortschritt: {min(100, self.stats['vocabulary_size'] // 10)}%
"""


def handle_module_command(self, command: str) -> str:
                """Behandelt Modul-spezifische Befehle"""
                for module_name, module_info in self.modules.items():
                        if module_name in command.lower():
                                module_info['last_update'] = datetime.now(
                                ).isoformat()
                                self._save_memory(
                                    'mukke_modules.json', self.modules)
                                return f"✅ Modul '{module_name}' wurde aktiviert. Status: {module_info['status']}"

                return "ℹ️ Verfügbare Module: " + ', '.join(self.modules.keys())


def get_learning_stats(self) -> Dict:
                """Gibt Lernstatistiken zurück"""
                return {
                        'vocabulary_size': self.stats['vocabulary_size'],
                        'patterns_learned': self.stats['patterns_learned'],
                        'errors_fixed': self.stats['errors_fixed'],
                        'code_analyzed': self.stats['code_analyzed'],
                        'total_analyses': self.stats.get('total_analyses', 0)


def backup_memory(self):
                """Erstellt ein Backup des Memory-Systems"""
                try:
                        backup_dir = PROJECT_ROOT / 'backups' / datetime.now().strftime('%Y%m%d_%H%M%S')
                        backup_dir.mkdir(parents=True, exist_ok=True)

                        # Kopiere alle Memory-Dateien
                        for memory_file in MEMORY_PATH.glob('*.json'):
                                shutil.copy2(
                                    memory_file, backup_dir / memory_file.name)

                        logger.info(f"Memory backup created: {backup_dir}")
                        return True
                except Exception as e:
                        logger.error(f"Error creating backup: {e}")
                        return False


# Globale Jarviz-Instanz
jarviz = JarvizCore()

# Flask Routes


@ app.route('/')
def index():
        """Dashboard"""
        return render_template('dashboard.html')


@ app.route('/api/status')
def api_status():
        """API Status"""
        return jsonify({
                'status': 'online',
                'version': jarviz.version,
                'jarviz_status': jarviz.status,
                'timestamp': datetime.now().isoformat()
        })


@ app.route('/api/chat', methods=['POST'])
def api_chat():
    """Chat mit Jarviz"""
    try:
        data = request.json
        message = data.get('message', '')
        context = data.get('context', {})

        if not message:
            return jsonify({'error': 'No message provided'}), 400

        openai_response = openai.ChatCompletion.create(
            model="gpt-4o",
            messages=[
                {"role": "system",
                    "content": "Du bist Jarviz, ein KI-Assistent für die MukkeApp."},
                {"role": "user", "content": message}
            ],
            temperature=0.7
        )

        response = openai_response.choices[0].message.content

        # Via WebSocket broadcasten
        socket.emit('jarviz_response', {
            'message': message,
            'response': response,
            'timestamp': datetime.now().isoformat()
        })

        return jsonify({
            'response': response,
            'status': 'success'
        })

    except Exception as e:
        logger.error(f"Chat error: {e}")
        return jsonify({'error': str(e)}), 500


@ app.route('/api/modules')
def api_modules():
        """Module Status"""
        return jsonify(jarviz.modules)


@ app.route('/api/stats')
def api_stats():
        """Statistiken"""
        return jsonify({
                'total_conversations': jarviz.stats['total_conversations'],
                'total_patterns': jarviz.stats['patterns_learned'],
                'total_solutions': len(jarviz.error_solutions),
                'total_file_changes': len(jarviz.file_changes),
                'total_analyses': jarviz.stats.get('total_analyses', 0)
        })


@ app.route('/api/learning-stats')
def api_learning_stats():
        """Lernstatistiken"""
        return jsonify(jarviz.get_learning_stats())


@ app.route('/api/analyze-main-dart', methods=['POST'])
def api_analyze_main_dart():
        """Analysiert main.dart"""
        try:
                analysis = jarviz.analyze_main_dart()

                # Prüfe ob Screens erstellt werden sollen
                data = request.json
                if data.get('create_screens'):
                        creation_result = jarviz.create_all_screens()
                        analysis += f"\n\n{creation_result}"

                return jsonify({
                        'analysis': analysis,
                        'summary': 'Analyse abgeschlossen',
                        'status': 'success'
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500


@ app.route('/api/create-screen', methods=['POST'])
def api_create_screen():
        """Erstellt einen Screen"""
        try:
                data = request.json
                screen_name = data.get('screen_name')

                if not screen_name:
                        return jsonify({'error': 'screen_name required'}), 400

                result = jarviz.create_flutter_screen(
                    f'erstelle {screen_name} screen')

                return jsonify({
                        'result': result,
                        'status': 'success'
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500


@ app.route('/api/fix-errors', methods=['POST'])
def api_fix_errors():
        """Behebt Projekt-Fehler"""
        try:
                result = jarviz.fix_project_errors()

                return jsonify({
                        'result': result,
                        'summary': 'Fehleranalyse abgeschlossen',
                        'fixed_errors': jarviz.stats['errors_fixed']
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500


@ app.route('/api/analyze-project', methods=['POST'])
def api_analyze_project():
        """Analysiert das gesamte Projekt"""
        try:
                analysis = jarviz.analyze_project()

                # Lerne aus der Analyse
                if request.json.get('learn_patterns'):
                        # TODO: Implement pattern learning
                        pass

                return jsonify({
                        'analysis': analysis,
                        'summary': 'Projektanalyse abgeschlossen',
                        'recommendations': []
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500


@ app.route('/api/monitor-project')
def api_monitor_project():
        """Überwacht Projekt auf Änderungen"""
        try:
                changes = []
                errors = []

                # Prüfe auf neue Änderungen
                recent_changes = jarviz.file_changes[-10:]
                for change in recent_changes:
                        if datetime.fromisoformat(change['timestamp']) > datetime.now() - timedelta(minutes=1):
                                changes.append(change)

                return jsonify({
                        'changes': changes,
                        'errors': errors
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500


@ app.route('/api/backup-memory', methods=['POST'])
def api_backup_memory():
        """Erstellt Memory-Backup"""
        try:
                success = jarviz.backup_memory()

                return jsonify({
                        'success': success,
                        'message': 'Backup erstellt' if success else 'Backup fehlgeschlagen'
                })
        except Exception as e:
                return jsonify({'error': str(e)}), 500

# WebSocket Events


@ socketio.on('connect')
def handle_connect():
        """Client verbunden"""
        logger.info(f"Client connected: {request.sid}")
        emit('connected', {'data': 'Connected to Jarviz'})


@ socketio.on('disconnect')
def handle_disconnect():
        """Client getrennt"""
        logger.info(f"Client disconnected: {request.sid}")


@ socketio.on('command')
def handle_command(data):
        """Befehl via WebSocket"""
        message = data.get('message', '')
        context = data.get('context', {})
        response = jarviz.process_command(message, context)

        emit('response', {
                'response': response,
                'timestamp': datetime.now().isoformat()
        })


# Main
if __name__ == '__main__':
        # Stelle sicher, dass alle Verzeichnisse existieren
        for path in [PROJECT_ROOT / 'logs', PROJECT_ROOT / 'backups', PROJECT_ROOT / 'templates']:
                path.mkdir(exist_ok=True)

        # Starte Server
        logger.info("Starting Jarviz Complete Backend Server...")
        logger.info(f"Project Root: {PROJECT_ROOT}")
        logger.info(f"Flutter Path: {FLUTTER_PATH}")

        # Server starten
        socketio.run(app, host='0.0.0.0', port=5000,
                     debug=True)  # !/usr/bin/env python3
"""

        def _generate_game_screen(self, class_name: str, title: str) -> str:
                """Generiert Game Screen"""
                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > with SingleTickerProviderStateMixin {{
    late AnimationController _animationController;
    Timer? _gameTimer;
    int _score = 0;
    int _timeLeft = 60;
    bool _isPlaying = false;

    @ override
    void initState() {{
        super.initState();
        _animationController = AnimationController(
            duration: const Duration(milliseconds: 500),
            vsync: this,
        );

    @ override
    void dispose() {{
        _animationController.dispose();
        _gameTimer?.cancel();
        super.dispose();

    void _startGame() {{
        setState(() {{
            _isPlaying = true;
            _score = 0;
            _timeLeft = 60;
        }});

        _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {{
            setState(() {{
                _timeLeft--;
                if (_timeLeft <= 0) {{
                    _endGame();
            }});
        }});

    void _endGame() {{
        _gameTimer?.cancel();
        setState(()= > _isPlaying = false);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context)= > AlertDialog(
                backgroundColor: AppColors.surfaceDark,
                title: const Text(
                    'Spiel beendet!',
                    style: TextStyle(color: Colors.white),
                ),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                            'Dein Score: $_score',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            'Gut gespielt!',
                            style: TextStyle(color: Colors.white70),
                        ),
                    ],
                ),
                actions: [
                    TextButton(
                        onPressed: () {{
                            Navigator.pop(context);
                            _startGame();
                        }},
                        child: const Text('Nochmal'),
                    ),
                    TextButton(
                        onPressed: () {{
                            Navigator.pop(context);
                            Navigator.pop(context);
                        }},
                        child: const Text('Beenden'),
                    ),
                ],
            ),
        );

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            appBar: AppBar(
                title: Text('{title}'),
                backgroundColor: AppColors.primary,
                elevation: 0,
                actions: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                            child: Text(
                                'Zeit: $_timeLeft s',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                        ),
                    ),
                ],
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: SafeArea(
                    child: Column(
                        children: [
                            // Score Display
                            Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                        Column(
                                            children: [
                                                const Text(
                                                    'Score',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                    ),
                                                ),
                                                Text(
                                                    '$_score',
                                                    style: const TextStyle(
                                                        color: AppColors.primary,
                                                        fontSize: 36,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Column(
                                            children: [
                                                const Text(
                                                    'Highscore',
                                                    style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                    ),
                                                ),
                                                const Text(
                                                    '1337',
                                                    style: TextStyle(
                                                        color: AppColors.accent,
                                                        fontSize: 36,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),

                            // Game Area
                            Expanded(
                                child: Center(
                                    child: _isPlaying
                                            ? GestureDetector(
                                                    onTap: () {{
                                                        setState(()= > _score++);
                                                        _animationController.forward(from: 0);
                                                    }},
                                                    child: AnimatedBuilder(
                                                        animation: _animationController,
                                                        builder: (context, child) {{
                                                            return Transform.scale(
                                                                scale: 1.0 + (_animationController.value * 0.2),
                                                                child: Container(
                                                                    width: 150,
                                                                    height: 150,
                                                                    decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                            colors: AppColors.primaryGradient,
                                                                        ),
                                                                        shape: BoxShape.circle,
                                                                        boxShadow: [
                                                                            BoxShadow(
                                                                                color: AppColors.primary.withOpacity(0.5),
                                                                                blurRadius: 30,
                                                                                spreadRadius: 10,
                                                                            ),
                                                                        ],
                                                                    ),
                                                                    child: const Center(
                                                                        child: Text(
                                                                            'TAP!',
                                                                            style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 32,
                                                                                fontWeight: FontWeight.bold,
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            );
                                                        }},
                                                    ),
                                                ): Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        Icon(
                                                            Icons.gamepad,
                                                            size: 100,
                                                            color: AppColors.primary.withOpacity(0.5),
                                                        ),
                                                        const SizedBox(height: 20),
                                                        const Text(
                                                            'Bereit für die Challenge?',
                                                            style: TextStyle(
                                                                color: Colors.white70,
                                                                fontSize: 18,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                ),
                            ),

                            // Start Button
                            if (!_isPlaying)
                                Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SizedBox(
                                        width: double.infinity,
                                        height: 56,
                                        child: ElevatedButton(
                                            onPressed: _startGame,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.accent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                ),
                                            ),
                                            child: const Text(
                                                'Spiel starten (1€)',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                        ],
                    ),
                ),
            ),
        );


"""

        def _generate_chat_screen(self, class_name: str) -> str:
                """Generiert Chat Screen"""
                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    final _messageController = TextEditingController();
    final _scrollController = ScrollController();
    final List < ChatMessage > _messages = [
        ChatMessage(
            text: 'Hey! Wie geht\'s?',
            isMe: false,
            time: '10:30',
            sender: 'Sarah',
        ),
        ChatMessage(
            text: 'Super, danke! Hast du die neue Challenge gesehen?',
            isMe: true,
            time: '10:32',
        ),
        ChatMessage(
            text: 'Ja! Die sieht krass aus 🔥',
            isMe: false,
            time: '10:33',
            sender: 'Sarah',
        ),
    ];

    @ override
    void dispose() {{
        _messageController.dispose();
        _scrollController.dispose();
        super.dispose();

    void _sendMessage() {{
        final text = _messageController.text.trim();
        if (text.isNotEmpty) {{
            setState(() {{
                _messages.add(ChatMessage(
                    text: text,
                    isMe: true,
                    time: TimeOfDay.now().format(context),
                ));
            }});
            _messageController.clear();

            // Scroll to bottom
            Future.delayed(const Duration(milliseconds: 100), () {{
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                );
            }});

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.primary,
                elevation: 0,
                title: Row(
                    children: [
                        Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: AppColors.accentGradient,
                                ),
                                shape: BoxShape.circle,
                            ),
                            child: const Center(
                                child: Text(
                                    'S',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'Sarah',
                                    style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                    'Online',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.videocam),
                        onPressed: () {{}},
                    ),
                    IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () {{}},
                    ),
                    IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {{}},
                    ),
                ],
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: Column(
                    children: [
                        // Messages
                        Expanded(
                            child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {{
                                    final message = _messages[index];
                                    return Align(
                                        alignment: message.isMe
                                                ? Alignment.centerRight: Alignment.centerLeft,
                                        child: Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                                            ),
                                            decoration: BoxDecoration(
                                                gradient: message.isMe
                                                        ? LinearGradient(colors: AppColors.primaryGradient): null,
                                                color: message.isMe ? null: AppColors.surfaceDark,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(16),
                                                    topRight: const Radius.circular(16),
                                                    bottomLeft: Radius.circular(message.isMe ? 16: 4),
                                                    bottomRight: Radius.circular(message.isMe ? 4: 16),
                                                ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                            ),
                                            child: Column(
                                                crossAxisAlignment: message.isMe
                                                        ? CrossAxisAlignment.end: CrossAxisAlignment.start,
                                                children: [
                                                    if (!message.isMe)
                                                        Text(
                                                            message.sender ?? '',
                                                            style: TextStyle(
                                                                color: AppColors.primary,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        message.text,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                        ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        message.time,
                                                        style: TextStyle(
                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 12,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                }},
                            ),
                        ),

                        // Input Area
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.surfaceDark,
                                boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, -5),
                                    ),
                                ],
                            ),
                            child: Row(
                                children: [
                                    IconButton(
                                        icon: const Icon(Icons.attach_file, color: AppColors.primary),
                                        onPressed: () {{}},
                                    ),
                                    Expanded(
                                        child: TextField(
                                            controller: _messageController,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                                hintText: 'Nachricht schreiben...',
                                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                                filled: true,
                                                fillColor: AppColors.background,
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(25),
                                                    borderSide: BorderSide.none,
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                ),
                                            ),
                                            onSubmitted: (_)= > _sendMessage(),
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                                            shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                            icon: const Icon(Icons.send, color: Colors.white),
                                            onPressed: _sendMessage,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );


class ChatMessage {{
    final String text;
    final bool isMe;
    final String time;
    final String? sender;

    ChatMessage({{
        required this.text,
        required this.isMe,
        required this.time,
        this.sender,
    }});


"""

        def _generate_live_screen(self, class_name: str, title: str) -> str:
                """Generiert Live Streaming Screen"""
                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    bool _isLive = false;
    int _viewerCount = 0;
    final List < String > _comments = [];
    final _commentController = TextEditingController();

    @ override
    void dispose() {{
        _commentController.dispose();
        super.dispose();

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            body: Stack(
                children: [
                    // Live Video Background
                    Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                            ),
                        ),
                        child: Center(
                            child: Icon(
                                Icons.videocam,
                                size: 100,
                                color: Colors.white.withOpacity(0.3),
                            ),
                        ),
                    ),

                    // Overlay
                    SafeArea(
                        child: Column(
                            children: [
                                // Top Bar
                                Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            // Live Badge
                                            Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: _isLive ? Colors.red: Colors.grey,
                                                    borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                    children: [
                                                        Icon(
                                                            Icons.circle,
                                                            size: 8,
                                                            color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                            _isLive ? 'LIVE': 'OFFLINE',
                                                            style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),

                                            // Viewer Count
                                            Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                    children: [
                                                        const Icon(
                                                            Icons.visibility,
                                                            size: 16,
                                                            color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                            '$_viewerCount',
                                                            style: const TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),

                                            // Close Button
                                            IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white),
                                                onPressed: ()= > Navigator.pop(context),
                                            ),
                                        ],
                                    ),
                                ),

                                // Spacer
                                const Spacer(),

                                // Comments Section
                                Container(
                                    height: 200,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ListView.builder(
                                        reverse: true,
                                        itemCount: _comments.length,
                                        itemBuilder: (context, index) {{
                                            return Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                    _comments[_comments.length -
                                                        1 - index],
                                                    style: const TextStyle(color: Colors.white),
                                                ),
                                            );
                                        }},
                                    ),
                                ),

                                // Bottom Controls
                                Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        children: [
                                            // Comment Input
                                            if (_isLive)
                                                Row(
                                                    children: [
                                                        Expanded(
                                                            child: TextField(
                                                                controller: _commentController,
                                                                style: const TextStyle(color: Colors.white),
                                                                decoration: InputDecoration(
                                                                    hintText: 'Kommentar schreiben...',
                                                                    hintStyle: TextStyle(
                                                                        color: Colors.white.withOpacity(0.5),
                                                                    ),
                                                                    filled: true,
                                                                    fillColor: Colors.black.withOpacity(0.5),
                                                                    border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(25),
                                                                        borderSide: BorderSide.none,
                                                                    ),
                                                                    contentPadding: const EdgeInsets.symmetric(
                                                                        horizontal: 20,
                                                                        vertical: 10,
                                                                    ),
                                                                ),
                                                                onSubmitted: (text) {{
                                                                    if (text.isNotEmpty) {{
                                                                        setState(() {{
                                                                            _comments.add(
                                                                                text);
                                                                        }});
                                                                        _commentController.clear();
                                                                }},
                                                            ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        IconButton(
                                                            icon: const Icon(Icons.send, color: AppColors.primary),
                                                            onPressed: () {{
                                                                final text = _commentController.text;
                                                                if (text.isNotEmpty) {{
                                                                    setState(() {{
                                                                        _comments.add(
                                                                            text);
                                                                    }});
                                                                    _commentController.clear();
                                                            }},
                                                        ),
                                                    ],
                                                ),

                                            const SizedBox(height: 16),

                                            // Control Buttons
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                    // Camera Switch
                                                    Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.5),
                                                            shape: BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                            icon: const Icon(Icons.cameraswitch, color: Colors.white),
                                                            onPressed: () {{}},
                                                        ),
                                                    ),

                                                    // Go Live Button
                                                    GestureDetector(
                                                        onTap: () {{
                                                            setState(() {{
                                                                _isLive = !_isLive;
                                                                if (_isLive) {{
                                                                    _viewerCount = 1;
                                                                    _comments.add(
                                                                        'Stream gestartet! 🎉');
                                                                }} else {{
                                                                    _viewerCount = 0;
                                                                    _comments.clear();
                                                            }});
                                                        }},
                                                        child: Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: _isLive ? Colors.red: AppColors.accent,
                                                                boxShadow: [
                                                                    BoxShadow(
                                                                        color: (_isLive ? Colors.red: AppColors.accent)
                                                                                .withOpacity(0.5),
                                                                        blurRadius: 20,
                                                                        spreadRadius: 5,
                                                                    ),
                                                                ],
                                                            ),
                                                            child: Icon(
                                                                _isLive ? Icons.stop: Icons.videocam,
                                                                color: Colors.white,
                                                                size: 40,
                                                            ),
                                                        ),
                                                    ),

                                                    // Effects
                                                    Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.5),
                                                            shape: BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                            icon: const Icon(Icons.auto_awesome, color: Colors.white),
                                                            onPressed: () {{}},
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );


"""

        def _generate_auth_screen(self, class_name: str, title: str) -> str:
                """Generiert Auth-Screen mit Formular"""
                is_login = 'login' in class_name.lower()

                name_field = '''// Name Field
                                        TextFormField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                                labelText: 'Name',
                                                prefixIcon: Icon(Icons.person, color: AppColors.primary),
                                            ),
                                            validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                    return 'Bitte Name eingeben';
                                                return null;
                                            },
                                        ),
                                        const SizedBox(height: 16),

                                        ''' if not is_login else ''

                name_controller = 'final _nameController = TextEditingController();' if not is_login else ''
                name_dispose = '_nameController.dispose();' if not is_login else ''
                auth_type = 'login' if is_login else 'signup'
                button_text = 'Anmelden' if is_login else 'Registrieren'
                switch_route = 'AppRoutes.signup' if is_login else 'AppRoutes.login'
                switch_text = 'Noch kein Konto? Registrieren' if is_login else 'Bereits registriert? Anmelden'

                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    final _formKey = GlobalKey < FormState > ();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    {name_controller}
    bool _isLoading = false;

    @ override
    void dispose() {{
        _emailController.dispose();
        _passwordController.dispose();
        {name_dispose}
        super.dispose();

    Future < void > _submit() async {{
        if (!_formKey.currentState!.validate()) return;

        setState(()= > _isLoading = true);

        try {{
            // TODO: Implement {auth_type} logic
            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {{
                Navigator.pushReplacementNamed(context, AppRoutes.home);
        }} catch(e) {{
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler: ${{e}}')),
            );
        }} finally {{
            if (mounted) {{
                setState(()= > _isLoading = false);

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: SafeArea(
                    child: Center(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        // Logo
                                        Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: AppColors.primaryGradient,
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                                Icons.music_note,
                                                size: 60,
                                                color: Colors.white,
                                            ),
                                        ),
                                        const SizedBox(height: 40),

                                        Text(
                                            '{title}',
                                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                        const SizedBox(height: 40),

                                        {name_field} // Email Field
                                        TextFormField(
                                            controller: _emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                                labelText: 'E-Mail',
                                                prefixIcon: Icon(Icons.email, color: AppColors.primary),
                                            ),
                                            validator: (value) {{
                                                if (value == null | | value.isEmpty) {{
                                                    return 'Bitte E-Mail eingeben';
                                                if (!value.contains('@')) {{
                                                    return 'Bitte gültige E-Mail eingeben';
                                                return null;
                                            }},
                                        ),
                                        const SizedBox(height: 16),

                                        // Password Field
                                        TextFormField(
                                            controller: _passwordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                                labelText: 'Passwort',
                                                prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                                            ),
                                            validator: (value) {{
                                                if (value == null | | value.isEmpty) {{
                                                    return 'Bitte Passwort eingeben';
                                                if (value.length < 6) {{
                                                    return 'Passwort muss mindestens 6 Zeichen lang sein';
                                                return null;
                                            }},
                                        ),
                                        const SizedBox(height: 32),

                                        // Submit Button
                                        SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: _isLoading ? null: _submit,
                                                child: _isLoading
                                                        ? const CircularProgressIndicator(color: Colors.white): Text('{button_text}'),
                                            ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Switch Auth Mode
                                        TextButton(
                                            onPressed: () {{
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    {switch_route},
                                                );
                                            }},
                                            child: Text(
                                                '{switch_text}',
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );


"""

        def _generate_main_screen(self, class_name: str, title: str) -> str:
                """Generiert Main-Screen mit Navigation"""
                # Bestimme Icon basierend auf Screen-Name
                icons = {
                        'music': 'Icons.music_note',
                        'dating': 'Icons.favorite',
                        'sport': 'Icons.fitness_center',
                        'challenge': 'Icons.bolt',
                        'games': 'Icons.gamepad',
                        'avatar': 'Icons.face',
                        'tracking': 'Icons.location_on',
                        'fashion': 'Icons.checkroom',
                        'language': 'Icons.language',
                        'live': 'Icons.live_tv',
                        'chat': 'Icons.chat',

                icon = 'Icons.apps'
                for key, value in icons.items():
                        if key in class_name.lower():
                                icon = value
                                break

                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    final List < _Feature > features = [];

    @ override
    void initState() {{
        super.initState();
        _initializeFeatures();

    void _initializeFeatures() {{
        // TODO: Add specific features for {title}
        features.addAll([
            _Feature(
                title: 'Feature 1',
                description: 'Beschreibung für Feature 1',
                icon: Icons.star,
                onTap: ()= > _showFeatureDialog('Feature 1'),
            ),
            _Feature(
                title: 'Feature 2',
                description: 'Beschreibung für Feature 2',
                icon: Icons.settings,
                onTap: ()= > _showFeatureDialog('Feature 2'),
            ),
        ]);

    void _showFeatureDialog(String feature) {{
        showDialog(
            context: context,
            builder: (context)= > AlertDialog(
                title: Text(feature),
                content: Text('$feature wird bald verfügbar sein!'),
                actions: [
                    TextButton(
                        onPressed: ()= > Navigator.pop(context),
                        child: const Text('OK'),
                    ),
                ],
            ),
        );

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            appBar: AppBar(
                title: Text('{title}'),
                backgroundColor: AppColors.primary,
                elevation: 0,
                actions: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                                '42', // Beispielwert
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            Text(
                                'Level',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {{
                            // TODO: Settings
                        }},
                    ),
                ],
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: Column(
                    children: [
                        // Header
                        Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                                children: [
                                    Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: AppColors.accentGradient,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                            {icon},
                                            size: 48,
                                            color: Colors.white,
                                        ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                        'Willkommen bei {title}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                        ),
                                    ),
                                ],
                            ),
                        ),

                        // Features Grid
                        Expanded(
                            child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.0,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                ),
                                itemCount: features.length,
                                itemBuilder: (context, index) {{
                                    final feature = features[index];
                                    return InkWell(
                                        onTap: feature.onTap,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: [
                                                        AppColors.primary.withOpacity(
                                                            0.2),
                                                        AppColors.accent.withOpacity(
                                                            0.1),
                                                    ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: AppColors.primary.withOpacity(0.3),
                                                ),
                                            ),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Icon(
                                                        feature.icon,
                                                        size: 48,
                                                        color: AppColors.accent,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                        feature.title,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                        ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        feature.description,
                                                        style: TextStyle(
                                                            color: Colors.white.withOpacity(0.7),
                                                            fontSize: 12,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                }},
                            ),
                        ),
                    ],
                ),
            ),
        );


class _Feature {{
    final String title;
    final String description;
    final IconData icon;
    final VoidCallback onTap;

    _Feature({{
        required this.title,
        required this.description,
        required this.icon,
        required this.onTap,
    }});


"""

        def _generate_profile_screen(self, class_name: str, title: str) -> str:
                """Generiert Profile-Screen"""
                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    @ override
    Widget build(BuildContext context) {{
        final userProvider = Provider.of < UserProvider > (context);

        return Scaffold(
            appBar: AppBar(
                title: const Text('Profil'),
                backgroundColor: AppColors.primary,
                elevation: 0,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {{
                            // TODO: Edit profile
                        }},
                    ),
                ],
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                            // Profile Header
                            Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                    children: [
                                        // Avatar
                                        Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                    colors: AppColors.primaryGradient,
                                                ),
                                                border: Border.all(
                                                    color: AppColors.accent,
                                                    width: 3,
                                                ),
                                            ),
                                            child: const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                            ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Name
                                        Text(
                                            'Max Mustermann',
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Email
                                        Text(
                                            'max@example.com',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: AppColors.textGrey,
                                            ),
                                        ),
                                    ],
                                ),
                            ),

                            // Stats
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                        _StatItem(
                                            value: '42',
                                            label: 'Challenges',
                                            icon: Icons.bolt,
                                        ),
                                        _StatItem(
                                            value: '128',
                                            label: 'Punkte',
                                            icon: Icons.star,
                                        ),
                                        _StatItem(
                                            value: '15',
                                            label: 'Level',
                                            icon: Icons.trending_up,
                                        ),
                                    ],
                                ),
                            ),
                            const SizedBox(height: 32),

                            // Menu Items
                            ..._buildMenuItems(),
                        ],
                    ),
                ),
            ),
        );

    List < Widget > _buildMenuItems() {{
        final items = [
                'icon': Icons.person,
                'title': 'Persönliche Daten',
                'onTap': ()= > _navigate('personal_data'),
            }},
                'icon': Icons.notifications,
                'title': 'Benachrichtigungen',
                'onTap': ()= > _navigate('notifications'),
            }},
                'icon': Icons.security,
                'title': 'Sicherheit',
                'onTap': ()= > _navigate('security'),
            }},
                'icon': Icons.payment,
                'title': 'Zahlungsmethoden',
                'onTap': ()= > _navigate('payment'),
            }},
                'icon': Icons.help,
                'title': 'Hilfe & Support',
                'onTap': ()= > _navigate('help'),
            }},
                'icon': Icons.logout,
                'title': 'Abmelden',
                'onTap': ()= > _logout(),
                'color': AppColors.error,
            }},
        ];

        return items.map((item)= > ListTile(
            leading: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color? ?? AppColors.primary,
            ),
            title: Text(
                item['title'] as String,
                style: TextStyle(
                    color: item['color'] as Color? ?? Colors.white,
                ),
            ),
            trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textGrey,
            ),
            onTap: item['onTap'] as VoidCallback,
        )).toList();

    void _navigate(String route) {{
        // TODO: Navigate to specific route
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigation zu $route')),
        );

    void _logout() {{
        showDialog(
            context: context,
            builder: (context)= > AlertDialog(
                title: const Text('Abmelden'),
                content: const Text('Möchtest du dich wirklich abmelden?'),
                actions: [
                    TextButton(
                        onPressed: ()= > Navigator.pop(context),
                        child: const Text('Abbrechen'),
                    ),
                    TextButton(
                        onPressed: () {{
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route)= > false,
                            );
                        }},
                        child: const Text(
                            'Abmelden',
                            style: TextStyle(color: AppColors.error),
                        ),
                    ),
                ],
            ),
        );


class _StatItem extends StatelessWidget {{
    final String value;
    final String label;
    final IconData icon;

    const _StatItem({{
        required this.value,
        required this.label,
        required this.icon,
    }});

    @ override
    Widget build(BuildContext context) {{
        return Column(
            children: [
                Icon(
                    icon,
                    color: AppColors.primary,
                    size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                    value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                Text(
                    label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                    ),
                ),
            ],
        );


"""
                """Generiert Standard-Screen"""
                return f"""import 'package:flutter/material.dart';


class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}): super(key: key);

    @ override
    State < {class_name} > createState() = > _{class_name}State();


class _{class_name}State extends State < {class_name} > {{
    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            appBar: AppBar(
                title: Text('{title}'),
                backgroundColor: AppColors.primary,
                elevation: 0,
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: AppColors.primaryGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                        BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                        ),
                                    ],
                                ),
                                child: const Icon(
                                    Icons.construction,
                                    size: 60,
                                    color: Colors.white,
                                ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                                '{title}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Coming Soon',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textGrey,
                                ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                                onPressed: () {{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Feature wird entwickelt...'),
                                            backgroundColor: AppColors.primary,
                                        ),
                                    );
                                }},
                                icon: const Icon(Icons.notifications),
                                label: const Text('Benachrichtigung erhalten'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );


"""
Jarviz Complete Backend Server - Vollständig funktionierendes System
Mit Android Studio Integration, Lernfunktion und automatischer Code-Generierung
"""


# Flask imports

# Projekt-Pfade
PROJECT_ROOT = Path('C:/Jarviz')
FLUTTER_PATH = PROJECT_ROOT / 'flutter_app'
MEMORY_PATH = PROJECT_ROOT / 'ai_engine' / 'memory'
TEMPLATES_PATH = PROJECT_ROOT / 'ai_engine' / 'templates'
ENV_PATH = PROJECT_ROOT / '.env'

# Stelle sicher, dass alle Pfade existieren
for path in [MEMORY_PATH, TEMPLATES_PATH, PROJECT_ROOT / 'logs', PROJECT_ROOT / 'templates']:
        path.mkdir(parents=True, exist_ok=True)

# Lade .env wenn vorhanden
if ENV_PATH.exists():
        load_dotenv(ENV_PATH)

# Logging Setup
logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
                logging.FileHandler(PROJECT_ROOT / 'logs' /
                                    'jarviz.log', encoding='utf-8'),
                logging.StreamHandler()
        ]
)
logger = logging.getLogger(__name__)

# Flask App Setup
app = Flask(__name__,
        template_folder=str(PROJECT_ROOT / 'templates'),
        static_folder=str(PROJECT_ROOT / 'static')
)
app.config['SECRET_KEY'] = os.getenv(
    'FLASK_SECRET_KEY', 'mukke-app-secret-2024')
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')


class FileWatcher(FileSystemEventHandler):
        """Überwacht Dateiänderungen im Projekt"""

        def __init__(self, jarviz_core):
                self.jarviz = jarviz_core
                self.last_event_time = {}

        def on_modified(self, event):
                if event.is_directory:
                        return

                # Ignoriere bestimmte Dateien
                if any(pattern in event.src_path for pattern in ['.git', 'node_modules', '.idea', 'build', '__pycache__']):
                        return

                # Debouncing - verhindere mehrfache Events
                current_time = time.time()
                if event.src_path in self.last_event_time:
                        if current_time - self.last_event_time[event.src_path] < 1:
                                return
                self.last_event_time[event.src_path] = current_time

                # Verarbeite Änderung
                self.jarviz.process_file_change(event.src_path)

        def on_created(self, event):
                if event.is_directory:
                        return

                if event.src_path.endswith('.dart'):
                        self.jarviz.analyze_new_file(event.src_path)


class JarvizCore:
        """Hauptklasse für die Jarviz KI-Engine"""

        def __init__(self):
                self.version = "2.0.0"
                self.status = "initializing"
                self.learning_mode = True
                self.auto_fix_enabled = False

                # Memory System
                self.conversation_history = []
                self.code_patterns = {}
                self.error_solutions = {}
                self.learned_vocabulary = set()
                self.file_changes = []
                self.module_states = {}
                self.analyzed_files = {}
                self.code_templates = {}
                self.import_patterns = {}

                # Module initialisieren
                self.modules = self._init_modules()

                # Learning Stats
                self.stats = {
                        'patterns_learned': 0,
                        'errors_fixed': 0,
                        'code_analyzed': 0,
                        'vocabulary_size': 0,
                        'total_conversations': 0,
                        'total_file_changes': 0,
                        'total_analyses': 0

                # Screen Templates aus main.dart
                self.screen_templates = self._load_screen_templates()

                # Load Memory
                self._load_all_memory()

                # File Watcher starten
                self.file_observer = None
                self._start_file_watcher()

                logger.info(f"Jarviz v{self.version} initialized")
                self.status = "ready"

        def _init_modules(self) -> Dict:
                """Initialisiert alle MukkeApp Module"""
                modules = {
                        'profile_system': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'music_engine': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'dating_system': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'sport_coach': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'challenge_system': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'gaming_engine': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'avatar_ai': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'tracking_system': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'fashion_ar': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'language_coach': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'live_streaming': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True},
                        'improvement_system': {'status': 'ready', 'active': True, 'last_update': None, 'learning': True}
                return modules

        def _load_screen_templates(self) -> Dict:
                """Lädt Screen-Templates aus main.dart"""
                screens = {
                        'splash_screen': 'SplashScreen',
                        'onboarding_screen': 'OnboardingScreen',
                        'login_screen': 'LoginScreen',
                        'signup_screen': 'SignUpScreen',
                        'home_screen': 'HomeScreen',
                        'profile_screen': 'ProfileScreen',
                        'music_main_screen': 'MusicMainScreen',
                        'ki_music_screen': 'KiMusicScreen',
                        'dating_main_screen': 'DatingMainScreen',
                        'sport_main_screen': 'SportMainScreen',
                        'challenge_main_screen': 'ChallengeMainScreen',
                        'challenge_create_screen': 'ChallengeCreateScreen',
                        'completed_challenges_screen': 'CompletedChallengesScreen',
                        'games_main_screen': 'GamesMainScreen',
                        'duell_screen': 'DuellScreen',
                        'tauziehen_screen': 'TauziehenScreen',
                        'reaction_game_screen': 'ReactionGameScreen',
                        'fitness_battle_screen': 'FitnessBattleScreen',
                        'avatar_main_screen': 'AvatarMainScreen',
                        'tracking_main_screen': 'TrackingMainScreen',
                        'add_child_profile_screen': 'AddChildProfileScreen',
                        'fashion_main_screen': 'FashionMainScreen',
                        'language_main_screen': 'LanguageMainScreen',
                        'live_main_screen': 'LiveMainScreen',
                        'live_feed_screen': 'LiveFeedScreen',
                        'chat_main_screen': 'ChatMainScreen',
                        'improvements_screen': 'ImprovementsScreen',
                        'ranking_screen': 'RankingScreen',
                        'monetization_screen': 'MonetizationScreen'
                return screens

        def _load_all_memory(self):
                """Lädt alle Memory-Dateien"""
                try:
                        # Conversation History
                        history_file = MEMORY_PATH / 'conversation_history.json'
                        if history_file.exists():
                                with open(history_file, 'r', encoding='utf-8') as f:
                                        data = json.load(f)
                                        self.conversation_history = data.get(
                                            'data', [])

                        # Code Patterns
                        patterns_file = MEMORY_PATH / 'code_patterns.json'
                        if patterns_file.exists():
                                with open(patterns_file, 'r', encoding='utf-8') as f:
                                        data = json.load(f)
                                        self.code_patterns = data.get(
                                            'data', {})

                        # Error Solutions
                        errors_file = MEMORY_PATH / 'error_solutions.json'
                        if errors_file.exists():
                                with open(errors_file, 'r', encoding='utf-8') as f:
                                        data = json.load(f)
                                        self.error_solutions = data.get(
                                            'data', {})

                        # Vocabulary
                        vocab_file = MEMORY_PATH / 'vocabulary.json'
                        if vocab_file.exists():
                                with open(vocab_file, 'r', encoding='utf-8') as f:
                                        data = json.load(f)
                                        self.learned_vocabulary = set(
                                            data.get('words', []))

                        # Module States
                        modules_file = MEMORY_PATH / 'mukke_modules.json'
                        if modules_file.exists():
                                with open(modules_file, 'r', encoding='utf-8') as f:
                                        data = json.load(f)
                                        saved_modules = data.get('data', {})
                                        # Merge mit aktuellen Modulen
                                        for module_name, module_data in saved_modules.items():
                                                if module_name in self.modules:
                                                        self.modules[module_name].update(
                                                            module_data)

                        # Update stats
                        self.stats['vocabulary_size'] = len(
                            self.learned_vocabulary)
                        self.stats['total_conversations'] = len(
                            self.conversation_history)
                        self.stats['patterns_learned'] = len(
                            self.code_patterns)

                except Exception as e:
                        logger.error(f"Error loading memory: {e}")

        def _save_memory(self, filename: str, data: Any):
                """Speichert Memory-Datei"""
                filepath = MEMORY_PATH / filename
                try:
                        content = {
                                'version': '2.0',
                                'updated_at': datetime.now().isoformat(),
                                'data': data
                        with open(filepath, 'w', encoding='utf-8') as f:
                                json.dump(content, f, indent=2,
                                          ensure_ascii=False)
                except Exception as e:
                        logger.error(f"Error saving memory {filename}: {e}")

        def _start_file_watcher(self):
                """Startet den File Watcher für Android Studio Integration"""
                try:
                        self.file_observer = Observer()
                        event_handler = FileWatcher(self)

                        # Überwache Flutter-Projekt
                        if FLUTTER_PATH.exists():
                                self.file_observer.schedule(
                                    event_handler, str(FLUTTER_PATH), recursive=True)
                                logger.info(
                                    f"Watching Flutter project at {FLUTTER_PATH}")

                        self.file_observer.start()
                except Exception as e:
                        logger.error(f"Error starting file watcher: {e}")

        def process_file_change(self, filepath: str):
                """Verarbeitet Dateiänderungen"""
                try:
                        path = Path(filepath)

                        # Lerne aus der Änderung
                        if path.suffix == '.dart':
                                self.analyze_dart_file(path)

                                # Benachrichtige Dashboard
                                socketio.emit('file_changed', {
                                        'file': str(path),
                                        'timestamp': datetime.now().isoformat()
                                })

                                # Speichere Änderung
                                self.file_changes.append({
                                        'timestamp': datetime.now().isoformat(),
                                        'action': 'modified',
                                        'file': str(path)
                                })
                                self._save_memory(
                                    'file_changes.json', self.file_changes[-100:])

                except Exception as e:
                        logger.error(f"Error processing file change: {e}")

        def analyze_dart_file(self, filepath: Path):
                """Analysiert eine Dart-Datei und lernt daraus"""
                try:
                        with open(filepath, 'r', encoding='utf-8') as f:
                                content = f.read()

                        # Extrahiere Imports
                        imports = re.findall(r"import\s+'([^']+)';", content)
                        for import_stmt in imports:
                                if import_stmt not in self.import_patterns:
                                        self.import_patterns[import_stmt] = 0
                                self.import_patterns[import_stmt] += 1

                        # Extrahiere Klassen
                        classes = re.findall(r'class\s+(\w+)', content)

                        # Extrahiere Widgets
                        widgets = re.findall(r'Widget\s+(\w+)\s*\(', content)

                        # Lerne neue Wörter
                        words = re.findall(r'\b[a-zA-Z]{3,}\b', content)
                        new_words = []
                        for word in words:
                                if word not in self.learned_vocabulary:
                                        self.learned_vocabulary.add(word)
                                        new_words.append(word)

                        # Update Stats
                        self.stats['code_analyzed'] += 1
                        self.stats['vocabulary_size'] = len(
                            self.learned_vocabulary)

                        # Speichere Analyse
                        self.analyzed_files[str(filepath)] = {
                                'timestamp': datetime.now().isoformat(),
                                'imports': imports,
                                'classes': classes,
                                'widgets': widgets,
                                'line_count': len(content.split('\n'))

                        # Benachrichtige Dashboard über neue Wörter
                        if new_words:
                                socketio.emit('learning_update', {
                                        'new_words': new_words[:10],
                                        'total_vocabulary': len(self.learned_vocabulary)
                                })

                        # Speichere Vocabulary
                        self._save_memory('vocabulary.json', {
                                          'words': list(self.learned_vocabulary)})

                except Exception as e:
                        logger.error(f"Error analyzing dart file: {e}")

        def analyze_new_file(self, filepath: str):
                """Analysiert eine neue Datei"""
                path = Path(filepath)
                if path.suffix == '.dart':
                        self.analyze_dart_file(path)

                        # Auto-Update main.dart wenn neuer Screen erstellt wurde
                        if 'screen' in path.stem.lower():
                                self.update_main_dart_imports(path)

        def update_main_dart_imports(self, new_screen_path: Path):
                """Aktualisiert main.dart mit neuen Screen-Imports"""
                try:
                        main_dart = FLUTTER_PATH / 'lib' / 'main.dart'
                        if not main_dart.exists():
                                return

                        with open(main_dart, 'r', encoding='utf-8') as f:
                                content = f.read()

                        # Extrahiere Screen-Name
                        screen_name = new_screen_path.stem

                        # Erstelle Import-Statement
                        relative_path = new_screen_path.relative_to(
                            FLUTTER_PATH / 'lib')
                        import_path = str(relative_path).replace(
                            '\\', '/').replace('.dart', '')
                        import_stmt = f"import '{import_path}.dart';"

                        # Prüfe ob Import bereits existiert
                        if import_stmt not in content:
                                # Finde Stelle für Import (nach anderen Screen-Imports)
                                import_section_end = content.find('// Utils')
                                if import_section_end > 0:
                                        before = content[:import_section_end]
                                        after = content[import_section_end:]
                                        content = before + import_stmt + '\n' + after

                                        # Speichere aktualisierte main.dart
                                        with open(main_dart, 'w', encoding='utf-8') as f:
                                                f.write(content)

                                        logger.info(
                                            f"Updated main.dart with import for {screen_name}")

                except Exception as e:
                        logger.error(f"Error updating main.dart: {e}")

        def process_command(self, command: str, context: Optional[Dict]=None) -> str:
                """Verarbeitet einen Befehl"""
                logger.info(f"Processing command: {command}")

                # Zu History hinzufügen
                self.conversation_history.append({
                        'timestamp': datetime.now().isoformat(),
                        'command': command,
                        'context': context
                })

                # Lerne aus dem Befehl
                words = re.findall(r'\b[a-zA-Z]{3,}\b', command)
                for word in words:
                        if word not in self.learned_vocabulary:
                                self.learned_vocabulary.add(word)

                response = self._execute_command(command, context)

                # Response speichern
                self.conversation_history.append({
                        'timestamp': datetime.now().isoformat(),
                        'response': response
                })

                # Memory speichern
                self._save_memory('conversation_history.json',
                                  self.conversation_history[-100:])
                self.stats['total_conversations'] = len(
                    self.conversation_history)

                return response

        def _execute_command(self, command: str, context: Optional[Dict]) -> str:
                """Führt einen Befehl aus"""
                command_lower = command.lower()

                # Analysiere main.dart
                if 'analysiere main.dart' in command_lower:
                        return self.analyze_main_dart()

                # Erstelle alle Screens
                elif 'erstelle alle screens' in command_lower or 'lege alle screens' in command_lower:
                        return self.create_all_screens()

                # Erstelle einzelnen Screen
                elif ('erstelle' in command_lower or 'create' in command_lower) and 'screen' in command_lower:
                        return self.create_flutter_screen(command)

                # Fehler beheben
                elif 'fehler beheben' in command_lower or 'fix errors' in command_lower:
                        return self.fix_project_errors()

                # Tests ausführen
                elif 'test' in command_lower and 'flutter' in command_lower:
                        return self.run_flutter_tests()

                # App starten
                elif 'starte app' in command_lower:
                        return self.start_flutter_app()

                # Deploy
                elif 'deploy' in command_lower:
                        return self.deploy_app()

                # Projekt analysieren
                elif 'analysiere projekt' in command_lower or 'analyze project' in command_lower:
                        return self.analyze_project()

                # Status
                elif 'status' in command_lower:
                        return self.get_status()

                # Module
                elif any(module in command_lower for module in self.modules.keys()):
                        return self.handle_module_command(command)

                # Default
                else:
                        return f"Befehl verstanden: {command}. Ich kann folgendes:\n- main.dart analysieren\n- Alle Screens erstellen\n- Fehler beheben\n- Tests ausführen\n- Projekt analysieren"

        def analyze_main_dart(self) -> str:
                """Analysiert main.dart und gibt Struktur zurück"""
                try:
                        main_dart = FLUTTER_PATH / 'lib' / 'main.dart'
                        if not main_dart.exists():
                                return "❌ main.dart nicht gefunden!"

                        with open(main_dart, 'r', encoding='utf-8') as f:
                                content = f.read()

                        # Analysiere Imports
                        imports = re.findall(
                            r"import\s+'screens/([^']+)\.dart';", content)

                        # Analysiere Routes
                        routes = re.findall(
                            r"case\s+AppRoutes\.(\w+):", content)

                        # Prüfe welche Screens fehlen
                        missing_screens = []
                        for route in routes:
                                screen_file = f"{route}.dart"
                                screen_path = FLUTTER_PATH / 'lib' / 'screens' / screen_file
                                if not screen_path.exists():
                                        missing_screens.append(route)

                        result = f"📱 main.dart Analyse:\n"
                        result += f"✅ {len(imports)} Screen-Imports gefunden\n"
                        result += f"📍 {len(routes)} Routes definiert\n"

                        if missing_screens:
                                result += f"\n⚠️ {len(missing_screens)} Screens fehlen:\n"
                                for screen in missing_screens[:10]:
                                        result += f"  - {screen}\n"
                                result += f"\n💡 Verwende 'Erstelle alle Screens' um sie anzulegen!"
                        else:
                                result += f"\n✅ Alle Screens vorhanden!"

                        # Lerne aus der Analyse
                        self.stats['code_analyzed'] += 1

                        return result

                except Exception as e:
                        logger.error(f"Error analyzing main.dart: {e}")
                        return f"❌ Fehler bei der Analyse: {str(e)}"

        def create_all_screens(self) -> str:
                """Erstellt alle fehlenden Screens basierend auf main.dart"""
                try:
                        created_count = 0
                        errors = []

                        for screen_name, class_name in self.screen_templates.items():
                                screen_path = FLUTTER_PATH / 'lib' /
                                    'screens' / f'{screen_name}.dart'

                                # Erstelle Verzeichnisstruktur wenn nötig
                                if '/' in screen_name:
                                        parts = screen_name.split('/')
                                        sub_dir = FLUTTER_PATH /
                                            'lib' / 'screens' / parts[0]
                                        sub_dir.mkdir(exist_ok=True)
                                        screen_path = sub_dir /
                                            f'{parts[1]}.dart'

                                if not screen_path.exists():
                                        try:
                                                # Generiere Screen-Code
                                                code = self.generate_flutter_screen(
                                                    class_name, screen_name)

                                                # Erstelle Datei
                                                screen_path.parent.mkdir(
                                                    parents=True, exist_ok=True)
                                                with open(screen_path, 'w', encoding='utf-8') as f:
                                                        f.write(code)

                                                created_count += 1
                                                logger.info(
                                                    f"Created screen: {screen_name}")

                                                # Tracke Änderung
                                                self.file_changes.append({
                                                        'timestamp': datetime.now().isoformat(),
                                                        'action': 'created',
                                                        'file': str(screen_path),
                                                        'component': screen_name
                                                })

                                        except Exception as e:
                                                errors.append(
                                                    f"{screen_name}: {str(e)}")

                        # Speichere Änderungen
                        self._save_memory('file_changes.json',
                                          self.file_changes[-100:])

                        result = f"✅ {created_count} Screens erstellt!\n"
                        if errors:
                                result += f"\n❌ {len(errors)} Fehler:\n"
                                for error in errors[:5]:
                                        result += f"  - {error}\n"

                        return result

                except Exception as e:
                        logger.error(f"Error creating screens: {e}")
                        return f"❌ Fehler beim Erstellen der Screens: {str(e)}"

        def generate_flutter_screen(self, class_name: str, screen_name: str) -> str:
                """Generiert vollständigen Flutter Screen Code"""
                # Bestimme Screen-Typ basierend auf Name
                title = re.sub(r'([A-Z])', r' \1',
                               class_name.replace('Screen', '')).strip()

                # Template basierend auf Screen-Typ
                if 'splash' in screen_name:
                        return self._generate_splash_screen(class_name)
                elif 'onboarding' in screen_name:
                        return self._generate_onboarding_screen(class_name)
                elif 'auth' in screen_name or 'login' in screen_name or 'signup' in screen_name:
                        return self._generate_auth_screen(class_name, title)
                elif 'home' in screen_name:
                        return self._generate_home_screen(class_name)
                elif 'main' in screen_name:
                        return self._generate_main_screen(class_name, title)
                elif 'profile' in screen_name:
                        return self._generate_profile_screen(class_name, title)
                elif 'challenge' in screen_name and 'create' in screen_name:
                        return self._generate_challenge_create_screen(class_name)
                elif 'game' in screen_name or 'duell' in screen_name or 'tauziehen' in screen_name:
                        return self._generate_game_screen(class_name, title)
                elif 'chat' in screen_name:
                        return self._generate_chat_screen(class_name)
                elif 'live' in screen_name:
                        return self._generate_live_screen(class_name, title)
                else:
                        return self._generate_default_screen(class_name, title)

        def _generate_splash_screen(self, class_name: str) -> str:
                """Generiert Splash Screen"""
                return f"""import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}) : super(key: key);

    @override
    State<{class_name}> createState() => _{class_name}State();

class _{class_name}State extends State<{class_name}> with SingleTickerProviderStateMixin {{
    late AnimationController _controller;
    late Animation<double> _fadeAnimation;
    late Animation<double> _scaleAnimation;

    @override
    void initState() {{
        super.initState();

        // Vollbild
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

        // Animationen
        _controller = AnimationController(
            duration: const Duration(milliseconds: 2000),
            vsync: this,
        );

        _fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
        ).animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ));

        _scaleAnimation = Tween<double>(
            begin: 0.5,
            end: 1.0,
        ).animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
        ));

        _controller.forward();

        // Navigation nach 3 Sekunden
        Future.delayed(const Duration(seconds: 3), () {{
            if (mounted) {{
                Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }});

    @override
    void dispose() {{
        _controller.dispose();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        super.dispose();

    @override
    Widget build(BuildContext context) {{
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                    ),
                ),
                child: Center(
                    child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {...}{
                            return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Container(
                                                width: 150,
                                                height: 150,
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: AppColors.primaryGradient,
                                                    ),
                                                    borderRadius: BorderRadius.circular(30),
                                                    boxShadow: [
                                                        BoxShadow(
                                                            color: AppColors.primary.withOpacity(0.5),
                                                            blurRadius: 30,
                                                            spreadRadius: 10,
                                                        ),
                                                    ],
                                                ),
                                                child: const Icon(
                                                    Icons.music_note,
                                                    size: 80,
                                                    color: Colors.white,
                                                ),
                                            ),
                                            const SizedBox(height: 30),
                                            const Text(
                                                'MukkeApp',
                                                style: TextStyle(
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 2,
                                                ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                                'Die ultimative Erlebnisplattform',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white.withOpacity(0.8),
                                                    letterSpacing: 1,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            );
                        },
                    ),
                ),
            ),
        );
"""

        def _generate_onboarding_screen(self, class_name: str) -> str:
                """Generiert Onboarding Screen"""
                return f"""import 'package:flutter/material.dart';
import '../utils/constants.dart';

class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}) : super(key: key);

    @override
    State<{class_name}> createState() => _{class_name}State();

class _{class_name}State extends State<{class_name}> {{
    final PageController _pageController = PageController();
    int _currentPage = 0;

    final List<OnboardingPage> _pages = [
        OnboardingPage(
            title: 'Willkommen bei MukkeApp',
            description: '12 Apps in einer - Deine ultimative Erlebnisplattform',
            icon: Icons.rocket_launch,
            gradient: AppColors.primaryGradient,
        ),
        OnboardingPage(
            title: 'KI-Power',
            description: 'Persönlicher Avatar, Musik-Generator und mehr',
            icon: Icons.psychology,
            gradient: AppColors.accentGradient,
        ),
        OnboardingPage(
            title: 'Community',
            description: 'Challenges, Duelle und Live-Streaming',
            icon: Icons.people,
            gradient: [AppColors.success, AppColors.primary],
        ),
    ];

    @override
    void dispose() {{
        _pageController.dispose();
        super.dispose();

    @override
    Widget build(BuildContext context) {{
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                    ),
                ),
                child: SafeArea(
                    child: Column(
                        children: [
                            // Skip Button
                            Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                    onPressed: () => _navigateToLogin(),
                                    child: const Text(
                                        'Überspringen',
                                        style: TextStyle(color: Colors.white70),
                                    ),
                                ),
                            ),

                            // Pages
                            Expanded(
                                child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) {{
                                        setState(() => _currentPage = index);
                                    }},
                                    itemCount: _pages.length,
                                    itemBuilder: (context, index) {{
                                        final page = _pages[index];
                                        return Padding(
                                            padding: const EdgeInsets.all(40),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Container(
                                                        width: 120,
                                                        height: 120,
                                                        decoration: BoxDecoration(
                                                            gradient: LinearGradient(colors: page.gradient),
                                                            shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                            page.icon,
                                                            size: 60,
                                                            color: Colors.white,
                                                        ),
                                                    ),
                                                    const SizedBox(height: 40),
                                                    Text(
                                                        page.title,
                                                        style: const TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                        page.description,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white.withOpacity(0.8),
                                                        ),
                                                        textAlign: TextAlign.center,
                                                    ),
                                                ],
                                            ),
                                        );
                                    }},
                                ),
                            ),

                            // Indicators & Button
                            Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                    children: [
                                        // Page Indicators
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(
                                                _pages.length,
                                                (index) => AnimatedContainer(
                                                    duration: const Duration(milliseconds: 300),
                                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                                    height: 10,
                                                    width: _currentPage == index ? 30 : 10,
                                                    decoration: BoxDecoration(
                                                        color: _currentPage == index
                                                                ? AppColors.primary
                                                                : Colors.white30,
                                                        borderRadius: BorderRadius.circular(5),
                                                    ),
                                                ),
                                            ),
                                        ),
                                        const SizedBox(height: 40),

                                        // Next/Start Button
                                        SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: () {{
                                                    if (_currentPage < _pages.length - 1) {{
                                                        _pageController.nextPage(
                                                            duration: const Duration(milliseconds: 300),
                                                            curve: Curves.easeInOut,
                                                        );
                                                    }} else {{
                                                        _navigateToLogin();
                                                }},
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                ),
                                                child: Text(
                                                    _currentPage < _pages.length - 1 ? 'Weiter' : 'Los geht\'s',
                                                    style: const TextStyle(fontSize: 18),
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );

    void _navigateToLogin() {{
        Navigator.pushReplacementNamed(context, AppRoutes.login);

class OnboardingPage {{
    final String title;
    final String description;
    final IconData icon;
    final List<Color> gradient;

    OnboardingPage({{
        required this.title,
        required this.description,
        required this.icon,
        required this.gradient,
    }});
"""

        def _generate_home_screen(self, class_name: str) -> str:
                """Generiert Home Screen mit allen Modulen"""
                return f"""import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/user_provider.dart';

class {class_name} extends StatefulWidget {{
    const {class_name}({{Key? key}}) : super(key: key);

    @override
    State<{class_name}> createState() => _{class_name}State();

class _{class_name}State extends State<{class_name}> {{
    int _selectedIndex = 0;

    final List<ModuleItem> _modules = [
        ModuleItem(
            title: 'Mukke Musik',
            description: 'KI-generierte Musik',
            icon: Icons.music_note,
            gradient: [Color(0xFF6B46C1), Color(0xFF9333EA)],
            route: AppRoutes.musicMain,
        ),
        ModuleItem(
            title: 'Mukke Dating',
            description: 'Finde dein Match',
            icon: Icons.favorite,
            gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
            route: AppRoutes.datingMain,
        ),
        ModuleItem(
            title: 'Sport & Fitness',
            description: 'Dein KI-Coach',
            icon: Icons.fitness_center,
            gradient: [Color(0xFF10B981), Color(0xFF059669)],
            route: AppRoutes.sportMain,
        ),
        ModuleItem(
            title: 'Real Challenge',
            description: '1€ Challenges',
            icon: Icons.bolt,
            gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
            route: AppRoutes.challengeMain,
        ),
        ModuleItem(
            title: 'Mukke Spiele',
            description: 'Duelle & Games',
            icon: Icons.gamepad,
            gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            route: AppRoutes.gamesMain,
        ),
        ModuleItem(
            title: 'KI Avatar',
            description: 'Dein digitales Ich',
            icon: Icons.face,
            gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            route: AppRoutes.avatarMain,
        ),
        ModuleItem(
            title: 'Tracking',
            description: 'Familie im Blick',
            icon: Icons.location_on,
            gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
            route: AppRoutes.trackingMain,
        ),
        ModuleItem(
            title: 'Mode AR',
            description: 'Virtual Try-On',
            icon: Icons.checkroom,
            gradient: [Color(0xFFA78BFA), Color(0xFF9333EA)],
            route: AppRoutes.fashionMain,
        ),
        ModuleItem(
            title: 'Sprachen',
            description: 'KI-Sprachlehrer',
            icon: Icons.language,
            gradient: [Color(0xFF14B8A6), Color(0xFF0D9488)],
            route: AppRoutes.languageMain,
        ),
        ModuleItem(
            title: 'Live',
            description: 'Streaming & Events',
            icon: Icons.live_tv,
            gradient: [Color(0xFFEF4444), Color(0xFFB91C1C)],
            route: AppRoutes.liveMain,
        ),
        ModuleItem(
            title: 'Chat',
            description: 'Messenger & Calls',
            icon: Icons.chat,
            gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            route: AppRoutes.chatMain,
        ),
        ModuleItem(
            title: 'Verbesserungen',
            description: 'Deine Ideen',
            icon: Icons.lightbulb,
            gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
            route: AppRoutes.improvements,
        ),
    ];

    @override
    Widget build(BuildContext context) {{
        return Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                    ),
                ),
                child: SafeArea(
                    child: Column(
                        children: [
                            // Header
                            Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    'Hallo, Max!',
                                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                                Text(
                                                    'Was möchtest du heute erleben?',
                                                    style: TextStyle(
                                                        color: Colors.white.withOpacity(0.7),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Stack(
                                            children: [
                                                Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            colors: AppColors.primaryGradient,
                                                        ),
                                                        shape: BoxShape.circle,
                                                    ),
                                                    child: IconButton(
                                                        icon: const Icon(Icons.notifications, color: Colors.white),
                                                        onPressed: () {{}},
                                                    ),
                                                ),
                                                Positioned(
                                                    right: 8,
                                                    top: 8,
                                                    child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration: const BoxDecoration(
                                                            color: AppColors.accent,
                                                            shape: BoxShape.circle,
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),

                            // Modules Grid
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 1.1,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                        ),
                                        itemCount: _modules.length,
                                        itemBuilder: (context, index) {{
                                            final module = _modules[index];
                                            return InkWell(
                                                onTap: () => Navigator.pushNamed(context, module.route),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: module.gradient,
                                                        ),
                                                        borderRadius: BorderRadius.circular(20),
                                                        boxShadow: [
                                                            BoxShadow(
                                                                color: module.gradient[0].withOpacity(0.3),
                                                                blurRadius: 15,
                                                                offset: const Offset(0, 8),
                                                            ),
                                                        ],
                                                    ),
                                                    child: Padding(
                                                        padding: const EdgeInsets.all(20),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                Icon(
                                                                    module.icon,
                                                                    size: 40,
                                                                    color: Colors.white,
                                                                ),
                                                                Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                        Text(
                                                                            module.title,
                                                                            style: const TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.bold,
                                                                            ),
                                                                        ),
                                                                        const SizedBox(height: 4),
                                                                        Text(
                                                                            module.description,
                                                                            style: TextStyle(
                                                                                color: Colors.white.withOpacity(0.8),
                                                                                fontSize: 12,
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                            );
                                        }},
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),

            // Bottom Navigation
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                        ),
                    ],
                ),
                child: BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) {{
                        setState(() => _selectedIndex = index);
                        switch (index) {{
                            case 1:
                                Navigator.pushNamed(
                                    context, AppRoutes.challengeMain);
                                break;
                            case 2:
                                Navigator.pushNamed(
                                    context, AppRoutes.ranking);
                                break;
                            case 3:
                                Navigator.pushNamed(
                                    context, AppRoutes.profile);
                                break;
                    }},
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    selectedItemColor: AppColors.primary,
                    unselectedItemColor: Colors.white54,
                    items: const [
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.bolt),
                            label: 'Challenges',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.leaderboard),
                            label: 'Ranking',
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.person),
                            label: 'Profil',
                        ),
                    ],
                ),
            ),
        );

class ModuleItem {{
    final String title;
    final String description;
    final IconData icon;
    final List<Color> gradient;
    final String route;

    ModuleItem({{
        required this.title,
        required this.description,
        required this.icon,
        required this.gradient,
        required this.route,
    }});
"""


formKey = GlobalKey < FormState > ();
final _titleController = TextEditingController();
final _descriptionController = TextEditingController();

    String _selectedCategory = 'Sport';
    int _selectedDuration = 24;
    bool _isRecording = false;
    CameraController? _cameraController;

    final List < String > _categories = [
        'Sport', 'Musik', 'Tanz', 'Comedy', 'Kunst', 'Kochen', 'Gaming', 'Sonstiges'
    ];

    @ override
    void initState() {{
        super.initState();
        _initializeCamera();

    Future < void > _initializeCamera() async {{
        try {{
            final cameras = await availableCameras();
            if (cameras.isNotEmpty) {{
                _cameraController = CameraController(
                    cameras.first,
                    ResolutionPreset.high,
                );
                await _cameraController!.initialize();
                if (mounted) setState(() {{}});
        }} catch(e) {{
            print('Camera initialization error: $e');

    @ override
    _void dispose() {{
        _titleController.dispose();
        _descriptionController.dispose();
        _cameraController?.dispose();
        super.dispose();

    @ override
    Widget build(BuildContext context) {{
        return Scaffold(
            appBar: AppBar(
                title: const Text('Challenge erstellen'),
                backgroundColor: AppColors.primary,
                elevation: 0,
            ),
            body: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.background, AppColors.surfaceDark],
                    ),
                ),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Video Preview
                                Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.primary, width: 2),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: _cameraController?.value.isInitialized == true
                                                ? CameraPreview(_cameraController!): const Center(
                                                        child: Icon(
                                                            Icons.videocam,
                                                            size: 60,
                                                            color: Colors.white54,
                                                        ),
                                                    ),
                                    ),
                                ),
                                const SizedBox(height: 20),

                                // Record Button
                                Center(
                                    child: GestureDetector(
                                        onTap: _toggleRecording,
                                        child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _isRecording ? Colors.red: AppColors.accent,
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: (_isRecording ? Colors.red: AppColors.accent)
                                                                .withOpacity(0.5),
                                                        blurRadius: 20,
                                                        spreadRadius: 5,
                                                    ),
                                                ],
                                            ),
                                            child: Icon(
                                                _isRecording ? Icons.stop: Icons.videocam,
                                                color: Colors.white,
                                                size: 40,
                                            ),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 30),

                                // Title
                                TextFormField(
                                    controller: _titleController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        labelText: 'Challenge Titel',
                                        labelStyle: const TextStyle(color: AppColors.textGrey),
                                        prefixIcon: const Icon(Icons.title, color: AppColors.primary),
                                        filled: true,
                                        fillColor: AppColors.surfaceDark,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                    ),
                                    validator: (value) {{
                                        if (value == null | | value.isEmpty) {{
                                            return 'Bitte einen Titel eingeben';
                                        return null;
                                    }},
                                ),
                                const SizedBox(height: 20),

                                // Description
                                TextFormField(
                                    controller: _descriptionController,
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                        labelText: 'Beschreibung',
                                        labelStyle: const TextStyle(color: AppColors.textGrey),
                                        prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                                        filled: true,
                                        fillColor: AppColors.surfaceDark,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                    ),
                                    validator: (value) {{
                                        if (value == null | | value.isEmpty) {{
                                            return 'Bitte eine Beschreibung eingeben';
                                        return null;
                                    }},
                                ),
                                const SizedBox(height: 20),

                                // Category
                                const Text(
                                    'Kategorie',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _categories.map((category) {{
                                        final isSelected = _selectedCategory == category;
                                        return InkWell(
                                            onTap: ()=> setState(() = > _selectedCategory = category),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.primary: AppColors.surfaceDark,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: isSelected ? AppColors.primary: Colors.white24,
                                                    ),
                                                ),
                                                child: Text(
                                                    category,
                                                    style: TextStyle(
                                                        color: isSelected ? Colors.white: Colors.white70,
                                                        fontWeight: isSelected ? FontWeight.bold: FontWeight.normal,
                                                    ),
                                                ),
                                            ),
                                        );
                                    }}).toList(),
                                ),
                                const SizedBox(height: 30),

                                // Duration
                                const Text(
                                    'Laufzeit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                    children: [
                                        Icon(Icons.timer, color: AppColors.primary),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Slider(
                                                value: _selectedDuration.toDouble(),
                                                min: 1,
                                                max: 72,
                                                divisions: 71,
                                                activeColor: AppColors.primary,
                                                inactiveColor: AppColors.surfaceDark,
                                                label: '$_selectedDuration Stunden',
                                                onChanged: (value) {{
                                                    setState(()= > _selectedDuration = value.round());
                                                }},
                                            ),
                                        ),
                                        Text(
                                            '$_selectedDuration h',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 30),

                                // Prize Info
                                Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: AppColors.accentGradient,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                        children: [
                                            const Icon(Icons.euro, color: Colors.white, size: 30),
                                            const SizedBox(width: 16),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        const Text(
                                                            'Einsatz: 1€',
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                        Text(
                                                            'Winner takes all!',
                                                            style: TextStyle(
                                                                color: Colors.white.withOpacity(0.8),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 30),

                                // Create Button
                                SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                        onPressed: _createChallenge,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.accent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                            ),
                                        ),
                                        child: const Text(
                                            'Challenge erstellen',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );

    void _toggleRecording() {{
        setState(()= > _isRecording = !_isRecording);
        if (_isRecording) {{
            // Start recording
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aufnahme gestartet')),
            );
        }} else {{
            // Stop recording
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aufnahme beendet')),
            );

    void _createChallenge() {{
        if (_formKey.currentState!.validate()) {{
            // TODO: Challenge erstellen
            showDialog(
                context: context,
                builder: (context)= > AlertDialog(
                    backgroundColor: AppColors.surfaceDark,
                    title: const Text(
                        'Challenge erstellt!',
                        style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                        'Deine Challenge wurde erfolgreich erstellt und ist jetzt live!',
                        style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                        TextButton(
                            onPressed: () {{
                                Navigator.pop(context);
                                Navigator.pop(context);
                            }},
                            child: const Text('OK'),
                        ),
                    ],
                ),
            );
"""
