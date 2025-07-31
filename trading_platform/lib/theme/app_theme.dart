import 'package:flutter/material.dart';


const Color accentGreen = Color(0xFF3DFF9E);
const Color primaryBlue = Color(0xFF004E98);
const Color accentOrange = Color(0xFFFF8D36);
const Color accentGreenSlightlyMuted = Color(0xFF50E0A0); // 稍微柔和的綠色
const Color neutralGray = Color(0xFFD1D6E2);
const Color lightBackground = Color(0xFFEBEBEB);

const Color darkBlue = Color(0xFF304F6D);
const Color grayGreen = Color(0xFF899481);
const Color slightOrange = Color(0xFFE07D54);
const Color lightYellow = Color(0xFFFFFCF3);
const Color lightBlue = Color(0xFFE2F3FD);
const Color lightBrown = Color(0xFFE6E1DD);

final ColorScheme primaryCS = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    secondary: accentOrange,
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black38,
    surface: neutralGray,
    onSurface: darkBlue
);


final ColorScheme lightColorScheme = ColorScheme(

  brightness: Brightness.light,
  primary: primaryBlue,
  onPrimary: Colors.white,
  primaryContainer: Color.lerp(primaryBlue, Colors.white, 0.85),
  onPrimaryContainer: primaryBlue,

  secondary: accentOrange, // 主要行動呼籲色
  onSecondary: Colors.white, // 或一個非常深的藍色/黑色以確保對比
  secondaryContainer: Color.lerp(accentOrange, Colors.white, 0.85),
  onSecondaryContainer: const Color(0xFF3B1E00), // 深橙色區域的文字

  tertiary: accentGreenSlightlyMuted, // 次要強調，柔和處理
  onTertiary: Colors.black, // 或深藍色
  tertiaryContainer: Color.lerp(accentGreenSlightlyMuted, Colors.white, 0.85),
  onTertiaryContainer: const Color(0xFF00381A), // 深綠色區域的文字

  error: const Color(0xFFB00020),
  onError: Colors.white,
  errorContainer: const Color(0xFFFCD8DF),
  onErrorContainer: const Color(0xFF141213),
  surface: const Color(0xFFD1D6E2), // 卡片等使用純白，更突出
  onSurface: Colors.black87,
  surfaceContainerHighest: neutralGray,
  onSurfaceVariant: Colors.black54,

  outline: accentOrange,
  outlineVariant: neutralGray.withOpacity(0.4),

  shadow: Colors.black.withOpacity(0.1),
  scrim: Colors.black.withOpacity(0.2),
  inverseSurface: const Color(0xFF303030),
  onInverseSurface: Color(0xFFEBEBEB),
  inversePrimary: Colors.white.withOpacity(0.9),
  surfaceTint: primaryBlue,
);

// --- 深色主題 ColorScheme ---
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: primaryBlue, // 深色模式下 primaryBlue 仍然適用，或者可以稍微調亮
  onPrimary: Colors.white,

  primaryContainer: Color.lerp(primaryBlue, Colors.black, 0.6), // 更深的主要容器色
  onPrimaryContainer: Color.lerp(primaryBlue, Colors.white, 0.2), // 在深色 primaryContainer 上的亮色文字

  secondary: accentGreen, // accentGreen 在深色模式下可能需要降低飽和度或調亮
  onSecondary: Colors.black, // 仍然需要確保對比度，如果 accentGreen 調整了，這裡也要調整

  secondaryContainer: Color.lerp(accentGreen, Colors.black, 0.7),
  onSecondaryContainer: Color.lerp(accentGreen, Colors.white, 0.1),

  tertiary: accentOrange, // accentOrange 在深色模式下可能也需要調整
  onTertiary: Colors.black,

  tertiaryContainer: Color.lerp(accentOrange, Colors.black, 0.7),
  onTertiaryContainer: Color.lerp(accentOrange, Colors.white, 0.1),

  error: const Color(0xFFCF6679), // 深色模式下的錯誤紅
  onError: Colors.black,

  errorContainer: const Color(0xFFB00020),
  onErrorContainer: const Color(0xFFF9DEDC),

  surface: const Color(0xFF1E1E1E), // 比背景稍亮的深色表面
  onSurface: Colors.white.withOpacity(0.87),

  surfaceContainerHighest: const Color(0xFF303030), // 深色模式下的 neutralGray 變體
  onSurfaceVariant: Colors.white.withOpacity(0.6),

  outline: neutralGray.withOpacity(0.5),
  outlineVariant: neutralGray.withOpacity(0.3),

  shadow: Colors.black.withOpacity(0.25),
  scrim: Colors.black.withOpacity(0.5),

  inverseSurface: lightBackground.withOpacity(0.95), // 淺色背景，用於 Snackbar 等
  onInverseSurface: Colors.black.withOpacity(0.9),

  inversePrimary: primaryBlue.withOpacity(0.8),
  surfaceTint: primaryBlue,
);

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,

);

final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
);