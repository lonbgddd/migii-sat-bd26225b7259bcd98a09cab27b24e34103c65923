import 'dart:io';

import 'package:flutter/foundation.dart';

class GlobalHelper {
  static const urlTerms = "https://eupgroup.net/apps/migiisat/terms.html";
  static const emailSupport = "migiisat@eupgroup.net";
  static const urlMessenger = "https://www.facebook.com/MigiiSAT";

  static const urlAdsInHouse =
      "https://product.eupgroup.net/resapi/ads/adsInhouse";
  static const urlAdsInHouseAction =
      "https://product.eupgroup.net/resapi/ads/adsInhouseAction";

  static const baseUrl = "https://sat.migii.net/api/";
  static const urlListExam = "${baseUrl}question/exam";
  static const urlExam = "${baseUrl}question/exam/";

  static const urlGetTimeServer = "${baseUrl}server/time-server";
  static const urlCountQuestionInKind =
      "${baseUrl}question/count-question-detail";
  static const urlPracticeQuestion = "${baseUrl}question/practice";
  static const urlReportQuestion = "${baseUrl}question/report";
  static const urlPracticeHistory = "${baseUrl}question/history";

  static const urlSignInEmail = "${baseUrl}user/login";
  static const urlSignInGoogle = "${baseUrl}user/loginWithGmail";
  static const urlSignInApple = "${baseUrl}user/loginWithApple";
  static const urlRegisterEmail = "${baseUrl}user/register";
  static const urlLogOut = "${baseUrl}user/logout";
  static const urlDeleteAccount = "${baseUrl}user/delete-user";
  static const urlGetProfile = "${baseUrl}user/profile";

  static const urlInfoSubscriptionsGoogle =
      "${baseUrl}premium/getInfoSubscriptionsGoogle";
  static const urlInfoSubscriptionsApple =
      "${baseUrl}premium/getInfoSubscriptionsApple";
  static const urlVerifiedGoogleStore = "${baseUrl}premium/verifiedGoogleStore";
  static const urlVerifiedAppleStore = "${baseUrl}premium/verifiedAppleStore";

  static const dataBox = "data_box";
  static const keyExamList = "exam_list";
  static const keyHistoryPractice = "history_practice";
  static const idHistoryPractice = "practice_history_";
  static const idQuestion = "question_";
  static const keyExam = "exam_";
  static const keyExamState = "exam_state_";
  static const keyHistoryExam = "history_exam";
  static const idHistoryExam = "exam_history_";

  static const sku12Months = "migii_sat_12months";
  static const sku12MonthsSale = "migii_sat_12months_";
  static const sku6Months = "migii_sat_6months";
  static const sku6MonthsSale = "migii_sat_6months_";
  static const sku3Months = "migii_sat_3months";
  static const sku3MonthsSale = "migii_sat_3months_";
  static const sku1Months = "migii_sat_1months";
  static const sku7Days = "migii_sat_7days";
  static const sku5Days = "migii_sat_5days";
  static const sku3Days = "migii_sat_3days";
  static const skuCustom = "migii_sat_custom";

  static const defaultAdsPress = 3600;
  static const defaultIntervalAdsInter = 300;
  static final defaultIdBanner = Platform.isAndroid
      ? (kDebugMode
          ? "ca-app-pub-3940256099942544/6300978111"
          : "ca-app-pub-8268370626959195/1132331574")
      : (kDebugMode
          ? "ca-app-pub-3940256099942544/2934735716"
          : "ca-app-pub-8268370626959195/2063066027");
  static final defaultIdInter = Platform.isAndroid
      ? (kDebugMode
          ? "ca-app-pub-3940256099942544/1033173712"
          : "ca-app-pub-8268370626959195/9481594884")
      : (kDebugMode
          ? "ca-app-pub-3940256099942544/4411468910"
          : "ca-app-pub-8268370626959195/8412055793");

  static const List<String> googleScopes = <String>['email'];
}
