import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:migii_sat/view/view_screen/splash_screen.dart';

import 'package:provider/provider.dart';
import '../../main.dart';
import '../../model/home/training_section_json_object.dart';
import '../../viewmodel/helper/color_helper.dart';
import '../../viewmodel/helper/dio/dio_helper.dart';
import '../../viewmodel/helper/event/event_helper.dart';
import '../../viewmodel/helper/global_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import '../../viewmodel/helper/utils.dart';
import '../base/base_stateful.dart';

class Application extends BasePage {
  const Application({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<Application> {
  @override
  void initState() {
    super.initState();
    dioHelper = DioHelper();
    streamController = StreamController.broadcast();

    Utils.loadJSONAsset("structure.json", (data) {
      List<dynamic> objects = jsonDecode(data);
      final itemList = List<TrainingSectionJSONObject>.from(
          objects.map((e) => TrainingSectionJSONObject.fromJson(e)));
      sectionsList = itemList;
    });

    eventHelper.listen((name) {
      switch (name) {
        case EventHelper.onLoadAdMod:
          _onLoadAds();
          break;
        case EventHelper.onShowIntervalAds:
          _onIntervalAds();
          break;
      }
    });

    _getCountryCode();
    _getTimeServer();
    _getNumberQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);
    final isPremium =
        context.select((AppProvider provider) => provider.isPremium);

    double heightBanner = _isShowAdsBanner && !isPremium
        ? (_adsBanner?.size.height.toDouble() ?? 0)
        : 0;
    double paddingBottom =
        heightBanner > 0 ? 0 : preferenceHelper.paddingInsetsBottom;

    if (Provider.of<AppProvider>(context, listen: false).paddingBottom !=
        paddingBottom) {
      Future.delayed(Duration.zero, () async {
        appProviderRead.bannerHeight = heightBanner;
        appProviderRead.paddingBottom = paddingBottom;
      });
    }

    // if (isPremium) {
    //   if (SaleLocalHelper.isActiveSaleLocal(preferenceHelper.timeServer)) {
    //     SaleLocalHelper.setupSaleLocal();
    //   }
    // }

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: theme(
              ColorHelper.colorBackgroundDay, ColorHelper.colorBackgroundNight,
              isNightMode: isNightMode),
          child: Column(children: [
            Expanded(
                child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'), // Anh
                      Locale('vi'), // Việt
                      Locale('es'), // Tây Ban Nha
                      Locale('ko'), // Hàn Quốc
                      Locale.fromSubtags(languageCode: 'zh'), // Trung Giản
                      Locale.fromSubtags(
                          languageCode: 'zh', scriptCode: 'Hant'), // Trung Phồn
                    ],
                    builder: BotToastInit(),
                    navigatorObservers: [BotToastNavigatorObserver()],
                    home: const SplashScreen())),
            if (_isShowAdsBanner && !isPremium && _adsBanner != null)
              Container(
                alignment: Alignment.center,
                width: _adsBanner!.size.width.toDouble(),
                height: heightBanner,
                child: AdWidget(ad: _adsBanner!),
              )
          ]),
        ));
  }

  BannerAd? _adsBanner;
  var _checkLoadAds = true;
  var _isShowAdsBanner = false;
  InterstitialAd? _interstitialAd;

  _onLoadAds() {
    if (_checkLoadAds) {
      _loadADS();
    } else {
      if (_isShowAble()) {
        if (!_isShowAdsBanner) {
          setState(() {
            _isShowAdsBanner = true;
          });
        }
      } else {
        if (_isShowAdsBanner) {
          setState(() {
            _isShowAdsBanner = false;
          });
        }
      }
    }
  }

  _loadADS() {
    _checkLoadAds = false;
    _adsBanner = BannerAd(
        size: AdSize.banner,
        adUnitId: GlobalHelper.defaultIdBanner,
        listener: BannerAdListener(onAdLoaded: (Ad ad) {
          if (_isShowAble()) {
            setState(() {
              _isShowAdsBanner = true;
            });
          }
          _onLoadAds();
        }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        }, onAdClicked: (Ad ad) {
          preferenceHelper.lastTimeClickAds = appProviderRead.timeServer;
          setState(() {
            _isShowAdsBanner = false;
          });
        }),
        request: const AdRequest());
    _adsBanner!.load();
    _createInterstitialAd();
  }

  bool _isShowAble() {
    final lastTimeClickedAds = preferenceHelper.lastTimeClickAds;
    // check khoang thoi gian lan cuoi cung lick quang cao
    final currentTime = appProviderRead.timeServer;
    return currentTime >= lastTimeClickedAds + GlobalHelper.defaultAdsPress;
  }

  _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: GlobalHelper.defaultIdInter,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            Future.delayed(const Duration(seconds: 10), () {
              _createInterstitialAd();
            });
          },
        ));
  }

  _onIntervalAds() {
    if (_interstitialAd == null || !_isInterstitialShowAble()) return;
    _showIntervalAds();
  }

  _showIntervalAds() {
    preferenceHelper.lastTimeShowAdsInter = appProviderRead.timeServer;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        Future.delayed(const Duration(seconds: 10), () {
          _createInterstitialAd();
        });
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        Future.delayed(const Duration(seconds: 10), () {
          _createInterstitialAd();
        });
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  bool _isInterstitialShowAble() {
    if (preferenceHelper.isPremium()) return false;
    // check ads clicked
    final lastTimeClickedAds = preferenceHelper.lastTimeClickAds;
    final currentTime = appProviderRead.timeServer;
    if (currentTime < lastTimeClickedAds + GlobalHelper.defaultAdsPress) {
      return false;
    }

    // check khoang thoi gian lan truoc hien quang cao
    final lastTimeShowAdsInter = preferenceHelper.lastTimeShowAdsInter;
    return currentTime >=
        lastTimeShowAdsInter + GlobalHelper.defaultIntervalAdsInter;
  }

  _getCountryCode() {
    dioHelper.getCountryCode().then((value) {
      if (value.isNotEmpty) preferenceHelper.countryCode = value;
    });
  }

  _getTimeServer() {
    preferenceHelper.timeServer = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    dioHelper.getTimeServer().then((timeServer) {
      if (timeServer > 0) {
        preferenceHelper.timeServer = timeServer ~/ 1000;
      }
      appProviderRead.timeServer = preferenceHelper.timeServer;
    });
  }

  _getNumberQuestion() {
    dioHelper.getNumberQuestion().then((value) {
      final questions = value?.questions;
      if (questions != null) {
        preferenceHelper.numberQuestionJson = jsonEncode(questions);
      }
    });
  }

  @override
  void dispose() {
    dioHelper.close();
    streamController.close();
    super.dispose();
    _adsBanner?.dispose();
    _interstitialAd?.dispose();
  }
}
