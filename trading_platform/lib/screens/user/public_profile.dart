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
  List<Product> _userProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    debugPrint("PublicUserProfilePage: Displaying profile for User ID: ${widget.userId}");
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
      setState(() {
        _username = '用戶 ${widget.userId.substring(0, widget.userId.length > 5 ? 5 : widget.userId.length)}';
        _avatarUrl = '';
        _completedTransactions = (widget.userId.hashCode % 100).abs();
        _bio = '這是用戶 $_username 的公開介紹。熱愛探索新技術和開源項目！目前已完成 $_completedTransactions 筆交易。希望能與更多人交流學習。';
        _userSchool = widget.userId.hashCode.isEven ? '國立台灣科技大學管理學院' : '範例大學軟體工程系';
      });
    }
  }

  Future<void> _loadUserProductsInternal() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      // 創建模擬商品數據
      final List<Product> mockProducts = [];
      final int sellerId = int.tryParse(widget.userId) ?? widget.userId.hashCode.abs();

      // 創建模擬的 SellerInfo
      final sellerInfo = SellerInfo(
        id: sellerId,
        username: '用戶${widget.userId.substring(0, widget.userId.length > 3 ? 3 : widget.userId.length)}的專業店鋪',
        avatarUrl: 'https://picsum.photos/seed/seller_avatar_${widget.userId}/100/100',
      );

      for (int index = 0; index < 8; index++) {
        final int productId = int.tryParse('${widget.userId.hashCode.abs()}$index') ??
            (widget.userId.hashCode.abs() + index);
        final now = DateTime.now();
        final isSoldProduct = (index % 4 == 0);

        // 創建Product，使用正確的參數類型
        try {
          final product = Product(
            id: productId, // int 類型
            name: '用戶精選商品 ${index + 1}',
            description: '這是一款高品質的用戶精選商品 ${index + 1}，具有多種優良特性和獨特設計，絕對物超所值。歡迎選購！',
            price: (widget.userId.hashCode % 1500 + 500 + index * 150).toDouble(),
            originalPrice: (widget.userId.hashCode % 1500 + 700 + index * 170).toDouble(),
            categoryId: (index % 5) + 1,
            category: '模擬分類 ${(index % 5) + 1}',
            stockQuantity: isSoldProduct ? 0 : (index * 5 + 10),
            status: isSoldProduct ? "sold" : "available",
            imageUrls: [
              'https://picsum.photos/seed/product_${productId}_image1/400/300',
              if (index % 2 == 0) 'https://picsum.photos/seed/product_${productId}_image2/400/300',
            ],
            createdAt: now.subtract(Duration(days: index + 5, hours: index * 2)),
            updatedAt: now.subtract(Duration(days: index, hours: index)),
            salesCount: isSoldProduct ? (index * 10 + 15) : (index * 10 + 5),
            averageRating: (index % 5 == 0) ? null : ((index % 40 + 10) / 10.0).clamp(3.0, 5.0),
            reviewCount: (index * 5 + 3), // 必需的 int，不是可選的
            tags: (index % 3 == 0) ? ['熱銷', '店長推薦'] : ['新品上架', '特價'],
            sellerId: sellerId,
            seller: sellerInfo,
            shippingInfo: null,
            isFavorite: false,
          );
          mockProducts.add(product);
        } catch (e) {
          debugPrint('Error creating product $index: $e');
          continue;
        }
      }

      setState(() {
        _userProducts = mockProducts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final User? currentUser = authProvider.currentUser;
    final bool isViewingOwnProfile = currentUser != null &&
        currentUser.id.toString() == widget.userId;

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
                Text(_errorMessage!,
                    style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _loadAllData,
                    child: const Text('重試'))
              ],
            ),
          ))
          : CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, colorScheme, textTheme),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _buildUserStats(context, colorScheme, textTheme),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildUserProductsSection(context, colorScheme, textTheme),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: statusBarHeight + 16.0,
        bottom: profileCurveHeight + 16.0,
      ),
      constraints: BoxConstraints(minHeight: avatarRadius * 2 + 32),
      child: Stack(
        children: [
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
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
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.8),
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
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
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
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
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

  Widget _buildUserStats(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    Widget verticalDivider = Container(
      height: 30,
      width: 1.5,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: ShapeDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: const StadiumBorder(),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildStatItem(
                    context,
                    Icons.school_outlined,
                    _userSchool,
                    colorScheme,
                    textTheme),
              ),
              verticalDivider,
              Expanded(
                child: _buildStatItem(
                    context,
                    Icons.swap_horiz_outlined,
                    '$_completedTransactions 筆',
                    colorScheme,
                    textTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            value,
            style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
              child: Center(
                  child: Text('這位用戶暫無上架商品')),
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
          debugPrint('Tapped on product: ${productFromList.name}, ID: ${productFromList.id}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(productId: productFromList.id), // 直接使用 int
            ),
          );
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
                  child: productFromList.imageUrls.isNotEmpty
                      ? Image.network(
                    productFromList.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 30,
                          )),
                    ),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: 30,
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          // 修復：正確處理可空的 description
                          if (productFromList.description?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                productFromList.description!,
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                    fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'NT\$ ${productFromList.price.toStringAsFixed(0)}',
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