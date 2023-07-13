import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:migii_sat/model/home/training_section_json_object.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/global_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/screen_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../view/view_custom/latex_text.dart';
import 'dio/dio_helper.dart';
import 'language_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utils {
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case "vi":
        return "Tiếng Việt";
      case "en":
        return "English";
      case "es":
        return "Español";
      case "ko":
        return "한국어";
      case "cn":
        return "简体中文";
      case "tw":
        return "繁體中文";
    }
    return "";
  }

  static Future openLink(String link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    }
  }

  static Future openMessenger() async {
    final url = Uri.parse(GlobalHelper.urlMessenger);
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir = await getApplicationDocumentsDirectory();
    path = '${dir.path}/$uniqueFileName';
    return path;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double widthScreen(BuildContext context) {
    return isPortrait(context)
        ? preferenceHelper.widthScreen
        : preferenceHelper.heightScreen;
  }

  static double heightScreen(BuildContext context) {
    return isPortrait(context)
        ? preferenceHelper.heightScreen
        : preferenceHelper.widthScreen;
  }

  static bool isTablet() {
    return screenSize == ScreenSize.md ||
        screenSize == ScreenSize.lg ||
        screenSize == ScreenSize.xl;
  }

  static Future trackerScreen(String category) async {
    await FirebaseAnalytics.instance.setCurrentScreen(screenName: category);
  }

  static Future trackerEvent(String category, String action) async {
    await FirebaseAnalytics.instance.logEvent(
      name: category,
      parameters: {
        "event": action,
      },
    );
  }

  static Future trackBannerEvent(String action) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "AdsInHouse",
      parameters: {
        "event": action,
      },
    );
  }

  static trackAdsInHouseEvent(int idUser, int adGroupId, int adId, int bannerId,
      int click, String name) {
    dioHelper
        .postAdsInHouseAction(idUser, adGroupId, adId, bannerId, click, name)
        .then((messageObject) => null);
  }

  static loadJSONAsset(String fileName, Function(String data) assetCallback) {
    rootBundle
        .loadString("assets/json/$fileName")
        .then((value) => assetCallback(value));
  }

  static rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing();
    } else {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        inAppReview.openStoreListing(appStoreId: "6450196004");
      }
    }
  }

  static List<LatexItem> convertLatex(String text) {
    List<LatexItem> latexList = [];
    var textConvert = text;

    final matches =
        textConvert.matches("([^\\\\]|^)\\\$(.|\n|\r)*?[^\\\\]\\\$");
    // for (final match in matches) {
    //   Log.all("match: $match");
    // }
    if (matches.isNotEmpty) {
      List<String> matchesConvert = [];
      for (final match in matches) {
        matchesConvert.add(match.substring(match.indexOf("\$")));
      }

      for (final match in matchesConvert) {
        final indexOf = textConvert.indexOf(match);
        if (indexOf > 0) {
          latexList.add(LatexItem(textConvert.substring(0, indexOf)));
          textConvert = textConvert.substring(indexOf);
        }

        if (match.contains("\n") && !match.contains("{cases}")) {
          final matchSplit = match.substring(1, match.length - 1).split("\n");
          for (var i = 0; i < matchSplit.length; i++) {
            if (i > 0) latexList.add(LatexItem("\n\n"));
            latexList.add(LatexItem("\$${matchSplit[i]}\$", isLatex: true));
          }
        } else {
          if (match.contains("begin{cases}") && match.contains("end{cases}")) {
            final matchSub = match.substring(1, match.length - 1);

            final index1 = matchSub.indexOf("\\begin{cases}");
            latexList.add(LatexItem(matchSub.substring(0, index1)));

            final index2 = matchSub.indexOf("end{cases}");
            latexList.add(LatexItem(
                "\$${matchSub.substring(index1, index2 + 10)}\$",
                isLatex: true));

            latexList.add(LatexItem(matchSub.substring(index2 + 10)));
          } else {
            latexList.add(LatexItem(match, isLatex: true));
          }
        }

        textConvert = textConvert.substring(match.length);
      }
    }

    if (textConvert.isNotEmpty) {
      latexList.add(LatexItem(textConvert));
      textConvert = "";
    }

    return latexList;
  }

  static bool checkGridIns(String idKind) {
    return [
      "210001_1_1",
      "210002_1_1",
      "220001_1_1",
      "220002_1_1",
      "230001_1_1",
      "230002_1_1",
      "240001_1_1",
      "240001_2_1",
      "240001_3_1",
      "240001_4_1",
      "240001_5_1",
      "240001_6_1",
      "240001_7_1",
      "240002_1_1",
    ].contains(idKind);
  }

  static bool checkWritingReading(String idKind) {
    return [
      "110001",
      "110002",
      "110003",
      "120001",
      "120002",
      "120003",
      "130001",
      "130002",
      "140001",
      "140002",
    ].contains(idKind);
  }

  static TrainingSectionTheme? getTrainingItem(String idKind) {
    if (idKind.isNullOrEmpty) return null;
    final sections = sectionsList;
    if (sections.isNullOrEmpty) return null;

    for (final section in sections!) {
      final kinds = section.kinds;
      if (kinds.isNullOrEmpty) continue;

      for (final kindItem in kinds!) {
        final themes = kindItem.themes;
        if (themes.isNullOrEmpty) continue;

        for (final themeItem in themes!) {
          final idKindList = themeItem.idKindList;
          if (idKindList.isNullOrEmpty || !idKindList!.contains(idKind)) {
            continue;
          }
          return themeItem;
        }
      }
    }
    return null;
  }

  static String convertTimeHistory(int timeHistory, int timeCurrent) {
    AppLocalizations appLocalized =
        LanguageHelper(preferenceHelper.languageApp).localizations;

    if (timeHistory > timeCurrent) return appLocalized.just_now;

    // lấy thời gian 0h của ngày làm bài
    final time0hHistory =
        DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000)
            .copyWith(hour: 0, minute: 0, second: 0)
            .millisecondsSinceEpoch;

    // khoảng cách từ 0h ngày làm bài đến hiện tại
    final timeRangeDay = timeCurrent - time0hHistory;
    if (timeRangeDay < 86400) {
      // hôm nay
      // khoảng cách từ thời điểm làm bài đến hiện tại
      final timeRangeHistory = timeCurrent - timeHistory;
      if (timeRangeHistory < 60) {
        // dưới 1 phút
        return appLocalized.just_now;
      } else if (timeRangeHistory < 3600) {
        // dưới 1 giờ
        return (timeRangeHistory < 120
                ? appLocalized.minute_ago
                : appLocalized.minutes_ago)
            .format([timeRangeHistory ~/ 60]);
      } else {
        return (timeRangeHistory < 7200
                ? appLocalized.hour_ago
                : appLocalized.hours_ago)
            .format([timeRangeHistory ~/ 3600]);
      }
    } else if (timeRangeDay < 86400 * 2) {
      // hôm qua
      return appLocalized.yesterday_time.format([
        DateFormat("h:mm a")
            .format(DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000))
      ]);
    } else if (timeRangeDay < 86400 * 7) {
      // dưới 1 tuần
      return DateFormat("EEE, h:mm a")
          .format(DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000));
    } else {
      final yearHistory =
          DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000).year;
      final yearCurrent =
          DateTime.fromMillisecondsSinceEpoch(timeCurrent * 1000).year;
      if (yearHistory == yearCurrent) {
        return DateFormat(
                appLocalized.language_code == "vi" ? "d MMMM" : "MMM d")
            .format(DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000));
      }
      return DateFormat(appLocalized.language_code == "vi"
              ? "d MMMM yyyy"
              : "MMM d, yyyy")
          .format(DateTime.fromMillisecondsSinceEpoch(timeHistory * 1000));
    }
  }

  static bool checkGridInsCorrect(String yourAnswer, List<String> correctList) {
    if (yourAnswer.isEmpty || yourAnswer == "..." || correctList.isEmpty) {
      return false;
    }
    if (correctList.contains(yourAnswer)) return true;

    double yourAnswerValue = 0;
    if (yourAnswer.contains("/")) {
      final yourAnswerSplit = yourAnswer.split("/");
      if (yourAnswerSplit.length != 2) return false;
      double p1 = double.tryParse(yourAnswerSplit[0]) ?? 0;
      double p2 = double.tryParse(yourAnswerSplit[1]) ?? 0;
      if (p2 == 0) return false;
      yourAnswerValue = p1 / p2;
    } else {
      double p = double.tryParse(yourAnswer.replaceAll(",", ".")) ?? 0;
      yourAnswerValue = p;
    }

    for (final correct in correctList) {
      if (correct.trim() == yourAnswer) return true;

      double correctValue = 0;
      if (correct.contains("/")) {
        final correctSplit = correct.split("/");
        if (correctSplit.length != 2) continue;
        double p1 = double.tryParse(correctSplit[0]) ?? 0;
        double p2 = double.tryParse(correctSplit[1]) ?? 0;
        if (p2 == 0) continue;
        correctValue = p1 / p2;
      } else {
        double p = double.tryParse(correct) ?? 0;
        correctValue = p;
      }

      if ((yourAnswerValue * 100).round() == (correctValue * 100).round()) {
        return true;
      }
    }

    return false;
  }
}
