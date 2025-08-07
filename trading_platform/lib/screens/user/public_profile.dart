import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../providers/auth_provider.dart';
import '../../models/user/user.dart';
import '../../models/product/product.dart';
import '../product.dart';

class PublicUserProfilePage extends StatefulWidget {
  final String userId;

  const PublicUserProfilePage({super.key, required this.userId});

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  String _username = '';
  String _avatarUrl = '';
  int _completedTransactions = 0;
  String _bio = '這位用戶很神秘，什麼都沒留下...';
  String _userSchool = '未知學校';
  // String _userLocation = '未知地點'; // 已移除
  List<Product> _userProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    print("PublicUserProfilePage: Displaying profile for User ID: ${widget.userId}");
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _loadProfileDataInternal(),
        _loadUserProductsInternal(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加載用戶資料失敗: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileDataInternal() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _username = '用戶 ${widget.userId.substring(0, 5)}';
      _avatarUrl = ''; // 可替換為真實URL
      _completedTransactions = (widget.userId.hashCode % 100).abs();
      _bio =
      '這是用戶 ${_username} 的公開介紹。熱愛探索新技術和開源項目！目前已完成 $_completedTransactions 筆交易。希望能與更多人交流學習。';
      _userSchool = widget.userId.hashCode.isEven ? '國立台灣科技大學管理學院' : '範例大學軟體工程系';
    }
  }

  Future<void> _loadUserProductsInternal() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      // 創建一個模擬的賣家 User 對象
      // **重要**: 確保這個 mockSeller 的構造符合您真實 User 模型的定義
      // 假設您的 User 模型至少有以下字段，並按需調整
      final mockSeller = User(
        id: 'seller_for_${widget.userId}', // 必填
        username: '用戶${widget.userId.substring(0,3)}的專業店鋪', // 必填
        email: 'seller_user_${widget.userId.substring(0,3)}@example.com', // 必填
        registeredAt: DateTime.now().subtract(const Duration(days: 180)), // 必填

        // --- 以下為可選字段，根據您的 User 模型進行填充 ---
        phoneNumber: '09123456${widget.userId.hashCode % 100}', // 模擬電話號碼
        avatarUrl: 'https://picsum.photos/seed/seller_avatar_${widget.userId}/100/100', // 賣家頭像
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)), // 上次登錄時間
        bio: '大家好，我是 ${'用戶'+widget.userId.substring(0,3)}，專注於提供高品質商品。歡迎選購！', // 私有筆記
        schoolName: (widget.userId.hashCode % 3 == 0) ? '電子商務大學' : null, // 模擬學校
        isVerified: true, // 假設賣家已驗證
        roles: ['seller', 'premium_user'], // 模擬角色

        isSeller: true, // 設置為 true，因為這是賣家
        sellerName: '用戶${widget.userId.substring(0,3)}的精選小店', // 店鋪名/賣家名
        sellerDescription: '本店專營各類優質商品，品質保證，服務至上。全場模擬商品，僅供測試。', // 店鋪描述
        sellerRating: ((widget.userId.hashCode % 15 + 35) / 10.0).clamp(3.5, 5.0), // 模擬評分 3.5-5.0
        productCount: 8, // 與下面生成的商品數量一致

        favoriteProductIds: [], // 初始可以為空，或者模擬一些
        publicDisplayName: '店長${widget.userId.substring(0,2)}', // 公開顯示的名稱
        publicBio: '來自寶島的資深賣家，為您帶來最好的商品體驗。公開測試簡介。', // 公開的個人簡介
        publicCoverPhotoUrl: 'https://picsum.photos/seed/seller_cover_${widget.userId}/600/200', // 公開封面
        isSchoolPublic: widget.userId.hashCode.isEven, // 學校信息是否公開，模擬
      );


      _userProducts = List.generate(
        8, // 生成8個模擬商品
            (index) {
          final productId = 'prod_${widget.userId}_$index';
          final now = DateTime.now();
          final isSoldProduct = (index % 4 == 0); // 每隔幾個商品設置為已售出

          return Product( // <--- 使用官方 Product 模型的構造函數
            id: productId,
            name: '用戶精選商品 ${index + 1}',
            description: '這是一款高品質的用戶精選商品 ${index + 1}，由 ${mockSeller.username} 精心提供。具有多種優良特性和獨特設計，絕對物超所值。歡迎選購！詳情請點擊查看。請注意，本商品為模擬數據。',
            price: (widget.userId.hashCode % 1500 + 500 + index * 150).toDouble(),
            originalPrice: (widget.userId.hashCode % 1500 + 700 + index * 170).toDouble(), // 模擬原價
            categoryId: (index % 5) + 1, // 模擬 categoryId (假設為 1 到 5)
            stockQuantity: isSoldProduct ? 0 : (index * 5 + 10), // 如果已售出則庫存為0，否則模擬庫存
            imageUrls: [ // 至少需要一個 URL，您的模型要求 List<String>
              'https://picsum.photos/seed/${productId}_image1/400/300',
              if (index % 2 == 0) 'https://picsum.photos/seed/${productId}_image2/400/300', // 有些商品有多個圖片
              if (index % 3 == 0) 'https://picsum.photos/seed/${productId}_image3/400/300',
            ],
            category: '模擬分類 ${(index % 5) + 1}', // 模擬分類名稱
            status: isSoldProduct ? "sold" : "available", // 根據是否已售出設置狀態
            createdAt: now.subtract(Duration(days: index + 5, hours: index * 2)), // 模擬創建時間
            updatedAt: now.subtract(Duration(days: index, hours: index)),      // 模擬更新時間
            salesCount: isSoldProduct ? (index * 10 + 15) : (index * 10 + 5), // 模擬銷量
            averageRating: (index % 5 == 0) ? null : ((index % 40 + 10) / 10.0).clamp(3.0, 5.0), // 模擬平均評分 (3.0-5.0)，有些可能為null
            reviewCount: (index % 5 == 0) ? null : (index * 5 + 3), // 模擬評論數，有些可能為null
            tags: (index % 3 == 0) ? ['熱銷', '店長推薦'] : ['新品上架', '特價'], // 模擬標籤
            shippingInfo: null, // 暫時為 null，或者您可以創建一個模擬的 ShippingInformation 對象
            seller: mockSeller, // <--- 關聯上面創建的模擬賣家
            isSold: isSoldProduct, // <--- 根據上面邏輯設置
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentLoggedInUserId = authProvider.currentUser?.id;
    final bool isViewingOwnProfile =
        currentLoggedInUserId != null && currentLoggedInUserId == widget.userId;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!, style: textTheme.titleMedium?.copyWith(color: colorScheme.error)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadAllData, child: const Text('重試'))
              ],
            ),
          ))
          : CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, colorScheme, textTheme),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _buildSection(
              context,
              title: '關於我',
              content: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(_bio, style: textTheme.bodyLarge),
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _buildUserStats(context, colorScheme, textTheme), // 用戶統計區塊
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          _buildUserProductsSection(context, colorScheme, textTheme),
          SliverToBoxAdapter(child: const SizedBox(height: 80)), // For FAB
        ],
      ),
      floatingActionButton: _isLoading || isViewingOwnProfile
          ? null
          : FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('與 $_username 開始聊天（功能待實現）')));
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('傳送訊息'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- 修改 ProfileHeader，頭像嚴格置中，元素各自對齊 ---
  Widget _buildProfileHeader(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final double profileCurveHeight = 50.0;
    final double avatarRadius = 45.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool canPop = Navigator.canPop(context);

    final TextStyle usernameStyle = textTheme.headlineSmall?.copyWith(
      color: colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    ) ??
        TextStyle(
            fontSize: 24,
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: colorScheme.primary,
        shape: FullBottomConcaveAppBarShape(
          curveHeight: profileCurveHeight,
          topCornerRadius: 0,
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.only( // 上下 padding
        top: statusBarHeight + 16.0,
        bottom: profileCurveHeight + 16.0,
      ),
      constraints: BoxConstraints(minHeight: avatarRadius * 2 + 32), // 確保Stack有足夠高度
      child: Stack(
        children: [
          // 1. 返回按鈕 (如果可以返回) - 靠左垂直居中
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0), // 左邊距
                child: Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: colorScheme.onPrimary),
                    iconSize: usernameStyle.fontSize,
                    onPressed: () => Navigator.maybePop(context),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    padding: const EdgeInsets.all(12.0),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ),

          // 2. 頭像 - 水平置中，垂直居中
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor:
              colorScheme.surfaceContainerHighest.withOpacity(0.8),
              backgroundImage:
              _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty
                  ? Icon(
                Icons.person_rounded,
                size: avatarRadius * 1.2,
                color: colorScheme.primary,
              )
                  : null,
            ),
          ),

          // 3. 用戶名和ID - 靠右垂直居中
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0), // 右邊距
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _username,
                    style: usernameStyle,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.userId}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.85),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// --- 修改 _buildUserStats，取消均間並使用更新後的 _buildStatItem ---
  Widget _buildUserStats(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    Widget verticalDivider = Container(
      height: 30, // 可以根據內容調整高度，使其看起來更協調
      width: 1.5,   // 可以稍微加粗一點
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.4), // 調整顏色和透明度
        borderRadius: BorderRadius.circular(1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12.0), // 給分隔線一些左右空間
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // 外部 Padding
      child: Container(
        decoration: ShapeDecoration(
            color: colorScheme.surfaceVariant,
            shape: const StadiumBorder(),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // 內部 Padding，可以調整以獲得最佳視覺
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // *** 1. 取消均間，改為居中 ***
            children: [
              Expanded(
                child: _buildStatItem(
                    context,
                    Icons.school_outlined,
                    _userSchool,
                    colorScheme,
                    textTheme), // *** 2. 調用修改後的 _buildStatItem (無label) ***
              ),
              verticalDivider,
              Expanded(
                child: _buildStatItem(
                    context,
                    Icons.swap_horiz_outlined,
                    '$_completedTransactions 筆',
                    colorScheme,
                    textTheme), // *** 2. 調用修改後的 _buildStatItem (無label) ***
              ),
            ],
          ),
        ),
      ),
    );
  }



  // --- 修改 _buildStatItem，移除 label 參數和對應的 Text Widget ---
  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      ColorScheme colorScheme, TextTheme textTheme) {
    // Widget verticalDivider = Container(...); // 這個 verticalDivider 應該是 _buildUserStats 裡的，這裡不需要
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            value,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2, // 保持多行以防學校名稱過長
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // const SizedBox(height: 2), // 移除了標籤後，這個間距也可以考慮移除或調整
        // Text( // <--- 移除這個顯示 label 的 Text Widget
        //   label,
        //   style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
        //   textAlign: TextAlign.center,
        // ),
      ],
    );
  }



  Widget _buildUserProductsSection(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
            child: Text(
              '上架商品 (${_userProducts.length})',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (_userProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
              child: Center(
                  child: Text('這位用戶暫無上架商品', style: textTheme.bodyMedium)),
            )
          else
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _userProducts.length,
              itemBuilder: (context, index) {
                final product = _userProducts[index];
                return _buildProductListItem(context, product, colorScheme, textTheme);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(BuildContext context, Product productFromList,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () {
          print('Tapped on product: ${productFromList.name}, ID: ${productFromList.id}');

          // --- 導航到 ProductScreen ---
          Navigator.push(
            context,
            MaterialPageRoute(
              // productFromList 已經是官方的 Product 類型
              builder: (context) => ProductScreen(productId: productFromList.id),
            ),
          );
          // --- 導航結束 ---
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: productFromList.imageUrls.isNotEmpty // 檢查 imageUrls 列表是否為空
                      ? Image.network(
                    productFromList.imageUrls.first, // <--- 使用列表中的第一張圖片
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Center(child: Icon(Icons.broken_image_outlined, color: colorScheme.onSurfaceVariant, size: 30,)),
                    ),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                      : Container( // 如果 imageUrls 列表為空，顯示佔位符
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    child: Center(child: Icon(Icons.image_not_supported_outlined, color: colorScheme.onSurfaceVariant, size: 30,)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 90, // 給定一個固定高度以幫助佈局
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素在垂直方向上均勻分佈
                    children: [
                      Column( // 用於名稱和描述
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productFromList.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (productFromList.description != null && productFromList.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                productFromList.description!,
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 11),
                                maxLines: 1, // 描述通常只顯示一行預覽
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      // 價格顯示在底部
                      if (productFromList.price != null)
                        Text(
                          'NT\$ ${productFromList.price?.toStringAsFixed(0) ?? '---'}',
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSection(BuildContext context,
      {required String title, required Widget content, Widget? trailing}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
