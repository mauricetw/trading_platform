import 'package:flutter/foundation.dart';
import '../models/user/wishlist_item.dart'; // 確保這個 WishlistItem 模型包含 Product product;
import '../models/product/product.dart';
import '../services/wishlist_service.dart';
import '../services/api_service.dart'; // 或者您的 ApiException 定義位置

// 建議的狀態枚舉
enum WishlistStatus { initial, loading, loaded, empty, error }

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  String? _currentUserId;

  // 內部狀態
  // _wishlistItems 現在直接存儲包含 Product 的 WishlistItem
  List<WishlistItem> _wishlistItems = [];
  WishlistStatus _status = WishlistStatus.initial;
  String _errorMessage = '';

  // Getters
  List<WishlistItem> get wishlistItems => List.unmodifiable(_wishlistItems);
  WishlistStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == WishlistStatus.loading;

  // 構造函數
  WishlistProvider(this._wishlistService);

  void updateCurrentUser(String? userId) {
    if (_currentUserId == userId && userId != null && _status != WishlistStatus.initial && _status != WishlistStatus.error) {
      return;
    }
    _currentUserId = userId;
    if (_currentUserId != null) {
      fetchWishlistItems();
    } else {
      _wishlistItems = [];
      _status = WishlistStatus.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }

  Future<void> fetchWishlistItems({bool forceRefresh = false}) async {
    if (_currentUserId == null) {
      _status = WishlistStatus.error;
      _errorMessage = "用戶未登入，無法獲取願望清單。";
      notifyListeners();
      return;
    }
    if (_status == WishlistStatus.loading && !forceRefresh) return;

    _status = WishlistStatus.loading;
    _errorMessage = '';
    // 通知一次開始加載
    // 在 finally 中也會通知，但如果希望 UI 立即響應 loading 狀態，這裡可以加一次
    notifyListeners();

    try {
      // 假設 _wishlistService.getMyWishlistItems() 返回 List<WishlistItem>
      // 並且每個 WishlistItem 都已經通過 fromJson 填充了其 product 字段
      final items = await _wishlistService.getMyWishlistItems();
      _wishlistItems = items;

      if (_wishlistItems.isEmpty) {
        _status = WishlistStatus.empty;
      } else {
        _status = WishlistStatus.loaded;
      }
      _errorMessage = '';
    } on ApiException catch (e) {
      _errorMessage = '獲取願望清單失敗: ${e.message}';
      _status = WishlistStatus.error;
      _wishlistItems = []; // 出錯時清空
    } catch (error) {
      _errorMessage = '獲取願望清單時發生未知錯誤: $error';
      _status = WishlistStatus.error;
      _wishlistItems = []; // 出錯時清空
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addToWishlist(Product productToAdd) async {
    if (_currentUserId == null) {
      _errorMessage = "請先登入才能將商品加入願望清單。";
      notifyListeners();
      return false;
    }

    if (isProductInWishlistByProductId(productToAdd.id)) {
      print('商品 ${productToAdd.name} 已在願望清單中。');
      // 如果已存在，可以選擇返回 true，或者根據需要更新現有項目的某些信息（例如 createdAt）
      // 如果服務端 addItemToWishlist 會返回已存在的項目，我們可以更新本地的 WishlistItem
      try {
        // 即使已存在，也嘗試調用 service，服務端可能會返回更新後的 WishlistItem
        final existingOrNewWishlistItem = await _wishlistService.addItemToWishlist(productToAdd.id);
        final index = _wishlistItems.indexWhere((item) => item.id == existingOrNewWishlistItem.id || item.productId == productToAdd.id);
        if (index != -1) {
          // 更新本地的 WishlistItem，確保 product 也是最新的 (如果服務端返回了完整的 product)
          _wishlistItems[index] = existingOrNewWishlistItem;
        } else {
          // 服務端返回了新的項目，但本地檢查說已存在，這不太可能，除非本地檢查有誤或異步問題
          // 謹慎起見，如果找不到就添加
          _wishlistItems.add(existingOrNewWishlistItem);
        }
        _status = WishlistStatus.loaded; // 確保狀態是 loaded
        notifyListeners();
        return true;
      } catch (e) {
        // 如果再次添加失敗，按原樣處理
        _errorMessage = '添加已存在商品到願望清單時發生錯誤: $e';
        notifyListeners();
        return false;
      }
    }

    // 樂觀更新：創建一個包含完整 Product 的 WishlistItem
    // 這裡我們需要一個 "假" 的 WishlistItem ID 和 createdAt，服務端返回後會替換
    final tempWishlistItemId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticWishlistItem = WishlistItem(
      id: tempWishlistItemId, // 臨時 ID
      userId: _currentUserId!,
      productId: productToAdd.id,
      product: productToAdd, // <--- 關鍵：直接使用傳入的 Product 對象
      createdAt: DateTime.now(),
    );

    _wishlistItems.add(optimisticWishlistItem);
    if (_status == WishlistStatus.empty) _status = WishlistStatus.loaded;
    _errorMessage = '';
    notifyListeners();

    try {
      final newWishlistItem = await _wishlistService.addItemToWishlist(productToAdd.id);
      // 服務端返回的 newWishlistItem 應該也包含了 Product 對象
      // 移除臨時項目
      _wishlistItems.removeWhere((item) => item.id == tempWishlistItemId);
      // 添加真實項目 (或更新，如果服務端返回的 id 與樂觀更新的 productId 匹配的項已存在)
      final existingIndex = _wishlistItems.indexWhere((item) => item.id == newWishlistItem.id || item.productId == newWishlistItem.productId);
      if (existingIndex != -1) {
        _wishlistItems[existingIndex] = newWishlistItem; // 替換為服務器返回的完整數據
      } else {
        _wishlistItems.add(newWishlistItem);
      }

      if (_status == WishlistStatus.empty && _wishlistItems.isNotEmpty) {
        _status = WishlistStatus.loaded;
      }
      _errorMessage = '';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = '添加願望清單失敗: ${e.message}';
      _wishlistItems.removeWhere((item) => item.id == tempWishlistItemId); // 回滾樂觀更新
      if (_wishlistItems.isEmpty && _status == WishlistStatus.loaded) _status = WishlistStatus.empty;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = '添加願望清單時發生未知錯誤: $error';
      _wishlistItems.removeWhere((item) => item.id == tempWishlistItemId); // 回滾樂觀更新
      if (_wishlistItems.isEmpty && _status == WishlistStatus.loaded) _status = WishlistStatus.empty;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWishlistById(String wishlistItemId) async {
    if (_currentUserId == null) return false;

    WishlistItem? removedItemInstance;
    int originalIndex = -1;

    try {
      originalIndex = _wishlistItems.indexWhere((item) => item.id == wishlistItemId);
      if (originalIndex == -1) {
        print("要移除的 WishlistItem (ID: $wishlistItemId) 未在本地列表中找到。");
        // 嘗試直接調用服務，即使本地沒有，以防萬一數據不同步
        await _wishlistService.removeItemFromWishlist(wishlistItemId);
        // 如果遠程成功，我們最好還是刷新一下列表以確保一致性
        fetchWishlistItems();
        return true;
      }
      removedItemInstance = _wishlistItems.removeAt(originalIndex);
      if (_wishlistItems.isEmpty) _status = WishlistStatus.empty;
      _errorMessage = '';
      notifyListeners(); // 樂觀更新 UI

      await _wishlistService.removeItemFromWishlist(wishlistItemId);
      // 成功，樂觀更新已是最終狀態
      return true;
    } on ApiException catch (e) {
      _errorMessage = '移除願望清單失敗: ${e.message}';
      if (removedItemInstance != null && originalIndex != -1) { // 回滾
        _wishlistItems.insert(originalIndex, removedItemInstance);
        if (_status == WishlistStatus.empty && _wishlistItems.isNotEmpty) _status = WishlistStatus.loaded;
      }
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = '移除願望清單時發生未知錯誤: $error';
      if (removedItemInstance != null && originalIndex != -1) { // 回滾
        _wishlistItems.insert(originalIndex, removedItemInstance);
        if (_status == WishlistStatus.empty && _wishlistItems.isNotEmpty) _status = WishlistStatus.loaded;
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromWishlistByProductId(String productId) async {
    if (_currentUserId == null) {
      _errorMessage = "用戶未登入。"; // 或者您可以選擇不設置錯誤消息，直接返回 false
      notifyListeners(); // 如果您希望 UI 對此做出反應
      return false;
    }

    WishlistItem? removedItemInstance;
    int originalIndex = -1;

    try {
      originalIndex = _wishlistItems.indexWhere((item) => item.productId == productId);
      if (originalIndex == -1) {
        print("商品 (ID: $productId) 不在本地願望清單中，無法通過 ProductID 移除。");
        // 即使本地沒有，也嘗試調用服務，因為服務端可能是權威數據源
        // 如果服務端成功移除了（可能本地列表之前未同步），那麼操作也算成功
        // 但如果服務端也說沒有，它應該會拋錯或返回特定狀態碼，由 service 處理
        await _wishlistService.removeItemFromWishlistByProductId(productId);
        // 如果遠程操作沒有拋錯，可以認為操作成功，最好再刷新一下列表確保一致
        await fetchWishlistItems(); // 刷新以確保一致性
        _errorMessage = ''; // 清除之前的錯誤消息
        // notifyListeners(); // fetchWishlistItems 內部會 notify
        return true;
      }

      // 樂觀更新：從本地列表中移除
      removedItemInstance = _wishlistItems.removeAt(originalIndex);
      if (_wishlistItems.isEmpty) _status = WishlistStatus.empty;
      _errorMessage = '';
      notifyListeners();

      // 調用 Service 層的方法
      await _wishlistService.removeItemFromWishlistByProductId(productId);

      // 如果 service 調用成功，樂觀更新已是最終狀態
      // _errorMessage = ''; // 已經在樂觀更新時清除了
      // notifyListeners(); // 樂觀更新時已經通知過了，這裡可以不再通知，除非狀態有進一步變化
      return true;

    } on ApiException catch (e) {
      _errorMessage = '通過產品ID移除願望清單失敗: ${e.message}';
      if (removedItemInstance != null && originalIndex != -1) { // 回滾樂觀更新
        _wishlistItems.insert(originalIndex, removedItemInstance);
        if (_status == WishlistStatus.empty && _wishlistItems.isNotEmpty) {
          _status = WishlistStatus.loaded;
        }
      }
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = '通過產品ID移除願望清單時發生未知錯誤: $error';
      if (removedItemInstance != null && originalIndex != -1) { // 回滾樂觀更新
        _wishlistItems.insert(originalIndex, removedItemInstance);
        if (_status == WishlistStatus.empty && _wishlistItems.isNotEmpty) {
          _status = WishlistStatus.loaded;
        }
      }
      notifyListeners();
      return false;
    }
  }


  // 檢查商品是否在收藏列表中 (通過 Product ID)
  bool isProductInWishlistByProductId(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  bool isProductInWishlist(Product product) {
    return isProductInWishlistByProductId(product.id);
  }

  Set<String> get wishlistedProductIds => _wishlistItems.map((item) => item.productId).toSet();
}

// 假設 WishlistService 的一個輔助方法 (在 WishlistService 類中定義)
// 只是為了讓上面的 removeFromWishlistByProductId 示例更完整
// abstract class WishlistService {
//   ...
//   Future<WishlistItem> addItemToWishlist(String productId);
//   Future<void> removeItemFromWishlist(String wishlistItemId);
//   Future<void> removeItemFromWishlistByProductId(String productId); // 如果支持
//   Future<List<WishlistItem>> getMyWishlistItems();
//   bool isRemoveByProductIdSupported() => false; // 默認不支持，具體服務實現時覆蓋
// }

