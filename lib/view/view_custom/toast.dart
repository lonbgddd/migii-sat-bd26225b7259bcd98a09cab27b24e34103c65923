import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';

class Toast {
  static const top = 0;
  static const center = 1;
  static const bottom = 2;

  String text;
  int alignment;

  Toast(this.text, {this.alignment = bottom});

  void show() {
    BotToast.showCustomText(
        onlyOne: true,
        duration: const Duration(seconds: 2),
        toastBuilder: (textCancel) => FractionallySizedBox(
            widthFactor: 0.9,
            child: Align(
              alignment: alignment == bottom
                  ? const Alignment(0, 0.8)
                  : (alignment == center
                      ? const Alignment(0, 0)
                      : const Alignment(0, -0.8)),
              child: Card(
                elevation: 4.0.dp(),
                color: preferenceHelper.isNightMode
                    ? ColorHelper.colorBackgroundDay
                    : ColorHelper.colorBackgroundNight,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(150.0.dp())),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                20.0.dp(), 16.0.dp(), 20.0.dp(), 18.0.dp()),
                            child: Text(
                              text,
                              style: UIFont.fontAppBold(
                                  15.0.sp(),
                                  preferenceHelper.isNightMode
                                      ? ColorHelper.colorTextDay
                                      : ColorHelper.colorTextNight),
                              textAlign: TextAlign.center,
                            )))
                  ],
                ),
              ),
            )));
  }
}
