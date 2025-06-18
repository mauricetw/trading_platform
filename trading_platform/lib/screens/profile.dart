import 'package:first_flutter_project/screens/settings/setting.dart';
import 'package:flutter/material.dart';
import '../models/user/user.dart';
import 'cart.dart';
import 'review.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './auth/login_main.dart';


class Profile extends StatelessWidget {
  final User currentUser;
  const Profile({super.key, required this.currentUser});


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 判斷是否登入
    if (!authProvider.isLoggedIn) {
      // 延遲導航直到 build 完成，避免錯誤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())); // 替換成你的登入頁 route
      });

      return const Center(
        child: Text('請先登入', style: TextStyle(fontSize: 24)),
      );

    }

    final user = authProvider.currentUser!;

    //final user = currentUser;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 大頭貼
              CircleAvatar(
                radius: 50,
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
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 5),
              // 簡介/校名 (同一列)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.bio != null && user.bio!.isNotEmpty) Flexible(
                      child: Text(user.bio!, overflow: TextOverflow.ellipsis,)),
                  if (user.bio != null && user.bio!.isNotEmpty &&
                      user.schoolName != null &&
                      user.schoolName!.isNotEmpty) const SizedBox(width: 10),
                  if (user.schoolName != null &&
                      user.schoolName!.isNotEmpty) Flexible(child: Text(
                    user.schoolName!, overflow: TextOverflow.ellipsis,)),
                ],
              ),
              const SizedBox(height: 50),

              // *** 上下各兩個按鈕的垂直佈局 ***
              Column( // 外層使用 Column 垂直排列兩行按鈕
                children: [
                  Row( // 第一行按鈕
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // 在按鈕之間平均分配空間
                    children: [
                      // 收藏按鈕
                      Expanded( // 使用 Expanded 讓按鈕填充可用空間
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('點擊收藏');
                            // TODO: 導航到收藏頁面
                          },
                          icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                          ),
                          label: const Text('收藏'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF004E98),
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            textStyle: const TextStyle(fontSize: 18.0, color: Colors.white),
                            shape: RoundedRectangleBorder( // 添加圓角矩形邊框
                              borderRadius: BorderRadius.circular(
                                  100.0), // 調整圓角半徑
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0), // 設置按鈕之間的水平間距
                      // 購物車按鈕
                      Expanded( // 使用 Expanded 讓按鈕填充可用空間
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('點擊購物車');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CartPage()),
                            );
                          },
                          icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                          ),
                          label: const Text('購物車'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF004E98),
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            textStyle: const TextStyle(fontSize: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0), // 設置兩行按鈕之間的垂直間距
                  Row( // 第二行按鈕
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // 在按鈕之間平均分配空間
                    children: [
                      // 評價按鈕
                      Expanded( // 使用 Expanded 讓按鈕填充可用空間
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('點擊評價');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReviewPage()),
                            );
                          },
                          icon: const Icon(Icons.star_border),
                          label: const Text('評價'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF004E98),
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            textStyle: const TextStyle(fontSize: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0), // 設置按鈕之間的水平間距
                      // 設定按鈕
                      Expanded( // 使用 Expanded 讓按鈕填充可用空間
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('點擊設定');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined),
                          label: const Text('設定'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF004E98),
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            textStyle: const TextStyle(fontSize: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // *** 垂直佈局結束 ***

            ],
          ),
        ),
      ),
    );
  }
}