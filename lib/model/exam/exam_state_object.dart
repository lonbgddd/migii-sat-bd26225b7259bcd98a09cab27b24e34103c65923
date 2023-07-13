import 'package:json_annotation/json_annotation.dart';

part 'exam_state_object.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamStateObject {
  int? id;
  int? timeRemain;
  Map<int, ExamYourAnswer>? yourAnswerMap;
  int? score;

  ExamStateObject(this.id, this.timeRemain, this.yourAnswerMap, this.score);

  factory ExamStateObject.fromJson(Map<String, dynamic> json) =>
      _$ExamStateObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ExamStateObjectToJson(this);
}

@JsonSerializable()
class ExamYourAnswer {
  List<int>? yourAnswerList;
  List<String>? yourAnswerGridInsList;

  ExamYourAnswer({this.yourAnswerList, this.yourAnswerGridInsList});

  factory ExamYourAnswer.fromJson(Map<String, dynamic> json) =>
      _$ExamYourAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$ExamYourAnswerToJson(this);
}
