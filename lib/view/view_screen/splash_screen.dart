import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/home_screen.dart';
import 'package:migii_sat/view/view_screen/onboarding_screen.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/screen_info.dart';

class SplashScreen extends BasePage {
  const SplashScreen({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<SplashScreen> {
  var isAnimateName = false;
  var isAnimateLogo = false;

  @override
  Widget build(BuildContext context) {
    if (!_checkDataDevice) {
      _checkDataDevice = true;
      _setDataDevice(context);

      Future.delayed(const Duration(milliseconds: 200), () async {
        setState(() {
          isAnimateName = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () async {
          setState(() {
            isAnimateLogo = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () async {
            _startNextView();
          });
        });
      });
    }

    final screenWidth = preferenceHelper.screenWidthMinimum;
    ConstraintId ivBottom = ConstraintId('iv_bottom');
    ConstraintId viewCenter = ConstraintId('view_center');
    ConstraintId viewLogo = ConstraintId('view_logo');
    ConstraintId viewName = ConstraintId('view_name');

    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF5EC5B4),
        child: ConstraintLayout(children: [
          if (Utils.isPortrait(context))
            Image.asset(
              (Utils.isTablet()
                      ? "img_splash_bottom_ipad"
                      : "img_splash_bottom")
                  .withImage(),
              width: double.infinity,
              fit: BoxFit.contain,
            ).applyConstraint(
                id: ivBottom, width: matchParent, bottom: parent.bottom),
          if (Utils.isPortrait(context)) ...[
            const SizedBox(width: 1, height: 1)
                .applyConstraint(id: viewCenter, centerTo: parent),
            SizedBox(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  "img_splash_character".withImage(),
                  fit: BoxFit.cover,
                  width: isAnimateLogo ? screenWidth / 2 : 0,
                ),
              ),
            ).applyConstraint(
                id: viewLogo,
                centerHorizontalTo: parent,
                bottom: viewCenter.top),
          ] else ...[
            SizedBox(
                child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                "img_splash_character".withImage(),
                fit: BoxFit.fitWidth,
                width: isAnimateLogo ? screenWidth / 2 : 0,
              ),
            )).applyConstraint(id: viewLogo, centerTo: parent),
          ],
          Padding(
                  padding: EdgeInsets.only(left: screenWidth / 22),
                  child: AnimatedOpacity(
                    opacity: isAnimateName ? 1.0 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      "img_splash_name".withImage(),
                      fit: BoxFit.contain,
                    ),
                  ))
              .applyConstraint(
                  id: viewName,
                  width: screenWidth / 2,
                  centerHorizontalTo: parent,
                  bottom: viewLogo.top,
                  margin: EdgeInsets.only(bottom: -screenWidth / 24)),
        ]),
      ),
    );
  }

  _startNextView() {
    RouterNavigate.pushReplacementScreen(
        context,
        preferenceHelper.didOpenOnBoarding
            ? const HomeScreen()
            : const OnBoardingScreen());
  }

  var _checkDataDevice = false;

  _setDataDevice(BuildContext context) {
    screenSize = ScreenInfo.screenSize(context);

    if (preferenceHelper.appBarHeight == 0) {
      preferenceHelper.appBarHeight = AppBar().preferredSize.height.dp();
    }

    if (preferenceHelper.paddingInsetsBottom == 0) {
      final paddingBottom = MediaQuery.of(context).padding.bottom;
      if (paddingBottom > 0) {
        preferenceHelper.paddingInsetsBottom = paddingBottom;
        Future.delayed(Duration.zero, () async {
          appProviderRead.paddingBottom = paddingBottom;
        });
      }
    }

    if (preferenceHelper.paddingInsetsTop == 0) {
      preferenceHelper.paddingInsetsTop = MediaQuery.of(context).padding.top;
    }

    if (preferenceHelper.widthScreen == 0) {
      preferenceHelper.widthScreen = MediaQuery.of(context).size.width;
    }

    if (preferenceHelper.heightScreen == 0) {
      preferenceHelper.heightScreen = MediaQuery.of(context).size.height;
    }

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      var versionApp = packageInfo.version;
      if (versionApp.isNotEmpty) {
        preferenceHelper.versionApp = versionApp;
      }
    });

    if (preferenceHelper.idDevice.isEmpty) {
      if (Platform.isIOS) {
        DeviceInfoPlugin().iosInfo.then((value) {
          var deviceId = "${value.name}:${value.identifierForVendor}";
          preferenceHelper.idDevice = deviceId;
        });
      } else if (Platform.isAndroid) {
        DeviceInfoPlugin().androidInfo.then((value) {
          var deviceId = "${value.model}:${value.device}";
          preferenceHelper.idDevice = deviceId;
        });
      }
    }

    getApplicationDocumentsDirectory().then((dir) {
      preferenceHelper.documentsPath = dir.path;
    });
  }
}
