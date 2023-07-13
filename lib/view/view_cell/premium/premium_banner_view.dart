import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../base/base_stateful.dart';

class PremiumBannerView extends BasePage {
  const PremiumBannerView({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PremiumBannerView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  int _countTimer = 0;

  var bannerList = [];

  @override
  void initState() {
    super.initState();
    bannerList.add([
      "img_update_unlock",
      appLocalized().upgrade_review_title_1,
      appLocalized().upgrade_review_content_1
    ]);
    bannerList.add([
      "img_update_exam",
      appLocalized().upgrade_review_title_2,
      appLocalized().upgrade_review_content_2
    ]);
    bannerList.add([
      "img_update_no_ads",
      appLocalized().upgrade_review_title_3,
      appLocalized().upgrade_review_content_3
    ]);
    bannerList.add([
      "img_update_offline",
      appLocalized().upgrade_review_title_4,
      appLocalized().upgrade_review_content_4
    ]);
    bannerList.shuffle();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countTimer++;

      if (_countTimer == 3) {
        _countTimer = 0;

        _currentPage = _currentPage < 2 ? (_currentPage + 1) : 0;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: preferenceHelper.screenWidthMinimum * 3 / 8 + 84.0.dp(),
          child: PageView(
              controller: _pageController,
              children: [
                for (final bannerObject in bannerList) ...{
                  _bannerCell(
                      bannerObject[0], bannerObject[1], bannerObject[2]),
                }
              ],
              onPageChanged: (pos) {
                _currentPage = pos;
                _countTimer = 0;
              })),
      Padding(
          padding: EdgeInsets.only(top: 8.0.dp()),
          child: SmoothPageIndicator(
              controller: _pageController,
              count: bannerList.length,
              effect: ExpandingDotsEffect(
                  expansionFactor: 4,
                  dotWidth: 8.0.dp(),
                  dotHeight: 8.0.dp(),
                  spacing: 6.0.dp(),
                  dotColor: ColorHelper.colorGray,
                  activeDotColor: ColorHelper.colorPrimary)))
    ]);
  }

  Widget _bannerCell(String image, String title, String content) {
    return Card(
      elevation: 4.0.dp(),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0.dp())),
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight),
      margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 8.0.dp()),
      child: Column(children: [
        SizedBox(height: 12.0.dp()),
        Expanded(
          child: Image.asset(image.withImage(),
              fit: BoxFit.contain,
              width: double.infinity,
              height: preferenceHelper.screenWidthMinimum * 3 / 8),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(8.0.dp(), 12.0.dp(), 8.0.dp(), 0),
            child: AutoSizeText(title,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(ColorHelper.colorTextDay,
                        ColorHelper.colorTextGreenNight)),
                maxLines: 1,
                textAlign: TextAlign.center)),
        Padding(
            padding:
                EdgeInsets.fromLTRB(8.0.dp(), 4.0.dp(), 8.0.dp(), 8.0.dp()),
            child: AutoSizeText(content,
                style: UIFont.fontApp(
                    13.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 2,
                textAlign: TextAlign.center))
      ]),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
