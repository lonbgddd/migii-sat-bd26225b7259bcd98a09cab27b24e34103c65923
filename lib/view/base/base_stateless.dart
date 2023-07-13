import 'package:flutter/material.dart';

import '../../viewmodel/helper/language_helper.dart';
import '../../viewmodel/helper/preference_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BasePageLess extends StatelessWidget {
  BasePageLess({super.key});

  final LanguageHelper _languageHelper =
      LanguageHelper(preferenceHelper.languageApp);
  final bool _isNightMode = preferenceHelper.isNightMode;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  AppLocalizations appLocalized({String languageApp = ""}) {
    return _languageHelper.localizations;
  }

  Color theme(Color day, Color night) {
    return _isNightMode ? night : day;
  }
}
