// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_list_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamListJSONObject _$ExamListJSONObjectFromJson(Map<String, dynamic> json) =>
    ExamListJSONObject(
      (json['exams'] as List<dynamic>?)
          ?.map((e) => ExamListQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamListJSONObjectToJson(ExamListJSONObject instance) =>
    <String, dynamic>{
      'exams': instance.exams?.map((e) => e.toJson()).toList(),
    };

ExamListQuestion _$ExamListQuestionFromJson(Map<String, dynamic> json) =>
    ExamListQuestion(
      json['id'] as int?,
      json['name'] as String?,
      json['sum_score'] as int?,
      json['premium'] as int?,
    );

Map<String, dynamic> _$ExamListQuestionToJson(ExamListQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sum_score': instance.sumScore,
      'premium': instance.premium,
    };
