import 'package:flutter/material.dart';
import '../auth/sign_up.dart';
import '../auth/sign_in.dart';

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
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            Positioned(
              top: 0,
              left: 0,
              child: _buildCornerDot(),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCornerDot(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCornerDot(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCornerDot(),
            ),

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
                        Container(
                          height: 250,
                          width: 250,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/image/img.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          // 如果沒有實際圖片，可以使用以下替代方案
                          child: Image.asset('assets/image/img.png',
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.people,
                                  size: 120,
                                  color: Colors.black54,
                                );
                              }),
                        ),

                        const SizedBox(height: 30),

                        // 登入按鈕
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
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
                        // 處理點擊事件
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