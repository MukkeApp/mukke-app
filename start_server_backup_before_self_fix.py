#!/usr/bin/env python3
"""
Jarviz MukkeApp Development System - Vollständiges Startscript
Automatisierte Entwicklung der kompletten MukkeApp mit allen 12 Modulen
"""

import os

# Manuell PATH setzen, damit Python flutter, dart und firebase erkennt
os.environ["PATH"] += r";C:\flutter\bin;C:\Users\Mapst\AppData\Roaming\npm"

import sys
import time
import subprocess
from pathlib import Path
import webbrowser
import threading
import shutil
import json
import platform
from datetime import datetime

# Farben für Terminal-Output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    CYAN = '\033[96m'
    MAGENTA = '\033[95m'

def print_banner():
    """Zeigt das erweiterte MukkeApp Jarviz-Banner"""
    banner = f"""
{Colors.MAGENTA}
╔══════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║     ███╗   ███╗██╗   ██╗██╗  ██╗██╗  ██╗███████╗ █████╗ ██████╗ ██████╗ ║
║     ████╗ ████║██║   ██║██║ ██╔╝██║ ██╔╝██╔════╝██╔══██╗██╔══██╗██╔══██╗║
║     ██╔████╔██║██║   ██║█████╔╝ █████╔╝ █████╗  ███████║██████╔╝██████╔╝║
║     ██║╚██╔╝██║██║   ██║██╔═██╗ ██╔═██╗ ██╔══╝  ██╔══██║██╔═══╝ ██╔═══╝ ║
║     ██║ ╚═╝ ██║╚██████╔╝██║  ██╗██║  ██╗███████╗██║  ██║██║     ██║     ║
║     ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝     ║
║                                                                        ║
╚══════════════════════════════════════════════════════════════════════╝
{Colors.ENDC}
{Colors.CYAN}
          ██╗ █████╗ ██████╗ ██╗   ██╗██╗███████╗    ██╗   ██╗██████╗ 
          ██║██╔══██╗██╔══██╗██║   ██║██║╚══███╔╝    ██║   ██║╚════██╗
          ██║███████║██████╔╝██║   ██║██║  ███╔╝     ██║   ██║ █████╔╝
     ██   ██║██╔══██║██╔══██╗╚██╗ ██╔╝██║ ███╔╝      ╚██╗ ██╔╝██╔═══╝ 
     ╚█████╔╝██║  ██║██║  ██║ ╚████╔╝ ██║███████╗     ╚████╔╝ ███████╗
      ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚══════╝      ╚═══╝  ╚══════╝
{Colors.ENDC}
{Colors.BOLD}          🚀 MukkeApp Complete Development System v2.0 🚀{Colors.ENDC}
{Colors.YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.ENDC}
    
    {Colors.GREEN}Developer:{Colors.ENDC} mapstar1588@web.de
    {Colors.GREEN}Hardware:{Colors.ENDC} Asus TUF Gaming A15 - Ryzen 7, RTX 3050, 16GB RAM
    {Colors.GREEN}Package:{Colors.ENDC} com.mukke_app
    {Colors.GREEN}Domain:{Colors.ENDC} MukkeApp.com
"""
    print(banner)
    
    # Module anzeigen
    modules = [
        "👤 Profil & Konto", "🎵 Mukke Musik", "❤️ Mukke Dating",
        "💪 Sport & Fitness", "⚡ Real Challenge", "🎮 Mukke Spiele",
        "🤖 KI Avatar", "📍 Mukke Tracking", "👗 Mukke Mode AR",
        "🗣️ Mukke Sprache", "🔴 Mukke Live", "💡 Verbesserungen"
    ]
    
    print(f"\n{Colors.CYAN}📦 Integrierte Module:{Colors.ENDC}")
    for i, module in enumerate(modules, 1):
        print(f"   {i:02d}. {module}")
    print(f"{Colors.YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.ENDC}\n")

def detect_system():
    """Erkennt das Betriebssystem und Hardware"""
    print(f"{Colors.BLUE}🖥️ System-Erkennung...{Colors.ENDC}")
    
    system_info = {
        'os': platform.system(),
        'os_version': platform.version(),
        'machine': platform.machine(),
        'processor': platform.processor(),
        'python_version': sys.version.split()[0]
    }
    
    print(f"  {Colors.GREEN}✓{Colors.ENDC} OS: {system_info['os']} {platform.release()}")
    print(f"  {Colors.GREEN}✓{Colors.ENDC} Python: {system_info['python_version']}")
    print(f"  {Colors.GREEN}✓{Colors.ENDC} Architektur: {system_info['machine']}")
    
    # Python Version Warnung
    if sys.version_info >= (3, 13):
        print(f"  {Colors.YELLOW}⚠{Colors.ENDC} Python 3.13+ erkannt - einige ML-Pakete könnten inkompatibel sein")
        print(f"  {Colors.YELLOW}  Empfohlen: Python 3.10 oder 3.11{Colors.ENDC}")
    
    return system_info

def check_requirements():
    """Erweiterte Systemanforderungen prüfen"""
    print(f"\n{Colors.BLUE}🔍 Prüfe erweiterte Systemanforderungen...{Colors.ENDC}")
    
    requirements = {
        'Python': sys.version_info >= (3, 8),
        'Flutter': check_command('flutter --version'),
        'Dart': check_command('dart --version'),
        'Git': check_command('git --version'),
        'Node.js': check_command('node --version'),
        'Firebase CLI': check_command('firebase --version'),
        'Android Studio': check_android_studio(),
    }
    
    # CMake Check hinzufügen
    requirements['CMake'] = check_command('cmake --version')
    
    all_ok = True
    for req, status in requirements.items():
        if status:
            print(f"  {Colors.GREEN}✓{Colors.ENDC} {req}")
        else:
            print(f"  {Colors.RED}✗{Colors.ENDC} {req} - {Colors.YELLOW}Bitte installieren!{Colors.ENDC}")
            all_ok = False
    
    # RAM Check
    try:
        import psutil
        ram_gb = psutil.virtual_memory().total / (1024**3)
        if ram_gb >= 8:
            print(f"  {Colors.GREEN}✓{Colors.ENDC} RAM: {ram_gb:.1f} GB")
        else:
            print(f"  {Colors.YELLOW}⚠{Colors.ENDC} RAM: {ram_gb:.1f} GB (8GB+ empfohlen)")
    except:
        print(f"  {Colors.YELLOW}⚠{Colors.ENDC} RAM-Check nicht möglich")
    
    return all_ok

