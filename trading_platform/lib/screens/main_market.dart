// --- FILE: lib/screens/main_market.dart ---
import 'package:flutter/material.dart';
import 'search.dart';
import 'announcement.dart';
import 'user/profile.dart';
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../widgets/market_search_bar.dart';
import '../theme/app_theme.dart';
// REFACTORED: 不再需要直接導入 User 模型，因為不再手動傳遞
// import '../models/user/user.dart';

class MainMarket extends StatefulWidget {
  // --- 關鍵修正：不再需要從外部接收 currentUser ---
  const MainMarket({super.key});

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _marketSearchController = TextEditingController();
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // --- 關鍵修正：_pages 列表現在直接建立 Profile()，不需要任何參數 ---
  // Profile 頁面自己會透過 Provider 獲取使用者資料
  final List<Widget> _pages = const [
    HomePage(),
    ChatListScreen(),
    AnnouncementListScreen(),
    Profile(),
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
          gradient: LinearGradient(
            colors: [
              primaryCS.primary,
              // 修正：使用 withOpacity (或您自訂的 withValues)
              primaryCS.primary.withOpacity(0.9)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
