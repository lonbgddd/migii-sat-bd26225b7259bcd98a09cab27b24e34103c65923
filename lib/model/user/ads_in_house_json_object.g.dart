// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_in_house_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdsInHouseJSONObject _$AdsInHouseJSONObjectFromJson(
        Map<String, dynamic> json) =>
    AdsInHouseJSONObject(
      json['Ads'] == null
          ? null
          : AdsObject.fromJson(json['Ads'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdsInHouseJSONObjectToJson(
        AdsInHouseJSONObject instance) =>
    <String, dynamic>{
      'Ads': instance.ads?.toJson(),
    };

AdsObject _$AdsObjectFromJson(Map<String, dynamic> json) => AdsObject(
      json['ad_id'] as int?,
      json['ad_group_id'] as int?,
      json['country'] as String?,
      json['language'] as String?,
      json['daily'] as int?,
      (json['sale_android'] as List<dynamic>?)
          ?.map((e) => SaleObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['sale_ios'] as List<dynamic>?)
          ?.map((e) => SaleObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['sub_android'] == null
          ? null
          : BannerObject.fromJson(json['sub_android'] as Map<String, dynamic>),
      json['sub_ios'] == null
          ? null
          : BannerObject.fromJson(json['sub_ios'] as Map<String, dynamic>),
      json['top_1_android'] == null
          ? null
          : BannerObject.fromJson(
              json['top_1_android'] as Map<String, dynamic>),
      json['top_1_ios'] == null
          ? null
          : BannerObject.fromJson(json['top_1_ios'] as Map<String, dynamic>),
      (json['sub_list_android'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['sub_list_ios'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_1_list_android'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_1_list_ios'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_2_android'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_2_ios'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_3_android'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['top_3_ios'] as List<dynamic>?)
          ?.map((e) => BannerObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['end_android'] as int?,
      json['end_ios'] as int?,
      json['start_android'] as int?,
      json['start_ios'] as int?,
      json['timeServer'] as int?,
    );

Map<String, dynamic> _$AdsObjectToJson(AdsObject instance) => <String, dynamic>{
      'ad_id': instance.adId,
      'ad_group_id': instance.adGroupId,
      'country': instance.country,
      'language': instance.language,
      'daily': instance.daily,
      'sale_android': instance.saleAndroid,
      'sale_ios': instance.saleIos,
      'sub_android': instance.subAndroid,
      'sub_ios': instance.subIos,
      'top_1_android': instance.top1Android,
      'top_1_ios': instance.top1Ios,
      'sub_list_android': instance.subListAndroid,
      'sub_list_ios': instance.subListIos,
      'top_1_list_android': instance.top1ListAndroid,
      'top_1_list_ios': instance.top1ListIos,
      'top_2_android': instance.top2Android,
      'top_2_ios': instance.top2Ios,
      'top_3_android': instance.top3Android,
      'top_3_ios': instance.top3Ios,
      'end_android': instance.endAndroid,
      'end_ios': instance.endIos,
      'start_android': instance.startAndroid,
      'start_ios': instance.startIos,
      'timeServer': instance.timeServer,
    };

SaleObject _$SaleObjectFromJson(Map<String, dynamic> json) => SaleObject(
      json['premium'] as String?,
      json['percent'] as String?,
    );

Map<String, dynamic> _$SaleObjectToJson(SaleObject instance) =>
    <String, dynamic>{
      'premium': instance.premium,
      'percent': instance.percent,
    };

BannerObject _$BannerObjectFromJson(Map<String, dynamic> json) => BannerObject(
      json['action'] as String?,
      json['name'] as String?,
      json['link'] as String?,
      json['image'] as String?,
      json['title'] as String?,
      json['description'] as String?,
      json['button'] as String?,
      json['package'] as String?,
      json['isSubBanner'] as bool?,
    );

Map<String, dynamic> _$BannerObjectToJson(BannerObject instance) =>
    <String, dynamic>{
      'action': instance.action,
      'name': instance.name,
      'link': instance.link,
      'image': instance.image,
      'title': instance.title,
      'description': instance.description,
      'button': instance.button,
      'package': instance.package,
      'isSubBanner': instance.isSubBanner,
    };
