// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_json_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeJSONObject _$PracticeJSONObjectFromJson(Map<String, dynamic> json) =>
    PracticeJSONObject(
      (json['questions'] as List<dynamic>?)
          ?.map((e) => PracticeQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['domain'] as String?,
    );

Map<String, dynamic> _$PracticeJSONObjectToJson(PracticeJSONObject instance) =>
    <String, dynamic>{
      'questions': instance.questions?.map((e) => e.toJson()).toList(),
      'domain': instance.domain,
    };

PracticeQuestion _$PracticeQuestionFromJson(Map<String, dynamic> json) =>
    PracticeQuestion(
      json['id'] as int?,
      json['subject_id'] as int?,
      json['tag_id'] as int?,
      json['kind_id'] as String?,
      json['title'] as String?,
      json['general'] == null
          ? null
          : QuestionGeneral.fromJson(json['general'] as Map<String, dynamic>),
      (json['content'] as List<dynamic>?)
          ?.map((e) => QuestionContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PracticeQuestionToJson(PracticeQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject_id': instance.subjectId,
      'tag_id': instance.tagId,
      'kind_id': instance.kindId,
      'title': instance.title,
      'general': instance.general,
      'content': instance.content,
    };

QuestionGeneral _$QuestionGeneralFromJson(Map<String, dynamic> json) =>
    QuestionGeneral(
      json['g_text'] as String?,
      json['g_text_translate'] == null
          ? null
          : GeneralTranslate.fromJson(
              json['g_text_translate'] as Map<String, dynamic>),
      json['g_image'] as String?,
    );

Map<String, dynamic> _$QuestionGeneralToJson(QuestionGeneral instance) =>
    <String, dynamic>{
      'g_text': instance.gText,
      'g_text_translate': instance.gTextTranslate,
      'g_image': instance.gImage,
    };

GeneralTranslate _$GeneralTranslateFromJson(Map<String, dynamic> json) =>
    GeneralTranslate();

Map<String, dynamic> _$GeneralTranslateToJson(GeneralTranslate instance) =>
    <String, dynamic>{};

QuestionContent _$QuestionContentFromJson(Map<String, dynamic> json) =>
    QuestionContent(
      json['q_text'] as String?,
      json['q_image'] as String?,
      (json['q_answer'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['a_image'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['q_correct'] as List<dynamic>?)?.map((e) => e as String).toList(),
      (json['e_image'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['explain'] == null
          ? null
          : ContentExplain.fromJson(json['explain'] as Map<String, dynamic>),
      yourAnswer: json['yourAnswer'] as int? ?? 0,
      yourAnswerGridIns: json['yourAnswerGridIns'] as String? ?? "",
    );

Map<String, dynamic> _$QuestionContentToJson(QuestionContent instance) =>
    <String, dynamic>{
      'q_text': instance.qText,
      'q_image': instance.qImage,
      'q_answer': instance.qAnswer,
      'a_image': instance.aImage,
      'q_correct': instance.qCorrect,
      'e_image': instance.eImage,
      'explain': instance.explain,
      'yourAnswer': instance.yourAnswer,
      'yourAnswerGridIns': instance.yourAnswerGridIns,
    };

ContentExplain _$ContentExplainFromJson(Map<String, dynamic> json) =>
    ContentExplain(
      json['en'] as String?,
    );

Map<String, dynamic> _$ContentExplainToJson(ContentExplain instance) =>
    <String, dynamic>{
      'en': instance.en,
    };
