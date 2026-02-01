import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class MukkeSportScreen extends StatefulWidget {
  const MukkeSportScreen({super.key});

  @override
  State<MukkeSportScreen> createState() => _MukkeSportScreenState();
}

class _MukkeSportScreenState extends State<MukkeSportScreen> 
    with TickerProviderStateMixin {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Animation Controllers
  late AnimationController _avatarAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _avatarAnimation;
  late Animation<double> _pulseAnimation;
  
  // State Variables
  String _selectedGoal = 'Fitness';
  String _fitnessLevel = 'Anfänger';
  bool _hasInjuries = false;
  bool _isTraining = false;
  bool _isCameraActive = false;
  bool _isSpeaking = false;
  
  // Training Data
  String _currentExercise = '';
  int _reps = 0;
  int _targetReps = 10;
  int _sets = 0;
  int _targetSets = 3;
  String _coachMessage = 'Hey! Ich bin Jarviz, dein persönlicher KI-Coach! 💪';
  
  // Goals
  final List<String> _goals = [
    'Fitness',
    'Muskelaufbau',
    'Abnehmen',
    'Ausdauer',
    'Kraft',
    'Beweglichkeit',
    'Rehabilitation',
  ];
  
  // Fitness Levels
  final List<String> _fitnessLevels = [
    'Anfänger',
    'Fortgeschritten',
    'Profi',
    'Athlet',
  ];
  
  // Mock Exercises
  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Liegestütze',
      'icon': Icons.fitness_center,
      'duration': '2 Min',
      'difficulty': 'Mittel',
      'calories': 45,
    },
    {
      'name': 'Kniebeugen',
      'icon': Icons.accessibility_new,
      'duration': '3 Min',
      'difficulty': 'Leicht',
      'calories': 60,
    },
    {
      'name': 'Plank',
      'icon': Icons.sports_gymnastics,
      'duration': '1 Min',
      'difficulty': 'Schwer',
      'calories': 30,
    },
    {
      'name': 'Burpees',
      'icon': Icons.directions_run,
      'duration': '2 Min',
      'difficulty': 'Schwer',
      'calories': 80,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }
  
  void _initializeAnimations() {
    _avatarAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _avatarAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _loadUserData() {
    // TODO: Load from Firebase/Local Storage
    // Simulierte Daten aus dem Profil
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _coachMessage = 'Willkommen zurück! Bereit für dein Training? 🔥';
      });
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _avatarAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: Color(0xFF00BFFF)),
            SizedBox(width: 8),
            Text(
              'Mukke Motion Sport',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: _showLeaderboard,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isTraining ? _buildTrainingView() : _buildSetupView(),
    );
  }
  
  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildPersonalDataCard(),
            const SizedBox(height: 20),
            _buildGoalsCard(),
            const SizedBox(height: 20),
            _buildQuickWorkoutSection(),
            const SizedBox(height: 30),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BFFF).withOpacity(0.2),
            const Color(0xFFFF1493).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _avatarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _avatarAnimation.value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFFF), Color(0xFFFF1493)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFFF).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_martial_arts,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSpeaking 
                  ? const Color(0xFFFF1493) 
                  : Colors.grey[700]!,
                width: _isSpeaking ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isSpeaking ? Icons.mic : Icons.mic_none,
                  color: _isSpeaking 
                    ? const Color(0xFFFF1493) 
                    : Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _coachMessage,
                      key: ValueKey(_coachMessage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BFFF).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF00BFFF)),
              SizedBox(width: 8),
              Text(
                'Persönliche Daten',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    'Name',
                    Icons.badge,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _buildInputDecoration(
                    'Alter',
                    Icons.cake,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pflichtfeld';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _buildInputDecoration(
                    'Größe (cm)',
                    Icons.height,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pflichtfeld';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _buildInputDecoration(
                    'Gewicht (kg)',
                    Icons.monitor_weight,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pflichtfeld';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deine Daten werden automatisch aus dem Profil übernommen',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF1493).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: Color(0xFFFF1493)),
              SizedBox(width: 8),
              Text(
                'Deine Ziele',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Was möchtest du erreichen?',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.map((goal) {
              final isSelected = _selectedGoal == goal;
              return ChoiceChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedGoal = goal;
                    _updateCoachMessage();
                  });
                },
                selectedColor: const Color(0xFFFF1493),
                backgroundColor: const Color(0xFF1A1A1A),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
                side: BorderSide(
                  color: isSelected 
                    ? const Color(0xFFFF1493) 
                    : Colors.grey[700]!,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Dein Fitness-Level',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButton<String>(
              value: _fitnessLevel,
              isExpanded: true,
              dropdownColor: const Color(0xFF2D2D2D),
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              onChanged: (value) {
                setState(() {
                  _fitnessLevel = value!;
                });
              },
              items: _fitnessLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text(
              'Ich habe Verletzungen/Einschränkungen',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Der Coach passt das Training entsprechend an',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            value: _hasInjuries,
            onChanged: (value) {
              setState(() {
                _hasInjuries = value!;
              });
            },
            activeColor: const Color(0xFFFF1493),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickWorkoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Schnell-Workouts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Alle anzeigen',
                style: TextStyle(color: Color(0xFF00BFFF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              return _buildExerciseCard(_exercises[index]);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BFFF).withOpacity(0.8),
            const Color(0xFFFF1493).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startQuickWorkout(exercise),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  exercise['icon'],
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      exercise['duration'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercise['difficulty'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStartButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00BFFF), Color(0xFFFF1493)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BFFF).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _startFullTraining,
          icon: const Icon(Icons.play_arrow, size: 28),
          label: const Text(
            'Training starten',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
  
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: const Color(0xFF00BFFF)),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
  
  void _updateCoachMessage() {
    final messages = {
      'Fitness': 'Super Wahl! Lass uns deine allgemeine Fitness verbessern! 💪',
      'Muskelaufbau': 'Perfekt! Wir werden deine Muskeln zum Brennen bringen! 🔥',
      'Abnehmen': 'Klasse! Gemeinsam schaffen wir deine Traumfigur! 🎯',
      'Ausdauer': 'Excellent! Deine Kondition wird durch die Decke gehen! 🏃',
      'Kraft': 'Stark! Lass uns deine Power auf ein neues Level bringen! ⚡',
      'Beweglichkeit': 'Toll! Flexibilität ist der Schlüssel zur Gesundheit! 🧘',
      'Rehabilitation': 'Gut! Wir gehen es langsam und sicher an! 🩹',
    };
    
    setState(() {
      _coachMessage = messages[_selectedGoal] ?? 'Bereit für dein Training?';
    });
  }
  
  Widget _buildTrainingView() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTrainingHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCameraView(),
          ),
          const SizedBox(height: 20),
          _buildTrainingControls(),
          const SizedBox(height: 20),
          _buildTrainingStats(),
        ],
      ),
    );
  }
  
  Widget _buildTrainingHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF1493).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentExercise,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set $_sets von $_targetSets',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _stopTraining,
            icon: const Icon(
              Icons.close,
              color: Colors.red,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  void _startFullTraining() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isTraining = true;
        _currentExercise = 'Aufwärmen';
        _sets = 1;
        _reps = 0;
        _coachMessage = 'Los geht\'s! Wir starten mit dem Aufwärmen!';
      });
      
      // Simuliere Kamera-Aktivierung
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isCameraActive = true;
          _coachMessage = 'Super! Ich sehe dich. Lass uns beginnen!';
        });
        _startExerciseSimulation();
      });
    }
  }
  
  void _startQuickWorkout(Map<String, dynamic> exercise) {
    setState(() {
      _isTraining = true;
      _currentExercise = exercise['name'];
      _sets = 1;
      _targetSets = 1;
      _reps = 0;
      _targetReps = 15;
      _coachMessage = 'Schnell-Workout: ${exercise['name']}! Let\'s go!';
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCameraActive = true;
      });
      _startExerciseSimulation();
    });
  }
  
  void _startExerciseSimulation() {
    // Simuliere Übungsausführung mit Feedback
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isTraining) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _reps++;
        
        // Verschiedene Coach-Nachrichten
        final messages = [
          'Sehr gut! Weiter so!',
          'Perfekte Form! 💪',
          'Du machst das großartig!',
          'Halte die Spannung!',
          'Noch ${_targetReps - _reps} Wiederholungen!',
          'Atmung nicht vergessen!',
          'Super Tempo!',
          'Fast geschafft!',
        ];
        
        if (_reps == _targetReps ~/ 2) {
          _coachMessage = 'Halbzeit! Du rockst das! 🔥';
        } else if (_reps == _targetReps - 3) {
          _coachMessage = 'Nur noch 3! Gib alles!';
        } else if (_reps >= _targetReps) {
          _reps = 0;
          _sets++;
          if (_sets > _targetSets) {
            _completeExercise();
            timer.cancel();
          } else {
            _coachMessage = 'Set ${_sets - 1} geschafft! 30 Sekunden Pause!';
            _showRestTimer();
          }
        } else if (Random().nextBool()) {
          // Manchmal Korrektur-Feedback
          if (Random().nextInt(5) == 0) {
            _coachMessage = '⚠️ Achte auf deine Haltung! Rücken gerade!';
          } else {
            _coachMessage = messages[Random().nextInt(messages.length)];
          }
        }
        
        // Simuliere Spracherkennung
        _isSpeaking = Random().nextBool();
      });
    });
  }
  
  void _showRestTimer() {
    int restSeconds = 30;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Timer.periodic(const Duration(seconds: 1), (timer) {
              if (restSeconds <= 0) {
                timer.cancel();
                Navigator.pop(context);
                return;
              }
              setState(() {
                restSeconds--;
              });
            });
            
            return AlertDialog(
              backgroundColor: const Color(0xFF2D2D2D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pause',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00BFFF),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$restSeconds',
                          style: const TextStyle(
                            color: Color(0xFF00BFFF),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Trinke etwas Wasser!',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _completeExercise() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.green, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Übung abgeschlossen!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Du hast $_currentExercise erfolgreich beendet!',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Color(0xFF00BFFF),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Random().nextInt(10) + 5} Min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Random().nextInt(100) + 50} kcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${Random().nextInt(50) + 10} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopTraining();
            },
            child: const Text(
              'Beenden',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Nächste Übung
              setState(() {
                _currentExercise = 'Liegestütze';
                _reps = 0;
                _sets = 1;
                _coachMessage = 'Weiter geht\'s mit $_currentExercise!';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nächste Übung'),
          ),
        ],
      ),
    );
  }
  
  void _stopTraining() {
    setState(() {
      _isTraining = false;
      _isCameraActive = false;
      _currentExercise = '';
      _reps = 0;
      _sets = 0;
      _coachMessage = 'Training beendet! Du warst großartig! 🎉';
    });
  }
  
  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF2D2D2D),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.leaderboard, color: Color(0xFFFF1493)),
                  SizedBox(width: 12),
                  Text(
                    'Bestenliste',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: index < 3 
                        ? [
                            Colors.amber.withOpacity(0.2),
                            Colors.grey.withOpacity(0.2),
                            Colors.brown.withOpacity(0.2),
                          ][index]
                        : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: index < 3
                          ? [Colors.amber, Colors.grey, Colors.brown][index]
                          : Colors.grey[700]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFFF).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF00BFFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FitnessHero${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Level ${20 - index}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(1000 - index * 50)} XP',
                          style: const TextStyle(
                            color: Color(0xFFFF1493),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF00BFFF)),
            SizedBox(width: 12),
            Text(
              'Trainingseinstellungen',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text(
                'Sprachsteuerung',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Mit dem Coach sprechen',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
            SwitchListTile(
              title: const Text(
                'Musik während Training',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Motivierende Playlist',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
            SwitchListTile(
              title: const Text(
                'Geräte-Erkennung',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Automatisch Fitnessgeräte erkennen',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              value: false,
              onChanged: (value) {},
              activeColor: const Color(0xFF00BFFF),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Schließen',
              style: TextStyle(color: Color(0xFF00BFFF)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCameraView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isCameraActive 
            ? const Color(0xFF00BFFF) 
            : Colors.grey[700]!,
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: _isCameraActive
              ? const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 80,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      color: Colors.grey[600],
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kamera wird aktiviert...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 12),
                  SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF1493).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: _isSpeaking 
                      ? const Color(0xFFFF1493) 
                      : Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _coachMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          Icons.skip_previous,
          'Zurück',
          () {},
          Colors.grey[700]!,
        ),
        _buildControlButton(
          Icons.pause,
          'Pause',
          () {},
          const Color(0xFFFF1493),
        ),
        _buildControlButton(
          Icons.skip_next,
          'Weiter',
          () {},
          Colors.grey[700]!,
        ),
      ],
    );
  }
  
  Widget _buildControlButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrainingStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Wiederholungen',
            '$_reps / $_targetReps',
            const Color(0xFF00BFFF),
            Icons.repeat,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[700],
          ),
          _buildStatItem(
            'Herzfrequenz',
            '${120 + Random().nextInt(40)} BPM',
            Colors.red,
            Icons.favorite,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[700],
          ),
          _buildStatItem(
            'Kalorien',
            '${45 + Random().nextInt(100)}',
            Colors.orange,
            Icons.local_fire_department,
          ),
        ],
      ),
    );
  }
}