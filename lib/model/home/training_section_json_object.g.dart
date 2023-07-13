// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_section_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSectionJSONObject _$TrainingSectionJSONObjectFromJson(
        Map<String, dynamic> json) =>
    TrainingSectionJSONObject(
      json['section'] as String?,
      (json['kinds'] as List<dynamic>?)
          ?.map((e) => TrainingSectionKind.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TrainingSectionJSONObjectToJson(
        TrainingSectionJSONObject instance) =>
    <String, dynamic>{
      'section': instance.section,
      'kinds': instance.kinds?.map((e) => e.toJson()).toList(),
    };

TrainingSectionKind _$TrainingSectionKindFromJson(Map<String, dynamic> json) =>
    TrainingSectionKind(
      json['name'] as String?,
      (json['themes'] as List<dynamic>?)
          ?.map((e) => TrainingSectionTheme.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['icon'] as String?,
      json['is_premium'] as bool?,
    );

Map<String, dynamic> _$TrainingSectionKindToJson(
        TrainingSectionKind instance) =>
    <String, dynamic>{
      'name': instance.name,
      'themes': instance.themes,
      'icon': instance.icon,
      'is_premium': instance.isPremium,
    };

TrainingSectionTheme _$TrainingSectionThemeFromJson(
        Map<String, dynamic> json) =>
    TrainingSectionTheme(
      json['name'] as String?,
      (json['id_kind_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['default'] as int?,
      json['description'] as String?,
      json['time_multiple'] as int?,
      json['time_response'] as int?,
      json['icon'] as String?,
    );

Map<String, dynamic> _$TrainingSectionThemeToJson(
        TrainingSectionTheme instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id_kind_list': instance.idKindList,
      'default': instance.defaultQuestion,
      'description': instance.description,
      'time_multiple': instance.timeMultiple,
      'time_response': instance.timeResponse,
      'icon': instance.icon,
    };
