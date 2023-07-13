import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';

import '../../../model/user/ads_in_house_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../base/base_stateless.dart';
import '../../view_custom/highlight_text.dart';

class SettingMoreAppCell extends BasePageLess {
  SettingMoreAppCell({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerList =
        context.select((AppProvider provider) => provider.bannerListTop3);
    if (bannerList.isNullOrEmpty) return const SizedBox(height: 0);

    final adsObject = preferenceHelper.adsInHouseObject;
    if (adsObject != null) {
      for (final bannerObject in bannerList!) {
        Utils.trackAdsInHouseEvent(
            preferenceHelper.idUser,
            adsObject.adGroupId ?? 0,
            adsObject.adId ?? 0,
            3,
            0,
            bannerObject.action ?? "");
      }
    }

    final widthItem = Utils.widthScreen(context);

    return SizedBox(
        width: double.infinity,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 22.0.dp()),
              SvgPicture.asset(
                "ic_application".withIcon(),
                width: 20.0.dp(),
                height: 20.0.dp(),
                color: ColorHelper.colorPrimary,
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(20.0.dp(), 14.0.dp(), 20.0.dp(), 0),
                  child: HighlightText(
                    text: "[${appLocalized().ads}] ${appLocalized().other_app}",
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    spanList: [SpanItem(text: "[${appLocalized().ads}]")],
                    spanStyle: UIFont.fontAppBold(
                        13.0.sp(),
                        theme(ColorHelper.colorTextGreenDay,
                            ColorHelper.colorTextGreenNight)),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8.0.dp()),
          SizedBox(
            width: double.infinity,
            height: widthItem / 4 + 42.0.dp(),
            child: ListView.builder(
                key: const PageStorageKey("MoreApplicationCell"),
                padding: EdgeInsets.only(left: 56.0.dp(), right: 14.0.dp()),
                itemCount: bannerList!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _handleSaleBannerClick(bannerList[index]);
                    },
                    child: SizedBox(
                      width: widthItem / 4,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Card(
                          margin: EdgeInsets.fromLTRB(
                              6.0.dp(), 4.0.dp(), 6.0.dp(), 4.0.dp()),
                          elevation: 4.0.dp(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0.dp())),
                          color: theme(ColorHelper.colorBackgroundChildDay,
                              ColorHelper.colorBackgroundChildNight),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0.dp()),
                            child: Image.network(
                              bannerList[index].image!,
                              width: widthItem / 4 - 12.0.dp(),
                              height: widthItem / 4 - 12.0.dp(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              4.0.dp(), 0, 4.0.dp(), 4.0.dp()),
                          child: Text(
                            bannerList[index].title ?? "",
                            style: UIFont.fontApp(
                                12.0.dp(),
                                theme(ColorHelper.colorTextDay,
                                    ColorHelper.colorTextNight)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
                shrinkWrap: true),
          ),
          Container(
            width: double.infinity,
            height: 0.7.dp(),
            margin: EdgeInsets.only(left: 62.0.dp()),
            color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
          )
        ]));
  }

  _handleSaleBannerClick(BannerObject bannerObject) {
    final action = bannerObject.action;
    if (action.isNullOrEmpty || action != "package") return;

    final package = bannerObject.package;
    if (!package.isNullOrEmpty) {
      if (Platform.isIOS && package!.startsWith("id")) {
        StoreRedirect.redirect(iOSAppId: package.replaceFirst("id", ""));
      } else if (Platform.isAndroid) {
        StoreRedirect.redirect(androidAppId: package);
      }
    }

    Utils.trackBannerEvent("Banner Top 3: ${bannerObject.name ?? ""}");
    final adsObject = preferenceHelper.adsInHouseObject;
    if (adsObject != null) {
      Utils.trackAdsInHouseEvent(preferenceHelper.idUser,
          adsObject.adGroupId ?? 0, adsObject.adId ?? 0, 3, 1, action!);
    }
  }
}