def check_command(command):
    """Prüft ob ein Befehl verfügbar ist – inkl. vollständigem PATH"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ
        )
        return result.returncode == 0
    except Exception as e:
        return False

def check_android_studio():
    """Prüft ob Android Studio installiert ist"""
    if platform.system() == 'Windows':
        paths = [
            Path.home() / 'AppData' / 'Local' / 'Android' / 'Sdk',
            Path('C:/Android/Sdk')
        ]
    else:
        paths = [
            Path.home() / 'Android' / 'Sdk',
            Path('/usr/local/android-sdk'),
            Path.home() / 'Library' / 'Android' / 'sdk'
        ]
    
    return any(path.exists() for path in paths)

def install_dependencies():
    """Installiert alle benötigten Python-Dependencies für MukkeApp"""
    print(f"\n{Colors.BLUE}📦 Installiere MukkeApp Dependencies...{Colors.ENDC}")
    
    # Prüfe Python-Version für Kompatibilität
    python_version = sys.version_info
    skip_ml_packages = python_version >= (3, 13)
    
    # Gruppierte Dependencies
    dependency_groups = {
        "Core": [
            'flask', 'flask-socketio', 'flask-cors', 'python-socketio[client]',
            'python-dotenv', 'requests', 'aiofiles', 'aiohttp'
        ],
        "AI & ML": [
            'openai', 'transformers', 'torch',
            # Skip tensorflow und mediapipe für Python 3.13+
            'numpy', 'scikit-learn', 'pandas', 'matplotlib'
        ],
        "Development": [
            'watchdog', 'black', 'pylint', 'pytest', 'coverage'
        ],
        "Firebase & Cloud": [
            'firebase-admin', 'google-cloud-storage', 'google-cloud-firestore'
        ],
        "Audio & Speech": [
            'SpeechRecognition', 'pyttsx3', 'pyaudio', 'sounddevice',
            'librosa', 'pydub'
        ],
        "Computer Vision": [
            'opencv-python', 'pillow'
            # Skip mediapipe und face-recognition für Python 3.13+
        ],
        "Payment & Security": [
            'stripe', 'paypalrestsdk', 'cryptography', 'pyjwt'
        ],
        "Additional": [
            'websockets', 'schedule', 'psutil', 'colorama', 
            'rich', 'tqdm', 'python-decouple', 'gzip'
        ]
    }
    
    # Problematische Pakete für Python 3.13+
    if not skip_ml_packages:
        dependency_groups["AI & ML"].extend(['tensorflow'])
        dependency_groups["Computer Vision"].extend(['mediapipe', 'face-recognition'])
    
    total_deps = sum(len(deps) for deps in dependency_groups.values())
    installed = 0
    failed_deps = []
    
    for group_name, dependencies in dependency_groups.items():
        print(f"\n  {Colors.CYAN}📚 {group_name}:{Colors.ENDC}")
        for dep in dependencies:
            print(f"    Installing {dep}...", end='', flush=True)
            result = subprocess.run(
                [sys.executable, '-m', 'pip', 'install', dep, '--quiet'],
                capture_output=True
            )
            if result.returncode == 0:
                print(f" {Colors.GREEN}✓{Colors.ENDC}")
                installed += 1
            else:
                print(f" {Colors.RED}✗{Colors.ENDC}")
                failed_deps.append(dep)
                if result.stderr:
                    error_msg = result.stderr.decode().strip()
                    # Nur erste Zeile des Fehlers anzeigen
                    first_line = error_msg.split('\n')[0] if error_msg else "Unknown error"
                    print(f"      {Colors.YELLOW}→ {first_line}{Colors.ENDC}")
    
    print(f"\n  {Colors.GREEN}✅ {installed}/{total_deps} Dependencies installiert{Colors.ENDC}")
    
    if failed_deps:
        print(f"\n  {Colors.YELLOW}⚠ Fehlgeschlagene Dependencies:{Colors.ENDC}")
        for dep in failed_deps:
            print(f"    - {dep}")
        print(f"\n  {Colors.YELLOW}Diese können manuell nachinstalliert werden.{Colors.ENDC}")

def create_complete_structure():
    """Erstellt die komplette MukkeApp Projektstruktur"""
    print(f"\n{Colors.BLUE}📁 Erstelle vollständige MukkeApp-Struktur...{Colors.ENDC}")
    
    # Hauptverzeichnisse
    main_dirs = {
        "AI Engine": [
            'ai_engine', 'ai_engine/memory', 'ai_engine/models',
            'ai_engine/training', 'ai_engine/analytics'
        ],
        "App Modules": [
            'app_modules/profile_system', 'app_modules/music_engine',
            'app_modules/dating_system', 'app_modules/sport_coach',
            'app_modules/challenge_system', 'app_modules/gaming_engine',
            'app_modules/avatar_ai', 'app_modules/tracking_system',
            'app_modules/fashion_ar', 'app_modules/language_coach',
            'app_modules/live_streaming', 'app_modules/improvement_system'
        ],
        "Flutter App": [
            'flutter_app', 'flutter_app/lib', 'flutter_app/lib/screens',
            'flutter_app/lib/widgets', 'flutter_app/lib/services',
            'flutter_app/lib/models', 'flutter_app/lib/providers',
            'flutter_app/lib/utils', 'flutter_app/assets',
            'flutter_app/assets/images', 'flutter_app/assets/sounds',
            'flutter_app/assets/animations', 'flutter_app/android',
            'flutter_app/ios', 'flutter_app/web'
        ],
        "Server & API": [
            'server', 'server/api', 'server/websocket', 'server/middleware',
            'server/payment', 'server/auth', 'server/notifications'
        ],
        "Database": [
            'database', 'database/migrations', 'database/seeds',
            'database/backups', 'database/schemas'
        ],
        "Infrastructure": [
            'config', 'logs', 'backups', 'temp', 'uploads',
            'static', 'static/css', 'static/js', 'static/images',
            'templates', 'templates/emails', 'templates/reports'
        ],
        "Development": [
            'tests', 'tests/unit', 'tests/integration', 'tests/e2e',
            'docs', 'docs/api', 'docs/user', 'scripts', 'tools'
        ]
    }
    
    total_dirs = sum(len(dirs) for dirs in main_dirs.values())
    created = 0
    
    for category, directories in main_dirs.items():
        print(f"\n  {Colors.CYAN}📂 {category}:{Colors.ENDC}")
        for dir_name in directories:
            dir_path = Path(dir_name)
            dir_path.mkdir(parents=True, exist_ok=True)
            created += 1
            print(f"    {Colors.GREEN}✓{Colors.ENDC} {dir_name}/")
    
    print(f"\n  {Colors.GREEN}✅ {created} Verzeichnisse erstellt{Colors.ENDC}")

def create_configuration_files():
    """Erstellt alle Konfigurationsdateien für MukkeApp"""
    print(f"\n{Colors.BLUE}⚙️ Erstelle Konfigurationsdateien...{Colors.ENDC}")
    
    # .env Datei
    env_path = Path('.env')
    if not env_path.exists():
        env_content = """# MukkeApp Jarviz Configuration
