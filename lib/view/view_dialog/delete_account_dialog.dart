import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../view_custom/bounce_button.dart';

class DeleteAccountDialog extends BasePage {
  final VoidCallback deleteListener;

  const DeleteAccountDialog(this.deleteListener, {Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, VoidCallback deleteListener) {
    showGeneralDialog(
        barrierLabel: "DeleteAccountDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center,
              child: DeleteAccountDialog(deleteListener));
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(-1, 0), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<DeleteAccountDialog> {
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

  Column viewContainer() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.0.dp()),
          Row(children: [
            Padding(
                padding: EdgeInsets.only(left: 16.0.dp(), right: 12.0.dp()),
                child: SvgPicture.asset(
                  "ic_warning_2".withIcon(),
                  width: 28.0.dp(),
                  height: 28.0.dp(),
                )),
            Expanded(
                child: AutoSizeText(
              appLocalized().delete_account,
              style: UIFont.fontAppBold(16.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
              maxLines: 1,
              minFontSize: 12.0.sp(),
            ))
          ]),
          Padding(
            padding:
                EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 12.0.dp()),
            child: Text(
              appLocalized().delete_account_desc,
              style: UIFont.fontApp(15.0.sp(),
                  theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            BounceButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0.dp())),
                color: ColorHelper.colorRed,
                child: Container(
                    width: preferenceHelper.widthScreen / 5 - 10.0.dp(),
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(
                        6.0.dp(), 4.0.dp(), 6.0.dp(), 6.0.dp()),
                    child: Text(appLocalized().delete_account_button,
                        style: UIFont.fontAppBold(13.0.sp(), Colors.white))),
                onPress: () {
                  Navigator.pop(context);
                  widget.deleteListener();
                }),
            SizedBox(width: 12.0.dp()),
            BounceButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0.dp()),
                    side: BorderSide(
                        width: 1.0.dp(),
                        color: theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight))),
                color: theme(ColorHelper.colorBackgroundChildDay,
                    ColorHelper.colorBackgroundChildNight),
                child: Container(
                    width: preferenceHelper.widthScreen / 5 - 10,
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(
                        6.0.dp(), 4.0.dp(), 6.0.dp(), 6.0.dp()),
                    child: Text(appLocalized().cancel,
                        style: UIFont.fontAppBold(
                            13.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight)))),
                onPress: () {
                  Navigator.pop(context);
                }),
            SizedBox(width: 20.0.dp())
          ]),
          SizedBox(height: 16.0.dp())
        ]);
  }
}
