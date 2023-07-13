import 'dart:math';

import 'package:flutter/material.dart';
import 'animation_state.dart';

class Shake extends StatefulWidget {
  const Shake({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.shakeCount = 3,
    this.shakeOffset = 8,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;

  @override
  State<Shake> createState() => ShakeState(duration);
}

class ShakeState extends AnimationControllerState<Shake> {
  ShakeState(Duration duration) : super(duration);

  late final Animation<double> _sineAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: animationController,
    curve: SineCurve(count: widget.shakeCount.toDouble()),
  ));

  @override
  void initState() {
    super.initState();
    animationController.addStatusListener(_updateStatus);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sineAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_sineAnimation.value * widget.shakeOffset, 0),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  void shake() {
    animationController.forward();
  }
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});

  final double count;

  @override
  double transformInternal(double t) {
    return sin(count * 2 * pi * t);
  }
}
