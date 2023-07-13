// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'number_question_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NumberQuestionJSONObject _$NumberQuestionJSONObjectFromJson(
        Map<String, dynamic> json) =>
    NumberQuestionJSONObject(
      json['questions'] == null
          ? null
          : NumberQuestionObject.fromJson(
              json['questions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NumberQuestionJSONObjectToJson(
        NumberQuestionJSONObject instance) =>
    <String, dynamic>{
      'questions': instance.questions?.toJson(),
    };

NumberQuestionObject _$NumberQuestionObjectFromJson(
        Map<String, dynamic> json) =>
    NumberQuestionObject(
      (json['kind_id'] as List<dynamic>?)
          ?.map((e) => NumberQuestionKind.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NumberQuestionObjectToJson(
        NumberQuestionObject instance) =>
    <String, dynamic>{
      'kind_id': instance.kind,
    };

NumberQuestionKind _$NumberQuestionKindFromJson(Map<String, dynamic> json) =>
    NumberQuestionKind(
      json['kind_id'] as String?,
      json['detail'] as int?,
    );

Map<String, dynamic> _$NumberQuestionKindToJson(NumberQuestionKind instance) =>
    <String, dynamic>{
      'kind_id': instance.kindId,
      'detail': instance.detail,
    };
