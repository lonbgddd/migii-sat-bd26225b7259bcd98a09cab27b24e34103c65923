import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/main.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_custom/highlight_text.dart';
import 'package:migii_sat/view/view_dialog/lock_dialog.dart';
import 'package:migii_sat/view/view_dialog/request_login_dialog.dart';
import 'package:migii_sat/view/view_screen/exam/exam_prepare_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:migii_sat/viewmodel/helper/hive_helper.dart';
import 'package:provider/provider.dart';

import '../../../model/exam/exam_list_json_object.dart';
import '../../../model/home/home_screen_item.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_dialog/user_premium_dialog.dart';

// ignore: must_be_immutable
class ExamTabView extends BasePage {
  Function(String tab) selectTabListener;

  ExamTabView(this.selectTabListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<ExamTabView> {
  var isLoading = false;
  var stateError = 0;

  @override
  void initState() {
    super.initState();
    _loadListExam();
    eventHelper.listen((name) {
      switch (name) {
        case EventHelper.onUpdateExam:
          setState(() {});
          break;
      }
    });
    Utils.trackerScreen("HomeScreen - Exam");
  }

  @override
  Widget build(BuildContext context) {
    return viewContainer();
  }

  Widget viewContainer() {
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme(
          ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
      child: Column(children: [
        Container(
            width: double.infinity,
            height: preferenceHelper.appBarHeight +
                preferenceHelper.paddingInsetsTop,
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            decoration: BoxDecoration(
                color: ColorHelper.colorPrimary,
                boxShadow: kElevationToShadow[3]),
            child: Stack(children: [
              if (isPremium)
                GestureDetector(
                  onTap: () {
                    UserPremiumDialog.show(context);
                  },
                  child: Container(
                    width: preferenceHelper.appBarHeight,
                    height: double.infinity,
                    color: Colors.transparent,
                    padding: EdgeInsets.all(
                        preferenceHelper.appBarHeight / 2 - 11.0.dp()),
                    child: SvgPicture.asset(
                      "ic_premium_select".withIcon(),
                      color: Colors.white,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  appLocalized().exam,
                  style:
                      UIFont.fontAppBold(18.0.sp(), ColorHelper.colorTextNight),
                ),
              )
            ])),
        if (isLoading) ...{
          Expanded(
            child: Center(
              child: SizedBox(
                  width: 44.0.dp(),
                  height: 44.0.dp(),
                  child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: [
                        theme(ColorHelper.colorPrimary, ColorHelper.colorAccent)
                      ])),
            ),
          )
        } else if (stateError > 0) ...{
          Expanded(
              child: GestureDetector(
            onTap: () {
              _loadListExam();
            },
            child: Container(
              color: Colors.transparent,
              child: Column(children: [
                SizedBox(height: 24.0.dp()),
                Expanded(
                    child: FractionallySizedBox(
                        widthFactor: 0.66,
                        child: Image.asset(
                          "img_error".withImage(),
                          fit: BoxFit.contain,
                        ))),
                SizedBox(height: 24.0.dp()),
                FractionallySizedBox(
                  widthFactor: 0.83,
                  child: AutoSizeText(
                    appLocalized().whoops,
                    style: UIFont.fontAppBold(
                        18.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    maxLines: 1,
                    minFontSize: 8.0.sp(),
                  ),
                ),
                SizedBox(height: 12.0.dp()),
                FractionallySizedBox(
                  widthFactor: 0.83,
                  child: AutoSizeText(
                    "${stateError == 1 ? appLocalized().something_wrong : appLocalized().no_internet}\n${appLocalized().touch_reload}",
                    style: UIFont.fontApp(
                        14.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                    maxLines: 2,
                    minFontSize: 8.0.sp(),
                  ),
                ),
                SizedBox(height: 28.0.dp())
              ]),
            ),
          ))
        } else ...{
          Expanded(child: _examListView(isPremium))
        }
      ]),
    );
  }

  Widget _examListView(bool isPremium) {
    final examList =
        context.select((AppProvider provider) => provider.examList);

    return ListView.builder(
        key: const PageStorageKey("ExamTabView"),
        padding: EdgeInsets.only(top: 6.0.dp(), bottom: 24.0.dp()),
        itemCount: examList?.length ?? 0,
        itemBuilder: (context, index) {
          return Builder(builder: (context) {
            final item = examList![index];
            final isLock = !isPremium && (item.premium == 1);
            return _examCell(item, isLock);
          });
        },
        shrinkWrap: true);
  }

  Widget _examCell(ExamListQuestion examObject, bool isLock) {
    var examTitle = "";
    final name = examObject.name?.toLowerCase().replaceAll("test", "").trim();
    if (!name.isNullOrEmpty) {
      final number = int.tryParse(name!) ?? 0;
      if (number > 0) {
        examTitle = appLocalized().test_number.format([number]);
      }
    }

    if (examTitle.isEmpty) examTitle = examObject.name ?? "";

    final examState = HiveHelper.getStateExam(examObject.id ?? 0);

    return GestureDetector(
      onTap: () {
        if (preferenceHelper.statusSignIn == 0) {
          RequestLoginDialog.show(context);
          return;
        }

        if (isLock) {
          LockDialog.show(context, () {
            widget.selectTabListener(HomeScreenItem.routePremium);
          });
          return;
        }

        RouterNavigate.pushScreen(
            context, ExamPrepareScreen(examObject, examState));
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 6.0.dp()),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp())),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Padding(
                padding:
                    EdgeInsets.fromLTRB(16.0.dp(), 12.0.dp(), 16.0.dp(), 0),
                child: Text(
                  examTitle,
                  style: UIFont.fontAppBold(
                      17.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                ),
              )),
              if (isLock) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 2.0.dp(), right: 16.0.dp()),
                  child: SvgPicture.asset(
                    "ic_lock".withIcon(),
                    width: 18.0.dp(),
                    height: 18.0.dp(),
                    color: theme(ColorHelper.colorTextGreenDay,
                        ColorHelper.colorTextGreenNight),
                  ),
                )
              ]
            ]),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0.dp(), 4.0.dp(), 16.0.dp(), 0),
              child: HighlightText(
                text: "${appLocalized().exam_time.format([
                      134
                    ])} | ${appLocalized().exam_number_question.format([98])}",
                style: UIFont.fontApp(
                    14.0.sp(),
                    theme(ColorHelper.colorTextGreenDay,
                        ColorHelper.colorTextGreenNight)),
                spanList: [
                  SpanItem(text: appLocalized().exam_time_key),
                  SpanItem(text: appLocalized().exam_number_question_key)
                ],
                spanStyle: UIFont.fontAppBold(
                    14.0.sp(),
                    theme(ColorHelper.colorTextGreenDay,
                        ColorHelper.colorTextGreenNight)),
              ),
            ),
            SizedBox(height: 12.0.dp()),
            Row(
              children: [
                if (isLock)
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 16.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        appLocalized().start,
                        style: UIFont.fontAppBold(
                            14.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  )
                else if (examState == null)
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 16.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: ColorHelper.colorPrimary,
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        appLocalized().start,
                        style: UIFont.fontAppBold(
                            14.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  )
                else if ((examState.timeRemain ?? 0) > 0) ...[
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 16.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: ColorHelper.colorAccent,
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        appLocalized().exam_doing,
                        style: UIFont.fontAppBold(
                            13.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 12.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: ColorHelper.colorPrimary,
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        appLocalized().exam_continue,
                        style: UIFont.fontAppBold(
                            13.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  )
                ] else ...[
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 16.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: (examState.score ?? 0) > 1200
                        ? ColorHelper.colorPrimary
                        : ((examState.score ?? 0) > 800
                            ? ColorHelper.colorPrimary
                            : ColorHelper.colorRed),
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        "${examState.score} / 1600",
                        style: UIFont.fontAppBold(
                            13.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4.0.dp(),
                    margin: EdgeInsets.only(left: 12.0.dp()),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0.dp())),
                    color: ColorHelper.colorPrimary,
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 20.0.dp(), right: 20.0.dp()),
                      height: 28.0.dp(),
                      alignment: Alignment.center,
                      child: Text(
                        appLocalized().do_it_again,
                        style: UIFont.fontAppBold(
                            13.0.sp(), ColorHelper.colorTextNight),
                      ),
                    ),
                  )
                ]
              ],
            ),
            SizedBox(height: 12.0.dp()),
          ],
        ),
      ),
    );
  }

  _loadListExam() {
    if (!appProviderRead.examList.isNullOrEmpty) return;

    String examListJSON = HiveHelper.getData(GlobalHelper.keyExamList) ?? "";

    if (examListJSON.isEmpty) {
      setState(() {
        stateError = 0;
        isLoading = true;
      });
      dioHelper.getListExams().then((examListObject) {
        if (!mounted) return;
        if (examListObject == null) {
          setState(() {
            isLoading = false;
            stateError = isInternetAvailable ? 1 : 2;
          });
          return;
        }

        final examList = examListObject.exams;
        if (examList.isNullOrEmpty) {
          setState(() {
            isLoading = false;
            stateError = 1;
          });
          return;
        }

        HiveHelper.putData(
            GlobalHelper.keyExamList, jsonEncode(examListObject));

        setState(() {
          isLoading = false;
        });
        appProviderRead.examList = examList;
      });
    } else {
      ExamListJSONObject? examListObject;
      try {
        Map object = jsonDecode(examListJSON);
        examListObject = ExamListJSONObject.fromJson(object.cast());
      } on FormatException {
        examListObject = null;
      }

      if (examListObject?.exams == null) {
        HiveHelper.putData(GlobalHelper.keyExamList, "")
            .then((value) => _loadListExam());
        return;
      }

      Future.delayed(Duration.zero, () async {
        appProviderRead.examList = examListObject?.exams;
      });

      dioHelper.getListExams().then((examListObject) {
        if (!mounted) return;
        if (examListObject == null) return;

        final examList = examListObject.exams;
        if (examList.isNullOrEmpty) return;

        HiveHelper.putData(
            GlobalHelper.keyExamList, jsonEncode(examListObject));
        appProviderRead.examList = examList;
      });
    }
  }
}
