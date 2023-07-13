import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../base/base_stateful.dart';

class LanguageAppDialog extends BasePage {
  final VoidCallback? listener;

  const LanguageAppDialog({Key? key, this.listener}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, VoidCallback? changeLanguageListener) {
    showGeneralDialog(
        barrierLabel: "LanguageAppDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center,
              child: LanguageAppDialog(listener: changeLanguageListener));
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return ScaleTransition(scale: anim1, child: child);
        });
  }
}

class _State extends BasePageState<LanguageAppDialog> {
  String _languageApp = preferenceHelper.languageApp;
  var didSelect = false;

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
          Padding(
              padding: EdgeInsets.only(left: 20.0.dp(), top: 14.0.dp()),
              child: Text(
                  appLocalized(languageApp: _languageApp).select_edition,
                  style: UIFont.fontAppBold(
                      18.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)))),
          SizedBox(height: 8.0.dp()),
          languageView("English", "en"),
          languageView("Tiếng Việt", "vi"),
          languageView("Español", "es"),
          languageView("한국어", "ko"),
          languageView("简体中文", "cn"),
          languageView("繁體中文", "tw"),
          SizedBox(height: 12.0.dp())
        ]);
  }

  GestureDetector languageView(String languageName, String languageCode) {
    var isSelected = languageCode == _languageApp;

    return GestureDetector(
        child: Container(
            color: Colors.transparent,
            height: 44.0.dp(),
            width: double.infinity,
            child: Row(children: [
              Container(
                alignment: Alignment.center,
                width: 20.0.dp(),
                height: 20.0.dp(),
                margin: EdgeInsets.only(left: 32.0.dp()),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0.dp(),
                        color: isSelected
                            ? theme(ColorHelper.colorTextGreenDay,
                                ColorHelper.colorAccent)
                            : theme(ColorHelper.colorTextDay2,
                                ColorHelper.colorTextNight2)),
                    shape: BoxShape.circle),
                child: isSelected
                    ? Container(
                        width: 10.0.dp(),
                        height: 10.0.dp(),
                        decoration: BoxDecoration(
                            color: theme(ColorHelper.colorTextGreenDay,
                                ColorHelper.colorAccent),
                            shape: BoxShape.circle),
                      )
                    : null,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: 20.0.dp(), right: 16.0.dp(), bottom: 2.0.dp()),
                  child: Text(languageName,
                      style: UIFont.fontApp(
                          16.0.sp(),
                          theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight))))
            ])),
        onTap: () {
          setState(() {
            if (didSelect) return;
            didSelect = true;

            if (_languageApp == languageCode) {
              Navigator.pop(context);
              return;
            }

            _languageApp = languageCode;
            preferenceHelper.languageApp = languageCode;

            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.pop(context);
              if (widget.listener != null) {
                widget.listener!();
              }
            });
          });
        });
  }
}
