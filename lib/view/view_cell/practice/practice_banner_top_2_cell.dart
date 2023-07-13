import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../model/home/home_screen_item.dart';
import '../../../model/user/ads_in_house_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/utils.dart';

// ignore: must_be_immutable
class PracticeBannerTop2Cell extends BasePage {
  Function(String tab) selectTabListener;

  PracticeBannerTop2Cell(this.selectTabListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeBannerTop2Cell> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  int _countTimer = 0;
  var _checkTrack = false;

  List<BannerObject>? bannerList;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if ((bannerList?.length ?? 0) < 2) return;
      _countTimer++;

      if (_countTimer == 3) {
        _countTimer = 0;

        _currentPage =
            _currentPage < (bannerList!.length - 1) ? (_currentPage + 1) : 0;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bannerList = _getBannerList();
    if (bannerList.isNullOrEmpty) return const SizedBox(height: 0);

    if (!_checkTrack) {
      _checkTrack = true;
      Future.delayed(Duration.zero, () async {
        final adsObject = preferenceHelper.adsInHouseObject;
        if (adsObject != null) {
          for (final bannerObject in bannerList!) {
            Utils.trackAdsInHouseEvent(
                preferenceHelper.idUser,
                adsObject.adGroupId ?? 0,
                adsObject.adId ?? 0,
                2,
                0,
                bannerObject.action ?? "");
          }
        }
      });
    }

    final height = ((Utils.isPortrait(context)
                    ? preferenceHelper.widthScreen
                    : preferenceHelper.heightScreen) -
                32.0.dp()) *
            38 /
            67 +
        20.0.dp();

    return SizedBox(
        width: double.infinity,
        height: height,
        child: PageView(
            key: const PageStorageKey("UserBannerTop2Cell"),
            controller: _pageController,
            children: [
              for (final bannerObject in bannerList!) ...{
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16.0.dp(), 12.0.dp(), 16.0.dp(), 8.0.dp()),
                  child: GestureDetector(
                    onTap: () {
                      _handleSaleBannerClick(bannerObject);
                    },
                    child: Card(
                      elevation: 4.0.dp(),
                      margin: EdgeInsets.zero,
                      color: theme(ColorHelper.colorBackgroundChildDay,
                          ColorHelper.colorBackgroundChildNight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0.dp())),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0.dp()),
                          child: Image.network(
                            bannerObject.image!,
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0.dp())),
                          child: SvgPicture.asset(
                            "ic_ads".withIcon(),
                            width: 44.0.dp(),
                            height: 44.0.dp(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              appProviderRead.isCloseBannerTop2 = true;
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
                      ]),
                    ),
                  ),
                )
              }
            ],
            onPageChanged: (pos) {
              _currentPage = pos;
              _countTimer = 0;
            }));
  }

  List<BannerObject>? _getBannerList() {
    final isCloseBanner =
        context.select((AppProvider provider) => provider.isCloseBannerTop2);
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    if (isCloseBanner || isPremium) return null;
    final top2List =
        context.select((AppProvider provider) => provider.bannerListTop2);
    return top2List;
  }

  _handleSaleBannerClick(BannerObject bannerObject) {
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

    Utils.trackBannerEvent("Banner Top 2: ${bannerObject.name ?? ""}");
    final adsObject = preferenceHelper.adsInHouseObject;
    if (adsObject != null) {
      Utils.trackAdsInHouseEvent(preferenceHelper.idUser,
          adsObject.adGroupId ?? 0, adsObject.adId ?? 0, 2, 1, action!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
