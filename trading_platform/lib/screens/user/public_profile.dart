import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../providers/auth_provider.dart';

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
  String _userLocation = '未知地點';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    print("PublicUserProfilePage: Displaying profile for User ID: ${widget.userId}");
  }

  void _loadProfileData() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _username = '用戶 ${widget.userId}';
          _avatarUrl = '';
          _completedTransactions = (widget.userId.hashCode % 100).abs(); // 模擬成交量
          _bio = '這是用戶 ${widget.userId} 的公開介紹。熱愛編程和旅行！目前已完成 $_completedTransactions 筆交易。';
          _userSchool = widget.userId.hashCode.isEven ? '台灣科技大學' : '範例大學';
          _userLocation = widget.userId.hashCode.isOdd ? '台北市大安區' : '新北市板橋區';
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentLoggedInUserId = authProvider.currentUser?.id;
    final bool isViewingOwnProfile = currentLoggedInUserId != null && currentLoggedInUserId == widget.userId;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      // extendBodyBehindAppBar: true, // 如果你想讓 body 內容延伸到 AppBar (即我們的 header) 之後
      // appBar: PreferredSize( // 如果你想要一個透明的 AppBar 來觸發返回手勢，但內容在 body 裡
      //   preferredSize: Size.fromHeight(0), // 高度為 0
      //   child: AppBar(
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     leading: Navigator.canPop(context) ? BackButton(color: colorScheme.onPrimary) : null,
      //   ),
      // ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center( /* ... Error UI ... */ )
          : CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, colorScheme, textTheme), // <--- 使用修改後的 header
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
            child: _buildUserStats(context, colorScheme, textTheme),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _buildSection(
              context,
              title: '上架商品',
              content: Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      color: colorScheme.surfaceVariant,
                      margin: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 120,
                        child: Center(child: Text('商品 ${index + 1}', style: TextStyle(color: colorScheme.onSurfaceVariant),)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: _isLoading || isViewingOwnProfile
          ? null
          : FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('與 $_username 開始聊天（功能待實現）'))
          );
        },
        icon: const Icon(Icons.message_outlined),
        label: const Text('傳送訊息'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final double profileCurveHeight = 50.0;
    final double avatarRadius = 40.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack( // <--- 使用 Stack
      children: [
        Container(
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
          padding: EdgeInsets.fromLTRB(
            // 根據返回按鈕調整左邊距，確保主要內容不會和按鈕重疊太多
            Navigator.canPop(context) ? 56.0 : 16.0, // 56 可以根據按鈕寬度調整
            statusBarHeight + 20.0,
            16.0,
            profileCurveHeight + 20.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 如果返回按鈕在 Stack 中絕對定位，這裡可能不需要額外處理 CircleAvatar 的位置
              // 主要內容會自然地從 padding 開始
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                child: _avatarUrl.isEmpty
                    ? Icon(
                  Icons.person,
                  size: avatarRadius * 1.1,
                  color: colorScheme.primary,
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _username,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.userId}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 添加返回按鈕
        if (Navigator.canPop(context))
          Positioned(
            top: statusBarHeight + 8, // 調整以使其在視覺上居中於 Header 的交互區域
            left: 8,
            child: Material( // 添加 Material 以確保 IconButton 有水波紋效果且正確裁剪
              type: MaterialType.transparency,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                onPressed: () => Navigator.maybePop(context),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
          ),
      ],
    );
  }

  // _buildUserStats, _buildStatItem, _buildSection 方法保持不變
  // ... (複製貼上這些輔助方法到這裡)
  Widget _buildUserStats(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, Icons.school_outlined, _userSchool, "學校", colorScheme, textTheme),
              _buildStatItem(context, Icons.location_on_outlined, _userLocation, "地點", colorScheme, textTheme),
              _buildStatItem(context, Icons.swap_horiz_outlined,
                  '$_completedTransactions 筆', "成交量", colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
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
