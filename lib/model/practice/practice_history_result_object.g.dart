// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_history_result_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeHistoryResultObject _$PracticeHistoryResultObjectFromJson(
        Map<String, dynamic> json) =>
    PracticeHistoryResultObject(
      json['idHistory'] as String?,
      (json['idKindList'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['correct'] as int?,
      json['total'] as int?,
      json['time'] as int?,
      json['questionFormat'] as int?,
      (json['practiceList'] as List<dynamic>?)
          ?.map((e) => PracticeHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PracticeHistoryResultObjectToJson(
        PracticeHistoryResultObject instance) =>
    <String, dynamic>{
      'idHistory': instance.idHistory,
      'idKindList': instance.idKindList,
      'correct': instance.correct,
      'total': instance.total,
      'time': instance.time,
      'questionFormat': instance.questionFormat,
      'practiceList': instance.practiceList?.map((e) => e.toJson()).toList(),
    };

PracticeHistoryItem _$PracticeHistoryItemFromJson(Map<String, dynamic> json) =>
    PracticeHistoryItem(
      json['id'] as int?,
      (json['yourAnswerList'] as List<dynamic>?)?.map((e) => e as int).toList(),
      (json['yourAnswerGridInsList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PracticeHistoryItemToJson(
        PracticeHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'yourAnswerList': instance.yourAnswerList,
      'yourAnswerGridInsList': instance.yourAnswerGridInsList,
    };
