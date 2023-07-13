import 'package:provider/provider.dart';

import '../../viewmodel/helper/provider/app_provider.dart';
import '../../viewmodel/helper/language_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../viewmodel/helper/preference_helper.dart';
import 'package:flutter/material.dart';

class BaseView {
  final BuildContext context;
  late LanguageHelper _languageHelper;
  late String _languageApp;
  late bool _isNightMode;

  BaseView(this.context) {
    _updateLanguage();
    _isNightMode = preferenceHelper.isNightMode;
  }

  AppLocalizations appLocalized({String languageApp = ""}) {
    if (languageApp.isNotEmpty && _languageApp != languageApp) {
      _updateLanguage();
    }
    return _languageHelper.localizations;
  }

  _updateLanguage() {
    _languageApp = preferenceHelper.languageApp;
    _languageHelper = LanguageHelper(_languageApp);
  }

  Color theme(Color day, Color night, {bool? isNightMode}) {
    if (isNightMode != null && _isNightMode != isNightMode) {
      _isNightMode = isNightMode;
    }
    return _isNightMode ? night : day;
  }

  get isNightMode => _isNightMode;

  AppProvider get appProviderRead {
    return context.read<AppProvider>();
  }
}
