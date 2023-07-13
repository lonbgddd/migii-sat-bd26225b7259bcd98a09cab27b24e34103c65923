import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/user/log_in_screen.dart';
import 'package:migii_sat/view/view_screen/user/register_screen.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:provider/provider.dart';

import '../../../model/user/user_profile_json_object.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';

// ignore: must_be_immutable
class SettingAccountCell extends BasePage {
  VoidCallback logOutListener;

  SettingAccountCell(this.logOutListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<SettingAccountCell> {
  @override
  Widget build(BuildContext context) {
    final userObject =
        context.select((AppProvider provider) => provider.userObject);
    final isLogin = userObject != null;
    return isLogin ? _viewDidLogin(userObject) : _logInView();
  }

  Widget _viewDidLogin(UserProfileJSONObject userObject) {
    final languageApp =
        context.select((AppProvider provider) => provider.languageApp);
    final isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);
    final doingLogOut =
        context.select((AppProvider provider) => provider.doingLogOut);

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40.0.dp(),
        height: 40.0.dp(),
        margin: EdgeInsets.fromLTRB(12.0.dp(), 6.0.dp(), 4.0.dp(), 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0.dp()),
            border: Border.all(
                color: theme(ColorHelper.colorTextGreenDay,
                    ColorHelper.colorTextGreenNight,
                    isNightMode: isNightMode),
                width: 1.0.dp())),
        child: Image.asset("img_logo_migii_character_small".withImage()),
      ),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.0.dp(), 14.0.dp(), 12.0.dp(), 0),
            child: Text(
              userObject.name ?? "",
              style: UIFont.fontAppBold(
                  16.0.dp(),
                  theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight)),
              maxLines: 1,
            ),
          ),
          doingLogOut
              ? Container(
                  margin:
                      EdgeInsets.fromLTRB(32.0.dp(), 6.0.dp(), 0, 14.0.dp()),
                  child: SizedBox(
                      width: 20.0.dp(),
                      height: 20.0.dp(),
                      child: const LoadingIndicator(
                          indicatorType: Indicator.lineSpinFadeLoader,
                          colors: [ColorHelper.colorAccent])))
              : GestureDetector(
                  onTap: () {
                    widget.logOutListener();
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(
                        14.0.dp(), 8.0.dp(), 14.0.dp(), 14.0.dp()),
                    child: Text(
                      appLocalized(languageApp: languageApp).sign_out,
                      style: UIFont.fontAppBold(
                          13.0.sp(), ColorHelper.colorAccent,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
          Container(
              height: 1.0.dp(),
              width: double.infinity,
              margin: EdgeInsets.only(left: 6.0.dp()),
              color: theme(ColorHelper.colorTextGreenDay,
                  ColorHelper.colorTextGreenNight))
        ],
      ))
    ]);
  }

  Widget _logInView() {
    final languageApp =
        context.select((AppProvider provider) => provider.languageApp);
    final isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: 6.0.dp()),
      Row(children: [
        Container(
          width: 40.0.dp(),
          height: 40.0.dp(),
          margin: EdgeInsets.only(left: 12.0.dp(), right: 4.0.dp()),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0.dp()),
              border: Border.all(
                  color: theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight,
                      isNightMode: isNightMode),
                  width: 1.0.dp())),
          child: Image.asset("img_logo_migii_character_small".withImage()),
        ),
        GestureDetector(
          onTap: () {
            RouterNavigate.pushScreen(context, const LogInScreen());
          },
          child: Container(
            color: Colors.transparent,
            height: 48.0.dp(),
            padding: EdgeInsets.fromLTRB(20.0.dp(), 0, 20.0.dp(), 2.0.dp()),
            alignment: Alignment.center,
            child: Text(
              appLocalized(languageApp: languageApp).sign_in,
              style: UIFont.fontAppBold(
                  15.0.sp(),
                  theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight)),
            ),
          ),
        ),
        Container(
          width: 1.0.dp(),
          height: 36.0.dp(),
          color: theme(
              ColorHelper.colorTextGreenDay, ColorHelper.colorTextGreenNight),
        ),
        GestureDetector(
          onTap: () {
            RouterNavigate.pushScreen(context, const RegisterScreen());
          },
          child: Container(
            color: Colors.transparent,
            height: 48.0.dp(),
            padding: EdgeInsets.fromLTRB(20.0.dp(), 0, 20.0.dp(), 2.0.dp()),
            alignment: Alignment.center,
            child: Text(
              appLocalized().register,
              style: UIFont.fontAppBold(
                  15.0.sp(),
                  theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight)),
            ),
          ),
        )
      ]),
      Container(
          height: 1.0.dp(),
          width: double.infinity,
          margin: EdgeInsets.only(left: 62.0.dp()),
          color: theme(
              ColorHelper.colorTextGreenDay, ColorHelper.colorTextGreenNight))
    ]);
  }
}
