import 'dart:io';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:migii_sat/viewmodel/extensions/list_ext.dart';
import 'package:migii_sat/viewmodel/extensions/string_ext.dart';

import '../../viewmodel/helper/preference_helper.dart';

part 'ads_in_house_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class AdsInHouseJSONObject {
  @JsonKey(name: "Ads")
  AdsObject? ads;

  AdsInHouseJSONObject(this.ads);

  factory AdsInHouseJSONObject.fromJson(Map<String, dynamic> json) =>
      _$AdsInHouseJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AdsInHouseJSONObjectToJson(this);
}

@JsonSerializable()
class AdsObject {
  @JsonKey(name: "ad_id")
  int? adId;

  @JsonKey(name: "ad_group_id")
  int? adGroupId;

  String? country;
  String? language;
  int? daily;

  @JsonKey(name: "sale_android")
  List<SaleObject>? saleAndroid;

  @JsonKey(name: "sale_ios")
  List<SaleObject>? saleIos;

  @JsonKey(name: "sub_android")
  BannerObject? subAndroid;

  @JsonKey(name: "sub_ios")
  BannerObject? subIos;

  @JsonKey(name: "top_1_android")
  BannerObject? top1Android;

  @JsonKey(name: "top_1_ios")
  BannerObject? top1Ios;

  @JsonKey(name: "sub_list_android")
  List<BannerObject>? subListAndroid;

  @JsonKey(name: "sub_list_ios")
  List<BannerObject>? subListIos;

  @JsonKey(name: "top_1_list_android")
  List<BannerObject>? top1ListAndroid;

  @JsonKey(name: "top_1_list_ios")
  List<BannerObject>? top1ListIos;

  @JsonKey(name: "top_2_android")
  List<BannerObject>? top2Android;

  @JsonKey(name: "top_2_ios")
  List<BannerObject>? top2Ios;

  @JsonKey(name: "top_3_android")
  List<BannerObject>? top3Android;

  @JsonKey(name: "top_3_ios")
  List<BannerObject>? top3Ios;

  @JsonKey(name: "end_android")
  int? endAndroid;

  @JsonKey(name: "end_ios")
  int? endIos;

  @JsonKey(name: "start_android")
  int? startAndroid;

  @JsonKey(name: "start_ios")
  int? startIos;

  int? timeServer;

  AdsObject(
      this.adId,
      this.adGroupId,
      this.country,
      this.language,
      this.daily,
      this.saleAndroid,
      this.saleIos,
      this.subAndroid,
      this.subIos,
      this.top1Android,
      this.top1Ios,
      this.subListAndroid,
      this.subListIos,
      this.top1ListAndroid,
      this.top1ListIos,
      this.top2Android,
      this.top2Ios,
      this.top3Android,
      this.top3Ios,
      this.endAndroid,
      this.endIos,
      this.startAndroid,
      this.startIos,
      this.timeServer);

  factory AdsObject.fromJson(Map<String, dynamic> json) =>
      _$AdsObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AdsObjectToJson(this);

  List<SaleObject>? get sale {
    return Platform.isAndroid ? saleAndroid : saleIos;
  }

  BannerObject? get sub {
    return Platform.isAndroid ? subAndroid : subIos;
  }

  BannerObject? get top1 {
    return Platform.isAndroid ? top1Android : top1Ios;
  }

  List<BannerObject>? get subList {
    return Platform.isAndroid ? subListAndroid : subListIos;
  }

  List<BannerObject>? get top1List {
    return Platform.isAndroid ? top1ListAndroid : top1ListIos;
  }

  List<BannerObject>? get top2 {
    return Platform.isAndroid ? top2Android : top2Ios;
  }

  List<BannerObject>? get top3 {
    return Platform.isAndroid ? top3Android : top3Ios;
  }

  int? get end {
    return Platform.isAndroid ? endAndroid : endIos;
  }

