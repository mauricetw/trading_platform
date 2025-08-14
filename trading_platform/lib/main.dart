// --- FILE: lib/main.dart ---
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

// --- 引入所有需要的頁面 ---
import 'screens/auth/login_main.dart';
import 'screens/main_market.dart';
import 'screens/splash_screen.dart';

// --- 引入主題設定 ---
import 'theme/app_theme.dart';

void main() {
  // --- 1. 建立所有 Service 的單一實例 ---
  // 我們只建立一次，然後透過 Provider 傳遞給需要它們的地方
  final ApiClient apiClient = ApiClient();
  final AuthService authService = AuthService(apiClient);
  final UserService userService = UserService(apiClient);
  final ProductService productService = ProductService(apiClient);
  final CartService cartService = CartService(apiClient);
  final WishlistService wishlistService = WishlistService(apiClient);
  final AnnouncementService announcementService = AnnouncementService(apiClient);
  // 模擬服務
  final OrderService orderService = OrderService();
  final AddressService addressService = AddressService();

  runApp(
    // 使用 MultiProvider 註冊 App 所需的所有狀態管理器
    MultiProvider(
      providers: [
        // --- 2. 建立基礎 Provider ---
        ChangeNotifierProvider(
          create: (context) => AuthProvider(authService, userService, apiClient),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(productService),
        ),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        // 註冊 Provider
        ChangeNotifierProvider(create: (context) => AnnouncementProvider(announcementService)),

        // --- 3. 建立依賴其他 Provider 的 ProxyProvider ---
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (context) => CartProvider(cartService, null),
          update: (context, auth, previousCart) {
            previousCart?.update(auth);
            return previousCart ?? CartProvider(cartService, auth);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (context) => WishlistProvider(wishlistService, null),
          update: (context, auth, previousWishlist) {
            previousWishlist?.update(auth);
            return previousWishlist ?? WishlistProvider(wishlistService, auth);
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, CartProvider, CheckoutProvider>(
          create: (context) => CheckoutProvider(orderService, addressService, null, null),
          update: (context, auth, cart, previousCheckout) {
            previousCheckout?.update(auth, cart);
            return previousCheckout ?? CheckoutProvider(orderService, addressService, auth, cart);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
//       ),
//       //home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       home: const MainMarket(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '交易平台',

      // --- 整合點 1：使用組員版本的主題設定 ---
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system, // 根據系統設定自動切換亮暗模式

      // --- 整合點 2：使用你的 SplashScreen 作為 App 入口 ---
      // 這樣可以優雅地處理啟動時的認證檢查
      home: const SplashScreen(),

      // --- 整合點 3：使用你的命名路由，方便全域導航 ---
      // 確保 SplashScreen 和其他頁面可以使用這些路由
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainMarket(),
      },
    );
  }
}
