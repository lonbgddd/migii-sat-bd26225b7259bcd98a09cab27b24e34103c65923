import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../view_custom/base_view.dart';

class PremiumUpgradeView extends BaseView {
  PremiumUpgradeView(super.context);

  Widget init() {
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);
    final timeServer =
        context.select((AppProvider provider) => provider.timeServer);
    if (!isPremium) return const SizedBox(width: double.infinity, height: 0);

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

    var expiry = "";
    if (timeExpire > 0) {
      if (timeServer > timeExpire) {
        Future.delayed(Duration.zero, () async {
          preferenceHelper.setPremium(false, isAccount);
          preferenceHelper.setPremiumPackage("", isAccount);
          appProviderRead.isPremium = preferenceHelper.isPremium();
        });
        return const SizedBox(width: double.infinity, height: 0);
      } else {
        expiry = DateFormat("dd/MM/yyyy")
            .format(DateTime.fromMillisecondsSinceEpoch(timeExpire * 1000));
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.0.dp(), 16.0.dp(), 16.0.dp(), 4.0.dp()),
      child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.dp()),
              side: BorderSide(
                  color:
                      theme(ColorHelper.colorPrimary, ColorHelper.colorAccent),
                  width: 1.0.dp())),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          child: Column(children: [
            SizedBox(height: 20.0.dp()),
            Text(appLocalized().did_upgrade,
                style: UIFont.fontAppBold(
                    17.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight))),
            SizedBox(height: 12.0.dp()),
            Text(
              packageName,
              style: UIFont.fontAppBold(
                  20.0.sp(),
                  theme(
                      ColorHelper.colorTextGreenDay, ColorHelper.colorAccent)),
            ),
            if (expiry.isNotEmpty) ...[
              SizedBox(height: 4.0.dp()),
              Text(
                appLocalized().expires_on.format([expiry]),
                style: UIFont.fontApp(
                    14,
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              )
            ],
            SizedBox(height: 20.0.dp())
          ])),
    );
  }
}
