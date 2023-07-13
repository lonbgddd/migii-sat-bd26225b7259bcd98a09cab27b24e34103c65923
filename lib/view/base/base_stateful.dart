import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/helper/event/event_helper.dart';
import '../../viewmodel/helper/language_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import '../../viewmodel/helper/provider/app_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState<T extends BasePage> extends State<T> {
  late LanguageHelper _languageHelper;
  late String _languageApp;
  late bool _isNightMode;

  late EventHelper eventHelper;

  // DownloadHelper? downloadHelper;

  @override
  void initState() {
    super.initState();
    _updateLanguage();
    _isNightMode = preferenceHelper.isNightMode;
    eventHelper = EventHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  AppLocalizations appLocalized({String languageApp = ""}) {
    if (languageApp.isNotEmpty && this._languageApp != languageApp) {
      _updateLanguage();
    }
    return _languageHelper.localizations;
  }

  _updateLanguage() {
    _languageApp = preferenceHelper.languageApp;
    _languageHelper = LanguageHelper(_languageApp);
  }

  Color theme(Color day, Color night, {bool? isNightMode}) {
    if (isNightMode != null && this._isNightMode != isNightMode) {
      this._isNightMode = isNightMode;
    }
    return _isNightMode ? night : day;
  }

  bool get isNightMode => _isNightMode;

  AppProvider get appProviderRead {
    return context.read<AppProvider>();
  }


  initDownloadHelper() {
    // downloadHelper = DownloadHelper();
  }

  @override
  void dispose() {
    eventHelper.cancel();
    // downloadHelper?.close();
    super.dispose();
  }
}
