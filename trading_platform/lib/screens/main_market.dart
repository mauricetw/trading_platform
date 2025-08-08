import 'package:flutter/material.dart';
import 'search.dart';
// 確保這些檔案存在
import 'announcement.dart';
import 'profile.dart';
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../widgets/market_search_bar.dart';

class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _marketSearchController = TextEditingController();
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

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
    // --- 清理：移除不再需要的 dummyUser ---
    bool showMarketSearchBar = _currentIndex == 0;

    return Scaffold(
      // 使用 AppBar 來放置搜尋框，更符合 Material Design
      appBar: showMarketSearchBar
          ? AppBar(
        title: MarketSearchBar(
          controller: _marketSearchController,
          onSubmitted: (_) => _navigateToMarketSearchPage(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      )
          : null, // 其他頁面不顯示 AppBar
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        // --- 修正：確保所有頁面都已建立 ---
        children: const [
          HomePage(),
          ChatListScreen(), // 確保 ChatListScreen widget 存在
          AnnouncementListScreen(), // 確保 AnnouncementListScreen widget 存在
          Profile(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004E98), Color(0xFF004198)],
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
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