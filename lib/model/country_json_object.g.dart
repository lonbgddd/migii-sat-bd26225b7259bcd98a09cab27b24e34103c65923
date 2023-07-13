// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryJSONObject _$CountryJSONObjectFromJson(Map<String, dynamic> json) =>
    CountryJSONObject(
      city: json['city'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      region: json['region'] as String?,
      regionName: json['regionName'] as String?,
      status: json['status'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$CountryJSONObjectToJson(CountryJSONObject instance) =>
    <String, dynamic>{
      'city': instance.city,
      'country': instance.country,
      'countryCode': instance.countryCode,
      'region': instance.region,
      'regionName': instance.regionName,
      'status': instance.status,
      'timezone': instance.timezone,
    };
