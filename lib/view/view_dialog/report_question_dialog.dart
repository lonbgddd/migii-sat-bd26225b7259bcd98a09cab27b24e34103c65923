import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/view_custom/toast.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

import '../../main.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../base/base_stateful.dart';
import '../view_custom/bounce_button.dart';

class ReportQuestionDialog extends BasePage {
  final Function(String content) sendListener;

  const ReportQuestionDialog(this.sendListener, {Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, Function(String content) sendListener) {
    showGeneralDialog(
        barrierLabel: "ReportQuestionDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          return Column(children: [
            Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: ReportQuestionDialog(sendListener))),
            SizedBox(height: keyboardHeight)
          ]);
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<ReportQuestionDialog> {
  String reportContent = "";

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
        children: [
          SizedBox(height: 10.0.dp()),
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 16.0.dp(), right: 12.0.dp()),
                child: SvgPicture.asset(
                  "ic_report_error".withIcon(),
                  width: 36.0.dp(),
                  height: 36.0.dp(),
                )),
            Expanded(
                child: AutoSizeText(
              appLocalized().error_report,
              style: UIFont.fontAppBold(16.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              minFontSize: 12.0.sp(),
            ))
          ]),
          Container(
            width: double.infinity,
            margin:
                EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 16.0.dp()),
            padding: EdgeInsets.only(left: 12.0.dp(), right: 12.0.dp()),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0.dp()),
                border: Border.all(
                    color: theme(
                        ColorHelper.colorTextDay2, ColorHelper.colorTextNight2),
                    width: 1.0.dp())),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 88.0.dp(),
                  maxHeight: preferenceHelper.screenWidthMinimum / 3),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: appLocalized().anything_report,
                    hintMaxLines: 5,
                    hintStyle: UIFont.fontApp(15.0.sp(),
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2))),
                style: UIFont.fontApp(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                onChanged: (text) {
                  reportContent = text;
                },
                maxLines: null,
                keyboardType: TextInputType.text,
              ),
            ),
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
                    child: Text(appLocalized().send,
                        style: UIFont.fontAppBold(13.0.sp(), Colors.white))),
                onPress: () {
                  if (isInternetAvailable) {
                    Navigator.pop(context);
                    widget.sendListener(reportContent.trim());
                  } else {
                    Toast(appLocalized().no_internet).show();
                  }
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
                    child: Text(appLocalized().skip,
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
