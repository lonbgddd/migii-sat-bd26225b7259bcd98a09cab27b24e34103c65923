import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../base/base_stateful.dart';

class LockDialog extends BasePage {
  final VoidCallback learnMoreListener;

  const LockDialog(this.learnMoreListener, {Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, VoidCallback learnMoreListener) {
    showGeneralDialog(
        barrierLabel: "ReminderDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center, child: LockDialog(learnMoreListener));
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(-1, 0), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<LockDialog> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.8,
        child: Card(
            elevation: 4.0.dp(),
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0.dp())),
            child: viewContainer()));
  }

  Column viewContainer() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.only(bottom: 24.0.dp()),
        color: ColorHelper.colorPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0.dp()),
                topRight: Radius.circular(12.0.dp()))),
        child: Padding(
            padding:
                EdgeInsets.fromLTRB(20.0.dp(), 18.0.dp(), 20.0.dp(), 20.0.dp()),
            child: Text(
              appLocalized().noti_explain_premium,
              style: UIFont.fontAppBold(17.0.sp(), ColorHelper.colorTextNight),
              textAlign: TextAlign.center,
            )),
      ),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.learnMoreListener();
          },
          child: Card(
            elevation: 4.0.dp(),
            margin: EdgeInsets.zero,
            color: ColorHelper.colorPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0.dp())),
            child: Container(
              height: 40.0.dp(),
              padding: EdgeInsets.only(left: 12.0.dp(), right: 12.0.dp()),
              alignment: Alignment.center,
              child: AutoSizeText(
                appLocalized().learn_more,
                style:
                    UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                maxLines: 1,
                minFontSize: 8.0.sp(),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 2.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.transparent,
            height: 40.0.dp(),
            alignment: Alignment.center,
            child: AutoSizeText(
              appLocalized().ignore,
              style: UIFont.fontApp(14.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                  decoration: TextDecoration.underline, decorationThickness: 1),
              maxLines: 1,
              minFontSize: 8.0.sp(),
            ),
          ),
        ),
      ),
      SizedBox(height: 12.0.dp())
    ]);
  }
}
