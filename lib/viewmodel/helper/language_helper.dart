import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageHelper {
  late AppLocalizations _appLocalizations;

  LanguageHelper(String languageApp) {
    switch (languageApp) {
      case "cn":
        _appLocalizations = lookupAppLocalizations(
            const Locale.fromSubtags(languageCode: 'zh'));
        break;
      case "tw":
        _appLocalizations = lookupAppLocalizations(
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
        break;
      default:
        _appLocalizations = lookupAppLocalizations(Locale(languageApp));
        break;
    }
  }

  get localizations => _appLocalizations;
}
