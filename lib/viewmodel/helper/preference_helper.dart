import 'dart:convert';
import 'dart:math';

import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/practice/number_question_json_object.dart';
import '../../model/practice/practice_result_object.dart';
import '../../model/user/ads_in_house_json_object.dart';
import '../../model/user/user_profile_json_object.dart';

late PreferenceHelper preferenceHelper;

class PreferenceHelper {
  SharedPreferences? _prefs;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    return;
  }

  static Future<PreferenceHelper> getInstance() async {
    var preferences = PreferenceHelper();
    preferences._prefs = await SharedPreferences.getInstance();
    return preferences;
  }

// ----------------------- firstOpenApp
  final _firstOpenApp = "first_open_app";

  bool get checkFirstOpenApp {
    return _prefs?.getBool(_firstOpenApp) ?? true;
  }

  set checkFirstOpenApp(bool value) {
    _prefs?.setBool(_firstOpenApp, value);
  }

  // ----------------------- appBarHeight
  final _appBarHeight = "app_bar_height";

  get appBarHeight {
    return _prefs?.getDouble(_appBarHeight) ?? 0;
  }

  set appBarHeight(height) {
    _prefs?.setDouble(_appBarHeight, height);
  }

  // ----------------------- paddingInsetsBottom
  final _paddingInsetsBottom = "padding_insets_bottom";

  get paddingInsetsBottom {
    return _prefs?.getDouble(_paddingInsetsBottom) ?? 0;
  }

  set paddingInsetsBottom(value) {
    _prefs?.setDouble(_paddingInsetsBottom, value);
  }

  // ----------------------- paddingInsetsTop
  final _paddingInsetsTop = "padding_insets_top";

  get paddingInsetsTop {
    return _prefs?.getDouble(_paddingInsetsTop) ?? 0;
  }

  set paddingInsetsTop(value) {
    _prefs?.setDouble(_paddingInsetsTop, value);
  }

  // ----------------------- widthScreen
  final _widthScreen = "width_screen_2";

  get widthScreen {
    return _prefs?.getDouble(_widthScreen) ?? 0;
  }

  set widthScreen(value) {
    _prefs?.setDouble(_widthScreen, value);
  }

  // ----------------------- heightScreen
  final _heightScreen = "height_screen_2";

  get heightScreen {
    return _prefs?.getDouble(_heightScreen) ?? 0;
  }

  set heightScreen(value) {
    _prefs?.setDouble(_heightScreen, value);
  }

  // ----------------------- screenWidthMinimum
  get screenWidthMinimum {
    if (!Utils.isTablet()) return widthScreen;
    return min<double>(widthScreen, heightScreen / 2);
  }

  // ----------------------- versionApp
  final _versionApp = "version_app";

  get versionApp {
    return _prefs?.getString(_versionApp) ?? "";
  }

  set versionApp(value) {
    _prefs?.setString(_versionApp, value);
  }

  // ----------------------- languageApp
  final _languageApp = "language_app";

  get languageApp {
    return _prefs?.getString(_languageApp) ?? "en";
  }

  set languageApp(value) {
    _prefs?.setString(_languageApp, value);
  }

  // ----------------------- isNightMode
  final _nightMode = "night_mode";

  bool get isNightMode {
    return _prefs?.getBool(_nightMode) ?? false;
  }

  set isNightMode(value) {
    _prefs?.setBool(_nightMode, value);
  }

  // ----------------------- countryCode
  final _countryCode = "country_code";

  String get countryCode {
    return _prefs?.getString(_countryCode) ?? "en";
  }

  set countryCode(value) {
    _prefs?.setString(_countryCode, value);
  }

  // ----------------------- isReminderActive
  final _reminderActive = "reminder_active";

  get isReminderActive {
    return _prefs?.getBool(_reminderActive) ?? false;
  }

  set isReminderActive(value) {
    _prefs?.setBool(_reminderActive, value);
  }

  // ----------------------- timeReminder
  final _timeReminder = "time_reminder";

  String get timeReminder {
    return _prefs?.getString(_timeReminder) ?? "";
  }

  set timeReminder(String value) {
    _prefs?.setString(_timeReminder, value);
  }

  // ----------------------- openOnBoarding
  final _openOnBoarding = "open_on_boarding";

  get didOpenOnBoarding {
    return _prefs?.getBool(_openOnBoarding) ?? false;
  }

  set didOpenOnBoarding(value) {
    _prefs?.setBool(_openOnBoarding, value);
  }

  // ----------------------- setupLanguage
  final _setupLanguage = "setup_language";

  get isChooseLanguageFirst {
    return _prefs?.getBool(_setupLanguage) ?? false;
  }

  set isChooseLanguageFirst(value) {
    _prefs?.setBool(_setupLanguage, value);
  }

  // ----------------------- timeServer
  final _timeServer = "time_server";

  int get timeServer {
    return _prefs?.getInt(_timeServer) ?? 0;
  }

  set timeServer(int value) {
    _prefs?.setInt(_timeServer, value);
  }

  // ----------------------- idDevice
  final _idDevice = "id_device";

  String get idDevice {
    return _prefs?.getString(_idDevice) ?? "";
  }

  set idDevice(String value) {
    _prefs?.setString(_idDevice, value);
  }

  // ----------------------- checkAddedIdDevice
  final _addedIdDevice = "added_id_device";

  bool get checkAddedIdDevice {
    return _prefs?.getBool(_addedIdDevice) ?? false;
  }

  set checkAddedIdDevice(bool value) {
    _prefs?.setBool(_addedIdDevice, value);
  }

  // ----------------------- checkRemoveIdDevice
  final _removeIdDevice = "remove_id_device";

  bool get checkRemoveIdDevice {
    return _prefs?.getBool(_removeIdDevice) ?? false;
  }

  set checkRemoveIdDevice(bool value) {
    _prefs?.setBool(_removeIdDevice, value);
  }

  // ----------------------- idUserRemoveIdDevice
  final _idRemoveIdDevice = "id_remove_id_device";

  int get idUserRemoveIdDevice {
    return _prefs?.getInt(_idRemoveIdDevice) ?? 0;
  }

  set idUserRemoveIdDevice(int value) {
    _prefs?.setInt(_idRemoveIdDevice, value);
  }

  // ----------------------- tokenRemoveIdDevice
  final _tokenRemoveIdDevice = "token_remove_id_device";

  String get tokenRemoveIdDevice {
    return _prefs?.getString(_tokenRemoveIdDevice) ?? "";
  }

  set tokenRemoveIdDevice(String value) {
    _prefs?.setString(_tokenRemoveIdDevice, value);
  }

  // ----------------------- documentsPath
  final _documentsPath = "documents_path";

  String get documentsPath {
    return _prefs?.getString(_documentsPath) ?? "";
  }

  set documentsPath(String value) {
    _prefs?.setString(_documentsPath, value);
  }

  // ----------------------- isPremiumCheck
  final _premiumCheck = "premium_check";

  bool isPremium({bool? isAccount}) {
    if (isAccount == null) {
      return isPremium(isAccount: false) || isPremium(isAccount: true);
    }
    return _prefs
            ?.getBool("${_premiumCheck}_${isAccount ? "user" : "store"}") ??
        false;
  }

  setPremium(bool isPremium, bool isAccount) {
    // isAccount: true: user - false: store
    _prefs?.setBool(
        "${_premiumCheck}_${isAccount ? "user" : "store"}", isPremium);
  }

  // ----------------------- premiumPackage
  final _premiumPackage = "premium_package";

  String getPremiumPackage(bool isAccount) {
    return _prefs
            ?.getString("${_premiumPackage}_${isAccount ? "user" : "store"}") ??
        "";
  }

  setPremiumPackage(String package, bool isAccount) {
    _prefs?.setString(
        "${_premiumPackage}_${isAccount ? "user" : "store"}", package);
  }

  // ----------------------- expiredTime
  final _expiredTime = "expired_time";

  int getExpiredTime(String package, bool isAccount) {
    return _prefs?.getInt(
            "${_expiredTime}_${package}_${isAccount ? "user" : "store"}") ??
        0;
  }

  setExpiredTime(int time, String package, bool isAccount) {
    _prefs?.setInt(
        "${_expiredTime}_${package}_${isAccount ? "user" : "store"}", time);
  }

  // ----------------------- purchasedExpire
  final _purchasedExpire = "purchased_expire";

  int getPurchasedExpire(String purchaseID) {
    return _prefs?.getInt("${_purchasedExpire}_$purchaseID") ?? 0;
  }

  setPurchasedExpire(int time, String purchaseID) {
    _prefs?.setInt("${_purchasedExpire}_$purchaseID", time);
  }

  // ----------------------- typePremiumPriority
  int get typePremiumPriority {
    // 0: no premium - 1: store - 2: user
    if (!isPremium()) return 0;
    if (!isPremium(isAccount: true)) return 1;
    if (!isPremium(isAccount: false)) return 2;

    final timeExpiredStore = getExpiredTime(getPremiumPackage(false), false);
    final timeExpiredUser = getExpiredTime(getPremiumPackage(true), true);
    if (timeExpiredStore > timeExpiredUser) return 1;
    return 2;
  }

  // ----------------------- isSyncPremiumAccount
  final _syncPremiumAccount = "sync_premium_account";

  bool get didSyncPremiumAccount {
    return _prefs?.getBool(_syncPremiumAccount) ?? false;
  }

  set didSyncPremiumAccount(bool value) {
    _prefs?.setBool(_syncPremiumAccount, value);
  }

  // ----------------------- adsInHouse
  final _adsInHouse = "ads_in_house";

  String get adsInHouse {
    return _prefs?.getString("${_adsInHouse}_${countryCode}_$languageApp") ??
        "";
  }

  set adsInHouse(String value) {
    _prefs?.setString("${_adsInHouse}_${countryCode}_$languageApp", value);
  }

  AdsObject? get adsInHouseObject {
    final jsonString = adsInHouse;
    if (jsonString.isEmpty) return null;

    try {
      Map object = jsonDecode(jsonString);
      var adsObject = AdsObject.fromJson(object.cast());
      return adsObject;
    } on FormatException {
      return null;
    }
  }

  // ----------------------- adsShowTop1
  final _adsShowTop1 = "ads_show_top_1";

  int get adsShowTop1 {
    return _prefs?.getInt(_adsShowTop1) ?? 0;
  }

  set adsShowTop1(int value) {
    _prefs?.setInt(_adsShowTop1, value);
  }

  // ----------------------- statusSignIn
  final _statusSignIn = "status_sign_in";

  // 0 logOut, 1 - email, 2 - google, 3: apple
  int get statusSignIn {
    if (userProfileJson.isEmpty) return 0;
    return _prefs?.getInt(_statusSignIn) ?? 0;
  }

  set statusSignIn(int value) {
    _prefs?.setInt(_statusSignIn, value);
    if (value == 0) {
      userProfileJson = "";
      // didSyncPremiumAccount = false;
    }
  }

  // ----------------------- userProfileJson
  final _userProfileJson = "user_profile_json";

  String get userProfileJson {
    return _prefs?.getString(_userProfileJson) ?? "";
  }

  set userProfileJson(String value) {
    _prefs?.setString(_userProfileJson, value);
  }

  UserProfileJSONObject? get userProfile {
    if (userProfileJson.isEmpty || statusSignIn == 0) return null;
    try {
      Map object = jsonDecode(userProfileJson);
      var userObject = UserProfileJSONObject.fromJson(object.cast());
      return userObject;
    } on FormatException {
      return null;
    }
  }

  int get idUser {
    return userProfile?.id ?? 0;
  }

  String get accessToken {
    return userProfile?.token ?? "";
  }

  // ----------------------- skuPrice
  final _skuPrice = "sku_price";

  double getSkuPrice(String sku, int sale) {
    return _prefs?.getDouble("${_skuPrice}_${sku}_$sale") ?? 0;
  }

  setSkuPrice(double price, String sku, int sale) {
    _prefs?.setDouble("${_skuPrice}_${sku}_$sale", price);
  }

  // ----------------------- currencySymbol
  final _currencySymbol = "currency_symbol";

  String get currencySymbol {
    return _prefs?.getString(_currencySymbol) ?? "";
  }

  set currencySymbol(String value) {
    _prefs?.setString(_currencySymbol, value);
  }

  // ----------------------- lastTimeClickAds
  final _lastTimeClickAds = "last_time_click_ads";

  int get lastTimeClickAds {
    return _prefs?.getInt(_lastTimeClickAds) ?? 0;
  }

  set lastTimeClickAds(int value) {
    _prefs?.setInt(_lastTimeClickAds, value);
  }

  // ----------------------- lastTimeShowAdsInter
  final _lastTimeShowAdsInter = "last_time_show_ads_inter";

  int get lastTimeShowAdsInter {
    return _prefs?.getInt(_lastTimeShowAdsInter) ?? 0;
  }

  set lastTimeShowAdsInter(int value) {
    _prefs?.setInt(_lastTimeShowAdsInter, value);
  }

  // ----------------------- numberQuestionStart
  final _numberQuestionStart = "number_question_start";

  int getNumberQuestionStart(String idKind, int format) {
    return _prefs?.getInt("${_numberQuestionStart}_${idKind}_$format") ?? 0;
  }

  setNumberQuestionStart(String idKind, int number, int format) {
    _prefs?.setInt("${_numberQuestionStart}_${idKind}_$format", number);
  }

  // ----------------------- questionFormat
  final _questionFormat = "question_format";

  int getQuestionFormat(String idKind) {
    return _prefs?.getInt("${_questionFormat}_$idKind") ?? 0;
  }

  setQuestionFormat(String idKind, int format) {
    _prefs?.setInt("${_questionFormat}_$idKind", format);
  }

  // ----------------------- numberQuestionJson
  final _numberQuestionJson = "number_question_json";

  String get numberQuestionJson {
    return _prefs?.getString(_numberQuestionJson) ?? "";
  }

  set numberQuestionJson(String value) {
    _prefs?.setString(_numberQuestionJson, value);
  }

  int getTotalSubQuestion(List<String> idKindList) {
    final jsonData = numberQuestionJson;
    if (jsonData.isEmpty) return 0;

    NumberQuestionObject questionsObject;
    try {
      Map object = jsonDecode(jsonData);
      questionsObject = NumberQuestionObject.fromJson(object.cast());
    } on FormatException {
      return 0;
    }

    final kindList = questionsObject.kind;
    if (kindList.isNullOrEmpty) return 0;
    var totalSubQues = 0;
    for (final idKind in idKindList) {
      for (final kindObject in kindList!) {
        final objectKindId = kindObject.kindId ?? "";
        if (objectKindId.contains(idKind)) {
          totalSubQues += kindObject.detail ?? 0;
          break;
        }
      }
    }
    return totalSubQues;
  }

  // ----------------------- idQuestionCorrect
  final _idQuestionCorrect = "id_question_correct";

  // danh sách id câu hỏi đã làm đúng
  addIdQuestionsCorrect(String id, String idKind) {
    final idList = getIdQuestionsCorrect(idKind);
    if (idList.contains(id)) return;
    idList.add(id);
    _prefs?.setString("${_idQuestionCorrect}_$idKind", jsonEncode(idList));
  }

  removeIdQuestionsCorrect(String id, String idKind) {
    final idList = getIdQuestionsCorrect(idKind);
    var checkChange = false;
    while (idList.contains(id)) {
      for (var index = 0; index < idList.length; index++) {
        if (idList[index] == id) {
          idList.removeAt(index);
          checkChange = true;
          break;
        }
      }
    }

    if (!checkChange) return;
    _prefs?.setString("${_idQuestionCorrect}_$idKind",
        idList.isEmpty ? "" : jsonEncode(idList));
  }

  removeAllIdQuestionsCorrect(String idKind) {
    _prefs?.setString("${_idQuestionCorrect}_$idKind", "");
  }

  List<String> getIdQuestionsCorrect(String idKind) {
    final jsonString = _prefs?.getString("${_idQuestionCorrect}_$idKind") ?? "";
    if (jsonString.isEmpty) return [];
    try {
      List<String> stringList = List<String>.from(json.decode(jsonString));
      return stringList;
    } on FormatException {
      return [];
    }
  }

  // ----------------------- idQuestionDid
  final _idQuestionDid = "id_question_did";

