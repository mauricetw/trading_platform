// 運費資訊 Model (範例)
class ShippingInformation {
  final double cost;
  final String region; // 例如："全國", "指定地區"
  final String? carrier; // 例如："黑貓宅急便", "郵局"

  ShippingInformation({
    required this.cost,
    required this.region,
    this.carrier,
  });
}