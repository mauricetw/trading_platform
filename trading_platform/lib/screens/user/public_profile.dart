// --- FILE: lib/screens/user/public_profile.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../models/user/user.dart';
import '../../models/product/product.dart';
import '../product.dart';

// 輔助類別，用於打包 Future.wait 的結果
class UserProfileData {
  final User user;
  final List<Product> products;
  UserProfileData({required this.user, required this.products});
}

class PublicUserProfilePage extends StatefulWidget {
  final String userId;

  const PublicUserProfilePage({super.key, required this.userId});

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  late Future<UserProfileData> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 確保 context 已經準備好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  // 將資料載入邏輯整合到一個 Future 中
  void _loadAllData() {
    if (mounted) {
      final userService = context.read<UserService>();
      setState(() {
        _profileDataFuture = Future.wait([
          userService.getUserProfileById(widget.userId),
          userService.getProductsBySellerId(widget.userId),
        ]).then((results) {
          return UserProfileData(
            user: results[0] as User,
            products: results[1] as List<Product>,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 FutureBuilder 來處理載入、錯誤和成功狀態
    return FutureBuilder<UserProfileData>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return _buildErrorView(context, snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildErrorView(context, '找不到使用者資料');
        }

        final userData = snapshot.data!.user;
        final userProducts = snapshot.data!.products;
        final authProvider = context.read<AuthProvider>();
        final bool isViewingOwnProfile = authProvider.currentUser?.id.toString() == widget.userId;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerHighest,
          body: RefreshIndicator(
            onRefresh: () async => _loadAllData(),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _buildProfileHeader(context, colorScheme, textTheme, userData),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    title: '關於我',
                    content: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(userData.bio ?? '這位用戶很神秘，什麼都沒留下...', style: textTheme.bodyLarge),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _buildUserStats(context, colorScheme, textTheme, userData),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                _buildUserProductsSection(context, colorScheme, textTheme, userProducts),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
          floatingActionButton: isViewingOwnProfile
              ? null
              : FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('與 ${userData.username} 開始聊天（功能待實現）')));
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('傳送訊息'),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  // --- 以下 UI Builder Widgets 完整保留組員的設計，並適配真實資料 ---

  Widget _buildErrorView(BuildContext context, String error) {
    return Scaffold(
        appBar: AppBar(title: const Text('錯誤')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _loadAllData,
                    child: const Text('重試'))
              ],
            ),
          ),
        )
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, User user) {
    final double profileCurveHeight = 50.0;
    final double avatarRadius = 45.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool canPop = Navigator.canPop(context);

    final TextStyle usernameStyle = textTheme.headlineSmall?.copyWith(
      color: colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    ) ?? TextStyle(fontSize: 24, color: colorScheme.onPrimary, fontWeight: FontWeight.bold);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: colorScheme.primary,
        shape: FullBottomConcaveAppBarShape(curveHeight: profileCurveHeight, topCornerRadius: 0),
        shadows: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: EdgeInsets.only(top: statusBarHeight + 16.0, bottom: profileCurveHeight + 16.0),
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
                    icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary),
                    onPressed: () => Navigator.maybePop(context),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
              backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) ? NetworkImage(user.avatarUrl!) : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty) ? Icon(Icons.person_rounded, size: avatarRadius * 1.2, color: colorScheme.primary) : null,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user.username, style: usernameStyle, textAlign: TextAlign.right),
                  const SizedBox(height: 4),
                  Text('ID: ${user.id}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.85))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, User user) {
    Widget verticalDivider = Container(
      height: 30, width: 1.5,
      decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: ShapeDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: const StadiumBorder(),
            shadows: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildStatItem(context, Icons.school_outlined, user.schoolName ?? '未知學校', colorScheme, textTheme),
              ),
              verticalDivider,
              Expanded(
                child: _buildStatItem(context, Icons.swap_horiz_outlined, '${user.productCount} 筆交易', colorScheme, textTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProductsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, List<Product> products) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
          child: Text('上架商品 (${products.length})', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        ),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
            child: Center(child: Text('這位用戶暫無上架商品')),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductListItem(context, product, colorScheme, textTheme);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
      ]),
    );
  }

  Widget _buildProductListItem(BuildContext context, Product product, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductScreen(productId: product.id)),
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
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      child: Center(child: Icon(Icons.broken_image_outlined, color: colorScheme.onSurfaceVariant, size: 30)),
                    ),
                  )
                      : Container(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Center(child: Icon(Icons.image_not_supported_outlined, color: colorScheme.onSurfaceVariant, size: 30)),
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
                            product.name,
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                product.description,
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'NT\$ ${product.price.toStringAsFixed(0)}',
                        style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
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

  Widget _buildSection(BuildContext context, {required String title, required Widget content, Widget? trailing}) {
    final textTheme = Theme.of(context).textTheme;
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
