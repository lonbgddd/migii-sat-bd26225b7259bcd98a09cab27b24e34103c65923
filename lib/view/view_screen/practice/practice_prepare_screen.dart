
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/main.dart';
import 'package:migii_sat/model/practice/practice_json_object.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_custom/toast.dart';
import 'package:migii_sat/view/view_dialog/number_question_dialog.dart';
import 'package:migii_sat/view/view_dialog/option_display_answer_dialog.dart';
import 'package:migii_sat/view/view_screen/practice/practice_screen.dart';
import 'package:migii_sat/view/view_screen/practice/test_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:migii_sat/viewmodel/helper/log_cat.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../../model/home/training_section_json_object.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../view_custom/bounce_widget.dart';
import '../../view_custom/dashed_line_horizontal_painter.dart';

// ignore: must_be_immutable
class PracticePrepareScreen extends BasePage {
  TrainingSectionTheme themeItem;

  PracticePrepareScreen(this.themeItem, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticePrepareScreen> {
  late List<String>? _idKindList;
  var _numberQuestion = 0;
  var _numberQuestionPre = 0;
  var _idKind = "";
  var _hasFormat = false;
  var _questionFormat = 0; // 0: Trắc nghiệm - 1: tự luận
  var _questionFormatPre = 0;
  var _maxQuestion = 0;

  PracticeJSONObject? _practiceObject;
  var _isLoading = false;
  var _placeHolder = "";

  var _isTestMode = false;
  var _timeTest = 0;

  @override
  void initState() {
    super.initState();
    _idKindList = widget.themeItem.idKindList;
    if (!_idKindList.isNullOrEmpty) {
      var text = "";
      for (final id in _idKindList!) {
        if (text.isNotEmpty) text += "_";
        text += id;
        if (id.contains("_") && !_hasFormat) _hasFormat = true;
      }
      _idKind = text;
    } else {
      Future.delayed(Duration.zero, () async {
        _showErrorPlaceholder();
      });
      return;
    }
    if (_hasFormat) {
      _questionFormat = preferenceHelper.getQuestionFormat(_idKind);
    }

    _numberQuestion =
        preferenceHelper.getNumberQuestionStart(_idKind, _questionFormat) == 0
            ? (widget.themeItem.defaultQuestion ?? 1)
            : preferenceHelper.getNumberQuestionStart(_idKind, _questionFormat);
    _maxQuestion = (widget.themeItem.defaultQuestion ?? 1) * 3;
    _loadQuestions();
    Utils.trackerScreen("PracticePrepareScreen");
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
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _viewContainer(),
          )
        ]),
      ),
    );
  }

  Widget _viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    var name = widget.themeItem.name ?? "";
    if (name.contains(":")) {
      name = name.substring(name.indexOf(":") + 1).trim();
    }

    return Column(children: [
      SizedBox(height: preferenceHelper.paddingInsetsTop),
      Image.asset(
        "img_character_practice_2".withImage(),
        width: preferenceHelper.screenWidthMinimum / 2,
        fit: BoxFit.contain,
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
        child: Text(
          name,
          style: UIFont.fontAppBold(
              17.0.sp(),
              theme(ColorHelper.colorTextGreenDay,
                  ColorHelper.colorTextGreenNight)),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
          child: Column(children: [
        Flexible(
            child: Card(
          elevation: 4.0.dp(),
          margin:
              EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 12.0.dp()),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.dp())),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(),
                          16.0.dp(), _isTestMode ? 12.0.dp() : 14.0.dp()),
                      child: Text(
                        widget.themeItem.description ?? "",
                        style: UIFont.fontApp(
                            14.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    child: _isTestMode
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DashedLineHorizontalPainter(
                                height: 1.0.dp(),
                                dashWidth: 3.0.dp(),
                                color: theme(ColorHelper.colorGray,
                                    ColorHelper.colorGray2),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 6.0.dp(), bottom: 8.0.dp()),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        "ic_time".withIcon(),
                                        width: 18.0.dp(),
                                        height: 18.0.dp(),
                                        color: ColorHelper.colorAccent,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 8.0.dp()),
                                      Text(
                                        _convertTime(_timeTest),
                                        style: UIFont.fontAppBold(
                                            14.0.sp(),
                                            theme(ColorHelper.colorTextDay,
                                                ColorHelper.colorTextNight)),
                                      ),
                                      SizedBox(width: 12.0.dp())
                                    ]),
                              )
                            ],
                          )
                        : const SizedBox(width: double.infinity, height: 0)),
              ],
            ),
          ),
        )),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible:
              !_isLoading && (_placeHolder.isEmpty || _practiceObject != null),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${appLocalized().number_questions}:",
                style: UIFont.fontApp(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              ),
              GestureDetector(
                onTap: () {
                  NumberQuestionDialog.show(
                      context, _maxQuestion, _numberQuestion, (numberChoose) {
                    if (_numberQuestion == numberChoose) return;
                    setState(() {
                      _numberQuestion = numberChoose;
                    });
                    _loadQuestions();
                  });
                },
                child: Card(
                  elevation: 4.0.dp(),
                  margin: EdgeInsets.fromLTRB(16.0.dp(), 4.0.dp(), 0, 4.0.dp()),
                  color: theme(ColorHelper.colorBackgroundChildDay,
                      ColorHelper.colorBackgroundChildNight),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0.dp())),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          28.0.dp(), 4.0.dp(), 12.0.dp(), 6.0.dp()),
                      child: Text(
                        "$_numberQuestion",
                        style: UIFont.fontAppBold(
                            15.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.0.dp(), right: 6.0.dp()),
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
            ],
          ),
        ),
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible:
              !_isLoading && (_placeHolder.isEmpty || _practiceObject != null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              "${appLocalized().test_mode}:",
              style: UIFont.fontApp(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            ),
            Container(
                height: 36.0.dp(),
                margin: EdgeInsets.only(left: 4.0.dp(), top: 4.0.dp()),
                child: Switch(
                    value: _isTestMode,
                    activeColor: ColorHelper.colorAccent,
                    onChanged: (bool value) {
                      setState(() {
                        _isLoading = true;
                      });
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() {
                            _isTestMode = value;
                            _isLoading = false;
                          });
                        }
                      });
                    }))
          ]),
        ),
        if (_hasFormat)
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: !_isLoading &&
                (_placeHolder.isEmpty || _practiceObject != null),
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(4.0.dp(), 8.0.dp(), 4.0.dp(), 4.0.dp()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${appLocalized().question_type}:",
                    style: UIFont.fontApp(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(left: 12.0.dp()),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0.dp()),
                          border: Border.all(
                              color: theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight),
                              width: 1.0.dp())),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(
                            child: GestureDetector(
                          onTap: () {
                            if (_questionFormat != 0) {
                              setState(() {
                                _questionFormat = 0;
                                _numberQuestion = preferenceHelper
                                            .getNumberQuestionStart(
                                                _idKind, _questionFormat) ==
                                        0
                                    ? (widget.themeItem.defaultQuestion ?? 1)
                                    : preferenceHelper.getNumberQuestionStart(
                                        _idKind, _questionFormat);
                                _maxQuestion =
                                    (widget.themeItem.defaultQuestion ?? 1) * 3;
                              });
                              _loadQuestions();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16.0.dp(),
                                  height: 16.0.dp(),
                                  margin: EdgeInsets.fromLTRB(
                                      8.0.dp(), 10.0.dp(), 4.0.dp(), 10.0.dp()),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: _questionFormat == 0
                                              ? theme(
                                                  ColorHelper.colorTextGreenDay,
                                                  ColorHelper
                                                      .colorTextGreenNight)
                                              : theme(ColorHelper.colorTextDay,
                                                  ColorHelper.colorTextNight),
                                          width: 1.5.dp()),
                                      borderRadius:
                                          BorderRadius.circular(8.0.dp())),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_questionFormat == 0) ...{
                                          Container(
                                            width: 6.0.dp(),
                                            height: 6.0.dp(),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        3.0.dp()),
                                                color: theme(
                                                    ColorHelper
                                                        .colorTextGreenDay,
                                                    ColorHelper
                                                        .colorTextGreenNight)),
                                          )
                                        }
                                      ]),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 2.0.dp(), right: 6.0.dp()),
                                    child: AutoSizeText(
                                      "Multiple Choice",
                                      style: _questionFormat == 0
                                          ? UIFont.fontAppBold(
                                              13.0.sp(),
                                              theme(
                                                  ColorHelper.colorTextGreenDay,
                                                  ColorHelper
                                                      .colorTextGreenNight))
                                          : UIFont.fontApp(
                                              13.0.sp(),
                                              theme(ColorHelper.colorTextDay,
                                                  ColorHelper.colorTextNight)),
                                      maxLines: 1,
                                      minFontSize: 8.0.sp(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                        Container(
                          width: 1.0.dp(),
                          height: 24.0.dp(),
                          color: theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight),
                        ),
                        Flexible(
                            child: GestureDetector(
                          onTap: () {
                            if (_questionFormat != 1) {
                              setState(() {
                                _questionFormat = 1;
                                _numberQuestion = preferenceHelper
                                            .getNumberQuestionStart(
                                                _idKind, _questionFormat) ==
                                        0
                                    ? (widget.themeItem.defaultQuestion ?? 1)
                                    : preferenceHelper.getNumberQuestionStart(
                                        _idKind, _questionFormat);
                                _maxQuestion =
                                    (widget.themeItem.defaultQuestion ?? 1) * 3;
                              });
                              _loadQuestions();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16.0.dp(),
                                  height: 16.0.dp(),
                                  margin: EdgeInsets.fromLTRB(
                                      8.0.dp(), 10.0.dp(), 4.0.dp(), 10.0.dp()),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: _questionFormat == 1
                                              ? theme(
                                                  ColorHelper.colorTextGreenDay,
                                                  ColorHelper
                                                      .colorTextGreenNight)
                                              : theme(ColorHelper.colorTextDay,
                                                  ColorHelper.colorTextNight),
                                          width: 1.5.dp()),
                                      borderRadius:
                                          BorderRadius.circular(8.0.dp())),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_questionFormat == 1) ...{
                                          Container(
                                            width: 6.0.dp(),
                                            height: 6.0.dp(),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        3.0.dp()),
                                                color: theme(
                                                    ColorHelper
                                                        .colorTextGreenDay,
                                                    ColorHelper
                                                        .colorTextGreenNight)),
                                          )
                                        }
                                      ]),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 2.0.dp(), right: 6.0.dp()),
                                    child: AutoSizeText(
                                      "Grid-Ins",
                                      style: _questionFormat == 1
                                          ? UIFont.fontAppBold(
                                              13.0.sp(),
                                              theme(
                                                  ColorHelper.colorTextGreenDay,
                                                  ColorHelper
                                                      .colorTextGreenNight))
                                          : UIFont.fontApp(
                                              13.0.sp(),
                                              theme(ColorHelper.colorTextDay,
                                                  ColorHelper.colorTextNight)),
                                      maxLines: 1,
                                      minFontSize: 8.0.sp(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                      ]),
                    ),
                  )
                ],
              ),
            ),
          )
      ])),
      if (_isLoading)
        Container(
            margin: EdgeInsets.only(
                bottom: paddingBottom + 20.0.dp(), top: 60.0.dp()),
            width: 44.0.dp(),
            height: 44.0.dp(),
            child: const LoadingIndicator(
                indicatorType: Indicator.lineSpinFadeLoader,
                colors: [ColorHelper.colorAccent]))
      else if (_placeHolder.isEmpty || _practiceObject != null)
        FractionallySizedBox(
          widthFactor: 0.66,
          child: GestureDetector(
            onTap: () {
              _handleStart();
            },
            child: Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.only(
                  bottom: paddingBottom + 20.0.dp(), top: 60.0.dp()),
              color: ColorHelper.colorPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0.dp())),
              child: Container(
                height: 44.0.dp(),
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                    left: 12.0.dp(), right: 12.0.dp(), bottom: 2.0.dp()),
                child: AutoSizeText(
                  appLocalized().start,
                  style:
                      UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          ),
        )
      else
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "ic_warning".withIcon(),
                    width: 14.0.dp(),
                    height: 14.0.dp(),
                  ),
                  SizedBox(width: 14.0.dp()),
                  AutoSizeText(
                    _placeHolder,
                    style: UIFont.fontApp(13.0.sp(), ColorHelper.colorRed),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 8.0.sp(),
                  )
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.66,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _placeHolder = "";
                  });
                  _loadQuestions();
                },
                child: Card(
                  elevation: 4.0.dp(),
                  margin: EdgeInsets.only(
                      bottom: paddingBottom + 20.0.dp(), top: 12.0.dp()),
                  color: ColorHelper.colorRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0.dp())),
                  child: Container(
                    height: 44.0.dp(),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        left: 12.0.dp(), right: 12.0.dp(), bottom: 2.0.dp()),
                    child: AutoSizeText(
                      appLocalized().try_again,
                      style: UIFont.fontAppBold(
                          15.0.sp(), ColorHelper.colorTextNight),
                      maxLines: 1,
                      minFontSize: 8.0.sp(),
                    ),
                  ),
                ),
              ),
            )
          ],
        )
    ]);
  }

  _handleStart() {
    if (_practiceObject == null) {
      Toast(appLocalized().something_wrong).show();
      return;
    }

    if (preferenceHelper.isShowDialogTypeChoiceAnswer && _questionFormat != 1) {
      OptionDisplayAnswerDialog.show(context, () {
        preferenceHelper.isShowDialogTypeChoiceAnswer = false;
        _handleStart();
      });
      return;
    }

    if (_isTestMode) {
      RouterNavigate.pushReplacementScreen(context,
          TestScreen(_practiceObject, widget.themeItem, _questionFormat));
    } else {
      RouterNavigate.pushReplacementScreen(context,
          PracticeScreen(_practiceObject, widget.themeItem, _questionFormat));
    }
  }

  _loadQuestions() {
    if (_idKindList.isNullOrEmpty) {
      _showErrorPlaceholder();
      return;
    }

    if (!isInternetAvailable) {
      _showNoConnectPlaceholder();
      return;
    }

    final List<String> idList = [];
    for (final idKind in _idKindList!) {
      if (_hasFormat) {
        idList.add("${idKind}_$_questionFormat");
      } else {
        idList.add(idKind);
      }
    }

    setState(() {
      _isLoading = true;
    });

    dioHelper
        .getQuestionsPractice(
            idList, _numberQuestion, preferenceHelper.idDevice)
        .then((practiceObject) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final questionsList = practiceObject?.questions;
      if (questionsList.isNullOrEmpty) {
        if (isInternetAvailable) {
          _showErrorPlaceholder();
        } else {
          _showNoConnectPlaceholder();
        }
        return;
      }

      final sizeQues = questionsList!.length;
      if (sizeQues < _numberQuestion) {
        _maxQuestion = sizeQues;
        setState(() {
          _numberQuestion = sizeQues;
        });
      }

      // final json = jsonEncode(practiceObject);
      // Log.d("check: ${json.contains("satisfies the system of equations above, what is the value of")}");

      preferenceHelper.urlDomain = practiceObject!.domain ?? "";

      preferenceHelper.setNumberQuestionStart(
          _idKind, _numberQuestion, _questionFormat);
      _practiceObject = practiceObject;
      _questionFormatPre = _questionFormat;
      _numberQuestionPre = _numberQuestion;
      _timeTest = sizeQues *
          (_hasFormat && _questionFormat == 1
              ? (widget.themeItem.timeResponse ?? 0)
              : (widget.themeItem.timeMultiple ?? 0));
      if (_isTestMode) setState(() {});

      // _checkHasImage(practiceObject);
    });
  }

  // _checkHasImage(PracticeJSONObject practiceJSONObject) {
  //   var general_gImage_index = -1;
  //   PracticeQuestion? general_gImage_object;
  //
  //   var content_gImage_index = -1;
  //   PracticeQuestion? content_gImage_object;
  //
  //   var content_aImage_index = -1;
  //   PracticeQuestion? content_aImage_object;
  //
  //   var content_eImage_index = -1;
  //   PracticeQuestion? content_eImage_object;
  //
  //   var content_hasImg_index = -1;
  //   PracticeQuestion? content_hasImg_object;
  //
  //   var content_qAnswer_index = -1;
  //   PracticeQuestion? content_qAnswer_object;
  //
  //   final questionList = practiceJSONObject.questions;
  //   if (!questionList.isNullOrEmpty) {
  //     for (var index = 0; index < questionList!.length; index++) {
  //       final questionItem = questionList[index];
  //       final gText = questionItem.general?.gText;
  //
  //       if (!gText.isNullOrEmpty &&
  //           gText!.contains("img") &&
  //           content_hasImg_index == -1) {
  //         content_hasImg_index = index;
  //         content_hasImg_object = questionItem;
  //       }
  //
  //       final gImage = questionItem.general?.gImage;
  //       if (!gImage.isNullOrEmpty && general_gImage_index == -1) {
  //         general_gImage_index = index;
  //         general_gImage_object = questionItem;
  //       }
  //
  //       final contentList = questionItem.content;
  //       if (!contentList.isNullOrEmpty) {
  //         for (final content in contentList!) {
  //           final qText = content.qText;
  //           if (!qText.isNullOrEmpty &&
  //               qText!.contains("img") &&
  //               content_hasImg_index == -1) {
  //             content_hasImg_index = index;
  //             content_hasImg_object = questionItem;
  //           }
  //
  //           final qImage = content.qImage;
  //           if (!qImage.isNullOrEmpty && content_gImage_index == -1) {
  //             content_gImage_index = index;
  //             content_gImage_object = questionItem;
  //           }
  //
  //           final aImage = content.aImage;
  //           if (!aImage.isNullOrEmpty && content_aImage_index == -1) {
  //             content_aImage_index = index;
  //             content_aImage_object = questionItem;
  //           }
  //
  //           final qAnswer = content.qAnswer;
  //           if (!qAnswer.isNullOrEmpty && content_qAnswer_index == -1) {
  //             content_qAnswer_index = index;
  //             content_qAnswer_object = questionItem;
  //           }
  //
  //           final eImage = content.eImage;
  //           if (!eImage.isNullOrEmpty && content_eImage_index == -1) {
  //             content_eImage_index = index;
  //             content_eImage_object = questionItem;
  //           }
  //
  //           final explain = content.explain?.en;
  //           if (!explain.isNullOrEmpty &&
  //               explain!.contains("img") &&
  //               content_hasImg_index == -1) {
  //             content_hasImg_index = index;
  //             content_hasImg_object = questionItem;
  //           }
  //         }
  //       }
  //     }
  //   }
  //
  //   Log.d("hasGeneral_gImage: ${general_gImage_index > -1}");
  //   Log.d("hasContent_gImage: ${content_gImage_index > -1}");
  //   Log.d("hasContent_aImage: ${content_aImage_index > -1}");
  //   Log.d("hasContent_eImage: ${content_eImage_index > -1}");
  //   Log.d("hasImg: ${content_hasImg_index > -1}");
  //   Log.d("hasContent_qAnswer: ${content_qAnswer_index > -1}");
  //
  //   if (general_gImage_index > -1) {
  //     Log.all("general_gImage_object: ${jsonEncode(general_gImage_object)}");
  //   }
  //
  //   if (content_gImage_index > -1) {
  //     Log.all("content_gImage_object: ${jsonEncode(content_gImage_object)}");
  //   }
  //
  //   if (content_aImage_index > -1) {
  //     Log.all("content_aImage_object: ${jsonEncode(content_aImage_object)}");
  //   }
  //
  //   if (content_eImage_index > -1) {
  //     Log.all("content_eImage_object: ${jsonEncode(content_eImage_object)}");
  //   }
  //
  //   if (content_hasImg_index > -1) {
  //     Log.all("content_hasImg_object: ${jsonEncode(content_hasImg_object)}");
  //   }
  //
  //   if (content_qAnswer_index > -1) {
  //     Log.all("content_qAnswer_object: ${jsonEncode(content_qAnswer_object)}");
  //   }
  //
  // }

  _showErrorPlaceholder() {
    if (!mounted) return;
    if (_practiceObject != null) {
      setState(() {
        _questionFormat = _questionFormatPre;
        _numberQuestion = _numberQuestionPre;
      });
      Toast(appLocalized().something_wrong).show();
    } else {
      setState(() {
        _placeHolder = appLocalized().loadingError;
      });
    }
  }

  _showNoConnectPlaceholder() {
    if (!mounted) return;
    if (_practiceObject != null) {
      setState(() {
        _questionFormat = _questionFormatPre;
        _numberQuestion = _numberQuestionPre;
      });
      Toast(appLocalized().no_internet).show();
    } else {
      setState(() {
        _placeHolder = appLocalized().no_connect;
      });
    }
  }

  String _convertTime(int timeTotal) {
    var timeString = "";
    if (timeTotal ~/ 3600 > 0) timeString = "${timeTotal ~/ 3600}h";
    if ((timeTotal % 3600) ~/ 60 > 0) {
      timeString =
          "${timeString.isEmpty ? "" : "$timeString "}${(timeTotal % 3600) ~/ 60}m";
    }
    timeString =
        "${timeString.isEmpty ? "" : "$timeString "}${(timeTotal % 3600) % 60}s";
    return timeString;
  }
}
