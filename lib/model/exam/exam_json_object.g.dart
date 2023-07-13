// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamJSONObject _$ExamJSONObjectFromJson(Map<String, dynamic> json) =>
    ExamJSONObject(
      json['id'] as int?,
      json['name'] as String?,
      json['sum_score'] as int?,
      json['count_question'] as int?,
      json['time'] as int?,
    )..skills = (json['skills'] as List<dynamic>?)
        ?.map((e) => ExamSkill.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$ExamJSONObjectToJson(ExamJSONObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skills': instance.skills?.map((e) => e.toJson()).toList(),
      'sum_score': instance.sumScore,
      'count_question': instance.countQuestion,
      'time': instance.time,
    };

ExamSkill _$ExamSkillFromJson(Map<String, dynamic> json) => ExamSkill(
      (json['parts'] as List<dynamic>?)
          ?.map((e) => ExamPart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamSkillToJson(ExamSkill instance) => <String, dynamic>{
      'parts': instance.parts,
    };

ExamPart _$ExamPartFromJson(Map<String, dynamic> json) => ExamPart(
      json['title'] as String?,
      (json['question'] as List<dynamic>?)
          ?.map((e) => PracticeQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamPartToJson(ExamPart instance) => <String, dynamic>{
      'title': instance.title,
      'question': instance.question,
    };
