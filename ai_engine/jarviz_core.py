"""
Jarviz Core - Hauptmodul der KI-Engine
Selbstlernende KI für MukkeApp-Entwicklung
"""

import os
import sys
import json
import time
import logging
import subprocess
import threading
from pathlib import Path
from datetime import datetime
from queue import Queue
import traceback

logger = logging.getLogger(__name__)

# Logging-Setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/jarviz.log'),
        logging.StreamHandler()
    ]
)

class JarvizCore:
    def __init__(self):
        self.logger = logging.getLogger('JarvizCore')
        self.version = "2.0.0"
        self.status = "initializing"
        self.memory_path = Path('ai_engine/memory')
        self.flutter_path = Path('flutter_app')
        
        # Memory laden
        self.conversation_history = self._load_memory('conversation_history.json')
        self.code_patterns = self._load_memory('code_patterns.json')
        self.error_solutions = self._load_memory('error_solutions.json')
        self.file_changes = self._load_memory('file_changes.json')
        self.learned_behaviors = self._load_memory('learned_behaviors.json')
        
        # Module Status
        self.modules = self._load_memory('mukke_modules.json')
        
        # Command Queue
        self.command_queue = Queue()
        self.processing = False
        
        logger.info(f"Jarviz v{self.version} initialized")
        self.status = "ready"
        
    def _load_memory(self, filename):
        """Lädt Memory-Datei"""
        filepath = self.memory_path / filename
        try:
            if filepath.exists():
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    return data.get('data', data)
            else:
                self.logger.warning(f"Memory file not found: {filename}")
                return {} if filename.endswith('json') else []
        except Exception as e:
            self.logger.error(f"Error loading memory {filename}: {e}")
            return {} if filename.endswith('json') else []
    
    def _save_memory(self, filename, data):
        """Speichert Memory-Datei"""
        filepath = self.memory_path / filename
        try:
            content = {
                'version': '2.0',
                'updated_at': datetime.now().isoformat(),
                'data': data
            }
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(content, f, indent=2, ensure_ascii=False)
        except Exception as e:
            self.logger.error(f"Error saving memory {filename}: {e}")
    
    def process_command(self, command, context=None):
        """Verarbeitet einen Befehl"""
        logger.info(f"Processing command: {command}")
        
        # Zu History hinzufügen
        self.conversation_history.append({
            'timestamp': datetime.now().isoformat(),
            'command': command,
            'context': context
        })
        
        response = self._execute_command(command, context)
        
        # Response speichern
        self.conversation_history.append({
            'timestamp': datetime.now().isoformat(),
            'response': response
        })
        
        # Memory speichern
        self._save_memory('conversation_history.json', self.conversation_history[-100:])
        
        return response
    
    def _execute_command(self, command, context):
        """Führt einen Befehl aus"""
        command_lower = command.lower()
        
        # Flutter-Befehle
        if 'flutter' in command_lower:
            if 'create' in command_lower or 'erstelle' in command_lower:
                return self._create_flutter_component(command)
            elif 'test' in command_lower:
                return self._run_flutter_tests()
            elif 'build' in command_lower:
                return self._build_flutter_app()
                
        # Modul-Befehle
        elif any(module in command_lower for module in self.modules.keys()):
            return self._handle_module_command(command)
            
        # App-Kontrolle
        elif 'starte app' in command_lower:
            return self._start_app()
        elif 'stoppe app' in command_lower:
            return self._stop_app()
        elif 'deploy' in command_lower:
            return self._deploy_app()
            
        # Status
        elif 'status' in command_lower:
            return self._get_status()
            
        # Default
        else:
            return f"Befehl verstanden: {command}. Wie kann ich helfen?"
    
    def _create_flutter_component(self, command):
        """Erstellt Flutter-Komponente"""
        logger.info("Creating Flutter component")
        
        # Extrahiere Komponenten-Name
        parts = command.split()
        component_name = 'new_screen'
        
        for i, part in enumerate(parts):
            if part in ['screen', 'widget', 'service']:
                if i > 0:
                    component_name = parts[i-1].lower() + '_' + part
                break
        
        # Code generieren
        code = self._generate_flutter_code(component_name)
        
        # Datei erstellen
        file_path = self.flutter_path / 'lib' / 'screens' / f'{component_name}.dart'
        file_path.parent.mkdir(exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(code)
        
        # Änderung tracken
        self.file_changes.append({
            'timestamp': datetime.now().isoformat(),
            'action': 'created',
            'file': str(file_path),
            'component': component_name
        })
        self._save_memory('file_changes.json', self.file_changes[-100:])
        
        return f"✅ Flutter-Komponente '{component_name}' wurde erstellt: {file_path}"
    
    def _generate_flutter_code(self, component_name):
        """Generiert Flutter-Code"""
        class_name = ''.join(word.capitalize() for word in component_name.split('_'))
        
        return f"""import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class {class_name} extends StatefulWidget {{
  const {class_name}({{Key? key}}) : super(key: key);

  @override
  State<{class_name}> createState() => _{class_name}State();
}}

class _{class_name}State extends State<{class_name}> {{
  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{class_name}'),
        backgroundColor: const Color(0xFF00BFFF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          ),
        ),
        child: const Center(
          child: Text(
            '{class_name}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }}
}}
"""
    
    def _run_flutter_tests(self):
        """Führt Flutter-Tests aus"""
        logger.info("Running Flutter tests")
        
        try:
            result = subprocess.run(
                ['flutter', 'test'],
                cwd=self.flutter_path,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                return "✅ Alle Flutter-Tests erfolgreich!"
            else:
                # Fehler analysieren und Lösung vorschlagen
                error_msg = result.stderr or result.stdout
                solution = self._analyze_flutter_error(error_msg)
                return f"❌ Test-Fehler: {error_msg[:200]}\n\n💡 Lösungsvorschlag: {solution}"
                
        except Exception as e:
            return f"❌ Fehler beim Ausführen der Tests: {e}"
    
    def _analyze_flutter_error(self, error_msg):
        """Analysiert Flutter-Fehler und schlägt Lösung vor"""
        error_lower = error_msg.lower()
        
        # Bekannte Fehler prüfen
        for error_type, solution_info in self.error_solutions.items():
            if error_type in error_lower:
                solution_info['success_count'] += 1
                self._save_memory('error_solutions.json', self.error_solutions)
                return solution_info['solution']
        
        # Neue Lösung lernen
        return "Fehler wird analysiert. Bitte prüfen Sie die Imports und Syntax."
    
    def _start_app(self):
        """Startet die Flutter-App"""
        logger.info("Starting Flutter app")
        
        try:
            # Flutter run im Hintergrund
            process = subprocess.Popen(
                ['flutter', 'run', '-d', 'chrome'],
                cwd=self.flutter_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            # PID speichern für späteren Stop
            with open('.app_pid', 'w', encoding='utf-8') as f:
                f.write(str(process.pid))
            
            return "✅ MukkeApp wird gestartet... Öffne http://localhost:3000"
            
        except Exception as e:
            return f"❌ Fehler beim Starten der App: {e}"
    
    def _stop_app(self):
        """Stoppt die Flutter-App"""
        logger.info("Stopping Flutter app")
        
        try:
            if Path('.app_pid').exists():
                with open('.app_pid', 'r') as f:
                    pid = int(f.read())
                
                # Prozess beenden
                if sys.platform == 'win32':
                    subprocess.run(['taskkill', '/F', '/PID', str(pid)])
                else:
                    subprocess.run(['kill', str(pid)])
                
                Path('.app_pid').unlink()
                return "✅ MukkeApp wurde gestoppt"
            else:
                return "ℹ️ App läuft nicht"
                
        except Exception as e:
            return f"❌ Fehler beim Stoppen der App: {e}"
    
    def _deploy_app(self):
        """Deployed die App"""
        logger.info("Deploying app")
        
        steps = []
        
        try:
            # 1. Build erstellen
            steps.append("📦 Erstelle Production Build...")
            result = subprocess.run(
                ['flutter', 'build', 'web'],
                cwd=self.flutter_path,
                capture_output=True
            )
            
            if result.returncode == 0:
                steps.append("✅ Build erfolgreich")
            else:
                steps.append("❌ Build fehlgeschlagen")
                return '\n'.join(steps)
            
            # 2. Firebase Deploy (wenn konfiguriert)
            if Path('firebase.json').exists():
                steps.append("☁️ Deploye zu Firebase...")
                result = subprocess.run(
                    ['firebase', 'deploy'],
                    capture_output=True
                )
                
                if result.returncode == 0:
                    steps.append("✅ Firebase Deployment erfolgreich")
                    steps.append("🌐 App verfügbar unter: https://mukkeapp.web.app")
                else:
                    steps.append("❌ Firebase Deployment fehlgeschlagen")
            
            # 3. Build-Info speichern
            self._save_build_info()
            steps.append("📊 Build-Informationen gespeichert")
            
            return '\n'.join(steps)
            
        except Exception as e:
            steps.append(f"❌ Deployment-Fehler: {e}")
            return '\n'.join(steps)
    
    def _save_build_info(self):
        """Speichert Build-Informationen"""
        build_info = {
            'timestamp': datetime.now().isoformat(),
            'version': self.version,
            'modules': list(self.modules.keys()),
            'flutter_version': self._get_flutter_version()
        }
        
        build_history = self._load_memory('build_history.json')
        if not isinstance(build_history, list):
            build_history = []
        
        build_history.append(build_info)
        self._save_memory('build_history.json', build_history[-10:])
    
    def _get_flutter_version(self):
        """Holt Flutter-Version"""
        try:
            result = subprocess.run(
                ['flutter', '--version'],
                capture_output=True,
                text=True
            )
            return result.stdout.split('\n')[0] if result.returncode == 0 else 'Unknown'
        except:
            return 'Unknown'
    
    def _handle_module_command(self, command):
        """Behandelt Modul-spezifische Befehle"""
        for module_name, module_info in self.modules.items():
            if module_name in command.lower():
                module_info['last_update'] = datetime.now().isoformat()
                self._save_memory('mukke_modules.json', self.modules)
                return f"✅ Modul '{module_name}' wurde aktiviert. Status: {module_info['status']}"
        
        return "ℹ️ Modul nicht erkannt. Verfügbare Module: " + ', '.join(self.modules.keys())
    
    def _get_status(self):
        """Gibt System-Status zurück"""
        active_modules = sum(1 for m in self.modules.values() if m['status'] == 'ready')
        
        return f"""
🤖 Jarviz Status Report
====================
Version: {self.version}
Status: {self.status}
Aktive Module: {active_modules}/12
Konversationen: {len(self.conversation_history)}
Gelernte Muster: {len(self.code_patterns)}
Dateiänderungen: {len(self.file_changes)}

Module:
{self._format_modules_status()}
"""
    
    def _format_modules_status(self):
        """Formatiert Modul-Status"""
        status_str = ""
        for name, info in self.modules.items():
            emoji = "✅" if info['status'] == 'ready' else "⏸️"
            status_str += f"  {emoji} {name}: {info['status']}\n"
        return status_str

# Globale Instanz
jarviz = JarvizCore()