// danh sách id câu hỏi đã làm
  addIdQuestionsDid(String id, String idKind) {
    final idList = getIdQuestionsDid(idKind);
    if (idList.contains(id)) return;
    idList.add(id);
    _prefs?.setString("${_idQuestionDid}_$idKind", jsonEncode(idList));
  }

  removeAllIdQuestionsDid(int idKind) {
    _prefs?.setString("${_idQuestionDid}_$idKind", "");
  }

  List<String> getIdQuestionsDid(String idKind) {
    final jsonString = _prefs?.getString("${_idQuestionDid}_$idKind") ?? "";
    if (jsonString.isEmpty) return [];

    try {
      List<String> stringList = List<String>.from(json.decode(jsonString));
      return stringList;
    } on FormatException {
      return [];
    }
  }

// ----------------------- fontSize
  final _fontSize = "font_size";

  int get fontSize {
    final size = _prefs?.getInt(_fontSize) ?? 15;
    return size < 10 ? 10 : min(size, 30);
  }

  set fontSize(int value) {
    _prefs?.setInt(_fontSize, value);
  }

// ----------------------- autoNextQuestion
  final _autoNextQuestion = "auto_next_question";

  bool get isAutoNextQuestion {
    return _prefs?.getBool(_autoNextQuestion) ?? true;
  }

  set isAutoNextQuestion(bool value) {
    _prefs?.setBool(_autoNextQuestion, value);
  }

