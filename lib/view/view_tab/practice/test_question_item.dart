import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/latex_text.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';

// ignore: must_be_immutable
class TestQuestionItem extends BasePage {
  int posQuestion;
  PracticeQuestion? questionObject;
  int currentQuestion;
  Function(int currentQuestion, bool isNextQuestion)? setAnswerChooseListener;

  TestQuestionItem(this.posQuestion, this.questionObject, this.currentQuestion,
      this.setAnswerChooseListener,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<TestQuestionItem>
    with SingleTickerProviderStateMixin {
  double paddingBottom = 0;
  var fontSize = 15;
  var isChoiceAnswerBottom = false;

  var currentQuestionChild = 0;

  @override
  void initState() {
    super.initState();

    currentQuestionChild =
        _checkQuestionNotChoose(widget.questionObject?.content);
  }

  @override
  Widget build(BuildContext context) {
    paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);
    fontSize = context.select((AppProvider provider) => provider.fontSize);
    isChoiceAnswerBottom =
        context.select((AppProvider provider) => provider.isChoiceAnswerBottom);

    // Log.all("questionObject: ${jsonEncode(widget.questionObject)}");

    return Column(children: [
      Expanded(child: _questionContentView()),
      if (isChoiceAnswerBottom)
        _answerBottomView(widget.questionObject?.content ?? [])
    ]);
  }

  Widget _questionContentView() {
    final gText =
        widget.questionObject?.general?.gText?.replaceAll("\n", "<br>");
    final gImage = widget.questionObject?.general?.gImage;

    final contentList = widget.questionObject?.content;

    return SingleChildScrollView(
        child: Column(children: [
      SizedBox(height: 6.0.dp()),
      if (!gText.isNullOrEmpty || !gImage.isNullOrEmpty)
        Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0.dp())),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!gText.isNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        10.0.dp(), 8.0.dp(), 10.0.dp(), 10.0.dp()),
                    child: Html(
                      data: "<span>${gText!}</span>",
                      style: {
                        "span": UIFont.htmlFontApp(
                            fontSize.toDouble().sp(),
                            theme(ColorHelper.colorTextGreenDay,
                                ColorHelper.colorTextGreenNight))
                      },
                    ),
                  ),
                if (!gImage.isNullOrEmpty)
                  ClipRRect(
                    borderRadius: gText.isNullOrEmpty
                        ? BorderRadius.circular(8.0.dp())
                        : BorderRadius.only(
                            bottomLeft: Radius.circular(8.0.dp()),
                            bottomRight: Radius.circular(8.0.dp())),
                    child: Image.network(gImage!.addDomain(),
                        width: double.infinity, fit: BoxFit.contain),
                  )
              ],
            ),
          ),
        ),
      if (!contentList.isNullOrEmpty)
        for (var index = 0; index < contentList!.length; index++) ...{
          _contentItemView(index, contentList[index], contentList.length)
        },
      SizedBox(height: 24.0.dp() + (isChoiceAnswerBottom ? 0 : paddingBottom)),
    ]));
  }

  Widget _contentItemView(
      int posChildQues, QuestionContent contentItem, int totalQues) {
    final qText = contentItem.qText;
    final qImage = contentItem.qImage;

    final answerList = contentItem.qAnswer;
    final answerSize = answerList?.length ?? 0;

    final imageAnswerList = contentItem.aImage;
    final imageAnswerSize = imageAnswerList?.length ?? 0;

    final answerTotal = max(answerSize, imageAnswerSize);

    return Card(
      elevation: 4.0.dp(),
      margin: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.dp())),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!qText.isNullOrEmpty || !qImage.isNullOrEmpty) ...[
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color:
                      theme(const Color(0xFFBDA035), const Color(0xFF45736C)),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0.dp()),
                      topRight: Radius.circular(8.0.dp()))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!qText.isNullOrEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0.dp(), 10.0.dp(), 16.0.dp(), 12.0.dp()),
                      child: latexText(
                          Utils.convertLatex(
                              "${totalQues > 1 ? "${appLocalized().question_number.format([
                                      posChildQues + 1
                                    ])}: " : ""}${qText!.trim()}"),
                          UIFont.fontAppBold(fontSize.toDouble().sp(),
                              ColorHelper.colorTextNight)),
                    ),
                  if (!qImage.isNullOrEmpty)
                    ClipRRect(
                      borderRadius: qText.isNullOrEmpty
                          ? BorderRadius.only(
                              topLeft: Radius.circular(8.0.dp()),
                              topRight: Radius.circular(8.0.dp()))
                          : BorderRadius.zero,
                      child: Image.network(qImage!.addDomain(),
                          width: double.infinity, fit: BoxFit.contain),
                    )
                ],
              )),
          SizedBox(height: 4.0.dp()),
        ] else
          SizedBox(height: 8.0.dp()),
        if (answerTotal > 0)
          for (var index = 0; index < answerTotal; index++) ...{
            _answerTopItem(
                index,
                contentItem,
                index < answerSize ? answerList![index] : "",
                index < imageAnswerSize ? imageAnswerList![index] : "",
                posChildQues)
          },
        SizedBox(height: 8.0.dp())
      ]),
    );
  }

  Widget _answerTopItem(int index, QuestionContent contentObject, String answer,
      String imageAnswer, int posChildQues) {
    final tag = "${String.fromCharCode(index + 65)}.";

    final answerText = answer.isEmpty
        ? ""
        : (answer.trim().indexOf(tag) == 0
            ? answer.replaceFirst(tag, "").trim()
            : answer.trim());

    final paddingBonus = isChoiceAnswerBottom ? 0 : 2.0.dp();

    final yourAnswer = contentObject.yourAnswer;
    final correct =
        int.tryParse(contentObject.qCorrect?.firstOrNull ?? "0") ?? 0;

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () {
          if (isChoiceAnswerBottom) return;
          setState(() {
            contentObject.yourAnswer = index + 1;
          });
          _chooseAnswerListener(currentQuestionChild);
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(12.0.dp() + paddingBonus * 2,
              4.0.dp() + paddingBonus, 0, 4.0.dp() + paddingBonus),
          padding: EdgeInsets.only(bottom: 2.0.dp()),
          width: (6.0 + fontSize * 2).dp() + paddingBonus,
          height: (6.0 + fontSize * 2).dp() + paddingBonus,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  width: fontSize / 10,
                  color: isChoiceAnswerBottom
                      ? Colors.transparent
                      : theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
              color: isChoiceAnswerBottom
                  ? Colors.transparent
                  : (yourAnswer > 0 && yourAnswer == index + 1
                      ? ColorHelper.colorYellow
                      : Colors.transparent)),
          alignment: Alignment.center,
          child: Text(
            isChoiceAnswerBottom ? " $tag" : tag.replaceAll(".", ""),
            style: UIFont.fontAppBold(
                fontSize.toDouble().sp(),
                isChoiceAnswerBottom
                    ? theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)
                    : (yourAnswer > 0 && yourAnswer == index + 1
                        ? ColorHelper.colorTextDay
                        : theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight))),
          ),
        ),
      ),
      Flexible(
          child: Padding(
        padding: EdgeInsets.only(
            left: 8.0.dp() + paddingBonus, right: 12.0.dp(), top: 2.0.dp()),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: (12.0 + fontSize * 2).dp() + paddingBonus * 3),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (answerText.isNotEmpty)
                    latexText(
                        Utils.convertLatex(answerText),
                        UIFont.fontApp(
                            fontSize.toDouble().sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight),
                            decoration: yourAnswer > 0 &&
                                    yourAnswer == index + 1 &&
                                    yourAnswer != correct &&
                                    !isChoiceAnswerBottom
                                ? TextDecoration.lineThrough
                                : null)),
                  if (imageAnswer.isNotEmpty)
                    Image.network(imageAnswer.addDomain(),
                        width: double.infinity, fit: BoxFit.contain)
                ],
              )),
        ),
      )),
    ]);
  }

  Widget _answerBottomView(List<QuestionContent> contentList) {
    if (contentList.isEmpty) return const SizedBox();

    final contentObject = contentList[currentQuestionChild];
    var yourAnswer = contentObject.yourAnswer;

    List<String> listTitle = [];
    for (var i = 0; i < contentList.length; i++) {
      listTitle.add(appLocalized().sentence.format([i + 1]));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: paddingBottom),
      decoration: BoxDecoration(
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight, isNightMode: isNightMode),
          boxShadow: [
            BoxShadow(
              color:
                  theme(ColorHelper.colorGray, ColorHelper.colorBackgroundNight)
                      .withOpacity(0.39),
              blurRadius: 3.0.dp(),
              offset: Offset(0.0, -5.0.dp()),
            )
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0.dp()),
              topRight: Radius.circular(12.0.dp()))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (contentList.length > 1) ...{
          SizedBox(
            width: double.infinity,
            height: 44.0.dp(),
            child: SingleChildScrollView(
              child: Row(
                children: [
                  for (var i = 0; i < listTitle.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        if (currentQuestionChild == i) return;
                        setState(() {
                          currentQuestionChild = i;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        height: 44.0.dp(),
                        width: preferenceHelper.widthScreen / 3.5,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0.dp(), right: 8.0.dp()),
                                  child: AutoSizeText(
                                    listTitle[i],
                                    style: currentQuestionChild == i
                                        ? UIFont.fontAppBold(
                                            15.0.sp(),
                                            theme(
                                                ColorHelper.colorTextGreenDay,
                                                ColorHelper
                                                    .colorTextGreenNight))
                                        : UIFont.fontApp(
                                            14.0.sp(),
                                            theme(ColorHelper.colorGray,
                                                ColorHelper.colorGray2)),
                                    maxLines: 1,
                                    minFontSize: 8.0.sp(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: currentQuestionChild == i
                                  ? 2.0.dp()
                                  : 1.0.dp(),
                              color: currentQuestionChild == i
                                  ? theme(ColorHelper.colorTextGreenDay,
                                      ColorHelper.colorTextGreenNight)
                                  : theme(ColorHelper.colorGray,
                                      ColorHelper.colorGray2),
                            )
                          ],
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        },
        SizedBox(height: 4.0.dp()),
        Row(children: [
          SizedBox(width: 12.0.dp()),
          if ((contentObject.qAnswer?.length ?? 0) > 0)
            for (var index = 0;
                index < contentObject.qAnswer!.length;
                index++) ...{
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    contentObject.yourAnswer = index + 1;
                  });
                  _chooseAnswerListener(currentQuestionChild,
                      quesChildListener: (pos) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          currentQuestionChild = pos;
                        });
                      }
                    });
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(top: 8.0.dp(), bottom: 16.0.dp()),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Container(
                        height: 40.0.dp(),
                        width: 40.0.dp(),
                        padding: EdgeInsets.only(bottom: 2.0.dp()),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1.0.dp(),
                                color:
                                    (yourAnswer > 0 && yourAnswer == index + 1)
                                        ? theme(ColorHelper.colorTextDay,
                                            Colors.transparent)
                                        : theme(ColorHelper.colorTextDay,
                                            ColorHelper.colorTextNight)),
                            color: yourAnswer > 0 && yourAnswer == index + 1
                                ? ColorHelper.colorYellow
                                : Colors.transparent),
                        alignment: Alignment.center,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: UIFont.fontAppBold(
                              15.0.sp(),
                              (yourAnswer > 0 && yourAnswer == index + 1)
                                  ? ColorHelper.colorTextDay
                                  : theme(ColorHelper.colorTextDay,
                                      ColorHelper.colorTextNight)),
                        ),
                      )
                    ],
                  ),
                ),
              ))
            },
          SizedBox(width: 12.0.dp()),
        ])
      ]),
    );
  }

  _chooseAnswerListener(int posChildQues,
      {Function(int pos)? quesChildListener}) {
    final contentList = widget.questionObject?.content;
    if (contentList.isNullOrEmpty || posChildQues >= contentList!.length) {
      return;
    }

    var newIndex = -1;
    if (posChildQues < contentList.length - 1) {
      for (var index = posChildQues + 1; index < contentList.length; index++) {
        if (contentList[index].yourAnswer == 0) {
          newIndex = index;
          break;
        }
      }
    }

    if (newIndex == -1 && posChildQues > 0) {
      for (var index = 0; index < posChildQues; index++) {
        if (contentList[index].yourAnswer == 0) {
          newIndex = index;
          break;
        }
      }
    }

    if (newIndex != -1) {
      if (quesChildListener != null) quesChildListener(newIndex);
    } else {
      if (widget.setAnswerChooseListener != null) {
        widget.setAnswerChooseListener!(widget.posQuestion, true);
      }
    }
  }

  int _checkQuestionNotChoose(List<QuestionContent>? contentList) {
    if (contentList.isNullOrEmpty) return 0;

    var index = 0;
    for (var i = 0; i < contentList!.length; i++) {
      if (contentList[i].yourAnswer == 0) {
        index = i;
        break;
      }
    }
    return index;
  }
}
