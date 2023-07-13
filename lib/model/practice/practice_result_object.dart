import 'package:json_annotation/json_annotation.dart';

part 'practice_result_object.g.dart';

@JsonSerializable(explicitToJson: true)
class PracticeResultObject {
  List<PracticeResultItem>? items;

  @JsonKey(name: "device_id")
  String? deviceId;

  PracticeResultObject(this.items, this.deviceId);

  factory PracticeResultObject.fromJson(Map<String, dynamic> json) =>
      _$PracticeResultObjectFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeResultObjectToJson(this);
}

@JsonSerializable()
class PracticeResultItem {
  @JsonKey(name: "question_id")
  int? questionId;

  @JsonKey(name: "kind_id")
  String? kindId;

  @JsonKey(name: "sq_correct")
  int? correct;

  @JsonKey(name: "sq_incorrect")
  int? incorrect;

  PracticeResultItem(
      this.questionId, this.kindId, this.correct, this.incorrect);

  factory PracticeResultItem.fromJson(Map<String, dynamic> json) =>
      _$PracticeResultItemFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeResultItemToJson(this);
}
