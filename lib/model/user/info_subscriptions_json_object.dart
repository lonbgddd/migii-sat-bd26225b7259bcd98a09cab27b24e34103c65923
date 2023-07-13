import 'package:json_annotation/json_annotation.dart';

part 'info_subscriptions_json_object.g.dart';

@JsonSerializable()
class InfoSubscriptionsJSONObject {
  @JsonKey(name: "purchase_date")
  int? purchaseDate;

  @JsonKey(name: "time_expired")
  int? timeExpired;

  InfoSubscriptionsJSONObject(this.purchaseDate, this.timeExpired);

  factory InfoSubscriptionsJSONObject.fromJson(Map<String, dynamic> json) =>
      _$InfoSubscriptionsJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$InfoSubscriptionsJSONObjectToJson(this);
}
