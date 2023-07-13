import 'package:json_annotation/json_annotation.dart';

part 'training_section_json_object.g.dart';

@JsonSerializable(explicitToJson: true)
class TrainingSectionJSONObject {
  String? section;
  List<TrainingSectionKind>? kinds;

  TrainingSectionJSONObject(this.section, this.kinds);

  factory TrainingSectionJSONObject.fromJson(Map<String, dynamic> json) =>
      _$TrainingSectionJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSectionJSONObjectToJson(this);
}

@JsonSerializable()
class TrainingSectionKind {
  String? name;
  List<TrainingSectionTheme>? themes;
  String? icon;

  @JsonKey(name: "is_premium")
  bool? isPremium;

  TrainingSectionKind(this.name, this.themes, this.icon, this.isPremium);

  factory TrainingSectionKind.fromJson(Map<String, dynamic> json) =>
      _$TrainingSectionKindFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSectionKindToJson(this);
}

@JsonSerializable()
class TrainingSectionTheme {
  String? name;

  @JsonKey(name: "id_kind_list")
  List<String>? idKindList;

  @JsonKey(name: "default")
  int? defaultQuestion;

  String? description;

  @JsonKey(name: "time_multiple")
  int? timeMultiple;

  @JsonKey(name: "time_response")
  int? timeResponse;

  String? icon;

  TrainingSectionTheme(this.name, this.idKindList, this.defaultQuestion,
      this.description, this.timeMultiple, this.timeResponse, this.icon);

  factory TrainingSectionTheme.fromJson(Map<String, dynamic> json) =>
      _$TrainingSectionThemeFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSectionThemeToJson(this);
}
