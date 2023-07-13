import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:migii_sat/main.dart';
import 'package:migii_sat/view/base/base_stateful.dart';
import 'package:migii_sat/view/router.dart';
import 'package:migii_sat/view/view_cell/setting/setting_account_cell.dart';
import 'package:migii_sat/view/view_cell/setting/setting_description_cell.dart';
import 'package:migii_sat/view/view_cell/setting/setting_download_manament.dart';
import 'package:migii_sat/view/view_cell/setting/setting_more_app_cell.dart';
import 'package:migii_sat/view/view_cell/setting/setting_title_cell.dart';
import 'package:migii_sat/view/view_dialog/delete_account_dialog.dart';
import 'package:migii_sat/viewmodel/extensions/size_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';
import 'package:migii_sat/viewmodel/helper/dio/dio_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../viewmodel/helper/color_helper.dart';
import '../../../viewmodel/helper/event/event_helper.dart';
import '../../../viewmodel/helper/global_helper.dart';
import '../../../viewmodel/helper/local_notifications_helper.dart';
import '../../../viewmodel/helper/preference_helper.dart';
import '../../../viewmodel/helper/provider/app_provider.dart';
import '../../../viewmodel/helper/ui_font.dart';
import '../../../viewmodel/helper/utils.dart';
import '../../view_cell/setting/setting_switch_cell.dart';
import '../../view_custom/toast.dart';
import '../../view_dialog/feedback_dialog.dart';
import '../../view_dialog/language_app_dialog.dart';
import '../../view_dialog/lock_dialog.dart';
import '../../view_dialog/reminder_dialog.dart';

enum SettingType {
  account,
  updateApp,
  languageDevice,
  themeApp,
  downloadManage,
  share,
  reminder,
  feedback,
  rate,
  policy,
  moreApp,
  removeAccount,
  version
}

// ignore: must_be_immutable
class SettingTabView extends BasePage {
  VoidCallback changeLanguageListener;
  VoidCallback logOutListener;

  SettingTabView(this.changeLanguageListener, this.logOutListener, {super.key});

  @override
  BasePageState<BasePage> createState() => _State();
}

class _State extends BasePageState<SettingTabView> {
  late String _languageApp;
  late bool _isNightMode;

  @override
  void initState() {
    super.initState();
    Utils.trackerScreen("HomeScreen - Setting");
  }

  @override
  Widget build(BuildContext context) {
    _languageApp =
        context.select((AppProvider provider) => provider.languageApp);
    _isNightMode =
        context.select((AppProvider provider) => provider.isNightMode);
    context.select((AppProvider provider) => provider.isPremium);
    return viewContainer();
  }

