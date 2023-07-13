import 'package:json_annotation/json_annotation.dart';

part 'practice_history_result_object.g.dart';

@JsonSerializable(explicitToJson: true)
class PracticeHistoryResultObject {
  String? idHistory;
  List<String>? idKindList;
  int? correct;
  int? total;
  int? time;
  int? questionFormat;
  List<PracticeHistoryItem>? practiceList;

  PracticeHistoryResultObject(this.idHistory, this.idKindList, this.correct,
      this.total, this.time, this.questionFormat, this.practiceList);

  factory PracticeHistoryResultObject.fromJson(Map<String, dynamic> json) =>
      _$PracticeHistoryResultObjectFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeHistoryResultObjectToJson(this);
}

@JsonSerializable()
class PracticeHistoryItem {
  int? id;
  List<int>? yourAnswerList;
  List<String>? yourAnswerGridInsList;

  PracticeHistoryItem(this.id, this.yourAnswerList, this.yourAnswerGridInsList);

  factory PracticeHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PracticeHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeHistoryItemToJson(this);
}
