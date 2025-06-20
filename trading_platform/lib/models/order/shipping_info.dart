import 'package:json_annotation/json_annotation.dart';

part 'shipping_info.g.dart'; // 生成的文件名

@JsonSerializable()
class ShippingInformation {
  final double cost; // 運費
  final String region; // 例如："全國", "指定地區"
  final String? carrier; // 例如："黑貓宅急便", "郵局" (可選)

  ShippingInformation({
    required this.cost,
    required this.region,
    this.carrier,
  });

  /// Connect the generated [_$ShippingInformationFromJson] function to the `fromJson`
  /// factory.
  factory ShippingInformation.fromJson(Map<String, dynamic> json) =>
      _$ShippingInformationFromJson(json);

  /// Connect the generated [_$ShippingInformationToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ShippingInformationToJson(this);

  // Optional: copyWith method if you need to create modified copies
  ShippingInformation copyWith({
    double? cost,
    String? region,
    String? carrier,
  }) {
    return ShippingInformation(
      cost: cost ?? this.cost,
      region: region ?? this.region,
      carrier: carrier ?? this.carrier,
    );
  }
}