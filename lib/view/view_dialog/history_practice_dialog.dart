import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../model/home/training_section_json_object.dart';
import '../../model/practice/practice_history_result_object.dart';
import '../../model/practice/practice_json_object.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/global_helper.dart';
import '../../viewmodel/helper/hive_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../base/base_stateful.dart';
import '../router.dart';
import '../view_screen/practice/practice_result_screen.dart';

class HistoryPracticeDialog extends BasePage {
  const HistoryPracticeDialog({super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "HistoryPracticeDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.bottomCenter,
              child: HistoryPracticeDialog());
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 0.5), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<HistoryPracticeDialog> {
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        color: theme(
            ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.0.dp()),
                topRight: Radius.circular(22.0.dp()))),
        child: viewContainer());
  }

  Widget viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    int timeServer =
        Provider.of<AppProvider>(context, listen: false).timeServer;

    List<PracticeHistoryResultObject>? historyList =
        HiveHelper.getHistoryPracticeList();

    return SizedBox(
      width: double.infinity,
      height: Utils.heightScreen(context) * 3 / 4,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.zero,
          color: ColorHelper.colorPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.0.dp()),
                  topRight: Radius.circular(22.0.dp()))),
          child: SizedBox(
            width: double.infinity,
            height: preferenceHelper.appBarHeight,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    appLocalized().history_practice,
                    style: UIFont.fontAppBold(
                        17.0.sp(), ColorHelper.colorTextNight),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: double.infinity,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              "ic_close_2".withIcon(),
                              width: 22.0.dp(),
                              height: 22.0.dp(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              key: const PageStorageKey("HistoryPracticeDialog"),
              padding: EdgeInsets.only(
                  top: 6.0.dp(), bottom: paddingBottom + 20.0.dp()),
              itemCount: historyList?.length ?? 0,
              itemBuilder: (context, index) {
                return _historyItemView(historyList![index], timeServer);
              },
              shrinkWrap: true),
        )
      ]),
    );
  }

  Widget _historyItemView(
      PracticeHistoryResultObject historyItem, int timeServer) {
    final trainingItem =
        Utils.getTrainingItem(historyItem.idKindList?.firstOrNull ?? "");

    var name = trainingItem?.name ?? "";
    if (name.contains(":")) {
      name = name.substring(name.indexOf(":") + 1).trim();
    }
    int percent = (historyItem.total ?? 0) > 0
        ? ((historyItem.correct ?? 0) * 100 / historyItem.total!).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _handleResultPractice(historyItem, trainingItem);
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 6.0.dp()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp())),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0.dp(), right: 16.0.dp()),
                child: Text(
                  Utils.convertTimeHistory(historyItem.time ?? 0, timeServer),
                  style: UIFont.fontApp(
                      12.0.sp(),
                      theme(ColorHelper.colorTextDay2,
                          ColorHelper.colorTextNight2)),
                ),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 16.0.dp()),
                SvgPicture.asset(
                  (trainingItem?.icon ?? "").withIcon(),
                  width: 36.0.dp(),
                  height: 36.0.dp(),
                ),
                SizedBox(width: 12.0.dp()),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      SizedBox(height: 4.0.dp()),
                      Text(
                        name,
                        style: UIFont.fontAppBold(
                            15.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)),
                      ),
                      SizedBox(height: 6.0.dp()),
                      Row(children: [
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(left: 2.0.dp()),
                          child: Text(
                            "${appLocalized().number_questions}: ${historyItem.total}",
                            style: UIFont.fontApp(
                                14.0.sp(),
                                theme(ColorHelper.colorTextDay,
                                    ColorHelper.colorTextNight)),
                          ),
                        )),
                        Text("$percent%",
                            style: UIFont.fontAppBold(
                                14.0.sp(),
                                percent < 40
                                    ? ColorHelper.colorRed_2
                                    : (percent >= 80
                                        ? ColorHelper.colorGreen
                                        : ColorHelper.colorYellow_2))),
                        SizedBox(width: 2.0.dp())
                      ]),
                      Container(
                        height: 8.0.dp(),
                        margin:
                            EdgeInsets.only(top: 6.0.dp(), bottom: 14.0.dp()),
                        decoration: BoxDecoration(
                            color: theme(ColorHelper.colorTextGreenDay,
                                    ColorHelper.colorTextGreenNight)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.0.dp())),
                        padding: EdgeInsets.all(2.0.dp()),
                        child: LinearPercentIndicator(
                          percent: percent / 100,
                          lineHeight: 4.0.dp(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          progressColor: percent < 40
                              ? ColorHelper.colorRed_2
                              : (percent >= 80
                                  ? ColorHelper.colorGreen
                                  : ColorHelper.colorYellow_2),
                          barRadius: Radius.circular(2.0.dp()),
                        ),
                      )
                    ])),
                SizedBox(width: 16.0.dp())
              ])
            ]),
      ),
    );
  }

  _handleResultPractice(PracticeHistoryResultObject historyItem,
      TrainingSectionTheme? themeItem) {
    var questionFormat = historyItem.questionFormat ?? 0;
    List<PracticeQuestion> questions = [];

    List<PracticeHistoryItem>? practiceList = historyItem.practiceList;
    if (!practiceList.isNullOrEmpty) {
      for (final practiceItem in practiceList!) {
        final id = practiceItem.id;
        if (id == null) continue;

        final jsonData = HiveHelper.getData("${GlobalHelper.idQuestion}$id");
        PracticeQuestion? practiceQuestion;

        try {
          Map object = jsonDecode(jsonData);
          practiceQuestion = PracticeQuestion.fromJson(object.cast());
        } on FormatException {
          practiceQuestion = null;
        }

        if (practiceQuestion == null) continue;

        List<int> yourAnswerList = practiceItem.yourAnswerList ?? [];
        List<String> yourAnswerGridInsList =
            practiceItem.yourAnswerGridInsList ?? [];

        final contentList = practiceQuestion.content;
        if (!contentList.isNullOrEmpty) {
          if (questionFormat == 1) {
            for (var i = 0; i < contentList!.length; i++) {
              if (i < yourAnswerGridInsList.length) {
                contentList[i].yourAnswerGridIns = yourAnswerGridInsList[i];
              }
            }
          } else {
            for (var i = 0; i < contentList!.length; i++) {
              if (i < yourAnswerList.length) {
                contentList[i].yourAnswer = yourAnswerList[i];
              }
            }
          }
        }
        questions.add(practiceQuestion);
      }
    }

    final practiceObject =
        PracticeJSONObject(questions, preferenceHelper.urlDomain);

    RouterNavigate.pushScreen(
        context,
        PracticeResultScreen(practiceObject, themeItem, questionFormat,
            isHistory: true));
  }
}
