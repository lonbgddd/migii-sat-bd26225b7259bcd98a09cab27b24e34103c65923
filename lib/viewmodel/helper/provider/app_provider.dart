import 'package:flutter/material.dart';
import 'package:migii_sat/model/exam/exam_list_json_object.dart';

import '../../../model/user/ads_in_house_json_object.dart';
import '../../../model/user/user_profile_json_object.dart';
import '../global_helper.dart';
import '../preference_helper.dart';

class AppProvider extends ChangeNotifier {
// --------------------- languageApp
  String _languageApp = "";

  get languageApp => _languageApp;

  set languageApp(value) {
    _languageApp = value;
    notifyListeners();
  }

  // --------------------- isNightMode
  bool _isNightMode = preferenceHelper.isNightMode;

  get isNightMode => _isNightMode;

  set isNightMode(value) {
    _isNightMode = value;
    notifyListeners();
  }

  // --------------------- timeServer
  int _timeServer = 0;

  int get timeServer => _timeServer;

  set timeServer(int value) {
    _timeServer = value;
    notifyListeners();
  }

  // --------------------- userObject
  UserProfileJSONObject? _userObject = preferenceHelper.userProfile;

  UserProfileJSONObject? get userObject => _userObject;

  set userObject(UserProfileJSONObject? value) {
    _userObject = value;
    notifyListeners();
  }

  // --------------------- doingLogOut
  bool _doingLogOut = false;

  bool get doingLogOut => _doingLogOut;

  set doingLogOut(bool value) {
    _doingLogOut = value;
    notifyListeners();
  }

  // --------------------- isProcessing
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  set isProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  // --------------------- isPremium
  bool _isPremium = preferenceHelper.isPremium();

  bool get isPremium => _isPremium;

  set isPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // --------------------- examList
  List<ExamListQuestion>? _examList;

  List<ExamListQuestion>? get examList => _examList;

  set examList(List<ExamListQuestion>? value) {
    _examList = value;
    notifyListeners();
  }

  // --------------------- bannerTop1
  BannerObject? _bannerTop1;

  BannerObject? get bannerTop1 => _bannerTop1;

  set bannerTop1(BannerObject? value) {
    _bannerTop1 = value;
    notifyListeners();
  }

  // --------------------- isCloseBannerTop1
  bool _isCloseBannerTop1 = false;

  bool get isCloseBannerTop1 => _isCloseBannerTop1;

  set isCloseBannerTop1(bool value) {
    _isCloseBannerTop1 = value;
    notifyListeners();
  }

  // --------------------- bannerListTop2
  List<BannerObject>? _bannerListTop2;

  List<BannerObject>? get bannerListTop2 => _bannerListTop2;

  set bannerListTop2(List<BannerObject>? value) {
    _bannerListTop2 = value;
    notifyListeners();
  }

  // --------------------- isCloseBannerTop2
  bool _isCloseBannerTop2 = false;

  bool get isCloseBannerTop2 => _isCloseBannerTop2;

  set isCloseBannerTop2(bool value) {
    _isCloseBannerTop2 = value;
    notifyListeners();
  }

  // --------------------- bannerListTop3
  List<BannerObject>? _bannerListTop3;

  List<BannerObject>? get bannerListTop3 => _bannerListTop3;

  set bannerListTop3(List<BannerObject>? value) {
    _bannerListTop3 = value;
    notifyListeners();
  }

  // --------------------- sku12Months
  String _sku12Months = GlobalHelper.sku12Months;

  get sku12Months => _sku12Months;

  set sku12Months(value) {
    _sku12Months = value;
    notifyListeners();
  }

  // --------------------- sku6Months
  String _sku6Months = GlobalHelper.sku6Months;

  get sku6Months => _sku6Months;

  set sku6Months(value) {
    _sku6Months = value;
    notifyListeners();
  }

  // --------------------- sku3Months
  String _sku3Months = GlobalHelper.sku3Months;

  get sku3Months => _sku3Months;

  set sku3Months(value) {
    _sku3Months = value;
    notifyListeners();
  }

  // --------------------- paddingBottom
  // insetsBottom hoặc bannerHeight
  double _paddingBottom = preferenceHelper.paddingInsetsBottom;

  get paddingBottom => _paddingBottom;

  set paddingBottom(value) {
    _paddingBottom = value;
    notifyListeners();
  }

  // --------------------- bannerHeight
  double _bannerHeight = 0;

  get bannerHeight => _bannerHeight;

  set bannerHeight(value) {
    _bannerHeight = value;
    notifyListeners();
  }

  // --------------------- fontSize
  bool _autoNextQuestion = preferenceHelper.isAutoNextQuestion;

  bool get isAutoNextQuestion => _autoNextQuestion;

  set isAutoNextQuestion(value) {
    _autoNextQuestion = value;
    notifyListeners();
  }

  // --------------------- fontSize
  int _fontSize = preferenceHelper.fontSize;

  int get fontSize => _fontSize;

  set fontSize(value) {
    _fontSize = value;
    notifyListeners();
  }

  // --------------------- choiceAnswerBottom
  bool _choiceAnswerBottom = preferenceHelper.isChoiceAnswerBottom;

  bool get isChoiceAnswerBottom => _choiceAnswerBottom;

  set isChoiceAnswerBottom(value) {
    _choiceAnswerBottom = value;
    notifyListeners();
  }

// --------------------- appStoreLink
  String _appStoreLink = "";

  String get appStoreLink => _appStoreLink;

  set appStoreLink(value) {
    _appStoreLink = value;
    notifyListeners();
  }

  int _isDownload = 0;
  int get isDownload => _isDownload;

  void setIcriDownload() {
    _isDownload++;
    notifyListeners();
  }

  void setDecDownload() {
    _isDownload--;
    notifyListeners();
  }
}
