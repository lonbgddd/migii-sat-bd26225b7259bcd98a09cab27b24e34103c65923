import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/exam/exam_practice_screen.dart';
import 'package:migii_sat/view/view_screen/exam/exam_result_screen.dart';
import 'package:migii_sat/view/view_screen/exam/exam_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/map_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:migii_sat/viewmodel/helper/event/event_helper.dart';
import 'package:migii_sat/viewmodel/helper/hive_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/exam/exam_json_object.dart';
import '../../../model/exam/exam_list_json_object.dart';
import '../../../model/exam/exam_state_object.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../view_custom/bounce_widget.dart';
import '../../view_custom/highlight_text.dart';
import '../../view_custom/toast.dart';
import '../../view_dialog/option_display_answer_dialog.dart';

// ignore: must_be_immutable
class ExamPrepareScreen extends BasePage {
  ExamListQuestion? examObject;
  ExamStateObject? examState;

  ExamPrepareScreen(this.examObject, this.examState, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamPrepareScreen> {
  ExamJSONObject? _examObject;
  var _isLoading = false;
  var _placeHolder = "";

  var _examMode = 0;

  @override
  void initState() {
    super.initState();
    _loadExam();
    Utils.trackerScreen("ExamPrepareScreen");
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
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _viewContainer(),
          ),
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
          )
        ]),
      ),
    );
  }

  Widget _viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    var examTitle = "";
    final name =
        widget.examObject?.name?.toLowerCase().replaceAll("test", "").trim();
    if (!name.isNullOrEmpty) {
      final number = int.tryParse(name!) ?? -1;
      if (number > -1) {
        examTitle = appLocalized().test_number.format([number]);
      }
    }

    if (examTitle.isEmpty) examTitle = widget.examObject?.name ?? "";

    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
            preferenceHelper.appBarHeight,
            preferenceHelper.paddingInsetsTop + 24.0.dp(),
            preferenceHelper.appBarHeight,
            0),
        child: Text(
          examTitle,
          style: UIFont.fontAppBold(
              18.0.sp(),
              theme(ColorHelper.colorTextGreenDay,
                  ColorHelper.colorTextGreenNight)),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 0),
        child: HighlightText(
          text: appLocalized().exam_time.format([134]),
          style: UIFont.fontApp(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          spanList: [
            SpanItem(text: appLocalized().exam_time_key),
          ],
          spanStyle: UIFont.fontAppBold(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 0),
        child: HighlightText(
          text: appLocalized().exam_number_question.format([98]),
          style: UIFont.fontApp(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          spanList: [SpanItem(text: appLocalized().exam_number_question_key)],
          spanStyle: UIFont.fontAppBold(15.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
        ),
      ),
      Expanded(
          child: Padding(
        padding:
            EdgeInsets.only(left: preferenceHelper.screenWidthMinimum / 16),
        child: Image.asset(
          "img_character_exam".withImage(),
          width: preferenceHelper.screenWidthMinimum * 3 / 4,
          fit: BoxFit.contain,
        ),
      )),
      FractionallySizedBox(
        widthFactor: 0.75,
        child: Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: (_placeHolder.isEmpty || _examObject != null) && !_isLoading,
          child: Card(
            elevation: 4.0.dp(),
            margin: EdgeInsets.zero,
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0.dp())),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8.0.dp()),
                Text(
                  appLocalized().exam_mode,
                  style: UIFont.fontAppBold(
                      16.0.sp(),
                      theme(ColorHelper.colorTextGreenDay,
                          ColorHelper.colorTextGreenNight)),
                ),
                SizedBox(height: 4.0.dp()),
                GestureDetector(
                  onTap: () {
                    if (_examMode == 0) return;
                    setState(() {
                      _examMode = 0;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(
                        8.0.dp(), 4.0.dp(), 12.0.dp(), 4.0.dp()),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _examMode == 0
                              ? SvgPicture.asset(
                                  "ic_finger_2".withIcon(),
                                  width: 28.0.dp(),
                                  height: 28.0.dp(),
                                  fit: BoxFit.contain,
                                )
                              : SizedBox(width: 28.0.dp()),
                          SizedBox(width: 12.0.dp()),
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appLocalized().test,
                                style: UIFont.fontAppBold(
                                    15.0.sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                              ),
                              SizedBox(height: 2.0.dp()),
                              Text(
                                "(${appLocalized().mock_test_like_real})",
                                style: UIFont.fontApp(
                                    14.0.sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                              )
                            ],
                          )),
                        ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_examMode == 1) return;
                    setState(() {
                      _examMode = 1;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(
                        8.0.dp(), 4.0.dp(), 12.0.dp(), 4.0.dp()),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _examMode == 1
                              ? SvgPicture.asset(
                                  "ic_finger_2".withIcon(),
                                  width: 28.0.dp(),
                                  height: 28.0.dp(),
                                  fit: BoxFit.contain,
                                )
                              : SizedBox(width: 28.0.dp()),
                          SizedBox(width: 12.0.dp()),
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appLocalized().practice,
                                style: UIFont.fontAppBold(
                                    15.0.sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                              ),
                              SizedBox(height: 2.0.dp()),
                              Text(
                                "(${appLocalized().test_with_explain})",
                                style: UIFont.fontApp(
                                    14.0.sp(),
                                    theme(ColorHelper.colorTextDay,
                                        ColorHelper.colorTextNight)),
                              )
                            ],
                          )),
                        ]),
                  ),
                ),
                SizedBox(height: 8.0.dp()),
              ],
            ),
          ),
        ),
      ),
      if (_isLoading)
        Container(
            margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
            width: 44.0.dp(),
            height: 44.0.dp(),
            child: const LoadingIndicator(
                indicatorType: Indicator.lineSpinFadeLoader,
                colors: [ColorHelper.colorAccent]))
      else if (_placeHolder.isEmpty || _examObject != null) ...[
        if (widget.examState == null)
          FractionallySizedBox(
            widthFactor: 0.66,
            child: GestureDetector(
              onTap: () {
                _handleStart();
              },
              child: Card(
                elevation: 4.0.dp(),
                margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
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
                    style: UIFont.fontAppBold(
                        15.0.sp(), ColorHelper.colorTextNight),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                ),
              ),
            ),
          )
        else if ((widget.examState?.timeRemain ?? 0) > 0) ...[
          _examMode == 0
              ? Row(children: [
                  SizedBox(width: 20.0.dp()),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _handleResume();
                    },
                    child: Card(
                      elevation: 4.0.dp(),
                      margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
                      color: ColorHelper.colorAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0.dp())),
                      child: Container(
                        height: 44.0.dp(),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            left: 12.0.dp(),
                            right: 12.0.dp(),
                            bottom: 2.0.dp()),
                        child: AutoSizeText(
                          appLocalized().exam_continue,
                          style: UIFont.fontAppBold(
                              15.0.sp(), ColorHelper.colorTextNight),
                          maxLines: 1,
                          minFontSize: 8.0.sp(),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 16.0.dp()),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _handleStart();
                    },
                    child: Card(
                      elevation: 4.0.dp(),
                      margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
                      color: ColorHelper.colorPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0.dp())),
                      child: Container(
                        height: 44.0.dp(),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            left: 12.0.dp(),
                            right: 12.0.dp(),
                            bottom: 2.0.dp()),
                        child: AutoSizeText(
                          appLocalized().start,
                          style: UIFont.fontAppBold(
                              15.0.sp(), ColorHelper.colorTextNight),
                          maxLines: 1,
                          minFontSize: 8.0.sp(),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(width: 20.0.dp()),
                ])
              : FractionallySizedBox(
                  widthFactor: 0.66,
                  child: GestureDetector(
                    onTap: () {
                      _handleStart();
                    },
                    child: Card(
                      elevation: 4.0.dp(),
                      margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
                      color: ColorHelper.colorPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0.dp())),
                      child: Container(
                        height: 44.0.dp(),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            left: 12.0.dp(),
                            right: 12.0.dp(),
                            bottom: 2.0.dp()),
                        child: AutoSizeText(
                          appLocalized().start,
                          style: UIFont.fontAppBold(
                              15.0.sp(), ColorHelper.colorTextNight),
                          maxLines: 1,
                          minFontSize: 8.0.sp(),
                        ),
                      ),
                    ),
                  ),
                )
        ] else ...[
          Row(children: [
            SizedBox(width: 20.0.dp()),
            Expanded(
                child: GestureDetector(
              onTap: () {
                _handleResult();
              },
              child: Card(
                elevation: 4.0.dp(),
                margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
                color: ColorHelper.colorPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0.dp())),
                child: Container(
                  height: 44.0.dp(),
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      left: 12.0.dp(), right: 12.0.dp(), bottom: 2.0.dp()),
                  child: AutoSizeText(
                    appLocalized().show_last_result,
                    style: UIFont.fontAppBold(
                        15.0.sp(), ColorHelper.colorTextNight),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                ),
              ),
            )),
            SizedBox(width: 16.0.dp()),
            Expanded(
                child: GestureDetector(
              onTap: () {
                _handleStart();
              },
              child: Card(
                elevation: 4.0.dp(),
                margin: EdgeInsets.only(top: 56.0.dp(), bottom: 8.0.dp()),
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
                    style: UIFont.fontAppBold(
                        15.0.sp(), ColorHelper.colorTextNight),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                ),
              ),
            )),
            SizedBox(width: 20.0.dp()),
          ])
        ]
      ] else ...[
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
              _loadExam();
            },
            child: Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.all(8.0.dp()),
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
                  style:
                      UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          ),
        )
      ],
      SizedBox(height: paddingBottom + 16.0.dp())
    ]);
  }

  _handleStart() {
    if (_examObject == null) {
      Toast(appLocalized().something_wrong).show();
      return;
    }

    if (preferenceHelper.isShowDialogTypeChoiceAnswer) {
      OptionDisplayAnswerDialog.show(context, () {
        preferenceHelper.isShowDialogTypeChoiceAnswer = false;
        _handleStart();
      });
      return;
    }

    if (_examMode == 0) {
      RouterNavigate.pushReplacementScreen(
          context, ExamScreen(widget.examObject, _examObject));
    } else {
      RouterNavigate.pushReplacementScreen(
          context, ExamPracticeScreen(widget.examObject, _examObject));
    }
  }

  _handleResume() {
    if (_examObject == null) {
      Toast(appLocalized().something_wrong).show();
      return;
    }

    Map<int, ExamYourAnswer>? yourAnswerMap = widget.examState?.yourAnswerMap;
    var posQuestionResume = 0;
    var indexQuestion = 0;

    if (!yourAnswerMap.isNullOrEmpty) {
      final skills = _examObject?.skills;
      if (!skills.isNullOrEmpty) {
        for (final skill in skills!) {
          final parts = skill.parts;
          if (parts.isNullOrEmpty) continue;

          for (final part in parts!) {
            final questions = part.question;
            if (questions.isNullOrEmpty) continue;
            for (final question in questions!) {
              if (!yourAnswerMap!.containsKey(question.id)) {
                if (posQuestionResume == 0) posQuestionResume = indexQuestion;
                continue;
              }
              ExamYourAnswer? examYourAnswer = yourAnswerMap[question.id];
              if (examYourAnswer == null) continue;

              final contentList = question.content;
              if (contentList.isNullOrEmpty) continue;

              if (Utils.checkGridIns(question.kindId ?? "")) {
                final yourAnswerGridInsList =
                    examYourAnswer.yourAnswerGridInsList;
                if (yourAnswerGridInsList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerGridInsList!.length) {
                    contentList[i].yourAnswerGridIns = yourAnswerGridInsList[i];
                  }
                }
              } else {
                final yourAnswerList = examYourAnswer.yourAnswerList;
                if (yourAnswerList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerList!.length) {
                    contentList[i].yourAnswer = yourAnswerList[i];
                  }
                }
              }
              indexQuestion++;
            }
          }
        }
      }
    }

    final timeRemain = widget.examState?.timeRemain ?? 0;
    RouterNavigate.pushReplacementScreen(
        context,
        ExamScreen(widget.examObject, _examObject,
            timeRemain: timeRemain, posResume: posQuestionResume));
  }

  _handleResult() {
    final examObject = HiveHelper.getExam(widget.examObject?.id ?? 0);
    if (examObject == null) {
      Toast(appLocalized().something_wrong).show();
      return;
    }

    Map<int, ExamYourAnswer>? yourAnswerMap = widget.examState?.yourAnswerMap;

    if (!yourAnswerMap.isNullOrEmpty) {
      final skills = examObject.skills;
      if (!skills.isNullOrEmpty) {
        for (final skill in skills!) {
          final parts = skill.parts;
          if (parts.isNullOrEmpty) continue;

          for (final part in parts!) {
            final questions = part.question;
            if (questions.isNullOrEmpty) continue;
            for (final question in questions!) {
              if (!yourAnswerMap!.containsKey(question.id)) continue;

              ExamYourAnswer? examYourAnswer = yourAnswerMap[question.id];
              if (examYourAnswer == null) continue;

              final contentList = question.content;
              if (contentList.isNullOrEmpty) continue;

              if (Utils.checkGridIns(question.kindId ?? "")) {
                final yourAnswerGridInsList =
                    examYourAnswer.yourAnswerGridInsList;
                if (yourAnswerGridInsList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerGridInsList!.length) {
                    contentList[i].yourAnswerGridIns = yourAnswerGridInsList[i];
                  }
                }
              } else {
                final yourAnswerList = examYourAnswer.yourAnswerList;
                if (yourAnswerList.isNullOrEmpty) continue;

                for (var i = 0; i < contentList!.length; i++) {
                  if (i < yourAnswerList!.length) {
                    contentList[i].yourAnswer = yourAnswerList[i];
                  }
                }
              }
            }
          }
        }
      }
    }

    RouterNavigate.pushScreen(context,
        ExamResultScreen(widget.examObject, examObject, isHistory: true));
  }

  _loadExam() {
    final idExam = widget.examObject?.id ?? 0;
    if (idExam == 0) {
      Future.delayed(Duration.zero, () async {
        _showErrorPlaceholder();
      });
      return;
    }

    if (!isInternetAvailable) {
      Future.delayed(Duration.zero, () async {
        _showNoConnectPlaceholder();
      });
      return;
    }

    Future.delayed(Duration.zero, () async {
      setState(() {
        _isLoading = true;
      });
    });
    dioHelper.getExam(idExam).then((examObject) {
      if (!mounted) return;
      _isLoading = false;
      if (examObject == null) {
        _showErrorPlaceholder();
        return;
      }

      setState(() {
        _examObject = examObject;
      });
      HiveHelper.saveExam(idExam, examObject);
      eventHelper.push(EventHelper.onShowIntervalAds);
    });
  }

  _showErrorPlaceholder() {
    if (!mounted) return;
    final idExam = widget.examObject?.id ?? 0;
    if (idExam > 0) {
      final examObject = HiveHelper.getExam(idExam);
      if (examObject != null) {
        setState(() {
          _examObject = examObject;
        });
        return;
      }
    }

    setState(() {
      _placeHolder = appLocalized().loadingError;
    });
  }

  _showNoConnectPlaceholder() {
    if (!mounted) return;
    final idExam = widget.examObject?.id ?? 0;
    if (idExam > 0) {
      final examObject = HiveHelper.getExam(idExam);
      if (examObject != null) {
        setState(() {
          _examObject = examObject;
        });
        return;
      }
    }
    setState(() {
      _placeHolder = appLocalized().no_connect;
    });
  }
}
