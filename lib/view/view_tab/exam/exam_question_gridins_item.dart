import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_custom/latex_text.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../../model/exam/exam_cell_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';

// ignore: must_be_immutable
class ExamQuestionGridInsItem extends BasePage {
  int posQuestion;
  ExamCellObject? examObject;
  int currentQuestion;
  Function(int currentQuestion, bool isNextQuestion)? setAnswerChooseListener;

  ExamQuestionGridInsItem(this.posQuestion, this.examObject,
      this.currentQuestion, this.setAnswerChooseListener,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamQuestionGridInsItem>
    with SingleTickerProviderStateMixin {
  double paddingBottom = 0;
  double bannerHeight = 0;
  double keyboardHeight = 0;
  var fontSize = 15;
  bool isAutoNextQuestion = false;

  PracticeQuestion? questionObject;
  var currentQuestionChild = 0;

  @override
  void initState() {
    super.initState();
    questionObject = widget.examObject?.question;
  }

  @override
  Widget build(BuildContext context) {
    paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);
    fontSize = context.select((AppProvider provider) => provider.fontSize);
    isAutoNextQuestion =
        context.select((AppProvider provider) => provider.isAutoNextQuestion);

    bannerHeight =
        context.select((AppProvider provider) => provider.bannerHeight);
    keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Log.all("questionObject: ${jsonEncode(widget.questionObject)}");

    return _questionContentView();
  }

  final _scrollController = ScrollController();

  Widget _questionContentView() {
    final partTitle = widget.examObject?.title;

    final gText = questionObject?.general?.gText?.replaceAll("\n", "<br>");
    final gImage = questionObject?.general?.gImage;

    final contentList = questionObject?.content;

    if (keyboardHeight > 0 && mounted && _scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }

    return SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          if (!partTitle.isNullOrEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16.0.dp(), 16.0.dp(), 16.0.dp(), 4.0.dp()),
              child: Text(
                "✻ $partTitle!",
                style: UIFont.fontAppBold(
                    18.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
            ),
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
          isAutoNextQuestion
              ? GestureDetector(
                  onTap: () {
                    if (keyboardHeight > 0) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    if (widget.setAnswerChooseListener != null) {
                      widget.setAnswerChooseListener!(widget.posQuestion, true);
                    }
                  },
                  child: Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(
                        top: 12.0.dp(),
                        bottom: 24.0.dp() +
                            max(keyboardHeight - bannerHeight, paddingBottom)),
                    color: ColorHelper.colorPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0.dp())),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          24.0.dp(), 8.0.dp(), 24.0.dp(), 10.0.dp()),
                      child: Text(
                        appLocalized().next,
                        style: UIFont.fontAppBold(
                            15.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 24.0.dp() +
                      max(keyboardHeight - bannerHeight, paddingBottom))
        ]));
  }

  Widget _contentItemView(
      int posChildQues, QuestionContent contentItem, int totalQues) {
    final qText = contentItem.qText;
    final qImage = contentItem.qImage;

    if (qText.isNullOrEmpty && qImage.isNullOrEmpty) {
      return const SizedBox(width: double.infinity, height: 0);
    }

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
                Container(
                  width: double.infinity,
                  height: (14.0 + fontSize * 2).dp(),
                  margin: EdgeInsets.fromLTRB(
                      16.0.dp(), 4.0.dp(), 16.0.dp(), 16.0.dp()),
                  padding: EdgeInsets.only(left: 12.0.dp()),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5.dp(),
                        color: theme(ColorHelper.colorTextDay2,
                            ColorHelper.colorTextNight2)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    initialValue: contentItem.yourAnswerGridIns,
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
                      contentItem.yourAnswerGridIns = text;
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
