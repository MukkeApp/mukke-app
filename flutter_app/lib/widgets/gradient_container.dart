import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const GradientContainer({
    Key? key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.boxShadow,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [AppColors.primary, AppColors.accent],
        ),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}

// Animated Gradient Container
class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<List<Color>> gradients;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const AnimatedGradientContainer({
    Key? key,
    required this.child,
    required this.gradients,
    this.duration = const Duration(seconds: 3),
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.gradients.length;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextIndex = (_currentIndex + 1) % widget.gradients.length;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  widget.gradients[_currentIndex][0],
                  widget.gradients[nextIndex][0],
                  _animation.value,
                )!,
                Color.lerp(
                  widget.gradients[_currentIndex][1],
                  widget.gradients[nextIndex][1],
                  _animation.value,
                )!,
              ],
            ),
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Glass Morphism Container
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: color.withOpacity(0.2),
                  width: 1.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Gradient Border Container
class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double borderWidth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const GradientBorderContainer({
    Key? key,
    required this.child,
    this.colors,
    this.borderWidth = 2,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [AppColors.primary, AppColors.accent],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: borderRadius != null
              ? BorderRadius.circular(
                  (borderRadius as BorderRadius).topLeft.x - borderWidth,
                )
              : BorderRadius.circular(12 - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
