import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/practice/practice_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:provider/provider.dart';

import '../../../model/home/training_section_json_object.dart';
import '../../../model/practice/number_answer_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/bounce_widget.dart';

// ignore: must_be_immutable
class PracticeAnswerGridInsScreen extends BasePage {
  PracticeJSONObject? practiceObject;
  TrainingSectionTheme? themeItem;

  PracticeAnswerGridInsScreen(this.practiceObject, this.themeItem, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeAnswerGridInsScreen> {
  @override
  void initState() {
    super.initState();
    _answerList = _getAnswerList(widget.practiceObject?.questions);
    Utils.trackerScreen("PracticeAnswerGridInsScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme(
            ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
        child: Column(
          children: [
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
                        appLocalized().show_answer,
                        style: UIFont.fontAppBold(
                            17.0.sp(), ColorHelper.colorTextNight),
                      ),
                    )
                  ])),
            ),
            Expanded(child: viewContainer())
          ],
        ),
      ),
    );
  }

  List<NumberAnswerGridInsObject>? _answerList;

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
                  width: 1.0.dp())),
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
                padding: EdgeInsets.only(bottom: paddingBottom + 20.0.dp()),
                itemCount: _answerList?.length ?? 0,
                itemBuilder: (context, index) {
                  return Builder(builder: (context) {
                    final item = _answerList![index];
                    return _answerViewCell(item);
                  });
                },
                shrinkWrap: true))
      ]),
    );
  }

  Widget _answerViewCell(NumberAnswerGridInsObject answerObject) {
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
        PracticeScreen(
          widget.practiceObject,
          widget.themeItem,
          1,
          isShowAnswer: true,
          numberSentence: posQuestionChild == -1
              ? "${posQuestion + 1}"
              : "${posQuestion + 1}.${posQuestionChild + 1}",
        ));
    eventHelper.push(EventHelper.onShowIntervalAds);
  }

  List<NumberAnswerGridInsObject>? _getAnswerList(
      List<PracticeQuestion>? questionsList) {
    if (questionsList.isNullOrEmpty) return null;

    List<NumberAnswerGridInsObject> answerObjects = [];
    for (var quesParentIndex = 0;
        quesParentIndex < questionsList!.length;
        quesParentIndex++) {
      final contentList = questionsList[quesParentIndex].content;
      if (contentList.isNullOrEmpty) continue;
      final contentSize = contentList!.length;
      for (var indexContent = 0;
          indexContent < contentList.length;
          indexContent++) {
        final content = contentList[indexContent];
        final yourAnswer = content.yourAnswerGridIns;
        final correctList = content.qCorrect;

        final isCorrect =
            Utils.checkGridInsCorrect(yourAnswer, correctList ?? []);

        answerObjects.add(NumberAnswerGridInsObject(
            quesParentIndex,
            contentSize > 1 ? indexContent : -1,
            yourAnswer,
            correctList,
            isCorrect));
      }
    }
    return answerObjects;
  }
}
