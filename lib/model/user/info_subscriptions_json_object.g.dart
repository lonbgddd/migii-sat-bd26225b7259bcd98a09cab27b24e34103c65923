// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_subscriptions_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoSubscriptionsJSONObject _$InfoSubscriptionsJSONObjectFromJson(
        Map<String, dynamic> json) =>
    InfoSubscriptionsJSONObject(
      json['purchase_date'] as int?,
      json['time_expired'] as int?,
    );

Map<String, dynamic> _$InfoSubscriptionsJSONObjectToJson(
        InfoSubscriptionsJSONObject instance) =>
    <String, dynamic>{
      'purchase_date': instance.purchaseDate,
      'time_expired': instance.timeExpired,
    };
