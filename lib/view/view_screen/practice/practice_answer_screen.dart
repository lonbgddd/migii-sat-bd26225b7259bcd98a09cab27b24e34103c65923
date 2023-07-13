import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
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
class PracticeAnswerScreen extends BasePage {
  PracticeJSONObject? practiceObject;
  TrainingSectionTheme? themeItem;

  PracticeAnswerScreen(this.practiceObject, this.themeItem, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeAnswerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Tab> tabs;

  @override
  void initState() {
    super.initState();
    tabs = [
      Tab(text: appLocalized().all),
      Tab(text: appLocalized().choose_wrong),
      Tab(text: appLocalized().choose_correct),
    ];

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _answerList =
        _getAnswerList(widget.practiceObject?.questions, _tabController.index);
    Utils.trackerScreen("PracticeAnswerScreen");
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

  List<NumberAnswerObject>? _answerList;

  Widget viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    return Column(children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0.dp()),
            color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)
                .withOpacity(0.39)),
        height: 40.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
        padding: EdgeInsets.all(2.0.dp()),
        child: TabBar(
          controller: _tabController,
          labelPadding: EdgeInsets.fromLTRB(8.0.dp(), 0, 8.0.dp(), 2.0.dp()),
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: theme(ColorHelper.colorBackgroundChildDay,
                  ColorHelper.colorBackgroundChildNight)),
          labelStyle: UIFont.fontAppBold(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          labelColor:
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
          tabs: tabs,
        ),
      ),
      Expanded(
          child: ListView.builder(
              key: const PageStorageKey("PracticeAnswerScreen"),
              padding: EdgeInsets.only(
                  top: 12.0.dp(), bottom: paddingBottom + 20.0.dp()),
              itemCount: _answerList?.length ?? 0,
              itemBuilder: (context, index) {
                return Builder(builder: (context) {
                  final item = _answerList![index];
                  return _answerViewCell(item,
                      itemEnd: index == _answerList!.length - 1);
                });
              },
              shrinkWrap: true))
    ]);
  }

  Widget _answerViewCell(NumberAnswerObject answerObject,
      {bool itemEnd = false}) {
    final correctAnswer = answerObject.answerCorrect ?? 0;
    final chooseAnswer = answerObject.answerChoose ?? 0;
    final numberAnswer = answerObject.numberAnswer ?? 4;

    final btnSize = 36.0.dp();
    final btnWidth = (preferenceHelper.widthScreen * 17 / 25) / numberAnswer;

    final questionNumber = answerObject.questionNumber ?? 0;
    final questionNumberChild = answerObject.questionNumberChild ?? -1;
    final numberTitle = questionNumberChild > -1
        ? "${questionNumber + 1}.${questionNumberChild + 1}"
        : "${questionNumber + 1}";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            final questionNumber = answerObject.questionNumber;
            if (questionNumber == null) return;
            final questionNumberChild = answerObject.questionNumberChild;
            if (questionNumberChild == null) return;
            _answerClickListener(questionNumber, questionNumberChild);
          },
          child: Container(
            color: Colors.transparent,
            child: Row(children: [
              SizedBox(width: 16.0.dp()),
              SvgPicture.asset(
                (chooseAnswer == 0
                        ? "ic_warning_2"
                        : (chooseAnswer == correctAnswer
                            ? "ic_correct"
                            : "ic_wrong"))
                    .withIcon(),
                color: chooseAnswer == 0
                    ? null
                    : (chooseAnswer == correctAnswer
                        ? const Color(0xFF26A394)
                        : ColorHelper.colorRed),
                width: 16.0.dp(),
                height: 16.0.dp(),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(left: 6.0.dp(), right: 6.0.dp()),
                child: AutoSizeText(
                  appLocalized().question_number_2.format([numberTitle]),
                  style: UIFont.fontAppBold(
                      15.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                  textAlign: TextAlign.center,
                ),
              )),
              for (var i = 0; i < numberAnswer; i++) ...{
                _answerButton(i, chooseAnswer, correctAnswer, btnSize, btnWidth)
              },
              SizedBox(width: 8.0.dp())
            ]),
          ),
        ),
        if (!itemEnd)
          Container(
            width: double.infinity,
            height: 1.0.dp(),
            margin: EdgeInsets.only(left: 32.0.dp(), right: 32.0.dp()),
            color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
          )
      ],
    );
  }

  Widget _answerButton(
    int index,
    int yourAnswer,
    int correctAnswer,
    double btnSize,
    double btnWidth,
  ) {
    return Container(
      width: max(btnSize, btnWidth),
      padding: EdgeInsets.only(top: 10.0.dp(), bottom: 10.0.dp()),
      child: Stack(alignment: Alignment.center, children: [
        Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
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
                      : Colors.transparent),
              border: Border.all(
                  width: 1.0.dp(),
                  color: (yourAnswer > 0 &&
                              (yourAnswer == index + 1 ||
                                  correctAnswer == index + 1)) ||
                          (yourAnswer == 0 && correctAnswer == index + 1)
                      ? Colors.transparent
                      : theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight))),
          alignment: Alignment.center,
          child: Text(
            String.fromCharCode(index + 65),
            style: UIFont.fontApp(
                15.0.sp(),
                (yourAnswer > 0 &&
                            (yourAnswer == index + 1 ||
                                correctAnswer == index + 1)) ||
                        (yourAnswer == 0 && correctAnswer == index + 1)
                    ? ColorHelper.colorTextNight
                    : theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          ),
        )
      ]),
    );
  }

  List<NumberAnswerObject>? _getAnswerList(
      List<PracticeQuestion>? questionsList, int tabSegment) {
    if (questionsList.isNullOrEmpty) return null;

    List<NumberAnswerObject> answerObjects = [];
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
        final yourChoose = content.yourAnswer;
        final correctAnswer =
            int.tryParse(content.qCorrect?.firstOrNull ?? "0") ?? 0;
        final numberAnswer = content.qAnswer?.length ?? 0;
        if (tabSegment == 0) {
          answerObjects.add(NumberAnswerObject(
              quesParentIndex,
              contentSize > 1 ? indexContent : -1,
              yourChoose,
              correctAnswer,
              numberAnswer));
        } else {
          final isCorrect = yourChoose > 0 && correctAnswer == yourChoose;
          if ((!isCorrect && tabSegment == 1) ||
              (isCorrect && tabSegment == 2)) {
            answerObjects.add(NumberAnswerObject(
                quesParentIndex,
                contentSize > 1 ? indexContent : -1,
                yourChoose,
                correctAnswer,
                numberAnswer));
          }
        }
      }
    }
    return answerObjects;
  }

  _answerClickListener(int posQuestion, int posQuestionChild) {
    RouterNavigate.pushScreen(
        context,
        PracticeScreen(
          widget.practiceObject,
          widget.themeItem,
          0,
          isShowAnswer: true,
          numberSentence: posQuestionChild == -1
              ? "${posQuestion + 1}"
              : "${posQuestion + 1}.${posQuestionChild + 1}",
        ));
    eventHelper.push(EventHelper.onShowIntervalAds);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _answerList = _getAnswerList(
          widget.practiceObject?.questions, _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
