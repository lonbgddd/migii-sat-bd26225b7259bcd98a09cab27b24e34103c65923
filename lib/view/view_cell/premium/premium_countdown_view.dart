import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../view_custom/base_view.dart';

class PremiumCountdownView extends BaseView {
  PremiumCountdownView(super.context);

  Widget init() {
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);
    if (isPremium) {
      final isAccount = preferenceHelper.typePremiumPriority == 2;
      final skuId = preferenceHelper.getPremiumPackage(isAccount);
      if (skuId != GlobalHelper.sku3Days &&
          skuId != GlobalHelper.sku5Days &&
          skuId != GlobalHelper.sku7Days) return const SizedBox(height: 0);
    }

    final timeServer =
        context.select((AppProvider provider) => provider.timeServer);

    var day = 0;
    var hour = 0;
    var minute = 0;
    var second = 0;

    // bool isActiveSaleLocal;
    // if (SaleLocalHelper.isActiveSaleLocal(timeServer)) {
    //   isActiveSaleLocal = true;
    //
    //   final endSale = preferenceHelper.timeStartSaleLocal + 86400;
    //   var timeRemain = endSale - timeServer;
    //   day = timeRemain ~/ 86400;
    //
    //   timeRemain -= day * 86400;
    //   hour = timeRemain ~/ 3600;
    //
    //   timeRemain -= hour * 3600;
    //   minute = timeRemain ~/ 60;
    //   second = timeRemain - minute * 60;
    // } else {
    // isActiveSaleLocal = false;

    final adsObject = preferenceHelper.adsInHouseObject;
    if (adsObject == null) return const SizedBox(height: 0);

    final startSale = adsObject.start ?? 0;
    final endSale = adsObject.end ?? 0;
    if (startSale == 0 || endSale == 0) return const SizedBox(height: 0);

    if (timeServer < startSale || timeServer > endSale) {
      return const SizedBox(height: 0);
    }

    var timeRemain = endSale - timeServer;
    day = timeRemain ~/ 86400;

    timeRemain -= day * 86400;
    hour = timeRemain ~/ 3600;

    timeRemain -= hour * 3600;
    minute = timeRemain ~/ 60;
    second = timeRemain - minute * 60;
    // }

    return SizedBox(
        width: double.infinity,
        child: Column(children: [
          SizedBox(height: 16.0.dp()),
          Text(
              // isActiveSaleLocal
              //     ? appLocalized().heyko_offer.replaceAll("(percent)", "70") :
              "MIGII SALE OFF",
              style: UIFont.fontAppBold(17.0.sp(), ColorHelper.colorRed),
              textAlign: TextAlign.center),
          Text(appLocalized().offer_countdown,
              style: UIFont.fontAppBold(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight))),
          SizedBox(height: 8.0.dp()),
          Row(mainAxisSize: MainAxisSize.min, children: [
            timeView(day, appLocalized().day, appLocalized().days),
            timeView(hour, appLocalized().hour, appLocalized().hours),
            timeView(minute, appLocalized().min, appLocalized().mins),
            timeView(second, appLocalized().second, appLocalized().seconds)
          ]),
          SizedBox(height: 4.0.dp())
        ]));
  }

  Container timeView(int time, String title, String titles) {
    return Container(
        margin: EdgeInsets.all(4.0.dp()),
        width: 60.0.dp(),
        height: 72.0.dp(),
        child: Card(
            elevation: 4.0.dp(),
            margin: EdgeInsets.zero,
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0.dp()),
                side: BorderSide(
                    color: theme(ColorHelper.colorBackgroundChildDay,
                        ColorHelper.colorTextNight2),
                    width: 1.0.dp())),
            child: Column(children: [
              SizedBox(height: 8.0.dp()),
              AutoSizeText(
                time < 10 ? "0$time" : "$time",
                style: UIFont.fontAppBold(
                    22.0.sp(),
                    theme(ColorHelper.colorTextGreenDay,
                        ColorHelper.colorAccent)),
                maxLines: 1,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(2.0.dp(), 4.0.dp(), 2.0.dp(), 0),
                child: AutoSizeText(time < 2 ? title : titles,
                    style: UIFont.fontApp(
                        13.0.sp(),
                        theme(ColorHelper.colorTextDay2,
                            ColorHelper.colorTextNight2)),
                    maxLines: 1,
                    minFontSize: 8.0.sp()),
              )
            ])));
  }
}
