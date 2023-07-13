import 'package:json_annotation/json_annotation.dart';

part 'practice_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class PracticeJSONObject {
  List<PracticeQuestion>? questions;

  String? domain;

  PracticeJSONObject(this.questions, this.domain);

  factory PracticeJSONObject.fromJson(Map<String, dynamic> json) =>
      _$PracticeJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeJSONObjectToJson(this);
}

@JsonSerializable()
class PracticeQuestion {
  int? id;

  @JsonKey(name: "subject_id")
  int? subjectId;

  @JsonKey(name: "tag_id")
  int? tagId;

  @JsonKey(name: "kind_id")
  String? kindId;

  String? title;
  QuestionGeneral? general;
  List<QuestionContent>? content;

  PracticeQuestion(this.id, this.subjectId, this.tagId, this.kindId, this.title,
      this.general, this.content);

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) =>
      _$PracticeQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeQuestionToJson(this);
}

@JsonSerializable()
class QuestionGeneral {
  @JsonKey(name: "g_text")
  String? gText;

  @JsonKey(name: "g_text_translate")
  GeneralTranslate? gTextTranslate;

  @JsonKey(name: "g_image")
  String? gImage;

  QuestionGeneral(this.gText, this.gTextTranslate, this.gImage);

  factory QuestionGeneral.fromJson(Map<String, dynamic> json) =>
      _$QuestionGeneralFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionGeneralToJson(this);
}

@JsonSerializable()
class GeneralTranslate {
  GeneralTranslate();

  factory GeneralTranslate.fromJson(Map<String, dynamic> json) =>
      _$GeneralTranslateFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralTranslateToJson(this);
}

@JsonSerializable()
class QuestionContent {
  @JsonKey(name: "q_text")
  String? qText;

  @JsonKey(name: "q_image")
  String? qImage;

  @JsonKey(name: "q_answer")
  List<String>? qAnswer;

  @JsonKey(name: "a_image")
  List<String>? aImage;

  @JsonKey(name: "q_correct")
  List<String>? qCorrect;

  @JsonKey(name: "e_image")
  List<String>? eImage;

  ContentExplain? explain;

  var yourAnswer = 0;
  var yourAnswerGridIns = "";

  QuestionContent(this.qText, this.qImage, this.qAnswer, this.aImage,
      this.qCorrect, this.eImage, this.explain,
      {this.yourAnswer = 0, this.yourAnswerGridIns = ""});

  factory QuestionContent.fromJson(Map<String, dynamic> json) =>
      _$QuestionContentFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionContentToJson(this);
}

@JsonSerializable()
class ContentExplain {
  String? en;

  ContentExplain(this.en);

  factory ContentExplain.fromJson(Map<String, dynamic> json) =>
      _$ContentExplainFromJson(json);

  Map<String, dynamic> toJson() => _$ContentExplainToJson(this);
}
