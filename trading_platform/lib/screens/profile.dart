import 'package:first_flutter_project/screens/settings/setting.dart';
import 'package:flutter/material.dart';
import '../models/user/user.dart';
import 'cart.dart';
import 'review.dart';
import 'orderlist.dart';
import 'seller/store_management.dart';
import '../widgets/FullBottomConcaveAppBarShape.dart';
import 'package:first_flutter_project/theme/app_theme.dart'; // 確保正確導入

class Profile extends StatelessWidget {
  final User currentUser;
  final String userLocation = "台北市大安區";
  final String userSchool = "台灣科技大學";
  final double averageBuyReviewRate = 4.5;
  final double averageSellReviewRate = 4.8;

  const Profile({super.key, required this.currentUser});

  // 使用系統預設文本樣式，並允許微調
  Widget _buildInfoText(
      BuildContext context,
      String text, {
        double? fontSize,
        Color? color,
        FontWeight? fontWeight,
        TextAlign textAlign = TextAlign.start,
        TextStyle? baseStyle, // 允許傳入一個基礎的 TextTheme 樣式
      }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle effectiveBaseStyle = baseStyle ?? textTheme.bodyLarge ?? const TextStyle(fontSize: 16);

    return Text(
      text,
      textAlign: textAlign,
      style: effectiveBaseStyle.copyWith(
        color: color ?? effectiveBaseStyle.color, // 如果 color 為 null，使用 baseStyle 的顏色
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ElevatedButton.icon(
      icon: icon != null
          ? Icon(icon, color: colorScheme.onSecondary, size: 24)
          : const SizedBox.shrink(),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onSecondary, // 文字顏色 (on accentOrange)
        backgroundColor: colorScheme.secondary,    // 主要行動呼籲色 (accentOrange)
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 20), // 基於系統樣式調整
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: colorScheme.onPrimary, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary, // 文字顏色 (on primaryBlue)
          backgroundColor: colorScheme.primary,   // 主藍色 (primaryBlue)
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 16), // 基於系統樣式調整
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double profileInfoTopPadding = MediaQuery.of(context).padding.top + 10.0;
    final double profileInfoContentHeightEstimate = 120.0;
    final double profileCurveHeight = 50.0;
    final double profileInfoBottomPaddingForContent = 20.0;

    final double schoolInfoAreaTopOffset = profileInfoTopPadding + profileInfoContentHeightEstimate;
    final double schoolCardOverlapAdjustment = 10.0;
    final double schoolCardContentTopPadding = profileCurveHeight - schoolCardOverlapAdjustment;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // --- 1. 學校資訊的灰色背景條帶 (在最底層) ---
                Padding(
                  padding: EdgeInsets.only(top: schoolInfoAreaTopOffset),
                  child: Container(
                    width: double.infinity,
                    color: neutralGray, // 來自您的 app_theme.dart (surfaceContainerHighest)
                    padding: EdgeInsets.only(
                      top: schoolCardContentTopPadding,
                      left: 20.0,
                      right: 20.0,
                      bottom: 20.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 16.0,
                          ),
                          decoration: ShapeDecoration(
                            color: neutralGray, // 與父級背景一致
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildInfoText(
                                context,
                                userSchool,
                                baseStyle: textTheme.titleMedium, // 使用系統標題樣式
                                color: colorScheme.onSurface,     // 顏色來自 ColorScheme
                                fontWeight: FontWeight.w500,    // 保持或調整
                                textAlign: TextAlign.center,
                              ),
                              if (user.schoolName != null &&
                                  user.schoolName!.isNotEmpty &&
                                  userLocation.isNotEmpty)
                                const SizedBox(height: 5),
                              _buildInfoText(
                                context,
                                userLocation,
                                baseStyle: textTheme.bodyMedium, // 使用系統正文樣式
                                color: colorScheme.onSurfaceVariant, // 顏色來自 ColorScheme (例如 Colors.black54)
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 2. 個人資訊區塊 (在上方，帶形狀，底色改為 tertiary) ---
                Container(
                  decoration: ShapeDecoration(
                    color: colorScheme.tertiary, // 使用 ColorScheme 的 tertiary (accentGreenSlightlyMuted)
                    shape: FullBottomConcaveAppBarShape(
                      curveHeight: profileCurveHeight,
                      topCornerRadius: 15.0,
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25), // 可以考慮使用 colorScheme.shadow
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        // 使用 surfaceContainerHighest 或 neutralGray 作為背景
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null
                            ? Icon(
                          Icons.person,
                          size: 54,
                          color: colorScheme.onSurface.withOpacity(0.6), // 基於 onSurface 調整
                        )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInfoText(
                              context,
                              user.username,
                              baseStyle: textTheme.headlineSmall, // 例如：系統的大標題樣式
                              color: colorScheme.onTertiary,     // 文字顏色 on tertiary
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(height: 5),
                            _buildInfoText(
                              context,
                              user.id ?? 'N/A',
                              baseStyle: textTheme.titleMedium, // 例如：系統的中等標題樣式
                              color: colorScheme.onTertiary.withOpacity(0.85), // 文字顏色 on tertiary (稍暗)
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoText(context, '平均買家評價', baseStyle: textTheme.bodySmall, color: colorScheme.onTertiary, textAlign: TextAlign.end),
                          _buildInfoText(context, '$averageBuyReviewRate ★', baseStyle: textTheme.titleSmall, color: colorScheme.onTertiary, fontWeight: FontWeight.bold, textAlign: TextAlign.end),
                          const SizedBox(height: 8),
                          _buildInfoText(context, '平均賣家評價', baseStyle: textTheme.bodySmall, color: colorScheme.onTertiary, textAlign: TextAlign.end),
                          _buildInfoText(context, '$averageSellReviewRate ★', baseStyle: textTheme.titleSmall, color: colorScheme.onTertiary, fontWeight: FontWeight.bold, textAlign: TextAlign.end),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ), // Stack 結束

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _buildSecondaryButton(
                        context: context,
                        label: '收藏',
                        icon: Icons.favorite_border,
                        onPressed: () {
                          print('收藏');
                        },
                      ),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(
                        context: context,
                        label: '購物車',
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildSecondaryButton(
                        context: context,
                        label: '評價',
                        icon: Icons.star_border,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewPage()));
                        },
                      ),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(
                        context: context,
                        label: '設定',
                        icon: Icons.settings_outlined,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildPrimaryButton(
                    context: context,
                    label: '訂單資訊',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen()));
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildPrimaryButton(
                    context: context,
                    label: '銷售商品管理',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SellerDashboardScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
