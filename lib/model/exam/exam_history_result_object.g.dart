// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_history_result_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamHistoryResultObject _$ExamHistoryResultObjectFromJson(
        Map<String, dynamic> json) =>
    ExamHistoryResultObject(
      json['idHistory'] as String?,
      json['idExam'] as int?,
      json['name'] as String?,
      json['score'] as int?,
      json['time'] as int?,
      (json['yourAnswerMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            int.parse(k), ExamYourAnswer.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ExamHistoryResultObjectToJson(
        ExamHistoryResultObject instance) =>
    <String, dynamic>{
      'idHistory': instance.idHistory,
      'idExam': instance.idExam,
      'name': instance.name,
      'score': instance.score,
      'time': instance.time,
      'yourAnswerMap': instance.yourAnswerMap
          ?.map((k, e) => MapEntry(k.toString(), e.toJson())),
    };
