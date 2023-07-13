import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import 'package:app_settings/app_settings.dart';

class ConnectInternetDialog extends BasePage {
  const ConnectInternetDialog({Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "ConnectInternetDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.center, child: ConnectInternetDialog());
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

class _State extends BasePageState<ConnectInternetDialog> {
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
      Padding(
          padding: EdgeInsets.fromLTRB(16.0.dp(), 14.0.dp(), 16.0.dp(), 0),
          child: AutoSizeText(
            appLocalized().setting_internet_title,
            style: UIFont.fontAppBold(17.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 8.0.sp(),
          )),
      Padding(
          padding:
              EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 16.0.dp()),
          child: Text(
            appLocalized().setting_internet_content,
            style: UIFont.fontApp(14.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            textAlign: TextAlign.center,
          )),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            AppSettings.openWIFISettings();
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
                appLocalized().setting_internet_button,
                style:
                    UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                maxLines: 1,
                minFontSize: 8.0.sp(),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 12.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40.0.dp(),
            padding: EdgeInsets.only(left: 12.0.dp(), right: 12.0.dp()),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0.dp()),
                border: Border.all(
                    color: theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                    width: 1.0.dp())),
            child: AutoSizeText(
              appLocalized().cancel,
              style: UIFont.fontAppBold(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              minFontSize: 8.0.sp(),
            ),
          ),
        ),
      ),
      SizedBox(height: 16.0.dp())
    ]);
  }
}
