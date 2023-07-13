import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'country_json_object.g.dart';

@JsonSerializable()
class CountryJSONObject {
  String? city;
  String? country;
  String? countryCode;
  String? region;
  String? regionName;
  String? status;
  String? timezone;

  CountryJSONObject(
      {this.city,
      this.country,
      this.countryCode,
      this.region,
      this.regionName,
      this.status,
      this.timezone});

  factory CountryJSONObject.fromJson(Map<String, dynamic> json) =>
      _$CountryJSONObjectFromJson(json);

  Map<String, dynamic> toJson() => _$CountryJSONObjectToJson(this);
}
