// --- FILE: lib/screens/main_market.dart ---
import 'package:flutter/material.dart';
import 'search.dart';
import 'announcement.dart';
import 'user/profile.dart'; // 確保 profile.dart 位於 user/ 資料夾下
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../widgets/market_search_bar.dart';
import '../theme/app_theme.dart'; // 【【錯誤 2 修正】】引入主題設定檔

class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _marketSearchController = TextEditingController();
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // --- 【【錯誤 1 修正】】 ---
  // Profile() 現在是無參數的，它會自己從 AuthProvider 獲取使用者資料。
  final List<Widget> _pages = const [
    HomePage(),
    ChatListScreen(),
    AnnouncementListScreen(),
    Profile(), // 不再需要傳入 currentUser
  ];

  @override
  void dispose() {
    _marketSearchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMarketSearchPage() {
    String searchText = _marketSearchController.text.trim();
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(searchText: searchText),
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 【【錯誤 1 修正】】移除不再需要的 dummyUser ---

    // 從主題中獲取顏色配置
    final primaryCS = Theme.of(context).extension<MyThemesExtension>()!;
    bool showMarketSearchBar = _currentIndex == 0;

    return Scaffold(
      appBar: showMarketSearchBar
          ? AppBar(
        title: MarketSearchBar(
          controller: _marketSearchController,
          onSubmitted: (_) => _navigateToMarketSearchPage(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      )
          : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // 使用主題中的顏色來定義漸層
          gradient: LinearGradient(
            colors: [
              primaryCS.primary,
              primaryCS.primary.withOpacity(0.9)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryCS.shadow?.withOpacity(0.1) ?? Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          // 使用主題中的顏色來設定項目顏色
          selectedItemColor: primaryCS.secondary,
          unselectedItemColor: primaryCS.onSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: '訊息'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: '通知'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '個人檔案'),
          ],
        ),
      ),
    );
  }
}
