// ignore: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';

import '../../viewmodel/helper/color_helper.dart';
import '../base/base_stateful.dart';

// ignore: must_be_immutable
class PaymentResultDialog extends BasePage {
  int result;

  PaymentResultDialog(this.result, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context, int result) {
    showGeneralDialog(
        barrierLabel: "PaymentResultDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 250),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Align(
              alignment: Alignment.center, child: PaymentResultDialog(result));
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

class _State extends BasePageState<PaymentResultDialog> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.8,
        child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0.dp())),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0.dp()),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF4363A3), Color(0xFF3258A3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: viewContainer(),
              ),
            )));
  }

  Widget viewContainer() {
    var imgPayment = "";
    var titlePayment = "";
    var descPayment = "";
    Color colorButton;
    switch (widget.result) {
      case 0:
        imgPayment = "img_payment_fail";
        titlePayment = appLocalized().payment_fail;
        descPayment = appLocalized().payment_fail_content;
        colorButton = const Color(0xFFF0626E);
        break;
      case 1:
        imgPayment = "img_payment_success";
        titlePayment = appLocalized().payment_success;
        descPayment = appLocalized().payment_success_content;
        colorButton = ColorHelper.colorPrimary;
        break;
      case 3:
        imgPayment = "img_payment_restore";
        titlePayment = appLocalized().payment_restore_success;
        descPayment = appLocalized().payment_success_content;
        colorButton = ColorHelper.colorPrimary;
        break;
      default:
        imgPayment = "img_payment_restore_fail";
        titlePayment = appLocalized().payment_restore_fail;
        descPayment = appLocalized().payment_fail_content;
        colorButton = const Color(0xFFF0626E);
        break;
    }

    return Stack(alignment: Alignment.topCenter, children: [
      Transform.translate(
        offset: Offset(0, -preferenceHelper.screenWidthMinimum / 7),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            width: preferenceHelper.screenWidthMinimum * 0.8,
            decoration: const BoxDecoration(
                color: Color(0xFF3262AC), shape: BoxShape.circle),
          ),
        ),
      ),
      Transform.translate(
        offset: Offset(0, -preferenceHelper.screenWidthMinimum / 11),
        child: Container(
          width: preferenceHelper.screenWidthMinimum * 0.6,
          height: preferenceHelper.screenWidthMinimum * 0.6,
          decoration: const BoxDecoration(
              color: Color(0xFF3573BC), shape: BoxShape.circle),
        ),
      ),
      Transform.translate(
        offset: Offset(0, -preferenceHelper.screenWidthMinimum / 24),
        child: SvgPicture.asset(imgPayment.withImage(type: "svg"),
            width: preferenceHelper.screenWidthMinimum / 2,
            height: preferenceHelper.screenWidthMinimum / 2,
            fit: BoxFit.contain),
      ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
            padding: EdgeInsets.fromLTRB(12.0.dp(),
                preferenceHelper.screenWidthMinimum * 5 / 12, 12.0.dp(), 0),
            child: AutoSizeText(
              titlePayment,
              style: UIFont.fontAppBold(17.0.sp(), ColorHelper.colorTextNight),
              textAlign: TextAlign.center,
              minFontSize: 8.0.sp(),
            )),
        Padding(
            padding:
                EdgeInsets.fromLTRB(12.0.dp(), 12.0.dp(), 12.0.dp(), 20.0.dp()),
            child: AutoSizeText(
              descPayment,
              style: UIFont.fontApp(14.0.sp(), ColorHelper.colorTextNight),
              textAlign: TextAlign.center,
              minFontSize: 8.0.sp(),
            )),
        FractionallySizedBox(
          widthFactor: 0.5,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Card(
              elevation: 4.0.dp(),
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0.dp())),
              color: colorButton,
              child: Container(
                height: 40.0.dp(),
                padding: EdgeInsets.only(bottom: 2.0.dp()),
                alignment: Alignment.center,
                child: Text(appLocalized().close,
                    style: UIFont.fontAppBold(14.0.sp(), ColorHelper.colorTextNight)),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.0.dp())
      ])
    ]);
  }
}
