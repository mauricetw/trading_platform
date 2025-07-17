import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'sign_in.dart';

// 為了方便單獨測試此頁面，保留 main 函式
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(), // App 入口為 LoginScreen
    );
  }
}

// --- 類別名稱已修改為 LoginScreen ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 藍色邊框
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0047AB), width: 10),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        margin: const EdgeInsets.all(10),
        child: Stack(
          children: [
            // 四個角落的白色小圓點
            Positioned(top: 0, left: 0, child: _buildCornerDot()),
            Positioned(top: 0, right: 0, child: _buildCornerDot()),
            Positioned(bottom: 0, left: 0, child: _buildCornerDot()),
            Positioned(bottom: 0, right: 0, child: _buildCornerDot()),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 內容布局
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 人物圖片
                        SizedBox(
                          height: 250,
                          width: 250,
                          // 使用 Image.asset 來載入本地圖片
                          // 請確保你在專案根目錄下有 assets/image/img.png 這個檔案
                          // 並且在 pubspec.yaml 中有設定 assets: - assets/image/
                          child: Image.asset(
                            'assets/image/img.png',
                            fit: BoxFit.contain,
                            // 當圖片載入失敗時，顯示一個替代圖示
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.people,
                                size: 120,
                                color: Colors.black54,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 登入按鈕
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9248),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '登入',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // 註冊按鈕
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5DFFA6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '註冊',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 底部文字
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 處理「發生問題」的點擊事件
                      },
                      child: const Text(
                        '發生問題了嗎？',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 輔助函式，建立角落的白色圓點
  Widget _buildCornerDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
