// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileJSONObject _$UserProfileJSONObjectFromJson(
        Map<String, dynamic> json) =>
    UserProfileJSONObject(
      id: json['id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String?,
      language: json['language'] as String?,
      isPremium: json['isPremium'] as bool?,
      premium: json['premium'] == null
          ? null
          : Premium.fromJson(json['premium'] as Map<String, dynamic>),
      statusCode: json['statusCode'] as int?,
    );

Map<String, dynamic> _$UserProfileJSONObjectToJson(
        UserProfileJSONObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatar': instance.avatar,
      'token': instance.token,
      'language': instance.language,
      'isPremium': instance.isPremium,
      'premium': instance.premium,
      'statusCode': instance.statusCode,
    };

Premium _$PremiumFromJson(Map<String, dynamic> json) => Premium(
      json['product_id'] as String?,
      json['time_expired'] as int?,
    );

Map<String, dynamic> _$PremiumToJson(Premium instance) => <String, dynamic>{
      'product_id': instance.productId,
      'time_expired': instance.timeExpired,
    };
