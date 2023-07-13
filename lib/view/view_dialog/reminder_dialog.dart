import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/local_notifications_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/ui_font.dart';
import '../base/base_stateful.dart';
import '../view_custom/bounce_button.dart';
import '../view_custom/toast.dart';

class ReminderDialog extends BasePage {
  const ReminderDialog({super.key});

  @override
  BasePageState<BasePage> createState() => _State();

  static show(BuildContext context) {
    showGeneralDialog(
        barrierLabel: "ReminderDialog",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return const Align(
              alignment: Alignment.center, child: ReminderDialog());
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
              position:
                  Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
                      .animate(anim1),
              child: child);
        });
  }
}

class _State extends BasePageState<ReminderDialog> {
  int hourReminder = 0;
  int minuteReminder = 0;
  bool reminderActivated = false;

  @override
  void initState() {
    super.initState();
    String timeReminder = preferenceHelper.timeReminder;
    if (timeReminder.isEmpty) {
      var dateTime = DateTime.now();
      hourReminder = dateTime.hour;
      minuteReminder = dateTime.minute;
    } else {
      if (timeReminder.contains(":")) {
        var times = timeReminder.split(":");
        if (times.length == 2) {
          hourReminder = int.tryParse(times[0]) ?? 0;
          minuteReminder = int.tryParse(times[1]) ?? 0;
        }
      }
    }
    reminderActivated = preferenceHelper.isReminderActive;
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
      Padding(
          padding: EdgeInsets.fromLTRB(20.0.dp(), 16.0.dp(), 20.0.dp(), 0),
          child: AutoSizeText(appLocalized().study_reminder,
              style: UIFont.fontAppBold(
                  18.0.sp(),
                  theme(ColorHelper.colorTextGreenDay,
                      ColorHelper.colorTextGreenNight)),
              maxLines: 1)),
      Padding(
        padding: EdgeInsets.fromLTRB(24.0.dp(), 8.0.dp(), 16.0.dp(), 0),
        child: Row(
          children: [
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 4.0.dp()),
                    child: Text(
                        "${hourReminder < 10 ? "0$hourReminder" : "$hourReminder"}:${minuteReminder < 10 ? "0$minuteReminder" : "$minuteReminder"}",
                        style: UIFont.fontApp(
                            22.0.sp(),
                            theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight))))),
            Switch(
                value: reminderActivated,
                activeColor: ColorHelper.colorBackgroundChildDay,
                onChanged: (bool value) {
                  setState(() {
                    reminderActivated = value;
                  });
                })
          ],
        ),
      ),
      Padding(
          padding: EdgeInsets.only(left: 32.0.dp(), right: 32.0.dp()),
          child: Divider(
              color:
                  theme(ColorHelper.colorTextDay2, ColorHelper.colorTextNight2),
              thickness: 1.0.dp(),
              height: 1.0.dp())),
      SizedBox(
          height: 200.0.dp(),
          child: Stack(children: [
            CupertinoTheme(
                data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                            color: theme(ColorHelper.colorTextDay,
                                ColorHelper.colorTextNight),
                            fontSize: 20.0.sp()))),
                child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime.now()
                        .copyWith(hour: hourReminder, minute: minuteReminder),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        hourReminder = newDateTime.hour;
                        minuteReminder = newDateTime.minute;
                      });
                    },
                    use24hFormat: true,
                    minuteInterval: 1)),
            if (!reminderActivated)
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: theme(ColorHelper.colorBackgroundChildDay,
                          ColorHelper.colorBackgroundChildNight)
                      .withOpacity(0.39))
          ])),
      FractionallySizedBox(
        widthFactor: 0.66,
        child: SizedBox(
          height: 44.0.dp(),
          child: BounceButton(
            color: ColorHelper.colorPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0.dp())),
            child: Center(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 2.0.dp()),
                    child: Text(appLocalized().save,
                        style: UIFont.fontAppBold(
                            15.0.sp(), ColorHelper.colorTextNight)))),
            onPress: () {
              _handleReminder(
                  reminderActivated, "$hourReminder:$minuteReminder");
            },
          ),
        ),
      ),
      SizedBox(height: 20.0.dp())
    ]);
  }

  _handleReminder(bool isActive, String timeString) {
    Toast(
            isActive
                ? appLocalized().turn_on_reminders
                : appLocalized().turn_off_reminders,
            alignment: Toast.center)
        .show();

    if (!preferenceHelper.isReminderActive && !isActive) {
      Navigator.pop(context);
      return;
    }
    preferenceHelper.isReminderActive = isActive;
    if (isActive) {
      preferenceHelper.timeReminder = timeString;
      localNotificationsHelper.handlePushNotifyStudy(
          appLocalized().content_notify, appLocalized().content_study_reminder);
    } else {
      localNotificationsHelper.removePushNotifyStudy();
    }
    Navigator.pop(context);
  }
}
