import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 引入所有需要的 Providers ---
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/announcement_provider.dart';

// --- 引入所有需要的 Services ---
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

// --- 引入所有需要的頁面 ---
import 'screens/auth/login_main.dart';
import 'screens/main_market.dart';
import 'screens/splash_screen.dart';

// --- 引入主題設定 ---
import 'theme/app_theme.dart';

void main() {
  try {
    final ApiClient apiClient = ApiClient();
    final AuthService authService = AuthService(); // 不再需要傳入 apiClient
    final UserService userService = UserService(apiClient);
    final ProductService productService = ProductService(apiClient);
    final CartService cartService = CartService(apiClient);
    final WishlistService wishlistService = WishlistService(apiClient);
    final AnnouncementService announcementService = AnnouncementService(apiClient);
    final OrderService orderService = OrderService();
    final AddressService addressService = AddressService();
    final UploadService uploadService = UploadService(apiClient);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(authService, userService, apiClient),
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
  } catch (e) {
    debugPrint('Error in main: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('應用程式啟動錯誤: $e'),
          ),
        ),
      ),
    );
  }
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
          // 從 AuthProvider 獲取 currentUser
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final currentUser = authProvider.currentUser;

          if (currentUser != null) {
            return MainMarket(currentUser: currentUser);
          } else {
            // 如果沒有登入用戶，跳轉到登入頁面
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      },
    );
  }
}