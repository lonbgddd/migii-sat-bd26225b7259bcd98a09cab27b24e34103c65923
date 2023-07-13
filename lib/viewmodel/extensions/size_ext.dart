
import '../helper/screen_info.dart';

extension SizeInt on int {
  int dp() {
    switch (screenSize) {
      case ScreenSize.xs:
        return this * 8 ~/ 10;
      case ScreenSize.sm:
        return this ;
      case ScreenSize.md:
        return this * 12 ~/ 10;
      case ScreenSize.lg:
        return this * 14 ~/ 10;
      case ScreenSize.xl:
        return this * 16 ~/ 10;
      case ScreenSize.unknown:
        return this;
    }
  }

  int sp() {
    switch (screenSize) {
      case ScreenSize.xs:
        return this - 2;
      case ScreenSize.sm:
        return this;
      case ScreenSize.md:
        return this + 2;
      case ScreenSize.lg:
        return this + 4;
      case ScreenSize.xl:
        return this + 6;
      case ScreenSize.unknown:
        return this;
    }
  }
}

extension SizeDouble on double {
  double dp() {
    switch (screenSize) {
      case ScreenSize.xs:
        return this * 8 / 10;
      case ScreenSize.sm:
        return this;
      case ScreenSize.md:
        return this * 12 / 10;
      case ScreenSize.lg:
        return this * 14 / 10;
      case ScreenSize.xl:
        return this * 16 / 10;
      case ScreenSize.unknown:
        return this;
    }
  }

  double sp() {
    switch (screenSize) {
      case ScreenSize.xs:
        return this - 2;
      case ScreenSize.sm:
        return this;
      case ScreenSize.md:
        return this + 2;
      case ScreenSize.lg:
        return this + 4;
      case ScreenSize.xl:
        return this + 6;
      case ScreenSize.unknown:
        return this;
    }
  }
}
