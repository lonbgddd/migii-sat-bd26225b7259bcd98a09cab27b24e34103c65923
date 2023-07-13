import 'package:flutter/material.dart';

class DashedLineVerticalPainter extends StatelessWidget {
  final double width;
  final double dashHeight;
  final Color color;

  const DashedLineVerticalPainter(
      {Key? key,
      this.width = 1,
      this.dashHeight = 10.0,
      this.color = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxHeight = constraints.constrainHeight();
        final dashWidth = width;
        final dashCount = (boxHeight / (2 * dashHeight)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
