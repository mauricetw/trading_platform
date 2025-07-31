// main_market.dart
import 'package:flutter/material.dart';
import 'search.dart';
import 'annoucement.dart';
import 'user/profile.dart';
import 'chatlist/chat_list.dart';
import 'home_page.dart';
import '../models/user/user.dart';
import '../widgets/market_search_bar.dart';
import 'package:first_flutter_project/theme/app_theme.dart'; // 導入包含 MyThemesExtension 的文件


class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  static String routeName = 'MainMarket';
  static String routePath = '/main_market';

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
    String searchText = _marketSearchController.text;
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(searchText: searchText),
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

    bool showMarketSearchBar = _currentIndex == 0;

    return Scaffold(
      // 現在你可以使用 primaryCS 中的顏色了
      // 例如，如果你想讓 Scaffold 的背景色來自你的 primaryCS:
      // backgroundColor: primaryCS.background,

      body: Column(
        children: [
          if (showMarketSearchBar)
            MarketSearchBar(
              controller: _marketSearchController,
              onSubmitted: (_) => _navigateToMarketSearchPage(),
              // 你可以將 primaryCS 或其顏色傳遞給 MarketSearchBar (如果它接受的話)
              // 例如： searchBarBackgroundColor: primaryCS.surface,
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 假設 HomePage 也想使用 primaryCS，它內部也需要類似的獲取邏輯
                // 或者你將 primaryCS 作為參數傳遞下去
                const HomePage(/* customScheme: primaryCS */),
                const ChatListScreen(),
                const AnnouncementListScreen(),
                Profile(currentUser: dummyUser /*, customScheme: primaryCS */),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // 使用 primaryCS 中的顏色來定義漸變
          gradient: LinearGradient(
            colors: [
              primaryCS.primary, // 例如使用 primaryCS.primary
              primaryCS.primary
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryCS.shadow?.withOpacity(0.1) ?? Colors.black.withOpacity(0.1), // 使用 primaryCS 中的陰影色
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // 因為背景由 Container 的 gradient 提供
          // selectedItemColor: primaryCS.onPrimary, // 選中項的顏色，來自 primaryCS
          // unselectedItemColor: primaryCS.onPrimary.withOpacity(0.7), // 未選中項的顏色
          selectedItemColor: primaryCS.secondary, // 或者使用 primaryCS.secondary
          unselectedItemColor: primaryCS.onSecondary,


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
