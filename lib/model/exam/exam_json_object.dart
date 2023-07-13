import 'package:json_annotation/json_annotation.dart';
import '../practice/practice_json_object.dart';
part 'exam_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamJSONObject {
  int? id;
  String? name;
  List<ExamSkill>? skills;

  @JsonKey(name: "sum_score")
  int? sumScore;

  @JsonKey(name: "count_question")
  int? countQuestion;

  int? time;

  ExamJSONObject(this.id, this.name, this.sumScore,
      this.countQuestion, this.time);

  factory ExamJSONObject.fromJson(Map<String, dynamic> json) =>
      _$ExamJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ExamJSONObjectToJson(this);
}

@JsonSerializable()
class ExamSkill {

  List<ExamPart>? parts;

  ExamSkill(this.parts);

  factory ExamSkill.fromJson(Map<String, dynamic> json) =>
      _$ExamSkillFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSkillToJson(this);
}


@JsonSerializable()
class ExamPart {
  String? title;
  List<PracticeQuestion>? question;

  ExamPart(this.title, this.question);

  factory ExamPart.fromJson(Map<String, dynamic> json) =>
      _$ExamPartFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPartToJson(this);
}