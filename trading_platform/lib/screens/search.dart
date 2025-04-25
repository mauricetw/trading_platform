import 'package:flutter/material.dart';
//改成使用stateful

class SearchPage extends StatelessWidget {
  final String searchText;

  const SearchPage({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: Center(
        child: Text('You searched for: $searchText'),
      ),
    );
  }
}