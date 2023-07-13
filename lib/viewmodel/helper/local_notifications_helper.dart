import 'dart:io';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

late LocalNotificationsHelper localNotificationsHelper;

class LocalNotificationsHelper {
  final studyId = 1;

  LocalNotificationsHelper() {
    _configureLocalTimeZone();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  Future<void> setupLocalNotifications() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    /// A notification action which triggers a A pp navigation event
    const String navigationActionId = 'id_3';

    /// Defines a iOS/MacOS notification category for text input actions.
    const String darwinNotificationCategoryText = 'textCategory';

    /// Defines a iOS/MacOS notification category for plain actions.
    const String darwinNotificationCategoryPlain = 'plainCategory';

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {});
  }

  Future<bool> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      return granted;
    }
    return false;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      bool isAndroidGranted = await isAndroidPermissionGranted();
      if (isAndroidGranted) {
        return true;
      }
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      return granted ?? false;
    }
    return false;
  }

  Future<void> handlePushNotifyStudy(String title, String body) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        studyId,
        title,
        body,
        _notifyStudyInstance(),
        const NotificationDetails(
          android: AndroidNotificationDetails('study', 'notification_study',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _notifyStudyInstance() {
    String dateString = preferenceHelper.timeReminder;
    var hour = 0;
    var minute = 0;
    if (dateString.contains(":")) {
      var times = dateString.split(":");
      if (times.length == 2) {
        hour = int.tryParse(times[0]) ?? 0;
        minute = int.tryParse(times[1]) ?? 0;
      }
    }

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> removePushNotifyStudy() async {
    flutterLocalNotificationsPlugin.cancel(studyId);
  }

  Future<void> _configureLocalTimeZone() async {
    if (Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class FlutterTimezone {
  static const MethodChannel _channel = MethodChannel('flutter_timezone');

  ///
  /// Returns local timezone from the native layer.
  ///
  static Future<String> getLocalTimezone() async {
    final String? localTimezone =
        await _channel.invokeMethod("getLocalTimezone");
    if (localTimezone == null) {
      throw ArgumentError("Invalid return from platform getLocalTimezone()");
    }
    return localTimezone;
  }

  ///
  /// Gets the list of available timezones from the native layer.
  ///
  static Future<List<String>> getAvailableTimezones() async {
    final List<String>? availableTimezones =
        await _channel.invokeListMethod<String>("getAvailableTimezones");
    if (availableTimezones == null) {
      throw ArgumentError(
          "Invalid return from platform getAvailableTimezones()");
    }
    return availableTimezones;
  }
}
