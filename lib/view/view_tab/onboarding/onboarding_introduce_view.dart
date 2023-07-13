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
import '../../view_custom/bounce_button.dart';

// ignore: must_be_immutable
class OnBoardingIntroduceView extends BasePage {
  AnimationController animationEnter;
  AnimationController animationExit;
  final Function(int pos) handleNext;

  OnBoardingIntroduceView(
      this.handleNext, this.animationEnter, this.animationExit,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<OnBoardingIntroduceView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  int _countTimer = 0;

  var bannerList = [];

  @override
  void initState() {
    super.initState();

    bannerList = [
      ["img_introduce_1", appLocalized().onboard_intro_1, 0.7],
      ["img_introduce_2", appLocalized().onboard_intro_2, 0.75],
      ["img_introduce_3", appLocalized().onboard_intro_3, 0.85]
    ];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (bannerList.length < 2) return;
      _countTimer++;

      if (_countTimer == 3) {
        _countTimer = 0;

        _currentPage =
        _currentPage < (bannerList.length - 1) ? (_currentPage + 1) : 0;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.animationExit.forward();
    widget.animationEnter.forward();
    return Material(
        child: Container(
            color: ColorHelper.colorBackgroundChildDay,
            child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(widget.animationEnter),
                child: FadeTransition(
                    opacity: widget.animationExit,
                    child: SafeArea(
                        child: Column(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            16.0.dp(), 20.0.dp(), 16.0.dp(), 24.0.dp()),
                        child: Text(
                          appLocalized().login_to_practice,
                          style: UIFont.fontAppBold(
                              17.0.sp(), ColorHelper.colorTextDay),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                          child: PageView(
                              controller: _pageController,
                              children: [
                                for (final bannerObject in bannerList) ...[
                                  _bannerCell(bannerObject[0], bannerObject[1],
                                      bannerObject[2])
                                ],
                              ],
                              onPageChanged: (pos) {
                                _currentPage = pos;
                                _countTimer = 0;
                              })),
                      SizedBox(height: 20.0.dp()),
                      SmoothPageIndicator(
                          controller: _pageController,
                          count: bannerList.length,
                          effect: ExpandingDotsEffect(
                              expansionFactor: 4,
                              dotWidth: 8.0.dp(),
                              dotHeight: 8.0.dp(),
                              spacing: 6.0.dp(),
                              dotColor: ColorHelper.colorGray,
                              activeDotColor: ColorHelper.colorPrimary)),
                      SizedBox(height: 24.0.dp()),
                      FractionallySizedBox(
                          widthFactor: 0.75,
                          child: SizedBox(
                            height: 44.0.dp(),
                            child: BounceButton(
                              color: ColorHelper.colorPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(22.0.dp())),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                                  child: AutoSizeText(
                                      "${appLocalized().register} / ${appLocalized().log_in}",
                                      style: UIFont.fontAppBold(15.0.sp(),
                                          ColorHelper.colorTextNight),
                                      maxLines: 1,
                                      textAlign: TextAlign.center),
                                ),
                              ),
                              onPress: () {
                                handleNext(() {
                                  widget.handleNext(4);
                                });
                              },
                            ),
                          )),
                      SizedBox(height: 8.0.dp()),
                      FractionallySizedBox(
                        widthFactor: 0.75,
                        child: SizedBox(
                          height: 44.0.dp(),
                          child: GestureDetector(
                              onTap: () {
                                widget.handleNext(-1);
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                                  child: Text(appLocalized().skip,
                                      style: UIFont.fontAppBold(
                                          15.0.sp(), ColorHelper.colorTextDay,
                                          decoration:
                                              TextDecoration.underline)),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(height: 16.0.dp())
                    ]))))));
  }

  Column _bannerCell(String image, String title, double scale) {
    return Column(children: [
      Expanded(
          child: Image.asset(image.withImage(),
              width: preferenceHelper.screenWidthMinimum * scale,
              fit: BoxFit.contain)),
      Padding(
          padding:
              EdgeInsets.fromLTRB(16.0.dp(), 20.0.dp(), 16.0.dp(), 8.0.dp()),
          child: Text(
            title,
            style: UIFont.fontApp(16.0.sp(), ColorHelper.colorTextDay),
            textAlign: TextAlign.center,
          ))
    ]);
  }

  Future handleNext(Function completion) async {
    await widget.animationExit.reverse();
    await widget.animationEnter.reverse();
    completion();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
