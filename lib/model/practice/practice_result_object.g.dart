// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_result_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeResultObject _$PracticeResultObjectFromJson(
        Map<String, dynamic> json) =>
    PracticeResultObject(
      (json['items'] as List<dynamic>?)
          ?.map((e) => PracticeResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['device_id'] as String?,
    );

Map<String, dynamic> _$PracticeResultObjectToJson(
        PracticeResultObject instance) =>
    <String, dynamic>{
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'device_id': instance.deviceId,
    };

PracticeResultItem _$PracticeResultItemFromJson(Map<String, dynamic> json) =>
    PracticeResultItem(
      json['question_id'] as int?,
      json['kind_id'] as String?,
      json['sq_correct'] as int?,
      json['sq_incorrect'] as int?,
    );

Map<String, dynamic> _$PracticeResultItemToJson(PracticeResultItem instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'kind_id': instance.kindId,
      'sq_correct': instance.correct,
      'sq_incorrect': instance.incorrect,
    };