# Core Settings
FLASK_SECRET_KEY=mukke-app-secret-key-2024
FLUTTER_PROJECT_PATH=flutter_app
JARVIZ_MEMORY_PATH=ai_engine/memory
JARVIZ_BACKUP_PATH=backups
JARVIZ_LOG_PATH=logs
DEVELOPMENT_MODE=true
ENABLE_CLOUD_SYNC=false
AUTO_HOT_RELOAD=true
MEMORY_COMPRESSION=true

# AI Configuration
OPENAI_API_KEY=your-openai-api-key-here
ANTHROPIC_API_KEY=your-anthropic-key-here
GOOGLE_AI_KEY=your-google-ai-key-here

# Firebase Configuration
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=mukkeapp.firebaseapp.com
FIREBASE_PROJECT_ID=mukkeapp
FIREBASE_STORAGE_BUCKET=mukkeapp.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=881155995571
FIREBASE_APP_ID=1:881155995571:web:xxxxx
FIREBASE_CREDENTIALS_PATH=config/firebase-service-account.json

# Payment Configuration
PAYPAL_CLIENT_ID=your-paypal-client-id
PAYPAL_SECRET=your-paypal-secret
STRIPE_SECRET_KEY=your-stripe-secret
STRIPE_PUBLISHABLE_KEY=your-stripe-public

# Cloud Services
GOOGLE_CLOUD_PROJECT=mukkeapp
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=eu-central-1

# App Configuration
APP_NAME=MukkeApp
APP_VERSION=1.0.0
APP_DOMAIN=mukkeapp.com
DEVELOPER_EMAIL=mapstar1588@web.de

# Server Configuration
SERVER_HOST=0.0.0.0
SERVER_PORT=5000
WEBSOCKET_PORT=5001
API_VERSION=v1

# Database Configuration
DATABASE_URL=firebase://mukkeapp
REDIS_URL=redis://localhost:6379

# Social Media APIs
INSTAGRAM_API_KEY=your-instagram-key
FACEBOOK_APP_ID=your-facebook-id
TIKTOK_CLIENT_KEY=your-tiktok-key

# Maps & Location
GOOGLE_MAPS_API_KEY=your-maps-key
MAPBOX_ACCESS_TOKEN=your-mapbox-token

# Push Notifications
FCM_SERVER_KEY=your-fcm-key
APNS_KEY_ID=your-apns-key

# Analytics
GOOGLE_ANALYTICS_ID=your-ga-id
MIXPANEL_TOKEN=your-mixpanel-token

# Security
JWT_SECRET_KEY=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key
"""
        with open(env_path, 'w', encoding='utf-8') as f:
            f.write(env_content)
        print(f"  {Colors.GREEN}✓{Colors.ENDC} .env erstellt")
    
    # Firebase Service Account
    firebase_config = {
        "type": "service_account",
        "project_id": "mukkeapp",
        "private_key_id": "your-key-id",
        "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR-KEY\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk@mukkeapp.iam.gserviceaccount.com",
        "client_id": "your-client-id",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token"
    }
    
    firebase_path = Path('config/firebase-service-account.json')
    firebase_path.parent.mkdir(exist_ok=True)
    with open(firebase_path, 'w', encoding='utf-8') as f:
        json.dump(firebase_config, f, indent=2)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} Firebase Service Account")
    
    # package.json für Node.js Dependencies
    package_json = {
        "name": "mukkeapp-server",
        "version": "1.0.0",
        "description": "MukkeApp Backend Server",
        "main": "server.js",
        "scripts": {
            "start": "node server.js",
            "dev": "nodemon server.js",
            "test": "jest"
        },
        "dependencies": {
            "express": "^4.18.0",
            "socket.io": "^4.5.0",
            "firebase-admin": "^11.0.0",
            "stripe": "^12.0.0",
            "cors": "^2.8.5",
            "dotenv": "^16.0.0",
            "jsonwebtoken": "^9.0.0"
        },
        "devDependencies": {
            "nodemon": "^2.0.20",
            "jest": "^29.0.0"
        }
    }
    
    with open('package.json', 'w', encoding='utf-8') as f:
        json.dump(package_json, f, indent=2)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} package.json")
    
    # requirements.txt - angepasst für Python 3.13 Kompatibilität
    python_version = sys.version_info
    requirements_content = """# MukkeApp Python Requirements
flask==2.3.2
flask-socketio==5.3.4
flask-cors==4.0.0
python-dotenv==1.0.0
openai==1.3.0
firebase-admin==6.1.0
watchdog==3.0.0
numpy==1.24.3
opencv-python==4.8.0.74
"""
    
    # Füge kompatible Pakete hinzu
    if python_version < (3, 13):
        requirements_content += """mediapipe==0.10.3
tensorflow==2.13.0
face-recognition==1.3.0
"""
    
    requirements_content += """torch==2.0.1
transformers==4.30.2
speechrecognition==3.10.0
pyttsx3==2.90
paypalrestsdk==1.13.1
stripe==5.5.0
requests==2.31.0
pillow==10.0.0
librosa==0.10.0.post2
sounddevice==0.4.6
psutil==5.9.5
rich==13.5.2
tqdm==4.65.0
aiofiles==23.2.1
scikit-learn==1.3.0
pandas==2.0.3
matplotlib==3.7.2
"""
    
    with open('requirements.txt', 'w', encoding='utf-8') as f:
        f.write(requirements_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} requirements.txt")
    
    # Docker Configuration
    dockerfile_content = """FROM python:3.10-slim

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \\
    build-essential \\
    git \\
    ffmpeg \\
    libportaudio2 \\
    cmake \\
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose ports
EXPOSE 5000 5001

# Start Jarviz
CMD ["python", "start_jarviz.py"]
"""
    
    with open('Dockerfile', 'w', encoding='utf-8') as f:
        f.write(dockerfile_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} Dockerfile")
    
    # docker-compose.yml
    docker_compose = """version: '3.8'

