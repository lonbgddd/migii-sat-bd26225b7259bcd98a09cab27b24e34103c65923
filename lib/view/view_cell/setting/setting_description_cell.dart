import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/view_tab/home/setting_tab_view.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/base_view.dart';

class SettingDescriptionCell extends BaseView {
  final SettingType _type;
  final Function(SettingType type)? _itemMoreClickListener;

  SettingDescriptionCell(
      super.context, this._type, this._itemMoreClickListener);

  Widget init() {
    String icon = "";
    String title = "";
    String desc = "";
    var isUnderline = false;

    switch (_type) {
      case SettingType.languageDevice:
        icon = "ic_language";
        title = appLocalized().language_app;
        desc = Utils.getLanguageName(appLocalized().language_code);
        isUnderline = true;
        break;
      case SettingType.version:
        icon = "ic_version";
        title = appLocalized().version;
        desc = "v ${preferenceHelper.versionApp}";
        isUnderline = false;
        break;
      default:
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: () {
              if (_itemMoreClickListener != null) {
                _itemMoreClickListener!(_type);
              }
            },
            child: Container(
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
                  Text(desc,
                      style: UIFont.fontAppBold(
                          14.0.sp(), ColorHelper.colorAccent,
                          decoration:
                              isUnderline ? TextDecoration.underline : null)),
                  SizedBox(width: 16.0.dp())
                ]))),
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
