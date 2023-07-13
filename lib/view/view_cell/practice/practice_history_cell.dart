import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/toast.dart';
import 'package:migii_sat/view/view_dialog/history_exam_dialog.dart';
import 'package:migii_sat/view/view_dialog/history_practice_dialog.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/map_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/hive_helper.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/exam/exam_history_result_object.dart';
import '../../../model/exam/exam_json_object.dart';
import '../../../model/exam/exam_list_json_object.dart';
import '../../../model/exam/exam_state_object.dart';
import '../../../model/home/training_section_json_object.dart';
import '../../../model/practice/practice_history_result_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/dio/dio_helper.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../router.dart';
import '../../view_screen/exam/exam_result_screen.dart';
import '../../view_screen/practice/practice_result_screen.dart';

// ignore: must_be_immutable
class PracticeHistoryCell extends BasePage {
  Function(int) clickStartNow;

  PracticeHistoryCell(this.clickStartNow, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeHistoryCell> {
  @override
  void initState() {
    super.initState();
    eventHelper.listen((name) {
      switch (name) {
        case EventHelper.onUpdateHistory:
          setState(() {});
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(
                    20.0.dp(), 12.0.dp(), 20.0.dp(), 4.0.dp()),
                child: Text(
                  appLocalized().history,
                  style: UIFont.fontAppBold(
                      17.0.dp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                )),
            Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.fromLTRB(
                  16.0.dp(), 12.0.dp(), 16.0.dp(), 16.0.dp()),
              color: theme(ColorHelper.colorBackgroundChildDay,
                  ColorHelper.colorBackgroundChildNight),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0.dp())),
              child: _viewHistory(),
            )
          ]),
    );
  }

  var historyTab = 0;

  Widget _viewHistory() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        margin: EdgeInsets.fromLTRB(8.0.dp(), 4.0.dp(), 8.0.dp(), 0),
        width: double.infinity,
        height: 40.0.dp(),
        child: Row(children: [
          SizedBox(width: 12.0.dp()),
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (historyTab != 0) {
                setState(() {
                  historyTab = 0;
                });
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Column(children: [
                Expanded(
                    child: Center(
                  child: AutoSizeText(appLocalized().practice,
                      style: UIFont.fontAppBold(
                          15.0.sp(),
                          historyTab == 0
                              ? theme(ColorHelper.colorTextGreenDay,
                                  ColorHelper.colorTextGreenNight)
                              : theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight))),
                )),
                Container(
                  width: double.infinity,
                  height: 2.0.dp(),
                  decoration: BoxDecoration(
                      color: historyTab == 0
                          ? theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.0.dp())),
                )
              ]),
            ),
          )),
          Container(
            margin:
                EdgeInsets.fromLTRB(12.0.dp(), 8.0.dp(), 12.0.dp(), 8.0.dp()),
            height: double.infinity,
            width: 1.0.dp(),
            color:
                theme(ColorHelper.colorTextDay2, ColorHelper.colorTextNight2),
          ),
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (historyTab != 1) {
                setState(() {
                  historyTab = 1;
                });
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Column(children: [
                Expanded(
                    child: Center(
                  child: AutoSizeText(appLocalized().exam,
                      style: UIFont.fontAppBold(
                          15.0.sp(),
                          historyTab == 1
                              ? theme(ColorHelper.colorTextGreenDay,
                                  ColorHelper.colorTextGreenNight)
                              : theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight))),
                )),
                Container(
                  width: double.infinity,
                  height: 2.0.dp(),
                  decoration: BoxDecoration(
                      color: historyTab == 1
                          ? theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1.0.dp())),
                )
              ]),
            ),
          )),
          SizedBox(width: 12.0.dp()),
        ]),
      ),
      if (historyTab == 0) ...{
        _viewHistoryPractice()
      } else if (historyTab == 1) ...{
        _viewHistoryExam()
      }
    ]);
  }

  Widget _viewHistoryPractice() {
    List<PracticeHistoryResultObject>? historyList =
        HiveHelper.getHistoryPracticeList();
    if (historyList.isNullOrEmpty) return _viewEmpty();

    var isSeeMore = false;
    List<PracticeHistoryResultObject> itemHistoryList = [];
    for (final historyItem in historyList!) {
      if (itemHistoryList.length > 3) {
        isSeeMore = true;
        break;
      }
      itemHistoryList.add(historyItem);
    }

    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 4.0.dp()),
          for (var index = 0; index < itemHistoryList.length; index++) ...{
            _practiceHistoryCell(
                itemHistoryList[index], index == itemHistoryList.length - 1),
          },
          isSeeMore
              ? GestureDetector(
                  onTap: () {
                    HistoryPracticeDialog.show(context);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        20.0.dp(), 4.0.dp(), 20.0.dp(), 20.0.dp()),
                    color: Colors.transparent,
                    child: Text(
                      appLocalized().see_more,
                      style: UIFont.fontAppBold(
                          13.0.sp(),
                          theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight),
                          decoration: TextDecoration.underline),
                    ),
                  ),
                )
              : SizedBox(height: 10.0.dp())
        ],
      ),
    );
  }

  Widget _practiceHistoryCell(
      PracticeHistoryResultObject historyItem, bool isLastItem) {
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
        _handleResultPractice(historyItem, trainingItem);
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.dp(), 10.0.dp(), 0, 10.0.dp()),
            child: SvgPicture.asset(
              (trainingItem?.icon ?? "").withIcon(),
              width: 28.0.dp(),
              height: 28.0.dp(),
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 12.0.dp(), right: 12.0.dp()),
            child: Text(
              name,
              style: UIFont.fontApp(14.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          SizedBox(width: 16.0.dp())
        ]),
        if (!isLastItem)
          Container(
            width: double.infinity,
            height: 0.7.dp(),
            margin: EdgeInsets.only(left: 56.0.dp(), right: 16.0.dp()),
            color: theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
          )
      ]),
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

  Widget _viewHistoryExam() {
    List<ExamHistoryResultObject>? historyList =
        HiveHelper.getHistoryExamList();
    if (historyList.isNullOrEmpty) return _viewEmpty();

    var isSeeMore = false;
    List<ExamHistoryResultObject> itemHistoryList = [];
    for (final historyItem in historyList!) {
      if (itemHistoryList.length > 3) {
        isSeeMore = true;
        break;
      }
      itemHistoryList.add(historyItem);
    }

    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 4.0.dp()),
          for (var index = 0; index < itemHistoryList.length; index++) ...{
            _examHistoryCell(
                itemHistoryList[index], index == itemHistoryList.length - 1),
          },
          isSeeMore
              ? GestureDetector(
                  onTap: () {
                    HistoryExamDialog.show(context, (historyItem) {
                      _handleResultExam(historyItem);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        20.0.dp(), 4.0.dp(), 20.0.dp(), 20.0.dp()),
                    color: Colors.transparent,
                    child: Text(
                      appLocalized().see_more,
                      style: UIFont.fontAppBold(
                          13.0.sp(),
                          theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight),
                          decoration: TextDecoration.underline),
                    ),
                  ),
                )
              : SizedBox(height: 10.0.dp())
        ],
      ),
    );
  }

  Widget _examHistoryCell(
      ExamHistoryResultObject historyItem, bool isLastItem) {
    var examTitle = "";
    final name = historyItem.name?.toLowerCase().replaceAll("test", "").trim();
    if (!name.isNullOrEmpty) {
      final number = int.tryParse(name!) ?? -1;
      if (number > -1) {
        examTitle = appLocalized().test_number.format([number]);
      }
    }

    if (examTitle.isEmpty) examTitle = historyItem.name ?? "";

    int score = historyItem.score ?? 0;

    return GestureDetector(
      onTap: () {
        _handleResultExam(historyItem);
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
              child: Padding(
            padding:
                EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 12.0.dp(), 14.0.dp()),
            child: Text(
              examTitle,
              style: UIFont.fontAppBold(14.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          Text("$score / 1600",
              style: UIFont.fontAppBold(
                  14.0.sp(),
                  score > 1200
                      ? ColorHelper.colorPrimary
                      : (score > 800
                          ? ColorHelper.colorPrimary
                          : ColorHelper.colorRed))),
          SizedBox(width: 16.0.dp())
        ]),
        if (!isLastItem)
          Container(
            width: double.infinity,
            height: 0.7.dp(),
            margin: EdgeInsets.only(left: 16.0.dp(), right: 16.0.dp()),
            color: theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
          )
      ]),
    );
  }

  _handleResultExam(ExamHistoryResultObject historyItem) async {
    final idExam = historyItem.idExam;
    if (idExam == null) {
      Toast(appLocalized().something_wrong).show();
      return;
    }

    ExamListQuestion? examObject = await _getExamObject(idExam);
    if (examObject == null) {
      Toast(isInternetAvailable
              ? appLocalized().something_wrong
              : appLocalized().no_internet)
          .show();
      return;
    }

    ExamJSONObject? examQuestionObject = await _getExamQuestionObject(idExam);
    if (examQuestionObject == null) {
      Toast(isInternetAvailable
              ? appLocalized().something_wrong
              : appLocalized().no_internet)
          .show();
      return;
    }

    Map<int, ExamYourAnswer>? yourAnswerMap = historyItem.yourAnswerMap;
    if (!yourAnswerMap.isNullOrEmpty) {
      final skills = examQuestionObject.skills;
      if (!skills.isNullOrEmpty) {
        for (final skill in skills!) {
          final parts = skill.parts;
          if (parts.isNullOrEmpty) continue;

          for (final part in parts!) {
            final questionList = part.question;
            if (questionList.isNullOrEmpty) continue;

            for (final question in questionList!) {
              if (!yourAnswerMap!.containsKey(question.id)) continue;

              ExamYourAnswer? examYourAnswer = yourAnswerMap[question.id];
              if (examYourAnswer == null) continue;

              final contentList = question.content;
              if (contentList.isNullOrEmpty) continue;

              if (Utils.checkGridIns(question.kindId ?? "")) {
                final yourAnswerGridInsList =
                    examYourAnswer.yourAnswerGridInsList;
                if (yourAnswerGridInsList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerGridInsList!.length) {
                    contentList[i].yourAnswerGridIns = yourAnswerGridInsList[i];
                  }
                }
              } else {
                final yourAnswerList = examYourAnswer.yourAnswerList;
                if (yourAnswerList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerList!.length) {
                    contentList[i].yourAnswer = yourAnswerList[i];
                  }
                }
              }
            }
          }
        }
      }
    }

    if (!mounted) return;
    RouterNavigate.pushScreen(context,
        ExamResultScreen(examObject, examQuestionObject, isHistory: true));
  }

  Future<ExamListQuestion?> _getExamObject(int idExam) async {
    final examList = Provider.of<AppProvider>(context, listen: false).examList;
    if (!examList.isNullOrEmpty) {
      for (final examItem in examList!) {
        if (examItem.id == idExam) return examItem;
      }
    }

    String examListJSON = HiveHelper.getData(GlobalHelper.keyExamList) ?? "";
    if (examListJSON.isNotEmpty) {
      ExamListJSONObject? examListObject;
      try {
        Map object = jsonDecode(examListJSON);
        examListObject = ExamListJSONObject.fromJson(object.cast());
      } on FormatException {
        examListObject = null;
      }

      final exams = examListObject?.exams;
      if (!exams.isNullOrEmpty) {
        for (final examItem in exams!) {
          if (examItem.id == idExam) return examItem;
        }
      }
    }

    appProviderRead.isProcessing = true;
    final examListObject = await dioHelper.getListExams();
    appProviderRead.isProcessing = false;
    if (examListObject == null) return null;

    final exams = examListObject.exams;
    if (!exams.isNullOrEmpty) {
      for (final examItem in exams!) {
        if (examItem.id == idExam) return examItem;
      }
    }
    return null;
  }

  Future<ExamJSONObject?> _getExamQuestionObject(int idExam) async {
    final examObject = HiveHelper.getExam(idExam);
    if (examObject != null) return examObject;

    appProviderRead.isProcessing = true;
    final exam = await dioHelper.getExam(idExam);
    appProviderRead.isProcessing = false;
    return exam;
  }

  Widget _viewEmpty() {
    var textEmpty = "";
    switch (historyTab) {
      case 0:
        textEmpty = appLocalized().any_practice;
        break;
      case 1:
        textEmpty = appLocalized().any_exam;
        break;
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 24.0.dp(), 16.0.dp(), 0),
        child: Text(
          textEmpty,
          style: UIFont.fontApp(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      ),
      GestureDetector(
        onTap: () {
          widget.clickStartNow(historyTab);
        },
        child: Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.only(top: 16.0.dp(), bottom: 20.0.dp()),
          color: ColorHelper.colorPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0.dp())),
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(24.0.dp(), 2.0.dp(), 24.0.dp(), 4.0.dp()),
            child: Text(
              appLocalized().start_now,
              style: UIFont.fontAppBold(14.0.sp(), ColorHelper.colorTextNight),
            ),
          ),
        ),
      )
    ]);
  }
}
