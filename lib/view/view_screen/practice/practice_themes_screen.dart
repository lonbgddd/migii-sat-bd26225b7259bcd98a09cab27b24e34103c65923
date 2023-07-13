import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/main.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_dialog/connect_internet_dialog.dart';
import 'package:migii_sat/view/view_screen/practice/practice_prepare_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../model/home/training_section_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/bounce_widget.dart';

// ignore: must_be_immutable
class PracticeThemesScreen extends BasePage {
  TrainingSectionKind kindItem;

  PracticeThemesScreen(this.kindItem, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeThemesScreen> {
  var totalSubQues = 0;
  var totalDid = 0;
  var totalCorrect = 0;

  @override
  void initState() {
    super.initState();

    final themeList = widget.kindItem.themes;
    if (!themeList.isNullOrEmpty) {
      for (final themeItem in themeList!) {
        List<String>? idKindList = themeItem.idKindList;
        if (!idKindList.isNullOrEmpty) {
          totalSubQues += preferenceHelper.getTotalSubQuestion(idKindList!);
          for (final idKind in idKindList) {
            if (idKind.contains("_")) {
              totalDid +=
                  preferenceHelper.getIdQuestionsDid("${idKind}_0").length +
                      preferenceHelper.getIdQuestionsDid("${idKind}_1").length;
              totalCorrect += preferenceHelper
                      .getIdQuestionsCorrect("${idKind}_0")
                      .length +
                  preferenceHelper.getIdQuestionsCorrect("${idKind}_1").length;
            } else {
              totalDid += preferenceHelper.getIdQuestionsDid(idKind).length;
              totalCorrect +=
                  preferenceHelper.getIdQuestionsCorrect(idKind).length;
            }
          }
        }
      }
    }

    Utils.trackerScreen("PracticeThemesScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme(
            ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            decoration: BoxDecoration(
                color: ColorHelper.colorPrimary,
                boxShadow: kElevationToShadow[3]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: preferenceHelper.appBarHeight,
                    child: Row(children: [
                      BounceWidget(
                          child: Container(
                            width: preferenceHelper.appBarHeight,
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "ic_back".withIcon(),
                              width: 20.0.dp(),
                              height: 20.0.dp(),
                              color: Colors.white,
                            ),
                          ),
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      Expanded(
                          child: Text(
                        widget.kindItem.name ?? "",
                        style: UIFont.fontAppBold(
                            17.0.sp(), ColorHelper.colorTextNight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      SizedBox(width: 12.0.dp())
                    ])),
                _viewTotal()
              ],
            ),
          ),
          Expanded(child: _viewContainer())
        ]),
      ),
    );
  }

  Widget _viewTotal() {
    return Container(
      width: double.infinity,
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight),
      padding: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 12.0.dp()),
      child: Row(children: [
        SvgPicture.asset(
          (widget.kindItem.icon ?? "").withIcon(),
          width: 100.0.dp(),
          height: 100.0.dp(),
          fit: BoxFit.contain,
        ),
        SizedBox(width: 12.0.dp()),
        Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              Text(
                appLocalized().question_answered,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
              SizedBox(width: 12.0.dp()),
              Text(
                "$totalDid",
                style: UIFont.fontApp(
                    16.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              )
            ],
          ),
          SizedBox(height: 4.0.dp()),
          Row(
            children: [
              Text(
                appLocalized().question_correct,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
              SizedBox(width: 12.0.dp()),
              Text(
                "$totalCorrect",
                style: UIFont.fontApp(
                    16.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              )
            ],
          ),
          SizedBox(height: 4.0.dp()),
          Row(
            children: [
              Text(
                appLocalized().question_complete,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(12.0.dp(), 6.0.dp(), 8.0.dp(), 0),
                child: LinearPercentIndicator(
                  percent: totalSubQues == 0 ? 0 : (totalDid / totalSubQues),
                  lineHeight: 8.0.dp(),
                  padding: EdgeInsets.zero,
                  backgroundColor: ColorHelper.colorPrimary.withOpacity(0.39),
                  progressColor: ColorHelper.colorPrimary,
                  barRadius: Radius.circular(4.0.dp()),
                ),
              ))
            ],
          ),
        ]))
      ]),
    );
  }

  Widget _viewContainer() {
    final themesList = widget.kindItem.themes;

    return Stack(children: [
      Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            "img_background_practice".withImage(),
            width: double.infinity,
            fit: BoxFit.contain,
          )),
      SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0.dp(), bottom: 24.0.dp()),
              itemCount: themesList?.length ?? 0,
              itemBuilder: (context, index) {
                return Builder(builder: (context) {
                  return _themeItemView(themesList![index]);
                });
              },
              shrinkWrap: true))
    ]);
  }

  Widget _themeItemView(TrainingSectionTheme themeItem) {
    var totalSubQues = 0;
    var totalDid = 0;
    var totalCorrect = 0;

    List<String>? idKindList = themeItem.idKindList;
    if (!idKindList.isNullOrEmpty) {
      totalSubQues = preferenceHelper.getTotalSubQuestion(idKindList!);
      for (final idKind in idKindList) {
        if (idKind.contains("_")) {
          totalDid += preferenceHelper.getIdQuestionsDid("${idKind}_0").length +
              preferenceHelper.getIdQuestionsDid("${idKind}_1").length;
          totalCorrect +=
              preferenceHelper.getIdQuestionsCorrect("${idKind}_0").length +
                  preferenceHelper.getIdQuestionsCorrect("${idKind}_1").length;
        } else {
          totalDid += preferenceHelper.getIdQuestionsDid(idKind).length;
          totalCorrect += preferenceHelper.getIdQuestionsCorrect(idKind).length;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        if (isInternetAvailable) {
          RouterNavigate.pushReplacementScreen(
              context, PracticePrepareScreen(themeItem));
        } else {
          ConnectInternetDialog.show(context);
        }
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 6.0.dp()),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp())),
        child: Row(children: [
          SizedBox(width: 16.0.dp()),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 18.0.dp()),
              Text(
                themeItem.name ?? "",
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
              SizedBox(height: 10.0.dp()),
              Row(children: [
                Text(
                  appLocalized().complete,
                  style: UIFont.fontApp(
                      13.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                ),
                Expanded(
                    child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(12.0.dp(), 4.0.dp(), 20.0.dp(), 0),
                  child: LinearPercentIndicator(
                    percent: totalSubQues == 0 ? 0 : (totalDid / totalSubQues),
                    lineHeight: 6.0.dp(),
                    padding: EdgeInsets.zero,
                    backgroundColor: ColorHelper.colorPrimary.withOpacity(0.39),
                    progressColor: ColorHelper.colorPrimary,
                    barRadius: Radius.circular(3.0.dp()),
                  ),
                )),
                Text(
                  appLocalized()
                      .percent_correct
                      .format([totalCorrect, totalDid]),
                  style: UIFont.fontApp(
                      13.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                )
              ]),
              SizedBox(height: 20.0.dp())
            ],
          )),
          SizedBox(width: 20.0.dp()),
          SvgPicture.asset(
            "ic_arrow_right".withIcon(),
            width: 14.0.dp(),
            height: 14.0.dp(),
            color: theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
          ),
          SizedBox(width: 16.0.dp())
        ]),
      ),
    );
  }
}
