import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class WaveAnimation extends StatefulWidget {
  final double height;
  final double width;
  final Color? color;
  final Duration duration;
  final double amplitude;
  final int waveCount;

  const WaveAnimation({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.color,
    this.duration = const Duration(seconds: 3),
    this.amplitude = 20,
    this.waveCount = 2,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: WavePainter(
            animationValue: _animationController.value,
            color: widget.color ?? AppColors.primary,
            amplitude: widget.amplitude,
            waveCount: widget.waveCount,
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double amplitude;
  final int waveCount;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.amplitude,
    required this.waveCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height / 2 +
          amplitude *
              math.sin((i / size.width * 2 * math.pi * waveCount) +
                  (animationValue * 2 * math.pi));
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Multiple Wave Animation
class MultipleWaveAnimation extends StatefulWidget {
  final double height;
  final double width;
  final List<Color> colors;
  final Duration duration;
  final double amplitude;

  const MultipleWaveAnimation({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.colors = const [AppColors.primary, AppColors.accent],
    this.duration = const Duration(seconds: 3),
    this.amplitude = 20,
  });

  @override
  State<MultipleWaveAnimation> createState() => _MultipleWaveAnimationState();
}

class _MultipleWaveAnimationState extends State<MultipleWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: MultipleWavePainter(
            animationValue: _animationController.value,
            colors: widget.colors,
            amplitude: widget.amplitude,
          ),
        );
      },
    );
  }
}

class MultipleWavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final double amplitude;

  MultipleWavePainter({
    required this.animationValue,
    required this.colors,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.3 / (i + 1))
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      final offset = i * 0.2;
      final waveCount = 2 + i * 0.5;

      for (double x = 0; x <= size.width; x++) {
        final y = size.height / 2 +
            amplitude *
                (1 - i * 0.2) *
                math.sin((x / size.width * 2 * math.pi * waveCount) +
                    ((animationValue + offset) * 2 * math.pi));
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(MultipleWavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Circular Wave Animation
class CircularWaveAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final int waveCount;

  const CircularWaveAnimation({
    super.key,
    this.size = 200,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 2),
    this.waveCount = 3,
  });

  @override
  State<CircularWaveAnimation> createState() => _CircularWaveAnimationState();
}

class _CircularWaveAnimationState extends State<CircularWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(widget.waveCount, (index) {
              final delay = index / widget.waveCount;
              final animationValue = (_animation.value + delay) % 1.0;

              return Transform.scale(
                scale: animationValue,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(1 - animationValue),
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Audio Visualizer Wave
class AudioVisualizerWave extends StatefulWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final int barCount;
  final Duration animationDuration;

  const AudioVisualizerWave({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.colors = const [AppColors.primary, AppColors.accent],
    this.barCount = 30,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AudioVisualizerWave> createState() => _AudioVisualizerWaveState();
}

class _AudioVisualizerWaveState extends State<AudioVisualizerWave>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );
    _animateBars();
  }

  void _animateBars() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) break;

        final controller = _controllers[i];
        final targetHeight = _random.nextDouble();

        controller.animateTo(
          targetHeight,
          duration: Duration(
            milliseconds: 200 + _random.nextInt(300),
          ),
          curve: Curves.easeInOut,
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              return Container(
                width: widget.width / widget.barCount - 2,
                height: widget.height * (0.3 + 0.7 * _controllers[index].value),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      widget.colors[0],
                      widget.colors[1],
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Liquid Wave Background
class LiquidWaveBackground extends StatefulWidget {
  final double height;
  final Color backgroundColor;
  final Color waveColor;
  final Duration duration;

  const LiquidWaveBackground({
    super.key,
    this.height = double.infinity,
    this.backgroundColor = AppColors.background,
    this.waveColor = AppColors.primary,
    this.duration = const Duration(seconds: 10),
  });

  @override
  State<LiquidWaveBackground> createState() => _LiquidWaveBackgroundState();
}

class _LiquidWaveBackgroundState extends State<LiquidWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: LiquidWavePainter(
            animationValue: _animationController.value,
            backgroundColor: widget.backgroundColor,
            waveColor: widget.waveColor,
          ),
        );
      },
    );
  }
}

class LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final Color backgroundColor;
  final Color waveColor;

  LiquidWavePainter({
    required this.animationValue,
    required this.backgroundColor,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Wave
    final wavePaint = Paint()
      ..color = waveColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create liquid wave effect
    for (int layer = 0; layer < 3; layer++) {
      path.reset();

      final layerOffset = layer * 0.5;
      final amplitude = 50.0 - (layer * 10);
      final frequency = 0.5 + (layer * 0.2);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y = size.height * 0.7 +
            amplitude *
                math.sin((x / size.width * math.pi * 2 * frequency) +
                    (animationValue * math.pi * 2) +
                    layerOffset) +
            amplitude *
                0.5 *
                math.sin((x / size.width * math.pi * 4 * frequency) +
                    (animationValue * math.pi * 4) +
                    layerOffset);

        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      wavePaint.color = waveColor.withOpacity(0.1 - (layer * 0.03));
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(LiquidWavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}

// Loading Wave Animation
class LoadingWaveAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const LoadingWaveAnimation({
    super.key,
    this.size = 100,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<LoadingWaveAnimation> createState() => _LoadingWaveAnimationState();
}

class _LoadingWaveAnimationState extends State<LoadingWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: LoadingWavePainter(
              animationValue: _animationController.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class LoadingWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  LoadingWavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
      final waveRadius = radius * 0.8 +
          radius * 0.2 * math.sin(angle * 4 + animationValue * 2 * math.pi);

      final x = center.dx + waveRadius * math.cos(angle);
      final y = center.dy + waveRadius * math.sin(angle);

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LoadingWavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
