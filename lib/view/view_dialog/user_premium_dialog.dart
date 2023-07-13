import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/global_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';

class UserPremiumDialog extends BasePage {
  const UserPremiumDialog({Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "UserPremiumDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.center, child: UserPremiumDialog());
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

class _State extends BasePageState<UserPremiumDialog> {
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
    final isAccount = preferenceHelper.typePremiumPriority == 2;
    final skuId = preferenceHelper.getPremiumPackage(isAccount);

    var packageName = "";
    var timeExpire = 0;

    switch (skuId) {
      case GlobalHelper.sku12Months:
        packageName = appLocalized().annual;
        timeExpire = preferenceHelper.getExpiredTime(
            GlobalHelper.sku12Months, isAccount);
        break;
      case GlobalHelper.sku6Months:
        packageName = appLocalized().semiannual;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku6Months, isAccount);
        break;
      case GlobalHelper.sku3Months:
        packageName = appLocalized().quarterly;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku3Months, isAccount);
        break;
      case GlobalHelper.sku1Months:
        packageName = appLocalized().monthly;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku1Months, isAccount);
        break;
      case GlobalHelper.sku7Days:
        packageName = appLocalized().day_7;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku7Days, isAccount);
        break;
      case GlobalHelper.sku5Days:
        packageName = appLocalized().day_5;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku5Days, isAccount);
        break;
      case GlobalHelper.sku3Days:
        packageName = appLocalized().day_3;
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.sku3Days, isAccount);
        break;
      case GlobalHelper.skuCustom:
        packageName = "";
        timeExpire =
            preferenceHelper.getExpiredTime(GlobalHelper.skuCustom, isAccount);
        break;
    }

    var expiry = DateFormat("dd/MM/yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(timeExpire * 1000));

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding:
              EdgeInsets.fromLTRB(20.0.dp(), 16.0.dp(), 20.0.dp(), 8.0.dp()),
          child: Text(
            appLocalized().payment_success_content,
            style: UIFont.fontApp(17.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            textAlign: TextAlign.center,
          )),
      Text(
        packageName,
        style: UIFont.fontAppBold(18.0.sp(),
            theme(ColorHelper.colorTextGreenDay, ColorHelper.colorAccent)),
      ),
      if (expiry.isNotEmpty) ...[
        SizedBox(height: 4.0.dp()),
        Text(
          appLocalized().expires_on.format([expiry]),
          style: UIFont.fontApp(
              14, theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
        )
      ],
      SizedBox(height: 14.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
                appLocalized().close,
                style:
                    UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                maxLines: 1,
                minFontSize: 8.0.sp(),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 16.0.dp())
    ]);
  }
}
