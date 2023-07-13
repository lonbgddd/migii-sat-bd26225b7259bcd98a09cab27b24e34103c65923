import 'package:json_annotation/json_annotation.dart';
part 'number_question_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class NumberQuestionJSONObject {
  NumberQuestionObject? questions;

  NumberQuestionJSONObject(this.questions);

  factory NumberQuestionJSONObject.fromJson(Map<String, dynamic> json) =>
      _$NumberQuestionJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$NumberQuestionJSONObjectToJson(this);
}

@JsonSerializable()
class NumberQuestionObject {
  @JsonKey(name: "kind_id")
  List<NumberQuestionKind>? kind;

  NumberQuestionObject(this.kind);

  factory NumberQuestionObject.fromJson(Map<String, dynamic> json) =>
      _$NumberQuestionObjectFromJson(json);

  Map<String, dynamic> toJson() => _$NumberQuestionObjectToJson(this);
}

@JsonSerializable()
class NumberQuestionKind {
  @JsonKey(name: "kind_id")
  String? kindId;

  int? detail;

  NumberQuestionKind(this.kindId, this.detail);

  factory NumberQuestionKind.fromJson(Map<String, dynamic> json) =>
      _$NumberQuestionKindFromJson(json);

  Map<String, dynamic> toJson() => _$NumberQuestionKindToJson(this);
}
