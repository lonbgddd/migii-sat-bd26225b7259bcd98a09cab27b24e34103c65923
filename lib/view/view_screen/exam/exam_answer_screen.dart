import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/exam/exam_cell_object.dart';
import '../../../model/exam/exam_json_object.dart';
import '../../../model/exam/exam_list_json_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/dio/dio_helper.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/bounce_widget.dart';
import '../../view_custom/toast.dart';
import '../../view_dialog/font_size_dialog.dart';
import '../../view_dialog/report_question_dialog.dart';
import '../../view_dialog/type_choice_answer_dialog.dart';
import '../../view_tab/exam/exam_question_answer_item.dart';
import '../../view_tab/exam/exam_question_gridins_answer_item.dart';

// ignore: must_be_immutable
class ExamAnswerScreen extends BasePage {
  ExamListQuestion? examObject;
  ExamJSONObject? examQuestionObject;

  String? numberSentence;

  ExamAnswerScreen(
      this.examObject, this.examQuestionObject, this.numberSentence,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamAnswerScreen>
    with WidgetsBindingObserver {
  List<ExamCellObject>? questionsList;
  var questionSize = 0;

  var currentPart = 0;
  var currentQuestion = 0;
  var isShowSetting = false;
  var hasExplain = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    questionsList = _getQuestionList(widget.examQuestionObject);
    questionSize = questionsList?.length ?? 0;

    if (questionSize > 0) {
      hasExplain = _checkHasExplain(questionsList![0].question);
    }

    _pageController.addListener(() {
      final progress = _pageController.page!;
      progressIndicator.value = progress;
    });

    if (!widget.numberSentence.isNullOrEmpty) {
      int numberQuestion = 0;

      if (widget.numberSentence!.contains(".")) {
        final sentCurrent = widget.numberSentence!.split(".");
        if (sentCurrent.length == 2) {
          numberQuestion = int.tryParse(sentCurrent[0].trim()) ?? 1;
        } else {
          numberQuestion = 1;
        }
      } else {
        numberQuestion = int.tryParse(widget.numberSentence!) ?? 1;
      }
      if (numberQuestion > 1) {
        Future.delayed(Duration.zero, () async {
          _pageController.jumpToPage(numberQuestion - 1);
        });
      }
    }

    Utils.trackerScreen("ExamScreen");
  }

  @override
  Widget build(BuildContext context) {
    final fontSize =
        context.select((AppProvider provider) => provider.fontSize);
    final isChoiceAnswerBottom =
        context.select((AppProvider provider) => provider.isChoiceAnswerBottom);

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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Part ${currentPart + 1}",
                            style: UIFont.fontAppBold(
                                16.0.sp(), ColorHelper.colorTextNight),
                          ),
                          Text(
                            "${currentQuestion + 1}/$questionSize",
                            style: UIFont.fontApp(
                                14.0.sp(), ColorHelper.colorTextNight),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          eventHelper.push(EventHelper.onHideExplain);
                          if (isShowSetting) {
                            setState(() {
                              isShowSetting = false;
                            });
                          }
                          ReportQuestionDialog.show(context, (reportContent) {
                            if (reportContent.isEmpty) return;
                            if (currentQuestion >=
                                (questionsList?.length ?? 0)) {
                              Toast(appLocalized().something_wrong).show();
                              return;
                            }
                            final idQuestion =
                                questionsList![currentQuestion].question?.id ??
                                    0;
                            if (idQuestion == 0) {
                              Toast(appLocalized().something_wrong).show();
                              return;
                            }
                            _sendReport(reportContent, "$idQuestion");
                          });
                        },
                        child: Container(
                          width: preferenceHelper.widthScreen / 9,
                          height: double.infinity,
                          color: Colors.transparent,
                          margin: EdgeInsets.only(left: 10.0.dp()),
                          child: Stack(alignment: Alignment.center, children: [
                            SvgPicture.asset(
                              "ic_report".withIcon(),
                              width: 18.0.dp(),
                              height: 18.0.dp(),
                              color: ColorHelper.colorTextNight,
                            )
                          ]),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            isShowSetting = !isShowSetting;
                          });
                          eventHelper.push(EventHelper.onHideExplain);
                        },
                        child: Container(
                          width: preferenceHelper.widthScreen / 9,
                          height: double.infinity,
                          color: Colors.transparent,
                          child: Stack(alignment: Alignment.center, children: [
                            SvgPicture.asset(
                              "ic_setttings_unselect".withIcon(),
                              width: 18.0.dp(),
                              height: 18.0.dp(),
                              color: ColorHelper.colorTextNight,
                            )
                          ]),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      if (hasExplain)
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (isShowSetting) {
                              setState(() {
                                isShowSetting = false;
                              });
                            }
                            eventHelper.push(EventHelper.onShowExplain);
                          },
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                            padding:
                                EdgeInsets.fromLTRB(16.0.dp(), 0, 16.0.dp(), 0),
                            alignment: Alignment.center,
                            child: Text(
                              appLocalized().explain,
                              style: UIFont.fontAppBold(
                                  14.0.dp(), ColorHelper.colorTextNight,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        )
                    ])),
                ValueListenableBuilder(
                    valueListenable: progressIndicator,
                    builder: (context, value, child) {
                      return LinearPercentIndicator(
                        percent:
                            questionSize == 0 ? 0 : (value + 1) / questionSize,
                        lineHeight: 6.0.dp(),
                        padding: EdgeInsets.zero,
                        backgroundColor: ColorHelper.colorBackgroundChildNight
                            .withOpacity(0.19),
                        progressColor: theme(ColorHelper.colorTextGreenDay,
                            ColorHelper.colorAccent),
                      );
                    })
              ],
            ),
          ),
          Expanded(
              child: Stack(children: [
            _viewContainer(),
            if (isShowSetting)
              GestureDetector(
                onTap: () {
                  if (!isShowSetting) return;
                  setState(() {
                    isShowSetting = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            _viewSettings(fontSize, isChoiceAnswerBottom)
          ]))
        ]),
      ),
    );
  }

  final PageController _pageController = PageController();
  ValueNotifier<double> progressIndicator = ValueNotifier(0.0);

  Widget _viewContainer() {
    if (questionsList.isNullOrEmpty) return const SizedBox();

    return PageView(
      controller: _pageController,
      onPageChanged: (pos) {
        if (currentQuestion == pos) return;
        setState(() {
          currentPart = questionsList![pos].partNumber ?? 0;
          currentQuestion = pos;
          hasExplain =
              _checkHasExplain(questionsList![currentQuestion].question);
        });
        FocusManager.instance.primaryFocus?.unfocus();
      },
      children: [
        for (var indexPage = 0;
            indexPage < questionsList!.length;
            indexPage++) ...[
          Utils.checkGridIns(questionsList![indexPage].question?.kindId ?? "")
              ? ExamQuestionGridInsAnswerItem(
                  indexPage, questionsList![indexPage], currentQuestion)
              : ExamQuestionAnswerItem(
                  indexPage, questionsList![indexPage], currentQuestion)
        ],
      ],
    );
  }

  Widget _viewSettings(int fontSize, bool isChoiceAnswerBottom) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isShowSetting ? 116.0.dp() : 0,
        color: const Color(0xFF3EA394),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 4.0.dp()),
              Row(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16.0.dp(), 18.0.dp(), 16.0.dp(), 18.0.dp()),
                  child: SvgPicture.asset(
                    "ic_font_size".withIcon(),
                    width: 18.0.dp(),
                    height: 18.0.dp(),
                    color: Colors.white,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 2.0.dp(), right: 12.0.dp()),
                  child: AutoSizeText(
                    appLocalized().font_size,
                    style: UIFont.fontAppBold(
                        15.0.sp(), ColorHelper.colorTextNight),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    FontSizeDialog.show(context, fontSize, (fontChoose) {
                      preferenceHelper.fontSize = fontChoose;
                      appProviderRead.fontSize = fontChoose;
                    });
                  },
                  child: Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(right: 16.0.dp()),
                    color: theme(ColorHelper.colorBackgroundChildDay,
                        ColorHelper.colorBackgroundChildNight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.dp())),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            20.0.dp(), 2.0.dp(), 8.0.dp(), 4.0.dp()),
                        child: Text(
                          "$fontSize",
                          style: UIFont.fontAppBold(
                              15.0.sp(),
                              theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight)),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 2.0.dp(), right: 6.0.dp()),
                        child: SvgPicture.asset(
                          "ic_arrow_down".withIcon(),
                          width: 10.0.dp(),
                          height: 10.0.dp(),
                          color: theme(ColorHelper.colorTextDay2,
                              ColorHelper.colorTextNight2),
                        ),
                      )
                    ]),
                  ),
                )
              ]),
              Container(
                width: double.infinity,
                height: 1.0.dp(),
                margin: EdgeInsets.only(left: 50.0.dp()),
                color: Colors.white,
              ),
              Row(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16.0.dp(), 18.0.dp(), 16.0.dp(), 18.0.dp()),
                  child: SvgPicture.asset(
                    "ic_choice".withIcon(),
                    width: 18.0.dp(),
                    height: 18.0.dp(),
                    color: Colors.white,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 2.0.dp(), right: 12.0.dp()),
                  child: AutoSizeText(
                    appLocalized().answer_interface,
                    style: UIFont.fontAppBold(
                        15.0.sp(), ColorHelper.colorTextNight),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    TypeChoiceAnswerDialog.show(
                        context, isChoiceAnswerBottom ? 0 : 1, (typeChoice) {
                      preferenceHelper.typeChoiceAnswer = typeChoice;
                      appProviderRead.isChoiceAnswerBottom =
                          preferenceHelper.isChoiceAnswerBottom;
                    });
                  },
                  child: Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(right: 16.0.dp()),
                    color: theme(ColorHelper.colorBackgroundChildDay,
                        ColorHelper.colorBackgroundChildNight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.dp())),
                    child: SizedBox(
                      width: preferenceHelper.widthScreen / 3,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                10.0.dp(), 2.0.dp(), 4.0.dp(), 4.0.dp()),
                            child: AutoSizeText(
                              isChoiceAnswerBottom
                                  ? appLocalized().bottom_screen
                                  : appLocalized().above_the_topic,
                              style: UIFont.fontAppBold(
                                  15.0.sp(),
                                  theme(ColorHelper.colorTextDay,
                                      ColorHelper.colorTextNight)),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              minFontSize: 8.0.sp(),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 2.0.dp(), right: 6.0.dp()),
                          child: SvgPicture.asset(
                            "ic_arrow_down".withIcon(),
                            width: 10.0.dp(),
                            height: 10.0.dp(),
                            color: theme(ColorHelper.colorTextDay2,
                                ColorHelper.colorTextNight2),
                          ),
                        )
                      ]),
                    ),
                  ),
                )
              ]),
              SizedBox(height: 4.0.dp())
            ],
          ),
        ));
  }

  _sendReport(String content, String idQuestion) {
    var contentReport = Platform.operatingSystem;

    final email = preferenceHelper.userProfile?.email ?? "";
    if (email.isNotEmpty) {
      contentReport += " - Email: $email";
    }
    contentReport += " - Content exam: $content";
    dioHelper.postReportQuestion(contentReport, idQuestion).then((isSuccess) =>
        Toast(isSuccess
                ? appLocalized().report_sent
                : appLocalized().something_wrong)
            .show());
  }

  List<ExamCellObject>? _getQuestionList(ExamJSONObject? examQuestionObject) {
    final skills = examQuestionObject?.skills;
    if (skills.isNullOrEmpty) return null;

    List<ExamCellObject> questionList = [];
    var indexPart = 0;
    var posQuestion = 0;
    for (final skill in skills!) {
      final parts = skill.parts;
      if (parts.isNullOrEmpty) continue;

      for (final part in parts!) {
        final questions = part.question;
        if (questions.isNullOrEmpty) continue;

        for (var i = 0; i < questions!.length; i++) {
          questionList.add(ExamCellObject(i == 0 ? part.title : null, indexPart,
              posQuestion, questions[i]));
          posQuestion++;
        }
        indexPart++;
      }
    }
    return questionList;
  }

  bool _checkHasExplain(PracticeQuestion? questionObject) {
    if (questionObject == null) return false;

    final contentList = questionObject.content;
    if (!contentList.isNullOrEmpty) {
      for (final content in contentList!) {
        final explain = content.explain?.en;
        if (!explain.isNullOrEmpty) return true;
      }
    }
    return false;
  }
}
