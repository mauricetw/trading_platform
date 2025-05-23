import '../user/user.dart';
import '../order/shipping_info.dart';
class Product {
  final String id; //唯一識別碼
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final List<String> imageUrls;
  final String category;
  final String status; // 例如："available", "unavailable"
  final DateTime createdAt;
  final DateTime updatedAt;

  final int salesCount; // 新增：銷售量
  final double? averageRating; // 新增：平均評分 (使用 nullable double?)
  final int? reviewCount; // 新增：評價數量 (使用 nullable int?)
  final List<String>? tags; // 新增：標籤 (使用 nullable List<String>?)
  final ShippingInformation? shippingInfo; // 新增：運費資訊 (使用 nullable ShippingInformation?)
  final User? seller; // 新增：賣家資訊 (使用 nullable Seller?)

  // 可以添加其他屬性

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrls,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.salesCount = 0, // 預設銷售量為 0
    this.averageRating,
    this.reviewCount,
    this.tags,
    this.shippingInfo,
    this.seller,
  });
  // 可以添加 fromJson 或 toMap 方法，方便從 JSON 或 Map 轉換
}



