import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:provider/provider.dart';

import '../../model/exam/exam_history_result_object.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/hive_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../base/base_stateful.dart';
import '../view_custom/dashed_line_vertical_painter.dart';

// ignore: must_be_immutable
class HistoryExamDialog extends BasePage {
  Function(ExamHistoryResultObject historyItem) handleResultExam;

  HistoryExamDialog(this.handleResultExam, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context,
      Function(ExamHistoryResultObject historyItem) handleResultExam) {
    showGeneralDialog(
        barrierLabel: "HistoryExamDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: HistoryExamDialog(handleResultExam));
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 0.5), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<HistoryExamDialog> {
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        color: theme(
            ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.0.dp()),
                topRight: Radius.circular(22.0.dp()))),
        child: viewContainer());
  }

  Widget viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);

    int timeServer =
        Provider.of<AppProvider>(context, listen: false).timeServer;

    List<ExamHistoryResultObject>? historyList =
        HiveHelper.getHistoryExamList();

    return SizedBox(
      width: double.infinity,
      height: Utils.heightScreen(context) * 3 / 4,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.zero,
          color: ColorHelper.colorPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22.0.dp()),
                  topRight: Radius.circular(22.0.dp()))),
          child: SizedBox(
            width: double.infinity,
            height: preferenceHelper.appBarHeight,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    appLocalized().history_exam,
                    style: UIFont.fontAppBold(
                        17.0.sp(), ColorHelper.colorTextNight),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: double.infinity,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              "ic_close_2".withIcon(),
                              width: 22.0.dp(),
                              height: 22.0.dp(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              key: const PageStorageKey("HistoryExamDialog"),
              padding: EdgeInsets.only(
                  top: 6.0.dp(), bottom: paddingBottom + 20.0.dp()),
              itemCount: historyList?.length ?? 0,
              itemBuilder: (context, index) {
                return _historyItemView(historyList![index], timeServer);
              },
              shrinkWrap: true),
        )
      ]),
    );
  }

  Widget _historyItemView(ExamHistoryResultObject historyItem, int timeServer) {
    var examTitle = "";
    final name = historyItem.name?.toLowerCase().replaceAll("test", "").trim();
    if (!name.isNullOrEmpty) {
      final number = int.tryParse(name!) ?? -1;
      if (number > -1) {
        examTitle = appLocalized().test_number.format([number]);
      }
    }

    if (examTitle.isEmpty) examTitle = historyItem.name ?? "";

    int score = historyItem.score ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.handleResultExam(historyItem);
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 6.0.dp(), 16.0.dp(), 6.0.dp()),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp())),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        child: Row(children: [
          Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0.dp(), bottom: 12.0.dp()),
                child: Column(
                  children: [
                    Text(
                      examTitle,
                      style: UIFont.fontAppBold(
                          14.0.sp(),
                          theme(ColorHelper.colorTextDay,
                              ColorHelper.colorTextNight)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.0.dp()),
                    Text(
                      Utils.convertTimeHistory(
                          historyItem.time ?? 0, timeServer),
                      style: UIFont.fontApp(
                          12.0.sp(),
                          theme(ColorHelper.colorTextDay2,
                              ColorHelper.colorTextNight2)),
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 48.0.dp(),
            child: DashedLineVerticalPainter(
              width: 1.5.dp(),
              dashHeight: 4.0.dp(),
              color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Text(
              "$score / 1600",
              style: UIFont.fontAppBold(
                  15.0.sp(),
                  score > 1200
                      ? ColorHelper.colorPrimary
                      : (score > 800
                          ? ColorHelper.colorPrimary
                          : ColorHelper.colorRed)),
              textAlign: TextAlign.center,
            ),
          )
        ]),
      ),
    );
  }
}
