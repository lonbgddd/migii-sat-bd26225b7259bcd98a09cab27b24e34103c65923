import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/view_dialog/payment_result_dialog.dart';
import 'package:migii_sat/view/view_tab/home/exam_tab_view.dart';
import 'package:migii_sat/view/view_tab/home/practice_tab_view.dart';
import 'package:migii_sat/view/view_tab/home/premium_tab_view.dart';
import 'package:migii_sat/view/view_tab/home/setting_tab_view.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:migii_sat/viewmodel/helper/preference_helper.dart';
import 'package:migii_sat/viewmodel/helper/ui_font.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/home/home_screen_item.dart';
import '../../model/user/user_profile_json_object.dart';
import '../../viewmodel/helper/dio/dio_helper.dart';
import '../../viewmodel/helper/event/event_helper.dart';
import '../../viewmodel/helper/fcm_helper.dart';
import '../../viewmodel/helper/global_helper.dart';
import '../../viewmodel/helper/log_cat.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../../viewmodel/helper/utils.dart';
import '../view_custom/toast.dart';
import '../view_dialog/new_version_dialog.dart';

class HomeScreen extends BasePage {
  const HomeScreen({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<HomeScreen> with WidgetsBindingObserver {
  var _sayBackPress = 0;
  late String _languageApp;

  late List<HomeScreenItem> barItems;
  late String _currentTab;
  var _isResume = false;

  @override
  void initState() {
    super.initState();
    _isResume = true;
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onMessage.listen(_showFlutterNotification);
    _startTimer();
    barItems = [
      HomeScreenItem(
          HomeScreenItem.routePractice, "ic_home_select", "ic_home_unselect"),
      HomeScreenItem(
          HomeScreenItem.routeExam, "ic_exam_select", "ic_exam_unselect"),
      HomeScreenItem(HomeScreenItem.routePremium, "ic_premium_select",
          "ic_premium_unselect"),
      HomeScreenItem(HomeScreenItem.routeSetting, "ic_settings_select",
          "ic_setttings_unselect"),
    ];
    _currentTab = HomeScreenItem.routePractice;
    _getPremium();
    _getAdsInHouse();
    _initInAppPurchase();
    _checkSyncHistoryPractice();
    _checkVersionApp();
    eventHelper.push(EventHelper.onLoadAdMod);

    eventHelper.listen((name) {
      switch (name) {
        case EventHelper.onLoginSync:
          _updateLogin();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(child: viewContainer()),
        onWillPop: () => onBackPressed(context));
  }

  Widget viewContainer() {
    _languageApp =
        context.select((AppProvider provider) => provider.languageApp);
    final isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);
    final isProcessing =
        context.select((AppProvider provider) => provider.isProcessing);

    return Stack(
      children: [
        SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(children: [
              Expanded(child: _viewTabHome()),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: paddingBottom),
                decoration: BoxDecoration(
                    color: theme(ColorHelper.colorBackgroundChildDay,
                        ColorHelper.colorBackgroundChildNight,
                        isNightMode: isNightMode),
                    boxShadow: [
                      BoxShadow(
                        color: theme(ColorHelper.colorGray,
                                ColorHelper.colorBackgroundNight)
                            .withOpacity(0.39),
                        blurRadius: 3.0.dp(),
                        offset: Offset(0.0, -5.0.dp()),
                      ),
                    ]),
                child: SizedBox(
                  width: double.infinity,
                  height: preferenceHelper.appBarHeight,
                  child: Row(children: [
                    for (final item in barItems) ...{_viewBarBottom(item)}
                  ]),
                ),
              )
            ])),
        if (_purchasePending || isProcessing) ...[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: SizedBox(
                  width: 52.0.dp(),
                  height: 52.0.dp(),
                  child: const LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                      colors: [ColorHelper.colorAccent])),
            ),
          )
        ]
      ],
    );
  }

  Widget _viewTabHome() {
    switch (_currentTab) {
      case HomeScreenItem.routePractice:
        return PracticeTabView(_selectTabListener);
      case HomeScreenItem.routeExam:
        return ExamTabView(_selectTabListener);
      case HomeScreenItem.routePremium:
        return PremiumTabView(_purchaseListener);
      case HomeScreenItem.routeSetting:
        return SettingTabView(_changeLanguageListener, _logOutListener);
      default:
        return const SizedBox();
    }
  }

  Widget _viewBarBottom(HomeScreenItem item) {
    final isSelected = _currentTab == item.route;

    var label = "";
    switch (item.route) {
      case HomeScreenItem.routePractice:
        label = appLocalized(languageApp: _languageApp).practice;
        break;
      case HomeScreenItem.routeExam:
        label = appLocalized(languageApp: _languageApp).exam;
        break;
      case HomeScreenItem.routePremium:
        label = appLocalized(languageApp: _languageApp).upgrade;
        break;
      case HomeScreenItem.routeSetting:
        label = appLocalized(languageApp: _languageApp).setting;
        break;
    }

    return Expanded(
        child: GestureDetector(
      onTap: () {
        _selectTabListener(item.route);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          isSelected
              ? SvgPicture.asset(
                  item.iconSelect.withIcon(),
                  width: preferenceHelper.appBarHeight / 2,
                  height: preferenceHelper.appBarHeight / 2,
                )
              : SvgPicture.asset(
                  item.iconUnselect.withIcon(),
                  width: preferenceHelper.appBarHeight / 2.5,
                  height: preferenceHelper.appBarHeight / 2.5,
                ),
          AnimatedSize(
              duration: const Duration(milliseconds: 100),
              child: isSelected
                  ? AutoSizeText(
                      label,
                      style: UIFont.fontApp(14.0.sp(), ColorHelper.colorAccent),
                      maxLines: 1,
                    )
                  : const SizedBox())
        ]),
      ),
    ));
  }

  _selectTabListener(String tabName) {
    if (_currentTab == tabName) return;
    setState(() {
      _currentTab = tabName;
    });
  }

  _changeLanguageListener() {
    _setBannerObject();
    _getAdsInHouse();
  }

  _logOutListener() {
    if (!isInternetAvailable) {
      Toast(appLocalized().no_internet).show();
      return;
    }

    final token = preferenceHelper.userProfile?.token;
    if (token.isNullOrEmpty) {
      if (preferenceHelper.statusSignIn == 2) {
        // nếu đăng nhập google
        final googleSignIn = GoogleSignIn(scopes: GlobalHelper.googleScopes);
        googleSignIn.disconnect();
      }

      if (preferenceHelper.isPremium(isAccount: true)) {
        preferenceHelper.setPremium(false, true);
        preferenceHelper.setPremiumPackage("", true);
        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
      }
      preferenceHelper.statusSignIn = 0;
      appProviderRead.userObject = null;
      eventHelper.push(EventHelper.onLoginSync);
      return;
    }

    appProviderRead.doingLogOut = true;
    dioHelper.postLogOut(preferenceHelper.idDevice, token!).then((isSuccess) {
      appProviderRead.doingLogOut = false;
      if (isSuccess) {
        Toast(appLocalized().logout_successful).show();
        if (preferenceHelper.statusSignIn == 2) {
          // nếu đăng nhập google
          final googleSignIn = GoogleSignIn(scopes: GlobalHelper.googleScopes);
          googleSignIn.disconnect();
        }

        if (preferenceHelper.isPremium(isAccount: true)) {
          preferenceHelper.setPremium(false, true);
          preferenceHelper.setPremiumPackage("", true);
          if (appProviderRead.isPremium) appProviderRead.isPremium = false;
          appProviderRead.isPremium = preferenceHelper.isPremium();
        }
        preferenceHelper.statusSignIn = 0;
        appProviderRead.userObject = null;
        eventHelper.push(EventHelper.onLoginSync);
      } else {
        Toast(appLocalized().logout_error).show();
      }
    });
  }

  Future<bool> onBackPressed(BuildContext context) async {
    final timeMilli = DateTime.now().millisecondsSinceEpoch;
    if (_sayBackPress + 3000 > timeMilli) return true;

    Toast(appLocalized(languageApp: _languageApp).press_back_once_again).show();

    _sayBackPress = timeMilli;
    return false;
  }

  _getAdsInHouse() {
    dioHelper
        .getAdsInHouse(
            preferenceHelper.countryCode, preferenceHelper.languageApp)
        .then((adsInHouseObject) {
      preferenceHelper.adsShowTop1 = preferenceHelper.adsShowTop1 + 1;

      if (adsInHouseObject == null) {
        _setBannerObject();
        return;
      }

      final adsObject = adsInHouseObject.ads;
      if (adsObject == null) {
        preferenceHelper.adsInHouse = "";
        _setBannerObject();
        return;
      }

      preferenceHelper.adsInHouse = jsonEncode(adsObject);
      _setBannerObject();
    });
  }

  _setBannerObject() {
    final adsInHouseObject = preferenceHelper.adsInHouseObject;
    if (adsInHouseObject != null) {
      appProviderRead.bannerTop1 = adsInHouseObject.getBannerTop1();
      appProviderRead.bannerListTop2 = adsInHouseObject.getBannerListTop2();
      appProviderRead.bannerListTop3 = adsInHouseObject.getBannerListTop3();
    } else {
      appProviderRead.bannerTop1 = null;
      appProviderRead.bannerListTop2 = null;
      appProviderRead.bannerListTop3 = null;
    }

    _setSkuPremium();
  }

  _setSkuPremium() {
    final listSale = preferenceHelper.adsInHouseObject?.sale;
    if (listSale == null || listSale.isEmpty) {
      Future.delayed(Duration.zero, () async {
        if (appProviderRead.sku12Months == GlobalHelper.sku12Months) {
          appProviderRead.sku12Months = "";
        }
        appProviderRead.sku12Months = GlobalHelper.sku12Months;

        if (appProviderRead.sku6Months == GlobalHelper.sku6Months) {
          appProviderRead.sku6Months = "";
        }
        appProviderRead.sku6Months = GlobalHelper.sku6Months;

        if (appProviderRead.sku3Months == GlobalHelper.sku3Months) {
          appProviderRead.sku3Months = "";
        }
        appProviderRead.sku3Months = GlobalHelper.sku3Months;
      });
      return;
    }

    var checkContainSku12Months = false;
    var checkContainSku6Months = false;
    var checkContainSku3Months = false;

    for (final saleObject in listSale) {
      final premium = saleObject.premium;
      if (premium == null || premium.isEmpty) continue;
      switch (premium) {
        case "pre12months":
          final percent =
              (int.tryParse(saleObject.percent ?? "0") ?? 0) ~/ 10 * 10;
          if (percent > 0) {
            checkContainSku12Months = true;
            Future.delayed(Duration.zero, () async {
              if (appProviderRead.sku12Months ==
                  "${GlobalHelper.sku12MonthsSale}$percent") {
                appProviderRead.sku12Months = "";
              }
              appProviderRead.sku12Months =
                  "${GlobalHelper.sku12MonthsSale}$percent";
            });
          }
          break;
        case "pre6months":
          final percent =
              (int.tryParse(saleObject.percent ?? "0") ?? 0) ~/ 10 * 10;
          if (percent > 0) {
            checkContainSku6Months = true;
            Future.delayed(Duration.zero, () async {
              if (appProviderRead.sku6Months ==
                  "${GlobalHelper.sku6MonthsSale}$percent") {
                appProviderRead.sku6Months = "";
              }
              appProviderRead.sku6Months =
                  "${GlobalHelper.sku6MonthsSale}$percent";
            });
          }
          break;
        case "pre3months":
          final percent =
              (int.tryParse(saleObject.percent ?? "0") ?? 0) ~/ 10 * 10;
          if (percent > 0) {
            checkContainSku3Months = true;
            Future.delayed(Duration.zero, () async {
              if (appProviderRead.sku3Months ==
                  "${GlobalHelper.sku3MonthsSale}$percent") {
                appProviderRead.sku3Months = "";
              }
              appProviderRead.sku3Months =
                  "${GlobalHelper.sku3MonthsSale}$percent";
            });
          }
          break;
      }
    }
    Future.delayed(Duration.zero, () async {
      if (!checkContainSku12Months) {
        if (appProviderRead.sku12Months == GlobalHelper.sku12Months) {
          appProviderRead.sku12Months = "";
        }
        appProviderRead.sku12Months = GlobalHelper.sku12Months;
      }
      if (!checkContainSku6Months) {
        if (appProviderRead.sku6Months == GlobalHelper.sku6Months) {
          appProviderRead.sku6Months = "";
        }
        appProviderRead.sku6Months = GlobalHelper.sku6Months;
      }
      if (!checkContainSku3Months) {
        if (appProviderRead.sku3Months == GlobalHelper.sku3Months) {
          appProviderRead.sku3Months = "";
        }
        appProviderRead.sku3Months = GlobalHelper.sku3Months;
      }
    });
  }

  _updateLogin() {
    final user = preferenceHelper.userProfile;
    if (user?.token == null) return;
    _checkPremium(user!);
  }

  _checkPremium(UserProfileJSONObject user) {
    if (user.isPremium == true) {
      final productId = user.premium?.productId ?? "";
      if (!preferenceHelper.isPremium(isAccount: true)) {
        switch (productId) {
          case GlobalHelper.sku12Months:
            final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;
            if (preferenceHelper.timeServer <= timeExpired) {
              preferenceHelper.setPremium(true, true);
              preferenceHelper.setExpiredTime(
                  timeExpired, GlobalHelper.sku12Months, true);
              preferenceHelper.setPremiumPackage(
                  GlobalHelper.sku12Months, true);

              if (appProviderRead.isPremium) appProviderRead.isPremium = false;
              appProviderRead.isPremium = preferenceHelper.isPremium();
            }
            break;
          case GlobalHelper.sku6Months:
            final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;
            if (preferenceHelper.timeServer <= timeExpired) {
              preferenceHelper.setPremium(true, true);
              preferenceHelper.setExpiredTime(
                  timeExpired, GlobalHelper.sku6Months, true);
              preferenceHelper.setPremiumPackage(GlobalHelper.sku6Months, true);

              if (appProviderRead.isPremium) appProviderRead.isPremium = false;
              appProviderRead.isPremium = preferenceHelper.isPremium();
            }
            break;
          case GlobalHelper.sku3Months:
            final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;
            if (preferenceHelper.timeServer <= timeExpired) {
              preferenceHelper.setPremium(true, true);
              preferenceHelper.setExpiredTime(
                  timeExpired, GlobalHelper.sku3Months, true);
              preferenceHelper.setPremiumPackage(GlobalHelper.sku3Months, true);

              if (appProviderRead.isPremium) appProviderRead.isPremium = false;
              appProviderRead.isPremium = preferenceHelper.isPremium();
            }
            break;
          default:
            final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;
            final timeServer =
                Provider.of<AppProvider>(context, listen: false).timeServer;
            if (timeServer <= timeExpired) {
              preferenceHelper.setPremium(true, true);

              if (productId.contains("3day")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku3Days, true);
                preferenceHelper.setPremiumPackage(GlobalHelper.sku3Days, true);
              } else if (productId.contains("5day")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku5Days, true);
                preferenceHelper.setPremiumPackage(GlobalHelper.sku5Days, true);
              } else if (productId.contains("7day")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku7Days, true);
                preferenceHelper.setPremiumPackage(GlobalHelper.sku7Days, true);
              } else if (productId.contains("1month")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku1Months, true);
                preferenceHelper.setPremiumPackage(
                    GlobalHelper.sku1Months, true);
              } else if (productId.contains("3month")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku3Months, true);
                preferenceHelper.setPremiumPackage(
                    GlobalHelper.sku3Months, true);
              } else if (productId.contains("6month")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku6Months, true);
                preferenceHelper.setPremiumPackage(
                    GlobalHelper.sku6Months, true);
              } else if (productId.contains("12month")) {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.sku12Months, true);
                preferenceHelper.setPremiumPackage(
                    GlobalHelper.sku12Months, true);
              } else {
                preferenceHelper.setExpiredTime(
                    timeExpired, GlobalHelper.skuCustom, true);
                preferenceHelper.setPremiumPackage(
                    GlobalHelper.skuCustom, true);
              }
            }

            if (appProviderRead.isPremium) appProviderRead.isPremium = false;
            appProviderRead.isPremium = preferenceHelper.isPremium();
            break;
        }
      } else {
        final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;
        if (preferenceHelper.getExpiredTime(
                preferenceHelper.getPremiumPackage(true), true) !=
            timeExpired) {
          preferenceHelper.setPremium(false, true);
          preferenceHelper.setPremiumPackage("", true);

          if (appProviderRead.isPremium) appProviderRead.isPremium = false;
          appProviderRead.isPremium = preferenceHelper.isPremium();

          _checkPremium(user);
          return;
        } else {
          if (preferenceHelper.isPremium(isAccount: true)) {
            final timeServer =
                Provider.of<AppProvider>(context, listen: false).timeServer;

            final timeExpired = (user.premium?.timeExpired ?? 0) ~/ 1000;

            if (timeServer > timeExpired) {
              preferenceHelper.setPremium(false, true);
              preferenceHelper.setPremiumPackage("", true);

              if (appProviderRead.isPremium) appProviderRead.isPremium = false;
              appProviderRead.isPremium = preferenceHelper.isPremium();
            }
          }
        }
      }
    } else if (user.isPremium == false &&
        preferenceHelper.isPremium(isAccount: true)) {
      preferenceHelper.setPremium(false, true);
      preferenceHelper.setPremiumPackage("", true);

      if (appProviderRead.isPremium) appProviderRead.isPremium = false;
      appProviderRead.isPremium = preferenceHelper.isPremium();
    }
  }

  _getPremium() {
    final user = preferenceHelper.userProfile;
    if (user?.token == null) return;
    if (isInternetAvailable) {
      dioHelper.getProfileUser().then((userProfilePre) {
        if (userProfilePre != null) {
          user!.isPremium = userProfilePre.isPremium;
          user.premium = userProfilePre.premium;

          preferenceHelper.userProfileJson = jsonEncode(user);
          appProviderRead.userObject = user;
        }
        _checkPremium(user!);
      });
    } else {
      _checkPremium(user!);
    }
  }

  _checkSyncHistoryPractice() {
    if (preferenceHelper.historyPracticeSync.isEmpty) return;
    final syncList = preferenceHelper.getHistoryPracticeSync();
    if (syncList.isNullOrEmpty) {
      preferenceHelper.historyPracticeSync = "";
      return;
    }

    final syncItem = syncList.first;
    dioHelper.postResultPractice(syncItem).then((isSuccess) {
      if (!mounted) return;
      if (isSuccess) {
        syncList.removeAt(0);
        preferenceHelper.historyPracticeSync =
            syncList.isEmpty ? "" : jsonEncode(syncList);
        _checkSyncHistoryPractice();
      }
    });
  }

  _checkVersionApp() async {
    final newVersion = NewVersionPlus();
    final version = await newVersion.getVersionStatus();
    if (version?.canUpdate ?? false) {
      final storeVersion = version?.storeVersion ?? "";

      Future.delayed(Duration.zero, () async {
        if (preferenceHelper.versionStore != storeVersion) {
          NewVersionDialog.show(context, storeVersion, (isUpdate) {
            if (isUpdate) {
              final appStoreLink = version?.appStoreLink;
              if (!appStoreLink.isNullOrEmpty) Utils.openLink(appStoreLink!);
            } else {
              preferenceHelper.versionStore = storeVersion;
            }
          });
        }
        appProviderRead.appStoreLink = version?.appStoreLink ?? "";
      });
    }
  }

  @override
  void dispose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _isResume = true;
        _startTimer();
        _checkSyncHistoryPractice();
        // SaleLocalHelper.setupSaleLocal();
        break;
      case AppLifecycleState.paused:
        _isResume = false;
        _stopTimer();
        break;
      default:
        break;
    }
  }

  _showFlutterNotification(RemoteMessage message) {
    if (!_isResume) return;
    Log.d("2222");
    showFlutterNotification(message);
  }

  Timer? _timer;
  int _timeDeviceCached = 0;
  var didStartTimer = false;

  _startTimer() {
    if (didStartTimer) return;
    didStartTimer = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var timeServer = appProviderRead.timeServer;
      if (timeServer == 0) {
        timeServer = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }

      if (_timeDeviceCached > 0) {
        timeServer = timeServer +
            DateTime.now().millisecondsSinceEpoch ~/ 1000 -
            _timeDeviceCached;
        _timeDeviceCached = 0;
        preferenceHelper.timeServer = timeServer;
      }
      appProviderRead.timeServer = timeServer + 1;
    });
  }

  _stopTimer() {
    if (!didStartTimer) return;
    didStartTimer = false;
    _timeDeviceCached = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer?.cancel();
    _timer = null;
  }

  var _isSetupPurchase = false;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  bool _purchasePending = false;
  bool _handleRestore = false;

  _initInAppPurchase() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      if (purchaseDetailsList.isEmpty) {
        if (_handleRestore) {
          PaymentResultDialog.show(context, 2);
        }
        return;
      }
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    _initStoreInfo();

    Future.delayed(Duration.zero, () async {
      if (preferenceHelper.isPremium(isAccount: false)) {
        preferenceHelper.setPremium(false, false);
        preferenceHelper.setPremiumPackage("", false);
        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
      }
      _inAppPurchase.restorePurchases();
    });
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      _isSetupPurchase = false;
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    List<String> skuList = [];
    skuList.add(GlobalHelper.sku12Months);
    skuList.add(GlobalHelper.sku6Months);
    skuList.add(GlobalHelper.sku3Months);

    for (var i = 1; i < 10; i++) {
      skuList.add("${GlobalHelper.sku12MonthsSale}${i * 10}");
      skuList.add("${GlobalHelper.sku6MonthsSale}${i * 10}");
      skuList.add("${GlobalHelper.sku3MonthsSale}${i * 10}");
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(skuList.toSet());

    if (productDetailResponse.error != null) {
      _isSetupPurchase = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      _isSetupPurchase = false;
      return;
    }

    _isSetupPurchase = isAvailable;
    _products = productDetailResponse.productDetails;

    for (final productDetail in productDetailResponse.productDetails) {
      preferenceHelper.currencySymbol = productDetail.currencySymbol;
      switch (productDetail.id) {
        case GlobalHelper.sku12Months:
          preferenceHelper.setSkuPrice(
              productDetail.rawPrice, GlobalHelper.sku12Months, 0);
          break;
        case GlobalHelper.sku6Months:
          preferenceHelper.setSkuPrice(
              productDetail.rawPrice, GlobalHelper.sku6Months, 0);
          break;
        case GlobalHelper.sku3Months:
          preferenceHelper.setSkuPrice(
              productDetail.rawPrice, GlobalHelper.sku3Months, 0);
          break;
        default:
          if (productDetail.id.contains(GlobalHelper.sku12MonthsSale)) {
            final percent = int.tryParse(productDetail.id
                    .replaceAll(GlobalHelper.sku12MonthsSale, "")) ??
                0;
            if (percent > 0) {
              preferenceHelper.setSkuPrice(
                  productDetail.rawPrice, GlobalHelper.sku12Months, percent);
            }
          } else if (productDetail.id.contains(GlobalHelper.sku6MonthsSale)) {
            final percent = int.tryParse(productDetail.id
                    .replaceAll(GlobalHelper.sku6MonthsSale, "")) ??
                0;
            if (percent > 0) {
              preferenceHelper.setSkuPrice(
                  productDetail.rawPrice, GlobalHelper.sku6Months, percent);
            }
          } else if (productDetail.id.contains(GlobalHelper.sku3MonthsSale)) {
            final percent = int.tryParse(productDetail.id
                    .replaceAll(GlobalHelper.sku3MonthsSale, "")) ??
                0;
            if (percent > 0) {
              preferenceHelper.setSkuPrice(
                  productDetail.rawPrice, GlobalHelper.sku3Months, percent);
            }
          }
          break;
      }
    }
    _setSkuPremium();
  }

  _purchaseListener(String skuId) {
    if (skuId == "restore_payment") {
      _handleRestore = true;
      _inAppPurchase.restorePurchases();
      return;
    }

    if (!_isSetupPurchase) {
      PaymentResultDialog.show(context, 0);
      return;
    }

    ProductDetails? productDetails;
    for (final product in _products) {
      if (product.id == skuId) {
        productDetails = product;
        break;
      }
    }

    if (productDetails == null) {
      PaymentResultDialog.show(context, 0);
      return;
    }

    PurchaseParam purchaseParam = Platform.isAndroid
        ? GooglePlayPurchaseParam(productDetails: productDetails)
        : PurchaseParam(productDetails: productDetails);

    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    setState(() {
      _purchasePending = false;
    });

    // Huỷ gói purchase chỉ android
    // final InAppPurchaseAndroidPlatformAddition androidAddition =
    // _inAppPurchase.getPlatformAddition<
    //     InAppPurchaseAndroidPlatformAddition>();
    // await androidAddition.consumePurchase(purchaseDetails);

    final skuId = purchaseDetails.productID;

    switch (skuId) {
      case GlobalHelper.sku12Months:
        preferenceHelper.setPremium(true, false);
        preferenceHelper.setPremiumPackage(GlobalHelper.sku12Months, false);
        if (purchaseDetails.status == PurchaseStatus.restored) {
          if (_handleRestore) {
            PaymentResultDialog.show(context, 3);
          }
        } else {
          preferenceHelper.setExpiredTime(0, GlobalHelper.sku12Months, false);
          PaymentResultDialog.show(context, 1);
          Utils.trackerEvent(
              "premium", "premium_purchased_${GlobalHelper.sku12Months}");
        }

        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
        break;
      case GlobalHelper.sku6Months:
        if (preferenceHelper.getPremiumPackage(false) ==
            GlobalHelper.sku12Months) {
          break;
        }

        preferenceHelper.setPremium(true, false);
        preferenceHelper.setPremiumPackage(GlobalHelper.sku6Months, false);
        if (purchaseDetails.status == PurchaseStatus.restored) {
          if (_handleRestore) {
            PaymentResultDialog.show(context, 3);
          }
        } else {
          preferenceHelper.setExpiredTime(0, GlobalHelper.sku6Months, false);
          PaymentResultDialog.show(context, 1);
          Utils.trackerEvent(
              "premium", "premium_purchased_${GlobalHelper.sku6Months}");
        }

        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
        break;
      case GlobalHelper.sku3Months:
        if ([GlobalHelper.sku12Months, GlobalHelper.sku6Months]
            .contains(preferenceHelper.getPremiumPackage(false))) {
          break;
        }

        preferenceHelper.setPremium(true, false);
        preferenceHelper.setPremiumPackage(GlobalHelper.sku3Months, false);
        if (purchaseDetails.status == PurchaseStatus.restored) {
          if (_handleRestore) {
            PaymentResultDialog.show(context, 3);
          }
        } else {
          preferenceHelper.setExpiredTime(0, GlobalHelper.sku3Months, false);
          PaymentResultDialog.show(context, 1);
          Utils.trackerEvent(
              "premium", "premium_purchased_${GlobalHelper.sku3Months}");
        }

        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
        break;
      default:
        if (skuId.contains(GlobalHelper.sku12MonthsSale)) {
          preferenceHelper.setPremium(true, false);
          preferenceHelper.setPremiumPackage(GlobalHelper.sku12Months, false);

          if (purchaseDetails.status == PurchaseStatus.restored) {
            if (_handleRestore) {
              PaymentResultDialog.show(context, 3);
            }
          } else {
            preferenceHelper.setExpiredTime(0, GlobalHelper.sku12Months, false);
            PaymentResultDialog.show(context, 1);
            Utils.trackerEvent(
                "premium", "premium_purchased_${GlobalHelper.sku12Months}");
          }
          if (appProviderRead.isPremium) appProviderRead.isPremium = false;
          appProviderRead.isPremium = preferenceHelper.isPremium();
        } else if (skuId.contains(GlobalHelper.sku6MonthsSale)) {
          if (preferenceHelper.getPremiumPackage(false) ==
              GlobalHelper.sku12Months) break;

          preferenceHelper.setPremium(true, false);
          preferenceHelper.setPremiumPackage(GlobalHelper.sku6Months, false);

          if (purchaseDetails.status == PurchaseStatus.restored) {
            if (_handleRestore) {
              PaymentResultDialog.show(context, 3);
            }
          } else {
            preferenceHelper.setExpiredTime(0, GlobalHelper.sku6Months, false);
            PaymentResultDialog.show(context, 1);
            Utils.trackerEvent(
                "premium", "premium_purchased_${GlobalHelper.sku6Months}");
          }
          if (appProviderRead.isPremium) appProviderRead.isPremium = false;
          appProviderRead.isPremium = preferenceHelper.isPremium();
        } else if (skuId.contains(GlobalHelper.sku3MonthsSale)) {
          if ([GlobalHelper.sku12Months, GlobalHelper.sku6Months]
              .contains(preferenceHelper.getPremiumPackage(false))) break;

          preferenceHelper.setPremium(true, false);
          preferenceHelper.setPremiumPackage(GlobalHelper.sku3Months, false);

          if (purchaseDetails.status == PurchaseStatus.restored) {
            if (_handleRestore) {
              PaymentResultDialog.show(context, 3);
            }
          } else {
            preferenceHelper.setExpiredTime(0, GlobalHelper.sku3Months, false);
            PaymentResultDialog.show(context, 1);
            Utils.trackerEvent(
                "premium", "premium_purchased_${GlobalHelper.sku3Months}");
          }
          if (appProviderRead.isPremium) appProviderRead.isPremium = false;
          appProviderRead.isPremium = preferenceHelper.isPremium();
        }
        break;
    }

    _checkSyncPremium(
        purchaseDetails.productID,
        purchaseDetails.verificationData.serverVerificationData,
        purchaseDetails.purchaseID ?? purchaseDetails.productID,
        int.tryParse(purchaseDetails.transactionDate ?? "0") ?? 0);
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
    PaymentResultDialog.show(context, 0);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    PaymentResultDialog.show(context, 0);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          setState(() {
            _purchasePending = false;
          });
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  _checkSyncPremium(String productID, String receiptString, String purchaseID,
      int transactionDate) {
    final timeServer =
        Provider.of<AppProvider>(context, listen: false).timeServer;
    final purchasedExpire = preferenceHelper.getPurchasedExpire(purchaseID);

    if (purchasedExpire > 0) {
      if (purchasedExpire > timeServer) {
        if (preferenceHelper.statusSignIn == 0 ||
            preferenceHelper.didSyncPremiumAccount ||
            receiptString.isEmpty) {
          return;
        }
        _syncPremium(productID, receiptString);
        return;
      }
      if (productID.contains(GlobalHelper.sku12Months)) {
        preferenceHelper.setExpiredTime(0, GlobalHelper.sku12Months, false);
      } else if (productID.contains(GlobalHelper.sku6Months)) {
        preferenceHelper.setExpiredTime(0, GlobalHelper.sku6Months, false);
      } else if (productID.contains(GlobalHelper.sku3Months)) {
        preferenceHelper.setExpiredTime(0, GlobalHelper.sku3Months, false);
      }
      preferenceHelper.setPurchasedExpire(0, purchaseID);
    }
    dioHelper
        .getInfoPurchased(productID, receiptString, transactionDate)
        .then((timeExpires) {
      if (timeExpires == 0) return;

      final timeServer =
          Provider.of<AppProvider>(context, listen: false).timeServer;
      if (timeServer > timeExpires) {
        preferenceHelper.setPremium(false, false);
        preferenceHelper.setPremiumPackage("", false);
        if (appProviderRead.isPremium) appProviderRead.isPremium = false;
        appProviderRead.isPremium = preferenceHelper.isPremium();
        return;
      }

      preferenceHelper.setPurchasedExpire(timeExpires, purchaseID);

      if (productID.contains(GlobalHelper.sku12Months)) {
        preferenceHelper.setExpiredTime(
            timeExpires, GlobalHelper.sku12Months, false);
      } else if (productID.contains(GlobalHelper.sku6Months)) {
        preferenceHelper.setExpiredTime(
            timeExpires, GlobalHelper.sku6Months, false);
      } else if (productID.contains(GlobalHelper.sku3Months)) {
        preferenceHelper.setExpiredTime(
            timeExpires, GlobalHelper.sku3Months, false);
      }

      if (preferenceHelper.statusSignIn == 0 || receiptString.isEmpty) {
        preferenceHelper.didSyncPremiumAccount = false;
        return;
      }
      _syncPremium(productID, receiptString);
    });
  }

  _syncPremium(String productID, String receiptString) {
    dioHelper.syncPremiumAccount(productID, receiptString).then((verifyObject) {
      if (verifyObject == null) return;
      preferenceHelper.didSyncPremiumAccount = true;

      if (verifyObject.premium != null) {
        final userProfile = preferenceHelper.userProfile;
        if (userProfile == null) return;
        userProfile.isPremium = verifyObject.isPremium;
        userProfile.premium?.productId = verifyObject.premium!.productId;
        userProfile.premium?.timeExpired = verifyObject.premium!.timeExpired;

        preferenceHelper.userProfileJson = jsonEncode(userProfile);
        appProviderRead.userObject = userProfile;
        _checkPremium(userProfile);
      }
    });
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
