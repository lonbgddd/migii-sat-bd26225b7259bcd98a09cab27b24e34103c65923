import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/model/home/home_screen_item.dart';
import 'package:migii_sat/view/view_custom/base_view.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';

class PracticePreparationCell extends BaseView {
  Function(String tab) selectTabListener;

  PracticePreparationCell(super.context, this.selectTabListener);

  Widget init() {
    return SizedBox(
      width: double.infinity,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(
                    20.0.dp(), 12.0.dp(), 20.0.dp(), 4.0.dp()),
                child: Text(
                  appLocalized().exam_preparation,
                  style: UIFont.fontAppBold(
                      17.0.dp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0.dp(), 0, 10.0.dp(), 8.0.dp()),
              child: Wrap(spacing: 0, runSpacing: 0, children: [
                _preparationView("exam"),
                _preparationView("premium"),
                _preparationView("setting"),
              ]),
            )
          ]),
    );
  }

  Widget _preparationView(String type) {
    final widthItem = (preferenceHelper.widthScreen - 20.0.dp()) / 4;

    String icon = "";
    String name = "";
    switch (type) {
      case "exam":
        icon = "ic_exam";
        name = appLocalized().trial_exam;
        break;
      case "premium":
        icon = "ic_premium";
        name = appLocalized().upgrade;
        break;
      case "setting":
        icon = "ic_settings";
        name = appLocalized().setting;
        break;
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: () {
          _handleClick(type);
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
            child: Stack(alignment: Alignment.center, children: [
              Container(
                width: (widthItem - 12.0.dp()) / 2.2,
                height: (widthItem - 12.0.dp()) / 2.2,
                decoration: BoxDecoration(
                    color: ColorHelper.colorPrimary.withOpacity(0.1),
                    shape: BoxShape.circle),
                margin: EdgeInsets.only(
                    left: (widthItem - 12.0.dp()) / 4,
                    bottom: (widthItem - 12.0.dp()) / 2.5),
              ),
              SvgPicture.asset(
                icon.withIcon(),
                width: (widthItem - 12.0.dp()) / 2.2,
                height: (widthItem - 12.0.dp()) / 2.2,
              )
            ]),
          ),
        ),
      ),
      Container(
        width: widthItem,
        padding: EdgeInsets.fromLTRB(2.0.dp(), 4.0.dp(), 2.0.dp(), 4.0.dp()),
        child: Text(
          name,
          style: UIFont.fontApp(Utils.isTablet() ? 16.0.sp() : 13.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          textAlign: TextAlign.center,
        ),
      )
    ]);
  }

  _handleClick(String type) {
    switch (type) {
      case "exam":
        selectTabListener(HomeScreenItem.routeExam);
        break;
      case "premium":
        selectTabListener(HomeScreenItem.routePremium);
        break;
      case "setting":
        selectTabListener(HomeScreenItem.routeSetting);
        break;
    }
  }
}