services:
  jarviz:
    build: .
    ports:
      - "5000:5000"
      - "5001:5001"
    volumes:
      - ./flutter_app:/app/flutter_app
      - ./ai_engine/memory:/app/ai_engine/memory
      - ./logs:/app/logs
    environment:
      - FLASK_ENV=development
    restart: unless-stopped
    
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - jarviz
"""
    
    with open('docker-compose.yml', 'w', encoding='utf-8') as f:
        f.write(docker_compose)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} docker-compose.yml")

def create_memory_files():
    """Erstellt alle Memory-Dateien für Jarviz"""
    print(f"\n{Colors.BLUE}🧠 Initialisiere Jarviz Memory System...{Colors.ENDC}")
    
    memory_files = {
        'ai_engine/memory/conversation_history.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        },
        'ai_engine/memory/code_patterns.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {
                "flutter_widgets": [],
                "error_fixes": [],
                "optimizations": [],
                "user_preferences": []
            }
        },
        'ai_engine/memory/error_solutions.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {
                "undefined_name": {"solution": "Add missing import", "success_count": 0},
                "const_constructor": {"solution": "Add const keyword", "success_count": 0},
                "null_safety": {"solution": "Add null check", "success_count": 0},
                "type_mismatch": {"solution": "Check variable types", "success_count": 0}
            }
        },
        'ai_engine/memory/file_changes.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        },
        'ai_engine/memory/learned_behaviors.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {
                "coding_style": {},
                "common_fixes": [],
                "module_usage": {}
            }
        },
        'ai_engine/memory/mukke_modules.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {
                "profile_system": {"status": "ready", "last_update": None},
                "music_engine": {"status": "ready", "last_update": None},
                "dating_system": {"status": "ready", "last_update": None},
                "sport_coach": {"status": "ready", "last_update": None},
                "challenge_system": {"status": "ready", "last_update": None},
                "gaming_engine": {"status": "ready", "last_update": None},
                "avatar_ai": {"status": "ready", "last_update": None},
                "tracking_system": {"status": "ready", "last_update": None},
                "fashion_ar": {"status": "ready", "last_update": None},
                "language_coach": {"status": "ready", "last_update": None},
                "live_streaming": {"status": "ready", "last_update": None},
                "improvement_system": {"status": "ready", "last_update": None}
            }
        },
        'ai_engine/memory/user_preferences.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {}
        },
        'ai_engine/memory/module_states.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': {}
        },
        'ai_engine/memory/code_generation.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        },
        'ai_engine/memory/build_history.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        },
        'ai_engine/memory/test_results.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        },
        'ai_engine/memory/changelog.json': {
            'version': '2.0',
            'created_at': datetime.now().isoformat(),
            'data': []
        }
    }
    
    for file_path, content in memory_files.items():
        path = Path(file_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(content, f, indent=2)
        print(f"  {Colors.GREEN}✓{Colors.ENDC} {file_path}")

def create_flutter_project():
    """Erstellt das Flutter-Projekt wenn nicht vorhanden"""
    print(f"\n{Colors.BLUE}📱 Initialisiere Flutter MukkeApp...{Colors.ENDC}")
    
    # WICHTIG: Als Path-Objekt definieren, nicht als String!
    flutter_path = Path('flutter_app')
    
    if not (flutter_path / 'pubspec.yaml').exists():
        print(f"  {Colors.CYAN}Creating Flutter project...{Colors.ENDC}")
        result = subprocess.run(
            ['flutter', 'create', '--org', 'com.mukke_app', 'flutter_app'],
            capture_output=True
        )
        if result.returncode == 0:
            print(f"  {Colors.GREEN}✓{Colors.ENDC} Flutter-Projekt erstellt")
        else:
            print(f"  {Colors.RED}✗{Colors.ENDC} Flutter-Projekt konnte nicht erstellt werden")
            if result.stderr:
                print(f"      {Colors.YELLOW}→ {result.stderr.decode()}{Colors.ENDC}")
            return False
    
    # pubspec.yaml aktualisieren
    pubspec_content = """name: mukke_app
description: Die ultimative Erlebnisplattform - 12 Apps in einer

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.7.0
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.0
  bloc: ^8.1.2
  
  # Networking
  dio: ^5.4.0
  http: ^1.1.0
  web_socket_channel: ^2.4.0
  
  # UI/UX
  flutter_animate: ^4.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  
  # Navigation
  go_router: ^12.1.0
  
  # Permissions & Hardware
  permission_handler: ^11.1.0
  camera: ^0.10.5
  geolocator: ^10.1.0
  sensors_plus: ^4.0.0
  
  # Media
  image_picker: ^1.0.5
  video_player: ^2.8.1
  audioplayers: ^5.2.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.2.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  
  # Payment
  pay: ^1.1.2
  flutter_stripe: ^9.5.0
  
  # Social
  flutter_facebook_auth: ^6.0.3
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0
  
  # AR/AI
  arcore_flutter_plugin: ^0.1.0
  tflite_flutter: ^0.10.4
  
  # Utilities
  url_launcher: ^6.2.2
  share_plus: ^7.2.1
  connectivity_plus: ^5.0.2
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1
  
  # Internationalization
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/sounds/
    - assets/animations/
    - assets/fonts/
    
  fonts:
    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
        - asset: assets/fonts/Montserrat-Bold.ttf
          weight: 700
        - asset: assets/fonts/Montserrat-Light.ttf
          weight: 300
