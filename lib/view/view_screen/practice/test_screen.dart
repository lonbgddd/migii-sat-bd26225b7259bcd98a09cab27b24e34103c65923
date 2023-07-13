import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_dialog/exam_pause_dialog.dart';
import 'package:migii_sat/view/view_dialog/font_size_dialog.dart';
import 'package:migii_sat/view/view_dialog/practice_quit_dialog.dart';
import 'package:migii_sat/view/view_dialog/report_question_dialog.dart';
import 'package:migii_sat/view/view_dialog/submit_practice_dialog.dart';
import 'package:migii_sat/view/view_dialog/type_choice_answer_dialog.dart';
import 'package:migii_sat/view/view_screen/practice/practice_result_screen.dart';
import 'package:migii_sat/view/view_tab/practice/test_question_gridins_item.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../model/home/training_section_json_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../view_custom/bounce_widget.dart';
import '../../view_custom/toast.dart';
import '../../view_tab/practice/test_question_item.dart';

// ignore: must_be_immutable
class TestScreen extends BasePage {
  PracticeJSONObject? practiceObject;
  TrainingSectionTheme? themeItem;
  int questionFormat;

  TestScreen(this.practiceObject, this.themeItem, this.questionFormat,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<TestScreen> with WidgetsBindingObserver {
  List<PracticeQuestion>? questionsList;
  var questionSize = 0;

  var currentQuestion = 0;
  var isShowSetting = false;

  late int timePerQuestion;
  ValueNotifier<int> timeCountdown = ValueNotifier(-1);
  var isPause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    questionsList = widget.practiceObject?.questions;
    questionSize = questionsList?.length ?? 0;

    timePerQuestion = widget.questionFormat == 1
        ? (widget.themeItem?.timeResponse ?? 0)
        : (widget.themeItem?.timeMultiple ?? 0);

    _pageController.addListener(() {
      final progress = _pageController.page!;
      progressIndicator.value = progress;
    });
    timeCountdown.value = timePerQuestion;
    _startTimer();
    Utils.trackerScreen("TestScreen");
  }

  @override
  Widget build(BuildContext context) {
    final fontSize =
        context.select((AppProvider provider) => provider.fontSize);
    final isChoiceAnswerBottom =
        context.select((AppProvider provider) => provider.isChoiceAnswerBottom);

    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: Material(
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
                              if (isShowSetting) {
                                setState(() {
                                  isShowSetting = false;
                                });
                              }
                              PracticeQuitDialog.show(context, () {
                                Navigator.pop(context);
                                eventHelper.push(EventHelper.onShowIntervalAds);
                              });
                            }),
                        Text(
                          appLocalized()
                              .question_number
                              .format([currentQuestion + 1]),
                          style: UIFont.fontAppBold(
                              16.0.sp(), ColorHelper.colorTextNight),
                        ),
                        GestureDetector(
                          onTap: () {
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
                                  questionsList![currentQuestion].id ?? 0;
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
                            child:
                                Stack(alignment: Alignment.center, children: [
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
                            setState(() {
                              isShowSetting = !isShowSetting;
                            });
                          },
                          child: Container(
                            width: preferenceHelper.widthScreen / 9,
                            height: double.infinity,
                            color: Colors.transparent,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              SvgPicture.asset(
                                "ic_setttings_unselect".withIcon(),
                                width: 18.0.dp(),
                                height: 18.0.dp(),
                                color: ColorHelper.colorTextNight,
                              )
                            ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isShowSetting) {
                              setState(() {
                                isShowSetting = false;
                              });
                            }
                            isPause = true;
                            ExamPauseDialog.show(context, (isResume) {
                              if (isResume) {
                                isPause = false;
                              } else {
                                Navigator.pop(context);
                              }
                            });
                          },
                          child: Container(
                            width: preferenceHelper.widthScreen / 9,
                            height: double.infinity,
                            color: Colors.transparent,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              SvgPicture.asset(
                                "ic_pause_circle".withIcon(),
                                width: 18.0.dp(),
                                height: 18.0.dp(),
                                color: ColorHelper.colorTextNight,
                              )
                            ]),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            if (isShowSetting) {
                              setState(() {
                                isShowSetting = false;
                              });
                            }
                            _askComplete();
                          },
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                            padding:
                                EdgeInsets.fromLTRB(16.0.dp(), 0, 16.0.dp(), 0),
                            alignment: Alignment.center,
                            child: Text(
                              appLocalized().submit,
                              style: UIFont.fontAppBold(
                                  14.0.dp(), ColorHelper.colorTextNight,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        )
                      ])),
                  Transform.translate(
                    offset: Offset(0, -4.0.dp()),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "ic_time".withIcon(),
                          width: 18.0.dp(),
                          height: 18.0.dp(),
                          color: ColorHelper.colorTextNight,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 6.0.dp(), bottom: 2.0.dp()),
                          child: ValueListenableBuilder(
                            valueListenable: timeCountdown,
                            builder: (context, time, child) {
                              return Text(
                                _timeString(time),
                                style: UIFont.fontAppBold(
                                    14.0.sp(), ColorHelper.colorTextNight),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: progressIndicator,
                      builder: (context, value, child) {
                        return LinearPercentIndicator(
                          percent: questionSize == 0
                              ? 0
                              : (value + 1) / questionSize,
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
      ),
    );
  }

  final PageController _pageController = PageController();
  ValueNotifier<double> progressIndicator = ValueNotifier(0.0);

  Widget _viewContainer() {
    if (questionsList.isNullOrEmpty) return const SizedBox();

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (pos) {
        if (currentQuestion == pos) return;
        setState(() {
          currentQuestion = pos;
        });
        timeCountdown.value = timePerQuestion;
      },
      // scrollRightListener: (pagePre) {
      //   if (pagePre == questionsList!.length - 1) {
      //     _askComplete();
      //   }
      // },
      children: [
        for (var indexPage = 0;
            indexPage < questionsList!.length;
            indexPage++) ...[
          Utils.checkGridIns(questionsList![indexPage].kindId ?? "")
              ? TestQuestionGridInsItem(indexPage, questionsList![indexPage],
                  currentQuestion, _setAnswerChooseListener)
              : TestQuestionItem(indexPage, questionsList![indexPage],
                  currentQuestion, _setAnswerChooseListener)
        ],
      ],
    );
  }

  _setAnswerChooseListener(int currentQuestion, bool isNextQuestion) {
    if (currentQuestion >= (questionsList?.length ?? 0)) return;

    if (isNextQuestion) {
      if (currentQuestion < questionsList!.length - 1) {
        timeCountdown.value = -1;
        Future.delayed(const Duration(milliseconds: 300), () {
          _pageController.animateToPage(currentQuestion + 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
        });
      } else {
        _handleComplete();
      }
    }
  }

  _askComplete() {
    if (preferenceHelper.isAskSubmitPractice) {
      SubmitPracticeDialog.show(context, () {
        _handleComplete();
      });
    } else {
      _handleComplete();
    }
  }

  _handleComplete() {
    timeCountdown.value = -1;
    RouterNavigate.pushReplacementScreen(
        context,
        PracticeResultScreen(
          widget.practiceObject,
          widget.themeItem,
          widget.questionFormat,
          isTest: true,
        ));
  }

  Widget _viewSettings(int fontSize, bool isChoiceAnswerBottom) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: isShowSetting
            ? (widget.questionFormat == 0 ? 117.0.dp() : 63.0.dp())
            : 0,
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
              if (widget.questionFormat == 0) ...[
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
                    padding:
                        EdgeInsets.only(bottom: 2.0.dp(), right: 12.0.dp()),
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
              ],
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
    contentReport += " - Content: $content";
    dioHelper.postReportQuestion(contentReport, idQuestion).then((isSuccess) =>
        Toast(isSuccess
                ? appLocalized().report_sent
                : appLocalized().something_wrong)
            .show());
  }

  String _timeString(int time) {
    if (time <= 0) return "00:00";
    final minutes = time ~/ 60;
    final seconds = time % 60;
    return "%02d:%02d".format([minutes, seconds]);
  }

  Timer? _timer;
  var didStartTimer = false;

  _startTimer() {
    if (didStartTimer) return;
    didStartTimer = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeCountdown.value > -1 && !isPause) {
        if (timeCountdown.value < 1) {
          timeCountdown.value = -1;
          if (currentQuestion < (questionsList?.length ?? 0) - 1) {
            _pageController.animateToPage(currentQuestion + 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear);
          } else {
            _handleComplete();
          }
        } else {
          setState(() {
            timeCountdown.value -= 1;
          });
        }
      }
    });
  }

  _stopTimer() {
    if (!didStartTimer) return;
    didStartTimer = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _startTimer();
        break;
      case AppLifecycleState.paused:
        _stopTimer();
        break;
      default:
        break;
    }
  }

  Future<bool> onBackPressed(BuildContext context) async {
    if (isShowSetting) {
      setState(() {
        isShowSetting = false;
      });
    }
    PracticeQuitDialog.show(context, () {
      Navigator.pop(context);
      eventHelper.push(EventHelper.onShowIntervalAds);
    });
    return false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
