import 'package:json_annotation/json_annotation.dart';

part 'exam_list_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamListJSONObject {
  @JsonKey(name: "exams")
  List<ExamListQuestion>? exams;

  ExamListJSONObject(this.exams);

  factory ExamListJSONObject.fromJson(Map<String, dynamic> json) =>
      _$ExamListJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ExamListJSONObjectToJson(this);
}

@JsonSerializable()
class ExamListQuestion {
  int? id;
  String? name;
  @JsonKey(name: "sum_score")
  int? sumScore;
  int? premium;

  ExamListQuestion(this.id, this.name, this.sumScore, this.premium);

  factory ExamListQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamListQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$ExamListQuestionToJson(this);
}
