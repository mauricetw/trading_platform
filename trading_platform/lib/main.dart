import 'package:flutter/material.dart';
import '../screens/main_market.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/category_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/checkout_provider.dart';

import 'services/wishlist_service.dart';

import 'models/user/user.dart';
import 'theme/app_theme.dart';

void main() {

  runApp(
    // 使用 MultiProvider 替換單個 ChangeNotifierProvider
    MultiProvider(
      providers: [
        // AuthProvider
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        // CategoryProvider
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        // WishlistService
        //    WishlistService 本身不是 ChangeNotifier，所以使用 Provider<T>.
        Provider<WishlistService>(
          create: (_) => WishlistService(),
          // 如果 WishlistService 需要在銷毀時清理資源 (例如關閉 http.Client)，
          // 則需要更複雜的處理，但對於簡單的 Service，這樣通常足夠。
        ),

        // WishlistProvider (依賴 AuthProvider 和 WishlistService)
        ChangeNotifierProxyProvider2<AuthProvider, WishlistService, WishlistProvider>(
          // 泛型參數:
          // AuthProvider:      第一個依賴的 Provider
          // WishlistService:   第二個依賴的 Provider/Service
          // WishlistProvider:  我們要創建並提供的 ChangeNotifier

          create: (context) {
            // 'create' 在 MultiProvider 第一次構建時被調用。
            // 在這裡，我們需要創建一個 WishlistProvider 的初始實例。
            // 我們可以從上下文中讀取已經註冊的 WishlistService。
            final wishlistService = context.read<WishlistService>();
            return WishlistProvider(wishlistService); // WishlistProvider 構造函數接收 WishlistService
          },
          update: (
              BuildContext context,
              AuthProvider authProvider,       // 來自 AuthProvider 的最新值
              WishlistService wishlistService,  // 來自 Provider<WishlistService> 的實例 (通常不變)
              WishlistProvider? previousWishlistProvider, // 上一個 WishlistProvider 實例 (可能為 null)
              ) {
            // 'update' 會在 AuthProvider (因為它是 ChangeNotifier) 狀態改變時被調用，
            // 或者如果 WishlistService 也是 ChangeNotifier 並且改變時 (本例中不是)。
            // 它也會在 MultiProvider 重建時被調用。

            // 確保我們有一個 WishlistProvider 實例。
            // 如果 previousWishlistProvider 是 null (例如首次創建後)，
            // 或者您希望在每次依賴更新時都創建新實例（不常見），則創建新的。
            // 通常，我們會重用 previousWishlistProvider 並更新其狀態。
            final wishlistProvider = previousWishlistProvider ?? WishlistProvider(wishlistService);

            // 關鍵：將 AuthProvider 的狀態更新傳遞給 WishlistProvider
            wishlistProvider.updateCurrentUser(authProvider.currentUser?.id);

            return wishlistProvider;
          },
        ),

        // 添加其他您需要的 Providers
        ChangeNotifierProvider(create: (context) => CartProvider()),


      ],
      // child 屬性仍然是你的應用程式的根 Widget
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading Platform',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,

      // 不再直接設置 home，而是通過 Consumer 決定
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 檢查用戶是否已登錄
          if (authProvider.isLoggedIn && authProvider.currentUser != null) {
            final User currentUser = authProvider.currentUser!;

            // 檢查用戶是否為賣家
            // 您可以根據 User 模型中的 isSeller 屬性或 roles 列表來判斷
            bool isSeller = currentUser.isSeller ?? false;
            // 或者更嚴謹的判斷，如果 roles 列表存在且包含 'seller'
            // if (currentUser.roles != null && currentUser.roles!.contains('seller')) {
            //   isSeller = true;
            // }

            if (isSeller) {
              // 如果是賣家，導向賣家儀表板
              // 確保 SellerDashboardScreen 的構造函數是 const SellerDashboardScreen()
              // 它會從內部通過 Provider 獲取 currentUser
              return const MainMarket();
            } else {
              // 如果已登錄但不是賣家，可以導向市場主頁或其他普通用戶頁面
              // 這裡我們假設 MainMarket 也可以作為普通登錄用戶的主頁
              print("User '${currentUser.username}' is logged in but not a seller. Showing MainMarket.");
              return const MainMarket(); // 或者一個 BuyerDashboardScreen()
            }
          } else {
            // 如果用戶未登錄，顯示 MainMarket (假設它是登錄頁面或公共市場頁)
            print("User not logged in. Showing MainMarket.");
            return const MainMarket();
          }
        },
      ),
      // 您可能還會有路由表，用於處理命名路由
      // routes: {
      //   '/login': (context) => LoginScreen(), // 假設您有 LoginScreen
      //   '/main_market': (context) => const MainMarket(),
      //   '/seller_dashboard': (context) => const SellerDashboardScreen(),
      //   // ... 其他路由
      // },
    );
  }
}