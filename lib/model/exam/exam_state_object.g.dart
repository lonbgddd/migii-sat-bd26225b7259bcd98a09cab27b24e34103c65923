// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_state_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamStateObject _$ExamStateObjectFromJson(Map<String, dynamic> json) =>
    ExamStateObject(
      json['id'] as int?,
      json['timeRemain'] as int?,
      (json['yourAnswerMap'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            int.parse(k), ExamYourAnswer.fromJson(e as Map<String, dynamic>)),
      ),
      json['score'] as int?,
    );

Map<String, dynamic> _$ExamStateObjectToJson(ExamStateObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timeRemain': instance.timeRemain,
      'yourAnswerMap': instance.yourAnswerMap
          ?.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'score': instance.score,
    };

ExamYourAnswer _$ExamYourAnswerFromJson(Map<String, dynamic> json) =>
    ExamYourAnswer(
      yourAnswerList: (json['yourAnswerList'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      yourAnswerGridInsList: (json['yourAnswerGridInsList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExamYourAnswerToJson(ExamYourAnswer instance) =>
    <String, dynamic>{
      'yourAnswerList': instance.yourAnswerList,
      'yourAnswerGridInsList': instance.yourAnswerGridInsList,
    };
