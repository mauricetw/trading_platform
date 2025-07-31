import 'package:first_flutter_project/screens/settings/setting.dart';
import 'package:flutter/material.dart';
import '../../models/user/user.dart'; // 確保路徑正確
import 'public_profile.dart';
import '../cart.dart'; // 確保路徑正確
import '../orderlist.dart'; // 確保路徑正確
import '../seller/product_management.dart';
import '../seller/order_page.dart';
import '../seller/shipping_setting_page.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../theme/app_theme.dart';

class Profile extends StatelessWidget {
  final User currentUser;
  final String userLocation = "台北市大安區"; // 示例數據
  final String userSchool = "台灣科技大學"; // 示例數據
  final int completedTransactionNumber = 8; // 示例數據

  const Profile({super.key, required this.currentUser});

  Widget _buildInfoText(
      BuildContext context,
      String text, {
        double? fontSize,
        Color? color,
        FontWeight? fontWeight,
        TextAlign textAlign = TextAlign.start,
        TextStyle? baseStyle,
      }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle effectiveBaseStyle = baseStyle ?? textTheme.bodyLarge ?? const TextStyle(fontSize: 16.0, color: Colors.black87);

    return Text(
      text,
      textAlign: textAlign,
      style: effectiveBaseStyle.copyWith(
        color: color ?? effectiveBaseStyle.color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildStyledButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle buttonTextStyle = textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 16,
        color: primaryCS.onPrimary
    ) ?? TextStyle(
        fontWeight: FontWeight.w100,
        fontSize: 16,
        color: primaryCS.onPrimary
    );

    Widget buttonContent;
    if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryCS.onPrimary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: buttonTextStyle),
        ],
      );
    } else {
      buttonContent = Text(label, style: buttonTextStyle);
    }

    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCS.primary,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          elevation: 2,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: buttonContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double settingsButtonVerticalOffset = 5.0;
    final double settingsButtonApproxHeight = (IconTheme.of(context).size ?? 24.0) + (8.0 * 2);
    final double desiredAvatarTopMarginFromSettingsBottom = 10.0;
    final double profileInfoTopPadding = statusBarHeight +
        settingsButtonVerticalOffset +
        settingsButtonApproxHeight +
        desiredAvatarTopMarginFromSettingsBottom;

    final double avatarRadius = 45.0;
    final double infoRowHeightEstimate = (textTheme.titleMedium?.fontSize ?? 16.0) * 1.5;
    final double profileInfoContentHeightEstimate = (avatarRadius * 2) + 12.0 + infoRowHeightEstimate + 20.0;
    final double profileCurveHeight = 50.0;
    final double profileInfoBottomPaddingForContent = 20.0;
    final double greenBackgroundBottomY = profileInfoTopPadding + profileInfoContentHeightEstimate + profileInfoBottomPaddingForContent;
    final double schoolInfoAreaTopOffset = greenBackgroundBottomY;
    final double schoolCardOverlapAdjustment = 10.0;
    final double schoolCardContentTopPadding = profileCurveHeight - schoolCardOverlapAdjustment;

    return Scaffold(
      backgroundColor: primaryCS.surfaceContainerHighest,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: schoolInfoAreaTopOffset),
                      child: Container(
                        width: double.infinity,
                        color: primaryCS.surfaceContainerHighest,
                        padding: EdgeInsets.only(
                          top: schoolCardContentTopPadding,
                          left: 20.0,
                          right: 20.0,
                          bottom: 0.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 16.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildInfoText(
                                    context,
                                    userSchool,
                                    baseStyle: textTheme.titleMedium,
                                    color: primaryCS.onSurface,
                                    fontWeight: FontWeight.w500,
                                    textAlign: TextAlign.center,
                                  ),
                                  if ((user.schoolName != null && user.schoolName!.isNotEmpty) &&
                                      userLocation.isNotEmpty)
                                    const SizedBox(height: 5),
                                  if (userLocation.isNotEmpty)
                                    _buildInfoText(
                                      context,
                                      userLocation,
                                      baseStyle: textTheme.bodyMedium,
                                      color: primaryCS.onSurfaceVariant,
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: primaryCS.primary,
                        shape: FullBottomConcaveAppBarShape(
                          curveHeight: profileCurveHeight,
                          topCornerRadius: 15.0,
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
                        20.0,
                        profileInfoTopPadding,
                        20.0,
                        profileInfoBottomPaddingForContent + profileCurveHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: primaryCS.surfaceContainerHighest.withOpacity(0.8),
                            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                ? Icon(
                              Icons.person,
                              size: avatarRadius * 1.1,
                              color: primaryCS.primary,
                            )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // --- MODIFIED SECTION START ---
                          InkWell(
                            onTap: () {
                              print('Username/ID row tapped. User ID: ${user.id}');
                              if (user.id != null && user.id!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PublicUserProfilePage(userId: user.id!), // 假設 PublicUserProfilePage 已創建
                                  ),
                                );
                              } else {
                                print("User ID is null or empty, cannot navigate.");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('用戶ID無效，無法導航')),
                                );
                              }
                            },
                            splashColor: primaryCS.onPrimary.withOpacity(0.12),
                            highlightColor: primaryCS.onPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8.0), // 給水波紋效果一個圓角
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // 調整內邊距
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // 外部 Row 居中
                                mainAxisSize: MainAxisSize.min, // 使外部 Row 根據內容收縮
                                children: [
                                  Flexible( // 讓用戶名和ID部分可以被壓縮
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min, // 內部 Row 根據內容收縮
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: _buildInfoText(
                                            context,
                                            user.username,
                                            baseStyle: textTheme.titleMedium?.copyWith(fontSize: 16),
                                            color: primaryCS.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            "•",
                                            style: TextStyle(color: primaryCS.onPrimary, fontSize: 14),
                                          ),
                                        ),
                                        Flexible(
                                          child: _buildInfoText(
                                            context,
                                            "ID: ${user.id ?? 'N/A'}",
                                            baseStyle: textTheme.bodyMedium?.copyWith(fontSize: 18),
                                            color: primaryCS.onPrimary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8), // 用戶名/ID 與箭頭之間的間距
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: primaryCS.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // --- MODIFIED SECTION END ---
                        ],
                      ),
                    ),
                  ],
                ),
                // --- 下方按鈕區 ---
                Container(
                  color: primaryCS.surface,
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: primaryCS.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          '我是買家',
                          style: textTheme.titleMedium?.copyWith(
                              color: primaryCS.onSurface,
                              fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStyledButton(
                            context: context,
                            label: '收藏',
                            icon: Icons.favorite_border,
                            onPressed: () { print('收藏'); },
                          ),
                          const SizedBox(width: 15),
                          _buildStyledButton(
                            context: context,
                            label: '購物車',
                            icon: Icons.shopping_cart_outlined,
                            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage())); },
                          ),
                          const SizedBox(width: 15),
                          _buildStyledButton(
                            context: context,
                            label: '訂單資訊',
                            icon: Icons.receipt_long_outlined,
                            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen())); },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: primaryCS.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          '我是賣家',
                          style: textTheme.titleMedium?.copyWith(
                              color: primaryCS.onSurface,
                              fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStyledButton(
                            context: context,
                            label: '商品管理',
                            icon: Icons.inventory_2_outlined,
                            onPressed: () {
                              print('導航到：商品管理');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductManagementScreen(currentUser: currentUser)));
                            },
                          ),
                          const SizedBox(width: 15),
                          _buildStyledButton(
                            context: context,
                            label: '訂單管理',
                            icon: Icons.article_outlined,
                            onPressed: () {
                              print('導航到：訂單管理');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SellerOrderPage()));
                            },
                          ),
                          const SizedBox(width: 15),
                          _buildStyledButton(
                            context: context,
                            label: '運送設定',
                            icon: Icons.local_shipping_outlined,
                            onPressed: () {
                              print('導航到：運送設定');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingSettingsPage()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: statusBarHeight + settingsButtonVerticalOffset,
            right: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.settings_outlined,
                    color: primaryCS.secondary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 假設的 PublicUserProfilePage 頁面 (你需要創建這個文件和類)
// lib/screens/user/public_user_profile_page.dart
/*
import 'package:flutter/material.dart';

class PublicUserProfilePage extends StatelessWidget {
  final String userId;

  const PublicUserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用戶資料 (ID: $userId)'),
      ),
      body: Center(
        child: Text('這是用戶 $userId 的公開個人資料頁面。'),
      ),
    );
  }
}
*/
