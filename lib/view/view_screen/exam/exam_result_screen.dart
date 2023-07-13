import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:provider/provider.dart';

import '../../../model/exam/exam_history_result_object.dart';
import '../../../model/exam/exam_json_object.dart';
import '../../../model/exam/exam_list_json_object.dart';
import '../../../model/exam/exam_score.dart';
import '../../../model/exam/exam_state_object.dart';
import '../../../model/practice/number_answer_object.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/hive_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../router.dart';
import '../../view_custom/bounce_widget.dart';
import 'exam_answer_screen.dart';

// ignore: must_be_immutable
class ExamResultScreen extends BasePage {
  ExamListQuestion? examObject;
  ExamJSONObject? examQuestionObject;

  bool isHistory;

  ExamResultScreen(this.examObject, this.examQuestionObject,
      {this.isHistory = false, super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamResultScreen> {
  List<ExamNumberAnswerObject>? _answerList;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _answerList = _getAnswerList(widget.examQuestionObject?.skills);

    if (!widget.isHistory && widget.examQuestionObject != null) {
      _addHistory(widget.examQuestionObject!, totalScore);
    }

    Utils.trackerScreen("ExamResultScreen");
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
            child: SizedBox(
                height: preferenceHelper.appBarHeight,
                child: Stack(children: [
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
                  Center(
                    child: Text(
                      appLocalized().exam_result,
                      style: UIFont.fontAppBold(
                          17.0.sp(), ColorHelper.colorTextNight),
                    ),
                  )
                ])),
          ),
          Expanded(child: viewContainer())
        ]),
      ),
    );
  }

  Widget viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.0.dp(), 20.0.dp(), 16.0.dp(), 0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          height: 56.0.dp(),
          decoration: BoxDecoration(
              border: Border.all(
                  color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
                  width: 1.0.dp()),
              color: theme(const Color(0xFFFDF1D1), const Color(0xFFB0A380))),
          child: Row(children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
              child: AutoSizeText(
                appLocalized().question,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 1,
                minFontSize: 8.0.sp(),
                textAlign: TextAlign.center,
              ),
            )),
            Container(
                width: 1.0.dp(),
                height: double.infinity,
                color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
              child: AutoSizeText(
                appLocalized().correct_answer,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 2,
                minFontSize: 8.0.sp(),
                textAlign: TextAlign.center,
              ),
            )),
            Container(
                width: 1.0.dp(),
                height: double.infinity,
                color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
              child: AutoSizeText(
                appLocalized().your_answer,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 2,
                minFontSize: 8.0.sp(),
                textAlign: TextAlign.center,
              ),
            )),
            Container(
                width: 1.0.dp(),
                height: double.infinity,
                color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
              child: AutoSizeText(
                appLocalized().question_result,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 1,
                minFontSize: 8.0.sp(),
                textAlign: TextAlign.center,
              ),
            )),
          ]),
        ),
        Flexible(
            child: ListView.builder(
                key: const PageStorageKey("PracticeAnswerGridInsScreen"),
                padding: EdgeInsets.zero,
                itemCount: _answerList?.length ?? 0,
                itemBuilder: (context, index) {
                  return Builder(builder: (context) {
                    final item = _answerList![index];
                    return _answerViewCell(item);
                  });
                },
                shrinkWrap: true)),
        Container(
          width: double.infinity,
          height: 56.0.dp(),
          margin: EdgeInsets.only(bottom: paddingBottom + 20.0.dp()),
          decoration: BoxDecoration(
              border: Border.all(
                  color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
                  width: 1.0.dp()),
              color: theme(const Color(0xFFE0EAF4), const Color(0xFF8A99A8))),
          child: Row(children: [
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                  child: AutoSizeText(
                    appLocalized().result_score,
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                    textAlign: TextAlign.center,
                  ),
                )),
            Container(
                width: 1.0.dp(),
                height: double.infinity,
                color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
            Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                  child: AutoSizeText(
                    "$totalScore / 1600",
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    maxLines: 2,
                    minFontSize: 8.0.sp(),
                    textAlign: TextAlign.center,
                  ),
                )),
          ]),
        )
      ]),
    );
  }

  Widget _answerViewCell(ExamNumberAnswerObject answerObject) {
    final questionNumber = answerObject.questionNumber ?? 0;
    final questionNumberChild = answerObject.questionNumberChild ?? -1;
    final numberTitle = questionNumberChild > -1
        ? "${questionNumber + 1}.${questionNumberChild + 1}"
        : "${questionNumber + 1}";

    var correctAnswer = "";
    final corrects = answerObject.correctAnswer;
    if (!corrects.isNullOrEmpty) {
      for (final correct in corrects!) {
        if (correctAnswer.isNotEmpty) correctAnswer += "\n";
        correctAnswer += correct;
      }
    }

    var yourAnswer = answerObject.yourAnswer ?? "";
    if (yourAnswer.isEmpty) yourAnswer = "...";

    final isCorrect = answerObject.isCorrect ?? false;

    return GestureDetector(
      onTap: () {
        final questionNumber = answerObject.questionNumber;
        if (questionNumber == null) return;
        final questionNumberChild = answerObject.questionNumberChild;
        if (questionNumberChild == null) return;
        _answerClickListener(questionNumber, questionNumberChild);
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 60.0.dp(),
              child: Row(children: [
                Container(
                    width: 1.0.dp(),
                    height: double.infinity,
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                  child: Text(
                    numberTitle,
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    textAlign: TextAlign.center,
                  ),
                )),
                Container(
                    width: 1.0.dp(),
                    height: double.infinity,
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                  child: Text(
                    correctAnswer,
                    style: UIFont.fontApp(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    textAlign: TextAlign.center,
                  ),
                )),
                Container(
                    width: 1.0.dp(),
                    height: double.infinity,
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                  child: Text(
                    yourAnswer,
                    style: UIFont.fontApp(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    textAlign: TextAlign.center,
                  ),
                )),
                Container(
                    width: 1.0.dp(),
                    height: double.infinity,
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
                Expanded(
                    child: SvgPicture.asset(
                  (yourAnswer == "..."
                          ? "ic_warning_2"
                          : (isCorrect ? "ic_correct" : "ic_wrong"))
                      .withIcon(),
                  color: yourAnswer == "..."
                      ? null
                      : (isCorrect
                          ? const Color(0xFF26A394)
                          : ColorHelper.colorRed),
                  width: 16.0.dp(),
                  height: 16.0.dp(),
                )),
                Container(
                    width: 1.0.dp(),
                    height: double.infinity,
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
              ]),
            ),
            Container(
                width: double.infinity,
                height: 1.0.dp(),
                color: theme(ColorHelper.colorGray, ColorHelper.colorGray2))
          ],
        ),
      ),
    );
  }

  _answerClickListener(int posQuestion, int posQuestionChild) {
    RouterNavigate.pushScreen(
        context,
        ExamAnswerScreen(
          widget.examObject,
          widget.examQuestionObject,
          posQuestionChild == -1
              ? "${posQuestion + 1}"
              : "${posQuestion + 1}.${posQuestionChild + 1}",
        ));
    eventHelper.push(EventHelper.onShowIntervalAds);
  }

  List<ExamNumberAnswerObject>? _getAnswerList(List<ExamSkill>? skills) {
    if (skills.isNullOrEmpty) return null;

    List<ExamNumberAnswerObject> answerObjects = [];
    var writingReadingCorrect = 0;
    var mathCorrect = 0;

    var posQuestion = 0;
    for (final skill in skills!) {
      final parts = skill.parts;
      if (parts.isNullOrEmpty) continue;

      for (final part in parts!) {
        final questions = part.question;
        if (questions.isNullOrEmpty) continue;

        for (var i = 0; i < questions!.length; i++) {
          final contentList = questions[i].content;
          if (contentList.isNullOrEmpty) continue;
          final contentSize = contentList!.length;

          if (Utils.checkGridIns(questions[i].kindId ?? "")) {
            for (var indexContent = 0;
                indexContent < contentList.length;
                indexContent++) {
              final content = contentList[indexContent];
              final yourAnswer = content.yourAnswerGridIns;
              final correctList = content.qCorrect;

              final isCorrect =
                  Utils.checkGridInsCorrect(yourAnswer, correctList ?? []);

              answerObjects.add(ExamNumberAnswerObject(
                  posQuestion,
                  contentSize > 1 ? indexContent : -1,
                  yourAnswer,
                  correctList,
                  isCorrect));

              if (isCorrect) mathCorrect++;
            }
          } else {
            for (var indexContent = 0;
                indexContent < contentList.length;
                indexContent++) {
              final content = contentList[indexContent];
              final yourAnswer = content.yourAnswer;
              final correct = int.tryParse(content.qCorrect?.first ?? "0") ?? 0;

              final isCorrect = yourAnswer > 0 && yourAnswer == correct;

              answerObjects.add(ExamNumberAnswerObject(
                  posQuestion,
                  contentSize > 1 ? indexContent : -1,
                  yourAnswer == 0 ? "" : String.fromCharCode(yourAnswer + 64),
                  [String.fromCharCode(correct + 64)],
                  isCorrect));
              if (isCorrect) {
                if (Utils.checkWritingReading(questions[i].kindId ?? "")) {
                  writingReadingCorrect++;
                } else {
                  mathCorrect++;
                }
              }
            }
          }
          posQuestion++;
        }
      }
    }

    final writingReadingScore =
        ExamScore.scoreWritingReading(writingReadingCorrect);
    final mathScore = ExamScore.scoreMath(mathCorrect);

    totalScore = writingReadingScore + mathScore;
    return answerObjects;
  }

  _addHistory(ExamJSONObject examQuestionObject, int score) {
    final idHistoryNew = _checkIdHistory(HiveHelper.getHistoryExamList());
    int idExam = widget.examObject?.id ?? 0;
    String nameExam = widget.examObject?.name ?? "";

    int time = Provider.of<AppProvider>(context, listen: false).timeServer;

    Map<int, ExamYourAnswer> yourAnswerMap = {};

    final skills = examQuestionObject.skills;
    if (!skills.isNullOrEmpty) {
      for (final skill in skills!) {
        final parts = skill.parts;
        if (parts.isNullOrEmpty) continue;

        for (final part in parts!) {
          final questionList = part.question;
          if (questionList.isNullOrEmpty) continue;

          for (final question in questionList!) {
            final contentList = question.content;
            if (contentList.isNullOrEmpty) continue;

            if (Utils.checkGridIns(question.kindId ?? "")) {
              List<String> yourAnswerGridInsList = [];
              for (final content in contentList!) {
                yourAnswerGridInsList.add(content.yourAnswerGridIns);
              }
              yourAnswerMap[question.id ?? 0] =
                  ExamYourAnswer(yourAnswerGridInsList: yourAnswerGridInsList);
            } else {
              List<int> yourAnswerList = [];
              for (final content in contentList!) {
                yourAnswerList.add(content.yourAnswer);
              }

              yourAnswerMap[question.id ?? 0] =
                  ExamYourAnswer(yourAnswerList: yourAnswerList);
            }
          }
        }
      }
    }

    final examHistoryNew = ExamHistoryResultObject(
        idHistoryNew, idExam, nameExam, score, time, yourAnswerMap);
    HiveHelper.addHistoryExam(examHistoryNew);
    eventHelper.push(EventHelper.onUpdateHistory);
  }

  String _checkIdHistory(List<ExamHistoryResultObject>? historyList) {
    var index = 1;
    var idHistory = "${GlobalHelper.idHistoryExam}$index";
    if (historyList.isNullOrEmpty) return idHistory;

    while (true) {
      var checkExist = false;
      for (final history in historyList!) {
        if (history.idHistory == idHistory) {
          checkExist = true;
          break;
        }
      }
      if (!checkExist) break;
      index += 1;
      idHistory = "${GlobalHelper.idHistoryExam}$index";
    }
    return idHistory;
  }
}
