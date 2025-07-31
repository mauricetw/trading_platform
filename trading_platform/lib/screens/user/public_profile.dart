import 'package:flutter/material.dart';
import '../../models/user/user.dart';
import '../../../services/auth_service.dart'; // 示例

class PublicUserProfilePage extends StatefulWidget {
  final String userId;

  const PublicUserProfilePage({super.key, required this.userId});

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  // --- 示例狀態和服務 ---
  // User? _userProfile; // 用於存儲獲取到的用戶詳細信息
  // bool _isLoading = true;
  // String? _errorMessage;
  // final UserService _userService = UserService(); // 假設你有一個用戶服務

  @override
  void initState() {
    super.initState();
    // _fetchUserProfile(); // 在頁面初始化時獲取用戶數據
    print("PublicUserProfilePage: Displaying profile for User ID: ${widget.userId}");
  }

  // --- 示例：獲取用戶數據的方法 ---
  // Future<void> _fetchUserProfile() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });
  //   try {
  //     // final user = await _userService.getUserById(widget.userId);
  //     // 模擬網絡延遲和數據獲取
  //     await Future.delayed(const Duration(seconds: 1));
  //     // 假設 User 模型有一個構造函數，或者你從某處獲取模擬數據
  //     final user = User(
  //       id: widget.userId,
  //       username: '用戶 ${widget.userId}', // 示例用戶名
  //       email: 'user${widget.userId}@example.com', // 示例郵箱
  //       avatarUrl: '', // 示例頭像 URL
  //       // 其他你可能需要的字段
  //     );
  //
  //     setState(() {
  //       _userProfile = user;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = '無法加載用戶資料: $e';
  //       _isLoading = false;
  //     });
  //     print('Error fetching user profile: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用戶公開資料'),
        // 可以根據你的 App 主題調整
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // --- 根據加載狀態顯示不同內容的示例 ---
    // if (_isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    //
    // if (_errorMessage != null) {
    //   return Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    //           const SizedBox(height: 16),
    //           ElevatedButton(
    //             onPressed: _fetchUserProfile,
    //             child: const Text('重試'),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
    // }
    //
    // if (_userProfile == null) {
    //   return const Center(child: Text('未找到用戶資料。'));
    // }

    // --- 基礎的用戶信息顯示 ---
    // 這裡只是簡單顯示傳入的 userId，你需要根據實際需求擴展
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  // backgroundImage: _userProfile!.avatarUrl != null && _userProfile!.avatarUrl!.isNotEmpty
                  //     ? NetworkImage(_userProfile!.avatarUrl!)
                  //     : null,
                  // child: _userProfile!.avatarUrl == null || _userProfile!.avatarUrl!.isEmpty
                  //     ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                  //     : null,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 16),
                Text(
                  // _userProfile!.username, // '用戶名: ${widget.userId}'
                  '用戶名: 用戶 ${widget.userId}', // 示例
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${widget.userId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            '關於我:', // 示例部分
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '這裡可以顯示該用戶的公開介紹、評價、發布的商品等信息。\n當前用戶 ID 為: ${widget.userId}。',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // --- 在這裡添加更多用戶信息展示 ---
          // 例如：
          // - 用戶評價列表
          // - 用戶發布的商品列表
          // - 關注/粉絲按鈕等交互元素
        ],
      ),
    );
  }
}
