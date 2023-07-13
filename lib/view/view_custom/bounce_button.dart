import 'package:flutter/material.dart';
import 'bounce_widget.dart';

class BounceButton extends StatelessWidget {
  final Widget child;
  final Color? color;
  final ShapeBorder? shape;
  final VoidCallback? onPress;
  final double scale;

  const BounceButton(
      {super.key,
      required this.child,
      this.color,
      this.shape,
      this.onPress,
      this.scale = 0.96});

  @override
  Widget build(BuildContext context) {
    return BounceWidget(
        onPress: onPress,
        scale: scale,
        child: Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            color: color,
            shape: shape,
            child: child));
  }
}
