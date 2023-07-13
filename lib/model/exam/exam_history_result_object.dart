import 'package:json_annotation/json_annotation.dart';

import 'exam_state_object.dart';

part 'exam_history_result_object.g.dart';

@JsonSerializable(explicitToJson: true)
class ExamHistoryResultObject {
  String? idHistory;
  int? idExam;
  String? name;
  int? score;
  int? time;
  Map<int, ExamYourAnswer>? yourAnswerMap;

  ExamHistoryResultObject(this.idHistory, this.idExam, this.name, this.score,
      this.time, this.yourAnswerMap);

  factory ExamHistoryResultObject.fromJson(Map<String, dynamic> json) =>
      _$ExamHistoryResultObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ExamHistoryResultObjectToJson(this);
}
