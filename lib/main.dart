import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:migii_sat/view/view_screen/application.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/local_notifications_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/provider/app_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'model/home/training_section_json_object.dart';
import 'viewmodel/helper/fcm_helper.dart';
import 'viewmodel/helper/global_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  localNotificationsHelper = LocalNotificationsHelper();
  localNotificationsHelper.setupLocalNotifications();

  await Hive.initFlutter();
  await Hive.openBox(GlobalHelper.dataBox);

  runApp(ChangeNotifierProvider(
      create: (_) => AppProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PreferenceHelper.getInstance(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            preferenceHelper = snapshot.data;
            return viewContainer();
          }
          return Container(color: ColorHelper.colorPrimary);
        });
  }

  Widget viewContainer() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        isInternetAvailable =
            (await InternetConnectionChecker().hasConnection) ||
                kDebugMode; // log_test
      } else {
        isInternetAvailable = false || kDebugMode;
      }
    });

    _initFCM();

    if (preferenceHelper.checkFirstOpenApp) {
      Locale deviceLocale = window.locale; // or html.window.locale
      String languageDevice = deviceLocale.languageCode;

      var code = "en";
      if (languageDevice.contains("vi")) {
        code = "vi";
      } else if (languageDevice.contains("es")) {
        code = "es";
      } else if (languageDevice.contains("ko")) {
        code = "ko";
      } else if (languageDevice.contains("zh")) {
        String scriptCode = deviceLocale.scriptCode ?? "";
        if (scriptCode.toLowerCase().contains("hant")) {
          code = "tw";
        } else if (scriptCode.toLowerCase().contains("hans")) {
          code = "cn";
        }
      }
      preferenceHelper.languageApp = code;
      preferenceHelper.checkFirstOpenApp = false;
    }

    // preferenceHelper.numberOpenApp = preferenceHelper.numberOpenApp + 1;

    return const Application();
  }

  _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}

var isInternetAvailable = true;
List<TrainingSectionJSONObject>? sectionsList;
