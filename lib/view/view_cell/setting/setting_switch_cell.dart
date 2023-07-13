import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:migii_sat/view/view_tab/home/setting_tab_view.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../view_custom/base_view.dart';

class SettingSwitchCell extends BaseView {
  final SettingType _type;

  SettingSwitchCell(super.context, this._type);

  Widget init(bool isChecked, Function(bool isChecked) switchListener) {
    String icon = "";
    String title = "";
    if (_type == SettingType.themeApp) {
      icon = "ic_night_mode";
      title = appLocalized().dark_mode;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            color: Colors.transparent,
            child: Row(children: [
              SizedBox(width: 22.0.dp()),
              SvgPicture.asset(
                icon.withIcon(),
                width: 20.0.dp(),
                height: 20.0.dp(),
                color: ColorHelper.colorPrimary,
              ),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20.0.dp(), 14.0.dp(), 20.0.dp(), 16.0.dp()),
                      child: Text(title,
                          style: UIFont.fontAppBold(
                              15.0.sp(),
                              theme(ColorHelper.colorTextDay,
                                  ColorHelper.colorTextNight))))),
              Container(
                  height: 36.0.dp(),
                  padding: EdgeInsets.only(right: 16.0.dp(), bottom: 2.0.dp()),
                  child: Switch(
                      value: isChecked,
                      activeColor: ColorHelper.colorAccent,
                      onChanged: (bool value) {
                        switchListener(value);
                      }))
            ])),
        Container(
          width: double.infinity,
          height: 0.7.dp(),
          margin: EdgeInsets.only(left: 62.0.dp()),
          color: theme(ColorHelper.colorGray, ColorHelper.colorGray2),
        )
      ],
    );
  }
}
