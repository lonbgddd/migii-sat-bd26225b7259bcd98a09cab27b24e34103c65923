import 'dart:io';

import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_cell/premium/premium_banner_view.dart';
import '../../view_cell/premium/premium_countdown_view.dart';
import '../../view_cell/premium/premium_purchase_view.dart';
import '../../view_cell/premium/premium_upgrade_view.dart';

// ignore: must_be_immutable
class PremiumTabView extends BasePage {
  Function(String skuId) purchaseListener;

  PremiumTabView(this.purchaseListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PremiumTabView> {

  @override
  void initState() {
    super.initState();
    Utils.trackerScreen("HomeScreen - Premium");
  }

  @override
  Widget build(BuildContext context) {
    return viewContainer();
  }

  Widget viewContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme(
          ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
      child: Column(children: [
        Container(
            width: double.infinity,
            height: preferenceHelper.appBarHeight +
                preferenceHelper.paddingInsetsTop,
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            decoration: BoxDecoration(
                color: ColorHelper.colorPrimary,
                boxShadow: kElevationToShadow[3]),
            child: Stack(children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  appLocalized().upgrade,
                  style:
                      UIFont.fontAppBold(18.0.sp(), ColorHelper.colorTextNight),
                ),
              )
            ])),
        Expanded(child: listViewItem())
      ]),
    );
  }

  ListView listViewItem() {
    return ListView.builder(
        key: const PageStorageKey("PremiumTabView"),
        padding: EdgeInsets.only(bottom: 24.0.dp(), top: 6.0.dp()),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Builder(builder: (context) {
            return getItem(context, index);
          });
        },
        shrinkWrap: true);
  }

  Widget getItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const PremiumBannerView();
      case 1:
        return PremiumUpgradeView(context).init();
      case 2:
        return PremiumCountdownView(context).init();
      case 3:
        return PremiumPurchaseView(widget.purchaseListener);
      case 4:
        return Padding(
            padding:
                EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 12.0.dp()),
            child: Text(
              Platform.isAndroid
                  ? appLocalized().des_subscription_android
                  : appLocalized().des_subscription_ios,
              style: UIFont.fontApp(
                  14.0.sp(),
                  theme(
                      ColorHelper.colorTextDay2, ColorHelper.colorTextNight2)),
              textAlign: TextAlign.center,
            ));
      default:
        return const Text("other");
    }
  }
}
