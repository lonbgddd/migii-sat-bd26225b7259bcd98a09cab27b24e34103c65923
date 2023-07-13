import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';

// ignore: must_be_immutable
class OptionDisplayAnswerDialog extends BasePage {
  VoidCallback chooseListener;

  OptionDisplayAnswerDialog(this.chooseListener, {Key? key}) : super(key: key);

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, VoidCallback chooseListener) {
    showGeneralDialog(
        barrierLabel: "OptionDisplayAnswerDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 150),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center,
              child: OptionDisplayAnswerDialog(chooseListener));
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

class _State extends BasePageState<OptionDisplayAnswerDialog> {
  var isChoiceAnswerBottom = true;
  var didChoose = false;

  @override
  void initState() {
    super.initState();
    isChoiceAnswerBottom = preferenceHelper.isChoiceAnswerBottom;
  }

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
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.only(bottom: 8.0.dp()),
        color: ColorHelper.colorPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0.dp()),
                topRight: Radius.circular(12.0.dp()))),
        child: Container(
          width: double.infinity,
          padding:
              EdgeInsets.fromLTRB(16.0.dp(), 14.0.dp(), 16.0.dp(), 12.0.dp()),
          child: AutoSizeText(
            appLocalized().which_interface_choice,
            style: UIFont.fontAppBold(16.0.sp(), ColorHelper.colorTextNight),
            maxLines: 2,
            minFontSize: 8.0.sp(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      _answerBottomItem(isChoiceAnswerBottom, () {
        if (didChoose) return;
        didChoose = true;

        if (!isChoiceAnswerBottom) {
          setState(() {
            isChoiceAnswerBottom = true;
          });
          preferenceHelper.typeChoiceAnswer = 0;
          appProviderRead.isChoiceAnswerBottom =
              preferenceHelper.isChoiceAnswerBottom;
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
          widget.chooseListener();
        });
      }),
      _answerTopItem(!isChoiceAnswerBottom, () {
        if (didChoose) return;
        didChoose = true;

        if (isChoiceAnswerBottom) {
          setState(() {
            isChoiceAnswerBottom = false;
          });
          preferenceHelper.typeChoiceAnswer = 1;
          appProviderRead.isChoiceAnswerBottom =
              preferenceHelper.isChoiceAnswerBottom;
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
          widget.chooseListener();
        });
      }),
      SizedBox(height: 8.0.dp())
    ]);
  }

  Widget _answerBottomItem(bool isChoose, VoidCallback chooseListener) {
    return GestureDetector(
      onTap: () {
        chooseListener();
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp()),
            side: isChoose
                ? BorderSide(
                    color: theme(
                        ColorHelper.colorPrimary, ColorHelper.colorAccent),
                    width: 1.5.dp())
                : BorderSide.none),
        child: Container(
          width: double.infinity,
          color: isChoose
              ? theme(ColorHelper.colorPrimary, ColorHelper.colorAccent)
                  .withOpacity(0.15)
              : null,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            isChoose
                ? Padding(
                    padding:
                        EdgeInsets.fromLTRB(12.0.dp(), 14.0.dp(), 14.0.dp(), 0),
                    child: SvgPicture.asset("ic_checked".withIcon(),
                        width: 20.0.dp(), height: 20.0.dp()))
                : Container(
                    width: 20.0.dp(),
                    height: 20.0.dp(),
                    margin:
                        EdgeInsets.fromLTRB(12.0.dp(), 14.0.dp(), 12.0.dp(), 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9.0.dp()),
                        border: Border.all(
                            color: theme(
                                ColorHelper.colorGray, ColorHelper.colorGray2),
                            width: 2.0.dp())),
                  ),
            Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SizedBox(height: 12.0.dp()),
                  Text(
                    appLocalized().interface_choice_1,
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                  ),
                  SizedBox(height: 4.0.dp()),
                  Text(
                    appLocalized().comment_choice_1,
                    style: UIFont.fontApp(
                        14.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                  ),
                  Container(
                    width: double.infinity,
                    height: 44.0.dp(),
                    margin: EdgeInsets.only(top: 12.0.dp(), bottom: 14.0.dp()),
                    color: theme(ColorHelper.colorGray, ColorHelper.colorGray2)
                        .withOpacity(0.19),
                    child: Row(children: [
                      _answerItem("A"),
                      _answerItem("B"),
                      _answerItem("C"),
                      _answerItem("D"),
                    ]),
                  )
                ])),
            SizedBox(width: 12.0.dp())
          ]),
        ),
      ),
    );
  }

  Widget _answerItem(String text) {
    return Expanded(
        child: Padding(
      padding: EdgeInsets.only(top: 8.0.dp(), bottom: 8.0.dp()),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: theme(
                      ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                  width: 1.0.dp())),
          alignment: Alignment.center,
          child: Text(
            text,
            style: UIFont.fontApp(12.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          ),
        ),
      ),
    ));
  }

  Widget _answerTopItem(bool isChoose, VoidCallback chooseListener) {
    return GestureDetector(
      onTap: () {
        chooseListener();
      },
      child: Card(
        elevation: 4.0.dp(),
        margin: EdgeInsets.fromLTRB(16.0.dp(), 8.0.dp(), 16.0.dp(), 8.0.dp()),
        color: theme(ColorHelper.colorBackgroundChildDay,
            ColorHelper.colorBackgroundChildNight),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.dp()),
            side: isChoose
                ? BorderSide(
                    color: theme(
                        ColorHelper.colorPrimary, ColorHelper.colorAccent),
                    width: 1.5.dp())
                : BorderSide.none),
        child: Container(
          width: double.infinity,
          color: isChoose
              ? theme(ColorHelper.colorPrimary, ColorHelper.colorAccent)
                  .withOpacity(0.15)
              : null,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            isChoose
                ? Padding(
                    padding:
                        EdgeInsets.fromLTRB(12.0.dp(), 14.0.dp(), 14.0.dp(), 0),
                    child: SvgPicture.asset("ic_checked".withIcon(),
                        width: 20.0.dp(), height: 20.0.dp()))
                : Container(
                    width: 20.0.dp(),
                    height: 20.0.dp(),
                    margin:
                        EdgeInsets.fromLTRB(12.0.dp(), 14.0.dp(), 12.0.dp(), 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9.0.dp()),
                        border: Border.all(
                            color: theme(
                                ColorHelper.colorGray, ColorHelper.colorGray2),
                            width: 2.0.dp())),
                  ),
            Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  SizedBox(height: 12.0.dp()),
                  Text(
                    appLocalized().interface_choice_2,
                    style: UIFont.fontAppBold(
                        15.0.sp(),
                        theme(ColorHelper.colorTextDay,
                            ColorHelper.colorTextNight)),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 12.0.dp(), bottom: 16.0.dp()),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0.dp()),
                        color:
                            theme(ColorHelper.colorGray, ColorHelper.colorGray2)
                                .withOpacity(0.19)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                            12.0.dp(), 8.0.dp(), 12.0.dp(), 10.0.dp()),
                        decoration: BoxDecoration(
                            color: theme(const Color(0xFFBDA035),
                                const Color(0xFF45736C)),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0.dp()),
                                topRight: Radius.circular(8.0.dp()))),
                        child: Text(
                          "Question 2",
                          style: UIFont.fontAppBold(
                              14.0.sp(), ColorHelper.colorTextNight),
                        ),
                      ),
                      SizedBox(height: 4.0.dp()),
                      _answerItem2("A"),
                      _answerItem2("B"),
                      SizedBox(height: 6.0.dp()),
                    ]),
                  )
                ])),
            SizedBox(width: 12.0.dp())
          ]),
        ),
      ),
    );
  }

  Widget _answerItem2(String text) {
    return Row(children: [
      Container(
        width: 28.0.dp(),
        height: 28.0.dp(),
        margin: EdgeInsets.fromLTRB(12.0.dp(), 5.0.dp(), 8.0.dp(), 5.0.dp()),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0.dp()),
            border: Border.all(
                color:
                    theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight),
                width: 1.0.dp())),
        alignment: Alignment.center,
        child: Text(
          text,
          style: UIFont.fontApp(13.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 2.0.dp()),
        child: Text(
          "Answer $text",
          style: UIFont.fontApp(13.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
        ),
      )
    ]);
  }

}
