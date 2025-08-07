class CartItem {
  final String? id;
  final String userId;
  final String productId;
  int quantity;
  final String productName;
  final double productPrice;
  final String? productImage;

  // 【【新增】】用於標記此商品是否被選中去結帳
  bool isSelected;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productPrice,
    this.productImage,
    this.isSelected = false, // 默認不選中
  });

  CartItem copyWith({
    int? quantity,
    bool? isSelected, // 【【新增】】允許複製時修改選中狀態
  }) {
    return CartItem(
      id: id,
      userId: userId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      isSelected: isSelected ?? this.isSelected, // 【【新增】】
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      productName: json['productName'] as String,
      productPrice: (json['productPrice'] as num).toDouble(),
      productImage: json['productImage'] as String?,
      // 從 JSON 加載時，可以決定 isSelected 的默認值，通常是 false
      // 或者如果後端也保存選中狀態，則從 json['isSelected'] 獲取
      isSelected: json['isSelected'] as bool? ?? false, // 【【新增】】並提供默認值
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'isSelected': isSelected, // 【【新增】】
    };
  }

  // 可選：為了方便調試，可以重寫 toString
  @override
  String toString() {
    return 'CartItem(id: $id, name: $productName, quantity: $quantity, price: $productPrice, isSelected: $isSelected)';
  }
}
