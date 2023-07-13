import 'package:json_annotation/json_annotation.dart';

part 'user_profile_json_object.g.dart';

@JsonSerializable()
class UserProfileJSONObject {
  int? id;
  String? email;
  String? name;
  String? avatar;
  String? token;
  String? language;
  bool? isPremium;
  Premium? premium;

  int? statusCode;

  UserProfileJSONObject(
      {this.id,
      this.email,
      this.name,
      this.avatar,
      this.token,
      this.language,
      this.isPremium,
      this.premium,
      this.statusCode});

  factory UserProfileJSONObject.fromJson(Map<String, dynamic> json) =>
      _$UserProfileJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileJSONObjectToJson(this);
}

@JsonSerializable()
class Premium {
  @JsonKey(name: "product_id")
  String? productId;

  @JsonKey(name: "time_expired")
  int? timeExpired;

  Premium(this.productId, this.timeExpired);

  factory Premium.fromJson(Map<String, dynamic> json) =>
      _$PremiumFromJson(json);

  Map<String, dynamic> toJson() => _$PremiumToJson(this);
}
