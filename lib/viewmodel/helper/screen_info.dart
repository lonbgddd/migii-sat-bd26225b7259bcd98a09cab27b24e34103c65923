import 'dart:math';
import 'package:flutter/material.dart';

var screenSize = ScreenSize.sm;

enum ScreenSize { xs, sm, md, lg, xl, unknown }

class ScreenInfo {
  static Size size(BuildContext c) => MediaQuery.of(c).size;

  static double diagonal(BuildContext c) {
    Size s = size(c);
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  static ScreenSize screenSize(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 0 && diagonalValue <= 799) {
      return ScreenSize.xs;
    } else if (diagonalValue > 799 && diagonalValue <= 1023) {
      return ScreenSize.sm;
    } else if (diagonalValue > 1023 && diagonalValue <= 1439) {
      return ScreenSize.md;
    } else if (diagonalValue > 1439 && diagonalValue <= 1919) {
      return ScreenSize.lg;
    } else if (diagonalValue > 1919) {
      return ScreenSize.xl;
    } else {
      return ScreenSize.unknown;
    }
  }

  static bool isExtraSmall(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 0 && diagonalValue <= 599) {
      return true;
    } else {
      return false;
    }
  }

  static bool isSmall(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 600 && diagonalValue <= 1023) {
      return true;
    } else {
      return false;
    }
  }

  static bool isMedium(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 1023 && diagonalValue <= 1439) {
      return true;
    } else {
      return false;
    }
  }

  static bool isLarge(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 1440 && diagonalValue <= 1919) {
      return true;
    } else {
      return false;
    }
  }

  static bool isExtraLarge(BuildContext context) {
    double diagonalValue = diagonal(context);
    if (diagonalValue >= 1920) {
      return true;
    } else {
      return false;
    }
  }
}
