import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/local_notifications_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../base/base_stateful.dart';
import '../../view_custom/bounce_button.dart';
import '../../view_custom/toast.dart';

// ignore: must_be_immutable
class OnBoardingReminderSetupView extends BasePage {
  AnimationController animationEnter;
  AnimationController animationExit;
  final Function(int pos) handleNext;

  OnBoardingReminderSetupView(
      this.handleNext, this.animationEnter, this.animationExit,
      {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<OnBoardingReminderSetupView> {
  int hourReminder = 0;
  int minuteReminder = 0;
  bool reminderActivated = false;

  @override
  void initState() {
    super.initState();
    var dateTime = DateTime.now();
    hourReminder = dateTime.hour;
    minuteReminder = dateTime.minute;
    _checkGrant();
  }

  @override
  Widget build(BuildContext context) {
    ConstraintId ivPhone = ConstraintId('ivPhone');
    ConstraintId lblNote = ConstraintId('lblNote');
    ConstraintId btnSave = ConstraintId('btnSave');
    ConstraintId btnSkip = ConstraintId('btnSkip');
    ConstraintId viewTime = ConstraintId('viewTime');
    ConstraintId lblTitle = ConstraintId('lblTitle');
    ConstraintId lblDesc = ConstraintId('lblDesc');
    ConstraintId viewNotify = ConstraintId('viewNotify');
    ConstraintId iconNotify = ConstraintId('iconNotify');

    widget.animationExit.forward();
    widget.animationEnter.forward();
    return Material(
        child: Container(
            color: ColorHelper.colorBackgroundDay,
            child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(widget.animationEnter),
                child: FadeTransition(
                    opacity: widget.animationExit,
                    child: ConstraintLayout(children: [
                      AutoSizeText(appLocalized().time_best_for_you,
                              style: UIFont.fontAppBold(
                                  17.0.sp(), ColorHelper.colorTextDay),
                              textAlign: TextAlign.center,
                              minFontSize: 8.0.sp(),
                              maxLines: 1)
                          .applyConstraint(
                              id: lblTitle,
                              width: matchParent,
                              top: parent.top,
                              margin: EdgeInsets.fromLTRB(
                                  16.0.dp(),
                                  preferenceHelper.paddingInsetsTop + 20.0.dp(),
                                  16.0.dp(),
                                  0)),
                      AutoSizeText(appLocalized().time_best_for_you_des,
                              style: UIFont.fontApp(
                                  15.0.sp(), ColorHelper.colorTextDay),
                              textAlign: TextAlign.center,
                              maxLines: 2)
                          .applyConstraint(
                              id: lblDesc,
                              width: matchParent,
                              top: lblTitle.bottom,
                              margin: EdgeInsets.fromLTRB(
                                  16.0.dp(), 8.0.dp(), 16.0.dp(), 0)),
                      if (Utils.isPortrait(context)) ...[
                        Image.asset(
                          "img_onboard_reminder_phone".withImage(),
                          fit: BoxFit.fill,
                        ).applyConstraint(
                            id: ivPhone,
                            top: lblDesc.bottom,
                            bottom: viewTime.top,
                            width: matchConstraint,
                            height: matchConstraint,
                            widthPercent: 0.5,
                            centerHorizontalTo: parent,
                            margin: EdgeInsets.only(
                                top: preferenceHelper.screenWidthMinimum / 7,
                                bottom:
                                    -preferenceHelper.screenWidthMinimum / 7)),
                        Card(
                                margin: EdgeInsets.zero,
                                elevation: 4,
                                shape:
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0.dp())),
                                color: ColorHelper.colorBackgroundChildDay,
                                child: Row(children: [
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(16.0.dp(),
                                          12.0.dp(), 12.0.dp(), 12.0.dp()),
                                      child: Image.asset(
                                          "img_logo_migii_character_small"
                                              .withImage(),
                                          width: 40.0.dp(),
                                          height: 40.0.dp())),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(2.0.dp(),
                                              6.0.dp(), 16.0.dp(), 8.0.dp()),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText("Migii SAT",
                                                    style: UIFont.fontAppBold(
                                                        15.0.sp(),
                                                        ColorHelper
                                                            .colorTextDay),
                                                    maxLines: 1),
                                                SizedBox(height: 2.0.dp()),
                                                AutoSizeText(
                                                    appLocalized()
                                                        .content_notify,
                                                    style: UIFont.fontApp(
                                                        13.0.sp(),
                                                        ColorHelper
                                                            .colorTextDay),
                                                    maxLines: 1)
                                              ])))
                                ]))
                            .applyConstraint(
                                id: viewNotify,
                                width: matchConstraint,
                                widthPercent: 0.8,
                                centerHorizontalTo: parent,
                                centerVerticalTo: ivPhone,
                                verticalBias: 0.25),
                        Container(
                          decoration: const BoxDecoration(
                              color: ColorHelper.colorPrimary,
                              shape: BoxShape.circle),
                        ).applyConstraint(
                            id: iconNotify,
                            top: viewNotify.top,
                            right: viewNotify.right,
                            width: 16.0.dp(),
                            height: 16.0.dp(),
                            margin: EdgeInsets.only(
                                top: -8.0.dp(),
                                right: preferenceHelper.widthScreen / 15)),
                      ],
                      Card(
                              elevation: 4.0.dp(),
                              color: ColorHelper.colorBackgroundChildDay,
                              shape:
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0.dp())),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            24.0.dp(), 8.0.dp(), 16.0.dp(), 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4.0.dp()),
                                                    child: Text(
                                                        "${hourReminder < 10 ? "0$hourReminder" : "$hourReminder"}:${minuteReminder < 10 ? "0$minuteReminder" : "$minuteReminder"}",
                                                        style: UIFont.fontAppBold(
                                                            22.0.sp(),
                                                            ColorHelper
                                                                .colorTextDay)))),
                                            Switch(
                                                value: reminderActivated,
                                                activeColor:
                                                    ColorHelper.colorPrimary,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    reminderActivated = value;
                                                  });
                                                  if (reminderActivated) {
                                                    _checkGrant();
                                                  }
                                                })
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 32.0.dp(), right: 32.0.dp()),
                                        child: Divider(
                                            color: ColorHelper.colorTextDay,
                                            thickness: 1.0.dp(),
                                            height: 1.0.dp())),
                                    SizedBox(
                                        height: 200.0.dp(),
                                        child: Stack(children: [
                                          CupertinoTheme(
                                              data: CupertinoThemeData(
                                                  textTheme: CupertinoTextThemeData(
                                                      dateTimePickerTextStyle:
                                                          TextStyle(
                                                              color: ColorHelper
                                                                  .colorTextDay,
                                                              fontSize:
                                                                  20.0.sp()))),
                                              child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode
                                                      .time,
                                                  initialDateTime:
                                                      DateTime.now(),
                                                  onDateTimeChanged:
                                                      (DateTime newDateTime) {
                                                    setState(() {
                                                      hourReminder =
                                                          newDateTime.hour;
                                                      minuteReminder =
                                                          newDateTime.minute;
                                                    });
                                                  },
                                                  use24hFormat: true,
                                                  minuteInterval: 1)),
                                          if (!reminderActivated)
                                            Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                color: ColorHelper
                                                    .colorBackgroundChildDay
                                                    .withOpacity(0.3))
                                        ])),
                                  ]))
                          .applyConstraint(
                              id: viewTime,
                              bottom: btnSave.top,
                              width: matchConstraint,
                              widthPercent: 0.75,
                              centerHorizontalTo: parent,
                              margin: EdgeInsets.only(bottom: 16.0.dp())),
                      BounceButton(
                        color: ColorHelper.colorPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0.dp())),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 2.0.dp()),
                            child: Text(
                              appLocalized().save,
                              style: UIFont.fontAppBold(
                                  15.0.sp(), ColorHelper.colorTextNight),
                            ),
                          ),
                        ),
                        onPress: () {
                          _handleReminder(reminderActivated,
                              "$hourReminder:$minuteReminder");
                        },
                      ).applyConstraint(
                          id: btnSave,
                          bottom: lblNote.top,
                          width: matchConstraint,
                          widthPercent: 0.66,
                          centerHorizontalTo: parent,
                          height: 44.0.dp(),
                          margin: EdgeInsets.only(bottom: 12.0.dp())),
                      AutoSizeText(appLocalized().des_save_time,
                              style: UIFont.fontApp(
                                  14.0.sp(), ColorHelper.colorTextDay),
                              textAlign: TextAlign.center,
                              maxLines: 1)
                          .applyConstraint(
                              id: lblNote,
                              bottom: btnSkip.top,
                              width: matchConstraint,
                              widthPercent: 0.85,
                              centerHorizontalTo: parent,
                              margin: EdgeInsets.fromLTRB(
                                  16.0.dp(), 0, 16.0.dp(), 4.0.dp())),
                      GestureDetector(
                        onTap: () {
                          handleNext(() {
                            widget.handleNext(3);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Text(
                            appLocalized().skip,
                            style: UIFont.fontAppBold(
                                15.0.sp(), ColorHelper.colorTextDay,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ).applyConstraint(
                          id: btnSkip,
                          bottom: parent.bottom,
                          width: matchConstraint,
                          widthPercent: 0.66,
                          centerHorizontalTo: parent,
                          height: 44.0.dp(),
                          margin: EdgeInsets.only(
                              bottom: preferenceHelper.paddingInsetsBottom +
                                  12.0.dp()))
                    ])))));
  }

  _handleReminder(bool isActive, String timeString) {
    preferenceHelper.isReminderActive = isActive;
    if (isActive) {
      preferenceHelper.timeReminder = timeString;
      localNotificationsHelper.handlePushNotifyStudy(
          appLocalized().content_notify, appLocalized().content_study_reminder);
      Toast(appLocalized().turn_on_reminders, alignment: Toast.center).show();
    }
    handleNext(() {
      widget.handleNext(3);
    });
  }

  _checkGrant() {
    localNotificationsHelper.requestPermissions().then((bool didAllow) {
      if (!didAllow) {
        setState(() {
          reminderActivated = false;
        });
        Toast(appLocalized().grant_notify, alignment: Toast.center).show();
      } else {
        setState(() {
          reminderActivated = true;
        });
      }
    });
  }

  Future handleNext(Function completion) async {
    await widget.animationExit.reverse();
    await widget.animationEnter.reverse();
    completion();
  }
}
