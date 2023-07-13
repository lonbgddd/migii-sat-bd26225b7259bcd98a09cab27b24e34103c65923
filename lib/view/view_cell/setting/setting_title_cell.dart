import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/view_tab/home/setting_tab_view.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../view_custom/base_view.dart';

class SettingTitleCell extends BaseView {
  final SettingType _type;
  final Function(SettingType type)? _itemMoreClickListener;

  SettingTitleCell(super.context, this._type, this._itemMoreClickListener);

  Widget init() {
    String icon = "";
    String title = "";
    var isFilter = true;

    switch (_type) {
      case SettingType.share:
        icon = "ic_share";
        title = appLocalized().share_app;
        break;
      case SettingType.downloadManage:
        icon = "ic_download_manage";
        title = appLocalized().download_manage;
        break;
      case SettingType.reminder:
        icon = "ic_alarm_clock";
        title = appLocalized().remind_study;
        break;
      case SettingType.feedback:
        icon = "ic_feedback";
        title = appLocalized().feedback;
        break;
      case SettingType.rate:
        icon = "ic_rate";
        title = appLocalized().rate_app;
        break;
      case SettingType.policy:
        icon = "ic_policy";
        title = appLocalized().policy;
        break;
      case SettingType.removeAccount:
        icon = "ic_remove_account";
        title = appLocalized().delete_account;
        break;
      case SettingType.updateApp:
        icon = "ic_upgrade";
        title = appLocalized().update_app;
        isFilter = false;
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
                    color: isFilter ? ColorHelper.colorPrimary : null,
                  ),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              20.0.dp(), 14.0.dp(), 20.0.dp(), 16.0.dp()),
                          child: Text(title,
                              style: UIFont.fontAppBold(
                                  15.0.sp(),
                                  theme(ColorHelper.colorTextDay,
                                      ColorHelper.colorTextNight)))))
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
