import 'package:json_annotation/json_annotation.dart';

part 'time_server_json_object.g.dart';

@JsonSerializable()
class TimeServerJSONObject {
  int? time;

  TimeServerJSONObject(this.time);

  factory TimeServerJSONObject.fromJson(Map<String, dynamic> json) =>
      _$TimeServerJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$TimeServerJSONObjectToJson(this);
}
