import 'package:flutter/material.dart';

// 你提供的顏色常量
// const Color primaryBlue = Color(0xFF004E98);
const Color accentGreen = Color(0xFF3DFF9E);
// const Color neutralGray = Color(0xFFD1D6E2);
// const Color lightBackground = Color(0xFFEBEBEB);
// const Color accentOrange = Color(0xFFFF8D36);

const Color primaryBlue = Color(0xFF004E98);
const Color accentOrange = Color(0xFFFF8D36);
const Color accentGreenSlightlyMuted = Color(0xFF50E0A0); // 稍微柔和的綠色
const Color neutralGray = Color(0xFFD1D6E2);
const Color lightBackground = Color(0xFFEBEBEB);

final ColorScheme option1LightColorScheme = ColorScheme(
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
  surface: Colors.white, // 卡片等使用純白，更突出
  onSurface: Colors.black87,
  surfaceContainerHighest: neutralGray,
  onSurfaceVariant: Colors.black54,

  outline: neutralGray.withOpacity(0.7),
  outlineVariant: neutralGray.withOpacity(0.4),

  shadow: Colors.black.withOpacity(0.1),
  scrim: Colors.black.withOpacity(0.2),
  inverseSurface: const Color(0xFF303030),
  onInverseSurface: Colors.white,
  inversePrimary: Colors.white.withOpacity(0.9),
  surfaceTint: primaryBlue,
);

// --- 淺色主題 ColorScheme ---
final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: primaryBlue,
  onPrimary: Colors.white, // 在 primaryBlue 上的文字/圖標

  primaryContainer: Color.lerp(primaryBlue, Colors.white, 0.8), // 一個更淺的主要容器色
  onPrimaryContainer: primaryBlue, // 在 primaryContainer 上的文字/圖標

  secondary: accentGreen,
  onSecondary: Colors.black, // 在 accentGreen 上的文字/圖標 (需要確保對比度)
  // 如果 accentGreen 太亮，考慮深灰色或 primaryBlue

  secondaryContainer: Color.lerp(accentGreen, Colors.white, 0.8),
  onSecondaryContainer: Colors.black, // 同上，注意對比度

  tertiary: accentOrange,
  onTertiary: Colors.black, // 在 accentOrange 上的文字/圖標 (確保對比度)

  tertiaryContainer: Color.lerp(accentOrange, Colors.white, 0.8),
  onTertiaryContainer: Colors.black,

  error: const Color(0xFFB00020), // 標準的 Material Design 錯誤紅
  onError: Colors.white,

  errorContainer: const Color(0xFFFCD8DF),
  onErrorContainer: const Color(0xFF141213), // 主要文字顏色

  surface: Colors.white, // 卡片、對話框等的背景色 (比 lightBackground 更白一層)
  onSurface: Colors.black.withOpacity(0.87),

  surfaceContainerHighest: neutralGray, // 用於不同層次的表面，或次要背景
  onSurfaceVariant: Colors.black.withOpacity(0.6), // 在 neutralGray 上的文字，顏色可以略淺

  outline: neutralGray.withOpacity(0.7), // 邊框顏色
  outlineVariant: neutralGray.withOpacity(0.4), // 更細微的邊框

  shadow: Colors.black.withOpacity(0.15),
  scrim: Colors.black.withOpacity(0.3), // 遮罩層

  inverseSurface: Colors.black.withOpacity(0.85), // 深色背景，用於 Snackbar 等
  onInverseSurface: Colors.white.withOpacity(0.95), // 在 inverseSurface 上的文字

  inversePrimary: Colors.white.withOpacity(0.9), // 用於在深色背景上模擬 primary 效果
  surfaceTint: primaryBlue, // 用於給表面輕微著色，特別是在 Material 3 中
);


// --- 深色主題 ColorScheme ---
// 在深色主題中，我們會反轉亮度和顏色的飽和度/明度
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

// 如何在 MaterialApp 中使用：
/*
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    // 其他淺色主題設置...
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    // 其他深色主題設置...
  ),
  themeMode: ThemeMode.system, // 或 ThemeMode.light, ThemeMode.dark
  // ...
)
*/