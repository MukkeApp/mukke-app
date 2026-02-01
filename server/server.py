"""
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
