// 可能需要導入 Product Model，取決於你在 CartItem 中儲存多少 Product 資訊

class CartItem {
  // 購物車項目的唯一 ID (可選，如果後端為購物車項目生成 ID)
  final String? id;

  // 與此購物車項目關聯的使用者 ID
  final String userId;

  // 購物車中的商品 ID
  final String productId;

  // 購買數量
  int quantity;

  // 可選：商品的基本資訊快照，方便顯示
  // 這樣做的好處是，即使商品價格或名稱在您將其添加到購物車後發生變化，
  // 購物車中顯示的仍然是您添加時的資訊。
  // 但需要確保在結帳時檢查最新的商品價格。
  final String productName;
  final double productPrice;
  final String? productImage; // 商品圖片 URL

  // TODO: 如果商品有規格（例如顏色、尺寸），可能需要添加規格相關的 ID 或信息
  // final String? selectedVariantId;
  // final String? selectedOptions; // 例如：'顏色: 紅色, 尺寸: M'

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productPrice,
    this.productImage,
    // this.selectedVariantId,
    // this.selectedOptions,
  });

  // 創建一個拷貝並增加數量的輔助方法
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      userId: userId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      // 如果 quantity 為 null，保持原來的數量
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      // selectedVariantId: selectedVariantId,
      // selectedOptions: selectedOptions,
    );
  }

  // 從 JSON 創建 CartItem 物件
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      productName: json['productName'] as String,
      productPrice: (json['productPrice'] as num).toDouble(),
      productImage: json['productImage'] as String?,
      // selectedVariantId: json['selectedVariantId'] as String?,
      // selectedOptions: json['selectedOptions'] as String?,
    );
  }

  // 將 CartItem 物件轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      // 'selectedVariantId': selectedVariantId,
      // 'selectedOptions': selectedOptions,
    };
  }
}