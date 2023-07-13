import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/viewmodel/extensions/double_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/global_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../../viewmodel/helper/utils.dart';
import '../base/base_stateful.dart';
import '../view_custom/bounce_button.dart';

class TransferDialog extends BasePage {
  const TransferDialog({super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "TransferDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.bottomCenter, child: TransferDialog());
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 0.5), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<TransferDialog> {
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.0.dp()),
                topRight: Radius.circular(22.0.dp()))),
        child: viewContainer());
  }

  Column viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    final sku12Months =
        context.select((AppProvider provider) => provider.sku12Months);
    final sku6Months =
        context.select((AppProvider provider) => provider.sku6Months);
    final sku3Months =
        context.select((AppProvider provider) => provider.sku3Months);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding:
              EdgeInsets.fromLTRB(16.0.dp(), 20.0.dp(), 16.0.dp(), 12.0.dp()),
          child: AutoSizeText(appLocalized().discount_5_when_payment_trans,
              style: UIFont.fontAppBold(
                  15.0.sp(),
                  theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight)),
              maxLines: 2,
              textAlign: TextAlign.center)),
      premiumItem(sku12Months, GlobalHelper.sku12Months),
      premiumItem(sku6Months, GlobalHelper.sku6Months),
      premiumItem(sku3Months, GlobalHelper.sku3Months),
      Padding(
          padding:
              EdgeInsets.fromLTRB(16.0.dp(), 20.0.dp(), 16.0.dp(), 16.0.dp()),
          child: AutoSizeText(appLocalized().choose_payment,
              style: UIFont.fontAppBold(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 2,
              textAlign: TextAlign.center)),
      Padding(
          padding: EdgeInsets.fromLTRB(
              12.0.dp(), 0, 12.0.dp(), paddingBottom + 20.0.dp()),
          child:
              Row(children: [supportItem("email"), supportItem("messenger")]))
    ]);
  }

  Widget premiumItem(String skuId, String skuType) {
    var packageName = "";
    var salePercent = 0;

    switch (skuType) {
      case GlobalHelper.sku12Months:
        packageName = appLocalized().annual;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
      case GlobalHelper.sku6Months:
        packageName = appLocalized().semiannual;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
      case GlobalHelper.sku3Months:
        packageName = appLocalized().quarterly;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
    }

    return Row(children: [
      SizedBox(width: 20.0.dp()),
      SvgPicture.asset("ic_finger".withIcon(),
          width: 24.0.dp(), height: 24.0.dp()),
      Expanded(
          child: Container(
        margin: EdgeInsets.fromLTRB(12.0.dp(), 6.0.dp(), 20.0.dp(), 6.0.dp()),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0.dp()),
            border: Border.all(
                color: theme(ColorHelper.colorTextGreenDay,
                    ColorHelper.colorTextGreenNight),
                width: 1.0.dp())),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.0.dp(), 8.0.dp(), 12.0.dp(), 0),
              child: AutoSizeText(
                packageName,
                style: UIFont.fontAppBold(
                    16.0.sp(),
                    theme(ColorHelper.colorTextGreenDay,
                        ColorHelper.colorTextGreenNight)),
                maxLines: 1,
                minFontSize: 8.0.sp(),
              ),
            ),
            Row(children: [
              SizedBox(width: 12.0.dp()),
              Text(
                preferenceHelper
                    .getSkuPrice(skuType, salePercent)
                    .convertPrice(0),
                style: UIFont.fontAppBold(14.0.sp(),
                    theme(ColorHelper.colorGray, ColorHelper.colorGray2),
                    decoration: TextDecoration.lineThrough,
                    underlineSpace: -1,
                    decorationThickness: 1),
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0.dp(), top: 2.0.dp()),
                child: Text(
                    preferenceHelper
                        .getSkuPrice(skuType, salePercent)
                        .convertPrice(-5),
                    style: UIFont.fontAppBold(
                      14.0.sp(),
                      theme(
                          ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                    )),
              )
            ]),
            SizedBox(height: 8.0.dp())
          ],
        ),
      ))
    ]);
  }

  Expanded supportItem(String type) {
    var icon = "";
    var title = "";
    switch (type) {
      case "email":
        icon = "ic_email";
        title = appLocalized().send_email;
        break;
      case "messenger":
        icon = "ic_messenger";
        title = "Messenger";
        break;
    }

    return Expanded(
        child: Padding(
            padding:
                EdgeInsets.fromLTRB(8.0.dp(), 4.0.dp(), 8.0.dp(), 4.0.dp()),
            child: SizedBox(
                height: 44.0.dp(),
                child: BounceButton(
                    color: theme(ColorHelper.colorBackgroundChildDay,
                        ColorHelper.colorBackgroundChildNight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0.dp()),
                        side: BorderSide(
                            color: ColorHelper.colorBackgroundChildDay,
                            width: 1.0.dp())),
                    child: Row(children: [
                      Padding(
                          padding: EdgeInsets.only(left: 24.0.dp()),
                          child: SvgPicture.asset(icon.withIcon(),
                              width: 20.0.dp(), height: 20.0.dp())),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            12.0.dp(), 0, 24.0.dp(), 2.0.dp()),
                        child: AutoSizeText(title,
                            style: UIFont.fontAppBold(
                                15.0.sp(),
                                theme(ColorHelper.colorTextDay,
                                    ColorHelper.colorTextNight)),
                            maxLines: 1,
                            textAlign: TextAlign.center),
                      ))
                    ]),
                    onPress: () {
                      _handleClick(type);
                      Navigator.pop(context);
                    }))));
  }

  _handleClick(String type) {
    switch (type) {
      case "email":
        _sendEmail();
        break;
      case "messenger":
        Utils.openMessenger();
        break;
    }
  }

  _sendEmail() async {
    final infoDevice = "App version: ${preferenceHelper.versionApp} \n";
    final order =
        "${appLocalized().support_name}: \n${appLocalized().support_phone}: \n${appLocalized().support_email}: \n";

    final Email email = Email(
      body: "$infoDevice$order",
      subject: appLocalized().order_migii,
      recipients: [GlobalHelper.emailSupport],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}