"""
    
    pubspec_path = flutter_path / 'pubspec.yaml'
    with open(pubspec_path, 'w', encoding='utf-8') as f:
        f.write(pubspec_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} pubspec.yaml aktualisiert")
    
    # Asset-Verzeichnisse erstellen
    asset_dirs = [
        flutter_path / 'assets' / 'images',
        flutter_path / 'assets' / 'sounds',
        flutter_path / 'assets' / 'animations',
        flutter_path / 'assets' / 'fonts'
    ]
    
    for asset_dir in asset_dirs:
        asset_dir.mkdir(parents=True, exist_ok=True)
        # .gitkeep Datei erstellen, damit leere Ordner im Git bleiben
        (asset_dir / '.gitkeep').touch()
    
    print(f"  {Colors.GREEN}✓{Colors.ENDC} Asset-Verzeichnisse erstellt")
    
    # Jetzt flutter pub get ausführen
    print(f"  {Colors.CYAN}Installing Flutter packages...{Colors.ENDC}")
    result = subprocess.run(
    ['C:/flutter/bin/flutter.bat', 'pub', 'get'],
    cwd=str(flutter_path),
    capture_output=True,
    text=True
)

    
    if result.returncode == 0:
        print(f"  {Colors.GREEN}✓{Colors.ENDC} Flutter packages installiert")
    else:
        print(f"  {Colors.RED}✗{Colors.ENDC} Flutter pub get fehlgeschlagen")
        if result.stderr:
            print(f"      {Colors.YELLOW}→ {result.stderr}{Colors.ENDC}")
    
    # Erstelle jarviz_service.dart
    create_jarviz_service(flutter_path)
    
    return True

def create_jarviz_service(flutter_path):
    """Erstellt die jarviz_service.dart Datei"""
    service_path = flutter_path / 'lib' / 'services'
    service_path.mkdir(parents=True, exist_ok=True)
    
    service_content = '''import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

// Exception-Klassen
class JarvizException implements Exception {
  final String message;
  final int? statusCode;
  JarvizException(this.message, {this.statusCode});
}

// Result-Wrapper
class JarvizResult<T> {
  final T? data;
  final String? error;
  final bool success;
  
  JarvizResult.success(this.data) : error = null, success = true;
  JarvizResult.failure(this.error) : data = null, success = false;
}

class JarvizService {
  static const String baseUrl = 'http://localhost:5000';
  static const String wsUrl = 'ws://localhost:5000';
  
  WebSocketChannel? _channel;
  final http.Client _httpClient = http.Client();
  
  // Singleton
  static final JarvizService _instance = JarvizService._internal();
  factory JarvizService() => _instance;
  JarvizService._internal();
  
  // Verbindung testen
  Future<JarvizResult<bool>> testConnection() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/status'),
      ).timeout(const Duration(seconds: 5));
      
      return JarvizResult.success(response.statusCode == 200);
    } catch (e) {
      return JarvizResult.failure('Verbindungsfehler: $e');
    }
  }
  
  // Command senden
  Future<JarvizResult<String>> sendCommand(
    String command, {
    String? userId,
    String? projectId,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': command,
          'user_id': userId ?? 'default',
          'project_id': projectId ?? 'default',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return JarvizResult.success(data['response'] ?? 'Keine Antwort');
      }
      
      return JarvizResult.failure('Fehler: ${response.statusCode}');
    } catch (e) {
      return JarvizResult.failure('Fehler: $e');
    }
  }
  
  // Module Status
  Future<JarvizResult<Map<String, dynamic>>> getModules() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/modules'),
      );
      
      if (response.statusCode == 200) {
        return JarvizResult.success(json.decode(response.body));
      }
      
      return JarvizResult.failure('Fehler beim Abrufen der Module');
    } catch (e) {
      return JarvizResult.failure('Fehler: $e');
    }
  }
  
  // WebSocket verbinden
  void connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          print('WebSocket Nachricht: $message');
        },
        onError: (error) {
          print('WebSocket Fehler: $error');
        },
        onDone: () {
          print('WebSocket geschlossen');
          // Automatische Wiederverbindung nach 5 Sekunden
          Future.delayed(const Duration(seconds: 5), connectWebSocket);
        },
      );
    } catch (e) {
      print('WebSocket Verbindungsfehler: $e');
    }
  }
  
  void dispose() {
    _channel?.sink.close();
    _httpClient.close();
  }
}
'''
    
    with open(service_path / 'jarviz_service.dart', 'w', encoding='utf-8') as f:
        f.write(service_content)
    
    print(f"  {Colors.GREEN}✓{Colors.ENDC} jarviz_service.dart erstellt")

def copy_dashboard_and_templates():
    """Kopiert Dashboard und erstellt zusätzliche Templates"""
    print(f"\n{Colors.BLUE}📋 Erstelle Dashboard und Templates...{Colors.ENDC}")
    
    template_dir = Path('templates')
    template_dir.mkdir(exist_ok=True)
    
    # Erstelle erweitertes Dashboard
    dashboard_content = """<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jarviz MukkeApp Dashboard</title>
    <script src="https://cdn.socket.io/4.6.1/socket.io.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
            color: #fff;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: rgba(0, 191, 255, 0.1);
            border: 1px solid #00BFFF;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        h1 {
            color: #00BFFF;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #FF1493;
            font-size: 1.2em;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(0, 191, 255, 0.3);
            border-radius: 10px;
            padding: 20px;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: #00BFFF;
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 191, 255, 0.3);
        }
        
        .card h3 {
            color: #00BFFF;
            margin-bottom: 15px;
        }
        
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: bold;
        }
        
        .status.online {
            background: #00FF00;
            color: #000;
        }
        
        .status.offline {
            background: #FF0000;
            color: #fff;
        }
        
        .chat-container {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(0, 191, 255, 0.3);
            border-radius: 10px;
            padding: 20px;
            height: 400px;
            display: flex;
            flex-direction: column;
        }
        
        #messages {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 20px;
            padding: 10px;
        }
        
        .message {
            margin-bottom: 10px;
            padding: 10px;
            border-radius: 5px;
        }
        
        .message.user {
            background: #00BFFF;
            color: #000;
            text-align: right;
        }
        
        .message.jarviz {
            background: rgba(255, 20, 147, 0.2);
            border: 1px solid #FF1493;
        }
        
        .input-group {
            display: flex;
            gap: 10px;
        }
        
        input {
            flex: 1;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(0, 191, 255, 0.5);
            border-radius: 5px;
            color: #fff;
            font-size: 16px;
        }
        
        button {
            padding: 10px 20px;
            background: #FF1493;
            border: none;
            border-radius: 5px;
            color: #fff;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        button:hover {
            background: #FF69B4;
            transform: scale(1.05);
        }
        
        .modules {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .module {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(0, 191, 255, 0.3);
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .module.active {
            border-color: #00FF00;
            background: rgba(0, 255, 0, 0.1);
        }
        
        .module-icon {
            font-size: 2em;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🤖 Jarviz MukkeApp Dashboard</h1>
            <p class="subtitle">KI-gesteuerte App-Entwicklung</p>
        </header>
        
        <div class="grid">
            <div class="card">
                <h3>System Status</h3>
                <p>Status: <span id="status" class="status offline">Verbinde...</span></p>
                <p>Version: <span id="version">2.0.0</span></p>
                <p>Memory: <span id="memory-stats">Lädt...</span></p>
            </div>
            
            <div class="card">
                <h3>Statistiken</h3>
                <p>Konversationen: <span id="conversations">0</span></p>
                <p>Gelernte Muster: <span id="patterns">0</span></p>
                <p>Fehler behoben: <span id="fixes">0</span></p>
            </div>
            
            <div class="card">
                <h3>Aktionen</h3>
                <button onclick="createScreen()">📱 Screen erstellen</button>
                <button onclick="runTests()">🧪 Tests ausführen</button>
                <button onclick="deployApp()">🚀 App deployen</button>
            </div>
        </div>
        
        <div class="card">
            <h3>💬 Chat mit Jarviz</h3>
            <div class="chat-container">
                <div id="messages"></div>
                <div class="input-group">
                    <input type="text" id="input" placeholder="Schreibe einen Befehl..." />
                    <button onclick="sendMessage()">Senden</button>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h3>📦 Module</h3>
            <div id="modules" class="modules"></div>
        </div>
    </div>
    
    <script>
        const socket = io();
        
        // Verbindungsstatus
        socket.on('connect', () => {
            document.getElementById('status').textContent = 'Online';
            document.getElementById('status').className = 'status online';
            loadStats();
            loadModules();
        });
        
        socket.on('disconnect', () => {
            document.getElementById('status').textContent = 'Offline';
            document.getElementById('status').className = 'status offline';
        });
        
        // Chat
        function sendMessage() {
            const input = document.getElementById('input');
            const message = input.value.trim();
            
            if (!message) return;
            
            addMessage(message, 'user');
            
            fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message })
            })
            .then(res => res.json())
            .then(data => {
                addMessage(data.response, 'jarviz');
            })
            .catch(err => {
                addMessage('Fehler: ' + err.message, 'jarviz');
            });
            
            input.value = '';
        }
        
        function addMessage(text, sender) {
            const messages = document.getElementById('messages');
            const div = document.createElement('div');
            div.className = 'message ' + sender;
            div.textContent = text;
            messages.appendChild(div);
            messages.scrollTop = messages.scrollHeight;
        }
        
        // Stats laden
        async function loadStats() {
            try {
                const res = await fetch('/api/stats');
                const stats = await res.json();
                
                document.getElementById('conversations').textContent = stats.total_conversations || 0;
                document.getElementById('patterns').textContent = stats.total_patterns || 0;
                document.getElementById('fixes').textContent = stats.total_solutions || 0;
                document.getElementById('memory-stats').textContent = 
                    `${stats.total_file_changes || 0} Änderungen`;
            } catch (err) {
                console.error('Stats-Fehler:', err);
            }
        }
        
        // Module laden
        async function loadModules() {
            try {
                const res = await fetch('/api/modules');
                const modules = await res.json();
                
                const container = document.getElementById('modules');
                container.innerHTML = '';
                
                const moduleIcons = {
                    'profile_system': '👤',
                    'music_engine': '🎵',
                    'dating_system': '❤️',
                    'sport_coach': '💪',
                    'challenge_system': '⚡',
                    'gaming_engine': '🎮',
                    'avatar_ai': '🤖',
                    'tracking_system': '📍',
                    'fashion_ar': '👗',
                    'language_coach': '🗣️',
                    'live_streaming': '🔴',
                    'improvement_system': '💡'
                };
                
                for (const [name, status] of Object.entries(modules)) {
                    const div = document.createElement('div');
                    div.className = 'module' + (status.active ? ' active' : '');
                    div.innerHTML = `
                        <div class="module-icon">${moduleIcons[name] || '📦'}</div>
                        <div>${name.replace('_', ' ')}</div>
                    `;
                    container.appendChild(div);
                }
            } catch (err) {
                console.error('Module-Fehler:', err);
            }
        }
        
        // Aktionen
        async function createScreen() {
            const name = prompt('Screen-Name eingeben:');
            if (!name) return;
            
            const res = await sendCommand(`erstelle ${name} screen`);
            alert(res.response || 'Screen erstellt!');
        }
        
        async function runTests() {
            const res = await sendCommand('flutter test');
            alert(res.response || 'Tests gestartet!');
        }
        
        async function deployApp() {
            if (!confirm('App wirklich deployen?')) return;
            
            const res = await sendCommand('deploye app');
            alert(res.response || 'Deployment gestartet!');
        }
        
        async function sendCommand(command) {
            const res = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: command })
            });
            return await res.json();
        }
        
        // Enter-Taste für Chat
        document.getElementById('input').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });
        
        // Auto-Reload alle 30 Sekunden
        setInterval(() => {
            if (document.getElementById('status').className.includes('online')) {
                loadStats();
                loadModules();
            }
        }, 30000);
    </script>
