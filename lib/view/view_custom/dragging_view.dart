import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';

Widget draggingView() {
  final isNightMode = preferenceHelper.isNightMode;

  return Container(
    padding: EdgeInsets.fromLTRB(24.0.dp(), 12.0.dp(), 24.0.dp(), 0),
    color: Colors.transparent,
    child: Container(
      width: preferenceHelper.widthScreen / 4,
      decoration: BoxDecoration(
          color: isNightMode
              ? ColorHelper.colorTextGreenNight
              : ColorHelper.colorTextGreenDay,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0.dp()),
              topRight: Radius.circular(10.0.dp()))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            height: 1.0.dp(),
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(12.0.dp(), 8.0.dp(), 12.0.dp(), 0),
          ),
          Container(
            color: Colors.white,
            height: 1.0.dp(),
            width: double.infinity,
            margin:
                EdgeInsets.fromLTRB(12.0.dp(), 6.0.dp(), 12.0.dp(), 6.0.dp()),
          ),
        ],
      ),
    ),
  );
}
