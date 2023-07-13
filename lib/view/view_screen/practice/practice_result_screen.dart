import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_custom/toast.dart';
import 'package:migii_sat/view/view_screen/practice/practice_answer_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:migii_sat/viewmodel/helper/event/event_helper.dart';
import 'package:migii_sat/viewmodel/helper/hive_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/home/training_section_json_object.dart';
import '../../../model/practice/practice_history_result_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../model/practice/practice_result_object.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/bounce_widget.dart';
import 'practice_answer_gridins_screen.dart';
import 'practice_screen.dart';
import 'test_screen.dart';

// ignore: must_be_immutable
class PracticeResultScreen extends BasePage {
  PracticeJSONObject? practiceObject;
  TrainingSectionTheme? themeItem;
  int questionFormat;

  bool isHistory;
  bool isTest;

  PracticeResultScreen(this.practiceObject, this.themeItem, this.questionFormat,
      {super.key, this.isHistory = false, this.isTest = false});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeResultScreen> {
  var correctQuestion = 0;
  var totalQuestion = 0;
  var percentResult = 0;

  var titleResult = "";
  var descResult = "";

  var statusSync = 0;

  @override
  void initState() {
    super.initState();
    _getResultNumber(widget.practiceObject?.questions,
        (totalQuestion, correctQuestion) {
      this.correctQuestion = correctQuestion;
      this.totalQuestion = totalQuestion;

      percentResult =
          totalQuestion == 0 ? 0 : (correctQuestion * 100 ~/ totalQuestion);

      _getTitleResult(percentResult, (title, desc) {
        titleResult = title;
        descResult = desc;
      });

      if (!widget.isHistory && widget.practiceObject != null) {
        _sendResultServer(widget.practiceObject!.questions);
        _addHistory(
            widget.practiceObject!, this.correctQuestion, this.totalQuestion);
      }
    });

    Utils.trackerScreen("PracticeResultScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme(
            ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
        child: Stack(children: [
          if (Utils.isPortrait(context))
            Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "img_background_practice".withImage(),
                  width: double.infinity,
                  fit: BoxFit.contain,
                )),
          _viewContainer(),
          Padding(
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            child: BounceWidget(
                child: Container(
                  width: preferenceHelper.appBarHeight,
                  height: preferenceHelper.appBarHeight,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "ic_back".withIcon(),
                    width: 20.0.dp(),
                    height: 20.0.dp(),
                    color: theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                  ),
                ),
                onPress: () {
                  Navigator.pop(context);
                }),
          ),
        ]),
      ),
    );
  }

  Widget _viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    return Column(children: [
      SizedBox(
        height: preferenceHelper.paddingInsetsTop +
            preferenceHelper.appBarHeight / 2,
      ),
      Image.asset(
        (percentResult >= 50 ? "img_result_pass" : "img_result_not_pass")
            .withImage(),
        width: double.infinity,
        height: Utils.heightScreen(context) * 2 / 9,
        fit: BoxFit.contain,
      ),
      SizedBox(height: 8.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.83,
        child: Text(
          titleResult,
          style: UIFont.fontAppBold(17.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 8.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.83,
        child: Text(
          descResult,
          style: UIFont.fontApp(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 24.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.83,
        child: Padding(
          padding: EdgeInsets.only(left: 4.0.dp()),
          child: Text(
            appLocalized().result.format([correctQuestion, totalQuestion]),
            style: UIFont.fontAppBold(16.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          ),
        ),
      ),
      FractionallySizedBox(
        widthFactor: 0.83,
        child: Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.only(top: 8.0.dp()),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.dp())),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.fromLTRB(20.0.dp(), 12.0.dp(), 20.0.dp(), 0),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      appLocalized().right_rate,
                      style: UIFont.fontApp(
                          16.0.sp(),
                          theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight)),
                    )),
                    Text(
                      "$percentResult%",
                      style: UIFont.fontApp(
                          16.0.sp(),
                          theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight)),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
                child: Container(
                  height: 12.0.dp(),
                  decoration: BoxDecoration(
                      color: theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.0.dp())),
                  padding: EdgeInsets.all(3.0.dp()),
                  child: LinearPercentIndicator(
                    percent: percentResult / 100,
                    lineHeight: 6.0.dp(),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    progressColor: percentResult < 40
                        ? ColorHelper.colorRed_2
                        : (percentResult >= 80
                            ? ColorHelper.colorGreen
                            : ColorHelper.colorYellow_2),
                    barRadius: Radius.circular(3.0.dp()),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0.dp(), bottom: 16.0.dp()),
                child: Text(
                  appLocalized().try_continue,
                  style: UIFont.fontAppBold(
                      15.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                ),
              )
            ],
          ),
        ),
      ),
      const Expanded(child: SizedBox()),
      Row(children: [
        SizedBox(width: 24.0.dp()),
        Expanded(
            child: GestureDetector(
          onTap: () {
            if (statusSync == 1) return;
            if (widget.questionFormat == 1) {
              RouterNavigate.pushScreen(
                  context,
                  PracticeAnswerGridInsScreen(
                      widget.practiceObject, widget.themeItem));
            } else {
              RouterNavigate.pushScreen(
                  context,
                  PracticeAnswerScreen(
                      widget.practiceObject, widget.themeItem));
            }
          },
          child: Card(
            elevation: 4.0.dp(),
            margin: EdgeInsets.zero,
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0.dp())),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
              height: 44.0.dp(),
              alignment: Alignment.center,
              child: AutoSizeText(
                appLocalized().show_answer,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                maxLines: 1,
                minFontSize: 8.0.sp(),
              ),
            ),
          ),
        )),
        SizedBox(width: 16.0.dp()),
        if (widget.isHistory)
          Expanded(
              child: GestureDetector(
            onTap: () {
              final practiceObject = widget.practiceObject;
              if (practiceObject == null) {
                Toast(appLocalized().something_wrong).show();
                return;
              }
              final questions = practiceObject.questions;
              if (!questions.isNullOrEmpty) {
                for (final questionItem in questions!) {
                  final contentList = questionItem.content;
                  if (contentList.isNullOrEmpty) continue;

                  if (widget.questionFormat == 1) {
                    for (final content in contentList!) {
                      content.yourAnswerGridIns = "";
                    }
                  } else {
                    for (final content in contentList!) {
                      content.yourAnswer = 0;
                    }
                  }
                }
              }

              RouterNavigate.pushReplacementScreen(
                  context,
                  PracticeScreen(
                      practiceObject, widget.themeItem, widget.questionFormat));
            },
            child: Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.zero,
              color: theme(ColorHelper.colorBackgroundChildDay,
                  ColorHelper.colorBackgroundChildNight),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0.dp())),
              child: Container(
                padding: EdgeInsets.fromLTRB(12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                height: 44.0.dp(),
                alignment: Alignment.center,
                child: AutoSizeText(
                  appLocalized().do_again,
                  style: UIFont.fontAppBold(
                      15.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          ))
        else if (statusSync == 1)
          Expanded(
              child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 44.0.dp(),
                      height: 44.0.dp(),
                      child: const LoadingIndicator(
                          indicatorType: Indicator.lineSpinFadeLoader,
                          colors: [ColorHelper.colorAccent]))))
        else
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (statusSync == 2) return;
              if (_practiceObject == null) {
                Toast(appLocalized().something_wrong).show();
                return;
              }
              if (widget.isTest) {
                RouterNavigate.pushReplacementScreen(
                    context,
                    TestScreen(_practiceObject, widget.themeItem,
                        widget.questionFormat));
              } else {
                RouterNavigate.pushReplacementScreen(
                    context,
                    PracticeScreen(_practiceObject, widget.themeItem,
                        widget.questionFormat));
              }
            },
            child: Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.zero,
              color: statusSync == 0
                  ? theme(ColorHelper.colorBackgroundChildDay,
                      ColorHelper.colorBackgroundChildNight)
                  : theme(ColorHelper.colorGray, ColorHelper.colorGray2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0.dp())),
              child: Container(
                padding: EdgeInsets.fromLTRB(12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                height: 44.0.dp(),
                alignment: Alignment.center,
                child: AutoSizeText(
                  appLocalized().resume,
                  style: UIFont.fontAppBold(
                      15.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          )),
        SizedBox(width: 24.0.dp()),
      ]),
      SizedBox(height: paddingBottom + 24.0.dp())
    ]);
  }

  _getResultNumber(List<PracticeQuestion>? questionsList,
      Function(int totalQuestion, int correctQuestion) completion) {
    if (questionsList.isNullOrEmpty) {
      completion(0, 0);
      return;
    }
    var totalQuestion = 0;
    var correctQuestion = 0;

    for (final question in questionsList!) {
      final listContent = question.content;
      if (listContent.isNullOrEmpty) continue;
      totalQuestion += listContent!.length;
      for (var index = 0; index < listContent.length; index++) {
        var isCorrect = false;
        if (widget.questionFormat == 1) {
          isCorrect = Utils.checkGridInsCorrect(
              listContent[index].yourAnswerGridIns,
              listContent[index].qCorrect ?? []);
        } else {
          final correct =
              int.tryParse(listContent[index].qCorrect?.first ?? "0") ?? 0;
          final yourAnswer = listContent[index].yourAnswer;
          isCorrect = correct > 0 && correct == yourAnswer;
        }
        if (isCorrect) {
          // đúng
          correctQuestion += 1;
          if (!widget.isHistory) {
            final idSubQues = "${question.id}$index";
            preferenceHelper.addIdQuestionsCorrect(
                idSubQues, question.kindId ?? "");
            preferenceHelper.addIdQuestionsDid(
                idSubQues, question.kindId ?? "");
          }
        } else {
          // sai
          if (!widget.isHistory) {
            final idSubQues = "${question.id}$index";
            preferenceHelper.removeIdQuestionsCorrect(
                idSubQues, question.kindId ?? "");
            preferenceHelper.addIdQuestionsDid(
                idSubQues, question.kindId ?? "");
          }
        }
      }
    }
    completion(totalQuestion, correctQuestion);
  }

  _getTitleResult(
      int percentResult, Function(String title, String desc) completion) {
    final random = Random().nextInt(3);

    if (percentResult < 40) {
      switch (random) {
        case 0:
          completion(appLocalized().result_title_poor_1,
              appLocalized().result_desc_poor_1);
          break;
        case 1:
          completion(appLocalized().result_title_poor_2,
              appLocalized().result_desc_poor_2);
          break;
        case 2:
          completion(appLocalized().result_title_poor_3,
              appLocalized().result_desc_poor_3);
          break;
      }
      return;
    }

    if (percentResult > 80) {
      switch (random) {
        case 0:
          completion(appLocalized().result_title_good_1,
              appLocalized().result_desc_good_1);
          break;
        case 1:
          completion(appLocalized().result_title_good_2,
              appLocalized().result_desc_good_2);
          break;
        case 2:
          completion(appLocalized().result_title_good_3,
              appLocalized().result_desc_good_3);
          break;
      }
      return;
    }

    switch (random) {
      case 0:
        completion(appLocalized().result_title_average_1,
            appLocalized().result_desc_average_1);
        break;
      case 1:
        completion(appLocalized().result_title_average_2,
            appLocalized().result_desc_average_2);
        break;
      case 2:
        completion(appLocalized().result_title_average_3,
            appLocalized().result_desc_average_3);
        break;
    }
  }

  _sendResultServer(List<PracticeQuestion>? questionsList) {
    if (questionsList.isNullOrEmpty) {
      Future.delayed(Duration.zero, () async {
        if (mounted) {
          setState(() {
            statusSync = 2;
          });
        }
      });
      return;
    }

    List<PracticeResultItem> items = [];
    for (final ques in questionsList!) {
      final contentList = ques.content;
      if (contentList.isNullOrEmpty) continue;

      var numberCorrect = 0;
      var numberIncorrect = 0;

      for (final content in contentList!) {
        if (widget.questionFormat == 1) {
          final isCorrect = Utils.checkGridInsCorrect(
              content.yourAnswerGridIns, content.qCorrect ?? []);
          if (isCorrect) {
            numberCorrect++;
          } else {
            numberIncorrect++;
          }
        } else {
          final correct = int.tryParse(content.qCorrect?.first ?? "0") ?? 0;
          if (content.yourAnswer == correct) {
            numberCorrect++;
          } else {
            numberIncorrect++;
          }
        }
      }
      items.add(PracticeResultItem(
          ques.id, ques.kindId, numberCorrect, numberIncorrect));
    }

    final practiceResultObject =
        PracticeResultObject(items, preferenceHelper.idDevice);

    if (!isInternetAvailable) {
      setState(() {
        statusSync = 2;
      });

      final syncList = preferenceHelper.getHistoryPracticeSync();
      syncList.add(practiceResultObject);
      preferenceHelper.historyPracticeSync = jsonEncode(syncList);
      return;
    }

    setState(() {
      statusSync = 1;
    });
    dioHelper.postResultPractice(practiceResultObject).then((isSuccess) {
      if (!mounted) return;
      if (isSuccess) {
        _loadNewQuestion();
      } else {
        final syncList = preferenceHelper.getHistoryPracticeSync();
        syncList.add(practiceResultObject);
        preferenceHelper.historyPracticeSync = jsonEncode(syncList);

        setState(() {
          statusSync = 2;
        });
      }
    });
  }

  _addHistory(PracticeJSONObject practiceJSONObject, int correctQuestion,
      int totalQuestion) {
    final idHistoryNew = _checkIdHistory(HiveHelper.getHistoryPracticeList());
    List<String>? idKindList = widget.themeItem?.idKindList;

    int time = Provider.of<AppProvider>(context, listen: false).timeServer;

    List<PracticeHistoryItem> practiceList = [];

    List<PracticeQuestion>? questionList = practiceJSONObject.questions;
    if (!questionList.isNullOrEmpty) {
      for (final question in questionList!) {
        final contentList = question.content;
        if (contentList.isNullOrEmpty) continue;

        if (widget.questionFormat == 1) {
          List<String> yourAnswerGridInsList = [];
          for (final content in contentList!) {
            yourAnswerGridInsList.add(content.yourAnswerGridIns);
          }
          practiceList.add(
              PracticeHistoryItem(question.id, null, yourAnswerGridInsList));
        } else {
          List<int> yourAnswerList = [];
          for (final content in contentList!) {
            yourAnswerList.add(content.yourAnswer);
          }
          practiceList
              .add(PracticeHistoryItem(question.id, yourAnswerList, null));
        }

        HiveHelper.putData(
            "${GlobalHelper.idQuestion}${question.id}", jsonEncode(question));
      }
    }

    final practiceHistoryNew = PracticeHistoryResultObject(
        idHistoryNew,
        idKindList,
        correctQuestion,
        totalQuestion,
        time,
        widget.questionFormat,
        practiceList);
    HiveHelper.addHistoryPractice(practiceHistoryNew);
    eventHelper.push(EventHelper.onUpdateHistory);
  }

  String _checkIdHistory(List<PracticeHistoryResultObject>? historyList) {
    var index = 1;
    var idHistory = "${GlobalHelper.idHistoryPractice}$index";
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
      idHistory = "${GlobalHelper.idHistoryPractice}$index";
    }
    return idHistory;
  }

  PracticeJSONObject? _practiceObject;

  _loadNewQuestion() {
    if (!mounted) return;
    List<String>? idKindList = widget.themeItem?.idKindList;
    if (idKindList.isNullOrEmpty) {
      setState(() {
        statusSync = 2;
      });
      return;
    }

    var hasFormat = false;
    for (final id in idKindList!) {
      if (id.contains("_") && !hasFormat) hasFormat = true;
    }

    final List<String> idList = [];
    for (final idKind in idKindList) {
      if (hasFormat) {
        idList.add("${idKind}_${widget.questionFormat}");
      } else {
        idList.add(idKind);
      }
    }

    dioHelper
        .getQuestionsPractice(idList, totalQuestion, preferenceHelper.idDevice)
        .then((practiceObject) {
      if (!mounted) return;

      final questionsList = practiceObject?.questions;
      if (questionsList.isNullOrEmpty) {
        setState(() {
          statusSync = 2;
        });
        return;
      }

      setState(() {
        statusSync = 0;
      });
      _practiceObject = practiceObject;
      eventHelper.push(EventHelper.onShowIntervalAds);
    });
  }
}
