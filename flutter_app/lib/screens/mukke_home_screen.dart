import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  final List<Map<String, dynamic>> menuItems = [
    {
      'label': 'Profil',
      'route': '/profile',
      'icon': Icons.person,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF0099CC)],
    },
    {
      'label': 'Mukke Musik',
      'route': '/music',
      'icon': Icons.music_note,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF1E90FF)],
    },
    {
      'label': 'Mukke Dating',
      'route': '/dating',
      'icon': Icons.favorite,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFFF69B4)],
    },
    {
      'label': 'Mukke Motion Sport',
      'route': '/sport',
      'icon': Icons.fitness_center,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF00CED1)],
    },
    {
      'label': 'Mukke Real Challenge',
      'route': '/challenges',
      'icon': Icons.flash_on,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFFF4500)],
    },
    {
      'label': 'Mukke Spiele',
      'route': '/games',
      'icon': Icons.sports_esports,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF9370DB)],
    },
    {
      'label': 'Mukke Avatar',
      'route': '/avatar',
      'icon': Icons.face,
      'gradient': [const Color(0xFFFF1493), const Color(0xFF00BFFF)],
    },
    {
      'label': 'Mukke Tracking',
      'route': '/tracking',
      'icon': Icons.location_on,
      'gradient': [const Color(0xFF00CED1), const Color(0xFF20B2AA)],
    },
    {
      'label': 'Mukke Mode',
      'route': '/fashion',
      'icon': Icons.checkroom,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFDA70D6)],
    },
    {
      'label': 'Mukke Sprache',
      'route': '/language',
      'icon': Icons.translate,
      'gradient': [const Color(0xFF00BFFF), const Color(0xFF4169E1)],
    },
    {
      'label': 'Mukke Live',
      'route': '/live',
      'icon': Icons.live_tv,
      'gradient': [const Color(0xFFFF1493), const Color(0xFFFF0000)],
    },
    {
      'label': 'Verbesserungsvorschläge',
      'route': '/feedback', // Geändert zu /feedback statt /improvements
      'icon': Icons.lightbulb,
      'gradient': [const Color(0xFF32CD32), const Color(0xFF00FA9A)],
    },
  ];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Wave Background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WaveBackgroundPainter(
                  animation: _waveController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header mit MUKKE Logo
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow Effect
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF00BFFF).withValues(alpha: 0.3 * _glowController.value),
                                  const Color(0xFFFF1493).withValues(alpha: 0.1 * _glowController.value),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Logo mit Animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.05),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  painter: SoundWavesPainter(
                                    animation: _pulseController.value,
                                  ),
                                  size: const Size(250, 120),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: const [
                                      Color(0xFF00BFFF),
                                      Color(0xFFFF1493),
                                      Color(0xFF00BFFF),
                                    ],
                                    stops: [
                                      0.0,
                                      _pulseController.value,
                                      1.0,
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'MUKKE',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFFFF1493),
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        ),
                                        Shadow(
                                          color: Color(0xFF00BFFF),
                                          offset: Offset(-2, -2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Subtitle
                      Positioned(
                        bottom: 10,
                        child: Text(
                          'DIE PLATTFORM FÜR ECHTE ARTISTS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid Menu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        return _buildMenuItem(menuItems[index], index);
                      },
                    ),
                  ),
                ),

                // Bottom Wave - Optimiert gegen Overflow
                SizedBox(
                  height: 60,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BottomWavePainter(
                            animation: _waveController.value,
                          ),
                          size: Size.infinite,
                        ),
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
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (item['gradient'] as List<Color>)[0].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, item['route']);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: item['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamische Anpassung basierend auf verfügbarem Platz
                      final isSmallSpace = constraints.maxHeight < 100;

                      return Padding(
                        padding: EdgeInsets.all(isSmallSpace ? 12 : 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(
                                  item['icon'],
                                  size: isSmallSpace ? 28 : 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: isSmallSpace ? 4 : 8),
                            Flexible(
                              child: Text(
                                item['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallSpace ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Wave Background Painter
class WaveBackgroundPainter extends CustomPainter {
  final double animation;

  WaveBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      paint.color = const Color(0xFF00BFFF).withValues(alpha: 0.1 - (i * 0.02));

      final path = Path();
      const waveHeight = 20.0;
      final waveLength = size.width / 3;
      final yOffset = size.height * 0.3 + (i * 30);

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset + math.sin((x / waveLength + animation * 2 * math.pi)) * waveHeight;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Sound Waves Painter
class SoundWavesPainter extends CustomPainter {
  final double animation;

  SoundWavesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    const barWidth = 4.0;
    const barSpacing = 8.0;
    const barCount = 30;

    for (int i = 0; i < barCount; i++) {
      final x = (size.width / 2) - (barCount * (barWidth + barSpacing) / 2) + i * (barWidth + barSpacing);
      final normalizedPosition = (i - barCount / 2).abs() / (barCount / 2);
      final baseHeight = (1 - normalizedPosition) * 40;
      final animatedHeight = baseHeight * (0.5 + 0.5 * math.sin(animation * 2 * math.pi + i * 0.1));

      if (i < barCount / 2) {
        paint.color = Color.lerp(
          const Color(0xFFFF1493),
          const Color(0xFF00BFFF),
          i / (barCount / 2),
        )!;
      } else {
        paint.color = Color.lerp(
          const Color(0xFF00BFFF),
          const Color(0xFFFF1493),
          (i - barCount / 2) / (barCount / 2),
        )!;
      }

      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bottom Wave Painter
class BottomWavePainter extends CustomPainter {
  final double animation;

  BottomWavePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Erste Welle
    paint.color = const Color(0xFFFF1493).withValues(alpha: 0.3);
    final path1 = Path();
    path1.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = 20 + math.sin((x / size.width * 2 * math.pi) + animation * 2 * math.pi) * 10;
      path1.lineTo(x, y);
    }

    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Zweite Welle
    paint.color = const Color(0xFF00BFFF).withValues(alpha: 0.3);
    final path2 = Path();
    path2.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = 30 + math.sin((x / size.width * 2 * math.pi) - animation * 2 * math.pi) * 15;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