</body>
</html>"""
    
    with open(template_dir / 'dashboard.html', 'w', encoding='utf-8') as f:
        f.write(dashboard_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} dashboard.html erstellt")
    
    # Zusätzliche Templates erstellen
    additional_templates = {
        'module_status.html': """<!DOCTYPE html>
<html>
<head>
    <title>MukkeApp Module Status</title>
    <style>
        body { background: #1a1a1a; color: #fff; font-family: Arial, sans-serif; }
        .module { padding: 10px; margin: 5px; border: 1px solid #00BFFF; border-radius: 5px; }
        .active { background: rgba(0, 255, 0, 0.2); }
    </style>
</head>
<body>
    <h1>MukkeApp Module Status</h1>
    <div id="modules"></div>
    <script>
        fetch('/api/modules')
            .then(res => res.json())
            .then(data => {
                const container = document.getElementById('modules');
                for (const [name, status] of Object.entries(data)) {
                    const div = document.createElement('div');
                    div.className = 'module' + (status.active ? ' active' : '');
                    div.textContent = name + ': ' + (status.active ? 'Aktiv' : 'Inaktiv');
                    container.appendChild(div);
                }
            });
    </script>
</body>
</html>""",
        
        'analytics.html': """<!DOCTYPE html>
<html>
<head>
    <title>MukkeApp Analytics</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background: #1a1a1a; color: #fff; font-family: Arial, sans-serif; padding: 20px; }
        #chart { max-width: 800px; margin: 0 auto; }
    </style>
</head>
<body>
    <h1>MukkeApp Analytics Dashboard</h1>
    <canvas id="chart"></canvas>
    <script>
        // Beispiel-Chart
        const ctx = document.getElementById('chart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
                datasets: [{
                    label: 'Aktive Nutzer',
                    data: [12, 19, 3, 5, 2, 3, 15],
                    borderColor: '#00BFFF',
                    backgroundColor: 'rgba(0, 191, 255, 0.1)'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { labels: { color: '#fff' } }
                },
                scales: {
                    y: { ticks: { color: '#fff' }, grid: { color: '#333' } },
                    x: { ticks: { color: '#fff' }, grid: { color: '#333' } }
                }
            }
        });
    </script>
</body>
</html>"""
    }
    
    for filename, content in additional_templates.items():
        with open(template_dir / filename, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  {Colors.GREEN}✓{Colors.ENDC} {filename}")
import logging
logger = logging.getLogger(__name__)

def create_module_files():
    """Erstellt Basis-Dateien für alle 12 MukkeApp Module"""
    print(f"\n{Colors.BLUE}📦 Erstelle MukkeApp Module...{Colors.ENDC}")
    
    modules = {
        'profile_system': {
            'name': 'Profile System',
            'description': 'Nutzerverwaltung und Konten',
            'main_class': 'ProfileManager'
        },
        'music_engine': {
            'name': 'Mukke Musik',
            'description': 'Musik-Streaming und KI-Generierung',
            'main_class': 'MusicEngine'
        },
        'dating_system': {
            'name': 'Mukke Dating',
            'description': 'KI-basiertes Dating System',
            'main_class': 'DatingManager'
        },
        'sport_coach': {
            'name': 'Mukke Sport',
            'description': 'Fitness-Tracking mit KI-Coach',
            'main_class': 'SportCoach'
        },
        'challenge_system': {
            'name': 'Real Challenge',
            'description': '1€ Challenges mit Live-Bewertung',
            'main_class': 'ChallengeManager'
        },
        'gaming_engine': {
            'name': 'Mukke Spiele',
            'description': '1€ Duelle und Minispiele',
            'main_class': 'GamingEngine'
        },
        'avatar_ai': {
            'name': 'Mukke Avatar',
            'description': 'Persönlicher KI-Avatar',
            'main_class': 'AvatarAI'
        },
        'tracking_system': {
            'name': 'Mukke Tracking',
            'description': 'Kinder-Tracking und Sicherheit',
            'main_class': 'TrackingSystem'
        },
        'fashion_ar': {
            'name': 'Mukke Mode',
            'description': 'AR Fashion Try-On',
            'main_class': 'FashionAR'
        },
        'language_coach': {
            'name': 'Mukke Sprache',
            'description': 'KI-Sprachlehrer',
            'main_class': 'LanguageCoach'
        },
        'live_streaming': {
            'name': 'Mukke Live',
            'description': 'Live-Streaming mit Übersetzung',
            'main_class': 'LiveStreaming'
        },
        'improvement_system': {
            'name': 'Verbesserungen',
            'description': 'Community-Voting für Features',
            'main_class': 'ImprovementSystem'
        }
    }
    
    for module_name, module_info in modules.items():
        module_dir = Path(f'app_modules/{module_name}')
        module_dir.mkdir(parents=True, exist_ok=True)
        
        # __init__.py
        init_content = f'''"""
{module_info['name']} - {module_info['description']}
Part of MukkeApp by Jarviz
"""

from .{module_name} import {module_info['main_class']}

__all__ = ['{module_info['main_class']}']
__version__ = '1.0.0'
'''
        
        with open(module_dir / '__init__.py', 'w', encoding='utf-8') as f:
            f.write(init_content)
        
        # Hauptmodul-Datei
        module_content = f'''"""
{module_info['name']} Module for MukkeApp
{module_info['description']}
"""

import json
import logging
from datetime import datetime
from pathlib import Path

class {module_info['main_class']}:
    def __init__(self):
        self.name = "{module_info['name']}"
        self.version = "1.0.0"
        self.status = "ready"
        logger.info(f"{module_info['name']} initialized")
        self.logger.info(f"{self.name} initialized")
        
    def process(self, data):
        """Process module-specific data"""
        logger.info(f"Processing data in {module_info['name']}")
        return {{"status": "success", "module": self.name}}
        
    def get_status(self):
        """Get module status"""
        return {{
            "name": self.name,
            "version": self.version,
            "status": self.status,
            "active": True
        }}
'''
        
        with open(module_dir / f'{module_name}.py', 'w', encoding='utf-8') as f:
            f.write(module_content)
        
        print(f"  {Colors.GREEN}✓{Colors.ENDC} {module_name}/ erstellt")

def create_jarviz_files():
    """Erstellt die Haupt-Jarviz-Dateien"""
    print(f"\n{Colors.BLUE}🤖 Erstelle Jarviz KI-Engine...{Colors.ENDC}")
    
    # Jarviz-Verzeichnis
    jarviz_dir = Path('ai_engine')
    jarviz_dir.mkdir(exist_ok=True)
    
    # jarviz_core.py
    jarviz_core = '''"""
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
        
        self.logger.info(f"Jarviz v{self.version} initialized")
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
        self.logger.info(f"Processing command: {command}")
        
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
        self.logger.info("Creating Flutter component")
        
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
        self.logger.info("Running Flutter tests")
        
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
                return f"❌ Test-Fehler: {error_msg[:200]}\\n\\n💡 Lösungsvorschlag: {solution}"
                
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
        self.logger.info("Starting Flutter app")
        
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
        self.logger.info("Stopping Flutter app")
        
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
        self.logger.info("Deploying app")
        
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
                return '\\n'.join(steps)
            
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
            
            return '\\n'.join(steps)
            
        except Exception as e:
            steps.append(f"❌ Deployment-Fehler: {e}")
            return '\\n'.join(steps)
    
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
            return result.stdout.split('\\n')[0] if result.returncode == 0 else 'Unknown'
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
            status_str += f"  {emoji} {name}: {info['status']}\\n"
        return status_str

# Globale Instanz
jarviz = JarvizCore()
'''
    
    with open(jarviz_dir / 'jarviz_core.py', 'w', encoding='utf-8') as f:
        f.write(jarviz_core)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} jarviz_core.py")
    
    # __init__.py
    init_content = '''"""
Jarviz AI Engine for MukkeApp
Selbstlernende KI für automatisierte App-Entwicklung
"""

from .jarviz_core import jarviz, JarvizCore

__all__ = ['jarviz', 'JarvizCore']
__version__ = '2.0.0'
'''
    
    with open(jarviz_dir / '__init__.py', 'w', encoding='utf-8') as f:
        f.write(init_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} __init__.py")

def create_server_files():
    """Erstellt Server-Dateien"""
    print(f"\n{Colors.BLUE}🌐 Erstelle Server...{Colors.ENDC}")
    
    server_dir = Path('server')
    server_dir.mkdir(exist_ok=True)
    
    # server.py
    server_content = '''"""
MukkeApp Jarviz Server
WebSocket und REST API Server
"""

import os
import sys
from pathlib import Path

# Pfad Setup
sys.path.append(str(Path(__file__).parent.parent))

from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_socketio import SocketIO, emit
from flask_cors import CORS
import logging
from datetime import datetime

# Jarviz importieren
from ai_engine import jarviz

# Flask App
app = Flask(__name__, 
    template_folder='../templates',
    static_folder='../static'
)
app.config['SECRET_KEY'] = os.getenv('FLASK_SECRET_KEY', 'mukke-app-secret-2024')

# CORS aktivieren
CORS(app)

# SocketIO
socketio = SocketIO(app, cors_allowed_origins="*")

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Routes
@app.route('/')
def index():
    """Dashboard"""
    return render_template('dashboard.html')

@app.route('/api/status')
def api_status():
    """API Status"""
    return jsonify({
        'status': 'online',
        'version': '2.0.0',
        'jarviz_status': jarviz.status,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/chat', methods=['POST'])
def api_chat():
    """Chat mit Jarviz"""
    data = request.json
    message = data.get('message', '')
    
    if not message:
        return jsonify({'error': 'No message provided'}), 400
    
    # Jarviz verarbeiten lassen
    response = jarviz.process_command(message)
    
    # Via WebSocket broadcasten
    socketio.emit('jarviz_response', {
        'message': message,
        'response': response,
        'timestamp': datetime.now().isoformat()
    })
    
    return jsonify({
        'response': response,
        'status': 'success'
    })

@app.route('/api/modules')
def api_modules():
    """Module Status"""
    return jsonify(jarviz.modules)

@app.route('/api/stats')
def api_stats():
    """Statistiken"""
    return jsonify({
        'total_conversations': len(jarviz.conversation_history),
        'total_patterns': len(jarviz.code_patterns),
        'total_solutions': len(jarviz.error_solutions),
        'total_file_changes': len(jarviz.file_changes)
    })

# WebSocket Events
@socketio.on('connect')
def handle_connect():
    """Client verbunden"""
    logger.info(f"Client connected: {request.sid}")
    emit('connected', {'data': 'Connected to Jarviz'})

@socketio.on('disconnect')
def handle_disconnect():
    """Client getrennt"""
    logger.info(f"Client disconnected: {request.sid}")

@socketio.on('command')
def handle_command(data):
    """Befehl via WebSocket"""
    message = data.get('message', '')
    response = jarviz.process_command(message)
    
    emit('response', {
        'response': response,
        'timestamp': datetime.now().isoformat()
    })

# Server starten
def run_server(host='0.0.0.0', port=5000, debug=True):
    """Startet den Server"""
    logger.info(f"Starting Jarviz Server on {host}:{port}")
    socketio.run(app, host=host, port=port, debug=debug)

if __name__ == '__main__':
    run_server()
'''
    
    with open(server_dir / 'server.py', 'w', encoding='utf-8') as f:
        f.write(server_content)
    print(f"  {Colors.GREEN}✓{Colors.ENDC} server.py")
    
    # __init__.py
    with open(server_dir / '__init__.py', 'w', encoding='utf-8') as f:
        f.write('"""MukkeApp Server Package"""')
    print(f"  {Colors.GREEN}✓{Colors.ENDC} __init__.py")

def start_jarviz_server():
    """Startet den Jarviz-Server"""
    print(f"\n{Colors.BLUE}🚀 Starte Jarviz-Server...{Colors.ENDC}")
    
    # Server-Prozess starten
    server_process = subprocess.Popen(
        [sys.executable, 'server/server.py'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    # Warte kurz
    time.sleep(3)
    
    # Prüfe ob Server läuft
    if server_process.poll() is None:
        print(f"  {Colors.GREEN}✓{Colors.ENDC} Server läuft auf http://localhost:5000")
        
        # Dashboard im Browser öffnen
        print(f"\n{Colors.CYAN}🌐 Öffne Dashboard...{Colors.ENDC}")
        webbrowser.open('http://localhost:5000')
        
        return server_process
    else:
        print(f"  {Colors.RED}✗{Colors.ENDC} Server konnte nicht gestartet werden")
        stdout, stderr = server_process.communicate()
        if stderr:
            print(f"  {Colors.YELLOW}Fehler: {stderr.decode()}{Colors.ENDC}")
        return None

def main():
    """Hauptfunktion"""
    print_banner()
    
    # System erkennen
    system_info = detect_system()
    
    # Requirements prüfen
    if not check_requirements():
        print(f"\n{Colors.YELLOW}⚠ Einige Anforderungen fehlen. Installation kann fortgesetzt werden.{Colors.ENDC}")
        response = input(f"\n{Colors.CYAN}Trotzdem fortfahren? (j/n): {Colors.ENDC}")
        if response.lower() != 'j':
            print(f"\n{Colors.RED}Installation abgebrochen.{Colors.ENDC}")
            return
    
    # Dependencies installieren
    install_dependencies()
    
    # Struktur erstellen
    create_complete_structure()
    
    # Konfigurationsdateien
    create_configuration_files()
    
    # Memory-System
    create_memory_files()
    
    # Flutter-Projekt
    create_flutter_project()
    
    # Dashboard und Templates
    copy_dashboard_and_templates()
    
    # Module erstellen
    create_module_files()
    
    # Jarviz-Engine
    create_jarviz_files()
    
    # Server erstellen
    create_server_files()
    
    # Zusammenfassung
    print(f"\n{Colors.GREEN}{'=' * 80}{Colors.ENDC}")
    print(f"{Colors.BOLD}✅ MukkeApp Jarviz System erfolgreich installiert!{Colors.ENDC}")
    print(f"{Colors.GREEN}{'=' * 80}{Colors.ENDC}")
    
    print(f"\n{Colors.CYAN}📋 Nächste Schritte:{Colors.ENDC}")
    print(f"  1. API-Keys in .env eintragen")
    print(f"  2. Firebase-Credentials aktualisieren")
    print(f"  3. Flutter-Dependencies installieren")
    
    # Server starten?
    response = input(f"\n{Colors.CYAN}Jarviz-Server jetzt starten? (j/n): {Colors.ENDC}")
    if response.lower() == 'j':
        server_process = start_jarviz_server()
        
        if server_process:
            print(f"\n{Colors.GREEN}✅ Jarviz ist bereit!{Colors.ENDC}")
            print(f"{Colors.YELLOW}Drücke Strg+C zum Beenden.{Colors.ENDC}")
            
            try:
                # Server laufen lassen
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                print(f"\n{Colors.YELLOW}Beende Server...{Colors.ENDC}")
                server_process.terminate()
                print(f"{Colors.GREEN}✅ Server beendet.{Colors.ENDC}")
    else:
        print(f"\n{Colors.CYAN}Server kann später mit folgendem Befehl gestartet werden:{Colors.ENDC}")
        print(f"  python server/server.py")
    
    print(f"\n{Colors.MAGENTA}Viel Erfolg mit MukkeApp! 🚀{Colors.ENDC}")

if __name__ == "__main__":
    main()