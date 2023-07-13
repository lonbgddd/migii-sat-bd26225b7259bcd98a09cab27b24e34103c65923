import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/bounce_button.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

// ignore: must_be_immutable
class OnboardingStartView extends BasePage {
  AnimationController animationEnter;
  AnimationController animationExit;
  final Function(int pos) handleNext;

  OnboardingStartView(this.handleNext, this.animationEnter, this.animationExit,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<OnboardingStartView> {
  @override
  Widget build(BuildContext context) {
    widget.animationExit.forward();
    widget.animationEnter.forward();
    return Material(
      child: Container(
        color: const Color(0xFFF6F7F8),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(widget.animationEnter),
          child: FadeTransition(
            opacity: widget.animationExit,
            child: Column(children: [
              SizedBox(height: preferenceHelper.paddingInsetsTop + 16.0.dp()),
              Image.asset(
                "img_onboarding_character".withImage(),
                width: preferenceHelper.screenWidthMinimum * 0.8,
                fit: BoxFit.cover,
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(20.0.dp(), 16.0.dp(), 20.0.dp(), 0),
                child: Text(
                  appLocalized().title_onboarding_1,
                  style:
                      UIFont.fontAppBold(17.0.sp(), ColorHelper.colorTextDay),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(20.0.dp(), 12.0.dp(), 20.0.dp(), 0),
                child: Text(
                  appLocalized().des_onboarding_1,
                  style: UIFont.fontApp(15.0.sp(), ColorHelper.colorTextDay),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(child: SizedBox()),
              FractionallySizedBox(
                widthFactor: 0.66,
                child: BounceButton(
                  color: ColorHelper.colorPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0.dp())),
                  child: Container(
                    height: 44.0.dp(),
                    alignment: Alignment.center,
                    child: Text(appLocalized().start_now,
                        style: UIFont.fontAppBold(
                            15.0.sp(), ColorHelper.colorTextNight)),
                  ),
                  onPress: () {
                    handleNext(() {
                      widget.handleNext(2);
                    });
                  },
                ),
              ),
              SizedBox(height: preferenceHelper.paddingInsetsBottom + 24.0.dp())
            ]),
          ),
        ),
      ),
    );
  }

  Future handleNext(Function completion) async {
    await widget.animationExit.reverse();
    await widget.animationEnter.reverse();
    completion();
  }
}
