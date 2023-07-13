import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:migii_sat/model/exam/exam_list_json_object.dart';
import 'package:migii_sat/model/practice/number_question_json_object.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';

import '../../../model/country_json_object.dart';
import '../../../model/exam/exam_json_object.dart';
import '../../../model/practice/practice_json_object.dart';
import '../../../model/practice/practice_result_object.dart';
import '../../../model/time_server_json_object.dart';
import '../../../model/user/ads_in_house_json_object.dart';
import '../../../model/user/ads_in_house_message_json_object.dart';
import '../../../model/user/info_subscriptions_json_object.dart';
import '../../../model/user/user_profile_json_object.dart';
import '../global_helper.dart';

late DioHelper dioHelper;

class DioHelper {
  late Dio _dio;
  late CancelToken _cancelToken;

  DioHelper() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _cancelToken = CancelToken();
  }

  Future<String> getCountryCode() async {
    final response =
        await _dio.get("http://ip-api.com/json", cancelToken: _cancelToken);
    var object = CountryJSONObject.fromJson(response.data);
    return object.countryCode?.toLowerCase() ?? "";
  }

  Future<int> getTimeServer() async {
    try {
      final response = await _dio.get(GlobalHelper.urlGetTimeServer,
          cancelToken: _cancelToken);
      var object = TimeServerJSONObject.fromJson(response.data);
      return object.time ?? 0;
    } on DioException {
      return 0;
    } on TypeError {
      return 0;
    }
  }

  Future<AdsInHouseJSONObject?> getAdsInHouse(
      String countryCode, String languageApp) async {
    try {
      final response = await _dio.get(GlobalHelper.urlAdsInHouse,
          queryParameters: {
            'country': countryCode,
            'language': languageApp,
            'platform': Platform.isAndroid ? "android" : "ios",
            'project_id': 28
          },
          cancelToken: _cancelToken);
      return AdsInHouseJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<AdsInHouseMessageJSONObject?> postAdsInHouseAction(int idUser,
      int adGroupId, int adId, int bannerId, int click, String name) async {
    try {
      final response = await _dio.post(GlobalHelper.urlAdsInHouseAction,
          data: {
            'user_id': idUser,
            'ad_group_id': adGroupId,
            'ad_id': adId,
            'banner_id': bannerId,
            'click': click,
            'name': name,
            'platforms': Platform.isIOS ? "ios" : "android"
          },
          cancelToken: _cancelToken);
      return AdsInHouseMessageJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<UserProfileJSONObject?> postRegisterEmail(
      String name, String email, String password) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["name"] = name;
      params["email"] = email;
      params["password"] = password;
      params["language"] = preferenceHelper.languageApp;

      final response = await _dio.post(GlobalHelper.urlRegisterEmail,
          data: params, cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return UserProfileJSONObject(statusCode: 403);
      }
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<UserProfileJSONObject?> postLoginEmail(
      String email,
      String password,
      String idDevice,
      String device,
      String platforms,
      String platformsVersion,
      String appVersion) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["email"] = email;
      params["password"] = password;
      params["device_id"] = idDevice;
      params["device"] = device;
      params["platforms"] = platforms;
      params["platforms_version"] = platformsVersion;
      params["app_version"] = appVersion;

      final response = await _dio.post(GlobalHelper.urlSignInEmail,
          data: params, cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return UserProfileJSONObject(statusCode: 401);
      }
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<UserProfileJSONObject?> postLoginGoogle(
      String idToken,
      String idDevice,
      String device,
      String platforms,
      String platformsVersion,
      String appVersion) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["id_token"] = idToken;
      params["device_id"] = idDevice;
      params["language"] = preferenceHelper.languageApp;
      params["device"] = device;
      params["platforms"] = platforms;
      params["platforms_version"] = platformsVersion;
      params["app_version"] = appVersion;

      final response = await _dio.post(GlobalHelper.urlSignInGoogle,
          data: params, cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<UserProfileJSONObject?> postLoginApple(
      String accessToken,
      String name,
      String idDevice,
      String device,
      String platforms,
      String platformsVersion,
      String appVersion) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["access_token"] = accessToken;
      params["device_id"] = idDevice;
      params["language"] = preferenceHelper.languageApp;
      params["name"] = name;
      params["device"] = device;
      params["platforms"] = platforms;
      params["platforms_version"] = platformsVersion;
      params["app_version"] = appVersion;

      final response = await _dio.post(GlobalHelper.urlSignInApple,
          data: params, cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<bool> postLogOut(String idDevice, String token) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["device_id"] = idDevice;

      final response = await _dio.post(GlobalHelper.urlLogOut,
          data: params,
          options: Options(headers: {"Authorization": token}),
          cancelToken: _cancelToken);
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return true;
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<bool> postDeleteAccount(String token) async {
    try {
      final response = await _dio.delete(GlobalHelper.urlDeleteAccount,
          options: Options(headers: {"Authorization": token}),
          cancelToken: _cancelToken);
      return response.statusCode == 200;
    } on DioException {
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<UserProfileJSONObject?> getProfileUser() async {
    try {
      final response = await _dio.get(GlobalHelper.urlGetProfile,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<ExamListJSONObject?> getListExams() async {
    try {
      final response = await _dio.get(GlobalHelper.urlListExam,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return ExamListJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<ExamJSONObject?> getExam(int id) async {
    try {
      final response = await _dio.get("${GlobalHelper.urlExam}$id",
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return ExamJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<NumberQuestionJSONObject?> getNumberQuestion() async {
    try {
      final response = await _dio.get(GlobalHelper.urlCountQuestionInKind,
          cancelToken: _cancelToken);
      return NumberQuestionJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<PracticeJSONObject?> getQuestionsPractice(
      List<String> idKindList, int limit, String deviceId) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["kind"] = idKindList;

      final response = await _dio.post(
          "${GlobalHelper.urlPracticeQuestion}?limit=$limit&device_id=$deviceId",
          data: params,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return PracticeJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<PracticeJSONObject?> getToSaveQuestion(
      List<dynamic> idKindList) async {
    try {
      Map<String, dynamic> params = <String, dynamic>{};
      params["kind"] = idKindList;

      final response = await _dio.post(
          "${GlobalHelper.urlPracticeQuestion}?type=all",
          data: params,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return PracticeJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<bool> postReportQuestion(String content, String idQuestion) async {
    Map<String, dynamic> params = <String, dynamic>{};
    params["content"] = content;

    try {
      final response = await _dio.post(
          "${GlobalHelper.urlReportQuestion}/$idQuestion",
          data: params,
          cancelToken: _cancelToken);
      return response.statusCode == 201;
    } on DioException {
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<bool> postResultPractice(
      PracticeResultObject practiceResultObject) async {
    Map<String, dynamic> params = <String, dynamic>{};
    params["items"] = practiceResultObject.items;
    params["device_id"] = practiceResultObject.deviceId;

    try {
      final response = await _dio.post(GlobalHelper.urlPracticeHistory,
          data: params,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return response.statusCode == 201;
    } on DioException {
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<int> getInfoPurchased(
      String productID, String receiptString, int transactionDate) async {
    Map<String, dynamic> params = <String, dynamic>{};
    if (Platform.isAndroid) {
      params["subscriptionId"] = productID;
      params["token"] = receiptString;
    } else if (Platform.isIOS) {
      params["receipt"] = receiptString;
      if (kDebugMode) params["type"] = "sandbox";
    }

    try {
      final response = await _dio.post(
          Platform.isAndroid
              ? GlobalHelper.urlInfoSubscriptionsGoogle
              : GlobalHelper.urlInfoSubscriptionsApple,
          data: params,
          cancelToken: _cancelToken);
      final inforObject = InfoSubscriptionsJSONObject.fromJson(response.data);
      return (inforObject.timeExpired ?? 0) ~/ 1000;
    } on DioException {
      return 0;
    } on TypeError {
      return 0;
    }
  }

  Future<UserProfileJSONObject?> syncPremiumAccount(
      String productID, String receiptString) async {
    Map<String, dynamic> params = <String, dynamic>{};
    if (Platform.isAndroid) {
      params["subscriptionId"] = productID;
      params["token"] = receiptString;
    } else if (Platform.isIOS) {
      params["receipt"] = receiptString;
      if (kDebugMode) params["type"] = "sandbox";
    }

    try {
      final response = await _dio.post(
          Platform.isAndroid
              ? GlobalHelper.urlVerifiedGoogleStore
              : GlobalHelper.urlVerifiedAppleStore,
          data: params,
          options: Options(headers: {
            "Authorization": preferenceHelper.userProfile?.token ?? ""
          }),
          cancelToken: _cancelToken);
      return UserProfileJSONObject.fromJson(response.data);
    } on DioException {
      return null;
    } on TypeError {
      return null;
    }
  }

  close() {
    _cancelToken.cancel();
    _dio.close();
  }
}
