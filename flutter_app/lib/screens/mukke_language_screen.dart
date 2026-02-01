import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

import '../utils/constants.dart';

class MukkeLanguageScreen extends StatefulWidget {
  const MukkeLanguageScreen({super.key});

  @override
  _MukkeLanguageScreenState createState() => _MukkeLanguageScreenState();
}

class _MukkeLanguageScreenState extends State<MukkeLanguageScreen>
    with TickerProviderStateMixin {
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Speech & TTS
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final bool _isListening = false;
  final String _spokenText = '';

  // Camera for translation
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final bool _isTranslating = false;
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _progressController;
  late AnimationController _glowController;

  // Language Learning State
  String _selectedLanguage = '';
  String _selectedLanguageCode = '';
  int _currentLevel = 1;
  int _currentXP = 0;
  int _streak = 0;
  Map<String, dynamic> _userProgress = {};

  // Current Lesson
  Map<String, dynamic>? _currentLesson;
  final int _currentQuestionIndex = 0;
  final int _correctAnswers = 0;

  // Available Languages
  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'Englisch',
      'code': 'en',
      'flag': '🇬🇧',
      'icon': Icons.language,
      'color': const Color(0xFF1E88E5),
      'difficulty': 'Einfach',
      'users': 1250000,
    },
    {
      'name': 'Spanisch',
      'code': 'es',
      'flag': '🇪🇸',
      'icon': Icons.wb_sunny,
      'color': const Color(0xFFF44336),
      'difficulty': 'Mittel',
      'users': 890000,
    },
    {
      'name': 'Französisch',
      'code': 'fr',
      'flag': '🇫🇷',
      'icon': Icons.local_cafe,
      'color': const Color(0xFF3F51B5),
      'difficulty': 'Mittel',
      'users': 650000,
    },
    {
      'name': 'Italienisch',
      'code': 'it',
      'flag': '🇮🇹',
      'icon': Icons.local_pizza,
      'color': const Color(0xFF4CAF50),
      'difficulty': 'Mittel',
      'users': 420000,
    },
    {
      'name': 'Portugiesisch',
      'code': 'pt',
      'flag': '🇵🇹',
      'icon': Icons.beach_access,
      'color': const Color(0xFF009688),
      'difficulty': 'Mittel',
      'users': 380000,
    },
    {
      'name': 'Niederländisch',
      'code': 'nl',
      'flag': '🇳🇱',
      'icon': Icons.directions_bike,
      'color': const Color(0xFFFF9800),
      'difficulty': 'Mittel',
      'users': 220000,
    },
    {
      'name': 'Russisch',
      'code': 'ru',
      'flag': '🇷🇺',
      'icon': Icons.ac_unit,
      'color': const Color(0xFF9C27B0),
      'difficulty': 'Schwer',
      'users': 340000,
    },
    {
      'name': 'Japanisch',
      'code': 'ja',
      'flag': '🇯🇵',
      'icon': Icons.local_florist,
      'color': const Color(0xFFE91E63),
      'difficulty': 'Schwer',
      'users': 520000,
    },
    {
      'name': 'Koreanisch',
      'code': 'ko',
      'flag': '🇰🇷',
      'icon': Icons.music_note,
      'color': const Color(0xFF00BCD4),
      'difficulty': 'Schwer',
      'users': 480000,
    },
    {
      'name': 'Chinesisch',
      'code': 'zh',
      'flag': '🇨🇳',
      'icon': Icons.local_dining,
      'color': const Color(0xFFF44336),
      'difficulty': 'Sehr Schwer',
      'users': 750000,
    },
  ];

  // Lesson Types
  final List<Map<String, dynamic>> _lessonTypes = [
    {
      'id': 'alphabet',
      'name': 'Alphabet & Basics',
      'icon': Icons.abc,
      'color': const Color(0xFF4CAF50),
      'description': 'Lerne die Grundlagen',
    },
    {
      'id': 'daily',
      'name': 'Alltagssituationen',
      'icon': Icons.chat_bubble,
      'color': const Color(0xFF2196F3),
      'description': 'Praktische Gespräche',
    },
    {
      'id': 'travel',
      'name': 'Reisen & Tourismus',
      'icon': Icons.flight,
      'color': const Color(0xFFFF9800),
      'description': 'Für deine nächste Reise',
    },
    {
      'id': 'business',
      'name': 'Business & Beruf',
      'icon': Icons.business,
      'color': const Color(0xFF9C27B0),
      'description': 'Professionelle Kommunikation',
    },
    {
      'id': 'kids',
      'name': 'Kinder-Modus',
      'icon': Icons.child_care,
      'color': const Color(0xFFE91E63),
      'description': 'Spielerisch lernen',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
    _loadUserProgress();
    _checkCameraPermission();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
    await _flutterTts.setLanguage('de-DE');
  }

  Future<void> _loadUserProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('language_progress')
          .doc('stats')
          .get();

      if (doc.exists) {
        setState(() {
          _userProgress = doc.data()!;
          _streak = _userProgress['streak'] ?? 0;
          _currentXP = _userProgress['totalXP'] ?? 0;
          _currentLevel = (_currentXP / 1000).floor() + 1;
        });
      }
    } catch (e) {
      print('Load progress error: $e');
    }
  }

  Future<void> _checkCameraPermission() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void _selectLanguage(Map<String, dynamic> language) {
    setState(() {
      _selectedLanguage = language['name'];
      _selectedLanguageCode = language['code'];
    });

    HapticFeedback.mediumImpact();
    _showLessonTypeSelection();
  }

  void _showLessonTypeSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
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
              Text(
                '$_selectedLanguage lernen',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Wähle deinen Lernbereich',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _lessonTypes.length,
                  itemBuilder: (context, index) {
                    final type = _lessonTypes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _startLesson(type['id']);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              type['color'].withOpacity(0.2),
                              type['color'].withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: type['color'].withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: type['color'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                type['icon'],
                                color: type['color'],
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    type['description'],
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLesson(String lessonType) {
    // Generate lesson content based on type
    _generateLesson(lessonType);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          language: _selectedLanguage,
          languageCode: _selectedLanguageCode,
          lessonType: lessonType,
          lesson: _currentLesson!,
          onComplete: _onLessonComplete,
        ),
      ),
    );
  }

  void _generateLesson(String lessonType) {
    // Sample lesson structure (would be fetched from API)
    _currentLesson = {
      'type': lessonType,
      'questions': [
        {
          'type': 'translate',
          'question': 'Hallo',
          'answer': 'Hello',
          'options': ['Hello', 'Goodbye', 'Thanks', 'Please'],
        },
        {
          'type': 'speak',
          'phrase': 'Wie geht es dir?',
          'translation': 'How are you?',
        },
        {
          'type': 'listen',
          'audio': 'Good morning',
          'options': [
            'Guten Morgen',
            'Gute Nacht',
            'Guten Tag',
            'Auf Wiedersehen'
          ],
          'correct': 0,
        },
      ],
    };
  }

  void _onLessonComplete(int score, int totalQuestions) {
    final xpEarned = score * 10;
    setState(() {
      _currentXP += xpEarned;
      _currentLevel = (_currentXP / 1000).floor() + 1;
    });

    _saveProgress(xpEarned, score, totalQuestions);
    _showCompletionDialog(score, totalQuestions, xpEarned);
  }

  Future<void> _saveProgress(int xpEarned, int score, int total) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('language_progress')
          .doc('stats')
          .set({
        'totalXP': FieldValue.increment(xpEarned),
        'lessonsCompleted': FieldValue.increment(1),
        'lastLesson': FieldValue.serverTimestamp(),
        'streak': _calculateStreak(),
        _selectedLanguageCode: {
          'xp': FieldValue.increment(xpEarned),
          'lessons': FieldValue.increment(1),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Save progress error: $e');
    }
  }

  int _calculateStreak() {
    // Simple streak calculation (would be more complex in production)
    return _streak + 1;
  }

  void _showCompletionDialog(int score, int total, int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      score >= total * 0.8 ? Colors.green : Colors.orange,
                      score >= total * 0.8 ? Colors.lightGreen : Colors.amber,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  score >= total * 0.8 ? Icons.star : Icons.thumb_up,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                score >= total * 0.8 ? 'Ausgezeichnet!' : 'Gut gemacht!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$score von $total richtig',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$xp XP',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Zurück'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startLesson(_currentLesson!['type']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Nochmal'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTranslator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveTranslatorScreen(
          cameraController: _cameraController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    _speech.stop();
    _flutterTts.stop();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Stats
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated Background
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LanguageWavePainter(
                          animation: _waveController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          const Text(
                            'Mukke Sprachen',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lerne mit KI-Avatar & Live-Übersetzung',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            children: [
                              _buildStatChip(
                                icon: Icons.local_fire_department,
                                label: '$_streak Tage',
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                icon: Icons.star,
                                label: 'Level $_currentLevel',
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                icon: Icons.bolt,
                                label: '$_currentXP XP',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Translator Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _startTranslator,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.1),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.translate,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Übersetzer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Kamera-Übersetzung & Spracherkennung',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Section Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Wähle eine Sprache',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Languages Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final language = _languages[index];
                  return _buildLanguageCard(language);
                },
                childCount: _languages.length,
              ),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    final progress = _userProgress[language['code']] ?? {};
    final languageXP = progress['xp'] ?? 0;
    final languageLevel = (languageXP / 500).floor() + 1;

    return GestureDetector(
      onTap: () => _selectLanguage(language),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  language['color'].withOpacity(0.3),
                  language['color'].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: language['color'].withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: language['color'].withOpacity(
                    0.2 + (_glowController.value * 0.1),
                  ),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language['flag'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          if (languageXP > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Lvl $languageLevel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        language['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language['difficulty'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),

                      // Progress Bar
                      if (languageXP > 0) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (languageXP % 500) / 500,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              language['color'],
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$languageXP XP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(language['users'] / 1000).toStringAsFixed(0)}k lernen',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // NEW Badge
                if (languageXP == 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Lesson Screen
class LessonScreen extends StatefulWidget {
  final String language;
  final String languageCode;
  final String lessonType;
  final Map<String, dynamic> lesson;
  final Function(int, int) onComplete;

  const LessonScreen({
    super.key,
    required this.language,
    required this.languageCode,
    required this.lessonType,
    required this.lesson,
    required this.onComplete,
  });

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  late AnimationController _progressController;
  late AnimationController _correctController;
  late AnimationController _wrongController;

  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _isAnswering = false;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _correctController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _wrongController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeTTS();
    _speech.initialize();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage(widget.languageCode);
    await _flutterTts.setSpeechRate(0.4);
  }

  void _checkAnswer(String answer) {
    if (_isAnswering) return;

    setState(() {
      _isAnswering = true;
      _showResult = true;
    });

    final question = widget.lesson['questions'][_currentQuestionIndex];
    _isCorrect = answer == question['answer'] ||
        answer == question['options'][question['correct']];

    if (_isCorrect) {
      _correctAnswers++;
      _correctController.forward();
      HapticFeedback.lightImpact();
    } else {
      _wrongController.forward().then((_) {
        _wrongController.reverse();
      });
      HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.lesson['questions'].length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswering = false;
        _showResult = false;
        _isCorrect = false;
      });
      _correctController.reset();
      _progressController.forward();
    } else {
      widget.onComplete(_correctAnswers, widget.lesson['questions'].length);
    }
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson['questions'][_currentQuestionIndex];
    final progress =
        (_currentQuestionIndex + 1) / widget.lesson['questions'].length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Text(
              widget.language,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Frage ${_currentQuestionIndex + 1} von ${widget.lesson['questions'].length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCorrect ? Colors.green : AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          // Question Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildQuestionContent(question),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'translate':
        return _buildTranslateQuestion(question);
      case 'speak':
        return _buildSpeakQuestion(question);
      case 'listen':
        return _buildListenQuestion(question);
      default:
        return Container();
    }
  }

  Widget _buildTranslateQuestion(Map<String, dynamic> question) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Question
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Übersetze:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question['question'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Options
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              final option = question['options'][index];
              final isSelected = _showResult && option == question['answer'];
              final isWrong = _showResult && !isSelected && _isAnswering;

              return AnimatedBuilder(
                animation: isSelected ? _correctController : _wrongController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isSelected
                        ? 1.0 + (_correctController.value * 0.1)
                        : 1.0,
                    child: GestureDetector(
                      onTap: () => _checkAnswer(option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withOpacity(0.3)
                              : isWrong
                                  ? Colors.red.withOpacity(0.3)
                                  : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : isWrong
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: isSelected || isWrong
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Result Feedback
        if (_showResult)
          AnimatedBuilder(
            animation: _isCorrect ? _correctController : _wrongController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isCorrect ? _correctController.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isCorrect ? 'Richtig!' : 'Falsch!',
                        style: TextStyle(
                          color: _isCorrect ? Colors.green : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSpeakQuestion(Map<String, dynamic> question) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Instruction
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.mic,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sprich diesen Satz nach:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question['phrase'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '(${question['translation']})',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Play Button
        GestureDetector(
          onTap: () => _speak(question['phrase']),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.volume_up,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),

        const Spacer(),

        // Record Button
        GestureDetector(
          onTap: () {
            // Start recording
            _checkAnswer('correct'); // Simplified for demo
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
                SizedBox(width: 12),
                Text(
                  'Aufnahme starten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenQuestion(Map<String, dynamic> question) {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Instruction
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.headphones,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Höre zu und wähle die richtige Übersetzung:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _speak(question['audio']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Nochmal abspielen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Options
        Expanded(
          child: ListView.builder(
            itemCount: question['options'].length,
            itemBuilder: (context, index) {
              final option = question['options'][index];
              final isCorrect = index == question['correct'];
              final isSelected = _showResult && isCorrect;

              return GestureDetector(
                onTap: () => _checkAnswer(option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.withOpacity(0.3)
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Live Translator Screen
class LiveTranslatorScreen extends StatefulWidget {
  final CameraController? cameraController;

  const LiveTranslatorScreen({
    super.key,
    this.cameraController,
  });

  @override
  _LiveTranslatorScreenState createState() => _LiveTranslatorScreenState();
}

class _LiveTranslatorScreenState extends State<LiveTranslatorScreen> {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isProcessing = false;
  String _recognizedText = '';
  String _translatedText = '';
  String _targetLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'Englisch', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Spanisch', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Französisch', 'flag': '🇫🇷'},
    {'code': 'it', 'name': 'Italienisch', 'flag': '🇮🇹'},
    {'code': 'zh', 'name': 'Chinesisch', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanisch', 'flag': '🇯🇵'},
  ];

  Future<void> _scanText() async {
    if (_isProcessing || widget.cameraController == null) return;

    setState(() => _isProcessing = true);

    try {
      final image = await widget.cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _recognizedText = recognizedText.text;
      });

      if (_recognizedText.isNotEmpty) {
        await _translateText(_recognizedText);
      }
    } catch (e) {
      print('Text recognition error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _translateText(String text) async {
    try {
      // Simulate translation (would use Google Translate API in production)
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${Env.openAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Translate the following text to $_targetLanguage. '
                  'Only provide the translation, no explanations.',
            },
            {
              'role': 'user',
              'content': text,
            }
          ],
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _translatedText = data['choices'][0]['message']['content'];
        });

        // Speak translation
        await _flutterTts.setLanguage(_targetLanguage);
        await _flutterTts.speak(_translatedText);
      }
    } catch (e) {
      print('Translation error: $e');
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Übersetzer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (widget.cameraController != null &&
              widget.cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(widget.cameraController!),
            ),

          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Language Selector
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Text(
                    'Übersetzen nach:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _languages.length,
                        itemBuilder: (context, index) {
                          final lang = _languages[index];
                          final isSelected = lang['code'] == _targetLanguage;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _targetLanguage = lang['code']!;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(lang['flag']!),
                                  const SizedBox(width: 4),
                                  Text(
                                    lang['name']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
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
                ],
              ),
            ),
          ),

          // Scan Button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _scanText,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),

          // Results
          if (_recognizedText.isNotEmpty)
            Positioned(
              bottom: 200,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Original:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    if (_translatedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.translate,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Übersetzung:',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _translatedText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Env {
  static var openAiApiKey;
}

// Custom Painter
class LanguageWavePainter extends CustomPainter {
  final double animation;

  LanguageWavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Multiple language bubbles floating
    final languages = ['Hello', 'Hola', 'Bonjour', 'Ciao', '你好', 'こんにちは'];
    final colors = [
      AppColors.primary,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    for (int i = 0; i < languages.length; i++) {
      final progress = (animation + i * 0.15) % 1.0;
      final y = size.height - (progress * size.height * 1.5);
      final x = size.width * 0.1 +
          (i * size.width * 0.15) +
          math.sin(progress * math.pi * 2 + i) * 20;

      // Bubble
      paint.color = colors[i].withOpacity(0.2 - progress * 0.2);
      canvas.drawCircle(Offset(x, y), 40, paint);

      // Text (simplified representation)
      paint.color = colors[i].withOpacity(0.5 - progress * 0.5);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 20, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
