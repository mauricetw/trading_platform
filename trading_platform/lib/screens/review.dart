// lib/review_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 需要安裝 flutter_rating_bar 套件

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模擬商品評價列表
    final List<Map<String, dynamic>> reviews = [
      {
        'reviewer': '用戶 A',
        'rating': 4.5,
        'comment': '這個商品很不錯，我很喜歡！',
        'date': '2023-10-27',
      },
      {
        'reviewer': '用戶 B',
        'rating': 5.0,
        'comment': '非常滿意，下次還會購買。',
        'date': '2023-10-26',
      },
      {
        'reviewer': '用戶 C',
        'rating': 3.0,
        'comment': '還行，但有一些小瑕疵。',
        'date': '2023-10-25',
      },
      // 添加更多模擬評價...
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品評價'),
      ),
      body: reviews.isEmpty // 檢查評價列表是否為空
          ? const Center(
        child: Text('目前沒有評價！'),
      )
          : ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card( // 使用 Card 來美化每個評價項目
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review['reviewer'],
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                      Text(
                        review['date'],
                        style: const TextStyle(fontSize: 12.0, color: Colors
                            .grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // 顯示星級評價，需要安裝 flutter_rating_bar 套件
                  RatingBarIndicator(
                    rating: review['rating'],
                    itemBuilder: (context, index) =>
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                    itemCount: 5,
                    itemSize: 20.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 8.0),
                  Text(review['comment']), // 評價內容
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}