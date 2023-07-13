import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

extension Price on double {
  String convertPrice(int sale) {
    final price = sale >= 100 ? 0 : (this * 100 / (100 - sale));

    if (price > 99999) {
      return (price.round() ~/ 1000 * 1000)
          .toString()
          .insertDotPrice
          .addCurrency;
    }
    if (price > 9999) {
      return (price ~/ 100 * 100).toString().insertDotPrice.addCurrency;
    }
    if (price > 999) {
      return (price ~/ 10 * 10).toString().insertDotPrice.addCurrency;
    }
    return ((price * 100).round() / 100).toString().addCurrency;
  }

  String convertPricePerMonth(int sale, int month, String monthText) {
    final pricePerMonth =
        sale >= 100 ? 0 : ((this * 100 / (100 - sale)) / month);

    if (pricePerMonth > 99999) {
      return "${(pricePerMonth.round() ~/ 1000 * 1000).toString().insertDotPrice.addCurrency}/$monthText";
    }
    if (pricePerMonth > 9999) {
      return "${(pricePerMonth ~/ 100 * 100).toString().insertDotPrice.addCurrency}/$monthText";
    }
    if (pricePerMonth > 999) {
      return "${(pricePerMonth ~/ 10 * 10).toString().insertDotPrice.addCurrency}/$monthText";
    }
    return "${((pricePerMonth * 100).round() / 100).toString().addCurrency}/$monthText";
  }

  String convertPriceSaving(int sale, String saveText) {
    final price = sale >= 100 ? this : (this * sale / (100 - sale));

    if (price > 99999) {
      return "$saveText: ${(price.round() ~/ 1000 * 1000).toString().insertDotPrice.addCurrency}";
    }
    if (price > 9999) {
      return "$saveText: ${(price ~/ 100 * 100).toString().insertDotPrice.addCurrency}";
    }
    if (price > 999) {
      return "$saveText: ${(price ~/ 10 * 10).toString().insertDotPrice.addCurrency}";
    }
    return "$saveText: ${((price * 100).round() / 100).toString().addCurrency}";
  }

  String toStringPercent() {
    if ((this * 100).round() % 100 != 0) {
      return "${(this * 100).round() / 100}%";
    }

    if ((this * 10).round() % 10 != 0) {
      return "${(this * 10).round() / 10}%";
    }
    return "${round()}%";
  }
}
