import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../base/base_stateful.dart';
import '../../view_custom/bounce_button.dart';

// ignore: must_be_immutable
class OnBoardingLanguageView extends BasePage {
  AnimationController animationExit;

  final languageObjectList = [
    LanguageObject("Tiếng Việt", "vi", "ic_flag_vietnam_round",
        "Chọn ngôn ngữ của bạn", "Tiếp tục"),
    LanguageObject("English", "en", "ic_flag_english_round",
        "Choose your language", "Next"),
    LanguageObject(
        "Español", "es", "ic_flag_spain_round", "Elige tu idioma", "Continúa"),
    LanguageObject("한국어", "ko", "ic_flag_korea_round", "당신의 언어를 고르시 오", "다음"),
    LanguageObject("简体中文", "cn", "ic_flag_china_round", "选择你的语言", "继续"),
    LanguageObject("繁體中文", "tw", "ic_flag_taiwan_round", "選擇你的語言", "繼續")
  ];

  final Function() handleChangeLanguage;

  OnBoardingLanguageView(this.handleChangeLanguage, this.animationExit,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<OnBoardingLanguageView> {
  final originLanguage = preferenceHelper.languageApp;
  late List<LanguageObject> languageList;

  late String currentLanguage;
  late LanguageObject? languageObject;

  @override
  void initState() {
    super.initState();
    languageList = getLanguageList();
    currentLanguage = preferenceHelper.languageApp;
  }

  LanguageObject? getLanguageObject(String language) {
    for (var languageObject in widget.languageObjectList) {
      if (languageObject.languageCode == language) {
        return languageObject;
      }
    }
    return null;
  }

  List<LanguageObject> getLanguageList() {
    List<LanguageObject> languageList = [];
    widget.languageObjectList.shuffle();
    for (var languageObject in widget.languageObjectList) {
      var languageCode = languageObject.languageCode;
      if (languageCode == originLanguage) {
        languageList.insert(0, languageObject);
      } else {
        languageList.add(languageObject);
      }
    }
    return languageList;
  }

  @override
  Widget build(BuildContext context) {
    languageObject = getLanguageObject(currentLanguage);
    widget.animationExit.forward();
    return Material(
        child: Container(
            color: ColorHelper.colorBackgroundChildDay,
            child: FadeTransition(
              opacity: widget.animationExit,
              child: Column(children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        20.0.dp(),
                        preferenceHelper.paddingInsetsTop + 24.0.dp(),
                        20.0.dp(),
                        12.0.dp()),
                    child: Text(
                      languageObject?.title ?? "",
                      style: UIFont.fontAppBold(
                          18.0.sp(), ColorHelper.colorTextDay),
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: languageList.length,
                        itemBuilder: (context, index) {
                          return languageCell(languageList[index]);
                        })),
                FractionallySizedBox(
                  widthFactor: 0.66,
                  child: Container(
                    height: 44.0.dp(),
                    margin: EdgeInsets.only(
                        bottom:
                            preferenceHelper.paddingInsetsBottom + 20.0.dp(),
                        top: 24.0.dp()),
                    child: BounceButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0.dp())),
                      color: ColorHelper.colorPrimary,
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.only(bottom: 2.0.dp()),
                              child: Text(languageObject?.button ?? "",
                                  style: UIFont.fontAppBold(
                                      17.0.sp(), ColorHelper.colorTextNight)))),
                      onPress: () {
                        handleNext(() {
                          if (currentLanguage != originLanguage) {
                            preferenceHelper.languageApp = currentLanguage;
                          }
                          widget.handleChangeLanguage();
                        });
                      },
                    ),
                  ),
                )
              ]),
            )));
  }

  Future handleNext(Function completion) async {
    await widget.animationExit.reverse();
    completion();
  }

  Widget languageCell(LanguageObject languageObject) {
    var isSelected = languageObject.languageCode == currentLanguage;

    return GestureDetector(
        onTap: () {
          setState(() {
            currentLanguage = languageObject.languageCode ?? "";
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      20.0.dp(), 16.0.dp(), 20.0.dp(), 16.0.dp()),
                  child: SvgPicture.asset(languageObject.icon!.withIcon(),
                      width: 32.0.dp(), height: 32.0.dp())),
              Expanded(
                  child: Text(languageObject.name ?? "",
                      style: isSelected
                          ? UIFont.fontAppBold(
                              18.0.sp(), ColorHelper.colorTextGreenDay)
                          : UIFont.fontApp(
                              18.0.sp(), ColorHelper.colorTextDay))),
              Container(
                  width: 20.0.dp(),
                  height: 20.0.dp(),
                  margin: EdgeInsets.only(left: 16.0.dp(), right: 20.0.dp()),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0.dp()),
                      border: Border.all(
                          width: 2.0.dp(),
                          color: isSelected
                              ? ColorHelper.colorTextGreenDay
                              : ColorHelper.colorTextDay2)),
                  child: Stack(children: [
                    if (isSelected)
                      Center(
                        child: Container(
                          width: 10.0.dp(),
                          height: 10.0.dp(),
                          decoration: const BoxDecoration(
                              color: ColorHelper.colorTextGreenDay,
                              shape: BoxShape.circle),
                        ),
                      )
                  ]))
            ]),
            Container(
                width: double.infinity,
                height: 1.0.dp(),
                color: ColorHelper.colorTextDay2,
                margin: EdgeInsets.only(left: 72.0.dp(), right: 20.0.dp()))
          ]),
        ));
  }
}

class LanguageObject {
  String? name;
  String? languageCode;
  String? icon;
  String? title;
  String? button;

  LanguageObject(
      this.name, this.languageCode, this.icon, this.title, this.button);
}
