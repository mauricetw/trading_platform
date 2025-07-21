// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user/cart_item.dart';
import '../models/product/product.dart'; // 需要 Product Model

class CartProvider with ChangeNotifier {
  // 使用 Map 來儲存購物車項目，key 是商品 ID (或商品規格 ID)，value 是 CartItem
  // 使用 Map 可以方便地通過商品 ID 來查找和更新購物車項目
  final Map<String, CartItem> _items = {};

  // 獲取購物車項目的列表 (方便在 UI 中顯示)
  List<CartItem> get items {
    // 將 Map 的 value 轉換為 List
    return _items.values.toList();
  }

  // 獲取購物車中的總商品數量 (所有商品的數量總和)
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  // 獲取購物車中的商品種類數量 (不同商品的數量)
  int get itemCount {
    return _items.length;
  }


  // 獲取購物車中的總金額
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.productPrice * cartItem.quantity;
    });
    return total;
  }

  // TODO: 需要獲取當前使用者 ID
  String? _currentUserId;

  // 當 AuthProvider 的使用者狀態改變時呼叫此方法
  void updateCurrentUser(String? userId) {
    _currentUserId = userId;
    // TODO: 這裡可能需要從後端加載該使用者的購物車數據
    if (_currentUserId != null) {
      // fetchCartItems(_currentUserId!); // 如果需要從後端加載
    } else {
      _items.clear(); // 用戶登出後清空購物車
      // notifyListeners(); // 清空後需要通知 UI
    }
    // 不管是否登入，使用者狀態改變都可能影響 UI，所以最好通知一下
    notifyListeners();
  }

  // 添加或更新購物車中的商品
  // quantityToAdd 是每次點擊添加按鈕時增加的數量，通常是 1
  void addItem(Product product, int quantityToAdd) {
    if (_currentUserId == null) {
      // 提示用戶登入或其他處理
      print('用戶未登入，無法添加到購物車');
      return;
    }

    // 使用商品 ID 作為 Map 的 key
    final String key = product.id.toString();

    if (_items.containsKey(key)) {
      // 如果購物車中已經有這個商品，則增加數量
      _items.update(
        key,
            (existingItem) =>
            existingItem.copyWith(
              quantity: existingItem.quantity + quantityToAdd,
            ),
      );
    } else {
      // 如果購物車中沒有這個商品，則添加新的項目
      final newItem = CartItem(
        // id: '', // 如果後端生成 ID，這裡可能為空或暫時賦一個本地 ID
        userId: _currentUserId!,
        productId: key,
        quantity: quantityToAdd,
        productName: product.name,
        productPrice: product.price,
        // 確保 Product Model 有 imageUrl 或類似的屬性
        //productImage: product.imageUrl, // 假設 Product Model 有 imageUrl
      );
      _items.putIfAbsent(key, () => newItem);
    }

    // TODO: 將購物車狀態同步到後端 (例如：添加商品 API)
    // saveCartItemToBackend(_items[key]!);

    notifyListeners(); // 通知 UI 更新
  }

  // 移除購物車中的特定商品項目
  void removeItem(String productId) {
    if (_currentUserId == null) {
      return;
    }
    _items.remove(productId);

    // TODO: 將購物車狀態同步到後端 (例如：移除商品 API)
    // removeCartItemFromBackend(productId);

    notifyListeners(); // 通知 UI 更新
  }

  // 減少購物車中某商品的數量 (如果數量減到 0 則移除)
  void removeSingleItem(String productId) {
    if (_currentUserId == null || !_items.containsKey(productId)) {
      return;
    }

    // 獲取當前數量
    final int currentQuantity = _items[productId]!.quantity;

    if (currentQuantity > 1) {
      // 如果數量大於 1，則減少數量
      _items.update(
        productId,
            (existingItem) =>
            existingItem.copyWith(
              quantity: existingItem.quantity - 1,
            ),
      );
    } else {
      // 如果數量等於 1，則移除整個商品項目
      _items.remove(productId);
    }

    // TODO: 將購物車狀態同步到後端 (例如：更新數量或移除 API)
    // updateCartItemQuantityInBackend(productId, _items[productId]?.quantity ?? 0);

    notifyListeners(); // 通知 UI 更新
  }

  // 清空整個購物車
  void clearCart() {
    if (_currentUserId == null) {
      return;
    }
    _items.clear();

    // TODO: 將購物車狀態同步到後端 (例如：清空購物車 API)
    // clearCartInBackend(_currentUserId!);

    notifyListeners(); // 通知 UI 更新
  }

// （可選）從後端獲取購物車數據的方法
// Future<void> fetchCartItems(String userId) async {
//   // 實現從後端 API 獲取購物車數據的邏輯
//   // 解析數據並更新 _items Map
//   // notifyListeners();
// }

// （可選）將購物車數據同步到後端的方法
// Future<void> saveCartToBackend() async {
//   // 實現將 _items 中的數據發送到後端 API 的邏輯
//   // 這可以在每次添加、移除或更新數量後呼叫
// }

// （可選）將單個購物車項目同步到後端的方法
// Future<void> saveCartItemToBackend(CartItem item) async {
//    // 實現將單個 CartItem 發送到後端 API 的邏輯 (用於添加或更新)
// }

// （可選）從後端移除單個購物車項目
// Future<void> removeCartItemFromBackend(String productId) async {
//    // 實現從後端移除購物車項目的邏輯
// }

// （可選）更新後端購物車項目數量
// Future<void> updateCartItemQuantityInBackend(String productId, int quantity) async {
//   // 實現更新後端數量的邏輯
// }

// （可選）清空後端購物車
// Future<void> clearCartInBackend(String userId) async {
//    // 實現清空後端購物車的邏輯
// }

}