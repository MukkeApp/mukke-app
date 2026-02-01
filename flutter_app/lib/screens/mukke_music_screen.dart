import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;

import '../utils/constants.dart';

class MukkeMusicScreen extends StatefulWidget {
  const MukkeMusicScreen({super.key});

  @override
  State<MukkeMusicScreen> createState() => _MukkeMusicScreenState();
}

class _MukkeMusicScreenState extends State<MukkeMusicScreen>
    with TickerProviderStateMixin {
  // Animations
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  // State
  bool _isPlaying = false;
  String _currentMode = 'chill';
  double _volume = 0.7;
  bool _isShuffle = false;
  bool _isRepeat = false;

  // Current Track Info
  String _currentTrackTitle = 'Wähle deinen Vibe';
  String _currentArtist = 'MukkeApp KI';
  Duration _currentPosition = Duration.zero;
  final Duration _totalDuration = const Duration(minutes: 3, seconds: 30);

  // Playlist
  final List<Map<String, dynamic>> _playlist = [];
  int _currentTrackIndex = 0;

  // Timer für Mukke-Time
  Timer? _mukkeTimer;
  int _mukkeMinutes = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
  }

  void _initializeAnimations() {
    // Rotation für Cover Art
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Pulse für Play Button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Wave Animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  Future<void> _loadUserPreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _currentMode = data?['musicMode'] ?? 'chill';
            _volume = (data?['musicVolume'] ?? 0.7).toDouble();
          });
        }
      }
    } catch (e) {
      print('Fehler beim Laden der Präferenzen: $e');
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'musicMode': _currentMode,
          'musicVolume': _volume,
          'lastMusicSession': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Fehler beim Speichern der Präferenzen: $e');
    }
  }

  void _startMukkeTimer() {
    _mukkeTimer?.cancel();
    _mukkeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _mukkeMinutes++;
      });

      // Achievements checken
      if (_mukkeMinutes == 30) {
        _unlockAchievement('30_min_mukke');
      } else if (_mukkeMinutes == 60) {
        _unlockAchievement('1_hour_mukke');
      }
    });
  }

  void _stopMukkeTimer() {
    _mukkeTimer?.cancel();
    _saveMukkeSession();
  }

  Future<void> _saveMukkeSession() async {
    if (_mukkeMinutes > 0) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('mukke_sessions').add({
            'userId': user.uid,
            'duration': _mukkeMinutes,
            'mode': _currentMode,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Update total mukke time
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'totalMukkeMinutes': FieldValue.increment(_mukkeMinutes),
          });
        }
      } catch (e) {
        print('Fehler beim Speichern der Session: $e');
      }
    }
  }

  void _unlockAchievement(String achievementId) {
    // Achievement freischalten
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
                'Achievement freigeschaltet: ${_getAchievementName(achievementId)}'),
          ],
        ),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  String _getAchievementName(String id) {
    switch (id) {
      case '30_min_mukke':
        return '30 Minuten Mukke!';
      case '1_hour_mukke':
        return 'Mukke Champion!';
      default:
        return 'Neues Achievement!';
    }
  }

  Future<void> _generateKiMusic() async {
    try {
      setState(() {
        _currentTrackTitle = 'KI generiert deinen Track...';
        _currentArtist = 'MukkeApp KI';
      });

      // Simuliere KI-Musik Generierung
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _currentTrackTitle = 'Dein ${_getModeName(_currentMode)} Track';
        _currentArtist = 'MukkeApp KI feat. Jarviz';
      });

      _play();
    } catch (e) {
      print('Fehler bei KI-Musik Generierung: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KI-Musik konnte nicht generiert werden'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getModeGenre(String mode) {
    switch (mode) {
      case 'chill':
        return 'lofi,ambient,chillhop';
      case 'party':
        return 'edm,house,dance';
      case 'focus':
        return 'classical,study,concentration';
      case 'workout':
        return 'hiphop,trap,energetic';
      case 'relax':
        return 'nature,meditation,calm';
      default:
        return 'mixed';
    }
  }

  double _getModeEnergy(String mode) {
    switch (mode) {
      case 'chill':
        return 0.4;
      case 'party':
        return 0.9;
      case 'focus':
        return 0.3;
      case 'workout':
        return 1.0;
      case 'relax':
        return 0.2;
      default:
        return 0.5;
    }
  }

  void _play() {
    setState(() {
      _isPlaying = true;
    });
    _rotationController.repeat();
    _waveController.repeat();
    _startMukkeTimer();

    // Simuliere Position Update
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentPosition < _totalDuration) {
          _currentPosition = Duration(seconds: _currentPosition.inSeconds + 1);
        } else {
          _handleTrackComplete();
          timer.cancel();
        }
      });
    });
  }

  void _pause() {
    setState(() {
      _isPlaying = false;
    });
    _rotationController.stop();
    _waveController.stop();
    _stopMukkeTimer();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      if (_currentTrackTitle == 'Wähle deinen Vibe') {
        _generateKiMusic();
      } else {
        _play();
      }
    }
  }

  void _skipNext() {
    if (_playlist.isNotEmpty) {
      _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
      _loadTrack(_currentTrackIndex);
    } else {
      _generateKiMusic();
    }
  }

  void _skipPrevious() {
    if (_currentPosition.inSeconds > 3) {
      setState(() {
        _currentPosition = Duration.zero;
      });
    } else if (_playlist.isNotEmpty) {
      _currentTrackIndex =
          (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
      _loadTrack(_currentTrackIndex);
    }
  }

  void _loadTrack(int index) {
    // Implementierung für Playlist-Tracks
  }

  void _handleTrackComplete() {
    if (_isRepeat) {
      setState(() {
        _currentPosition = Duration.zero;
      });
      _play();
    } else if (_isShuffle && _playlist.isNotEmpty) {
      _currentTrackIndex = math.Random().nextInt(_playlist.length);
      _loadTrack(_currentTrackIndex);
    } else {
      _skipNext();
    }
  }

  void _changeMode(String mode) {
    setState(() {
      _currentMode = mode;
    });
    _saveUserPreferences();

    // Visuelles Feedback
    HapticFeedback.lightImpact();

    // Neue Musik für neuen Mode generieren
    if (_isPlaying) {
      _generateKiMusic();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _mukkeTimer?.cancel();
    _saveMukkeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mukke',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_music),
            onPressed: () {
              Navigator.pushNamed(context, '/music/library');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsSheet();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getModeColors(),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Mode Selector
              _buildModeSelector(),

              // Cover Art & Visualizer
              Expanded(
                child: Center(
                  child: _buildCoverArt(),
                ),
              ),

              // Track Info
              _buildTrackInfo(),

              // Progress Bar
              _buildProgressBar(),

              // Controls
              _buildControls(),

              // Volume & Features
              _buildBottomControls(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getModeColors() {
    switch (_currentMode) {
      case 'chill':
        return [Colors.purple.shade800, Colors.blue.shade900];
      case 'party':
        return [Colors.pink.shade600, Colors.orange.shade700];
      case 'focus':
        return [Colors.teal.shade700, Colors.blue.shade800];
      case 'workout':
        return [Colors.red.shade700, Colors.orange.shade800];
      case 'relax':
        return [Colors.indigo.shade800, Colors.purple.shade900];
      default:
        return [AppColors.primary, AppColors.accent];
    }
  }

  Widget _buildModeSelector() {
    final modes = ['chill', 'party', 'focus', 'workout', 'relax'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: modes.length,
        itemBuilder: (context, index) {
          final mode = modes[index];
          final isSelected = _currentMode == mode;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _changeMode(mode),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getModeIcon(mode),
                        size: 18,
                        color: isSelected ? _getModeColors()[0] : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getModeName(mode),
                        style: TextStyle(
                          color:
                              isSelected ? _getModeColors()[0] : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'chill':
        return Icons.weekend;
      case 'party':
        return Icons.celebration;
      case 'focus':
        return Icons.psychology;
      case 'workout':
        return Icons.fitness_center;
      case 'relax':
        return Icons.spa;
      default:
        return Icons.music_note;
    }
  }

  String _getModeName(String mode) {
    switch (mode) {
      case 'chill':
        return 'Chill';
      case 'party':
        return 'Party';
      case 'focus':
        return 'Focus';
      case 'workout':
        return 'Workout';
      case 'relax':
        return 'Relax';
      default:
        return mode;
    }
  }

  Widget _buildCoverArt() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wave Animation Background
        if (_isPlaying)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    animation: _waveController.value,
                    color: Colors.white.withOpacity(0.1),
                  ),
                );
              },
            ),
          ),

        // Rotating Cover
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getModeColors()[0].withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner Circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    // Center Icon
                    Icon(
                      _getModeIcon(_currentMode),
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Pulse Effect
        if (_isPlaying)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTrackInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            _currentTrackTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _currentArtist,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (_mukkeMinutes > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Mukke Zeit: $_mukkeMinutes Min',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          // Progress Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayColor: Colors.white.withOpacity(0.3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _currentPosition.inSeconds.toDouble(),
              min: 0,
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _currentPosition = Duration(seconds: value.toInt());
                });
              },
            ),
          ),
          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: _isShuffle ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          iconSize: 24,
          onPressed: () {
            setState(() {
              _isShuffle = !_isShuffle;
            });
            HapticFeedback.lightImpact();
          },
        ),

        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 36,
          onPressed: _skipPrevious,
        ),

        // Play/Pause
        const SizedBox(width: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _togglePlayPause,
            borderRadius: BorderRadius.circular(36),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 36,
                color: _getModeColors()[0],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 36,
          onPressed: _skipNext,
        ),

        // Repeat
        IconButton(
          icon: Icon(
            _isRepeat ? Icons.repeat_one : Icons.repeat,
            color: _isRepeat ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          iconSize: 24,
          onPressed: () {
            setState(() {
              _isRepeat = !_isRepeat;
            });
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          // Volume
          Icon(
            Icons.volume_down,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          Expanded(
            child: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
              },
              onChangeEnd: (_) => _saveUserPreferences(),
            ),
          ),
          Icon(
            Icons.volume_up,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),

          const SizedBox(width: 16),

          // AI Generate Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/music/ki');
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'KI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.equalizer, color: Colors.white),
              title: const Text('Equalizer',
                  style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Navigate to equalizer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.white),
              title: const Text('Sleep Timer',
                  style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Show sleep timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text('Offline Modus',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Toggle offline mode
                },
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.high_quality, color: Colors.white),
              title: const Text('Audio Qualität',
                  style: TextStyle(color: Colors.white)),
              subtitle:
                  const Text('Hoch', style: TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white54, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Show quality options
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Wave Painter for animations
class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveCount = 3;
    final waveHeight = 20.0;

    path.moveTo(0, size.height / 2);

    for (int i = 0; i <= size.width.toInt(); i++) {
      final x = i.toDouble();
      final y = size.height / 2 +
          math.sin((x / size.width * waveCount * 2 * math.pi) +
                  (animation * 2 * math.pi)) *
              waveHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
