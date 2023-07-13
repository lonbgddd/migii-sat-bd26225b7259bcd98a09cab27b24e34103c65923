import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_screen/user/register_screen.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/color_helper.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../main.dart';
import '../../../viewmodel/helper/animation/shake.dart';
import '../../../viewmodel/helper/dio/dio_helper.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_custom/bounce_widget.dart';
import '../../view_custom/dashed_line_vertical_painter.dart';
import '../../view_custom/highlight_text.dart';
import '../../view_custom/toast.dart';

class LogInScreen extends BasePage {
  const LogInScreen({super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<LogInScreen> {
  String email = "";
  String password = "";

  String loginWarning = "";
  String emailWarning = "";
  String passwordWarning = "";

  int signInStatus = 0;

  final _keyEmail = GlobalKey<ShakeState>();
  final _keyPassword = GlobalKey<ShakeState>();

  bool checkBoxState = true;
  bool didFillContent = false;

  bool isLoadingEmail = false;
  bool isLoadingGoogle = false;
  bool isLoadingApple = false;

  bool get isLoading {
    return isLoadingEmail || isLoadingGoogle || isLoadingApple;
  }

  @override
  void initState() {
    super.initState();
    Utils.trackerScreen("LogInScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      width: double.infinity,
      height: double.infinity,
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "img_background_practice".withImage(),
                width: double.infinity,
                fit: BoxFit.contain,
              )),
          Column(children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
              decoration: BoxDecoration(
                  color: ColorHelper.colorPrimary,
                  boxShadow: kElevationToShadow[3]),
              child: SizedBox(
                  height: preferenceHelper.appBarHeight,
                  child: Stack(children: [
                    BounceWidget(
                        child: Container(
                          width: preferenceHelper.appBarHeight,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "ic_back".withIcon(),
                            width: 20.0.dp(),
                            height: 20.0.dp(),
                            color: Colors.white,
                          ),
                        ),
                        onPress: () {
                          Navigator.pop(context);
                        }),
                    Center(
                      child: Text(
                        appLocalized().log_in,
                        style: UIFont.fontAppBold(
                            17.0.sp(), ColorHelper.colorTextNight),
                      ),
                    )
                  ])),
            ),
            Expanded(child: viewContainer())
          ])
        ],
      ),
    ));
  }

  Widget viewContainer() {
    final paddingBottom =
        context.select((AppProvider provider) => provider.paddingBottom);
    final bannerHeight =
        context.select((AppProvider provider) => provider.bannerHeight);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenWidthMinimum = preferenceHelper.screenWidthMinimum;

    return SingleChildScrollView(
        child: Column(children: [
      Container(
        width: max(screenWidthMinimum / 4 - keyboardHeight, 0),
        height: max(screenWidthMinimum / 4 - keyboardHeight, 0),
        margin: EdgeInsets.only(top: 16.0.dp()),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidthMinimum / 8),
            color: ColorHelper.colorBackgroundChildDay,
            border: Border.all(
                color: theme(ColorHelper.colorTextGreenDay,
                    ColorHelper.colorTextGreenNight,
                    isNightMode: isNightMode),
                width: 1.0.dp())),
        child: Image.asset("img_logo_migii_character".withImage()),
      ),
      Container(
        alignment: Alignment.topCenter,
        height: max(44.0.dp() - keyboardHeight, 0),
        padding: EdgeInsets.only(top: 4.0.dp()),
        child: Text(
          "Migii SAT",
          style: UIFont.fontAppBold(
              17.0.sp(),
              theme(ColorHelper.colorTextGreenDay,
                  ColorHelper.colorTextGreenNight)),
        ),
      ),
      if (loginWarning.isNotEmpty)
        FractionallySizedBox(
          widthFactor: 0.8,
          child: Row(children: [
            SvgPicture.asset(
              "ic_warning".withIcon(),
              width: 14.0.dp(),
              height: 14.0.dp(),
              color: ColorHelper.colorRed,
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 8.0.dp(), bottom: 2.0.dp()),
                  child: Text(loginWarning,
                      style:
                          UIFont.fontAppBold(13.0.sp(), ColorHelper.colorRed))),
            )
          ]),
        ),
      SizedBox(height: 4.0.dp()),
      _loginTextField("ic_email_2", appLocalized().email, emailWarning,
          _keyEmail, TextInputType.emailAddress, false, (content) {
        email = content;
        if (emailWarning.isNotEmpty) {
          setState(() {
            emailWarning = "";
          });
        }
        _valueChangeListener();
      }),
      _loginTextField("ic_password", appLocalized().password, passwordWarning,
          _keyPassword, TextInputType.text, true, (content) {
        password = content.trim();
        if (passwordWarning.isNotEmpty) {
          setState(() {
            passwordWarning = "";
          });
        }
        _valueChangeListener();
      }),
      SizedBox(height: 8.0.dp()),
      FractionallySizedBox(
        widthFactor: Utils.isTablet() ? 0.8 : 0.85,
        child: Row(children: [
          Transform.scale(
              scale: 1.3,
              child: Checkbox(
                checkColor: Colors.white,
                activeColor: ColorHelper.colorPrimary,
                value: checkBoxState,
                onChanged: (bool? value) {
                  setState(() {
                    checkBoxState = value!;
                  });
                },
                side: BorderSide(
                    width: 1.0.dp(),
                    color:
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0.dp())),
              )),
          Expanded(
              child: HighlightText(
            text: appLocalized().login_agree_text,
            style: UIFont.fontApp(14.0.sp(),
                theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
            spanList: [
              SpanItem(
                  text: appLocalized().login_agree_text_key,
                  onTap: () {
                    Utils.openLink(GlobalHelper.urlTerms);
                  })
            ],
            spanStyle: UIFont.fontApp(14.0.sp(), ColorHelper.colorAccent,
                decoration: TextDecoration.underline,
                decorationThickness: 1,
                underlineSpace: 1),
          )),
        ]),
      ),
      SizedBox(height: 20.0.dp()),
      isLoadingEmail
          ? Container(
              alignment: Alignment.center,
              child: SizedBox(
                  width: 44.0.dp(),
                  height: 44.0.dp(),
                  child: const LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: [ColorHelper.colorPrimary])))
          : FractionallySizedBox(
              widthFactor: 0.66,
              child: GestureDetector(
                onTap: () {
                  if (isLoading) return;
                  _handleLogin();
                },
                child: Card(
                  elevation: 4.0.dp(),
                  margin: EdgeInsets.zero,
                  color: ColorHelper.colorPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0.dp())),
                  child: Container(
                    height: 44.0.dp(),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 2.0.dp()),
                    child: Text(
                      appLocalized().log_in,
                      style: UIFont.fontAppBold(
                          15.0.sp(), ColorHelper.colorTextNight),
                    ),
                  ),
                ),
              ),
            ),
      SizedBox(height: max(20.0.dp() - keyboardHeight, 0)),
      FractionallySizedBox(
          widthFactor: 0.66,
          child: SizedBox(
            height: max(24.0.dp() - keyboardHeight, 0),
            child: Row(children: [
              SizedBox(width: 12.0.dp()),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(top: 4.0.dp()),
                      height: 1.5.dp(),
                      color: theme(ColorHelper.colorTextDay2,
                          ColorHelper.colorTextNight2))),
              SizedBox(width: 8.0.dp()),
              Text(
                appLocalized().or,
                style: UIFont.fontAppBold(
                    15.0.sp(),
                    theme(ColorHelper.colorTextDay2,
                        ColorHelper.colorTextNight2)),
              ),
              SizedBox(width: 8.0.dp()),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(top: 4.0.dp()),
                      height: 1.5.dp(),
                      color: theme(ColorHelper.colorTextDay2,
                          ColorHelper.colorTextNight2))),
              SizedBox(width: 12.0.dp())
            ]),
          )),
      if (isLoadingGoogle) ...[
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 16.0.dp()),
            child: SizedBox(
                width: 44.0.dp(),
                height: 44.0.dp(),
                child: const LoadingIndicator(
                    indicatorType: Indicator.lineSpinFadeLoader,
                    colors: [ColorHelper.colorRed]))),
      ] else ...[
        SizedBox(height: max(16.0.dp() - keyboardHeight, 0)),
        FractionallySizedBox(
          widthFactor: 0.66,
          child: GestureDetector(
            onTap: () {
              if (isLoading) return;
              _handleLoginGoogle();
            },
            child: Card(
                elevation: 4.0.dp(),
                margin: EdgeInsets.zero,
                color: ColorHelper.colorBackgroundChildDay,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0.dp())),
                child: SizedBox(
                    height: max(44.0.dp() - keyboardHeight, 0),
                    child: Row(children: [
                      SizedBox(width: 12.0.dp()),
                      SvgPicture.asset("ic_google".withIcon(),
                          width: 16.0.dp(), height: 16.0.dp()),
                      Expanded(
                          child: Center(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                            child: AutoSizeText(
                              appLocalized().login_google,
                              style: UIFont.fontAppBold(
                                  15.0.sp(), ColorHelper.colorTextDay),
                              minFontSize: 8.0.sp(),
                            )),
                      ))
                    ]))),
          ),
        )
      ],
      if (Platform.isIOS)
        if (isLoadingApple) ...[
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 16.0.dp()),
              child: SizedBox(
                  width: 44.0.dp(),
                  height: 44.0.dp(),
                  child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: [
                        theme(ColorHelper.colorTextDay2,
                            ColorHelper.colorTextNight2)
                      ]))),
        ] else ...[
          SizedBox(height: max(16.0.dp() - keyboardHeight, 0)),
          FractionallySizedBox(
            widthFactor: 0.66,
            child: GestureDetector(
              onTap: () {
                if (isLoading) return;
                _handleLoginApple();
              },
              child: Card(
                  elevation: 4.0.dp(),
                  margin: EdgeInsets.zero,
                  color: ColorHelper.colorBackgroundChildDay,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0.dp())),
                  child: SizedBox(
                      height: max(44.0.dp() - keyboardHeight, 0),
                      child: Row(children: [
                        SizedBox(width: 12.0.dp()),
                        SvgPicture.asset("ic_apple".withIcon(),
                            width: 16.0.dp(), height: 16.0.dp()),
                        Expanded(
                            child: Center(
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  12.0.dp(), 0, 12.0.dp(), 2.0.dp()),
                              child: AutoSizeText(
                                appLocalized().login_apple,
                                style: UIFont.fontAppBold(
                                    15.0.sp(), ColorHelper.colorTextDay),
                                minFontSize: 8.0.sp(),
                              )),
                        ))
                      ]))),
            ),
          )
        ],
      SizedBox(height: 20.0.dp()),
      FractionallySizedBox(
        widthFactor: 0.8,
        child: HighlightText(
          text: appLocalized().not_account,
          style: UIFont.fontApp(14.0.sp(),
              theme(ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
          spanList: [
            SpanItem(
                text: appLocalized().not_account_key,
                onTap: () {
                  if (isLoading) return;
                  RouterNavigate.pushReplacementScreen(
                      context, const RegisterScreen());
                })
          ],
          spanStyle: UIFont.fontAppBold(
              14.0.sp(),
              theme(ColorHelper.colorTextGreenDay,
                  ColorHelper.colorTextGreenNight),
              decoration: TextDecoration.underline),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(
          height: 24.0.dp() + max(keyboardHeight - bannerHeight, paddingBottom))
    ]));
  }

  Widget _loginTextField(
      String icon,
      String placeHolder,
      String warning,
      GlobalKey<ShakeState>? key,
      TextInputType? keyboardType,
      bool obscureText,
      Function(String content)? contentChange) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Column(children: [
        Shake(
          key: key,
          child: Container(
            margin: EdgeInsets.only(top: 8.0.dp()),
            width: double.infinity,
            height: 52.0.dp(),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1.0.dp(),
                  color: warning.isEmpty
                      ? theme(ColorHelper.colorTextDay2,
                          ColorHelper.colorTextNight2)
                      : ColorHelper.colorRed),
              borderRadius: BorderRadius.all(Radius.circular(26.0.dp())),
            ),
            child: Row(children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(18.0.dp(), 0, 12.0.dp(), 0),
                  child: SvgPicture.asset(
                    icon.withIcon(),
                    width: 18.0.dp(),
                    height: 18.0.dp(),
                    color: warning.isEmpty
                        ? theme(
                        ColorHelper.colorGray, ColorHelper.colorGray2)
                        : ColorHelper.colorRed,
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 4.0.dp(), bottom: 4.0.dp()),
                  child: DashedLineVerticalPainter(
                    width: 1.0.dp(),
                    dashHeight: 3.0.dp(),
                    color: warning.isEmpty
                        ? theme(ColorHelper.colorGray, ColorHelper.colorGray2)
                        : ColorHelper.colorRed,
                  )),
              SizedBox(width: 12.0.dp()),
              Expanded(
                  child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: placeHolder,
                    hintStyle: UIFont.fontApp(15.0.sp(),
                        theme(ColorHelper.colorGray, ColorHelper.colorGray2))),
                style: UIFont.fontApp(
                    15.0.sp(),
                    theme(
                        ColorHelper.colorTextDay, ColorHelper.colorTextNight)),
                onChanged: (text) {
                  if (contentChange != null) {
                    contentChange(text);
                  }
                },
                keyboardType: keyboardType,
                obscureText: obscureText,
              )),
            ]),
          ),
        ),
        if (warning.isNotEmpty)
          Padding(
              padding: EdgeInsets.fromLTRB(10.0.dp(), 2.0.dp(), 10.0.dp(), 0),
              child: Row(children: [
                SvgPicture.asset(
                  "ic_warning".withIcon(),
                  width: 14.0.dp(),
                  height: 14.0.dp(),
                  color: ColorHelper.colorRed,
                ),
                Expanded(
                  child: Padding(
                      padding:
                          EdgeInsets.only(left: 8.0.dp(), bottom: 2.0.dp()),
                      child: Text(warning,
                          style: UIFont.fontAppBold(
                              12.0.sp(), ColorHelper.colorRed))),
                )
              ])),
        SizedBox(height: 8.0.dp())
      ]),
    );
  }

  _handleLogin() {
    signInStatus = 1;
    _resetViewWarning();

    if (email.trim().isNotEmpty) {
      if (!email.isValidEmail()) {
        _keyEmail.currentState?.shake();
        setState(() {
          emailWarning = appLocalized().invalid_email;
        });
        return;
      }
    } else {
      _keyEmail.currentState?.shake();
      setState(() {
        emailWarning = appLocalized().can_not_null;
      });
      return;
    }

    if (password.isNotEmpty) {
      if (password.length < 6) {
        _keyPassword.currentState?.shake();
        setState(() {
          passwordWarning = appLocalized().invalid_password;
        });
        return;
      }
    } else {
      _keyPassword.currentState?.shake();
      setState(() {
        passwordWarning = appLocalized().can_not_null;
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (isInternetAvailable) {
      if (!checkBoxState) return;

      setState(() {
        isLoadingEmail = true;
      });

      Utils.trackerEvent("LOGIN", "Login Email");
      final device = preferenceHelper.idDevice.split(":").firstOrNull ?? "";
      dioHelper
          .postLoginEmail(
              email,
              password,
              preferenceHelper.idDevice,
              device,
              Platform.operatingSystem,
              Platform.operatingSystemVersion,
              preferenceHelper.versionApp)
          .then((userProfile) {
        setState(() {
          isLoadingEmail = false;
        });

        if (userProfile == null) {
          setState(() {
            loginWarning = appLocalized().signin_error;
          });
          return;
        }

        if (!userProfile.token.isNullOrEmpty) {
          preferenceHelper.statusSignIn = signInStatus;
          preferenceHelper.userProfileJson = jsonEncode(userProfile);
          Toast(appLocalized().sign_in_successful, alignment: Toast.center)
              .show();
          appProviderRead.userObject = userProfile;
          Utils.trackerEvent("LOGIN", "login_success");
          eventHelper.push(EventHelper.onLoginSync);
          Navigator.pop(context);
        } else if (userProfile.statusCode == 401) {
          preferenceHelper.statusSignIn = 0;
          setState(() {
            loginWarning = appLocalized().account_not_correct;
          });
        } else {
          preferenceHelper.statusSignIn = 0;
          setState(() {
            loginWarning = appLocalized().signin_error;
          });
        }
      });
    } else {
      setState(() {
        loginWarning = appLocalized().no_connect;
      });
    }
  }

  _handleLoginGoogle() async {
    if (isLoading) return;

    signInStatus = 2;
    _resetViewWarning();

    FocusManager.instance.primaryFocus?.unfocus();

    if (isInternetAvailable) {
      if (!checkBoxState) return;

      setState(() {
        isLoadingGoogle = true;
      });

      GoogleSignInAccount? userData;
      try {
        userData = await _googleSignIn.signIn();
      } catch (_) {
        userData = null;
      }

      if (!mounted) return;
      if (userData == null) {
        setState(() {
          isLoadingGoogle = false;
          loginWarning = appLocalized().signin_error;
        });
        return;
      }

      GoogleSignInAuthentication? googleKey;
      try {
        googleKey = await userData.authentication;
      } catch (_) {
        googleKey = null;
      }

      if (!mounted) return;
      if (googleKey == null) {
        setState(() {
          isLoadingGoogle = false;
          loginWarning = appLocalized().signin_error;
        });
        return;
      }

      final idToken = googleKey.idToken;
      if (idToken.isNullOrEmpty) {
        setState(() {
          isLoadingGoogle = false;
          loginWarning = appLocalized().signin_error;
        });
        return;
      }

      Utils.trackerEvent("LOGIN", "Login Google");
      final device = preferenceHelper.idDevice.split(":").firstOrNull ?? "";
      dioHelper
          .postLoginGoogle(
              idToken!,
              preferenceHelper.idDevice,
              device,
              Platform.operatingSystem,
              Platform.operatingSystemVersion,
              preferenceHelper.versionApp)
          .then((userProfile) {
        if (!mounted) return;

        setState(() {
          isLoadingGoogle = false;
        });

        if (userProfile == null) {
          setState(() {
            loginWarning = appLocalized().signin_error;
          });
          return;
        }

        if (!userProfile.token.isNullOrEmpty) {
          preferenceHelper.statusSignIn = signInStatus;
          preferenceHelper.userProfileJson = jsonEncode(userProfile);
          Toast(appLocalized().sign_in_successful, alignment: Toast.center)
              .show();
          appProviderRead.userObject = userProfile;
          Utils.trackerEvent("LOGIN", "login_success");
          eventHelper.push(EventHelper.onLoginSync);
          Navigator.pop(context);
        } else {
          preferenceHelper.statusSignIn = 0;
          setState(() {
            loginWarning = appLocalized().signin_error;
          });
        }
      });
    } else {
      setState(() {
        loginWarning = appLocalized().no_connect;
      });
    }
  }

  _handleLoginApple() {
    if (isLoading) return;

    signInStatus = 3;
    _resetViewWarning();

    FocusManager.instance.primaryFocus?.unfocus();

    if (isInternetAvailable) {
      if (!checkBoxState) return;

      SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]).then((credential) {
        if (!mounted) return;

        final appleIDToken = credential.identityToken;
        if (appleIDToken.isNullOrEmpty) {
          setState(() {
            loginWarning = appLocalized().signin_error;
          });
          return;
        }

        var fullName =
            "${credential.familyName ?? ""} ${credential.givenName ?? ""}"
                .trim();
        _checkAppleFullName(fullName, (name) {
          Utils.trackerEvent("LOGIN", "Login Apple");

          setState(() {
            isLoadingApple = true;
          });

          final device = preferenceHelper.idDevice.split(":").firstOrNull ?? "";
          dioHelper
              .postLoginApple(
                  appleIDToken!,
                  fullName,
                  preferenceHelper.idDevice,
                  device,
                  Platform.operatingSystem,
                  Platform.operatingSystemVersion,
                  preferenceHelper.versionApp)
              .then((userProfile) {
            if (!mounted) return;

            setState(() {
              isLoadingApple = false;
            });

            if (userProfile == null) {
              setState(() {
                loginWarning = appLocalized().signin_error;
              });
              return;
            }

            if (!userProfile.token.isNullOrEmpty) {
              preferenceHelper.statusSignIn = signInStatus;
              preferenceHelper.userProfileJson = jsonEncode(userProfile);
              Toast(appLocalized().sign_in_successful, alignment: Toast.center)
                  .show();
              appProviderRead.userObject = userProfile;
              Utils.trackerEvent("LOGIN", "login_success");
              eventHelper.push(EventHelper.onLoginSync);
              Navigator.pop(context);
            } else {
              preferenceHelper.statusSignIn = 0;
              setState(() {
                loginWarning = appLocalized().signin_error;
              });
            }
          });
        });
      });
    } else {
      setState(() {
        loginWarning = appLocalized().no_connect;
      });
    }
  }

  _resetViewWarning() {
    setState(() {
      loginWarning = "";
      emailWarning = "";
      passwordWarning = "";
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: GlobalHelper.googleScopes,
  );

  _checkAppleFullName(String fullName, Function(String fullname) callback) {
    if (fullName.isEmpty) {
      const FlutterSecureStorage()
          .read(key: "com.eup.migiisat_fullname")
          .then((value) {
        callback(value ?? "");
      });
    } else {
      _saveUserInKeychain(fullName);
      callback(fullName);
    }
  }

  _saveUserInKeychain(String fullName) async {
    await const FlutterSecureStorage()
        .write(key: "com.eup.migiisat_fullname", value: fullName);
  }

  _valueChangeListener() {
    if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
      if (!didFillContent) {
        setState(() {
          didFillContent = true;
        });
      }
    } else {
      if (didFillContent) {
        setState(() {
          didFillContent = false;
        });
      }
    }
  }
}
