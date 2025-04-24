import 'package:flutter/material.dart';
import 'search.dart';
import 'annoucement.dart';
import 'profile.dart';
import 'chat_list.dart';

class MainMarket extends StatefulWidget {
  const MainMarket({super.key});

  static String routeName = 'MainMarket';
  static String routePath = '/main_market';

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0; // 用於追蹤目前顯示的頁面索引
  final PageController _pageController = PageController(initialPage: 0); // 用於管理 PageView

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose(); // 記得釋放 PageController
    super.dispose();
  }

  void _navigateToSearchPage() {
    String searchText = _searchController.text;
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

  // 當 PageView 的頁面被滑動切換時，這個函式會被呼叫
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index; // 更新目前頁面的索引
    });
  }

  // 當底部導航列的項目被點擊時，這個函式會被呼叫
  void _onItemTapped(int index) {
    _pageController.animateToPage(
        index, // 切換到指定的頁面
        duration: const Duration(milliseconds: 300), // 切換動畫的時間
        curve: Curves.ease); // 切換動畫的曲線
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _navigateToSearchPage,
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController, // 設定 PageView 的控制器
              onPageChanged: _onPageChanged, // 設定頁面切換時要執行的函式
              children: const [
                // 商品列表會在這裡顯示
                Center(
                  child: Text('商品列表會在這裡顯示'), // 之後要換成真正的商品列表
                ),
                ChatList(), // 訊息頁面
                Annoucement(), // 通知頁面
                Profile(), // 個人檔案頁面
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 設定目前選取的項目
        onTap: _onItemTapped, // 設定項目點擊時要執行的函式
        type: BottomNavigationBarType.fixed, // 添加這個屬性
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
    );
  }
}