import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../providers/auth_provider.dart';
import '../../models/product/product.dart';
import '../product.dart';

import '../../mock/data/mock_users.dart' as mock_users;
import '../../mock/data/mock_products.dart' as mock_products;

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
    // ignore: avoid_print
    print("PublicUserProfilePage: Displaying profile for User ID: ${widget.userId}");
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _loadProfileData(),
        _loadUserProducts(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '加載用戶資料失敗: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfileData() async {
    await Future.delayed(const Duration(milliseconds: 200)); // 模擬延遲
    final basics = mock_users.buildMockPublicProfileBasics(widget.userId);
    if (!mounted) return;
    setState(() {
      _username = basics.username;
      _avatarUrl = basics.avatarUrl;
      _completedTransactions = basics.completedTransactions;
      _bio = basics.bio;
      _userSchool = basics.school;
    });
  }

  Future<void> _loadUserProducts() async {
    await Future.delayed(const Duration(milliseconds: 300)); // 模擬延遲
    final products = mock_products.buildMockProductsForUser(widget.userId, count: 8);
    if (!mounted) return;
    setState(() {
      _userProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentLoggedInUserId = authProvider.currentUser?.id.toString();
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
        ),
      )
          : CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildProfileHeader(context, colorScheme, textTheme)),
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
          SliverToBoxAdapter(child: _buildUserStats(context, colorScheme, textTheme)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildUserProductsSection(context, colorScheme, textTheme),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: _isLoading || isViewingOwnProfile
          ? null
          : FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('與 $_username 開始聊天（功能待實現）')));
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('傳送訊息'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ======= UI (原有樣式保留) =======

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final double profileCurveHeight = 50.0;
    final double avatarRadius = 45.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool canPop = Navigator.canPop(context);

    final TextStyle usernameStyle = textTheme.headlineSmall?.copyWith(
      color: colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    ) ??
        TextStyle(fontSize: 24, color: colorScheme.onPrimary, fontWeight: FontWeight.bold);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: colorScheme.primary,
        shape: FullBottomConcaveAppBarShape(curveHeight: profileCurveHeight, topCornerRadius: 0),
        shadows: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: EdgeInsets.only(top: statusBarHeight + 16.0, bottom: profileCurveHeight + 16.0),
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
                    icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary),
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
              backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty
                  ? Icon(Icons.person_rounded, size: avatarRadius * 1.2, color: colorScheme.primary)
                  : null,
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
                  Text(_username, style: usernameStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${widget.userId}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.85)),
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

  Widget _buildUserStats(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    Widget verticalDivider = Container(
      height: 30,
      width: 1.5,
      decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.4), borderRadius: BorderRadius.circular(1)),
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: ShapeDecoration(color: colorScheme.surfaceVariant, shape: const StadiumBorder(), shadows: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
        ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildStatItem(context, Icons.school_outlined, _userSchool, colorScheme, textTheme)),
              verticalDivider,
              Expanded(
                  child: _buildStatItem(
                      context, Icons.swap_horiz_outlined, '$_completedTransactions 筆', colorScheme, textTheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, ColorScheme colorScheme, TextTheme textTheme) {
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

  SliverList _buildUserProductsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
            child: Text('上架商品 (${_userProducts.length})',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (_userProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
              child: Center(child: Text('這位用戶暫無上架商品', style: textTheme.bodyMedium)),
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

  Widget _buildProductListItem(
      BuildContext context, Product product, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () {
          // ignore: avoid_print
          print('Tapped on product: ${product.name}, ID: ${product.id}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(productId: product.id, initialProduct: product),
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
                  child: (product.imageUrls.isNotEmpty)
                      ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: colorScheme.onSurfaceVariant, size: 30)),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    child: Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: colorScheme.onSurfaceVariant, size: 30)),
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
                          Text(product.name,
                              style:
                              textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          if (product.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                product.description,
                                style: textTheme.bodySmall
                                    ?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'NT\$ ${product.price.toStringAsFixed(0)}',
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

  Widget _buildSection(BuildContext context, {required String title, required Widget content, Widget? trailing}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
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
