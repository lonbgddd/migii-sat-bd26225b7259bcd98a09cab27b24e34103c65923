import 'package:flutter/material.dart';
import 'package:migii_sat/view/view_tab/onboarding/onboarding_start_view.dart';

import '../../viewmodel/helper/preference_helper.dart';
import '../base/base_stateful.dart';
import '../router.dart';
import '../view_tab/onboarding/onboarding_introduce_view.dart';
import '../view_tab/onboarding/onboarding_language_view.dart';
import '../view_tab/onboarding/onboarding_login_view.dart';
import '../view_tab/onboarding/onboarding_register_view.dart';
import '../view_tab/onboarding/onboarding_reminder_setup_view.dart';
import 'home_screen.dart';

class OnBoardingScreen extends BasePage {
  const OnBoardingScreen({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<OnBoardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationEnter;
  late AnimationController _animationExit;
  late int indexView;

  @override
  void initState() {
    _animationEnter = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        reverseDuration: Duration.zero);
    _animationExit = AnimationController(
        vsync: this,
        duration: Duration.zero,
        reverseDuration: const Duration(milliseconds: 150));

    super.initState();
    indexView = preferenceHelper.isChooseLanguageFirst ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    switch (indexView) {
      case 0:
        return OnBoardingLanguageView(() {
          preferenceHelper.isChooseLanguageFirst = true;
          _handleNext(1);
        }, _animationExit);
      case 1:
        return OnboardingStartView(
            _handleNext, _animationEnter, _animationExit);
      case 2:
        return OnBoardingReminderSetupView(
            _handleNext, _animationEnter, _animationExit);
      case 3:
        return OnBoardingIntroduceView(
            _handleNext, _animationEnter, _animationExit);
      case 4:
        return OnBoardingRegisterView(
            _handleNext, _animationEnter, _animationExit);
      case 5:
        return OnBoardingLoginView(
            _handleNext, _animationEnter, _animationExit);
    }
    return const Text("other");
  }

  void _handleNext(int pos) {
    if (pos == -1) {
      preferenceHelper.didOpenOnBoarding = true;
      RouterNavigate.pushReplacementScreen(context, const HomeScreen());
      return;
    }
    setState(() {
      indexView = pos;
    });
  }

  @override
  void dispose() {
    _animationEnter.dispose();
    _animationExit.dispose();
    super.dispose();
  }
}
