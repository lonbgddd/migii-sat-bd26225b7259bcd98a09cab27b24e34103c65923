import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../base/base_stateful.dart';
import '../view_custom/bounce_button.dart';

class SubmitPracticeDialog extends BasePage {
  final VoidCallback submitListener;

  const SubmitPracticeDialog(this.submitListener, {Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, VoidCallback submitListener) {
    showGeneralDialog(
        barrierLabel: "SubmitPracticeDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center,
              child: SubmitPracticeDialog(submitListener));
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

class _State extends BasePageState<SubmitPracticeDialog> {
  bool checkBoxState = false;

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
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.0.dp()),
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 16.0.dp(), right: 12.0.dp()),
                child: SvgPicture.asset(
                  "ic_submit_exam".withIcon(),
                  width: 36.0.dp(),
                  height: 36.0.dp(),
                )),
            Expanded(
                child: AutoSizeText(
              appLocalized().submit_title,
              style: UIFont.fontAppBold(16.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              minFontSize: 12.0.sp(),
            ))
          ]),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.dp(), 4.0.dp(), 16.0.dp(), 0),
            child: Text(
              appLocalized().submit_desc,
              style: UIFont.fontApp(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.0.dp(), 0, 4.0.dp(), 4.0.dp()),
            child: Row(children: [
              Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: ColorHelper.colorPrimary,
                    value: checkBoxState,
                    onChanged: (bool? value) {
                      setState(() {
                        checkBoxState = value!;
                      });
                    },
                    side: BorderSide(
                        width: 2.0.dp(),
                        color: theme(
                            ColorHelper.colorGray, ColorHelper.colorGray2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0.dp())),
                  )),
              Expanded(
                  child: Text(
                appLocalized().not_show_again,
                style: UIFont.fontApp(
                    14.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              )),
            ]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            BounceButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0.dp())),
                color: ColorHelper.colorBlue,
                child: Container(
                    width: preferenceHelper.widthScreen / 5 - 10.0.dp(),
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(
                        6.0.dp(), 4.0.dp(), 6.0.dp(), 6.0.dp()),
                    child: Text(appLocalized().submit,
                        style: UIFont.fontAppBold(13.0.sp(), Colors.white))),
                onPress: () {
                  Navigator.pop(context);
                  if (checkBoxState) {
                    preferenceHelper.isAskSubmitPractice = false;
                  }
                  widget.submitListener();
                }),
            SizedBox(width: 12.0.dp()),
            BounceButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0.dp()),
                    side: BorderSide(
                        width: 1.0.dp(),
                        color: theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight))),
                color: theme(ColorHelper.colorBackgroundChildDay,
                    ColorHelper.colorBackgroundChildNight),
                child: Container(
                    width: preferenceHelper.widthScreen / 5 - 10,
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(
                        6.0.dp(), 4.0.dp(), 6.0.dp(), 6.0.dp()),
                    child: Text(appLocalized().cancel,
                        style: UIFont.fontAppBold(
                            13.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)))),
                onPress: () {
                  Navigator.pop(context);
                }),
            SizedBox(width: 20.0.dp())
          ]),
          SizedBox(height: 16.0.dp())
        ]);
  }
}
