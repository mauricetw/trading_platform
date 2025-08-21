// --- FILE: lib/screens/main_market.dart ---
import 'package:flutter/material.dart';
import 'search.dart';
import 'announcement.dart';
import 'user/profile.dart';
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../widgets/market_search_bar.dart';
import '../theme/app_theme.dart';
import '../models/user/user.dart'; // User 模型的導入

class MainMarket extends StatefulWidget {
  final User currentUser; // User 類型參數

  const MainMarket({super.key, required this.currentUser});

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _marketSearchController = TextEditingController();
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // 使用 getter 來動態生成 pages，確保能獲取到 currentUser
  List<Widget> get _pages => [
    const HomePage(),
    const ChatListScreen(),
    const AnnouncementListScreen(),
    Profile(currentUser: widget.currentUser), // 傳入 User 類型的 currentUser 參數
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
    // 直接使用 app_theme.dart 中定義的 primaryCS
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
          // 使用 app_theme.dart 中定義的 primaryCS
          gradient: LinearGradient(
            colors: [
              primaryCS.primary,
              primaryCS.primary.withValues(alpha: 0.9) // 使用 withValues 替代已棄用的 withOpacity
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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