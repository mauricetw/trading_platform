// 檔案路徑: shipping_info.dart (或者它所在的 .dart 檔案)

class ShippingInformation {
  final double cost; // 運費
  final String region; // 例如："全國", "指定地區"
  final String? carrier; // 例如："黑貓宅急便", "郵局" (可選)

  ShippingInformation({
    required this.cost,
    required this.region,
    this.carrier,
  });

  // ---  ↓↓↓ 將 JSON Map 轉換為 ShippingInformation 物件的方法 ↓↓↓ ---
  factory ShippingInformation.fromJson(Map<String, dynamic> json) {
    return ShippingInformation(
      cost: (json['cost'] as num).toDouble(), // JSON 中的數字可能是 int 或 double，統一轉為 double
      region: json['region'] as String,
      carrier: json['carrier'] as String?, // carrier 是可選的，所以使用 as String?
    );
  }
  // ---  ↑↑↑ fromJson 方法結束 ↑↑↑ ---

  // ---  ↓↓↓ 將 ShippingInformation 物件轉換為 JSON Map 的方法 ↓↓↓ ---
  Map<String, dynamic> toJson() {
    return {
      'cost': cost,
      'region': region,
      'carrier': carrier, // 如果 carrier 是 null，它在 JSON 中也會是 null
    };
  }
// ---  ↑↑↑ toJson 方法結束 ↑↑↑ ---
}