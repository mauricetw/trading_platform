import 'package:flutter/material.dart';
import '../models/user/user.dart';

class Profile extends StatelessWidget {
  // 這裡我們還是保留 currentUser，因為個人資料頁面通常需要顯示使用者資訊
  // 如果你真的希望一個完全沒有使用者資訊的頁面，那結構會完全不同
  final User currentUser;

  const Profile({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // 我們假設這個 Profile Widget 只在使用者已登入時顯示
    final user = currentUser;

    return Center(
      child: SingleChildScrollView( // 使用 SingleChildScrollView 避免內容超出螢幕
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 添加內邊距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // 讓 Column 中的內容居中對齊
            children: [
              // 大頭貼
              CircleAvatar(
                radius: 50,
                // 如果 avatarUrl 存在，使用 NetworkImage 顯示圖片
                // 否則顯示預設的 person 圖標
                backgroundImage: user.avatarUrl != null ? NetworkImage(
                    user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 10),
              // 使用者名稱/暱稱
              Text(
                user.username,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              // 簡介/校名 (同一列)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.bio != null && user.bio!.isNotEmpty) Flexible(
                      child: Text(user.bio!, overflow: TextOverflow.ellipsis,)),
                  // 如果簡介存在且不為空則顯示, 使用Flexible避免文字溢出
                  if (user.bio != null && user.bio!.isNotEmpty &&
                      user.schoolName != null &&
                      user.schoolName!.isNotEmpty) const SizedBox(width: 10),
                  // 如果簡介和校名都存在且不為空，添加間距
                  if (user.schoolName != null &&
                      user.schoolName!.isNotEmpty) Flexible(child: Text(
                    user.schoolName!, overflow: TextOverflow.ellipsis,)),
                  // 如果校名存在且不為空則顯示, 使用Flexible避免文字溢出
                ],
              ),
              const SizedBox(height: 20),
              // 功能按鈕列表 (只保留收藏和設定)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // 讓按鈕寬度填充父容器
                children: [
                  // 收藏按鈕
                  ElevatedButton.icon(
                    onPressed: () {
                      // 處理點擊收藏的邏輯
                      print('點擊收藏'); // 測試用
                      // TODO: 導航到收藏頁面
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('收藏'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft, // 按鈕內容靠左對齊
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  const SizedBox(height: 8), // 添加間距
                  // 設定按鈕
                  ElevatedButton.icon(
                    onPressed: () {
                      // 處理點擊設定的邏輯
                      print('點擊設定'); // 測試用
                      // TODO: 導航到設定頁面
                    },
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('設定'),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft, // 按鈕內容靠左對齊
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}