  int? get start {
    return Platform.isAndroid ? startAndroid : startIos;
  }

  BannerObject? getBannerTop1() {
    if (preferenceHelper.adsShowTop1 % 2 == 1) {
      final subListItem = subList;
      if (!subListItem.isNullOrEmpty) {
        final subItem = subListItem![Random().nextInt(subListItem.length)];
        if (!subItem.image.isNullOrEmpty) {
          subItem.isSubBanner = true;
          return subItem;
        } else {
          for (final sub in subListItem) {
            if (!sub.image.isNullOrEmpty) {
              sub.isSubBanner = true;
              return sub;
            }
          }
        }
      }
    }

    final top1ListItem = top1List;
    if (!top1ListItem.isNullOrEmpty) {
      final topItem = top1ListItem![Random().nextInt(top1ListItem.length)];
      if (!topItem.image.isNullOrEmpty) {
        topItem.isSubBanner = false;
        return topItem;
      } else {
        for (final top in top1ListItem) {
          if (!top.image.isNullOrEmpty) {
            top.isSubBanner = false;
            return top;
          }
        }
      }
    }

    final subListItem = subList;
    if (!subListItem.isNullOrEmpty) {
      final subItem = subListItem![Random().nextInt(subListItem.length)];
      if (!subItem.image.isNullOrEmpty) {
        subItem.isSubBanner = true;
        return subItem;
      } else {
        for (final sub in subListItem) {
          if (!sub.image.isNullOrEmpty) {
            sub.isSubBanner = true;
            return sub;
          }
        }
      }
    }

    final subItem = sub;
    if (preferenceHelper.adsShowTop1 % 2 == 1 &&
        subItem != null &&
        !subItem.image.isNullOrEmpty) {
      subItem.isSubBanner = true;
      return subItem;
    }

    final top1Item = top1;
    if (top1Item != null && !top1Item.image.isNullOrEmpty) {
      top1Item.isSubBanner = false;
      return top1Item;
    }

    if (subItem != null && !subItem.image.isNullOrEmpty) {
      subItem.isSubBanner = true;
      return subItem;
    }
    return null;
  }

  List<BannerObject>? getBannerListTop2() {
    final top2Item = top2;
    if (top2Item.isNullOrEmpty) return null;
    List<BannerObject> bannerCheck = [];
    for (final banner in top2Item!) {
      if (banner.image.isNullOrEmpty) continue;
      bannerCheck.add(banner);
    }
    if (bannerCheck.isEmpty) return null;
    if (bannerCheck.length > 1) {
      bannerCheck.shuffle();
    }
    return bannerCheck;
  }

  List<BannerObject>? getBannerListTop3() {
    final top3Item = top3;
    if (top3Item.isNullOrEmpty) return null;
    List<BannerObject> bannerCheck = [];
    for (final banner in top3Item!) {
      if (banner.image.isNullOrEmpty) continue;
      bannerCheck.add(banner);
    }
    if (bannerCheck.isEmpty) return null;
    if (bannerCheck.length > 1) bannerCheck.shuffle();
    return bannerCheck;
  }
}

@JsonSerializable()
class SaleObject {
  String? premium;
  String? percent;

  SaleObject(this.premium, this.percent);

  factory SaleObject.fromJson(Map<String, dynamic> json) =>
      _$SaleObjectFromJson(json);

  Map<String, dynamic> toJson() => _$SaleObjectToJson(this);
}

@JsonSerializable()
class BannerObject {
  String? action;
  String? name;
  String? link;
  String? image;
  String? title;
  String? description;
  String? button;
  String? package;
  bool? isSubBanner;

  BannerObject(this.action, this.name, this.link, this.image, this.title,
      this.description, this.button, this.package, this.isSubBanner);

  factory BannerObject.fromJson(Map<String, dynamic> json) =>
      _$BannerObjectFromJson(json);

  Map<String, dynamic> toJson() => _$BannerObjectToJson(this);
}
