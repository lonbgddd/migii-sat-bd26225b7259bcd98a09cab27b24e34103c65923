import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_dialog/feedback_dialog.dart';
import 'package:migii_sat/viewmodel/extensions/double_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/highlight_text.dart';
import '../../view_dialog/transfer_dialog.dart';

// ignore: must_be_immutable
class PremiumPurchaseView extends BasePage {
  Function(String skuId) purchaseListener;

  PremiumPurchaseView(this.purchaseListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PremiumPurchaseView> {
  final _pageViewController = PageController(
      initialPage: 1,
      viewportFraction: 172.0.dp() / preferenceHelper.widthScreen);
  int _currentIndex = 1;
  var initPage = false;

  @override
  Widget build(BuildContext context) {
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);
    if (isPremium) {
      final isAccount = preferenceHelper.typePremiumPriority == 2;
      final skuId = preferenceHelper.getPremiumPackage(isAccount);
      if (skuId != GlobalHelper.sku3Days &&
          skuId != GlobalHelper.sku5Days &&
          skuId != GlobalHelper.sku7Days) return Container(height: 0);
    }

    if (!initPage) {
      initPage = true;
      Future.delayed(Duration.zero, () async {
        _pageViewController.jumpToPage(1);
      });
    }

    final sku3Months =
        context.select((AppProvider provider) => provider.sku3Months);
    final sku6Months =
        context.select((AppProvider provider) => provider.sku6Months);
    final sku12Months =
        context.select((AppProvider provider) => provider.sku12Months);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: double.infinity,
        height: 172.0.dp(),
        margin: EdgeInsets.only(top: 16.0.dp()),
        child: PageView.builder(
            controller: _pageViewController,
            itemCount: 3,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              var scale = _currentIndex == index ? 1.0 : 0.8;
              return TweenAnimationBuilder(
                  tween: Tween(begin: scale, end: scale),
                  duration: const Duration(milliseconds: 250),
                  child: _purchaseView(
                      index == 0
                          ? sku6Months
                          : (index == 1 ? sku12Months : sku3Months),
                      index),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  });
            }),
      ),
      SizedBox(height: 4.0.dp()),
      if (preferenceHelper.countryCode.toLowerCase() == "vn")
        GestureDetector(
          onTap: () {
            TransferDialog.show(context);
          },
          child: Container(
              color: Colors.transparent,
              height: 44.0.dp(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 8.0.dp()),
                SvgPicture.asset(
                  "ic_sale".withIcon(),
                  width: 20.0.dp(),
                  height: 20.0.dp(),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(8.0.dp(), 2.0.dp(), 14.0.dp(), 0),
                    child: AutoSizeText(
                      appLocalized().discount_5_when_payment_trans,
                      style: UIFont.fontAppBold(
                          14.0.sp(), ColorHelper.colorAccent,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.0.dp()),
                      maxLines: 1,
                      minFontSize: 8.0.sp(),
                    ),
                  ),
                )
              ])),
        ),
      GestureDetector(
        onTap: () {
          widget.purchaseListener("restore_payment");
        },
        child: Container(
            color: Colors.transparent,
            height: 44.0.dp(),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 8.0.dp()),
              SvgPicture.asset(
                "ic_restore".withIcon(),
                width: 20.0.dp(),
                height: 20.0.dp(),
                color: theme(ColorHelper.colorTextGreenDay,
                    ColorHelper.colorTextGreenNight),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0.dp(), 0, 28.0.dp(), 2.0.dp()),
                child: Text(
                  appLocalized().restore_payment,
                  style: UIFont.fontAppBold(
                      15.0.sp(),
                      theme(ColorHelper.colorTextGreenDay,
                          ColorHelper.colorTextGreenNight),
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.0.dp()),
                ),
              )
            ])),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 4.0.dp(), 16.0.dp(), 0),
        child: HighlightText(
          text: appLocalized().happend_payment,
          style: UIFont.fontApp(14.0.sp(),
              theme(ColorHelper.colorTextDay2, ColorHelper.colorTextNight2)),
          spanList: [
            SpanItem(
                text: appLocalized().happend_payment_key,
                onTap: () {
                  FeedbackDialog.show(context);
                })
          ],
          spanStyle: UIFont.fontApp(14.0.sp(), ColorHelper.colorAccent,
              decoration: TextDecoration.underline,
              decorationThickness: 1,
              underlineSpace: 1),
          textAlign: TextAlign.center,
        ),
      )
    ]);
  }

  Widget _purchaseView(String skuId, int posItem) {
    String skuType = "";
    var imgSalePercent = "";
    var packageName = "";
    int month = 1;
    var salePercent = 0;

    switch (posItem) {
      case 0:
        skuType = GlobalHelper.sku6Months;
        packageName = appLocalized().semiannual;
        imgSalePercent = "bg_sale_blue";
        month = 6;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
      case 1:
        skuType = GlobalHelper.sku12Months;
        packageName = appLocalized().annual;
        imgSalePercent = "bg_sale_red";
        month = 12;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
      case 2:
        skuType = GlobalHelper.sku3Months;
        packageName = appLocalized().quarterly;
        imgSalePercent = "bg_sale_green";
        month = 3;
        salePercent = skuId == skuType
            ? 0
            : (int.tryParse(skuId.replaceAll("${skuType}_", "")) ?? 0);
        break;
    }

    return GestureDetector(
      onTap: () {
        _pageViewController.animateToPage(posItem,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
        widget.purchaseListener(skuId);
        Utils.trackerEvent("premium", "premium_click_$skuType");
      },
      child: Card(
          elevation: 4.0.dp(),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.dp())),
          margin: EdgeInsets.only(top: 8.0.dp(), bottom: 8.0.dp()),
          child: Stack(children: [
            if (salePercent > 0) ...{
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.0.dp(), right: 4.0.dp()),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      imgSalePercent.withImage(),
                      width: 68.0.dp(),
                      height: 68.0.dp(),
                      fit: BoxFit.fill,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6.0.dp()),
                      child: Text(
                        "$salePercent%\nOFF",
                        style: UIFont.fontAppBold(13.0.sp(), Colors.white),
                      ),
                    )
                  ]),
                ),
              ),
            },
            Padding(
              padding: EdgeInsets.only(left: 12.0.dp(), top: 24.0.dp()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 76.0.dp()),
                    child: AutoSizeText(
                      packageName,
                      style: UIFont.fontAppBold(
                          18.0.sp(),
                          theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight)),
                      maxLines: 1,
                      minFontSize: 8.0.sp(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.0.dp(), right: 12.0.dp()),
                    child: AutoSizeText(
                      preferenceHelper
                          .getSkuPrice(skuType, salePercent)
                          .convertPrice(0),
                      style: UIFont.fontAppBold(
                          20.0.sp(),
                          theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight)),
                      maxLines: 1,
                      minFontSize: 8.0.sp(),
                    ),
                  ),
                  SizedBox(height: 8.0.dp()),
                  Text(
                    salePercent > 0
                        ? "${preferenceHelper.getSkuPrice(skuType, salePercent).convertPriceSaving(salePercent, appLocalized().savings)} "
                        : " ",
                    style: UIFont.fontApp(14.0.sp(),
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2),
                        decoration:
                            salePercent > 0 ? TextDecoration.lineThrough : null,
                        underlineSpace: -1,
                        decorationThickness: 1.5),
                  ),
                  Container(
                      margin:
                          EdgeInsets.fromLTRB(4.0.dp(), 8.0.dp(), 16.0.dp(), 0),
                      height: 1.0.dp(),
                      width: double.infinity,
                      color: theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding:
                          EdgeInsets.only(bottom: 6.0.dp(), right: 12.0.dp()),
                      child: AutoSizeText(
                        preferenceHelper
                            .getSkuPrice(skuType, salePercent)
                            .convertPricePerMonth(
                                0, month, appLocalized().month),
                        style: UIFont.fontApp(
                            15.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)),
                        maxLines: 1,
                        minFontSize: 8.0.sp(),
                      ),
                    ),
                  )
                ],
              ),
            )
          ])),
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }
}
