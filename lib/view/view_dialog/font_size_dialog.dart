import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../../viewmodel/helper/ui_font.dart';

// ignore: must_be_immutable
class FontSizeDialog extends BasePage {
  int fontSize;
  Function(int number) chooseListener;

  FontSizeDialog(this.fontSize, this.chooseListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(
      BuildContext context, int fontSize, Function(int number) chooseListener) {
    showGeneralDialog(
        barrierLabel: "FontSizeDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 200),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.bottomCenter,
              child: FontSizeDialog(fontSize, chooseListener));
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

class _State extends BasePageState<FontSizeDialog> {
  final List<String> listItem = [];
  var fontSize = 1;

  @override
  void initState() {
    super.initState();
    for (var index = 10; index <= 30; index++) {
      listItem.add("$index");
    }
    fontSize = widget.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.0.dp()),
                topRight: Radius.circular(22.0.dp()))),
        child: viewContainer());
  }

  Column viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: double.infinity,
        height: preferenceHelper.appBarHeight,
        color: theme(ColorHelper.colorPrimary, ColorHelper.colorAccent)
            .withOpacity(0.1),
        child: Row(children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                child: AutoSizeText(
                  appLocalized().exit,
                  style: UIFont.fontAppBold(14.0.sp(), ColorHelper.colorRed,
                      decoration: TextDecoration.underline),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          ),
          Flexible(
              flex: 3,
              child: Center(
                child: AutoSizeText(
                  appLocalized().choose_font_size,
                  style: UIFont.fontAppBold(
                      16.0.sp(),
                      theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              )),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.chooseListener(fontSize);
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 8.0.dp(), right: 8.0.dp()),
                child: AutoSizeText(
                  appLocalized().choose,
                  style: UIFont.fontAppBold(
                      14.0.sp(),
                      theme(ColorHelper.colorTextGreenDay,
                          ColorHelper.colorTextGreenNight),
                      decoration: TextDecoration.underline),
                  maxLines: 1,
                  minFontSize: 8.0.sp(),
                ),
              ),
            ),
          )
        ]),
      ),
      Container(
        width: double.infinity,
        height: 200.0.dp(),
        margin: EdgeInsets.fromLTRB(
            12.0.dp(), 0, 12.0.dp(), paddingBottom + 20.0.dp()),
        child: CupertinoPicker(
          itemExtent: 36,
          scrollController:
              FixedExtentScrollController(initialItem: fontSize - 10),
          children: [
            for (final item in listItem) ...{
              Padding(
                padding: EdgeInsets.only(top: 6.0.dp()),
                child: Text(
                  item,
                  style: TextStyle(
                      color: theme(ColorHelper.colorTextDay,
                          ColorHelper.colorTextNight)),
                ),
              )
            }
          ],
          onSelectedItemChanged: (int value) {
            fontSize = int.tryParse(listItem[value]) ?? 1;
          },
        ),
      )
    ]);
  }
}
