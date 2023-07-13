import 'package:flutter/material.dart';

import '../viewmodel/helper/animation/slide_bottom_route.dart';
import '../viewmodel/helper/animation/slide_right_route.dart';

class RouterNavigate {
  static pushScreen(BuildContext context, Widget widget) {
    Navigator.push(context, SlideRightRoute(widget: widget));
  }

  static pushReplacementScreen(BuildContext context, Widget widget) {
    Navigator.pushReplacement(context, SlideRightRoute(widget: widget));
  }

  static pushBottomScreen(BuildContext context, Widget widget) {
    Navigator.push(context, SlideBottomRoute(widget: widget));
  }

  static pushReplacementBottomScreen(BuildContext context, Widget widget) {
    Navigator.pushReplacement(context, SlideBottomRoute(widget: widget));
  }
}