  Widget viewContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme(ColorHelper.colorBackgroundChildDay,
          ColorHelper.colorBackgroundChildNight,
          isNightMode: _isNightMode),
      child: Column(children: [
        Container(
            width: double.infinity,
            height: preferenceHelper.appBarHeight +
                preferenceHelper.paddingInsetsTop,
            padding: EdgeInsets.only(top: preferenceHelper.paddingInsetsTop),
            decoration: BoxDecoration(
                color: ColorHelper.colorPrimary,
                boxShadow: kElevationToShadow[3]),
            child: Stack(children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  appLocalized(languageApp: _languageApp).setting,
                  style:
                      UIFont.fontAppBold(18.0.sp(), ColorHelper.colorTextNight),
                ),
              )
            ])),
        Expanded(child: listViewItem())
      ]),
    );
  }

  ListView listViewItem() {
    final userObject =
        context.select((AppProvider provider) => provider.userObject);
    String appStoreLink =
        context.select((AppProvider provider) => provider.appStoreLink);

    List<SettingType> itemMoreSections =
        _getItemSections(userObject != null, appStoreLink);

    return ListView.builder(
        key: const PageStorageKey("SettingTabView"),
        padding: EdgeInsets.only(top: 4.0.dp(), bottom: 16.0.dp()),
        itemCount: itemMoreSections.length,
        itemBuilder: (context, index) {
          return getItem(itemMoreSections[index]);
        },
        shrinkWrap: true);
  }

  Widget getItem(SettingType type) {
    switch (type) {
      case SettingType.account:
        return SettingAccountCell(widget.logOutListener);
      case SettingType.updateApp:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.languageDevice:
        return SettingDescriptionCell(context, type, _itemMoreClickListener)
            .init();
      case SettingType.themeApp:
        return SettingSwitchCell(context, type).init(_isNightMode, (isChecked) {
          preferenceHelper.isNightMode = isChecked;
          appProviderRead.isNightMode = isChecked;
        });
      case SettingType.downloadManage:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.share:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.reminder:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.feedback:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.rate:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.policy:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.moreApp:
        return SettingMoreAppCell();
      case SettingType.removeAccount:
        return SettingTitleCell(context, type, _itemMoreClickListener).init();
      case SettingType.version:
        return SettingDescriptionCell(context, type, null).init();
      default:
        return const Text("other");
    }
  }

  _itemMoreClickListener(SettingType type) {
    switch (type) {
      case SettingType.updateApp:
        String appStoreLink =
            Provider.of<AppProvider>(context, listen: false).appStoreLink;
        Utils.openLink(appStoreLink);
        break;
      case SettingType.languageDevice:
        LanguageAppDialog.show(context, () {
          appProviderRead.languageApp = preferenceHelper.languageApp;
          widget.changeLanguageListener();
        });
        break;
      case SettingType.downloadManage:
        if (!appProviderRead.isPremium) {
          LockDialog.show(context, () {});
        } else {
          RouterNavigate.pushScreen(context, DownloadManage());
        }
        break;
      case SettingType.share:
        Share.share(Platform.isAndroid
            ? "https://play.google.com/store/apps/details?id=com.eup.migiisat"
            : "https://itunes.apple.com/app/id6450196004");
        break;
      case SettingType.reminder:
        localNotificationsHelper.requestPermissions().then((bool didAllow) {
          if (!didAllow) {
            Toast(appLocalized().grant_notify, alignment: Toast.center).show();
          } else {
            ReminderDialog.show(context);
          }
        });
        break;
      case SettingType.feedback:
        FeedbackDialog.show(context);
        break;
      case SettingType.rate:
        Utils.rateApp();
        break;
      case SettingType.policy:
        Utils.openLink(GlobalHelper.urlTerms);
        break;
      case SettingType.removeAccount:
        DeleteAccountDialog.show(context, () {
          if (isInternetAvailable) {
            final accessToken = preferenceHelper.userProfile?.token;
            if (!accessToken.isNullOrEmpty) {
              appProviderRead.isProcessing = true;
              dioHelper.postDeleteAccount(accessToken!).then((isSuccess) {
                appProviderRead.isProcessing = false;
                if (isSuccess) {
                  Toast(appLocalized().account_deleted).show();
                  if (preferenceHelper.statusSignIn == 2) {
                    // nếu đăng nhập google
                    final googleSignIn =
                        GoogleSignIn(scopes: GlobalHelper.googleScopes);
                    googleSignIn.disconnect();
                  }

                  if (preferenceHelper.isPremium(isAccount: true)) {
                    preferenceHelper.setPremium(false, true);
                    preferenceHelper.setPremiumPackage("", true);
                    if (appProviderRead.isPremium) {
                      appProviderRead.isPremium = false;
                    }
                    appProviderRead.isPremium = preferenceHelper.isPremium();
                  }
                  preferenceHelper.statusSignIn = 0;
                  appProviderRead.userObject = null;
                  eventHelper.push(EventHelper.onLoginSync);
                } else {
                  Toast(appLocalized().something_wrong).show();
                }
              });
            } else {
              Toast(appLocalized().something_wrong).show();
            }
          } else {
            Toast(appLocalized().no_internet).show();
          }
        });
        break;
      default:
        break;
    }
  }

  List<SettingType> _getItemSections(bool isLogin, String appStoreLink) {
    List<SettingType> sections = [];
    sections.add(SettingType.account);
    if (appStoreLink.isNotEmpty) sections.add(SettingType.updateApp);
    sections.add(SettingType.languageDevice);
    sections.add(SettingType.themeApp);
    sections.add(SettingType.downloadManage);
    sections.add(SettingType.share);
    sections.add(SettingType.reminder);
    sections.add(SettingType.feedback);
    sections.add(SettingType.rate);
    sections.add(SettingType.policy);
    sections.add(SettingType.moreApp);
    if (isLogin) sections.add(SettingType.removeAccount);
    sections.add(SettingType.version);
    return sections;
  }
}
