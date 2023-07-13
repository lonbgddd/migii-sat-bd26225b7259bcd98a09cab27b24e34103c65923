import 'package:collection/collection.dart';
import 'package:sprintf/sprintf.dart';

import '../helper/preference_helper.dart';

extension GetImage on String {
  String withImage({String type = "png"}) => 'assets/image/$this.$type';

  String withIcon({String type = "svg"}) => 'assets/icon/$this.$type';

  String withTrophy({String type = "png"}) => 'assets/trophy/$this.$type';
}

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);

  String get clearSpace => trim().replaceAll(" ", "").toLowerCase();

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String addDomain() {
    return "${preferenceHelper.urlDomain}$this";
  }

  String addDomainInText() {
    if (contains("<img src=\"/uploads")) {
      return replaceAll("<img src=\"/uploads",
          "<img src=\"${preferenceHelper.urlDomain}/uploads");
    }
    return this;
  }

  String get clearLatex => replaceAll("\\%", "%").replaceAll("\\\$", "\$");
}

extension EmailValid on String {
  bool isValidEmail() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

extension CheckExist on String? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }
}

extension Regex on String {
  List<String> matches(String regex) {
    return RegExp(regex)
        .allMatches(this)
        .map((e) => e.group(0))
        .toList()
        .whereNotNull()
        .toList();
  }
}

extension Purchase on String {
  String get addCurrency {
    final currencySymbol = preferenceHelper.currencySymbol;
    if (currencySymbol == "₫") return "$this ₫";
    return "$currencySymbol $this";
  }

  String get insertDotPrice {
    final length = this.length;
    if (length == 0) return this;
    var check = true;
    var priceConvert = "";
    var count = 0;
    for (var i = length - 1; i >= 0; i--) {
      final ch = this[i];
      if (ch.isNumeric) {
        priceConvert += ch;
        count++;
        if (count == 3 && i > 0) {
          priceConvert += ".";
          count = 0;
        }
      } else {
        check = false;
        break;
      }
    }
    return check ? priceConvert.split('').reversed.join('') : this;
  }

  bool get isNumeric {
    return RegExp(r'^-?[0-9]+$').hasMatch(this);
  }
}
