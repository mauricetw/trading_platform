// main_market.dart
import 'package:flutter/material.dart';
import 'search.dart';
import 'annoucement.dart';
import 'profile.dart';
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../models/user/user.dart';
import '../widgets/market_search_bar.dart'; // <--- Import the new search bar widget

class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  static String routeName = 'MainMarket';
  static String routePath = '/main_market';

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _marketSearchController = TextEditingController(); // Renamed for clarity
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _marketSearchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMarketSearchPage() { // Renamed for clarity
    String searchText = _marketSearchController.text;
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(searchText: searchText), // Assuming SearchPage is for market search
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter something to search')),
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
    final User dummyUser = User(
      id: 'test_user_id',
      username: '測試用戶',
      email: 'test@example.com',
      registeredAt: DateTime.now(),
      isSeller: true,
      bio: '這是一個測試帳號的簡介',
      schoolName: '測試大學',
    );

    // Determine if the market search bar should be visible
    bool showMarketSearchBar = _currentIndex == 0; // Show only for the first tab (HomePage)

    return Scaffold(
      body: Column(
        children: [
          // Conditionally display the MarketSearchBar
          if (showMarketSearchBar)
            MarketSearchBar(
              controller: _marketSearchController,
              onSubmitted: (_) => _navigateToMarketSearchPage(),
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(), // Optional: Disable swipe if you only want bottom nav control
              children: [
                const HomePage(),
                const ChatListScreen(),
                const Annoucement(),
                Profile(currentUser: dummyUser),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        // ... (your existing BottomNavigationBar Container decoration)
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: '訊息',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: '通知',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '個人檔案',
            ),
          ],
        ),
      ),
    );
  }
}