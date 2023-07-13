import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';

class UIFont {
  static TextStyle fontApp(double size, Color color,
      {TextDecoration? decoration,
      double decorationThickness = 2,
      double underlineSpace = 2,
      double? height}) {
    if (decoration != null) {
      return TextStyle(
          fontFamily: "SVN",
          fontSize: size,
          color: Colors.transparent,
          shadows: [
            Shadow(offset: Offset(0, -underlineSpace.dp()), color: color)
          ],
          decoration: decoration,
          decorationThickness: decorationThickness.dp(),
          decorationColor: color);
    }
    return TextStyle(
        fontFamily: "SVN", fontSize: size, color: color, height: height);
  }

  static TextStyle fontAppBold(double size, Color color,
      {TextDecoration? decoration,
      double decorationThickness = 2,
      double underlineSpace = 2,
      double? height}) {
    if (decoration != null) {
      return TextStyle(
          fontFamily: "SVN",
          fontSize: size,
          color: Colors.transparent,
          shadows: [
            Shadow(offset: Offset(0, -underlineSpace.dp()), color: color)
          ],
          fontWeight: FontWeight.bold,
          decoration: decoration,
          decorationThickness: decorationThickness.dp(),
          decorationColor: color);
    }
    return TextStyle(
        fontFamily: "SVN",
        fontSize: size,
        color: color,
        fontWeight: FontWeight.bold,
        height: height);
  }

  static Style htmlFontApp(double size, Color color,
      {TextDecoration? decoration,
      double decorationThickness = 2,
      double underlineSpace = 2,
      double? height}) {
    if (decoration != null) {
      return Style(
          fontFamily: "SVN",
          fontSize: FontSize(size),
          color: color,
          textDecoration: decoration,
          textDecorationThickness: decorationThickness.dp(),
          textDecorationColor: color);
    }
    return Style(fontFamily: "SVN", fontSize: FontSize(size), color: color);
  }
}
