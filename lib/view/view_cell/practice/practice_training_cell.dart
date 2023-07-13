import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/practice/practice_themes_screen.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../main.dart';
import '../../../model/home/home_screen_item.dart';
import '../../../model/home/training_section_json_object.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../view_dialog/lock_dialog.dart';

// ignore: must_be_immutable
class PracticeTrainingCell extends BasePage {
  Function(String tab) selectTabListener;

  PracticeTrainingCell(this.selectTabListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<PracticeTrainingCell> {
  @override
  Widget build(BuildContext context) {
    if (sectionsList.isNullOrEmpty) {
      return const SizedBox(width: double.infinity, height: 0);
    }

    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    return Padding(
        padding: EdgeInsets.only(left: 10.0.dp(), right: 10.0.dp()),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final section in sectionsList!) ...{
            _trainingView(section, isPremium)
          }
        ]));
  }

  Widget _trainingView(TrainingSectionJSONObject sectionItem, bool isPremium) {
    final kinds = sectionItem.kinds;
    if (kinds.isNullOrEmpty) return const SizedBox(height: 0);
    return SizedBox(
      width: double.infinity,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(
                    10.0.dp(), 12.0.dp(), 10.0.dp(), 4.0.dp()),
                child: Text(
                  sectionItem.section ?? "",
                  style: UIFont.fontAppBold(
                      17.0.dp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                )),
            Wrap(spacing: 0, runSpacing: 0, children: [
              for (final kind in kinds!) ...[_trainingItem(kind, isPremium)]
            ])
          ]),
    );
  }

  Widget _trainingItem(TrainingSectionKind kindItem, bool isPremium) {
    final widthItem = (preferenceHelper.widthScreen - 20.0.dp()) / 4;
    final isLock = !isPremium && (kindItem.isPremium ?? false);

    var totalSubQues = 0;
    var totalDid = 0;
    final themeList = kindItem.themes;
    if (!themeList.isNullOrEmpty) {
      for (final themeItem in themeList!) {
        List<String>? idKindList = themeItem.idKindList;
        if (!idKindList.isNullOrEmpty) {
          totalSubQues += preferenceHelper.getTotalSubQuestion(idKindList!);
          for (final idKind in idKindList) {
            if (idKind.contains("_")) {
              totalDid +=
                  preferenceHelper.getIdQuestionsDid("${idKind}_0").length +
                      preferenceHelper.getIdQuestionsDid("${idKind}_1").length;
            } else {
              totalDid += preferenceHelper.getIdQuestionsDid(idKind).length;
            }
          }
        }
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () {
          if (isLock) {
            LockDialog.show(context, () {
              widget.selectTabListener(HomeScreenItem.routePremium);
            });
          } else {
            RouterNavigate.pushScreen(context, PracticeThemesScreen(kindItem));
          }
        },
        child: Card(
          elevation: 4.0.dp(),
          margin: EdgeInsets.all(6.0.dp()),
          color: theme(ColorHelper.colorBackgroundChildDay,
              ColorHelper.colorBackgroundChildNight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0.dp())),
          child: SizedBox(
            width: widthItem - 12.0.dp(),
            height: widthItem - 12.0.dp(),
            child: Column(children: [
              SizedBox(
                height: (widthItem - 12.0.dp()) / 6,
              ),
              SvgPicture.asset(
                (kindItem.icon ?? "").withIcon(),
                width: (widthItem - 12.0.dp()) / 2,
                height: (widthItem - 12.0.dp()) / 2,
              ),
              const Expanded(child: SizedBox()),
              if (isLock) ...[
                SvgPicture.asset(
                  "ic_lock".withIcon(),
                  width: (widthItem - 12.0.dp()) / 6,
                  color: theme(
                      ColorHelper.colorTextGreenDay, ColorHelper.colorAccent),
                ),
                SizedBox(height: 6.0.dp())
              ] else ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(8.0.dp(), 0, 8.0.dp(), 8.0.dp()),
                  child: LinearPercentIndicator(
                    percent: totalSubQues == 0 ? 0 : (totalDid / totalSubQues),
                    lineHeight: 4.0.dp(),
                    padding: EdgeInsets.zero,
                    backgroundColor: ColorHelper.colorPrimary.withOpacity(0.39),
                    progressColor: ColorHelper.colorAccent,
                    barRadius: Radius.circular(2.0.dp()),
                  ),
                )
              ]
            ]),
          ),
        ),
      ),
      Container(
        width: widthItem,
        padding: EdgeInsets.fromLTRB(2.0.dp(), 4.0.dp(), 2.0.dp(), 4.0.dp()),
        child: Text(
          kindItem.name ?? "",
          style: UIFont.fontApp(Utils.isTablet() ? 16.0.sp() : 13.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      )
    ]);
  }
}