// ----------------------- typeChoiceAnswer
  final _typeChoiceAnswer = "type_choice_answer";

  int get typeChoiceAnswer {
    return _prefs?.getInt(_typeChoiceAnswer) ?? 0;
  }

  set typeChoiceAnswer(int value) {
    _prefs?.setInt(_typeChoiceAnswer, value);
  }

  bool get isChoiceAnswerBottom {
    return typeChoiceAnswer == 0;
  }

// ----------------------- showDialogTypeChoiceAnswer
  final _showDialogTypeChoiceAnswer = "show_dialog_type_choice_answer";

  bool get isShowDialogTypeChoiceAnswer {
    return _prefs?.getBool(_showDialogTypeChoiceAnswer) ?? true;
  }

  set isShowDialogTypeChoiceAnswer(bool value) {
    _prefs?.setBool(_showDialogTypeChoiceAnswer, value);
  }

// ----------------------- askSubmitPractice
  final _isAskSubmitPractice = "ask_submit_practice";

  bool get isAskSubmitPractice {
    return _prefs?.getBool(_isAskSubmitPractice) ?? true;
  }

  set isAskSubmitPractice(bool value) {
    _prefs?.setBool(_isAskSubmitPractice, value);
  }

// ----------------------- historyPracticeSync
  final _historyPracticeSync = "history_practice_sync";

  String get historyPracticeSync {
    return _prefs?.getString(_historyPracticeSync) ?? "";
  }

  set historyPracticeSync(String value) {
    _prefs?.setString(_historyPracticeSync, value);
  }

  List<PracticeResultObject> getHistoryPracticeSync() {
    final jsonData = historyPracticeSync;
    if (jsonData.isEmpty) return [];
    try {
      List<dynamic> objects = jsonDecode(jsonData);
      var resultList = List<PracticeResultObject>.from(
          objects.map((e) => PracticeResultObject.fromJson(e)));
      return resultList;
    } on FormatException {
      return [];
    }
  }

  // ----------------------- versionStore
  final _versionStore = "version_store";

  String get versionStore {
    return _prefs?.getString(_versionStore) ?? "";
  }

  set versionStore(String value) {
    _prefs?.setString(_versionStore, value);
  }

  // ----------------------- urlDomain
  final _urlDomain = "url_domain";

  String get urlDomain {
    return _prefs?.getString(_urlDomain) ?? "https://sat.migii.net";
  }

  set urlDomain(String value) {
    _prefs?.setString(_urlDomain, value);
  }


}
