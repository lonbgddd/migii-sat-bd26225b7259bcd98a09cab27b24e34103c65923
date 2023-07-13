import 'package:json_annotation/json_annotation.dart';

part 'ads_in_house_message_json_object.g.dart';

@JsonSerializable()
class AdsInHouseMessageJSONObject {
  int? status;
  String? message;

  AdsInHouseMessageJSONObject(this.status, this.message);

  factory AdsInHouseMessageJSONObject.fromJson(Map<String, dynamic> json) =>
      _$AdsInHouseMessageJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$AdsInHouseMessageJSONObjectToJson(this);
}
