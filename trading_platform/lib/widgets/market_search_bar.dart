// market_search_bar.dart
import 'package:flutter/material.dart';

class MarketSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onTap; // Optional: if you want to handle tap separately

  const MarketSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004E98), Color(0xFF004E98)], // Matching MainMarket
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false, // SafeArea only for top if search bar is always at the top
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '輸入關鍵字查詢商品...', // More specific hint text
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: onSubmitted,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}