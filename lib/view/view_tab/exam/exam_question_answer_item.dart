import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
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

import '../../../model/exam/exam_cell_object.dart';
import '../../../model/practice/explain_content_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../model/practice/status_explain.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../view_custom/dragging_view.dart';

// ignore: must_be_immutable
class ExamQuestionAnswerItem extends BasePage {
  int posQuestion;
  ExamCellObject? examObject;
  int currentQuestion;

  ExamQuestionAnswerItem(
      this.posQuestion, this.examObject, this.currentQuestion,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamQuestionAnswerItem>
    with SingleTickerProviderStateMixin {
  double paddingBottom = 0;
  var fontSize = 15;
  var isChoiceAnswerBottom = false;

  PracticeQuestion? questionObject;
  var currentQuestionChild = 0;

  @override
  void initState() {
    super.initState();

    questionObject = widget.examObject?.question;
    eventHelper.listen((name) {
      switch (name) {
        case EventHelper.onShowExplain:
          if (widget.posQuestion == widget.currentQuestion) _showExplain();
          break;
        case EventHelper.onHideExplain:
          if (widget.posQuestion == widget.currentQuestion) _hideExplain();
          break;
      }
    });
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
      Expanded(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double height = constraints.maxHeight;
          explainMaxHeight = max(height - 34.0.dp(), 0);
          if (explainMaxHeight < explainHeight.value) {
            explainHeight.value = explainMaxHeight;
          }

          return Column(children: [
            Expanded(
                child: Stack(
              children: [
                _questionContentView(),
                if (statusExplain != StatusExplain.hide)
                  GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      double delta = details.delta.dy;
                      double height = min(max(explainHeight.value - delta, 0),
                          explainMaxHeight);
                      explainHeight.value = height;
                    },
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: draggingView()),
                  )
              ],
            )),
            if (statusExplain != StatusExplain.hide) _explainView(),
          ]);
        },
      )),
      if (isChoiceAnswerBottom) _answerBottomView(questionObject?.content ?? [])
    ]);
  }

  Widget _questionContentView() {
    final gText = questionObject?.general?.gText?.replaceAll("\n", "<br>");
    final gImage = questionObject?.general?.gImage;

    final contentList = questionObject?.content;

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
      Container(
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
                    : ((yourAnswer > 0 &&
                                (yourAnswer == index + 1 ||
                                    correct == index + 1)) ||
                            (yourAnswer == 0 && correct == index + 1)
                        ? Colors.transparent
                        : theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight))),
            color: isChoiceAnswerBottom
                ? Colors.transparent
                : (yourAnswer > 0
                    ? (yourAnswer == index + 1
                        ? (yourAnswer == correct
                            ? ColorHelper.colorPrimary
                            : ColorHelper.colorRed)
                        : (correct == index + 1
                            ? ColorHelper.colorPrimary
                            : Colors.transparent))
                    : (correct == index + 1
                        ? ColorHelper.colorPrimary
                        : Colors.transparent))),
        alignment: Alignment.center,
        child: Text(
          isChoiceAnswerBottom ? " $tag" : tag.replaceAll(".", ""),
          style: UIFont.fontAppBold(
              fontSize.toDouble().sp(),
              isChoiceAnswerBottom
                  ? theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)
                  : ((yourAnswer > 0 &&
                              (yourAnswer == index + 1 ||
                                  correct == index + 1)) ||
                          (yourAnswer == 0 && correct == index + 1)
                      ? ColorHelper.colorTextNight
                      : theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight))),
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
      if (!isChoiceAnswerBottom &&
          ((yourAnswer > 0 && yourAnswer == index + 1) ||
              (yourAnswer == 0 && correct == index + 1)))
        Padding(
          padding: EdgeInsets.only(top: 16.0.dp(), right: 16.0.dp()),
          child: SvgPicture.asset(
            (yourAnswer == 0
                    ? "ic_warning_2"
                    : (yourAnswer == correct ? "ic_correct" : "ic_wrong"))
                .withIcon(),
            color: yourAnswer == 0
                ? null
                : (yourAnswer == correct
                    ? const Color(0xFF26A394)
                    : ColorHelper.colorRed),
            width: 20.0.dp(),
            height: 20.0.dp(),
          ),
        )
    ]);
  }

  Widget _answerBottomView(List<QuestionContent> contentList) {
    if (contentList.isEmpty) return const SizedBox();

    final contentObject = contentList[currentQuestionChild];
    final correctAnswer =
        int.tryParse(contentObject.qCorrect?.firstOrNull ?? "0") ?? 0;
    var yourAnswer = contentObject.yourAnswer;

    final answerTotal = max(
        contentObject.qAnswer?.length ?? 0, contentObject.aImage?.length ?? 0);

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
          Padding(
            padding: EdgeInsets.only(left: 12.0.dp(), right: 8.0.dp()),
            child: SvgPicture.asset(
              (yourAnswer == 0
                      ? "ic_warning_2"
                      : (yourAnswer == correctAnswer
                          ? "ic_correct"
                          : "ic_wrong"))
                  .withIcon(),
              width: 24.0.dp(),
              height: 24.0.dp(),
              color: yourAnswer == 0
                  ? null
                  : (yourAnswer == correctAnswer
                      ? const Color(0xFF26A394)
                      : ColorHelper.colorRed),
            ),
          ),
          if (answerTotal > 0)
            for (var index = 0; index < answerTotal; index++) ...{
              Expanded(
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
                              color: (yourAnswer > 0 &&
                                          (yourAnswer == index + 1 ||
                                              correctAnswer == index + 1)) ||
                                      (yourAnswer == 0 &&
                                          correctAnswer == index + 1)
                                  ? Colors.transparent
                                  : theme(ColorHelper.colorTextDay,
                                      ColorHelper.colorTextNight)),
                          color: yourAnswer > 0
                              ? (yourAnswer == index + 1
                                  ? (yourAnswer == correctAnswer
                                      ? ColorHelper.colorPrimary
                                      : ColorHelper.colorRed)
                                  : (correctAnswer == index + 1
                                      ? ColorHelper.colorPrimary
                                      : Colors.transparent))
                              : (correctAnswer == index + 1
                                  ? ColorHelper.colorPrimary
                                  : Colors.transparent)),
                      alignment: Alignment.center,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: UIFont.fontAppBold(
                            15.0.sp(),
                            (yourAnswer > 0 &&
                                        (yourAnswer == index + 1 ||
                                            correctAnswer == index + 1)) ||
                                    (yourAnswer == 0 &&
                                        correctAnswer == index + 1)
                                ? ColorHelper.colorTextNight
                                : theme(ColorHelper.colorTextDay,
                                    ColorHelper.colorTextNight)),
                      ),
                    )
                  ],
                ),
              ))
            },
          SizedBox(width: 12.0.dp()),
        ])
      ]),
    );
  }

  ValueNotifier<double> explainHeight = ValueNotifier(0.0);
  double explainMaxHeight = 0;

  late TabController _tabController;
  ValueNotifier<List<String>?> explainTitles = ValueNotifier(null);
  ValueNotifier<List<ExplainContentObject>?> explainContents =
      ValueNotifier(null);
  var setupExplain = false;
  var statusExplain = StatusExplain.hide;

  Widget _explainView() {
    if (!setupExplain) {
      setupExplain = true;
      _setupExplain(questionObject, (listTitle, listContent) {
        _tabController =
            TabController(length: listTitle?.length ?? 0, vsync: this);
        explainTitles.value = listTitle;
        explainContents.value = listContent;
      });
    }

    return ValueListenableBuilder(
      valueListenable: explainTitles,
      builder: (context, titles, child) {
        if (titles.isNullOrEmpty) {
          return const SizedBox(width: double.infinity, height: 0);
        }
        return ValueListenableBuilder(
          valueListenable: explainContents,
          builder: (context, contents, child) {
            return ValueListenableBuilder(
              valueListenable: explainHeight,
              builder: (context, height, child) {
                if (height == 0) {
                  Future.delayed(Duration.zero, () async {
                    setState(() {
                      statusExplain = StatusExplain.hide;
                    });
                  });
                } else if (height == explainMaxHeight) {
                  Future.delayed(Duration.zero, () async {
                    setState(() {
                      statusExplain = StatusExplain.full;
                    });
                  });
                } else {
                  if (statusExplain != StatusExplain.normal) {
                    Future.delayed(Duration.zero, () async {
                      setState(() {
                        statusExplain = StatusExplain.normal;
                      });
                    });
                  }
                }
                return SizedBox(
                  width: double.infinity,
                  height: height,
                  child: Column(children: [
                    Container(
                      width: double.infinity,
                      height: min(height, 48.0.dp()),
                      decoration: BoxDecoration(
                          color: theme(ColorHelper.colorTextGreenDay,
                              ColorHelper.colorTextGreenNight),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.0.dp()),
                              topLeft: Radius.circular(12.0.dp()))),
                      child: Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              indicatorWeight: 2.0.dp(),
                              indicatorColor: Colors.white,
                              controller: _tabController,
                              labelStyle:
                                  UIFont.fontAppBold(14.0.sp(), Colors.white),
                              unselectedLabelStyle:
                                  UIFont.fontApp(14.0.sp(), Colors.white),
                              tabs: <Tab>[
                                for (final title in titles!) ...{
                                  Tab(text: title)
                                }
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _expandExplain();
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: double.infinity,
                              width: 40.0.dp(),
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 12.0.dp(), right: 12.0.dp()),
                              child: SvgPicture.asset(
                                statusExplain == StatusExplain.full
                                    ? "ic_inside".withIcon()
                                    : "ic_outside".withIcon(),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _hideExplain();
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: double.infinity,
                              width: 40.0.dp(),
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  left: 12.0.dp(), right: 12.0.dp()),
                              child: SvgPicture.asset(
                                "ic_close_3".withIcon(),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0.dp())
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF3EA394),
                        child: TabBarView(
                          controller: _tabController,
                          children: <Widget>[
                            for (final content in contents!) ...{
                              SingleChildScrollView(
                                child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!content.latexList.isNullOrEmpty)
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16.0.dp(),
                                                14.0.dp(),
                                                16.0.dp(),
                                                4.0.dp()),
                                            child: latexText(
                                                content.latexList!,
                                                UIFont.fontApp(
                                                    fontSize.toDouble().sp(),
                                                    Colors.white)),
                                          ),
                                        if (!content.imageList.isNullOrEmpty)
                                          for (final image
                                              in content.imageList!) ...{
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 4.0.dp(),
                                                    bottom: 4.0.dp()),
                                                child: Image.network(
                                                    image.addDomain(),
                                                    width: double.infinity,
                                                    fit: BoxFit.contain))
                                          },
                                        SizedBox(
                                          height: (isChoiceAnswerBottom
                                                  ? 0
                                                  : paddingBottom) +
                                              16.0.dp(),
                                        )
                                      ],
                                    )),
                              )
                            }
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              },
            );
          },
        );
      },
    );
  }

  _setupExplain(
      PracticeQuestion? questionObject,
      Function(List<String>? listTitle, List<ExplainContentObject>? listContent)
          completion) {
    if (questionObject == null) {
      completion(null, null);
      return;
    }

    List<String> listTitle = [];
    List<ExplainContentObject> listContent = [];

    final contentList = questionObject.content;
    if (!contentList.isNullOrEmpty) {
      if (contentList!.length > 1) {
        for (var index = 0; index < contentList.length; index++) {
          final explain = contentList[index].explain?.en ?? "";
          listTitle.add(appLocalized().question_number.format([index + 1]));
          listContent.add(ExplainContentObject(
              Utils.convertLatex(explain.trim()), contentList[index].eImage));
        }
      } else {
        final explain = contentList.first.explain?.en ?? "";
        if (explain.isNotEmpty) {
          listTitle.add(appLocalized().explain);
          listContent.add(ExplainContentObject(
              Utils.convertLatex(explain.trim()), contentList.first.eImage));
        }
      }
    }
    completion(listTitle, listContent);
  }

  var _isAnimating = false;

  _showExplain() {
    if (_isAnimating) return;
    if (statusExplain == StatusExplain.hide) {
      setState(() {
        explainHeight.value = 1;
        statusExplain = StatusExplain.normal;
        _animateExplain(explainHeight.value, explainMaxHeight / 2);
      });
    } else {
      _animateExplain(explainHeight.value, 0);
    }
  }

  _expandExplain() {
    if (_isAnimating) return;
    if (statusExplain == StatusExplain.full) {
      _animateExplain(explainHeight.value, explainMaxHeight / 2);
    } else {
      _animateExplain(explainHeight.value, explainMaxHeight);
    }
  }

  _hideExplain() {
    if (_isAnimating || statusExplain == StatusExplain.hide) return;
    _animateExplain(explainHeight.value, 0);
  }

  _animateExplain(double from, double to) async {
    _isAnimating = true;
    if (from < to) {
      while (explainHeight.value < to) {
        if (!mounted) return;
        explainHeight.value = min(explainHeight.value + 8, to);
        await Future.delayed(const Duration(milliseconds: 2));
      }
    } else {
      while (explainHeight.value > to) {
        if (!mounted) return;
        explainHeight.value = max(explainHeight.value - 8, to);
        await Future.delayed(const Duration(milliseconds: 2));
      }
    }
    _isAnimating = false;
  }
}
