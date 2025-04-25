import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            // backgroundImage: AssetImage('assets/profile_image.jpg'), // 可以設定大頭貼圖片
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('簡介'),
              SizedBox(width: 10),
              Text('校名'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // 處理點擊訂單
                },
                child: const Text('訂單'),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  // 處理點擊收藏
                },
                child: const Text('收藏'),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  // 處理點擊設定
                },
                child: const Text('設定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}