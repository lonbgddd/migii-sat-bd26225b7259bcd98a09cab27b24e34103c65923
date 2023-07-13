import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/dragging_view.dart';
import 'package:migii_sat/view/view_custom/latex_text.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../../model/practice/explain_content_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../model/practice/status_explain.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';

// ignore: must_be_immutable
class PracticeQuestionGridInsItem extends BasePage {
  int posQuestion;
  PracticeQuestion? questionObject;
  int currentQuestion;
  bool isShowAnswer;
  Function(int currentQuestion, bool isNextQuestion)? setAnswerChooseListener;

  PracticeQuestionGridInsItem(this.posQuestion, this.questionObject,
      this.currentQuestion, this.setAnswerChooseListener, this.isShowAnswer,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeQuestionGridInsItem>
    with SingleTickerProviderStateMixin {
  double paddingBottom = 0;
  double bannerHeight = 0;
  double keyboardHeight = 0;
  var fontSize = 15;

  var currentQuestionChild = 0;
  late List<String> answerEnterList;

  @override
  void initState() {
    super.initState();

    answerEnterList =
        List.filled(widget.questionObject?.content?.length ?? 0, "");

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

    bannerHeight =
        context.select((AppProvider provider) => provider.bannerHeight);
    keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    if (keyboardHeight > 0 && statusExplain != StatusExplain.hide) {
      _hideExplain();
    }

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
    ]);
  }

  final _scrollController = ScrollController();

  Widget _questionContentView() {
    final gText =
        widget.questionObject?.general?.gText?.replaceAll("\n", "<br>");
    final gImage = widget.questionObject?.general?.gImage;

    final contentList = widget.questionObject?.content;
    final didCheck = !(contentList?.first.yourAnswerGridIns).isNullOrEmpty;

    if (keyboardHeight > 0 &&
        mounted &&
        !didCheck &&
        _scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }

    return SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          SizedBox(height: 6.0.dp()),
          if (!gText.isNullOrEmpty || !gImage.isNullOrEmpty)
            Card(
              elevation: 4.0.dp(),
              margin:
                  EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
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
          !widget.isShowAnswer
              ? GestureDetector(
                  onTap: () {
                    if (didCheck) return;
                    if (keyboardHeight > 0) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }

                    setState(() {
                      for (var i = 0; i < contentList!.length; i++) {
                        contentList[i].yourAnswerGridIns =
                            answerEnterList[i].trim().isNotEmpty
                                ? answerEnterList[i].trim()
                                : "...";
                      }
                    });

                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (widget.setAnswerChooseListener != null) {
                        widget.setAnswerChooseListener!(
                            widget.posQuestion, true);
                      }
                    });
                  },
                  child: Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(
                        top: 12.0.dp(),
                        bottom: 24.0.dp() +
                            max(keyboardHeight - bannerHeight, paddingBottom)),
                    color: didCheck
                        ? theme(ColorHelper.colorGray, ColorHelper.colorGray2)
                        : ColorHelper.colorYellow_2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.dp())),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          24.0.dp(), 8.0.dp(), 24.0.dp(), 10.0.dp()),
                      child: Text(
                        appLocalized().check,
                        style: UIFont.fontAppBold(
                            15.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  ),
                )
              : SizedBox(height: 24.0.dp() + paddingBottom),
        ]));
  }

  Widget _contentItemView(
      int posChildQues, QuestionContent contentItem, int totalQues) {
    final qText = contentItem.qText;
    final qImage = contentItem.qImage;

    if (qText.isNullOrEmpty && qImage.isNullOrEmpty) {
      return const SizedBox(width: double.infinity, height: 0);
    }

    var yourAnswerGridIns = contentItem.yourAnswerGridIns;
    if (yourAnswerGridIns.isEmpty && widget.isShowAnswer) {
      yourAnswerGridIns = "...";
    }
    final isCorrect = Utils.checkGridInsCorrect(
        yourAnswerGridIns, contentItem.qCorrect ?? []);

    return Card(
      elevation: 4.0.dp(),
      margin: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0.dp())),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0.dp()),
        child: SizedBox(
            width: double.infinity,
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
                        UIFont.fontApp(
                            fontSize.toDouble().sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight))),
                  ),
                if (!qImage.isNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.0.dp()),
                    child: Image.network(qImage!.addDomain(),
                        width: double.infinity, fit: BoxFit.contain),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: (14.0 + fontSize * 2).dp(),
                        margin: EdgeInsets.fromLTRB(
                            16.0.dp(), 4.0.dp(), 8.0.dp(), 16.0.dp()),
                        padding: EdgeInsets.only(left: 12.0.dp()),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1.5.dp(),
                              color: yourAnswerGridIns.isNullOrEmpty &&
                                      !widget.isShowAnswer
                                  ? theme(ColorHelper.colorTextDay2,
                                      ColorHelper.colorTextNight2)
                                  : (isCorrect
                                      ? const Color(0xFF26A394)
                                      : ColorHelper.colorRed)),
                          color: yourAnswerGridIns.isNullOrEmpty &&
                                  !widget.isShowAnswer
                              ? null
                              : (isCorrect
                                      ? const Color(0xFF26A394)
                                      : ColorHelper.colorRed)
                                  .withOpacity(0.15),
                        ),
                        alignment: Alignment.centerLeft,
                        child: yourAnswerGridIns.isNullOrEmpty &&
                                !widget.isShowAnswer
                            ? TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: appLocalized().enter_answer,
                                    hintStyle: UIFont.fontApp(
                                        fontSize.toDouble().sp(),
                                        theme(ColorHelper.colorGray,
                                            ColorHelper.colorGray2))),
                                style: UIFont.fontApp(
                                    fontSize.toDouble().sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                                onChanged: (text) {
                                  answerEnterList[posChildQues] = text;
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: true),
                              )
                            : Text(
                                yourAnswerGridIns,
                                style: UIFont.fontApp(
                                    fontSize.toDouble().sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                                maxLines: 1,
                              ),
                      ),
                    ),
                    if (widget.isShowAnswer)
                      Padding(
                        padding:
                            EdgeInsets.only(right: 4.0.dp(), left: 4.0.dp()),
                        child: SvgPicture.asset(
                          (yourAnswerGridIns == "..."
                                  ? "ic_warning_2"
                                  : (isCorrect ? "ic_correct" : "ic_wrong"))
                              .withIcon(),
                          width: 24.0.dp(),
                          height: 24.0.dp(),
                          color: yourAnswerGridIns == "..."
                              ? null
                              : (isCorrect
                                  ? const Color(0xFF26A394)
                                  : ColorHelper.colorRed),
                        ),
                      ),
                    SizedBox(width: 8.0.dp())
                  ],
                ),
                if ((!yourAnswerGridIns.isNullOrEmpty || widget.isShowAnswer) &&
                    !contentItem.qCorrect.isNullOrEmpty) ...[
                  for (final correct in contentItem.qCorrect!) ...{
                    Padding(
                        padding: EdgeInsets.fromLTRB(
                            16.0.dp(), 0, 16.0.dp(), 4.0.dp()),
                        child: Text(
                          "✏  $correct",
                          style: UIFont.fontAppBold(
                              fontSize.toDouble().sp(),
                              theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight)),
                        ))
                  },
                  SizedBox(height: 8.0.dp())
                ]
              ],
            )),
      ),
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
      _setupExplain(widget.questionObject, (listTitle, listContent) {
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
                                          height: paddingBottom + 16.0.dp(),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
