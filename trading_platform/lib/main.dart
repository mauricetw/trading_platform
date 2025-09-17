// --- FILE: lib/main.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// (imports 保持不變)
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/announcement_provider.dart';

import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
import 'services/order_service.dart';
import 'services/address_service.dart';
import 'services/announcement_service.dart';
import 'services/upload_service.dart';

import 'screens/auth/login_main.dart';
import 'screens/main_market.dart';
import 'screens/splash_screen.dart';

import 'theme/app_theme.dart';

void main() {
  // (依賴注入部分保持不變)
  final ApiClient apiClient = ApiClient();
  final AuthService authService = AuthService(apiClient);
  final UserService userService = UserService(apiClient);
  final ProductService productService = ProductService(apiClient);
  final CartService cartService = CartService(apiClient);
  final WishlistService wishlistService = WishlistService(apiClient);
  final AnnouncementService announcementService = AnnouncementService(apiClient);
  final UploadService uploadService = UploadService(apiClient);
  final OrderService orderService = OrderService();
  final AddressService addressService = AddressService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, userService, apiClient, uploadService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productService, uploadService),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnouncementProvider(announcementService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(cartService, null),
          update: (_, auth, previousCart) {
            previousCart?.update(auth);
            return previousCart ?? CartProvider(cartService, auth);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(wishlistService, null),
          update: (_, auth, previousWishlist) {
            previousWishlist?.update(auth);
            return previousWishlist ?? WishlistProvider(wishlistService, auth);
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, CartProvider, CheckoutProvider>(
          create: (_) => CheckoutProvider(orderService, addressService, null, null),
          update: (_, auth, cart, previousCheckout) {
            previousCheckout?.update(auth, cart);
            return previousCheckout ?? CheckoutProvider(orderService, addressService, auth, cart);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '交易平台',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginMainPage(),
        '/home': (context) {
          // --- 關鍵修正：不再需要檢查 currentUser 或手動傳遞 ---
          // AuthProvider 的狀態會由 SplashScreen 或登入流程處理好
          // 直接回傳 MainMarket 即可
          return const MainMarket();
        },
      },
    );
  }
}
