import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../view_custom/bounce_button.dart';
import '../view_screen/user/log_in_screen.dart';

class RequestLoginDialog extends BasePage {
  const RequestLoginDialog({Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "RequestLoginDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.center, child: RequestLoginDialog());
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

class _State extends BasePageState<RequestLoginDialog> {
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
      SizedBox(height: 10.0.dp()),
      Image.asset(
        "img_logo_migii_character_small".withImage(),
        width: preferenceHelper.screenWidthMinimum / 5,
        fit: BoxFit.contain,
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
        child: Text(
          appLocalized().request_login_title,
          style: UIFont.fontAppBold(16.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 20.0.dp()),
        child: Text(
          appLocalized().request_login_content,
          style: UIFont.fontApp(14.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      ),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: SizedBox(
          height: 44.0.dp(),
          child: BounceButton(
            color: ColorHelper.colorPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0.dp())),
            child: Center(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 2.0.dp()),
                    child: Text(appLocalized().login_now,
                        style: UIFont.fontAppBold(
                            15.0.sp(), ColorHelper.colorTextNight)))),
            onPress: () {
              Navigator.pop(context);
              RouterNavigate.pushScreen(context, const LogInScreen());
            },
          ),
        ),
      ),
      SizedBox(height: 20.0.dp()),
    ]);
  }
}
