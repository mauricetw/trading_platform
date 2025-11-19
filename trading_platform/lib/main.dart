// --- FILE: lib/main.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/order_provider.dart';
import 'providers/seller_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/wishpool_provider.dart';
import 'providers/wishpool_invite_provider.dart';
import 'providers/address_provider.dart';

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
import 'services/chat_service.dart';
import 'services/websocket_service.dart';
import 'services/wishpool_service.dart';
import 'services/wishpool_invite_service.dart';

import 'screens/auth/login_main.dart';
import 'screens/main_market.dart';
import 'screens/splash_screen.dart';
import 'screens/wishpool/wishpool_main.dart';

import 'theme/app_theme.dart';

void main() {
  // 1. 建立共用的 ApiClient 實例 (它會持有 Token)
  final ApiClient apiClient = ApiClient();

  // 2. 將 apiClient 注入到各個 Service
  final AuthService authService = AuthService(apiClient);
  final UserService userService = UserService(apiClient);
  final ProductService productService = ProductService(apiClient);
  final CartService cartService = CartService(apiClient);
  final WishlistService wishlistService = WishlistService(apiClient);
  final AnnouncementService announcementService = AnnouncementService(apiClient);
  final UploadService uploadService = UploadService(apiClient);
  final OrderService orderService = OrderService(apiClient);
  final AddressService addressService = AddressService(apiClient);
  final ChatService chatService = ChatService(apiClient);
  final WebSocketService webSocketService = WebSocketService();

  final WishPoolService wishPoolService = WishPoolService(apiClient);
  final WishPoolInviteService wishPoolInviteService = WishPoolInviteService(apiClient);


  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>(
          create: (_) => userService,
        ),

        Provider<OrderService>(
          create: (_) => orderService,
        ),

        Provider<AddressService>(
          create: (_) => addressService,
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, userService, apiClient, uploadService),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductProvider(productService, uploadService),
        ),

        // --- [修改] 注入 ProductService 到 CategoryProvider ---
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(productService),
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

        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(chatService, webSocketService, null),
          update: (_, auth, previousChat) {
            previousChat?.update(auth);
            return previousChat ?? ChatProvider(chatService, webSocketService, auth);
          },
        ),

        ChangeNotifierProxyProvider2<AuthProvider, CartProvider, CheckoutProvider>(
          create: (_) => CheckoutProvider(orderService, addressService, null, null),
          update: (_, auth, cart, previousCheckout) {
            previousCheckout?.update(auth, cart);
            return previousCheckout ?? CheckoutProvider(orderService, addressService, auth, cart);
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(orderService, null),
          update: (_, auth, previousOrders) {
            previousOrders?.update(auth);
            return previousOrders ?? OrderProvider(orderService, auth);
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, SellerProvider>(
          create: (_) => SellerProvider(orderService, null),
          update: (_, auth, previous) {
            previous?.update(auth);
            return previous ?? SellerProvider(orderService, auth);
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
          create: (ctx) => AddressProvider(
              Provider.of<AddressService>(ctx, listen: false),
              null
          ),
          update: (ctx, auth, previous) {
            previous?.update(auth);
            return previous ?? AddressProvider(
                Provider.of<AddressService>(ctx, listen: false),
                auth
            );
          },
        ),

        ChangeNotifierProvider(
          create: (_) => WishPoolProvider(wishPoolService),
        ),
        ChangeNotifierProvider(
          create: (_) => WishPoolInviteProvider(wishPoolInviteService),
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
          return const MainMarket();
        },
      },
    );
  }
}