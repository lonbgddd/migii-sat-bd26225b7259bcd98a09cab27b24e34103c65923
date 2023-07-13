import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../base/base_stateful.dart';
import '../view_custom/bounce_button.dart';

// ignore: must_be_immutable
class NewVersionDialog extends BasePage {
  String newVersion;
  Function(bool isUpdate) updateListener;

  NewVersionDialog(this.newVersion, this.updateListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(
      BuildContext context, String newVersion, Function(bool isUpdate) updateListener) {
    showGeneralDialog(
        barrierLabel: "NewVersionDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 250),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center,
              child: NewVersionDialog(newVersion, updateListener));
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<NewVersionDialog> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.8,
        child: Card(
            elevation: 4.0.dp(),
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0.dp())),
            child: viewContainer()));
  }

  Widget viewContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0.dp()),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 12.0.dp()),
        Image.asset(
          "img_character_update".withImage(),
          width: preferenceHelper.screenWidthMinimum / 3,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.0.dp(), 8.0.dp(), 8.0.dp(), 0),
          child: AutoSizeText(
            appLocalized().version_upgrade.format([widget.newVersion]),
            style: UIFont.fontAppBold(17.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8.0.dp(), 8.0.dp(), 8.0.dp(), 16.0.dp()),
          child: Text(
            appLocalized().upgrade_content,
            style: UIFont.fontApp(14.0.sp(),
                theme(ColorHelper.colorTextDay2, ColorHelper.colorTextNight2)),
            textAlign: TextAlign.center,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 2 / 3,
          child: BounceButton(
            color: ColorHelper.colorPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0.dp())),
            child: Container(
              height: 44.0.dp(),
              padding: EdgeInsets.fromLTRB(12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
              alignment: Alignment.center,
              child: AutoSizeText(
                appLocalized().do_it_now,
                style:
                    UIFont.fontAppBold(15.0.sp(), ColorHelper.colorTextNight),
                maxLines: 1,
              ),
            ),
            onPress: () {
              Navigator.pop(context);
              widget.updateListener(true);
            },
          ),
        ),
        SizedBox(height: 12.0.sp()),
        FractionallySizedBox(
          widthFactor: 2 / 3,
          child: BounceButton(
            color: theme(ColorHelper.colorBackgroundChildDay,
                ColorHelper.colorBackgroundChildNight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0.dp()),
                side: BorderSide(
                    width: 2.0.dp(), color: ColorHelper.colorPrimary)),
            child: Container(
              height: 44.0.dp(),
              padding: EdgeInsets.fromLTRB(12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
              alignment: Alignment.center,
              child: AutoSizeText(
                appLocalized().ignore,
                style: UIFont.fontAppBold(15.0.sp(), ColorHelper.colorPrimary),
                maxLines: 1,
              ),
            ),
            onPress: () {
              Navigator.pop(context);
              widget.updateListener(false);
            },
          ),
        ),
        SizedBox(height: 20.0.dp())
      ]),
    );
  }
}
