import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../model/home/home_screen_item.dart';
import '../../../model/user/ads_in_house_json_object.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/utils.dart';

// ignore: must_be_immutable
class PracticeBannerTop1Cell extends BasePage {
  Function(String tab) selectTabListener;

  PracticeBannerTop1Cell(this.selectTabListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeBannerTop1Cell> {
  var _checkTrack = false;

  @override
  Widget build(BuildContext context) {
    final isCloseBanner =
        context.select((AppProvider provider) => provider.isCloseBannerTop1);
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    if (isCloseBanner || isPremium) return const SizedBox(height: 0);

    final bannerObject =
        context.select((AppProvider provider) => provider.bannerTop1);

    if (bannerObject == null) return const SizedBox(height: 0);

    if (!_checkTrack) {
      _checkTrack = true;
      Future.delayed(Duration.zero, () async {
        final adsObject = preferenceHelper.adsInHouseObject;
        if (adsObject != null) {
          Utils.trackAdsInHouseEvent(
              preferenceHelper.idUser,
              adsObject.adGroupId ?? 0,
              adsObject.adId ?? 0,
              2,
              0,
              bannerObject.action ?? "");
        }
      });
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 8.0.dp()),
      child: AspectRatio(
        aspectRatio: 67 / 22,
        child: GestureDetector(
          onTap: () {
            _handleBannerClick(bannerObject);
          },
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 4.0.dp(),
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0.dp())),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0.dp()),
                  child: Image.network(
                    bannerObject.image!,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      appProviderRead.isCloseBannerTop1 = true;
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(10.0.dp()),
                      child: SvgPicture.asset(
                        "ic_close_2".withIcon(),
                        width: 20.0.dp(),
                        height: 20.0.dp(),
                        color: ColorHelper.colorRed,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleBannerClick(BannerObject bannerObject) {
    final action = bannerObject.action;
    if (action.isNullOrEmpty) return;

    switch (action) {
      case "premium":
        widget.selectTabListener(HomeScreenItem.routePremium);
        break;
      case "fulltest":
        widget.selectTabListener(HomeScreenItem.routeExam);
        break;
      case "package":
        final package = bannerObject.package;
        if (!package.isNullOrEmpty) {
          if (Platform.isIOS && package!.startsWith("id")) {
            StoreRedirect.redirect(iOSAppId: package.replaceFirst("id", ""));
          } else if (Platform.isAndroid) {
            StoreRedirect.redirect(androidAppId: package);
          }
        }
        break;
      case "link":
        final link = bannerObject.link;
        if (!link.isNullOrEmpty) {
          Utils.openLink(link!);
        }
        break;
    }

    Utils.trackBannerEvent("Banner Top 1: ${bannerObject.name ?? ""}");
    final adsObject = preferenceHelper.adsInHouseObject;
    if (adsObject != null) {
      Utils.trackAdsInHouseEvent(
          preferenceHelper.idUser,
          adsObject.adGroupId ?? 0,
          adsObject.adId ?? 0,
          (bannerObject.isSubBanner ?? false) ? 4 : 1,
          1,
          action!);
    }
  }
}
