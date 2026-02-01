import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

import '../utils/constants.dart';

class MukkeAvatarScreen extends StatefulWidget {
  const MukkeAvatarScreen({super.key});

  @override
  State<MukkeAvatarScreen> createState() => _MukkeAvatarScreenState();
}

class _MukkeAvatarScreenState extends State<MukkeAvatarScreen>
    with TickerProviderStateMixin {
  // Camera & Permissions
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isMirrorMode = false;

  // Speech & TTS
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _speechText = '';

  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Avatar State
  String _avatarName = 'Jarviz';
  String _avatarMood = 'happy';
  String _lastAdvice = '';
  Map<String, dynamic> _avatarPersonality = {
    'humor': 0.8,
    'empathy': 0.9,
    'creativity': 0.7,
    'supportiveness': 1.0,
  };

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _waveController;

  // UI State
  bool _isAnalyzing = false;
  bool _showChat = false;
  final List<Map<String, String>> _chatMessages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // OpenAI API Key - In einer echten App sollte dies sicher gespeichert werden!
  static const String _openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAvatar();
    _setupTTS();
    _checkPermissions();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeAvatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Lade Avatar-Einstellungen
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('avatar')
          .doc('settings')
          .get();

      if (doc.exists) {
        setState(() {
          _avatarName = doc.data()?['name'] ?? 'Jarviz';
          _avatarPersonality = doc.data()?['personality'] ?? _avatarPersonality;
        });
      }

      // Begrüßung
      _speak(
          'Hallo! Ich bin $_avatarName, dein persönlicher KI-Begleiter. Wie kann ich dir heute helfen?');
    } catch (e) {
      print('Avatar initialization error: $e');
    }
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage('de-DE');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _initializeCamera();
      await _initializeSpeech();
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        // Front camera für Spiegel-Modus
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (!available) {
        print('Speech recognition not available');
      }
    } catch (e) {
      print('Speech initialization error: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Berechtigungen benötigt',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Der Avatar benötigt Zugriff auf Kamera und Mikrofon für die volle Funktionalität.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Später'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Einstellungen öffnen'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMirrorMode() async {
    if (!_isCameraInitialized) {
      await _checkPermissions();
      return;
    }

    setState(() {
      _isMirrorMode = !_isMirrorMode;
    });

    if (_isMirrorMode) {
      _speak('Spiegel-Modus aktiviert. Lass mich dein Outfit analysieren!');
      HapticFeedback.mediumImpact();

      // Starte Outfit-Analyse nach 2 Sekunden
      Future.delayed(const Duration(seconds: 2), () {
        _analyzeOutfit();
      });
    } else {
      _speak('Spiegel-Modus deaktiviert.');
    }
  }

  Future<void> _analyzeOutfit() async {
    if (!_isMirrorMode || _cameraController == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Foto aufnehmen
      final image = await _cameraController!.takePicture();

      // OpenAI Vision API für Outfit-Analyse
      final analysis = await _analyzeImageWithAI(File(image.path));

      setState(() {
        _isAnalyzing = false;
        _lastAdvice = analysis;
      });

      // Zeige Analyse
      _showStyleAnalysis(analysis);
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _speak('Entschuldigung, bei der Analyse ist ein Fehler aufgetreten.');
    }
  }

  Future<String> _analyzeImageWithAI(File imageFile) async {
    try {
      // Bild zu Base64 konvertieren
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // OpenAI API Call
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'system',
              'content': 'Du bist ein freundlicher, humorvoller Modeberater namens $_avatarName. '
                  'Analysiere das Outfit und gib konstruktives, positives Feedback. '
                  'Sei ehrlich aber immer ermutigend. Verwende Emojis und sei persönlich.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analysiere mein Outfit und gib mir Stil-Tipps!'
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('AI Analysis error: $e');
      // Fallback-Antwort
      return 'Du siehst heute richtig gut aus! Du geiles Stück '
          'Was brauchst du Heute? Vielleicht was zum ausgehen? '
          'Mit einer schönen Uhr oder eine Kette könnte das Outfit noch mehr aufwerten!';
    }
  }

  void _showStyleAnalysis(String analysis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceDark,
              AppColors.background,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.accent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.face,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Style-Analyse von $_avatarName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      analysis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _analyzeOutfit();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Neue Analyse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveStyleAdvice(analysis);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Speichern'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    _speak(analysis);
  }

  Future<void> _saveStyleAdvice(String advice) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('style_history')
          .add({
        'advice': advice,
        'timestamp': FieldValue.serverTimestamp(),
        'avatarMood': _avatarMood,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Style-Tipp gespeichert!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Save error: $e');
    }
  }

  void _toggleChat() {
    setState(() {
      _showChat = !_showChat;
    });

    if (_showChat && _chatMessages.isEmpty) {
      _addChatMessage(
          'assistant', 'Hey! Ich bin $_avatarName. Frag mich alles! 😊');
    }
  }

  void _startListening() async {
    if (!_isListening && _speech.isAvailable) {
      setState(() => _isListening = true);

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _speechText = result.recognizedWords;
          });

          if (result.finalResult) {
            _processSpeechInput(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'de_DE',
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  void _processSpeechInput(String input) {
    _addChatMessage('user', input);
    _generateAIResponse(input);
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isEmpty) return;

    final message = _chatController.text.trim();
    _addChatMessage('user', message);
    _chatController.clear();

    _generateAIResponse(message);
  }

  void _addChatMessage(String sender, String message) {
    setState(() {
      _chatMessages.add({
        'sender': sender,
        'message': message,
        'timestamp': DateTime.now().toString(),
      });
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _generateAIResponse(String userInput) async {
    try {
      // Zeige Typing-Indikator
      _addChatMessage('assistant', '...');

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Du bist $_avatarName, ein freundlicher KI-Avatar in der MukkeApp. '
                      'Persönlichkeit: Humor ${_avatarPersonality["humor"]}, '
                      'Empathie ${_avatarPersonality["empathy"]}, '
                      'Kreativität ${_avatarPersonality["creativity"]}, '
                      'Unterstützung ${_avatarPersonality["supportiveness"]}. '
                      'Sei persönlich, verwende Emojis und halte Antworten kurz aber hilfreich.'
            },
            {'role': 'user', 'content': userInput}
          ],
          'max_tokens': 150,
          'temperature': 0.8,
        }),
      );

      // Entferne Typing-Indikator
      setState(() {
        _chatMessages.removeLast();
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        _addChatMessage('assistant', aiResponse);
        _speak(aiResponse);

        // Update Avatar Mood basierend auf Konversation
        _updateAvatarMood(userInput, aiResponse);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      // Entferne Typing-Indikator bei Fehler
      setState(() {
        if (_chatMessages.isNotEmpty &&
            _chatMessages.last['message'] == '...') {
          _chatMessages.removeLast();
        }
      });

      print('AI Response error: $e');
      _addChatMessage('assistant',
          'Ups, da ist etwas schief gelaufen. Versuch es nochmal! 😅');
    }
  }

  void _updateAvatarMood(String userInput, String aiResponse) {
    // Einfache Stimmungsanalyse
    final lowerInput = userInput.toLowerCase();

    if (lowerInput.contains('traurig') || lowerInput.contains('schlecht')) {
      setState(() => _avatarMood = 'empathetic');
    } else if (lowerInput.contains('super') || lowerInput.contains('toll')) {
      setState(() => _avatarMood = 'excited');
    } else if (lowerInput.contains('hilfe') || lowerInput.contains('problem')) {
      setState(() => _avatarMood = 'helpful');
    } else {
      setState(() => _avatarMood = 'happy');
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  IconData _getAvatarIcon() {
    switch (_avatarMood) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'excited':
        return Icons.sentiment_very_satisfied_outlined;
      case 'empathetic':
        return Icons.sentiment_satisfied;
      case 'helpful':
        return Icons.support_agent;
      default:
        return Icons.face;
    }
  }

  void _showStyleHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleHistoryScreen(avatarName: _avatarName),
      ),
    );
  }

  void _showAvatarSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: AvatarSettingsSheet(
          avatarName: _avatarName,
          personality: _avatarPersonality,
          onSave: (name, personality) {
            setState(() {
              _avatarName = name;
              _avatarPersonality = personality;
            });
            _saveAvatarSettings();
          },
        ),
      ),
    );
  }

  Future<void> _saveAvatarSettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('avatar')
          .doc('settings')
          .set({
        'name': _avatarName,
        'personality': _avatarPersonality,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _speak(
          'Super! Ich bin jetzt $_avatarName und freue mich auf unsere gemeinsame Zeit!');
    } catch (e) {
      print('Save settings error: $e');
    }
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Chat Messages
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              final isUser = message['sender'] == 'user';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isUser) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          _getAvatarIcon(),
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : AppColors.surfaceDark,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isUser ? 20 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 20),
                          ),
                        ),
                        child: Text(
                          message['message']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.accent,
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Chat Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _startListening,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : AppColors.primary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        _isListening ? _speechText : 'Nachricht schreiben...',
                    hintStyle: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),
                    filled: true,
                    fillColor: Color.fromRGBO(0, 0, 0, 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendChatMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMirrorOverlay() {
    return Stack(
      children: [
        // Camera Preview
        if (_cameraController != null && _isCameraInitialized)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),

        // Overlay UI
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.7),
                ],
              ),
            ),
          ),
        ),

        // Top Controls
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: _toggleMirrorMode,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Spiegel-Modus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Analysis Overlay
        if (_isAnalyzing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Analysiere dein Outfit...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KI-Magic in Arbeit ✨',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bottom Action Button
        if (!_isAnalyzing)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _analyzeOutfit,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Outfit analysieren',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mukke Avatar - $_avatarName'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showChat ? Icons.close : Icons.chat,
              color: AppColors.primary,
            ),
            onPressed: _toggleChat,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animierter Hintergrund
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: AvatarBackgroundPainter(
                  animation: _waveController.value,
                  primaryColor: AppColors.primary,
                  accentColor: AppColors.accent,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Hauptinhalt
          if (!_showChat) _buildMainView() else _buildChatView(),

          // Spiegel-Overlay
          if (_isMirrorMode) _buildMirrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar Display
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow Effect
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.5 * _glowController.value),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: AppColors.accent
                              .withOpacity(0.3 * _glowController.value),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Avatar Container
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, math.sin(_floatController.value * math.pi) * 10),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.05),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Avatar Face
                                Icon(
                                  _getAvatarIcon(),
                                  size: 80,
                                  color: Colors.white,
                                ),

                                // Speaking Indicator
                                if (_isListening)
                                  Positioned(
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.mic,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Hört zu',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Avatar Name & Status
          Text(
            _avatarName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dein persönlicher KI-Begleiter',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 40),

          // Feature Cards
          _buildFeatureCard(
            icon: Icons.camera_alt,
            title: 'Spiegel-Modus',
            subtitle: 'Outfit-Analyse & Style-Tipps',
            onTap: _toggleMirrorMode,
            gradient: [AppColors.primary, AppColors.accent],
          ),

          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.mic,
            title: 'Sprachsteuerung',
            subtitle: 'Sprich mit deinem Avatar',
            onTap: _startListening,
            gradient: [AppColors.accent, Colors.purple],
          ),

          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.style,
            title: 'Style-Historie',
            subtitle: 'Deine gespeicherten Looks',
            onTap: _showStyleHistory,
            gradient: [Colors.purple, AppColors.primary],
          ),

          const SizedBox(height: 16),

          _buildFeatureCard(
            icon: Icons.settings,
            title: 'Avatar anpassen',
            subtitle: 'Persönlichkeit & Aussehen',
            onTap: _showAvatarSettings,
            gradient: [Colors.orange, Colors.red],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withOpacity(0.2)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient[0].withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Style History Screen
class StyleHistoryScreen extends StatelessWidget {
  final String avatarName;

  const StyleHistoryScreen({
    super.key,
    required this.avatarName,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Style-Historie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('style_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Style-Tipps gespeichert',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.style,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timestamp != null
                              ? '${timestamp.day}.${timestamp.month}.${timestamp.year}'
                              : 'Datum unbekannt',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['advice'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Avatar Settings Sheet
class AvatarSettingsSheet extends StatefulWidget {
  final String avatarName;
  final Map<String, dynamic> personality;
  final Function(String, Map<String, dynamic>) onSave;

  const AvatarSettingsSheet({
    super.key,
    required this.avatarName,
    required this.personality,
    required this.onSave,
  });

  @override
  State<AvatarSettingsSheet> createState() => _AvatarSettingsSheetState();
}

class _AvatarSettingsSheetState extends State<AvatarSettingsSheet> {
  late TextEditingController _nameController;
  late Map<String, double> _personality;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.avatarName);
    _personality = Map<String, double>.from(
      widget.personality.map((key, value) => MapEntry(key, value.toDouble())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Avatar anpassen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Avatar Name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Persönlichkeit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Persönlichkeits-Slider
            ..._personality.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getPersonalityLabel(entry.key),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: AppColors.accent,
                      overlayColor: AppColors.accent.withOpacity(0.3),
                    ),
                    child: Slider(
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          _personality[entry.key] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_nameController.text, _personality);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Speichern',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPersonalityLabel(String key) {
    switch (key) {
      case 'humor':
        return '😄 Humor';
      case 'empathy':
        return '❤️ Empathie';
      case 'creativity':
        return '🎨 Kreativität';
      case 'supportiveness':
        return '🤝 Unterstützung';
      default:
        return key;
    }
  }
}

// Background Painter
class AvatarBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;

  AvatarBackgroundPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Animated Gradient Circles
    for (int i = 0; i < 3; i++) {
      final progress = (animation + i * 0.33) % 1.0;
      final radius = 100 + (i * 50.0);
      final opacity = (1 - progress) * 0.1;

      paint.shader = RadialGradient(
        colors: [
          i % 2 == 0
              ? primaryColor.withOpacity(opacity)
              : accentColor.withOpacity(opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(
          size.width * (0.2 + i * 0.3),
          size.height * progress,
        ),
        radius: radius,
      ));

      canvas.drawCircle(
        Offset(
          size.width * (0.2 + i * 0.3),
          size.height * progress,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
